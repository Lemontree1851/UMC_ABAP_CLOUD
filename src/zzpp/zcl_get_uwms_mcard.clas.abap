CLASS zcl_get_uwms_mcard DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_get_uwms_mcard IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.
    TYPES: BEGIN OF ty_response_res,
             plant_id   TYPE string,
             loc_id     TYPE string,
             mat_id     TYPE string,
             upn_qty    TYPE string,
             mat_is_upn TYPE string,
           END OF ty_response_res,
           BEGIN OF ty_response_d,
             results TYPE TABLE OF ty_response_res WITH DEFAULT KEY,
           END OF ty_response_d,
           BEGIN OF ty_response,
             d TYPE ty_response_d,
           END OF ty_response.

    DATA: lt_original_data TYPE STANDARD TABLE OF zc_materialstockvh WITH DEFAULT KEY.
    DATA: ls_response TYPE ty_response.

    lt_original_data = CORRESPONDING #( it_original_data ).

    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        " Get UWMS Access configuration
        SELECT SINGLE *
          FROM zc_tbc1001
         WHERE zid = 'ZBC002'
           AND zvalue1 = @lv_system_url
          INTO @DATA(ls_config).
        ##NO_HANDLER
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      IF ls_config IS NOT INITIAL.
        DATA(lv_filter) = |PLANT_ID eq '{ <fs_original_data>-plant }' and MAT_ID eq '{ <fs_original_data>-material }' and LOC_ID eq '{ <fs_original_data>-storagelocation }'|.
        CONDENSE ls_config-zvalue2 NO-GAPS. " ODATA_URL
        CONDENSE ls_config-zvalue3 NO-GAPS. " TOKEN_URL
        CONDENSE ls_config-zvalue4 NO-GAPS. " CLIENT_ID
        CONDENSE ls_config-zvalue5 NO-GAPS. " CLIENT_SECRET
        zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |{ ls_config-zvalue2 }/odata/v2/TableService/INV03_HT_LIST|
                                                                iv_odata_filter  = lv_filter
                                                                iv_token_url     = CONV #( ls_config-zvalue3 )
                                                                iv_client_id     = CONV #( ls_config-zvalue4 )
                                                                iv_client_secret = CONV #( ls_config-zvalue5 )
                                                                iv_authtype      = 'OAuth2.0'
                                                      IMPORTING ev_status_code   = DATA(lv_status_code)
                                                                ev_response      = DATA(lv_response) ).
        IF lv_status_code = 200.
          xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
            ( xco_cp_json=>transformation->boolean_to_abap_bool )
          ) )->write_to( REF #( ls_response ) ).

          IF ls_response-d-results IS NOT INITIAL.
            <fs_original_data>-m_card_quantity = ls_response-d-results[ 1 ]-upn_qty.
            <fs_original_data>-m_card          = ls_response-d-results[ 1 ]-mat_is_upn.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.

ENDCLASS.
