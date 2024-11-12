@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZZR_PRT_TEMPLATE'
define root view entity ZZC_PRT_TEMPLATE
  provider contract transactional_query
  as projection on ZZR_PRT_TEMPLATE
{
  key TemplateUUID,
      TemplateID,
      TemplateName,
      ServiceDefinitionName,
      XDPMimeType,
      XDPFileName,
      XDPContent,
      XSDMimeType,
      XSDFileName,
      XSDContent,
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
