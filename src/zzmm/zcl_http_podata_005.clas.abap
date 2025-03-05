CLASS zcl_http_podata_005 DEFINITION

  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    "入参
    TYPES:
      BEGIN OF ty_inputs,
        pono         TYPE c    LENGTH 10,               "購買発注"
        dno          TYPE n    LENGTH 5,                "購買発注明細"
        seq          TYPE c    LENGTH 4,                "連続番号"
        deliverydate TYPE c LENGTH 10    ,               "納品日"
        quantity     TYPE ztmm_1009-quantity,               "納品数量"
        delflag      TYPE c    LENGTH 1,                "削除フラグ（納期回答）"
        extnumber    TYPE c    LENGTH 35,               "参照
        ztype        TYPE c    LENGTH 1,                "N:创建Confirmation I:Insert Line U:Update D:Delete
      END OF ty_inputs.

    "传参
    TYPES:
      BEGIN OF ty_output,
        pono         TYPE c    LENGTH 10,
        dno          TYPE c    LENGTH 5,
        seq          TYPE c    LENGTH 4,
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
      ls_insert_req     TYPE ty_inputs,
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
      lv_request  TYPE string,
      ls_response TYPE ty_response,
      lt_value    TYPE STANDARD TABLE OF if_web_http_request=>name_value_pairs,
      ls_value    TYPE if_web_http_request=>name_value_pairs.

    DATA: lt_ztmm_1009 TYPE STANDARD TABLE OF ztmm_1009,
          lw_ztmm_1009 LIKE LINE OF lt_ztmm_1009.   " 数据库表的内表

    DATA:
      base_url      TYPE string,
      lv_token_json TYPE string,
      lv_token      TYPE string,
      lv_status     TYPE i.


    "ADD BY STANLEY 20250121


ENDCLASS.



