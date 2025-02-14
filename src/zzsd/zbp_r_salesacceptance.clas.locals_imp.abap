CLASS lhc_salesacceptance DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_salesacceptance.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.
    TYPES:
      lv_output(8)  TYPE p DECIMALS 5.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR salesacceptance RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION salesacceptance~processlogic RESULT result.

    METHODS check  CHANGING ct_data         TYPE lty_request_t
                            cv_periodtype   TYPE c
                            cv_acceptyear   TYPE gjahr
                            cv_acceptperiod TYPE monat.
    METHODS insert CHANGING ct_data         TYPE lty_request_t
                            cv_periodtype   TYPE c
                            cv_acceptyear   TYPE gjahr
                            cv_acceptperiod TYPE monat.
    METHODS update CHANGING ct_data         TYPE lty_request_t
                            cv_periodtype   TYPE c
                            cv_acceptyear   TYPE gjahr
                            cv_acceptperiod TYPE monat.
    METHODS delete CHANGING ct_data         TYPE lty_request_t
                            cv_periodtype   TYPE c
                            cv_acceptyear   TYPE gjahr
                            cv_acceptperiod TYPE monat.
    METHODS append CHANGING ct_data         TYPE lty_request_t
                            cv_periodtype   TYPE c
                            cv_acceptyear   TYPE gjahr
                            cv_acceptperiod TYPE monat.
    METHODS calc_date CHANGING cv_periodtype   TYPE c
                               cv_acceptyear   TYPE gjahr
                               cv_acceptperiod TYPE monat
                               cv_from         TYPE d
                               cv_to           TYPE d.
    METHODS convert_amount changing cv_currency TYPE i_currency-currency
                                    cv_input    TYPE any
                                    cv_output   TYPE lv_output.
    CONSTANTS:
      lc_fin   TYPE c LENGTH 1 VALUE '0'.
ENDCLASS.

CLASS lhc_salesacceptance IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD processlogic.
    DATA: lt_request TYPE TABLE OF lty_request,
          lt_export  TYPE TABLE OF lty_request.

    DATA: lv_acceptperiod TYPE monat,
          lv_acceptyear   TYPE gjahr.

    DATA: i TYPE i.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_request.

      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).
      READ TABLE lt_request  INTO DATA(ls_data) INDEX 1.
      DATA(lv_periodtype) = ls_data-periodtype.
      lv_acceptperiod = ls_data-acceptperiod.
      lv_acceptyear = ls_data-acceptdate+0(4).

      CASE lv_event.
        WHEN 'CHECK'.
          check( CHANGING ct_data = lt_request
                          cv_periodtype = lv_periodtype
                          cv_acceptyear = lv_acceptyear
                          cv_acceptperiod = lv_acceptperiod ).
        WHEN 'INSERT'.
          insert( CHANGING ct_data = lt_request
                           cv_periodtype = lv_periodtype
                           cv_acceptyear = lv_acceptyear
                           cv_acceptperiod = lv_acceptperiod ).

        WHEN 'UPDATE'.
          update( CHANGING ct_data = lt_request
                           cv_periodtype = lv_periodtype
                           cv_acceptyear = lv_acceptyear
                           cv_acceptperiod = lv_acceptperiod ).
        WHEN 'DELETE'.
          delete( CHANGING ct_data = lt_request
                           cv_periodtype = lv_periodtype
                           cv_acceptyear = lv_acceptyear
                           cv_acceptperiod = lv_acceptperiod ).
        WHEN 'APPEND'.
          append( CHANGING ct_data = lt_request
                           cv_periodtype = lv_periodtype
                           cv_acceptyear = lv_acceptyear
                           cv_acceptperiod = lv_acceptperiod ).

        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.


    ENDLOOP.

  ENDMETHOD.


  METHOD check.
    DATA:
      lv_matnr     TYPE matnr,
      lv_year      TYPE c LENGTH 4,
      lv_month     TYPE monat,
      lv_nextmonth TYPE budat,
      lv_from      TYPE budat,
      lv_to        TYPE budat,
      lv_message   TYPE string,
      lv_msg       TYPE string.

* Calculate date
    calc_date( CHANGING cv_periodtype = cv_periodtype
                        cv_acceptperiod = cv_acceptperiod
                        cv_acceptyear = cv_acceptyear
                        cv_from = lv_from
                        cv_to = lv_to ).

