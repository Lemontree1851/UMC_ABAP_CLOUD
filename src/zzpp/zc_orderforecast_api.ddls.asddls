@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Forecast'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_ORDERFORECAST_API
  as select from ztpp_1012
{
  key ztpp_1012.uuid                  as Uuid,
      ztpp_1012.customer              as Customer,
      ztpp_1012.material              as Material,
      ztpp_1012.plant                 as Plant,
      ztpp_1012.material_by_customer  as MaterialByCustomer,
      ztpp_1012.requirement_date      as RequirementDate,
      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      ztpp_1012.requirement_qty       as RequirementQty,
      ztpp_1012.unit_of_measure       as UnitOfMeasure,
      ztpp_1012.remark                as Remark,
      ztpp_1012.created_by            as CreatedBy,
      ztpp_1012.created_at            as CreatedAt,
      ztpp_1012.last_changed_by       as LastChangedBy,
      ztpp_1012.last_changed_at       as LastChangedAt,
      ztpp_1012.local_last_changed_at as LocalLastChangedAt
}
