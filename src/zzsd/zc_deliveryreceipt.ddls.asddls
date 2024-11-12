@EndUserText.label: '納受領出力-报表'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_DeliveryReceipt
  provider contract transactional_query as projection on ZR_DELIVERYRECEIPT
{
  key DeliveryDocument,
  key DeliveryDocumentItem,
  ReferenceSDDocument,
  ReferenceSDDocumentItem,
  DeliveryDocumentItemText,
  OverallSDProcessStatus,
  DeliveryDocumentType,
  ShippingPoint,
  SoldToParty,
  ShipToParty,
  IntcoExtPlndTransfOfCtrlDteTme,
  CreatedByUser,
  DeliveryDate,
  CreationDate,
  SalesOrganization,
  SalesOffice,
  Material,
  MaterialByCustomer,
  ActualDeliveryQuantity,
  DeliveryQuantityUnit,
  ConditionRateValue,
  ConditionQuantity,
  ConditionQuantityUnit,
  ConditionCurrency,
  ConditionAmount,
  TransactionCurrency,
  /* Associations */
  _Customer.PostalCode,
  _Customer.CityName,
  _Customer.CustomerName,
  DeliveryReceiptNo,
  _BC1001.zvalue2 as TheCompanyPostalCode,
  _BC1001.zvalue3 as TheCompanyCityName1,
  _BC1001.zvalue4 as TheCompanyCityName2,
  _BC1001.zvalue5 as TheCompanyTelNumber,
  _BC1001.zvalue6 as TheCompanyFaxNumber,
  _BC1001.zvalue7 as TheCompanyName
}
