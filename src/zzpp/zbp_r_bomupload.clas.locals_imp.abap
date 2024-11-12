CLASS lhc_zr_bomupload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_bomupload.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR bomupload RESULT result.
    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION bomupload~processlogic RESULT result.

    METHODS check  CHANGING ct_data TYPE lty_request_t.
    METHODS excute CHANGING ct_data TYPE lty_request_t.
    METHODS export IMPORTING it_data              TYPE lty_request_t
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.
    METHODS get_message IMPORTING io_message    TYPE REF TO if_abap_behv_message
                        RETURNING VALUE(rv_msg) TYPE string.
ENDCLASS.

CLASS lhc_zr_bomupload IMPLEMENTATION.

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
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.
    DATA: lv_subitem_quantity TYPE zr_bomupload-billofmaterialsubitemquantity.

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CLEAR: <lfs_data>-status,<lfs_data>-message.
      CLEAR: lv_message.

      IF <lfs_data>-material IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-001 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-plant IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-002 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-billofmaterialvariantusage IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-003 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-headervaliditystartdate IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-004 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-bomheaderquantityinbaseunit IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-005 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-billofmaterialitemnumber IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-006 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-billofmaterialitemcategory IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-007 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-billofmaterialitemquantity IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-008 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-billofmaterialitemunit IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-009 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      " 副明細の数量取得 = 副明細設定术イ小卜数量 * 副明細数量
      IF <lfs_data>-bomsubiteminstallationpoint IS NOT INITIAL.
        CLEAR lv_subitem_quantity.
        SPLIT <lfs_data>-bomsubiteminstallationpoint AT ',' INTO TABLE DATA(lt_bomsubitem_points).
        lv_subitem_quantity = lines( lt_bomsubitem_points ) * <lfs_data>-billofmaterialsubitemquantity.
        " 構成数量 <> 副明細の数量
        IF lv_subitem_quantity <> <lfs_data>-billofmaterialitemquantity.
          MESSAGE e106(zpp_001) INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        ENDIF.
      ENDIF.

      IF lv_message IS NOT INITIAL.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = lv_message.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD excute.
    TYPES:
*&--BOM Sub item
      BEGIN OF lty_bom_subitem,
        bomsubiteminstallationpoint   TYPE i_billofmaterialsubitemtp_2-bomsubiteminstallationpoint,
        billofmaterialsubitemquantity TYPE string,
      END OF lty_bom_subitem,
*&--BOM Item
      BEGIN OF lty_bom_item,
        validity_start_date            TYPE string,
        bill_of_material_item_number   TYPE i_billofmaterialitemtp_2-billofmaterialitemnumber,
        bill_of_material_item_category TYPE i_billofmaterialitemtp_2-billofmaterialitemcategory,
        bill_of_material_component     TYPE i_billofmaterialitemtp_2-billofmaterialcomponent,
        bill_of_material_item_quantity TYPE string,
        bill_of_material_item_unit     TYPE i_billofmaterialitemtp_2-billofmaterialitemunit,
        b_o_m_item_sorter              TYPE i_billofmaterialitemtp_2-bomitemsorter,
        component_scrap_in_percent     TYPE string,
        alternative_item_group         TYPE i_billofmaterialitemtp_2-alternativeitemgroup,
        alternative_item_priority      TYPE i_billofmaterialitemtp_2-alternativeitempriority,
        alternative_item_strategy      TYPE i_billofmaterialitemtp_2-alternativeitemstrategy,
        usage_probability_percent      TYPE string,
        b_o_m_item_description         TYPE i_billofmaterialitemtp_2-bomitemdescription,
        b_o_m_item_text2               TYPE i_billofmaterialitemtp_2-bomitemtext2,
        prod_order_issue_location      TYPE i_billofmaterialitemtp_2-prodorderissuelocation,
        b_o_m_item_is_costing_relevant TYPE i_billofmaterialitemtp_2-bomitemiscostingrelevant,
        to_b_o_m_sub_items             TYPE TABLE OF lty_bom_subitem WITH DEFAULT KEY,
      END OF lty_bom_item,
*&--BOM Header
      BEGIN OF lty_bom_header,
        bill_of_material               TYPE i_billofmaterialtp_2-billofmaterial,
        bill_of_material_variant       TYPE i_billofmaterialtp_2-billofmaterialvariant,
        material                       TYPE i_billofmaterialtp_2-material,
        plant                          TYPE i_billofmaterialtp_2-plant,
        bill_of_material_variant_usage TYPE i_billofmaterialtp_2-billofmaterialvariantusage,
        header_validity_start_date     TYPE string,
        bomheaderquantityinbaseunit    TYPE string,
        b_o_m_header_text              TYPE i_billofmaterialtp_2-bomheadertext,
        b_o_m_alternative_text         TYPE i_billofmaterialtp_2-bomalternativetext,
        bill_of_material_status        TYPE i_billofmaterialtp_2-billofmaterialstatus,
        to_bill_of_material_item       TYPE TABLE OF lty_bom_item WITH DEFAULT KEY,
      END OF lty_bom_header,
