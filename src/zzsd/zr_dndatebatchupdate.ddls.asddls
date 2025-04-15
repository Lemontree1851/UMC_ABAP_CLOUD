@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '出荷伝票外部移転の日付一括更新'
define root view entity ZR_DNDATEBATCHUPDATE
  as select from    ZR_DNDATEBATCHUPDATE_01 as _item
    inner join      ZR_TBC1006              as _AssignPlant on _AssignPlant.Plant = _item.Plant
    inner join      ZR_TBC1018              as _AssignSP    on _AssignSP.ShippingPoint = _item.ShippingPoint
    inner join      ZC_BusinessUserEmail    as _User        on  _User.Email = _AssignPlant.Mail
                                                            and _User.Email = _AssignSP.Mail
    left outer join ZR_DNDATEBATCHUPDATE_01 as _check       on  _check.DeliveryDocument2 is initial
                                                            and _check.DeliveryDocument3 = _item.DeliveryDocument
{

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_DeliveryDocumentStdVH', element: 'DeliveryDocument' } } ]
  key _item.DeliveryDocument,
  key _item.DeliveryDocumentItem,
      _item.ShippingPoint,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_SalesOrganization', element: 'SalesOrganization' } } ]
      _item.SalesOrganization,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_SALSEOFFICE_VH', element: 'SalesOffice' } } ]
      _item.SalesOffice,
      _item.SoldToParty,
      _item.SoldToPartyName         as SoldToPartyName,
      _item.ShipToParty,
      _item.ShipToPartyName         as ShipToPartyName,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_ProductStdVH', element: 'Product' } } ]
      _item.Product,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PlantStdVH', element: 'Plant' } } ]
      _item.Plant,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_StorageLocationStdVH', element: 'Plant' } } ]
      _item.StorageLocation,
      _item.ActualDeliveredQtyInBaseUnit,
      _item.BaseUnit,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_ProfitCenterVH', element: 'ProfitCenter' } } ]
      _item.ProfitCenter,
      _item.ReferenceSDDocument,
      _item.ReferenceSDDocumentItem,
      _item.DeliveryRelatedBillingStatus,
      _item.DocumentDate,
      _item.DeliveryDate,
      _item.ActualGoodsMovementDate,
      _item.OverallGoodsMovementStatus,
      _item.IntcoExtPlndTransfOfCtrlDteTme,
      _item.IntcoExtActlTransfOfCtrlDteTme,
      _item.IntcoIntPlndTransfOfCtrlDteTme,
      _item.IntcoIntActlTransfOfCtrlDteTme,
      _item.YY1_SalesDocType_DLH,
      ''                            as Status,
      cast('' as abap.sstring( 1 )) as Message,
      _item.DeliveryDocument3,
      _item.DeliveryDocument2,
      case
        when _check.DeliveryDocument is not initial
            then ''
        else _item.DeliveryDocument
      end                           as DeliveryDocument4,
      _User.Email                   as UserEmail
}
