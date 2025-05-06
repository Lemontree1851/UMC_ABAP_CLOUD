CLASS lhc_paymethod DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF lty_request1.
    TYPES:  name      TYPE string.
    TYPES:  sign      TYPE string.
    TYPES:  option        TYPE string.
    TYPES:  low         TYPE string.
    TYPES: high TYPE string,
           END OF lty_request1,
           lty_request_t1 TYPE TABLE OF lty_request1.
    TYPES:lty_zr_paymethod TYPE TABLE OF zr_paymethod.
    TYPES:lty_ztfi_1023 TYPE TABLE OF ztfi_1023.
    "TYPES:lty_zr_paymethod_sum TYPE TABLE OF zr_paymethod_sum.
    TYPES:BEGIN OF ty_zr_paymethod_sum.
            INCLUDE TYPE zr_paymethod_sum.
    TYPES:  organizationbpname1(50) TYPE c,
            counts                  TYPE i,
            conditiondate           TYPE zr_paymethod-postingdate,
          END OF ty_zr_paymethod_sum,
          lty_zr_paymethod_sum TYPE TABLE OF ty_zr_paymethod_sum.
    DATA:
      lr_customer         TYPE RANGE OF kunnr,
      lrs_customer        LIKE LINE OF lr_customer,
      lr_companycode      TYPE RANGE OF bukrs,
      lr_companycode_auth TYPE RANGE OF bukrs,
      lrs_companycode     LIKE LINE OF lr_companycode,
      lr_paymentmethod    TYPE RANGE OF dzlsch,
      lrs_paymentmethod   LIKE LINE OF lr_paymentmethod,
      lr_postdate         TYPE RANGE OF zr_paymethod-postingdate,
      lrs_postdate        LIKE LINE OF lr_postdate.
    CONSTANTS: lc_mode_insert TYPE string VALUE `I`,
               lc_mode_update TYPE string VALUE `U`,
               lc_mode_in     TYPE string VALUE `IN`,
               lc_mode_out    TYPE string VALUE `OUT`,
               pack_size      TYPE i VALUE 20000.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR paymethod RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION paymethod~processlogic RESULT result.
    METHODS processsearch FOR MODIFY
      IMPORTING keys FOR ACTION paymethod~processsearch RESULT result.

    METHODS search
      EXPORTING ct_data TYPE lty_zr_paymethod_sum.
    METHODS getdata
      IMPORTING cs_run  TYPE ty_zr_paymethod_sum OPTIONAL
      EXPORTING ct_data TYPE lty_zr_paymethod.
    METHODS check  CHANGING ct_data TYPE lty_zr_paymethod_sum.
    METHODS execute  CHANGING ct_data TYPE lty_zr_paymethod_sum.
    METHODS export IMPORTING ct_data              TYPE lty_zr_paymethod_sum
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.
    METHODS job  CHANGING ct_data TYPE lty_zr_paymethod_sum.
    METHODS jobschd              IMPORTING cv_uuid   TYPE sysuuid_x16 OPTIONAL
                                 CHANGING  cs_run    TYPE ty_zr_paymethod_sum
                                           ct_data   TYPE lty_zr_paymethod
                                           file_uuid TYPE sysuuid_x16.
    METHODS modifyjournalentrytp IMPORTING cv_test TYPE c
                                           cv_uuid TYPE sysuuid_x16 OPTIONAL
                                 CHANGING  cs_run  TYPE ty_zr_paymethod_sum
                                           ct_data TYPE lty_zr_paymethod.

    METHODS modifyjournalentrytpsingle IMPORTING cv_test TYPE c
                                                 cv_uuid TYPE sysuuid_x16 OPTIONAL
                                       CHANGING  cs_run  TYPE ty_zr_paymethod_sum
                                                 cs_data TYPE zr_paymethod
                                       RAISING   zzcx_custom_exception.

    METHODS get_message IMPORTING io_message    TYPE REF TO if_abap_behv_message
                        RETURNING VALUE(rv_msg) TYPE string.
    METHODS execute1  CHANGING ct_data TYPE lty_zr_paymethod_sum
                      RAISING  zzcx_custom_exception.
    "job改成存自建表的模式
    METHODS job_tab  CHANGING ct_data TYPE lty_zr_paymethod_sum.
    "job改成存自建表的模式
    METHODS jobschd_tab              IMPORTING cv_uuid   TYPE sysuuid_x16 OPTIONAL

                                     CHANGING  cs_run    TYPE ty_zr_paymethod_sum
                                               ct_data   TYPE lty_zr_paymethod
                                               ct_fi1023 TYPE lty_ztfi_1023
                                               cv_num    TYPE i
                                               cv_uuid_p TYPE sysuuid_x16 OPTIONAL.

ENDCLASS.

