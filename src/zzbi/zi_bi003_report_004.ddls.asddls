@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 004'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BI003_REPORT_004
  as select from ZI_BI003_REPORT_004_PO( p_recover_type:'ST'  )
{

  key PurchaseOrder,
  key PurchaseOrderItem,

      @EndUserText: { label:  'Billing Document', quickInfo: 'Billing Document' }
  key cast('' as vbeln_va)                as BillingDocument,

      @EndUserText: { label:  'Billing Document Item', quickInfo: 'Billing Document Item' }
  key cast('000000' as posnr_va)          as BillingDocumentItem,

      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      CompanyCode,

      _Matdoc.FiscalYearPeriod,
      _Matdoc.FiscalYear,
      _Matdoc.FiscalMonth,
      RecoveryManagementNumber,
      _CompanyCode.CompanyCodeName,

      @ObjectModel.text.element: [ 'MaterialText' ]
      @EndUserText: { label:  'Material', quickInfo: 'Material' }
      Material,

      @EndUserText: { label:  'Material Text', quickInfo: 'Material Text' }
      // _ProductText.ProductName            as MaterialText,
      PurchaseOrderItemText               as MaterialText, // ADD BY XINLEI XU 2025/03/19

      @ObjectModel.text.element: [ 'ProductGroupName' ]
      _Product.ProductGroup,
      _Product._ProductGroupText_2[1:Language = $session.system_language].ProductGroupName,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      OrderQuantity,
      BaseUnit,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Amount', quickInfo: 'Net Price Amount' }
      // MOD BEGN BY XINLEI XU 2025/03/26
      //      cast( currency_conversion( amount=>NetPriceAmount,
      //                                 exchange_rate_date=>_PurchaseOrder.CreationDate,
      //                                 source_currency=>DocumentCurrency,
      //                                 target_currency=>_CompanyCode.Currency
      //                               )
      //            as dmbtr )                    as NetPriceAmount,
      case when DocumentCurrency <> _CompanyCode.Currency
           then cast( currency_conversion( amount=>NetPriceAmount,
                                           exchange_rate_date=>_PurchaseOrder.CreationDate,
                                           source_currency=>DocumentCurrency,
                                           target_currency=>_CompanyCode.Currency ) as dmbtr )
           else NetPriceAmount
      end                                 as NetPriceAmount,
      // MOD END BY XINLEI XU 2025/03/26

      _CompanyCode.Currency               as CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      // MOD BEGN BY XINLEI XU 2025/03/26
      //      cast( ( cast( currency_conversion( amount=>NetPriceAmount,
      //                                         exchange_rate_date=>_PurchaseOrder.CreationDate,
      //                                         source_currency=>DocumentCurrency,
      //                                         target_currency=>_CompanyCode.Currency
      //                                     )
      //              as abap.dec(16, 2) ) * OrderQuantity
      //           )  as dmbtr )                  as RecoveryNecessaryAmount,
      case when DocumentCurrency <> _CompanyCode.Currency
           then cast( ( cast( currency_conversion( amount=>NetPriceAmount,
                                                   exchange_rate_date=>_PurchaseOrder.CreationDate,
                                                   source_currency=>DocumentCurrency,
                                                   target_currency=>_CompanyCode.Currency ) as abap.dec(16, 2) ) * OrderQuantity ) as dmbtr )
           else cast( cast( NetPriceAmount as abap.dec(16, 2) ) * OrderQuantity as dmbtr )
      end                                 as RecoveryNecessaryAmount,
      // MOD END BY XINLEI XU 2025/03/26

      @ObjectModel.text.element: [ 'GLAccountName' ]
      GLAccount,
      _GLAccountText.GLAccountName,

      @ObjectModel.text.element: [ 'FixedAssetDescription' ]
      FixedAsset,

      _FixedAsset.FixedAssetDescription,

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
      cast('0.00' as dmbtr)               as RecoveryAmount, //BillingTotalAmount
      cast( '' as belnr_d )               as AccountingDocument,
      cast( '' as abap.char(6))           as AccountingDocumentItem
}
union select from ZI_BI003_REPORT_004_BILLING
{
  key    cast( '' as ebeln )             as PurchaseOrder,
  key    cast('00000' as ebelp)          as PurchaseOrderItem,
  key    BillingDocument,
  key    BillingDocumentItem,

