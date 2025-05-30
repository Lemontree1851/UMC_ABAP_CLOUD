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
    DATA lv_etag TYPE string.
    DATA is_check_error TYPE abap_bool.
    DATA lv_json TYPE string.
    DATA lv_api_head TYPE string.
    DATA lv_api_item TYPE string.

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

    is_check_error = abap_false.
    LOOP AT records INTO DATA(record).
      READ TABLE records_input INTO record_input WITH KEY salesdocument = record-salesdocument
        salesdocumentitem = record-salesdocumentitem BINARY SEARCH.
      IF sy-subrc = 0.
        IF record_input-currdeliveryqty <= 0.
          record-currdeliveryqty = record-remainingqty.
        ELSE.
          record-currdeliveryqty = record_input-currdeliveryqty.
        ENDIF.
        record-orderquantityunit = record_input-orderquantityunit.
        record-currstoragelocation = record_input-currstoragelocation.
        record-currshippingtype = record_input-currshippingtype.
        record-currplannedgoodsissuedate = record_input-currplannedgoodsissuedate.
        record-currdeliverydate = record_input-currdeliverydate.
      ENDIF.

      "校验
      "不能大于剩余数量
      IF record-currdeliveryqty > record-remainingqty.
        is_check_error = abap_true.
        record-type = 'E'.
        MESSAGE e022(zsd_001) INTO record-message.
      ENDIF.
      MODIFY records FROM record.
    ENDLOOP.
    IF is_check_error = abap_true.
      LOOP AT records INTO record.
        record-salesdocument = |{ record-salesdocument ALPHA = OUT }|.
        record-salesdocumentitem = |{ record-salesdocumentitem ALPHA = OUT }|.
        MODIFY records FROM record.
      ENDLOOP.
      lv_json = /ui2/cl_json=>serialize( records ).
      APPEND VALUE #( %cid    = key-%cid
                      %param  = VALUE #( zzkey = lv_json ) ) TO result.
      EXIT.
    ENDIF.

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
    DATA: ls_request       TYPE ty_outb_delivery_head,
          ls_delivery_item TYPE ty_delivery_document_item,
          ls_response      TYPE ty_response,
          ls_error_v2      TYPE zzcl_odata_utils=>gty_error,
          is_error         TYPE abap_boolean.
    TYPES:
      "DN修改的抬头结构
      BEGIN OF ty_update_header,
        planned_goods_issue_date TYPE string,
        goods_issue_time         TYPE string,
        delivery_date            TYPE string,
        delivery_time            TYPE string,
*        actual_goods_movement_date TYPE string,
        bill_of_lading           TYPE string,
      END OF ty_update_header,

      BEGIN OF ty_update_item,
        storage_location TYPE lgort_d,
      END OF ty_update_item,

      BEGIN OF ty_update_request,
        header_data TYPE ty_update_header,
      END OF ty_update_request.
    DATA: ls_update_request TYPE ty_update_request.

    DATA lv_item_index TYPE i.

    "TOFIX 实际不是按照so划分DN 应该是按照几个字段来判定是否为一个DN
    "一个so对应一个dn 所以用SO作为抬头
    DATA(records_key) = records.

*&--MOD BEGIN BY XINLEI XU 2025/03/21 按维度将数据分组，相同维度的数据创建一个DN
*    SORT records_key BY salesdocument.
*    DELETE ADJACENT DUPLICATES FROM records_key COMPARING salesdocument.
    SORT records_key BY salesdocumenttype
                        salesorganization
                        shippingpoint
                        soldtoparty
                        billingtoparty
                        shiptoparty
                        plant
                        transitplant
                        route
                        shippingtype
                        incotermsclassification
                        incotermstransferlocation.
    DELETE ADJACENT DUPLICATES FROM records_key COMPARING salesdocumenttype
                                                          salesorganization
                                                          shippingpoint
                                                          soldtoparty
                                                          billingtoparty
                                                          shiptoparty
                                                          plant
                                                          transitplant
                                                          route
                                                          shippingtype
                                                          incotermsclassification
                                                          incotermstransferlocation.
    IF records_key IS NOT INITIAL.
      SELECT zid,
             zseq,
             zvalue1
        FROM ztbc_1001
       WHERE zid = 'ZSD016'
        INTO TABLE @DATA(lt_config).
      SORT lt_config BY zvalue1.
    ENDIF.
