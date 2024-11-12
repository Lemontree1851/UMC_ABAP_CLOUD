@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pur Info Record Header'
define root view entity ZR_PURINFORECORDUPDATE
  as select from ztmm_1004
  composition [0..*] of ZR_PURINFORECORDUPDATEITEM as _Item
{
  key uuid                           as UUID,
      purchasinginforecord           as PurchasingInfoRecord, //購買情報
      supplier                       as Supplier, //サプライヤ
      material                       as Material, //品目
      purchasingorganization         as PurchasingOrganization, //購買組織
      plant                          as Plant, //プラント
      purchasinginforecordcategory   as PurchasingInfoRecordCategory, //購買情報カテゴリ
      suppliermaterialnumber         as SupplierMaterialNumber, //仕入先品目コード
      suppliersubrange               as SupplierSubrange, //仕入先部門
      suppliermaterialgroup          as SupplierMaterialGroup, //仕入先品目Group
      suppliercertorigincountry      as SupplierCertOriginCountry, //原産国
      suppliercertoriginregion       as SupplierCertOriginRegion,  //地域(都道府県)
      suplrcertoriginclassfctnnumber as SuplrCertOriginClassfctnNumber, //番号
      purgdocorderquantityunit       as PurgDocOrderQuantityUnit, //発注単位
      orderitemqtytobaseqtydnmntr    as OrderItemQtyToBaseQtyDnmntr, //変換(分母)
      orderitemqtytobaseqtynmrtr     as OrderItemQtyToBaseQtyNmrtr,  //変換(分子)
      materialplanneddeliverydurn    as MaterialPlannedDeliveryDurn, //納入予定日数
      standardpurchaseorderquantity  as StandardPurchaseOrderQuantity, //標準購買発注数量
      minimumpurchaseorderquantity   as MinimumPurchaseOrderQuantity,  //最低発注数量
      shippinginstruction            as ShippingInstruction, //出荷指示
      unlimitedoverdeliveryisallowed as UnlimitedOverdeliveryIsAllowed, //過剰納入無制限
      invoiceisgoodsreceiptbased     as InvoiceIsGoodsReceiptBased, //入庫基準請求書
      supplierconfirmationcontrolkey as SupplierConfirmationControlKey, //確認管理
      taxcode                        as TaxCode,  //税コード
      currency                       as Currency, //通貨コード
      netpriceamount                 as NetPriceAmount, //正味価格
      materialpriceunitqty           as MaterialPriceUnitQty, //価格単位
      purchaseorderpriceunit         as PurchaseOrderPriceUnit, //購買発注価格単位
      ordpriceunittoorderunitdnmntr  as OrdPriceUnitToOrderUnitDnmntr, //変換(分母)
      orderpriceunittoorderunitnmrtr as OrderPriceUnitToOrderUnitNmrtr, //変換(分子)
      pricingdatecontrol             as PricingDateControl, //価格設定日制御
      incotermsclassification        as IncotermsClassification, //インコタームズ
      incotermslocation1             as IncotermsLocation1, //インコタームズ場所１
      incotermslocation2             as IncotermsLocation2, //インコタームズ場所２
      conditionvaliditystartdate     as ConditionValidityStartDate, //有効開始日
      pricevalidityenddate           as PriceValidityEndDate,   //有効終了日
      xflag                          as Xflag,  //スケータ単価有無
      status                         as Status, // ステータス
      message                        as Message, // メッセージ
      created_by                     as CreatedBy,
      created_at                     as CreatedAt,
      last_changed_by                as LastChangedBy,
      last_changed_at                as LastChangedAt,
      local_last_changed_at          as LocalLastChangedAt,

      /* associations */
      _Item
}
