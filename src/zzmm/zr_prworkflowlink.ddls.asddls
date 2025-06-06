@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Requisition Workflow'

define root view entity ZR_PRWORKFLOWLINK
  as select from ztmm_1006
    inner join   ZR_PRWORKFLOW_SUM on  ztmm_1006.apply_depart = ZR_PRWORKFLOW_SUM.ApplyDepart_sum
                                   and ztmm_1006.pr_no        = ZR_PRWORKFLOW_SUM.PrNo_sum

  //association [0..*] to ZR_WF_ApprovalHistory as _ApprovalHistory on  ztmm_1006.workflow_id    = _ApprovalHistory.WorkflowId
  //                                                                and ztmm_1006.instance_id    = _ApprovalHistory.InstanceId
  //                                                                and ztmm_1006.application_id = _ApprovalHistory.ApplicationId
  association [0..1] to ZC_WF_PrType_VH   as _PrType          on $projection.PrType = _PrType.Zvalue1
  association [0..1] to ZC_WF_Location_VH as _Kyoten          on $projection.Kyoten = _Kyoten.Zvalue1

  // ADD BEGIN BY XINLEI XU 2025/02/24
  association [0..*] to ZC_TMM_1012       as _Attachment      on $projection.UUID = _Attachment.PrUuid
  // ADD END BY XINLEI XU 2025/02/24

  // ADD BEGIN BY XINLEI XU 2025/05/07 CR#4359
  association [0..1] to I_PurchasingGroup as _PurchasingGroup on $projection.PurchaseGrp = _PurchasingGroup.PurchasingGroup
  // ADD END BY XINLEI XU 2025/05/07 CR#4359
{
  key ztmm_1006.uuid                           as UUID,
      ztmm_1006.apply_depart                   as ApplyDepart,
      ztmm_1006.pr_no                          as PrNo,
      ztmm_1006.pr_item                        as PrItem,
      ztmm_1006.pr_type                        as PrType,
      ztmm_1006.order_type                     as OrderType,
      ztmm_1006.supplier                       as Supplier,
      ztmm_1006.company_code                   as CompanyCode,
      ztmm_1006.purchase_org                   as PurchaseOrg,
      ztmm_1006.purchase_grp                   as PurchaseGrp,
      ztmm_1006.plant                          as Plant,
      ztmm_1006.currency                       as Currency,
      ztmm_1006.item_category                  as ItemCategory,
      ztmm_1006.account_type                   as AccountType,
      ztmm_1006.mat_id                         as MatID,
      ztmm_1006.mat_desc                       as MatDesc,
      ztmm_1006.material_group                 as MaterialGroup,
      ztmm_1006.quantity                       as Quantity,
      ztmm_1006.unit                           as Unit,
      ztmm_1006.price                          as Price,
      ztmm_1006.unit_price                     as UnitPrice,
      ztmm_1006.delivery_date                  as DeliveryDate,
      ztmm_1006.location                       as Location,
      ztmm_1006.return_item                    as ReturnItem,
      ztmm_1006.free                           as Free,
      ztmm_1006.gl_account                     as GlAccount,
      ztmm_1006.cost_center                    as CostCenter,
      ztmm_1006.wbs_elemnt                     as WbsElemnt,
      ztmm_1006.asset_no                       as AssetNo,
      ztmm_1006.tax                            as Tax,
      ztmm_1006.item_text                      as ItemText,
      ztmm_1006.pr_by                          as PrBy,
      ztmm_1006.track_no                       as TrackNo,
      ztmm_1006.ean                            as Ean,
      ztmm_1006.customer_rec                   as CustomerRec,
      ztmm_1006.asset_ori                      as AssetOri,
      ztmm_1006.memo_text                      as MemoText,
      ztmm_1006.buy_purpoose                   as BuyPurpoose,
      ztmm_1006.is_link                        as IsLink,
      ztmm_1006.approve_status                 as ApproveStatus,
      ztmm_1006.purchase_order                 as PurchaseOrder,
      ztmm_1006.purchase_order_item            as PurchaseOrderItem,
      ztmm_1006.kyoten                         as Kyoten,
      ztmm_1006.is_approve                     as IsApprove,
      ztmm_1006.document_info_record_doc_type  as DocumentInfoRecordDocType,
      ztmm_1006.document_info_record_doc_numbe as DocumentInfoRecordDocNumber,
      ztmm_1006.document_info_record_doc_versi as DocumentInfoRecordDocVersion,
      ztmm_1006.document_info_record_doc_part  as DocumentInfoRecordDocPart,
      ztmm_1006.apply_date                     as ApplyDate,
      ztmm_1006.apply_time                     as ApplyTime,
      ztmm_1006.created_at                     as CreatedAt,
      @Semantics.user.createdBy: true
      ztmm_1006.local_created_by               as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      ztmm_1006.local_created_at               as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      ztmm_1006.local_last_changed_by          as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      ztmm_1006.local_last_changed_at          as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      ztmm_1006.lat_cahanged_at                as LatCahangedAt,
      ZR_PRWORKFLOW_SUM.Amount_Sum             as AmountSum,
      ztmm_1006.workflow_id                    as WorkflowId,
      ztmm_1006.instance_id                    as InstanceId,
      ztmm_1006.application_id                 as ApplicationId,

      _PrType,
      _Kyoten,
      _Attachment,

      _PurchasingGroup // ADD BY XINLEI XU 2025/05/07 CR#4359
}
