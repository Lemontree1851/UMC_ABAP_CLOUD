CLASS zcl_salesacceptance_result DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_salesacceptance_result IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    DATA:
      lt_output TYPE STANDARD TABLE OF zr_salesacceptance_result,
      ls_output TYPE zr_salesacceptance_result.

    DATA:
      lv_from  TYPE budat,
      lv_year  TYPE c LENGTH 4,
      lv_month TYPE monat.

* Get filter range
    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          CASE ls_filter_cond-name.
            WHEN 'CUSTOMER'.
              DATA(lr_kunnr) = ls_filter_cond-range.
            WHEN 'PERIODTYPE'.
              DATA(lr_periodtype) = ls_filter_cond-range.
              READ TABLE lr_periodtype INTO DATA(lrs_periodtype) INDEX 1.
              DATA(lv_periodtype) = lrs_periodtype-low.
            WHEN 'ACCEPTPERIOD'.
              DATA(lr_acceptperiod) = ls_filter_cond-range.
              READ TABLE lr_acceptperiod INTO DATA(lrs_acceptperiod) INDEX 1.
              DATA(lv_acceptperiod) = lrs_acceptperiod-low.
          ENDCASE.
        ENDLOOP.
      CATCH cx_rap_query_filter_no_range.
        "handle exception
        io_response->set_data( lt_output ).
    ENDTRY.

*A 指定される期間の検収データと実績データを抽出
*A 以前期間に保留となった検収と実績データ
    SELECT *
      FROM ztsd_1003 WITH PRIVILEGED ACCESS
     WHERE customer IN @lr_kunnr
       AND periodtype = @lv_periodtype
       AND acceptperiod = @lv_acceptperiod
       AND finishstatus = '0'
      INTO TABLE @DATA(lt_1003).
    IF sy-subrc = 0.
      SELECT *
      FROM ztsd_1012 WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_1003
     WHERE salesorganization = @lt_1003-salesorganization
       AND customer = @lt_1003-customer
       AND periodtype = @lt_1003-periodtype
       AND acceptperiod = @lt_1003-acceptperiod
       AND customerpo = @lt_1003-customerpo
      INTO TABLE @DATA(lt_1012).
    ENDIF.

    lv_year = xco_cp=>sy->date( )->year.
    CASE lv_periodtype.
      WHEN 'A'.  "1日~月末
        lv_from = lv_year && lv_acceptperiod && '01'.
      WHEN 'B'.  "16日~次月15日
        lv_from = lv_year && lv_acceptperiod && '16'.
      WHEN 'C'.  "21日~次月20日
        lv_from = lv_year && lv_acceptperiod && '21'.
      WHEN 'D'.  "26日~次月25日
        lv_from = lv_year && lv_acceptperiod && '26'.
    ENDCASE.

    SELECT *
      FROM ztsd_1003 WITH PRIVILEGED ACCESS
     WHERE customer IN @lr_kunnr
       AND periodtype = @lv_periodtype
       AND acceptperiodfrom < @lv_from
       AND finishstatus = '0'
      INTO TABLE @DATA(lt_1003_t).
    IF sy-subrc = 0.
      SELECT *
      FROM ztsd_1012 WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_1003
     WHERE salesorganization = @lt_1003-salesorganization
       AND customer = @lt_1003-customer
       AND periodtype = @lt_1003-periodtype
       AND acceptperiod = @lt_1003-acceptperiod
       AND customerpo = @lt_1003-customerpo
      INTO TABLE @DATA(lt_1012_t).
    ENDIF.

    IF lt_1003_t IS NOT INITIAL.
      APPEND LINES OF lt_1003_t TO lt_1003.
    ENDIF.

    IF lt_1012_t IS NOT INITIAL.
      APPEND LINES OF lt_1012_t TO lt_1012.
    ENDIF.

* B I_SalesDocument
* D I_SalesDocumentItem
    IF lt_1003 IS NOT INITIAL.
      SELECT a~salesdocument,
             b~salesdocumentitem,
             a~salesdocumenttype,
             a~purchaseorderbycustomer,
             b~product,
             b~salesdocumentitemtext
        FROM i_salesdocument WITH PRIVILEGED ACCESS AS a
        INNER JOIN i_salesdocumentitem WITH PRIVILEGED ACCESS AS b
          ON ( a~salesdocument = b~salesdocument )
        FOR ALL ENTRIES IN @lt_1003
       WHERE a~purchaseorderbycustomer = @lt_1003-customerpo
        INTO TABLE @DATA(lt_so).
    ENDIF.

    IF lt_so IS NOT INITIAL.
* C: I_BillingDocumentItem
* G: I_BillingDocument
      SELECT a~billingdocument,
             a~accountingexchangerate,
             a~exchangeratedate,
             b~billingdocumentitem,
             b~billingquantity,
             b~netamount,
             b~taxamount,
             b~salesdocument,
             b~salesdocumentitem
        FROM i_billingdocument WITH PRIVILEGED ACCESS AS a
        INNER JOIN i_billingdocumentitem WITH PRIVILEGED ACCESS AS b
          ON ( a~billingdocument = b~billingdocument )
        FOR ALL ENTRIES IN @lt_so
       WHERE b~salesdocument = @lt_so-salesdocument
         AND b~salesdocumentitem = @lt_so-salesdocumentitem
         AND a~cancelledbillingdocument = @space
        INTO TABLE @DATA(lt_billing).
