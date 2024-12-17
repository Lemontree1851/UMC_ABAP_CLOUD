CLASS zzcl_dtimp_process DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mo_application_log TYPE REF TO if_bali_log,
          mo_table           TYPE REF TO data,
          mo_out             TYPE REF TO if_oo_adt_classrun_out.

    DATA: ms_configuration TYPE STRUCTURE FOR READ RESULT zzr_dtimp_conf,
          ms_file          TYPE STRUCTURE FOR READ RESULT zzr_dtimp_files.

    DATA: mv_uuid TYPE sysuuid_x16.

    METHODS:
      get_parameter_id IMPORTING it_parameters TYPE if_apj_dt_exec_object=>tt_templ_val,

      init_application_log,
      save_job_info,

      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime,

      get_file_content IMPORTING i_uuid TYPE sysuuid_x16,
      get_configuration IMPORTING i_uuid TYPE sysuuid_x16,
      get_data_from_excel,
      process_logic.
ENDCLASS.



CLASS ZZCL_DTIMP_PROCESS IMPLEMENTATION.


  METHOD add_message_to_log.
    TRY.
        IF sy-batch = abap_true.
          DATA(lo_free_text) = cl_bali_free_text_setter=>create(
                                 severity = COND #( WHEN i_type IS NOT INITIAL
                                                    THEN i_type
                                                    ELSE if_bali_constants=>c_severity_status )
                                 text     = i_text ).

          lo_free_text->set_detail_level( detail_level = '1' ).

          mo_application_log->add_item( item = lo_free_text ).

          cl_bali_log_db=>get_instance( )->save_log( log = mo_application_log
                                                     assign_to_current_appl_job = abap_true ).

        ELSE.
