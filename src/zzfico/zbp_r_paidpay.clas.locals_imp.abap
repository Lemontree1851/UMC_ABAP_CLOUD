CLASS lhc_paidpay DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_paidpay.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR paidpay RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION paidpay~processlogic RESULT result.

    METHODS check  CHANGING ct_data       TYPE lty_request_t
                            cv_uploadtype TYPE c.

    METHODS excute CHANGING ct_data       TYPE lty_request_t
                            cv_uploadtype TYPE c.


ENDCLASS.

CLASS lhc_paidpay IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD processlogic.
    DATA lt_request TYPE TABLE OF lty_request.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.
    DATA(lv_type) = keys[ 1 ]-%param-uploadtype.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).

      CASE lv_event.
        WHEN 'CHECK'.
          check( CHANGING ct_data = lt_request
                          cv_uploadtype = lv_type ).

        WHEN 'EXCUTE'.
          excute( CHANGING ct_data = lt_request
                           cv_uploadtype = lv_type ).
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
      lv_int     TYPE string,
      lv_decimal TYPE string,
      lv_text    TYPE string,
      lv_msg     TYPE string,
      lv_message TYPE string.
* Get referent data
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data>).
      <ls_data>-businesspartner = |{ <ls_data>-businesspartner ALPHA = IN }|.
      CLEAR: <ls_data>-status, <ls_data>-message.
    ENDLOOP.

    SELECT companycode,
           profitcenter
      FROM i_profitcenter WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @ct_data
     WHERE profitcenter = @ct_data-profitcenter
      INTO TABLE @DATA(lt_profit).

    SELECT purchasinggroup
      FROM i_purchasinggroup WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @ct_data
     WHERE purchasinggroup = @ct_data-purchasinggroup
      INTO TABLE @DATA(lt_ekgrp).

    SELECT customer,
           companycode
      FROM i_customercompany WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @ct_data
     WHERE customer = @ct_data-businesspartner
       AND companycode = @ct_data-companycode
      INTO TABLE @DATA(lt_bp).

    SORT lt_profit BY profitcenter.
    SORT lt_bp BY customer companycode.
    SORT lt_ekgrp BY purchasinggroup.
