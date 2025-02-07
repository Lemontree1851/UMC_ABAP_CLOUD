@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '回収残データ一括アップロード'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_BI003_UPLOAD
  provider contract transactional_query
  as projection on ZR_BI003_UPLOAD
{
  key Uuid,
      UploadType,
      JsonData,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
