@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access Function <-> AccessBtn Table'
define root view entity ZC_TBC1015_VH
  as select from ztbc_1015
    inner join   ztbc_1014 on ztbc_1014.function_id = ztbc_1015.function_id
{
      @UI.hidden: true
  key ztbc_1015.uuid                  as Uuid,
      @UI.lineItem: [{ position: 10, cssDefault.width: '20rem' }]
      @EndUserText.label: 'Application Id'
  key ztbc_1015.function_id           as FunctionId,
      @UI.lineItem: [{ position: 20, cssDefault.width: '20rem' }]
      @EndUserText.label: 'Access Id'
      ztbc_1015.access_id             as AccessId,
      @UI.lineItem: [{ position: 30, cssDefault.width: '20rem' }]
      @EndUserText.label: 'Access Name'
      ztbc_1015.access_name           as AccessName,
      ztbc_1015.created_by            as CreatedBy,
      ztbc_1015.created_at            as CreatedAt,
      ztbc_1015.last_changed_by       as LastChangedBy,
      ztbc_1015.last_changed_at       as LastChangedAt,
      @UI.hidden: true
      ztbc_1015.local_last_changed_at as LocalLastChangedAt,
      @UI.lineItem: [{ position: 40, cssDefault.width: '10rem' }]
      @EndUserText.label: 'Design File Id'
      ztbc_1014.design_file_id        as DesignFileId,
      @UI.lineItem: [{ position: 50, cssDefault.width: '15rem' }]
      @EndUserText.label: 'Application Name'
      ztbc_1014.function_name         as FunctionName
}
