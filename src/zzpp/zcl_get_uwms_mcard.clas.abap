CLASS zcl_get_uwms_mcard DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GET_UWMS_MCARD IMPLEMENTATION.


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
    DATA: ls_response TYPE ty_response,
          lt_api_data TYPE TABLE OF ty_response_res.

    lt_original_data = CORRESPONDING #( it_original_data ).

    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        " Get UWMS Access configuration
        SELECT *
          FROM zc_tbc1001
         WHERE zid = 'ZBC002'
           AND zvalue1 = @lv_system_url
          INTO TABLE @DATA(lt_config).        "#EC CI_ALL_FIELDS_NEEDED
        ##NO_HANDLER
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    SORT lt_config BY zvalue2.
    DELETE ADJACENT DUPLICATES FROM lt_config COMPARING zvalue2.

    LOOP AT lt_config INTO DATA(ls_config).
      CONDENSE ls_config-zvalue2 NO-GAPS. " ODATA_URL
      CONDENSE ls_config-zvalue3 NO-GAPS. " TOKEN_URL
      CONDENSE ls_config-zvalue4 NO-GAPS. " CLIENT_ID
      CONDENSE ls_config-zvalue5 NO-GAPS. " CLIENT_SECRET

      DATA(lv_top)  = 1000.
      DATA(lv_skip) = -1000.
      DO.
        lv_skip += 1000.
        zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |{ ls_config-zvalue2 }/odata/v2/TableService/INV03_HT_LIST?$top={ lv_top }&$skip={ lv_skip }|
                                                                iv_token_url     = CONV #( ls_config-zvalue3 )
                                                                iv_client_id     = CONV #( ls_config-zvalue4 )
                                                                iv_client_secret = CONV #( ls_config-zvalue5 )
                                                                iv_authtype      = 'OAuth2.0'
                                                      IMPORTING ev_status_code   = DATA(lv_status_code)
                                                                ev_response      = DATA(lv_response) ).
        IF lv_status_code = 200.
          CLEAR ls_response.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                               pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                     CHANGING  data = ls_response ).

          IF ls_response-d-results IS NOT INITIAL.
            APPEND LINES OF ls_response-d-results TO lt_api_data.
          ELSE.
            EXIT.
          ENDIF.
        ELSE.
          EXIT.
        ENDIF.
        CLEAR: lv_status_code, lv_response.
      ENDDO.
    ENDLOOP.
    SORT lt_api_data BY plant_id mat_id loc_id.

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      READ TABLE lt_api_data INTO DATA(ls_api_data) WITH KEY plant_id = <fs_original_data>-plant
                                                             mat_id = <fs_original_data>-material
                                                             loc_id = <fs_original_data>-storagelocation BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_original_data>-m_card_quantity = ls_api_data-upn_qty.
        <fs_original_data>-m_card          = ls_api_data-mat_is_upn.
      ENDIF.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