* Check if profit and BP center exits
    LOOP AT ct_data ASSIGNING <ls_data>.
      READ TABLE lt_profit INTO DATA(ls_profit)
           WITH KEY profitcenter = <ls_data>-profitcenter BINARY SEARCH.
      IF sy-subrc <> 0.
        DATA(lv_status) = 'E'.
        MESSAGE s019(zfico_001) WITH <ls_data>-profitcenter INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message(
                             iv_message1 = lv_message
                             iv_message2 = lv_msg
                             iv_symbol = '\' ).
      ENDIF.

      READ TABLE lt_bp INTO DATA(ls_bp)
           WITH KEY customer = <ls_data>-businesspartner
                    companycode = <ls_data>-companycode BINARY SEARCH.
      IF sy-subrc <> 0.
        lv_status = 'E'.
        MESSAGE s020(zfico_001) WITH <ls_data>-businesspartner INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message(
                             iv_message1 = lv_message
                             iv_message2 = lv_msg
                             iv_symbol = '\' ).
      ENDIF.

      READ TABLE lt_ekgrp INTO DATA(ls_ekgrp)
           WITH KEY purchasinggroup = <ls_data>-purchasinggroup BINARY SEARCH.
      IF sy-subrc <> 0.
        lv_status = 'E'.
        MESSAGE s030(zfico_001) WITH <ls_data>-purchasinggroup INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message(
                             iv_message1 = lv_message
                             iv_message2 = lv_msg
                             iv_symbol = '\' ).
      ENDIF.
      "整数かをチェックする
      CASE cv_uploadtype.
        WHEN '1'.
          lv_text = <ls_data>-prestockamt.
          CONDENSE lv_text NO-GAPS.
          SPLIT lv_text  AT '.' INTO lv_int lv_decimal.
          IF lv_decimal <> '00'.
            lv_status = 'E'.
            lv_message = zzcl_common_utils=>merge_message(
                                 iv_message1 = lv_message
                                 iv_message2 = '金額が整数ではない。'
                                 iv_symbol = '\' ).
          ENDIF.
        WHEN '2'.
          lv_text = <ls_data>-begpurgrpamt.
          CONDENSE lv_text NO-GAPS.
          SPLIT lv_text  AT '.' INTO lv_int lv_decimal.
          IF lv_decimal <> '00'.
            lv_status = 'E'.
            lv_message = zzcl_common_utils=>merge_message(
                                 iv_message1 = lv_message
                                 iv_message2 = '金額が整数ではない。'
                                 iv_symbol = '\' ).
          ENDIF.
          lv_text = <ls_data>-begchgmaterialamt.
          CONDENSE lv_text NO-GAPS.
          SPLIT lv_text  AT '.' INTO lv_int lv_decimal.
          IF lv_decimal <> '00'.
            lv_status = 'E'.
            lv_message = zzcl_common_utils=>merge_message(
                                 iv_message1 = lv_message
                                 iv_message2 = '金額が整数ではない。'
                                 iv_symbol = '\' ).
          ENDIF.
          lv_text = <ls_data>-begcustomerrev.
          CONDENSE lv_text NO-GAPS.
          SPLIT lv_text  AT '.' INTO lv_int lv_decimal.
          IF lv_decimal <> '00'.
            lv_status = 'E'.
            lv_message = zzcl_common_utils=>merge_message(
                                 iv_message1 = lv_message
                                 iv_message2 = '金額が整数ではない。'
                                 iv_symbol = '\' ).
          ENDIF.
          lv_text = <ls_data>-begrev.
          CONDENSE lv_text NO-GAPS.
          SPLIT lv_text  AT '.' INTO lv_int lv_decimal.
          IF lv_decimal <> '00'.
            lv_status = 'E'.
            lv_message = zzcl_common_utils=>merge_message(
                                 iv_message1 = lv_message
                                 iv_message2 = '金額が整数ではない。'
                                 iv_symbol = '\' ).
          ENDIF.
      ENDCASE.
      IF lv_status = 'E'.
        <ls_data>-status = lv_status.
        <ls_data>-message = lv_message.
      ENDIF.
      <ls_data>-businesspartner = |{ <ls_data>-businesspartner ALPHA = OUT }|.
      CLEAR: lv_status, lv_message, lv_msg.
    ENDLOOP.

  ENDMETHOD.

  METHOD excute.
    DATA:
      lt_ztfi_1008 TYPE STANDARD TABLE OF ztfi_1008,
      ls_ztfi_1008 TYPE ztfi_1008,
      lt_ztfi_1009 TYPE STANDARD TABLE OF ztfi_1009,
      ls_ztfi_1009 TYPE ztfi_1009.
    SELECT companycode,
           currency
      FROM i_companycode WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @ct_data
     WHERE companycode = @ct_data-companycode
      INTO TABLE @DATA(lt_bukrs).
    SORT lt_bukrs BY companycode.

    CASE cv_uploadtype.
      WHEN '1'.
        SELECT *
          FROM ztfi_1008
          FOR ALL ENTRIES IN @ct_data
         WHERE companycode = @ct_data-companycode
           AND fiscalyear = @ct_data-fiscalyear
           AND period = @ct_data-period
          INTO TABLE @DATA(lt_delete1).
        IF sy-subrc = 0.
          DELETE ztfi_1008 FROM TABLE @lt_delete1.
        ENDIF.

        LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data>).
          MOVE-CORRESPONDING <ls_data> TO ls_ztfi_1008.
          READ TABLE lt_bukrs INTO DATA(ls_bukrs)
               WITH KEY companycode = <ls_data>-companycode BINARY SEARCH.
          IF sy-subrc = 0.
            ls_ztfi_1008-currency = ls_bukrs-currency.
            ls_ztfi_1008-prestockamt = zzcl_common_utils=>conversion_amount(
                                            iv_alpha = 'IN'
                                            iv_currency = ls_bukrs-currency
                                            iv_input = <ls_data>-prestockamt ).
            ls_ztfi_1008-businesspartner = |{ <ls_data>-BusinessPartner ALPHA = IN }|.
          ENDIF.
          APPEND ls_ztfi_1008 TO lt_ztfi_1008.
          CLEAR: ls_ztfi_1008.
        ENDLOOP.

        INSERT ztfi_1008 FROM TABLE @lt_ztfi_1008.
        IF sy-subrc = 0.
          LOOP AT ct_data ASSIGNING <ls_data>.
            <ls_data>-status = 'S'.
            <ls_data>-message = '成功にアップロードしました'.
          ENDLOOP.
        ELSE.
          LOOP AT ct_data ASSIGNING <ls_data>.
            <ls_data>-status = 'E'.
            <ls_data>-message = TEXT-002.
          ENDLOOP.
        ENDIF.

      WHEN '2'.
        SELECT *
            FROM ztfi_1009
            FOR ALL ENTRIES IN @ct_data
           WHERE companycode = @ct_data-companycode
             AND fiscalyear = @ct_data-fiscalyear
             AND period = @ct_data-period
            INTO TABLE @DATA(lt_delete2).
        IF sy-subrc = 0.
          DELETE ztfi_1009 FROM TABLE @lt_delete2.
        ENDIF.

        LOOP AT ct_data ASSIGNING <ls_data>.
          MOVE-CORRESPONDING <ls_data> TO ls_ztfi_1009.
          READ TABLE lt_bukrs INTO ls_bukrs
               WITH KEY companycode = <ls_data>-companycode BINARY SEARCH.
          IF sy-subrc = 0.
            ls_ztfi_1009-currency = ls_bukrs-currency.
            ls_ztfi_1009-businesspartner = |{ <ls_data>-BusinessPartner ALPHA = IN }|.
            ls_ztfi_1009-begpurgrpamt = zzcl_common_utils=>conversion_amount(
                                            iv_alpha = 'IN'
                                            iv_currency = ls_bukrs-currency
                                            iv_input = <ls_data>-begpurgrpamt ).
            ls_ztfi_1009-begchgmaterialamt = zzcl_common_utils=>conversion_amount(
                                            iv_alpha = 'IN'
                                            iv_currency = ls_bukrs-currency
                                            iv_input = <ls_data>-begchgmaterialamt ).
            ls_ztfi_1009-begcustomerrev = zzcl_common_utils=>conversion_amount(
                                            iv_alpha = 'IN'
                                            iv_currency = ls_bukrs-currency
                                            iv_input = <ls_data>-begcustomerrev ).
            ls_ztfi_1009-begrev = zzcl_common_utils=>conversion_amount(
                                            iv_alpha = 'IN'
                                            iv_currency = ls_bukrs-currency
                                            iv_input = <ls_data>-begrev ).
          ENDIF.

          APPEND ls_ztfi_1009 TO lt_ztfi_1009.
          CLEAR: ls_ztfi_1009.
        ENDLOOP.

        MODIFY ztfi_1009 FROM TABLE @lt_ztfi_1009   .
        IF sy-subrc = 0.
          LOOP AT ct_data ASSIGNING <ls_data>.
            <ls_data>-status = 'S'.
            <ls_data>-message = '成功にアップロードしました'.
          ENDLOOP.
        ELSE.
          LOOP AT ct_data ASSIGNING <ls_data>.
            <ls_data>-status = 'E'.
            <ls_data>-message = TEXT-002.
          ENDLOOP.
        ENDIF.

      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
