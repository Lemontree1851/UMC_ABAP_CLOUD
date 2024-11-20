CLASS zcl_http_podata_001 DEFINITION

  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    "入参
    TYPES:
      BEGIN OF ty_inputs,
        pono         TYPE c    LENGTH 10,               "購買発注"
        dno          TYPE n    LENGTH 5,                "購買発注明細"
*        seq          TYPE c    LENGTH 4,                "連続番号"
        deliverydate TYPE c    LENGTH 10,               "納品日"
        quantity     TYPE p    DECIMALS 3 LENGTH 13,    "納品数量"
        delflag      TYPE c    LENGTH 1,                "削除フラグ（納期回答）"
        extnumber    TYPE c    LENGTH 35,               "参照
      END OF ty_inputs.

    "传参
    TYPES:
      BEGIN OF ty_output,
        pono         TYPE c    LENGTH 10,
        dno          TYPE c    LENGTH 5,
*        seq          TYPE c    LENGTH 4,
        deliverydate TYPE c    LENGTH 10,
        quantity     TYPE c    LENGTH 13,
        delflag      TYPE c    LENGTH 1,
        extnumber    TYPE c    LENGTH 35,
      END OF ty_output,

      BEGIN OF ty_response,
        purchaseorderid           TYPE c LENGTH 10,     "PO_NO
        purchaseorderitemid       TYPE c LENGTH 5,      "D_NO
        sequentialnmbrofsuplrconf TYPE c LENGTH 4,      "SEQ
        purchaseorderitemcategory TYPE c LENGTH 2,      "CH
        requesteddeliverydate     TYPE c LENGTH 10,
        requestedquantity         TYPE c LENGTH 13,
      END OF ty_response,

      BEGIN OF ty_output1,
        items TYPE STANDARD TABLE OF ty_output WITH EMPTY KEY,
      END OF ty_output1,

      ty_output_table TYPE STANDARD TABLE OF ty_output WITH EMPTY KEY.


*    TYPES: tt_items TYPE STANDARD TABLE OF ty_inputs WITH EMPTY KEY.
*
*    TYPES:
*      BEGIN OF ty_items,
*        items  TYPE tt_items,
*      END OF ty_items.
*
*    TYPES: lt_items TYPE STANDARD TABLE OF ty_items WITH EMPTY KEY.
*
*    DATA: lt_req TYPE STANDARD TABLE OF lt_items.


    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      lt_req            TYPE STANDARD TABLE OF ty_inputs,
      ls_req1           TYPE ty_inputs,
      lt_req1           TYPE STANDARD TABLE OF ty_inputs,
      ls_output         TYPE ty_output,
      lv_error(1)       TYPE c,
      lv_text           TYPE string,
      es_outputs        TYPE ty_output1,
      lc_header_content TYPE string VALUE 'content-type',
      lc_content_type   TYPE string VALUE 'text/json'.

    DATA:
      lt_sum        TYPE STANDARD TABLE OF ty_inputs,
      ls_sum        TYPE ty_inputs,
      lv_start_time TYPE sy-uzeit,
      lv_start_date TYPE sy-datum,
      lv_end_time   TYPE sy-uzeit,
      lv_end_date   TYPE sy-datum,
      lv_temp(14)   TYPE c,
      lv_starttime  TYPE p LENGTH 16 DECIMALS 0,
      lv_endtime    TYPE p LENGTH 16 DECIMALS 0,
      lv_sum_qty    TYPE p LENGTH 13 DECIMALS 0. " 新增变量用于存储数量总和

    DATA:
*          ls_request  TYPE ty_request,
      lv_request  TYPE string,
      ls_response TYPE ty_response,
      lt_value    TYPE STANDARD TABLE OF if_web_http_request=>name_value_pairs,
      ls_value    TYPE if_web_http_request=>name_value_pairs.

    DATA:
      base_url      TYPE string,
      lv_token_json TYPE string,
      lv_token      TYPE string,
      lv_status     TYPE i.

ENDCLASS.



