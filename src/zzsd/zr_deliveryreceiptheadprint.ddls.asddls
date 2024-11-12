@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '納受領出力抬头'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZR_DeliveryReceiptHeadPrint as select distinct from ZR_DELIVERYRECEIPT
  association [0..*] to ZR_DeliveryReceiptItemPrint as _DeliveryItem
    on $projection.DeliveryDocument = _DeliveryItem.DeliveryDocument
    and $projection.ShipToParty = _DeliveryItem.ShipToParty
{
  key DeliveryDocument,
  key ShipToParty,
  /* Associations */
  _Customer.PostalCode,
  _Customer.CityName,
  _Customer.CustomerName,
  _DeliveryItem
}
