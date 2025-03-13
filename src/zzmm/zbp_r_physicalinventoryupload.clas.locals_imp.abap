CLASS lhc_physicalinvupload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_physicalinventoryupload.
    TYPES:  row TYPE i,
          END OF lty_request,

          lty_request_t TYPE TABLE OF lty_request.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR physicalinvupload RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION physicalinvupload~processlogic RESULT result.

    METHODS excute CHANGING ct_data TYPE lty_request_t.
    METHODS get_message IMPORTING io_message    TYPE REF TO if_abap_behv_message
                        RETURNING VALUE(rv_msg) TYPE string.

ENDCLASS.

CLASS lhc_physicalinvupload IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD processlogic.
    DATA lt_request TYPE TABLE OF lty_request.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).
      CASE lv_event.
        WHEN 'EXCUTE'.
          excute( CHANGING ct_data = lt_request ) .
        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD excute.
    TYPES:
      BEGIN OF ts_sourcelist,
        _material                    TYPE string,
        _plant                       TYPE string,
        _validity_start_date         TYPE string,
        _validity_end_date           TYPE string,
        _supplier                    TYPE string,
        _supplying_plant             TYPE string,
        _source_of_supply_is_blocked TYPE string,
        _purchasing_organization     TYPE string,
        _m_r_p_sourcing_control      TYPE string,
      END OF ts_sourcelist,

      BEGIN OF ty_message,
        lang  TYPE string,
        value TYPE string,
      END OF ty_message,

      BEGIN OF ty_error,
        code    TYPE string,
        message TYPE ty_message,
      END OF ty_error,

      BEGIN OF ty_res_api,
        error TYPE ty_error,
      END OF ty_res_api,

      BEGIN OF lty_update,
        _material                   TYPE i_physinvtrydocitem-material,
        _quantity_in_unit_of_entry  TYPE string,
        _unit_of_entry              TYPE i_physinvtrydocitem-unitofentry,
        physicalinventoryitemiszero TYPE xsdboolean,
        _batch                      TYPE i_physinvtrydocitem-batch,
      END OF lty_update,

      BEGIN OF lty_create,
        material TYPE i_physinvtrydocitem-material,
      END OF lty_create,

      BEGIN OF lty_create_2,
        _material                     TYPE i_physinvtrydocitem-material,
        _supplier                     TYPE i_physinvtrydocitem-supplier,
        reasonforphysinvtrydifference TYPE i_physinvtrydocitem-reasonforphysinvtrydifference,
      END OF lty_create_2,

      BEGIN OF lty_create_header,
        _plant                     TYPE i_physinvtrydocheader-plant,
        _storage_location          TYPE i_physinvtrydocheader-storagelocation,
        _inventoryspecialstocktype TYPE i_physinvtrydocheader-inventoryspecialstocktype,
        to_phyinvdocitem           TYPE TABLE OF lty_create_2 WITH DEFAULT KEY,
      END OF lty_create_header,

      BEGIN OF lty_response_2,
        d TYPE lty_create_header,
      END OF lty_response_2.

    DATA: ls_request       TYPE lty_update,

          ls_header        TYPE lty_create_header,
          ls_item          TYPE lty_create_2,
          ls_request_2     TYPE lty_response_2,

          lt_sourcelist    TYPE STANDARD TABLE OF ts_sourcelist,
          ls_sourcelist    TYPE ts_sourcelist,
          ls_res_api       TYPE ty_res_api,
          lt_header_create TYPE TABLE FOR CREATE i_purchasingsourcelisttp,
          ls_header_create TYPE STRUCTURE FOR CREATE i_purchasingsourcelisttp,
          lt_item_create   TYPE TABLE FOR CREATE i_purchasingsourcelisttp\_purchasingsourceitem,
          ls_item_create   TYPE STRUCTURE FOR CREATE i_purchasingsourcelisttp\_purchasingsourceitem,
          lt_item_update   TYPE TABLE FOR UPDATE i_purchasingsourcelistitemtp,
          ls_item_update   TYPE STRUCTURE FOR UPDATE i_purchasingsourcelistitemtp,
          lt_header_delete TYPE TABLE FOR DELETE i_purchasingsourcelisttp,
          ls_header_delete TYPE STRUCTURE FOR DELETE i_purchasingsourcelisttp,
          lt_item_delete   TYPE TABLE FOR DELETE i_purchasingsourcelistitemtp,
          ls_item_delete   TYPE STRUCTURE FOR DELETE i_purchasingsourcelistitemtp.

    DATA: lo_root_exc TYPE REF TO cx_root,
          lv_path     TYPE string,
          lv_path_c   TYPE string,
          lv_usage(1) TYPE c,
          lv_status   TYPE c,
          i           TYPE i,
          m           TYPE i,
          n           TYPE i,
          lv_message  TYPE string,
          lv_matnr    TYPE c LENGTH 18,
          ls_error    TYPE zzcl_odata_utils=>gty_error.