CLASS lhc_paymethod IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD processsearch.
    DATA: lt_request TYPE lty_zr_paymethod_sum.
    DATA: lt_request1 TYPE TABLE OF lty_request1.
    DATA: lv_error TYPE c.
    DATA: lv_execute TYPE c.

    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
    DATA(lv_user_company) = zzcl_common_utils=>get_company_by_user( lv_user_email ).
    SPLIT lv_user_company AT '&' INTO TABLE DATA(lt_company).
    lr_companycode_auth = VALUE #( FOR companycode IN lt_company ( sign = 'I' option = 'EQ' low = companycode ) ).

    DATA: i TYPE i.

    CLEAR: lv_error,lv_execute.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    READ TABLE keys INTO DATA(key) INDEX  1.
    IF sy-subrc = 0.
      CLEAR lt_request.
      i += 1.

      CLEAR: lr_companycode.

      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request1 ).
      LOOP AT lt_request1 INTO DATA(ls_sel_opt_1).
        CASE ls_sel_opt_1-name.
          WHEN 'CompanyCode'.
            MOVE-CORRESPONDING ls_sel_opt_1 TO lrs_companycode.
            IF lrs_companycode-low IN lr_companycode_auth AND lr_companycode_auth IS NOT INITIAL.
              INSERT lrs_companycode INTO TABLE lr_companycode.
            ENDIF.
          WHEN 'Customer'.
            MOVE-CORRESPONDING ls_sel_opt_1 TO lrs_customer.
            lrs_customer-low = |{ lrs_customer-low ALPHA = IN }| .
            INSERT lrs_customer INTO TABLE lr_customer.
          WHEN 'PaymentMethod'.
            MOVE-CORRESPONDING ls_sel_opt_1 TO lrs_paymentmethod.
            INSERT lrs_paymentmethod INTO TABLE lr_paymentmethod.
          WHEN 'Receiver'.
            IF ls_sel_opt_1-low IS NOT INITIAL.
              MOVE-CORRESPONDING ls_sel_opt_1 TO lrs_postdate.
              lrs_postdate-sign = 'I'.
              lrs_postdate-option = 'BT'.
              lrs_postdate-low = ls_sel_opt_1-low+0(4) && ls_sel_opt_1-low+5(2) && ls_sel_opt_1-low+8(2).
              lrs_postdate-high = ls_sel_opt_1-low+13(4) && ls_sel_opt_1-low+18(2) && ls_sel_opt_1-low+21(2).
              INSERT lrs_postdate INTO TABLE lr_postdate.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
      "不存在为空的情况
      IF lr_companycode IS INITIAL .
        CLEAR lr_companycode.
        lrs_companycode-sign = 'I'.
        lrs_companycode-option = 'EQ' .
        lrs_companycode-low = '' .
        INSERT lrs_companycode INTO TABLE lr_companycode.
      ENDIF.
      TRY.
          search( IMPORTING ct_data = lt_request ).

          DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

          APPEND VALUE #( %cid   = key-%cid
                          %param = VALUE #( event = lv_event
                                            zzkey = lv_json ) ) TO result.
        CATCH zzcx_custom_exception.
          " handle exception
          APPEND VALUE #( %cid = key-%cid ) TO failed-paymethod.
          APPEND VALUE #( %cid = key-%cid
                          %msg = new_message_with_text( text = 'Error' ) ) TO reported-paymethod.
      ENDTRY.


    ENDIF.

  ENDMETHOD.
  METHOD processlogic.
    DATA: lt_request TYPE lty_zr_paymethod_sum.
    DATA: lt_request1 TYPE TABLE OF lty_request1.
    DATA: lv_error TYPE c.
    DATA: lv_execute TYPE c.


    DATA: i TYPE i.

    CLEAR: lv_error,lv_execute.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_request.
      i += 1.

      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).

      CASE lv_event.
        WHEN 'CHECK'.
          TRY.
              check( CHANGING ct_data = lt_request ).
            CATCH cx_root INTO DATA(le_rrr).

              DATA(lv_e) = le_rrr->get_longtext( ).
          ENDTRY.
        WHEN 'EXCUTE'.

          TRY.
              execute( CHANGING ct_data = lt_request ).
            CATCH zzcx_custom_exception.
              " handle exception
              APPEND VALUE #( %cid = key-%cid ) TO failed-paymethod.
              APPEND VALUE #( %cid = key-%cid
                              %msg = new_message_with_text( text = 'Error' ) ) TO reported-paymethod.
          ENDTRY.
        WHEN 'JOB'.
          TRY.
              job_tab( CHANGING ct_data = lt_request ).
            CATCH zzcx_custom_exception.
              APPEND VALUE #( %cid = key-%cid ) TO failed-paymethod.
              APPEND VALUE #( %cid = key-%cid
                              %msg = new_message_with_text( text = 'Error' ) ) TO reported-paymethod.
          ENDTRY.
        WHEN 'EXPORT'.
          DATA(lv_recorduuid) = export( EXPORTING ct_data = lt_request ).


        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).
      IF lv_event = 'EXPORT' .
        APPEND VALUE #( %cid   = key-%cid
                       %param = VALUE #( event = lv_event
                                         zzkey = lv_json
                                         recorduuid = lv_recorduuid ) ) TO result.
      ELSE.
        APPEND VALUE #( %cid   = key-%cid
                        %param = VALUE #( event = lv_event
                                 zzkey = lv_json
                                 recorduuid = lv_recorduuid ) ) TO result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
  METHOD getdata.

    IF cs_run IS NOT INITIAL.
      SELECT
           companycode,
           accountingdocument,
           fiscalyear,
           accountingdocumentitem ,
           postingdate,
           lastday AS lastdate,
           supplier,
           paymentmethod,
           netduedate,
           paymentterms,
           companycodecurrency,
           amountincompanycodecurrency,
           accountingclerkphonenumber,
           accountingclerkfaxnumber
       FROM zr_paymethod_cal
       WHERE companycode = @cs_run-companycode
       AND lastday = @cs_run-lastdate
       AND supplier = @cs_run-supplier
       AND netduedate = @cs_run-netduedate
       AND paymentmethod = @cs_run-paymentmethod
       AND paymentterms = @cs_run-paymentterms
       INTO CORRESPONDING FIELDS OF TABLE @ct_data.


    ELSE.
      SELECT
          companycode,
          accountingdocument,
          fiscalyear,
          accountingdocumentitem ,
          postingdate,
          lastday AS lastdate,
          supplier,
          paymentmethod,
          netduedate,
          paymentterms,
          companycodecurrency,
          amountincompanycodecurrency,
          accountingclerkphonenumber,
          accountingclerkfaxnumber
      FROM zr_paymethod_cal
      WHERE companycode IN @lr_companycode
      AND supplier IN @lr_customer
      AND paymentmethod IN @lr_paymentmethod
      AND postingdate IN @lr_postdate
      INTO CORRESPONDING FIELDS OF TABLE @ct_data.
    ENDIF.

  ENDMETHOD.
  METHOD search.

    DATA:ls_sum TYPE ty_zr_paymethod_sum.
    DATA:lt_sum TYPE lty_zr_paymethod_sum.
    DATA:lv_month(10) TYPE c.
    DATA:lt_data TYPE lty_zr_paymethod.

    getdata( IMPORTING ct_data = lt_data ).

    SELECT
        paymentterms,
        paymenttermsvaliditymonthday,"????
        paymentmethod,
        bslndtecalcaddlmnths,
        cashdiscount1dayofmonth,
        cashdiscount1additionalmonths
    FROM i_paymenttermsconditions
    INTO TABLE @DATA(lt_paymentterms).                  "#EC CI_NOWHERE
    SORT lt_paymentterms BY paymentterms paymenttermsvaliditymonthday.

    IF lt_data IS NOT INITIAL.
      SELECT
      businesspartner,
      organizationbpname1
      FROM i_businesspartner
      FOR ALL ENTRIES IN @lt_data
      WHERE businesspartner = @lt_data-supplier
      INTO TABLE @DATA(lt_businesspartner).        "#EC CI_NO_TRANSFORM
      SORT lt_businesspartner BY businesspartner.
    ENDIF.

    LOOP AT lt_data INTO DATA(ls_data).
      CLEAR ls_sum.
      ls_sum-companycode = ls_data-companycode .
      ls_sum-lastdate = ls_data-lastdate  .
      ls_sum-supplier = ls_data-supplier .
      ls_sum-netduedate = ls_data-netduedate .
      ls_sum-paymentmethod = ls_data-paymentmethod .
      ls_sum-paymentterms = ls_data-paymentterms .
      ls_sum-amountincompanycodecurrency = ls_data-amountincompanycodecurrency .
      ls_sum-companycodecurrency = ls_data-companycodecurrency .
      ls_sum-accountingclerkphonenumber = ls_data-accountingclerkphonenumber.
      ls_sum-accountingclerkfaxnumber  = ls_data-accountingclerkfaxnumber  .
      ls_sum-counts = 1.
      COLLECT ls_sum INTO lt_sum.
    ENDLOOP.
    LOOP AT lt_sum ASSIGNING FIELD-SYMBOL(<fs_sum>).

      IF <fs_sum>-amountincompanycodecurrency < 0.
        <fs_sum>-amountincompanycodecurrency = <fs_sum>-amountincompanycodecurrency * -1.
      ENDIF.

      <fs_sum>-amountincompanycodecurrency = zzcl_common_utils=>conversion_amount(
                                          iv_alpha = 'OUT'
                                          iv_currency = <fs_sum>-companycodecurrency
                                          iv_input = <fs_sum>-amountincompanycodecurrency ).


      READ TABLE lt_businesspartner INTO DATA(ls_businesspartner) WITH KEY businesspartner = <fs_sum>-supplier BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_sum>-organizationbpname1 = ls_businesspartner-organizationbpname1.
      ENDIF.
      "CONDENSE <fs_sum>-AccountingClerkPhoneNumber.
      READ TABLE lt_paymentterms INTO DATA(ls_paymentterms) WITH KEY paymentterms = <fs_sum>-accountingclerkphonenumber BINARY SEARCH.
      IF sy-subrc = 0.
        CLEAR lv_month.
        <fs_sum>-paymentmethod_a = ls_paymentterms-paymentmethod.

        DATA:lv_data_temp TYPE aedat.
        DATA:lv_next_start TYPE aedat.
        DATA:lv_d(2) TYPE c.
        DATA:lv_m TYPE i.
        lv_data_temp = <fs_sum>-lastdate.
        lv_data_temp = zzcl_common_utils=>get_begindate_of_month( EXPORTING iv_date = <fs_sum>-lastdate ).

        lv_m = ls_paymentterms-bslndtecalcaddlmnths + ls_paymentterms-cashdiscount1additionalmonths.
        lv_next_start = zzcl_common_utils=>calc_date_add( EXPORTING date = lv_data_temp month = lv_m ).

        IF ls_paymentterms-cashdiscount1dayofmonth < 10.
          lv_d = '0' && ls_paymentterms-cashdiscount1dayofmonth.
        ELSE.
          lv_d = ls_paymentterms-cashdiscount1dayofmonth.
        ENDIF.
        <fs_sum>-conditiondate = lv_next_start+0(6) &&  lv_d.

      ENDIF.
      <fs_sum>-supplier = |{ <fs_sum>-supplier ALPHA = OUT }| .

      TRY .
          IF <fs_sum>-amountincompanycodecurrency > <fs_sum>-accountingclerkfaxnumber.
            DELETE lt_sum.
          ENDIF.
        CATCH cx_root INTO DATA(lo_root).
          DELETE lt_sum.
      ENDTRY.
    ENDLOOP.

    ct_data = lt_sum .

  ENDMETHOD.
  METHOD execute.
    DATA:lt_data TYPE lty_zr_paymethod.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA:lv_check_succ TYPE string.
    DATA:lv_message TYPE string.
    DATA:lv_month(10) TYPE c.
    SELECT
        paymentterms,
        paymenttermsvaliditymonthday,"????
        paymentmethod,
        bslndtecalcaddlmnths,
        cashdiscount1dayofmonth,
        cashdiscount1additionalmonths
    FROM i_paymenttermsconditions
    INTO TABLE @DATA(lt_paymentterms).                  "#EC CI_NOWHERE
    SORT lt_paymentterms BY paymentterms paymenttermsvaliditymonthday.

    MESSAGE s022(zfico_001) INTO lv_check_succ .
    LOOP AT ct_data INTO DATA(cs_data1).
      IF cs_data1-status = 'E' .
        MESSAGE s024(zfico_001) INTO lv_message .
        cs_data1-status  = 'E'.
        cs_data1-message = lv_message.
      ENDIF.
      IF cs_data1-message NE lv_check_succ AND cs_data1-status = ''.
        MESSAGE s023(zfico_001) INTO lv_message .
        cs_data1-status  = 'E'.
        cs_data1-message = lv_message.
      ENDIF.

      MODIFY ct_data FROM cs_data1 TRANSPORTING status message.
    ENDLOOP.

    LOOP AT ct_data INTO DATA(cs_data) WHERE status = ''.
      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
        CATCH cx_uuid_error INTO DATA(e) ##NO_HANDLER.
          "handle exception
      ENDTRY.
      cs_data-supplier = |{ cs_data-supplier ALPHA = IN }| .
      getdata( EXPORTING cs_run = cs_data IMPORTING ct_data = lt_data ).

      READ TABLE lt_paymentterms INTO DATA(ls_paymentterms) WITH KEY paymentterms = cs_data-accountingclerkphonenumber BINARY SEARCH.
      IF sy-subrc = 0.
        CLEAR lv_month.
        cs_data-paymentmethod_a = ls_paymentterms-paymentmethod.
        DATA:lv_data_temp TYPE aedat.
        DATA:lv_next_start TYPE aedat.
        DATA:lv_d(2) TYPE c.
        DATA:lv_m TYPE i.
        lv_data_temp = cs_data-lastdate.
        lv_data_temp = zzcl_common_utils=>get_begindate_of_month( EXPORTING iv_date = cs_data-lastdate ).

        lv_m = ls_paymentterms-bslndtecalcaddlmnths + ls_paymentterms-cashdiscount1additionalmonths.
        lv_next_start = zzcl_common_utils=>calc_date_add( EXPORTING date = lv_data_temp month = lv_m ).

        IF ls_paymentterms-cashdiscount1dayofmonth < 10.
          lv_d = '0' && ls_paymentterms-cashdiscount1dayofmonth.
        ELSE.
          lv_d = ls_paymentterms-cashdiscount1dayofmonth.
        ENDIF.
        cs_data-conditiondate = lv_next_start+0(6) &&  lv_d.
      ENDIF.

      CLEAR cs_data-message.
      modifyjournalentrytp( EXPORTING cv_test = '' cv_uuid = lv_uuid CHANGING cs_run = cs_data  ct_data = lt_data ).
      "只拼接非成功消息
      LOOP AT lt_data INTO DATA(ls_data) WHERE status NE 'S'.
        cs_data-message =  |{ cs_data-message }{ '/' }{ ls_data-message }|.
      ENDLOOP.
      IF sy-subrc <> 0.
        "如果全对
        MESSAGE s043(zfico_001) INTO cs_data-message .
      ENDIF.
      READ TABLE lt_data TRANSPORTING NO FIELDS WITH KEY status = 'E'.
      IF sy-subrc = 0.
        cs_data-status  = 'E'.
      ENDIF.

      MODIFY ct_data FROM cs_data TRANSPORTING status message.

      GET TIME STAMP FIELD lv_timestamp.
      INSERT INTO ztfi_1006 VALUES  @( VALUE #(
                                            uuid                        = lv_uuid
                                            amountincompanycodecurrency = cs_data-amountincompanycodecurrency
                                            companycodecurrency         = cs_data-companycodecurrency
                                            accountingclerkphonenumber  = cs_data-accountingclerkphonenumber
                                            accountingclerkfaxnumber    = cs_data-accountingclerkfaxnumber
                                            paymentmethod_a             = cs_data-paymentmethod_a
                                            companycode                 = cs_data-companycode
                                            supplier                    = cs_data-supplier
                                            lastdate                    = cs_data-lastdate
                                            netduedate                  = cs_data-netduedate
                                            paymentmethod               = cs_data-paymentmethod
                                            paymentterms                = cs_data-paymentterms
                                            status                      = cs_data-status
                                            message                     = cs_data-message
                                            conditiondate = cs_data-conditiondate
                                            created_by         = sy-uname
                                            created_at         = lv_timestamp
                                            last_changed_by    = sy-uname
                                            last_changed_at    = lv_timestamp
                                            local_last_changed_at = lv_timestamp ) ).
    ENDLOOP.

  ENDMETHOD.
  METHOD execute1.
    DATA:lt_data TYPE lty_zr_paymethod.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA:lv_message TYPE string.
    DATA:lv_msg TYPE string.
    DATA:lv_check_succ TYPE string.

    MESSAGE s022(zfico_001) INTO lv_check_succ .
    LOOP AT ct_data INTO DATA(cs_data1).
      IF cs_data1-status = 'E' .
        MESSAGE s024(zfico_001) INTO lv_message .
        cs_data1-status  = 'E'.
        cs_data1-message = lv_message.
      ENDIF.
      IF cs_data1-message NE lv_check_succ AND cs_data1-status = ''.
        MESSAGE s023(zfico_001) INTO lv_message .
        cs_data1-status  = 'E'.
        cs_data1-message = lv_message.
      ENDIF.
      MODIFY ct_data FROM cs_data1 TRANSPORTING status message.
    ENDLOOP.

    LOOP AT ct_data INTO DATA(cs_data) WHERE status = ''.

      cs_data-supplier = |{ cs_data-supplier ALPHA = IN }| .
      getdata( EXPORTING cs_run = cs_data IMPORTING ct_data = lt_data ).

      LOOP AT lt_data INTO DATA(ls_data).

        IF cs_data-accountingclerkphonenumber = ls_data-paymentterms .
          CLEAR lv_msg.
          MESSAGE s024(zfico_001) WITH ls_data-fiscalyear ls_data-companycode ls_data-accountingdocument INTO lv_msg .
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).

        ELSE.

          DATA: lt_je  TYPE TABLE FOR ACTION IMPORT i_journalentrytp~change.
          APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<je>).
