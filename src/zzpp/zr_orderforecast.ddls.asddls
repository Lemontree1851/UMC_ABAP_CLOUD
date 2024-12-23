@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Forecast'
define root view entity ZR_ORDERFORECAST
  as select from ztpp_1012
    inner join   ZR_TBC1006           as _AssignPlant on _AssignPlant.Plant = ztpp_1012.plant
    inner join   ZC_BusinessUserEmail as _User        on  _User.Email  = _AssignPlant.Mail
                                                      and _User.UserID = $session.user
{
  key ztpp_1012.uuid                  as Uuid,
      ztpp_1012.customer              as Customer,
      ztpp_1012.material              as Material,
      ztpp_1012.plant                 as Plant,
      ztpp_1012.material_by_customer  as MaterialByCustomer,
      ztpp_1012.requirement_date      as RequirementDate,
      ztpp_1012.requirement_qty       as RequirementQty,
      ztpp_1012.unit_of_measure       as UnitOfMeasure,
      ztpp_1012.remark                as Remark,
      ztpp_1012.created_by            as CreatedBy,
      ztpp_1012.created_at            as CreatedAt,
      ztpp_1012.last_changed_by       as LastChangedBy,
      ztpp_1012.last_changed_at       as LastChangedAt,
      ztpp_1012.local_last_changed_at as LocalLastChangedAt
}
