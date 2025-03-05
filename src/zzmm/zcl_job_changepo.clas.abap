CLASS zcl_job_changepo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS: compay_code_befor TYPE bukrs VALUE '1400',
               compay_code_after TYPE bukrs VALUE '1100',
               purchase_org      TYPE ekorg VALUE '1000',
               plant             TYPE werks_d VALUE '1400'.
    CLASS-METHODS:
      init_application_log,
      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime.
    CLASS-DATA:
      mo_application_log TYPE REF TO if_bali_log.
ENDCLASS.



CLASS ZCL_JOB_CHANGEPO IMPLEMENTATION.


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

    SELECT DISTINCT
      _item~purchaseorder
    FROM i_purchaseorderapi01 AS _head
    LEFT JOIN i_purchaseorderitemapi01 AS _item
      ON _head~purchaseorder = _item~purchaseorder
    WHERE _head~companycode = @compay_code_befor
      AND _head~purchasingorganization = @purchase_org
      AND _item~plant = @plant
    INTO TABLE @DATA(lt_purchaseorder).

*    DATA: lt_prucahseorde_head TYPE TABLE FOR UPDATE i_purchaseordertp_2.
*    CLEAR lt_prucahseorde_head.
    DATA lv_msg TYPE cl_bali_free_text_setter=>ty_text .
    LOOP AT lt_purchaseorder INTO DATA(ls_purchaseorder).
*      APPEND VALUE #( purchaseorder = ls_purchaseorder-purchaseorder
*                      companycode = compay_code_after
*                      %control-companycode = 1 ) TO lt_prucahseorde_head.
      "BOI 虽然传值结构是一个内表，但是对于抬头数据一次依然只能传递一个key值
      MODIFY ENTITIES OF i_purchaseordertp_2
        ENTITY purchaseorder
        UPDATE FROM VALUE #( (  purchaseorder = ls_purchaseorder-purchaseorder
                                companycode = compay_code_after
                                %control-companycode = 1 ) )
        MAPPED DATA(mapped)
        FAILED DATA(failed)
        REPORTED DATA(reported).

      IF failed IS INITIAL.
        CLEAR lv_msg.
        MESSAGE s016(zmm_001) WITH ls_purchaseorder-purchaseorder INTO lv_msg.
        TRY.
            add_message_to_log( i_text = lv_msg i_type = 'S' ).
          CATCH cx_bali_runtime ##NO_HANDLER.
        ENDTRY.
        COMMIT ENTITIES.
      ELSE.
        LOOP AT reported-purchaseorder INTO DATA(reported_head).
          CLEAR lv_msg.
          MESSAGE e017(zmm_001) WITH reported_head-purchaseorder INTO lv_msg.
          DATA(lv_msgtext) = cl_message_helper=>get_text_for_message( reported_head-%msg ).
          TRY.
              add_message_to_log( i_text = lv_msg i_type = 'E' ).
              add_message_to_log( i_text = CONV #( lv_msgtext ) i_type = 'E' ).
            CATCH cx_bali_runtime ##NO_HANDLER.
          ENDTRY.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

*&--ADD BEGIN BY XINLEI XU 2025/02/24
    IF lt_purchaseorder IS INITIAL.
      CLEAR lv_msg.
      MESSAGE s024(zmm_001) INTO lv_msg.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'S' ).
        CATCH cx_bali_runtime ##NO_HANDLER.
      ENDTRY.
    ENDIF.
*&--ADD BEGIN BY XINLEI XU 2025/02/24

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    " for debugger
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
