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
    "TYPES:lty_zr_paymethod_sum TYPE TABLE OF zr_paymethod_sum.
    TYPES:BEGIN OF ty_zr_paymethod_sum.
            INCLUDE TYPE zr_paymethod_sum.
    TYPES:  organizationbpname1(50) TYPE c,
            counts                  TYPE i,
            conditiondate           TYPE zr_paymethod-postingdate,
          END OF ty_zr_paymethod_sum,
          lty_zr_paymethod_sum TYPE TABLE OF ty_zr_paymethod_sum.
    DATA:
      lr_customer       TYPE RANGE OF kunnr,
      lrs_customer      LIKE LINE OF lr_customer,
      lr_companycode    TYPE RANGE OF bukrs,
      lrs_companycode   LIKE LINE OF lr_companycode,
      lr_paymentmethod  TYPE RANGE OF dzlsch,
      lrs_paymentmethod LIKE LINE OF lr_paymentmethod,
      lr_postdate       TYPE RANGE OF zr_paymethod-postingdate,
      lrs_postdate      LIKE LINE OF lr_postdate.
    CONSTANTS: lc_mode_insert TYPE string VALUE `I`,
               lc_mode_update TYPE string VALUE `U`,
               lc_mode_in     TYPE string VALUE `IN`,
               lc_mode_out    TYPE string VALUE `OUT`.
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
    METHODS check1  CHANGING ct_data TYPE lty_zr_paymethod_sum.
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

    METHODS modifyjournalentrytpsingle1 IMPORTING cv_test TYPE c
                                                  cv_uuid TYPE sysuuid_x16 OPTIONAL
                                        CHANGING  cs_run  TYPE ty_zr_paymethod_sum
                                                  cs_data TYPE zr_paymethod
                                        RAISING   zzcx_custom_exception.
    METHODS get_message IMPORTING io_message    TYPE REF TO if_abap_behv_message
                        RETURNING VALUE(rv_msg) TYPE string.
    METHODS execute1  CHANGING ct_data TYPE lty_zr_paymethod_sum
                      RAISING  zzcx_custom_exception.


ENDCLASS.

CLASS lhc_paymethod IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD processsearch.
    DATA: lt_request TYPE lty_zr_paymethod_sum.
    DATA: lt_request1 TYPE TABLE OF lty_request1.
    DATA: lv_error TYPE c.
    DATA: lv_execute TYPE c.

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
            INSERT lrs_companycode INTO TABLE lr_companycode.
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
          "execute( CHANGING ct_data = lt_request ).

          " APPEND VALUE #( %cid = key-%cid ) TO failed-paymethod.
          "APPEND VALUE #( %cid = key-%cid
          "                %msg = new_message_with_text( text = 'Error' ) ) TO reported-paymethod.
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
              job( CHANGING ct_data = lt_request ).
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
                                      zzkey = lv_json ) ) TO result.
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

