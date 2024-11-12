@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Old Material Info'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_OLD_MATERIAL
  as select from    ZI_MAT_101_MATDOC_LASTEST as MatDoc
    inner join      ZI_PO_101_MATDOC_WITH_REV as POMATDOC    on MatDoc.CombineKey = POMATDOC.CombineKey
    inner join      I_PurchaseOrderItemAPI01  as POITEM      on  POMATDOC.PurchaseOrder     = POITEM.PurchaseOrder
                                                             and POMATDOC.PurchaseOrderItem = POITEM.PurchaseOrderItem

    left outer join I_ProductText             as ProductText on  ProductText.Product  = POITEM.Material
                                                             and ProductText.Language = $session.system_language
{
  key MatDoc.CombineKey,
      POITEM.PurchaseOrder,
      POITEM.PurchaseOrderItem,
      POITEM.Material,
      POITEM._PurchaseOrder.PurchaseOrderType,
      POITEM._PurchaseOrder.CreationDate,
      POITEM.DocumentCurrency,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      POITEM.NetPriceAmount,

      ProductText.ProductName
}
where
     POITEM._PurchaseOrder.PurchaseOrderType = 'NB'
  or POITEM._PurchaseOrder.PurchaseOrderType = 'ZB20'
  or POITEM._PurchaseOrder.PurchaseOrderType = 'ZB21'
  or POITEM._PurchaseOrder.PurchaseOrderType = 'ZB30'
  or POITEM._PurchaseOrder.PurchaseOrderType = 'ZH90'
  or POITEM._PurchaseOrder.PurchaseOrderType = 'ZH91'
