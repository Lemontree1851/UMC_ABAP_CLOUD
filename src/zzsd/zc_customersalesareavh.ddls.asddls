@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Sales Area VH'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CustomerSalesAreaVH
  as select from I_Customer
    inner join   I_CustomerCompany   as customerc on I_Customer.Customer = customerc.Customer
    inner join   I_CustomerSalesArea as customers on customers.Customer = I_Customer.Customer
{
          @ObjectModel.text.element: ['BPCustomerName']
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          @Search.ranking: #HIGH
  key     I_Customer.Customer,
          @ObjectModel.text.element: ['CompanyCodeName']
          @UI.textArrangement: #TEXT_LAST
          @Search: {
               defaultSearchElement: true,
               ranking: #MEDIUM,
               fuzzinessThreshold: 0.8
              }
  key     customerc.CompanyCode,
          @ObjectModel.text.element: ['SalesOrganizationName']
          @UI.textArrangement: #TEXT_LAST
          @Search: {
               defaultSearchElement: true,
               ranking: #MEDIUM,
               fuzzinessThreshold: 0.8
              }
  key     customers.SalesOrganization,
          @ObjectModel.text.element: ['DistributionChannelName']
          @UI.textArrangement: #TEXT_LAST
          @Search: {
               defaultSearchElement: true,
               ranking: #MEDIUM,
               fuzzinessThreshold: 0.8
              }
  key     customers.DistributionChannel,
          @ObjectModel.text.element: ['DivisionName']
          @UI.textArrangement: #TEXT_LAST
          @Search: {
               defaultSearchElement: true,
               ranking: #MEDIUM,
               fuzzinessThreshold: 0.8
              }
  key     customers.Division,
          I_Customer.CustomerName as BPCustomerName,
          customerc._CompanyCode.CompanyCodeName,
          customers._SalesOrganization._Text[1:Language = 'J'].SalesOrganizationName,
          customers._DistributionChannel._Text[1:Language = 'J'].DistributionChannelName,
          customers._Division._Text[1:Language = 'J'].DivisionName
}
