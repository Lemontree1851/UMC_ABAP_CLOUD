CLASS lhc_zr_salesacceptance_result DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF lty_request,
            status  TYPE c LENGTH 1,
            message TYPE c LENGTH 100,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    TYPES: lt_salesaccept TYPE TABLE OF zr_salesacceptance_result,
           lv_output(8)   TYPE p DECIMALS 5.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_salesacceptance_result RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zr_salesacceptance_result.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zr_salesacceptance_result.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zr_salesacceptance_result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zr_salesacceptance_result RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zr_salesacceptance_result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION zr_salesacceptance_result~processlogic RESULT result.

    METHODS save_1012 CHANGING ct_accept       TYPE lt_salesaccept
                               ct_data         TYPE lty_request_t
                               cv_periodtype   TYPE c
                               cv_acceptyear   TYPE gjahr
                               cv_acceptperiod TYPE monat.
    METHODS save_1003 CHANGING ct_accept       TYPE lt_salesaccept
                               ct_data         TYPE lty_request_t
                               cv_periodtype   TYPE c
                               cv_acceptyear   TYPE gjahr
                               cv_acceptperiod TYPE monat.
    METHODS convert_amount CHANGING cv_currency TYPE i_currency-currency
                                    cv_input    TYPE any
                                    cv_output   TYPE lv_output.

ENDCLASS.

CLASS lhc_zr_salesacceptance_result IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD processlogic.
    DATA:
      lt_request     TYPE TABLE OF lty_request,
      lt_salesaccept TYPE TABLE OF zr_salesacceptance_result.
    DATA:
      lv_acceptperiod TYPE monat,
      lv_acceptyear   TYPE gjahr.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.
    DATA(lv_ztype) = keys[ 1 ]-%param-ztype.
    DATA(lv_periodtype) = keys[ 1 ]-%param-periodtype.
    lv_acceptperiod = keys[ 1 ]-%param-acceptperiod.
    lv_acceptyear = keys[ 1 ]-%param-acceptyear.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_salesaccept.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_salesaccept ).

      CASE lv_ztype.
        WHEN '1'.
          save_1012( CHANGING ct_accept       = lt_salesaccept
                              ct_data         = lt_request
                              cv_periodtype   = lv_periodtype
                              cv_acceptyear   = lv_acceptyear
                              cv_acceptperiod = lv_acceptperiod ).
        WHEN '2'.
          save_1003( CHANGING ct_accept       = lt_salesaccept
                              ct_data         = lt_request
                              cv_periodtype   = lv_periodtype
                              cv_acceptyear   = lv_acceptyear
                              cv_acceptperiod = lv_acceptperiod ).
      ENDCASE.
    ENDLOOP.

    DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

    APPEND VALUE #( %cid   = key-%cid
                    %param = VALUE #( event = lv_event
                                      zzkey = lv_json ) ) TO result.
  ENDMETHOD.

  METHOD save_1012.
    DATA:
      lt_1012    TYPE STANDARD TABLE OF ztsd_1012,
      ls_1012    TYPE ztsd_1012,
      ls_request TYPE lty_request.

    SELECT *                                  "#EC CI_ALL_FIELDS_NEEDED
      FROM ztbc_1001
     WHERE zid = 'ZSD008'
        OR zid = 'ZSD009'
        OR zid = 'ZSD010'
      INTO TABLE @DATA(lt_1001).
