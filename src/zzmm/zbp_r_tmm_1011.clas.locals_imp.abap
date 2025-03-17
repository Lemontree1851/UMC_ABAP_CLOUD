CLASS lhc_zr_tmm_1011 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_tmm_1011.
    TYPES:  row       TYPE i,
            useremail TYPE i_workplaceaddress-defaultemailaddress, " ADD BY XINLEI XU 2025/03/17
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zrtmm1011
        RESULT result,
      processlogic FOR MODIFY
        IMPORTING keys FOR ACTION zrtmm1011~processlogic RESULT result.

    METHODS check  CHANGING ct_data TYPE lty_request_t.
    METHODS excute CHANGING ct_data TYPE lty_request_t.
    METHODS export IMPORTING it_data              TYPE lty_request_t
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.
ENDCLASS.

CLASS lhc_zr_tmm_1011 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD processlogic.

    DATA: lt_request TYPE TABLE OF lty_request,
          lt_export  TYPE TABLE OF lty_request.

    DATA: i TYPE i.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_request.
      i += 1.

      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).

      CASE lv_event.
        WHEN 'CHECK'.
          check( CHANGING ct_data = lt_request ).
        WHEN 'EXCUTE'.
          excute( CHANGING ct_data = lt_request ).
        WHEN 'EXPORT'.
          APPEND LINES OF lt_request TO lt_export.
        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

      IF lv_event = 'EXPORT' AND i = lines( keys ).
        DATA(lv_recorduuid) = export( EXPORTING it_data = lt_export ).

        APPEND VALUE #( %cid   = key-%cid
                        %param = VALUE #( event = lv_event
                                          zzkey = lv_json
                                          recorduuid = lv_recorduuid ) ) TO result.
      ELSE.
        APPEND VALUE #( %cid   = key-%cid
                        %param = VALUE #( event = lv_event
                                          zzkey = lv_json ) ) TO result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD check.
    DATA: lv_message  TYPE string,
          lv_msg      TYPE string,
          lv_length   TYPE i,
          lv_item_pos TYPE i.

    CHECK ct_data IS NOT INITIAL.

*&--ADD BEGIN BY XINLEI XU 2025/03/17
    READ TABLE ct_data INTO DATA(ls_data) INDEX 1.
*&--ADD END BY XINLEI XU 2025/03/17

*    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ). " DEL BY XINLEI XU 2025/03/17
    DATA(lv_plant) = zzcl_common_utils=>get_plant_by_user( ls_data-useremail ).

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CLEAR lv_length.
      lv_length = strlen( <lfs_data>-orderkey ).
      IF lv_length > 5.
        lv_item_pos = lv_length - 5.
        <lfs_data>-purchaseorder = <lfs_data>-orderkey+0(lv_item_pos).
        <lfs_data>-purchaseorderitem = <lfs_data>-orderkey+lv_item_pos(5).

        <lfs_data>-purchaseorder = |{ <lfs_data>-purchaseorder ALPHA = IN }|.
      ENDIF.
    ENDLOOP.

    SELECT purchaseorder,
           purchaseorderitem,
           material,
           plant,
           orderquantity,
           storagelocation,
           purchaseorderquantityunit
           FROM i_purchaseorderitemapi01
           FOR ALL ENTRIES IN @ct_data
           WHERE purchaseorder = @ct_data-purchaseorder
           AND purchaseorderitem = @ct_data-purchaseorderitem
           INTO TABLE @DATA(lt_po_data).

    LOOP AT ct_data ASSIGNING <lfs_data>.
      CLEAR: <lfs_data>-status,<lfs_data>-message.
      CLEAR: lv_message.

      IF <lfs_data>-documentdate IS INITIAL.
        <lfs_data>-documentdate = cl_abap_context_info=>get_system_date( ).
      ENDIF.

      IF <lfs_data>-postingdate IS INITIAL.
        <lfs_data>-postingdate = cl_abap_context_info=>get_system_date( ).
      ENDIF.

      IF <lfs_data>-purchaseorder IS INITIAL.
        MESSAGE e003(zmm_020) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-purchaseorderitem IS INITIAL.
        MESSAGE e004(zmm_020) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

