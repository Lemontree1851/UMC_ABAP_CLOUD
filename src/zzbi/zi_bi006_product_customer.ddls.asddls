@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI006 Product Customer'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI006_PRODUCT_CUSTOMER as select from ZI_BI006_PARTNER_SEARCHTERM2 as SearchTerm2
left outer join I_BusinessPartner as BusinessPartner on SearchTerm2.BusinessPartner = BusinessPartner.BusinessPartner
{
    key BusinessPartner.BusinessPartner,
    BusinessPartner.BusinessPartnerName,
    BusinessPartner.SearchTerm2
}
 