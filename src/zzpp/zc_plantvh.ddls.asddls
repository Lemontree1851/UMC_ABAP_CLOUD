@VDM.viewType: #COMPOSITE

@ObjectModel: {
  dataCategory : #VALUE_HELP,
  representativeKey: 'Plant',
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

@EndUserText.label: 'Plant Value Help - Down List'
define view entity ZC_PlantVH
  as select from I_Plant
{
      @ObjectModel.text.element: ['PlantName']
  key Plant,
      @UI.hidden: true
      PlantName
}
