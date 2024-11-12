@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Document Type Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.dataCategory: #VALUE_HELP
@Search.searchable: true
define root view entity ZC_SalesDocumentTypeVH
  as select from I_SalesDocumentTypeText
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['SalesDocumentTypeName']
  key SalesDocumentType,
      SalesDocumentTypeName
}
where
  Language = $session.system_language