* alpha in
    LOOP AT ct_accept ASSIGNING FIELD-SYMBOL(<lfs_accept>).
      <lfs_accept>-customer = |{ <lfs_accept>-customer ALPHA = IN }|.
      <lfs_accept>-salesdocument = |{ <lfs_accept>-salesdocument ALPHA = IN }|.
      <lfs_accept>-billingdocument = |{ <lfs_accept>-billingdocument ALPHA = IN }|.
      <lfs_accept>-product = |{ <lfs_accept>-product ALPHA = IN }|.
    ENDLOOP.

    IF ct_accept IS NOT INITIAL.
      SELECT *                                "#EC CI_ALL_FIELDS_NEEDED
        FROM ztsd_1012
        FOR ALL ENTRIES IN @ct_accept
       WHERE periodtype = @cv_periodtype
         AND acceptperiod = @ct_accept-acceptperiod
         AND salesdocument = @ct_accept-salesdocument
        INTO TABLE @DATA(lt_table).
    ENDIF.

    SELECT salesdocument,
           salesorganization,
           soldtoparty
      FROM i_salesdocument
      FOR ALL ENTRIES IN @ct_accept
     WHERE salesdocument = @ct_accept-salesdocument
      INTO TABLE @DATA(lt_so).

    SORT lt_so BY salesdocument.
    SORT lt_table BY salesdocument salesdocumentitem.
    LOOP AT ct_accept INTO DATA(ls_accept).
      READ TABLE lt_so INTO DATA(ls_so)
           WITH KEY salesdocument = ls_accept-salesdocument BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1012-salesorganization = ls_so-salesorganization.
        ls_1012-customer = ls_so-soldtoparty.
      ENDIF.

      ls_1012-periodtype = cv_periodtype.
      ls_1012-acceptyear = cv_acceptyear.
      ls_1012-acceptperiod = ls_accept-acceptperiod.
      ls_1012-salesdocument = ls_accept-salesdocument.
      ls_1012-salesdocumentitem = ls_accept-salesdocumentitem.
      ls_1012-billingdocument = ls_accept-billingdocument.
      ls_1012-customerpo = ls_accept-customerpo.
      ls_1012-salesdocumenttype = ls_accept-salesdocumenttype.
      ls_1012-acceptperiodfrom = ls_accept-acceptperiodfrom.
      ls_1012-acceptperiodto = ls_accept-acceptperiodto.
      ls_1012-product = ls_accept-product.
      ls_1012-salesdocumentitemtext = ls_accept-salesdocumentitemtext.
      ls_1012-postingdate = ls_accept-postingdate.
      ls_1012-acceptdate = ls_accept-acceptdate.
      ls_1012-acceptqty = ls_accept-acceptdate.
      ls_1012-billingquantity = ls_accept-billingquantity.
      convert_amount( CHANGING  cv_currency = ls_accept-currency
                                cv_input    = ls_accept-acceptprice
                                cv_output   = ls_1012-acceptprice ).
      ls_1012-conditionratevalue = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'IN'
                                                         iv_currency = ls_accept-currency
                                                         iv_input = ls_accept-conditionratevalue ).
      ls_1012-conditioncurrency = ls_accept-conditioncurrency.
      ls_1012-conditionquantity = ls_accept-conditionquantity.
      convert_amount( CHANGING  cv_currency = ls_accept-currency
                                cv_input    = ls_accept-accceptamount
                                cv_output   = ls_1012-accceptamount ).
      ls_1012-netamount = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'IN'
                                                         iv_currency = ls_accept-currency
                                                         iv_input = ls_accept-netamount ).
      convert_amount( CHANGING  cv_currency = ls_accept-currency
                                cv_input    = ls_accept-acccepttaxamount
                                cv_output   = ls_1012-acccepttaxamount ).
      ls_1012-taxamount = zzcl_common_utils=>conversion_amount(
                                                         iv_alpha = 'IN'
                                                         iv_currency = ls_accept-currency
                                                         iv_input = ls_accept-taxamount ).
      ls_1012-accceptcurrency = ls_accept-currency.
      ls_1012-accountingexchangerate = ls_accept-accountingexchangerate.
      ls_1012-exchangeratedate = ls_accept-exchangeratedate.
      ls_1012-outsidedata = ls_accept-outsidedata.
      ls_1012-remarks = ls_accept-remarks.
      READ TABLE lt_1001 INTO DATA(ls_1001)
                 WITH KEY zid = 'ZSD008'
                          zvalue2 = ls_accept-processstatus.
      IF sy-subrc = 0.
        ls_1012-processstatus = ls_1001-zvalue1.
      ELSE.
        ls_1012-processstatus = ls_accept-processstatus.
      ENDIF.

      "保留，同时更新old_status
      READ TABLE lt_table INTO DATA(ls_table)
           WITH KEY salesdocument = ls_accept-salesdocument
                    salesdocumentitem = ls_accept-salesdocumentitem BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1012-old_status = ls_table-old_status.
      ELSE.
        IF ls_1012-processstatus = '4'.
          ls_1012-old_status = '4'.
        ENDIF.
      ENDIF.
      READ TABLE lt_1001 INTO ls_1001
                 WITH KEY zid = 'ZSD009'
                          zvalue2 = ls_accept-reasoncategory.
      IF sy-subrc = 0.
        ls_1012-reasoncategory = ls_1001-zvalue1.
      ELSE.
        ls_1012-reasoncategory = ls_accept-reasoncategory.
      ENDIF.

      READ TABLE lt_1001 INTO ls_1001
                 WITH KEY zid = 'ZSD010'
                          zvalue2 = ls_accept-reason.
      IF sy-subrc = 0.
        ls_1012-reason = ls_1001-zvalue1.
      ELSE.
        ls_1012-reason = ls_accept-reason.
      ENDIF.
      APPEND ls_1012 TO lt_1012.
      CLEAR: ls_1012.
    ENDLOOP.

    IF lt_1012 IS NOT INITIAL.
      MODIFY ztsd_1012 FROM TABLE @lt_1012.
      IF sy-subrc = 0.
        ls_request-status = 'S'.
        ls_request-message = TEXT-001.
        APPEND ls_request TO ct_data.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD save_1003.
    DATA:
      lt_1003    TYPE STANDARD TABLE OF ztsd_1003,
      ls_1003    TYPE ztsd_1003,
      ls_request TYPE lty_request.

