@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Requisition'
define root view entity ZR_MATERIALREQUISITION
  as select from    ztpp_1009               as _Header
    inner join      ztpp_1010               as _Item               on _Item.material_requisition_no = _Header.material_requisition_no
    left outer join I_MfgOrderWithStatus    as _MfgOrderWithStatus on _MfgOrderWithStatus.ManufacturingOrder = _Item.manufacturing_order
    left outer join I_ProductValuationBasic as _ProductValuation   on  _ProductValuation.Product       = _Item.material
                                                                   and _ProductValuation.ValuationArea = _Header.plant

  association [0..1] to I_Plant                       as _Plant                   on  $projection.Plant = _Plant.Plant
  association [0..1] to ZC_CostCenterVH               as _CostCenterText          on  $projection.CostCenter = _CostCenterText.CostCenter

  association [0..1] to ZC_ProductVH                  as _ProductDescription      on  $projection.Product = _ProductDescription.Material
                                                                                  and $projection.Plant   = _ProductDescription.Plant
  association [0..1] to ZC_ProductVH                  as _MaterialDescription     on  $projection.Material = _MaterialDescription.Material
                                                                                  and $projection.Plant    = _MaterialDescription.Plant
  association [0..1] to I_Customer                    as _Customer                on  $projection.Customer = _Customer.Customer
  association [0..1] to I_StorageLocation             as _StorageLocation         on  $projection.Plant           = _StorageLocation.Plant
                                                                                  and $projection.StorageLocation = _StorageLocation.StorageLocation

  association [0..1] to ZC_ApplicationTypeVH          as _TypeText                on  $projection.Type = _TypeText.Zvalue1
  association [0..1] to ZC_ApplicationStatusVH        as _MRStatusText            on  $projection.MRStatus = _MRStatusText.Zvalue1
  association [0..1] to ZC_ManufacturingOrderClosedVH as _OrderStatusText         on  $projection.OrderIsClosed = _OrderStatusText.Zvalue1
  association [0..1] to ZC_ApplicationPostingStatusVH as _PostingStatusText       on  $projection.PostingStatus = _PostingStatusText.Zvalue1
  association [0..1] to ZC_LineWarehouseStatusVH      as _LineWarehouseStatusText on  $projection.LineWarehouseStatus = _LineWarehouseStatusText.Zvalue1
  association [0..1] to ZC_ApplicationPostingStatusVH as _UWMS_PostStatusText     on  $projection.UWMS_PostStatus = _UWMS_PostStatusText.Zvalue1
  association [0..1] to ZC_DeleteFlagVH               as _DeleteFlagText          on  $projection.ItemDeleteFlag = _DeleteFlagText.Zvalue1
  association [0..1] to ZC_TBC1001                    as _ReasonText              on  $projection.Reason = _ReasonText.Zvalue1
                                                                                  and _ReasonText.ZID    = 'ZPP011'

{
  key _Header.material_requisition_no    as MaterialRequisitionNo,
  key _Item.item_no                      as ItemNo,
      _Header.type                       as Type,
      _Header.m_r_status                 as MRStatus,
      _Header.plant                      as Plant,
      _Header.cost_center                as CostCenter,
      _Header.customer                   as Customer,
      _Header.receiver                   as Receiver,
      _Header.line_warehouse_status      as LineWarehouseStatus,
      _Header.requisition_date           as RequisitionDate,
      _Header.delete_flag                as HeaderDeleteFlag,

      _Header.last_approved_date         as LastApprovedDate,
      _Header.last_approved_time         as LastApprovedTime,
      _Header.last_approved_by_user      as LastApprovedByUser,
      _Header.last_approved_by_user_name as LastApprovedByUserName,

      _Header.created_date               as HeaderCreatedDate,
      _Header.created_time               as HeaderCreatedTime,
      _Header.created_by_user            as HeaderCreatedByUser,
      _Header.created_by_user_name       as HeaderCreatedByUserName,
      _Header.last_changed_date          as HeaderLastChangedDate,
      _Header.last_changed_time          as HeaderLastChangedTime,
      _Header.last_changed_by_user       as HeaderLastChangedByUser,
      _Header.last_changed_by_user_name  as HeaderLastChangedByUserName,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _Header.local_last_changed_at      as HeaderLocalLastChangedAt,

      _Item.manufacturing_order          as ManufacturingOrder,
      _Item.product                      as Product,
      _Item.material                     as Material,
      _Item.storage_location             as StorageLocation,
      _Item.base_unit                    as BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      _Item.quantity                     as Quantity,
      _Item.location                     as Location,
      _Item.reason                       as Reason,
      _Item.remark                       as Remark,
      _Item.posting_status               as PostingStatus,
      _Item.goods_movement_type          as GoodsMovementType,
      _Item.material_document            as MaterialDocument,
      _Item.posting_date                 as PostingDate,
      _Item.posting_time                 as PostingTime,
      _Item.posting_by_user              as PostingByUser,
      _Item.posting_by_user_name         as PostingByUserName,
      _Item.cancel_material_document     as CancelMaterialDocument,
      _Item.cancelled_by_user            as CancelledByUser,
      _Item.cancelled_by_user_name       as CancelledByUserName,
      _Item.uwms_post_status             as UWMS_PostStatus,

      _Item.delete_flag                  as ItemDeleteFlag,

      case when _Item.delete_flag = 'W'
           then 1
           else 0 end                    as Criticality,

      case when _Header.type <> '31' and _Header.line_warehouse_status <> 'X'
      then _UWMS_PostStatusText.Zvalue2
      else '' end                        as UWMS_PostStatusText,

      _MfgOrderWithStatus.OrderIsClosed,
      @Semantics.amount.currencyCode: 'Currency'
      _ProductValuation.StandardPrice,
      _ProductValuation.PriceUnitQty,
      _ProductValuation.Currency,

      @Semantics.amount.currencyCode: 'Currency'
      cast( _Item.quantity * ( cast( _ProductValuation.StandardPrice as abap.dec( 11, 2 ) ) / _ProductValuation.PriceUnitQty )
            as abap.curr( 23, 2 )  )     as TotalAmount,

      _Item.created_date                 as ItemCreatedDate,
      _Item.created_time                 as ItemCreatedTime,
      _Item.created_by_user              as ItemCreatedByUser,
      _Item.created_by_user_name         as ItemCreatedByUserName,
      _Item.last_changed_date            as ItemLastChangedDate,
      _Item.last_changed_time            as ItemLastChangedTime,
      _Item.last_changed_by_user         as ItemLastChangedByUser,
      _Item.last_changed_by_user_name    as ItemLastChangedByUserName,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _Item.local_last_changed_at        as ItemLocalLastChangedAt,

      _Plant,
      _CostCenterText,
      _ProductDescription,
      _MaterialDescription,
      _Customer,
      _StorageLocation,

      _TypeText,
      _MRStatusText,
      _OrderStatusText,
      _PostingStatusText,
      _LineWarehouseStatusText,
      _DeleteFlagText,
      _ReasonText
}