         CompanyCode,


         _FiscalCalendarDate.FiscalYearPeriod,
         _FiscalCalendarDate.FiscalYear,
         case _FiscalCalendarDate.FiscalPeriod when '000' then '00'
                  else cast( substring(_FiscalCalendarDate.FiscalPeriod, 2, 2) as monat )
                  end                    as FiscalMonth,

         RecoveryManagementNumber,

         _Companycode.CompanyCodeName,

         cast('' as matnr)               as Material,
         cast('' as maktx)               as MaterialText,


         cast('' as abap.char(9))        as ProductGroup,

         cast('' as abap.char(20))       as ProductGroupName,


         cast('0' as abap.quan( 13, 3 )) as OrderQuantity,
         cast('' as vrkme)               as BaseUnit,

         cast( '0.00' as dmbtr )         as NetPriceAmount,

         _Companycode.Currency           as CompanyCurrency,

         cast( '0.00' as dmbtr )         as RecoveryNecessaryAmount,

         cast( '' as hkont)              as GLAccount,
         cast('' as abap.char(20) )      as GLAccountName,

         cast('' as anln1 )              as FixedAsset,

         cast('' as abap.char(50) )      as FixedAssetDescription,

         salesorderdocument,
         salesorderdocumentitem,

         SoldToParty                     as Customer,

         _Customer.CustomerName,

         TransactionCurrency,

         billingproduct,

         _ProductText.ProductName        as BillingProductText,

         BillingDocumentDate,

         ProfitCenter,

         _ProfitCetnerText.ProfitCenterName,

         BillingQuantityUnit,

         BillingQuantity,
         _Companycode.Currency           as BillingCurrency,

         // MOD BEGN BY XINLEI XU 2025/03/26
         //         currency_conversion( amount=>BillingPrice,
         //                              exchange_rate_date=>BillingDocumentDate,
         //                              source_currency=>TransactionCurrency,
         //                              target_currency=>_Companycode.Currency
         //                            )            as BillingPrice,
         case when TransactionCurrency <> _Companycode.Currency
              then currency_conversion( amount=>BillingPrice,
                                        exchange_rate_date=>BillingDocumentDate,
                                        source_currency=>TransactionCurrency,
                                        target_currency=>_Companycode.Currency )
              else BillingPrice
         end                             as BillingPrice,
         // MOD END BY XINLEI XU 2025/03/26

         ConditionType,

         // MOD BEGN BY XINLEI XU 2025/03/26
         //         cast( currency_conversion( amount=>ConditionRateAmount,
         //                                    exchange_rate_date=>BillingDocumentDate,
         //                                    source_currency=>TransactionCurrency,
         //                                    target_currency=>_Companycode.Currency
         //                                  )  as dmbtr
         //              )                          as ConditionRateAmount,
         case when TransactionCurrency <> _Companycode.Currency
              then cast( currency_conversion( amount=>ConditionRateAmount,
                                              exchange_rate_date=>BillingDocumentDate,
                                              source_currency=>TransactionCurrency,
                                              target_currency=>_Companycode.Currency ) as dmbtr )
              else cast( ConditionRateAmount as dmbtr )
         end                             as ConditionRateAmount,

         //         currency_conversion( amount=>RecoveryAmount,
         //                                      exchange_rate_date=>BillingDocumentDate,
         //                                      source_currency=>TransactionCurrency,
         //                                      target_currency=>_Companycode.Currency
         //                             )           as RecoveryAmount, //BillingTotalAmount
         case when TransactionCurrency <> _Companycode.Currency
              then currency_conversion( amount=>RecoveryAmount,
                                        exchange_rate_date=>BillingDocumentDate,
                                        source_currency=>TransactionCurrency,
                                        target_currency=>_Companycode.Currency )
              else RecoveryAmount
         end                             as RecoveryAmount, //BillingTotalAmount
         // MOD END BY XINLEI XU 2025/03/26

