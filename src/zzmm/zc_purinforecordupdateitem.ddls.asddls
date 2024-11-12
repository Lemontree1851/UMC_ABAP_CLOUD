@EndUserText.label: 'Pur Info Record Item'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_PURINFORECORDUPDATEITEM
  as projection on ZR_PURINFORECORDUPDATEITEM
{
  key UUID,
      Supplier,
      Material,
      PurchasingOrganization,
      Plant,
      PurchasingInfoRecordCategory,
      ConditionValidityStartDate,
      ConditionValidityEndDate,
      ConditionScaleQuantity,
      ConditionScaleAmount,
      ConditionScaleAmountCurrency,
      ConditionScaleQuantityUnit,
      /* Associations */
      _Header : redirected to parent ZC_PURINFORECORDUPDATE
}
