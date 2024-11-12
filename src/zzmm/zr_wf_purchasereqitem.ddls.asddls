@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Requisition Workflow'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WF_PURCHASEREQitem
  as select distinct from ztmm_1006 
    association to parent ZR_WF_PURCHASEREQ as _WF_PURCHASEREQ on  $projection.ApplyDepart    =  _WF_PURCHASEREQ.ApplyDepart
                                                               and $projection.PrNo =  _WF_PURCHASEREQ.PrNo
                                                            
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
      _WF_PURCHASEREQ
      }