*      IF <lfs_data>-batch IS INITIAL.
*        MESSAGE e005(zmm_020) INTO lv_msg.
*        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
*      ENDIF.

      IF <lfs_data>-quantityinentryunit IS INITIAL.
        MESSAGE e006(zmm_020) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      READ TABLE lt_po_data INTO DATA(ls_po_data) WITH KEY purchaseorder = <lfs_data>-purchaseorder
                                                           purchaseorderitem = <lfs_data>-purchaseorderitem.
      IF sy-subrc <> 0.
        MESSAGE e007(zmm_020) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ELSE.
        IF <lfs_data>-entryunit IS INITIAL.
          <lfs_data>-entryunit = ls_po_data-purchaseorderquantityunit.
        ENDIF.

        IF <lfs_data>-material IS INITIAL.
          <lfs_data>-material = ls_po_data-material.
        ENDIF.

        IF <lfs_data>-plant IS INITIAL.
          <lfs_data>-plant = ls_po_data-plant.
        ENDIF.

        IF <lfs_data>-storagelocation IS INITIAL.
          <lfs_data>-storagelocation = ls_po_data-storagelocation.
        ENDIF.


        <lfs_data>-goodsmovementtype = '101'.
        "<lfs_data>-inventorytransactiontype = 'A01'.
        <lfs_data>-goodsmovementcode = '01'.
      ENDIF.

      IF <lfs_data>-plant IS INITIAL.
        MESSAGE e008(zmm_020) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ELSEIF NOT lv_plant CS <lfs_data>-plant.
        MESSAGE e027(zbc_001) WITH <lfs_data>-plant INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-storagelocation IS INITIAL.
        MESSAGE e009(zmm_020) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.


      IF lv_message IS NOT INITIAL.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = lv_message.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD excute.

    TYPES:
      BEGIN OF ty_item_data,
        material                    TYPE matnr,
        purchase_order              TYPE ebeln,
        purchase_order_item         TYPE ebelp,
        quantity_in_entry_unit      TYPE string,
        entry_unit                  TYPE erfme,
        plant                       TYPE werks_d,
        storage_location            TYPE lgort_d,
        batch                       TYPE charg_d,
        goods_movement_type         TYPE bwart,
        goods_movement_ref_doc_type TYPE c LENGTH 1,
      END OF ty_item_data,


      BEGIN OF lty_matdoc_item,
        results TYPE STANDARD TABLE OF ty_item_data WITH DEFAULT KEY,
      END OF lty_matdoc_item,

      BEGIN OF lty_matdoc_header,
*        materialdocument           TYPE mblnr,
*        materialdocumentyear       TYPE mjahr,
        document_date                 TYPE string,
        posting_date                  TYPE string,
        material_document_header_text TYPE bktxt,
        goods_movement_code           TYPE c LENGTH 2,
        to_materialdocumentitem       TYPE lty_matdoc_item,

      END OF lty_matdoc_header,

      BEGIN OF lty_matdoc_header_res,
        material_document             TYPE mblnr,
        material_document_year        TYPE mjahr,
        document_date                 TYPE string,
        posting_date                  TYPE string,
        material_document_header_text TYPE bktxt,

      END OF lty_matdoc_header_res,

*&--Response
      BEGIN OF lty_response,
        d TYPE lty_matdoc_header_res,
      END OF lty_response.

    DATA: ls_request      TYPE lty_matdoc_header,
          ls_response     TYPE lty_response,
          ls_update_table TYPE ztmm_1011,
          lt_update_table TYPE TABLE OF ztmm_1011.

    DATA: lv_message   TYPE string,
          lv_timestamp TYPE tzntstmpl,
          lv_quantity  TYPE string,
          lv_unit      TYPE msehiunit,
          ls_error     TYPE zzcl_odata_utils=>gty_error.

    check( CHANGING ct_data = ct_data ).
