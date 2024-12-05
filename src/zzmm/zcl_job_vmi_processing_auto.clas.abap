CLASS zcl_job_vmi_processing_auto DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS:
      init_application_log,
      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime.
    CLASS-DATA:
      mo_application_log TYPE REF TO if_bali_log.
ENDCLASS.

CLASS zcl_job_vmi_processing_auto IMPLEMENTATION.
  METHOD if_apj_dt_exec_object~get_parameters.
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.
    DATA:
      lt_results TYPE zcl_vmi_processing_auto=>tt_ztmm_1010,
      lv_message TYPE cl_bali_free_text_setter=>ty_text,
      lv_type    TYPE cl_bali_free_text_setter=>ty_severity.

    "获取日志对象
    init_application_log( ).

*    DATA:
*      lt_ztmm_1010 TYPE STANDARD TABLE OF ztmm_1010,
*      ls_ztmm_1010 TYPE ztmm_1010,
*      lv_timestamp TYPE timestamp.
*
*    GET TIME STAMP FIELD lv_timestamp.
*    ls_ztmm_1010-uuid = lv_timestamp.
*    CONDENSE ls_ztmm_1010-uuid.
*    ls_ztmm_1010-material = 'ZTEST_RAW001'.
*    ls_ztmm_1010-quantity = 1.
*    ls_ztmm_1010-unit = 'ST'.
*    ls_ztmm_1010-storagelocation = 'A02Y'.
*    ls_ztmm_1010-plant = '1100'.
*    ls_ztmm_1010-customer = '0000010002'.
*    ls_ztmm_1010-documentdate = cl_abap_context_info=>get_system_date( ).
*    ls_ztmm_1010-postingdate = cl_abap_context_info=>get_system_date( ).
*    ls_ztmm_1010-created_at = lv_timestamp.
*    ls_ztmm_1010-created_by = sy-uname.
*
*    MODIFY ztmm_1010 FROM @ls_ztmm_1010.
*    COMMIT WORK AND WAIT.
*update ztmm_1010 set plant = '1400',customer = 'H10001' ,storagelocation = 'H1U3' WHERE CUSTOMER = '0001000122'.
*COMMIT WORK AND WAIT.

    TRY.
        zcl_vmi_processing_auto=>execute(
      IMPORTING
        et_results = lt_results ).
      CATCH zzcx_custom_exception INTO DATA(lx_zzcx_custom_exception).
        lv_message = lx_zzcx_custom_exception->get_text( ).

        TRY.
            add_message_to_log( i_text = lv_message i_type = 'E' ).
          CATCH cx_bali_runtime ##NO_HANDLER.
        ENDTRY.
    ENDTRY.

    IF lv_message IS INITIAL.
      IF lt_results IS NOT INITIAL.
        "顧客VMI自動処理は処理済ですので、チェックしてください
        MESSAGE ID 'ZMM_001' TYPE 'S' NUMBER 021 INTO lv_message.

        TRY.
            add_message_to_log( i_text = lv_message i_type = 'S' ).
          CATCH cx_bali_runtime ##NO_HANDLER.
        ENDTRY.

        LOOP AT lt_results INTO DATA(ls_results).
          IF ls_results-materialdocument IS NOT INITIAL.
            lv_type = 'S'.

            "UUID &1 处理成功: &2 &3
            MESSAGE ID 'ZMM_001' TYPE 'S' NUMBER 022 WITH ls_results-uuid ls_results-materialdocument ls_results-materialdocumentyear INTO lv_message.
          ELSE.
            lv_type = 'E'.

            "UUID &1 处理失败: &2
            MESSAGE ID 'ZMM_001' TYPE 'S' NUMBER 023 WITH ls_results-uuid ls_results-message INTO lv_message.
          ENDIF.

          TRY.
              add_message_to_log( i_text = lv_message i_type = lv_type ).
            CATCH cx_bali_runtime ##NO_HANDLER.
          ENDTRY.
        ENDLOOP.
      ELSE.
        "没有需要处理的顾客VMI
        MESSAGE ID 'ZMM_001' TYPE 'S' NUMBER 024 INTO lv_message.

        TRY.
            add_message_to_log( i_text = lv_message i_type = 'S' ).
          CATCH cx_bali_runtime ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.

    "for debugger
    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.
*    lt_parameters = VALUE #( ( selname = 'P_ID'
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '8B3CF2B54B611EEFA2D72EB68B20D50C' ) ).
    TRY.
*        if_apj_rt_exec_object~execute( it_parameters = lt_parameters ).
        if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_root INTO DATA(lo_root).
        out->write( |Exception has occured: { lo_root->get_text(  ) }| ).
    ENDTRY.
  ENDMETHOD.

  METHOD init_application_log.
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object      = 'ZZ_LOG_MM037'
                                                                       subobject   = 'ZZ_LOG_MM037_SUB'
*                                                                       external_id = CONV #( mv_uuid )
                                                                       ) ).
      CATCH cx_bali_runtime ##NO_HANDLER.

    ENDTRY.
  ENDMETHOD.

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
      CATCH cx_bali_runtime INTO DATA(lx_bali_runtime) ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