* Material conversion alpha IN
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      <lfs_data>-umcproductcode = zzcl_common_utils=>conversion_matn1(
                                        EXPORTING iv_alpha = 'IN'
                                                  iv_input = <lfs_data>-umcproductcode ).
      <lfs_data>-customermaterial = zzcl_common_utils=>conversion_matn1(
                                        EXPORTING iv_alpha = 'IN'
                                                  iv_input = <lfs_data>-customermaterial ).

      <lfs_data>-customer = |{ <lfs_data>-customer ALPHA = IN }|.

    ENDLOOP.
* Get reference data
    SELECT product
      FROM i_product
      FOR ALL ENTRIES IN @ct_data
     WHERE product = @ct_data-umcproductcode
      INTO TABLE @DATA(lt_mara).

    SELECT salesorganization,
           customer,
           product,
           materialbycustomer
      FROM i_customermaterial_2
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @ct_data
     WHERE salesorganization = @ct_data-salesorganization
       AND customer = @ct_data-customer
      INTO TABLE @DATA(lt_customermaterial).

    SORT lt_mara BY product.
    SORT lt_customermaterial BY salesorganization customer.

    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
    DATA(lv_vkorg) = zzcl_common_utils=>get_salesorg_by_user( lv_user_email ).

    LOOP AT ct_data ASSIGNING <lfs_data>.
      CLEAR lv_message.
*-1 Mandatory
      IF <lfs_data>-salesorganization IS INITIAL.
        MESSAGE s001(zsd_001) WITH <lfs_data>-row TEXT-001 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.

      IF <lfs_data>-customer IS INITIAL.
        MESSAGE s001(zsd_001) WITH <lfs_data>-row TEXT-002 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.

      IF cv_periodtype IS INITIAL.
        MESSAGE s001(zsd_001) WITH <lfs_data>-row TEXT-003 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.

      IF cv_acceptperiod IS INITIAL.
        MESSAGE s001(zsd_001) WITH <lfs_data>-row TEXT-004 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.

      IF <lfs_data>-receiptdate IS INITIAL.
        MESSAGE s001(zsd_001) WITH <lfs_data>-row TEXT-005 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.

      IF <lfs_data>-acceptdate IS INITIAL.
        MESSAGE s001(zsd_001) WITH <lfs_data>-row TEXT-006 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.

      IF <lfs_data>-currency IS INITIAL.
        MESSAGE s001(zsd_001) WITH <lfs_data>-row TEXT-007 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.
      IF <lfs_data>-taxrate IS INITIAL.
        MESSAGE s001(zsd_001) WITH <lfs_data>-row TEXT-008 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.
* -2 Logic check
      "'UMCProductCode'は値がある
      IF <lfs_data>-umcproductcode IS NOT INITIAL.
        READ TABLE lt_mara TRANSPORTING NO FIELDS
             WITH KEY product = <lfs_data>-umcproductcode BINARY SEARCH.
        IF sy-subrc <> 0.
          MESSAGE s002(zsd_001) WITH <lfs_data>-row TEXT-009 <lfs_data>-umcproductcode INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ELSE.
        " 'UMCProductCode'は値がない、且つ'CustomerMaterial'は値□がある
        READ TABLE lt_customermaterial INTO DATA(ls_customermaterial)
             WITH KEY salesorganization = <lfs_data>-salesorganization
                      customer = <lfs_data>-customer BINARY SEARCH.
        IF sy-subrc <> 0.
          MESSAGE s003(zsd_001) WITH <lfs_data>-row TEXT-010 <lfs_data>-customermaterial INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ELSE.
          <lfs_data>-umcproductcode = ls_customermaterial-product.
        ENDIF.
      ENDIF.
* OutsideDataの値は検証する
      IF <lfs_data>-outsidedata IS NOT INITIAL
     AND <lfs_data>-outsidedata <> 'Y'
     AND <lfs_data>-outsidedata <> 'N'.
        MESSAGE s001(zsd_001) WITH <lfs_data>-row TEXT-011 <lfs_data>-outsidedata INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.


* AcceptDate
      IF <lfs_data>-acceptperiodfrom IS NOT INITIAL
     AND <lfs_data>-acceptperiodto IS NOT INITIAL.
        IF <lfs_data>-acceptdate < <lfs_data>-acceptperiodfrom
        OR <lfs_data>-acceptdate > <lfs_data>-acceptperiodto.
          MESSAGE s004(zsd_001) WITH <lfs_data>-row TEXT-012 <lfs_data>-acceptdate INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ELSE.
        IF <lfs_data>-acceptdate < lv_from
        OR <lfs_data>-acceptdate > lv_to.
          MESSAGE s004(zsd_001) WITH <lfs_data>-row TEXT-012 <lfs_data>-acceptdate INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ENDIF.