* APAR Item Control
          DATA lt_aparitem LIKE <je>-%param-_aparitems.
          DATA ls_aparitem LIKE LINE OF lt_aparitem.
          DATA ls_aparitem_control LIKE ls_aparitem-%control.
          ls_aparitem_control-paymentterms = if_abap_behv=>mk-on.
          ls_aparitem_control-bpbankaccountinternalid = if_abap_behv=>mk-on.
* Test Data
          <je>-accountingdocument = ls_data-accountingdocument.
          <je>-fiscalyear = ls_data-fiscalyear.
          <je>-companycode = ls_data-companycode.
          <je>-%param = VALUE #(
           _aparitems = VALUE #( (
           glaccountlineitem = ls_data-accountingdocumentitem
           paymentterms = cs_data-accountingclerkphonenumber
           bpbankaccountinternalid = ''
           %control = ls_aparitem_control )
           )
           ) .
          MODIFY ENTITIES OF i_journalentrytp
          FORWARDING PRIVILEGED
           ENTITY journalentry
           EXECUTE change FROM lt_je
           FAILED DATA(ls_failed)
           REPORTED DATA(ls_reported)
           MAPPED DATA(ls_mapped).
          IF ls_failed IS NOT INITIAL.
            LOOP AT ls_reported-journalentry INTO DATA(ls_reported_journalentry).
              CLEAR lv_msg.
              lv_msg = get_message( ls_reported_journalentry-%msg ).
              lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
            ENDLOOP.
            "ROLLBACK ENTITIES.
            cs_data-status  = 'E'.
            cs_data-message = lv_message.
            RAISE EXCEPTION TYPE zzcx_custom_exception.
          ELSE.
            CLEAR lv_msg.
            MESSAGE s026(zfico_001) WITH ls_data-fiscalyear ls_data-companycode ls_data-accountingdocument INTO lv_msg .
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).

          ENDIF.

        ENDIF.
        IF cs_data-status  NE 'E'.
          cs_data-status = 'S'.
        ENDIF.
        cs_data-message = lv_message.
      ENDLOOP.


      "cs_data-message =  |{ cs_data-message }{ '/' }{ ls_data-message }|.
      MODIFY ct_data FROM cs_data TRANSPORTING status message.

    ENDLOOP.

  ENDMETHOD.

  METHOD check.
    DATA:lt_data TYPE lty_zr_paymethod.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA:lv_message TYPE string.

    SELECT
    paymentterms,
    paymenttermsvaliditymonthday,"????
    paymentmethod,
    bslndtecalcaddlmnths,
    cashdiscount1dayofmonth,
    cashdiscount1additionalmonths