*    IF line_exists( ct_data[ status = 'E' ] ).
*      RETURN.
*    ENDIF.

    " Sub contract request, the internal table usually has only one entry
    LOOP AT ct_data INTO DATA(ls_data) WHERE status <> 'E'.
      CLEAR ls_request.

      ls_request = VALUE #( document_date                       = |{ ls_data-documentdate+0(4) }-{ ls_data-documentdate+4(2) }-{ ls_data-documentdate+6(2) }T00:00:00|
                            posting_date                          = |{ ls_data-postingdate+0(4) }-{ ls_data-postingdate+4(2) }-{ ls_data-postingdate+6(2) }T00:00:00|
                            material_document_header_text             = ls_data-materialdocumentheadertext
                            "inventory_transaction_type = ls_data-inventorytransactiontype
                            goods_movement_code = ls_data-goodsmovementcode
                          ).

      lv_quantity = ls_data-quantityinentryunit.
      CONDENSE lv_quantity NO-GAPS.

      TRY.
          lv_unit = zzcl_common_utils=>conversion_cunit( iv_alpha = 'OUT' iv_input = ls_data-entryunit ).
        CATCH zzcx_custom_exception.
          lv_unit = ls_data-entryunit.
      ENDTRY.

      ls_request-to_materialdocumentitem-results = VALUE #( ( material = ls_data-material
                                                             purchase_order = ls_data-purchaseorder
                                                             purchase_order_item = ls_data-purchaseorderitem
                                                             quantity_in_entry_unit = lv_quantity
                                                             entry_unit = lv_unit
                                                             plant  = ls_data-plant
                                                             storage_location = ls_data-storagelocation
                                                             batch = ls_data-batch
                                                             goods_movement_type = ls_data-goodsmovementtype
                                                             goods_movement_ref_doc_type = 'B'
                                                          ) ).


      DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).


      REPLACE ALL OCCURRENCES OF `ToMaterialdocumentitem`          IN lv_requestbody  WITH `to_MaterialDocumentItem`.
      REPLACE ALL OCCURRENCES OF 'Results' IN lv_requestbody WITH 'results'.

      DATA(lv_path) = |/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.


      zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                   iv_method      = if_web_http_client=>post
                                                   iv_body        = lv_requestbody
                                         IMPORTING ev_status_code = DATA(lv_status_code)
                                                   ev_response    = DATA(lv_response) ).
      IF lv_status_code = 201.
        xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore )
          ( xco_cp_json=>transformation->boolean_to_abap_bool )
        ) )->write_to( REF #( ls_response ) ).

        "成功
        MESSAGE s000(zmm_020) WITH ls_data-purchaseorder
                                  ls_data-purchaseorderitem
                                  ls_response-d-material_document
                                  INTO lv_message.
        ls_data-status = 'S'.
        ls_data-message = lv_message.
        ls_data-materialdocument = ls_response-d-material_document.
        ls_data-materialdocumentyear = ls_response-d-material_document_year.
        ls_data-materialdocumentitem = 1.


        MODIFY ct_data FROM ls_data TRANSPORTING status message materialdocument materialdocumentyear materialdocumentitem.
      ELSE.
        /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                   CHANGING  data = ls_error ).
        ls_data-status = 'E'.
        ls_data-message = ls_error-error-message-value.
        MODIFY ct_data FROM ls_data TRANSPORTING status message.
      ENDIF.

      " set log
      lt_update_table = CORRESPONDING #( ct_data MAPPING document_date = documentdate
                                                         posting_date = postingdate
                                                         batch = batch
                                                         entry_unit = entryunit
                                                         goods_movement_code = goodsmovementcode
                                                         goods_movement_type = goodsmovementtype
                                                         inventory_transaction_type = inventorytransactiontype
                                                         material = material
                                                         material_document = materialdocument
                                                         material_document_header_text = materialdocumentheadertext
                                                         material_document_item = materialdocumentitem
                                                         material_document_year = materialdocumentyear
                                                         message = message
                                                         order_key = orderkey
                                                         purchase_order = purchaseorder
                                                         purchase_order_item = purchaseorderitem
                                                         quantity_in_entry_unit = quantityinentryunit
                                                         status = status
                                                         storage_location = storagelocation
                                       ).
      GET TIME STAMP FIELD lv_timestamp.
      LOOP AT lt_update_table ASSIGNING FIELD-SYMBOL(<lfs_update_table>).
        CLEAR ls_update_table.
        TRY.
            <lfs_update_table>-uuid = cl_system_uuid=>create_uuid_x16_static( ).
            ##NO_HANDLER
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
        <lfs_update_table>-created_by = sy-uname.
        <lfs_update_table>-created_at = lv_timestamp.
        <lfs_update_table>-last_changed_by = sy-uname.
        <lfs_update_table>-last_changed_at = lv_timestamp.
        <lfs_update_table>-local_last_changed_at = lv_timestamp.
      ENDLOOP.
      MODIFY ztmm_1011 FROM TABLE @lt_update_table.
    ENDLOOP.

  ENDMETHOD.

  METHOD export.
    TYPES:BEGIN OF lty_export,
            message                    TYPE zze_zzkey,
            materialdocument           TYPE mblnr,
            materialdocumentyear       TYPE string,
            materialdocumentitem       TYPE string,
            documentdate               TYPE c LENGTH 10,
            postingdate                TYPE c LENGTH 10,
            materialdocumentheadertext TYPE bktxt,
            orderkey                   TYPE c LENGTH 15,
            quantityinentryunit        TYPE erfmg,
            batch                      TYPE charg_d,
            plant                      TYPE werks_d,
            storagelocation            TYPE lgort_d,
          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.

    LOOP AT it_data INTO DATA(ls_data).
      APPEND INITIAL LINE TO lt_export ASSIGNING FIELD-SYMBOL(<lfs_export>).
      <lfs_export> = CORRESPONDING #( ls_data ).
      <lfs_export>-documentdate = |{ <lfs_export>-documentdate+0(4) }/{ <lfs_export>-documentdate+4(2) }/{ <lfs_export>-documentdate+6(2) }|.
      <lfs_export>-postingdate   = |{ <lfs_export>-postingdate+0(4) }/{ <lfs_export>-postingdate+4(2) }/{ <lfs_export>-postingdate+6(2) }|.

      IF ls_data-materialdocumentyear IS INITIAL.
        CLEAR <lfs_export>-materialdocumentyear.
      ENDIF.

      IF ls_data-materialdocumentitem IS INITIAL.
        CLEAR <lfs_export>-materialdocumentitem.
      ENDIF.
    ENDLOOP.

    SELECT SINGLE uuidconf, object, templatecontent, startcolumn, startrow
      FROM zzc_dtimp_conf
     WHERE object = 'ZDOWNLOAD_PO'
      INTO @DATA(ls_file_conf).
    IF sy-subrc = 0.
      " FILE_CONTENT must be populated with the complete file content of the .XLSX file
      " whose content shall be processed programmatically.
      DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( ls_file_conf-templatecontent ).
      DATA(lo_write_access) = lo_document->write_access(  ).
      DATA(lo_worksheet) = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).

      DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
        )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( ls_file_conf-startcolumn )
        )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( ls_file_conf-startrow )
        )->get_pattern( ).

      lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_export )
        )->execute( ).

      DATA(lv_file) = lo_write_access->get_file_content( ).

      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
        CATCH cx_uuid_error.
          "handle exception
          RETURN.
      ENDTRY.

      GET TIME STAMP FIELD DATA(lv_timestamp).



      INSERT INTO zzt_prt_record VALUES @( VALUE #( record_uuid     = lv_uuid
                                                    provided_keys   = |PO一括入庫_エクセル出力|
                                                    pdf_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    pdf_file_name   = |購買発注入庫実績一括登録_{ lv_timestamp }.xlsx|
                                                    pdf_content     = lv_file
                                                    created_by      = sy-uname
                                                    created_at      = lv_timestamp
                                                    last_changed_by = sy-uname
                                                    last_changed_at = lv_timestamp
                                                    local_last_changed_at = lv_timestamp ) ).

      TRY.
          cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = lv_uuid
                                                   IMPORTING uuid_c36 = rv_recorduuid  ).
        CATCH cx_uuid_error.
          " handle exception
          RETURN.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


ENDCLASS.
