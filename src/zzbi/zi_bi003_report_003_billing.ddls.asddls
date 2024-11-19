@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 002 Billing Info'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_REPORT_003_BILLING
  as select from    ZI_BI003_REPORT_002_BILLING( p_recover_type: 'IN', p_condition_type: 'ZPIN' ) as billing
    left outer join I_FiscCalendarDateForCompCode                                                 as FiscalCalendarDate on  FiscalCalendarDate.CalendarDate = billing.BillingDocumentDate
                                                                                                                        and FiscalCalendarDate.CompanyCode  = billing.CompanyCode
    left outer join ZI_BI003_REPORT_REC_NEC_AMT_S                                                 as TOTALAMT           on  billing.RecoveryManagementNumber    =  TOTALAMT.RecoveryManagementNumber
                                                                                                                        and FiscalCalendarDate.FiscalYearPeriod <= TOTALAMT.FiscalYearPeriod
    left outer join ZI_BI003_REPORT_REC_NEC_AMT_GS( p_product_group:'400' )                       as GRPTOTAL           on  billing.RecoveryManagementNumber    = GRPTOTAL.RecoveryManagementNumber
                                                                                                                        and FiscalCalendarDate.FiscalYearPeriod = GRPTOTAL.FiscalYearPeriod
{
  key billing.BillingDocument,
  key billing.BillingDocumentItem,
      billing.BillingDocumentDate,
      billing.billingproduct,
      billing.ProfitCenter,
      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      billing.BillingQuantity,
      billing.BillingQuantityUnit,
      billing.TransactionCurrency,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      billing.BillingNetAmount,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      billing.BillingPrice,
      billing.salesorderdocument,
      billing.salesorderdocumentitem,
      billing.CompanyCode,
      billing.RecoveryManagementNumber,
      billing.ConditionType,
      billing.ConditionRateAmount,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case when billing.ConditionRateAmount > 0 then cast( ( billing.ConditionRateAmount * billing.BillingQuantity ) as dmbtr )
      else billing.BillingNetAmount
      end        as RecoveryAmount, //BillingTotalAmount,

      billing.SoldToParty,
      /* Associations */
      billing._Companycode,
      billing._Customer,
      billing._FiscalCalendarDate,
      billing._ProductText,
      billing._ProfitCetnerText,

      case when TOTALAMT.TotalAmount <> 0
      then round( cast( ( cast( GRPTOTAL.TotalGroupAmount as abap.dec(16, 2) ) /
                   cast( TOTALAMT.TotalAmount as abap.dec(16, 2) )
               ) as abap.dec( 16, 4 ) ), 4)
      else 0 end as PercentageOfAp

}
