@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print Material Requisition Header'
define root view entity ZR_MATERIALREQUISITION_PRT_H
  as select from    ztpp_1009
    left outer join ztpp_1010 on  ztpp_1010.material_requisition_no = ztpp_1009.material_requisition_no
                              and ztpp_1010.item_no                 = '0010'
  association [0..1] to I_Plant                      as _Plant                   on  $projection.Plant = _Plant.Plant
  association [0..1] to I_Customer                   as _Customer                on  $projection.Customer = _Customer.Customer
  association [0..1] to ZC_ApplicationTypeVH         as _TypeText                on  $projection.Type = _TypeText.Zvalue1
  association [0..1] to ZC_LineWarehouseStatusVH     as _LineWarehouseStatusText on  $projection.LineWarehouseStatus = _LineWarehouseStatusText.Zvalue1
  association [0..1] to ZR_TBC1001                   as _Receiver                on  $projection.Receiver = _Receiver.Zvalue1
                                                                                 and _Receiver.ZID        = 'ZPP004'
  association [0..*] to ZR_MATERIALREQUISITION_PRT_I as _Item                    on  $projection.MaterialRequisitionNo = _Item.MaterialRequisitionNo
{
  key ztpp_1009.material_requisition_no                                 as MaterialRequisitionNo,
      ztpp_1009.type                                                    as Type,
      ztpp_1009.plant                                                   as Plant,
      ztpp_1009.cost_center                                             as CostCenter,
      ztpp_1009.customer                                                as Customer,
      ztpp_1009.receiver                                                as Receiver,
      ztpp_1009.line_warehouse_status                                   as LineWarehouseStatus,
      ztpp_1009.created_date                                            as CreatedDate,
      ztpp_1009.created_by_user                                         as CreatedByUser,
      ztpp_1009.created_by_user_name                                    as CreatedByUserName,
      ztpp_1009.requisition_date                                        as RequisitionDate,
      ztpp_1009.last_approved_date                                      as LastApprovedDate,
      ztpp_1009.last_approved_by_user                                   as LastApprovedByUser,
      ztpp_1009.last_approved_by_user_name                              as LastApprovedByUserName,

      _Plant.PlantName,
      _Customer.CustomerName,
      concat( concat(ztpp_1009.customer,':'), _Customer.CustomerName)   as CustomerStr,
      _TypeText.Zvalue2                                                 as TypeText,
      _LineWarehouseStatusText.Zvalue2                                  as LineWarehouseStatusText,

      //      _Receiver.Zvalue2                                                 as ReceiverName,
      //      concat( concat(ztpp_1009.receiver,':'), _Receiver.Zvalue2)        as ReceiverStr,
      ''                                                                as ReceiverName,

      case when ztpp_1009.receiver is not initial
           then ztpp_1009.receiver
           else ztpp_1009.created_by_user_name end                      as ReceiverStr,

      case when ztpp_1009.type = '31' then 'I/M No.' else 'M/R No.' end as TypeLabel,
      case when ztpp_1009.type = '31'
           then '副　資　材　仕　損　処　理　依　頼　書'
           else '部　品　払　出　依　頼　書'
      end                                                               as TableTitle,

      ztpp_1010.manufacturing_order                                     as ManufacturingOrder,
      ztpp_1010.product                                                 as Product,

      /* Associations */
      @ObjectModel.filter.enabled: false
      _Item
}
