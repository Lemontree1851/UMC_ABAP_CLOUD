CLASS lhc_paidpaydocument DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:
      lty_request_t TYPE TABLE OF zr_paidpaydocument,

* input data structure 買掛金/売掛金仕訳
      BEGIN OF ts_item1_a,
        companycode        TYPE string,
        fiscalyear         TYPE string,
        postingdate1       TYPE string,
        postingdate2       TYPE string,
        customer           TYPE string,
        supplier           TYPE string,
        profitcenter       TYPE string,
        purchasinggroup    TYPE string,
        currency           TYPE string,
        ztype              TYPE string,
        chargeable         TYPE string,
        currentstockamount TYPE string,
        currentstocksemi   TYPE string,
        currentstockfin    TYPE string,
        currentstocktotal  TYPE string,
      END OF ts_item1_a,
      tt_item1_a TYPE STANDARD TABLE OF ts_item1_a WITH DEFAULT KEY,

      BEGIN OF ts_create_a,
        BEGIN OF to_create,
          items TYPE tt_item1_a,
        END OF to_create,
      END OF ts_create_a,

      BEGIN OF ts_response_a,
        companycode     TYPE c LENGTH 4,
        customer        TYPE kunnr,
        supplier        TYPE lifnr,
        profitcenter    TYPE prctr,
        purchasinggroup TYPE ekgrp,
        fiscalyear1     TYPE c LENGTH 4,
        document1       TYPE c LENGTH 10,
        fiscalyear2     TYPE c LENGTH 4,
        document2       TYPE c LENGTH 10,
        fiscalyear3     TYPE c LENGTH 4,
        document3       TYPE c LENGTH 10,
        fiscalyear4     TYPE c LENGTH 4,
        document4       TYPE c LENGTH 10,
        message         TYPE c LENGTH 500,
        status          TYPE c LENGTH 1,
      END OF ts_response_a,

      BEGIN OF ts_output_a,
        items TYPE STANDARD TABLE OF ts_response_a WITH EMPTY KEY,
      END OF ts_output_a,
