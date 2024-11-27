@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI006 Partner Search Term2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI006_PARTNER_SEARCHTERM2 as select from I_BusinessPartner
{
    key max(BusinessPartner) as BusinessPartner,
    SearchTerm2
} group by SearchTerm2
 