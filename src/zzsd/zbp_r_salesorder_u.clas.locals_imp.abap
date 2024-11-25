CLASS lhc_salesorderfordn DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR salesorderfordn RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE salesorderfordn.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE salesorderfordn.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE salesorderfordn.

    METHODS read FOR READ
      IMPORTING keys FOR READ salesorderfordn RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK salesorderfordn.

    METHODS createdeliveryorder FOR MODIFY
      IMPORTING keys FOR ACTION salesorderfordn~createdeliveryorder RESULT result.
    CLASS-METHODS:
      format_date_to_odata
        IMPORTING iv_date        TYPE datum
        RETURNING VALUE(rv_date) TYPE string.

ENDCLASS.

CLASS lhc_salesorderfordn IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD createdeliveryorder.
    DATA records_input TYPE TABLE OF zc_salesorder_u.
    DATA lv_message TYPE string.

    LOOP AT keys INTO DATA(key).
      CLEAR records_input.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records_input ).
    ENDLOOP.

    LOOP AT records_input INTO DATA(record_input).
      record_input-salesdocument = |{ record_input-salesdocument ALPHA = IN }|.
      record_input-salesdocumentitem = |{ record_input-salesdocumentitem ALPHA = IN }|.
      MODIFY records_input FROM record_input.
    ENDLOOP.

    SELECT
      *
    FROM zr_salesorder_u
    FOR ALL ENTRIES IN @records_input
    WHERE salesdocument = @records_input-salesdocument
      AND salesdocumentitem = @records_input-salesdocumentitem
    INTO TABLE @DATA(records).

    DATA record_temp LIKE LINE OF records.

*    LOOP AT keys INTO DATA(ls_keys).
**        ls_keys-%param-DeliveryType "获取参数
*    ENDLOOP.
    LOOP AT records INTO DATA(record).
      READ TABLE records_input INTO record_input WITH KEY salesdocument = record-salesdocument
        salesdocumentitem = record-salesdocumentitem BINARY SEARCH.
      IF sy-subrc = 0.
        record-currdeliveryqty = record_input-currdeliveryqty.
        record-orderquantityunit = record_input-orderquantityunit.
        record-currstoragelocation = record_input-currstoragelocation.
        record-currshippingtype = record_input-currshippingtype.
        record-currplannedgoodsissuedate = record_input-currplannedgoodsissuedate.
        record-currdeliverydate = record_input-currdeliverydate.
      ENDIF.

      "校验
      IF record-currdeliveryqty < 0 OR record-currdeliveryqty > record-remainingqty.
        "不能为0，不能大于剩余数量
      ENDIF.
      MODIFY records FROM record.
    ENDLOOP.
    "创建DN的结构 创建DN时允许的字段有限，请参考note 2899036
    TYPES:
      "创建DN的行项目结构
      BEGIN OF ty_delivery_document_item,
        reference_s_d_document      TYPE i_outbounddeliveryitemtp-referencesddocument,
        reference_s_d_document_item TYPE i_outbounddeliveryitemtp-referencesddocumentitem,
        actual_delivery_quantity    TYPE string,
        delivery_quantity_unit      TYPE i_outbounddeliveryitemtp-orderquantityunit,
      END OF ty_delivery_document_item,
      BEGIN OF ty_item_results,
        results TYPE TABLE OF ty_delivery_document_item WITH DEFAULT KEY,
      END OF ty_item_results,
      "创建DN的抬头结构
      BEGIN OF ty_outb_delivery_head,
        shipping_point            TYPE i_outbounddeliverytp-shippingpoint,
        to_delivery_document_item TYPE ty_item_results,
      END OF ty_outb_delivery_head,
      "create response
      BEGIN OF ty_delivery_reponse,
        delivery_document TYPE vbeln_vl,
      END OF ty_delivery_reponse,
      BEGIN OF ty_response,
        d TYPE ty_delivery_reponse,
      END OF ty_response.
    DATA: ls_request  TYPE ty_outb_delivery_head,
          ls_bom_item TYPE ty_delivery_document_item,
          ls_response TYPE ty_response,
          ls_error_v2 TYPE zzcl_odata_utils=>gty_error,
          is_error    TYPE abap_boolean.
    TYPES:
      "DN修改的抬头结构
      BEGIN OF ty_update_header,
        shipping_type               TYPE i_outbounddeliverytp-shippingtype,
        planned_goods_movement_date TYPE i_outbounddeliverytp-plannedgoodsmovementdate,
        delivery_date               TYPE i_outbounddeliverytp-deliverydate,
