@EndUserText.label: 'Purchase Price Variance Report'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_PURCHASEPRICEVARIANCE
  provider contract transactional_query
  as projection on ZR_PURCHASEPRICEVARIANCE
{
  key      PurchaseOrder,
  key      PurchaseOrderItem,
           CompanyCode,
           PurchasingOrganization,
           PurchasingGroup,
           Supplier,
           DocumentCurrency,
           PurchaseOrderDate,

           PurchaseOrderItemCategory,
           Material,
           PurchaseOrderItemText,
           SupplierMaterialNumber,
           OrderQuantity,
           PurchaseOrderQuantityUnit,
           NetPriceAmount,
           NetPriceQuantity,
           Plant,
           StorageLocation,
           PurchasingInfoRecord,
           PricingDateControl,
           PurgDocPriceDate,
           IsCompletelyDelivered,

           PricingDateControl2,
           Currency,
           PurchaseOrderStr,
           PriceDate,

           _PurOrdScheduleLine.ScheduleLineDeliveryDate,
           _PurchasingGroup.PurchasingGroupName,
           _BusinessPartner.OrganizationBPName1,
           _StorageLocation.StorageLocationName,
           _Product.YY1_CUSTOMERMATERIAL_PRD,
           _PricingDateControlTxt1.PricingDateControlText,
           _PricingDateControlTxt2.PricingDateControlText as PricingDateControl2Text,

           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PURCHASEPRICEVARIANCE'
  virtual  DeliveryDate               : abap.dats,
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PURCHASEPRICEVARIANCE'
  virtual  PostingDate                : abap.dats,
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PURCHASEPRICEVARIANCE'
  virtual  ConditionValidityStartDate : abap.dats,
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PURCHASEPRICEVARIANCE'
  virtual  ConditionValidityEndDate   : abap.dats,
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PURCHASEPRICEVARIANCE'
  virtual  ConditionQuantity          : abap.dec(5),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PURCHASEPRICEVARIANCE'
  virtual  ConditionQuantityUnit      : abap.unit(3),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PURCHASEPRICEVARIANCE'
  virtual  CurrentPrice               : abap.dec(23,5),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PURCHASEPRICEVARIANCE'
  virtual  ConditionRateValue         : abap.dec(23,5),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PURCHASEPRICEVARIANCE'
  virtual  NewPrice                   : abap.dec(23,5),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PURCHASEPRICEVARIANCE'
  virtual  Difference                 : abap.dec(23,5),

           /* Associations */
           _PurOrdScheduleLine,
           _PurchasingGroup,
           _BusinessPartner,
           _StorageLocation,
           _PricingDateControlTxt1,
           _Product,
           _PurgInfoRecdOrgPlntData,
           _PricingDateControlTxt2
}
