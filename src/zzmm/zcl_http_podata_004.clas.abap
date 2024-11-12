CLASS zcl_http_podata_004 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    "入参
    TYPES:
      BEGIN OF ty_inputs,
*        DocumentDate                TYPE c LENGTH 8,    "請求書日付"
        documentdate TYPE d,    "請求書日付"
      END OF ty_inputs.

    TYPES:
      BEGIN OF ty_response,
        supplierinvoice             TYPE c LENGTH 10,   "請求書伝票番号"
        fiscalyear                  TYPE c LENGTH 4,    "会計年度"
        invoicingparty              TYPE c LENGTH 10,   "請求元"
        documentdate                TYPE d,          "請求書日付"
        postingdate                 TYPE c LENGTH 8,    "転記日付"
        exchangerate                TYPE c LENGTH 9,    "換算レート"
        duecalculationbasedate      TYPE c LENGTH 8,    "基準日"
        invoicegrossamount          TYPE c LENGTH 13,   "請求書総額"
        createdbyuser               TYPE c LENGTH 12,   "登録者"
        lastchangedbyuser           TYPE c LENGTH 12,   "更新者"
        supplierinvoicetaxcounter   TYPE c LENGTH 6,    "請求書明細
        taxcode                     TYPE c LENGTH 2,    "税コード
        taxamount                   TYPE c LENGTH 13,   "消費税額
        totalamount                 TYPE c LENGTH 13,
        unitprice                   TYPE c LENGTH 13,
        supplierinvoiceitem         TYPE c LENGTH 6,    "請求書明細"
        purchaseorder               TYPE c LENGTH 10,   "購買伝票"
        purchaseorderitem           TYPE c LENGTH 5,    "明細"
        debitcreditcode             TYPE c LENGTH 1,    "借方/貸方フラグ"
        purchaseorderitemmaterial   TYPE c LENGTH 40,   "品目"
        documentcurrency            TYPE c LENGTH 5,    "通貨"
        supplierinvoiceitemamount   TYPE c LENGTH 13,   "金額"
        quantityinpurchaseorderunit TYPE c LENGTH 13,   "数量"
        purchaseorderquantityunit   TYPE c LENGTH 3,    "発注単位"
        costcenter                  TYPE c LENGTH 10,   "原価センタ"
        glaccount                   TYPE c LENGTH 10,   "G/L 勘定"
        purchaseorderitemtext       TYPE c LENGTH 40,   "品目購買テキスト
        requisitionername           TYPE c LENGTH 12,   "購買依頼者
        requirementtracking         TYPE c LENGTH 10,   "購買依頼追跡番号
        plant                       TYPE c LENGTH 4,    "プラント
        purchasinggroup             TYPE c LENGTH 3,    "購買グループ
        companycode                 TYPE c LENGTH 4,    "会社コード
        purchasinggroupname         TYPE c LENGTH 18,   "購買グループ名
        accountingdocument          TYPE c LENGTH 10,   "仕訳
      END OF ty_response,

      BEGIN OF ty_output,
        items TYPE STANDARD TABLE OF ty_response WITH EMPTY KEY,
      END OF ty_output.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
    lt_req TYPE STANDARD TABLE OF ty_inputs.

    DATA:
      lv_tablename(10)  TYPE c,
      lv_error(1)       TYPE c,
      lv_text           TYPE string,
      ls_response       TYPE ty_response,
      es_response       TYPE ty_output,
      lc_header_content TYPE string VALUE 'content-type',
      lc_content_type   TYPE string VALUE 'text/json'.

    DATA:
      lv_start_time TYPE sy-uzeit,
      lv_start_date TYPE sy-datum,
      lv_end_time   TYPE sy-uzeit,
      lv_end_date   TYPE sy-datum,
      lv_temp(14)   TYPE c,
      lv_starttime  TYPE p LENGTH 16 DECIMALS 0,
      lv_endtime    TYPE p LENGTH 16 DECIMALS 0.

    DATA:
      lv_request TYPE string,
      lt_value   TYPE STANDARD TABLE OF if_web_http_request=>name_value_pairs,
      ls_value   TYPE if_web_http_request=>name_value_pairs.

ENDCLASS.



CLASS ZCL_HTTP_PODATA_004 IMPLEMENTATION.


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

