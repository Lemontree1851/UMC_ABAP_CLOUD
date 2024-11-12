@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '請求書出力报表'
define root view entity ZR_INVOICEREPORT as select from ZR_INVOICEOUTPUT
{
  key BillingDocument,
  key BillingDocumentItem,
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
  NetAmount,
  TransactionCurrency,
  SalesDocument,
  SalesDocumentItem,
  /* Associations */
  _Head.BillingDocumentType,
  _Head.OverallSDProcessStatus,
  _Head.CreatedByUser,
  _Head.CreationDate,
  _Head.TotalNetAmount,
  _SalesDocumentItem.MaterialByCustomer,
  _AddiCompnay.CompanyCodeParameterValue,
  _Customer.PostalCode,
  _Customer.CityName,
  _Customer.CustomerName,
  _Customer.FaxNumber,
  _Customer.TelephoneNumber1,
  case when _PrcElemtPrice.ConditionQuantity = 0
    then 0
    else cast( _PrcElemtPrice.ConditionRateValue / _PrcElemtPrice.ConditionQuantity as abap.dec(23,2) )
  end as UnitPrice,
  _PrcElemtPrice.ConditionQuantity,
  _PrcElemtPrice.ConditionQuantityUnit,
  concat(cast(cast(_PrcElemtRate.ConditionRateValue as abap.int1 ) as abap.char(3)), '%') as TaxRate,
  NetAmount10,
  //get_numeric_value 会自动将金额内部值转为外部值
  division( cast (get_numeric_value(NetAmount10) as abap.dec(17) ),10,0) as  NetAmountTax10,
  //NetAmount10 * 1.1
  cast (get_numeric_value(NetAmount10) as abap.dec(17)) * cast(1.1 as abap.dec(2,1)) as NetAmountIncludeTax10,
  //消费税对象外
  NetAmountExclude,
  _SD1008.invoice_no as InvoiceNo,
  _BC1001
}
