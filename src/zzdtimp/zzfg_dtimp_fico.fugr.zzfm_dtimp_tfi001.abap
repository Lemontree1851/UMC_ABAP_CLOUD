FUNCTION zzfm_dtimp_tfi001.
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
      bukrs      TYPE string,
      zbunseki1  TYPE string,
      zbunseki1t TYPE string,
    END OF ty_results.
  DATA:ls_results TYPE ty_results.
  DATA:lt_results TYPE STANDARD TABLE OF ty_results.
  DATA:lv_path     TYPE string.
  TYPES:
    BEGIN OF ty_results1,
      sap_uuid(36) TYPE c,
      bukrs        TYPE string,
      zbunseki1    TYPE string,
      zbunseki1t   TYPE string,
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
  TYPES:
    BEGIN OF ty_dup,
      bukrs     TYPE string,
      zbunseki1 TYPE string,
      num       TYPE i,
    END OF ty_dup.
  DATA:ls_dup TYPE ty_dup.
  DATA:lt_dup TYPE STANDARD TABLE OF ty_dup.


  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  lv_path = |/YY1_B_BUNSEKI1_CDS/YY1_B_BUNSEKI1|.
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
  SORT ls_res_api_old-d-results BY bukrs zbunseki1.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<linedup>).

    ls_dup-bukrs                  = <linedup>-('Bukrs').
    ls_dup-zbunseki1              = <linedup>-('Zbunseki1').
    ls_dup-num                    = 1.
    COLLECT  ls_dup INTO  lt_dup.
  ENDLOOP.

  DELETE lt_dup WHERE num = 1.

  LOOP AT ls_res_api_old-d-results INTO DATA(ls_old).

    "这次导入不存在的直接删
    READ TABLE eo_data->* ASSIGNING FIELD-SYMBOL(<line>) WITH KEY ('Bukrs') = ls_old-bukrs ('Zbunseki1') = ls_old-zbunseki1. "#EC CI_ANYSEQ
    IF sy-subrc <> 0.

      IF iv_struc = 'ZZS_DTIMP_TFI001_DEL' AND lv_msg_del IS INITIAL.

        lv_path = |/YY1_B_BUNSEKI1_CDS/YY1_B_BUNSEKI1(guid'{  ls_old-sap_uuid }')|.
        zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_path
          iv_method      = if_web_http_client=>delete
        IMPORTING
          ev_status_code = DATA(lv_stat_code2)
          ev_response    = DATA(lv_resbody_api2) ).
        IF  lv_stat_code2 = 204.
          MESSAGE s031(zfico_001) WITH ls_old-bukrs && ` ` &&  ls_old-zbunseki1 INTO lv_msg.
        ELSE.
          lv_msg_del = ls_old-bukrs && ` ` &&  ls_old-zbunseki1 && ':' && lv_resbody_api2.
          CONTINUE.
        ENDIF.

      ENDIF.

    ELSE.

      "这次导入和旧的key一样的话 先删再post
      CLEAR ls_results.

      ls_results-bukrs                  = <line>-('Bukrs').
      ls_results-zbunseki1              = <line>-('Zbunseki1').
      ls_results-zbunseki1t             = <line>-('Zbunseki1t').

      IF lv_msg_del IS NOT INITIAL.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_msg_del iv_symbol = '/' ).
      ENDIF.

      IF ls_results-bukrs IS INITIAL.
        MESSAGE s006(zbc_001) WITH TEXT-001 INTO lv_message.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.

      IF ls_results-zbunseki1 IS INITIAL.
        MESSAGE s006(zbc_001) WITH TEXT-002 INTO lv_message.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.

      IF ls_results-zbunseki1t IS INITIAL.
        MESSAGE s006(zbc_001) WITH TEXT-003 INTO lv_message.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.

      IF <line>-('Message') IS NOT INITIAL.
        <line>-('Type') = 'E'.
      ELSE.

        IF iv_struc = 'ZZS_DTIMP_TFI001_DEL' AND lv_msg_del IS INITIAL.
        ELSE.
          READ TABLE lt_dup TRANSPORTING NO FIELDS WITH KEY bukrs = ls_old-bukrs zbunseki1 = ls_old-zbunseki1.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.
        ENDIF.

        CLEAR lv_msg.
        lv_path = |/YY1_B_BUNSEKI1_CDS/YY1_B_BUNSEKI1(guid'{  ls_old-sap_uuid }')|.
        zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_path
          iv_method      = if_web_http_client=>delete
        IMPORTING
          ev_status_code = lv_stat_code2
          ev_response    = lv_resbody_api2 ).
        IF  lv_stat_code2 = 204.
          "MESSAGE s031(zfico_001) WITH ls_old-bukrs && ` ` &&  ls_old-zbunseki1 INTO lv_msg.
        ELSE.
          <line>-('Message') = ls_old-bukrs && ` ` &&  ls_old-zbunseki1 && ':' && lv_resbody_api2.
          <line>-('Type') = 'E'.
        ENDIF.

        READ TABLE lt_dup TRANSPORTING NO FIELDS WITH KEY bukrs = ls_old-bukrs zbunseki1 = ls_old-zbunseki1.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.

        "存在的先删
        CLEAR lv_msg.
        DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_results )->apply( VALUE #(
                   " ( xco_cp_json=>transformation->camel_case_to_underscore )
                  ) )->to_string( ).
        lv_path = |/YY1_B_BUNSEKI1_CDS/YY1_B_BUNSEKI1|.
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
          MESSAGE s032(zfico_001) WITH  ls_results-bukrs && ` ` &&  ls_results-zbunseki1 INTO lv_msg.
          <line>-('Message') = lv_msg.
        ELSE.
          lv_msg = ls_results-bukrs && ` ` &&  ls_results-zbunseki1  && ':' && lv_resbody_api.
          <line>-('Message') = lv_msg.
          <line>-('Type') = 'E'.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

  "new key 直接导入
  LOOP AT eo_data->* ASSIGNING <line>.
    READ TABLE lt_dup TRANSPORTING NO FIELDS WITH KEY bukrs = <line>-('Bukrs') zbunseki1 = <line>-('Zbunseki1').
    IF sy-subrc = 0.
      MESSAGE s033(zbc_001) INTO lv_message.
      <line>-('Type') = 'E'.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.
    CHECK <line>-('Message') IS INITIAL.

    READ TABLE ls_res_api_old-d-results TRANSPORTING NO FIELDS WITH KEY bukrs = <line>-('Bukrs') zbunseki1 = <line>-('Zbunseki1') BINARY SEARCH.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    CLEAR ls_results.

    ls_results-bukrs                  = <line>-('Bukrs').
    ls_results-zbunseki1              = <line>-('Zbunseki1').
    ls_results-zbunseki1t             = <line>-('Zbunseki1t').

    IF lv_msg_del IS NOT INITIAL.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_msg_del iv_symbol = '/' ).
    ENDIF.

    IF ls_results-bukrs IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-001 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF ls_results-zbunseki1 IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-002 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF ls_results-zbunseki1t IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-003 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF <line>-('Message') IS NOT INITIAL.
      <line>-('Type') = 'E'.
    ELSE.

      CLEAR lv_msg.

      lv_requestbody = xco_cp_json=>data->from_abap( ls_results )->apply( VALUE #(
         " ( xco_cp_json=>transformation->camel_case_to_underscore )
        ) )->to_string( ).
      lv_path = |/YY1_B_BUNSEKI1_CDS/YY1_B_BUNSEKI1|.
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
        MESSAGE s032(zfico_001) WITH  ls_results-bukrs && ` ` &&  ls_results-zbunseki1 INTO lv_msg.
        <line>-('Message') = lv_msg.
      ELSE.
        lv_msg = ls_results-bukrs && ` ` &&  ls_results-zbunseki1  && ':' && lv_resbody_api.
        <line>-('Message') = lv_msg.
        <line>-('Type') = 'E'.
      ENDIF.

    ENDIF.
  ENDLOOP.

ENDFUNCTION.
