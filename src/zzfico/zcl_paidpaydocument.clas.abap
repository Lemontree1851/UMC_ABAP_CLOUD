CLASS zcl_paidpaydocument DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_paidpaydocument IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TYPES:
      BEGIN OF ts_mrp,
        product        TYPE matnr,
        plant          TYPE werks_d,
        mrpresponsible TYPE dispo,
        sort           TYPE c LENGTH 20,
      END OF ts_mrp.

    DATA:
      lt_output       TYPE STANDARD TABLE OF zr_paidpaydocument,
      ls_output       TYPE zr_paidpaydocument,
      lt_mrp          TYPE STANDARD TABLE OF ts_mrp,
      ls_mrp          TYPE ts_mrp,
      lt_1013         TYPE STANDARD TABLE OF ztfi_1013,
      ls_1013         TYPE ztfi_1013,

      lr_sort         TYPE RANGE OF i_businesspartner-searchterm2,
      lrs_sort        LIKE LINE OF lr_sort,
      lr_plant        TYPE RANGE OF werks_d,
      lrs_plant       LIKE LINE OF lr_plant,
      lr_blart_kunnr  TYPE RANGE OF blart,
      lrs_blart_kunnr LIKE LINE OF lr_blart_kunnr,
      lr_blart_lifnr  TYPE RANGE OF blart,
      lrs_blart_lifnr LIKE LINE OF lr_blart_lifnr.

    DATA:
      lv_amount(9)        TYPE p DECIMALS 2,
      lv_rate(9)          TYPE p DECIMALS 2,
      lv_fiscalyearperiod TYPE i_fiscalyearperiodforvariant-fiscalyearperiod,
      lv_poper            TYPE poper,
      lv_year             TYPE c LENGTH 4,
      lv_month            TYPE monat,
      lv_length           TYPE i,
      lv_length1          TYPE i,
      lv_length2          TYPE i.

