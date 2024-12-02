@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 002 Billing Info'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_REPORT_002_BILLING_F5
  with parameters
    p_recover_type   : ze_recycle_type,
    p_condition_type : kscha
  as select from    I_BillingDocumentItem          as billingitem
    inner join      ZR_TBI_RECY_INFO001            as recover_info  on  billingitem.YY1_ManagementNo_3_BDI = recover_info.RecoveryManagementNumber
                                                                    and recover_info.RecoveryType          = $parameters.p_recover_type
    left outer join I_BillingDocItemPrcgElmntBasic as BillingPrice  on  BillingPrice.BillingDocument     = billingitem.BillingDocument
                                                                    and BillingPrice.BillingDocumentItem = billingitem.BillingDocumentItem
                                                                    and BillingPrice.ConditionType       = $parameters.p_condition_type
    left outer join I_SalesDocument                as SalesDocument on SalesDocument.SalesDocument = billingitem.SalesDocument
    left outer join I_Currency                     as Currency      on Currency.Currency = billingitem.TransactionCurrency
  association [1]    to I_CompanyCode                 as _Companycode        on  _Companycode.CompanyCode = $projection.CompanyCode


  association [1]    to I_Customer                    as _Customer           on  _Customer.Customer = $projection.SoldToParty
  association [0..1] to I_ProfitCenterText            as _ProfitCetnerText   on  _ProfitCetnerText.ProfitCenter = $projection.ProfitCenter
                                                                             and _ProfitCetnerText.Language     = $session.system_language
  association [0..1] to I_ProductText                 as _ProductText        on  _ProductText.Product  = $projection.billingproduct
                                                                             and _ProductText.Language = $session.system_language
  association [0..1] to I_FiscCalendarDateForCompCode as _FiscalCalendarDate on  _FiscalCalendarDate.CalendarDate = $projection.BillingDocumentDate
                                                                             and _FiscalCalendarDate.CompanyCode  = $projection.CompanyCode
{
  key billingitem.BillingDocument,
  key billingitem.BillingDocumentItem,
      billingitem.BillingDocumentDate,
      billingitem.Product                       as billingproduct,
      billingitem.ProfitCenter,

      @Semantics.quantity.unitOfMeasure: 'billingquantityunit'
      billingitem.BillingQuantity,
      billingitem.BillingQuantityUnit,
      billingitem.TransactionCurrency,

      @Semantics.amount.currencyCode: 'transactioncurrency'
      case billingitem.BillingQuantity when 0 then billingitem.NetAmount
      else
        cast (
                cast( billingitem.NetAmount as abap.dec(16, 2) ) / ( cast( billingitem.BillingQuantity as abap.dec(13, 3) )
             ) as abap.curr(16, 2) )
      end                                       as BillingPrice,

      billingitem.SalesDocument                 as salesorderdocument,
      billingitem.SalesDocumentItem             as salesorderdocumentitem,

      @Semantics.amount.currencyCode: 'transactioncurrency'
      billingitem.NetAmount                     as BillingNetAmount,

      recover_info.CompanyCode,
      recover_info.RecoveryManagementNumber,


      BillingPrice.ConditionType,


      case Currency.Decimals
      when 3 then BillingPrice.ConditionRateAmount * 10
      when 2 then BillingPrice.ConditionRateAmount
      when 1 then BillingPrice.ConditionRateAmount / 10
      when 0 then BillingPrice.ConditionRateAmount / 100
      else BillingPrice.ConditionRateAmount end as ConditionRateAmount,


      SalesDocument.SoldToParty,

      _Companycode,
      _Customer,
      _ProfitCetnerText,
      _ProductText,
      _FiscalCalendarDate
}