*    DATA(lt_supplier_invoice) = VALUE TABLE OF ty_response.
    DATA: lv_latest_date TYPE d.

    IF lt_req IS INITIAL.

      " 获取所有数据
      SELECT supplierinvoice,
             fiscalyear,
             invoicingparty,
             documentdate,
             postingdate,
             exchangerate,
             duecalculationbasedate,
             invoicegrossamount,
             createdbyuser,
             lastchangedbyuser
        FROM i_supplierinvoiceapi01
        INTO TABLE @DATA(lt_supplier_invoice1).

      DATA(lt_supplier_invoice2) = lt_supplier_invoice1[].
      IF lt_supplier_invoice2 IS NOT INITIAL.
        SORT lt_supplier_invoice2 BY supplierinvoice fiscalyear DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_supplier_invoice2 COMPARING supplierinvoice fiscalyear.
      ENDIF.

      " 定义 Range 表来存储拼接后的字段
      DATA: lt_range1 TYPE RANGE OF awkey,
            ls_range1 LIKE LINE OF lt_range1.

      " 将 SupplierInvoice 和 FiscalYear 拼接，并插入到 Range 表中
      LOOP AT lt_supplier_invoice2 INTO DATA(lw_supplier_invoice2).
        CLEAR ls_range1.
        ls_range1-sign = 'I'.
        ls_range1-option = 'EQ'.
        ls_range1-low = lw_supplier_invoice2-supplierinvoice && lw_supplier_invoice2-fiscalyear.
        APPEND ls_range1 TO lt_range1.
      ENDLOOP.

      " 从 I_JournalEntry 表中根据拼接的字段查询 AccountingDocument
      SELECT accountingdocument
        FROM i_journalentry
        WHERE originalreferencedocument IN @lt_range1
        INTO TABLE @DATA(lt_journal_entry1).

      " 从 I_SupplierInvoiceTaxAPI01 表获取数据
      SELECT supplierinvoice,
             fiscalyear,
             supplierinvoicetaxcounter,
             taxcode,
             taxamount
        FROM i_supplierinvoicetaxapi01
        FOR ALL ENTRIES IN @lt_supplier_invoice2
        WHERE supplierinvoice = @lt_supplier_invoice2-supplierinvoice
          AND fiscalyear = @lt_supplier_invoice2-fiscalyear
        INTO TABLE @DATA(lt_tax1).

      " 从 I_SuplrInvcItemPurOrdRefAPI01 表获取数据
      SELECT supplierinvoice,
             fiscalyear,
             supplierinvoiceitem,
             purchaseorder,
             purchaseorderitem,
             debitcreditcode,
             purchaseorderitemmaterial,
             purchaseorderquantityunit,
             quantityinpurchaseorderunit,
             documentcurrency,
             supplierinvoiceitemamount
        FROM i_suplrinvcitempurordrefapi01
        FOR ALL ENTRIES IN @lt_supplier_invoice2
        WHERE supplierinvoice = @lt_supplier_invoice2-supplierinvoice
          AND fiscalyear = @lt_supplier_invoice2-fiscalyear
        INTO TABLE @DATA(lt_po_ref1).

      " 判空
      IF lt_po_ref1 IS INITIAL.
        lv_error = 'X'.
        lv_text = 'No data found in I_SuplrInvcItemPurOrdRefAPI01'.
        " Handle the error
      ELSE.
        " 排序
        SORT lt_po_ref1 BY supplierinvoice fiscalyear supplierinvoiceitem.

        " 去重
        DELETE ADJACENT DUPLICATES FROM lt_po_ref1 COMPARING supplierinvoice fiscalyear supplierinvoiceitem.
      ENDIF.

      IF lt_po_ref1 IS NOT INITIAL.
        " 从 I_SuplrInvcItmAcctAssgmtAPI01 表获取数据
        SELECT supplierinvoice,
               fiscalyear,
               supplierinvoiceitem,
               costcenter,
               glaccount
          FROM i_suplrinvcitmacctassgmtapi01
          FOR ALL ENTRIES IN @lt_po_ref1
          WHERE supplierinvoice = @lt_po_ref1-supplierinvoice
            AND fiscalyear = @lt_po_ref1-fiscalyear
            AND supplierinvoiceitem = @lt_po_ref1-supplierinvoiceitem
          INTO TABLE @DATA(lt_acct_assgmt1).
      ENDIF.

      IF lt_po_ref1 IS NOT INITIAL.

        " 从 I_PurchaseOrderItemAPI01 表获取数据
        SELECT purchaseorder,
               purchaseorderitem,
               purchaseorderitemtext,
               requisitionername,
               requirementtracking,
               plant,
               netpriceamount,
               netpricequantity
          FROM i_purchaseorderitemapi01
          FOR ALL ENTRIES IN @lt_po_ref1
          WHERE purchaseorder = @lt_po_ref1-purchaseorder
            AND purchaseorderitem = @lt_po_ref1-purchaseorderitem
          INTO TABLE @DATA(lt_po_item1).

      ENDIF.


      IF lt_po_ref1 IS NOT INITIAL.
        " 从 I_PurchaseOrderAPI01 表获取数据
        SELECT purchaseorder,
               purchasinggroup,   "新加字段
               companycode
          FROM i_purchaseorderapi01
          FOR ALL ENTRIES IN @lt_po_ref1
          WHERE purchaseorder = @lt_po_ref1-purchaseorder
          INTO TABLE @DATA(lt_purchase_order1).
      ENDIF.

      DATA:
        lt_result1 TYPE STANDARD TABLE OF ty_response,
        lw_result1 TYPE ty_response.

      LOOP AT lt_supplier_invoice1 INTO DATA(lw_supplier_invoice1).
        CLEAR lw_result1.
        lw_result1-supplierinvoice        = lw_supplier_invoice1-supplierinvoice.
        lw_result1-fiscalyear             = lw_supplier_invoice1-fiscalyear.
        lw_result1-invoicingparty         = lw_supplier_invoice1-invoicingparty.
        lw_result1-documentdate           = lw_supplier_invoice1-documentdate.
        lw_result1-postingdate            = lw_supplier_invoice1-postingdate.
        lw_result1-exchangerate           = lw_supplier_invoice1-exchangerate.
        lw_result1-duecalculationbasedate = lw_supplier_invoice1-duecalculationbasedate.
        lw_result1-invoicegrossamount     = lw_supplier_invoice1-invoicegrossamount.
        lw_result1-createdbyuser          = lw_supplier_invoice1-createdbyuser.
        lw_result1-lastchangedbyuser      = lw_supplier_invoice1-lastchangedbyuser.

        " 查找相关的 Tax 数据
        READ TABLE lt_tax1 INTO DATA(lw_tax1) WITH KEY supplierinvoice = lw_result1-supplierinvoice
                                                            fiscalyear = lw_result1-fiscalyear.
        IF sy-subrc = 0.

          SELECT SINGLE zvalue2
            FROM ztbc_1001
            WHERE zid = 'MM0001'
            AND zvalue1 = @lw_tax1-taxcode
            INTO @DATA(lv_value2_1).

          lw_result1-supplierinvoicetaxcounter = lw_tax1-supplierinvoicetaxcounter.
          lw_result1-taxcode                   = lw_tax1-taxcode.
          lw_result1-taxamount                 = lv_value2_1 / 2.

        ENDIF.

        " 查找相关的 Purchase Order Reference 数据
        READ TABLE lt_po_ref1 INTO DATA(lw_po_ref1) WITH KEY supplierinvoice = lw_result1-supplierinvoice
                                                                  fiscalyear = lw_result1-fiscalyear.
        IF sy-subrc = 0.
          lw_result1-supplierinvoiceitem         = lw_po_ref1-supplierinvoiceitem.
          lw_result1-purchaseorder               = lw_po_ref1-purchaseorder.
          lw_result1-purchaseorderitem           = lw_po_ref1-purchaseorderitem.
          lw_result1-debitcreditcode             = lw_po_ref1-debitcreditcode.
          lw_result1-purchaseorderitemmaterial   = lw_po_ref1-purchaseorderitemmaterial.
          lw_result1-purchaseorderquantityunit   = lw_po_ref1-purchaseorderquantityunit.
          lw_result1-quantityinpurchaseorderunit = lw_po_ref1-quantityinpurchaseorderunit.
          lw_result1-supplierinvoiceitemamount   = lw_po_ref1-supplierinvoiceitemamount.
          lw_result1-totalamount                 = lw_po_ref1-supplierinvoiceitemamount + lw_result1-taxamount.
        ENDIF.

        " 将 lw_result 添加到结果表中
        APPEND lw_result1 TO lt_result1.

      ENDLOOP.

      LOOP AT lt_acct_assgmt1 INTO DATA(lw_acct_assgmt1).
        READ TABLE lt_result1 INTO lw_result1 WITH KEY supplierinvoice = lw_acct_assgmt1-supplierinvoice
                                                          fiscalyear = lw_acct_assgmt1-fiscalyear
                                                 supplierinvoiceitem = lw_acct_assgmt1-supplierinvoiceitem.
        IF sy-subrc = 0.
          lw_result1-costcenter = lw_acct_assgmt1-costcenter.
          lw_result1-glaccount  = lw_acct_assgmt1-glaccount.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_po_item1 INTO DATA(lw_po_item1).
        READ TABLE lt_result1 INTO lw_result1 WITH KEY purchaseorder = lw_po_item1-purchaseorder
                                                 purchaseorderitem = lw_po_item1-purchaseorderitem.
        IF sy-subrc = 0.
          lw_result1-purchaseorderitemtext = lw_po_item1-purchaseorderitemtext.
          lw_result1-requisitionername     = lw_po_item1-requisitionername.
          lw_result1-requirementtracking   = lw_po_item1-requirementtracking.
          lw_result1-plant                 = lw_po_item1-plant.

          " 检查 NetPriceQuantity 是否为零，避免除零错误
          IF lw_po_item1-netpricequantity <> 0.
            lw_result1-unitprice = lw_po_item1-netpriceamount / lw_po_item1-netpricequantity.
          ELSE.
            lw_result1-unitprice = 0. " 如果数量为 0，可以根据业务需求设定默认值
          ENDIF.

        ENDIF.
      ENDLOOP.

      " 示例：从 lt_purchase_order2 中获取数据并合并到 lw_result
      LOOP AT lt_purchase_order1 INTO DATA(lw_purchase_order1).
        READ TABLE lt_result1 INTO lw_result1 WITH KEY purchaseorder = lw_purchase_order1-purchaseorder.
        IF sy-subrc = 0.
          lw_result1-purchasinggroup = lw_purchase_order1-purchasinggroup.
          lw_result1-companycode     = lw_purchase_order1-companycode.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_journal_entry1 INTO DATA(lw_journal_entry1).
        " 拼接 OriginalReferenceDocument
        DATA(lv_combined_key1) = lw_result1-supplierinvoice && lw_result1-fiscalyear.

        " 根据拼接的 key 查找对应的记录
        READ TABLE lt_result1 INTO lw_result1
          WITH KEY accountingdocument = lv_combined_key1.
        IF sy-subrc = 0.
          lw_result1-accountingdocument = lw_journal_entry1-accountingdocument.
        ENDIF.
      ENDLOOP.

      " 合并数据
      LOOP AT lt_result1 INTO lw_result1.

        ls_response-supplierinvoice                      = lw_result1-supplierinvoice.
        ls_response-fiscalyear                           = lw_result1-fiscalyear.
        ls_response-invoicingparty                       = lw_result1-invoicingparty.
        ls_response-documentdate                         = lw_result1-documentdate.
        ls_response-postingdate                          = lw_result1-postingdate.
        ls_response-exchangerate                         = lw_result1-exchangerate.
        ls_response-duecalculationbasedate               = lw_result1-duecalculationbasedate.
        ls_response-invoicegrossamount                   = lw_result1-invoicegrossamount.
        ls_response-createdbyuser                        = lw_result1-createdbyuser.
        ls_response-lastchangedbyuser                    = lw_result1-lastchangedbyuser.
        ls_response-supplierinvoicetaxcounter            = lw_result1-debitcreditcode.
        ls_response-taxcode                              = lw_result1-taxcode.
        ls_response-taxamount                            = lw_result1-debitcreditcode.
        ls_response-supplierinvoiceitem                  = lw_result1-supplierinvoiceitem.
        ls_response-purchaseorder                        = lw_result1-purchaseorder.
        ls_response-purchaseorderitem                    = lw_result1-purchaseorderitem.
        ls_response-debitcreditcode                      = lw_result1-debitcreditcode.
        ls_response-purchaseorderitemmaterial            = lw_result1-purchaseorderitemmaterial.
        ls_response-documentcurrency                     = lw_result1-documentcurrency.
        ls_response-supplierinvoiceitemamount            = lw_result1-supplierinvoiceitemamount.
        ls_response-quantityinpurchaseorderunit          = lw_result1-quantityinpurchaseorderunit.
        ls_response-purchaseorderquantityunit            = lw_result1-purchaseorderquantityunit.
        ls_response-costcenter                           = lw_result1-costcenter.
        ls_response-glaccount                            = lw_result1-glaccount.
        ls_response-purchaseorderitemtext                = lw_result1-purchaseorderitemtext.
        ls_response-requisitionername                    = lw_result1-requisitionername.
        ls_response-requirementtracking                  = lw_result1-requirementtracking.
        ls_response-plant                                = lw_result1-plant.
        ls_response-purchasinggroup                      = lw_result1-purchasinggroup.
        ls_response-companycode                          = lw_result1-companycode.
        ls_response-purchasinggroupname                  = lw_result1-purchasinggroupname.
        ls_response-accountingdocument                   = lw_result1-accountingdocument.

        DATA lv_taxamount1    TYPE p LENGTH 10 DECIMALS 2.
        DATA lv_totalamount1  TYPE p LENGTH 10 DECIMALS 2.

        CASE lw_result1-documentcurrency.
          WHEN 'JPY'.
            " 保留 3 位小数，四舍五入
            DATA(lv_unit_price_jpy1) = round( val = lw_result1-unitprice dec = 3 ).
            ls_response-unitprice = lv_unit_price_jpy1.

            " 舍弃小数部分，取整
            DATA(lv_taxamount_jpy1) = floor( lw_result1-taxamount ).
            ls_response-totalamount = lv_taxamount_jpy1.

          WHEN 'USD'.
            " 保留 5 位小数，四舍五入
            DATA(lv_unit_price_usd1) = round( val = lw_result1-unitprice dec = 5 ).
            ls_response-unitprice = lv_unit_price_usd1.

            " 保留 2 位小数，舍弃其他位数
            lv_taxamount1 = floor( lw_result1-taxamount * 100 ) / 100.
            ls_response-taxamount = lv_taxamount1.

            " 保留 2 位小数，四舍五入
            lv_totalamount1 = floor( lw_result1-totalamount * 100 ) / 100.
            ls_response-totalamount = lv_totalamount1.

          WHEN 'EUR'.
            " 保留 5 位小数，四舍五入
            DATA(lv_unit_price_eur1) = round( val = lw_result1-unitprice dec = 5 ).
            ls_response-unitprice = lv_unit_price_eur1.

            " 乘以 100，取整后再除以 100，保留 2 位小数
            lv_taxamount1 = floor( lw_result1-taxamount * 100 ) / 100.
            " 保留 2 位小数，舍弃其他位数
            ls_response-taxamount = lv_taxamount1.

            " 保留 2 位小数，四舍五入
            lv_totalamount1 = floor( lw_result1-totalamount * 100 ) / 100.
            ls_response-totalamount = lv_totalamount1.

          WHEN OTHERS.
            ls_response-taxamount   = lw_result1-taxamount.
            ls_response-totalamount = lw_result1-totalamount.
            ls_response-unitprice   = lw_result1-unitprice.
        ENDCASE.


        CONDENSE ls_response-supplierinvoice.
        CONDENSE ls_response-fiscalyear.
        CONDENSE ls_response-invoicingparty.
        CONDENSE ls_response-documentdate.
        CONDENSE ls_response-postingdate.
        CONDENSE ls_response-exchangerate.
        CONDENSE ls_response-duecalculationbasedate.
        CONDENSE ls_response-invoicegrossamount.
        CONDENSE ls_response-createdbyuser.
        CONDENSE ls_response-lastchangedbyuser.
        CONDENSE ls_response-supplierinvoicetaxcounter.
        CONDENSE ls_response-taxcode.
        CONDENSE ls_response-taxamount.
        CONDENSE ls_response-supplierinvoiceitem.
        CONDENSE ls_response-purchaseorder.
        CONDENSE ls_response-purchaseorderitem.
        CONDENSE ls_response-debitcreditcode.
        CONDENSE ls_response-purchaseorderitemmaterial.
        CONDENSE ls_response-documentcurrency.
        CONDENSE ls_response-supplierinvoiceitemamount.
        CONDENSE ls_response-quantityinpurchaseorderunit.
        CONDENSE ls_response-purchaseorderquantityunit.
        CONDENSE ls_response-costcenter.
        CONDENSE ls_response-glaccount.
        CONDENSE ls_response-purchaseorderitemtext.
        CONDENSE ls_response-requisitionername.
        CONDENSE ls_response-requirementtracking.
        CONDENSE ls_response-plant.
        CONDENSE ls_response-purchasinggroup.
        CONDENSE ls_response-companycode.
        CONDENSE ls_response-purchasinggroupname.
        CONDENSE ls_response-accountingdocument.
        CONDENSE ls_response-taxamount.
        CONDENSE ls_response-totalamount.
        CONDENSE ls_response-unitprice.
        APPEND   ls_response TO es_response-items.

      ENDLOOP.

      IF lt_result1 IS INITIAL.
        lv_text = 'error'.
        "propagate any errors raised
        response->set_status( '500' )."500
        response->set_text( lv_text ).
      ELSE.

        "respond with success payload
        response->set_status( '200' ).

        DATA(lv_json_string1) = xco_cp_json=>data->from_abap( es_response )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_pascal_case )
           ) )->to_string( ).
        response->set_text( lv_json_string1 ).
        response->set_header_field( i_name  = lc_header_content
                                    i_value = lc_content_type ).

      ENDIF.