*&--MOD END BY XINLEI XU 2025/03/21

    "给request中填充数据
    LOOP AT records_key INTO DATA(record_key).
      is_error = abap_false.
      ls_request-shipping_point = record_key-shippingpoint.
*      IF record_key-acceptdate IS INITIAL.
*        record_key-acceptdate = cl_abap_context_info=>get_system_date( ).
*      ENDIF.

      CLEAR ls_request-to_delivery_document_item-results.
      " 行项目信息
      CLEAR lv_item_index.
*&--MOD BEGIN BY XINLEI XU 2025/03/21 按维度将数据分组，相同维度的数据创建一个DN
*      LOOP AT records INTO record_temp WHERE salesdocument = record_key-salesdocument.
      LOOP AT records INTO record_temp WHERE salesdocumenttype = record_key-salesdocumenttype
                                         AND salesorganization = record_key-salesorganization
                                         AND shippingpoint = record_key-shippingpoint
                                         AND soldtoparty = record_key-soldtoparty
                                         AND billingtoparty = record_key-billingtoparty
                                         AND shiptoparty = record_key-shiptoparty
                                         AND plant = record_key-plant
                                         AND transitplant = record_key-transitplant
                                         AND route = record_key-route
                                         AND shippingtype = record_key-shippingtype
                                         AND incotermsclassification = record_key-incotermsclassification
                                         AND incotermstransferlocation = record_key-incotermstransferlocation.
*&--MOD END BY XINLEI XU 2025/03/21
        ls_delivery_item-reference_s_d_document = record_temp-salesdocument.
        ls_delivery_item-reference_s_d_document_item = record_temp-salesdocumentitem.
        ls_delivery_item-actual_delivery_quantity = record_temp-currdeliveryqty.
        ls_delivery_item-delivery_quantity_unit = record_temp-orderquantityunit.
        CONDENSE ls_delivery_item-actual_delivery_quantity NO-GAPS.
        APPEND ls_delivery_item TO ls_request-to_delivery_document_item-results.
        CLEAR ls_delivery_item.

        "根据目前测试判定 生成的DN行项目和参考so行项目无关，和内表顺序有关，所以不能用so行项目代替DN行项目
        lv_item_index = lv_item_index + 10."SO 行项目编码规则为10 20 30
        record_temp-deliverydocumentitem = lv_item_index.
        MODIFY records FROM record_temp.
      ENDLOOP.

*&--MOD BEGIN BY XINLEI XU 2025/03/21 优化
*      SELECT COUNT( * )
*        FROM ztbc_1001
*       WHERE zid = 'ZSD016'
*         AND zvalue1 = @record_key-salesdocumenttype.
      READ TABLE lt_config TRANSPORTING NO FIELDS WITH KEY zvalue1 = record_key-salesdocumenttype BINARY SEARCH.
*&--MOD END BY XINLEI XU 2025/03/21
      "返品DN
      IF sy-subrc = 0.
        lv_api_head = '/API_CUSTOMER_RETURNS_DELIVERY_SRV;v=0002/A_ReturnsDeliveryHeader'.
        lv_api_item = '/API_CUSTOMER_RETURNS_DELIVERY_SRV;v=0002/A_ReturnsDeliveryItem'.
      ELSE.
        lv_api_head = '/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader'.
        lv_api_item = '/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryItem'.
      ENDIF.

      "将数据转换成json格式
      DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
          ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).

      REPLACE ALL OCCURRENCES OF 'ToDeliveryDocumentItem' IN  lv_requestbody WITH 'to_DeliveryDocumentItem'.
      REPLACE ALL OCCURRENCES OF 'Results' IN  lv_requestbody WITH 'results'.

      DATA(lv_path) = |{ lv_api_head }?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

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
          MODIFY records FROM record_temp TRANSPORTING type message deliverydocument
            WHERE salesdocument = ls_document_item-reference_s_d_document
              AND salesdocumentitem = ls_document_item-reference_s_d_document_item.
        ENDLOOP.
        CLEAR record_temp.

        "修改DN抬头
        "有些字段在创建时无法赋值，需要通过修改来实现，

        "判定可以指定的字段是否有输入值，如果没则不需要修改DN
        DATA lv_need_change TYPE abap_bool.
        lv_need_change = abap_false.