* Authorization Check
      IF NOT lv_vkorg CS <lfs_data>-salesorganization.
        MESSAGE e027(zbc_001) WITH <lfs_data>-salesorganization INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

* Edit output
      IF lv_message IS NOT INITIAL.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = lv_message.
      ELSE.
        <lfs_data>-status = 'S'.
        <lfs_data>-periodtype = cv_periodtype.
        <lfs_data>-acceptperiod = cv_acceptperiod.
        <lfs_data>-acceptperiodfrom = lv_from.
        <lfs_data>-acceptperiodto = lv_to.
        IF <lfs_data>-outsidedata IS INITIAL.
          <lfs_data>-outsidedata = 'N'.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD insert.
    DATA:
      lt_ztsd_1003 TYPE STANDARD TABLE OF ztsd_1003,
      ls_ztsd_1003 TYPE ztsd_1003.
    DATA:
      lv_matnr     TYPE matnr,
      lv_year      TYPE c LENGTH 4,
      lv_month     TYPE c LENGTH 2,
      lv_nextmonth TYPE budat,
      lv_from      TYPE budat,
      lv_to        TYPE budat,
      lv_message   TYPE string,
      lv_msg       TYPE string.
* Calculate date
    calc_date( CHANGING cv_periodtype = cv_periodtype
                        cv_acceptyear = cv_acceptyear
                        cv_acceptperiod = cv_acceptperiod
                        cv_from = lv_from
                        cv_to = lv_to ).

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      <lfs_data>-umcproductcode = zzcl_common_utils=>conversion_matn1(
                                      EXPORTING iv_alpha = 'IN'
                                                iv_input = <lfs_data>-umcproductcode ).
      <lfs_data>-customermaterial = zzcl_common_utils=>conversion_matn1(
                                      EXPORTING iv_alpha = 'IN'
                                                iv_input = <lfs_data>-customermaterial ).

      <lfs_data>-customer = |{ <lfs_data>-customer ALPHA = IN }|.
    ENDLOOP.
* Check
    SELECT COUNT( * )
      FROM ztsd_1003
      FOR ALL ENTRIES IN @ct_data
     WHERE salesorganization = @ct_data-salesorganization
       AND customer = @ct_data-customer
       AND periodtype = @ct_data-periodtype
       AND acceptperiod = @ct_data-acceptperiod.

    IF sy-subrc = 0.
      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = TEXT-013.
      ENDLOOP.
    ELSE.
