@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Organization Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define root view entity ZC_SalesOrganization_VH
  as select from I_SalesOrganizationText
{
      @ObjectModel.text.element: ['SalesOrganizationName']
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @UI.lineItem: [{ position: 10, cssDefault.width: '10rem' }]
  key SalesOrganization,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @UI.lineItem: [{ position: 20, cssDefault.width: '20rem' }]
      @Semantics.text:true
      SalesOrganizationName
}
where
  Language = $session.system_language
