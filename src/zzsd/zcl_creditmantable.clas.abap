CLASS zcl_creditmantable DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_creditmantable IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA:
      lv_KUNNR             TYPE KUNNR,
      lt_data              TYPE STANDARD TABLE OF zr_creditmantable,
      ls_data              TYPE zr_creditmantable,
      ls_data_salesd       TYPE zr_creditmantable, "本月の売上金額-予
      ls_data_xy           TYPE zr_creditmantable,
      ls_data_xs           TYPE zr_creditmantable,
      lv_day               TYPE i,
      lr_salesorganization TYPE RANGE OF zr_creditmantable-salesorganization,
      ls_salesorganization LIKE LINE OF lr_salesorganization,
      lr_customer          TYPE RANGE OF zr_creditmantable-customer,
      lS_customer          LIKE LINE OF lr_customer,
      lv_termsno           TYPE char10,
      lv_zyear             TYPE zr_creditmantable-zyear.
    DATA:
      lv_rowno  TYPE n LENGTH 4,
      lv_date   TYPE sy-datum,
      lv_zyeart TYPE zr_creditmantable-zyear,
      lv_zmoth  TYPE c LENGTH 2,
      lv_terms  TYPE sy-index.

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
            CASE ls_filter_cond-name.
              WHEN 'SALESORGANIZATION'.
                CLEAR ls_salesorganization.
                ls_salesorganization-sign   = 'I'.
                ls_salesorganization-option = 'EQ'.
                ls_salesorganization-low    = str_rec_l_range-low.
                APPEND ls_salesorganization TO lr_salesorganization.

              WHEN 'CUSTOMER'.
                 CLEAR lS_customer.
                lS_customer-sign   = 'I'.
                lS_customer-option = 'EQ'.

                lv_KUNNR = str_rec_l_range-low.
                lv_KUNNR = |{ lv_KUNNR ALPHA = IN }|.
                lS_customer-low    = lv_KUNNR.

                APPEND lS_customer TO lr_customer.

              WHEN 'ZYEAR'.
                lv_zyear = str_rec_l_range-low.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.
        ENDLOOP.

      CATCH cx_rap_query_filter_no_range.
        "handle exception
        io_response->set_data( lt_data ).
    ENDTRY.

    if lv_zyear is INITIAL.

      lv_zyear = sy-datum+0(4).

    ENDIF.

    SELECT
      sales~salesorganization,"販売組織
      customerc~customer,      "得意先コード
      customer~customername,  "得意先名称
      customerc~companycode,
      credit~creditsegmentcurrency,
      credit~customercreditlimitamount      AS limitamount,"与信限度額
      customerpay~customerpaymenttermsname  AS terms,       "回収条件-支払条件
      payment~paymentterms,
      payment~PaymentTermsValidityMonthDay,
      payment~bslndtecalcaddlmnths          AS addlmnths,   "追加月
      payment~cashdiscount1days             AS cadays      "日数
 FROM i_salesorganization WITH PRIVILEGED ACCESS AS sales
 INNER JOIN i_customercompany WITH PRIVILEGED ACCESS AS customerc
              ON customerc~companycode = sales~companycode
 INNER JOIN i_creditmanagementaccount  WITH PRIVILEGED ACCESS AS creditm
              ON creditm~creditsegment   = sales~salesorganization
             AND creditm~businesspartner = customerc~customer
 INNER JOIN i_customersalesarea        WITH PRIVILEGED ACCESS AS customers
              ON customers~salesorganization = sales~salesorganization
             AND customers~customer          = customerc~customer
 INNER JOIN i_customer                 WITH PRIVILEGED ACCESS AS customer
              ON customer~customer = customerc~customer
 LEFT OUTER JOIN i_creditmanagementaccount  WITH PRIVILEGED ACCESS AS credit
              ON credit~creditsegment   = sales~salesorganization
             AND credit~businesspartner = customerc~customer
 LEFT OUTER JOIN i_paymenttermsconditions   WITH PRIVILEGED ACCESS AS payment
              ON payment~paymentterms = customerc~paymentterms
 LEFT OUTER JOIN i_customerpaymenttermstext WITH PRIVILEGED ACCESS AS customerpay
              ON customerpay~customerpaymentterms = payment~paymentterms
             AND customerpay~Language = 'J'
           WHERE sales~salesorganization IN @lr_salesorganization
             AND customerc~customer  IN @lr_customer
  INTO TABLE @DATA(lt_customer).

    SORT lt_customer by salesorganization customer customername creditsegmentcurrency limitamount terms paymentterms PaymentTermsValidityMonthDay.
    DELETE ADJACENT DUPLICATES FROM lt_customer COMPARING salesorganization customer customername creditsegmentcurrency limitamount terms paymentterms.

    if lt_customer is NOT INITIAL.

        DATA(lt_customer_n) = lt_customer.

        SORT lt_customer_n BY customer
                              salesorganization.
        DELETE ADJACENT DUPLICATES FROM lt_customer_n
                              COMPARING customer
                                        salesorganization.
        IF lt_customer_n IS NOT INITIAL.
          SELECT
            salesd~SalesDocument,
            salesd~SalesDocumentItem,
            salesd~SoldToParty AS customer,
            salesd~salesorganization,
            salesd~salesdocumentdate AS zdate,
            salesd~netamount                "売上金額-予
          FROM i_salesdocumentitem         WITH PRIVILEGED ACCESS AS salesd
           FOR ALL ENTRIES IN @lt_customer_n
         WHERE salesd~SoldToParty               = @lt_customer_n-customer
           AND salesd~salesorganization        = @lt_customer_n-salesorganization
          INTO TABLE @DATA(lt_salesd).

          SELECT
            billing~BillingDocument,
            billing~payerparty AS customer,
            billing~salesorganization,
            billing~billingdocumentdate AS zdate,
            billing~totalnetamount,"売上金額-実(正味額)
            billing~totaltaxamount "売上金額-実（税額）
          FROM i_billingdocument WITH PRIVILEGED ACCESS AS billing
           FOR ALL ENTRIES IN @lt_customer_n
         WHERE billing~payerparty               = @lt_customer_n-customer
           AND billing~salesorganization        = @lt_customer_n-salesorganization
          INTO TABLE @DATA(lt_billing).

          SELECT
            glaccount~SourceLedger,
            glaccount~CompanyCode,
            glaccount~FiscalYear,
            glaccount~AccountingDocument,
            glaccount~LedgerGLLineItem,
            glaccount~Ledger,
            glaccount~customer,
            glaccount~salesorganization,
            glaccount~postingdate AS zdate,
            glaccount~amountincompanycodecurrency "与信利用額-実
          FROM i_glaccountlineitem WITH PRIVILEGED ACCESS AS glaccount
           FOR ALL ENTRIES IN @lt_customer_n
         WHERE glaccount~customer           = @lt_customer_n-customer
           AND glaccount~CompanyCode        = @lt_customer_n-companycode
           AND glaccount~accountingdocumentcategory <> 'A'
           AND glaccount~accountingdocumentcategory <> 'S'
          INTO TABLE @DATA(lt_glaccount).
        ENDIF.

        SORT lt_customer BY customer
                            salesorganization
                            limitamount .
    endif.

    CLEAR lv_rowno.
    LOOP AT lt_customer ASSIGNING  FIELD-SYMBOL(<lfs_customer>)
     GROUP BY ( customer = <lfs_customer>-customer
                salesorganization = <lfs_customer>-salesorganization
                limitamount        = <lfs_customer>-limitamount
                ).

      CLEAR ls_data.
      ls_data-customer           = <lfs_customer>-customer.
      ls_data-customer = |{ ls_data-customer alpha = out }|.
      ls_data-customername       = <lfs_customer>-customername.
      ls_data-limitamount        = <lfs_customer>-limitamount .
      ls_data-currency           = <lfs_customer>-creditsegmentcurrency.

      ls_data-zymonth1          = lv_zyear && '年度1月'.
      ls_data-zymonth2          = lv_zyear && '年度2月'.
      ls_data-zymonth3          = lv_zyear && '年度3月'.
      ls_data-zymonth4          = lv_zyear && '年度4月'.
      ls_data-zymonth5          = lv_zyear && '年度5月'.
      ls_data-zymonth6          = lv_zyear && '年度6月'.
      ls_data-zymonth7          = lv_zyear && '年度7月'.
      ls_data-zymonth8          = lv_zyear && '年度8月'.
      ls_data-zymonth9          = lv_zyear && '年度9月'.
      ls_data-zymonth10         = lv_zyear && '年度10月'.
      ls_data-zymonth11         = lv_zyear && '年度11月'.
      ls_data-zymonth12         = lv_zyear && '年度12月'.
      LOOP AT GROUP <lfs_customer> ASSIGNING FIELD-SYMBOL(<lfs_customerg>).

