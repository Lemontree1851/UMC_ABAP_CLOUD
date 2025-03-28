FUNCTION zzfm_dtimp_tfi003.
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
      companycode TYPE string,
      zhojoku     TYPE string,
      zhojocd     TYPE string,
      zhojocdt    TYPE string,
    END OF ty_results.
  DATA:ls_results TYPE ty_results.
  DATA:lt_results TYPE STANDARD TABLE OF ty_results.
  DATA:lv_path     TYPE string.
  TYPES:
    BEGIN OF ty_results1,
      sap_uuid(36) TYPE c,
      companycode  TYPE string,
      zhojoku      TYPE string,
      zhojocd      TYPE string,
      zhojocdt     TYPE string,
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
      companycode TYPE string,
      zhojoku     TYPE string,
      zhojocd     TYPE string,
      num         TYPE i,
    END OF ty_dup.
  DATA:ls_dup TYPE ty_dup.
  DATA:lt_dup TYPE STANDARD TABLE OF ty_dup.
  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  lv_path = |/YY1_B_HOJO_CDS/YY1_B_HOJO|.
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
  SORT ls_res_api_old-d-results BY companycode zhojoku zhojocd.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<linedup>).

    ls_dup-companycode               = <linedup>-('Companycode').
    ls_dup-zhojoku                   = <linedup>-('Zhojoku').
    ls_dup-zhojocd                   = <linedup>-('Zhojocd').
    ls_dup-num                       = 1.
    COLLECT  ls_dup INTO  lt_dup.
  ENDLOOP.

  DELETE lt_dup WHERE num = 1.

  LOOP AT ls_res_api_old-d-results INTO DATA(ls_old).

    "这次导入不存在的直接删
    READ TABLE eo_data->* ASSIGNING FIELD-SYMBOL(<line>) WITH KEY ('Companycode') = ls_old-companycode ('Zhojoku') = ls_old-zhojoku ('Zhojocd') = ls_old-zhojocd."#EC CI_ANYSEQ
    IF sy-subrc <> 0.

      IF iv_struc = 'ZZS_DTIMP_TFI003_DEL' AND lv_msg_del IS INITIAL.

        lv_path = |/YY1_B_HOJO_CDS/YY1_B_HOJO(guid'{  ls_old-sap_uuid }')|.
        zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_path
          iv_method      = if_web_http_client=>delete
        IMPORTING
          ev_status_code = DATA(lv_stat_code2)
          ev_response    = DATA(lv_resbody_api2) ).
        IF  lv_stat_code2 = 204.
          MESSAGE s031(zfico_001) WITH ls_old-companycode && ` ` &&  ls_old-zhojoku && ` ` &&  ls_old-zhojocd INTO lv_msg.
        ELSE.
          lv_msg_del = ls_old-companycode && ` ` &&  ls_old-zhojoku && ` ` &&  ls_old-zhojocd && ':' && lv_resbody_api2.
          CONTINUE.
        ENDIF.

      ENDIF.

    ELSE.
      "这次导入和旧的key一样的话 先删再post
      CLEAR ls_results.

      ls_results-companycode               = <line>-('Companycode').
      ls_results-zhojoku                   = <line>-('Zhojoku').
      ls_results-zhojocd                   = <line>-('Zhojocd').
      ls_results-zhojocdt                  = <line>-('Zhojocdt').
      IF lv_msg_del IS NOT INITIAL.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_msg_del iv_symbol = '/' ).
      ENDIF.

      IF ls_results-companycode IS INITIAL.
        MESSAGE s006(zbc_001) WITH TEXT-008 INTO lv_message.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.

      IF ls_results-zhojoku IS INITIAL.
        MESSAGE s006(zbc_001) WITH TEXT-009 INTO lv_message.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.

      IF ls_results-zhojocd  IS INITIAL.
        MESSAGE s006(zbc_001) WITH TEXT-010 INTO lv_message.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.

      IF ls_results-zhojocdt IS INITIAL.
        MESSAGE s006(zbc_001) WITH TEXT-011 INTO lv_message.
        <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.

      IF <line>-('Message') IS NOT INITIAL.
        <line>-('Type') = 'E'.
      ELSE.
        IF iv_struc = 'ZZS_DTIMP_TFI003_DEL' AND lv_msg_del IS INITIAL.
        ELSE.
          READ TABLE lt_dup TRANSPORTING NO FIELDS WITH KEY companycode = ls_old-companycode zhojoku = ls_old-zhojoku zhojocd = ls_old-zhojocd.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.
        ENDIF.
        CLEAR lv_msg.
        lv_path = |/YY1_B_HOJO_CDS/YY1_B_HOJO(guid'{  ls_old-sap_uuid }')|.
        zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_path
          iv_method      = if_web_http_client=>delete
        IMPORTING
          ev_status_code = lv_stat_code2
          ev_response    = lv_resbody_api2 ).
        IF  lv_stat_code2 = 204.
          "MESSAGE s031(zfico_001) WITH ls_old-Companycode && ` ` &&  ls_old-Zhojoku INTO lv_msg.
        ELSE.
          <line>-('Message') = ls_old-companycode && ` ` &&  ls_old-zhojoku && ` ` &&  ls_old-zhojocd && ':' && lv_resbody_api2.
          <line>-('Type') = 'E'.
        ENDIF.

        READ TABLE lt_dup TRANSPORTING NO FIELDS WITH KEY companycode = ls_old-companycode zhojoku = ls_old-zhojoku zhojocd = ls_old-zhojocd.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.

        "存在的先删
        CLEAR lv_msg.
        DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_results )->apply( VALUE #(
                   " ( xco_cp_json=>transformation->camel_case_to_underscore )
                  ) )->to_string( ).
        lv_path = |/YY1_B_HOJO_CDS/YY1_B_HOJO|.
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
          MESSAGE s032(zfico_001) WITH  ls_results-companycode && ` ` &&  ls_results-zhojoku && ` ` &&  ls_results-zhojocd INTO lv_msg.
          <line>-('Message') = lv_msg.
        ELSE.
          lv_msg = ls_results-companycode && ` ` &&  ls_results-zhojoku && ` ` &&  ls_results-zhojocd && ':' && lv_resbody_api.
          <line>-('Message') = lv_msg.
          <line>-('Type') = 'E'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  "new key 直接导入
  LOOP AT eo_data->* ASSIGNING <line>.
    READ TABLE lt_dup TRANSPORTING NO FIELDS WITH KEY companycode = <line>-('Companycode') zhojoku = <line>-('Zhojoku') zhojocd = <line>-('Zhojocd').
    IF sy-subrc = 0.
      MESSAGE s033(zbc_001) INTO lv_message.
      <line>-('Type') = 'E'.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.
    CHECK <line>-('Message') IS INITIAL.

    READ TABLE ls_res_api_old-d-results TRANSPORTING NO FIELDS WITH KEY companycode = <line>-('Companycode') zhojoku = <line>-('Zhojoku') zhojocd = <line>-('Zhojocd') BINARY SEARCH.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    CLEAR ls_results.

    ls_results-companycode               = <line>-('Companycode').
    ls_results-zhojoku                   = <line>-('Zhojoku').
    ls_results-zhojocd                   = <line>-('Zhojocd').
    ls_results-zhojocdt                  = <line>-('Zhojocdt').

    IF lv_msg_del IS NOT INITIAL.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_msg_del iv_symbol = '/' ).
    ENDIF.

    IF ls_results-companycode IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-008 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF ls_results-zhojoku IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-009 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF ls_results-zhojocd  IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-010 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF ls_results-zhojocdt IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-011 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF <line>-('Message') IS NOT INITIAL.
      <line>-('Type') = 'E'.
    ELSE.

      CLEAR lv_msg.

      lv_requestbody = xco_cp_json=>data->from_abap( ls_results )->apply( VALUE #(
         " ( xco_cp_json=>transformation->camel_case_to_underscore )
        ) )->to_string( ).
      lv_path = |/YY1_B_HOJO_CDS/YY1_B_HOJO|.
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
        MESSAGE s032(zfico_001) WITH  ls_results-companycode && ` ` &&  ls_results-zhojoku && ` ` &&  ls_results-zhojocd INTO lv_msg.
        <line>-('Message') = lv_msg.
      ELSE.
        lv_msg = ls_results-companycode && ` ` &&  ls_results-zhojoku && ` ` &&  ls_results-zhojocd && ':' && lv_resbody_api.
        <line>-('Message') = lv_msg.
        <line>-('Type') = 'E'.
      ENDIF.

    ENDIF.
  ENDLOOP.
ENDFUNCTION.
