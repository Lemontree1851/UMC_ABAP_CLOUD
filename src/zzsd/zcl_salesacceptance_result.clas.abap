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
      ls_output TYPE zr_salesacceptance_result,
      lr_vkorg  TYPE RANGE OF vkorg,
      lrs_vkorg LIKE LINE OF lr_vkorg.

    DATA:
      lv_year      TYPE c LENGTH 4,
      lv_month     TYPE monat,
      lv_nextmonth TYPE budat,
      lv_from      TYPE budat,
      lv_to        TYPE budat,
      lv_netpr(8)  TYPE p DECIMALS 2.

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
            WHEN 'LAYER'.
              DATA(lr_layer) = ls_filter_cond-range.
              READ TABLE lr_layer INTO DATA(lrs_layer) INDEX 1.
              DATA(lv_layer) = lrs_layer-low.
            WHEN 'FINISHSTATUS'.
              DATA(lr_finish) = ls_filter_cond-range.
              READ TABLE lr_finish INTO DATA(lrs_finish) INDEX 1.
              DATA(lv_finish) = lrs_finish-low.
          ENDCASE.
        ENDLOOP.
      CATCH cx_rap_query_filter_no_range.
        "handle exception
        io_response->set_data( lt_output ).
    ENDTRY.

* ZTBC_1001
    SELECT *                                  "#EC CI_ALL_FIELDS_NEEDED
      FROM ztbc_1001
     WHERE zid = 'ZSD003'
        OR zid = 'ZSD004'
        OR zid = 'ZSD008'
        OR zid = 'ZSD009'
        OR zid = 'ZSD010'
      INTO TABLE @DATA(lt_1001).

    CASE lv_periodtype.
      WHEN 'A'.  "1日~月末
        lv_year = xco_cp=>sy->date( )->year.
        lv_from = lv_year && lv_acceptperiod && '01'.
        IF lv_acceptperiod = 12.
          lv_year = lv_year + 1.
          lv_nextmonth = lv_year && '01' && '01'.
        ELSE.
          lv_month = lv_acceptperiod + 1.
          lv_nextmonth = lv_year && lv_month && '01'.
        ENDIF.
        lv_to = lv_nextmonth - 1.
      WHEN 'B'.  "16日~次月15日
        lv_year = xco_cp=>sy->date( )->year.
        lv_from = lv_year && lv_acceptperiod && '16'.
        IF lv_acceptperiod = 12.
          lv_year = lv_year + 1.
          lv_month = '01'.
        ELSE.
          lv_month = lv_acceptperiod + 1.
        ENDIF.
        lv_to = lv_year && lv_month && '15'.
      WHEN 'C'.  "21日~次月20日
        lv_year = xco_cp=>sy->date( )->year.
        lv_from = lv_year && lv_acceptperiod && '21'.
        IF lv_acceptperiod = 12.
          lv_year = lv_year + 1.
          lv_month = '01'.
        ELSE.
          lv_month = lv_acceptperiod + 1.
        ENDIF.
        lv_to = lv_year && lv_month && '20'.

      WHEN 'D'.  "26日~次月25日
        lv_year = xco_cp=>sy->date( )->year.
        lv_from = lv_year && lv_acceptperiod && '26'.
        IF lv_acceptperiod = 12.
          lv_year = lv_year + 1.
          lv_month = '01'.
        ELSE.
          lv_month = lv_acceptperiod + 1.
        ENDIF.
        lv_to = lv_year && lv_month && '25'.
    ENDCASE.

    CASE lv_layer.
      WHEN '1'.   "第一个页面
