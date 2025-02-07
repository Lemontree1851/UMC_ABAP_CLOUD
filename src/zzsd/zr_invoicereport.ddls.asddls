@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '請求書出力报表'
define root view entity ZR_INVOICEREPORT
  as select from ZR_INVOICEOUTPUT     as _main
  //权限控制
    inner join   ZR_TBC1013           as _AssignSalesOrg on _AssignSalesOrg.SalesOrganization = _main.SalesOrganization
    inner join   ZC_BusinessUserEmail as _User           on  _User.Email  = _AssignSalesOrg.Mail
                                                         and _User.UserID = $session.user
{
  key _main.BillingDocument,
  key _main.BillingDocumentItem,
      _main.BillingDocumentDate,
      _main.BillingDocumentItemText,
      _main.SoldToParty,
      _main.SalesOrganization,
      _main.PayerParty,
      _main.BillToParty,
      _main.ShippingPoint,
      _main.SalesOffice,
      _main.Product,
      _main.BillingQuantity,
      _main.BillingQuantityUnit,
      _main.NetAmount,
      _main.TransactionCurrency,
      _main.SalesDocument,
      _main.SalesDocumentItem,
      /* Associations */
      _main._Head.BillingDocumentType,
      _main._Head.OverallSDProcessStatus,
      _main._Head.CreatedByUser,
      _main._Head.CreationDate,
      _main._Head.TotalNetAmount,
      _main._SalesDocumentItem.MaterialByCustomer,
      _main._AddiCompnay.CompanyCodeParameterValue,
      _main._Customer.PostalCode,
      _main._Customer.CityName,
      _main._Customer.CustomerName,
      _main._Customer.FaxNumber,
      _main._Customer.TelephoneNumber1,
      case when _main._PrcElemtPrice.ConditionQuantity = 0
        then 0
        else cast( _main._PrcElemtPrice.ConditionRateValue / _main._PrcElemtPrice.ConditionQuantity as abap.dec(23,2) )
      end                                                                                           as UnitPrice,
      _main._PrcElemtPrice.ConditionQuantity,
      _main._PrcElemtPrice.ConditionQuantityUnit,
      concat(cast(cast(_main._PrcElemtRate.ConditionRateValue as abap.int1 ) as abap.char(3)), '%') as TaxRate,
      _main.NetAmount10,
      //get_numeric_value 会自动将金额内部值转为外部值
      division( cast (get_numeric_value(_main.NetAmount10) as abap.dec(17) ),10,0)                  as NetAmountTax10,
      //NetAmount10 * 1.1
      cast (get_numeric_value(_main.NetAmount10) as abap.dec(17)) * cast(1.1 as abap.dec(2,1))      as NetAmountIncludeTax10,
      //消费税对象外
      _main.NetAmountExclude,
      _main._SD1008.invoice_no                                                                      as InvoiceNo,

      // ADD BEGIN BY XINLEI XU 2025/01/10
      _main._SD1008.invoice_item_no                                                                 as InvoiceItemNo,
      // ADD END BY XINLEI XU 2025/01/10

      _main._BC1001
}
