@EndUserText.label: 'OF Split Rule'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_OFSPLITRULE
  provider contract transactional_query
  as projection on ZR_OFSPLITRULE
{
//      @ObjectModel.text.element: ['CustomerName']
  key Customer,      // 顧客
//      @ObjectModel.text.element: ['ProductName']
  key SplitMaterial, // 品目コード
      @ObjectModel.text.element: ['PlantName']
  key Plant,         // プラント
      @ObjectModel.text.element: ['SplitUnitText']
  key SplitUnit,     // 分割単位
      ShipUnit,      // 出荷単位
      ValidEnd,      // 打切り年月
      DeleteFlag,    // 削除フラグ
      @ObjectModel.text.element: ['CreateUserName']
      CreatedBy,
      CreatedAt,
      @ObjectModel.text.element: ['UpdateUserName']
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      _ProductPlantBasic.MRPResponsible,

      @UI.hidden: true
      _Customer.CustomerName,
      @UI.hidden: true
      _ProductText.ProductName,
      @UI.hidden: true
      _Plant.PlantName,
      @UI.hidden: true
      _SplitUnit.text            as SplitUnitText,
      @UI.hidden: true
      _CreateUser.PersonFullName as CreateUserName,
      @UI.hidden: true
      _UpdateUser.PersonFullName as UpdateUserName
}
