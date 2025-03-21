CLASS lhc_zc_inventoryrequirement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_inventoryrequirement RESULT result.

*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE zc_inventoryrequirement.
*
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE zc_inventoryrequirement.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE zc_inventoryrequirement.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_inventoryrequirement RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_inventoryrequirement.

    METHODS schedulemrpsynchronous FOR MODIFY
      IMPORTING keys FOR ACTION zc_inventoryrequirement~schedulemrpsynchronous RESULT result.

    METHODS getmrpsynchronoustime FOR MODIFY
      IMPORTING keys FOR ACTION zc_inventoryrequirement~getmrpsynchronoustime RESULT result.

ENDCLASS.

CLASS lhc_zc_inventoryrequirement IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD create.
*  ENDMETHOD.
*
*  METHOD update.
*  ENDMETHOD.
*
*  METHOD delete.
*  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

*&--ADD BEGIN BY XINLEI XU 2025/03/21 CM#4333
  METHOD schedulemrpsynchronous.
    DATA: lv_job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZJT_SUPPLYDEMAND',
          ls_job_start_info    TYPE cl_apj_rt_api=>ty_start_info,
          lt_job_parameters    TYPE cl_apj_rt_api=>tt_job_parameter_value,
          lv_job_text          TYPE cl_apj_rt_api=>ty_job_text,
          lv_job_name          TYPE cl_apj_rt_api=>ty_jobname,
          lv_job_count         TYPE cl_apj_rt_api=>ty_jobcount,
          lv_message           TYPE string.

    DATA: BEGIN OF ls_result,
            jobname       TYPE string,
            scheduleuser  TYPE string,
            schedulebegin TYPE string,
          END OF ls_result.

    " Only one record
    LOOP AT keys INTO DATA(key).
      TRY.
          ls_job_start_info-start_immediately = abap_true.

          TRY.
              DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
              ##NO_HANDLER
            CATCH cx_uuid_error.
              " handle exception
          ENDTRY.
          lt_job_parameters = VALUE #( ( name    = 'P_ID'
                                         t_value = VALUE #( ( sign   = 'I'
                                                              option = 'EQ'
                                                              low    = lv_uuid ) ) ) ).

          lv_job_text = |MRPデータ同期 - 在庫所要量一覧レポートより起動 { lv_uuid }|.

          " Schedule job
          cl_apj_rt_api=>schedule_job(
            EXPORTING
              iv_job_template_name   = lv_job_template_name
              iv_job_text            = lv_job_text
              is_start_info          = ls_job_start_info
              it_job_parameter_value = lt_job_parameters
            IMPORTING
              ev_jobname             = lv_job_name
              ev_jobcount            = lv_job_count
              et_message             = DATA(et_message) ).

          GET TIME STAMP FIELD DATA(lv_timestamp).
          INSERT INTO ztbc_1021 VALUES @( VALUE #( uuid = lv_uuid
                                                   schedule_user = key-%param-zzkey
                                                   schedule_begin = lv_timestamp
                                                   job_name = lv_job_name
                                                   job_count = lv_job_count
                                                   job_text = lv_job_text ) ).

          ls_result = VALUE #( jobname = lv_job_name
                               scheduleuser = key-%param-zzkey
                               schedulebegin = lv_timestamp ).
          DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_result ).
          APPEND VALUE #( %cid   = key-%cid
                          %param = VALUE #( event = 'S'
                                            zzkey = lv_json ) ) TO result.
        CATCH cx_apj_rt INTO DATA(lo_apj_rt).
          IF lo_apj_rt->bapimsg-message IS NOT INITIAL.
            lv_message = lo_apj_rt->bapimsg-message.
          ELSE.
            READ TABLE et_message INTO DATA(msg) WITH KEY type = 'E'.
            lv_message = msg-message.
          ENDIF.
          APPEND VALUE #( %cid   = key-%cid
                          %param = VALUE #( event = 'E'
                                            zzkey = lv_message ) ) TO result.
        CATCH cx_root INTO DATA(lo_root).
          APPEND VALUE #( %cid   = key-%cid
                          %param = VALUE #( event = 'E'
                                            zzkey = |Exception: { lo_root->get_text(  ) }| ) ) TO result.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD getmrpsynchronoustime.
    DATA: BEGIN OF ls_result,
            scheduleuser  TYPE string,
            schedulebegin TYPE string,
            scheduleend   TYPE string,
          END OF ls_result.

    " Only one record
    LOOP AT keys INTO DATA(key).
      CLEAR ls_result.

      SELECT SINGLE * FROM ztbc_1021 WHERE schedule_end IS INITIAL INTO @DATA(ls_schedule).
      IF sy-subrc = 0.
        ls_result-scheduleuser = ls_schedule-schedule_user.
        IF ls_schedule-schedule_begin IS NOT INITIAL.
          ls_result-schedulebegin = ls_schedule-schedule_begin.
        ENDIF.
        IF ls_schedule-schedule_end IS NOT INITIAL.
          ls_result-scheduleend = ls_schedule-schedule_end.
        ENDIF.
      ELSE.
        SELECT CAST( MAX( last_changed_at ) AS CHAR ) FROM ztbc_1020 INTO @DATA(lv_tstmpl).
        IF lv_tstmpl IS NOT INITIAL.
          ls_result-scheduleend = lv_tstmpl+0(14).
        ENDIF.
      ENDIF.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_result ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( zzkey = lv_json ) ) TO result.

    ENDLOOP.
  ENDMETHOD.
*&--ADD END BY XINLEI XU 2025/03/21 CM#4333

ENDCLASS.

CLASS lsc_zc_inventoryrequirement DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_inventoryrequirement IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