* I: I_SalesDocumentTypeText
      SELECT salesdocumenttype,
             salesdocumenttypename
        FROM i_salesdocumenttypetext WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_so
       WHERE salesdocumenttype = @lt_so-salesdocumenttype
        INTO TABLE @DATA(lt_auart).
    ENDIF.

    IF lt_billing IS NOT INITIAL.
* E: I_JournalEntryItem
      SELECT companycode,
             fiscalyear,
             accountingdocument,
             referencedocument,
             referencedocumentitem,
             postingdate
        FROM i_journalentryitem
        FOR ALL ENTRIES IN @lt_billing
       WHERE referencedocument = @lt_billing-billingdocument
         AND referencedocumentitem = @lt_billing-billingdocumentitem
        INTO TABLE @DATA(lt_bkpf).

* F: I_BillingDocumentItemPrcgElmnt
      SELECT billingdocument,
             billingdocumentitem,
             pricingprocedurestep,
             pricingprocedurecounter,
             conditionratevalue,
             conditioncurrency,
             conditionquantity
        FROM i_billingdocumentitemprcgelmnt
        FOR ALL ENTRIES IN @lt_billing
       WHERE billingdocument = @lt_billing-billingdocument
         AND billingdocumentitem = @lt_billing-billingdocumentitem
        INTO TABLE @DATA(lt_prcd_elements).
    ENDIF.

* Edit output
    SORT lt_1003 BY customerpo.
    SORT lt_1012 BY salesdocument salesdocumentitem.
    SORT lt_billing BY salesdocument salesdocumentitem.
    SORT lt_auart BY salesdocumenttype.
    SORT lt_bkpf BY referencedocument referencedocumentitem.
    SORT lt_prcd_elements BY billingdocument billingdocumentitem.

    LOOP AT lt_so INTO DATA(ls_so).
      ls_output-salesdocument = ls_so-salesdocument.
      ls_output-salesdocumentitem = ls_so-salesdocumentitem.
      ls_output-salesdocumenttype = ls_so-salesdocumenttype.
      ls_output-product = ls_so-product.
      ls_output-salesdocumentitemtext = ls_so-salesdocumentitemtext.
      READ TABLE lt_1003 INTO DATA(ls_1003)
           WITH KEY customerpo = ls_so-purchaseorderbycustomer BINARY SEARCH.
      IF sy-subrc = 0.
        ls_output-customer = ls_1003-customer.          "得意先
        ls_output-periodtype = ls_1003-periodtype.      "期間区分
        ls_output-acceptperiod = ls_1003-acceptperiod.  "検収期間
        ls_output-customerpo = ls_1003-customerpo.      "得意先PO番号
        ls_output-acceptperiodfrom = ls_1003-acceptperiodfrom.
        ls_output-acceptperiodto = ls_1003-acceptperiodto.
        ls_output-acceptdate = ls_1003-acceptdate.   "検収日付
        ls_output-acceptqty = ls_1003-acceptqty.     "検収数
        ls_output-acceptprice = ls_1003-acceptprice. "検収単価
        ls_output-accceptamount = ls_1003-accceptamount. "検収金額
        ls_output-currency = ls_1003-currency.        "検収通貨(受注通貨)
        ls_output-outsidedata = ls_1003-outsidedata.  "SAP外売上区分(フラグ)
      ENDIF.

      READ TABLE lt_1012 INTO DATA(ls_1012)
           WITH KEY salesdocument = ls_so-salesdocument
                    salesdocumentitem = ls_so-salesdocumentitem BINARY SEARCH.
      IF sy-subrc = 0.
        ls_output-remarks = ls_1012-remarks.             "備考
        ls_output-processstatus = ls_1012-processstatus. "処理ステータス
        ls_output-reasoncategory = ls_1012-reasoncategory. "要因区分
        ls_output-reason = ls_1012-reason.                 "差異要因
      ENDIF.

      READ TABLE lt_billing INTO DATA(ls_billing)
           WITH KEY salesdocument = ls_so-salesdocument
                    salesdocumentitem = ls_so-salesdocumentitem BINARY SEARCH.
      IF sy-subrc = 0.
        ls_output-billingdocument = ls_billing-billingdocument.  "実績伝票番号
        ls_output-accountingexchangerate = ls_billing-accountingexchangerate. "為替レート
        ls_output-exchangeratedate = ls_billing-exchangeratedate.  "為替日付
        ls_output-billingquantity = ls_billing-billingquantity.    "出庫数
        ls_output-netamount = ls_billing-netamount.                "請求金額
        ls_output-taxamount = ls_billing-taxamount.                "請求税額

        READ TABLE lt_prcd_elements INTO DATA(ls_prcd)
             WITH KEY billingdocument = ls_billing-billingdocument
                      billingdocumentitem = ls_billing-billingdocumentitem BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-conditionratevalue = ls_prcd-conditionratevalue. "請求単価
          ls_output-conditioncurrency = ls_prcd-conditioncurrency.   "単価通貨
          ls_output-conditionquantity = ls_prcd-conditionquantity.   "単価数量単位
        ENDIF.

        READ TABLE lt_bkpf INTO DATA(ls_bkpf)
           WITH KEY referencedocument = ls_billing-billingdocument
                    referencedocumentitem = ls_billing-billingdocumentitem BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-postingdate = ls_bkpf-postingdate.               "実績転記日
        ENDIF.
      ENDIF.

      APPEND ls_output TO lt_output.
      CLEAR: ls_output.
    ENDLOOP.




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