*         回収条件-何か月後回収
*         日数がゼロの場合は、追加月をそのまま取得
        IF <lfs_customerg>-cadays = 0.

          ls_data-terms1     = <lfs_customerg>-addlmnths.
          lv_termsno = |{ ls_data-terms1 alpha = out }|.
          ls_data-termstext1 = lv_termsno && 'か月後回収'.

*         日数がゼロ以外の場合
        ELSE.

          lv_day = <lfs_customerg>-cadays / 30.
          lv_day = ceil( lv_day ).
          ls_data-terms1     = lv_day + <lfs_customerg>-addlmnths.
          lv_termsno = |{ ls_data-terms1 alpha = out }|.
          ls_data-termstext1 = lv_termsno && 'か月後回収'.
        ENDIF.

*         回収条件-支払条件
        ls_data-termstext2 = <lfs_customerg>-terms.

*         売上金額-予
        LOOP AT lt_salesd ASSIGNING FIELD-SYMBOL(<lfs_salesd>)
                                    WHERE customer          = <lfs_customerg>-customer
                                      AND salesorganization = <lfs_customerg>-salesorganization
                                      AND zdate+0(4)        = lv_zyear.

          CASE <lfs_salesd>-zdate+4(2).
            WHEN 01.
              ls_data-zmonth1 = ls_data-zmonth1 + <lfs_salesd>-netamount.
            WHEN 02.
              ls_data-zmonth2 = ls_data-zmonth2 + <lfs_salesd>-netamount.
            WHEN 03.
              ls_data-zmonth3 = ls_data-zmonth3 + <lfs_salesd>-netamount.
            WHEN 04.
              ls_data-zmonth4 = ls_data-zmonth4 + <lfs_salesd>-netamount.
            WHEN 05.
              ls_data-zmonth5 = ls_data-zmonth5 + <lfs_salesd>-netamount.
            WHEN 06.
              ls_data-zmonth6 = ls_data-zmonth6 + <lfs_salesd>-netamount.
            WHEN 07.
              ls_data-zmonth7 = ls_data-zmonth7 + <lfs_salesd>-netamount.
            WHEN 08.
              ls_data-zmonth8 = ls_data-zmonth8 + <lfs_salesd>-netamount.
            WHEN 09.
              ls_data-zmonth9 = ls_data-zmonth9 + <lfs_salesd>-netamount.
            WHEN 10.
              ls_data-zmonth10 = ls_data-zmonth10 + <lfs_salesd>-netamount.
            WHEN 11.
              ls_data-zmonth11 = ls_data-zmonth11 + <lfs_salesd>-netamount.
            WHEN 12.
              ls_data-zmonth12 = ls_data-zmonth12 + <lfs_salesd>-netamount.
          ENDCASE.

        ENDLOOP.

        lv_rowno = lv_rowno + 1.
        ls_data-text1         = '売上金額:予SAP_SO納入日、正味額'.
        APPEND ls_data TO lt_data.

