@EndUserText.label: '納受領出力-出力'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_DeliveryReceiptPrint as projection on ZR_DeliveryReceiptPrint
{
  key DeliveryDocument,
  key ShipToParty,
  PostalCode,
  CityName,
  CustomerName,
  /* Associations */
  _Item
}