FROM i_paymenttermsconditions
INTO TABLE @DATA(lt_paymentterms).                      "#EC CI_NOWHERE
    SORT lt_paymentterms BY paymentterms paymenttermsvaliditymonthday.


    LOOP AT ct_data INTO DATA(cs_data).
      CLEAR lv_message.

      cs_data-supplier = |{ cs_data-supplier ALPHA = IN }| .
      getdata( EXPORTING cs_run = cs_data IMPORTING ct_data = lt_data ).

      READ TABLE lt_paymentterms TRANSPORTING NO FIELDS WITH KEY paymentterms = cs_data-accountingclerkphonenumber
      BINARY SEARCH.
      IF sy-subrc NE 0.
        MESSAGE s021(zfico_001) WITH cs_data-accountingclerkphonenumber INTO lv_message .
      ENDIF.


      IF lv_message IS INITIAL.
        cs_data-status  = ''.
        MESSAGE s022(zfico_001) INTO cs_data-message .
      ELSE.
        cs_data-status  = 'E'.
        cs_data-message = lv_message.
      ENDIF.

      MODIFY ct_data FROM cs_data TRANSPORTING status message.

    ENDLOOP.

  ENDMETHOD.

  METHOD job.
    DATA:lt_data TYPE lty_zr_paymethod.
    DATA:lv_file_uuid TYPE sysuuid_x16.
    DATA:lv_check_succ TYPE string.
    DATA:lv_message TYPE string.

    MESSAGE s022(zfico_001) INTO lv_check_succ .
    LOOP AT ct_data INTO DATA(cs_data1) .
      IF cs_data1-status = 'E' .
        MESSAGE s024(zfico_001) INTO lv_message .
        cs_data1-status  = 'E'.
        cs_data1-message = lv_message.
      ENDIF.
      IF cs_data1-message NE lv_check_succ AND cs_data1-status = ''.
        MESSAGE s023(zfico_001) INTO lv_message .
        cs_data1-status  = 'E'.
        cs_data1-message = lv_message.
      ENDIF.
      MODIFY ct_data FROM cs_data1 TRANSPORTING status message.
    ENDLOOP.

    LOOP AT ct_data INTO DATA(cs_data) WHERE status = ''..
      cs_data-supplier = |{ cs_data-supplier ALPHA = IN }| .
      getdata( EXPORTING cs_run = cs_data IMPORTING ct_data = lt_data ).
      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
        CATCH cx_uuid_error INTO DATA(e) ##NO_HANDLER.
          "handle exception
      ENDTRY.

      LOOP AT lt_data INTO DATA(ls_data).
        ls_data-accountingclerkphonenumber = cs_data-accountingclerkphonenumber.
        ls_data-uuid = lv_uuid.
        MODIFY lt_data FROM ls_data TRANSPORTING accountingclerkphonenumber uuid .
      ENDLOOP.

      jobschd( CHANGING cs_run = cs_data  ct_data = lt_data file_uuid = lv_file_uuid ).

      cs_data-message =  'Job' && ` ` && lv_file_uuid && ` ` &&  'scheduled'.
      MODIFY ct_data FROM cs_data TRANSPORTING status message.
    ENDLOOP.

  ENDMETHOD.
  METHOD jobschd.

    TYPES:BEGIN OF lty_export,
            "uuid                        TYPE zr_paymethod-uuid,
            accountingdocument          TYPE zr_paymethod-accountingdocument,
            fiscalyear                  TYPE zr_paymethod-fiscalyear,
            companycode                 TYPE zr_paymethod-companycode,
            accountingdocumentitem      TYPE zr_paymethod-accountingdocumentitem,
            postingdate                 TYPE zr_paymethod-postingdate,
            amountincompanycodecurrency TYPE zr_paymethod-amountincompanycodecurrency,
            companycodecurrency         TYPE zr_paymethod-companycodecurrency,
            accountingclerkphonenumber  TYPE zr_paymethod-accountingclerkphonenumber,
            accountingclerkfaxnumber    TYPE zr_paymethod-accountingclerkfaxnumber,
            paymentmethod_a             TYPE zr_paymethod-paymentmethod_a,
            conditiondate               TYPE zr_paymethod-postingdate,
            supplier                    TYPE zr_paymethod-supplier,
            lastdate                    TYPE zr_paymethod-lastdate,
            netduedate                  TYPE zr_paymethod-netduedate,
            paymentmethod               TYPE zr_paymethod-paymentmethod,
            paymentterms                TYPE zr_paymethod-paymentterms,


          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA:lv_message TYPE string.
    DATA:lv_month(10) TYPE c.
    DATA:lv_date TYPE bldat.
    DATA:lv_time TYPE uzeit.
    SELECT
        paymentterms,
        paymenttermsvaliditymonthday,"????
        paymentmethod,
        bslndtecalcaddlmnths,
        cashdiscount1dayofmonth,
        cashdiscount1additionalmonths
    FROM i_paymenttermsconditions
    INTO TABLE @DATA(lt_paymentterms).                  "#EC CI_NOWHERE
    SORT lt_paymentterms BY paymentterms paymenttermsvaliditymonthday.

    lt_export = CORRESPONDING #( ct_data ).

    LOOP AT lt_export INTO DATA(ls_export).
      READ TABLE lt_paymentterms INTO DATA(ls_paymentterms) WITH KEY paymentterms = ls_export-accountingclerkphonenumber BINARY SEARCH.
      IF sy-subrc = 0.
        CLEAR lv_month.
        ls_export-paymentmethod_a = ls_paymentterms-paymentmethod.

        DATA:lv_data_temp TYPE aedat.
        DATA:lv_next_start TYPE aedat.
        DATA:lv_d(2) TYPE c.
        DATA:lv_m TYPE i.
        lv_data_temp = ls_export-lastdate.
        lv_data_temp = zzcl_common_utils=>get_begindate_of_month( EXPORTING iv_date = ls_export-lastdate ).

        lv_m = ls_paymentterms-bslndtecalcaddlmnths + ls_paymentterms-cashdiscount1additionalmonths.
        lv_next_start = zzcl_common_utils=>calc_date_add( EXPORTING date = lv_data_temp month = lv_m ).

        IF ls_paymentterms-cashdiscount1dayofmonth < 10.
          lv_d = '0' && ls_paymentterms-cashdiscount1dayofmonth.
        ELSE.
          lv_d = ls_paymentterms-cashdiscount1dayofmonth.
        ENDIF.
        ls_export-conditiondate = lv_next_start+0(6) &&  lv_d.

      ENDIF.
      ls_export-amountincompanycodecurrency = zzcl_common_utils=>conversion_amount(
                                    iv_alpha = 'OUT'
                                    iv_currency = ls_export-companycodecurrency
                                    iv_input = ls_export-amountincompanycodecurrency ).
      MODIFY  lt_export FROM  ls_export TRANSPORTING conditiondate paymentmethod_a amountincompanycodecurrency.

    ENDLOOP.

    SELECT SINGLE *
      FROM zzc_dtimp_conf
     WHERE object = 'ZDATAIMPORT_PAYMETHOD'
      INTO @DATA(ls_file_conf).
    IF sy-subrc = 0.
      " FILE_CONTENT must be populated with the complete file content of the .XLSX file
      " whose content shall be processed programmatically.
      DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( ls_file_conf-templatecontent ).
      DATA(lo_write_access) = lo_document->write_access(  ).
      DATA(lo_worksheet) = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).

      DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
        )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( ls_file_conf-startcolumn )
        )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( ls_file_conf-startrow )
        )->get_pattern( ).

      lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_export )
        )->execute( ).

      DATA(lv_file) = lo_write_access->get_file_content( ).
      DATA: lv_job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZZ_JT_DATAIMPORT',
            ls_job_start_info    TYPE cl_apj_rt_api=>ty_start_info,
            lt_job_parameters    TYPE cl_apj_rt_api=>tt_job_parameter_value,
            lv_job_name          TYPE cl_apj_rt_api=>ty_jobname,
            lv_job_count         TYPE cl_apj_rt_api=>ty_jobcount.
      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
        CATCH cx_uuid_error INTO DATA(e) ##NO_HANDLER.
          "handle exception
      ENDTRY.
      GET TIME STAMP FIELD lv_timestamp.

      TRY.
          DATA(lv_timezone) = cl_abap_context_info=>get_user_time_zone( ).
          "时间戳格式转换成日期格式
          CONVERT TIME STAMP lv_timestamp TIME ZONE lv_timezone INTO DATE lv_date TIME lv_time .
        CATCH cx_abap_context_info_error INTO DATA(e11) ##NO_HANDLER.
          "handle exception
      ENDTRY.

      INSERT INTO zzt_dtimp_files VALUES @( VALUE #( uuid_file = lv_uuid
                                                    uuid_conf     = ls_file_conf-uuidconf
                                                    file_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    file_name   = |FICO-015支払方法変更_{ lv_date }_{ lv_time }|
                                                    file_content    = lv_file
                                                    job_name  = lv_job_name
                                                    job_count = lv_job_count
                                                    created_by      = sy-uname
                                                    created_at      = lv_timestamp
                                                    last_changed_by = sy-uname
                                                    last_changed_at = lv_timestamp
                                                    local_last_changed_at = lv_timestamp ) ).
      TRY.
          ls_job_start_info-start_immediately = abap_true.

          lt_job_parameters = VALUE #( ( name    = 'P_ID'
                                         t_value = VALUE #( ( sign   = 'I'
                                                              option = 'EQ'
                                                              low    = lv_uuid ) ) ) ).
          " Schedule job
          cl_apj_rt_api=>schedule_job(
            EXPORTING
              iv_job_template_name   = lv_job_template_name
              iv_job_text            = |Batch Data Import Job of { lv_uuid }|
              is_start_info          = ls_job_start_info
              it_job_parameter_value = lt_job_parameters
            IMPORTING
              ev_jobname             = lv_job_name
              ev_jobcount            = lv_job_count ).
          INSERT INTO zzt_dtimp_start VALUES @( VALUE #( uuid_file       = lv_uuid
                                                         created_by      = sy-uname
                                                         created_at      = lv_timestamp
                                                         last_changed_by = sy-uname
                                                         last_changed_at = lv_timestamp
                                                         local_last_changed_at = lv_timestamp ) ).
        CATCH cx_apj_rt INTO DATA(lo_apj_rt) ##NO_HANDLER.


        CATCH cx_root INTO DATA(lo_root) ##NO_HANDLER.

      ENDTRY.

      file_uuid = lv_job_name.

    ENDIF.
  ENDMETHOD.
  METHOD modifyjournalentrytp.
    DATA:lv_message TYPE string.
    DATA:lv_msg TYPE string.
    LOOP AT ct_data INTO DATA(cs_data).

