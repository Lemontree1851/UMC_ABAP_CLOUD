@EndUserText.label: 'Order Forecast'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_ORDERFORECAST
  provider contract transactional_query
  as projection on ZR_ORDERFORECAST
{
  key Uuid,
      Customer,
      Material,
      Plant,
      MaterialByCustomer,
      RequirementDate,
      RequirementQty,
      UnitOfMeasure,
      Remark,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
