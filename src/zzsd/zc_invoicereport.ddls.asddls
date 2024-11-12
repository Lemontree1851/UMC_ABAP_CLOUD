@EndUserText.label: '請求書出力报表'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_INVOICEREPORT
provider contract transactional_query  as projection on ZR_INVOICEREPORT
{
  key BillingDocument,
  key BillingDocumentItem,
  BillingDocumentType,
  BillingDocumentDate,
  BillingDocumentItemText,
  SoldToParty,
  SalesOrganization,
  PayerParty,
  BillToParty,
  ShippingPoint,
  SalesOffice,
  Product,
  BillingQuantity,
  BillingQuantityUnit,
  OverallSDProcessStatus,
  CreatedByUser,
  CreationDate,
  NetAmount,
  TransactionCurrency,
  SalesDocument,
  SalesDocumentItem,
  TotalNetAmount,
  MaterialByCustomer,
  CompanyCodeParameterValue,
  PostalCode,
  CityName,
  CustomerName,
  FaxNumber,
  TelephoneNumber1,
  UnitPrice,
  ConditionQuantity,
  ConditionQuantityUnit,
  TaxRate,
  NetAmount10,
  NetAmountTax10,
  NetAmountIncludeTax10,
  NetAmountExclude,
  InvoiceNo,
  _BC1001.zvalue2 as TheCompanyPostalCode,
  _BC1001.zvalue3 as TheCompanyCityName1,
  _BC1001.zvalue4 as TheCompanyCityName2,
  _BC1001.zvalue5 as TheCompanyTelNumber,
  _BC1001.zvalue6 as TheCompanyFaxNumber,
  _BC1001.zvalue7 as TheCompanyName,

//  汇款地址 vbrk tx05 长文本
// 效率太低，且报表不展示,只打印时获取，考虑在调用打印的actin返回数据之后再获取一下文本
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GET_INVOICEREPORT_LONGTEXT' 
  virtual RemitAddress : abap.string
//  RemitAddress
}
