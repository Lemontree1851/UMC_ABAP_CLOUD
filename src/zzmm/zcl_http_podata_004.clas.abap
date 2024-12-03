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
        documentdate                TYPE d,             "請求書日付"
        postingdate1                TYPE c LENGTH 8,    "転記日付"
        postingdate2                TYPE c LENGTH 8,    "伝票日付"
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
        suppliername                TYPE c LENGTH 20,   "サプライヤ名
        taxrate                     TYPE c LENGTH 2,    "税率
        sendflag                    TYPE c LENGTH 1,    "status
        documentheadertext          TYPE c LENGTH 40,
        taxamountheader             TYPE c LENGTH 13,   "消費税額header
      END OF ty_response,

*----------------------------------------------uweb调用参考 pickinglist。
      BEGIN OF ty_response_res,
        inv_no  TYPE c LENGTH 10,
        gl_year TYPE c LENGTH 4,

      END OF ty_response_res,

      BEGIN OF ty_response_d,
        results TYPE TABLE OF ty_response_res WITH DEFAULT KEY,
      END OF ty_response_d,

      BEGIN OF ty_maxinvoice,
        d TYPE ty_response_d,
      END OF ty_maxinvoice,

**********************************************************************

      BEGIN OF ty_output,
        items TYPE STANDARD TABLE OF ty_response WITH EMPTY KEY,
      END OF ty_output.

    INTERFACES if_http_service_extension .
PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      lt_req TYPE STANDARD TABLE OF ty_inputs,
      lw_req LIKE LINE OF lt_req.

    DATA:  lt_uweb_api   TYPE STANDARD TABLE OF ty_response_res,
           ls_maxinvoice TYPE ty_maxinvoice.

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

    DATA:lv_rate TYPE p DECIMALS 2.

  ENDCLASS.

CLASS ZCL_HTTP_PODATA_004 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA: lv_latest_date TYPE d.

    DATA(lv_sy_datum) = cl_abap_context_info=>get_system_date( ).

    lw_req-documentdate = lv_sy_datum.

    APPEND lw_req TO lt_req.

    IF lt_req IS INITIAL.

      " 根据 DocumentDate 过滤数据
      SELECT a~supplierinvoice,
             a~fiscalyear,
             a~invoicingparty,
             a~documentdate,
             a~postingdate,
             a~exchangerate,
             a~duecalculationbasedate,
             a~invoicegrossamount,
             a~createdbyuser,
             a~lastchangedbyuser,
             a~documentheadertext,
             a~companycode,
             a~documentcurrency,
             b~suppliername,
             c~supplierinvoiceitem,
             c~purchaseorder,
             c~purchaseorderitem,
             c~debitcreditcode,
             c~purchaseorderitemmaterial,
             c~purchaseorderquantityunit,
             c~quantityinpurchaseorderunit,
*             c~documentcurrency,
             c~supplierinvoiceitemamount,
             d~postingdate AS postingdate_item,
             e~purchasinggroup,
             f~purchasinggroupname
        FROM i_supplierinvoiceapi01 WITH PRIVILEGED ACCESS AS a
        LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS b
        ON b~supplier = a~invoicingparty
        LEFT JOIN i_suplrinvcitempurordrefapi01 WITH PRIVILEGED ACCESS AS c
        ON c~supplierinvoice = a~supplierinvoice
        AND c~fiscalyear = a~fiscalyear
         LEFT JOIN i_materialdocumentheader_2 WITH PRIVILEGED ACCESS AS d
        ON d~materialdocumentyear = c~referencedocumentfiscalyear
        AND d~materialdocument    = c~referencedocument
        LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS e
        ON e~purchaseorder = c~purchaseorder
        LEFT JOIN i_purchasinggroup WITH PRIVILEGED ACCESS AS f
        ON f~purchasinggroup = e~purchasinggroup
        INTO TABLE @DATA(lt_supplier_invoice1).

      DATA(lt_supplier_invoice2) = lt_supplier_invoice1[].
      IF lt_supplier_invoice2 IS NOT INITIAL.
        SORT lt_supplier_invoice2 BY supplierinvoice fiscalyear DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_supplier_invoice2 COMPARING supplierinvoice fiscalyear purchaseorder purchaseorderitem.
      ENDIF.

      " 从 I_SupplierInvoiceTaxAPI01 表获取数据
      SELECT supplierinvoice,
             fiscalyear,
             supplierinvoicetaxcounter,
             taxcode,
             taxamount
        FROM i_supplierinvoicetaxapi01 WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_supplier_invoice2
        WHERE supplierinvoice = @lt_supplier_invoice2-supplierinvoice
          AND fiscalyear = @lt_supplier_invoice2-fiscalyear
        INTO TABLE @DATA(lt_tax1).

      IF lt_tax1 IS NOT INITIAL.
        SORT lt_tax1 BY supplierinvoice fiscalyear DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_tax1 COMPARING supplierinvoice fiscalyear.
      ENDIF.

      " 判空
      IF lt_supplier_invoice1 IS INITIAL.
        lv_error = 'X'.
        lv_text = 'No data found in I_SuplrInvcItemPurOrdRefAPI01'.
        " Handle the error
      ELSE.
        " 排序
        SORT lt_supplier_invoice1 BY supplierinvoice fiscalyear purchaseorder supplierinvoiceitem.

        " 去重
        DELETE ADJACENT DUPLICATES FROM lt_supplier_invoice1 COMPARING supplierinvoice fiscalyear purchaseorder supplierinvoiceitem.
      ENDIF.

      IF lt_supplier_invoice1 IS NOT INITIAL.

        " 从 I_PurOrdAccountAssignmentAPI01 表获取数据
        SELECT purchaseorder,
               purchaseorderitem,
               costcenter,
               glaccount
          FROM i_purordaccountassignmentapi01 WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_supplier_invoice2
          WHERE purchaseorder = @lt_supplier_invoice2-purchaseorder
            AND purchaseorderitem = @lt_supplier_invoice2-purchaseorderitem
          INTO TABLE @DATA(lt_acct_assgmt1).
      ENDIF.

      " 判空
      IF lt_acct_assgmt1 IS INITIAL.
        lv_error = 'X'.
        lv_text = 'No data found in i_purordaccountassignmentapi01'.
        " Handle the error
      ELSE.
        " 排序
        SORT lt_acct_assgmt1 BY purchaseorder purchaseorderitem.

        " 去重
        DELETE ADJACENT DUPLICATES FROM lt_acct_assgmt1 COMPARING purchaseorder purchaseorderitem.
      ENDIF.

      IF lt_supplier_invoice1 IS NOT INITIAL.

        " 从 I_PurchaseOrderItemAPI01 表获取数据
        SELECT purchaseorder,
               purchaseorderitem,
               purchaseorderitemtext,
               requisitionername,
               requirementtracking,
               plant,
               netpriceamount,
               netpricequantity
          FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_supplier_invoice2
          WHERE purchaseorder = @lt_supplier_invoice2-purchaseorder
            AND purchaseorderitem = @lt_supplier_invoice2-purchaseorderitem
          INTO TABLE @DATA(lt_po_item1).

      ENDIF.

      " 判空
      IF lt_po_item1 IS NOT INITIAL.
        SORT lt_po_item1 BY purchaseorder purchaseorderitem.
        DELETE ADJACENT DUPLICATES FROM lt_po_item1 COMPARING purchaseorder purchaseorderitem.
      ENDIF.

      IF lt_supplier_invoice1 IS NOT INITIAL.
        " 从 I_PurchaseOrderAPI01 表获取数据
        SELECT a~purchaseorder,
               a~purchasinggroup,   "新加字段