* 買掛金/売掛金仕訳
      BEGIN OF ts_item1_b,
        companycode TYPE string,
        fiscalyear  TYPE string,
        postingdate TYPE string,
        customer    TYPE string,
        supplier    TYPE string,
        currency    TYPE string,
        ztype       TYPE string,
        ap          TYPE string,
        ar          TYPE string,
      END OF ts_item1_b,
      tt_item1_b TYPE STANDARD TABLE OF ts_item1_b WITH DEFAULT KEY,

      BEGIN OF ts_create_b,
        BEGIN OF to_create,
          items TYPE tt_item1_b,
        END OF to_create,
      END OF ts_create_b,

      BEGIN OF ts_response_b,
        companycode TYPE c LENGTH 4,
        customer    TYPE kunnr,
        supplier    TYPE lifnr,
        fiscalyear1 TYPE c LENGTH 4,
        document1   TYPE c LENGTH 10,
        fiscalyear2 TYPE c LENGTH 4,
        document2   TYPE c LENGTH 10,
        fiscalyear3 TYPE c LENGTH 4,
        document3   TYPE c LENGTH 10,
        fiscalyear4 TYPE c LENGTH 4,
        document4   TYPE c LENGTH 10,
        message     TYPE c LENGTH 500,
        status      TYPE c LENGTH 1,
      END OF ts_response_b,

      BEGIN OF ts_output_b,
        items TYPE STANDARD TABLE OF ts_response_b WITH EMPTY KEY,
      END OF ts_output_b,

      BEGIN OF ts_item2_a,
        companycode     TYPE bukrs,
        fiscalyear      TYPE gjahr,
        period          TYPE monat,
        customer        TYPE string,
        supplier        TYPE string,
        profitcenter    TYPE string,
        purchasinggroup TYPE string,
        belnr1          TYPE belnr_d,
        gjahr1          TYPE gjahr,
        belnr2          TYPE belnr_d,
        gjahr2          TYPE gjahr,
        belnr3          TYPE belnr_d,
        gjahr3          TYPE gjahr,
        belnr4          TYPE belnr_d,
        gjahr4          TYPE gjahr,
      END OF ts_item2_a,
      tt_item2_a TYPE STANDARD TABLE OF ts_item2_a WITH DEFAULT KEY,

      BEGIN OF ts_cancel_a,
        BEGIN OF to_cancel,
          items TYPE tt_item2_a,
        END OF to_cancel,
      END OF ts_cancel_a,

      BEGIN OF ts_item2_b,
        companycode TYPE bukrs,
        fiscalyear  TYPE gjahr,
        period      TYPE monat,
        customer    TYPE kunnr,
        supplier    TYPE lifnr,
        belnr1      TYPE belnr_d,
        gjahr1      TYPE gjahr,
        belnr2      TYPE belnr_d,
        gjahr2      TYPE gjahr,
        belnr3      TYPE belnr_d,
        gjahr3      TYPE gjahr,
        belnr4      TYPE belnr_d,
        gjahr4      TYPE gjahr,
      END OF ts_item2_b,
      tt_item2_b TYPE STANDARD TABLE OF ts_item2_b WITH DEFAULT KEY,

      BEGIN OF ts_cancel_b,
        BEGIN OF to_cancel,
          items TYPE tt_item2_b,
        END OF to_cancel,
      END OF ts_cancel_b.

    DATA:
      lt_1011 TYPE STANDARD TABLE OF ztfi_1011,
      ls_1011 TYPE ztfi_1011,
      lt_1013 TYPE STANDARD TABLE OF ztfi_1013,
      ls_1013 TYPE ztfi_1013.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR paidpaydocument RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE paidpaydocument.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE paidpaydocument.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE paidpaydocument.

    METHODS read FOR READ
      IMPORTING keys FOR READ paidpaydocument RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK paidpaydocument.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION paidpaydocument~processlogic RESULT result.

    METHODS post CHANGING ct_data       TYPE lty_request_t
                          cv_ztype      TYPE c
                          cv_fiscalyear TYPE gjahr
                          cv_period     TYPE monat.

    METHODS cancel CHANGING ct_data  TYPE lty_request_t
                            cv_ztype TYPE c.

ENDCLASS.

CLASS lhc_paidpaydocument IMPLEMENTATION.

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
    DATA lt_request TYPE TABLE OF zr_paidpaydocument.
    CHECK keys IS NOT INITIAL.
* Get parameter

    DATA(lv_ztype) = keys[ 1 ]-%param-ztype.
    DATA(lv_event) = keys[ 1 ]-%param-event.
    DATA(lv_fiscalyear) = keys[ 1 ]-%param-fiscalyear.
    DATA(lv_period) = keys[ 1 ]-%param-period.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).
      IF lv_event = 'POST'.
        post( CHANGING ct_data = lt_request
                       cv_ztype = lv_ztype
                       cv_fiscalyear = lv_fiscalyear
                       cv_period = lv_period ).

      ELSEIF lv_event = 'CANCEL'.
        cancel( CHANGING ct_data = lt_request
                       cv_ztype = lv_ztype ).
      ENDIF.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( zzkey = lv_json ) ) TO result.
    ENDLOOP.


  ENDMETHOD.

  METHOD post.
    DATA:
      lt_create_a   TYPE STANDARD TABLE OF ts_create_a,
      ls_create_a   TYPE ts_create_a,
      lt_item_a     TYPE STANDARD TABLE OF ts_item1_a,
      ls_item_a     TYPE ts_item1_a,
      lt_create_b   TYPE STANDARD TABLE OF ts_create_b,
      ls_create_b   TYPE ts_create_b,
      lt_item_b     TYPE STANDARD TABLE OF ts_item1_b,
      ls_item_b     TYPE ts_item1_b,
      lt_output_a   TYPE STANDARD TABLE OF ts_output_a,
      ls_response_a TYPE ts_response_a,
      es_response_a TYPE ts_output_a,
      lt_output_b   TYPE STANDARD TABLE OF ts_output_b,
      ls_response_b TYPE ts_response_b,
      es_response_b TYPE ts_output_b.

    DATA:
      lv_msg              TYPE string,
      lv_text             TYPE string,
      lv_url              TYPE string,
      lv_username         TYPE string,
      lv_pwd              TYPE string,
      lv_fiscalyearperiod TYPE i_fiscalyearperiodforvariant-fiscalyearperiod,
      lv_poper            TYPE poper,
      lv_postdate1        TYPE budat,
      lv_postdate2        TYPE budat,
      lc_header_content   TYPE string VALUE 'content-type',
      lc_content_type     TYPE string VALUE 'text/json'.

