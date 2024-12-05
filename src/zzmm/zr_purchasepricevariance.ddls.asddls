@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Price Variance Report'
define root view entity ZR_PURCHASEPRICEVARIANCE
  as select from    I_PurchaseOrderAPI01        as _PurchaseOrder
    inner join      I_PurchaseOrderItemAPI01    as _PurchaseOrderItem on _PurchaseOrderItem.PurchaseOrder = _PurchaseOrder.PurchaseOrder
    left outer join I_PurchasingInfoRecordApi01 as _PurInfoRecord     on  _PurInfoRecord.Supplier = _PurchaseOrder.Supplier
                                                                      and _PurInfoRecord.Material = _PurchaseOrderItem.Material

  association [0..1] to I_PurOrdScheduleLineAPI01      as _PurOrdScheduleLine      on  $projection.PurchaseOrder                     = _PurOrdScheduleLine.PurchaseOrder
                                                                                   and $projection.PurchaseOrderItem                 = _PurOrdScheduleLine.PurchaseOrderItem
                                                                                   and _PurOrdScheduleLine.PurchaseOrderScheduleLine = '0001'
  association [0..1] to I_PurchasingGroup              as _PurchasingGroup         on  $projection.PurchasingGroup = _PurchasingGroup.PurchasingGroup
  association [0..1] to I_BusinessPartner              as _BusinessPartner         on  $projection.Supplier = _BusinessPartner.BusinessPartner
  association [0..1] to I_StorageLocation              as _StorageLocation         on  $projection.StorageLocation = _StorageLocation.StorageLocation
  association [0..1] to I_PricingDateControlTxt        as _PricingDateControlTxt1  on  $projection.PricingDateControl   = _PricingDateControlTxt1.PricingDateControl
                                                                                   and _PricingDateControlTxt1.Language = $session.system_language
  association [0..1] to I_Product                      as _Product                 on  $projection.Material = _Product.Product
  association [0..1] to I_PurgInfoRecdOrgPlntDataApi01 as _PurgInfoRecdOrgPlntData on  $projection.PurchasingInfoRecord      = _PurgInfoRecdOrgPlntData.PurchasingInfoRecord
                                                                                   and $projection.PurchasingOrganization    = _PurgInfoRecdOrgPlntData.PurchasingOrganization
                                                                                   and $projection.PurchaseOrderItemCategory = _PurgInfoRecdOrgPlntData.PurchasingInfoRecordCategory
                                                                                   and $projection.Plant                     = _PurgInfoRecdOrgPlntData.Plant
  association [0..1] to I_PricingDateControlTxt        as _PricingDateControlTxt2  on  $projection.PricingDateControl2  = _PricingDateControlTxt2.PricingDateControl
                                                                                   and _PricingDateControlTxt2.Language = $session.system_language
{

  key _PurchaseOrder.PurchaseOrder,
  key _PurchaseOrderItem.PurchaseOrderItem,
      _PurchaseOrder.CompanyCode,
      _PurchaseOrder.PurchasingOrganization,
      _PurchaseOrder.PurchasingGroup,
      _PurchaseOrder.Supplier,
      _PurchaseOrder.DocumentCurrency,
      _PurchaseOrder.PurchaseOrderDate,

      _PurchaseOrderItem.PurchaseOrderItemCategory,
      _PurchaseOrderItem.Material,
      _PurchaseOrderItem.PurchaseOrderItemText,
      _PurchaseOrderItem.SupplierMaterialNumber,
      _PurchaseOrderItem.OrderQuantity,
      _PurchaseOrderItem.PurchaseOrderQuantityUnit,
      _PurchaseOrderItem.NetPriceAmount,
      _PurchaseOrderItem.NetPriceQuantity,
      _PurchaseOrderItem.Plant,
      _PurchaseOrderItem.StorageLocation,
      // _PurchaseOrderItem.PurchasingInfoRecord,
      _PurInfoRecord.PurchasingInfoRecord,
      _PurchaseOrderItem.PricingDateControl                                        as PricingDateControl,
      _PurchaseOrderItem.PurgDocPriceDate,
      _PurchaseOrderItem.IsCompletelyDelivered,

      _PurgInfoRecdOrgPlntData.PricingDateControl                                  as PricingDateControl2,
      _PurgInfoRecdOrgPlntData.Currency,

      concat( _PurchaseOrder.PurchaseOrder, _PurchaseOrderItem.PurchaseOrderItem ) as PurchaseOrderStr,

      case when _PurgInfoRecdOrgPlntData.PricingDateControl = '1'
           then _PurchaseOrder.PurchaseOrderDate
           when _PurgInfoRecdOrgPlntData.PricingDateControl = '2'
           then _PurOrdScheduleLine.ScheduleLineDeliveryDate
           else _PurchaseOrderItem.PurgDocPriceDate end                            as PriceDate,

      _PurOrdScheduleLine,
      _PurchasingGroup,
      _BusinessPartner,
      _StorageLocation,
      _PricingDateControlTxt1,
      _Product,
      _PurgInfoRecdOrgPlntData,
      _PricingDateControlTxt2
}
