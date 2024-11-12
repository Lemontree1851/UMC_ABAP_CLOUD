@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 004 Billing Info'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_REPORT_005_BILLING
  as select from ZI_BI003_REPORT_002_BILLING( p_recover_type: 'SS', p_condition_type: 'ZPSS' )
{
  key BillingDocument,
  key BillingDocumentItem,
      BillingDocumentDate,
      billingproduct,
      ProfitCenter,
      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      BillingQuantity,
      BillingQuantityUnit,
      TransactionCurrency,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      BillingNetAmount,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      BillingPrice,
      salesorderdocument,
      salesorderdocumentitem,
      CompanyCode,
      RecoveryManagementNumber,
      ConditionType,
      ConditionRateAmount,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case when ConditionRateAmount > 0 then cast( ( ConditionRateAmount * BillingQuantity ) as dmbtr )
      else BillingNetAmount //cast ( ( cast( billingnetamount as abap.dec( 16, 2 ) )  * BillingQuantity ) as dmbtr )
      end as RecoveryAmount, //BillingTotalAmount,

      SoldToParty,
      /* Associations */
      _Companycode,
      _Customer,
      _FiscalCalendarDate,
      _ProductText,
      _ProfitCetnerText
}
