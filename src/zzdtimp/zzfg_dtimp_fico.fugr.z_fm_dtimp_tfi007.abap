FUNCTION z_fm_dtimp_tfi007.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
*********************************************************************

  DATA:lv_msg1 TYPE cl_bali_free_text_setter=>ty_text .
  DATA:lv_msg  TYPE string.
  DATA:ls_data TYPE zr_paymethod.
  DATA:lt_data TYPE TABLE OF zr_paymethod.
  DATA:lv_uuid1 TYPE sysuuid_x16.
  DATA:lv_message TYPE string.
  DATA:ls_run TYPE zr_paymethod_sum.
  DATA:ls_run_old TYPE zr_paymethod_sum.
  DATA:lv_housebank(5) TYPE c .
  DATA:lv_housebankaccount(5) TYPE c .
  DATA: mv_uuid TYPE sysuuid_x16.
  DATA: dyn_wa TYPE REF TO data.
  FIELD-SYMBOLS: <dyn_table> TYPE table,
                 <dyn_wa>    TYPE any.

  CLEAR ls_run .
  CREATE DATA eo_data TYPE TABLE OF (iv_struc).
  ASSIGN eo_data->* TO <dyn_table>.
  CREATE DATA dyn_wa LIKE LINE OF <dyn_table>.
  ASSIGN dyn_wa->* TO <dyn_wa>.

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line1>).
    mv_uuid =  <line1>-('Uuidall').
  ENDLOOP.

  CLEAR <dyn_table>.

  SELECT * FROM ztfi_1023
  WHERE uuid = @mv_uuid
  INTO TABLE @DATA(lt_ztfi_1023) .            "#EC CI_ALL_FIELDS_NEEDED

  CLEAR ls_run .

  SELECT *
    FROM ztbc_1001
  WHERE  zid   = 'ZFI010'
  INTO TABLE @DATA(lt_ztbc).                  "#EC CI_ALL_FIELDS_NEEDED

  SORT lt_ztfi_1023 BY uuid_all uuid.

  LOOP AT lt_ztfi_1023 ASSIGNING FIELD-SYMBOL(<line>).
    TRY.
        DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
        ##NO_HANDLER
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.
    CLEAR ls_data.
    ls_data-uuid                                = lv_uuid.
    ls_data-accountingdocument                  = <line>-accountingdocument.
    ls_data-fiscalyear                          = <line>-fiscalyear.
    ls_data-accountingdocumentitem              = <line>-accountingdocumentitem.
    ls_data-postingdate                         = <line>-postingdate.
    ls_data-amountincompanycodecurrency         = <line>-amountincompanycodecurrency.
    ls_data-companycodecurrency                 = <line>-companycodecurrency.
    ls_data-accountingclerkphonenumber          = <line>-accountingclerkphonenumber.
    ls_data-accountingclerkfaxnumber            = <line>-accountingclerkfaxnumber.
    ls_data-paymentmethod_a                     = <line>-paymentmethod_a.
    ls_data-conditiondate1                      = <line>-conditiondate.
    ls_data-companycode                         = <line>-companycode.
    ls_data-supplier                            = <line>-supplier.
    ls_data-lastdate                            = <line>-lastdate.
    ls_data-netduedate                          = <line>-netduedate.
    ls_data-paymentmethod                       = <line>-paymentmethod.
    ls_data-paymentterms                        = <line>-paymentterms.

    ls_run-uuid                                = <line>-uuid                         .
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
    "  MESSAGE s006(zbc_001) WITH TEXT-001 INTO <line>-Message.
    "ENDIF.


    IF ls_data-accountingclerkfaxnumber = ls_data-paymentterms.
      MESSAGE s025(zfico_001) WITH ls_data-fiscalyear ls_data-companycode ls_data-accountingdocument INTO lv_message .
      ls_data-message = lv_message.
      ls_data-status = 'S'.
    ELSE.


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

      READ TABLE lt_ztbc INTO DATA(ls_ztbc) WITH KEY zvalue1 = ls_data-companycode
      zvalue2 = ls_data-paymentmethod zvalue3 = ls_data-paymentmethod_a.
      IF sy-subrc = 0  .
        ls_aparitem_control-housebank        = if_abap_behv=>mk-on.
        ls_aparitem_control-housebankaccount = if_abap_behv=>mk-on.
        lv_housebank        = ls_ztbc-zvalue4.
        lv_housebankaccount = ls_ztbc-zvalue5.
      ENDIF.

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
       housebank               = lv_housebank
       housebankaccount        = lv_housebankaccount
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
*                                            conditiondate1              = ls_data-conditiondate1
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



    ENDIF.
    <line>-type    = ls_data-status.
    <line>-message = ls_data-message.

    MOVE-CORRESPONDING <line> TO <dyn_wa>.
    APPEND  <dyn_wa> TO <dyn_table>.


    lv_msg1 = ls_data-message.

    IF ls_data-status NE 'S'.
      ls_run-message =  |{ <line>-message }{ '/' }{ ls_run-message }|.
    ENDIF.

