FUNCTION zzfm_dtimp_tfi006.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA: ls_data TYPE zzs_dtimp_tfi006,
        lt_data TYPE TABLE OF zzs_dtimp_tfi006.

  DATA lv_message TYPE string.
  DATA:lv_path     TYPE string.
  TYPES:
    BEGIN OF ty_inventory,
      inventory TYPE string,
    END OF ty_inventory,
    BEGIN OF ty_change,
      _inventory TYPE ty_inventory,
    END OF ty_change.
  DATA:ls_change TYPE ty_change.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).

    CLEAR ls_data.
    ls_data-companycode        = <line>-('Companycode').
    ls_data-masterfixedasset   = <line>-('Masterfixedasset').
    ls_data-fixedasset         = <line>-('Fixedasset').
    ls_data-inventory          = <line>-('Inventory').

    IF ls_data-companycode IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-014 INTO <line>-('Message').
    ENDIF.

    IF ls_data-masterfixedasset IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-015 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF ls_data-fixedasset  IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-016 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF ls_data-inventory IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-017 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF <line>-('Message') IS NOT INITIAL.
      <line>-('Type') = 'E'.
    ELSE.

      CLEAR ls_change.
      ls_change-_inventory-inventory = ls_data-inventory .
      lv_path = |/api_fixedasset/srvd_a2x/sap/fixedasset/0001/FixedAsset/{ ls_data-companycode }/{ ls_data-masterfixedasset }/{ ls_data-fixedasset }/SAP__self.Change|.

      DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_change )->apply( VALUE #(
                 " ( xco_cp_json=>transformation->camel_case_to_underscore )
                ) )->to_string( ).
      zzcl_common_utils=>request_api_v4( EXPORTING iv_path        = lv_path
                                                   iv_method      = if_web_http_client=>post
                                                    "iv_select      = lv_select
                                                    "iv_filter      = lv_filter
                                                   iv_body        = lv_requestbody
                                                   iv_format      = 'json'
                                         IMPORTING ev_status_code = DATA(lv_stat_code)
                                                   ev_response    = DATA(lv_resbody_api) ).
      IF lv_stat_code = 200.

        <line>-('Type') = 'S'.
        <line>-('Message') = 'Success'.
      ELSE.
        <line>-('Message') = lv_resbody_api .
        <line>-('Type') = 'E'.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
