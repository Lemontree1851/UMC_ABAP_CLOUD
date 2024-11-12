@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Change'
define root view entity ZR_POCHANGE
  as select from ztmm_1007
{
  key uuid                           as UUID,
      purchaseorder                  as PurchaseOrder, //購買発注
      purchaseorderitem              as PurchaseOrderItem, //購買発注明細
      companycode                    as CompanyCode, //会社コード
      purchasingorganization         as PurchasingOrganization, //購買組織
      purchasinggroup                as PurchasingGroup, //購買グループ
      currency                       as Currency, //通貨
      purchasingdocumentdeletioncode as PurchasingDocumentDeletionCode, //削除フラグ
      accountassignmentcategory      as AccountAssignmentCategory, //勘定設定カテゴリ
      purchaseorderitemcategory      as PurchaseOrderItemCategory, //明細カテゴリ
      material                       as Material, //品目
      purchaseorderitemtext          as PurchaseOrderItemText, //テキスト(短)
      materialgroup                  as MaterialGroup, //品目グループ
      orderquantity                  as OrderQuantity, //発注数量
      schedulelinedeliverydate       as ScheduleLineDeliveryDate, //納入日付
      netpriceamount                 as NetPriceAmount, //正味発注価格
      orderpriceunit                 as OrderPriceUnit, //発注価格単位
      plant                          as Plant, //プラント
      storagelocation                as StorageLocation, //保管場所
      requisitionername              as RequisitionerName, //購買依頼者
      requirementtracking            as RequirementTracking, //購買依頼追跡番号
      isreturnitem                   as IsReturnItem, //返品明細
      internationalarticlenumber     as InternationalArticleNumber, //EAN/UPC
      discountinkindeligibility      as DiscountInKindEligibility, //無償品対象
      taxcode                        as TaxCode, //税コード
      iscompletelydelivered          as IsCompletelyDelivered, //納入完了
      pricingdatecontrol             as PricingDateControl, //価格設定日制御
      purgdocpricedate               as PurgDocPriceDate, //価格設定日
      glaccount                      as GLAccount, //GL勘定科目
      costcenter                     as CostCenter, //原価センタ
      masterfixedasset               as MasterFixedAsset, //資産
      fixedasset                     as FixedAsset, //資産補助番号
      orderid                        as OrderID, //指図
      wbselementinternalid_2         as WBSElementInternalID_2, //WBS要素
      longtext                       as LongText, //項目テキスト
      status                         as Status,  //ステータス
      message                        as Message, //メッセージ
      purchaseorderunit              as PurchaseOrderUnit, //Purchase Order Unit
      created_by                     as CreatedBy,
      created_at                     as CreatedAt,
      last_changed_by                as LastChangedBy,
      last_changed_at                as LastChangedAt,
      local_last_changed_at          as LocalLastChangedAt

}
