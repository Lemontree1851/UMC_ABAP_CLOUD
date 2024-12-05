CLASS zcl_http_usap_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
* input data type
    TYPES:
      BEGIN OF ts_input_item1,
        uwmskey                      TYPE c LENGTH 36,   "Usap key
        itemno                       TYPE c LENGTH 4,
        goodsmovementcode            TYPE c LENGTH 2, "
        goodsmovementtype            TYPE c LENGTH 3,
        documentdate                 TYPE budat,
        postingdate                  TYPE budat,
        material                     TYPE c LENGTH 40,
        plant                        TYPE c LENGTH 4,
        storagelocation              TYPE c LENGTH 4,
        supplier                     TYPE c LENGTH 10,
        purchaseorder                TYPE c LENGTH 10,
        purchaseorderitem            TYPE c LENGTH 5,
        customer                     TYPE c LENGTH 10,
        salesorder                   TYPE c LENGTH 10,
        salesorderitem               TYPE c LENGTH 6,
        goodsmovementrefdoctype      TYPE c LENGTH 1,
        goodsmovementreasoncode      TYPE c LENGTH 4,
        entryunit                    TYPE c LENGTH 5,
        quantityinentryunit(7)       TYPE p DECIMALS 3,
        issuingorreceivingplant      TYPE c LENGTH 4,
        issuingorreceivingstorageloc TYPE c LENGTH 4,
        issgorrcvgmaterial           TYPE c LENGTH 40,
        reservation                  TYPE c LENGTH 10,
        reservationitem              TYPE c LENGTH 10,
        stocktype                    TYPE c LENGTH 2,
        inventoryspecialstocktype    TYPE c LENGTH 1,
        split                        TYPE c LENGTH 1,
        vmi_flag                     TYPE c LENGTH 1,
        mrno                         TYPE c LENGTH 15,
        mritemno                     TYPE c LENGTH 4,
        remark                       TYPE c LENGTH 50,
      END OF ts_input_item1,
      tt_item1 TYPE STANDARD TABLE OF ts_input_item1 WITH DEFAULT KEY,

      BEGIN OF ts_create,
        BEGIN OF to_create,
          items TYPE tt_item1,
        END OF to_create,
      END OF ts_create,

      BEGIN OF ts_input_item2,
        uwmskey              TYPE c LENGTH 36,
        itemno               TYPE c LENGTH 4,
        materialdocumentyear TYPE mjahr,
        materialdocument     TYPE c LENGTH 10,
        postingdate          TYPE budat,
        mrno                 TYPE c LENGTH 15,
        mritemno             TYPE c LENGTH 4,
      END OF ts_input_item2,
      tt_item2 TYPE STANDARD TABLE OF ts_input_item2 WITH DEFAULT KEY,

      BEGIN OF ts_cancel,
        BEGIN OF to_cancel,
          items TYPE tt_item2,
        END OF to_cancel,
      END OF ts_cancel,

      BEGIN OF ts_response,
        _uwms_key               TYPE c LENGTH 36,
        _item_no                TYPE c LENGTH 4,
        _material_document_year TYPE c LENGTH 4,
        _material_document      TYPE c LENGTH 10,
        _message                TYPE c LENGTH 220,
        _status                 TYPE c LENGTH 1,
      END OF ts_response,

      BEGIN OF ts_output,
        items TYPE STANDARD TABLE OF ts_response WITH EMPTY KEY,
      END OF ts_output,

      BEGIN OF ts_matdocitem,
        _material_document_year       TYPE string,
        _material_document            TYPE string,
        _material_document_item       TYPE string,
        _material                     TYPE matnr,
        _plant                        TYPE werks_d,
        _storage_location             TYPE c LENGTH 4,
        _goods_movement_type          TYPE c LENGTH 3,
        _inventory_special_stock_type TYPE c LENGTH 1,
        _supplier                     TYPE c LENGTH 10,
        _customer                     TYPE c LENGTH 10,
        _sales_order                  TYPE c LENGTH 10,
        _sales_order_item             TYPE c LENGTH 6,
        _purchase_order               TYPE c LENGTH 10,
        _purchase_order_item          TYPE c LENGTH 5,
        _goods_movement_ref_doc_type  TYPE c LENGTH 1,
        _goods_movement_reason_code   TYPE c LENGTH 4,
        _entry_unit                   TYPE c LENGTH 5,
        _quantity_in_entry_unit       TYPE c LENGTH 16,
        _issg_or_rcvg_material        TYPE c LENGTH 40,
        _issuing_or_receiving_plant   TYPE c LENGTH 4,
        issuingorreceivingstorageloc  TYPE c LENGTH 4,
        _material_document_item_text  TYPE c LENGTH 50,
        _reservation                  TYPE c LENGTH 10,
        _reservation_item             TYPE c LENGTH 4,
      END OF ts_matdocitem,
      tt_matdocitem TYPE STANDARD TABLE OF ts_matdocitem WITH DEFAULT KEY,

      BEGIN OF ts_matdocheader,
        _document_date            TYPE string,
        _posting_date             TYPE string,
        _goods_movement_code      TYPE string,
        to_material_document_item TYPE tt_matdocitem,
      END OF ts_matdocheader,

      BEGIN OF ts_d,
        materialdocumentyear TYPE string,
        materialdocument     TYPE string,
      END OF ts_d,
      BEGIN OF ts_message,
        lang  TYPE string,
        value TYPE string,
      END OF ts_message,

      BEGIN OF ts_error,
        code    TYPE string,
        message TYPE ts_message,
      END OF ts_error,

      BEGIN OF ts_res_api,
        d     TYPE ts_d,
        error TYPE ts_error,
      END OF ts_res_api,


      lt_head_t   TYPE TABLE FOR CREATE i_materialdocumenttp,
      lt_item_t   TYPE TABLE FOR CREATE i_materialdocumenttp\_materialdocumentitem,
      lt_cancel_t TYPE TABLE FOR ACTION IMPORT i_materialdocumenttp\\materialdocument~cancel,
      ct_usap_t   TYPE TABLE OF ztmm_1003.

    METHODS create CHANGING ct_header   TYPE lt_head_t
                            ct_item     TYPE lt_item_t
                            cs_matdoc   TYPE ts_matdocheader
                            cs_create   TYPE ts_input_item1
                            ct_response TYPE ts_output.

    METHODS cancel CHANGING ct_cancel   TYPE lt_cancel_t
                            ct_usap     TYPE ct_usap_t
                            cs_item     TYPE ts_input_item2
                            ct_response TYPE ts_output.
    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      ls_create_in      TYPE ts_create,
      ls_cancel_in      TYPE ts_cancel,
      lv_msg(220)       TYPE c,
      lv_text           TYPE string,
      lv_success        TYPE c,
      lv_count          TYPE i,
      ls_response       TYPE ts_response,
      es_response       TYPE ts_output,
      lc_header_content TYPE string VALUE 'content-type',
      lc_content_type   TYPE string VALUE 'text/json',
      lo_root_exc       TYPE REF TO cx_root.