*        actual_goods_movement_date TYPE string,
      END OF ty_update_header,

      BEGIN OF ty_update_item,
        storage_location TYPE lgort_d,
      END OF ty_update_item,

      BEGIN OF ty_update_request,
        header_data TYPE ty_update_header,
      END OF ty_update_request.
    DATA: ls_update_request TYPE ty_update_request.

    "TOFIX 实际不是按照so划分DN 应该是按照几个字段来判定是否为一个DN
    "一个so对应一个dn 所以用SO作为抬头
    DATA(records_key) = records.
    SORT records_key BY salesdocument.
    DELETE ADJACENT DUPLICATES FROM records_key COMPARING salesdocument.
    "给request中填充数据
    LOOP AT records_key INTO DATA(record_key).
      is_error = abap_false.
      ls_request-shipping_point = record_key-shippingpoint.
*      IF record_key-acceptdate IS INITIAL.
*        record_key-acceptdate = cl_abap_context_info=>get_system_date( ).
*      ENDIF.

      CLEAR ls_request-to_delivery_document_item-results.
      " 行项目信息
      LOOP AT records INTO record_temp WHERE salesdocument = record_key-salesdocument.
        ls_bom_item-reference_s_d_document = record_temp-salesdocument.
        ls_bom_item-reference_s_d_document_item = record_temp-salesdocumentitem.
        ls_bom_item-actual_delivery_quantity = record_temp-currdeliveryqty.
        ls_bom_item-delivery_quantity_unit = record_temp-orderquantityunit.
        CONDENSE ls_bom_item-actual_delivery_quantity NO-GAPS.
        APPEND ls_bom_item TO ls_request-to_delivery_document_item-results.
        CLEAR ls_bom_item.
      ENDLOOP.

      "将数据转换成json格式
      DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
          ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).

      REPLACE ALL OCCURRENCES OF 'ToDeliveryDocumentItem' IN  lv_requestbody WITH 'to_DeliveryDocumentItem'.
      REPLACE ALL OCCURRENCES OF 'Results' IN  lv_requestbody WITH 'results'.

      DATA(lv_path) = |/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

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
        "DN登録成功しました。
        MESSAGE s006(zsd_001) WITH ls_response-d-delivery_document INTO lv_message.
        record_temp-type = 'S'.
        record_temp-message = lv_message.
        "回写生成的DN和DN行项目以及消息
        LOOP AT ls_request-to_delivery_document_item-results INTO DATA(ls_document_item).
          record_temp-deliverydocument = ls_response-d-delivery_document.
          record_temp-deliverydocumentitem = ls_document_item-reference_s_d_document_item.
          MODIFY records FROM record_temp TRANSPORTING type message deliverydocument deliverydocumentitem
            WHERE salesdocument = ls_document_item-reference_s_d_document
              AND salesdocumentitem = ls_document_item-reference_s_d_document_item.
        ENDLOOP.
        CLEAR record_temp.
        "修改DN

