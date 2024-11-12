CLASS zbp_r_generatejournalentry DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zr_generatejournalentry.

  " D_JournalEntryPostCurrencyAmtP
  TYPES: BEGIN OF ty_amount,
           currency_role             TYPE curtp,
           journal_entry_item_amount TYPE wrbtr,
           currency                  TYPE waers,
         END OF ty_amount.
  " D_JournalEntryPostGLItemP
  TYPES: BEGIN OF ty_item,
           g_l_account_line_item TYPE i_journalentryitem-ledgergllineitem,
           g_l_account           TYPE i_journalentryitem-glaccount,
           tax_code              TYPE i_journalentryitem-taxcode,
           document_item_text    TYPE i_journalentryitem-documentitemtext,
           amount                TYPE TABLE OF ty_amount WITH DEFAULT KEY,
         END OF ty_item.
  TYPES: BEGIN OF ty_apitems,
           glaccountlineitem     TYPE i_journalentryitem-ledgergllineitem,
           supplier              TYPE c LENGTH 50,
         END OF ty_apitems.
  TYPES: BEGIN OF ty_aritems,
           glaccountlineitem      TYPE i_journalentryitem-ledgergllineitem,
           paymentterms           TYPE c LENGTH 50,
         END OF ty_aritems.
  TYPES: BEGIN OF ty_request,
           company_code              TYPE i_journalentrytp-companycode,
           business_transaction_type TYPE i_journalentrytp-businesstransactiontype,
           posting_date              TYPE i_journalentrytp-postingdate,
           document_date             TYPE i_journalentrytp-documentdate,
           accounting_document_type  TYPE i_journalentrytp-accountingdocumenttype,
           document_header_text      TYPE i_journalentrytp-accountingdocumentheadertext,
           items                     TYPE TABLE OF ty_item WITH DEFAULT KEY,
           apitems                   TYPE TABLE OF ty_apitems WITH DEFAULT KEY,
           aritems                   TYPE TABLE OF ty_aritems WITH DEFAULT KEY,
         END OF ty_request.

  TYPES: BEGIN OF ty_temp_key,
           cid TYPE abp_behv_cid,
           pid TYPE abp_behv_pid,
         END OF ty_temp_key,
         tt_temp_key TYPE STANDARD TABLE OF ty_temp_key WITH DEFAULT KEY,
         BEGIN OF ty_final_key,
           cid                TYPE abp_behv_cid,
           companycode        TYPE bukrs,
           fiscalyear         TYPE belnr_d,
           accountingdocument TYPE gjahr,
         END OF ty_final_key,
         tt_final_key TYPE STANDARD TABLE OF ty_final_key WITH DEFAULT KEY.

  CLASS-DATA: gt_temp_key  TYPE tt_temp_key,
              gt_final_key TYPE tt_final_key.

ENDCLASS.



CLASS ZBP_R_GENERATEJOURNALENTRY IMPLEMENTATION.
ENDCLASS.
