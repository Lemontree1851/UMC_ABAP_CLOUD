@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '支払方法変更'
define root view entity ZC_PAYMETHOD 
  provider contract transactional_query
  as projection on ZR_PAYMETHOD 
{
  key UUID,

      AccountingDocument,
      FiscalYear,
      AccountingDocumentItem,
      PostingDate,
      
      AmountInCompanyCodeCurrency,
      CompanyCodeCurrency,
      AccountingClerkPhoneNumber,
      AccountingClerkFaxNumber,
      PaymentMethod_a,
      CompanyCode,
      Supplier,
      LastDate,
      NetdueDate,
      PaymentMethod,
      PaymentTerms,
      
      Status,  // ステータス
      Message, // メッセージ
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