*               a~companycode,
               b~purchasinggroupname
          FROM i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS a
          LEFT JOIN i_purchasinggroup WITH PRIVILEGED ACCESS AS b
          ON b~purchasinggroup = a~purchasinggroup
          FOR ALL ENTRIES IN @lt_supplier_invoice2
          WHERE purchaseorder = @lt_supplier_invoice2-purchaseorder
          INTO TABLE @DATA(lt_purchase_order1).
      ENDIF.

      " 判空
      IF lt_purchase_order1 IS NOT INITIAL.
        SORT lt_purchase_order1 BY purchaseorder.
        DELETE ADJACENT DUPLICATES FROM lt_purchase_order1 COMPARING purchaseorder.
      ENDIF.

      DATA:
        lt_result1 TYPE STANDARD TABLE OF ty_response,
        lw_result1 TYPE ty_response.

      LOOP AT lt_supplier_invoice1 INTO DATA(lw_supplier_invoice1).

        lw_result1-supplierinvoice             = lw_supplier_invoice1-supplierinvoice.
        lw_result1-fiscalyear                  = lw_supplier_invoice1-fiscalyear.
        lw_result1-documentcurrency            = lw_supplier_invoice1-documentcurrency.
        lw_result1-postingdate2                = lw_supplier_invoice1-postingdate.
        lw_result1-supplierinvoiceitem         = lw_supplier_invoice1-supplierinvoiceitem.
        lw_result1-purchaseorder               = lw_supplier_invoice1-purchaseorder.
        lw_result1-purchaseorderitem           = lw_supplier_invoice1-purchaseorderitem.
        lw_result1-debitcreditcode             = lw_supplier_invoice1-debitcreditcode.
        lw_result1-purchaseorderitemmaterial   = lw_supplier_invoice1-purchaseorderitemmaterial.
        lw_result1-purchaseorderquantityunit   = lw_supplier_invoice1-purchaseorderquantityunit.
        lw_result1-quantityinpurchaseorderunit = lw_supplier_invoice1-quantityinpurchaseorderunit.
        lw_result1-supplierinvoiceitemamount   = lw_supplier_invoice1-supplierinvoiceitemamount.
        lw_result1-purchasinggroup             = lw_supplier_invoice1-purchasinggroup.
        lw_result1-purchasinggroupname         = lw_supplier_invoice1-purchasinggroupname.
        lw_result1-suppliername                = lw_supplier_invoice1-suppliername.
        lw_result1-invoicingparty              = lw_supplier_invoice1-invoicingparty.
        lw_result1-documentdate                = lw_supplier_invoice1-documentdate.
        lw_result1-postingdate1                = lw_supplier_invoice1-postingdate.
        lw_result1-exchangerate                = lw_supplier_invoice1-exchangerate.
        lw_result1-duecalculationbasedate      = lw_supplier_invoice1-duecalculationbasedate.
        lw_result1-invoicegrossamount          = lw_supplier_invoice1-invoicegrossamount.
        lw_result1-createdbyuser               = lw_supplier_invoice1-createdbyuser.
        lw_result1-lastchangedbyuser           = lw_supplier_invoice1-lastchangedbyuser.
        lw_result1-documentheadertext          = lw_supplier_invoice1-documentheadertext.
        lw_result1-companycode                 = lw_supplier_invoice1-companycode.

        SORT lt_tax1 BY supplierinvoice fiscalyear DESCENDING.
        READ TABLE lt_tax1 INTO DATA(lw_tax1) WITH KEY supplierinvoice = lw_result1-supplierinvoice
                                                            fiscalyear = lw_result1-fiscalyear
                                                            BINARY SEARCH.
        IF sy-subrc = 0.

          SELECT SINGLE zvalue2
            FROM ztbc_1001
            WHERE zid = 'ZMM001'
            AND zvalue1 = @lw_tax1-taxcode
            INTO @DATA(lv_value2_1).

          lw_result1-supplierinvoicetaxcounter = lw_tax1-supplierinvoicetaxcounter.
          lw_result1-taxcode                   = lw_tax1-taxcode.
          lw_result1-taxamountheader           = lw_tax1-taxamount.
          lw_result1-taxrate                   = lv_value2_1.
          lv_rate = lv_value2_1 / 100.

        ENDIF.

        READ TABLE lt_supplier_invoice1 INTO DATA(ls_supplier_invoice1) WITH KEY supplierinvoice = lw_result1-supplierinvoice
                                                                  fiscalyear = lw_result1-fiscalyear
                                                                  BINARY SEARCH.
        IF sy-subrc = 0.
          lw_result1-taxamount                   = ls_supplier_invoice1-supplierinvoiceitemamount * lv_rate.
          lw_result1-totalamount                 = ls_supplier_invoice1-supplierinvoiceitemamount + lw_result1-taxamount.
        ENDIF.

        " 将 lw_result 添加到结果表中
        APPEND lw_result1 TO lt_result1.

      ENDLOOP.

      SORT lt_result1 BY purchaseorder purchaseorderitem DESCENDING.
      LOOP AT lt_result1 ASSIGNING FIELD-SYMBOL(<lw_result1>).

        READ TABLE lt_acct_assgmt1 INTO DATA(lw_acct_assgmt1) WITH KEY purchaseorder     = <lw_result1>-purchaseorder
                                                                       purchaseorderitem = <lw_result1>-purchaseorderitem
                                                                       BINARY SEARCH.
        IF sy-subrc = 0.
          <lw_result1>-costcenter = lw_acct_assgmt1-costcenter.
          <lw_result1>-glaccount  = lw_acct_assgmt1-glaccount.
        ENDIF.

        READ TABLE lt_po_item1 INTO DATA(lw_po_item1) WITH KEY purchaseorder     = <lw_result1>-purchaseorder
                                                               purchaseorderitem = <lw_result1>-purchaseorderitem
                                                               BINARY SEARCH.
        IF sy-subrc = 0.
          <lw_result1>-purchaseorderitemtext = lw_po_item1-purchaseorderitemtext.
          <lw_result1>-requisitionername     = lw_po_item1-requisitionername.
          <lw_result1>-requirementtracking   = lw_po_item1-requirementtracking.
          <lw_result1>-plant                 = lw_po_item1-plant.

          " 检查 NetPriceQuantity 是否为零，避免除零错误
          IF lw_po_item1-netpricequantity <> 0.
            <lw_result1>-unitprice = lw_po_item1-netpriceamount / lw_po_item1-netpricequantity.
          ELSE.
            <lw_result1>-unitprice = 0. " 如果数量为 0，可以根据业务需求设定默认值
          ENDIF.

        ENDIF.

      ENDLOOP.

      "uweb 接口
      zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |http://220.248.121.53:11380/srv/odata/v2/TableService/PCH_T04_PAYMENT_H|
                                                              iv_client_id     = CONV #( 'Tom' )
                                                              iv_client_secret = CONV #( '1' )
                                                             iv_authtype      = 'Basic'
                                                    IMPORTING ev_status_code   = DATA(lv_status_code_uweb)
                                                              ev_response      = DATA(lv_response_uweb) ).
      IF lv_status_code_uweb = 200.
        xco_cp_json=>data->from_string( lv_response_uweb )->apply( VALUE #(
*            ( xco_cp_json=>transformation->pascal_case_to_underscore )
          ( xco_cp_json=>transformation->boolean_to_abap_bool )
        ) )->write_to( REF #( ls_maxinvoice ) ).

        IF ls_maxinvoice-d-results IS NOT INITIAL.

          APPEND LINES OF ls_maxinvoice-d-results TO lt_uweb_api.

        ENDIF.

      ENDIF.

      SORT lt_uweb_api BY gl_year inv_no DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_uweb_api COMPARING gl_year inv_no.

      "inv_no
      READ TABLE lt_uweb_api INDEX 1 INTO DATA(lw_versionmax).

      SORT lt_result1 BY supplierinvoice fiscalyear DESCENDING.

      " 删除 supplierinvoice 小于 lw_versionmax-inv_no 的数据
      DELETE lt_result1 WHERE supplierinvoice < lw_versionmax-inv_no.

      " 删除 supplierinvoiceitem 为空且 taxamountheader 不等于 '仮払消費税調整' 的数据
      DELETE lt_result1 WHERE supplierinvoiceitem IS INITIAL OR supplierinvoiceitem = '000000'
                          AND documentheadertext <> '仮払消費税調整'.

      " 合并数据
      LOOP AT lt_result1 INTO lw_result1.

        DATA(lv_unit1) = lw_result1-purchaseorderquantityunit.
        DATA(lv_unit11) = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = lv_unit1 ).

        ls_response-documentheadertext                   = lw_result1-documentheadertext.
        ls_response-suppliername                         = lw_result1-suppliername.
        ls_response-supplierinvoice                      = lw_result1-supplierinvoice.
        ls_response-fiscalyear                           = lw_result1-fiscalyear.
        " 去除前导零
        SHIFT lw_result1-invoicingparty LEFT DELETING LEADING '0'.
        ls_response-invoicingparty                       = lw_result1-invoicingparty.
        ls_response-documentdate                         = lw_result1-documentdate.

        IF lw_result1-postingdate1 = '00000000'.
          ls_response-postingdate1 = space.
        ELSE.
          ls_response-postingdate1                         = lw_result1-postingdate1.
        ENDIF.

        IF lw_result1-postingdate2 = '00000000'.
          ls_response-postingdate2 = space.
        ELSE.
          ls_response-postingdate2                         = lw_result1-postingdate2.
        ENDIF.

        ls_response-exchangerate                         = lw_result1-exchangerate.
        ls_response-duecalculationbasedate               = lw_result1-duecalculationbasedate.
        ls_response-invoicegrossamount                   = lw_result1-invoicegrossamount.
        ls_response-createdbyuser                        = lw_result1-createdbyuser.
        ls_response-lastchangedbyuser                    = lw_result1-lastchangedbyuser.
        ls_response-supplierinvoicetaxcounter            = lw_result1-debitcreditcode.
        ls_response-taxcode                              = lw_result1-taxcode.
        ls_response-taxamount                            = lw_result1-debitcreditcode.
        IF lw_result1-supplierinvoiceitem IS INITIAL OR lw_result1-supplierinvoiceitem = '000000' AND lw_result1-documentheadertext = '仮払消費税調整'.
          ls_response-supplierinvoiceitem = '1'.
        ELSE.
          ls_response-supplierinvoiceitem                  = lw_result1-supplierinvoiceitem.
        ENDIF.
        ls_response-supplierinvoiceitem                  = lw_result1-supplierinvoiceitem.
        SHIFT lw_result1-purchaseorder LEFT DELETING LEADING '0'.
        ls_response-purchaseorder                        = lw_result1-purchaseorder.
        ls_response-purchaseorderitem                    = lw_result1-purchaseorderitem.
        ls_response-debitcreditcode                      = lw_result1-debitcreditcode.
        ls_response-purchaseorderitemmaterial            = lw_result1-purchaseorderitemmaterial.
        ls_response-documentcurrency                     = lw_result1-documentcurrency.
