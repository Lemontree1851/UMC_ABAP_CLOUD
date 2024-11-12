@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '出荷伝票外部移転の日付一括更新'
define root view entity ZR_DNDATEBATCHUPDATE
  as select from    I_DeliveryDocumentItem     as _itmes
    inner join      I_DeliveryDocument         as _Document    on _Document.DeliveryDocument = _itmes.DeliveryDocument
                                                              and _Document.OverallGoodsMovementStatus = 'C'
    left outer join I_BusinessPartner as _SoldToParty on _Document.SoldToParty = _SoldToParty.BusinessPartner
    left outer join I_BusinessPartner as _ShipToParty on _Document.ShipToParty = _ShipToParty.BusinessPartner
{
       
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_DeliveryDocumentStdVH', element: 'DeliveryDocument' } } ]
  key _itmes.DeliveryDocument,
  key _itmes.DeliveryDocumentItem,
      _Document.ShippingPoint,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_SalesOrganization', element: 'SalesOrganization' } } ]
      _Document.SalesOrganization,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_SALSEOFFICE_VH', element: 'SalesOffice' } } ]
      _itmes.SalesOffice,
      _Document.SoldToParty,
      _SoldToParty.BusinessPartnerName as SoldToPartyName,
      _Document.ShipToParty,
      _ShipToParty.BusinessPartnerName as ShipToPartyName,
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
      _Document.DocumentDate,
      _Document.DeliveryDate,
      _Document.ActualGoodsMovementDate,
      _Document.OverallGoodsMovementStatus,
//      cast(
//        case _Document.IntcoExtPlndTransfOfCtrlDteTme
//            when 0 then '00000000'
//            else left(cast(_Document.IntcoExtPlndTransfOfCtrlDteTme as abap.char(25)),8)
//        end
//        as abap.dats) as IntcoExtPlndTransfOfCtrlDteTme,
//        
//      cast(
//        case _Document.IntcoExtActlTransfOfCtrlDteTme
//            when 0 then '00000000'
//            else left(cast(_Document.IntcoExtPlndTransfOfCtrlDteTme as abap.char(25)),8)
//        end
//        as abap.dats) as IntcoExtActlTransfOfCtrlDteTme,
//      cast(left(cast(_Document.IntcoExtPlndTransfOfCtrlDteTme as abap.char(25)),8) as abap.dats) as IntcoExtPlndTransfOfCtrlDteTme,
//      cast(left(cast(_Document.IntcoExtActlTransfOfCtrlDteTme as abap.char(25)),8) as abap.dats) as IntcoExtActlTransfOfCtrlDteTme,
      _Document.IntcoExtPlndTransfOfCtrlDteTme,
      _Document.IntcoExtActlTransfOfCtrlDteTme,
      _Document.IntcoIntPlndTransfOfCtrlDteTme,
      _Document.IntcoIntActlTransfOfCtrlDteTme,
      _Document.YY1_SalesDocType_DLH,
      '' as Status,
      cast('' as abap.sstring( 1 )) as Message
}where _itmes.DeliveryRelatedBillingStatus = 'A'