* Get filter range
    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          CASE ls_filter_cond-name.
            WHEN 'COMPANYCODE'.
              DATA(lr_bukrs) = ls_filter_cond-range.
              READ TABLE lr_bukrs INTO DATA(lrs_bukrs) INDEX 1.
              DATA(lv_bukrs) = lrs_bukrs-low.
            WHEN 'FISCALYEAR'.
              DATA(lr_gjahr) = ls_filter_cond-range.
              READ TABLE lr_gjahr INTO DATA(lrs_gjahr) INDEX 1.
              DATA(lv_gjahr) = lrs_gjahr-low.
            WHEN 'PERIOD'.
              DATA(lr_monat) = ls_filter_cond-range.
              READ TABLE lr_monat INTO DATA(lrs_monat) INDEX 1.
              DATA(lv_monat) = lrs_monat-low.
            WHEN 'ZTYPE'.
              DATA(lr_ztype) = ls_filter_cond-range.
              READ TABLE lr_ztype INTO DATA(lrs_ztype) INDEX 1.
              DATA(lv_ztype) = lrs_ztype-low.
          ENDCASE.
        ENDLOOP.
      CATCH cx_rap_query_filter_no_range.
        "handle exception
        io_response->set_data( lt_output ).
    ENDTRY.

    CASE lv_ztype.
      WHEN 'A'.          "売上/仕入純額処理
        SELECT *
          FROM ztfi_1011
         WHERE companycode = @lv_bukrs
           AND fiscalyear = @lv_gjahr
           AND period = @lv_monat
          INTO TABLE @DATA(lt_1011).

        LOOP AT lt_1011 INTO DATA(ls_1011).
          ls_output-companycode = ls_1011-companycode.  "会社コード
          ls_output-fiscalyear = ls_1011-fiscalyear.    "会計年度
          ls_output-period = ls_1011-period.            "会計期間
          ls_output-customer = ls_1011-customer.        "得意先コード
          ls_output-supplier = ls_1011-supplier. "仕入先コード
          ls_output-ztype = lv_ztype.
          ls_output-profitcenter = ls_1011-profitcenter. "利益センタ
          ls_output-purchasinggroup = ls_1011-purchasinggroup.  "購買グループ
          ls_output-customername = ls_1011-customername.   "得意先名称
          ls_output-suppliername = ls_1011-suppliername.   "仕入先名称
          ls_output-profitcentername = ls_1011-profitcentername.  "利益センタテキスト
          ls_output-purgrpamount = ls_1011-purgrpamount. "当期購買グループ別仕入金額
          ls_output-chargeableamount = ls_1011-chargeableamount. "当期有償支給品仕入金額
          lv_rate = ls_1011-chargeablerate * 100.
          ls_output-chargeablerate = lv_rate.  "当期仕入率
          CONDENSE ls_output-chargeablerate.
          ls_output-previousstockamount = ls_1011-previousstocktotal. "在庫金額（前期末）
          ls_output-currentstockamount = ls_1011-currentstockpaid. "在庫金額（当期末）-有償支給品
          ls_output-currentstocksemi = ls_1011-currentstocksemi.  "在庫金額（当期末）-半製品
          ls_output-currentstockfin = ls_1011-currentstockfin.  "在庫金額（当期末）-製品
          ls_output-currentstocktotal = ls_1011-currentstocktotal.  "在庫金額（当期末）-合計
          ls_output-stockchangeamount = ls_1011-stockchangeamount. "在庫増減金額
          ls_output-paidmaterialcost = ls_1011-paidmaterialcost.  "払いだし材料費
          ls_output-customerrevenue = ls_1011-customerrevenue.  "該当得意先の総売上高
          ls_output-revenue = ls_1011-revenue.  "会社レベルの総売上高
          lv_rate = ls_1011-revenuerate * 100.
          ls_output-revenuerate = lv_rate.  "総売上金額占有率
          CONDENSE ls_output-revenuerate.
          ls_output-currency = ls_1011-currency.
          ls_output-gjahr1 = ls_1011-gjahr1.
          ls_output-belnr1 = ls_1011-belnr1.
          ls_output-gjahr2 = ls_1011-gjahr2.
          ls_output-belnr2 = ls_1011-belnr2.
          ls_output-gjahr3 = ls_1011-gjahr3.
          ls_output-belnr3 = ls_1011-belnr3.
          ls_output-gjahr4 = ls_1011-gjahr4.
          ls_output-belnr4 = ls_1011-belnr4.
          ls_output-status = ls_1011-status.
          ls_output-message = ls_1011-message.
          APPEND ls_output TO lt_output.
          CLEAR: ls_output.
        ENDLOOP.

      WHEN 'B'.          "買掛金/売掛金純額処理
        SELECT valuationarea
          FROM i_valuationarea WITH PRIVILEGED ACCESS
         WHERE companycode = @lv_bukrs
          INTO TABLE @DATA(lt_plant).

        LOOP AT lt_plant INTO DATA(ls_plant).
          lrs_plant-sign = 'I'.
          lrs_plant-option = 'EQ'.
          lrs_plant-low = ls_plant-valuationarea.
          APPEND lrs_plant TO lr_plant.
          CLEAR: lrs_plant.
        ENDLOOP.

* 2.02 Get matnr
        SELECT product,
               plant
          FROM i_productplantbasic WITH PRIVILEGED ACCESS
         WHERE plant IN @lr_plant
          INTO TABLE @DATA(lt_product).

        "Filter 品目コードの最後4桁固定「：**2」
        LOOP AT lt_product INTO DATA(ls_product).
          lv_length = strlen( ls_product-product ).
          lv_length1 = lv_length - 1.
          lv_length2 = lv_length - 4.

          IF ls_product-product+lv_length1(1) = '2'
         AND ( lv_length2 >= 0
           AND ls_product-product+lv_length2(1) = ':' ).
          ELSE.
            DELETE lt_product.
            CONTINUE.
          ENDIF.
        ENDLOOP.

        IF lt_product IS NOT INITIAL.
          SELECT product
            FROM i_product
            FOR ALL ENTRIES IN @lt_product
           WHERE product = @lt_product-product
             AND producttype = 'ZROH'
            INTO TABLE @DATA(lt_mara).

          SORT lt_mara BY product.
          LOOP AT lt_product INTO ls_product.
            READ TABLE lt_mara WITH KEY product = ls_product-product
                               BINARY SEARCH TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              DELETE lt_product.
              CONTINUE.
            ENDIF.
          ENDLOOP.
        ENDIF.