*        ls_response-supplierinvoiceitemamount            = lw_result1-supplierinvoiceitemamount.
        ls_response-taxrate                              = lw_result1-taxrate.
        ls_response-quantityinpurchaseorderunit          = lw_result1-quantityinpurchaseorderunit.
        ls_response-purchaseorderquantityunit            = lv_unit11.
        ls_response-costcenter                           = lw_result1-costcenter.
        ls_response-glaccount                            = lw_result1-glaccount.
        ls_response-purchaseorderitemtext                = lw_result1-purchaseorderitemtext.
        ls_response-requisitionername                    = lw_result1-requisitionername.
        ls_response-requirementtracking                  = lw_result1-requirementtracking.
        ls_response-plant                                = lw_result1-plant.
        ls_response-purchasinggroup                      = lw_result1-purchasinggroup.
        ls_response-companycode                          = lw_result1-companycode.
        ls_response-purchasinggroupname                  = lw_result1-purchasinggroupname.
*        ls_response-accountingdocument                   = lw_result1-accountingdocument.
        ls_response-sendflag                             = '1'.
*        ls_response-taxamountheader                      = lw_result1-taxamountheader.

        DATA lv_taxamount1        TYPE p LENGTH 10 DECIMALS 2.
        DATA lv_totalamount1      TYPE p LENGTH 10 DECIMALS 2.
        DATA lv_netpriceamount    TYPE p LENGTH 10 DECIMALS 5.
        DATA lv_unit_price_jpy1   TYPE p LENGTH 10 DECIMALS 3.
        DATA lv_taxamount_jpy1    TYPE p LENGTH 10 DECIMALS 5.

        CASE lw_result1-documentcurrency.
          WHEN 'JPY'.
            " 保留 3 位小数，四舍五入
            lv_netpriceamount  = lw_result1-unitprice * 100.
            lv_unit_price_jpy1 = round( val = lv_netpriceamount dec = 3 ).
            ls_response-unitprice = lv_unit_price_jpy1.

            " 舍弃小数部分，取整
            CONDENSE lw_result1-taxamount.
            lv_taxamount1 = lw_result1-taxamount * 100.
            lv_taxamount_jpy1 = floor( lv_taxamount1 ).
            ls_response-taxamount = lv_taxamount_jpy1.
            ls_response-supplierinvoiceitemamount = lw_result1-supplierinvoiceitemamount * 100.
            ls_response-totalamount  = lw_result1-totalamount * 100.
            ls_response-invoicegrossamount  = lw_result1-invoicegrossamount * 100.
            ls_response-taxamountheader     = lw_result1-taxamountheader * 100.

            ls_response-totalamount        = ls_response-supplierinvoiceitemamount + ls_response-taxamount.


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

        CONDENSE ls_response-suppliername.
        CONDENSE ls_response-supplierinvoice.
        CONDENSE ls_response-fiscalyear.
        CONDENSE ls_response-invoicingparty.
        CONDENSE ls_response-documentdate.
        CONDENSE ls_response-postingdate1.
        CONDENSE ls_response-postingdate2.
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
*        CONDENSE ls_response-accountingdocument.
        CONDENSE ls_response-taxamount.
        CONDENSE ls_response-totalamount.
        CONDENSE ls_response-unitprice.
        CONDENSE ls_response-taxrate.
        CONDENSE ls_response-sendflag.
        CONDENSE ls_response-documentheadertext.
        CONDENSE ls_response-taxamountheader.
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
      SELECT a~supplierinvoice,
             a~fiscalyear,
             a~invoicingparty,
             a~documentdate,
             a~postingdate,
             a~exchangerate,
             a~duecalculationbasedate,
             a~invoicegrossamount,
             a~createdbyuser,
             a~lastchangedbyuser,
             a~documentheadertext,
             a~companycode,
             a~documentcurrency,
             b~suppliername,
             c~supplierinvoiceitem,
             c~purchaseorder,
             c~purchaseorderitem,
             c~debitcreditcode,
             c~purchaseorderitemmaterial,
             c~purchaseorderquantityunit,
             c~quantityinpurchaseorderunit,
