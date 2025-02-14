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
      _ProductText.ProductName            as MaterialText,

      @ObjectModel.text.element: [ 'ProductGroupName' ]
      _Product.ProductGroup,
      _Product._ProductGroupText_2[1:Language = $session.system_language].ProductGroupName,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      OrderQuantity,
      BaseUnit,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Amount', quickInfo: 'Net Price Amount' }
      cast( currency_conversion( amount=>NetPriceAmount,
                                 exchange_rate_date=>_PurchaseOrder.CreationDate,
                                 source_currency=>DocumentCurrency,
                                 target_currency=>_CompanyCode.Currency
                               )
            as dmbtr )                    as NetPriceAmount,

      _CompanyCode.Currency               as CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      cast( ( cast( currency_conversion( amount=>NetPriceAmount,
                                         exchange_rate_date=>_PurchaseOrder.CreationDate,
                                         source_currency=>DocumentCurrency,
                                         target_currency=>_CompanyCode.Currency
                                     )
              as abap.dec(16, 2) ) * OrderQuantity
           )  as dmbtr )                  as RecoveryNecessaryAmount,

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
      cast('0.00' as dmbtr)               as RecoveryAmount //BillingTotalAmount
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

         currency_conversion( amount=>BillingPrice,
                              exchange_rate_date=>BillingDocumentDate,
                              source_currency=>TransactionCurrency,
                              target_currency=>_Companycode.Currency
                            )            as BillingPrice,

         ConditionType,

         cast( currency_conversion( amount=>ConditionRateAmount,
                                    exchange_rate_date=>BillingDocumentDate,
                                    source_currency=>TransactionCurrency,
                                    target_currency=>_Companycode.Currency
                                  )  as dmbtr
              )                          as ConditionRateAmount,

         currency_conversion( amount=>RecoveryAmount,
                                      exchange_rate_date=>BillingDocumentDate,
                                      source_currency=>TransactionCurrency,
                                      target_currency=>_Companycode.Currency
                             )           as RecoveryAmount //BillingTotalAmount
}
// ADD BEGIN BY XINLEI XU 2025/02/10
union select from ztbi_bi003_j04 as _table
{
  key purchase_order             as PurchaseOrder,
  key purchase_order_item        as PurchaseOrderItem,
  key billing_document           as BillingDocument,
  key billing_document_item      as BillingDocumentItem,
      company_code               as CompanyCode,
      fiscal_year_period         as FiscalYearPeriod,
      fiscal_year                as FiscalYear,
      fiscal_month               as FiscalMonth,
      recovery_management_number as RecoveryManagementNumber,
      company_code_name          as CompanyCodeName,
      material                   as Material,
      material_text              as MaterialText,
      product_group              as ProductGroup,
      product_group_name         as ProductGroupName,
      order_quantity             as OrderQuantity,
      base_unit                  as BaseUnit,
      net_price_amount           as NetPriceAmount,
      company_currency           as CompanyCurrency,
      recovery_necessary_amount  as RecoveryNecessaryAmount,
      gl_account                 as GlAccount,
      gl_account_name            as GlAccountName,
      fixed_asset                as FixedAsset,
      fixed_asset_description    as FixedAssetDescription,
      sales_order_document       as SalesOrderDocument,
      sales_order_document_item  as SalesOrderDocumentItem,
      customer                   as Customer,
      customer_name              as CustomerName,
      transaction_currency       as TransactionCurrency,
      billing_product            as BillingProduct,
      billing_product_text       as BillingProductText,
      billing_document_date      as BillingDocumentDate,
      profit_center              as ProfitCenter,
      profit_center_name         as ProfitCenterName,
      billing_quantity_unit      as BillingQuantityUnit,
      billing_quantity           as BillingQuantity,
      billing_currency           as BillingCurrency,
      billing_price              as BillingPrice,
      condition_type             as ConditionType,
      condition_rate_amount      as ConditionRateAmount,
      recovery_amount            as RecoveryAmount
}
where
  job_run_by = 'UPLOAD'
// ADD END BY XINLEI XU 2025/02/10