***************************************************************
    ELSE.

      " 根据 DocumentDate 过滤数据
      SELECT supplierinvoice,
             fiscalyear,
             invoicingparty,
             documentdate,
             postingdate,
             exchangerate,
             duecalculationbasedate,
             invoicegrossamount,
             createdbyuser,
             lastchangedbyuser
        FROM i_supplierinvoiceapi01
        FOR ALL ENTRIES IN @lt_req
        WHERE documentdate = @lt_req-documentdate
        INTO TABLE @DATA(lt_supplier_invoice3).

      DATA(lt_supplier_invoice4) = lt_supplier_invoice3[].
      IF lt_supplier_invoice4 IS NOT INITIAL.
        SORT lt_supplier_invoice4 BY supplierinvoice fiscalyear DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_supplier_invoice4 COMPARING supplierinvoice fiscalyear.
      ENDIF.

      " 定义 Range 表来存储拼接后的字段
      DATA: lt_range2 TYPE RANGE OF awkey,
            ls_range2 LIKE LINE OF lt_range2.

      " 将 SupplierInvoice 和 FiscalYear 拼接，并插入到 Range 表中
      LOOP AT lt_supplier_invoice4 INTO DATA(lw_supplier_invoice4).
        CLEAR ls_range2.
        ls_range2-sign = 'I'.
        ls_range2-option = 'EQ'.
        ls_range2-low = lw_supplier_invoice4-supplierinvoice && lw_supplier_invoice4-fiscalyear.
        APPEND ls_range2 TO lt_range2.
      ENDLOOP.

      " 从 I_JournalEntry 表中根据拼接的字段查询 AccountingDocument
      SELECT accountingdocument
        FROM i_journalentry
        WHERE originalreferencedocument IN @lt_range2
        INTO TABLE @DATA(lt_journal_entry2).

      " 从 I_SupplierInvoiceTaxAPI01 表获取数据
      SELECT supplierinvoice,
             fiscalyear,
             supplierinvoicetaxcounter,
             taxcode,
             taxamount
        FROM i_supplierinvoicetaxapi01
        FOR ALL ENTRIES IN @lt_supplier_invoice4
        WHERE supplierinvoice = @lt_supplier_invoice4-supplierinvoice
          AND fiscalyear = @lt_supplier_invoice4-fiscalyear
        INTO TABLE @DATA(lt_tax2).

      " 从 I_SuplrInvcItemPurOrdRefAPI01 表获取数据
      SELECT supplierinvoice,
             fiscalyear,
             supplierinvoiceitem,
             purchaseorder,
             purchaseorderitem,
             debitcreditcode,
             purchaseorderitemmaterial,
             purchaseorderquantityunit,
             quantityinpurchaseorderunit,
             documentcurrency,
             supplierinvoiceitemamount
        FROM i_suplrinvcitempurordrefapi01
        FOR ALL ENTRIES IN @lt_supplier_invoice4
        WHERE supplierinvoice = @lt_supplier_invoice4-supplierinvoice
          AND fiscalyear = @lt_supplier_invoice4-fiscalyear
        INTO TABLE @DATA(lt_po_ref2).

      " 判空
      IF lt_po_ref2 IS INITIAL.
        lv_error = 'X'.
        lv_text = 'No data found in I_SuplrInvcItemPurOrdRefAPI01'.
        " Handle the error
      ELSE.
        " 排序
        SORT lt_po_ref2 BY supplierinvoice fiscalyear supplierinvoiceitem.

        " 去重
        DELETE ADJACENT DUPLICATES FROM lt_po_ref2 COMPARING supplierinvoice fiscalyear supplierinvoiceitem.
      ENDIF.

      IF lt_po_ref2 IS NOT INITIAL.
        " 从 I_SuplrInvcItmAcctAssgmtAPI01 表获取数据
        SELECT supplierinvoice,
               fiscalyear,
               supplierinvoiceitem,
               costcenter,
               glaccount
          FROM i_suplrinvcitmacctassgmtapi01
          FOR ALL ENTRIES IN @lt_po_ref2
          WHERE supplierinvoice = @lt_po_ref2-supplierinvoice
            AND fiscalyear = @lt_po_ref2-fiscalyear
            AND supplierinvoiceitem = @lt_po_ref2-supplierinvoiceitem
          INTO TABLE @DATA(lt_acct_assgmt2).
      ENDIF.

      IF lt_po_ref2 IS NOT INITIAL.
        " 从 I_PurchaseOrderItemAPI01 表获取数据
        SELECT purchaseorder,
               purchaseorderitem,
               purchaseorderitemtext,
               requisitionername,
               requirementtracking,
               plant,
               netpriceamount,
               netpricequantity
          FROM i_purchaseorderitemapi01
          FOR ALL ENTRIES IN @lt_po_ref2
          WHERE purchaseorder = @lt_po_ref2-purchaseorder
            AND purchaseorderitem = @lt_po_ref2-purchaseorderitem
          INTO TABLE @DATA(lt_po_item2).
      ENDIF.

      IF lt_po_ref2 IS NOT INITIAL.
        " 从 I_PurchaseOrderAPI01 表获取数据
        SELECT purchaseorder,
               purchasinggroup,
               companycode
          FROM i_purchaseorderapi01
          FOR ALL ENTRIES IN @lt_po_ref2
          WHERE purchaseorder = @lt_po_ref2-purchaseorder
          INTO TABLE @DATA(lt_purchase_order2).
      ENDIF.

    ENDIF.

    DATA:
      lt_result TYPE STANDARD TABLE OF ty_response,
      lw_result TYPE ty_response.

    LOOP AT lt_supplier_invoice3 INTO DATA(lw_supplier_invoice3).
      CLEAR lw_result.
      lw_result-supplierinvoice        = lw_supplier_invoice3-supplierinvoice.
      lw_result-fiscalyear             = lw_supplier_invoice3-fiscalyear.
      lw_result-invoicingparty         = lw_supplier_invoice3-invoicingparty.
      lw_result-documentdate           = lw_supplier_invoice3-documentdate.
      lw_result-postingdate            = lw_supplier_invoice3-postingdate.
      lw_result-exchangerate           = lw_supplier_invoice3-exchangerate.
      lw_result-duecalculationbasedate = lw_supplier_invoice3-duecalculationbasedate.
      lw_result-invoicegrossamount     = lw_supplier_invoice3-invoicegrossamount.
      lw_result-createdbyuser          = lw_supplier_invoice3-createdbyuser.
      lw_result-lastchangedbyuser      = lw_supplier_invoice3-lastchangedbyuser.

      " 查找相关的 Tax 数据
      READ TABLE lt_tax2 INTO DATA(lw_tax2) WITH KEY supplierinvoice = lw_result-supplierinvoice
                                                          fiscalyear = lw_result-fiscalyear.

      IF sy-subrc = 0.

        SELECT SINGLE zvalue2
          FROM ztbc_1001
          WHERE zid = 'MM0001'
          AND zvalue1 = @lw_tax2-taxcode
          INTO @DATA(lv_value2_2).

        lw_result-supplierinvoicetaxcounter = lw_tax2-supplierinvoicetaxcounter.
        lw_result-taxcode                   = lw_tax2-taxcode.
        lw_result-taxamount                 = lv_value2_2 / 2.

      ENDIF.

      " 查找相关的 Purchase Order Reference 数据
      READ TABLE lt_po_ref2 INTO DATA(lw_po_ref2) WITH KEY supplierinvoice = lw_result-supplierinvoice
                                                                fiscalyear = lw_result-fiscalyear.
      IF sy-subrc = 0.
        lw_result-supplierinvoiceitem         = lw_po_ref2-supplierinvoiceitem.
        lw_result-purchaseorder               = lw_po_ref2-purchaseorder.
        lw_result-purchaseorderitem           = lw_po_ref2-purchaseorderitem.
        lw_result-debitcreditcode             = lw_po_ref2-debitcreditcode.
        lw_result-purchaseorderitemmaterial   = lw_po_ref2-purchaseorderitemmaterial.
        lw_result-purchaseorderquantityunit   = lw_po_ref2-purchaseorderquantityunit.
        lw_result-quantityinpurchaseorderunit = lw_po_ref2-quantityinpurchaseorderunit.
        lw_result-supplierinvoiceitemamount   = lw_po_ref2-supplierinvoiceitemamount.
        lw_result-totalamount                 = lw_po_ref2-supplierinvoiceitemamount + lw_result-taxamount.
      ENDIF.

      " 将 lw_result 添加到结果表中
      APPEND lw_result TO lt_result.
    ENDLOOP.

    LOOP AT lt_acct_assgmt2 INTO DATA(lw_acct_assgmt2).
      READ TABLE lt_result INTO lw_result WITH KEY supplierinvoice = lw_acct_assgmt2-supplierinvoice
                                                        fiscalyear = lw_acct_assgmt2-fiscalyear
                                               supplierinvoiceitem = lw_acct_assgmt2-supplierinvoiceitem.
      IF sy-subrc = 0.
        lw_result-costcenter = lw_acct_assgmt2-costcenter.
        lw_result-glaccount  = lw_acct_assgmt2-glaccount.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_po_item2 INTO DATA(lw_po_item2).
      READ TABLE lt_result INTO lw_result WITH KEY purchaseorder = lw_po_item2-purchaseorder
                                               purchaseorderitem = lw_po_item2-purchaseorderitem.
      IF sy-subrc = 0.
        lw_result-purchaseorderitemtext = lw_po_item2-purchaseorderitemtext.
        lw_result-requisitionername     = lw_po_item2-requisitionername.
        lw_result-requirementtracking   = lw_po_item2-requirementtracking.
        lw_result-plant                 = lw_po_item2-plant.

        " 检查 NetPriceQuantity 是否为零，避免除零错误
        IF lw_po_item2-netpricequantity <> 0.
          lw_result-unitprice = lw_po_item2-netpriceamount / lw_po_item2-netpricequantity.
        ELSE.
          lw_result-unitprice = 0. " 如果数量为 0，可以根据业务需求设定默认值
        ENDIF.

      ENDIF.

    ENDLOOP.

    " 示例：从 lt_purchase_order2 中获取数据并合并到 lw_result
    LOOP AT lt_purchase_order2 INTO DATA(lw_purchase_order2).
      READ TABLE lt_result INTO lw_result WITH KEY purchaseorder = lw_purchase_order2-purchaseorder.
      IF sy-subrc = 0.
        lw_result-purchasinggroup = lw_purchase_order2-purchasinggroup.
        lw_result-companycode     = lw_purchase_order2-companycode.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_journal_entry2 INTO DATA(lw_journal_entry2).
      " 拼接 OriginalReferenceDocument
      DATA(lv_combined_key) = lw_result-supplierinvoice && lw_result-fiscalyear.

      " 根据拼接的 key 查找对应的记录
      READ TABLE lt_result INTO lw_result
        WITH KEY accountingdocument = lv_combined_key.
      IF sy-subrc = 0.
        lw_result-accountingdocument = lw_journal_entry2-accountingdocument.
      ENDIF.
    ENDLOOP.

    " 合并数据
    LOOP AT lt_result INTO lw_result.

      ls_response-supplierinvoice                      = lw_result-supplierinvoice.
      ls_response-fiscalyear                           = lw_result-fiscalyear.
      ls_response-invoicingparty                       = lw_result-invoicingparty.
      ls_response-documentdate                         = lw_result-documentdate.
      ls_response-postingdate                          = lw_result-postingdate.
      ls_response-exchangerate                         = lw_result-exchangerate.
      ls_response-duecalculationbasedate               = lw_result-duecalculationbasedate.
      ls_response-invoicegrossamount                   = lw_result-invoicegrossamount.
      ls_response-createdbyuser                        = lw_result-createdbyuser.
      ls_response-lastchangedbyuser                    = lw_result-lastchangedbyuser.
      ls_response-supplierinvoicetaxcounter            = lw_result-debitcreditcode.
      ls_response-taxcode                              = lw_result-taxcode.
      ls_response-taxamount                            = lw_result-debitcreditcode.
      ls_response-supplierinvoiceitem                  = lw_result-supplierinvoiceitem.
      ls_response-purchaseorder                        = lw_result-purchaseorder.
      ls_response-purchaseorderitem                    = lw_result-purchaseorderitem.
      ls_response-debitcreditcode                      = lw_result-debitcreditcode.
      ls_response-purchaseorderitemmaterial            = lw_result-purchaseorderitemmaterial.
      ls_response-documentcurrency                     = lw_result-documentcurrency.
      ls_response-supplierinvoiceitemamount            = lw_result-supplierinvoiceitemamount.
      ls_response-quantityinpurchaseorderunit          = lw_result-quantityinpurchaseorderunit.
      ls_response-purchaseorderquantityunit            = lw_result-purchaseorderquantityunit.
      ls_response-costcenter                           = lw_result-costcenter.
      ls_response-glaccount                            = lw_result-glaccount.
      ls_response-purchaseorderitemtext                = lw_result-purchaseorderitemtext.
      ls_response-requisitionername                    = lw_result-requisitionername.
      ls_response-requirementtracking                  = lw_result-requirementtracking.
      ls_response-plant                                = lw_result-plant.
      ls_response-purchasinggroup                      = lw_result-purchasinggroup.
      ls_response-companycode                          = lw_result-companycode.
      ls_response-purchasinggroupname                  = lw_result-purchasinggroupname.
      ls_response-accountingdocument                   = lw_result-accountingdocument.
      ls_response-taxamount                            = lw_result-taxamount.
      ls_response-totalamount                          = lw_result-totalamount.
      ls_response-unitprice                            = lw_result-unitprice.

      DATA lv_taxamount2    TYPE p LENGTH 10 DECIMALS 2.
      DATA lv_totalamount2  TYPE p LENGTH 10 DECIMALS 2.

      CASE lw_result1-documentcurrency.
        WHEN 'JPY'.
          " 保留 3 位小数，四舍五入
          DATA(lv_unit_price_jpy2) = round( val = lw_result1-unitprice dec = 3 ).
          ls_response-unitprice = lv_unit_price_jpy2.

          " 舍弃小数部分，取整
          DATA(lv_taxamount_jpy2) = floor( lw_result1-taxamount ).
          ls_response-totalamount = lv_taxamount_jpy2.

        WHEN 'USD'.
          " 保留 5 位小数，四舍五入
          DATA(lv_unit_price_usd2) = round( val = lw_result1-unitprice dec = 5 ).
          ls_response-unitprice = lv_unit_price_usd2.

          " 保留 2 位小数，舍弃其他位数
          lv_taxamount2 = floor( lw_result1-taxamount * 100 ) / 100.
          ls_response-taxamount = lv_taxamount2.

          " 保留 2 位小数，四舍五入
          lv_totalamount2 = floor( lw_result1-totalamount * 100 ) / 100.
          ls_response-totalamount = lv_totalamount2.

        WHEN 'EUR'.
          " 保留 5 位小数，四舍五入
          DATA(lv_unit_price_eur2) = round( val = lw_result1-unitprice dec = 5 ).
          ls_response-unitprice = lv_unit_price_eur2.

          " 乘以 100，取整后再除以 100，保留 2 位小数
          lv_taxamount2 = floor( lw_result1-taxamount * 100 ) / 100.
          " 保留 2 位小数，舍弃其他位数
          ls_response-taxamount = lv_taxamount2.

          " 保留 2 位小数，四舍五入
          lv_totalamount2 = floor( lw_result1-totalamount * 100 ) / 100.
          ls_response-totalamount = lv_totalamount2.

        WHEN OTHERS.
          ls_response-taxamount   = lw_result1-taxamount.
          ls_response-totalamount = lw_result1-totalamount.
          ls_response-unitprice   = lw_result1-unitprice.
      ENDCASE.

      CONDENSE ls_response-supplierinvoice.
      CONDENSE ls_response-fiscalyear.
      CONDENSE ls_response-invoicingparty.
      CONDENSE ls_response-documentdate.
      CONDENSE ls_response-postingdate.
      CONDENSE ls_response-exchangerate.
      CONDENSE ls_response-duecalculationbasedate.
      CONDENSE ls_response-invoicegrossamount.
      CONDENSE ls_response-createdbyuser.
      CONDENSE ls_response-lastchangedbyuser.
      CONDENSE ls_response-supplierinvoicetaxcounter.
      CONDENSE ls_response-taxcode.
      CONDENSE ls_response-taxamount.
      CONDENSE ls_response-supplierinvoiceitem.
      CONDENSE ls_response-purchaseorder.
      CONDENSE ls_response-purchaseorderitem.
      CONDENSE ls_response-debitcreditcode.
      CONDENSE ls_response-purchaseorderitemmaterial.
      CONDENSE ls_response-documentcurrency.
      CONDENSE ls_response-supplierinvoiceitemamount.
      CONDENSE ls_response-quantityinpurchaseorderunit.
      CONDENSE ls_response-purchaseorderquantityunit.
      CONDENSE ls_response-costcenter.
      CONDENSE ls_response-glaccount.
      CONDENSE ls_response-purchaseorderitemtext.
      CONDENSE ls_response-requisitionername.
      CONDENSE ls_response-requirementtracking.
      CONDENSE ls_response-plant.
      CONDENSE ls_response-purchasinggroup.
      CONDENSE ls_response-companycode.
      CONDENSE ls_response-purchasinggroupname.
      CONDENSE ls_response-accountingdocument.
      CONDENSE ls_response-taxamount.
      CONDENSE ls_response-totalamount.
      CONDENSE ls_response-unitprice.
      APPEND   ls_response TO es_response-items.

    ENDLOOP.

    IF lt_result IS INITIAL.
      lv_text = 'error'.
      "propagate any errors raised
      response->set_status( '500' )."500
      response->set_text( lv_text ).
    ELSE.

      "respond with success payload
      response->set_status( '200' ).

      DATA(lv_json_string) = xco_cp_json=>data->from_abap( es_response )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
         ) )->to_string( ).
      response->set_text( lv_json_string ).
      response->set_header_field( i_name  = lc_header_content
                                  i_value = lc_content_type ).

    ENDIF.

  ENDMETHOD.
ENDCLASS.
