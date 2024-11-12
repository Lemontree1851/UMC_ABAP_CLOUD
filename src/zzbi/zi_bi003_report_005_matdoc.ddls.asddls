@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 005 Material Documents'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_REPORT_005_MATDOC
  with parameters
    p_recover_type :ze_recycle_type
  as select from I_MaterialDocumentItem_2   as item
    inner join   I_MaterialDocumentHeader_2 as header       on  item.MaterialDocumentYear = header.MaterialDocumentYear
                                                            and item.MaterialDocument     = header.MaterialDocument
    inner join   ZR_TBI_RECY_INFO001        as recover_info on  header.MaterialDocumentHeaderText = recover_info.RecoveryManagementNumber
                                                            and recover_info.RecoveryType         = $parameters.p_recover_type
                                                            and item.CompanyCode                  = recover_info.CompanyCode
  association [0..1] to I_ProductText   as _ProductText   on  _ProductText.Product  = $projection.Material
                                                          and _ProductText.Language = $session.system_language
  association [0..1] to I_GLAccountText as _GLAccountText on  _GLAccountText.GLAccount = $projection.GLAccount
                                                          and _GLAccountText.Language  = $session.system_language


{
  key item.MaterialDocument                                            as MaterialDocument,
  key item.MaterialDocumentYear                                        as MaterialDocumentYear,
  key item.MaterialDocumentItem                                        as MaterialDocumentItem,


      item.PostingDate,
      item.Plant,
      item.Material,
      item.Batch,
      item.GoodsMovementType,
      item.GoodsMovementIsCancelled,

      recover_info.RecoveryManagementNumber,


      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      item.QuantityInEntryUnit,
      item.EntryUnit,

      item.FiscalYearPeriod,

      case item.FiscalYearPeriod
      when '0000000' then cast('0000' as gjahr)
      else cast( substring(item.FiscalYearPeriod, 1, 4)  as gjahr) end as FiscalYear,

      case item.FiscalYearPeriod
      when '0000000' then cast('00' as monat)
      else cast( substring(item.FiscalYearPeriod, 6, 2)  as monat) end as FiscalMonth,

      item.CompanyCode,
      item.GLAccount,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      item.TotalGoodsMvtAmtInCCCrcy                                    as RecoveryNecessaryAmount,
      item.CompanyCodeCurrency                                         as CompanyCurrency,


      item._CompanyCode,
      _ProductText,
      _GLAccountText
}
where
  item.GoodsMovementIsCancelled = ''
