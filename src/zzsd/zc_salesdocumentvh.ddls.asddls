@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'SalesDocument'

@ObjectModel.usageType.dataClass: #TRANSACTIONAL
@ObjectModel.usageType.serviceQuality: #B
@ObjectModel.usageType.sizeCategory: #L

@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Search.searchable: true

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Value help for Sales Document PRIVILEGED'
define view entity ZC_SalesDocumentVH
  as select from I_SalesDocument
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key SalesDocument,

      @Consumption.hidden: true
      DistributionChannel,
      @Consumption.hidden: true
      OrganizationDivision,
      @Consumption.hidden: true
      SalesDocumentType,
      @Consumption.hidden: true
      SalesOrganization
}
