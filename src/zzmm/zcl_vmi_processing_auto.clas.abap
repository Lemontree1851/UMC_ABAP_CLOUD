CLASS zcl_vmi_processing_auto DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      tt_ztmm_1010 TYPE STANDARD TABLE OF ztmm_1010 WITH DEFAULT KEY.

    CLASS-METHODS:
      "! Execute VMI processing
      "! @parameter IT_VMIDATA | Execute VMI processing with specified UUID
      execute IMPORTING it_vmidata TYPE tt_ztmm_1010 OPTIONAL
              EXPORTING et_results TYPE tt_ztmm_1010
              RAISING   zzcx_custom_exception.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VMI_PROCESSING_AUTO IMPLEMENTATION.


  METHOD execute.

    TYPES:
      BEGIN OF ty_results,
        _material                     TYPE string,
        _plant                        TYPE string,
        _storage_location             TYPE string,
        _goods_movement_type          TYPE string,
        _inventory_special_stock_type TYPE string,
        _cost_center                  TYPE string,
        _supplier                     TYPE string,
        _quantity_in_entry_unit       TYPE string,
        _entry_unit                   TYPE meins,
      END OF ty_results,
      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,

      BEGIN OF ty_matdocitem,
        results TYPE tt_results,
      END OF ty_matdocitem,

      BEGIN OF ty_request,
        _document_date          TYPE string,
        _posting_date           TYPE string,
        _goods_movement_code    TYPE string,
        _material_document_item TYPE ty_matdocitem,
      END OF ty_request,

      BEGIN OF ty_d,
        material_document_year TYPE string,
        material_document      TYPE string,
      END OF ty_d,

      BEGIN OF ty_errordetails,
        message TYPE string,
      END OF ty_errordetails,
      tt_errordetails TYPE STANDARD TABLE OF ty_errordetails WITH DEFAULT KEY,

      BEGIN OF ty_innererror,
        errordetails TYPE tt_errordetails,
      END OF ty_innererror,

      BEGIN OF ty_message,
        value TYPE string,
      END OF ty_message,

      BEGIN OF ty_error,
        message    TYPE ty_message,
        innererror TYPE ty_innererror,
      END OF ty_error,

      BEGIN OF ty_response,
        d     TYPE ty_d,
        error TYPE ty_error,
      END OF ty_response,

      BEGIN OF ty_ztbc_1001,
        customer   TYPE kunnr,
        costcenter TYPE kostl,
      END OF ty_ztbc_1001.

    DATA:
      lt_ztmm_1010      TYPE STANDARD TABLE OF ztmm_1010,
      lt_ztbc_1001      TYPE STANDARD TABLE OF ty_ztbc_1001,
      lt_lock_parameter TYPE if_abap_lock_object=>tt_parameter,
      ls_result         TYPE ty_results,
      ls_request        TYPE ty_request,
      ls_response       TYPE ty_response,
      lv_year           TYPE if_xco_cp_tm_date=>tv_year,
      lv_month          TYPE if_xco_cp_tm_date=>tv_month,
      lv_day            TYPE if_xco_cp_tm_date=>tv_day,
      lv_client         TYPE sy-mandt,
      lv_message        TYPE string,
      lv_path           TYPE string,
      lv_timestampl     TYPE timestampl.

    CONSTANTS:
      lc_stat_code_201      TYPE if_web_http_response=>http_status-code VALUE '201',
      lc_stat_code_500      TYPE if_web_http_response=>http_status-code VALUE '500',
      lc_hour_08            TYPE if_xco_cp_tm_time=>tv_hour             VALUE '08',
      lc_minute_00          TYPE if_xco_cp_tm_time=>tv_minute           VALUE '00',
      lc_second_00          TYPE if_xco_cp_tm_time=>tv_second           VALUE '00',
      lc_zid_zmm004         TYPE string VALUE 'ZMM004',
      lc_gmcode_06          TYPE string VALUE '06',
      lc_gmtype_201         TYPE string VALUE '201',
      lc_gmtype_501         TYPE string VALUE '501',
      lc_invspecstocktype_k TYPE string VALUE 'K',
      lc_alpha_out          TYPE string VALUE 'OUT',
      lc_second_in_ms       TYPE i      VALUE '1000'.

    IF it_vmidata IS NOT INITIAL.
      "Obtain data of VMI
      SELECT *
        FROM ztmm_1010
         FOR ALL ENTRIES IN @it_vmidata
       WHERE uuid = @it_vmidata-uuid
         AND processed = @abap_false
        INTO TABLE @DATA(lt_ztmm_1010_tmp).
    ELSE.
      "Obtain data of VMI
      SELECT *
        FROM ztmm_1010
       WHERE processed = @abap_false
        INTO TABLE @lt_ztmm_1010_tmp.
    ENDIF.

    IF lt_ztmm_1010_tmp IS NOT INITIAL.
      "Obtain data of cost center
      SELECT zvalue1 AS customer,
             zvalue2 AS costcenter
        FROM ztbc_1001
       WHERE zid = @lc_zid_zmm004
        INTO TABLE @lt_ztbc_1001.

      LOOP AT lt_ztbc_1001 ASSIGNING FIELD-SYMBOL(<fs_ztbc_1001>).
        <fs_ztbc_1001>-customer   = |{ <fs_ztbc_1001>-customer ALPHA = IN }|.
        <fs_ztbc_1001>-costcenter = |{ <fs_ztbc_1001>-costcenter ALPHA = IN }|.
      ENDLOOP.

      lv_client = sy-mandt.

      TRY.
          DATA(lr_lock) = cl_abap_lock_object_factory=>get_instance( 'EZ_ZTMM_1010' ).
        CATCH cx_abap_lock_failure INTO DATA(lx_abap_lock_failure).
          RAISE EXCEPTION NEW zzcx_custom_exception( textid = VALUE #( msgid = 'ZMM_001'
                                                                       msgno = '000'
                                                                       attr1 = lx_abap_lock_failure->get_text( ) ) ).
      ENDTRY.

      LOOP AT lt_ztmm_1010_tmp INTO DATA(ls_ztmm_1010).
        lt_lock_parameter = VALUE #( ( name = 'CLIENT' value = REF #( lv_client ) )
                                     ( name = 'UUID'   value = REF #( ls_ztmm_1010-uuid ) ) ).

        TRY.
            lr_lock->enqueue( it_parameter = lt_lock_parameter ).
          CATCH cx_abap_foreign_lock INTO DATA(lx_abap_foreign_lock).
            lv_message = lx_abap_foreign_lock->get_text( ).
          CATCH cx_abap_lock_failure INTO lx_abap_lock_failure.
            lv_message = lx_abap_lock_failure->get_text( ).
        ENDTRY.

        IF lv_message IS NOT INITIAL.
          ls_ztmm_1010-message = lv_message.
          APPEND ls_ztmm_1010 TO et_results.
        ELSE.
          APPEND ls_ztmm_1010 TO lt_ztmm_1010.
        ENDIF.

        CLEAR:
          lt_lock_parameter,
          lv_message.
      ENDLOOP.

      SORT lt_ztbc_1001 BY customer.

      LOOP AT lt_ztmm_1010 ASSIGNING FIELD-SYMBOL(<fs_ztmm_1010>).
        "201
        ls_result-_material            = <fs_ztmm_1010>-material.
        ls_result-_plant               = <fs_ztmm_1010>-plant.
        ls_result-_storage_location    = <fs_ztmm_1010>-storagelocation.
        ls_result-_goods_movement_type = lc_gmtype_201.

        "Read data of cost center
        READ TABLE lt_ztbc_1001 INTO DATA(ls_ztbc_1001) WITH KEY customer = <fs_ztmm_1010>-customer BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-_cost_center = ls_ztbc_1001-costcenter.
        ENDIF.

        ls_result-_quantity_in_entry_unit = <fs_ztmm_1010>-quantity.
        CONDENSE ls_result-_quantity_in_entry_unit.

        TRY.
            ls_result-_entry_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                   iv_input = <fs_ztmm_1010>-unit ).
          CATCH zzcx_custom_exception INTO DATA(lx_root_exc).
            ls_result-_entry_unit = <fs_ztmm_1010>-unit.
        ENDTRY.

        APPEND ls_result TO ls_request-_material_document_item-results.
        CLEAR ls_result.

        "501 K
        ls_result-_material                     = <fs_ztmm_1010>-material.
        ls_result-_plant                        = <fs_ztmm_1010>-plant.
        ls_result-_storage_location             = <fs_ztmm_1010>-storagelocation.
        ls_result-_goods_movement_type          = lc_gmtype_501.
        ls_result-_inventory_special_stock_type = lc_invspecstocktype_k.
        ls_result-_supplier                     = <fs_ztmm_1010>-customer.
        ls_result-_quantity_in_entry_unit       = <fs_ztmm_1010>-quantity.
        CONDENSE ls_result-_quantity_in_entry_unit.

        TRY.
            ls_result-_entry_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                   iv_input = <fs_ztmm_1010>-unit ).
          CATCH zzcx_custom_exception INTO lx_root_exc.
            ls_result-_entry_unit = <fs_ztmm_1010>-unit.
        ENDTRY.

        APPEND ls_result TO ls_request-_material_document_item-results.
        CLEAR ls_result.

        lv_year  = <fs_ztmm_1010>-postingdate+0(4).
        lv_month = <fs_ztmm_1010>-postingdate+4(2).
        lv_day   = <fs_ztmm_1010>-postingdate+6(2).

        DATA(lv_timestamp) = xco_cp_time=>moment( iv_year   = lv_year
                                                  iv_month  = lv_month
                                                  iv_day    = lv_day
                                                  iv_hour   = lc_hour_08
                                                  iv_minute = lc_minute_00
                                                  iv_second = lc_second_00
                                                )->get_unix_timestamp( )->value * lc_second_in_ms.

        ls_request-_posting_date = |/Date({ lv_timestamp })/|.

        lv_year  = <fs_ztmm_1010>-documentdate+0(4).
        lv_month = <fs_ztmm_1010>-documentdate+4(2).
        lv_day   = <fs_ztmm_1010>-documentdate+6(2).

        lv_timestamp = xco_cp_time=>moment( iv_year   = lv_year
                                            iv_month  = lv_month
                                            iv_day    = lv_day
                                            iv_hour   = lc_hour_08
                                            iv_minute = lc_minute_00
                                            iv_second = lc_second_00
                                          )->get_unix_timestamp( )->value * lc_second_in_ms.

        ls_request-_document_date = |/Date({ lv_timestamp })/|.

        ls_request-_goods_movement_code = lc_gmcode_06.

        DATA(lv_body_request) = /ui2/cl_json=>serialize( data = ls_request
                                                         compress = 'X'
                                                         pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

        REPLACE ALL OCCURRENCES OF 'MaterialDocumentItem' IN lv_body_request WITH 'to_MaterialDocumentItem'.

        "/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader
        lv_path = |/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader|.

        "Call API of creating material document
        zzcl_common_utils=>request_api_v2(
          EXPORTING
            iv_path        = lv_path
            iv_method      = if_web_http_client=>post
            iv_body        = lv_body_request
          IMPORTING
            ev_status_code = DATA(lv_stat_code)
            ev_response    = DATA(lv_response) ).

        IF lv_stat_code = lc_stat_code_201.
          "JSON->ABAP
          xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
              ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_response ) ).

          <fs_ztmm_1010>-materialdocument     = ls_response-d-material_document.
          <fs_ztmm_1010>-materialdocumentyear = ls_response-d-material_document_year.
          <fs_ztmm_1010>-processed            = abap_true.
          CLEAR <fs_ztmm_1010>-message.
        ELSE.
          "Could not fetch SCRF token
          IF lv_stat_code = lc_stat_code_500.
            <fs_ztmm_1010>-message = lv_response.
          ELSE.
            "JSON->ABAP
            xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
                ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_response ) ).

            READ TABLE ls_response-error-innererror-errordetails INTO DATA(ls_errordetails) INDEX 1.
            IF sy-subrc = 0.
              <fs_ztmm_1010>-message = ls_errordetails-message.
            ELSE.
              <fs_ztmm_1010>-message = ls_response-error-message-value.
            ENDIF.
          ENDIF.
        ENDIF.

        GET TIME STAMP FIELD lv_timestampl.

        UPDATE ztmm_1010
           SET processed             = @<fs_ztmm_1010>-processed,
               message               = @<fs_ztmm_1010>-message,
               materialdocument      = @<fs_ztmm_1010>-materialdocument,
               materialdocumentyear  = @<fs_ztmm_1010>-materialdocumentyear,
               last_changed_at       = @lv_timestampl,
               last_changed_by       = @sy-uname,
               local_last_changed_at = @lv_timestampl
         WHERE uuid = @<fs_ztmm_1010>-uuid.

        COMMIT WORK AND WAIT.

        CLEAR:
          ls_request,
          ls_response,
          lv_body_request.

        lt_lock_parameter = VALUE #( ( name = 'CLIENT' value = REF #( lv_client ) )
                                     ( name = 'UUID'   value = REF #( <fs_ztmm_1010>-uuid ) ) ).

        TRY.
            lr_lock->dequeue( it_parameter = lt_lock_parameter ).
          CATCH cx_abap_lock_failure INTO lx_abap_lock_failure ##NO_HANDLER.
        ENDTRY.

        CLEAR lt_lock_parameter.
      ENDLOOP.

      APPEND LINES OF lt_ztmm_1010 TO et_results.
      SORT et_results BY uuid.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
