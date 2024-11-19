@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LED Material Production Version Info'
@Metadata.allowExtensions: true
define root view entity ZC_LEDPRODUCTIONVERSION
  provider contract transactional_query
  as projection on ZR_LEDPRODUCTIONVERSION
{
  key Material,
      @ObjectModel.text.element: ['PlantName']
  key Plant,
  key VersionInfo,
  key Component,
      DeleteFlag,
      @ObjectModel.text.element: ['CreateUserName']
      CreatedBy,
      CreatedAt,
      @ObjectModel.text.element: ['UpdateUserName']
      LastChangedBy,
      LastChangedAt,
      @UI.hidden: true
      LocalLastChangedAt,

      _MaterialText.ProductName  as MaterialName,
      _ComponentText.ProductName as ComponentName,
      @UI.hidden: true
      _Plant.PlantName,
      @UI.hidden: true
      _CreateUser.PersonFullName as CreateUserName,
      @UI.hidden: true
      _UpdateUser.PersonFullName as UpdateUserName
}
