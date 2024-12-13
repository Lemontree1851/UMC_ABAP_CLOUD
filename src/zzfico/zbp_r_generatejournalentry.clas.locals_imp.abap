CLASS lsc_zr_generatejournalentry DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zr_generatejournalentry IMPLEMENTATION.

  METHOD save_modified.

    DATA: ls_insert TYPE ztfi_1017,
          lt_insert TYPE TABLE OF ztfi_1017.

    IF zbp_r_generatejournalentry=>gt_temp_key IS NOT INITIAL.
      LOOP AT zbp_r_generatejournalentry=>gt_temp_key INTO DATA(ls_temp_key).
        CONVERT KEY OF i_journalentrytp FROM ls_temp_key-pid TO FINAL(lv_root_key).
        APPEND VALUE #( cid = ls_temp_key-cid
                        companycode = lv_root_key-companycode
                        accountingdocument = lv_root_key-accountingdocument
                        fiscalyear = lv_root_key-fiscalyear ) TO zbp_r_generatejournalentry=>gt_final_key.
      ENDLOOP.
    ENDIF.

    LOOP AT create-zr_generatejournalentry INTO DATA(ls_create).
      READ TABLE zbp_r_generatejournalentry=>gt_final_key INTO DATA(ls_key) WITH KEY cid = ls_insert-uuid.
      IF sy-subrc = 0.
        ls_insert = CORRESPONDING #( ls_create ).
        ls_insert = CORRESPONDING #( ls_key ).
        APPEND ls_insert TO lt_insert.
      ENDIF.
    ENDLOOP.

    IF lt_insert IS NOT INITIAL.
      INSERT ztfi_1017 FROM TABLE @lt_insert.
    ENDIF.

    IF update IS NOT INITIAL.
      UPDATE ztfi_1017 FROM TABLE @update-zr_generatejournalentry
      INDICATORS SET STRUCTURE %control MAPPING FROM ENTITY.
    ENDIF.

    IF delete IS NOT INITIAL.
      LOOP AT delete-zr_generatejournalentry INTO DATA(ls_delete).
        DELETE FROM ztfi_1017 WHERE uuid = @ls_delete-uuid.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_zr_generatejournalentry DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_generatejournalentry RESULT result.

    METHODS post FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_generatejournalentry~post.

ENDCLASS.

CLASS lhc_zr_generatejournalentry IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD post.
    DATA: ls_request TYPE zbp_r_generatejournalentry=>ty_request.

    DATA: lt_entry   TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
          ls_entry   LIKE LINE OF lt_entry,
          ls_glitem  LIKE LINE OF ls_entry-%param-_glitems,
          ls_apitems LIKE LINE OF ls_entry-%param-_apitems,
          ls_aritems LIKE LINE OF ls_entry-%param-_aritems.

    READ ENTITIES OF zr_generatejournalentry IN LOCAL MODE
    ENTITY zr_generatejournalentry
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT FINAL(lt_data).

    CLEAR lt_entry.
    LOOP AT lt_data INTO DATA(ls_data).
      xco_cp_json=>data->from_string( ls_data-jsondata )->apply( VALUE #(
                ( xco_cp_json=>transformation->pascal_case_to_underscore )
                ( xco_cp_json=>transformation->boolean_to_abap_bool )
              ) )->write_to( REF #( ls_request ) ).

      CLEAR: ls_entry,ls_glitem.

      " use UUID as CID
      ls_entry-%cid = ls_data-uuid.
      ls_entry-%param = VALUE #( companycode                  = ls_request-company_code
                                 businesstransactiontype      = ls_request-business_transaction_type
                                 postingdate                  = ls_request-posting_date
                                 documentdate                 = ls_request-document_date
                                 accountingdocumenttype       = ls_request-accounting_document_type
                                 accountingdocumentheadertext = ls_request-document_header_text ).

      LOOP AT ls_request-items INTO DATA(ls_item).
        ls_glitem = VALUE #( glaccountlineitem = ls_item-g_l_account_line_item
                             glaccount         = ls_item-g_l_account
                             taxcode           = ls_item-tax_code
                             documentitemtext  = ls_item-document_item_text ).

        LOOP AT ls_item-amount INTO DATA(ls_amount).
          ls_glitem-_currencyamount = VALUE #( BASE ls_glitem-_currencyamount (
                                      currencyrole           = ls_amount-currency_role
                                      journalentryitemamount = ls_amount-journal_entry_item_amount
                                      currency               = ls_amount-currency ) ).
        ENDLOOP.
        APPEND ls_glitem TO ls_entry-%param-_glitems.
      ENDLOOP.

      LOOP AT ls_request-apitems INTO DATA(ls_apitem).
        ls_apitems = VALUE #( glaccountlineitem = ls_apitem-glaccountlineitem
                              supplier          = ls_apitem-supplier ).
        APPEND ls_apitems TO ls_entry-%param-_apitems.
      ENDLOOP.

      LOOP AT ls_request-aritems INTO DATA(ls_aritem).
        ls_aritems = VALUE #( glaccountlineitem = ls_aritem-glaccountlineitem
                              paymentterms = ls_aritem-paymentterms ).
        APPEND ls_aritems TO ls_entry-%param-_aritems.
      ENDLOOP.

      APPEND ls_entry TO lt_entry.
    ENDLOOP.

    IF lt_entry IS NOT INITIAL.
      MODIFY ENTITIES OF i_journalentrytp PRIVILEGED
      ENTITY journalentry
      EXECUTE post FROM lt_entry
      MAPPED FINAL(ls_post_mapped)
      FAILED FINAL(ls_post_failed)
      REPORTED FINAL(ls_post_reported).

      IF ls_post_failed IS NOT INITIAL.
        LOOP AT ls_post_reported-journalentry INTO DATA(ls_report).

        ENDLOOP.
      ELSE.
        LOOP AT ls_post_mapped-journalentry INTO DATA(ls_je_mapped).
          APPEND VALUE #( cid = ls_je_mapped-%cid
                          pid = ls_je_mapped-%pid ) TO zbp_r_generatejournalentry=>gt_temp_key.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
