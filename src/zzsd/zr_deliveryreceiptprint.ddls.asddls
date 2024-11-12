@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '納受領出力'
define root view entity ZR_DeliveryReceiptPrint
  as select distinct from ZR_DeliveryReceiptHeadPrint as _Head
  association [0..*] to ZR_DeliveryReceiptItemPrint as _Item on  $projection.DeliveryDocument = _Item.DeliveryDocument
                                                             and $projection.ShipToParty      = _Item.ShipToParty
{
  key _Head.DeliveryDocument,
  key _Head.ShipToParty,
      _Head.PostalCode,
      _Head.CityName,
      _Head.CustomerName,
      /* Associations */
      _Item
}
