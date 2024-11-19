@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZZR_DTIMP_FILES'
define root view entity ZZC_DTIMP_FILES
  provider contract transactional_query
  as projection on ZZR_DTIMP_FILES
{
  key      UuidFile,
           UuidConf,
           _Configuration.Object,
           _Configuration.ObjectName,
           _Configuration.TemplateMimeType,
           _Configuration.TemplateName,
           @Semantics.largeObject: { mimeType: 'TemplateMimeType',
                                     fileName: 'TemplateName',
                                     contentDispositionPreference: #ATTACHMENT }
           _Configuration.TemplateContent,
           FileMimeType,
           FileName,
           FileContent,
           JobCount,
           JobName,
           LogHandle,
           @ObjectModel.text.element: ['CreateUserName']
           CreatedBy,
           CreatedAt,
           LastChangedBy,
           LastChangedAt,
           LocalLastChangedAt,

           @UI.hidden: true
           _CreateUser.PersonFullName as CreateUserName,

           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_DTIMP_GET_STATUS'
  virtual  JobStatus            : abap.char( 1 ),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_DTIMP_GET_STATUS'
  virtual  JobStatusText        : abap.char( 20 ),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_DTIMP_GET_STATUS'
  virtual  JobStatusCriticality : abap.int1,

           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_DTIMP_GET_STATUS'
  virtual  LogStatus            : abap.char( 1 ),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_DTIMP_GET_STATUS'
  virtual  LogStatusText        : abap.char( 20 ),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_DTIMP_GET_STATUS'
  virtual  LogStatusCriticality : abap.int1,
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_DTIMP_GET_STATUS'
  virtual  ApplicationLogUrl    : abap.string( 1000 ),

           _Configuration : redirected to ZZC_DTIMP_CONF,
           _ApplicationLog
}
