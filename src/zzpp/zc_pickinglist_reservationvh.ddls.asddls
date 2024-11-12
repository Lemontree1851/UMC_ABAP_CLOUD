@VDM.viewType: #COMPOSITE

@ObjectModel: {
  dataCategory : #VALUE_HELP,
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

@EndUserText.label: 'Picking List Reservation Data'
define view entity ZC_PICKINGLIST_RESERVATIONVH
  as select distinct from ztpp_1015
{
  key plant                 as Plant,
  key reservation           as Reservation,
      @EndUserText.label: 'Storage Location From'
      storage_location_from as StorageLocationFrom,
      @EndUserText.label: 'Storage Location To'
      storage_location_to   as StorageLocationTo,
      @EndUserText.label: 'Created Date'
      created_date          as CreatedDate,
      @EndUserText.label: 'Created By'
      created_by_user_name  as CreatedByUserName
}
