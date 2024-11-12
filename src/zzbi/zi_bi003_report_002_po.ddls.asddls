@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 002 PO Info'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_REPORT_002_PO
  with parameters
    p_recover_type :ze_recycle_type
  as select from    I_PurchaseOrderItemAPI01 as poitem
    inner join      ZR_TBI_RECY_INFO001      as recy    on  poitem.InternationalArticleNumber = recy.RecoveryManagementNumber
                                                        and poitem.CompanyCode                = recy.CompanyCode
                                                        and recy.RecoveryType                 = $parameters.p_recover_type
    left outer join I_Product                as Product on Product.Product = poitem.Material


  association [1]    to I_CompanyCode             as _CompanyCode      on  _CompanyCode.CompanyCode = $projection.CompanyCode

  association [0..1] to I_ProductText             as _ProductText      on  _ProductText.Product  = $projection.Material
                                                                       and _ProductText.Language = $session.system_language
  association [0..1] to ZI_PO_101_MATDOC_LASTEST  as _LastMatdoc       on  _LastMatdoc.PurchaseOrder     = $projection.PurchaseOrder
                                                                       and _LastMatdoc.PurchaseOrderItem = $projection.PurchaseOrderItem
  association [0..1] to ZI_PO_101_MATDOC_WITH_REV as _Matdoc           on  _Matdoc.CombineKey = $projection.combinekey
  association [0..1] to ZI_BI003_OLD_MATERIAL     as _OldMaterial      on  _OldMaterial.Material = $projection.ProductOldID
  association [0..1] to I_ProfitCenterText        as _ProfitCenterText on  _ProfitCenterText.ProfitCenter      = $projection.ProfitCenter
                                                                       and _ProfitCenterText.Language          = $session.system_language
                                                                       and _ProfitCenterText.ValidityStartDate <= $session.system_date
                                                                       and _ProfitCenterText.ValidityEndDate   >= $session.system_date
{
  key poitem.PurchaseOrder,
  key poitem.PurchaseOrderItem,
      poitem.InternationalArticleNumber as RecoveryManagementNumber,
      poitem.DocumentCurrency,
      //poitem.BaseUnit,

      // in order to fix the po unit and keep ui5 app not changed, use alias baseunit
      poitem.PurchaseOrderQuantityUnit  as BaseUnit,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      poitem.OrderQuantity,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      poitem.NetPriceAmount,

      poitem.CompanyCode,
      poitem.Material,
      poitem.ProfitCenter,

      poitem._PurchaseOrder,
      poitem._PurOrdAcctAssignment,


      Product.ProductOldID,


      _LastMatdoc.CombineKey,
      _Matdoc,
      _OldMaterial,

      _ProductText,
      _CompanyCode,
      _ProfitCenterText
}
