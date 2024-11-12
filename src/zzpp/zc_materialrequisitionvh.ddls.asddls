@VDM.viewType: #COMPOSITE

@ObjectModel: {
  dataCategory : #VALUE_HELP,
  representativeKey: 'MaterialRequisitionNo',
  supportedCapabilities: [ #SQL_DATA_SOURCE,
                           #CDS_MODELING_DATA_SOURCE,
                           #CDS_MODELING_ASSOCIATION_TARGET,
                           #VALUE_HELP_PROVIDER,
                           #SEARCHABLE_ENTITY
  ],
  usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MASTER
  }
}

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Consumption.ranked: true
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Material Requisition Value Help'
define view entity ZC_MaterialRequisitionVH
  as select from ztpp_1009
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @EndUserText.label: 'Requisition No.'
  key material_requisition_no as MaterialRequisitionNo,
      plant                   as Plant,
      @EndUserText.label: 'Type'
      type                    as Type,
      @EndUserText.label: 'Created Date'
      created_date            as CreatedDate,
      cost_center             as CostCenter,
      customer                as Customer,
      @EndUserText.label: 'Created By'
      created_by_user_name    as CreatedByUserName
}
