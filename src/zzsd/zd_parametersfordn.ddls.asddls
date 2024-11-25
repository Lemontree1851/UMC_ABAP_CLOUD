define abstract entity ZD_PARAMETERSFORDN
{
  @EndUserText.label: '今回納品数'
  @Semantics.quantity.unitOfMeasure: 'CurrDeliverQtyUnit'
  CurrDeliveryQty : menge_d;
  CurrDeliverQtyUnit : meins;
  @EndUserText.label: '今回保管場所'
  CurrStorageLocation : lgort_d;
  @EndUserText.label: '今回出荷タイプ'
  CurrShippingType : abap.char(2);
  @EndUserText.label: '今回計画出庫日付'
  CurrPlannedGoodsIssueDate : datum;
  @EndUserText.label: '今回納入日付'
  CurrDeliveryDate : datum;
}
