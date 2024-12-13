@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Organization Value Help'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_SalesOrganization_VH
  as select from I_SalesOrganizationText
{
      @UI.lineItem: [{ position: 10, cssDefault.width: '10rem' }]
  key SalesOrganization,
      @UI.lineItem: [{ position: 20, cssDefault.width: '20rem' }]
      SalesOrganizationName
}
where
  Language = $session.system_language