ENDCLASS.



CLASS zcl_http_usap_001 IMPLEMENTATION.


  METHOD cancel.
    DATA:
      ls_ztpp_1010 TYPE ztpp_1010.

    MODIFY ENTITY i_materialdocumenttp\\materialdocument   ##EML_IN_LOOP_OK
              EXECUTE cancel FROM ct_cancel
              RESULT DATA(ls_cancel_result)
              MAPPED DATA(ls_cancel_mapped)
              FAILED DATA(ls_cancel_failed)
              REPORTED DATA(ls_cancel_reported).

    IF ls_cancel_failed IS INITIAL.  "Get ref. document
      COMMIT ENTITIES.
      IF sy-subrc = 0.
        LOOP AT ls_cancel_result INTO DATA(ls_result).
          DATA(lv_doc)  = ls_result-%param-materialdocument.
          DATA(lv_year) = ls_result-%param-materialdocumentyear.
        ENDLOOP.
      ENDIF.
      IF lv_doc IS INITIAL.  "if no document
        lv_success = 'E'.
        ls_response-_uwms_key = cs_item-uwmskey.
        ls_response-_item_no = cs_item-itemno.
        "Material Document canceled failed
        MESSAGE e003(zmm_001) INTO ls_response-_message.
        ls_response-_status = 'E'.
        APPEND ls_response TO es_response-items.
        CLEAR: ls_response.
      ELSE.
        READ TABLE ct_usap INTO DATA(ls_usap)
             WITH KEY uwmskey = cs_item-uwmskey
                      itemno = cs_item-itemno.
        IF sy-subrc = 0.
          DELETE FROM ztmm_1003 WHERE uwmskey = @ls_usap-uwmskey
                                  AND itemno = @ls_usap-itemno.
          IF sy-subrc <> 0.
            ROLLBACK WORK.
            ls_response-_uwms_key = cs_item-uwmskey.
            ls_response-_item_no = cs_item-itemno.
            "Cancel successful but delete database failed
            MESSAGE e004(zmm_001) INTO ls_response-_message.
            ls_response-_status = 'E'.
            ls_response-_material_document = lv_doc.
            ls_response-_material_document_year = lv_year.
            APPEND ls_response TO es_response-items.
            CLEAR: ls_response.
          ELSE.
            COMMIT WORK AND WAIT.
            ls_response-_uwms_key = cs_item-uwmskey.
            ls_response-_item_no = cs_item-itemno.
            ls_response-_material_document = lv_doc.
            ls_response-_material_document_year = lv_year.
            ls_response-_status = 'S'.
            APPEND ls_response TO es_response-items.
            CLEAR: ls_response.
          ENDIF.
        ELSE.
          ls_response-_uwms_key = cs_item-uwmskey.
          ls_response-_item_no = cs_item-itemno.
          ls_response-_material_document = lv_doc.
          ls_response-_material_document_year = lv_year.
          ls_response-_status = 'S'.
          APPEND ls_response TO es_response-items.
          CLEAR: ls_response.
        ENDIF.

        "MR update
        IF cs_item-mrno IS NOT INITIAL
       AND cs_item-mritemno IS NOT INITIAL.
          UPDATE ztpp_1010 SET uwms_post_status = @space
                 WHERE material_requisition_no = @cs_item-mrno
                   AND item_no = @cs_item-mritemno.
          IF sy-subrc <> 0.
            ROLLBACK WORK.
          ELSE.
            COMMIT WORK AND WAIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      lv_success = 'E'.
      LOOP AT ls_cancel_reported-materialdocument INTO DATA(ls_header).
        DATA(lv_msgty) = ls_header-%msg->if_t100_dyn_msg~msgty.
        IF lv_msgty = 'E'
        OR lv_msgty = 'A'.
          lv_text = ls_header-%msg->if_message~get_text( ).
          IF lv_msg IS INITIAL.
            lv_msg = lv_text.
          ELSE.
            lv_msg = lv_msg && '/' && lv_text.
          ENDIF.
        ENDIF.
      ENDLOOP.

      LOOP AT ls_cancel_reported-materialdocumentitem INTO DATA(ls_item).
        lv_msgty = ls_item-%msg->if_t100_dyn_msg~msgty.
        IF lv_msgty = 'E'
        OR lv_msgty = 'A'.
          lv_text = ls_item-%msg->if_message~get_text( ).
          IF lv_msg IS INITIAL.
            lv_msg = lv_text.
          ELSE.
            lv_msg = lv_msg && '/' && lv_text.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF lv_msgty = 'A'
      OR lv_msgty = 'E'.
        ls_response-_uwms_key = cs_item-uwmskey.
        ls_response-_item_no = cs_item-itemno.
        ls_response-_message = lv_msg.
        ls_response-_status = 'E'.
        APPEND ls_response TO es_response-items.
        CLEAR: ls_response.
      ENDIF.
    ENDIF.
    CLEAR: lv_msgty, lv_msg, lv_text.
  ENDMETHOD.


  METHOD create.
    DATA:
      lt_ztmm_usap TYPE STANDARD TABLE OF ztmm_1003,
      ls_ztmm_usap TYPE ztmm_1003,
      ls_res_api   TYPE ts_res_api,
      lt_ztmm_1010 TYPE STANDARD TABLE OF ztmm_1010,
      ls_ztmm_1010 TYPE ztmm_1010,
      lt_ztpp_1010 TYPE STANDARD TABLE OF ztpp_1010,
      ls_ztpp_1010 TYPE ztpp_1010.

    DATA:
      lv_timestamp TYPE timestamp.

    DATA(lv_reqbody_api) = /ui2/cl_json=>serialize( data = cs_matdoc
                                                    compress = 'X'
                                                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
    REPLACE ALL OCCURRENCES OF `issuingorreceivingstorageloc` IN lv_reqbody_api  WITH 'IssuingOrReceivingStorageLoc'.
    REPLACE ALL OCCURRENCES OF `toMaterialDocumentItem` IN lv_reqbody_api  WITH 'to_MaterialDocumentItem'.
    zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = |/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader?sap-language={ zzcl_common_utils=>get_current_language(  ) }|
                                                       iv_method      = if_web_http_client=>post
                                                       iv_body        = lv_reqbody_api
                                             IMPORTING ev_status_code = DATA(lv_status_code)
                                                       ev_response    = DATA(lv_response) ).
    /ui2/cl_json=>deserialize(
                          EXPORTING json = lv_response
                          CHANGING data = ls_res_api ).

    IF lv_status_code = 201. " created
      ls_response-_uwms_key = cs_create-uwmskey.
      ls_response-_item_no = cs_create-itemno.
      ls_response-_material_document_year = ls_res_api-d-materialdocumentyear.
      ls_response-_material_document = ls_res_api-d-materialdocument.

      " Insert log table
      ls_ztmm_usap-uwmskey = cs_create-uwmskey.
      ls_ztmm_usap-itemno = cs_create-itemno.
      ls_ztmm_usap-documentdate = cs_create-documentdate.
      ls_ztmm_usap-materialdocumentyear = ls_response-_material_document_year.
      ls_ztmm_usap-materialdocument = ls_response-_material_document.
      ls_ztmm_usap-postingdate = cs_create-postingdate.
      ls_ztmm_usap-goodsmovementtype = cs_create-goodsmovementtype.
      INSERT ztmm_1003 FROM @ls_ztmm_usap.
      IF sy-subrc <> 0.
        ROLLBACK WORK.
        ls_response-_status = 'E'.
        "MIGO success but Database insert failed
        MESSAGE e001(zmm_001) INTO ls_response-_message.
        APPEND ls_response TO es_response-items.
        CLEAR: ls_response.
      ELSE.
        COMMIT WORK AND WAIT.
        ls_response-_status = 'S'.
        APPEND ls_response TO es_response-items.
        CLEAR: ls_response.
      ENDIF.
      "VMI update
      IF cs_create-vmi_flag = 'X'.
        GET TIME STAMP FIELD lv_timestamp.
        ls_ztmm_1010-uuid = cs_create-uwmskey.
        ls_ztmm_1010-material = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = 'IN' iv_input = cs_create-material ).
        ls_ztmm_1010-quantity = cs_create-quantityinentryunit.
        TRY.
            ls_ztmm_1010-unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = 'IN'
                                                                               iv_input = cs_create-entryunit ).
          CATCH zzcx_custom_exception INTO lo_root_exc.
            ls_ztmm_1010-unit = cs_create-entryunit.
        ENDTRY.
        ls_ztmm_1010-plant = cs_create-plant.
        ls_ztmm_1010-storagelocation = cs_create-storagelocation.
        ls_ztmm_1010-customer = |{ cs_create-customer ALPHA = IN }|.
        ls_ztmm_1010-documentdate = cs_create-documentdate.
        ls_ztmm_1010-postingdate = cs_create-postingdate.
        ls_ztmm_1010-created_at = lv_timestamp.
        ls_ztmm_1010-created_by = sy-uname.
        INSERT ztmm_1010 FROM @ls_ztmm_1010.
        IF sy-subrc <> 0.
          ROLLBACK WORK.
        ELSE.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
      "MR update
      IF cs_create-mrno IS NOT INITIAL
     AND cs_create-mritemno IS NOT INITIAL.
        UPDATE ztpp_1010 SET uwms_post_status = 'P'
               WHERE material_requisition_no = @cs_create-mrno
                 AND item_no = @cs_create-mritemno.
        IF sy-subrc <> 0.
          ROLLBACK WORK.
        ELSE.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
    ELSE.
      lv_success = 'E'.
      ls_response-_uwms_key = cs_create-uwmskey.
      ls_response-_item_no = cs_create-itemno.
      ls_response-_status = 'E'.
      ls_response-_message = ls_res_api-error-message-value.
      APPEND ls_response TO es_response-items.
      CLEAR: ls_response.
    ENDIF.

    CLEAR: cs_matdoc,
           lv_text, lv_msg, lv_count.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    DATA:
      lt_materialdocument_header TYPE TABLE FOR CREATE i_materialdocumenttp,
      ls_materialdocument_header TYPE STRUCTURE FOR CREATE i_materialdocumenttp,
      lt_materialdocument_item   TYPE TABLE FOR CREATE i_materialdocumenttp\_materialdocumentitem,
      ls_materialdocument_item   TYPE STRUCTURE FOR CREATE i_materialdocumenttp\_materialdocumentitem,
      lt_cancel_header           TYPE TABLE FOR ACTION IMPORT i_materialdocumenttp\\materialdocument~cancel,
      ls_cancel_header           TYPE STRUCTURE FOR ACTION IMPORT i_materialdocumenttp\\materialdocument~cancel,
      lt_cancel_item             TYPE TABLE FOR ACTION IMPORT i_materialdocumenttp\\materialdocumentitem~cancel,
      ls_cancel_item             TYPE STRUCTURE FOR ACTION IMPORT i_materialdocumenttp\\materialdocumentitem~cancel,
      ls_matdocheader            TYPE ts_matdocheader,
      lt_matdocitem              TYPE STANDARD TABLE OF ts_matdocitem,
      ls_matdocitem              TYPE ts_matdocitem,
      ls_res_api                 TYPE ts_res_api.

    DATA:
      lt_ztmm_usap TYPE STANDARD TABLE OF ztmm_1003,
      ls_ztmm_usap TYPE ztmm_1003.


    DATA(lv_req_body) = request->get_text( ).
    IF sy-subrc <> 0.
      ls_response-_message = 'Connect fail'.
      ls_response-_status = 'E'.
      APPEND ls_response TO es_response-items.
      RETURN.
    ENDIF.

    DATA(lv_header) = request->get_header_field( i_name = 'action' ).

    IF lv_header = 'CREATE'.
      /ui2/cl_json=>deserialize(
         EXPORTING
           json             = lv_req_body
           pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
         CHANGING
           data             = ls_create_in ).
    ELSE.
      /ui2/cl_json=>deserialize(
         EXPORTING
           json             = lv_req_body
           pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
         CHANGING
           data             = ls_cancel_in ).
    ENDIF.