* Posting date
* V3 会计期间转换
    lv_poper = cv_period.
    lv_fiscalyearperiod = cv_fiscalyear && lv_poper.
    SELECT SINGLE *
      FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
     WHERE fiscalyearvariant = 'V3'
       AND fiscalyearperiod = @lv_fiscalyearperiod
      INTO @DATA(ls_v3).
    IF sy-subrc = 0.
      lv_postdate1 = ls_v3-fiscalperiodenddate.  "当月最后一天
    ENDIF.

    lv_fiscalyearperiod = ls_v3-nextfiscalperiodfiscalyear && ls_v3-nextfiscalperiod.
    SELECT SINGLE *                           "#EC CI_ALL_FIELDS_NEEDED
      FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
     WHERE fiscalyearvariant = 'V3'
       AND fiscalyearperiod = @lv_fiscalyearperiod
      INTO @ls_v3.
    IF sy-subrc = 0.
      lv_postdate2 = ls_v3-fiscalperiodstartdate.
    ENDIF.

    SELECT SINGLE zvalue2,
                  zvalue3
      FROM ztbc_1001
     WHERE zid = 'ZBC001'
       AND zvalue1 = 'BTP'
      INTO ( @lv_username,
             @lv_pwd ).

    CASE cv_ztype.
      WHEN 'A'.  "売上仕入仕訳
        LOOP AT ct_data INTO DATA(ls_data).
          ls_item_a-companycode = ls_data-companycode.
          ls_item_a-fiscalyear = ls_data-fiscalyear.
          ls_item_a-postingdate1 = lv_postdate1.
          ls_item_a-postingdate2 = lv_postdate2.
          ls_item_a-customer = ls_data-customer.
          ls_item_a-supplier = ls_data-supplier.
          ls_item_a-profitcenter = ls_data-profitcenter.
          ls_item_a-purchasinggroup = ls_data-purchasinggroup.
          ls_item_a-currency = ls_data-currency.
          ls_item_a-ztype = cv_ztype.
          ls_item_a-chargeable = ls_data-chargeableamount.
          ls_item_a-currentstockamount = ls_data-currentstockamount.
          ls_item_a-currentstocksemi = ls_data-currentstocksemi.
          ls_item_a-currentstockfin = ls_data-currentstockfin.
          ls_item_a-currentstocktotal = ls_data-currentstocktotal.
          APPEND ls_item_a TO lt_item_a.
          CLEAR: ls_item_a.
        ENDLOOP.
        ls_create_a-to_create-items = lt_item_a.
