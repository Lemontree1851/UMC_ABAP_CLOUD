@EndUserText.label: 'Permission Access User <-> Role Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI: {
  headerInfo: {
    typeName: 'Authority User',
    typeNamePlural: 'Authority User'
  }
}
define view entity ZC_TBC1007_1
  as projection on ZR_TBC1007_1
{

  key Uuid,
      @UI.lineItem: [{ position: 30 }]
      @EndUserText.label: 'Mail'
  key Mail,
      RoleId,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      @UI.lineItem: [{ position: 10 }]
      @EndUserText.label: 'User Id'
      UserId,

      @UI.lineItem: [{ position: 20 }]
      @EndUserText.label: 'User Name'
      UserName,

      @UI.lineItem: [{ position: 40 }]
      @EndUserText.label: 'Department'
      Department,

      /* Associations */
      _Role : redirected to parent ZC_TBC1005
}