* Insert process
      SELECT product,
             baseunit
        FROM i_product
        FOR ALL ENTRIES IN @ct_data
       WHERE product = @ct_data-umcproductcode
        INTO TABLE @DATA(lt_mara).

      SELECT salesorganization,
             customer,
             product,
             materialbycustomer
        FROM i_customermaterial_2
        WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @ct_data
       WHERE salesorganization = @ct_data-salesorganization
         AND customer = @ct_data-customer
        INTO TABLE @DATA(lt_customermaterial).

      SORT lt_mara BY product.
      SORT lt_customermaterial BY salesorganization customer.

      LOOP AT ct_data ASSIGNING <lfs_data>.
        ls_ztsd_1003-salesorganization = <lfs_data>-salesorganization.
        ls_ztsd_1003-customer = <lfs_data>-customer.
        ls_ztsd_1003-periodtype = <lfs_data>-periodtype.
        ls_ztsd_1003-acceptyear = cv_acceptyear.
        ls_ztsd_1003-acceptperiod = <lfs_data>-acceptperiod.
        ls_ztsd_1003-customerpo = <lfs_data>-customerpo.
        ls_ztsd_1003-itemno = <lfs_data>-itemno.
        IF <lfs_data>-acceptperiodfrom IS NOT INITIAL.
          ls_ztsd_1003-acceptperiodfrom = <lfs_data>-acceptperiodfrom.
        ELSE.
          ls_ztsd_1003-acceptperiodfrom = lv_from.
        ENDIF.
        IF <lfs_data>-acceptperiodto IS NOT INITIAL.
          ls_ztsd_1003-acceptperiodto = <lfs_data>-acceptperiodto.
        ELSE.
          ls_ztsd_1003-acceptperiodto = lv_to.
        ENDIF.
        IF <lfs_data>-umcproductcode IS NOT INITIAL.
          ls_ztsd_1003-umcproductcode = <lfs_data>-umcproductcode.
        ELSE.
          READ TABLE lt_customermaterial INTO DATA(ls_customermaterial)
               WITH KEY salesorganization = <lfs_data>-salesorganization
                        customer = <lfs_data>-customer BINARY SEARCH.
          IF sy-subrc = 0.
            ls_ztsd_1003-umcproductcode = ls_customermaterial-product.
          ENDIF.
        ENDIF.
        ls_ztsd_1003-customermaterial = <lfs_data>-customermaterial.
        ls_ztsd_1003-customermaterialtext = <lfs_data>-customermaterialtext.
        ls_ztsd_1003-receiptdate = <lfs_data>-receiptdate.
        ls_ztsd_1003-acceptdate = <lfs_data>-acceptdate.
        ls_ztsd_1003-acceptqty = <lfs_data>-acceptqty.
        ls_ztsd_1003-receiptqty = <lfs_data>-receiptqty.
        ls_ztsd_1003-unqualifiedqty = <lfs_data>-unqualifiedqty.
        ls_ztsd_1003-undersupplyqty = <lfs_data>-undersupplyqty.
        convert_amount( CHANGING  cv_currency = <lfs_data>-currency
                                  cv_input    = <lfs_data>-acceptprice
                                  cv_output   = ls_ztsd_1003-acceptprice ).
        convert_amount( CHANGING  cv_currency = <lfs_data>-currency
                                  cv_input    = <lfs_data>-accceptamount
                                  cv_output   = ls_ztsd_1003-accceptamount ).
        ls_ztsd_1003-currency = <lfs_data>-currency.
        ls_ztsd_1003-taxrate = <lfs_data>-taxrate.
        ls_ztsd_1003-outsidedata = <lfs_data>-outsidedata.
        ls_ztsd_1003-finishstatus = lc_fin.
        READ TABLE lt_mara INTO DATA(ls_mara)
             WITH KEY product = <lfs_data>-umcproductcode
             BINARY SEARCH.
        IF sy-subrc = 0.
          ls_ztsd_1003-unit = ls_mara-baseunit.
        ENDIF.
        ls_ztsd_1003-created_by = cl_abap_context_info=>get_user_technical_name( ).
        ls_ztsd_1003-created_at = cl_abap_context_info=>get_system_date( ).
        APPEND ls_ztsd_1003 TO lt_ztsd_1003.
        CLEAR: ls_ztsd_1003.
      ENDLOOP.

      INSERT ztsd_1003 FROM TABLE @lt_ztsd_1003.
      IF sy-subrc = 0.
        LOOP AT ct_data ASSIGNING <lfs_data>.
          <lfs_data>-status = 'S'.
          <lfs_data>-message = TEXT-017.  "Insert Successfully
        ENDLOOP.
      ELSE.
        LOOP AT ct_data ASSIGNING <lfs_data>.
          <lfs_data>-status = 'E'.
          <lfs_data>-message = TEXT-018.  "Insert failed
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD update.
    DATA:
      lt_ztsd_1003 TYPE STANDARD TABLE OF ztsd_1003,
      ls_ztsd_1003 TYPE ztsd_1003.
    DATA:
      lv_matnr   TYPE matnr,
      lv_from    TYPE budat,
      lv_to      TYPE budat,
      lv_message TYPE string,
      lv_msg     TYPE string.
* Calculate date
    calc_date( CHANGING cv_periodtype = cv_periodtype
                        cv_acceptyear = cv_acceptyear
                        cv_acceptperiod = cv_acceptperiod
                        cv_from = lv_from
                        cv_to = lv_to ).
* Check if exist
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      <lfs_data>-umcproductcode = zzcl_common_utils=>conversion_matn1(
                                      EXPORTING iv_alpha = 'IN'
                                                iv_input = <lfs_data>-umcproductcode ).
      <lfs_data>-customermaterial = zzcl_common_utils=>conversion_matn1(
                                      EXPORTING iv_alpha = 'IN'
                                                iv_input = <lfs_data>-customermaterial ).

      <lfs_data>-customer = |{ <lfs_data>-customer ALPHA = IN }|.
    ENDLOOP.
    SELECT *
      FROM ztsd_1003
      FOR ALL ENTRIES IN @ct_data
     WHERE salesorganization = @ct_data-salesorganization
       AND customer = @ct_data-customer
       AND periodtype = @ct_data-periodtype
       AND acceptperiod = @ct_data-acceptperiod
      INTO TABLE @DATA(lt_table).

    IF sy-subrc <> 0.
      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = TEXT-013. "指定得意先且つ指定期間の検収データは既に登録しました。
      ENDLOOP.
      RETURN.
    ENDIF.
