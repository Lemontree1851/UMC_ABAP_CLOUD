FUNCTION zzfm_paymentmethod.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA: ls_data TYPE zr_paymethod,
        lt_data TYPE TABLE OF zr_paymethod.

  DATA lv_message TYPE string.
  DATA lv_message_all TYPE string.
  DATA lv_status(1) TYPE c.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).
        <line>-('Message') = '123'.
      <line>-('Type') = 'S'.
  ENDLOOP.
*
*    CLEAR ls_data.
*    ls_data-accountingdocument                  = <line>-('AccountingDocument').
*    ls_data-fiscalyear                          = <line>-('FiscalYear').
*    ls_data-accountingdocumentitem              = <line>-('AccountingDocumentItem').
*    ls_data-postingdate                         = <line>-('PostingDate').
*    ls_data-amountincompanycodecurrency         = <line>-('AmountInCompanyCodeCurrency').
*    ls_data-companycodecurrency                 = <line>-('CompanyCodeCurrency').
*    ls_data-accountingclerkphonenumber          = <line>-('AccountingClerkPhoneNumber').
*    ls_data-accountingclerkfaxnumber            = <line>-('AccountingClerkFaxNumber').
*    ls_data-paymentmethod_a                     = <line>-('PaymentMethod_a').
*    ls_data-companycode                         = <line>-('CompanyCode').
*    ls_data-supplier                            = <line>-('Supplier').
*    ls_data-lastdate                            = <line>-('LastDate').
*    ls_data-netduedate                          = <line>-('NetdueDate').
*    ls_data-paymentmethod                       = <line>-('PaymentMethod').
*    ls_data-paymentterms                        = <line>-('PaymentTerms').
*
*    "check logic
*    "IF ls_data-zid IS INITIAL.
*    "  MESSAGE s006(zbc_001) WITH TEXT-001 INTO <line>-('Message').
*    "ENDIF.
*
*    IF ls_data-accountingclerkfaxnumber = ls_data-paymentterms.
*      MESSAGE s024(zfico_001) WITH ls_data-fiscalyear ls_data-companycode ls_data-accountingdocument INTO lv_message .
*      <line>-('Message') = lv_message.
*      <line>-('Type') = 'S'.
*      lv_message_all = zzcl_common_utils=>merge_message( iv_message1 = lv_message_all iv_message2 = lv_message iv_symbol = '/' ).
*
*    ELSE.
*
*      DATA: lv_msg     TYPE string.
*      DATA lv_timestamp TYPE tzntstmpl.
*
*
*      CLEAR lv_message.
*      DATA: lt_je  TYPE TABLE FOR ACTION IMPORT i_journalentrytp~change.
*      APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<je>).
** APAR Item Control
*      DATA lt_aparitem LIKE <je>-%param-_aparitems.
*      DATA ls_aparitem LIKE LINE OF lt_aparitem.
*      DATA ls_aparitem_control LIKE ls_aparitem-%control.
*      ls_aparitem_control-paymentterms = if_abap_behv=>mk-on.
*
** Test Data
*      <je>-accountingdocument = ls_data-accountingdocument.
*      <je>-fiscalyear = ls_data-fiscalyear.
*      <je>-companycode = ls_data-companycode.
*      <je>-%param = VALUE #(
*       _aparitems = VALUE #( (
*       glaccountlineitem = ls_data-accountingdocumentitem
*       paymentterms = ls_data-accountingclerkphonenumber
*       %control = ls_aparitem_control )
*       )
*       ) .
*      MODIFY ENTITIES OF i_journalentrytp
*       ENTITY journalentry
*       EXECUTE change FROM lt_je
*       FAILED DATA(ls_failed)
*       REPORTED DATA(ls_reported)
*       MAPPED DATA(ls_mapped).
*
*      IF ls_failed IS NOT INITIAL.
*        LOOP AT ls_reported-journalentry INTO DATA(ls_reported_journalentry).
*          CLEAR lv_msg.
*          MESSAGE ID ls_reported_journalentry-%msg->if_t100_message~t100key-msgid
*       TYPE ls_reported_journalentry-%msg->m_severity
*     NUMBER ls_reported_journalentry-%msg->if_t100_message~t100key-msgno
*       WITH ls_reported_journalentry-%msg->if_t100_dyn_msg~msgv1
*            ls_reported_journalentry-%msg->if_t100_dyn_msg~msgv2
*            ls_reported_journalentry-%msg->if_t100_dyn_msg~msgv3
*            ls_reported_journalentry-%msg->if_t100_dyn_msg~msgv4 INTO lv_msg .
*          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
*        ENDLOOP.
*        ROLLBACK ENTITIES.
*        ls_data-status  = 'E'.
*        ls_data-message = lv_message.
*        lv_status = 'E'.
*      ELSE.
*        COMMIT ENTITIES BEGIN
*        RESPONSE OF i_journalentrytp
*        FAILED DATA(lt_commit_failed)
*        REPORTED DATA(lt_commit_reported).
*        COMMIT ENTITIES END.
*        "登録成功しました。
*        MESSAGE s080(zpp_001) WITH 'BOM' INTO lv_message.
*        ls_data-status  = 'S'.
*        ls_data-message = lv_message.
*      ENDIF.
*      <line>-('Message') = ls_data-status.
*      <line>-('Type') = ls_data-message.
*      GET TIME STAMP FIELD lv_timestamp.
*      INSERT INTO ztfi_1005 VALUES  @( VALUE #(
*                                            uuid                        = ls_data-uuid
*                                            accountingdocument          = ls_data-accountingdocument
*                                            fiscalyear                  = ls_data-fiscalyear
*                                            accountingdocumentitem      = ls_data-accountingdocumentitem
*                                            postingdate                 = ls_data-postingdate
*                                            amountincompanycodecurrency = ls_data-amountincompanycodecurrency
*                                            companycodecurrency         = ls_data-companycodecurrency
*                                            accountingclerkphonenumber  = ls_data-accountingclerkphonenumber
*                                            accountingclerkfaxnumber    = ls_data-accountingclerkfaxnumber
*                                            paymentmethod_a             = ls_data-paymentmethod_a
*                                            companycode                 = ls_data-companycode
*                                            supplier                    = ls_data-supplier
*                                            lastdate                    = ls_data-lastdate
*                                            netduedate                  = ls_data-netduedate
*                                            paymentmethod               = ls_data-paymentmethod
*                                            paymentterms                = ls_data-paymentterms
*                                            status                      = ls_data-status
*                                            message                     = ls_data-message
*
*                                            created_by         = sy-uname
*                                            created_at         = lv_timestamp
*                                            last_changed_by    = sy-uname
*                                            last_changed_at    = lv_timestamp
*                                            local_last_changed_at = lv_timestamp ) ).
*
*      lv_message_all = zzcl_common_utils=>merge_message( iv_message1 = lv_message_all iv_message2 = ls_data-message iv_symbol = '/' ).
*
*
*    ENDIF.
*  ENDLOOP.
*  IF sy-subrc = 0.
*
*    IF lv_status IS INITIAL.
*      lv_status = 'S'.
*    ENDIF.
*
*    TRY.
*        DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
*      CATCH cx_uuid_error.
*        "handle exception
*    ENDTRY.
*    INSERT INTO ztfi_1006 VALUES  @( VALUE #(
*                                        uuid                        = lv_uuid
*
*                                        amountincompanycodecurrency = ls_data-amountincompanycodecurrency
*                                        companycodecurrency         = ls_data-companycodecurrency
*                                        accountingclerkphonenumber  = ls_data-accountingclerkphonenumber
*                                        accountingclerkfaxnumber    = ls_data-accountingclerkfaxnumber
*                                        paymentmethod_a             = ls_data-paymentmethod_a
*                                        companycode                 = ls_data-companycode
*                                        supplier                    = ls_data-supplier
*                                        lastdate                    = ls_data-lastdate
*                                        netduedate                  = ls_data-netduedate
*                                        paymentmethod               = ls_data-paymentmethod
*                                        paymentterms                = ls_data-paymentterms
*                                        status                      =   lv_status
*                                        message                     = lv_message_all
*
*                                        created_by         = sy-uname
*                                        created_at         = lv_timestamp
*                                        last_changed_by    = sy-uname
*                                        last_changed_at    = lv_timestamp
*                                        local_last_changed_at = lv_timestamp ) ).
*  ENDIF.


ENDFUNCTION.