CLASS ZCL_HTTP_PODATA_005 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
  "Define New supplier Confirmation stru

  "define Change Supplier Confirmation
    TYPES:BEGIN OF ty_update_stru,
          DeliveryDate  type  string,
          DeliveryTime  type  string,
          ConfirmedQuantity type i_purchaseorderitemapi01-orderquantity,
          PurchaseOrderQuantityUnit type string,
          SupplierConfirmationExtNumber type string,
   END OF ty_update_stru.
   DATA:lt_update_stru TYPE STANDARD TABLE OF ty_update_stru,
        ls_update_stru TYPE ty_update_stru.

  "define New Supplier Confirmation
    TYPES: BEGIN OF ty_head,
             delivery_date TYPE string,
             confirmed_quantity TYPE string,
             purchase_order_quantity_unit TYPE string,
             ext_number TYPE string,
           END OF ty_head,

           BEGIN OF ty_item_tp,
             po_item TYPE string,
             ext_ref TYPE string,
             line_tp TYPE STANDARD TABLE OF ty_head WITH NON-UNIQUE DEFAULT KEY,
           END OF ty_item_tp,

           BEGIN OF ty_json_data,
             suplr_conf_ref_purchase_order TYPE string,
             supplier_confirmation_item_tp TYPE STANDARD TABLE OF ty_item_tp WITH NON-UNIQUE DEFAULT KEY,
           END OF ty_json_data.

    DATA(lv_req_body) = request->get_text( ).
    DATA(lv_header) = request->get_header_field( i_name = 'form' ).

    "first deserialize the request`
    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->write_to( REF #( lt_req ) ).


    IF lt_req IS NOT INITIAL.
      "Check Delete Flag
      LOOP AT lt_req INTO DATA(lw_req).
        IF lw_req-delflag = 'Y'.
          APPEND ls_output TO es_outputs-items.
          lv_text = 'UWEBで購買伝票' && lw_req-pono && '明細' && lw_req-dno && 'は削除フラグを付けました.UMC購買担当者と連絡してください.'.
          lv_error = 'X'.
          CONTINUE.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_req ASSIGNING FIELD-SYMBOL(<fs_req>).
        <fs_req>-pono = |{ <fs_req>-pono ALPHA = IN }|.
      ENDLOOP.

      SELECT purchaseorder, purchaseorderitem, purchasingdocumentdeletioncode, orderquantity
        FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_req
        WHERE purchaseorder = @lt_req-pono
          AND purchaseorderitem = @lt_req-dno
        INTO TABLE @DATA(lt_deletecode).

      SELECT purchaseorder, purchaseorderitem,purchaseorderquantityunit,NetAmount,DocumentCurrency
        FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_req
        WHERE purchaseorder = @lt_req-pono
          AND purchaseorderitem = @lt_req-dno
        INTO TABLE @DATA(lt_unit).

      IF lt_unit IS NOT INITIAL.
        SELECT unitofmeasure, unitofmeasureisocode
           FROM i_unitofmeasure WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_unit
           WHERE unitofmeasure = @lt_unit-purchaseorderquantityunit
           INTO TABLE @DATA(lt_unit1).

      ENDIF.
       "查找是否confirmation，并决定用什么
          SELECT purchaseorder,
                 purchaseorderitem,
                 sequentialnmbrofsuplrconf,
                 deliverydate,
                 mrprelevantquantity,
                 supplierconfirmation,
                 supplierconfirmationitem
            FROM I_POSupplierConfirmationAPI01 WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_req
           WHERE purchaseorder = @lt_req-pono
            INTO TABLE @data(lt_already_confirm).
       LOOP AT lt_req INTO lw_req.
         READ TABLE lt_already_confirm INTO DATA(ls_confirm_chk) WITH KEY purchaseorder = lw_req-pono
                                                                          purchaseorderitem = lw_req-dno.
         IF sy-subrc EQ 0.
            "需要判断数量，多的需要Insert
            READ TABLE lt_already_confirm INTO DATA(ls_confrim_line_chk) WITH KEY purchaseorder = lw_req-pono
                                                                                  purchaseorderitem = lw_req-dno
                                                                                  sequentialnmbrofsuplrconf = lw_req-seq.
            IF SY-SUBRC EQ 0.
                lw_req-ztype = 'U'.
            ELSE.
                lw_req-ztype = 'I'.
            ENDIF.
         ELSE.
            lw_req-ztype = 'N'.
         ENDIF.

         MODIFY lt_req FROM lw_req TRANSPORTING ztype.
       ENDLOOP.

       "查找需要删除的
       LOOP AT lt_already_confirm INTO DATA(ls_confirm_del).
         READ TABLE lt_req INTO lw_req WITH KEY pono = ls_confirm_del-PurchaseOrder
                                                dno = ls_confirm_del-PurchaseOrderItem
                                                seq = ls_confirm_del-SequentialNmbrOfSuplrConf.
         IF SY-SUBRC NE 0.
            lw_req-pono = ls_confirm_del-PurchaseOrder.
            lw_req-dno = ls_confirm_del-PurchaseOrderItem.
            lw_req-seq = ls_confirm_del-SequentialNmbrOfSuplrConf.
            lw_req-ztype = 'D'.
            APPEND lw_req TO lt_req.
         ENDIF.
       ENDLOOP.

    ENDIF.

    " 检查PO删除标志
    LOOP AT lt_deletecode INTO DATA(ls_deletecode).
      IF ls_deletecode-purchasingdocumentdeletioncode = 'L'.
        lv_text = 'S4HCで購買伝票' && ls_deletecode-purchaseorder && '明細' && ls_deletecode-purchaseorderitem && 'は削除フラグを付けました.UMC購買担当者と連絡してください.'.
        lv_error = 'X'.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    DATA:
      lv_length TYPE i VALUE 0,
      lv_index  TYPE i.

    DATA: lv_newdn type c,
          lv_dno   TYPE n    LENGTH 5.

    " 如果没有删除标志的错误，进行数量总和比较
    IF lv_error IS INITIAL.

      CLEAR: lv_sum_qty.
      SORT lt_req BY pono dno deliverydate.

      DATA(lt_req1) = lt_req.
      SORT lt_req1 BY pono.
      DELETE ADJACENT DUPLICATES FROM lt_req1 COMPARING pono.
      "首先删除需要删除的confirmation Line
      LOOP AT lt_req INTO DATA(ls_del) WHERE ztype = 'D'.
           READ TABLE lt_already_confirm INTO DATA(ls_del_line) WITH KEY PurchaseOrder = ls_del-pono
                                                                             PurchaseOrderItem = ls_del-dno.
           DATA(lv_d_path) = |/api_supplierconfirmation/srvd_a2x/sap/supplierconfirmation/0001/ConfirmationLine| &&
                             |/{ ls_del_line-supplierconfirmation }/{ ls_del_line-supplierconfirmationitem }/{ lw_req-seq }|.
           zzcl_common_utils=>request_api_v4( EXPORTING iv_path        = lv_d_path
                                                               iv_method      = if_web_http_client=>delete
                                                     IMPORTING ev_status_code = DATA(lv_status_code)
                                                               ev_response    = DATA(lv_response) ).
      ENDLOOP.

      LOOP AT lt_req1 INTO DATA(lw_req1).
        CLEAR:lv_newdn,lv_dno.
        lv_index = 0.

          "ADD BY STANLEY 20250120
          SORT lt_already_confirm BY purchaseorder purchaseorderitem sequentialnmbrofsuplrconf.
          LOOP AT lt_already_confirm INTO DATA(ls_already_confirm).
            if ls_already_confirm-MRPRelevantQuantity > 0.
                CLEAR:ls_insert_req.
                ls_insert_req-pono = ls_already_confirm-purchaseorder.
                ls_insert_req-dno = ls_already_confirm-purchaseorderitem.
                ls_insert_req-seq = ls_already_confirm-sequentialnmbrofsuplrconf.
                ls_insert_req-deliverydate = ls_already_confirm-deliverydate+0(4) && '-' &&
                ls_already_confirm-deliverydate+4(2) && '-' && ls_already_confirm-deliverydate+6(2).
                ls_insert_req-delflag = 'A'."Already Confirmed
                ls_insert_req-quantity = ls_already_confirm-mrprelevantquantity.
                APPEND ls_insert_req TO lt_req.
             endif.
          ENDLOOP.

          SORT lt_req BY pono dno seq deliverydate.
         "END ADD

        LOOP AT lt_req INTO DATA(ls_req) WHERE pono = lw_req1-pono  .

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
                READ TABLE lt_already_confirm INTO DATA(ls_confrim_line) WITH KEY PurchaseOrder = ls_req-pono
                                                                                  PurchaseOrderItem = ls_req-dno.
            if ls_req-ztype = 'I' OR ls_req-ztype = 'U'.
                CLEAR:ls_update_stru,lt_update_stru.
                ls_update_stru = VALUE #(
                        DeliveryDate =  ls_req-deliverydate
                        DeliveryTime = '05:00:00'
                        ConfirmedQuantity = ls_req-quantity
                        PurchaseOrderQuantityUnit = 'PCS'
                        SupplierConfirmationExtNumber = ls_req-extnumber

                        ).
                DATA: lt_name_mappings TYPE /ui2/cl_json=>name_mappings,
                      ls_name_mapping LIKE LINE OF lt_name_mappings.

                ls_name_mapping-abap = 'supplierconfirmationextnumber'.
                ls_name_mapping-json = 'SupplierConfirmationExtNumber'.
                INSERT ls_name_mapping INTO TABLE lt_name_mappings.

                ls_name_mapping-abap = 'deliverydate'.
                ls_name_mapping-json = 'DeliveryDate'.
                INSERT ls_name_mapping INTO TABLE lt_name_mappings.
                ls_name_mapping-abap = 'deliverytime'.
                ls_name_mapping-json = 'DeliveryTime'.
                INSERT ls_name_mapping INTO TABLE lt_name_mappings.
                ls_name_mapping-abap = 'confirmedquantity'.
                ls_name_mapping-json = 'ConfirmedQuantity'.
                INSERT ls_name_mapping INTO TABLE lt_name_mappings.
                ls_name_mapping-abap = 'purchaseorderquantityunit'.
                ls_name_mapping-json = 'PurchaseOrderQuantityUnit'.
                INSERT ls_name_mapping INTO TABLE lt_name_mappings.
                DATA: lv_json_string TYPE string.

                CALL METHOD /ui2/cl_json=>serialize
                  EXPORTING
                    data          = ls_update_stru
                    name_mappings = lt_name_mappings
                  RECEIVING
                    r_json        = lv_json_string.

            elseif ls_req-ztype = 'N'.

            endif.



            CASE ls_req-ztype.
                WHEN 'N'.
                    DATA(lv_n_path) = '/api_supplierconfirmation/srvd_a2x/sap/supplierconfirmation/0001/Confirmation'.
                WHEN 'I'.
                    DATA(lv_i_path) = |/api_supplierconfirmation/srvd_a2x/sap/supplierconfirmation/0001/ConfirmationItem| &&
                                      |/{ ls_confrim_line-supplierconfirmation }/{ ls_confrim_line-supplierconfirmationitem }/_SupplierConfirmationLineTP'|.



                   zzcl_common_utils=>request_api_v4( EXPORTING iv_path        = lv_i_path
                                                                       iv_method      = if_web_http_client=>post
                                                                       iv_body        = lv_json_string
                                                             IMPORTING ev_status_code = lv_status_code
                                                                       ev_response    = lv_response ).
                WHEN 'U'.
                    DATA(lv_u_path) = |/api_supplierconfirmation/srvd_a2x/sap/supplierconfirmation/0001/ConfirmationLine| &&
                                      |/{ ls_confrim_line-supplierconfirmation }/{ ls_confrim_line-supplierconfirmationitem }/{ lw_req-seq }|.
                   zzcl_common_utils=>request_api_v4( EXPORTING iv_path        = lv_u_path
                                                                       iv_method      = if_web_http_client=>patch
                                                                       iv_body        = lv_json_string
                                                             IMPORTING ev_status_code = lv_status_code
                                                                       ev_response    = lv_response ).
                WHEN 'D'.
                    CONTINUE.
            ENDCASE.



          ENDIF.

         ENDLOOP.
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

        " 清空数据库表数据
        LOOP AT lt_req INTO DATA(ls_delete).
          DELETE FROM ztmm_1009 WHERE pono = @ls_delete-pono AND dno = @ls_delete-dno.
        ENDLOOP.

