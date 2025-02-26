@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM-011 Attachments'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_TMM_1012
  as select from ztmm_1012
{
  key pr_uuid               as PrUuid,
  key file_uuid             as FileUuid,
      file_seq              as FileSeq,
      file_type             as FileType,
      file_name             as FileName,
      file_size             as FileSize,
      s3_filename           as S3Filename,
      pr_uuid_c36           as PrUuidC36,
      file_uuid_c36         as FileUuidC36,
      created_by            as CreatedBy,
      created_by_name       as CreatedByName,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_by_name  as LastChangedByName,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
