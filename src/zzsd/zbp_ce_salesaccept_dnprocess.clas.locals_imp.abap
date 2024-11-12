CLASS lhc_dnprocess DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR dnprocess RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE dnprocess.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE dnprocess.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE dnprocess.

    METHODS read FOR READ
      IMPORTING keys FOR READ dnprocess RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK dnprocess.

    METHODS checkrecords FOR MODIFY
      IMPORTING keys FOR ACTION dnprocess~checkrecords RESULT result.
    METHODS createdn FOR MODIFY
      IMPORTING keys FOR ACTION dnprocess~createdn RESULT result.

ENDCLASS.

CLASS lhc_dnprocess IMPLEMENTATION.

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

  METHOD checkrecords.
    DATA records TYPE TABLE OF zce_salesaccept_dnprocess.
    DATA record_temp LIKE LINE OF records.
    DATA lv_message TYPE string.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).
    ENDLOOP.
    LOOP AT records INTO record_temp.
      record_temp-soldtoparty = |{ record_temp-soldtoparty ALPHA = IN }|.
      record_temp-product = |{ record_temp-product ALPHA = IN }|.
      MODIFY records FROM record_temp.
    ENDLOOP.

    "获取模板需要的客户数据
    SELECT
      *
    FROM ztbc_1001
    WHERE zid = 'ZSD001'
      OR zid = 'ZSD002'
    INTO TABLE @DATA(lt_bc1001).

    LOOP AT records ASSIGNING FIELD-SYMBOL(<fs_record>).
      "根据模板决定SoldToParty
      IF <fs_record>-soldtoparty IS INITIAL.
        CASE <fs_record>-filetype.
            "アラクサラネットワークス株式会社
          WHEN '0'.
            READ TABLE lt_bc1001 INTO DATA(ls_bc1001) WITH KEY zid = 'ZSD001'.
            IF sy-subrc = 0.
              <fs_record>-soldtoparty = ls_bc1001-zvalue1.
            ENDIF.
            "日立オムロンターミナルソリューションズ株式会社
          WHEN '1' OR '2'.
            READ TABLE lt_bc1001 INTO ls_bc1001 WITH KEY zid = 'ZSD002'
              zvalue1 = <fs_record>-purchasefrom zvalue2 = <fs_record>-soldto.
            IF sy-subrc = 0.
              <fs_record>-soldtoparty = ls_bc1001-zvalue3.
            ENDIF.
        ENDCASE.
        <fs_record>-soldtoparty = |{ <fs_record>-soldtoparty ALPHA = IN }|.
      ENDIF.
    ENDLOOP.

    "获取要返回的报表数据
    IF records IS NOT INITIAL.
      SELECT
        *
      FROM zc_salesdocumentfordn
      FOR ALL ENTRIES IN @records
      WHERE purchaseorderbycustomer = @records-purchaseorderbycustomer
        AND soldtoparty = @records-soldtoparty
      INTO TABLE @DATA(lt_salesdocumentfordn).
    ENDIF.
    "返回结果
    DATA ls_result LIKE LINE OF result.
    LOOP AT lt_salesdocumentfordn INTO DATA(ls_salesdocumentfordn).
      ls_result-%cid = keys[ 1 ]-%cid.
      MOVE-CORRESPONDING ls_salesdocumentfordn TO ls_result-%param.
      "如果上传的purchaseorderbycustomer和soldtoparty组合唯一，则此种方式没有问题，
      "如果不唯一且是合理数据，则可能需要用records循环套用lt_salesdocumentfordn循环
      READ TABLE records INTO record_temp WITH KEY purchaseorderbycustomer = ls_salesdocumentfordn-purchaseorderbycustomer
        soldtoparty = ls_salesdocumentfordn-soldtoparty.
      "传回前端传入的字段
      IF sy-subrc = 0.
        ls_result-%param-purchasefrom = record_temp-purchasefrom.
        ls_result-%param-soldto = record_temp-soldto.
        ls_result-%param-acceptdate = record_temp-acceptdate.
        ls_result-%param-acceptquantity = record_temp-acceptquantity.
        ls_result-%param-acceptunit = record_temp-acceptunit."前端不会传入此字段
      ENDIF.

      "校验 検収数＜受注残数 时报错
      IF record_temp-acceptquantity < ls_salesdocumentfordn-undeliveredqty.
        ls_result-%param-type = 'E'.
        MESSAGE e015(zsd_001) INTO lv_message.
        ls_result-%param-message = zzcl_common_utils=>merge_message(  iv_message1 = ls_result-%param-message
                                                                      iv_message2 = lv_message
                                                                      iv_symbol = ';' ).
      ENDIF.
      APPEND ls_result TO result.
      CLEAR ls_result.
    ENDLOOP.

  ENDMETHOD.

  METHOD createdn.
    DATA records TYPE TABLE OF zce_salesaccept_dnprocess.
    DATA record_temp LIKE LINE OF records.
    DATA lv_message TYPE string.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).
    ENDLOOP.
    "创建DN的结构 创建DN时允许的字段有限，请参考note 2899036
    TYPES:
      BEGIN OF ty_delivery_document_item,
        reference_s_d_document      TYPE i_outbounddeliveryitemtp-referencesddocument,
        reference_s_d_document_item TYPE i_outbounddeliveryitemtp-referencesddocumentitem,
        actual_delivery_quantity    TYPE string,
        delivery_quantity_unit      TYPE i_outbounddeliveryitemtp-orderquantityunit,
      END OF ty_delivery_document_item,
      BEGIN OF ty_item_results,
        results TYPE TABLE OF ty_delivery_document_item WITH DEFAULT KEY,
      END OF ty_item_results,
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

    "DN修改
    TYPES:
      BEGIN OF ty_update_header,
        actual_goods_movement_date TYPE string,
      END OF ty_update_header,

      BEGIN OF ty_update_request,
        header_data TYPE ty_update_header,
      END OF ty_update_request.
    DATA: ls_update_request TYPE ty_update_request.


    "一个so对应一个dn 所以用SO作为抬头,但按照业务逻辑，一般也不会出现多个so
    DATA(records_key) = records.
    SORT records_key BY salesdocument.
    DELETE ADJACENT DUPLICATES FROM records_key COMPARING salesdocument.
    "给request中填充数据
    LOOP AT records_key INTO DATA(record_key).
      is_error = abap_false.
      ls_request-shipping_point = record_key-shippingpoint.
      IF record_key-acceptdate IS INITIAL.
        record_key-acceptdate = cl_abap_context_info=>get_system_date( ).
      ENDIF.

      CLEAR ls_request-to_delivery_document_item-results.
      " 行项目信息
      LOOP AT records INTO record_temp WHERE salesdocument = record_key-salesdocument.
        ls_bom_item-reference_s_d_document = record_temp-salesdocument.
        ls_bom_item-reference_s_d_document_item = record_temp-salesdocumentitem.
        ls_bom_item-actual_delivery_quantity = record_temp-acceptquantity.
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

        "保存一些无法通过API或者BOI修改的字段信息到自建表，后续通过再次调用修改API 通过增强实现
        "有些字段在创建时无法赋值，需要通过修改来实现，
        "其中【外部実績日付】【内部実績日付】无法直接需改，需要通过增强逻辑实现（和AcceptDate保持一致）
        DATA ls_sd1009 TYPE ztsd_1009.
        ls_sd1009-delivery_document = |{ ls_response-d-delivery_document ALPHA = IN }|.
        ls_sd1009-purchase_order_by_customer = record_key-purchaseorderbycustomer.
        ls_sd1009-sold_to_party = |{ record_key-soldtoparty ALPHA = IN }|.
        ls_sd1009-product_by_purchase = |{ record_key-productbypurchase ALPHA = IN }|.
        ls_sd1009-accept_quantity = record_key-acceptquantity.
        ls_sd1009-accept_unit = record_key-acceptunit.
        ls_sd1009-accept_date = record_key-acceptdate.
        ls_sd1009-is_extension_used = abap_false.
        ls_sd1009-created_by = cl_abap_context_info=>get_user_technical_name( ).
        ls_sd1009-created_on = cl_abap_context_info=>get_system_date( ).
        ls_sd1009-created_at = cl_abap_context_info=>get_system_time( ).
        MODIFY ztsd_1009 FROM @ls_sd1009.

        CLEAR ls_update_request.
        ls_update_request-header_data-actual_goods_movement_date = |{ record_key-acceptdate+0(4) }-{ record_key-acceptdate+4(2) }-{ record_key-acceptdate+6(2) }T00:00:00|.
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
        IF lv_status_code = 204.
          UPDATE ztsd_1009 SET is_extension_used = @abap_true
            WHERE delivery_document = @ls_response-d-delivery_document.

          "修改行项目
          "TOFIX 目前库存地点逻辑未确定，先填充固定值A622，后续复制SD-015的库存地点的逻辑
          LOOP AT records INTO record_temp WHERE DeliveryDocument = ls_response-d-delivery_document.
            data(lv_param) = |DeliveryDocument='{ record_temp-DeliveryDocument }',DeliveryDocumentItem='{ record_temp-DeliveryDocumentItem }'|.
            lv_path = |/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryItem({ lv_param })?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
            lv_requestbody = |\{"d":\{"StorageLocation":"A622"\}\}|."由于目前只修改一个字段，所以直接构建字符串
            zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                         iv_method      = if_web_http_client=>patch
                                                         iv_body        = lv_requestbody
                                               IMPORTING ev_status_code = lv_status_code
                                                         ev_response    = lv_response ).
            IF lv_status_code <> 204.
              is_error = abap_true.
            ENDIF.
          ENDLOOP.
          if is_error = abap_false.
            "获取ETag
            lv_path = |/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader('{ ls_response-d-delivery_document }')?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
            zzcl_common_utils=>get_api_etag(  EXPORTING iv_odata_version = 'V2'
                                                        iv_path          = lv_path
                                              IMPORTING ev_status_code   = lv_status_code
                                                        ev_response      = lv_response
                                                        ev_etag          = DATA(lv_etag) ).
            if lv_status_code <> 200.
              is_error = abap_true.
            else.
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
            endif.
          endif.
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

    SELECT
      unitofmeasure,
      unitofmeasure_e
    FROM i_unitofmeasure
    INTO TABLE @DATA(lt_unitofmeasure).
    SORT lt_unitofmeasure BY unitofmeasure_e.

    "返回结果
    DATA ls_result LIKE LINE OF result.
    LOOP AT records INTO record_temp.
      ls_result-%cid = keys[ 1 ]-%cid.
      "外部值转内部值（此处如果返回单位外部值会出错）
      READ TABLE lt_unitofmeasure INTO DATA(ls_unitofmeasure) WITH KEY unitofmeasure_e = record_temp-orderquantityunit BINARY SEARCH.
      IF sy-subrc = 0.
        record_temp-orderquantityunit = ls_unitofmeasure-unitofmeasure.
      ENDIF.
      MOVE-CORRESPONDING record_temp TO ls_result-%param.
      APPEND ls_result TO result.
      CLEAR ls_result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zce_salesaccept_dnprocess DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zce_salesaccept_dnprocess IMPLEMENTATION.

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
