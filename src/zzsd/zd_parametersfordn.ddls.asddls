define abstract entity ZD_PARAMETERSFORDN
{
  DeliveryType       : abap.char(4);
  ShippingType       : abap.char(2);
  @EndUserText.label : 'Ship-to Party'
  ShipToParty        : zekunnr;
  @Semantics.quantity.unitOfMeasure: 'CurrDeliverQtyUnit'
  CurrDeliveryQty    : menge_d;
  CurrDeliverQtyUnit : meins;
  ShippingStorLoc    : abap.char(4);
}