* Call API
        TRY.
            lv_url = cl_abap_context_info=>get_system_url( ) && 'sap/bc/http/sap/Z_HTTP_PAIDPAY_001'.
            DATA(lo_destination) = cl_http_destination_provider=>create_by_url( i_url = lv_url ).
          CATCH cx_abap_context_info_error INTO DATA(lx_context_error).
            IF sy-subrc = 0. ENDIF.
          CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
            IF sy-subrc = 0. ENDIF.
        ENDTRY.

        TRY.
            DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

            lo_http_client->get_http_request(  )->set_authorization_basic(
            i_username = lv_username
            i_password = lv_pwd ).

          CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
            IF sy-subrc = 0. ENDIF.
        ENDTRY.
        DATA(lo_http_request) = lo_http_client->get_http_request( ).
        /ui2/cl_json=>serialize(
            EXPORTING
              data = ls_create_a
              compress = 'X'
              pretty_name = /ui2/cl_json=>pretty_mode-camel_case
            RECEIVING
              r_json = DATA(json_post) ).

        lo_http_request->set_text( json_post ).
        lo_http_request->set_header_field( i_name = 'Content-Type' i_value = 'text/xml' ).
        lo_http_request->set_header_field( i_name = 'action' i_value = 'CREATE' ).

        TRY.
            DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
          CATCH cx_web_http_client_error INTO DATA(lx_http_error).
            IF sy-subrc = 0. ENDIF.
        ENDTRY.
        lo_response->get_status( RECEIVING r_value = DATA(ls_http_status) ).
        IF ls_http_status-code = 200
        OR ls_http_status-code = 201.
          DATA(lv_string) = lo_response->get_text( ).
          lv_string = '[' && lv_string && ']'.
          /ui2/cl_json=>deserialize(
                          EXPORTING json = lv_string
                          CHANGING data = lt_output_a ).
          READ TABLE lt_output_a INTO DATA(ls_output_a) INDEX 1.
          DATA(lt_a) = ls_output_a-items.

          LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
            READ TABLE lt_a INTO DATA(ls_a)
                 WITH KEY companycode = <lfs_data>-companycode
                          customer = <lfs_data>-customer
                          supplier = <lfs_data>-supplier
                          profitcenter = <lfs_data>-profitcenter
                          purchasinggroup = <lfs_data>-purchasinggroup.
            IF sy-subrc = 0.
              <lfs_data>-belnr1 = ls_a-document1.
              <lfs_data>-gjahr1 = ls_a-fiscalyear1.
              <lfs_data>-belnr2 = ls_a-document2.
              <lfs_data>-gjahr2 = ls_a-fiscalyear2.
              <lfs_data>-belnr3 = ls_a-document3.
              <lfs_data>-gjahr3 = ls_a-fiscalyear3.
              <lfs_data>-belnr4 = ls_a-document4.
              <lfs_data>-gjahr4 = ls_a-fiscalyear4.
              <lfs_data>-message = ls_a-message.
              <lfs_data>-status = ls_a-status.
            ENDIF.
          ENDLOOP.
        ELSE.
          lv_string = lo_response->get_text( ).
          LOOP AT ct_data ASSIGNING <lfs_data>.
            <lfs_data>-status = 'E'.
            <lfs_data>-message = lv_string.
          ENDLOOP.
        ENDIF.
* Modify DB
        LOOP AT ct_data INTO ls_data.
          MOVE-CORRESPONDING ls_data TO ls_1011.
          APPEND ls_1011 TO lt_1011.
          CLEAR: ls_1011.
        ENDLOOP.
        IF lt_1011 IS NOT INITIAL.
          MODIFY ztfi_1011 FROM TABLE @lt_1011.
        ENDIF.

      WHEN 'B'.  "買掛金/売掛金仕訳
        LOOP AT ct_data INTO ls_data.
          ls_item_b-companycode = ls_data-companycode.
          ls_item_b-fiscalyear = ls_data-fiscalyear.
          ls_item_b-postingdate = lv_postdate1.
          ls_item_b-customer = ls_data-customer.
          ls_item_b-supplier = ls_data-supplier.
          ls_item_b-currency = ls_data-currency.
          ls_item_b-ztype = cv_ztype.
          ls_item_b-ap = ls_data-ap.
          ls_item_b-ar = ls_data-ar.

          APPEND ls_item_b TO lt_item_b.
          CLEAR: ls_item_b.
        ENDLOOP.
        ls_create_b-to_create-items = lt_item_b.
