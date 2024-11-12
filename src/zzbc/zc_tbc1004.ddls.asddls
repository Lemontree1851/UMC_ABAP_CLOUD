@EndUserText.label: 'Permission Access User Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_TBC1004
  provider contract transactional_query
  as projection on ZR_TBC1004
{
  key UserUuid,
      UserId,
      Mail,
      Department,
      UserName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _AssignPlant : redirected to composition child ZC_TBC1006,
      _AssignRole  : redirected to composition child ZC_TBC1007
}
