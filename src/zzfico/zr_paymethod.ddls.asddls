@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '支払方法変更'
define root view entity ZR_PAYMETHOD
  as select from ztfi_1005
{
  key uuid                        as UUID,

      accountingdocument          as AccountingDocument,
      fiscalyear                  as FiscalYear,
      accountingdocumentitem      as AccountingDocumentItem,
      postingdate                 as PostingDate,
      amountincompanycodecurrency as AmountInCompanyCodeCurrency,
      companycodecurrency         as CompanyCodeCurrency,
      accountingclerkphonenumber  as AccountingClerkPhoneNumber,
      accountingclerkfaxnumber    as AccountingClerkFaxNumber,
      paymentmethod_a             as PaymentMethod_a,
      conditiondate1              as ConditionDate1,
      companycode                 as CompanyCode,
      supplier                    as Supplier,
      lastdate                    as LastDate,
      netduedate                  as NetdueDate,
      paymentmethod               as PaymentMethod,
      paymentterms                as PaymentTerms,

      status                      as Status,  // ステータス
      message                     as Message, // メッセージ
      @Semantics.user.createdBy: true
      created_by                  as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                  as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by             as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at             as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at       as LocalLastChangedAt
}
