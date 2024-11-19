FUNCTION zzfm_paymentmethod.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IO_DATA) TYPE  ZZS_DTIMP_TFI005 OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE  ZZS_DTIMP_TFI005
*"----------------------------------------------------------------------
    eo_data = io_data.


**********************************************************************
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.
* APAR Item Control
    DATA: lt_je  TYPE TABLE FOR ACTION IMPORT i_journalentrytp~change.
    APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<je>).
    DATA lt_aparitem LIKE <je>-%param-_aparitems.
    DATA ls_aparitem LIKE LINE OF lt_aparitem.
    DATA ls_aparitem_control LIKE ls_aparitem-%control.
    ls_aparitem_control-paymentterms = if_abap_behv=>mk-on.
    IF io_data-paymentmethod_a NE 'A'.
      ls_aparitem_control-bpbankaccountinternalid = if_abap_behv=>mk-on.
    ENDIF.
* Test Data
    <je>-accountingdocument = io_data-accountingdocument.
    <je>-fiscalyear = io_data-fiscalyear.
    <je>-companycode = io_data-companycode.
    <je>-%param = VALUE #(
     _aparitems = VALUE #( (
     glaccountlineitem = io_data-accountingdocumentitem
     paymentterms = io_data-accountingclerkphonenumber
     "paymentterms = '123'
     bpbankaccountinternalid = ''
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

        eo_data-status  = 'E'.
        eo_data-message = lv_message.
      ELSE.

        "登録成功しました。
        MESSAGE s080(zpp_001) WITH 'BOM' INTO lv_message.
        eo_data-status  = 'S'.
        eo_data-message = lv_message.
      ENDIF.


ENDFUNCTION.