*         本月の売上金額-予
        CLEAR ls_data_salesd.
        MOVE-CORRESPONDING ls_data TO ls_data_salesd.

        CLEAR:
          ls_data-zpercent1,
          ls_data-zpercent2,
          ls_data-zpercent3,
          ls_data-zpercent4,
          ls_data-zpercent5,
          ls_data-zpercent6,
          ls_data-zpercent7,
          ls_data-zpercent8,
          ls_data-zpercent9,
          ls_data-zpercent10,
          ls_data-zpercent11,
          ls_data-zpercent12,
          ls_data-zmonth1,
          ls_data-zmonth2,
          ls_data-zmonth3,
          ls_data-zmonth4,
          ls_data-zmonth5,
          ls_data-zmonth6,
          ls_data-zmonth7,
          ls_data-zmonth8,
          ls_data-zmonth9,
          ls_data-zmonth10,
          ls_data-zmonth11,
          ls_data-zmonth12.

*         売上金額-実
        LOOP AT lt_billing ASSIGNING FIELD-SYMBOL(<lfs_billing>)
                                    WHERE customer          = <lfs_customerg>-customer
                                      AND salesorganization = <lfs_customerg>-salesorganization
                                      AND zdate+0(4)        = lv_zyear.
          CASE <lfs_billing>-zdate+4(2).
            WHEN 01.
              ls_data-zmonth1 = ls_data-zmonth1 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
            WHEN 02.
              ls_data-zmonth2 = ls_data-zmonth2 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
            WHEN 03.
              ls_data-zmonth3 = ls_data-zmonth3 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
            WHEN 04.
              ls_data-zmonth4 = ls_data-zmonth4 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
            WHEN 05.
              ls_data-zmonth5 = ls_data-zmonth5 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
            WHEN 06.
              ls_data-zmonth6 = ls_data-zmonth6 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
            WHEN 07.
              ls_data-zmonth7 = ls_data-zmonth7 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
            WHEN 08.
              ls_data-zmonth8 = ls_data-zmonth8 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
            WHEN 09.
              ls_data-zmonth9 = ls_data-zmonth9 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
            WHEN 10.
              ls_data-zmonth10 = ls_data-zmonth10 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
            WHEN 11.
              ls_data-zmonth11 = ls_data-zmonth11 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
            WHEN 12.
              ls_data-zmonth12 = ls_data-zmonth12 + <lfs_billing>-totalnetamount + <lfs_billing>-totaltaxamount.
          ENDCASE.
        ENDLOOP.

        lv_rowno = lv_rowno + 1.
        ls_data-text1         = '売上金額:実SAP売上実績税込価格'.
        APPEND ls_data TO lt_data.
        CLEAR:
          ls_data-zpercent1,
          ls_data-zpercent2,
          ls_data-zpercent3,
          ls_data-zpercent4,
          ls_data-zpercent5,
          ls_data-zpercent6,
          ls_data-zpercent7,
          ls_data-zpercent8,
          ls_data-zpercent9,
          ls_data-zpercent10,
          ls_data-zpercent11,
          ls_data-zpercent12,
          ls_data-zmonth1,
          ls_data-zmonth2,
          ls_data-zmonth3,
          ls_data-zmonth4,
          ls_data-zmonth5,
          ls_data-zmonth6,
          ls_data-zmonth7,
          ls_data-zmonth8,
          ls_data-zmonth9,
          ls_data-zmonth10,
          ls_data-zmonth11,
          ls_data-zmonth12.

