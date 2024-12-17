CLASS zcl_job_bpbank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_results,
        bp                 TYPE string,
        bankidentification TYPE string,
      END OF ty_results.
    DATA:ls_results TYPE ty_results.
    DATA:lv_path     TYPE string.
    TYPES:
      BEGIN OF ty_results1,
        sap_uuid(36)       TYPE c,
        bp                 TYPE string,
        bankidentification TYPE string,
      END OF ty_results1,
      tt_results TYPE STANDARD TABLE OF ty_results1 WITH DEFAULT KEY,
      BEGIN OF ty_d,
        results TYPE tt_results,
      END OF ty_d,
      BEGIN OF ty_res_api,
        d TYPE ty_d,
      END OF ty_res_api.
    DATA:ls_res_api  TYPE ty_res_api.
    CONSTANTS: compay_code_befor     TYPE bukrs VALUE '1400',
               compay_code_after     TYPE bukrs VALUE '1100',
               purchase_org          TYPE ekorg VALUE '1000',
               plant                 TYPE werks_d VALUE '1400',
               bankidentification(4) TYPE c VALUE '000A'.
    CLASS-METHODS:
      init_application_log,
      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime.
    CLASS-DATA:
      mo_application_log TYPE REF TO if_bali_log.
ENDCLASS.



CLASS ZCL_JOB_BPBANK IMPLEMENTATION.


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

    DATA lv_msg TYPE cl_bali_free_text_setter=>ty_text .
    " 获取日志对象
    init_application_log( ).

    SELECT
      businesspartner,
      bankidentification
     FROM i_businesspartnerbank
    WHERE bankidentification = @bankidentification
    INTO TABLE @DATA(lt_businesspartnerbank).
    SORT lt_businesspartnerbank BY businesspartner.

    lv_path = |/YY1_B_BPBAK_CDS/YY1_B_BPBAK|.
    "Call API
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>get
        iv_format      = 'json'
        IMPORTING
        ev_status_code = DATA(lv_stat_code1)
        ev_response    = DATA(lv_resbody_api1) ).

    /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api1
                 CHANGING  data = ls_res_api ).
    SORT ls_res_api-d-results BY bp.

    LOOP AT lt_businesspartnerbank INTO DATA(ls_businesspartnerbank).

      READ TABLE ls_res_api-d-results TRANSPORTING NO FIELDS WITH KEY bp = ls_businesspartnerbank-businesspartner BINARY SEARCH.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR lv_msg.
      ls_results-bp = ls_businesspartnerbank-businesspartner.
      ls_results-bankidentification = ls_businesspartnerbank-bankidentification .
      DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_results )->apply( VALUE #(
          ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).
      REPLACE ALL OCCURRENCES OF 'Bankidentification' IN lv_requestbody WITH 'BankIdentification'.
      lv_path = |/YY1_B_BPBAK_CDS/YY1_B_BPBAK|.
      "Call API
      zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_path
          iv_method      = if_web_http_client=>post

          iv_body        = lv_requestbody
        IMPORTING
          ev_status_code = DATA(lv_stat_code)
          ev_response    = DATA(lv_resbody_api) ).
      IF  lv_stat_code = 201.
        MESSAGE s032(zfico_001) WITH ls_businesspartnerbank-businesspartner INTO lv_msg.
        TRY.
            add_message_to_log( i_text = lv_msg i_type = 'S' ).
          CATCH cx_bali_runtime INTO DATA(e) ##NO_HANDLER.
        ENDTRY.
      ELSE.
        lv_msg = ls_businesspartnerbank-businesspartner  && ':' && lv_resbody_api.
        TRY.
            add_message_to_log( i_text = lv_msg i_type = 'E' ).
          CATCH cx_bali_runtime INTO DATA(e1) ##NO_HANDLER.
        ENDTRY.
      ENDIF.


    ENDLOOP.

    LOOP AT ls_res_api-d-results INTO DATA(ls_old).

      READ TABLE  lt_businesspartnerbank TRANSPORTING NO FIELDS WITH KEY businesspartner = ls_old-bp BINARY SEARCH.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      lv_path = |/YY1_B_BPBAK_CDS/YY1_B_BPBAK(guid'{  ls_old-sap_uuid }')|.
      zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>delete
      IMPORTING
        ev_status_code = DATA(lv_stat_code2)
        ev_response    = DATA(lv_resbody_api2) ).
      IF  lv_stat_code2 = 204.
        MESSAGE s031(zfico_001) WITH ls_old-bp INTO lv_msg.
        TRY.
            add_message_to_log( i_text = lv_msg i_type = 'S' ).
          CATCH cx_bali_runtime INTO DATA(e2) ##NO_HANDLER.
        ENDTRY.
      ELSE.
        lv_msg = ls_old-bp && ':' && lv_resbody_api2.
        TRY.
            add_message_to_log( i_text = lv_msg i_type = 'E' ).
          CATCH cx_bali_runtime INTO DATA(e3) ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDLOOP.



    IF lv_stat_code IS INITIAL AND  lv_stat_code2 IS INITIAL.
      lv_msg = 'アドオンテーブル変更無し'.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'S' ).
        CATCH cx_bali_runtime INTO DATA(e4) ##NO_HANDLER.
      ENDTRY.
    ENDIF.

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
      CATCH cx_root INTO DATA(lo_root) ##NO_HANDLER.
        out->write( |Exception has occured: { lo_root->get_text(  ) }| ).
    ENDTRY.
  ENDMETHOD.


  METHOD init_application_log.
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object      = 'ZZ_LOG_FI015'
                                                                       subobject   = 'ZZ_LOG_FI015_SUB'
*                                                                       external_id = CONV #( mv_uuid )
                                                                       ) ).
      CATCH cx_bali_runtime INTO DATA(e) ##NO_HANDLER.
        " handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