*    LOOP AT ct_data INTO DATA(cs_data).
*      cs_data-amountincompanycodecurrency = zzcl_common_utils=>conversion_amount(
*                                      iv_alpha = 'OUT'
*                                      iv_currency = cs_data-companycodecurrency
*                                      iv_input = cs_data-amountincompanycodecurrency ).
*      MODIFY ct_data FROM cs_data TRANSPORTING amountincompanycodecurrency.
*    ENDLOOP.


  ENDMETHOD.
  METHOD search.

    DATA:ls_sum TYPE ty_zr_paymethod_sum.
    DATA:lt_sum TYPE lty_zr_paymethod_sum.
    DATA:lv_month(10) TYPE c.
    DATA:lt_data TYPE lty_zr_paymethod.


    IF lr_companycode IS INITIAL OR lr_postdate IS INITIAL.

      "RAISE EXCEPTION TYPE zzcx_custom_exception.

    ENDIF.


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

    SELECT
    businesspartner,
    organizationbpname1
    FROM i_businesspartner
    FOR ALL ENTRIES IN @lt_data
    WHERE businesspartner = @lt_data-supplier
    INTO TABLE @DATA(lt_businesspartner).
    SORT lt_businesspartner BY businesspartner.


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
*        lv_month  = <fs_sum>-lastdate+4(2).
*        lv_month += ls_paymentterms-bslndtecalcaddlmnths.
*        lv_month += ls_paymentterms-cashdiscount1additionalmonths.
*
*        DATA:lv_num TYPE i.
*        DATA:lv_rest TYPE i.
*        DATA:lv_y TYPE i.
*        DATA:lv_d(2) TYPE c.
*        DATA:lv_m TYPE i.
*        lv_num =  lv_month / 12.
*        lv_rest = lv_month - 12 * lv_num.
*        lv_y = <fs_sum>-lastdate+0(4) + lv_num.
*        lv_m = lv_rest + 1.
*        IF ls_paymentterms-cashdiscount1dayofmonth < 10.
*          lv_d = '0' && ls_paymentterms-cashdiscount1dayofmonth.
*        ELSE.
*          lv_d = ls_paymentterms-cashdiscount1dayofmonth.
*        ENDIF.
*        IF lv_m < 10.
*          <fs_sum>-conditiondate = lv_y && '0' && lv_m && lv_d.
*        ELSE.
*          <fs_sum>-conditiondate = lv_y && lv_m && lv_d.
*        ENDIF.
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
      LOOP AT lt_data INTO DATA(ls_data).
        cs_data-message =  |{ cs_data-message }{ '/' }{ ls_data-message }|.
      ENDLOOP.
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

            " COMMIT ENTITIES BEGIN
            "RESPONSE OF i_journalentrytp
            "FAILED DATA(lt_commit_failed)
            "REPORTED DATA(lt_commit_reported).
            " COMMIT ENTITIES END.
            "登録成功しました。
            " MESSAGE s080(zpp_001) WITH 'BOM' INTO lv_message.
            " cs_data-status  = 'S'.
            " cs_data-message = lv_message.
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
  METHOD check1.
    DATA:lt_data TYPE lty_zr_paymethod.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA:ls_zzs_dtimp_tbc1001 TYPE zzs_dtimp_tfi005.
    DATA:lt_zzs_dtimp_tbc1001 TYPE STANDARD TABLE OF zzs_dtimp_tfi005.
    DATA:lt_job_exp TYPE STANDARD TABLE OF zzs_dtimp_tfi005.
    DATA:lv_func_name TYPE zze_functionname.
    DATA:lv_struc_name TYPE zze_structurename.
    DATA:lv_message TYPE string.
    DATA: lt_ptab TYPE abap_func_parmbind_tab,
          lo_data TYPE REF TO data ##NEEDED.
    DATA:mo_table           TYPE REF TO data.
    DATA(lv_has_error) = abap_false.
    lv_func_name = 'ZZFM_DTIMP_TFI005'.
    lv_struc_name = 'ZZS_DTIMP_TFI005'.
    LOOP AT ct_data INTO DATA(cs_data).
      CLEAR lv_message.

      cs_data-supplier = |{ cs_data-supplier ALPHA = IN }| .
      getdata( EXPORTING cs_run = cs_data IMPORTING ct_data = lt_data ).
      LOOP AT lt_data INTO DATA(ls_data).
        CLEAR ls_zzs_dtimp_tbc1001.
        MOVE-CORRESPONDING ls_data TO ls_zzs_dtimp_tbc1001.
        ls_zzs_dtimp_tbc1001-accountingclerkphonenumber  = cs_data-accountingclerkphonenumber.
        APPEND ls_zzs_dtimp_tbc1001 TO lt_zzs_dtimp_tbc1001.
      ENDLOOP.
      CREATE DATA mo_table TYPE TABLE OF (lv_struc_name).
      mo_table->* = lt_zzs_dtimp_tbc1001.

      lt_ptab = VALUE #( ( name  = 'IO_DATA'
                     kind  = abap_func_exporting
                     value = REF #( mo_table ) )
                   ( name  = 'IV_STRUC'
                     kind  = abap_func_exporting
                     value = REF #( lv_struc_name ) )
                   ( name  = 'IO_JOB'
                     kind  = abap_func_exporting
                     value = REF #( 'X' ) )
                   ( name  = 'EO_DATA'
                     kind  = abap_func_importing
                     value = REF #( lo_data ) ) ).
      TRY.
          CALL FUNCTION lv_func_name PARAMETER-TABLE lt_ptab.
        CATCH cx_root INTO DATA(le_root).
          lv_message = le_root->get_longtext( ).
          " handle exception
          lv_has_error = abap_true.
      ENDTRY.
      IF lv_message IS INITIAL.
        lt_job_exp = lo_data->*.
        LOOP AT lt_job_exp INTO DATA(ls_job_exp).
          cs_data-message =  |{ cs_data-message }{ '/' }{ ls_job_exp-message }|.
        ENDLOOP.
      ELSE.
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

      "LOOP AT lt_data INTO ls_data.

      "ENDLOOP.
      cs_data-message =  'Job' && lv_file_uuid && 'scheduled'.
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
    DATA: lv_message TYPE string.
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
      MODIFY  lt_export FROM  ls_export TRANSPORTING conditiondate paymentmethod_a.

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

      INSERT INTO zzt_dtimp_files VALUES @( VALUE #( uuid_file = lv_uuid
                                                    uuid_conf     = ls_file_conf-uuidconf
                                                    file_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    file_name   = |ChangeList.xlsx|
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

        CATCH cx_apj_rt INTO DATA(lo_apj_rt) ##NO_HANDLER.
          "RAISE EXCEPTION TYPE zzcx_custom_exception.
          "'lv_message = lo_apj_rt->get_text( ).

          "  APPEND VALUE #( uuidfile = <lfs_file>-uuidfile
          "                 %msg     = new_message_with_text( severity = if_abap_behv_message=>severity-error
          "                                                   text     = lo_apj_rt->bapimsg-message ) )
          "     TO reported-files.

        CATCH cx_root INTO DATA(lo_root) ##NO_HANDLER.
          "RAISE EXCEPTION TYPE zzcx_custom_exception.
          "lv_message = lo_root->get_text( ).

          "  APPEND VALUE #(  uuidfile = <lfs_file>-uuidfile
          "                   %msg     = new_message_with_text( severity = if_abap_behv_message=>severity-error
          "                                                     text     = |Exception: { lo_root->get_text(  ) }| ) )
          "      TO reported-files.
      ENDTRY.

      file_uuid = lv_uuid.

    ENDIF.
  ENDMETHOD.
  METHOD modifyjournalentrytp.
    DATA:lv_message TYPE string.
    DATA:lv_msg TYPE string.
    LOOP AT ct_data INTO DATA(cs_data).

      IF cs_run-accountingclerkphonenumber = cs_data-paymentterms .
        CLEAR lv_msg.
        MESSAGE s025(zfico_001) WITH cs_data-fiscalyear cs_data-companycode cs_data-accountingdocument INTO lv_msg .
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        cs_data-message = lv_message.
      ELSE.

        TRY.
            modifyjournalentrytpsingle( EXPORTING cv_test = cv_test  CHANGING cs_run = cs_run  cs_data = cs_data ).
          CATCH zzcx_custom_exception INTO DATA(e) ##NO_HANDLER.
            " handle exception
            " handle exception
        ENDTRY.
      ENDIF.
      MODIFY ct_data FROM cs_data TRANSPORTING status message.
    ENDLOOP.

  ENDMETHOD.
  METHOD modifyjournalentrytpsingle1.
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.
    DATA lv_timestamp TYPE tzntstmpl.


    CLEAR lv_message.
*    DATA: lt_je  TYPE TABLE FOR ACTION IMPORT i_journalentrytp~change.
*    APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<je>).
** APAR Item Control
*    DATA lt_aparitem LIKE <je>-%param-_aparitems.
*    DATA ls_aparitem LIKE LINE OF lt_aparitem.
*    DATA ls_aparitem_control LIKE ls_aparitem-%control.
*    ls_aparitem_control-paymentterms = if_abap_behv=>mk-on.
*    IF cs_data-paymentmethod_a NE 'A'.
*      ls_aparitem_control-bpbankaccountinternalid = if_abap_behv=>mk-on.
*    ENDIF.
** Test Data
*    <je>-accountingdocument = cs_data-accountingdocument.
*    <je>-fiscalyear = cs_data-fiscalyear.
*    <je>-companycode = cs_data-companycode.
*    <je>-%param = VALUE #(
*     _aparitems = VALUE #( (
*     glaccountlineitem = cs_data-accountingdocumentitem
*     paymentterms = cs_run-accountingclerkphonenumber
*     bpbankaccountinternalid = ''
*     %control = ls_aparitem_control )
*     )
*     ) .
*    MODIFY ENTITIES OF i_journalentrytp
*     ENTITY journalentry
*     EXECUTE change FROM lt_je
*     FAILED DATA(ls_failed)
*     REPORTED DATA(ls_reported)
*     MAPPED DATA(ls_mapped).
*
*    IF ls_failed IS NOT INITIAL.
*      LOOP AT ls_reported-journalentry INTO DATA(ls_reported_journalentry).
*        CLEAR lv_msg.
*        lv_msg = get_message( ls_reported_journalentry-%msg ).
*        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
*      ENDLOOP.
*      cs_data-status  = 'E'.
*      cs_data-message = lv_message.
*      "RAISE EXCEPTION TYPE zzcx_custom_exception.
*    ELSE.
*      MESSAGE s026(zfico_001) WITH cs_data-fiscalyear cs_data-companycode cs_data-accountingdocument INTO lv_message .
*      cs_data-status  = 'S'.
*      cs_data-message = lv_message.
*    ENDIF.

    DATA:ls_zzs_dtimp_tfi005 TYPE zzs_dtimp_tfi005.
    MOVE-CORRESPONDING  cs_data TO ls_zzs_dtimp_tfi005.
    ls_zzs_dtimp_tfi005-accountingclerkphonenumber = cs_run-accountingclerkphonenumber.

    TRY.

        CALL FUNCTION 'ZZFM_PAYMENTMETHOD'
          EXPORTING
            io_data = ls_zzs_dtimp_tfi005
          IMPORTING
            eo_data = ls_zzs_dtimp_tfi005.
      CATCH cx_root INTO DATA(e) ##NO_HANDLER.
        " handle exception

    ENDTRY.

    TRY.
        DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
      CATCH cx_uuid_error INTO DATA(e1) ##NO_HANDLER.
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

  ENDMETHOD.
  METHOD modifyjournalentrytpsingle.
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA lv_bpbankaccountinternalid(3) TYPE c.

    CLEAR lv_message.
    DATA: lt_je  TYPE TABLE FOR ACTION IMPORT i_journalentrytp~change.
    APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<je>).
