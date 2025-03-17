CLASS zcl_job_factory_holiday DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .

    CLASS-DATA out TYPE REF TO if_oo_adt_classrun_out.
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



CLASS ZCL_JOB_FACTORY_HOLIDAY IMPLEMENTATION.


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
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    " 获取日志对象
    init_application_log( ).

    DATA:
      lv_date   TYPE datum,
      is_error  TYPE abap_boolean,
      lt_pp1018 TYPE TABLE OF ztpp_1018,
      ls_pp1018 LIKE LINE OF lt_pp1018.


    SELECT
      plant
    FROM i_plant WITH PRIVILEGED ACCESS
    INTO TABLE @DATA(lt_plant).

    LOOP AT lt_plant INTO DATA(ls_plant).
      lv_date = cl_abap_context_info=>get_system_date( ).
      lv_date = lv_date(4) && '0101'.
      "3年加25天
      DO 1120 TIMES.
        ls_pp1018-plant = ls_plant-plant.

        IF NOT zzcl_common_utils=>is_workingday( iv_plant = ls_plant-plant iv_date = lv_date ).
          ls_pp1018-holiday_date = lv_date.
          ls_pp1018-next_workday = zzcl_common_utils=>get_workingday( iv_plant = ls_plant-plant iv_date = lv_date ).
          APPEND ls_pp1018 TO lt_pp1018.
        ENDIF.
        lv_date = lv_date + 1.
      ENDDO.
    ENDLOOP.

    is_error = abap_false.
    DELETE FROM ztpp_1018 WHERE plant IS NOT INITIAL.
    IF sy-subrc <> 0 AND sy-subrc <> 4.
      is_error = abap_true.
    ENDIF.
    MODIFY ztpp_1018 FROM TABLE @lt_pp1018.
    IF sy-subrc <> 0.
      is_error = abap_true.
    ENDIF.
    IF is_error = abap_true.
      ROLLBACK WORK.
*      out->write( 'Failed' ).
      TRY.
          add_message_to_log( i_text = 'Failed' i_type = 'E' ).
        CATCH cx_bali_runtime ##NO_HANDLER.
      ENDTRY.
    ELSE.
      COMMIT WORK.
*      out->write( 'Successed' ).
      TRY.
          add_message_to_log( i_text = 'Successed' i_type = 'S' ).
        CATCH cx_bali_runtime ##NO_HANDLER.
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    " main method for debugger
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
                               header = cl_bali_header_setter=>create( object      = 'ZZ_LOG_MM015'
                                                                       subobject   = 'ZZ_LOG_MM015_SUB'
*                                                                       external_id = CONV #( mv_uuid )
                                                                       ) ).
      CATCH cx_bali_runtime ##NO_HANDLER.
        " handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
