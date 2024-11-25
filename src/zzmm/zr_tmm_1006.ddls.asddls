@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTMM_1006'
define root view entity ZR_TMM_1006
  as select from ztmm_1006
  association [0..1] to ZC_WF_PrType_VH         as _PrTypeText         on  $projection.PrType = _PrTypeText.Zvalue1
  association [0..1] to ZC_WF_ApplyDepart_VH    as _ApplyDepartText    on  $projection.ApplyDepart = _ApplyDepartText.Zvalue1
  association [0..1] to ztbc_1001               as _OrderTypeText      on  $projection.OrderType = _OrderTypeText.zvalue1
                                                                       and _OrderTypeText.zid    = 'ZMM003'
  association [0..1] to ztbc_1001               as _BuyPurposeText     on  $projection.BuyPurpoose = _BuyPurposeText.zvalue1
                                                                       and _BuyPurposeText.zid     = 'ZMM002'
  association [0..1] to ZC_WF_Location_VH       as _KyotenText         on  $projection.Kyoten = _KyotenText.Zvalue1
  association [0..1] to ZC_WF_ApprovalStatus_VH as _ApprovalStatusText on  $projection.ApproveStatus = _ApprovalStatusText.Zvalue1
{
  key uuid                                   as UUID,
      apply_depart                           as ApplyDepart,
      pr_no                                  as PrNo,
      pr_item                                as PrItem,
      pr_type                                as PrType,
      order_type                             as OrderType,
      supplier                               as Supplier,
      company_code                           as CompanyCode,
      purchase_org                           as PurchaseOrg,
      purchase_grp                           as PurchaseGrp,
      plant                                  as Plant,
      currency                               as Currency,
      item_category                          as ItemCategory,
      account_type                           as AccountType,
      mat_id                                 as MatID,
      mat_desc                               as MatDesc,
      material_group                         as MaterialGroup,
      quantity                               as Quantity,
      unit                                   as Unit,
      price                                  as Price,
      unit_price                             as UnitPrice,
      delivery_date                          as DeliveryDate,
      location                               as Location,
      return_item                            as ReturnItem,
      free                                   as Free,
      gl_account                             as GlAccount,
      cost_center                            as CostCenter,
      wbs_elemnt                             as WbsElemnt,
      asset_no                               as AssetNo,
      tax                                    as Tax,
      item_text                              as ItemText,
      pr_by                                  as PrBy,
      track_no                               as TrackNo,
      ean                                    as Ean,
      customer_rec                           as CustomerRec,
      asset_ori                              as AssetOri,
      memo_text                              as MemoText,
      buy_purpoose                           as BuyPurpoose,
      is_link                                as IsLink,
      approve_status                         as ApproveStatus,
      purchase_order                         as PurchaseOrder,
      purchase_order_item                    as PurchaseOrderItem,
      kyoten                                 as Kyoten,
      is_approve                             as IsApprove,
      supplier_mat                           as SupplierMat,
      polink_by                              as PolinkBy,
      document_info_record_doc_type          as DocumentInfoRecordDocType,
      document_info_record_doc_numbe         as DocumentInfoRecordDocNumber,
      document_info_record_doc_versi         as DocumentInfoRecordDocVersion,
      document_info_record_doc_part          as DocumentInfoRecordDocPart,
      apply_date                             as ApplyDate,
      apply_time                             as ApplyTime,
      created_at                             as CreatedAt,
      @Semantics.user.createdBy: true
      local_created_by                       as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at                       as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by                  as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                  as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      lat_cahanged_at                        as LatCahangedAt,
      cast('' as bapi_mtype preserving type) as Type,
      cast('' as abap.sstring(256))          as ResultText,
      cast('' as abap.sstring(1033))         as Message,
      workflow_id                            as WorkflowId,
      instance_id                            as InstanceId,
      application_id                         as ApplicationId,
      _ApplyDepartText.Zvalue2               as ApplyDepartText,
      _PrTypeText.Zvalue2                    as PrTypeText,
      _OrderTypeText.zvalue3                 as OrderTypeText,
      _BuyPurposeText.zvalue3                as BuyPurposeText,
      _KyotenText.Zvalue2                    as KyotenText,
      _ApprovalStatusText.Zvalue2            as ApproveStatusText

}