*         与信利用額-予(1月)
        lv_date = lv_zyear && '0101'.
        ls_data-zmonth1 = ls_data_salesd-zmonth1.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth1 = ls_data-zmonth1 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.

*         与信利用額-予(2月)
        lv_date = lv_zyear && '0201'.
        ls_data-zmonth2 = ls_data_salesd-zmonth2.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth2 = ls_data-zmonth2 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.

*         与信利用額-予(3月)
        lv_date = lv_zyear && '0301'.
        ls_data-zmonth3 = ls_data_salesd-zmonth3.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth3 = ls_data-zmonth3 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.

*         与信利用額-予(4月)
        lv_date = lv_zyear && '0401'.
        ls_data-zmonth4 = ls_data_salesd-zmonth4.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth4 = ls_data-zmonth4 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.

*         与信利用額-予(5月)
        lv_date = lv_zyear && '0501'.
        ls_data-zmonth5 = ls_data_salesd-zmonth5.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth5 = ls_data-zmonth5 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.

*         与信利用額-予(6月)
        lv_date = lv_zyear && '0601'.
        ls_data-zmonth6 = ls_data_salesd-zmonth6.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth6 = ls_data-zmonth6 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.

*         与信利用額-予(7月)
        lv_date = lv_zyear && '0701'.
        ls_data-zmonth7 = ls_data_salesd-zmonth7.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth7 = ls_data-zmonth7 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.

