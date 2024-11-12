@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '納受領出力明细'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZR_DeliveryReceiptItemPrint as select from ZR_DELIVERYRECEIPT
{
  key DeliveryDocument,
  key DeliveryDocumentItem,
  ShipToParty,
  ReferenceSDDocument,
  ReferenceSDDocumentItem,
  MaterialByCustomer,
  DeliveryDocumentItemText,
  @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
  ActualDeliveryQuantity,
  DeliveryQuantityUnit,
  ConditionRateValue,
  ConditionQuantity,
  ConditionQuantityUnit,
  ConditionCurrency,
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  ConditionAmount,
  TransactionCurrency
}
