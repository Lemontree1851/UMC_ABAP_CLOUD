CLASS zcl_http_paidpay_002 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ts_item1,
        companycode  TYPE string,
        fiscalyear   TYPE string,
        period       TYPE string,
        postingdate1 TYPE string,
        postingdate2 TYPE string,
        customer     TYPE string,
        supplier     TYPE string,
        currency     TYPE string,
        ztype        TYPE string,
        ap           TYPE string,
        ar           TYPE string,
      END OF ts_item1,

      tt_item1 TYPE STANDARD TABLE OF ts_item1 WITH DEFAULT KEY,

      BEGIN OF ts_create,
        BEGIN OF to_create,
          items TYPE tt_item1,
        END OF to_create,
      END OF ts_create,

      BEGIN OF ts_item2,
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
      END OF ts_item2,
      tt_item2 TYPE STANDARD TABLE OF ts_item2 WITH DEFAULT KEY,

      BEGIN OF ts_cancel,
        BEGIN OF to_cancel,
          items TYPE tt_item2,
        END OF to_cancel,
      END OF ts_cancel,

      BEGIN OF ts_response,
        _company_code TYPE bukrs,
        _customer     TYPE kunnr,
        _supplier     TYPE lifnr,
        _fiscal_year  TYPE gjahr,
        _period       TYPE monat,
        _document1    TYPE c LENGTH 10,
        _fiscal_year1 TYPE c LENGTH 4,
        _document2    TYPE c LENGTH 10,
        _fiscal_year2 TYPE c LENGTH 4,
        _document3    TYPE c LENGTH 10,
        _fiscal_year3 TYPE c LENGTH 4,
        _document4    TYPE c LENGTH 10,
        _fiscal_year4 TYPE c LENGTH 4,
        _message      TYPE c LENGTH 500,
        _status       TYPE c LENGTH 1,
      END OF ts_response,

      BEGIN OF ts_output,
        items TYPE STANDARD TABLE OF ts_response WITH EMPTY KEY,
      END OF ts_output.

    TYPES:
      lt_deep_t     TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
      lt_deep_rev_t TYPE TABLE FOR ACTION IMPORT i_journalentrytp~reverse,
      ls_response_t TYPE ts_response.

    METHODS post CHANGING ct_deep     TYPE lt_deep_t
                          cs_response TYPE ls_response_t
                          cv_fail     TYPE c
                          cv_i        TYPE i.

    METHODS cancel  CHANGING ct_deep     TYPE lt_deep_rev_t
                             cs_response TYPE ls_response_t
                             cv_fail     TYPE c
                             cv_i        TYPE i.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      ls_create_in      TYPE ts_create,
      ls_cancel_in      TYPE ts_cancel,
      lv_msg(220)       TYPE c,
      lv_text           TYPE string,
      lt_response       TYPE STANDARD TABLE OF ts_response,
      ls_response       TYPE ts_response,
      es_response       TYPE ts_output,
      lc_header_content TYPE string VALUE 'content-type',
      lc_content_type   TYPE string VALUE 'text/json',
      lo_root_exc       TYPE REF TO cx_root.
ENDCLASS.