* Create Process
    IF lv_header = 'CREATE'.
      DATA(lt_create) = ls_create_in-to_create-items.

      " Get log data
      SELECT *                                  "#EC CI_FAE_NO_LINES_OK
        FROM ztmm_1003
        FOR ALL ENTRIES IN @lt_create
       WHERE uwmskey = @lt_create-uwmskey
        INTO TABLE @DATA(lt_usap).

      SORT lt_usap BY uwmskey itemno.
      SORT lt_create BY uwmskey itemno.

      LOOP AT lt_create ASSIGNING FIELD-SYMBOL(<lfs_member>)
              GROUP BY ( uwmskey = <lfs_member>-uwmskey )
              REFERENCE INTO DATA(create).
        LOOP AT GROUP create INTO DATA(ls_create).
          lv_count = sy-tabix.
          " Check if exits in log table ZTMM_USAP
          READ TABLE lt_usap INTO DATA(ls_usap)
                             WITH KEY uwmskey = ls_create-uwmskey
                                      itemno = ls_create-itemno BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(lv_flg) = 'X'.
            ls_response-_uwms_key = ls_usap-uwmskey.
            ls_response-_item_no = ls_usap-itemno.
            ls_response-_material_document_year = ls_usap-materialdocumentyear.
            ls_response-_material_document = ls_usap-materialdocument.
            ls_response-_status = 'S'.

            APPEND ls_response TO es_response-items.
            CLEAR: ls_response.
            CONTINUE.

          ELSE.
            IF ls_create-split = 'X'.
              "Header
              ls_matdocheader-_document_date = |{ ls_create-documentdate+0(4) }-{ ls_create-documentdate+4(2) }-{ ls_create-documentdate+6(2) }T00:00:00|.
              ls_matdocheader-_posting_date = |{ ls_create-postingdate+0(4) }-{ ls_create-postingdate+4(2) }-{ ls_create-postingdate+6(2) }T00:00:00|.
              ls_matdocheader-_goods_movement_code = ls_create-goodsmovementcode.

            ELSE.
              IF lv_count = 1.
                "Header
                ls_matdocheader-_document_date = |{ ls_create-documentdate+0(4) }-{ ls_create-documentdate+4(2) }-{ ls_create-documentdate+6(2) }T00:00:00|.
                ls_matdocheader-_posting_date = |{ ls_create-postingdate+0(4) }-{ ls_create-postingdate+4(2) }-{ ls_create-postingdate+6(2) }T00:00:00|.
                ls_matdocheader-_goods_movement_code = ls_create-goodsmovementcode.

              ENDIF.
            ENDIF.
          ENDIF.
