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
  },
  resultSet.sizeCategory: #XS
}

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Approve Status Value Help - Down List'
define view entity ZC_ApproveStatus_VH
  as select from ZR_TBC1001
{
      @ObjectModel.text.element: ['Zvalue2']
  key Zvalue1,
      @UI.hidden: true
      Zvalue2
}
where
  ZID = 'ZMM018'