CLASS ZCL_HTTP_PAIDPAY_002 IMPLEMENTATION.


  METHOD cancel.
    DATA:
      lv_msg     TYPE string,
      lv_message TYPE string.
    FIELD-SYMBOLS: <fs> TYPE any.
    MODIFY ENTITIES OF i_journalentrytp
            ENTITY journalentry
            EXECUTE reverse  FROM ct_deep
              FAILED DATA(ls_failed)
              REPORTED DATA(ls_reported)
              MAPPED DATA(ls_mapped).

    IF ls_failed IS NOT INITIAL.
      cv_fail = 'X'.
      LOOP AT ls_reported-journalentry INTO DATA(ls_reported_rev).
        DATA(lv_msgty) = ls_reported_rev-%msg->if_t100_dyn_msg~msgty.
        IF lv_msgty = 'E'.
          lv_msg = ls_reported_rev-%msg->if_message~get_text( ).
          lv_message = zzcl_common_utils=>merge_message(
                         iv_message1 = lv_message
                         iv_message2 = lv_msg
                         iv_symbol = '\' ).
        ENDIF.
      ENDLOOP.
      cs_response-_status  = 'E'.
      cs_response-_message = lv_message.
    ELSE.
      COMMIT ENTITIES BEGIN
        RESPONSE OF i_journalentrytp
        FAILED DATA(lt_commit_failed)
        REPORTED DATA(lt_commit_reported).
      IF sy-subrc = 0.
        cs_response-_status  = 'S'.
      ENDIF.
      COMMIT ENTITIES END.

      IF lt_commit_failed IS NOT INITIAL.
        cv_fail = 'X'.
        LOOP AT lt_commit_reported-journalentry INTO DATA(ls_commit_rep).
          lv_msgty = ls_commit_rep-%msg->if_t100_dyn_msg~msgty.
          IF lv_msgty = 'E'.
            lv_msg = ls_commit_rep-%msg->if_message~get_text( ).
            lv_message = zzcl_common_utils=>merge_message(
                           iv_message1 = lv_message
                           iv_message2 = lv_msg
                           iv_symbol = '\' ).
          ENDIF.
        ENDLOOP.
        cs_response-_status  = 'E'.
        cs_response-_message = lv_message.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    DATA:
      lt_deep     TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
      ls_deep     TYPE STRUCTURE FOR ACTION IMPORT i_journalentrytp~post,
      lt_deep_rev TYPE TABLE FOR ACTION IMPORT i_journalentrytp~reverse,
      ls_deep_rev TYPE STRUCTURE FOR ACTION IMPORT i_journalentrytp~reverse.


    DATA:
      i          TYPE i,
      lv_cr(9)   TYPE p DECIMALS 2,
      lv_cr1(9)  TYPE p DECIMALS 2,
      lv_cr2(9)  TYPE p DECIMALS 2,
      lv_dr(9)   TYPE p DECIMALS 2,
      lv_msg     TYPE string,
      lv_message TYPE string,
      lv_fail    TYPE c LENGTH 1.

    DATA(lv_req_body) = request->get_text( ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lv_header) = request->get_header_field( i_name = 'action' ).

    IF lv_header = 'CREATE'.
      /ui2/cl_json=>deserialize(
         EXPORTING
           json             = lv_req_body
           pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
         CHANGING
           data             = ls_create_in ).
    ELSE.
      /ui2/cl_json=>deserialize(
         EXPORTING
           json             = lv_req_body
           pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
         CHANGING
           data             = ls_cancel_in ).
    ENDIF.

* Post
    IF lv_header = 'CREATE'.
      DATA(lt_create) = ls_create_in-to_create-items.
      LOOP AT lt_create INTO DATA(ls_create).
*        ls_create-customer = | { ls_create-customer ALPHA = IN } |.
*        ls_create-supplier = | { ls_create-supplier ALPHA = IN } |.
        IF ls_create-ap >= ls_create-ar.
          lv_dr = ls_create-ap.
        ELSE.
          lv_dr = ls_create-ar.
        ENDIF.
        lv_cr = -1 * lv_dr.
* 1st document
        i += 1.
        ls_deep-%cid = |My%CID_{ i }|.

        ls_deep-%param-companycode = ls_create-companycode.
        ls_deep-%param-accountingdocumenttype = 'Z2'.
        ls_deep-%param-documentdate = ls_create-postingdate1.
        ls_deep-%param-postingdate = ls_create-postingdate1.
        ls_deep-%param-createdbyuser = sy-uname.

        ls_deep-%param-_apitems =
          VALUE #(
            ( glaccountlineitem = |001|
              supplier = ls_create-supplier
              _currencyamount =
                VALUE #( ( currencyrole = '00' journalentryitemamount = lv_dr currency = ls_create-currency ) )
            )
          ).
        ls_deep-%param-_aritems =
          VALUE #(
            ( glaccountlineitem = |002|
              customer = ls_create-customer
              _currencyamount =
                VALUE #( ( currencyrole = '00' journalentryitemamount = lv_cr currency = ls_create-currency ) )
            )
          ).
        APPEND ls_deep TO lt_deep.
        post( CHANGING ct_deep = lt_deep
                       cs_response = ls_response
                       cv_fail = lv_fail
                       cv_i = i ).
        CLEAR: ls_deep, lt_deep.