*--------------------------------just for test
    "用于创建成功后的返回值
    TYPES: BEGIN OF ty_response_s,
             fiscalyear                TYPE string,
             physicalinventorydocument TYPE string,
           END OF ty_response_s,
           BEGIN OF ty_response_ss,
             d TYPE ty_response_s,
           END OF ty_response_ss.
    DATA: ls_response_ss TYPE ty_response_ss.
*-----------------------------------

*-----------------------------------
    TYPES: BEGIN OF ty_response_c,
             physicalinventorydocument     TYPE string,
             physicalinventorydocumentitem TYPE string,
           END OF ty_response_c,
           BEGIN OF ty_response_cc,
             d TYPE ty_response_c,
           END OF ty_response_cc.
    DATA:ls_response_cc TYPE ty_response_cc.
*-----------------------------------

* Authorization Check
    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
    DATA(lv_plant) = zzcl_common_utils=>get_plant_by_user( lv_user_email ).
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data>).
      IF NOT lv_plant CS <ls_data>-plant.
        lv_status = 'E'.
        <ls_data>-status = 'E'.
        MESSAGE e027(zbc_001) WITH <ls_data>-plant INTO <ls_data>-message.
      ENDIF.
    ENDLOOP.
    IF lv_status = 'E'.
      RETURN.
    ENDIF.
