@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pur Info Record Item'
define view entity ZR_PURINFORECORDITEM
  as select from ztmm_1005
  association to parent ZR_PURINFORECORDHEADER as _Header on $projection.UUID = _Header.UUID
{
  key uuid                         as UUID,
      supplier                     as Supplier, //サプライヤ
      material                     as Material, //品目
      purchasingorganization       as PurchasingOrganization, //購買組織
      plant                        as Plant, //プラント
      purchasinginforecordcategory as PurchasingInfoRecordCategory, //購買情報カテゴリ
      conditionvaliditystartdate   as ConditionValidityStartDate,   //有効開始日
      conditionvalidityenddate     as ConditionValidityEndDate,     //有効終了日
      conditionscalequantity       as ConditionScaleQuantity, //スケール数量
      conditionscaleamount         as ConditionScaleAmount, //スケール金額
      conditionscaleamountcurrency as ConditionScaleAmountCurrency,
      conditionscalequantityunit   as ConditionScaleQuantityUnit,
      
      /* associations */
      _Header

}