*A 指定される期間の検収データと実績データを抽出
*A 以前期間に保留となった検収と実績データ
        IF lv_finish = '0'.
          SELECT *
            FROM ztsd_1003 WITH PRIVILEGED ACCESS
           WHERE customer IN @lr_kunnr
             AND periodtype = @lv_periodtype
             AND acceptperiod = @lv_acceptperiod
             AND ( finishstatus = '0'
                OR finishstatus = @space )
            INTO TABLE @DATA(lt_1003).
          IF sy-subrc = 0.
            SELECT *                          "#EC CI_ALL_FIELDS_NEEDED
            FROM ztsd_1012 WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_1003
           WHERE salesorganization = @lt_1003-salesorganization
             AND customer = @lt_1003-customer
             AND periodtype = @lt_1003-periodtype
             AND acceptperiod = @lt_1003-acceptperiod
             AND customerpo = @lt_1003-customerpo
            INTO TABLE @DATA(lt_1012).
          ENDIF.

          SELECT *
            FROM ztsd_1003 WITH PRIVILEGED ACCESS
           WHERE customer IN @lr_kunnr
             AND periodtype = @lv_periodtype
             AND acceptperiodto < @lv_from
             AND ( finishstatus = '0'
                OR finishstatus = @space )
            INTO TABLE @DATA(lt_1003_t).
          IF sy-subrc = 0.
            SELECT *
            FROM ztsd_1012 WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_1003_t
           WHERE salesorganization = @lt_1003_t-salesorganization
             AND customer = @lt_1003_t-customer
             AND periodtype = @lt_1003_t-periodtype
             AND acceptperiod = @lt_1003_t-acceptperiod
             AND customerpo = @lt_1003_t-customerpo
             AND processstatus = '4'
            INTO TABLE @DATA(lt_1012_t).
          ENDIF.

          SORT lt_1012_t BY salesorganization customer periodtype acceptperiod customerpo.
          LOOP AT lt_1003_t INTO DATA(ls_1003_t).
            READ TABLE lt_1012_t TRANSPORTING NO FIELDS
                 WITH KEY salesorganization = ls_1003_t-salesorganization
                          customer = ls_1003_t-customer
                          periodtype = ls_1003_t-periodtype
                          acceptperiod = ls_1003_t-acceptperiod
                          customerpo = ls_1003_t-customerpo BINARY SEARCH.
            IF sy-subrc <> 0.
              DELETE lt_1003_t.
              CONTINUE.
            ENDIF.
          ENDLOOP.


          IF lt_1003_t IS NOT INITIAL.
            APPEND LINES OF lt_1003_t TO lt_1003.
          ENDIF.

          IF lt_1012_t IS NOT INITIAL.
            APPEND LINES OF lt_1012_t TO lt_1012.
          ENDIF.
        ELSE.
          SELECT *
            FROM ztsd_1003 WITH PRIVILEGED ACCESS
           WHERE customer IN @lr_kunnr
             AND periodtype = @lv_periodtype
             AND acceptperiod = @lv_acceptperiod
             AND finishstatus = '1'
            INTO TABLE @lt_1003.
          IF sy-subrc = 0.
            SELECT *                          "#EC CI_ALL_FIELDS_NEEDED
            FROM ztsd_1012 WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_1003
           WHERE salesorganization = @lt_1003-salesorganization
             AND customer = @lt_1003-customer
             AND periodtype = @lt_1003-periodtype
             AND acceptperiod = @lt_1003-acceptperiod
             AND customerpo = @lt_1003-customerpo
            INTO TABLE @lt_1012.
          ENDIF.

        ENDIF.

      WHEN '2'.  "第2页面
*A 指定される期間の検収データと実績データを抽出
*A 以前期間に保留となった検収と実績データ
        IF lv_finish = '0'.
          SELECT *
            FROM ztsd_1003 WITH PRIVILEGED ACCESS
           WHERE customer IN @lr_kunnr
             AND periodtype = @lv_periodtype
             AND acceptperiod = @lv_acceptperiod
             AND ( finishstatus = '0'
                OR finishstatus = @space )
            INTO TABLE @lt_1003.
          IF sy-subrc = 0.
            SELECT *                          "#EC CI_ALL_FIELDS_NEEDED
              FROM ztsd_1012 WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_1003
             WHERE salesorganization = @lt_1003-salesorganization
               AND customer = @lt_1003-customer
               AND periodtype = @lt_1003-periodtype
               AND acceptperiod = @lt_1003-acceptperiod
               AND customerpo = @lt_1003-customerpo
              INTO TABLE @lt_1012.
          ENDIF.

          SELECT *
            FROM ztsd_1003 WITH PRIVILEGED ACCESS
           WHERE customer IN @lr_kunnr
             AND periodtype = @lv_periodtype
             AND acceptperiodfrom < @lv_from
             AND ( finishstatus = '0'
                OR finishstatus = @space )
            INTO TABLE @lt_1003_t.

          IF lt_1003_t IS NOT INITIAL.
            SELECT *                          "#EC CI_ALL_FIELDS_NEEDED
              FROM ztsd_1012
              FOR ALL ENTRIES IN @lt_1003_t
             WHERE salesorganization = @lt_1003_t-salesorganization
               AND customer = @lt_1003_t-customer
               AND periodtype = @lt_1003_t-periodtype
               AND acceptperiod = @lt_1003_t-acceptperiod
               AND customerpo = @lt_1003_t-customerpo
               AND old_status = '4'
              INTO TABLE @lt_1012_t.
          ENDIF.

          SORT lt_1012_t BY salesorganization customer periodtype acceptperiod customerpo.
          LOOP AT lt_1003_t INTO ls_1003_t.
            READ TABLE lt_1012_t TRANSPORTING NO FIELDS
                 WITH KEY salesorganization = ls_1003_t-salesorganization
                          customer = ls_1003_t-customer
                          periodtype = ls_1003_t-periodtype
                          acceptperiod = ls_1003_t-acceptperiod
                          customerpo = ls_1003_t-customerpo BINARY SEARCH.
            IF sy-subrc <> 0.
              DELETE lt_1003_t.
              CONTINUE.
            ENDIF.
          ENDLOOP.

          IF lt_1003_t IS NOT INITIAL.
            APPEND LINES OF lt_1003_t TO lt_1003.
          ENDIF.

          IF lt_1012_t IS NOT INITIAL.
            APPEND LINES OF lt_1012_t TO lt_1012.
          ENDIF.
        ELSE.
          SELECT *
            FROM ztsd_1003 WITH PRIVILEGED ACCESS
           WHERE customer IN @lr_kunnr
             AND periodtype = @lv_periodtype
             AND acceptperiod = @lv_acceptperiod
             AND finishstatus = '1'
            INTO TABLE @lt_1003.
          IF sy-subrc = 0.
            SELECT *                          "#EC CI_ALL_FIELDS_NEEDED
              FROM ztsd_1012 WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_1003
             WHERE salesorganization = @lt_1003-salesorganization
               AND customer = @lt_1003-customer
               AND periodtype = @lt_1003-periodtype
               AND acceptperiod = @lt_1003-acceptperiod
               AND customerpo = @lt_1003-customerpo
              INTO TABLE @lt_1012.
          ENDIF.
        ENDIF.
    ENDCASE.