*          mo_out->write( i_text ).
        ENDIF.
        ##NO_HANDLER
      CATCH cx_bali_runtime INTO DATA(lx_bali_runtime).
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD get_configuration.
    READ ENTITY zzr_dtimp_conf
    ALL FIELDS WITH VALUE #( (  %key-uuidconf = ms_file-uuidconf ) )
    RESULT FINAL(lt_configuration).

    IF lt_configuration IS NOT INITIAL.
      ms_configuration = lt_configuration[ 1 ].
    ENDIF.
  ENDMETHOD.


  METHOD get_data_from_excel.
    TRY.
        " create internal table
        CREATE DATA mo_table TYPE TABLE OF (ms_configuration-structurename).

        " read excel object
        DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( ms_file-filecontent ).
        DATA(lo_worksheet) = lo_document->read_access(  )->get_workbook(
                             )->worksheet->for_name( CONV string( ms_configuration-sheetname ) ).

        DATA(lv_sheet_exists) = lo_worksheet->exists(  ).
        IF lv_sheet_exists = abap_false.
          TRY.
              add_message_to_log( i_text = |Sheet { ms_configuration-sheetname } does not exist in the data file.|
                                  i_type = if_bali_constants=>c_severity_error ).
              ##NO_HANDLER
            CATCH cx_bali_runtime.
              " handle exception
          ENDTRY.
          RETURN.
        ENDIF.

        DATA(lo_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
        )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( ms_configuration-startrow )
        )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( ms_configuration-startcolumn )
        )->get_pattern(  ).

        lo_worksheet->select( lo_pattern )->row_stream(  )->operation->write_to( mo_table )->execute(  ).
      CATCH cx_sy_create_data_error INTO DATA(lx_sy_create_data_error).
        TRY.
            add_message_to_log( i_text = |Data structure of Import Object { ms_configuration-objectname } not found.|
                                i_type = if_bali_constants=>c_severity_error ).
            ##NO_HANDLER
          CATCH cx_bali_runtime.
            " handle exception
        ENDTRY.
    ENDTRY.
  ENDMETHOD.


  METHOD get_file_content.
    READ ENTITY zzr_dtimp_files
    ALL FIELDS WITH VALUE #( ( %key-uuidfile = i_uuid ) )
    RESULT FINAL(lt_file).

    IF lt_file IS NOT INITIAL.
      ms_file = lt_file[ 1 ].
    ENDIF.
  ENDMETHOD.


  METHOD get_parameter_id.
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_ID'.
          mv_uuid = ls_parameter-low.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #( ( selname        = 'P_ID'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'X'
                                  length         = 16
                                  param_text     = 'UUID of stored file'
                                  changeable_ind = abap_true ) ).

    " Return the default parameters values here
    " et_parameter_val
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    " get parameter id
    get_parameter_id( it_parameters ).

    " create log handle
    init_application_log(  ).

    " save job info to ZZC_DTIMP_FILES
    save_job_info(  ).

    IF mv_uuid IS INITIAL.
      TRY.
          add_message_to_log( i_text = |Record for UUID { mv_uuid } not found.|
                              i_type = if_bali_constants=>c_severity_error ).
          ##NO_HANDLER
        CATCH cx_bali_runtime.
          " handle exception
      ENDTRY.
      RETURN.
    ENDIF.

    TRY.
        add_message_to_log( |Process batch import UUID of { mv_uuid }| ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.

    " get file content
    get_file_content( mv_uuid ).

    TRY.
        add_message_to_log( |File name: { ms_file-filename }| ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.

    IF ms_file IS INITIAL.
      TRY.
          add_message_to_log( i_text = |Record for File UUID { mv_uuid } not found.|
                              i_type = if_bali_constants=>c_severity_error ).
          ##NO_HANDLER
        CATCH cx_bali_runtime.
          " handle exception
      ENDTRY.
      RETURN.
    ENDIF.

    IF ms_file-filecontent IS INITIAL.
      TRY.
          add_message_to_log( i_text = |File not found.|
                              i_type = if_bali_constants=>c_severity_error ).
          ##NO_HANDLER
        CATCH cx_bali_runtime.
          " handle exception
      ENDTRY.
      RETURN.
    ENDIF.

    " get configuration
    get_configuration( mv_uuid ).

    TRY.
        add_message_to_log( |Import object: { ms_configuration-objectname }| ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.

    " read excel
    IF ms_configuration IS INITIAL.
      TRY.
          add_message_to_log( i_text = |Configuration not found for this batch import record.|
                              i_type = if_bali_constants=>c_severity_error ).
          ##NO_HANDLER
        CATCH cx_bali_runtime.
          " handle exception
      ENDTRY.
      RETURN.
    ENDIF.

    get_data_from_excel( ).

    IF mo_table IS INITIAL.
      TRY.
          add_message_to_log( i_text = |No data was read from the file.|
                              i_type = if_bali_constants=>c_severity_error ).
          ##NO_HANDLER
        CATCH cx_bali_runtime.
          " handle exception
      ENDTRY.
      RETURN.
    ENDIF.

    TRY.
        add_message_to_log( |Batch data import - Start.| ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.

    " call function module
    process_logic( ).

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
*    " for debugger => 请使用类 zcl_debug_job
*    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.
*    lt_parameters = VALUE #( ( selname = 'P_ID'
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = 'A1405D901B3B1EEFA9E82B9A5D1A95E1' ) ).
*    TRY.
*        if_apj_rt_exec_object~execute( it_parameters = lt_parameters ).
*      CATCH cx_root INTO DATA(lo_root).
*        out->write( |Exception has occured: { lo_root->get_text(  ) }| ).
*    ENDTRY.
  ENDMETHOD.


  METHOD init_application_log.
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object      = 'ZZ_LOG_DTIMP'
                                                                       subobject   = 'ZZ_LOG_DTIMP_SUB'
                                                                       external_id = CONV #( mv_uuid ) ) ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD process_logic.
    DATA: lt_ptab TYPE abap_func_parmbind_tab,
          lo_data TYPE REF TO data ##NEEDED.
    FIELD-SYMBOLS : <lfs_table> TYPE STANDARD TABLE.

    lt_ptab = VALUE #( ( name  = 'IO_DATA'
                         kind  = abap_func_exporting
                         value = REF #( mo_table ) )
                       ( name  = 'IV_STRUC'
                         kind  = abap_func_exporting
                         value = REF #( ms_configuration-structurename ) )
                       ( name  = 'EO_DATA'
                         kind  = abap_func_importing
                         value = REF #( lo_data ) ) ).

    DATA(lv_has_error) = abap_false.

    TRY.
        CALL FUNCTION ms_configuration-functionname PARAMETER-TABLE lt_ptab.
      CATCH cx_root.
        " handle exception
        lv_has_error = abap_true.
        TRY.
            add_message_to_log( i_text = |The logic processing function contains errors.|
                                i_type = if_bali_constants=>c_severity_error ).
            ##NO_HANDLER
          CATCH cx_bali_runtime.
            " handle exception
        ENDTRY.
        RETURN.
    ENDTRY.

    TRY.
        ASSIGN lo_data->* TO <lfs_table>.
      CATCH cx_bali_runtime.
        " handle exception
        lv_has_error = abap_true.
    ENDTRY.

    " save log
    LOOP AT <lfs_table> ASSIGNING FIELD-SYMBOL(<lfs_table_line>).
      TRY.
          add_message_to_log( i_text = |Line: { sy-tabix }, status: { <lfs_table_line>-('type') }, message: {  <lfs_table_line>-('message') }|
                              i_type = COND #( WHEN <lfs_table_line>-('type') = if_bali_constants=>c_severity_error
                                               THEN if_bali_constants=>c_severity_warning
                                               ELSE <lfs_table_line>-('type') ) ).
          IF <lfs_table_line>-('type') = if_bali_constants=>c_severity_error.
            lv_has_error = abap_true.
          ENDIF.
        CATCH cx_bali_runtime.
          " handle exception
          lv_has_error = abap_true.
      ENDTRY.
    ENDLOOP.

    IF lv_has_error = abap_true.
      TRY.
          add_message_to_log( i_text = |Batch import processing contains errors.|
                              i_type = if_bali_constants=>c_severity_error ).
          ##NO_HANDLER
        CATCH cx_bali_runtime.
          " handle exception
      ENDTRY.
    ELSE.
      TRY.
          add_message_to_log( |Batch data import - Completed.| ).
          ##NO_HANDLER
        CATCH cx_bali_runtime.
          " handle exception
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD save_job_info.
    IF sy-batch = abap_true.
      DATA(lv_loghandle) = mo_application_log->get_handle( ).
      TRY.
          cl_apj_rt_api=>get_job_runtime_info( IMPORTING ev_jobname        = DATA(lv_jobname)
                                                         ev_jobcount       = DATA(lv_jobcount)
                                                         ev_catalog_name   = DATA(lv_catalog)
                                                         ev_template_name  = DATA(lv_template) ).
          ##NO_HANDLER
        CATCH cx_apj_rt.
          " handle exception
      ENDTRY.

      MODIFY ENTITY zzr_dtimp_files
      UPDATE FIELDS ( jobname jobcount loghandle )
      WITH VALUE #( ( jobname   = lv_jobname
                      jobcount  = lv_jobcount
                      loghandle = lv_loghandle
                      uuidfile  = mv_uuid ) ).
      COMMIT ENTITIES.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