* 2.03 Get last 2 characters of mrpresponsible
        IF lt_product IS NOT INITIAL.
          SELECT product,
                 plant,
                 mrpresponsible
            FROM i_productplantbasic WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_product
           WHERE plant IN @lr_plant
             AND product = @lt_product-product
            INTO TABLE @lt_mrp.
        ENDIF.

        LOOP AT lt_mrp ASSIGNING FIELD-SYMBOL(<lfs_mrp>).
          DATA(lv_len) = strlen( <lfs_mrp>-mrpresponsible ) - 2.
          IF lv_len < 0.
            CONTINUE.
          ENDIF.
          lrs_sort-sign = 'I'.
          lrs_sort-option = 'EQ'.
          lrs_sort-low = <lfs_mrp>-mrpresponsible+lv_len(2).
          APPEND lrs_sort TO lr_sort.
          CLEAR: lrs_sort.
        ENDLOOP.

        IF lr_sort IS NOT INITIAL.
          SELECT businesspartner,
                 businesspartnername,
                 searchterm2
            FROM i_businesspartner WITH PRIVILEGED ACCESS
           WHERE searchterm2 IN @lr_sort
            INTO TABLE @DATA(lt_bp).
        ENDIF.

        IF lt_bp IS NOT INITIAL.
          SELECT customer,   "#EC CI_NO_TRANSFORM
                 companycode
            FROM i_customercompany WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_bp
           WHERE customer = @lt_bp-businesspartner
             AND companycode = @lv_bukrs
            INTO TABLE @DATA(lt_kunnr).
        ENDIF.

        IF lt_kunnr IS NOT INITIAL.
          SELECT supplier,     "#EC CI_NO_TRANSFORM
                 companycode
            FROM i_suppliercompany
            FOR ALL ENTRIES IN @lt_kunnr
           WHERE supplier = @lt_kunnr-customer
             AND companycode = @lv_bukrs
            INTO TABLE @DATA(lt_lifnr).
        ENDIF.

* V3 会计期间转换
        lv_poper = lv_monat.
        lv_fiscalyearperiod = lv_gjahr && lv_poper.
        IF lv_fiscalyearperiod IS NOT INITIAL.
          SELECT SINGLE *                     "#EC CI_ALL_FIELDS_NEEDED
            FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
           WHERE fiscalyearvariant = 'V3'
             AND fiscalyearperiod = @lv_fiscalyearperiod
            INTO @DATA(ls_v3).
        ENDIF.

        SELECT *
          FROM ztbc_1001
         WHERE ( zid = 'ZFI008' OR zid = 'ZFI009' )
           AND zvalue1 = @lv_bukrs
          INTO TABLE @DATA(lt_1001).          "#EC CI_ALL_FIELDS_NEEDED
        LOOP AT lt_1001 INTO DATA(ls_1001).
          IF ls_1001-zid = 'ZFI008'.  "customer
            lrs_blart_kunnr-sign = 'I'.
            lrs_blart_kunnr-option = 'EQ'.
            lrs_blart_kunnr-low = ls_1001-zvalue2.
            APPEND lrs_blart_kunnr TO lr_blart_kunnr.
            CLEAR: lrs_blart_kunnr.
          ENDIF.

          IF ls_1001-zid = 'ZFI009'.  "supplier
            lrs_blart_lifnr-sign = 'I'.
            lrs_blart_lifnr-option = 'EQ'.
            lrs_blart_lifnr-low = ls_1001-zvalue2.
            APPEND lrs_blart_lifnr TO lr_blart_lifnr.
            CLEAR: lrs_blart_lifnr.
          ENDIF.
        ENDLOOP.

        IF lt_kunnr IS NOT INITIAL.
* 売掛金の金額
          SELECT sourceledger,
                 companycode,
                 fiscalyear,
                 accountingdocument,
                 ledgergllineitem,
                 ledger,
                 glaccount,
                 profitcenter,
                 companycodecurrency,
                 amountincompanycodecurrency,
                 customer,
                 fiscalperiod,
                 postingdate
            FROM i_journalentryitem WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_kunnr
           WHERE sourceledger = '0L'
             AND companycode = @lv_bukrs
             AND accountingdocumenttype IN @lr_blart_kunnr
             AND ( ( fiscalyear = @lv_gjahr AND fiscalperiod <= @lv_monat )
                 OR fiscalyear < @lv_gjahr )
             AND ledger = '0L'
             AND customer = @lt_kunnr-customer
            INTO TABLE @DATA(lt_bseg_ar).          "#EC CI_NO_TRANSFORM
        ENDIF.

        IF lt_lifnr IS NOT INITIAL.