* Customer Name
* B I_SalesDocument
* D I_SalesDocumentItem
    IF lt_1003 IS NOT INITIAL.
      SELECT a~salesdocument,
             b~salesdocumentitem,
             a~salesdocumenttype,
             a~SalesOrganization,
             a~purchaseorderbycustomer,
             b~product,
             b~salesdocumentitemtext
        FROM i_salesdocument WITH PRIVILEGED ACCESS AS a
        INNER JOIN i_salesdocumentitem WITH PRIVILEGED ACCESS AS b
          ON ( a~salesdocument = b~salesdocument )
        FOR ALL ENTRIES IN @lt_1003
       WHERE a~soldtoparty IN @lr_kunnr
         AND a~purchaseorderbycustomer = @lt_1003-customerpo
        INTO TABLE @DATA(lt_so).

      SELECT customer,
             customername
        FROM i_customer
        FOR ALL ENTRIES IN @lt_1003
       WHERE customer = @lt_1003-customer
        INTO TABLE @DATA(lt_customer).
    ENDIF.

* Authorization Check
    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
    DATA(lv_vkorg) = zzcl_common_utils=>get_salesorg_by_user( lv_user_email ).
    IF lv_vkorg IS INITIAL.
        CLEAR: lt_1003, lt_so.
      ELSE.
        SPLIT lv_vkorg AT '&' INTO TABLE DATA(lt_vkorg_check).
        CLEAR lr_vkorg.
        lr_vkorg = VALUE #( FOR salesorganization IN lt_vkorg_check ( sign = 'I' option = 'EQ' low = salesorganization ) ).
        DELETE lt_1003 WHERE salesorganization NOT IN lr_vkorg.
        DELETE lt_so WHERE salesorganization NOT IN lr_vkorg.
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
         AND language = @sy-langu
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
        FROM i_journalentryitem WITH PRIVILEGED ACCESS
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
        FROM i_billingdocumentitemprcgelmnt WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_billing
       WHERE billingdocument = @lt_billing-billingdocument
         AND billingdocumentitem = @lt_billing-billingdocumentitem
         AND conditiontype = 'PPR0'
         AND conditioninactivereason = @space
        INTO TABLE @DATA(lt_prcd_elements).
    ENDIF.

