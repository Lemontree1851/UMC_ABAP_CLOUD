CLASS lsc_zzr_dtimp_files DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zzr_dtimp_files IMPLEMENTATION.

  METHOD save_modified.

    DATA: lv_job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZZ_JT_DATAIMPORT',
          ls_job_start_info    TYPE cl_apj_rt_api=>ty_start_info,
          lt_job_parameters    TYPE cl_apj_rt_api=>tt_job_parameter_value,
          lv_job_name          TYPE cl_apj_rt_api=>ty_jobname,
          lv_job_count         TYPE cl_apj_rt_api=>ty_jobcount.

    DATA lt_files TYPE TABLE OF zzr_dtimp_files.

    IF create-files IS NOT INITIAL.
      lt_files = CORRESPONDING #( create-files ).
    ELSEIF update-files IS NOT INITIAL.
      lt_files = CORRESPONDING #( update-files ).
    ENDIF.

    SELECT uuid_file
      FROM zzt_dtimp_start
       FOR ALL ENTRIES IN @lt_files
     WHERE uuid_file = @lt_files-uuidfile
      INTO TABLE @DATA(lt_files_start).         "#EC CI_FAE_NO_LINES_OK

    SORT lt_files_start BY uuid_file.

    LOOP AT lt_files ASSIGNING FIELD-SYMBOL(<lfs_file>) WHERE filecontent IS NOT INITIAL.
      CLEAR: ls_job_start_info,
             lt_job_parameters.

      READ TABLE lt_files_start TRANSPORTING NO FIELDS WITH KEY uuid_file = <lfs_file>-uuidfile BINARY SEARCH.
      IF sy-subrc = 0.
        EXIT.
      ENDIF.

      TRY.
          ls_job_start_info-start_immediately = abap_true.

          lt_job_parameters = VALUE #( ( name    = 'P_ID'
                                         t_value = VALUE #( ( sign   = 'I'
                                                              option = 'EQ'
                                                              low    = <lfs_file>-uuidfile ) ) ) ).
          " Schedule job
          cl_apj_rt_api=>schedule_job(
            EXPORTING
              iv_job_template_name   = lv_job_template_name
              iv_job_text            = |Batch Data Import Job of { <lfs_file>-uuidfile }|
              is_start_info          = ls_job_start_info
              it_job_parameter_value = lt_job_parameters
            IMPORTING
              ev_jobname             = lv_job_name
              ev_jobcount            = lv_job_count ).

          GET TIME STAMP FIELD DATA(lv_timestamp).
          INSERT INTO zzt_dtimp_start VALUES @( VALUE #( uuid_file       = <lfs_file>-uuidfile
                                                         created_by      = sy-uname
                                                         created_at      = lv_timestamp
                                                         last_changed_by = sy-uname
                                                         last_changed_at = lv_timestamp
                                                         local_last_changed_at = lv_timestamp ) ).
        CATCH cx_apj_rt INTO DATA(lo_apj_rt).

          APPEND VALUE #( uuidfile = <lfs_file>-uuidfile
                          %msg     = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                            text     = lo_apj_rt->bapimsg-message ) )
              TO reported-files.

        CATCH cx_root INTO DATA(lo_root).

          APPEND VALUE #(  uuidfile = <lfs_file>-uuidfile
                           %msg     = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = |Exception: { lo_root->get_text(  ) }| ) )
              TO reported-files.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_zzr_dtimp_files DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR files
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR files RESULT result,
      validationmandatory FOR VALIDATE ON SAVE
        IMPORTING keys FOR files~validationmandatory.
ENDCLASS.

CLASS lhc_zzr_dtimp_files IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zzr_dtimp_files IN LOCAL MODE
    ENTITY files
    FIELDS ( uuidfile jobname )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_files)
    FAILED failed.

    result = VALUE #( FOR file IN lt_files
                        ( %tky         = file-%tky
                          %delete      = COND #( WHEN file-jobname IS NOT INITIAL
                                                 THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
                          %update      = COND #( WHEN file-jobname IS NOT INITIAL
                                                 THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
                          %action-edit = COND #( WHEN file-jobname IS NOT INITIAL
                                                 THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
                     ) ).
  ENDMETHOD.

  METHOD validationmandatory.
    READ ENTITIES OF zzr_dtimp_files IN LOCAL MODE
    ENTITY files
    FIELDS ( uuidconf filecontent )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_files).

    LOOP AT lt_files ASSIGNING FIELD-SYMBOL(<lfs_file>).
      IF <lfs_file>-uuidconf IS INITIAL.
        APPEND VALUE #( %tky = <lfs_file>-%tky ) TO failed-files.
        APPEND VALUE #( %tky = <lfs_file>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = 'Import Object is mandatory.' )
                        %element-uuidconf = if_abap_behv=>mk-on
                       ) TO reported-files.
      ENDIF.
*      IF <lfs_file>-FileContent IS INITIAL.
*        APPEND VALUE #( %tky = <lfs_file>-%tky ) TO failed-files.
*        APPEND VALUE #( %tky = <lfs_file>-%tky
*                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                      text = 'Upload File is mandatory.' )
*                        %element-filecontent = if_abap_behv=>mk-on
*                       ) TO reported-files.
*      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
