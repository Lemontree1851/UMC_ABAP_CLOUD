@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approval Sts Value Help for Sales Doc'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.dataCategory: #VALUE_HELP
@Search.searchable: true
define root view entity ZC_SalesDocApprovalStatusVH
  as select from I_SalesDocApprovalStatusT
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['SalesDocApprovalStatusDesc']
  key SalesDocApprovalStatus,
      SalesDocApprovalStatusDesc
}
where
  Language = $session.system_language
