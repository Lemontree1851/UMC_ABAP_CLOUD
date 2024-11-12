@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '出荷伝票外部移転の日付一括更新'
define root view entity ZC_DNDATEBATCHUPDATE
  provider contract transactional_query
  as projection on ZR_DNDATEBATCHUPDATE
{
  key DeliveryDocument,
  key DeliveryDocumentItem,
      ShippingPoint,
      SalesOrganization,
      SalesOffice,
      SoldToParty,
      SoldToPartyName,
      ShipToParty,
      ShipToPartyName,
      Product,
      Plant,
      StorageLocation,
      ActualDeliveredQtyInBaseUnit,
      BaseUnit,
      ProfitCenter,
      ReferenceSDDocument,
      ReferenceSDDocumentItem,
      DeliveryRelatedBillingStatus,
      DocumentDate,
      DeliveryDate,
      ActualGoodsMovementDate,
      OverallGoodsMovementStatus,
      IntcoExtPlndTransfOfCtrlDteTme,
      IntcoExtActlTransfOfCtrlDteTme,
      IntcoIntPlndTransfOfCtrlDteTme,
      IntcoIntActlTransfOfCtrlDteTme,
      YY1_SalesDocType_DLH,
      Status,
      Message
}