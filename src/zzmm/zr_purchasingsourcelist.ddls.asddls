@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchasing Source List'
define root view entity ZR_PURCHASINGSOURCELIST
  as select from ztmm_1001
{
  key uuid                    as UUID,
      material                as Material,                //品目
      plant                   as Plant,                   //プラント
      sourcelistrecord        as SourceListRecord,        //番号
      validitystartdate       as ValidityStartDate,       //有効開始日
      validityenddate         as ValidityEndDate,         //有効終了日
      supplier                as Supplier,                //サプライヤ
      purchasingorganization  as PurchasingOrganization,  //購買組織
      supplierisfixed         as SupplierIsFixed,         //固定供給元
      sourceofsupplyisblocked as SourceOfSupplyIsBlocked, //ブロック供給元
      mrpsourcingcontrol      as MrpSourcingControl,      //MRP区分
      xflag                   as Xflag,                   //用途
      status                  as Status,                  //ステータス
      message                 as Message,                 //メッセージ
      created_by              as CreatedBy,
      created_at              as CreatedAt,
      last_changed_by         as LastChangedBy,
      last_changed_at         as LastChangedAt,
      local_last_changed_at   as LocalLastChangedAt

}
