FUNCTION zzfm_dtimp_tfi005.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
*********************************************************************

  DATA: ls_data TYPE zr_paymethod.
  DATA: lt_data TYPE TABLE OF zr_paymethod.
  DATA: lv_uuid1 TYPE sysuuid_x16.
  DATA lv_message TYPE string.
  DATA: ls_run TYPE zr_paymethod_sum.

  CLEAR ls_run .
  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).

    TRY.
        DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
        ##NO_HANDLER
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.
    CLEAR ls_data.
    ls_data-uuid                                = lv_uuid.
    ls_data-accountingdocument                  = <line>-('AccountingDocument').
    ls_data-fiscalyear                          = <line>-('FiscalYear').
    ls_data-accountingdocumentitem              = <line>-('AccountingDocumentItem').
    ls_data-postingdate                         = <line>-('PostingDate').
    ls_data-amountincompanycodecurrency         = <line>-('AmountInCompanyCodeCurrency').
    ls_data-companycodecurrency                 = <line>-('CompanyCodeCurrency').
    ls_data-accountingclerkphonenumber          = <line>-('AccountingClerkPhoneNumber').
    ls_data-accountingclerkfaxnumber            = <line>-('AccountingClerkFaxNumber').
    ls_data-paymentmethod_a                     = <line>-('PaymentMethod_a').
    ls_data-conditiondate1                      = <line>-('Conditiondate').
    ls_data-companycode                         = <line>-('CompanyCode').
    ls_data-supplier                            = <line>-('Supplier').
    ls_data-lastdate                            = <line>-('LastDate').
    ls_data-netduedate                          = <line>-('NetdueDate').
    ls_data-paymentmethod                       = <line>-('PaymentMethod').
    ls_data-paymentterms                        = <line>-('PaymentTerms').

    ls_run-uuid                                = lv_uuid                         .
    ls_run-amountincompanycodecurrency         = ls_data-amountincompanycodecurrency  .
    ls_run-companycodecurrency                 = ls_data-companycodecurrency          .
    ls_run-accountingclerkphonenumber          = ls_data-accountingclerkphonenumber   .
    ls_run-accountingclerkfaxnumber            = ls_data-accountingclerkfaxnumber     .
    ls_run-paymentmethod_a                     = ls_data-paymentmethod_a              .
    ls_run-companycode                         = ls_data-companycode                  .
    ls_run-supplier                            = ls_data-supplier                     .
    ls_run-lastdate                            = ls_data-lastdate                     .
    ls_run-netduedate                          = ls_data-netduedate                   .
    ls_run-paymentmethod                       = ls_data-paymentmethod                .
    ls_run-paymentterms                        = ls_data-paymentterms                 .

    ls_run-amountincompanycodecurrency = zzcl_common_utils=>conversion_amount(
                                        iv_alpha = 'IN'
                                        iv_currency = ls_run-companycodecurrency
                                        iv_input = ls_run-amountincompanycodecurrency ).
    ls_data-amountincompanycodecurrency = zzcl_common_utils=>conversion_amount(
                                        iv_alpha = 'IN'
                                        iv_currency = ls_data-companycodecurrency
                                        iv_input = ls_data-amountincompanycodecurrency ).
    "check logic
    "IF ls_data-zid IS INITIAL.
    "  MESSAGE s006(zbc_001) WITH TEXT-001 INTO <line>-('Message').
    "ENDIF.

    IF ls_data-accountingclerkfaxnumber = ls_data-paymentterms.
      MESSAGE s025(zfico_001) WITH ls_data-fiscalyear ls_data-companycode ls_data-accountingdocument INTO lv_message .
      ls_data-message = lv_message.
      ls_data-status = 'S'.
    ELSE.

      DATA: lv_msg     TYPE string.
      DATA lv_timestamp TYPE tzntstmpl.
      DATA lv_bpbankaccountinternalid(4) TYPE c.

      CLEAR lv_message.
      DATA: lt_je  TYPE TABLE FOR ACTION IMPORT i_journalentrytp~change.
      CLEAR lt_je.

      APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<je>).
* APAR Item Control
      DATA lt_aparitem LIKE <je>-%param-_aparitems.
      DATA ls_aparitem LIKE LINE OF lt_aparitem.
      DATA ls_aparitem_control LIKE ls_aparitem-%control.
      ls_aparitem_control-paymentterms = if_abap_behv=>mk-on.

      IF ls_data-paymentmethod_a NE 'A'.
        ls_aparitem_control-bpbankaccountinternalid = if_abap_behv=>mk-on.
        CLEAR lv_bpbankaccountinternalid.
      ELSE.
        DATA:lv_supplier TYPE kunnr.
        lv_supplier = |{ ls_data-supplier ALPHA = IN }|.
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

