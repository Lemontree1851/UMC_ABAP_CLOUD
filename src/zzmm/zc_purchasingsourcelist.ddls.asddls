@EndUserText.label: 'Purchasing Source List'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_PURCHASINGSOURCELIST
  provider contract transactional_query
  as projection on ZR_PURCHASINGSOURCELIST
{
  key UUID,
      Material,
      Plant,
      SourceListRecord,
      ValidityStartDate,
      ValidityEndDate,
      Supplier,
      PurchasingOrganization,
      SupplierIsFixed,
      SourceOfSupplyIsBlocked,
      MrpSourcingControl,
      Xflag,
      Status,
      Message,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
