@AbapCatalog.sqlViewName: 'ZICUSOMERVH'
@AbapCatalog.compiler.compareFilter: true

@VDM.viewType: #BASIC

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'Customer'

@ObjectModel.supportedCapabilities: [#SQL_DATA_SOURCE,
                                     #CDS_MODELING_DATA_SOURCE,
                                     #CDS_MODELING_ASSOCIATION_TARGET,
                                     #VALUE_HELP_PROVIDER,
                                     #SEARCHABLE_ENTITY]
@ObjectModel.modelingPattern:#NONE
@ObjectModel.usageType.serviceQuality: #B
@ObjectModel.usageType.sizeCategory: #XL
@ObjectModel.usageType.dataClass: #MASTER

@AccessControl.authorizationCheck: #CHECK
//<TODO> Please double-check personal data blocking
//@AccessControl.personalData.blocking: #REQUIRED
@ClientHandling.algorithm: #SESSION_VARIABLE

@Search.searchable: true

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Customer'
@Consumption.ranked: true
define view ZC_Customer_VH
  as select from I_Customer 
  inner join I_CustomerCompany         as customerc on I_Customer.Customer = customerc.Customer
  inner join I_CreditManagementAccount as creditm   on creditm.BusinessPartner = customerc.Customer
  inner join I_CustomerSalesArea       as customers on customers.Customer = customerc.Customer
  inner join I_SalesOrganization       as Sales     on Sales.SalesOrganization = customerc.CompanyCode
                                                   and Sales.SalesOrganization = creditm.CreditSegment
                                                   and Sales.SalesOrganization = customers.SalesOrganization
{
          @ObjectModel.text.element: ['BPCustomerName']
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          @Search.ranking: #HIGH
  key     I_Customer.Customer,
  
          @EndUserText.label: 'Customer Name 1'
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          //@Search.ranking: #HIGH
          @Search.ranking: #LOW
          I_Customer.OrganizationBPName1,

          //          @UI.hidden: true
          //          @Consumption.filter.hidden: true
          @EndUserText.label: 'Business Partner Name 1'
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          @Search.ranking: #LOW
          I_Customer.BusinessPartnerName1,

          @EndUserText.label: 'Customer Name 2'
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          //@Search.ranking: #HIGH
          @Search.ranking: #LOW
          I_Customer.OrganizationBPName2,

          //          @UI.hidden: true
          //          @Consumption.filter.hidden: true
          @EndUserText.label: 'Business Partner Name 2'
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          @Search.ranking: #LOW
          I_Customer.BusinessPartnerName2,

          @EndUserText.label: 'Country/Region'
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          //@Search.ranking: #HIGH
          @Search.ranking: #LOW
          I_Customer.Country,

          @EndUserText.label: 'City'
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          //@Search.ranking: #HIGH
          @Search.ranking: #LOW
          I_Customer.CityName,

          @UI.hidden: true
          @Consumption.filter.hidden: true
          @EndUserText.label: 'Business Partner Address City'
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          @Search.ranking: #LOW
          I_Customer.BPAddrCityName,

          @EndUserText.label: 'Street'
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          //@Search.ranking: #HIGH
          @Search.ranking: #LOW
          I_Customer.StreetName,

          @UI.hidden: true
          @Consumption.filter.hidden: true
          @EndUserText.label: 'Business Partner Address Street'
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          @Search.ranking: #LOW
          I_Customer.BPAddrStreetName,

          @EndUserText.label: 'Postal Code'
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          //@Search.ranking: #HIGH
          @Search.ranking: #LOW
          I_Customer.PostalCode,

          @EndUserText.label: 'Customer Name'
          // @Search.defaultSearchElement: true
          //  @Search.fuzzinessThreshold: 0.8
          //  @Search.ranking: #HIGH
          I_Customer.CustomerName,

          //          @UI.hidden: true
          //          @Consumption.filter.hidden: true
          @EndUserText.label: 'Business Partner Customer Name'
          I_Customer.BPCustomerName,


          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.CustomerAccountGroup,

          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.AuthorizationGroup,

          @UI.hidden: true
          @Consumption.filter.hidden: true
          @EndUserText.label: 'Purpose Complete Flag'
          I_Customer.IsBusinessPurposeCompleted,

          @UI.hidden: true
          I_Customer.IsCompetitor,
          @EndUserText.label: 'Business Partner'
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          //@Search.ranking: #HIGH
          @Search.ranking: #LOW
          I_Customer._CustomerToBusinessPartner._BusinessPartner.BusinessPartner,

          @EndUserText.label: 'Business Partner Type'
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer._CustomerToBusinessPartner._BusinessPartner.BusinessPartnerType,

          // Fields added For Data Controller in DCL .... NOT TO BE CONSUMED.
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.DataControllerSet,
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.DataController1,
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.DataController2,
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.DataController3,
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.DataController4,
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.DataController5,
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.DataController6,
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.DataController7,
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.DataController8,
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.DataController9,
          @UI.hidden: true
          @Consumption.filter.hidden: true
          I_Customer.DataController10

}