* Edit output
    SORT lt_1003 BY customerpo.
    SORT lt_1012 BY salesdocument salesdocumentitem billingdocument.
    SORT lt_billing BY salesdocument salesdocumentitem.
    SORT lt_auart BY salesdocumenttype.
    SORT lt_bkpf BY referencedocument referencedocumentitem.
    SORT lt_prcd_elements BY billingdocument billingdocumentitem.
    SORT lt_customer BY customer.

    LOOP AT lt_so INTO DATA(ls_so).
      ls_output-salesdocument = ls_so-salesdocument.
      ls_output-salesdocumentitem = ls_so-salesdocumentitem.
      ls_output-salesdocumenttype = ls_so-salesdocumenttype.
      ls_output-layer = lv_layer.
      ls_output-finishstatus = lv_finish.

      READ TABLE lt_auart INTO DATA(ls_auart)
                 WITH KEY salesdocumenttype = ls_so-salesdocumenttype BINARY SEARCH.
      IF sy-subrc = 0.
        ls_output-salesdocumenttypetext = ls_auart-salesdocumenttypename.
      ENDIF.
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
        "検収単価
        ls_output-acceptprice = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'OUT'
                                                         iv_currency = ls_1003-currency
                                                         iv_input = ls_1003-acceptprice ).
        CONDENSE ls_output-acceptprice NO-GAPS.
        "検収金額
        ls_output-accceptamount = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'OUT'
                                                         iv_currency = ls_1003-currency
                                                         iv_input = ls_1003-accceptamount ).
        CONDENSE ls_output-accceptamount NO-GAPS.
        "検収税額
        ls_output-acccepttaxamount = ls_1003-accceptamount * ls_1003-taxrate.
        CONDENSE ls_output-acccepttaxamount NO-GAPS.
        ls_output-acccepttaxamount = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'OUT'
                                                         iv_currency = ls_1003-currency
                                                         iv_input = ls_output-acccepttaxamount ).
        CONDENSE ls_output-acccepttaxamount NO-GAPS.
        ls_output-currency = ls_1003-currency.        "検収通貨(受注通貨)
        ls_output-outsidedata = ls_1003-outsidedata.  "SAP外売上区分(フラグ)
      ENDIF.

      READ TABLE lt_billing INTO DATA(ls_billing)
           WITH KEY salesdocument = ls_so-salesdocument
                    salesdocumentitem = ls_so-salesdocumentitem BINARY SEARCH.
      IF sy-subrc = 0.
        ls_output-billingdocument = ls_billing-billingdocument.  "実績伝票番号
        ls_output-accountingexchangerate = ls_billing-accountingexchangerate. "為替レート
        ls_output-exchangeratedate = ls_billing-exchangeratedate.  "為替日付
        ls_output-billingquantity = ls_billing-billingquantity.    "出庫数
        "請求金額
        ls_output-netamount = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'OUT'
                                                         iv_currency = ls_1003-currency
                                                         iv_input = ls_billing-netamount ).
        CONDENSE ls_output-netamount NO-GAPS.
        "請求税額
        ls_output-taxamount = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'OUT'
                                                         iv_currency = ls_1003-currency
                                                         iv_input = ls_billing-taxamount ).
        CONDENSE ls_output-taxamount NO-GAPS.
        READ TABLE lt_prcd_elements INTO DATA(ls_prcd)
             WITH KEY billingdocument = ls_billing-billingdocument
                      billingdocumentitem = ls_billing-billingdocumentitem BINARY SEARCH.
        IF sy-subrc = 0.
          "請求単価
          ls_output-conditionratevalue = ls_prcd-conditionratevalue.
          CONDENSE ls_output-conditionratevalue NO-GAPS.
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

      IF lv_layer = 1.
        IF lv_finish = '0'. "内部编码
          READ TABLE lt_1012 INTO DATA(ls_1012)
               WITH KEY salesdocument = ls_output-salesdocument
                        salesdocumentitem = ls_output-salesdocumentitem
                        billingdocument = ls_output-billingdocument BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-remarks = ls_1012-remarks.
            ls_output-processstatus = ls_1012-processstatus.
            ls_output-reasoncategory = ls_1012-reasoncategory.
            ls_output-reason = ls_1012-reason.
          ELSE.
            IF ls_output-conditionquantity <> 0.
              lv_netpr = ls_output-conditionratevalue / ls_output-conditionquantity.
            ENDIF.
            IF ls_output-acceptqty = ls_output-billingquantity
           AND ls_output-acceptprice = lv_netpr
           AND ls_output-accceptamount = ls_output-netamount
           AND ls_output-acccepttaxamount = ls_output-taxamount.
              ls_output-processstatus = '0'.
            ELSE.
              ls_output-processstatus = '2'.
            ENDIF.
          ENDIF.
        ELSE.   "外部编码
          READ TABLE lt_1012 INTO ls_1012
               WITH KEY salesdocument = ls_output-salesdocument
                        salesdocumentitem = ls_output-salesdocumentitem
                        billingdocument = ls_output-billingdocument BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-remarks = ls_1012-remarks.
            READ TABLE lt_1001 INTO DATA(ls_1001)
               WITH KEY zid = 'ZSD008'
                        zvalue1 = ls_1012-processstatus.
            IF sy-subrc = 0.
              ls_output-processstatus = ls_1001-zvalue2.
            ELSE.
              ls_output-processstatus = ls_1012-processstatus.
            ENDIF.

            READ TABLE lt_1001 INTO ls_1001
                 WITH KEY zid = 'ZSD009'
                          zvalue1 = ls_1012-reasoncategory.
            IF sy-subrc = 0.
              ls_output-reasoncategory = ls_1001-zvalue2.
            ELSE.
              ls_output-reasoncategory = ls_1012-reasoncategory.
            ENDIF.

            READ TABLE lt_1001 INTO ls_1001
                 WITH KEY zid = 'ZSD010'
                          zvalue1 = ls_1012-reason.
            IF sy-subrc = 0.
              ls_output-reason = ls_1001-zvalue2.
            ELSE.
              ls_output-reason = ls_1012-reason.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        "Code转描述
        READ TABLE lt_1012 INTO ls_1012
             WITH KEY salesdocument = ls_output-salesdocument
                      salesdocumentitem = ls_output-salesdocumentitem
                      billingdocument = ls_output-billingdocument BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-remarks = ls_1012-remarks.
          READ TABLE lt_1001 INTO ls_1001
               WITH KEY zid = 'ZSD008'
                        zvalue1 = ls_1012-processstatus.
          IF sy-subrc = 0.
            ls_output-processstatus = ls_1001-zvalue2.
          ELSE.
            ls_output-processstatus = ls_1012-processstatus.
          ENDIF.

          READ TABLE lt_1001 INTO ls_1001
               WITH KEY zid = 'ZSD009'
                        zvalue1 = ls_1012-reasoncategory.
          IF sy-subrc = 0.
            ls_output-reasoncategory = ls_1001-zvalue2.
          ELSE.
            ls_output-reasoncategory = ls_1012-reasoncategory.
          ENDIF.

          READ TABLE lt_1001 INTO ls_1001
               WITH KEY zid = 'ZSD010'
                        zvalue1 = ls_1012-reason.
          IF sy-subrc = 0.
            ls_output-reason = ls_1001-zvalue2.
          ELSE.
            ls_output-reason = ls_1012-reason.
          ENDIF.
        ENDIF.
      ENDIF.

      "编辑表头描述
      READ TABLE lt_customer INTO DATA(ls_customer)
           WITH KEY customer = ls_1003-customer BINARY SEARCH.
      IF sy-subrc = 0.
        ls_output-customername = |{ ls_output-customer ALPHA = OUT }|.
        ls_output-customername = ls_output-customername && ` ` && ls_customer-customername.
      ENDIF.
      READ TABLE lt_1001 INTO ls_1001
           WITH KEY zid = 'ZSD003'
                    zvalue1 = lv_periodtype.
      IF sy-subrc = 0.
        ls_output-periodtypetext = lv_periodtype && ` ` && ls_1001-zvalue2.
      ENDIF.
      READ TABLE lt_1001 INTO ls_1001
           WITH KEY zid = 'ZSD004'
                    zvalue1 = lv_acceptperiod.
      IF sy-subrc = 0.
        ls_output-acceptperiodtext = lv_acceptperiod && ` ` && ls_1001-zvalue2.
      ENDIF.
      ls_output-acceptperiodfromtext = |{ lv_from+0(4) }/{ lv_from+4(2) }/{ lv_from+6(2) }|.
      ls_output-acceptperiodtotext = |{ lv_to+0(4) }/{ lv_to+4(2) }/{ lv_to+6(2) }|.
      APPEND ls_output TO lt_output.
      CLEAR: ls_output.
    ENDLOOP.

    IF lv_layer = '2'.
      DATA:
        lv_first TYPE c VALUE 'X'.
      DATA(lt_tmp) = lt_output[].
      CLEAR: lt_output.
      LOOP AT lt_tmp INTO DATA(ls_tmp)
                        GROUP BY ( processstatus = ls_tmp-processstatus )
                        REFERENCE INTO DATA(member).
        LOOP AT GROUP member INTO DATA(ls_mem).
          IF lv_first = 'X'.
            ls_output-customerpo = ls_mem-processstatus.
            APPEND ls_output TO lt_output.
            CLEAR: ls_output.
          ENDIF.
          CLEAR: lv_first.
          APPEND ls_mem TO lt_output.

        ENDLOOP.
        lv_first = 'X'.
      ENDLOOP.
    ENDIF.


    IF lv_layer = '1'.
      " Filtering
      zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
                                   CHANGING  ct_data     = lt_output ).
    ENDIF.
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