* Check if finish
    SELECT COUNT( * )
      FROM ztsd_1003
      FOR ALL ENTRIES IN @ct_data
     WHERE salesorganization = @ct_data-salesorganization
       AND customer = @ct_data-customer
       AND periodtype = @ct_data-periodtype
       AND acceptperiod = @ct_data-acceptperiod
       AND finishstatus = '1'.
    IF sy-subrc = 0.
      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = TEXT-014.  "指定得意先且つ指定期間の検収データは既に照合済み
      ENDLOOP.
      RETURN.
    ENDIF.
* Delete reference data
    IF lt_table IS NOT INITIAL.
      DELETE ztsd_1003 FROM TABLE @lt_table.
      IF sy-subrc <> 0.
        LOOP AT ct_data ASSIGNING <lfs_data>.
          <lfs_data>-status = 'E'.
          <lfs_data>-message = TEXT-022.  "Delete failed
          EXIT.
        ENDLOOP.
        RETURN.
      ENDIF.
    ENDIF.

    SELECT product,
           baseunit
      FROM i_product
       FOR ALL ENTRIES IN @ct_data
     WHERE product = @ct_data-umcproductcode
      INTO TABLE @DATA(lt_mara).

    SELECT salesorganization,
                 customer,
                 product,
                 materialbycustomer
            FROM i_customermaterial_2
            WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @ct_data
           WHERE salesorganization = @ct_data-salesorganization
             AND customer = @ct_data-customer
            INTO TABLE @DATA(lt_customermaterial).

    SORT lt_mara BY product.
    SORT lt_customermaterial BY salesorganization customer.

    LOOP AT ct_data ASSIGNING <lfs_data>.
      ls_ztsd_1003-salesorganization = <lfs_data>-salesorganization.
      ls_ztsd_1003-customer = <lfs_data>-customer.
      ls_ztsd_1003-periodtype = <lfs_data>-periodtype.
      ls_ztsd_1003-acceptyear = cv_acceptyear.
      ls_ztsd_1003-acceptperiod = <lfs_data>-acceptperiod.
      ls_ztsd_1003-customerpo = <lfs_data>-customerpo.
      ls_ztsd_1003-itemno = <lfs_data>-itemno.
      IF <lfs_data>-acceptperiodfrom IS NOT INITIAL.
        ls_ztsd_1003-acceptperiodfrom = <lfs_data>-acceptperiodfrom.
      ELSE.
        ls_ztsd_1003-acceptperiodfrom = lv_from.
      ENDIF.
      IF <lfs_data>-acceptperiodto IS NOT INITIAL.
        ls_ztsd_1003-acceptperiodto = <lfs_data>-acceptperiodto.
      ELSE.
        ls_ztsd_1003-acceptperiodto = lv_to.
      ENDIF.
      IF <lfs_data>-umcproductcode IS NOT INITIAL.
        ls_ztsd_1003-umcproductcode = <lfs_data>-umcproductcode.
      ELSE.
        READ TABLE lt_customermaterial INTO DATA(ls_customermaterial)
             WITH KEY salesorganization = <lfs_data>-salesorganization
                      customer = <lfs_data>-customer BINARY SEARCH.
        IF sy-subrc = 0.
          ls_ztsd_1003-umcproductcode = ls_customermaterial-product.
        ENDIF.
      ENDIF.
      ls_ztsd_1003-customermaterial = <lfs_data>-customermaterial.
      ls_ztsd_1003-customermaterialtext = <lfs_data>-customermaterialtext.
      ls_ztsd_1003-receiptdate = <lfs_data>-receiptdate.
      ls_ztsd_1003-acceptdate = <lfs_data>-acceptdate.
      ls_ztsd_1003-acceptqty = <lfs_data>-acceptqty.
      ls_ztsd_1003-receiptqty = <lfs_data>-receiptqty.
      ls_ztsd_1003-unqualifiedqty = <lfs_data>-unqualifiedqty.
      ls_ztsd_1003-undersupplyqty = <lfs_data>-undersupplyqty.
      convert_amount( CHANGING  cv_currency = <lfs_data>-currency
                                cv_input    = <lfs_data>-acceptprice
                                cv_output   = ls_ztsd_1003-acceptprice ).
      convert_amount( CHANGING  cv_currency = <lfs_data>-currency
                                cv_input    = <lfs_data>-accceptamount
                                cv_output   = ls_ztsd_1003-accceptamount ).
      ls_ztsd_1003-currency = <lfs_data>-currency.
      ls_ztsd_1003-taxrate = <lfs_data>-taxrate.
      ls_ztsd_1003-outsidedata = <lfs_data>-outsidedata.
      ls_ztsd_1003-finishstatus = lc_fin.
      READ TABLE lt_mara INTO DATA(ls_mara)
           WITH KEY product = <lfs_data>-umcproductcode
           BINARY SEARCH.
      IF sy-subrc = 0.
        ls_ztsd_1003-unit = ls_mara-baseunit.
      ENDIF.
      ls_ztsd_1003-created_by = cl_abap_context_info=>get_user_technical_name( ).
      ls_ztsd_1003-created_at = cl_abap_context_info=>get_system_date( ).
      APPEND ls_ztsd_1003 TO lt_ztsd_1003.
      CLEAR: ls_ztsd_1003.
    ENDLOOP.

    INSERT ztsd_1003 FROM TABLE @lt_ztsd_1003.
    IF sy-subrc = 0.
      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'S'.
        <lfs_data>-message = TEXT-019.  "Update successfully
      ENDLOOP.
    ELSE.
      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = TEXT-020.  "Update failed
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD delete.
    DATA:
      lt_ztsd_1003 TYPE STANDARD TABLE OF ztsd_1003,
      ls_ztsd_1003 TYPE ztsd_1003.
    DATA:
      lv_matnr   TYPE matnr,
      lv_message TYPE string,
      lv_msg     TYPE string.

