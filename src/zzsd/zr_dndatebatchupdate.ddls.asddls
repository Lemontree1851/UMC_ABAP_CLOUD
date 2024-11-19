@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '出荷伝票外部移転の日付一括更新'
define root view entity ZR_DNDATEBATCHUPDATE
  as select from    ZR_DNDATEBATCHUPDATE_01 as _itmes
    left outer join ZR_DNDATEBATCHUPDATE_01 as _check on  _check.DeliveryDocument2 is initial
                                                      and _check.DeliveryDocument3 = _itmes.DeliveryDocument
{

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_DeliveryDocumentStdVH', element: 'DeliveryDocument' } } ]
  key _itmes.DeliveryDocument,
  key _itmes.DeliveryDocumentItem,
      _itmes.ShippingPoint,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_SalesOrganization', element: 'SalesOrganization' } } ]
      _itmes.SalesOrganization,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_SALSEOFFICE_VH', element: 'SalesOffice' } } ]
      _itmes.SalesOffice,
      _itmes.SoldToParty,
      _itmes.SoldToPartyName        as SoldToPartyName,
      _itmes.ShipToParty,
      _itmes.ShipToPartyName        as ShipToPartyName,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_ProductStdVH', element: 'Product' } } ]
      _itmes.Product,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PlantStdVH', element: 'Plant' } } ]
      _itmes.Plant,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_StorageLocationStdVH', element: 'Plant' } } ]
      _itmes.StorageLocation,
      _itmes.ActualDeliveredQtyInBaseUnit,
      _itmes.BaseUnit,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_ProfitCenterVH', element: 'ProfitCenter' } } ]
      _itmes.ProfitCenter,
      _itmes.ReferenceSDDocument,
      _itmes.ReferenceSDDocumentItem,
      _itmes.DeliveryRelatedBillingStatus,
      _itmes.DocumentDate,
      _itmes.DeliveryDate,
      _itmes.ActualGoodsMovementDate,
      _itmes.OverallGoodsMovementStatus,
      _itmes.IntcoExtPlndTransfOfCtrlDteTme,
      _itmes.IntcoExtActlTransfOfCtrlDteTme,
      _itmes.IntcoIntPlndTransfOfCtrlDteTme,
      _itmes.IntcoIntActlTransfOfCtrlDteTme,
      _itmes.YY1_SalesDocType_DLH,
      ''                            as Status,
      cast('' as abap.sstring( 1 )) as Message,
      _itmes.DeliveryDocument3,
      _itmes.DeliveryDocument2,
      case
        when _check.DeliveryDocument is not initial
            then ''
        else _itmes.DeliveryDocument
      end                           as DeliveryDocument4
}
