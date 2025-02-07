FUNCTION zzfm_dtimp_tfi004.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA lv_message TYPE string.
  TYPES:
    BEGIN OF ty_results,
      companycode    TYPE string,
      zglaccount     TYPE string,

    END OF ty_results.
  DATA:ls_results TYPE ty_results.
  DATA:lt_results TYPE STANDARD TABLE OF ty_results.
  DATA:lv_path     TYPE string.
  TYPES:
    BEGIN OF ty_results1,
      sap_uuid(36)   TYPE c,
      companycode    TYPE string,
      zglaccount     TYPE string,

    END OF ty_results1,
    tt_results TYPE STANDARD TABLE OF ty_results1 WITH DEFAULT KEY,
    BEGIN OF ty_d,
      results TYPE tt_results,
    END OF ty_d,
    BEGIN OF ty_res_api,
      d TYPE ty_d,
    END OF ty_res_api.
  DATA:ls_res_api_old  TYPE ty_res_api.
  DATA lv_msg TYPE cl_bali_free_text_setter=>ty_text .
  DATA lv_msg_del TYPE string.
  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  lv_path = |/YY1_B_HOJOMAN_CDS/YY1_B_HOJOMAN|.
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
               CHANGING  data = ls_res_api_old ).
  SORT ls_res_api_old-d-results BY  companycode  zglaccount.



  LOOP AT ls_res_api_old-d-results INTO DATA(ls_old).

    "这次导入不存在的直接删
    READ TABLE eo_data->* ASSIGNING FIELD-SYMBOL(<line>) WITH KEY ('Companycode') = ls_old-companycode ('Zglaccount') = ls_old-zglaccount.
    IF sy-subrc <> 0.

      IF iv_struc = 'ZZS_DTIMP_TFI004_DEL' AND lv_msg_del IS INITIAL.

        lv_path = |/YY1_B_HOJOMAN_CDS/YY1_B_HOJOMAN(guid'{  ls_old-sap_uuid }')|.
        zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_path
          iv_method      = if_web_http_client=>delete
        IMPORTING
          ev_status_code = DATA(lv_stat_code2)
          ev_response    = DATA(lv_resbody_api2) ).
        IF  lv_stat_code2 = 204.
          MESSAGE s031(zfico_001) WITH ls_old-companycode && ` ` &&  ls_old-zglaccount INTO lv_msg.
        ELSE.
          lv_msg_del = ls_old-companycode && ` ` &&  ls_old-zglaccount && ':' && lv_resbody_api2.
          CONTINUE.
        ENDIF.

      ENDIF.

    ELSE.
      "这次导入和旧的key一样的话 先删再post
      CLEAR ls_results.

      ls_results-companycode               = <line>-('Companycode').
      ls_results-zglaccount                = <line>-('Zglaccount').

      IF lv_msg_del IS NOT INITIAL.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_msg_del iv_symbol = '/' ).
      ENDIF.

      IF ls_results-companycode IS INITIAL.
        MESSAGE s006(zbc_001) WITH TEXT-012 INTO lv_message.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.

      IF ls_results-zglaccount IS INITIAL.
        MESSAGE s006(zbc_001) WITH TEXT-013 INTO lv_message.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.


      IF <line>-('Message') IS NOT INITIAL.
        <line>-('Type') = 'E'.
      ELSE.

        CLEAR lv_msg.
        lv_path = |/YY1_B_HOJOMAN_CDS/YY1_B_HOJOMAN(guid'{  ls_old-sap_uuid }')|.
        zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_path
          iv_method      = if_web_http_client=>delete
        IMPORTING
          ev_status_code = lv_stat_code2
          ev_response    = lv_resbody_api2 ).
        IF  lv_stat_code2 = 204.
          "MESSAGE s031(zfico_001) WITH ls_old-Companycode && ` ` &&  ls_old-Zglaccount INTO lv_msg.
        ELSE.
          <line>-('Message') = ls_old-companycode && ` ` &&  ls_old-zglaccount && ':' && lv_resbody_api2.
          <line>-('Type') = 'E'.
        ENDIF.
        "存在的先删
        CLEAR lv_msg.
        DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_results )->apply( VALUE #(
                   " ( xco_cp_json=>transformation->camel_case_to_underscore )
                  ) )->to_string( ).
        lv_path = |/YY1_B_HOJOMAN_CDS/YY1_B_HOJOMAN|.
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
          MESSAGE s032(zfico_001) WITH  ls_results-companycode && ` ` &&  ls_results-zglaccount INTO lv_msg.
          <line>-('Message') = lv_msg.
        ELSE.
          lv_msg = ls_results-companycode && ` ` &&  ls_results-zglaccount  && ':' && lv_resbody_api.
          <line>-('Message') = lv_msg.
          <line>-('Type') = 'E'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  "new key 直接导入
  LOOP AT eo_data->* ASSIGNING <line>.

    CHECK <line>-('Message') IS INITIAL.

    READ TABLE ls_res_api_old-d-results TRANSPORTING NO FIELDS WITH KEY companycode = <line>-('Companycode') zglaccount = <line>-('Zglaccount') BINARY SEARCH.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    CLEAR ls_results.

    ls_results-companycode               = <line>-('Companycode').
    ls_results-zglaccount                = <line>-('Zglaccount').


    IF lv_msg_del IS NOT INITIAL.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_msg_del iv_symbol = '/' ).
    ENDIF.

      IF ls_results-companycode IS INITIAL.
        MESSAGE s006(zbc_001) WITH TEXT-012 INTO lv_message.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.

      IF ls_results-zglaccount IS INITIAL.
        MESSAGE s006(zbc_001) WITH TEXT-013 INTO lv_message.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.


    IF <line>-('Message') IS NOT INITIAL.
      <line>-('Type') = 'E'.
    ELSE.

      CLEAR lv_msg.

      lv_requestbody = xco_cp_json=>data->from_abap( ls_results )->apply( VALUE #(
         " ( xco_cp_json=>transformation->camel_case_to_underscore )
        ) )->to_string( ).
      lv_path = |/YY1_B_HOJOMAN_CDS/YY1_B_HOJOMAN|.
      "Call API
      zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_path
          iv_method      = if_web_http_client=>post

          iv_body        = lv_requestbody
        IMPORTING
          ev_status_code = lv_stat_code
          ev_response    = lv_resbody_api ).
      IF  lv_stat_code = 201.
        MESSAGE s032(zfico_001) WITH  ls_results-companycode && ` ` &&  ls_results-zglaccount INTO lv_msg.
        <line>-('Message') = lv_msg.
      ELSE.
        lv_msg = ls_results-companycode && ` ` &&  ls_results-zglaccount  && ':' && lv_resbody_api.
        <line>-('Message') = lv_msg.
        <line>-('Type') = 'E'.
      ENDIF.

    ENDIF.
  ENDLOOP.

ENDFUNCTION.