* 2nd document: 上記仕訳の逆仕訳
        IF lv_fail IS INITIAL.
          i += 1.
          ls_deep-%cid = |My%CID_{ i }|.

          ls_deep-%param-companycode = ls_create-companycode.
          ls_deep-%param-accountingdocumenttype = 'Z2'.
          ls_deep-%param-documentdate = ls_create-postingdate1.
          ls_deep-%param-postingdate = ls_create-postingdate1.
          ls_deep-%param-createdbyuser = sy-uname.
          ls_deep-%param-_aritems =
            VALUE #(
              ( glaccountlineitem = |001|
                customer = ls_create-customer
                _currencyamount =
                  VALUE #( ( currencyrole = '00' journalentryitemamount = lv_dr currency = ls_create-currency ) )
              )
            ).
          ls_deep-%param-_apitems =
            VALUE #(
              ( glaccountlineitem = |002|
                supplier = ls_create-supplier
                _currencyamount =
                  VALUE #( ( currencyrole = '00' journalentryitemamount = lv_cr currency = ls_create-currency ) )
              )
            ).
          APPEND ls_deep TO lt_deep.
          post( CHANGING ct_deep = lt_deep
                         cs_response = ls_response
                         cv_fail = lv_fail
                         cv_i = i ).
          CLEAR: ls_deep, lt_deep.
        ENDIF.
* 3rd document
        IF ls_create-ap > ls_create-ar.
          lv_dr = ls_create-ap - ls_create-ar.
          lv_cr = -1 * lv_dr.
        ENDIF.

        i += 1.
        ls_deep-%cid = |My%CID_{ i }|.

        ls_deep-%param-companycode = ls_create-companycode.
        ls_deep-%param-accountingdocumenttype = 'Z2'.
        ls_deep-%param-documentdate = ls_create-postingdate2.
        ls_deep-%param-postingdate = ls_create-postingdate2.
        ls_deep-%param-createdbyuser = sy-uname.
        ls_deep-%param-_apitems =
          VALUE #(
            ( glaccountlineitem = |001|
              supplier = ls_create-supplier
              _currencyamount =
                VALUE #( ( currencyrole = '00' journalentryitemamount = lv_dr currency = ls_create-currency ) )
            )
            ( glaccountlineitem = |002|
              supplier = ls_create-supplier
              glaccount = '0021101000'
              _currencyamount =
                VALUE #( ( currencyrole = '00' journalentryitemamount = lv_cr currency = ls_create-currency ) )
            )
          ).
        APPEND ls_deep TO lt_deep.
        post( CHANGING ct_deep = lt_deep
                       cs_response = ls_response
                       cv_fail = lv_fail
                       cv_i = i ).
        CLEAR: ls_deep, lt_deep.