*        "保存一些无法通过API或者BOI修改的字段信息到自建表，后续通过再次调用修改API 通过增强实现
*        "有些字段在创建时无法赋值，需要通过修改来实现，
*        "其中【外部実績日付】【内部実績日付】无法直接需改，需要通过增强逻辑实现（和AcceptDate保持一致）
*        DATA ls_sd1009 TYPE ztsd_1009.
*        ls_sd1009-delivery_document = |{ ls_response-d-delivery_document ALPHA = IN }|.
*        ls_sd1009-purchase_order_by_customer = record_key-purchaseorderbycustomer.
*        ls_sd1009-sold_to_party = |{ record_key-soldtoparty ALPHA = IN }|.
*        ls_sd1009-product_by_purchase = |{ record_key-productbypurchase ALPHA = IN }|.
*        ls_sd1009-accept_quantity = record_key-acceptquantity.
*        ls_sd1009-accept_unit = record_key-acceptunit.
*        ls_sd1009-accept_date = record_key-acceptdate.
*        ls_sd1009-is_extension_used = abap_false.
*        ls_sd1009-created_by = cl_abap_context_info=>get_user_technical_name( ).
*        ls_sd1009-created_on = cl_abap_context_info=>get_system_date( ).
*        ls_sd1009-created_at = cl_abap_context_info=>get_system_time( ).
*        MODIFY ztsd_1009 FROM @ls_sd1009.

        "修改DN抬头
        "有些字段在创建时无法赋值，需要通过修改来实现，

        "判定可以指定的字段是否有输入值，如果没则不需要修改DN
        DATA lv_need_change TYPE abap_bool.
        lv_need_change = abap_false.
        IF record_key-shippingtype IS NOT INITIAL OR record_key-currplannedgoodsissuedate IS NOT INITIAL.
          lv_need_change = abap_true.
        ENDIF.
        IF lv_need_change = abap_true.
          CLEAR ls_update_request.
          "TOFIX 对于api来说，或许不处理的字段结构中也不能有，那么可能无法使用abap2json 需要直接拼接json字符串
          IF record_key-shippingtype IS NOT INITIAL.
            ls_update_request-header_data-shipping_type = record_key-shippingtype.
          ENDIF.
          IF record_key-currplannedgoodsissuedate IS NOT INITIAL.
            ls_update_request-header_data-planned_goods_movement_date = format_date_to_odata( record_key-currplannedgoodsissuedate ).
          ENDIF.
          IF record_key-deliverydate IS NOT INITIAL.
            ls_update_request-header_data-delivery_date = format_date_to_odata( record_key-deliverydate ).
          ENDIF.
          "将数据转换成json格式
          lv_requestbody = xco_cp_json=>data->from_abap( ls_update_request )->apply( VALUE #(
              ( xco_cp_json=>transformation->underscore_to_pascal_case )
            ) )->to_string( ).

          REPLACE ALL OCCURRENCES OF 'HeaderData' IN lv_requestbody WITH 'd'.
          lv_path = |/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader('{ ls_response-d-delivery_document }')?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
          zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                       iv_method      = if_web_http_client=>patch
                                                       iv_body        = lv_requestbody
                                             IMPORTING ev_status_code = lv_status_code
                                                       ev_response    = lv_response ).
        ELSE.
          "因为后续DN行项目修改需要判定lv_status_code，如果DN抬头不修改则直接认为修改成功
          lv_status_code = 204.
        ENDIF.
        IF lv_status_code = 204.
          "修改DN行项目 目前DN行项目只修改一个库存地点，且库存地点会填充默认值，所以直接修改库存地点即可，不需要判定是否有手动输入的值
          LOOP AT records INTO record_temp WHERE deliverydocument = ls_response-d-delivery_document.
            IF record_temp-currstoragelocation IS NOT INITIAL.
              DATA(lv_param) = |DeliveryDocument='{ record_temp-deliverydocument }',DeliveryDocumentItem='{ record_temp-deliverydocumentitem }'|.
              lv_path = |/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryItem({ lv_param })?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
              lv_requestbody = |\{"d":\{"StorageLocation":"{ record_temp-currstoragelocation }"\}\}|."由于目前只修改一个字段，所以直接构建字符串
              zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                           iv_method      = if_web_http_client=>patch
                                                           iv_body        = lv_requestbody
                                                 IMPORTING ev_status_code = lv_status_code
                                                           ev_response    = lv_response ).
              IF lv_status_code <> 204.
                is_error = abap_true.
              ENDIF.
            ENDIF.
          ENDLOOP.
          IF is_error = abap_false.
            "获取ETag
            lv_path = |/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader('{ ls_response-d-delivery_document }')?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
            zzcl_common_utils=>get_api_etag(  EXPORTING iv_odata_version = 'V2'
                                                        iv_path          = lv_path
                                              IMPORTING ev_status_code   = lv_status_code
                                                        ev_response      = lv_response
                                                        ev_etag          = DATA(lv_etag) ).
            IF lv_status_code <> 200.
              is_error = abap_true.
            ELSE.
              "过账DN
              lv_path = |/API_OUTBOUND_DELIVERY_SRV;v=0002/PostGoodsIssue?DeliveryDocument='{ ls_response-d-delivery_document }'|.
              zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                           iv_method      = if_web_http_client=>post
                                                           iv_etag        = lv_etag
                                                 IMPORTING ev_status_code = lv_status_code
                                                           ev_response    = lv_response ).
              IF lv_status_code <> 200.
                is_error = abap_true.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          is_error = abap_true.
        ENDIF.

      ELSE.
        is_error = abap_true.
      ENDIF.
      IF is_error = abap_true.
        xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore )
        ) )->write_to( REF #( ls_error_v2 ) ).

        LOOP AT records INTO record_temp WHERE salesdocument = record_key-salesdocument.
          record_temp-type = 'E'.
          record_temp-message = zzcl_common_utils=>merge_message( iv_message1 = record_temp-message
                                                                  iv_message2 = ls_error_v2-error-message-value
                                                                  iv_symbol   = ';' ).
          MODIFY records FROM record_temp.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    LOOP AT records INTO record.
      record-salesdocument = |{ record-salesdocument ALPHA = OUT }|.
      record-salesdocumentitem = |{ record-salesdocumentitem ALPHA = OUT }|.
      MODIFY records FROM record.
    ENDLOOP.
    DATA(lv_json) = /ui2/cl_json=>serialize( records ).
    APPEND VALUE #( %cid    = key-%cid
                    %param  = VALUE #( zzkey = lv_json ) ) TO result.

  ENDMETHOD.

  METHOD format_date_to_odata.
    rv_date = |{ iv_date+0(4) }-{ iv_date+4(2) }-{ iv_date+6(2) }T00:00:00|.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_salesorderfordn_u DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_salesorderfordn_u IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
