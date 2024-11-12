@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 002'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_BI003_REPORT_002
  as select from ZI_BI003_REPORT_002_PO(p_recover_type : 'SB')
{
  key PurchaseOrder,
  key PurchaseOrderItem,

      @EndUserText: { label:  'Billing Document', quickInfo: 'Billing Document' }
  key cast('' as vbeln_va)                as BillingDocument,

      @EndUserText: { label:  'Billing Document Item', quickInfo: 'Billing Document Item' }
  key cast('000000' as posnr_va)          as BillingDocumentItem,
      RecoveryManagementNumber,
      DocumentCurrency,
      BaseUnit,
      _PurchaseOrder.CreationDate,
      _CompanyCode.Currency               as CompanyCurrency,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      OrderQuantity,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Amount', quickInfo: 'Net Price Amount' }
      NetPriceAmount,



      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      CompanyCode,

      @ObjectModel.text.element: [ 'SpotbuyMaterialText' ]
      @EndUserText: { label:  'Spotbuy Material', quickInfo: 'Spotbuy Material' }
      Material                            as SpotbuyMaterial,

      @EndUserText: { label:  'Spotbuy Material Text', quickInfo: 'Spotbuy Material Text' }
      _ProductText.ProductName            as SpotbuyMaterialText,

      @ObjectModel.text.element: [ 'ProductOldText' ]
      @EndUserText: { label:  'Old Product ID', quickInfo: 'Old Product ID' }
      ProductOldID,

      @EndUserText: { label:  'Old Product Text', quickInfo: 'Old Product Text' }
      _OldMaterial.ProductName            as ProductOldText,

      _Matdoc.FiscalYearPeriod,

      @Consumption.filter      : { selectionType: #SINGLE, multipleSelections: false }
      _Matdoc.FiscalYear,

      @Consumption.filter      : { selectionType: #SINGLE, multipleSelections: true }
      _Matdoc.FiscalMonth,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Old Material Price', quickInfo: 'Old Material Price' }
      //_OldMaterial.NetPriceAmount as OldMaterialPrice,
      cast( currency_conversion( amount => _OldMaterial.NetPriceAmount,
                           exchange_rate_date =>_PurchaseOrder.CreationDate,
                           source_currency => DocumentCurrency,
                           target_currency => _CompanyCode.Currency
                         )   as dmbtr )   as OldMaterialPrice,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Diff', quickInfo: 'Net Price Diff' }
      cast( currency_conversion( amount => NetPriceAmount - _OldMaterial.NetPriceAmount ,
                           exchange_rate_date => _PurchaseOrder.CreationDate,
                           source_currency => DocumentCurrency,
                           target_currency => _CompanyCode.Currency
                         )   as dmbtr )   as NetPriceDiff,



      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      cast ( cast( currency_conversion( amount => NetPriceAmount - _OldMaterial.NetPriceAmount ,
                   exchange_rate_date => _PurchaseOrder.CreationDate,
                   source_currency => DocumentCurrency,
                   target_currency => _CompanyCode.Currency
                 ) as abap.dec( 16, 2 ) ) * OrderQuantity
             as dmbtr
           )                              as RecoveryNecessaryAmount, //NetAmountDiff,

      _CompanyCode.CompanyCodeName,

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
      cast('0.00' as dmbtr)               as RecoveryAmount //BillingTotalAmount
}
union select from ZI_BI003_REPORT_002_BILLING(p_condition_type: 'ZPSB', p_recover_type: 'SB')
{
  key    cast('' as ebeln )                 as PurchaseOrder,
  key    cast('00000' as ebelp)             as PurchaseOrderItem,
  key    BillingDocument,
  key    BillingDocumentItem,
         RecoveryManagementNumber,
         cast('' as waers)                  as DocumentCurrency,
         cast('' as vrkme)                  as BaseUnit,
         cast('00000000' as abap.dats)      as CreationDate,
         _Companycode.Currency              as CompanyCurrency,


         cast('0' as abap.quan( 13, 3 ))    as OrderQuantity,

         cast('0.00' as dmbtr)              as NetPriceAmount,

         CompanyCode,
         cast('' as matnr)                  as SpotbuyMaterial,

         cast('' as maktx)                  as SpotbuyMaterialText,

         cast('' as matnr)                  as ProductOldID,

         cast('' as maktx)                  as ProductOldText,

         _FiscalCalendarDate.FiscalYearPeriod,

         _FiscalCalendarDate.FiscalYear,

         case _FiscalCalendarDate.FiscalPeriod when '000' then '00'
         else cast( substring(_FiscalCalendarDate.FiscalPeriod, 2, 2) as monat )
         end                                as FiscalMonth,

         cast('0.00' as dmbtr)              as OldMaterialPrice,

         cast('0.00' as dmbtr)              as NetPriceDiff,

         cast('0.00' as dmbtr)              as RecoveryNecessaryAmount, //NetAmountDiff,

         _Companycode.CompanyCodeName,

         salesorderdocument,
         salesorderdocumentitem,

         SoldToParty                        as Customer,

         _Customer.CustomerName,

         TransactionCurrency,

         billingproduct,

         _ProductText.ProductName           as BillingProductText,

         BillingDocumentDate,

         ProfitCenter,

         _ProfitCetnerText.ProfitCenterName as ProfitCenterName,

         BillingQuantityUnit,

         BillingQuantity,

         _Companycode.Currency              as BillingCurrency,


         currency_conversion( amount=>BillingPrice,
                              exchange_rate_date=>BillingDocumentDate,
                              source_currency=>TransactionCurrency,
                              target_currency=>_Companycode.Currency
                            )               as BillingPrice,



         ConditionType,

         cast( currency_conversion( amount=>ConditionRateAmount,
                              exchange_rate_date=>BillingDocumentDate,
                              source_currency=>TransactionCurrency,
                              target_currency=>_Companycode.Currency
                            )  as dmbtr )   as ConditionRateAmount,

         case when ConditionRateAmount > 0 then
          cast ( cast( currency_conversion( amount => ConditionRateAmount,
                       exchange_rate_date => BillingDocumentDate,
                       source_currency => TransactionCurrency,
                       target_currency => _Companycode.Currency
                     ) as abap.dec( 16, 2 ) ) * BillingQuantity
                 as dmbtr
               )
         else cast ( cast( currency_conversion( amount => BillingNetAmount,
                       exchange_rate_date => BillingDocumentDate,
                       source_currency => TransactionCurrency,
                       target_currency => _Companycode.Currency
                     ) as abap.dec( 16, 2 ) )
                 as dmbtr
               )
         end                                as RecoveryAmount //BillingTotalAmount
}
