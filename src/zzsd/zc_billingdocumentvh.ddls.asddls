@VDM.viewType: #COMPOSITE

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'BillingDocument'

@ObjectModel.usageType.dataClass: #TRANSACTIONAL
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #L
@ObjectModel.supportedCapabilities: [ #VALUE_HELP_PROVIDER,
                                      #SEARCHABLE_ENTITY ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Value help for Billing Document PRIVILEGED'
@Search.searchable: true
@Consumption.ranked: true
define view entity ZC_BillingDocumentVH
  as select from I_BillingDocumentBasic
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key BillingDocument,

      @Consumption.hidden: true
      BillingDocumentType,
      @Consumption.hidden: true
      SalesOrganization
}