* Call API
        TRY.
            lv_url = cl_abap_context_info=>get_system_url( ) && 'sap/bc/http/sap/Z_HTTP_PAIDPAY_002'.
            lo_destination = cl_http_destination_provider=>create_by_url( i_url = lv_url ).
          CATCH cx_abap_context_info_error INTO lx_context_error.
            IF sy-subrc = 0. ENDIF.
          CATCH cx_http_dest_provider_error INTO lx_http_dest_provider_error.
            IF sy-subrc = 0. ENDIF.
        ENDTRY.

        TRY.
            lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

            lo_http_client->get_http_request(  )->set_authorization_basic(
            i_username = lv_username
            i_password = lv_pwd ).

          CATCH cx_web_http_client_error INTO lx_web_http_client_error.
            IF sy-subrc = 0. ENDIF.
        ENDTRY.
        lo_http_request = lo_http_client->get_http_request( ).
        /ui2/cl_json=>serialize(
            EXPORTING
              data = ls_create_b
              compress = 'X'
              pretty_name = /ui2/cl_json=>pretty_mode-camel_case
            RECEIVING
              r_json = json_post ).

        lo_http_request->set_text( json_post ).
        lo_http_request->set_header_field( i_name = 'Content-Type' i_value = 'text/xml' ).
        lo_http_request->set_header_field( i_name = 'action' i_value = 'CREATE' ).

        TRY.
            lo_response = lo_http_client->execute( i_method = if_web_http_client=>post ).
          CATCH cx_web_http_client_error INTO lx_http_error.
            IF sy-subrc = 0. ENDIF.
        ENDTRY.
        lo_response->get_status( RECEIVING r_value = ls_http_status ).
        IF ls_http_status-code = 200
        OR ls_http_status-code = 201.
          lv_string = lo_response->get_text( ).
          lv_string = '[' && lv_string && ']'.
          /ui2/cl_json=>deserialize(
                          EXPORTING json = lv_string
                          CHANGING data = lt_output_b ).
          READ TABLE lt_output_b INTO DATA(ls_output_b) INDEX 1.
          DATA(lt_b) = ls_output_b-items.
          SORT lt_b BY companycode customer supplier.
          LOOP AT ct_data ASSIGNING <lfs_data>.
            READ TABLE lt_b INTO DATA(ls_b)
                 WITH KEY companycode = <lfs_data>-companycode
                          customer = <lfs_data>-customer
                          supplier = <lfs_data>-supplier BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_data>-belnr5 = ls_a-document1.
              <lfs_data>-gjahr5 = ls_a-fiscalyear1.
              <lfs_data>-belnr6 = ls_a-document2.
              <lfs_data>-gjahr6 = ls_a-fiscalyear2.
              <lfs_data>-belnr7 = ls_a-document3.
              <lfs_data>-gjahr7 = ls_a-fiscalyear3.
              <lfs_data>-belnr8 = ls_a-document4.
              <lfs_data>-gjahr8 = ls_a-fiscalyear4.
              <lfs_data>-message = ls_a-message.
              <lfs_data>-status = ls_a-status.
            ENDIF.
          ENDLOOP.
        ELSE.
          lv_string = lo_response->get_text( ).
          LOOP AT ct_data ASSIGNING <lfs_data>.
            <lfs_data>-status = 'E'.
            <lfs_data>-message = lv_string.
          ENDLOOP.
        ENDIF.

* Modify DB
        LOOP AT ct_data INTO ls_data.
          MOVE-CORRESPONDING ls_data TO ls_1013.
          ls_1013-belnr1 = ls_data-belnr5.
          ls_1013-gjahr1 = ls_data-gjahr5.
          ls_1013-belnr2 = ls_data-belnr6.
          ls_1013-gjahr2 = ls_data-gjahr6.
          ls_1013-belnr3 = ls_data-belnr7.
          ls_1013-gjahr3 = ls_data-gjahr7.
          ls_1013-belnr4 = ls_data-belnr8.
          ls_1013-gjahr4 = ls_data-gjahr8.
          APPEND ls_1013 TO lt_1013.
          CLEAR: ls_1013.
        ENDLOOP.