* Check if exist
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      <lfs_data>-umcproductcode = zzcl_common_utils=>conversion_matn1(
                                      EXPORTING iv_alpha = 'IN'
                                                iv_input = <lfs_data>-umcproductcode ).
      <lfs_data>-customermaterial = zzcl_common_utils=>conversion_matn1(
                                      EXPORTING iv_alpha = 'IN'
                                                iv_input = <lfs_data>-customermaterial ).

      <lfs_data>-customer = |{ <lfs_data>-customer ALPHA = IN }|.
    ENDLOOP.
    SELECT *
      FROM ztsd_1003
      FOR ALL ENTRIES IN @ct_data
     WHERE salesorganization = @ct_data-salesorganization
       AND customer = @ct_data-customer
       AND periodtype = @ct_data-periodtype
       AND acceptperiod = @ct_data-acceptperiod
      INTO TABLE @DATA(lt_table).

    IF sy-subrc <> 0.
      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = TEXT-013. "指定得意先且つ指定期間の検収データは既に登録しました。
      ENDLOOP.
      RETURN.
    ENDIF.
* Check if finish
    SELECT COUNT( * )
      FROM ztsd_1003
      FOR ALL ENTRIES IN @ct_data
     WHERE salesorganization = @ct_data-salesorganization
       AND customer = @ct_data-customer
       AND periodtype = @ct_data-periodtype
       AND acceptperiod = @ct_data-acceptperiod
       AND finishstatus = '1'.
    IF sy-subrc = 0.
      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = TEXT-014.  "指定得意先且つ指定期間の検収データは既に照合済み
      ENDLOOP.
      RETURN.
    ENDIF.

* Delete data
    IF lt_table IS NOT INITIAL.
      DELETE ztsd_1003 FROM TABLE @lt_table.
      IF sy-subrc = 0.
        LOOP AT ct_data ASSIGNING <lfs_data>.
          <lfs_data>-status = 'S'.
          <lfs_data>-message = TEXT-021.  "Delete successfully
        ENDLOOP.
      ELSE.
        LOOP AT ct_data ASSIGNING <lfs_data>.
          <lfs_data>-status = 'E'.
          <lfs_data>-message = TEXT-022.  "Delete failed
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD append.
    DATA:
      lt_ztsd_1003 TYPE STANDARD TABLE OF ztsd_1003,
      ls_ztsd_1003 TYPE ztsd_1003.
    DATA:
      lv_matnr   TYPE matnr,
      lv_from    TYPE budat,
      lv_to      TYPE budat,
      lv_message TYPE string,
      lv_msg     TYPE string.