*         与信利用額-予(8月)
        lv_date = lv_zyear && '0801'.
        ls_data-zmonth8 = ls_data_salesd-zmonth8.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth8 = ls_data-zmonth8 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.

*         与信利用額-予(9月)
        lv_date = lv_zyear && '0901'.
        ls_data-zmonth9 = ls_data_salesd-zmonth9.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth9 = ls_data-zmonth9 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.

*         与信利用額-予(10月)
        lv_date = lv_zyear && '1001'.
        ls_data-zmonth10 = ls_data_salesd-zmonth10.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth10 = ls_data-zmonth10 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.

*         与信利用額-予(11月)
        lv_date = lv_zyear && '1101'.
        ls_data-zmonth11 = ls_data_salesd-zmonth11.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth11 = ls_data-zmonth11 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.

*         与信利用額-予(12月)
        lv_date = lv_zyear && '1201'.
        ls_data-zmonth12 = ls_data_salesd-zmonth12.
        lv_terms = ls_data_salesd-terms1.

*         本月前のXか月間の売上金額-予
        DO lv_terms TIMES.

          lv_date = zzcl_common_utils=>calc_date_subtract(
            EXPORTING
              date   = lv_date
              month  = 1 ).

          lv_zyeart = lv_date+0(4).
          lv_zmoth  = lv_date+4(2).

          LOOP AT lt_salesd ASSIGNING <lfs_salesd>
                                      WHERE customer          = <lfs_customerg>-customer
                                        AND salesorganization = <lfs_customerg>-salesorganization
                                        AND zdate+0(4)        = lv_zyeart.
            CASE <lfs_salesd>-zdate+4(2).
              WHEN lv_zmoth.
                ls_data-zmonth12 = ls_data-zmonth12 + <lfs_salesd>-netamount.
            ENDCASE.
          ENDLOOP.
        ENDDO.
        lv_rowno = lv_rowno + 1.
        ls_data-text1         = '与信利用額:予SO残高_回収条件+1か月前'.
        APPEND ls_data TO lt_data.