* 買掛金の金額
          SELECT sourceledger,
                 companycode,
                 fiscalyear,
                 accountingdocument,
                 ledgergllineitem,
                 ledger,
                 glaccount,
                 profitcenter,
                 companycodecurrency,
                 amountincompanycodecurrency,
                 supplier,
                 fiscalperiod,
                 postingdate
            FROM i_journalentryitem WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_lifnr
           WHERE sourceledger = '0L'
             AND companycode = @lv_bukrs
             AND accountingdocumenttype IN @lr_blart_lifnr
             AND ( ( fiscalyear = @lv_gjahr AND fiscalperiod <= @lv_monat )
                 OR fiscalyear < @lv_gjahr )
             AND ledger = '0L'
             AND supplier = @lt_lifnr-supplier
            INTO TABLE @DATA(lt_bseg_ap).          "#EC CI_NO_TRANSFORM
        ENDIF.

        SORT lt_bseg_ar BY companycode fiscalyear customer.
        SORT lt_bp BY businesspartner.
        " Sum AR
        LOOP AT lt_bseg_ar INTO DATA(ls_ar)
                      GROUP BY ( companycode = ls_ar-companycode
                                 fiscalyear = ls_ar-fiscalyear
                                 cutomer = ls_ar-customer )
                      REFERENCE INTO DATA(member_ar).
          LOOP AT GROUP member_ar ASSIGNING FIELD-SYMBOL(<lfs_ar>).
            lv_amount = lv_amount + <lfs_ar>-amountincompanycodecurrency.
          ENDLOOP.
          ls_1013-client = sy-mandt.
          ls_1013-companycode = <lfs_ar>-companycode.
          ls_1013-fiscalyear = <lfs_ar>-fiscalyear.
          ls_1013-period = lv_monat.
          ls_1013-customer = <lfs_ar>-customer.
          ls_1013-currency = <lfs_ar>-companycodecurrency.
          ls_1013-ar = lv_amount.
          READ TABLE lt_bp INTO DATA(ls_bp)
               WITH KEY businesspartner = <lfs_ar>-customer BINARY SEARCH.
          IF sy-subrc = 0.
            ls_1013-customername = ls_bp-businesspartnername.
          ENDIF.
          APPEND ls_1013 TO lt_1013.
          CLEAR: ls_1013, lv_amount.
        ENDLOOP.

        SORT lt_bseg_ap BY companycode fiscalyear supplier.
        SORT lt_1013 BY companycode fiscalyear customer.
        " Sum AP
        LOOP AT lt_bseg_ap INTO DATA(ls_ap)
                      GROUP BY ( companycode = ls_ap-companycode
                                 fiscalyear = ls_ap-fiscalyear
                                 supplier = ls_ap-supplier )
                      REFERENCE INTO DATA(member_ap).
          LOOP AT GROUP member_ap ASSIGNING FIELD-SYMBOL(<lfs_ap>).
            lv_amount = lv_amount + <lfs_ap>-amountincompanycodecurrency.
          ENDLOOP.

          READ TABLE lt_1013 ASSIGNING FIELD-SYMBOL(<lfs_1013>)
               WITH KEY companycode = <lfs_ap>-companycode
                        fiscalyear = <lfs_ap>-fiscalyear
                        customer = <lfs_ap>-supplier BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_1013>-supplier = <lfs_ap>-supplier.
            READ TABLE lt_bp INTO ls_bp
                 WITH KEY businesspartner = <lfs_ap>-supplier BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_1013>-suppliername = ls_bp-businesspartnername.
            ENDIF.
            <lfs_1013>-ap = lv_amount.
          ELSE.
            ls_1013-client = sy-mandt.
            ls_1013-companycode = <lfs_ap>-companycode.
            ls_1013-fiscalyear = <lfs_ap>-fiscalyear.
            ls_1013-period = lv_monat.
            ls_1013-supplier = <lfs_ap>-supplier.
            ls_1013-currency = <lfs_ap>-companycodecurrency.
            ls_1013-ap = lv_amount.
            READ TABLE lt_bp INTO ls_bp
                 WITH KEY businesspartner = <lfs_ap>-supplier BINARY SEARCH.
            IF sy-subrc = 0.
              ls_1013-suppliername = ls_bp-businesspartnername.
            ENDIF.
            APPEND ls_1013 TO lt_1013.
          ENDIF.
          CLEAR: ls_1013, lv_amount.
        ENDLOOP.

        SELECT *
          FROM ztfi_1013
         WHERE companycode = @lv_bukrs
           AND fiscalyear = @lv_gjahr
           AND period = @lv_monat
          INTO TABLE @DATA(lt_table).

        SORT lt_table BY companycode fiscalyear period customer supplier.
        "Edit output
        LOOP AT lt_1013 INTO ls_1013.
          READ TABLE lt_table INTO DATA(ls_table)
               WITH KEY companycode = ls_1013-companycode
                        fiscalyear = ls_1013-fiscalyear
                        period = ls_1013-period
                        customer = ls_1013-customer
                        supplier = ls_1013-supplier BINARY SEARCH.
          IF sy-subrc <> 0.
            "新数据，在点击过账后更新进addon表，因为在query中无法对addon table使用增删改
            ls_output-ztype = lv_ztype.
            ls_output-companycode = ls_1013-companycode.
            ls_output-fiscalyear = ls_1013-fiscalyear.
            ls_output-period = ls_1013-period.
            ls_output-customer = ls_1013-customer.
            ls_output-supplier = ls_1013-supplier.
            ls_output-customername = ls_1013-customername.
            ls_output-suppliername = ls_1013-suppliername.
            ls_output-ar = ls_1013-ar.
            ls_output-ar = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'OUT'
                                                         iv_currency = ls_1013-currency
                                                         iv_input = ls_1013-ar ).
            CONDENSE ls_output-ar NO-GAPS.
            "AP取反
            ls_1013-ap = -1 * ls_1013-ap.
            ls_output-ap = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'OUT'
                                                         iv_currency = ls_1013-currency
                                                         iv_input = ls_1013-ap ).
            CONDENSE ls_output-ap NO-GAPS.
            ls_output-currency = ls_1013-currency.
            ls_output-belnr5 = ls_1013-belnr1.
            ls_output-gjahr5 = ls_1013-gjahr1.
            ls_output-belnr6 = ls_1013-belnr2.
            ls_output-gjahr6 = ls_1013-gjahr2.
            ls_output-belnr7 = ls_1013-belnr3.
            ls_output-gjahr7 = ls_1013-gjahr3.
            ls_output-belnr8 = ls_1013-belnr4.
            ls_output-gjahr8 = ls_1013-gjahr4.
            APPEND ls_output TO lt_output.
          ELSE.
            "如果addon表中已存在，用addon表的数据
            MOVE-CORRESPONDING ls_table TO ls_output.
            ls_output-ar = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'OUT'
                                                         iv_currency = ls_1013-currency
                                                         iv_input = ls_table-ar ).
            CONDENSE ls_output-ar NO-GAPS.
            ls_output-ap = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'OUT'
                                                         iv_currency = ls_1013-currency
                                                         iv_input = ls_table-ap ).
            CONDENSE ls_output-ap NO-GAPS.
            ls_output-ztype = lv_ztype.
            ls_output-currency = ls_table-currency.
            ls_output-belnr5 = ls_table-belnr1.
            ls_output-gjahr5 = ls_table-gjahr1.
            ls_output-belnr6 = ls_table-belnr2.
            ls_output-gjahr6 = ls_table-gjahr2.
            ls_output-belnr7 = ls_table-belnr3.
            ls_output-gjahr7 = ls_table-gjahr3.
            ls_output-belnr8 = ls_table-belnr4.
            ls_output-gjahr8 = ls_table-gjahr4.
            APPEND ls_output TO lt_output.
          ENDIF.
          CLEAR: ls_output.
        ENDLOOP.

        LOOP AT lt_output ASSIGNING FIELD-SYMBOL(<lfs_output>).
          lv_length = strlen( <lfs_output>-ar ) - 1.
          IF <lfs_output>-ar+lv_length(1) = '-'.
            <lfs_output>-ar = |{ <lfs_output>-ar+lv_length(1) }{ <lfs_output>-ar(lv_length) }|.
          ENDIF.

          lv_length = strlen( <lfs_output>-ap ) - 1.
          IF <lfs_output>-ap+lv_length(1) = '-'.
            <lfs_output>-ap = |{ <lfs_output>-ap+lv_length(1) }{ <lfs_output>-ap(lv_length) }|.
          ENDIF.

        ENDLOOP.
    ENDCASE.

    SORT lt_output BY companycode fiscalyear period customer supplier profitcenter purchasinggroup.
    " Filtering
    zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
                                 CHANGING  ct_data     = lt_output ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_output ) ).
    ENDIF.

    "Sort
    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                               CHANGING  ct_data  = lt_output ).

    " Paging
    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                              CHANGING  ct_data   = lt_output ).

    io_response->set_data( lt_output ).


  ENDMETHOD.
ENDCLASS.
