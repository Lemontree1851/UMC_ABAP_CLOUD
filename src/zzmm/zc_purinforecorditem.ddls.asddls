@EndUserText.label: 'Pur Info Record Item'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_PURINFORECORDITEM
  as projection on ZR_PURINFORECORDITEM
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
      _Header : redirected to parent ZC_PURINFORECORDHEADER
}