*         限度使用率-予＝与信利用額-予/与信限度額
        CLEAR ls_data_xy.
        MOVE-CORRESPONDING ls_data TO ls_data_xy.

        try.
            ls_data_xy-zmonth1 = ls_data_xy-zmonth1 / ls_data_xy-limitamount.
            ls_data_xy-zmonth2 = ls_data_xy-zmonth2 / ls_data_xy-limitamount.
            ls_data_xy-zmonth3 = ls_data_xy-zmonth3 / ls_data_xy-limitamount.
            ls_data_xy-zmonth4 = ls_data_xy-zmonth4 / ls_data_xy-limitamount.
            ls_data_xy-zmonth5 = ls_data_xy-zmonth5 / ls_data_xy-limitamount.
            ls_data_xy-zmonth6 = ls_data_xy-zmonth6 / ls_data_xy-limitamount.
            ls_data_xy-zmonth7 = ls_data_xy-zmonth7 / ls_data_xy-limitamount.
            ls_data_xy-zmonth8 = ls_data_xy-zmonth8 / ls_data_xy-limitamount.
            ls_data_xy-zmonth9 = ls_data_xy-zmonth9 / ls_data_xy-limitamount.
            ls_data_xy-zmonth10 = ls_data_xy-zmonth10 / ls_data_xy-limitamount.
            ls_data_xy-zmonth11 = ls_data_xy-zmonth11 / ls_data_xy-limitamount.
            ls_data_xy-zmonth12 = ls_data_xy-zmonth12 / ls_data_xy-limitamount.
        CATCH cx_root  INTO DATA(exc).
            ls_data_xy-zmonth1 = 0.
            ls_data_xy-zmonth2 = 0.
            ls_data_xy-zmonth3 = 0.
            ls_data_xy-zmonth4 = 0.
            ls_data_xy-zmonth5 = 0.
            ls_data_xy-zmonth6 = 0.
            ls_data_xy-zmonth7 = 0.
            ls_data_xy-zmonth8 = 0.
            ls_data_xy-zmonth9 = 0.
            ls_data_xy-zmonth10 = 0.
            ls_data_xy-zmonth11 = 0.
            ls_data_xy-zmonth12 = 0.
        ENDTRY.

        CLEAR:
          ls_data-zpercent1,
          ls_data-zpercent2,
          ls_data-zpercent3,
          ls_data-zpercent4,
          ls_data-zpercent5,
          ls_data-zpercent6,
          ls_data-zpercent7,
          ls_data-zpercent8,
          ls_data-zpercent9,
          ls_data-zpercent10,
          ls_data-zpercent11,
          ls_data-zpercent12,
          ls_data-zmonth1,
          ls_data-zmonth2,
          ls_data-zmonth3,
          ls_data-zmonth4,
          ls_data-zmonth5,
          ls_data-zmonth6,
          ls_data-zmonth7,
          ls_data-zmonth8,
          ls_data-zmonth9,
          ls_data-zmonth10,
          ls_data-zmonth11,
          ls_data-zmonth12.

*         与信利用額-実
        LOOP AT lt_glaccount ASSIGNING FIELD-SYMBOL(<lfs_glaccount>)
                                    WHERE customer          = <lfs_customerg>-customer
                                      AND CompanyCode       = <lfs_customerg>-CompanyCode
                                      AND zdate+0(4)        = lv_zyear.
          CASE <lfs_glaccount>-zdate+4(2).
            WHEN 01.
              ls_data-zmonth1 = ls_data-zmonth1 + <lfs_glaccount>-amountincompanycodecurrency.
            WHEN 02.
              ls_data-zmonth2 = ls_data-zmonth2 + <lfs_glaccount>-amountincompanycodecurrency.
            WHEN 03.
              ls_data-zmonth3 = ls_data-zmonth3 + <lfs_glaccount>-amountincompanycodecurrency.
            WHEN 04.
              ls_data-zmonth4 = ls_data-zmonth4 + <lfs_glaccount>-amountincompanycodecurrency.
            WHEN 05.
              ls_data-zmonth5 = ls_data-zmonth5 + <lfs_glaccount>-amountincompanycodecurrency.
            WHEN 06.
              ls_data-zmonth6 = ls_data-zmonth6 + <lfs_glaccount>-amountincompanycodecurrency.
            WHEN 07.
              ls_data-zmonth7 = ls_data-zmonth7 + <lfs_glaccount>-amountincompanycodecurrency.
            WHEN 08.
              ls_data-zmonth8 = ls_data-zmonth8 + <lfs_glaccount>-amountincompanycodecurrency.
            WHEN 09.
              ls_data-zmonth9 = ls_data-zmonth9 + <lfs_glaccount>-amountincompanycodecurrency.
            WHEN 10.
              ls_data-zmonth10 = ls_data-zmonth10 + <lfs_glaccount>-amountincompanycodecurrency.
            WHEN 11.
              ls_data-zmonth11 = ls_data-zmonth11 + <lfs_glaccount>-amountincompanycodecurrency.
            WHEN 12.
              ls_data-zmonth12 = ls_data-zmonth12 + <lfs_glaccount>-amountincompanycodecurrency.
          ENDCASE.

        ENDLOOP.
        lv_rowno = lv_rowno + 1.
        ls_data-text1         = '与信利用額:実SAP売掛残高＋でんさい残高'.
        APPEND ls_data TO lt_data.