*&--MOD BEGIN BY XINLEI XU 2025/04/25
*        IF record_key-currplannedgoodsissuedate IS NOT INITIAL OR record_key-currdeliverydate IS NOT INITIAL.
*          lv_need_change = abap_true.
*        ENDIF.
*        IF lv_need_change = abap_true.
*          CLEAR ls_update_request.
*          IF record_key-currplannedgoodsissuedate IS NOT INITIAL.
*            ls_update_request-header_data-planned_goods_issue_date = format_date_to_odata( record_key-currplannedgoodsissuedate ).
*            ls_update_request-header_data-goods_issue_time = 'PT00H00M00S'.
*          ENDIF.
*          IF record_key-currdeliverydate IS NOT INITIAL.
*            ls_update_request-header_data-delivery_date = format_date_to_odata( record_key-currdeliverydate ).
*            ls_update_request-header_data-delivery_time = 'PT00H00M00S'.
*          ENDIF.
        CLEAR ls_update_request.
        IF record_key-currplannedgoodsissuedate IS NOT INITIAL.
          ls_update_request-header_data-planned_goods_issue_date = format_date_to_odata( record_key-currplannedgoodsissuedate ).
          ls_update_request-header_data-goods_issue_time = 'PT00H00M00S'.
          lv_need_change = abap_true.
        ENDIF.
        IF record_key-currdeliverydate IS NOT INITIAL.
          ls_update_request-header_data-delivery_date = format_date_to_odata( record_key-currdeliverydate ).
          ls_update_request-header_data-delivery_time = 'PT00H00M00S'.
          lv_need_change = abap_true.
        ENDIF.

*        DATA: lv_deliverydocument TYPE i_deliverydocument-deliverydocument.
*        lv_deliverydocument = |{ ls_response-d-delivery_document ALPHA = IN }|.
*        SELECT SINGLE logisticsexecutionscenario
*          FROM i_deliverydocument WITH PRIVILEGED ACCESS
*         WHERE deliverydocument = @lv_deliverydocument
*          INTO @DATA(lv_scenario).
*        IF sy-subrc = 0 AND ( lv_scenario = '2' OR lv_scenario = '4' ).
*          ls_update_request-header_data-bill_of_lading = 'SD015'.  " 目的： 触发增强 YY1_DNEXTENSION
*          lv_need_change = abap_true.
*          CLEAR: lv_deliverydocument,lv_scenario.
*        ENDIF.

        IF lv_need_change = abap_true.