* Modify DB
        IF lt_1013 IS NOT INITIAL.
          MODIFY ztfi_1013 FROM TABLE @lt_1013.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

  METHOD cancel.
    DATA:
      lt_cancel_a   TYPE STANDARD TABLE OF ts_cancel_a,
      ls_cancel_a   TYPE ts_cancel_a,
      lt_item_a     TYPE STANDARD TABLE OF ts_item2_a,
      ls_item_a     TYPE ts_item2_a,
      lt_cancel_b   TYPE STANDARD TABLE OF ts_cancel_b,
      ls_cancel_b   TYPE ts_cancel_b,
      lt_item_b     TYPE STANDARD TABLE OF ts_item2_b,
      ls_item_b     TYPE ts_item2_b,
      lt_output_a   TYPE STANDARD TABLE OF ts_output_a,
      ls_response_a TYPE ts_response_a,
      es_response_a TYPE ts_output_a,
      lt_output_b   TYPE STANDARD TABLE OF ts_output_b,
      ls_response_b TYPE ts_response_b,
      es_response_b TYPE ts_output_b.

    DATA:
      lv_msg              TYPE string,
      lv_text             TYPE string,
      lv_url              TYPE string,
      lv_username         TYPE string,
      lv_pwd              TYPE string,
      lv_fiscalyearperiod TYPE i_fiscalyearperiodforvariant-fiscalyearperiod,
      lv_poper            TYPE poper,
      lc_header_content   TYPE string VALUE 'content-type',
      lc_content_type     TYPE string VALUE 'text/json'.

    SELECT SINGLE zvalue2,
                  zvalue3
      FROM ztbc_1001
     WHERE zid = 'ZBC001'
       AND zvalue1 = 'BTP'
      INTO ( @lv_username,
             @lv_pwd ).

    CASE cv_ztype.
      WHEN 'A'.  "売上仕入reverse
        LOOP AT ct_data INTO DATA(ls_data).
          ls_item_a-companycode = ls_data-companycode.
          ls_item_a-fiscalyear = ls_data-fiscalyear.
          ls_item_a-period = ls_data-period.
          ls_item_a-customer = ls_data-customer.
          ls_item_a-supplier = ls_data-supplier.
          ls_item_a-profitcenter = ls_data-profitcenter.
          ls_item_a-purchasinggroup = ls_data-purchasinggroup.
          ls_item_a-belnr1 = ls_data-belnr1.
          ls_item_a-gjahr1 = ls_data-gjahr1.
          ls_item_a-belnr2 = ls_data-belnr2.
          ls_item_a-gjahr2 = ls_data-gjahr2.
          ls_item_a-belnr3 = ls_data-belnr3.
          ls_item_a-gjahr3 = ls_data-gjahr3.
          ls_item_a-belnr4 = ls_data-belnr4.
          ls_item_a-gjahr4 = ls_data-gjahr4.
          APPEND ls_item_a TO lt_item_a.
          CLEAR: ls_item_a.
        ENDLOOP.
        ls_cancel_a-to_cancel-items = lt_item_a.
