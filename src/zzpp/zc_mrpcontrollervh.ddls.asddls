@VDM.viewType: #COMPOSITE

@ObjectModel: {
  dataCategory : #VALUE_HELP,
  representativeKey: 'MRPController',
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

@EndUserText.label: 'MRP Controller Value Help'
define view entity ZC_MRPControllerVH
  as select distinct from I_MRPController
{
  key MRPController,
      MRPControllerName
}