* if not, then migo
          "Item - Convert data
          DATA(lv_material) = zzcl_common_utils=>conversion_matn1(
                                EXPORTING iv_alpha = 'IN'
                                          iv_input = ls_create-material ).

          TRY.
              DATA(lv_unit) = zzcl_common_utils=>conversion_cunit(
                                EXPORTING iv_alpha = 'IN'
                                          iv_input = ls_create-entryunit ).
            CATCH zzcx_custom_exception INTO lo_root_exc.
              IF sy-subrc = 0. ENDIF.
          ENDTRY.

          DATA(lv_po) = |{ ls_create-purchaseorder ALPHA = IN }|.
          DATA(lv_poitem) = |{ ls_create-purchaseorderitem ALPHA = IN }|.
          DATA(lv_supplier) = |{ ls_create-supplier ALPHA = IN }|.
          DATA(lv_so) = |{ ls_create-salesorder ALPHA = IN }|.
          DATA(lv_soitem) = |{ ls_create-salesorderitem ALPHA = IN }|.
          DATA(lv_customer) = |{ ls_create-customer ALPHA = IN }|.

          ls_matdocitem-_material = lv_material.
          ls_matdocitem-_plant = ls_create-plant.
          ls_matdocitem-_storage_location = ls_create-storagelocation.
          ls_matdocitem-_goods_movement_type = ls_create-goodsmovementtype.
          ls_matdocitem-_inventory_special_stock_type = ls_create-inventoryspecialstocktype.
          ls_matdocitem-_supplier = lv_supplier.
          ls_matdocitem-_sales_order = lv_so.
          ls_matdocitem-_sales_order_item = lv_soitem.
          ls_matdocitem-_purchase_order = lv_po.
          ls_matdocitem-_purchase_order_item = lv_poitem.
          ls_matdocitem-_goods_movement_ref_doc_type = ls_create-goodsmovementrefdoctype.
          ls_matdocitem-_goods_movement_reason_code = ls_create-goodsmovementreasoncode.
          ls_matdocitem-_entry_unit = ls_create-entryunit.
          ls_matdocitem-_quantity_in_entry_unit = ls_create-quantityinentryunit.
          CONDENSE ls_matdocitem-_quantity_in_entry_unit.
          ls_matdocitem-_issg_or_rcvg_material = ls_create-issgorrcvgmaterial.
          ls_matdocitem-_issuing_or_receiving_plant = ls_create-issuingorreceivingplant.
          ls_matdocitem-issuingorreceivingstorageloc = ls_create-issuingorreceivingstorageloc.
          ls_matdocitem-_material_document_item_text = ls_create-remark.
          ls_matdocitem-_reservation = |{ ls_create-reservation ALPHA = IN }|.
          ls_matdocitem-_reservation_item = |{ ls_create-reservationitem ALPHA = IN }|.
          APPEND ls_matdocitem TO lt_matdocitem.
          ls_matdocheader-to_material_document_item = lt_matdocitem.

          IF ls_create-split = 'X'
         AND lv_success IS INITIAL.
            create( CHANGING ct_header = lt_materialdocument_header
                             ct_item = lt_materialdocument_item
                             cs_matdoc = ls_matdocheader
                             cs_create = ls_create
                             ct_response = es_response ).
            CLEAR: lt_materialdocument_header,
                   lt_materialdocument_item,
                   lt_matdocitem,
                   ls_matdocheader,
                   lv_count.
            WAIT UP TO 1 SECONDS.
          ENDIF.

        ENDLOOP.


        IF lv_flg IS INITIAL
       AND ls_create-split IS INITIAL.
          create( CHANGING ct_header = lt_materialdocument_header
                           ct_item = lt_materialdocument_item
                           cs_matdoc = ls_matdocheader
                           cs_create = ls_create
                           ct_response = es_response ).
          CLEAR: lt_materialdocument_header,
                 lt_materialdocument_item.

        ENDIF.

        CLEAR: ls_create, ls_usap, lv_success,
               lv_text, lv_msg, lv_count, lv_flg,
               ls_matdocheader, lt_matdocitem, ls_matdocitem.
      ENDLOOP.
    ELSEIF lv_header = 'CANCEL'.