* 4th document
        IF lv_fail IS INITIAL.
          i += 1.
          ls_deep-%cid = |My%CID_{ i }|.

          ls_deep-%param-companycode = ls_create-companycode.
          ls_deep-%param-accountingdocumenttype = 'Z2'.
          ls_deep-%param-documentdate = ls_create-postingdate2.
          ls_deep-%param-postingdate = ls_create-postingdate2.
          ls_deep-%param-createdbyuser = sy-uname.
          ls_deep-%param-_apitems =
            VALUE #(
              ( glaccountlineitem = |001|
                supplier = ls_create-supplier
                glaccount = '0021101000'
                _currencyamount =
                  VALUE #( ( currencyrole = '00' journalentryitemamount = lv_dr currency = ls_create-currency ) )
              )
              ( glaccountlineitem = |002|
                supplier = ls_create-supplier
                _currencyamount =
                  VALUE #( ( currencyrole = '00' journalentryitemamount = lv_cr currency = ls_create-currency ) )
              )
            ).
          APPEND ls_deep TO lt_deep.
          post( CHANGING ct_deep = lt_deep
                        cs_response = ls_response
                        cv_fail = lv_fail
                        cv_i = i ).
          CLEAR: ls_deep, lt_deep.
        ENDIF.
* Edit output response
        ls_response-_company_code = ls_create-companycode.
        ls_response-_fiscal_year = ls_create-fiscalyear.
        ls_response-_period = ls_create-period.
        ls_response-_customer = ls_create-customer.
        ls_response-_supplier = ls_create-supplier.
        APPEND ls_response TO es_response-items.
        CLEAR: ls_response, lv_fail, i.
      ENDLOOP.

    ELSE.
* Reverse
      DATA(lt_cancel) = ls_cancel_in-to_cancel-items.

      SELECT companycode,
             fiscalyear,
             accountingdocument,
             postingdate
        FROM i_journalentry
        FOR ALL ENTRIES IN @lt_cancel
       WHERE companycode = @lt_cancel-companycode
         AND fiscalyear = @lt_cancel-fiscalyear
         AND ( accountingdocument = @lt_cancel-belnr1
            OR accountingdocument = @lt_cancel-belnr2
            OR accountingdocument = @lt_cancel-belnr3
            OR accountingdocument = @lt_cancel-belnr4 )
        INTO TABLE @DATA(lt_bkpf).

      SORT lt_bkpf BY companycode fiscalyear accountingdocument.
      LOOP AT lt_cancel INTO DATA(ls_cancel).
* 1st document
        READ TABLE lt_bkpf INTO DATA(ls_bkpf)
             WITH KEY companycode = ls_cancel-companycode
                      fiscalyear = ls_cancel-fiscalyear
                      accountingdocument = ls_cancel-belnr1 BINARY SEARCH.
        IF sy-subrc = 0.
          ls_deep_rev-%key-accountingdocument = ls_cancel-belnr1.
          ls_deep_rev-%key-companycode = ls_cancel-companycode.
          ls_deep_rev-%key-fiscalyear = ls_cancel-fiscalyear.
          ls_deep_rev-accountingdocument = ls_cancel-belnr1.
          ls_deep_rev-companycode = ls_cancel-companycode.
          ls_deep_rev-fiscalyear = ls_cancel-fiscalyear.
          ls_deep_rev-%param = VALUE #(
                                 postingdate = ls_bkpf-postingdate
                                 reversalreason = '01'
                                 createdbyuser = sy-uname
                               ).
          APPEND ls_deep_rev TO lt_deep_rev.
          cancel( CHANGING ct_deep = lt_deep_rev
                           cs_response = ls_response
                           cv_fail = lv_fail
                           cv_i = i ).
          IF ls_response-_status = 'E'.
            ls_response-_document1 = ls_cancel-belnr1.
            ls_response-_fiscal_year1 = ls_cancel-gjahr1.
          ENDIF.
          CLEAR: ls_deep_rev, lt_deep_rev.
        ENDIF.