*         限度使用率-実＝与信利用額-実/与信限度額
        CLEAR ls_data_xs.
        MOVE-CORRESPONDING ls_data TO ls_data_xs.

        try.
            ls_data_xs-zmonth1 = ls_data_xs-zmonth1 / ls_data_xy-limitamount.
            ls_data_xs-zmonth2 = ls_data_xs-zmonth2 / ls_data_xy-limitamount.
            ls_data_xs-zmonth3 = ls_data_xs-zmonth3 / ls_data_xy-limitamount.
            ls_data_xs-zmonth4 = ls_data_xs-zmonth4 / ls_data_xy-limitamount.
            ls_data_xs-zmonth5 = ls_data_xs-zmonth5 / ls_data_xy-limitamount.
            ls_data_xs-zmonth6 = ls_data_xs-zmonth6 / ls_data_xy-limitamount.
            ls_data_xs-zmonth7 = ls_data_xs-zmonth7 / ls_data_xy-limitamount.
            ls_data_xs-zmonth8 = ls_data_xs-zmonth8 / ls_data_xy-limitamount.
            ls_data_xs-zmonth9 = ls_data_xs-zmonth9 / ls_data_xy-limitamount.
            ls_data_xs-zmonth10 = ls_data_xs-zmonth10 / ls_data_xy-limitamount.
            ls_data_xs-zmonth11 = ls_data_xs-zmonth11 / ls_data_xy-limitamount.
            ls_data_xs-zmonth12 = ls_data_xs-zmonth12 / ls_data_xy-limitamount.
        CATCH cx_root  INTO DATA(excc).
             ls_data_xs-zmonth1 = 0.
            ls_data_xs-zmonth2 = 0.
            ls_data_xs-zmonth3 = 0.
            ls_data_xs-zmonth4 = 0.
            ls_data_xs-zmonth5 = 0.
            ls_data_xs-zmonth6 = 0.
            ls_data_xs-zmonth7 = 0.
            ls_data_xs-zmonth8 = 0.
            ls_data_xs-zmonth9 = 0.
            ls_data_xs-zmonth10 = 0.
            ls_data_xs-zmonth11 = 0.
            ls_data_xs-zmonth12 = 0.
        ENDTRY.

        CLEAR:
          ls_data-zpercent1,
          ls_data-zpercent2,
          ls_data-zpercent3,
          ls_data-zpercent4,
          ls_data-zpercent5,
          ls_data-zpercent6,
          ls_data-zpercent7,
          ls_data-zpercent8,
          ls_data-zpercent9,
          ls_data-zpercent10,
          ls_data-zpercent11,
          ls_data-zpercent12,
          ls_data-zmonth1,
          ls_data-zmonth2,
          ls_data-zmonth3,
          ls_data-zmonth4,
          ls_data-zmonth5,
          ls_data-zmonth6,
          ls_data-zmonth7,
          ls_data-zmonth8,
          ls_data-zmonth9,
          ls_data-zmonth10,
          ls_data-zmonth11,
          ls_data-zmonth12.