*&--Response
      BEGIN OF lty_response,
        d TYPE lty_bom_header,
      END OF lty_response.

    DATA: ls_request      TYPE lty_bom_header,
          ls_bom_item     TYPE lty_bom_item,
          ls_bom_subitem  TYPE lty_bom_subitem,
          ls_response     TYPE lty_response,
          ls_update_table TYPE ztpp_1002,
          lt_update_table TYPE TABLE OF ztpp_1002.

    DATA: lv_baseunit  TYPE mseh3,
          lv_message   TYPE string,
          lv_timestamp TYPE tzntstmpl,
          ls_error     TYPE zzcl_odata_utils=>gty_error.

    check( CHANGING ct_data = ct_data ).
    IF line_exists( ct_data[ status = 'E' ] ).
      RETURN.
    ENDIF.

    CLEAR: ls_request.
    LOOP AT ct_data INTO DATA(ls_data).

      " BOM Header
      IF sy-tabix = 1.
        DATA(lv_datetime) = |{ ls_data-headervaliditystartdate+0(4) }-{ ls_data-headervaliditystartdate+4(2) }-{ ls_data-headervaliditystartdate+6(2) }T00:00:00|.
        ls_request = VALUE #( material                       = ls_data-material
                              plant                          = ls_data-plant
                              bill_of_material_variant_usage = ls_data-billofmaterialvariantusage
                              bill_of_material_variant       = ls_data-billofmaterialvariant
                              header_validity_start_date     = lv_datetime
                              bomheaderquantityinbaseunit    = ls_data-bomheaderquantityinbaseunit
                              b_o_m_header_text              = ls_data-bomheadertext
                              b_o_m_alternative_text         = ls_data-bomalternativetext
                              bill_of_material_status        = ls_data-billofmaterialstatus ).
        CONDENSE ls_request-bomheaderquantityinbaseunit NO-GAPS.
      ENDIF.

      " BOM Items
      CLEAR ls_bom_item.
      ls_bom_item = VALUE #( validity_start_date            = lv_datetime
                             bill_of_material_item_number   = ls_data-billofmaterialitemnumber
                             bill_of_material_item_category = ls_data-billofmaterialitemcategory
                             bill_of_material_component     = ls_data-billofmaterialcomponent
                             bill_of_material_item_quantity = ls_data-billofmaterialitemquantity
                             bill_of_material_item_unit     = ls_data-billofmaterialitemunit
                             b_o_m_item_sorter              = ls_data-bomitemsorter
                             component_scrap_in_percent     = ls_data-componentscrapinpercent
                             alternative_item_group         = ls_data-alternativeitemgroup
                             alternative_item_priority      = ls_data-alternativeitempriority
                             alternative_item_strategy      = ls_data-alternativeitemstrategy
                             usage_probability_percent      = ls_data-usageprobabilitypercent
                             b_o_m_item_description         = ls_data-bomitemdescription
                             b_o_m_item_text2               = ls_data-bomitemtext2
                             prod_order_issue_location      = ls_data-prodorderissuelocation
                             b_o_m_item_is_costing_relevant = ls_data-bomitemiscostingrelevant ).
      CONDENSE ls_bom_item-bill_of_material_item_quantity NO-GAPS.
      CONDENSE ls_bom_item-component_scrap_in_percent NO-GAPS.
      CONDENSE ls_bom_item-usage_probability_percent NO-GAPS.

      " BOM Sub Items
      SPLIT ls_data-bomsubiteminstallationpoint AT ',' INTO TABLE DATA(lt_bomsubitem_points).
      LOOP AT lt_bomsubitem_points INTO DATA(lv_bomsubitem_point).
        CLEAR ls_bom_subitem.
        ls_bom_subitem = VALUE #( bomsubiteminstallationpoint   = lv_bomsubitem_point
                                  billofmaterialsubitemquantity = ls_data-billofmaterialsubitemquantity ).
        CONDENSE ls_bom_subitem-billofmaterialsubitemquantity NO-GAPS.
        APPEND ls_bom_subitem TO ls_bom_item-to_b_o_m_sub_items.
      ENDLOOP.

      APPEND ls_bom_item TO ls_request-to_bill_of_material_item.
    ENDLOOP.

    DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    REPLACE ALL OCCURRENCES OF `ToBillOfMaterialItem`          IN lv_requestbody  WITH `to_BillOfMaterialItem`.
    REPLACE ALL OCCURRENCES OF `ToBOMSubItems`                 IN lv_requestbody  WITH `to_BOMSubItems`.
    REPLACE ALL OCCURRENCES OF `Bomheaderquantityinbaseunit`   IN lv_requestbody  WITH `BOMHeaderQuantityInBaseUnit`.
    REPLACE ALL OCCURRENCES OF `Bomsubiteminstallationpoint`   IN lv_requestbody  WITH `BOMSubItemInstallationPoint`.
    REPLACE ALL OCCURRENCES OF `Billofmaterialsubitemquantity` IN lv_requestbody  WITH `BillOfMaterialSubItemQuantity`.

    DATA(lv_path) = |/API_BILL_OF_MATERIAL_SRV;v=2/MaterialBOM?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

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

      " BOM登録成功しました。
      MESSAGE s080(zpp_001) WITH |BOM { ls_response-d-bill_of_material }/{ ls_response-d-bill_of_material_variant }| INTO lv_message.
      ls_data-status = 'S'.
      ls_data-message = lv_message.
      MODIFY ct_data FROM ls_data TRANSPORTING status message WHERE row IS NOT INITIAL.
    ELSE.
      /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                 CHANGING  data = ls_error ).
      ls_data-status = 'E'.
      ls_data-message = ls_error-error-message-value.
      MODIFY ct_data FROM ls_data TRANSPORTING status message WHERE row IS NOT INITIAL.
    ENDIF.

    " set log
    lt_update_table = CORRESPONDING #( ct_data ).
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
    MODIFY ztpp_1002 FROM TABLE @lt_update_table.
  ENDMETHOD.

  METHOD export.
    TYPES:BEGIN OF lty_export,
            status                        TYPE bapi_mtype,
            message                       TYPE zze_zzkey,
            material                      TYPE zr_bomupload-material,
            plant                         TYPE zr_bomupload-plant,
            billofmaterialvariantusage    TYPE zr_bomupload-billofmaterialvariantusage,
            billofmaterialvariant         TYPE zr_bomupload-billofmaterialvariant,
            headervaliditystartdate       TYPE string,
            bomheaderquantityinbaseunit   TYPE zr_bomupload-bomheaderquantityinbaseunit,
            bomheadertext                 TYPE zr_bomupload-bomheadertext,
            bomalternativetext            TYPE zr_bomupload-bomalternativetext,
            billofmaterialstatus          TYPE zr_bomupload-billofmaterialstatus,
            billofmaterialitemnumber      TYPE zr_bomupload-billofmaterialitemnumber,
            billofmaterialitemcategory    TYPE zr_bomupload-billofmaterialitemcategory,
            billofmaterialcomponent       TYPE zr_bomupload-billofmaterialcomponent,
            billofmaterialitemquantity    TYPE zr_bomupload-billofmaterialitemquantity,
            billofmaterialitemunit        TYPE zr_bomupload-billofmaterialitemunit,
            bomitemsorter                 TYPE zr_bomupload-bomitemsorter,
            componentscrapinpercent       TYPE zr_bomupload-componentscrapinpercent,
            alternativeitemgroup          TYPE zr_bomupload-alternativeitemgroup,
            alternativeitempriority       TYPE zr_bomupload-alternativeitempriority,
            alternativeitemstrategy       TYPE zr_bomupload-alternativeitemstrategy,
            usageprobabilitypercent       TYPE zr_bomupload-usageprobabilitypercent,
            bomitemdescription            TYPE zr_bomupload-bomitemdescription,
            bomitemtext2                  TYPE zr_bomupload-bomitemtext2,
            prodorderissuelocation        TYPE zr_bomupload-prodorderissuelocation,
            bomitemiscostingrelevant      TYPE zr_bomupload-bomitemiscostingrelevant,
            bomsubiteminstallationpoint   TYPE zr_bomupload-bomsubiteminstallationpoint,
            billofmaterialsubitemquantity TYPE zr_bomupload-billofmaterialsubitemquantity,
          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.

    LOOP AT it_data INTO DATA(ls_data).
      APPEND INITIAL LINE TO lt_export ASSIGNING FIELD-SYMBOL(<lfs_export>).
      <lfs_export> = CORRESPONDING #( ls_data ).
      <lfs_export>-headervaliditystartdate = |{ <lfs_export>-headervaliditystartdate+0(4) }/{ <lfs_export>-headervaliditystartdate+4(2) }/{ <lfs_export>-headervaliditystartdate+6(2) }|.
    ENDLOOP.

    SELECT SINGLE *
      FROM zzc_dtimp_conf
     WHERE object = 'ZDOWNLOAD_BOM'
      INTO @DATA(ls_file_conf).               "#EC CI_ALL_FIELDS_NEEDED
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
          ##NO_HANDLER
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

      GET TIME STAMP FIELD DATA(lv_timestamp).

      INSERT INTO zzt_prt_record VALUES @( VALUE #( record_uuid     = lv_uuid
                                                    provided_keys   = |BOMの一括登録_エクセル出力|
                                                    pdf_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    pdf_file_name   = |BOM_Export_{ lv_timestamp }.xlsx|
                                                    pdf_content     = lv_file
                                                    created_by      = sy-uname
                                                    created_at      = lv_timestamp
                                                    last_changed_by = sy-uname
                                                    last_changed_at = lv_timestamp
                                                    local_last_changed_at = lv_timestamp ) ).

      TRY.
          cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = lv_uuid
                                                   IMPORTING uuid_c36 = rv_recorduuid  ).
          ##NO_HANDLER
        CATCH cx_uuid_error.
          " handle exception
      ENDTRY.
    ENDIF.
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
