@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '##GENERATED ZZT_PRT_TEMPLATE'
define root view entity ZZR_PRT_TEMPLATE
  as select from zzt_prt_template as _Template
  association [0..1] to I_BusinessUserVH as _CreateUser on $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser on $projection.LastChangedBy = _UpdateUser.UserID
{
  key template_uuid           as TemplateUUID,
      template_id             as TemplateID,
      template_name           as TemplateName,
      service_definition_name as ServiceDefinitionName,
      @Semantics.mimeType: true
      xdp_mime_type           as XDPMimeType,
      xdp_file_name           as XDPFileName,
      @Semantics.largeObject: { mimeType: 'XDPMimeType',
                                fileName: 'XDPFileName',
                                contentDispositionPreference: #ATTACHMENT }
      xdp_content             as XDPContent,
      @Semantics.mimeType: true
      xsd_mime_type           as XSDMimeType,
      xsd_file_name           as XSDFileName,
      @Semantics.largeObject: { mimeType: 'XSDMimeType',
                                fileName: 'XSDFileName',
                                contentDispositionPreference: #ATTACHMENT }
      xsd_content             as XSDContent,
      @Semantics.user.createdBy: true
      created_by              as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at              as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by         as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at         as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at   as LocalLastChangedAt,

      _CreateUser,
      _UpdateUser
}