*      IF cs_run-accountingclerkphonenumber = cs_data-paymentterms .
*        CLEAR lv_msg.
*        MESSAGE s025(zfico_001) WITH cs_data-fiscalyear cs_data-companycode cs_data-accountingdocument INTO lv_msg .
*        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
*        cs_data-message = lv_message.
*      ELSE.

      TRY.
          modifyjournalentrytpsingle( EXPORTING cv_test = cv_test  CHANGING cs_run = cs_run  cs_data = cs_data ).
        CATCH zzcx_custom_exception INTO DATA(e) ##NO_HANDLER.

      ENDTRY.
*      ENDIF.
      MODIFY ct_data FROM cs_data TRANSPORTING status message.
    ENDLOOP.

  ENDMETHOD.

  METHOD modifyjournalentrytpsingle.
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA lv_bpbankaccountinternalid(4) TYPE c.

    CLEAR lv_message.
    DATA: lt_je  TYPE TABLE FOR ACTION IMPORT i_journalentrytp~change.
    APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<je>).


* APAR Item Control
    DATA lt_aparitem LIKE <je>-%param-_aparitems.
    DATA ls_aparitem LIKE LINE OF lt_aparitem.
    DATA ls_aparitem_control LIKE ls_aparitem-%control.
    ls_aparitem_control-paymentterms = if_abap_behv=>mk-on.

    DATA:lv_housebank(5) TYPE c .
    DATA:lv_housebankaccount(5) TYPE c .
    SELECT *
      FROM ztbc_1001
    WHERE  zid   = 'ZFI010'
    INTO TABLE @DATA(lt_ztbc).                "#EC CI_ALL_FIELDS_NEEDED

    READ TABLE lt_ztbc INTO DATA(ls_ztbc) WITH KEY zvalue1 = cs_data-companycode
    zvalue2 = cs_data-paymentmethod    zvalue3 = cs_run-paymentmethod_a .
    IF sy-subrc = 0  .
      ls_aparitem_control-housebank        = if_abap_behv=>mk-on.
      ls_aparitem_control-housebankaccount = if_abap_behv=>mk-on.
      lv_housebank        = ls_ztbc-zvalue4.
      lv_housebankaccount = ls_ztbc-zvalue5.
    ENDIF.

    IF cs_run-paymentmethod_a NE 'A'.
      ls_aparitem_control-bpbankaccountinternalid = if_abap_behv=>mk-on.
      CLEAR lv_bpbankaccountinternalid.
    ELSE.
      DATA:lv_supplier TYPE kunnr.
      lv_supplier = |{ cs_data-supplier ALPHA = IN }|.
      SELECT SINGLE businesspartner
      FROM i_businesspartnerbank
      WITH PRIVILEGED ACCESS
      WHERE businesspartner = @lv_supplier
      AND bankidentification = '000A'
      INTO @DATA(ls_businesspartnerbank).
      IF sy-subrc = 0.
        ls_aparitem_control-bpbankaccountinternalid = if_abap_behv=>mk-on.
        lv_bpbankaccountinternalid = '000A'.
      ENDIF.
    ENDIF.

    <je>-accountingdocument = cs_data-accountingdocument.
    <je>-fiscalyear = cs_data-fiscalyear.
    <je>-companycode = cs_data-companycode.
    <je>-%param = VALUE #(
     _aparitems = VALUE #( (
     glaccountlineitem = cs_data-accountingdocumentitem
     paymentterms = cs_run-accountingclerkphonenumber
     bpbankaccountinternalid = lv_bpbankaccountinternalid
     housebank        = lv_housebank
     housebankaccount = lv_housebankaccount
     %control = ls_aparitem_control )
     )
     ) .
    MODIFY ENTITIES OF i_journalentrytp
     ENTITY journalentry
     EXECUTE change FROM lt_je
     FAILED DATA(ls_failed)
     REPORTED DATA(ls_reported)
     MAPPED DATA(ls_mapped).
    IF cv_test IS INITIAL.
      IF ls_failed IS NOT INITIAL.
        LOOP AT ls_reported-journalentry INTO DATA(ls_reported_journalentry).
          CLEAR lv_msg.
          lv_msg = get_message( ls_reported_journalentry-%msg ).
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        ENDLOOP.
        cs_data-status  = 'E'.
        cs_data-message = lv_message.

        "如果失败了 一定要再改回去 因为这里不能commit 后面的标准代码会强制try again
        CLEAR: lv_bpbankaccountinternalid,lv_housebank,lv_housebankaccount.
        SELECT SINGLE bpbankaccountinternalid,housebank,housebankaccount
         FROM i_operationalacctgdocitem
        WHERE companycode = @cs_data-companycode
          AND fiscalyear = @cs_data-fiscalyear
          AND accountingdocument = @cs_data-accountingdocument
          AND accountingdocumentitem = @cs_data-accountingdocumentitem
        INTO (@lv_bpbankaccountinternalid,@lv_housebank,@lv_housebankaccount).

        "改回去
        <je>-%param = VALUE #(
         _aparitems = VALUE #( (
         glaccountlineitem = cs_data-accountingdocumentitem
         paymentterms      = cs_run-paymentterms
         bpbankaccountinternalid = lv_bpbankaccountinternalid
         housebank        = lv_housebank
         housebankaccount = lv_housebankaccount
         %control                = ls_aparitem_control )
         )
         ) .

        MODIFY ENTITIES OF i_journalentrytp
        ENTITY journalentry
        EXECUTE change FROM lt_je
        FAILED DATA(ls_failed1)
        REPORTED DATA(ls_reported1)
        MAPPED DATA(ls_mapped1).

      ELSE.
        MESSAGE s026(zfico_001) WITH cs_data-fiscalyear cs_data-companycode cs_data-accountingdocument INTO lv_message .
        cs_data-status  = 'S'.
        cs_data-message = lv_message.
      ENDIF.
      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
        CATCH cx_uuid_error INTO DATA(e) ##NO_HANDLER.
          "handle exception
      ENDTRY.
      GET TIME STAMP FIELD lv_timestamp.
      INSERT INTO ztfi_1005 VALUES  @( VALUE #(
                                            uuid                        = lv_uuid
                                            accountingdocument          = cs_data-accountingdocument
                                            fiscalyear                  = cs_data-fiscalyear
                                            accountingdocumentitem      = cs_data-accountingdocumentitem
                                            postingdate                 = cs_data-postingdate
                                            amountincompanycodecurrency = cs_data-amountincompanycodecurrency
                                            companycodecurrency         = cs_data-companycodecurrency
                                            accountingclerkphonenumber  = cs_data-accountingclerkphonenumber
                                            accountingclerkfaxnumber    = cs_data-accountingclerkfaxnumber
                                            paymentmethod_a             = cs_run-paymentmethod_a
                                            conditiondate1 = cs_run-conditiondate
                                            companycode                 = cs_data-companycode
                                            supplier                    = cs_data-supplier
                                            lastdate                    = cs_data-lastdate
                                            netduedate                  = cs_data-netduedate
                                            paymentmethod               = cs_data-paymentmethod
                                            paymentterms                = cs_data-paymentterms
                                            status                      = cs_data-status
                                            message                     = cs_data-message

                                            created_by         = sy-uname
                                            created_at         = lv_timestamp
                                            last_changed_by    = sy-uname
                                            last_changed_at    = lv_timestamp
                                            local_last_changed_at = lv_timestamp ) ).
    ELSE.

    ENDIF.


  ENDMETHOD.
  METHOD get_message.
    MESSAGE ID io_message->if_t100_message~t100key-msgid
       TYPE io_message->m_severity
     NUMBER io_message->if_t100_message~t100key-msgno
       WITH io_message->if_t100_dyn_msg~msgv1
            io_message->if_t100_dyn_msg~msgv2
            io_message->if_t100_dyn_msg~msgv3
            io_message->if_t100_dyn_msg~msgv4 INTO rv_msg.
  ENDMETHOD.

  METHOD export.
    TYPES:BEGIN OF lty_export,
            status                      TYPE zr_paymethod_sum-status,
            message                     TYPE zr_paymethod_sum-message,

            companycode(4)              TYPE c,
            supplier                    TYPE zr_paymethod_sum-supplier,
            organizationbpname1(30)     TYPE c,
            amountincompanycodecurrency TYPE zr_paymethod_sum-amountincompanycodecurrency,
            companycodecurrency         TYPE zr_paymethod_sum-companycodecurrency,
            counts                      TYPE i,
            lastdate                    TYPE zr_paymethod_sum-lastdate,
            netduedate                  TYPE zr_paymethod_sum-netduedate,
            paymentmethod               TYPE zr_paymethod_sum-paymentmethod,
            paymentterms                TYPE zr_paymethod_sum-paymentterms,
            conditiondate               TYPE  zr_paymethod-postingdate,
            paymentmethod_a             TYPE zr_paymethod_sum-paymentmethod_a,
            accountingclerkphonenumber  TYPE zr_paymethod_sum-accountingclerkphonenumber,
            accountingclerkfaxnumber    TYPE zr_paymethod_sum-accountingclerkfaxnumber,

          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA:lv_date TYPE bldat.
    DATA:lv_time TYPE uzeit.
    lt_export = CORRESPONDING #( ct_data ).

    SELECT SINGLE *
      FROM zzc_dtimp_conf
     WHERE object = 'ZDOWNLOAD_PAYMENTMETHOD'
      INTO @DATA(ls_file_conf).               "#EC CI_ALL_FIELDS_NEEDED
    IF sy-subrc = 0.
      " FILE_CONTENT must be populated with the complete file content of the .XLSX file
      " whose content shall be processed programmatically.
      DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( ls_file_conf-templatecontent ).
      DATA(lo_write_access) = lo_document->write_access(  ).
      DATA(lo_worksheet) = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).

      DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
        )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( ls_file_conf-startcolumn )
        )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( ls_file_conf-startrow )
        )->get_pattern( ).

      lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_export  )
        )->execute( ).

      DATA(lv_file) = lo_write_access->get_file_content( ).

      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
        CATCH cx_uuid_error INTO DATA(e) ##NO_HANDLER.
          "handle exception
      ENDTRY.

      GET TIME STAMP FIELD lv_timestamp.

      TRY.
          DATA(lv_timezone) = cl_abap_context_info=>get_user_time_zone( ).
          "时间戳格式转换成日期格式
          CONVERT TIME STAMP lv_timestamp TIME ZONE lv_timezone INTO DATE lv_date TIME lv_time .
        CATCH cx_abap_context_info_error INTO DATA(e11) ##NO_HANDLER.
          "handle exception
      ENDTRY.

      INSERT INTO zzt_prt_record VALUES @( VALUE #( record_uuid     = lv_uuid
                                                    provided_keys   = |FICO-015支払方法変更_{ lv_date }_{ lv_time }|
                                                    pdf_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    pdf_file_name   = |FICO-015支払方法変更_{ lv_date }_{ lv_time }.xlsx|
                                                    pdf_content     = lv_file
                                                    created_by      = sy-uname
                                                    created_at      = lv_timestamp
                                                    last_changed_by = sy-uname
                                                    last_changed_at = lv_timestamp
                                                    local_last_changed_at = lv_timestamp ) ).

      TRY.
          cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = lv_uuid
                                                   IMPORTING uuid_c36 = rv_recorduuid  ).
        CATCH cx_uuid_error INTO DATA(e1) ##NO_HANDLER.
          " handle exception
      ENDTRY.
    ENDIF.
  ENDMETHOD.
  METHOD job_tab.
    TYPES:BEGIN OF lty_export,
            uuidall(32)                 TYPE c,
            accountingdocument          TYPE zr_paymethod-accountingdocument,
            fiscalyear                  TYPE zr_paymethod-fiscalyear,
            companycode                 TYPE zr_paymethod-companycode,
            accountingdocumentitem      TYPE zr_paymethod-accountingdocumentitem,
            postingdate                 TYPE zr_paymethod-postingdate,
            amountincompanycodecurrency TYPE zr_paymethod-amountincompanycodecurrency,
            companycodecurrency         TYPE zr_paymethod-companycodecurrency,
            accountingclerkphonenumber  TYPE zr_paymethod-accountingclerkphonenumber,
            accountingclerkfaxnumber    TYPE zr_paymethod-accountingclerkfaxnumber,
            paymentmethod_a             TYPE zr_paymethod-paymentmethod_a,
            conditiondate               TYPE zr_paymethod-postingdate,
            supplier                    TYPE zr_paymethod-supplier,
            lastdate                    TYPE zr_paymethod-lastdate,
            netduedate                  TYPE zr_paymethod-netduedate,
            paymentmethod               TYPE zr_paymethod-paymentmethod,
            paymentterms                TYPE zr_paymethod-paymentterms,


          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.
    DATA lt_export TYPE lty_export_t.
    DATA ls_export  TYPE lty_export .
    DATA:lt_data TYPE lty_zr_paymethod.
    DATA:lv_file_uuid TYPE sysuuid_x16.
    DATA:lv_check_succ TYPE string.
    DATA:lv_message TYPE string.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA:lv_date TYPE bldat.
    DATA:lv_time TYPE uzeit.
    DATA:lt_ztfi1023_all TYPE STANDARD TABLE OF ztfi_1023.
    DATA:lv_num TYPE i.
    DATA:lv_uuid_p TYPE sysuuid_x16 .

    CLEAR:lt_ztfi1023_all,lv_num.

    MESSAGE s022(zfico_001) INTO lv_check_succ .
    LOOP AT ct_data INTO DATA(cs_data1) .
      IF cs_data1-status = 'E' .
        MESSAGE s024(zfico_001) INTO lv_message .
        cs_data1-status  = 'E'.
        cs_data1-message = lv_message.
      ENDIF.
      IF cs_data1-message NE lv_check_succ AND cs_data1-status = ''.
        MESSAGE s023(zfico_001) INTO lv_message .
        cs_data1-status  = 'E'.
        cs_data1-message = lv_message.
      ENDIF.
      MODIFY ct_data FROM cs_data1 TRANSPORTING status message.
    ENDLOOP.

    TRY.
        DATA(lv_uuid_all) = cl_system_uuid=>create_uuid_x16_static(  ).
      CATCH cx_uuid_error INTO DATA(e1) ##NO_HANDLER.
        "handle exception
    ENDTRY.

    LOOP AT ct_data INTO DATA(cs_data) WHERE status = ''..
      cs_data-supplier = |{ cs_data-supplier ALPHA = IN }| .
      getdata( EXPORTING cs_run = cs_data IMPORTING ct_data = lt_data ).

      LOOP AT lt_data INTO DATA(ls_data).
        ls_data-accountingclerkphonenumber = cs_data-accountingclerkphonenumber.
        MODIFY lt_data FROM ls_data TRANSPORTING accountingclerkphonenumber .
      ENDLOOP.

      jobschd_tab( EXPORTING cv_uuid = lv_uuid_all
      CHANGING cs_run = cs_data  ct_data = lt_data ct_fi1023 = lt_ztfi1023_all cv_num = lv_num cv_uuid_p = lv_uuid_p  ).

    ENDLOOP.
    IF sy-subrc = 0.

      IF lt_ztfi1023_all IS NOT INITIAL.

        MODIFY ztfi_1023 FROM TABLE @lt_ztfi1023_all.

      ENDIF.

      SORT lt_ztfi1023_all BY uuid_all uuid.
      DELETE ADJACENT DUPLICATES FROM lt_ztfi1023_all COMPARING uuid_all uuid.

      IF lines( lt_ztfi1023_all ) > 10000.
        RETURN.
      ENDIF.

      LOOP AT lt_ztfi1023_all INTO DATA(ls_ztfi1023_all).

        CLEAR lt_export.

        ls_export-uuidall = ls_ztfi1023_all-uuid.
        APPEND ls_export TO lt_export.


        DATA: lv_job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZZ_JT_DATAIMPORT',
              ls_job_start_info    TYPE cl_apj_rt_api=>ty_start_info,
              lt_job_parameters    TYPE cl_apj_rt_api=>tt_job_parameter_value,
              lv_job_name          TYPE cl_apj_rt_api=>ty_jobname,
              lv_job_count         TYPE cl_apj_rt_api=>ty_jobcount.

        SELECT SINGLE *
              FROM zzc_dtimp_conf
             WHERE object = 'ZDATAIMPORT_PAYMETHOD'
              INTO @DATA(ls_file_conf).
        IF sy-subrc = 0.
          " FILE_CONTENT must be populated with the complete file content of the .XLSX file
          " whose content shall be processed programmatically.
          DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( ls_file_conf-templatecontent ).
          DATA(lo_write_access) = lo_document->write_access(  ).
          DATA(lo_worksheet) = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).

          DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
            )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( ls_file_conf-startcolumn )
            )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( ls_file_conf-startrow )
            )->get_pattern( ).

          lo_worksheet->select( lo_selection_pattern
            )->row_stream(
            )->operation->write_from( REF #( lt_export )
            )->execute( ).

          DATA(lv_file) = lo_write_access->get_file_content( ).

          GET TIME STAMP FIELD lv_timestamp.

          TRY.
              DATA(lv_timezone) = cl_abap_context_info=>get_user_time_zone( ).
              "时间戳格式转换成日期格式
              CONVERT TIME STAMP lv_timestamp TIME ZONE lv_timezone INTO DATE lv_date TIME lv_time .
            CATCH cx_abap_context_info_error INTO DATA(e11) ##NO_HANDLER.
              "handle exception
          ENDTRY.

          INSERT INTO zzt_dtimp_files VALUES @( VALUE #( uuid_file = ls_ztfi1023_all-uuid
                                                        uuid_conf     = ls_file_conf-uuidconf
                                                        file_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                        file_name   = |FICO-015支払方法変更_{ lv_date }_{ lv_time }|
                                                        file_content    = lv_file
                                                        job_name  = lv_job_name
                                                        job_count = lv_job_count
                                                        created_by      = sy-uname
                                                        created_at      = lv_timestamp
                                                        last_changed_by = sy-uname
                                                        last_changed_at = lv_timestamp
                                                        local_last_changed_at = lv_timestamp ) ).
          TRY.
              ls_job_start_info-start_immediately = abap_true.

              lt_job_parameters = VALUE #( ( name    = 'P_ID'
                                             t_value = VALUE #( ( sign   = 'I'
                                                                  option = 'EQ'
                                                                  low    = ls_ztfi1023_all-uuid ) ) ) ).
              " Schedule job
              cl_apj_rt_api=>schedule_job(
                EXPORTING
                  iv_job_template_name   = lv_job_template_name
                  iv_job_text            = |Batch Data Import Job of { lv_uuid_all }|
                  is_start_info          = ls_job_start_info
                  it_job_parameter_value = lt_job_parameters
                IMPORTING
                  ev_jobname             = lv_job_name
                  ev_jobcount            = lv_job_count ).
              INSERT INTO zzt_dtimp_start VALUES @( VALUE #( uuid_file       = ls_ztfi1023_all-uuid
                                                             created_by      = sy-uname
                                                             created_at      = lv_timestamp
                                                             last_changed_by = sy-uname
                                                             last_changed_at = lv_timestamp
                                                             local_last_changed_at = lv_timestamp ) ).
            CATCH cx_apj_rt INTO DATA(lo_apj_rt) ##NO_HANDLER.

              DATA(lv_msg_error)    = lo_apj_rt->bapimsg-message  .


            CATCH cx_root INTO DATA(lo_root) ##NO_HANDLER.

              lv_msg_error     =  lo_root->get_text(  ).
          ENDTRY.
        ENDIF.

      ENDLOOP.

      LOOP AT ct_data INTO cs_data WHERE status = ''..

        IF lo_apj_rt IS NOT INITIAL OR lo_root IS NOT INITIAL .
          IF lv_msg_error IS NOT INITIAL.
            cs_data-message = lv_msg_error.
          ELSE.
            cs_data-message = 'Error'.
          ENDIF.
        ELSE.
          cs_data-message =  'Job' && ` ` && lv_uuid_all && ` ` &&  'scheduled'.
        ENDIF.
        MODIFY ct_data FROM cs_data TRANSPORTING status message.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.
  METHOD jobschd_tab.

    TYPES:BEGIN OF lty_export,
            uuid                        TYPE zr_paymethod-uuid,
            accountingdocument          TYPE zr_paymethod-accountingdocument,
            fiscalyear                  TYPE zr_paymethod-fiscalyear,
            companycode                 TYPE zr_paymethod-companycode,
            accountingdocumentitem      TYPE zr_paymethod-accountingdocumentitem,
            postingdate                 TYPE zr_paymethod-postingdate,
            amountincompanycodecurrency TYPE zr_paymethod-amountincompanycodecurrency,
            companycodecurrency         TYPE zr_paymethod-companycodecurrency,
            accountingclerkphonenumber  TYPE zr_paymethod-accountingclerkphonenumber,
            accountingclerkfaxnumber    TYPE zr_paymethod-accountingclerkfaxnumber,
            paymentmethod_a             TYPE zr_paymethod-paymentmethod_a,
            conditiondate               TYPE zr_paymethod-postingdate,
            supplier                    TYPE zr_paymethod-supplier,
            lastdate                    TYPE zr_paymethod-lastdate,
            netduedate                  TYPE zr_paymethod-netduedate,
            paymentmethod               TYPE zr_paymethod-paymentmethod,
            paymentterms                TYPE zr_paymethod-paymentterms,


          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.
    DATA lt_export TYPE lty_export_t.

    DATA:lv_message TYPE string.
    DATA:lv_month(10) TYPE c.

    DATA:lt_ztfi_1023 TYPE STANDARD TABLE OF ztfi_1023.
    DATA:ls_ztfi_1023 TYPE ztfi_1023.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA:lv_date TYPE bldat.
    DATA:lv_time TYPE uzeit.


    CLEAR lt_ztfi_1023.

    SELECT
        paymentterms,
        paymenttermsvaliditymonthday,"????
        paymentmethod,
        bslndtecalcaddlmnths,
        cashdiscount1dayofmonth,
        cashdiscount1additionalmonths
    FROM i_paymenttermsconditions
    INTO TABLE @DATA(lt_paymentterms).                  "#EC CI_NOWHERE
    SORT lt_paymentterms BY paymentterms paymenttermsvaliditymonthday.

    lt_export = CORRESPONDING #( ct_data ).

    TRY.
        DATA(lv_timezone) = cl_abap_context_info=>get_user_time_zone( ).
        "时间戳格式转换成日期格式
        CONVERT TIME STAMP lv_timestamp TIME ZONE lv_timezone INTO DATE lv_date TIME lv_time .
      CATCH cx_abap_context_info_error INTO DATA(e11) ##NO_HANDLER.
        "handle exception
    ENDTRY.

    LOOP AT lt_export INTO DATA(ls_export).
      IF cv_uuid_p IS INITIAL.
        TRY.
            cv_uuid_p = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error INTO DATA(e) ##NO_HANDLER.
            "handle exception
        ENDTRY.
      ENDIF.
      cv_num += 1.
      IF cv_num > pack_size .
        TRY.
            cv_uuid_p = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error INTO e ##NO_HANDLER.
            "handle exception
        ENDTRY.
        cv_num = 1.
      ENDIF.

      READ TABLE lt_paymentterms INTO DATA(ls_paymentterms) WITH KEY paymentterms = ls_export-accountingclerkphonenumber BINARY SEARCH.
      IF sy-subrc = 0.
        CLEAR lv_month.
        ls_export-paymentmethod_a = ls_paymentterms-paymentmethod.

        DATA:lv_data_temp TYPE aedat.
        DATA:lv_next_start TYPE aedat.
        DATA:lv_d(2) TYPE c.
        DATA:lv_m TYPE i.
        lv_data_temp = ls_export-lastdate.
        lv_data_temp = zzcl_common_utils=>get_begindate_of_month( EXPORTING iv_date = ls_export-lastdate ).

        lv_m = ls_paymentterms-bslndtecalcaddlmnths + ls_paymentterms-cashdiscount1additionalmonths.
        lv_next_start = zzcl_common_utils=>calc_date_add( EXPORTING date = lv_data_temp month = lv_m ).

        IF ls_paymentterms-cashdiscount1dayofmonth < 10.
          lv_d = '0' && ls_paymentterms-cashdiscount1dayofmonth.
        ELSE.
          lv_d = ls_paymentterms-cashdiscount1dayofmonth.
        ENDIF.
        ls_export-conditiondate = lv_next_start+0(6) &&  lv_d.

      ENDIF.
      ls_export-amountincompanycodecurrency = zzcl_common_utils=>conversion_amount(
                                    iv_alpha = 'OUT'
                                    iv_currency = ls_export-companycodecurrency
                                    iv_input = ls_export-amountincompanycodecurrency ).
      MODIFY  lt_export FROM  ls_export TRANSPORTING conditiondate paymentmethod_a amountincompanycodecurrency.

      MOVE-CORRESPONDING ls_export TO ls_ztfi_1023.
      ls_ztfi_1023-uuid_all              = cv_uuid.
      ls_ztfi_1023-uuid                  = cv_uuid_p.
      ls_ztfi_1023-created_by            = sy-uname.
      ls_ztfi_1023-created_at            = lv_timestamp.
      ls_ztfi_1023-last_changed_by       = sy-uname.
      ls_ztfi_1023-last_changed_at       = lv_timestamp.
      ls_ztfi_1023-local_last_changed_at = lv_timestamp.
      APPEND ls_ztfi_1023 TO lt_ztfi_1023.
    ENDLOOP.

    APPEND LINES OF lt_ztfi_1023 TO ct_fi1023.

*    IF lt_ztfi_1023 IS NOT INITIAL.
*
*      MODIFY ztfi_1023 FROM TABLE @lt_ztfi_1023.
*
*    ENDIF.


  ENDMETHOD.
ENDCLASS.