CLASS zcl_http_podata_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(lv_req_body) = request->get_text( ).

    DATA(lv_header) = request->get_header_field( i_name = 'form' ).

    IF lv_header = 'XML'.

    ELSE.
      "first deserialize the request
      xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
          ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->write_to( REF #( lt_req ) ).

    ENDIF.

    IF lt_req IS NOT INITIAL.

      LOOP AT lt_req INTO DATA(lw_req).
        IF lw_req-delflag = 'Y'.
          APPEND ls_output TO es_outputs-items.
          lv_text = 'UWEBで購買伝票' && lw_req-pono && '明細' && lw_req-dno && 'は削除フラグを付けました.UMC購買担当者と連絡してください.'.
          lv_error = 'X'.
          CONTINUE.
        ENDIF.
      ENDLOOP.

      SELECT purchaseorder, purchaseorderitem, purchasingdocumentdeletioncode, orderquantity
        FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_req
        WHERE purchaseorder = @lt_req-pono
          AND purchaseorderitem = @lt_req-dno
        INTO TABLE @DATA(lt_deletecode).

      SELECT purchaseorder, purchaseorderitem,purchaseorderquantityunit
        FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_req
        WHERE purchaseorder = @lt_req-pono
          AND purchaseorderitem = @lt_req-dno
        INTO TABLE @DATA(lt_unit).

      SELECT unitofmeasure, unitofmeasureisocode
         FROM i_unitofmeasure WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_unit
         WHERE unitofmeasure = @lt_unit-purchaseorderquantityunit
         INTO TABLE @DATA(lt_unit1).

    ENDIF.

    " 检查删除标志
    LOOP AT lt_deletecode INTO DATA(ls_deletecode).
      IF ls_deletecode-purchasingdocumentdeletioncode = 'L'.
        lv_text = 'S4HCで購買伝票' && ls_deletecode-purchaseorder && '明細' && ls_deletecode-purchaseorderitem && 'は削除フラグを付けました.UMC購買担当者と連絡してください.'.
        lv_error = 'X'.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    " 如果没有删除标志的错误，进行数量总和比较
    IF lv_error IS INITIAL.

      CLEAR: lv_sum_qty.
      SORT lt_req BY pono dno deliverydate.

      LOOP AT lt_req INTO DATA(ls_req).

        " 按照纳品日进行筛选累加
        DATA(lv_current_date) = ls_req-deliverydate.
        CLEAR: lv_sum_qty.

        LOOP AT lt_req INTO DATA(ls_req_inner) WHERE pono = ls_req-pono
                                                  AND dno = ls_req-dno
                                                  AND delflag <> 'X'.
          lv_sum_qty = lv_sum_qty + ls_req_inner-quantity.
        ENDLOOP.

        " 比较每日的纳品数量与发注数
        READ TABLE lt_deletecode WITH KEY purchaseorder     = ls_req-pono
                                          purchaseorderitem = ls_req-dno INTO DATA(ls_deletecode_item).

        IF lv_sum_qty <= ls_deletecode_item-orderquantity.

          ls_output-pono                    = ls_req-pono.
          ls_output-dno                     = ls_req-dno.
*          ls_output-seq                     = ls_req-seq.
          ls_output-deliverydate            = ls_req-deliverydate.
          ls_output-quantity                = ls_req-quantity.
          ls_output-delflag                 = ls_req-delflag.
          ls_output-extnumber               = ls_req-extnumber.

          CONDENSE ls_output-pono.
          CONDENSE ls_output-dno.
*          CONDENSE ls_output-seq.
          CONDENSE ls_output-deliverydate.
          CONDENSE ls_output-deliverydate.
          CONDENSE ls_output-delflag.
          CONDENSE ls_output-extnumber.

          APPEND ls_output TO es_outputs-items.

          TRY.
              DATA(lv_uuid) = cl_system_uuid=>create_uuid_c32_static( ).
            CATCH cx_uuid_error INTO DATA(lx_uuid_error).
              " 处理 UUID 错误
              lv_error = 'X'.
              lv_text = 'UUID 创建失败: ' && lx_uuid_error->get_text( ).
              " 处理错误或记录日志
          ENDTRY.

          " 格式化 UUID 添加分隔符
          DATA lv_formatted_uuid TYPE string.
          lv_formatted_uuid = |{ lv_uuid+0(8) }-{ lv_uuid+8(4) }-{ lv_uuid+12(4) }-{ lv_uuid+16(4) }-{ lv_uuid+20(12) }|.

          " 将 UUID 添加到 base_url 末尾
*          base_url = |https://my412552-api.s4hana.cloud.sap/sap/bc/srt/scs_ext/sap/orderconfirmationrequest_in?MessageId={ lv_formatted_uuid }|.

          TRY.
              DATA(lv_base_url) = 'https://' && cl_abap_context_info=>get_system_url( ) && '/sap/bc/srt/scs_ext/sap/orderconfirmationrequest_in?MessageId=' && lv_formatted_uuid.
              DATA(lo_destination) = cl_http_destination_provider=>create_by_url( i_url = lv_base_url ).
            CATCH cx_abap_context_info_error INTO DATA(lx_context_error).
              " 处理上下文信息错误
              lv_error = 'X'.
              lv_text = '获取系统 URL 失败: ' && lx_context_error->get_text( ).
            CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
              " 处理 HTTP 目的地提供者错误
              lv_error = 'X'.
              lv_text = 'HTTP 目的地创建失败: ' && lx_http_dest_provider_error->get_text( ).
          ENDTRY.

          TRY.
              DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

              DATA: lv_username TYPE string, " 存储用户名
                    lv_password TYPE string. " 存储密码

              " 从表 ZC_TBC1001 中读取用户名和密码
              SELECT SINGLE zvalue2,zvalue3
                FROM zc_tbc1001
                WHERE zid = 'ZBC001'
                  AND zvalue1 = 'UWEB'
               INTO (@lv_username,@lv_password).

              IF sy-subrc <> 0.
                " 处理密码读取失败的情况
                lv_error = 'X'.
                lv_text = '无法从 ZC_TBC1001 表中读取用户名或密码'.
                RETURN.
              ENDIF.

              " 使用读取的用户名和密码进行 HTTP 请求的授权
              lo_http_client->get_http_request( )->set_authorization_basic(
                i_username = lv_username
                i_password = lv_password ).


              "DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
            CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
              lv_error = 'X'.
              lv_text = 'HTTP 请求失败: ' && lx_web_http_client_error->get_text( ).
              " 处理错误或记录日志
              RETURN.
          ENDTRY.

          DATA(lo_http_request) = lo_http_client->get_http_request( ).

          DATA(lv_date) = sy-datum.  " 获取当前日期
          DATA(lv_time) = sy-uzeit.  " 获取当前时间

          DATA(lv_timestamp) = |{ lv_date+0(4) }-{ lv_date+4(2) }-{ lv_date+6(2) }T{ lv_time+0(2) }:{ lv_time+2(2) }:{ lv_time+4(2) }Z|.

          DATA:
            lv_hour                    TYPE i,
            lv_minute                  TYPE i,
            lv_second                  TYPE i,
            lv_adjusted_hour           TYPE i,
            lv_adjusted_hour_str       TYPE string,
            lv_minute_str              TYPE string,
            lv_second_str              TYPE string,
*            lv_timestamp               TYPE string,
            lv_confirmed_delivery_time TYPE string.

          " 从时间中提取小时、分钟、秒
          lv_hour = lv_time+0(2).
          lv_minute = lv_time+2(2).
          lv_second = lv_time+4(2).

          " 调整小时
          lv_adjusted_hour = lv_hour + 8.
          IF lv_adjusted_hour >= 24.
            lv_adjusted_hour = lv_adjusted_hour - 24.
          ENDIF.

          " 将小时、分钟、秒转换为两位数格式
          IF lv_adjusted_hour < 10.
            lv_adjusted_hour_str = |0{ lv_adjusted_hour }|.
          ELSE.
            lv_adjusted_hour_str = |{ lv_adjusted_hour }|.
          ENDIF.

          IF lv_minute < 10.
            lv_minute_str = |0{ lv_minute }|.
          ELSE.
            lv_minute_str = |{ lv_minute }|.
          ENDIF.

          IF lv_second < 10.
            lv_second_str = |0{ lv_second }|.
          ELSE.
            lv_second_str = |{ lv_second }|.
          ENDIF.

          " 生成确认交货时间
          lv_confirmed_delivery_time = |{ lv_adjusted_hour_str }:{ lv_minute_str }:{ lv_second_str }|.
          CONDENSE ls_output-quantity NO-GAPS.
          DATA: lv_utc_timestamp TYPE timestamp.
          DATA: lv_timestamp_string TYPE string.
          DATA: lv_final_time_string TYPE string.

          GET TIME STAMP FIELD lv_utc_timestamp.

          " 将时间戳转换为字符串
          lv_timestamp_string = lv_utc_timestamp.

          " 拼接成目标格式 YYYY-MM-DDThh:mm:ssZ
          lv_final_time_string = |{ lv_timestamp_string(4) }-{ lv_timestamp_string+4(2) }-{ lv_timestamp_string+6(2) }T{ lv_timestamp_string+8(2) }:{ lv_timestamp_string+10(2) }:{ lv_timestamp_string+12(2) }Z|.


          DATA:
            lv_previous_pono   TYPE c LENGTH 10,  " 记录上一个pono
            lv_previous_dno    TYPE n LENGTH 5,   " 记录上一个dno
            lv_current_request TYPE string.        " 当前SOAP请求，逐条拼接
*            lv_request         TYPE string.        " 最终的完整请求

          CLEAR lv_request.  " 初始化请求字符串
          CLEAR lv_previous_pono.
          CLEAR lv_previous_dno.

          LOOP AT lt_req INTO ls_req.

            " 每次碰到新的pono和dno时，开始生成新的SOAP请求
            IF lv_previous_pono <> ls_req-pono OR lv_previous_dno <> ls_req-dno.

              " 如果不是第一次，并且上一条请求不为空，结束上一条请求并发送
              IF lv_previous_pono IS NOT INITIAL.
                " 结束上一条请求并将其传递出去
                lv_current_request = lv_current_request &&
                                     '</Item>' &&
                                     '</OrderConfirmation>' &&
                                     '</edi:OrderConfRequest>' &&
                                     '</soap:Body>' &&
                                     '</soap:Envelope>'.

                " 发送当前的请求
                lo_http_request->set_text( lv_current_request ).

                CLEAR lv_current_request.  " 清空当前请求
              ENDIF.

              " 开始新的 OrderConfRequest
              lv_current_request = |<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:edi="http://sap.com/xi/EDI">| &&
                                   |<soap:Header/>| &&
                                   |<soap:Body>| &&
                                   |<edi:OrderConfRequest>| &&
                                   |<MessageHeader>| &&
                                   |<ID>{ lv_uuid }</ID>| &&
                                   |<CreationDateTime>{ lv_final_time_string }</CreationDateTime>| &&
                                   |</MessageHeader>| &&
                                   |<OrderConfirmation>| &&
                                   |<PurchaseOrderID>{ ls_req-pono }</PurchaseOrderID>| &&
                                   |<Item>| &&
                                   |<PurchaseOrderItemID>{ ls_req-dno }</PurchaseOrderItemID>|.

              " 更新上一个pono和dno
              lv_previous_pono = ls_req-pono.
              lv_previous_dno = ls_req-dno.
            ENDIF.

            " 假设获取到的单位信息包含在 lt_unit 中，取第一个单位信息
            LOOP AT lt_unit INTO DATA(ls_unit).

              DATA:lv_converted_unit TYPE string.
              CLEAR lv_converted_unit.

              READ TABLE lt_unit1 WITH KEY unitofmeasure  = ls_unit-purchaseorderquantityunit INTO DATA(ls_unit1).

              IF sy-subrc = 0.
                lv_converted_unit = ls_unit1-unitofmeasureisocode.
              ELSE.
                " 如果未找到匹配，使用默认值或处理错误
                lv_converted_unit = ls_unit-purchaseorderquantityunit.
              ENDIF.


              " 正确拼接 <ScheduleLine> 标签
              lv_current_request = lv_current_request &&
                                   |<ScheduleLine>| &&
*                                   |<PurchaseOrderScheduleLine>{ ls_req-seq }</PurchaseOrderScheduleLine>| &&
                                   |<ConfirmedDeliveryDate>{ ls_req-deliverydate }</ConfirmedDeliveryDate>| &&
                                   |<ConfirmedDeliveryTime>{ lv_confirmed_delivery_time }</ConfirmedDeliveryTime>| &&
                                   |<ConfirmedOrderQuantityByMaterialAvailableCheck unitCode="{ lv_converted_unit }">{ ls_req-quantity }</ConfirmedOrderQuantityByMaterialAvailableCheck>| &&
                                   |</ScheduleLine>|.

            ENDLOOP.

          ENDLOOP.

          " 结束最后一条请求并发送
          IF lv_previous_pono IS NOT INITIAL.
            lv_current_request = lv_current_request &&
                                 '</Item>' &&
                                 '</OrderConfirmation>' &&
                                 '</edi:OrderConfRequest>' &&
                                 '</soap:Body>' &&
                                 '</soap:Envelope>'.

            " 发送最后一个请求
            lo_http_request->set_text( lv_current_request ).
          ENDIF.

          " 设置请求头
          lo_http_request->set_header_field( i_name = 'Content-Type' i_value = 'text/xml' ).

          TRY.
              DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
            CATCH cx_web_http_client_error INTO DATA(lx_http_error).
              " 在这里处理异常，例如记录错误日志或返回自定义错误消息
              lv_text = 'HTTP リクエストに失敗しました。接続や設定を確認してください'.
              lv_error = 'X'.
          ENDTRY.

          lo_response->get_status( RECEIVING r_value = DATA(ls_http_status) ).
          IF ls_http_status-code = 202
          OR ls_http_status-code = 201.
            DATA(lv_string) = lo_response->get_text( ).

            /ui2/cl_json=>deserialize(
                            EXPORTING json = lv_string
                                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                            CHANGING data = ls_response ).

            " 成功消息
            lv_text = '納期回答情報は購買伝票に反映されました.'.
            lv_error = ''.
          ELSE.
            lv_text = '納期回答情報が購買伝票に反映されませんでした.再度ご確認ください.'.
            lv_error = 'X'.
            EXIT.
          ENDIF.
        ELSE.
          lv_text = '納期回答合計数量は購買発注の発注数を超過します. データをチェックしてください.'.
          lv_error = 'X'.
          EXIT.
        ENDIF.

      ENDLOOP.

    ENDIF.

*将错误消息通过标准方法改成前台能读取到的内容
    IF lv_text IS NOT INITIAL.

      IF lv_error IS NOT INITIAL.
        response->set_status( '202' ).
        " 创建一个 JSON 结构以包含成功消息和数据
        DATA(lv_text_json_error) = lv_text.

        DATA(lv_json_string_error) = xco_cp_json=>data->from_abap( es_outputs )->apply( VALUE #(
            ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).
*
        " 将 lv_text 直接作为消息字段，并组合 JSON 内容
*        DATA(lv_response_json_error) = '{ "message": "' && '"status":"202"' && lv_text_json_error && '", "Items": ' && lv_json_string_error && ' }'.
        DATA(lv_response_json_error) = '{ "message": "' && lv_text_json_error && '", "status": "202", "Items": ' && lv_json_string_error && ' }'.
        response->set_text( lv_response_json_error ).
        response->set_header_field( i_name  = lc_header_content
                                    i_value = lc_content_type ).

      ELSE.
        response->set_status( '200' ).
        " 创建一个 JSON 结构以包含成功消息和数据
        DATA(lv_text_json_succ) = lv_text.

        DATA(lv_json_string_succ) = xco_cp_json=>data->from_abap( es_outputs )->apply( VALUE #(
            ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).

        " 将 lv_text 直接作为消息字段，并组合 JSON 内容
*        DATA(lv_response_json_succ) = '{ "message": "' && '"status":"200"' && lv_text_json_succ && '", "Items": ' && lv_json_string_succ && ' }'.
        DATA(lv_response_json_succ) = '{ "message": "' && lv_text_json_succ && '", "status": "200", "Items": ' && lv_json_string_succ && ' }'.

        response->set_text( lv_response_json_succ ).
        response->set_header_field( i_name  = lc_header_content
                                    i_value = lc_content_type ).

      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
