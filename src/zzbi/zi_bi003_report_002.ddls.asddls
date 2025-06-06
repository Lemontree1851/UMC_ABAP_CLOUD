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
      // _ProductText.ProductName            as SpotbuyMaterialText,
      PurchaseOrderItemText               as SpotbuyMaterialText, // ADD BY XINLEI XU 2025/03/19

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
      //MOD BEGIN BY XINLEI XU 2025/03/26
      //      cast( currency_conversion( amount => _OldMaterial.NetPriceAmount,
      //                           exchange_rate_date =>_PurchaseOrder.CreationDate,
      //                           source_currency => DocumentCurrency,
      //                           target_currency => _CompanyCode.Currency
      //                         )   as dmbtr )   as OldMaterialPrice,
      case when DocumentCurrency <> _CompanyCode.Currency
           then cast( currency_conversion( amount => _OldMaterial.NetPriceAmount,
                                           exchange_rate_date =>_PurchaseOrder.CreationDate,
                                           source_currency => DocumentCurrency,
                                           target_currency => _CompanyCode.Currency ) as dmbtr )
           else _OldMaterial.NetPriceAmount
      end                                 as OldMaterialPrice,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Diff', quickInfo: 'Net Price Diff' }
      //      cast( currency_conversion( amount => NetPriceAmount - _OldMaterial.NetPriceAmount ,
      //                           exchange_rate_date => _PurchaseOrder.CreationDate,
      //                           source_currency => DocumentCurrency,
      //                           target_currency => _CompanyCode.Currency
      //                         )   as dmbtr )         as NetPriceDiff,
      case when DocumentCurrency <> _CompanyCode.Currency
           then cast( currency_conversion( amount => NetPriceAmount - _OldMaterial.NetPriceAmount,
                                           exchange_rate_date => _PurchaseOrder.CreationDate,
                                           source_currency => DocumentCurrency,
                                           target_currency => _CompanyCode.Currency ) as dmbtr )
           else  NetPriceAmount - _OldMaterial.NetPriceAmount
      end                                 as NetPriceDiff,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      //      cast ( cast( currency_conversion( amount => NetPriceAmount - _OldMaterial.NetPriceAmount ,
      //                   exchange_rate_date => _PurchaseOrder.CreationDate,
      //                   source_currency => DocumentCurrency,
      //                   target_currency => _CompanyCode.Currency
      //                 ) as abap.dec( 16, 2 ) ) * OrderQuantity
      //             as dmbtr
      //           )                                                      as RecoveryNecessaryAmount,
      case when DocumentCurrency <> _CompanyCode.Currency
           then cast ( cast( currency_conversion( amount => NetPriceAmount - _OldMaterial.NetPriceAmount,
                                                  exchange_rate_date => _PurchaseOrder.CreationDate,
                                                  source_currency => DocumentCurrency,
                                                  target_currency => _CompanyCode.Currency ) as abap.dec( 16, 2 ) ) * OrderQuantity as dmbtr )
           else cast ( cast( NetPriceAmount - _OldMaterial.NetPriceAmount as abap.dec( 16, 2 ) )
                       * OrderQuantity as dmbtr )
      end                                 as RecoveryNecessaryAmount,
      //MOD END BY XINLEI XU 2025/03/26

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

         cast('0.00' as abap.curr(11, 2))   as NetPriceAmount,

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


         // MOD BEGN BY XINLEI XU 2025/03/26
         //         currency_conversion( amount=>BillingPrice,
         //                              exchange_rate_date=>BillingDocumentDate,
         //                              source_currency=>TransactionCurrency,
         //                              target_currency=>_Companycode.Currency
         //                            )               as BillingPrice,
         case when TransactionCurrency <> _Companycode.Currency
              then currency_conversion( amount=>BillingPrice,
                                        exchange_rate_date=>BillingDocumentDate,
                                        source_currency=>TransactionCurrency,
                                        target_currency=>_Companycode.Currency )
              else BillingPrice
         end                                as BillingPrice,

         ConditionType,

         //         cast( currency_conversion( amount=>ConditionRateAmount,
         //                              exchange_rate_date=>BillingDocumentDate,
         //                              source_currency=>TransactionCurrency,
         //                              target_currency=>_Companycode.Currency
         //                            )  as dmbtr )   as ConditionRateAmount,
         case when TransactionCurrency <> _Companycode.Currency
              then cast( currency_conversion( amount=>ConditionRateAmount,
                                              exchange_rate_date=>BillingDocumentDate,
                                              source_currency=>TransactionCurrency,
                                              target_currency=>_Companycode.Currency ) / ConditionQuantity as dmbtr )
              else cast( ConditionRateAmount / ConditionQuantity as dmbtr )
         end                                as ConditionRateAmount,

         case when ConditionRateAmount > 0 then
         //          cast ( cast( currency_conversion( amount => ConditionRateAmount,
         //                       exchange_rate_date => BillingDocumentDate,
         //                       source_currency => TransactionCurrency,
         //                       target_currency => _Companycode.Currency
         //                     ) as abap.dec( 16, 2 ) ) * BillingQuantity
         //                 as dmbtr
         //               )
         //         else cast ( cast( currency_conversion( amount => BillingNetAmount,
         //                       exchange_rate_date => BillingDocumentDate,
         //                       source_currency => TransactionCurrency,
         //                       target_currency => _Companycode.Currency
         //                     ) as abap.dec( 16, 2 ) )
         //                 as dmbtr
         //               )
              case when TransactionCurrency <> _Companycode.Currency
                   then cast ( cast( currency_conversion( amount => ConditionRateAmount,
                                                          exchange_rate_date => BillingDocumentDate,
                                                          source_currency => TransactionCurrency,
                                                          target_currency => _Companycode.Currency
                                                        ) as abap.dec( 16, 2 ) ) / ConditionQuantity * BillingQuantity as dmbtr )
                   else cast ( ConditionRateAmount / ConditionQuantity * BillingQuantity as dmbtr ) end
         else
              case when TransactionCurrency <> _Companycode.Currency
                   then cast ( cast( currency_conversion( amount => BillingNetAmount,
                                                          exchange_rate_date => BillingDocumentDate,
                                                          source_currency => TransactionCurrency,
                                                          target_currency => _Companycode.Currency ) as abap.dec( 16, 2 ) ) as dmbtr )
                   else BillingNetAmount end
         // MOD END BY XINLEI XU 2025/03/26
         end                                as RecoveryAmount //BillingTotalAmount
}
// ADD BEGIN BY XINLEI XU 2025/02/10
union select from ztbi_bi003_j02       as _table
  inner join      ZR_TBC1012           as _AssignCompany on _AssignCompany.CompanyCode = _table.company_code
  inner join      ZC_BusinessUserEmail as _User          on  _User.Email  = _AssignCompany.Mail
                                                         and _User.UserID = $session.user
{
  key _table.purchase_order             as PurchaseOrder,
  key _table.purchase_order_item        as PurchaseOrderItem,
  key _table.billing_document           as BillingDocument,
  key _table.billing_document_item      as BillingDocumentItem,
      _table.recovery_management_number as RecoveryManagementNumber,
      _table.document_currency          as DocumentCurrency,
      _table.base_unit                  as BaseUnit,
      cast('00000000' as abap.dats)     as CreationDate,
      _table.company_currency           as CompanyCurrency,
      _table.order_quantity             as OrderQuantity,
      _table.net_price_amount           as NetPriceAmount,
      _table.company_code               as CompanyCode,
      _table.spotbuy_material           as SpotbuyMaterial,
      _table.spotbuy_material_text      as SpotbuyMaterialText,
      _table.product_old_id             as ProductOldId,
      _table.product_old_text           as ProductOldText,
      _table.fiscal_year_period         as FiscalYearPeriod,
      _table.fiscal_year                as FiscalYear,
      _table.fiscal_month               as FiscalMonth,
      _table.old_material_price         as OldMaterialPrice,
      _table.net_price_diff             as NetPriceDiff,
      _table.recovery_necessary_amount  as RecoveryNecessaryAmount,
      _table.company_code_name          as CompanyCodeName,
      _table.sales_order_document       as SalesOrderDocument,
      _table.sales_order_document_item  as SalesOrderDocumentItem,
      _table.customer                   as Customer,
      _table.customer_name              as CustomerName,
      _table.transaction_currency       as TransactionCurrency,
      _table.billing_product            as BillingProduct,
      _table.billing_product_text       as BillingProductText,
      _table.billing_document_date      as BillingDocumentDate,
      _table.profit_center              as ProfitCenter,
      _table.profit_center_name         as ProfitCenterName,
      _table.billing_quantity_unit      as BillingQuantityUnit,
      _table.billing_quantity           as BillingQuantity,
      _table.billing_currency           as BillingCurrency,
      _table.billing_price              as BillingPrice,
      _table.condition_type             as ConditionType,
      _table.condition_rate_amount      as ConditionRateAmount,
      _table.recovery_amount            as RecoveryAmount
}
where
  _table.job_run_by = 'UPLOAD'
// ADD END BY XINLEI XU 2025/02/10
