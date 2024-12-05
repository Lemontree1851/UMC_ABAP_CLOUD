@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Company Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CustomerCompanyVH
  as select from I_CustomerCompany
{
      @ObjectModel.text.element: ['CustomerName']
      @Search: {
           defaultSearchElement: true,
           ranking: #HIGH,
           fuzzinessThreshold: 0.8
          }
      @UI.textArrangement: #TEXT_LAST
  key Customer,
      @ObjectModel.text.element: ['CompanyCodeName']
      @UI.textArrangement: #TEXT_LAST
      @Search: {
           defaultSearchElement: true,
           ranking: #MEDIUM,
           fuzzinessThreshold: 0.8
          }
  key CompanyCode,
      _Customer,
      _Customer.Country,
      _Customer.BPCustomerName as CustomerName,
      _CompanyCode.CompanyCodeName
}
