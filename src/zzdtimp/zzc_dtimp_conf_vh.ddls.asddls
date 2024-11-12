@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZZR_DTIMP_CONF'
define root view entity ZZC_DTIMP_CONF_VH
  provider contract transactional_query
  as projection on ZZR_DTIMP_CONF
{
  key UuidConf,
      Object,
      ObjectName,
      FunctionName,
      StructureName,
      TemplateMimeType,
      TemplateName,
      TemplateContent,
      SheetName,
      StartRow,
      StartColumn,
      @ObjectModel.text.element: ['CreateUserName']
      CreatedBy,
      CreatedAt,
      @ObjectModel.text.element: ['UpdateUserName']
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      @UI.hidden: true
      _CreateUser.PersonFullName as CreateUserName,
      @UI.hidden: true
      _UpdateUser.PersonFullName as UpdateUserName
}
where
  Object like 'ZDATAIMPORT%'
