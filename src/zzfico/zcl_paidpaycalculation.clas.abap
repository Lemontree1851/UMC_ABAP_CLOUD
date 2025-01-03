CLASS zcl_paidpaycalculation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_paidpaycalculation IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    DATA:
      lt_output TYPE STANDARD TABLE OF zr_paidpaycalculation,
      ls_output TYPE zr_paidpaycalculation.
    DATA:
      lv_fiscalyearperiod TYPE i_fiscalyearperiodforvariant-fiscalyearperiod,
      lv_poper            TYPE poper,
      lv_rate(10)         TYPE p DECIMALS 2.

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
            WHEN 'LEDGE'.
              DATA(lr_ledge) = ls_filter_cond-range.
              READ TABLE lr_ledge INTO DATA(lrs_ledge) INDEX 1.
              DATA(lv_ledge) = lrs_ledge-low.
          ENDCASE.
        ENDLOOP.
      CATCH cx_rap_query_filter_no_range.
        "handle exception
        io_response->set_data( lt_output ).
    ENDTRY.

    CASE lv_ztype.
      WHEN 'A'.    "品番別
        SELECT *
          FROM ztfi_1010
         WHERE companycode = @lv_bukrs
           AND fiscalyear = @lv_gjahr
           AND period = @lv_monat
           AND ledge = @lv_ledge
          INTO TABLE @DATA(lt_1010).
        IF sy-subrc = 0.
          LOOP AT lt_1010 INTO DATA(ls_1010).
            ls_output-ztype = lv_ztype.
            ls_output-companycode = ls_1010-companycode.
            ls_output-fiscalyear = ls_1010-fiscalyear.
            ls_output-period = ls_1010-period.
            ls_output-customer = ls_1010-customer. "得意先コード
            ls_output-supplier = ls_1010-supplier. "仕入先コード
            ls_output-product = ls_1010-product.   "有償支給品番
            ls_output-profitcenter = ls_1010-profitcenter. "利益センタ
            ls_output-ledge = lv_ledge.
            ls_output-purchasinggroup = ls_1010-purchasinggroup.  "購買グループ
            ls_output-upperproduct01 = ls_1010-upperproduct01.    "上位品番
            ls_output-valuationclass01 = ls_1010-valuationclass01.   "評価クラス
            ls_output-valuationquantity01 = ls_1010-valuationquantity01.
            ls_output-upperproduct02 = ls_1010-upperproduct02.    "上位品番
            ls_output-valuationclass02 = ls_1010-valuationclass02.   "評価クラス
            ls_output-valuationquantity02 = ls_1010-valuationquantity02.
            ls_output-upperproduct03 = ls_1010-upperproduct03.    "上位品番
            ls_output-valuationclass03 = ls_1010-valuationclass03.   "評価クラス
            ls_output-valuationquantity03 = ls_1010-valuationquantity03.
            ls_output-upperproduct04 = ls_1010-upperproduct04.    "上位品番
            ls_output-valuationclass04 = ls_1010-valuationclass04.   "評価クラス
            ls_output-valuationquantity04 = ls_1010-valuationquantity04.
            ls_output-upperproduct05 = ls_1010-upperproduct05.    "上位品番
            ls_output-valuationclass05 = ls_1010-valuationclass05.   "評価クラス
            ls_output-valuationquantity05 = ls_1010-valuationquantity05.
            ls_output-upperproduct06 = ls_1010-upperproduct06.    "上位品番
            ls_output-valuationclass06 = ls_1010-valuationclass06.   "評価クラス
            ls_output-valuationquantity06 = ls_1010-valuationquantity06.
            ls_output-upperproduct07 = ls_1010-upperproduct07.    "上位品番
            ls_output-valuationclass07 = ls_1010-valuationclass07.   "評価クラス
            ls_output-valuationquantity07 = ls_1010-valuationquantity07.
            ls_output-upperproduct08 = ls_1010-upperproduct08.    "上位品番
            ls_output-valuationclass08 = ls_1010-valuationclass08.   "評価クラス
            ls_output-valuationquantity08 = ls_1010-valuationquantity08.
            ls_output-upperproduct09 = ls_1010-upperproduct09.    "上位品番
            ls_output-valuationclass09 = ls_1010-valuationclass09.   "評価クラス
            ls_output-valuationquantity09 = ls_1010-valuationquantity09.
            ls_output-upperproduct10 = ls_1010-upperproduct10.    "上位品番
            ls_output-valuationclass10 = ls_1010-valuationclass10.   "評価クラス
            ls_output-valuationquantity10 = ls_1010-valuationquantity10.

            ls_output-customername = ls_1010-customername.   "得意先名称
            ls_output-suppliername = ls_1010-suppliername.   "仕入先名称
            ls_output-profitcentername = ls_1010-profitcentername.  "利益センタテキスト
            ls_output-productdescription = ls_1010-productdescription.  "有償支給品番テキスト
            ls_output-cost01 = ls_1010-cost01.   "標準原価-材料費
            ls_output-cost02 = ls_1010-cost02.
            ls_output-cost03 = ls_1010-cost03.
            ls_output-cost04 = ls_1010-cost04.
            ls_output-cost05 = ls_1010-cost05.
            ls_output-cost06 = ls_1010-cost06.
            ls_output-cost07 = ls_1010-cost07.
            ls_output-cost08 = ls_1010-cost08.
            ls_output-cost09 = ls_1010-cost09.
            ls_output-cost10 = ls_1010-cost10.
            ls_output-materialcost2000 = ls_1010-materialcost2000.    "標準原価-材料費合計-2000
            ls_output-materialcost3000 = ls_1010-materialcost3000.    "標準原価-材料費合計-3000
            ls_output-purgrpamount1 = ls_1010-purgrpamount1.      "当期購買グループ別仕入金額期初
            ls_output-purgrpamount2 = ls_1010-purgrpamount2.      "当期購買グループ別仕入金額本年初-上个月末
            ls_output-purgrpamount = ls_1010-purgrpamount.      "当期購買グループ別仕入金額当前期间
            ls_output-chargeableamount1 = ls_1010-chargeableamount1.  "当期有償支給品仕入金額期初
            ls_output-chargeableamount2 = ls_1010-chargeableamount2.  "当期有償支給品仕入金額本年初-上个月末
            ls_output-chargeableamount = ls_1010-chargeableamount.  "当期有償支給品仕入金額
            ls_output-previousstockamount = ls_1010-previousstockamount. "在庫金額（前期末）
            ls_output-currentstockamount = ls_1010-currentstockamount. "在庫金額（当期末）-有償支給品
            ls_output-customerrevenue1 = ls_1010-customerrevenue1. "該当得意先の総売上高期初
            ls_output-customerrevenue = ls_1010-customerrevenue. "該当得意先の総売上高
            ls_output-revenue1 = ls_1010-revenue1.  "会社レベルの総売上高期初
            ls_output-revenue = ls_1010-revenue.  "会社レベルの総売上高
            ls_output-currency = ls_1010-currency.
            APPEND ls_output TO lt_output.
            CLEAR: ls_output.
          ENDLOOP.
        ENDIF.

      WHEN 'B'.    "購買グルー合計
        SELECT *
          FROM ztfi_1011
         WHERE companycode = @lv_bukrs
           AND fiscalyear = @lv_gjahr
           AND period = @lv_monat
           AND ledge = @lv_ledge
          INTO TABLE @DATA(lt_1011).
        IF sy-subrc = 0.
          LOOP AT lt_1011 INTO DATA(ls_1011).
            ls_output-ztype = lv_ztype.
            ls_output-companycode = ls_1011-companycode.
            ls_output-fiscalyear = ls_1011-fiscalyear.
            ls_output-period = ls_1011-period.
            ls_output-customer = ls_1011-customer. "得意先コード
            ls_output-supplier = ls_1011-supplier. "仕入先コード
            ls_output-profitcenter = ls_1011-profitcenter. "利益センタ
            ls_output-purchasinggroup = ls_1011-purchasinggroup.  "購買グループ
            ls_output-ledge = lv_ledge.
            ls_output-customername = ls_1011-customername.   "得意先名称
            ls_output-suppliername = ls_1011-suppliername.   "仕入先名称
            ls_output-profitcentername = ls_1011-profitcentername.  "利益センタテキスト
            ls_output-purgrptot = ls_1011-purgrpamount. "当期購買グループ別仕入金額
            ls_output-chargeabletot = ls_1011-chargeableamount. "当期有償支給品仕入金額
            lv_rate = ls_1011-chargeablerate * 100.
            IF lv_rate <> 0.
              ls_output-chargeablerate = lv_rate.  "当期仕入率
              CONDENSE ls_output-chargeablerate NO-GAPS.
            ELSE.
              ls_output-chargeablerate = '0'.  "当期仕入率
              CONDENSE ls_output-chargeablerate NO-GAPS.
            ENDIF.
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
            IF lv_rate <> 0.
              ls_output-revenuerate = lv_rate.  "総売上金額占有率
              CONDENSE ls_output-revenuerate NO-GAPS.
            ELSE.
              ls_output-revenuerate = '0'.  "総売上金額占有率
              CONDENSE ls_output-revenuerate NO-GAPS.
            ENDIF.
            ls_output-currency = ls_1011-currency.
            APPEND ls_output TO lt_output.
            CLEAR: ls_output.
          ENDLOOP.
        ENDIF.
    ENDCASE.

    SORT lt_output BY companycode profitcenter product purchasinggroup customer supplier.
*    " Filtering
*    zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
*                                 CHANGING  ct_data     = lt_output ).

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