*        IF sy-subrc = 0.

        " 将接口数据逐行处理并构造数据库表的内表
        LOOP AT lt_req INTO DATA(ls_insert).

*          CONDENSE ls_insert-quantity.
*          shift ls_insert-quantity  LEFT DELETING LEADING '0'.

          REPLACE ALL OCCURRENCES OF '-' IN ls_insert-deliverydate WITH ''.

*          ls_insert-quantity = |{ ls_insert-quantity ALPHA = IN }| .

          lw_ztmm_1009-pono                = ls_insert-pono         .
          lw_ztmm_1009-dno                 = ls_insert-dno          .
          lw_ztmm_1009-seq                 = ls_insert-seq          .
          lw_ztmm_1009-deliverydate        = ls_insert-deliverydate .
          lw_ztmm_1009-quantity            = ls_insert-quantity     .
          lw_ztmm_1009-extnumber           = ls_insert-extnumber    .

          INSERT  ztmm_1009 FROM @lw_ztmm_1009 .

          IF sy-subrc = 0 .
            COMMIT WORK.
          ENDIF.

        ENDLOOP.

        " 将内表数据插入数据库表
        IF lt_ztmm_1009 IS NOT INITIAL.
          TRY.
              INSERT ztmm_1009 FROM TABLE @lt_ztmm_1009.
              COMMIT WORK.
            CATCH cx_sy_open_sql_db INTO DATA(lx_sql_error).
              IF sy-subrc = 0.
              ENDIF.
          ENDTRY.
        ENDIF.

*        ENDIF.

      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