* Test Data
      <je>-accountingdocument = ls_data-accountingdocument.
      <je>-fiscalyear = ls_data-fiscalyear.
      <je>-companycode = ls_data-companycode.
      <je>-%param = VALUE #(
       _aparitems = VALUE #( (
       glaccountlineitem = ls_data-accountingdocumentitem
       paymentterms = ls_data-accountingclerkphonenumber
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

      IF ls_failed IS NOT INITIAL.
        CLEAR lv_message.
        LOOP AT ls_reported-journalentry INTO DATA(ls_reported_journalentry).
          CLEAR lv_msg.
          MESSAGE ID ls_reported_journalentry-%msg->if_t100_message~t100key-msgid
       TYPE ls_reported_journalentry-%msg->m_severity
     NUMBER ls_reported_journalentry-%msg->if_t100_message~t100key-msgno
       WITH ls_reported_journalentry-%msg->if_t100_dyn_msg~msgv1
            ls_reported_journalentry-%msg->if_t100_dyn_msg~msgv2
            ls_reported_journalentry-%msg->if_t100_dyn_msg~msgv3
            ls_reported_journalentry-%msg->if_t100_dyn_msg~msgv4 INTO lv_msg .
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        ENDLOOP.
        ROLLBACK ENTITIES.
        ls_data-status  = 'E'.
        ls_data-message = lv_message.
        ls_run-status = 'E'.
      ELSE.

        COMMIT ENTITIES BEGIN
        RESPONSE OF i_journalentrytp
        FAILED DATA(lt_commit_failed)
        REPORTED DATA(lt_commit_reported).
        COMMIT ENTITIES END.
        MESSAGE s026(zfico_001) WITH ls_data-fiscalyear ls_data-companycode ls_data-accountingdocument INTO lv_message .
        ls_data-status  = 'S'.
        ls_data-message = lv_message.
      ENDIF.

      GET TIME STAMP FIELD lv_timestamp.
      INSERT INTO ztfi_1005 VALUES  @( VALUE #(
                                            uuid                        = ls_data-uuid
                                            accountingdocument          = ls_data-accountingdocument
                                            fiscalyear                  = ls_data-fiscalyear
                                            accountingdocumentitem      = ls_data-accountingdocumentitem
                                            postingdate                 = ls_data-postingdate
                                            amountincompanycodecurrency = ls_data-amountincompanycodecurrency
                                            companycodecurrency         = ls_data-companycodecurrency
                                            accountingclerkphonenumber  = ls_data-accountingclerkphonenumber
                                            accountingclerkfaxnumber    = ls_data-accountingclerkfaxnumber
                                            paymentmethod_a             = ls_data-paymentmethod_a
                                            conditiondate1              = ls_data-conditiondate1
                                            companycode                 = ls_data-companycode
                                            supplier                    = ls_data-supplier
                                            lastdate                    = ls_data-lastdate
                                            netduedate                  = ls_data-netduedate
                                            paymentmethod               = ls_data-paymentmethod
                                            paymentterms                = ls_data-paymentterms
                                            status                      = ls_data-status
                                            message                     = ls_data-message

                                            created_by         = sy-uname
                                            created_at         = lv_timestamp
                                            last_changed_by    = sy-uname
                                            last_changed_at    = lv_timestamp
                                            local_last_changed_at = lv_timestamp ) ).



    ENDIF.
    <line>-('Type') = ls_data-status.
    <line>-('Message') = ls_data-message.
    IF ls_data-status NE 'S'.
      ls_run-message =  |{ <line>-('Message') }{ '/' }{ ls_run-message }|.
    ENDIF.
  ENDLOOP.
  IF sy-subrc = 0 .

    IF ls_run-status IS INITIAL.
      ls_run-status = 'S'.
    ENDIF.

    GET TIME STAMP FIELD lv_timestamp.

    INSERT INTO ztfi_1006 VALUES  @( VALUE #(
                                          uuid                        = lv_uuid
                                          amountincompanycodecurrency = ls_run-amountincompanycodecurrency
                                          companycodecurrency         = ls_run-companycodecurrency
                                          accountingclerkphonenumber  = ls_run-accountingclerkphonenumber
                                          accountingclerkfaxnumber    = ls_run-accountingclerkfaxnumber
                                          paymentmethod_a             = ls_run-paymentmethod_a
                                          companycode                 = ls_run-companycode
                                          supplier                    = ls_run-supplier
                                          lastdate                    = ls_run-lastdate
                                          netduedate                  = ls_run-netduedate
                                          paymentmethod               = ls_run-paymentmethod
                                          paymentterms                = ls_run-paymentterms
                                          status                      = ls_run-status
                                          message                     = ls_run-message

                                          created_by         = sy-uname
                                          created_at         = lv_timestamp
                                          last_changed_by    = sy-uname
                                          last_changed_at    = lv_timestamp
                                          local_last_changed_at = lv_timestamp ) ).

  ENDIF.



ENDFUNCTION.
