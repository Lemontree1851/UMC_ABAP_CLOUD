@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 003 Accounting Info'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_REPORT_003_ACCOUTING
  with parameters
    p_recover_type :ze_recycle_type
  as select from I_JournalEntryItem  as docitem
    inner join   ZR_TBI_RECY_INFO001 as recy on  docitem.AssignmentReference = recy.RecoveryManagementNumber
                                             and docitem.CompanyCode         = recy.CompanyCode
                                             and recy.RecoveryType           = $parameters.p_recover_type

  association [1] to I_CompanyCode as _CompanyCode on _CompanyCode.CompanyCode = $projection.CompanyCode

{
  key docitem.SourceLedger,
  key docitem.CompanyCode,
  key docitem.FiscalYear,
  key docitem.AccountingDocument,
  key docitem.LedgerGLLineItem,
  key docitem.Ledger,
      //docitem.DocumentItemText as RecoveryManagementNumber,
      recy.RecoveryManagementNumber,
      docitem.FiscalYearPeriod,
      docitem.FiscalPeriod,
      docitem.GLAccount,
      docitem.MasterFixedAsset                                  as FixedAsset,
      docitem.CompanyCodeCurrency,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      docitem.AmountInCompanyCodeCurrency,


      _CompanyCode,

      docitem._GLAccountTxt[1:Language = $session.system_language].GLAccountName,
      docitem._MasterFixedAssetText.MasterFixedAssetDescription as FixedAssetDescription

}
where
      docitem.SourceLedger    = '0L'
  and docitem.Ledger          = '0L'
  and docitem.DebitCreditCode = 'S'
