@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '##GENERATED ZZT_DTIMP_FILES'
define root view entity ZZR_DTIMP_FILES
  as select from zzt_dtimp_files
  association [0..1] to ZZR_DTIMP_CONF   as _Configuration  on $projection.UuidConf = _Configuration.UuidConf
  association [0..1] to I_BusinessUserVH as _CreateUser     on $projection.CreatedBy = _CreateUser.UserID

  association [0..*] to ZZC_DTIMP_LOGS   as _ApplicationLog on $projection.LogHandle = _ApplicationLog.LogHandle
{
  key uuid_file                             as UuidFile,

      uuid_conf                             as UuidConf,
      @Semantics.mimeType: true
      file_mime_type                        as FileMimeType,
      file_name                             as FileName,
      @Semantics.largeObject: { mimeType: 'FileMimeType',
                                fileName: 'FileName',
                                contentDispositionPreference: #ATTACHMENT }
      file_content                          as FileContent,
      job_count                             as JobCount,
      job_name                              as JobName,
      cast( log_handle as abap.char( 22 ) ) as LogHandle,
      @Semantics.user.createdBy: true
      created_by                            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                 as LocalLastChangedAt,

      _Configuration,
      _ApplicationLog,
      _CreateUser
}