* Call API
        TRY.
            lv_url = cl_abap_context_info=>get_system_url( ) && 'sap/bc/http/sap/Z_HTTP_PAIDPAY_001'.
            DATA(lo_destination) = cl_http_destination_provider=>create_by_url( i_url = lv_url ).
          CATCH cx_abap_context_info_error INTO DATA(lx_context_error).
            IF sy-subrc = 0. ENDIF.
          CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
            IF sy-subrc = 0. ENDIF.
        ENDTRY.

        TRY.
            DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

            lo_http_client->get_http_request(  )->set_authorization_basic(
            i_username = lv_username
            i_password = lv_pwd ).

          CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
            IF sy-subrc = 0. ENDIF.
        ENDTRY.
        DATA(lo_http_request) = lo_http_client->get_http_request( ).
        /ui2/cl_json=>serialize(
            EXPORTING
              data = ls_cancel_a
              compress = 'X'
              pretty_name = /ui2/cl_json=>pretty_mode-camel_case
            RECEIVING
              r_json = DATA(json_post) ).

        lo_http_request->set_text( json_post ).
        lo_http_request->set_header_field( i_name = 'Content-Type' i_value = 'text/xml' ).
        lo_http_request->set_header_field( i_name = 'action' i_value = 'CANCEL' ).

        TRY.
            DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
          CATCH cx_web_http_client_error INTO DATA(lx_http_error).
            IF sy-subrc = 0. ENDIF.
        ENDTRY.
        lo_response->get_status( RECEIVING r_value = DATA(ls_http_status) ).
        IF ls_http_status-code = 200
        OR ls_http_status-code = 201.
          DATA(lv_string) = lo_response->get_text( ).
          lv_string = '[' && lv_string && ']'.
          /ui2/cl_json=>deserialize(
                          EXPORTING json = lv_string
                          CHANGING data = lt_output_a ).
          READ TABLE lt_output_a INTO DATA(ls_output_a) INDEX 1.
          DATA(lt_a) = ls_output_a-items.
          SORT lt_a BY companycode customer supplier profitcenter purchasinggroup.
          LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
            READ TABLE lt_a INTO DATA(ls_a)
                 WITH KEY companycode = <lfs_data>-companycode
                          customer = <lfs_data>-customer
                          supplier = <lfs_data>-supplier
                          profitcenter = <lfs_data>-profitcenter
                          purchasinggroup = <lfs_data>-purchasinggroup BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_data>-belnr1 = ls_a-document1.
              <lfs_data>-gjahr1 = ls_a-fiscalyear1.
              <lfs_data>-belnr2 = ls_a-document2.
              <lfs_data>-gjahr2 = ls_a-fiscalyear2.
              <lfs_data>-belnr3 = ls_a-document3.
              <lfs_data>-gjahr3 = ls_a-fiscalyear3.
              <lfs_data>-belnr4 = ls_a-document4.
              <lfs_data>-gjahr4 = ls_a-fiscalyear4.
              <lfs_data>-message = ls_a-message.
              <lfs_data>-status = ls_a-status.
            ENDIF.
          ENDLOOP.
        ELSE.
          lv_string = lo_response->get_text( ).
          LOOP AT ct_data ASSIGNING <lfs_data>.
            <lfs_data>-status = 'E'.
            <lfs_data>-message = lv_string.
          ENDLOOP.
        ENDIF.
        LOOP AT ct_data INTO ls_data.
          MOVE-CORRESPONDING ls_data TO ls_1011.
          APPEND ls_1011 TO lt_1011.
          CLEAR: ls_1011.
        ENDLOOP.
        IF lt_1011 IS NOT INITIAL.
          MODIFY ztfi_1011 FROM TABLE @lt_1011.
        ENDIF.
      WHEN 'B'.  "買掛金/売掛金reverse
        LOOP AT ct_data INTO ls_data.
          ls_item_b-companycode = ls_data-companycode.
          ls_item_b-fiscalyear = ls_data-fiscalyear.
          ls_item_b-period = ls_data-period.
          ls_item_b-customer = ls_data-customer.
          ls_item_b-supplier = ls_data-supplier.
          ls_item_b-belnr1 = ls_data-belnr1.
          ls_item_b-gjahr1 = ls_data-gjahr1.
          ls_item_b-belnr2 = ls_data-belnr2.
          ls_item_b-gjahr2 = ls_data-gjahr2.
          ls_item_b-belnr3 = ls_data-belnr3.
          ls_item_b-gjahr3 = ls_data-gjahr3.
          ls_item_b-belnr4 = ls_data-belnr4.
          ls_item_b-gjahr4 = ls_data-gjahr4.
          APPEND ls_item_b TO lt_item_b.
          CLEAR: ls_item_b.
        ENDLOOP.
        ls_cancel_b-to_cancel-items = lt_item_b.
