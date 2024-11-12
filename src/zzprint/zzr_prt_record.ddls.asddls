@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '##GENERATED ZZT_PRT_RECORD'
define root view entity ZZR_PRT_RECORD
  as select from zzt_prt_record as Record
  association [0..1] to ZZR_PRT_TEMPLATE as _Template   on $projection.TemplateUUID = _Template.TemplateUUID
  association [0..1] to I_BusinessUserVH as _CreateUser on $projection.CreatedBy = _CreateUser.UserID
{
  key record_uuid               as RecordUUID,
      template_uuid             as TemplateUUID,
      is_external_provided_data as IsExternalProvidedData,
      @Semantics.mimeType: true
      data_mime_type            as DataMimeType,
      data_file_name            as DataFileName,
      @Semantics.largeObject: { mimeType: 'DataMimeType',
                                fileName: 'DataFileName',
                                contentDispositionPreference: #ATTACHMENT }
      external_provided_data    as ExternalProvidedData,
      provided_keys             as ProvidedKeys,
      @Semantics.mimeType: true
      pdf_mime_type             as PDFMimeType,
      pdf_file_name             as PDFFileName,
      @Semantics.largeObject: { mimeType: 'PDFMimeType',
                                fileName: 'PDFFileName',
                                contentDispositionPreference: #ATTACHMENT }
      pdf_content               as PDFContent,
      @Semantics.user.createdBy: true
      created_by                as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by           as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at           as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at     as LocalLastChangedAt,

      _Template,
      _CreateUser
}
