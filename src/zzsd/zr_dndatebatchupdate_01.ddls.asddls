@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '出荷伝票外部移転の日付一括更新'
define root view entity ZR_DNDATEBATCHUPDATE_01
  as select from I_DeliveryDocumentItem as _itmes
    inner join   I_DeliveryDocument     as _Document on  _Document.DeliveryDocument           = _itmes.DeliveryDocument
                                                     and _Document.OverallGoodsMovementStatus = 'C'

  association [0..1] to I_BusinessPartner        as _SoldToParty          on  $projection.SoldToParty = _SoldToParty.BusinessPartner
  association [0..1] to I_BusinessPartner        as _ShipToParty          on  $projection.ShipToParty = _ShipToParty.BusinessPartner
  association [0..1] to I_SalesDocumentItem      as _SalesDocumentItem    on  _SalesDocumentItem.SalesDocument     = $projection.ReferenceSDDocument
                                                                          and _SalesDocumentItem.SalesDocumentItem = $projection.ReferenceSDDocumentItem
  association [0..1] to I_MaterialDocumentItem_2 as _MaterialDocumentItem on  _MaterialDocumentItem.ReversedMaterialDocument is initial
                                                                          and _MaterialDocumentItem.GoodsMovementIsCancelled is initial
                                                                          and _MaterialDocumentItem.GoodsMovementType        = '601'
                                                                          and _MaterialDocumentItem.DebitCreditCode          = 'H'
                                                                          and _MaterialDocumentItem.DeliveryDocument         = $projection.DeliveryDocument
{
  key _itmes.DeliveryDocument,
  key _itmes.DeliveryDocumentItem,
      _Document.ShippingPoint,
      _Document.SalesOrganization,
      _itmes.SalesOffice,
      _Document.SoldToParty,
      _SoldToParty.BusinessPartnerName       as SoldToPartyName,
      _Document.ShipToParty,
      _ShipToParty.BusinessPartnerName       as ShipToPartyName,
      _itmes.Product,
      _itmes.Plant,
      _itmes.StorageLocation,
      _itmes.ActualDeliveredQtyInBaseUnit,
      _itmes.BaseUnit,
      _itmes.ProfitCenter,
      _itmes.ReferenceSDDocument,
      _itmes.ReferenceSDDocumentItem,
      _itmes.DeliveryRelatedBillingStatus,
      _Document.DocumentDate,
      _Document.DeliveryDate,
      _Document.ActualGoodsMovementDate,
      _Document.OverallGoodsMovementStatus,
      _Document.IntcoExtPlndTransfOfCtrlDteTme,
      _Document.IntcoExtActlTransfOfCtrlDteTme,
      _Document.IntcoIntPlndTransfOfCtrlDteTme,
      _Document.IntcoIntActlTransfOfCtrlDteTme,
      _Document.YY1_SalesDocType_DLH,
      ''                                     as Status,
      cast('' as abap.sstring( 1 ))          as Message,

      case when
        _SalesDocumentItem.TransitPlant is not initial
      then _SalesDocumentItem.TransitPlant
      else _itmes.Plant
      end                                    as Plant2,

      _MaterialDocumentItem.Plant            as Plant3,
      
      _MaterialDocumentItem.GoodsMovementType,
      _MaterialDocumentItem.DebitCreditCode,
      
      _MaterialDocumentItem.DeliveryDocument as DeliveryDocument3,

      case 
        when _MaterialDocumentItem.DeliveryDocument is not initial
         and $projection.Plant3 = $projection.Plant2
            then ''
        else _itmes.DeliveryDocument
      end                                    as DeliveryDocument2
}
where
  _itmes.DeliveryRelatedBillingStatus = 'A'
