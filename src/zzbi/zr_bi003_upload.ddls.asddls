@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '回収残データ一括アップロード'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_BI003_UPLOAD
  as select from ztbi_bi003_up
{
  key uuid                  as Uuid,
      upload_type           as UploadType,
      json_data             as JsonData,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