*&--MOD END BY XINLEI XU 2025/04/25
          "将数据转换成json格式
          lv_requestbody = xco_cp_json=>data->from_abap( ls_update_request )->apply( VALUE #(
              ( xco_cp_json=>transformation->underscore_to_pascal_case )
            ) )->to_string( ).
          REPLACE ALL OCCURRENCES OF 'HeaderData' IN lv_requestbody WITH 'd'.
          "如果日期字段没有值，则结构中不能出现，所以替换掉空值
          REPLACE ALL OCCURRENCES OF ',"DeliveryDate":"","DeliveryTime":""' IN lv_requestbody WITH ''.
          REPLACE ALL OCCURRENCES OF '"DeliveryDate":"","DeliveryTime":"",' IN lv_requestbody WITH ''.
          REPLACE ALL OCCURRENCES OF ',"PlannedGoodsIssueDate":"","GoodsIssueTime":""' IN lv_requestbody WITH ''.
          REPLACE ALL OCCURRENCES OF '"PlannedGoodsIssueDate":"","GoodsIssueTime":"",' IN lv_requestbody WITH ''.

          lv_path = |{ lv_api_head }('{ ls_response-d-delivery_document }')?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
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
          "修改DN行项目 目前DN行项目只修改一个库存地点
          LOOP AT records INTO record_temp WHERE deliverydocument = ls_response-d-delivery_document.
            "如果没有输入新的库存地点，或者输入的库存地点和SO的库存地点相同 则不需要修改
            IF record_temp-currstoragelocation IS NOT INITIAL AND record_temp-currstoragelocation <> record_temp-storagelocation.
              DATA(lv_param) = |DeliveryDocument='{ record_temp-deliverydocument }',DeliveryDocumentItem='{ record_temp-deliverydocumentitem }'|.
              lv_path = |{ lv_api_item }({ lv_param })?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
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
*          "过账DN
*          IF is_error = abap_false.
*            "获取ETag
*            lv_path = |/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader('{ ls_response-d-delivery_document }')?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
*            zzcl_common_utils=>get_api_etag(  EXPORTING iv_odata_version = 'V2'
*                                                        iv_path          = lv_path
*                                              IMPORTING ev_status_code   = lv_status_code
*                                                        ev_response      = lv_response
*                                                        ev_etag          = DATA(lv_etag) ).
*            IF lv_status_code <> 200.
*              is_error = abap_true.
*            ELSE.
*              "过账DN
*              lv_path = |/API_OUTBOUND_DELIVERY_SRV;v=0002/PostGoodsIssue?DeliveryDocument='{ ls_response-d-delivery_document }'|.
*              zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
*                                                           iv_method      = if_web_http_client=>post
*                                                           iv_etag        = lv_etag
*                                                 IMPORTING ev_status_code = lv_status_code
*                                                           ev_response    = lv_response ).
*              IF lv_status_code <> 200.
*                is_error = abap_true.
*              ENDIF.
*            ENDIF.
*          ENDIF.
        ELSE.
          is_error = abap_true.
        ENDIF.

      ELSE.
        is_error = abap_true.
      ENDIF.
      IF is_error = abap_true.
*&--MOD BEGIN BY XINLEI XU 2025/03/21 按维度将数据分组，相同维度的数据创建一个DN
*      LOOP AT records INTO record_temp WHERE salesdocument = record_key-salesdocument.
        LOOP AT records INTO record_temp WHERE salesdocumenttype = record_key-salesdocumenttype
                                           AND salesorganization = record_key-salesorganization
                                           AND shippingpoint = record_key-shippingpoint
                                           AND soldtoparty = record_key-soldtoparty
                                           AND billingtoparty = record_key-billingtoparty
                                           AND shiptoparty = record_key-shiptoparty
                                           AND plant = record_key-plant
                                           AND transitplant = record_key-transitplant
                                           AND route = record_key-route
                                           AND shippingtype = record_key-shippingtype
                                           AND incotermsclassification = record_key-incotermsclassification
                                           AND incotermstransferlocation = record_key-incotermstransferlocation.
*&--MOD END BY XINLEI XU 2025/03/21
          record_temp-type = 'E'.
          record_temp-message = zzcl_common_utils=>merge_message( iv_message1 = record_temp-message
                                                                  iv_message2 = zzcl_common_utils=>parse_error_v2( lv_response )
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
    lv_json = /ui2/cl_json=>serialize( records ).
    APPEND VALUE #( %cid    = key-%cid
                    %param  = VALUE #( zzkey = lv_json ) ) TO result.

  ENDMETHOD.

  METHOD format_date_to_odata.
    DATA lv_timestamp TYPE timestamp.
    DATA lv_timestamp_str TYPE string.
    TRY.
        DATA(lv_timezone) = cl_abap_context_info=>get_user_time_zone( ).
        CONVERT DATE iv_date TIME '000000' INTO TIME STAMP lv_timestamp TIME ZONE lv_timezone.
      CATCH cx_abap_context_info_error INTO DATA(sef).
        lv_timestamp = |{ iv_date }000000|.
    ENDTRY.
    lv_timestamp_str = lv_timestamp.
    rv_date = |{ lv_timestamp_str+0(4) }-{ lv_timestamp_str+4(2) }-{ lv_timestamp_str+6(2) }T{ lv_timestamp_str+8(2) }:{ lv_timestamp_str+10(2) }:{ lv_timestamp_str+12(2) }|.
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
