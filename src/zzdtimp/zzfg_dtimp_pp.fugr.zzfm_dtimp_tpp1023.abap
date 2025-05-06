FUNCTION zzfm_dtimp_tpp1023.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA: ls_data TYPE zzs_dtimp_tpp1023,
        lt_data TYPE TABLE OF zzs_dtimp_tpp1023.

  DATA: ls_error_v2 TYPE zzcl_odata_utils=>gty_error,
        lv_path     TYPE string.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).
    CLEAR ls_data.
    IF <line>-('order_number') IS INITIAL.
      CONTINUE.
    ENDIF.

    ls_data-order_number = <line>-('order_number').
    ls_data-order_number = |{ ls_data-order_number ALPHA = IN }|.

    lv_path = |/API_PRODUCTION_ORDER_2_SRV/A_ProductionOrder_2?$filter=ManufacturingOrder eq '{ ls_data-order_number }'|.

    "获取ETag
    zzcl_common_utils=>get_api_etag(  EXPORTING iv_odata_version = 'V2'
                                                iv_path          = lv_path
                                      IMPORTING ev_status_code   = DATA(lv_status_code)
                                                ev_response      = DATA(lv_response)
                                                ev_etag          = DATA(lv_etag) ).

    lv_path = |/API_PRODUCTION_ORDER_2_SRV/ReleaseOrder?ManufacturingOrder='{ ls_data-order_number }'|.

    "Call API of releasing production order
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>post
        iv_etag        = lv_etag
      IMPORTING
        ev_status_code = lv_status_code
        ev_response    = lv_response ).

    IF lv_status_code = 200.
      <line>-('Type') = 'S'.
      MESSAGE s100(zpp_001) INTO <line>-('Message').
    ELSE.
      TRY.
          xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
           ( xco_cp_json=>transformation->pascal_case_to_underscore )
          ) )->write_to( REF #( ls_error_v2 ) ).
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
      <line>-('Type') = 'E'.
      <line>-('Message') = |{ ls_data-order_number ALPHA = OUT }:{ ls_error_v2-error-message-value }|.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
