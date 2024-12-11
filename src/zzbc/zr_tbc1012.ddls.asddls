@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access User <-> Company Table'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_TBC1012
  as select from ztbc_1012     as _AssignCompany
    inner join   I_CompanyCode as _CompanyCode on _CompanyCode.CompanyCode = _AssignCompany.company_code

  association to parent ZR_TBC1004 as _User on $projection.UserId = _User.UserId
{
  key _AssignCompany.uuid                  as Uuid,
  key _AssignCompany.user_id               as UserId,
      _AssignCompany.company_code          as CompanyCode,
      @Semantics.user.createdBy: true
      _AssignCompany.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      _AssignCompany.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      _AssignCompany.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      _AssignCompany.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _AssignCompany.local_last_changed_at as LocalLastChangedAt,

      _CompanyCode.CompanyCodeName,

      _User
}