* Cancel Process
      DATA(lt_cancel) = ls_cancel_in-to_cancel-items.
      " Get log data
      SELECT *                                  "#EC CI_FAE_NO_LINES_OK
        FROM ztmm_1003
        FOR ALL ENTRIES IN @lt_cancel
       WHERE uwmskey = @lt_cancel-uwmskey
        INTO TABLE @lt_usap.

      SORT lt_usap BY uwmskey itemno.

      SELECT materialdocumentyear,
             materialdocument,
             materialdocumentitem
        FROM i_materialdocumentitemtp WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_cancel
       WHERE materialdocumentyear = @lt_cancel-materialdocumentyear
         AND materialdocument = @lt_cancel-materialdocument
         AND isautomaticallycreated = @space
        INTO TABLE @DATA(lt_mdoc).

      LOOP AT lt_cancel  ASSIGNING FIELD-SYMBOL(<lfs_cancel>)
              GROUP BY ( uwmskey = <lfs_cancel>-uwmskey )
              REFERENCE INTO DATA(cancel).
        LOOP AT GROUP cancel INTO DATA(ls_cancel).
          READ TABLE lt_usap INTO ls_usap
               WITH KEY uwmskey = ls_cancel-uwmskey
                        itemno = ls_cancel-itemno BINARY SEARCH.
          IF sy-subrc <> 0.
            ls_response-_uwms_key = ls_cancel-uwmskey.
            ls_response-_item_no = ls_cancel-itemno.
            ls_response-_message = TEXT-001 && ls_cancel-materialdocument && TEXT-002.
            ls_response-_status = 'E'.
            APPEND ls_response TO es_response-items.
            CLEAR: ls_response.
            CONTINUE.
          ENDIF.
          lt_cancel_header = VALUE #( (
                %key-materialdocument = ls_cancel-materialdocument
                %key-materialdocumentyear = ls_cancel-materialdocumentyear
                %param-postingdate = ls_cancel-postingdate
                ) ).

          IF lv_success IS INITIAL.
            cancel( CHANGING ct_cancel = lt_cancel_header
                             ct_usap  = lt_usap
                             cs_item  = ls_cancel
                             ct_response = es_response ).
          ENDIF.
          CLEAR: lt_cancel_header.
        ENDLOOP.
        CLEAR: lv_success.
      ENDLOOP.
    ELSE.
      "Other error
      MESSAGE e005(zmm_001) INTO ls_response-_message.
      ls_response-_status = 'E'.
      APPEND ls_response TO es_response-items.
      CLEAR: ls_response.

    ENDIF.

* Send response to USAP
    response->set_status( '200' ).
    DATA(lv_json_string) = xco_cp_json=>data->from_abap( es_response )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).
    response->set_text( lv_json_string ).
    response->set_header_field( i_name  = lc_header_content
                                i_value = lc_content_type ).
  ENDMETHOD.
ENDCLASS.
