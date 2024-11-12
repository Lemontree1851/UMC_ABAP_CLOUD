@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZZR_PRT_RECORD'
define root view entity ZZC_PRT_RECORD
  provider contract transactional_query
  as projection on ZZR_PRT_RECORD
{
  key RecordUUID,
      TemplateUUID,
      _Template.TemplateID,
      _Template.TemplateName,
      IsExternalProvidedData,
      DataMimeType,
      DataFileName,
      ExternalProvidedData,
      ProvidedKeys,
      PDFMimeType,
      PDFFileName,
      PDFContent,
      @ObjectModel.text.element: ['CreateUserName']
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt,

      @UI.hidden: true
      _CreateUser.PersonFullName as CreateUserName,

      _Template : redirected to ZZC_PRT_TEMPLATE
}
