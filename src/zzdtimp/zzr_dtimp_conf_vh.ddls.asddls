@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '##GENERATED ZZT_DTIMP_CONF'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZZR_DTIMP_CONF_VH
  as select from zzt_dtimp_conf       as _Configuration
    inner join   ZR_USER_ACCESSBUTTON as _UserAccess on _UserAccess.AccessId = _Configuration.object
    inner join   ZC_BusinessUserEmail as _User       on  _User.Email  = _UserAccess.Mail
                                                     and _User.UserID = $session.user

  association [0..1] to I_BusinessUserVH as _CreateUser on $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser on $projection.LastChangedBy = _UpdateUser.UserID
{
  key _Configuration.uuid_conf             as UuidConf,
      _Configuration.object                as Object,
      _Configuration.object_name           as ObjectName,
      _Configuration.function_name         as FunctionName,
      _Configuration.structure_name        as StructureName,
      @Semantics.mimeType: true
      _Configuration.template_mime_type    as TemplateMimeType,
      _Configuration.template_name         as TemplateName,
      @Semantics.largeObject: { mimeType: 'TemplateMimeType',
                                fileName: 'TemplateName',
                                contentDispositionPreference: #ATTACHMENT }
      _Configuration.template_content      as TemplateContent,
      _Configuration.sheet_name            as SheetName,
      _Configuration.start_row             as StartRow,
      _Configuration.start_column          as StartColumn,
      @Semantics.user.createdBy: true
      _Configuration.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      _Configuration.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      _Configuration.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      _Configuration.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _Configuration.local_last_changed_at as LocalLastChangedAt,

      _CreateUser,
      _UpdateUser
}