* Calculate date
    calc_date( CHANGING cv_periodtype = cv_periodtype
                        cv_acceptyear = cv_acceptyear
                        cv_acceptperiod = cv_acceptperiod
                        cv_from = lv_from
                        cv_to = lv_to ).
* Check if exist
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      <lfs_data>-umcproductcode = zzcl_common_utils=>conversion_matn1(
                                      EXPORTING iv_alpha = 'IN'
                                                iv_input = <lfs_data>-umcproductcode ).
      <lfs_data>-customermaterial = zzcl_common_utils=>conversion_matn1(
                                      EXPORTING iv_alpha = 'IN'
                                                iv_input = <lfs_data>-customermaterial ).

      <lfs_data>-customer = |{ <lfs_data>-customer ALPHA = IN }|.
    ENDLOOP.
    SELECT *                                  "#EC CI_ALL_FIELDS_NEEDED
      FROM ztsd_1003
      FOR ALL ENTRIES IN @ct_data
     WHERE salesorganization = @ct_data-salesorganization
       AND customer = @ct_data-customer
       AND periodtype = @ct_data-periodtype
       AND acceptperiod = @ct_data-acceptperiod
      INTO TABLE @DATA(lt_table).

    IF sy-subrc <> 0.
      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = TEXT-013. "指定得意先且つ指定期間の検収データは既に登録しました。
      ENDLOOP.
      RETURN.
    ENDIF.
