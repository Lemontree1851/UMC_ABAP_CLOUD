@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '##GENERATED ZZT_DTIMP_CONF'
define root view entity ZZR_DTIMP_CONF
  as select from zzt_dtimp_conf as _Configuration
  association [0..1] to I_BusinessUserVH as _CreateUser on $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser on $projection.LastChangedBy = _UpdateUser.UserID
{
  key uuid_conf             as UuidConf,
      object                as Object,
      object_name           as ObjectName,
      function_name         as FunctionName,
      structure_name        as StructureName,
      @Semantics.mimeType: true
      template_mime_type    as TemplateMimeType,
      template_name         as TemplateName,
      @Semantics.largeObject: { mimeType: 'TemplateMimeType',
                                fileName: 'TemplateName',
                                contentDispositionPreference: #ATTACHMENT }
      template_content      as TemplateContent,
      sheet_name            as SheetName,
      start_row             as StartRow,
      start_column          as StartColumn,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _CreateUser,
      _UpdateUser
}
