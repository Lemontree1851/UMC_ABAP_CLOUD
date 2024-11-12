@AbapCatalog.sqlViewName: 'ZBDGLSUM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '連結勘定残高試算表'
@Metadata.ignorePropagatedAnnotations: true
@Analytics.dataCategory: #CUBE
define view ZC_BDGLACCOUNT_SUM as select from I_Plant
{
    Plant
}