* Check if finish
    SELECT COUNT( * )
      FROM ztsd_1003
      FOR ALL ENTRIES IN @ct_data
     WHERE salesorganization = @ct_data-salesorganization
       AND customer = @ct_data-customer
       AND periodtype = @ct_data-periodtype
       AND acceptperiod = @ct_data-acceptperiod
       AND finishstatus = '1'.
    IF sy-subrc = 0.
      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = TEXT-014.  "指定得意先且つ指定期間の検収データは既に照合済み
      ENDLOOP.
      RETURN.
    ENDIF.

    SELECT product,
           baseunit
      FROM i_product
      FOR ALL ENTRIES IN @ct_data
     WHERE product = @ct_data-umcproductcode
      INTO TABLE @DATA(lt_mara).

    SELECT salesorganization,
           customer,
           product,
           materialbycustomer
      FROM i_customermaterial_2 WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @ct_data
     WHERE salesorganization = @ct_data-salesorganization
       AND customer = @ct_data-customer
       INTO TABLE @DATA(lt_customermaterial).

    SORT lt_mara BY product.
    SORT lt_customermaterial BY salesorganization customer.

    LOOP AT ct_data ASSIGNING <lfs_data>.
      ls_ztsd_1003-salesorganization = <lfs_data>-salesorganization.
      ls_ztsd_1003-customer = <lfs_data>-customer.
      ls_ztsd_1003-periodtype = <lfs_data>-periodtype.
      ls_ztsd_1003-acceptyear = cv_acceptyear.
      ls_ztsd_1003-acceptperiod = <lfs_data>-acceptperiod.
      ls_ztsd_1003-customerpo = <lfs_data>-customerpo.
      ls_ztsd_1003-itemno = <lfs_data>-itemno.
      IF <lfs_data>-acceptperiodfrom IS NOT INITIAL.
        ls_ztsd_1003-acceptperiodfrom = <lfs_data>-acceptperiodfrom.
      ELSE.
        ls_ztsd_1003-acceptperiodfrom = lv_from.
      ENDIF.
      IF <lfs_data>-acceptperiodto IS NOT INITIAL.
        ls_ztsd_1003-acceptperiodto = <lfs_data>-acceptperiodto.
      ELSE.
        ls_ztsd_1003-acceptperiodto = lv_to.
      ENDIF.
      IF <lfs_data>-umcproductcode IS NOT INITIAL.
        ls_ztsd_1003-umcproductcode = <lfs_data>-umcproductcode.
      ELSE.
        READ TABLE lt_customermaterial INTO DATA(ls_customermaterial)
             WITH KEY salesorganization = <lfs_data>-salesorganization
                      customer = <lfs_data>-customer BINARY SEARCH.
        IF sy-subrc = 0.
          ls_ztsd_1003-umcproductcode = ls_customermaterial-product.
        ENDIF.
      ENDIF.
      ls_ztsd_1003-customermaterial = <lfs_data>-customermaterial.
      ls_ztsd_1003-customermaterialtext = <lfs_data>-customermaterialtext.
      ls_ztsd_1003-receiptdate = <lfs_data>-receiptdate.
      ls_ztsd_1003-acceptdate = <lfs_data>-acceptdate.
      ls_ztsd_1003-acceptqty = <lfs_data>-acceptqty.
      ls_ztsd_1003-receiptqty = <lfs_data>-receiptqty.
      ls_ztsd_1003-unqualifiedqty = <lfs_data>-unqualifiedqty.
      ls_ztsd_1003-undersupplyqty = <lfs_data>-undersupplyqty.
      convert_amount( CHANGING  cv_currency = <lfs_data>-currency
                                cv_input    = <lfs_data>-acceptprice
                                cv_output   = ls_ztsd_1003-acceptprice ).
      convert_amount( CHANGING  cv_currency = <lfs_data>-currency
                                cv_input    = <lfs_data>-accceptamount
                                cv_output   = ls_ztsd_1003-accceptamount ).

      ls_ztsd_1003-currency = <lfs_data>-currency.
      ls_ztsd_1003-taxrate = <lfs_data>-taxrate.
      ls_ztsd_1003-outsidedata = <lfs_data>-outsidedata.
      ls_ztsd_1003-finishstatus = lc_fin.
      READ TABLE lt_mara INTO DATA(ls_mara)
           WITH KEY product = <lfs_data>-umcproductcode
           BINARY SEARCH.
      IF sy-subrc = 0.
        ls_ztsd_1003-unit = ls_mara-baseunit.
      ENDIF.
      ls_ztsd_1003-created_by = cl_abap_context_info=>get_user_technical_name( ).
      ls_ztsd_1003-created_at = cl_abap_context_info=>get_system_date( ).
      APPEND ls_ztsd_1003 TO lt_ztsd_1003.
      CLEAR: ls_ztsd_1003.
    ENDLOOP.

    INSERT ztsd_1003 FROM TABLE @lt_ztsd_1003.
    IF sy-subrc = 0.
      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'S'.
        <lfs_data>-message = TEXT-023.  "Update successfully
      ENDLOOP.
    ELSE.
      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = TEXT-024.  "Update failed
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD calc_date.
    DATA:
      lv_year      TYPE c LENGTH 4,
      lv_month     TYPE monat,
      lv_nextmonth TYPE budat,
      lv_from      TYPE budat,
      lv_to        TYPE budat.
    CASE cv_periodtype.
      WHEN 'A'.  "1日~月末
        lv_year = cv_acceptyear.
        lv_from = lv_year && cv_acceptperiod && '01'.
        IF cv_acceptperiod = 12.
          lv_year = lv_year + 1.
          lv_nextmonth = lv_year && '01' && '01'.
        ELSE.
          lv_month = cv_acceptperiod + 1.
          lv_nextmonth = lv_year && lv_month && '01'.
        ENDIF.
        lv_to = lv_nextmonth - 1.
      WHEN 'B'.  "16日~次月15日
        lv_year = cv_acceptyear.
        lv_from = lv_year && cv_acceptperiod && '16'.
        IF cv_acceptperiod = 12.
          lv_year = lv_year + 1.
          lv_month = '01'.
        ELSE.
          lv_month = cv_acceptperiod + 1.
        ENDIF.
        lv_to = lv_year && lv_month && '15'.
      WHEN 'C'.  "21日~次月20日
        lv_year = cv_acceptyear.
        lv_from = lv_year && cv_acceptperiod && '21'.
        IF cv_acceptperiod = 12.
          lv_year = lv_year + 1.
          lv_month = '01'.
        ELSE.
          lv_month = cv_acceptperiod + 1.
        ENDIF.
        lv_to = lv_year && lv_month && '20'.

      WHEN 'D'.  "26日~次月25日
        lv_year = cv_acceptyear.
        lv_from = lv_year && cv_acceptperiod && '26'.
        IF cv_acceptperiod = 12.
          lv_year = lv_year + 1.
          lv_month = '01'.
        ELSE.
          lv_month = cv_acceptperiod + 1.
        ENDIF.
        lv_to = lv_year && lv_month && '25'.
    ENDCASE.
    cv_from = lv_from.
    cv_to = lv_to.
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
