@EndUserText.label: 'Permission Access User Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_TBC1004
  provider contract transactional_query
  as projection on ZR_TBC1004
{
  key Mail,
      UserId,
      UserName,
      Department,
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
      _UpdateUser.PersonFullName as UpdateUserName,

      /* Associations */
      _AssignPlant    : redirected to composition child ZC_TBC1006,
      _AssignCompany  : redirected to composition child ZC_TBC1012,
      _AssignSalesOrg : redirected to composition child ZC_TBC1013,
      _AssignPurchOrg : redirected to composition child ZC_TBC1017,
      _AssignRole     : redirected to composition child ZC_TBC1007
}
