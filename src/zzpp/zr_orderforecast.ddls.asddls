@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Forecast'
define root view entity ZR_ORDERFORECAST
  as select from ztpp_1012
{
  key uuid                  as Uuid,
      customer              as Customer,
      material              as Material,
      plant                 as Plant,
      material_by_customer  as MaterialByCustomer,
      requirement_date      as RequirementDate,
      requirement_qty       as RequirementQty,
      unit_of_measure       as UnitOfMeasure,
      remark                as Remark,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
