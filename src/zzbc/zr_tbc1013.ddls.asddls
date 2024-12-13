@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access User <-> Sales Org. Table'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_TBC1013
  as select from ztbc_1013               as _AssignSalesOrg
    inner join   I_SalesOrganizationText as _SalesOrgText on  _SalesOrgText.SalesOrganization = _AssignSalesOrg.sales_organization
                                                          and _SalesOrgText.Language          = $session.system_language

  association to parent ZR_TBC1004 as _User on $projection.Mail = _User.Mail
{
  key _AssignSalesOrg.uuid                  as Uuid,
  key _AssignSalesOrg.mail                  as Mail,
      _AssignSalesOrg.sales_organization    as SalesOrganization,
      @Semantics.user.createdBy: true
      _AssignSalesOrg.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      _AssignSalesOrg.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      _AssignSalesOrg.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      _AssignSalesOrg.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _AssignSalesOrg.local_last_changed_at as LocalLastChangedAt,

      _SalesOrgText.SalesOrganizationName,

      _User
}