*         限度使用額-予
        lv_rowno = lv_rowno + 1.
        ls_data_xy-text1         = '限度使用率:予利用見込÷限度額'.

        if ls_data_xy-zmonth1 <> 0.
          ls_data_xy-zpercent1 = '%'.
        ENDIF.
        if ls_data_xy-zmonth2 <> 0.
          ls_data_xy-zpercent2 = '%'.
        ENDIF.
        if ls_data_xy-zmonth3 <> 0.
          ls_data_xy-zpercent3 = '%'.
        ENDIF.
        if ls_data_xy-zmonth4 <> 0.
          ls_data_xy-zpercent4 = '%'.
        ENDIF.
        if ls_data_xy-zmonth5 <> 0.
          ls_data_xy-zpercent5 = '%'.
        ENDIF.
        if ls_data_xy-zmonth6 <> 0.
          ls_data_xy-zpercent6 = '%'.
        ENDIF.
        if ls_data_xy-zmonth7 <> 0.
          ls_data_xy-zpercent7 = '%'.
        ENDIF.
        if ls_data_xy-zmonth8 <> 0.
          ls_data_xy-zpercent8 = '%'.
        ENDIF.
        if ls_data_xy-zmonth9 <> 0.
          ls_data_xy-zpercent9 = '%'.
        ENDIF.
        if ls_data_xy-zmonth10 <> 0.
          ls_data_xy-zpercent10 = '%'.
        ENDIF.
        if ls_data_xy-zmonth11 <> 0.
          ls_data_xy-zpercent11 = '%'.
        ENDIF.
        if ls_data_xy-zmonth12 <> 0.
          ls_data_xy-zpercent12 = '%'.
        ENDIF.
        APPEND ls_data_xy TO lt_data.
        CLEAr ls_data_xy.

*         限度使用率-実
        lv_rowno = lv_rowno + 1.
        ls_data_xs-text1         = '限度使用率:実利用実績÷限度額'.

        if ls_data_xs-zmonth1 <> 0.
          ls_data_xs-zpercent1 = '%'.
        ENDIF.
        if ls_data_xs-zmonth2 <> 0.
          ls_data_xs-zpercent2 = '%'.
        ENDIF.
        if ls_data_xs-zmonth3 <> 0.
          ls_data_xs-zpercent3 = '%'.
        ENDIF.
        if ls_data_xs-zmonth4 <> 0.
          ls_data_xs-zpercent4 = '%'.
        ENDIF.
        if ls_data_xs-zmonth5 <> 0.
          ls_data_xs-zpercent5 = '%'.
        ENDIF.
        if ls_data_xs-zmonth6 <> 0.
          ls_data_xs-zpercent6 = '%'.
        ENDIF.
        if ls_data_xs-zmonth7 <> 0.
          ls_data_xs-zpercent7 = '%'.
        ENDIF.
        if ls_data_xs-zmonth8 <> 0.
          ls_data_xs-zpercent8 = '%'.
        ENDIF.
        if ls_data_xs-zmonth9 <> 0.
          ls_data_xs-zpercent9 = '%'.
        ENDIF.
        if ls_data_xs-zmonth10 <> 0.
          ls_data_xs-zpercent10 = '%'.
        ENDIF.
        if ls_data_xs-zmonth11 <> 0.
          ls_data_xs-zpercent11 = '%'.
        ENDIF.
        if ls_data_xs-zmonth12 <> 0.
          ls_data_xs-zpercent12 = '%'.
        ENDIF.
        APPEND ls_data_xs TO lt_data.
        clear ls_data_xs.
      ENDLOOP.
    ENDLOOP.

    io_response->set_total_number_of_records( lines( lt_data ) ).

    "Sort
    IF io_request->get_sort_elements( ) IS NOT INITIAL.
      zzcl_odata_utils=>orderby(
        EXPORTING
          it_order = io_request->get_sort_elements( )
        CHANGING
          ct_data  = lt_data ).
    ENDIF.

    "Page
    zzcl_odata_utils=>paging(
      EXPORTING
        io_paging = io_request->get_paging( )
      CHANGING
        ct_data   = lt_data ).

    io_response->set_data( lt_data ).

  ENDMETHOD.

ENDCLASS.
