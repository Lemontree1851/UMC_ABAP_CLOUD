@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access User <-> PurchOrgTable'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_TBC1017
  as select from ztbc_1017                as _AssignPurchOrg
    inner join   I_PurchasingOrganization as _PurchasingOrganization on _PurchasingOrganization.PurchasingOrganization = _AssignPurchOrg.purchasing_organization

  association to parent ZR_TBC1004 as _User on $projection.Mail = _User.Mail
{
  key _AssignPurchOrg.uuid                    as Uuid,
  key _AssignPurchOrg.mail                    as Mail,
      _AssignPurchOrg.purchasing_organization as PurchasingOrganization,
      @Semantics.user.createdBy: true
      _AssignPurchOrg.created_by              as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      _AssignPurchOrg.created_at              as CreatedAt,
      @Semantics.user.lastChangedBy: true
      _AssignPurchOrg.last_changed_by         as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      _AssignPurchOrg.last_changed_at         as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _AssignPurchOrg.local_last_changed_at   as LocalLastChangedAt,

      _PurchasingOrganization.PurchasingOrganizationName,

      _User
}