* 2nd document
        IF lv_fail IS INITIAL.
          READ TABLE lt_bkpf INTO ls_bkpf
                       WITH KEY companycode = ls_cancel-companycode
                                fiscalyear = ls_cancel-fiscalyear
                                accountingdocument = ls_cancel-belnr2 BINARY SEARCH.
          IF sy-subrc = 0.
            ls_deep_rev-%key-accountingdocument = ls_cancel-belnr2.
            ls_deep_rev-%key-companycode = ls_cancel-companycode.
            ls_deep_rev-%key-fiscalyear = ls_cancel-fiscalyear.
            ls_deep_rev-accountingdocument = ls_cancel-belnr2.
            ls_deep_rev-companycode = ls_cancel-companycode.
            ls_deep_rev-fiscalyear = ls_cancel-fiscalyear.
            ls_deep_rev-%param = VALUE #(
                                   postingdate = ls_bkpf-postingdate
                                   reversalreason = '01'
                                   createdbyuser = sy-uname
                                 ).
            APPEND ls_deep_rev TO lt_deep_rev.
            cancel( CHANGING ct_deep = lt_deep_rev
                             cs_response = ls_response
                             cv_fail = lv_fail
                             cv_i = i ).
            IF ls_response-_status = 'E'.
              ls_response-_document2 = ls_cancel-belnr2.
              ls_response-_fiscal_year2 = ls_cancel-gjahr2.
            ENDIF.
            CLEAR: ls_deep_rev, lt_deep_rev.
          ENDIF.
        ENDIF.
* 3rd document
        IF lv_fail IS INITIAL.
          READ TABLE lt_bkpf INTO ls_bkpf
                       WITH KEY companycode = ls_cancel-companycode
                                fiscalyear = ls_cancel-fiscalyear
                                accountingdocument = ls_cancel-belnr3 BINARY SEARCH.
          IF sy-subrc = 0.
            ls_deep_rev-%key-accountingdocument = ls_cancel-belnr3.
            ls_deep_rev-%key-companycode = ls_cancel-companycode.
            ls_deep_rev-%key-fiscalyear = ls_cancel-fiscalyear.
            ls_deep_rev-accountingdocument = ls_cancel-belnr3.
            ls_deep_rev-companycode = ls_cancel-companycode.
            ls_deep_rev-fiscalyear = ls_cancel-fiscalyear.
            ls_deep_rev-%param = VALUE #(
                                   postingdate = ls_bkpf-postingdate
                                   reversalreason = '01'
                                   createdbyuser = sy-uname
                                 ).
            APPEND ls_deep_rev TO lt_deep_rev.
            cancel( CHANGING ct_deep = lt_deep_rev
                             cs_response = ls_response
                             cv_fail = lv_fail
                             cv_i = i ).
            IF ls_response-_status = 'E'.
              ls_response-_document3 = ls_cancel-belnr3.
              ls_response-_fiscal_year3 = ls_cancel-gjahr3.
            ENDIF.
            CLEAR: ls_deep_rev, lt_deep_rev.
          ENDIF.
        ENDIF.
* 4th document
        IF lv_fail IS INITIAL.
          READ TABLE lt_bkpf INTO ls_bkpf
                       WITH KEY companycode = ls_cancel-companycode
                                fiscalyear = ls_cancel-fiscalyear
                                accountingdocument = ls_cancel-belnr4 BINARY SEARCH.
          IF sy-subrc = 0.
            ls_deep_rev-%key-accountingdocument = ls_cancel-belnr4.
            ls_deep_rev-%key-companycode = ls_cancel-companycode.
            ls_deep_rev-%key-fiscalyear = ls_cancel-fiscalyear.
            ls_deep_rev-accountingdocument = ls_cancel-belnr4.
            ls_deep_rev-companycode = ls_cancel-companycode.
            ls_deep_rev-fiscalyear = ls_cancel-fiscalyear.
            ls_deep_rev-%param = VALUE #(
                                   postingdate = ls_bkpf-postingdate
                                   reversalreason = '01'
                                   createdbyuser = sy-uname
                                 ).
            APPEND ls_deep_rev TO lt_deep_rev.
            cancel( CHANGING ct_deep = lt_deep_rev
                             cs_response = ls_response
                             cv_fail = lv_fail
                             cv_i = i ).
            IF ls_response-_status = 'E'.
              ls_response-_document4 = ls_cancel-belnr4.
              ls_response-_fiscal_year4 = ls_cancel-gjahr4.
            ENDIF.
            CLEAR: ls_deep_rev, lt_deep_rev.
          ENDIF.
        ENDIF.
