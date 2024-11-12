CLASS zcl_get_invoicereport_longtext DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_get_invoicereport_longtext IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF iv_entity = 'ZC_INVOICEREPORT'.
      LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
        CASE <fs_calc_element>.
          WHEN 'REMITADDRESS'.
            INSERT `BILLINGDOCUMENT` INTO TABLE et_requested_orig_elements.

        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA lt_original_data TYPE STANDARD TABLE OF zc_invoicereport WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).

    TYPES: BEGIN OF ty_longtext,
             billing_document TYPE i_billingdocument-billingdocument,
             language         TYPE string,
             long_text_i_d    TYPE string,
             long_text        TYPE string,
           END OF ty_longtext,
           BEGIN OF ty_result,
             results TYPE TABLE OF ty_longtext WITH DEFAULT KEY,
           END OF ty_result,
           BEGIN OF ty_response,
             d TYPE ty_result,
           END OF ty_response.
    DATA: ls_response TYPE ty_response.
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).

      "效率会很低，可以考虑，在报表中不显示，只在打印时调用此api获取结果 在zbp_r_invoicereport中的三个打印方法中添加逻辑（这三个方法中会打印获取数据）
      DATA(lv_path) = |/API_BILLING_DOCUMENT_SRV/A_BillingDocument('{ <fs_original_data>-billingdocument }')/to_Text?sap-language={ zzcl_common_utils=>get_current_language( ) }|.
      zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                   iv_method      = if_web_http_client=>get
*                                                   iv_body        = lv_requestbody
                                        IMPORTING ev_status_code   = DATA(lv_status_code)
                                                  ev_response      = DATA(lv_response) ).
      IF lv_status_code = 200.
        xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore )
        ) )->write_to( REF #( ls_response ) ).
      ENDIF.
      LOOP AT ls_response-d-results INTO data(ls_result) WHERE language = zzcl_common_utils=>get_current_language( ) and long_text_i_d = 'TX05'.
        <fs_original_data>-RemitAddress = ls_result-long_text.
      ENDLOOP.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).
  ENDMETHOD.
ENDCLASS.