         cast( '' as belnr_d )           as AccountingDocument,
         cast( '' as abap.char(6))       as AccountingDocumentItem
}
// ADD BEGIN BY XINLEI XU 2025/02/10
union select from ztbi_bi003_j04       as _table
  inner join      ZR_TBC1012           as _AssignCompany on _AssignCompany.CompanyCode = _table.company_code
  inner join      ZC_BusinessUserEmail as _User          on  _User.Email  = _AssignCompany.Mail
                                                         and _User.UserID = $session.user
{
  key _table.purchase_order             as PurchaseOrder,
  key _table.purchase_order_item        as PurchaseOrderItem,
  key _table.billing_document           as BillingDocument,
  key _table.billing_document_item      as BillingDocumentItem,
      _table.company_code               as CompanyCode,
      _table.fiscal_year_period         as FiscalYearPeriod,
      _table.fiscal_year                as FiscalYear,
      _table.fiscal_month               as FiscalMonth,
      _table.recovery_management_number as RecoveryManagementNumber,
      _table.company_code_name          as CompanyCodeName,
      _table.material                   as Material,
      _table.material_text              as MaterialText,
      _table.product_group              as ProductGroup,
      _table.product_group_name         as ProductGroupName,
      _table.order_quantity             as OrderQuantity,
      _table.base_unit                  as BaseUnit,
      _table.net_price_amount           as NetPriceAmount,
      _table.company_currency           as CompanyCurrency,
      _table.recovery_necessary_amount  as RecoveryNecessaryAmount,
      _table.gl_account                 as GlAccount,
      _table.gl_account_name            as GlAccountName,
      _table.fixed_asset                as FixedAsset,
      _table.fixed_asset_description    as FixedAssetDescription,
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
      _table.recovery_amount            as RecoveryAmount,
      cast( '' as belnr_d )             as AccountingDocument,
      cast( '' as abap.char(6))         as AccountingDocumentItem
}
where
  _table.job_run_by = 'UPLOAD'
// ADD END BY XINLEI XU 2025/02/10

// ADD BEGIN BY XINLEI XU 2025/02/20
union select from ZI_BI003_REPORT_003_ACCOUTING( p_recover_type: 'ST' )
{
  key cast('' as ebeln)                   as PurchaseOrder,
  key cast('00000' as ebelp)              as PurchaseOrderItem,
  key cast('' as vbeln_va)                as BillingDocument,
  key cast('000000' as posnr_va)          as BillingDocumentItem,
      CompanyCode,
      FiscalYearPeriod,
      FiscalYear,
      case FiscalPeriod when '000' then '00'
               else cast( substring(FiscalPeriod, 2, 2) as monat )
               end                        as FiscalMonth,

      RecoveryManagementNumber,
      _CompanyCode.CompanyCodeName,

      cast('' as matnr)                   as Material,
      cast('' as maktx)                   as MaterialText,
      cast('' as abap.char(9))            as ProductGroup,
      cast('' as abap.char(20))           as ProductGroupName,
      cast('0' as abap.quan( 13, 3 ))     as OrderQuantity,
      cast('' as vrkme)                   as BaseUnit,
      cast( '0.00' as dmbtr )             as NetPriceAmount,
      CompanyCodeCurrency                 as CompanyCurrency,
      AmountInCompanyCodeCurrency         as RecoveryNecessaryAmount,
      GLAccount,
      GLAccountName,
      FixedAsset,
      FixedAssetDescription,
      cast('' as vbeln_va)                as SalesOrderDocument,
      cast('000000' as posnr_va)          as SalesOrderDocumentItem,
      cast('' as kunnr)                   as Customer,
      cast('' as abap.char(80))           as CustomerName,
      cast('' as waers)                   as TransactionCurrency,
      cast('' as matnr)                   as BillingProduct,
      cast('' as maktx)                   as BillingProductText,
      cast('00000000' as fkdat)           as BillingDocumentDate,
      cast('' as prctr)                   as ProfitCenter,
      cast('' as abap.char(40))           as ProfitCenterName,
      cast('' as vrkme)                   as BillingQuantityUnit,
      cast('0.000' as abap.quan( 13, 3 )) as BillingQuantity,
      cast('' as waers)                   as BillingCurrency,
      cast('0.00' as abap.curr(16, 2))    as BillingPrice,
      cast('' as kscha)                   as ConditionType,
      cast('0.00' as dmbtr)               as ConditionRateAmount,
      cast('0.00' as dmbtr)               as RecoveryAmount,
      AccountingDocument,
      LedgerGLLineItem                    as AccountingDocumentItem
}
// ADD END BY XINLEI XU 2025/02/20
