@VDM.viewType: #COMPOSITE

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'WorkCenterInternalID'
@ObjectModel.supportedCapabilities: [#VALUE_HELP_PROVIDER, #SEARCHABLE_ENTITY]
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.usageType.dataClass: #MASTER

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Search.searchable: true
@Consumption.ranked: true

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Value help for Work Center PRIVILEGED'
define view entity ZC_WorkCenterVH
  as select from I_WorkCenter
{

      @UI.hidden: true
  key WorkCenterInternalID,
      @UI.hidden: true
  key WorkCenterTypeCode,
      WorkCenter,
      _Text[ Language = $session.system_language ].WorkCenterText,
      Plant
}