*    IF ls_run_old-uuid NE ls_run-uuid AND ls_run_old-uuid IS NOT INITIAL.
*      IF ls_run_old-status IS INITIAL.
*        ls_run_old-status = 'S'.
*      ENDIF.
*
*      GET TIME STAMP FIELD lv_timestamp.
*
*      INSERT INTO ztfi_1006 VALUES  @( VALUE #(
*                                            uuid                        = ls_run_old-uuid
*                                            amountincompanycodecurrency = ls_run_old-amountincompanycodecurrency
*                                            companycodecurrency         = ls_run_old-companycodecurrency
*                                            accountingclerkphonenumber  = ls_run_old-accountingclerkphonenumber
*                                            accountingclerkfaxnumber    = ls_run_old-accountingclerkfaxnumber
*                                            paymentmethod_a             = ls_run_old-paymentmethod_a
*                                            companycode                 = ls_run_old-companycode
*                                            supplier                    = ls_run_old-supplier
*                                            lastdate                    = ls_run_old-lastdate
*                                            netduedate                  = ls_run_old-netduedate
*                                            paymentmethod               = ls_run_old-paymentmethod
*                                            paymentterms                = ls_run_old-paymentterms
*                                            status                      = ls_run_old-status
*                                            message                     = ls_run_old-message
*
*                                            created_by         = sy-uname
*                                            created_at         = lv_timestamp
*                                            last_changed_by    = sy-uname
*                                            last_changed_at    = lv_timestamp
*                                            local_last_changed_at = lv_timestamp ) ).
*    ENDIF.
*    ls_run_old = ls_run.

  ENDLOOP.
*  IF sy-subrc = 0 .
*
*    IF ls_run-status IS INITIAL.
*      ls_run-status = 'S'.
*    ENDIF.
*
*    GET TIME STAMP FIELD lv_timestamp.
*
*    INSERT INTO ztfi_1006 VALUES  @( VALUE #(
*                                          uuid                        = lv_uuid
*                                          amountincompanycodecurrency = ls_run-amountincompanycodecurrency
*                                          companycodecurrency         = ls_run-companycodecurrency
*                                          accountingclerkphonenumber  = ls_run-accountingclerkphonenumber
*                                          accountingclerkfaxnumber    = ls_run-accountingclerkfaxnumber
*                                          paymentmethod_a             = ls_run-paymentmethod_a
*                                          companycode                 = ls_run-companycode
*                                          supplier                    = ls_run-supplier
*                                          lastdate                    = ls_run-lastdate
*                                          netduedate                  = ls_run-netduedate
*                                          paymentmethod               = ls_run-paymentmethod
*                                          paymentterms                = ls_run-paymentterms
*                                          status                      = ls_run-status
*                                          message                     = ls_run-message
*
*                                          created_by         = sy-uname
*                                          created_at         = lv_timestamp
*                                          last_changed_by    = sy-uname
*                                          last_changed_at    = lv_timestamp
*                                          local_last_changed_at = lv_timestamp ) ).
*
*  ENDIF.








ENDFUNCTION.
