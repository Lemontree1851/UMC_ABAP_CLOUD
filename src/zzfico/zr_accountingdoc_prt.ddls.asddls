@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print Accounting Document Header'
define root view entity ZR_ACCOUNTINGDOC_PRT
  as select from ZR_ACCOUNTINGDOC_R
  association [0..1] to ZR_ACCOUNTINGDOC_PRT_H as _Header on  $projection.CompanyCode        = _Header.Companycode
                                                          and $projection.AccountingDocument = _Header.accountingdocument
                                                          and $projection.FiscalYear         = _Header.fiscalyear
  association [0..*] to ZR_ACCOUNTINGDOC_PRT_I as _ITEM   on  $projection.CompanyCode        = _ITEM.Companycode
                                                          and $projection.AccountingDocument = _ITEM.accountingdocument
                                                          and $projection.FiscalYear         = _ITEM.fiscalyear
{
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,
      @ObjectModel.filter.enabled: false
      @ObjectModel.sort.enabled: false
      _Header,
      @ObjectModel.filter.enabled: false
      _ITEM
}