*---------------------------------------------------------

    LOOP AT ct_data ASSIGNING <ls_data>.
      DATA(lv_matnrin) = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in  iv_input = <ls_data>-material ).
      DATA(lv_supplier) = |{ <ls_data>-supplier ALPHA = IN }|.

      SELECT SINGLE
             b~physicalinventorydocument,
             b~physicalinventorydocumentitem,
             b~fiscalyear
        FROM i_physinvtrydocitem WITH PRIVILEGED ACCESS AS b
        JOIN i_physinvtrydocheader WITH PRIVILEGED ACCESS AS a
                                     ON a~physicalinventorydocument = b~physicalinventorydocument
       WHERE a~plant                          = @<ls_data>-plant
         AND a~storagelocation                = @<ls_data>-storagelocation
         AND a~inventoryspecialstocktype      = @<ls_data>-inventoryspecialstocktype
         AND b~material                       = @lv_matnrin
         AND b~supplier                       = @lv_supplier
         AND b~batch                          = @<ls_data>-batch
         AND b~physinvtryitemisdeleted        <> 'X'
         AND b~physicalinventoryitemiscounted <> 'X'
        INTO @DATA(ls_phyinv).

      IF <ls_data>-unitofentry IS INITIAL.
        SELECT SINGLE baseunit
          FROM i_product WITH PRIVILEGED ACCESS
         WHERE product = @lv_matnrin
          INTO @DATA(lv_unit).

        TRY.
            <ls_data>-unitofentry = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = lv_unit ).
            ##NO_HANDLER
          CATCH zzcx_custom_exception.
            " handle exception
        ENDTRY.
        CLEAR: lv_matnrin.
      ENDIF.

      REPLACE ALL OCCURRENCES OF ',' IN <ls_data>-quantity WITH ''.

      "调用api patch
      IF ls_phyinv-physicalinventorydocument IS NOT INITIAL.
        "因为有头和明细，所以调用patch更新
        ls_request = VALUE #( _material                   = <ls_data>-material
                              _quantity_in_unit_of_entry  = <ls_data>-quantity
                              _unit_of_entry              = <ls_data>-unitofentry
                              physicalinventoryitemiszero = <ls_data>-physicalinventoryitemiszero
                              _batch                      = <ls_data>-batch ).

        DATA(lv_requestbody) = /ui2/cl_json=>serialize( data = ls_request
                                                        compress = 'X'
                                                        pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

        REPLACE ALL OCCURRENCES OF 'physicalinventoryitemiszero' IN lv_requestbody  WITH `PhysicalInventoryItemIsZero`.

        "修改地址中的信息
        DATA(lv_a) = ls_phyinv-fiscalyear.
        DATA(lv_b) = ls_phyinv-physicalinventorydocument.
        DATA(lv_c) = ls_phyinv-physicalinventorydocumentitem.

        lv_path = |/API_PHYSICAL_INVENTORY_DOC_SRV/A_PhysInventoryDocItem(FiscalYear='{ lv_a }',PhysicalInventoryDocument='{ lv_b }',PhysicalInventoryDocumentItem='{ lv_c }')?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
        zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                     iv_method      = if_web_http_client=>patch
                                                     iv_body        = lv_requestbody
                                           IMPORTING ev_status_code = DATA(lv_status_code)
                                                     ev_response    = DATA(lv_response) ).
        "成功会返回204
        IF lv_status_code = 204.
          <ls_data>-status = 'S'.
          <ls_data>-message = |実地棚卸伝票 { lv_b } 明細 { lv_c } は変更されました。|.
        ELSE.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                     CHANGING  data = ls_error ).
          <ls_data>-status = 'E'.
          <ls_data>-message = ls_error-error-message-value.
        ENDIF.

        "调用API 先使用post创建 再使用patch更新
      ELSE.
        ls_header = VALUE #( _plant                     = <ls_data>-plant
                             _storage_location          = <ls_data>-storagelocation
                             _inventoryspecialstocktype = <ls_data>-inventoryspecialstocktype ).

        ls_item   = VALUE #( _material                     = <ls_data>-material
                             _supplier                     = <ls_data>-supplier
                             reasonforphysinvtrydifference = <ls_data>-reasonforphysinvtrydifference ).

        APPEND ls_item TO ls_header-to_phyinvdocitem.

        DATA(lv_requestbody_c) = /ui2/cl_json=>serialize( data = ls_header
                                                          compress = 'X'
                                                          pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

        REPLACE ALL OCCURRENCES OF 'Inventoryspecialstocktype' IN lv_requestbody_c WITH 'InventorySpecialStockType'.
        REPLACE ALL OCCURRENCES OF 'Reasonforphysinvtrydifference' IN lv_requestbody_c WITH 'Reasonforphysinvtrydifference'.
        REPLACE ALL OCCURRENCES OF 'toPhyinvdocitem' IN lv_requestbody_c WITH 'to_PhysicalInventoryDocumentItem'.

        lv_path_c = |/API_PHYSICAL_INVENTORY_DOC_SRV/A_PhysInventoryDocHeader?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

        zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path_c
                                                     iv_method      = if_web_http_client=>post
                                                     iv_body        = lv_requestbody_c
                                           IMPORTING ev_status_code = DATA(lv_status_code_c)
                                                     ev_response    = DATA(lv_response_c) ).

        IF lv_status_code_c = 201.
          xco_cp_json=>data->from_string( lv_response_c )->apply( VALUE #(
              ( xco_cp_json=>transformation->underscore_to_pascal_case )
          ) )->write_to( REF #( ls_response_ss ) ).

          <ls_data>-message = |実地棚卸伝票 { ls_response_ss-d-physicalinventorydocument } が登録されました。|.

          ls_request = VALUE #( _material                   = <ls_data>-material
                                _quantity_in_unit_of_entry  = <ls_data>-quantity
                                _unit_of_entry              = <ls_data>-unitofentry
                                physicalinventoryitemiszero = <ls_data>-physicalinventoryitemiszero
                                _batch                      = <ls_data>-batch ).

          lv_requestbody = /ui2/cl_json=>serialize( data = ls_request
                                                    compress = 'X'
                                                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

          REPLACE ALL OCCURRENCES OF `Quantityinunitofentry` IN lv_requestbody  WITH `QuantityInUnitOfEntry`.
          REPLACE ALL OCCURRENCES OF `Unitofentry` IN lv_requestbody  WITH `UnitOfEntry`.
          REPLACE ALL OCCURRENCES OF 'physicalinventoryitemiszero' IN lv_requestbody  WITH `PhysicalInventoryItemIsZero`.

          lv_a = ls_response_ss-d-fiscalyear.
          lv_b = ls_response_ss-d-physicalinventorydocument.
          lv_c = '001'.

          lv_path = |/API_PHYSICAL_INVENTORY_DOC_SRV/A_PhysInventoryDocItem(FiscalYear='{ lv_a }',PhysicalInventoryDocument='{ lv_b }',PhysicalInventoryDocumentItem='{ lv_c }')?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

          zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                       iv_method      = if_web_http_client=>patch
                                                       iv_body        = lv_requestbody
                                             IMPORTING ev_status_code = lv_status_code
                                                       ev_response    = lv_response ).
          IF lv_status_code = 204.
            /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                       CHANGING  data = ls_response_cc ).
            <ls_data>-status = 'S'.
            <ls_data>-message = |実地棚卸伝票 { lv_b } 明細 { lv_c } は登録され、変更されました。|.
          ELSE.
            /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                       CHANGING  data = ls_error ).
            <ls_data>-status = 'E'.
            <ls_data>-message = <ls_data>-message && ' しかし  ' && ls_error-error-message-value.
          ENDIF.
        ELSE.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_response_c
                                     CHANGING  data = ls_error ).
          <ls_data>-status = 'E'.
          <ls_data>-message = ls_error-error-message-value.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_message.
    MESSAGE ID io_message->if_t100_message~t100key-msgid
          TYPE io_message->m_severity
        NUMBER io_message->if_t100_message~t100key-msgno
          WITH io_message->if_t100_dyn_msg~msgv1
               io_message->if_t100_dyn_msg~msgv2
               io_message->if_t100_dyn_msg~msgv3
               io_message->if_t100_dyn_msg~msgv4 INTO rv_msg.
  ENDMETHOD.

ENDCLASS.