* APAR Item Control
    DATA lt_aparitem LIKE <je>-%param-_aparitems.
    DATA ls_aparitem LIKE LINE OF lt_aparitem.
    DATA ls_aparitem_control LIKE ls_aparitem-%control.
    ls_aparitem_control-paymentterms = if_abap_behv=>mk-on.

    IF cs_data-paymentmethod_a NE 'A'.
      ls_aparitem_control-bpbankaccountinternalid = if_abap_behv=>mk-on.
      CLEAR lv_bpbankaccountinternalid.
    ELSE.
      DATA:lv_supplier TYPE kunnr.
      lv_supplier = |{ cs_data-supplier ALPHA = IN }|.
      SELECT SINGLE businesspartner
      FROM i_businesspartnerbank
      WHERE businesspartner = @lv_supplier
      AND bankidentification = '000A'
      INTO @DATA(ls_businesspartnerbank).
      IF sy-subrc = 0.
        ls_aparitem_control-bpbankaccountinternalid = if_abap_behv=>mk-on.
        lv_bpbankaccountinternalid = '000A'.
      ENDIF.
    ENDIF.

* Test Data
    <je>-accountingdocument = cs_data-accountingdocument.
    <je>-fiscalyear = cs_data-fiscalyear.
    <je>-companycode = cs_data-companycode.
    <je>-%param = VALUE #(
     _aparitems = VALUE #( (
     glaccountlineitem = cs_data-accountingdocumentitem
     paymentterms = cs_run-accountingclerkphonenumber
     bpbankaccountinternalid = lv_bpbankaccountinternalid
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
        "RAISE EXCEPTION TYPE zzcx_custom_exception.
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

      IF ls_failed IS NOT INITIAL.
        "ROLLBACK ENTITIES.
        LOOP AT ls_reported-journalentry INTO ls_reported_journalentry.
          CLEAR lv_msg.
          lv_msg = get_message( ls_reported_journalentry-%msg ).
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        ENDLOOP.
        cs_data-status  = 'E'.
        cs_data-message = lv_message.
        cs_data-status  = 'S'.
        cs_data-message = '校验成功'.
        "RAISE EXCEPTION TYPE zzcx_custom_exception.

      ELSE.
        cs_data-status  = 'S'.
        cs_data-message = '校验成功'.

        RAISE EXCEPTION TYPE zzcx_custom_exception.

      ENDIF.
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

