@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 005'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BI003_REPORT_005
  as select from ZI_BI003_REPORT_005_MATDOC( p_recover_type:'SS' )
{
  key MaterialDocument                    as MaterialDocument,
  key MaterialDocumentYear                as MaterialDocumentYear,
  key MaterialDocumentItem                as MaterialDocumentItem,

      @EndUserText: { label:  'Billing Document', quickInfo: 'Billing Document' }
  key cast('' as vbeln_va)                as BillingDocument,

      @EndUserText: { label:  'Billing Document Item', quickInfo: 'Billing Document Item' }
  key cast('000000' as posnr_va)          as BillingDocumentItem,


      @ObjectModel.text.element: [ 'ProductName' ]
      @EndUserText: { label:  'Material', quickInfo: 'Material' }
      Material,

      @EndUserText: { label:  'Material Text', quickInfo: 'Material Text' }
      _ProductText.ProductName,

      RecoveryManagementNumber,


      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      QuantityInEntryUnit,
      EntryUnit,

      FiscalYearPeriod,
      FiscalYear,
      FiscalMonth,

      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      CompanyCode,
      _CompanyCode.CompanyCodeName,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      RecoveryNecessaryAmount,

      CompanyCurrency,

      @ObjectModel.text.element: [ 'GLAccountName' ]
      GLAccount,
      _GLAccountText.GLAccountName,

      cast('' as vbeln_va)                as SalesOrderDocument,
      cast('000000' as posnr_va)          as SalesOrderDocumentItem,

      @ObjectModel.text.element: [ 'CustomerName' ]
      cast('' as kunnr)                   as Customer,
      cast('' as abap.char(80))           as CustomerName,

      cast('' as waers)                   as TransactionCurrency,

      @ObjectModel.text.element: [ 'BillingProductText' ]
      @EndUserText: { label:  'Billing Product', quickInfo: 'Billing Product' }
      cast('' as matnr)                   as BillingProduct,

      @EndUserText: { label:  'Billing Product Text', quickInfo: 'Billing Product Text' }
      cast('' as maktx)                   as BillingProductText,

      cast('00000000' as fkdat)           as BillingDocumentDate,

      @ObjectModel.text.element: [ 'ProfitCenterName' ]
      cast('' as prctr)                   as ProfitCenter,

      cast('' as abap.char(40))           as ProfitCenterName,

      cast('' as vrkme)                   as BillingQuantityUnit,

      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      cast('0.000' as abap.quan( 13, 3 )) as BillingQuantity,

      cast('' as waers)                   as BillingCurrency,

      @Semantics.amount.currencyCode: 'BillingCurrency'
      cast('0.00' as abap.curr(16, 2))    as BillingPrice,

      cast('' as kscha)                   as ConditionType,

      @Semantics.amount.currencyCode: 'BillingCurrency'
      @EndUserText: { label:  'Condition Amount', quickInfo: 'Condition Amount' }
      cast('0.00' as dmbtr)               as ConditionRateAmount,

      @Semantics.amount.currencyCode: 'BillingCurrency'
      @EndUserText: { label:  'Recovery Amount', quickInfo: 'Recovery Amount' }
      cast('0.00' as dmbtr)               as RecoveryAmount
}
union select from ZI_BI003_REPORT_005_BILLING
{
  key    cast( '' as mblnr )                 as MaterialDocument,
  key    cast('0000' as mjahr)               as MaterialDocumentYear,
  key    cast('0000' as mblpo)               as MaterialDocumentItem,
  key    BillingDocument,
  key    BillingDocumentItem,

         cast('' as matnr)                   as Material,
         cast('' as maktx)                   as ProductName,

         RecoveryManagementNumber,


         cast('0.000' as abap.quan( 13, 3 )) as QuantityInEntryUnit,
         cast('' as meins)                   as EntryUnit,

         _FiscalCalendarDate.FiscalYearPeriod,
         _FiscalCalendarDate.FiscalYear,

         case _FiscalCalendarDate.FiscalPeriod when '000' then '00'
                  else cast( substring(_FiscalCalendarDate.FiscalPeriod, 2, 2) as monat )
                  end                        as FiscalMonth,

         CompanyCode,
         _Companycode.CompanyCodeName,

         cast('0.00' as dmbtr)               as RecoveryNecessaryAmount,


         _Companycode.Currency               as CompanyCurrency,

         cast('' as hkont)                   as GLAccount,
         cast('' as abap.char(40))           as GLAccountName,

         salesorderdocument,
         salesorderdocumentitem,

         SoldToParty                         as Customer,
         _Customer.CustomerName,

         TransactionCurrency,

         billingproduct,

         _ProductText.ProductName            as BillingProductText,

         BillingDocumentDate,

         ProfitCenter,

         _ProfitCetnerText.ProfitCenterName,

         BillingQuantityUnit,

         BillingQuantity,

         _Companycode.Currency               as BillingCurrency,

         currency_conversion( amount=>BillingPrice,
                              exchange_rate_date=>BillingDocumentDate,
                              source_currency=>TransactionCurrency,
                              target_currency=>_Companycode.Currency
                            )                as BillingPrice,

         ConditionType,

         //         cast( currency_conversion( amount=>ConditionRateAmount,
         //                                    exchange_rate_date=>BillingDocumentDate,
         //                                    source_currency=>TransactionCurrency,
         //                                    target_currency=>_Companycode.Currency
         //                                  )  as dmbtr
         //              )                              as ConditionRateAmount,

         //cast(ConditionRateAmount as dmbtr)  as ConditionRateAmount,

         currency_conversion( amount=>cast( ConditionRateAmount as dmbtr ),
                           exchange_rate_date=>BillingDocumentDate,
                           source_currency=>TransactionCurrency,
                           target_currency=>_Companycode.Currency
                         )                   as ConditionRateAmount,

         currency_conversion( amount=>RecoveryAmount,
                                      exchange_rate_date=>BillingDocumentDate,
                                      source_currency=>TransactionCurrency,
                                      target_currency=>_Companycode.Currency
                             )               as RecoveryAmount //BillingTotalAmount

}