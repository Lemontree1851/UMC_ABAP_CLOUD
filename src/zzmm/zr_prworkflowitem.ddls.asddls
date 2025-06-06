@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Requisition Workflow'
define root view entity ZR_PRWORKFLOWITEM
  as select from ztmm_1006
  association [0..1] to ztbc_1001  as _BuyPurposeText on  $projection.BuyPurpoose = _BuyPurposeText.zvalue1
                                                      and _BuyPurposeText.zid     = 'ZMM002'

  // ADD BEGIN BY XINLEI XU 2025/04/22 CR#4359
  association [0..1] to I_Supplier as _Supplier       on  $projection.Supplier = _Supplier.Supplier
  // ADD END BY XINLEI XU 2025/04/22 CR#4359
{
  key uuid                                            as UUID,
      apply_depart                                    as ApplyDepart,
      pr_no                                           as PrNo,
      pr_item                                         as PrItem,
      pr_type                                         as PrType,
      order_type                                      as OrderType,
      supplier                                        as Supplier,
      company_code                                    as CompanyCode,
      purchase_org                                    as PurchaseOrg,
      purchase_grp                                    as PurchaseGrp,
      plant                                           as Plant,
      currency                                        as Currency,
      item_category                                   as ItemCategory,
      account_type                                    as AccountType,
      mat_id                                          as MatID,
      mat_desc                                        as MatDesc,
      material_group                                  as MaterialGroup,
      quantity                                        as Quantity,
      unit                                            as Unit,
      @Semantics.amount.currencyCode : 'currency'
      case currency
      when 'JPY' then price / 100
      else price
      end                                             as Price,
      unit_price                                      as UnitPrice,
      delivery_date                                   as DeliveryDate,
      location                                        as Location,
      return_item                                     as ReturnItem,
      free                                            as Free,
      gl_account                                      as GlAccount,
      cost_center                                     as CostCenter,
      wbs_elemnt                                      as WbsElemnt,
      order_id                                        as OrderId,
      asset_no                                        as AssetNo,
      tax                                             as Tax,
      item_text                                       as ItemText,
      pr_by                                           as PrBy,
      track_no                                        as TrackNo,
      ean                                             as Ean,
      customer_rec                                    as CustomerRec,
      asset_ori                                       as AssetOri,
      memo_text                                       as MemoText,
      buy_purpoose                                    as BuyPurpoose,
      is_link                                         as IsLink,
      approve_status                                  as ApproveStatus,
      purchase_order                                  as PurchaseOrder,
      purchase_order_item                             as PurchaseOrderItem,
      kyoten                                          as Kyoten,
      is_approve                                      as IsApprove,
      document_info_record_doc_type                   as DocumentInfoRecordDocType,
      document_info_record_doc_numbe                  as DocumentInfoRecordDocNumber,
      document_info_record_doc_versi                  as DocumentInfoRecordDocVersion,
      document_info_record_doc_part                   as DocumentInfoRecordDocPart,
      apply_date                                      as ApplyDate,
      apply_time                                      as ApplyTime,
      created_at                                      as CreatedAt,
      @Semantics.user.createdBy: true
      local_created_by                                as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at                                as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by                           as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                           as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      lat_cahanged_at                                 as LatCahangedAt,
      cast('' as bapi_mtype preserving type)          as Type,
      cast('' as abap.sstring(256))                   as ResultText,
      cast('' as abap.sstring(1033))                  as Message,
      _BuyPurposeText.zvalue3                         as BuyPurposeText,
      @Semantics.amount.currencyCode : 'currency'
      case currency
      when 'JPY' then
      (case when unit_price <> 0
                  then price * quantity / unit_price
                  else 0 end  ) / 100
      else
            (case when unit_price <> 0
                  then price * quantity / unit_price
                  else 0 end  )

               end                                    as amount1,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ATTACHMENT'
      @EndUserText.label: '添付ファイル'
      cast( '' as abap.sstring(4)  )                  as zattachment,

      // ADD BEGIN BY XINLEI XU 2025/04/23 CR#4359
      cast( price / unit_price as abap.dec( 18, 5 ) ) as NetPrice,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ATTACHMENT'
      cast( '' as abap.char(20) )                     as CostCenterName,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ATTACHMENT'
      cast( '' as abap.char(20) )                     as GLAccountName,
      // ADD END BY XINLEI XU 2025/04/23 CR#4359

      _Supplier
}
