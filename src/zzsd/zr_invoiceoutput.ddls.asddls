@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '請求書出力'
define root view entity ZR_INVOICEOUTPUT
  as select from I_BillingDocumentItem
  association [0..1] to I_BillingDocument              as _Head              on  $projection.BillingDocument = _Head.BillingDocument
  association [0..1] to I_Customer                     as _Customer          on  $projection.soldtoparty = _Customer.Customer
  association [0..1] to I_AddlCompanyCodeInformation   as _AddiCompnay       on  $projection.salesorganization         = _AddiCompnay.CompanyCode
                                                                             and _AddiCompnay.CompanyCodeParameterType = 'JPCCRP'
  association [0..1] to I_SalesDocumentItem            as _SalesDocumentItem on  $projection.SalesDocument = _SalesDocumentItem.SalesDocument
                                                                             and $projection.SalesDocumentItem = _SalesDocumentItem.SalesDocumentItem
  association [0..*] to I_BillingDocumentItemPrcgElmnt as _PrcElemtPrice     on  $projection.BillingDocument            = _PrcElemtPrice.BillingDocument
                                                                             and $projection.BillingDocumentItem        = _PrcElemtPrice.BillingDocumentItem
                                                                             and _PrcElemtPrice.ConditionInactiveReason = ''
                                                                             and _PrcElemtPrice.ConditionType           = 'PPR0'
  association [0..*] to I_BillingDocumentItemPrcgElmnt as _PrcElemtRate      on  $projection.BillingDocument           = _PrcElemtRate.BillingDocument
                                                                             and $projection.BillingDocumentItem       = _PrcElemtRate.BillingDocumentItem
                                                                             and _PrcElemtRate.ConditionInactiveReason = ''
                                                                             and _PrcElemtRate.ConditionType           = 'TTX1'
  association [0..1] to ztsd_1008                      as _SD1008            on  $projection.BillingDocument     = _SD1008.billing_document
                                                                             and $projection.BillingDocumentItem = _SD1008.billing_document_item
  association [0..1] to ztbc_1001                      as _BC1001            on  $projection.ShippingPoint = _BC1001.zvalue1
                                                                             and _BC1001.zid               = 'ZSD007'
{
  key BillingDocument,
  key BillingDocumentItem,
      BillingDocumentDate,
      BillingDocumentItemText,
      _Head.SoldToParty,
      _Head.SalesOrganization,
      _Head.PayerParty,
      BillToParty,
      @EndUserText.label: '出荷ポイント'
      cast( ShippingPoint as abap.char(4) ) as ShippingPoint,
      SalesOffice,
      cast( Product as matnr preserving type ) as Product,
      BillingQuantity,
      BillingQuantityUnit,
      NetAmount,
      TransactionCurrency,
      SalesDocument,
      SalesDocumentItem,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case when _PrcElemtRate.ConditionRateValue = 10
        then NetAmount
        else cast(0 as abap.curr(15,2))
      end as NetAmount10,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case when _PrcElemtRate.ConditionRateValue <> 10
        then NetAmount
        else cast(0 as abap.curr(15,2))
      end as NetAmountExclude,
      _Head,
      _Customer,
      _AddiCompnay,
      _SalesDocumentItem,
      _PrcElemtPrice,
      _PrcElemtRate,
      _SD1008,
      _BC1001
}