* Call API
        TRY.
            lv_url = cl_abap_context_info=>get_system_url( ) && 'sap/bc/http/sap/Z_HTTP_PAIDPAY_002'.
            lo_destination = cl_http_destination_provider=>create_by_url( i_url = lv_url ).

          CATCH cx_abap_context_info_error INTO lx_context_error.
            IF sy-subrc = 0. ENDIF.
          CATCH cx_http_dest_provider_error INTO lx_http_dest_provider_error.
            IF sy-subrc = 0. ENDIF.
        ENDTRY.

        TRY.
            lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

            lo_http_client->get_http_request(  )->set_authorization_basic(
            i_username = lv_username
            i_password = lv_pwd ).

          CATCH cx_web_http_client_error INTO lx_web_http_client_error.
            IF sy-subrc = 0. ENDIF.
        ENDTRY.
        lo_http_request = lo_http_client->get_http_request( ).
        /ui2/cl_json=>serialize(
            EXPORTING
              data = ls_cancel_b
              compress = 'X'
              pretty_name = /ui2/cl_json=>pretty_mode-camel_case
            RECEIVING
              r_json = json_post ).

        lo_http_request->set_text( json_post ).
        lo_http_request->set_header_field( i_name = 'Content-Type' i_value = 'text/xml' ).
        lo_http_request->set_header_field( i_name = 'action' i_value = 'CANCEL' ).

        TRY.
            lo_response = lo_http_client->execute( i_method = if_web_http_client=>post ).
          CATCH cx_web_http_client_error INTO lx_http_error.
            IF sy-subrc = 0. ENDIF.
        ENDTRY.
        lo_response->get_status( RECEIVING r_value = ls_http_status ).
        IF ls_http_status-code = 200
        OR ls_http_status-code = 201.
          lv_string = lo_response->get_text( ).
          lv_string = '[' && lv_string && ']'.
          /ui2/cl_json=>deserialize(
                          EXPORTING json = lv_string
                          CHANGING data = lt_output_b ).
          READ TABLE lt_output_b INTO DATA(ls_output_b) INDEX 1.
          DATA(lt_b) = ls_output_b-items.
          SORT lt_b BY companycode customer supplier.
          LOOP AT ct_data ASSIGNING <lfs_data>.
            READ TABLE lt_b INTO DATA(ls_b)
                 WITH KEY companycode = <lfs_data>-companycode
                          customer = <lfs_data>-customer
                          supplier = <lfs_data>-supplier BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_data>-belnr5 = ls_a-document1.
              <lfs_data>-gjahr5 = ls_a-fiscalyear1.
              <lfs_data>-belnr6 = ls_a-document2.
              <lfs_data>-gjahr6 = ls_a-fiscalyear2.
              <lfs_data>-belnr7 = ls_a-document3.
              <lfs_data>-gjahr7 = ls_a-fiscalyear3.
              <lfs_data>-belnr8 = ls_a-document4.
              <lfs_data>-gjahr8 = ls_a-fiscalyear4.
              <lfs_data>-message = ls_a-message.
              <lfs_data>-status = ls_a-status.
            ENDIF.
          ENDLOOP.
        ELSE.
          lv_string = lo_response->get_text( ).
          LOOP AT ct_data ASSIGNING <lfs_data>.
            <lfs_data>-status = 'E'.
            <lfs_data>-message = lv_string.
          ENDLOOP.
        ENDIF.
* modify db
        LOOP AT ct_data INTO ls_data.
          MOVE-CORRESPONDING ls_data TO ls_1013.
          ls_1013-belnr1 = ls_data-belnr5.
          ls_1013-gjahr1 = ls_data-gjahr5.
          ls_1013-belnr2 = ls_data-belnr6.
          ls_1013-gjahr2 = ls_data-gjahr6.
          ls_1013-belnr3 = ls_data-belnr7.
          ls_1013-gjahr3 = ls_data-gjahr7.
          ls_1013-belnr4 = ls_data-belnr8.
          ls_1013-gjahr4 = ls_data-gjahr8.
          APPEND ls_1013 TO lt_1013.
          CLEAR: ls_1013.
        ENDLOOP.

        IF lt_1013 IS NOT INITIAL.
          MODIFY ztfi_1013 FROM TABLE @lt_1013.
        ENDIF.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_paidpaydocument DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_paidpaydocument IMPLEMENTATION.

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