* Ckeck if proccessstatus = 2
    READ TABLE ct_accept WITH KEY processstatus = '処理待ち' TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      ls_request-status = 'E'.
      ls_request-message = TEXT-003.
      APPEND ls_request TO ct_data.
      RETURN.
    ENDIF.
* alpha in
    LOOP AT ct_accept ASSIGNING FIELD-SYMBOL(<lfs_accept>).
      <lfs_accept>-customer = |{ <lfs_accept>-customer ALPHA = IN }|.
      <lfs_accept>-salesdocument = |{ <lfs_accept>-salesdocument ALPHA = IN }|.
      <lfs_accept>-billingdocument = |{ <lfs_accept>-billingdocument ALPHA = IN }|.
      <lfs_accept>-product = |{ <lfs_accept>-product ALPHA = IN }|.
      <lfs_accept>-periodtype = cv_periodtype.
    ENDLOOP.

    SELECT *
      FROM ztsd_1003
      FOR ALL ENTRIES IN @ct_accept
     WHERE periodtype = @cv_periodtype
       AND acceptperiod = @ct_accept-acceptperiod
       AND customerpo = @ct_accept-customerpo
      INTO TABLE @DATA(lt_table).


    SELECT salesdocument,
           salesorganization,
           soldtoparty
      FROM i_salesdocument
      FOR ALL ENTRIES IN @ct_accept
     WHERE salesdocument = @ct_accept-salesdocument
      INTO TABLE @DATA(lt_so).

    SORT lt_so BY salesdocument.
    LOOP AT ct_accept ASSIGNING <lfs_accept>.
      READ TABLE lt_so INTO DATA(ls_so)
           WITH KEY salesdocument = <lfs_accept>-salesdocument BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_accept>-customer = ls_so-soldtoparty.
        <lfs_accept>-salesorganization = ls_so-salesorganization.
      ENDIF.
    ENDLOOP.

    DELETE ct_accept WHERE processstatus = '保留'.
    SORT ct_accept BY salesorganization customer periodtype acceptperiod customerpo.
    LOOP AT lt_table INTO ls_1003.
      READ TABLE ct_accept INTO DATA(ls_accept)
           WITH KEY salesorganization = ls_1003-salesorganization
                    customer = ls_1003-customer
                    periodtype = cv_periodtype
                    acceptperiod = ls_1003-acceptperiod
                    customerpo = ls_1003-customerpo.
      IF sy-subrc = 0.
        ls_1003-finishstatus = '1'.
        APPEND ls_1003 TO lt_1003.
        CLEAR: ls_1003.
      ENDIF.
    ENDLOOP.
    IF lt_1003 IS NOT INITIAL.
      MODIFY ztsd_1003 FROM TABLE @lt_1003.
      IF sy-subrc = 0.
        ls_request-status = 'S'.
        ls_request-message = TEXT-002.
        APPEND ls_request TO ct_data.
      ENDIF.
    ELSE.
      ls_request-status = 'S'.
      ls_request-message = TEXT-002.
      APPEND ls_request TO ct_data.
    ENDIF.
  ENDMETHOD.

  METHOD convert_amount.
    DATA: int_shift          TYPE i,
          dec_amount_int(12) TYPE p DECIMALS 5,
          struct_tcurx       TYPE i_currency.

    SELECT SINGLE * FROM i_currency WHERE currency = @cv_currency INTO @struct_tcurx. "#EC CI_ALL_FIELDS_NEEDED

    IF sy-subrc = 0. "Currency has a number of decimals not equal two
      int_shift = 2 - struct_tcurx-decimals.
    ELSE. "Currency is no exceptional currency. It has two decimals
      int_shift = 0.
    ENDIF.

    " Fill AMOUNT_EXTERNAL and shift decimal point depending on CURRENCY
    dec_amount_int = cv_input.
    DO int_shift TIMES.
      dec_amount_int = dec_amount_int / 10.
    ENDDO.
    cv_output = dec_amount_int.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_salesacceptance_result DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_salesacceptance_result IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
