@EndUserText.label: '用于创建DN的SO信息'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_SALESORDER_U
  provider contract transactional_query as projection on ZR_SALESORDER_U
//  association [1..1] to I_SalesOrderItemTextTP as _Text on _Text.SalesOrder = $projection.SalesOrder
//      and _Text.SalesOrderItem = $projection.SalesOrderItem
{
  key SalesDocument,
  key SalesDocumentItem,
      SalesOrganization,
      SalesOffice,
      SalesGroup,
      SalesDocumentType,
      YY1_SalesDocType_SDH, //受注伝票タイプ（Old）
      CreationDate,
      ShippingPoint,
      ShippingPointName,
      SoldToParty,
      CustomerName,
      BillingToParty,
      BillingToPartyName,
      ShipToParty,
      ShipToPartyName,
      PurchaseOrderByCustomer,
      UnderlyingPurchaseOrderItem,
      DeliveryBlockReason,
      DeliveryBlockReasonText,
      Material,
      MaterialByCustomer,
      Plant,
      TransitPlant,
      StorageLocation,
      StorageLocationName,
      Route,
      ShippingType,
      ShippingTypeName,
      @EndUserText.label: '指定納入日付（明細）'
      RequestedDeliveryDate,
      @EndUserText.label: '計画出庫日付'
      DeliveryDate,
      OrderQuantity,
      OrderQuantityUnit,
      IncotermsClassification,
      @EndUserText.label: 'インコタームズ場所'
      IncotermsTransferLocation,
      @EndUserText.label: '確認済受注数'
      ConfdOrderQty,
      @EndUserText.label: 'DN作成済数量'
      DeliveredQty,
      @EndUserText.label: '受注残数'
      RemainingQty,
      @EndUserText.label: '今回納品数'
      CurrDeliveryQty,
      @EndUserText.label: '今回保管場所'
      CurrStorageLocation,
      @EndUserText.label: '今回出荷タイプ'
      CurrShippingType,
      @EndUserText.label: '今回計画出庫日付'
      CurrPlannedGoodsIssueDate,
      @EndUserText.label: '今回納入日付'
      CurrDeliveryDate,
      @EndUserText.label: '今回出荷伝票'
      DeliveryDocument,
      @EndUserText.label: '出荷伝票明細'
      DeliveryDocumentItem,
      _Text.LongText,
      @EndUserText.label: 'ステータス'
      Type,
      @EndUserText.label: '結果'
      Status,
      @EndUserText.label: 'メッセージ'
      Message,
      Language
}