*             c~documentcurrency,
             c~supplierinvoiceitemamount,
             d~postingdate AS postingdate_item,
             e~purchasinggroup,
             f~purchasinggroupname
        FROM i_supplierinvoiceapi01 WITH PRIVILEGED ACCESS AS a
        LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS b
        ON b~supplier = a~invoicingparty
        LEFT JOIN i_suplrinvcitempurordrefapi01 WITH PRIVILEGED ACCESS AS c
        ON c~supplierinvoice = a~supplierinvoice
        AND c~fiscalyear = a~fiscalyear
         LEFT JOIN i_materialdocumentheader_2 WITH PRIVILEGED ACCESS AS d
        ON d~materialdocumentyear = c~referencedocumentfiscalyear
        AND d~materialdocument    = c~referencedocument
        LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS e
        ON e~purchaseorder = c~purchaseorder
        LEFT JOIN i_purchasinggroup WITH PRIVILEGED ACCESS AS f
        ON f~purchasinggroup = e~purchasinggroup
        INTO TABLE @DATA(lt_supplier_invoice3).

      DATA(lt_supplier_invoice4) = lt_supplier_invoice3[].
      IF lt_supplier_invoice4 IS NOT INITIAL.
        SORT lt_supplier_invoice4 BY supplierinvoice fiscalyear DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_supplier_invoice4 COMPARING supplierinvoice fiscalyear purchaseorder purchaseorderitem.
      ENDIF.

      " 从 I_SupplierInvoiceTaxAPI01 表获取数据
      SELECT supplierinvoice,
             fiscalyear,
             supplierinvoicetaxcounter,
             taxcode,
             taxamount
        FROM i_supplierinvoicetaxapi01 WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_supplier_invoice4
        WHERE supplierinvoice = @lt_supplier_invoice4-supplierinvoice
          AND fiscalyear = @lt_supplier_invoice4-fiscalyear
        INTO TABLE @DATA(lt_tax2).

      IF lt_tax2 IS NOT INITIAL.
        SORT lt_tax2 BY supplierinvoice fiscalyear DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_tax2 COMPARING supplierinvoice fiscalyear.
      ENDIF.

      " 判空
      IF lt_supplier_invoice3 IS INITIAL.
        lv_error = 'X'.
        lv_text = 'No data found in I_SuplrInvcItemPurOrdRefAPI01'.
        " Handle the error
      ELSE.
        " 排序
        SORT lt_supplier_invoice3 BY supplierinvoice fiscalyear purchaseorder supplierinvoiceitem.

        " 去重
        DELETE ADJACENT DUPLICATES FROM lt_supplier_invoice3 COMPARING supplierinvoice fiscalyear purchaseorder supplierinvoiceitem.
      ENDIF.

      IF lt_supplier_invoice3 IS NOT INITIAL.

        " 从 I_PurOrdAccountAssignmentAPI01 表获取数据
        SELECT purchaseorder,
               purchaseorderitem,
               costcenter,
               glaccount
          FROM i_purordaccountassignmentapi01 WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_supplier_invoice4
          WHERE purchaseorder = @lt_supplier_invoice4-purchaseorder
            AND purchaseorderitem = @lt_supplier_invoice4-purchaseorderitem
          INTO TABLE @DATA(lt_acct_assgmt2).
      ENDIF.

      " 判空
      IF lt_acct_assgmt2 IS INITIAL.
        lv_error = 'X'.
        lv_text = 'No data found in i_purordaccountassignmentapi01'.
        " Handle the error
      ELSE.
        " 排序
        SORT lt_acct_assgmt2 BY purchaseorder purchaseorderitem.

        " 去重
        DELETE ADJACENT DUPLICATES FROM lt_acct_assgmt2 COMPARING purchaseorder purchaseorderitem.
      ENDIF.

      IF lt_supplier_invoice3 IS NOT INITIAL.
        " 从 I_PurchaseOrderItemAPI01 表获取数据
        SELECT purchaseorder,
               purchaseorderitem,
               purchaseorderitemtext,
               requisitionername,
               requirementtracking,
               plant,
               netpriceamount,
               netpricequantity
          FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_supplier_invoice4
          WHERE purchaseorder = @lt_supplier_invoice4-purchaseorder
            AND purchaseorderitem = @lt_supplier_invoice4-purchaseorderitem
          INTO TABLE @DATA(lt_po_item2).
      ENDIF.

      " 判空
      IF lt_po_item2 IS NOT INITIAL.
        SORT lt_po_item2 BY purchaseorder purchaseorderitem.
        DELETE ADJACENT DUPLICATES FROM lt_po_item2 COMPARING purchaseorder purchaseorderitem.
      ENDIF.

      DATA:
        lt_result TYPE STANDARD TABLE OF ty_response,
        lw_result TYPE ty_response.

      LOOP AT lt_supplier_invoice3 INTO DATA(lw_supplier_invoice3).

        lw_result-supplierinvoice             = lw_supplier_invoice3-supplierinvoice.
        lw_result-fiscalyear                  = lw_supplier_invoice3-fiscalyear.
        lw_result-postingdate2                = lw_supplier_invoice3-postingdate.
        lw_result-supplierinvoiceitem         = lw_supplier_invoice3-supplierinvoiceitem.
        lw_result-purchaseorder               = lw_supplier_invoice3-purchaseorder.
        lw_result-purchaseorderitem           = lw_supplier_invoice3-purchaseorderitem.
        lw_result-debitcreditcode             = lw_supplier_invoice3-debitcreditcode.
        lw_result-purchaseorderitemmaterial   = lw_supplier_invoice3-purchaseorderitemmaterial.
        lw_result-purchaseorderquantityunit   = lw_supplier_invoice3-purchaseorderquantityunit.
        lw_result-quantityinpurchaseorderunit = lw_supplier_invoice3-quantityinpurchaseorderunit.
        lw_result-documentcurrency            = lw_supplier_invoice3-documentcurrency.
        lw_result-supplierinvoiceitemamount   = lw_supplier_invoice3-supplierinvoiceitemamount.
        lw_result-purchasinggroup             = lw_supplier_invoice3-purchasinggroup.
        lw_result-purchasinggroupname         = lw_supplier_invoice3-purchasinggroupname.
        lw_result-postingdate1                = lw_supplier_invoice3-postingdate_item.
        lw_result-suppliername                = lw_supplier_invoice3-suppliername.
        lw_result-invoicingparty              = lw_supplier_invoice3-invoicingparty.
        lw_result-documentdate                = lw_supplier_invoice3-documentdate.
        lw_result-exchangerate                = lw_supplier_invoice3-exchangerate.
        lw_result-duecalculationbasedate      = lw_supplier_invoice3-duecalculationbasedate.
        lw_result-invoicegrossamount          = lw_supplier_invoice3-invoicegrossamount.
        lw_result-createdbyuser               = lw_supplier_invoice3-createdbyuser.
        lw_result-lastchangedbyuser           = lw_supplier_invoice3-lastchangedbyuser.
        lw_result-documentheadertext          = lw_supplier_invoice3-documentheadertext.
        lw_result-companycode                 = lw_supplier_invoice3-companycode.

        SORT lt_tax2 BY supplierinvoice fiscalyear DESCENDING.
        READ TABLE lt_tax2 INTO DATA(lw_tax2) WITH KEY supplierinvoice = lw_result-supplierinvoice
                                                            fiscalyear = lw_result-fiscalyear
                                                            BINARY SEARCH.
        IF sy-subrc = 0.

          SELECT SINGLE zvalue2
            FROM ztbc_1001
            WHERE zid = 'ZMM001'
            AND zvalue1 = @lw_tax2-taxcode
            INTO @DATA(lv_value2_2).

          lw_result-supplierinvoicetaxcounter = lw_tax2-supplierinvoicetaxcounter.
          lw_result-taxcode                   = lw_tax2-taxcode.
          lw_result-taxamountheader           = lw_tax2-taxamount.
          lw_result-taxrate                   = lv_value2_2.
          lv_rate = lv_value2_2 / 100.

        ENDIF.

        READ TABLE lt_supplier_invoice3 INTO DATA(ls_supplier_invoice3) WITH KEY supplierinvoice     = lw_result-supplierinvoice
                                                                                 fiscalyear          = lw_result-fiscalyear
                                                                                 purchaseorder       = lw_result-purchaseorder
                                                                                 purchaseorderitem   = lw_result-purchaseorderitem
                                                                                 supplierinvoiceitem = lw_result-supplierinvoiceitem
                                                                                 BINARY SEARCH.
        IF sy-subrc = 0.
          lw_result-taxamount                   = ls_supplier_invoice3-supplierinvoiceitemamount * lv_rate.
          lw_result-totalamount                 = ls_supplier_invoice3-supplierinvoiceitemamount + lw_result-taxamount.
        ENDIF.

        " 将 lw_result 添加到结果表中
        APPEND lw_result TO lt_result.
      ENDLOOP.

      SORT lt_result BY purchaseorder purchaseorderitem DESCENDING.
      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lw_result>).

        READ TABLE lt_acct_assgmt2 INTO DATA(lw_acct_assgmt2) WITH KEY purchaseorder = <lw_result>-purchaseorder
                                                                       purchaseorderitem = <lw_result>-purchaseorderitem
                                                                       BINARY SEARCH.
        IF sy-subrc = 0.
          <lw_result>-costcenter = lw_acct_assgmt2-costcenter.
          <lw_result>-glaccount  = lw_acct_assgmt2-glaccount.
        ENDIF.

        READ TABLE lt_po_item2 INTO DATA(lw_po_item2) WITH KEY purchaseorder     = <lw_result>-purchaseorder
                                                               purchaseorderitem = <lw_result>-purchaseorderitem
                                                               BINARY SEARCH.
        IF sy-subrc = 0.
          <lw_result>-purchaseorderitemtext = lw_po_item2-purchaseorderitemtext.
          <lw_result>-requisitionername     = lw_po_item2-requisitionername.
          <lw_result>-requirementtracking   = lw_po_item2-requirementtracking.
          <lw_result>-plant                 = lw_po_item2-plant.

          " 检查 NetPriceQuantity 是否为零，避免除零错误
          IF lw_po_item2-netpricequantity <> 0.
            <lw_result>-unitprice = lw_po_item2-netpriceamount / lw_po_item2-netpricequantity.
          ELSE.
            <lw_result>-unitprice = 0. " 如果数量为 0，可以根据业务需求设定默认值
          ENDIF.

        ENDIF.

      ENDLOOP.

      "uweb 接口
      zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |http://220.248.121.53:11380/srv/odata/v2/TableService/PCH_T04_PAYMENT_H|
                                                              iv_client_id     = CONV #( 'Tom' )
                                                              iv_client_secret = CONV #( '1' )
                                                             iv_authtype      = 'Basic'
                                                    IMPORTING ev_status_code   = DATA(lv_status_code_uweb1)
                                                              ev_response      = DATA(lv_response_uweb1) ).
      IF lv_status_code_uweb1 = 200.
        xco_cp_json=>data->from_string( lv_response_uweb1 )->apply( VALUE #(
*            ( xco_cp_json=>transformation->pascal_case_to_underscore )
          ( xco_cp_json=>transformation->boolean_to_abap_bool )
        ) )->write_to( REF #( ls_maxinvoice ) ).

        IF ls_maxinvoice-d-results IS NOT INITIAL.

          APPEND LINES OF ls_maxinvoice-d-results TO lt_uweb_api.

        ENDIF.

      ENDIF.

      SORT lt_uweb_api BY gl_year inv_no DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_uweb_api COMPARING gl_year inv_no.

      "获取supplierinvoice最大的记录
      READ TABLE lt_uweb_api INDEX 1 INTO DATA(lw_versionmax1).

      SORT lt_result BY supplierinvoice fiscalyear DESCENDING.

      " 删除 supplierinvoice 小于 lw_versionmax-inv_no 的数据
*      DELETE lt_result WHERE supplierinvoice < lw_versionmax1-inv_no.
      DELETE lt_result WHERE supplierinvoice < lw_versionmax1-inv_no.

      " 删除 supplierinvoiceitem 为空且 taxamountheader 不等于 '仮払消費税調整' 的数据
      DELETE lt_result WHERE supplierinvoiceitem IS INITIAL OR supplierinvoiceitem = '000000'
                          AND documentheadertext <> '仮払消費税調整'.

      " 合并数据
      LOOP AT lt_result INTO lw_result.

        DATA(lv_unit2) = lw_result-purchaseorderquantityunit.
        DATA(lv_unit22) = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = lv_unit2 ).

        ls_response-documentheadertext                   = lw_result-documentheadertext.
        ls_response-suppliername                         = lw_result-suppliername.
        ls_response-supplierinvoice                      = lw_result-supplierinvoice.
        ls_response-fiscalyear                           = lw_result-fiscalyear.
        " 去除前导零
        SHIFT lw_result-invoicingparty LEFT DELETING LEADING '0'.
        ls_response-invoicingparty                       = lw_result-invoicingparty.
        ls_response-documentdate                         = lw_result-documentdate.
        IF lw_result-postingdate1 = '00000000'.
          ls_response-postingdate1 = space.
        ELSE.
          ls_response-postingdate1                         = lw_result-postingdate1.
        ENDIF.

        IF lw_result-postingdate2 = '00000000'.
          ls_response-postingdate2 = space.
        ELSE.
          ls_response-postingdate2                         = lw_result-postingdate2.
        ENDIF.

        ls_response-exchangerate                         = lw_result-exchangerate.
        ls_response-duecalculationbasedate               = lw_result-duecalculationbasedate.
        ls_response-invoicegrossamount                   = lw_result-invoicegrossamount.
        ls_response-createdbyuser                        = lw_result-createdbyuser.
        ls_response-lastchangedbyuser                    = lw_result-lastchangedbyuser.
        ls_response-supplierinvoicetaxcounter            = lw_result-debitcreditcode.
        ls_response-taxcode                              = lw_result-taxcode.
        ls_response-taxamount                            = lw_result-debitcreditcode.
        IF lw_result-supplierinvoiceitem IS INITIAL OR lw_result-supplierinvoiceitem = '000000' AND lw_result-documentheadertext = '仮払消費税調整'.
          ls_response-supplierinvoiceitem = '1'.
        ELSE.
          ls_response-supplierinvoiceitem                  = lw_result-supplierinvoiceitem.
        ENDIF.
        " 去除前导零
        SHIFT lw_result-purchaseorder LEFT DELETING LEADING '0'.
        ls_response-purchaseorder                        = lw_result-purchaseorder.
        ls_response-purchaseorderitem                    = lw_result-purchaseorderitem.
        ls_response-debitcreditcode                      = lw_result-debitcreditcode.
        ls_response-purchaseorderitemmaterial            = lw_result-purchaseorderitemmaterial.
        ls_response-documentcurrency                     = lw_result-documentcurrency.
        ls_response-supplierinvoiceitemamount            = lw_result-supplierinvoiceitemamount.
        ls_response-taxrate                              = lw_result-taxrate.
        ls_response-quantityinpurchaseorderunit          = lw_result-quantityinpurchaseorderunit.
        ls_response-purchaseorderquantityunit            = lv_unit22.
        ls_response-costcenter                           = lw_result-costcenter.
        ls_response-glaccount                            = lw_result-glaccount.
        ls_response-purchaseorderitemtext                = lw_result-purchaseorderitemtext.
        ls_response-requisitionername                    = lw_result-requisitionername.
        ls_response-requirementtracking                  = lw_result-requirementtracking.
        ls_response-plant                                = lw_result-plant.
        ls_response-purchasinggroup                      = lw_result-purchasinggroup.
        ls_response-companycode                          = lw_result-companycode.
        ls_response-purchasinggroupname                  = lw_result-purchasinggroupname.