* Edit output response
        ls_response-_company_code = ls_cancel-companycode.
        ls_response-_fiscal_year = ls_cancel-fiscalyear.
        ls_response-_period = ls_cancel-period.
        ls_response-_customer = ls_cancel-customer.
        ls_response-_supplier = ls_cancel-supplier.
        APPEND ls_response TO es_response-items.
        CLEAR: ls_response, lv_fail, i.
      ENDLOOP.
    ENDIF.

* Send response to USAP
    response->set_status( '200' ).
    DATA(lv_json_string) = xco_cp_json=>data->from_abap( es_response )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).
    response->set_text( lv_json_string ).
    response->set_header_field( i_name  = lc_header_content
                                i_value = lc_content_type ).

  ENDMETHOD.


  METHOD post.
    DATA:
      lv_msg     TYPE string,
      lv_message TYPE string.
    FIELD-SYMBOLS: <fs> TYPE any.
    MODIFY ENTITIES OF i_journalentrytp
              ENTITY journalentry
              EXECUTE post FROM ct_deep
              FAILED DATA(ls_failed_deep)
              REPORTED DATA(ls_reported_deep)
              MAPPED DATA(ls_mapped_deep).
    IF ls_failed_deep IS NOT INITIAL.
      cv_fail = 'X'.
      LOOP AT ls_reported_deep-journalentry INTO DATA(ls_reported).
        DATA(lv_msgty) = ls_reported-%msg->if_t100_dyn_msg~msgty.
        IF lv_msgty = 'E'.
          lv_msg = ls_reported-%msg->if_message~get_text( ).
          lv_message = zzcl_common_utils=>merge_message(
                         iv_message1 = lv_message
                         iv_message2 = lv_msg
                         iv_symbol = '\' ).
        ENDIF.
      ENDLOOP.
      cs_response-_message = lv_message.
    ELSE.
      COMMIT ENTITIES BEGIN
        RESPONSE OF i_journalentrytp
        FAILED DATA(lt_commit_failed)
        REPORTED DATA(lt_commit_reported).
      IF sy-subrc = 0.
        LOOP AT ls_mapped_deep-journalentry ASSIGNING FIELD-SYMBOL(<keys_header>).
          CONVERT KEY OF i_journalentrytp
                            FROM <keys_header>-%pid
                            TO <keys_header>-%key.
        ENDLOOP.
      ENDIF.
      COMMIT ENTITIES END.

      IF lt_commit_failed IS NOT INITIAL.
        cv_fail = 'X'.
        LOOP AT lt_commit_reported-journalentry INTO DATA(ls_commit_rep).
          lv_msgty = ls_commit_rep-%msg->if_t100_dyn_msg~msgty.
          IF lv_msgty = 'E'.
            lv_msg = ls_commit_rep-%msg->if_message~get_text( ).
            lv_message = zzcl_common_utils=>merge_message(
                           iv_message1 = lv_message
                           iv_message2 = lv_msg
                           iv_symbol = '\' ).
          ENDIF.
        ENDLOOP.
        cs_response-_message = lv_message.
      ELSE.
        DATA(lv_field1) = '_DOCUMENT' && cv_i.
        DATA(lv_field2) = '_FISCAL_YEAR' && cv_i.
        ASSIGN COMPONENT lv_field1 OF STRUCTURE cs_response TO <fs>.
        <fs> = <keys_header>-%key-accountingdocument.
        ASSIGN COMPONENT lv_field2 OF STRUCTURE cs_response TO <fs>.
        <fs> = <keys_header>-%key-fiscalyear.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
