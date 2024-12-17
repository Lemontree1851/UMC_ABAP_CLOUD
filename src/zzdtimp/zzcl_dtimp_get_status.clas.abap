CLASS zzcl_dtimp_get_status DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_DTIMP_GET_STATUS IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA lt_original_data TYPE STANDARD TABLE OF zzc_dtimp_files WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    IF lt_original_data IS NOT INITIAL.
      SELECT uuidfile,
             filename,
             jobname,
             jobcount,
             loghandle
        FROM zzc_dtimp_files
         FOR ALL ENTRIES IN @lt_original_data
       WHERE uuidfile = @lt_original_data-uuidfile
        INTO TABLE @DATA(lt_files).
      SORT lt_files BY uuidfile.
    ENDIF.

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).

      READ TABLE lt_files INTO DATA(ls_file) WITH KEY uuidfile = <fs_original_data>-uuidfile BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_original_data>-filename  = ls_file-filename.
        <fs_original_data>-jobname   = ls_file-jobname.
        <fs_original_data>-jobcount  = ls_file-jobcount.
        <fs_original_data>-loghandle = ls_file-loghandle.
      ENDIF.

      TRY.
          IF <fs_original_data>-jobname IS NOT INITIAL AND <fs_original_data>-jobcount IS NOT INITIAL.

            DATA(ls_job_info) = cl_apj_rt_api=>get_job_details( iv_jobname  = CONV #( <fs_original_data>-jobname )
                                                                iv_jobcount = CONV #( <fs_original_data>-jobcount ) ).

            <fs_original_data>-jobstatus = ls_job_info-status.
            <fs_original_data>-jobstatustext = ls_job_info-status_text.

            CASE ls_job_info-status.
              WHEN 'F'. "Finished
                <fs_original_data>-jobstatuscriticality = 3.
              WHEN 'A'. "Aborted
                <fs_original_data>-jobstatuscriticality = 1.
              WHEN 'R'. "Running
                <fs_original_data>-jobstatuscriticality = 2.
              WHEN OTHERS.
                <fs_original_data>-jobstatuscriticality = 0.
            ENDCASE.

            <fs_original_data>-logstatus = ls_job_info-logstatus.

            CASE ls_job_info-logstatus.
              WHEN 'S'. "Finished
                <fs_original_data>-logstatustext = 'Success'.
                <fs_original_data>-logstatuscriticality = 3.
              WHEN 'E'. "Aborted
                <fs_original_data>-logstatustext = 'Error'.
                <fs_original_data>-logstatuscriticality = 1.
              WHEN OTHERS.
                <fs_original_data>-logstatustext = 'None'.
                <fs_original_data>-logstatuscriticality = 0.
            ENDCASE.

*            DATA(lv_loghandle) = cl_web_http_utility=>escape_url( CONV #( <fs_original_data>-loghandle ) ).

*            DATA(lv_uri) = cl_abap_context_info=>get_system_url( ).
*
*            DATA(lv_url) = |https://{ lv_uri }/ui#ApplicationJob-show?JobCatalogEntryName=&/v4_JobRunLog/%252F| &&
*                           |ApplicationLogOverviewSet('{ lv_loghandle }')%20%252F| &&
*                           |JobRunOverviewSet(JobName%253D'{ <fs_original_data>-jobname }'%252C| &&
*                           |JobRunCount='{ <fs_original_data>-jobcount }')%20default|.
*
*            <fs_original_data>-applicationlogurl = lv_url.

          ELSEIF <fs_original_data>-filename IS NOT INITIAL.
            <fs_original_data>-jobstatus = 'R'.
            <fs_original_data>-jobstatustext = 'Running'.
            <fs_original_data>-jobstatuscriticality = 2.
          ELSE.
            <fs_original_data>-jobstatus = 'N'.
            <fs_original_data>-jobstatustext = 'None'.
            <fs_original_data>-jobstatuscriticality = 2.
          ENDIF.
        CATCH cx_apj_rt INTO DATA(lo_apj_rt).
          <fs_original_data>-jobstatus = 'E'.
          <fs_original_data>-jobstatustext = lo_apj_rt->get_text(  ).
          <fs_original_data>-jobstatuscriticality = 0.
        CATCH cx_root INTO DATA(lo_root).
          <fs_original_data>-jobstatus = 'E'.
          <fs_original_data>-jobstatustext = lo_root->get_text(  ).
          <fs_original_data>-jobstatuscriticality = 0.
      ENDTRY.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