*      ls_response-accountingdocument                   = lw_result-accountingdocument.
        ls_response-taxamount                            = lw_result-taxamount.
        CONDENSE lw_result-totalamount.
        ls_response-totalamount                          = lw_result-totalamount.
        CONDENSE lw_result-unitprice.
        ls_response-unitprice                            = lw_result-unitprice.
        ls_response-sendflag                             = '1'.
        ls_response-taxamountheader                      = lw_result-taxamountheader.

        DATA lv_taxamount2        TYPE p LENGTH 10 DECIMALS 2.
        DATA lv_totalamount2      TYPE p LENGTH 10 DECIMALS 2.
        DATA lv_netpriceamount2   TYPE p LENGTH 10 DECIMALS 5.
        DATA lv_unit_price_jpy2   TYPE p LENGTH 10 DECIMALS 3.
        DATA lv_taxamount_jpy2    TYPE p LENGTH 10 DECIMALS 5.

        CASE lw_result-documentcurrency.
          WHEN 'JPY'.
            " 保留 3 位小数，四舍五入
            lv_netpriceamount2  = lw_result-unitprice * 100.
            lv_unit_price_jpy2 = round( val = lv_netpriceamount2 dec = 3 ).
            ls_response-unitprice = lv_unit_price_jpy2.

            " 舍弃小数部分，取整
            CONDENSE lw_result-taxamount.
            lv_taxamount2 = lw_result-taxamount * 100.
            lv_taxamount_jpy2 = floor( lv_taxamount2 ).
            ls_response-taxamount = lv_taxamount_jpy2.
            ls_response-supplierinvoiceitemamount = lw_result-supplierinvoiceitemamount * 100.
            ls_response-totalamount  = lw_result-totalamount * 100.
            ls_response-invoicegrossamount  = lw_result-invoicegrossamount * 100.
            ls_response-taxamountheader     = lw_result-taxamountheader * 100.

            ls_response-totalamount        = ls_response-supplierinvoiceitemamount + ls_response-taxamount.

          WHEN 'USD'.
            " 保留 5 位小数，四舍五入
            DATA(lv_unit_price_usd2) = round( val = lw_result-unitprice dec = 5 ).
            ls_response-unitprice = lv_unit_price_usd2.

            " 保留 2 位小数，舍弃其他位数
            lv_taxamount2 = floor( lw_result-taxamount * 100 ) / 100.
            ls_response-taxamount = lv_taxamount2.

            " 保留 2 位小数，四舍五入
            lv_totalamount2 = floor( lw_result-totalamount * 100 ) / 100.
            ls_response-totalamount = lv_totalamount2.

          WHEN 'EUR'.
            " 保留 5 位小数，四舍五入
            DATA(lv_unit_price_eur2) = round( val = lw_result-unitprice dec = 5 ).
            ls_response-unitprice = lv_unit_price_eur2.

            " 乘以 100，取整后再除以 100，保留 2 位小数
            lv_taxamount2 = floor( lw_result-taxamount * 100 ) / 100.
            " 保留 2 位小数，舍弃其他位数
            ls_response-taxamount = lv_taxamount2.

            " 保留 2 位小数，四舍五入
            lv_totalamount2 = floor( lw_result-totalamount * 100 ) / 100.
            ls_response-totalamount = lv_totalamount2.

          WHEN OTHERS.
            ls_response-taxamount   = lw_result-taxamount.
            ls_response-totalamount = lw_result-totalamount.
            ls_response-unitprice   = lw_result-unitprice.
        ENDCASE.

        CONDENSE ls_response-suppliername.
        CONDENSE ls_response-supplierinvoice.
        CONDENSE ls_response-fiscalyear.
        CONDENSE ls_response-invoicingparty.
        CONDENSE ls_response-documentdate.
        CONDENSE ls_response-postingdate1.
        CONDENSE ls_response-postingdate2.
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
*      CONDENSE ls_response-accountingdocument.
        CONDENSE ls_response-taxamount.
        CONDENSE ls_response-totalamount.
        CONDENSE ls_response-unitprice.
        CONDENSE ls_response-taxrate.
        CONDENSE ls_response-sendflag.
        CONDENSE ls_response-documentheadertext.
        CONDENSE ls_response-taxamountheader.
        APPEND   ls_response TO es_response-items.

      ENDLOOP.
    ENDIF.

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
