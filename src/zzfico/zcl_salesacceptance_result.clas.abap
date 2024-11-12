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
      APPENDING TABLE @lt_1003.

    SORT lt_1003 BY salesorganization customer periodtype acceptperiod customerpo itemno.

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
