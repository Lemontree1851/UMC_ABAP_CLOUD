@VDM.viewType: #COMPOSITE

@ObjectModel: {
  dataCategory : #VALUE_HELP,
  representativeKey: 'Zvalue1',
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

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Apply Depart Value Help'
define view entity ZC_WF_ApplyDepart_VH
  as select from ZR_TBC1001
{
      @ObjectModel.text.element: ['Zvalue2']
      @EndUserText.label: 'Apply Depart'
  key Zvalue1,
      @EndUserText.label: 'Name'
      Zvalue2
}
where
  ZID = 'ZMM008'
