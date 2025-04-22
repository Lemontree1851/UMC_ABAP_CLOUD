@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_PRWORKFLOWITEM '
define root view entity ZC_PRWORKFLOWITEM
  provider contract transactional_query
  as projection on ZR_PRWORKFLOWITEM
{
  key UUID,
      @EndUserText.label: 'ステータス'
      ApplyDepart,
      PrNo,
      PrItem,
      Supplier,
      Currency,
      MatID,
      MatDesc,
      MaterialGroup,
      Quantity,
      Unit,
      Price,
      UnitPrice,
      DeliveryDate,
      Location,
      GlAccount,
      CostCenter,
      WbsElemnt,
      OrderId,
      AssetNo,
      Tax,
      ItemText,
      Ean,
      CustomerRec,
      AssetOri,
      MemoText,
      BuyPurpoose,
      @EndUserText.label: '購入目的テキスト'
      @Consumption.filter.hidden: true
      BuyPurposeText,
      amount1,
      zattachment,

      // ADD BEGIN BY XINLEI XU 2025/04/23 CR#4359
      CompanyCode,
      NetPrice,
      _Supplier.SupplierName,
      CostCenterName,
      GLAccountName
      // ADD END BY XINLEI XU 2025/04/23 CR#4359
}
