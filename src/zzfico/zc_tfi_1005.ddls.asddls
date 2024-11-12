@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TFI_1005
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TFI_1005
{
  key Uuid,
  key Accountingdocument,
  key Fiscalyear,
  key Accountingdocumentitem,
  key Companycode,
  Postingdate,
  Amountincompanycodecurrency,
  @Semantics.currencyCode: true
  Companycodecurrency,
  Accountingclerkphonenumber,
  Accountingclerkfaxnumber,
  PaymentmethodA,
  Conditiondate1,
  Supplier,
  Lastdate,
  Netduedate,
  Paymentmethod,
  Paymentterms,
  Status,
  Message,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