*            companycode(4)                 TYPE c,
*            lastdate                    TYPE zr_paymethod_sum-lastdate,
*            supplier                    TYPE zr_paymethod_sum-supplier,
*            organizationbpname1e(30) TYPE c,
*            netduedate                  TYPE zr_paymethod_sum-netduedate,
*            paymentmethod               TYPE zr_paymethod_sum-paymentmethod,
*            paymentterms                TYPE zr_paymethod_sum-paymentterms,
*            amountincompanycodecurrency TYPE zr_paymethod_sum-amountincompanycodecurrency,
*            companycodecurrency         TYPE zr_paymethod_sum-companycodecurrency,
*            accountingclerkphonenumber  TYPE zr_paymethod_sum-accountingclerkphonenumber,
*            accountingclerkfaxnumber    TYPE zr_paymethod_sum-accountingclerkfaxnumber,
*            paymentmethod_a             TYPE zr_paymethod_sum-paymentmethod_a,

            status  TYPE zr_paymethod_sum-status,
            message TYPE zr_paymethod_sum-message,



          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.
    DATA lv_timestamp TYPE tzntstmpl.

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

      INSERT INTO zzt_prt_record VALUES @( VALUE #( record_uuid     = lv_uuid
                                                    provided_keys   = |FICO-015支払方法変更_{ lv_timestamp }|
                                                    pdf_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    pdf_file_name   = |Export.xlsx|
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
ENDCLASS.
