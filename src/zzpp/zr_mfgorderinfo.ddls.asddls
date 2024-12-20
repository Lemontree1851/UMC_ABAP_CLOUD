@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manufacturing Order Infomation Report'
define root view entity ZR_MFGORDERINFO
  as select from I_ManufacturingOrder as _MfgOrder
    inner join   ZR_TBC1006           as _AssignPlant on _AssignPlant.Plant = _MfgOrder.ProductionPlant
    inner join   ZC_BusinessUserEmail as _User        on  _User.Email  = _AssignPlant.Mail
                                                      and _User.UserID = $session.user

  association [0..1] to I_ProductDescription as _MaterialDescription on  $projection.Material          = _MaterialDescription.Product
                                                                     and _MaterialDescription.Language = $session.system_language
{
  key _MfgOrder.ManufacturingOrder,
      _MfgOrder.ProductionPlant,
      _MfgOrder.ProductionSupervisor,
      cast(_MfgOrder.Material as matnr preserving type) as Material,
      _MfgOrder.ProductionVersion,
      _MfgOrder.MRPController,
      _MfgOrder.MfgOrderPlannedTotalQty,
      _MfgOrder.Batch,
      _MfgOrder.MfgOrderConfirmedYieldQty,
      _MfgOrder.ProductionUnit,
      _MfgOrder.MfgOrderPlannedStartDate,
      _MfgOrder.MfgOrderPlannedEndDate,
      _MfgOrder.SalesOrder,
      _MaterialDescription
}
