@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTMM_1006'
define root view entity ZR_TMM_1006
  as select from ztmm_1006            as _main
    inner join   ZR_TBC1012           as _AssignCompany     on _AssignCompany.CompanyCode = _main.company_code
    inner join   ZR_TBC1006           as _AssignPlant       on _AssignPlant.Plant = _main.plant
    inner join   ZR_TBC1017           as _AssignPurchaseOrg on _AssignPurchaseOrg.PurchasingOrganization = _main.purchase_org
    inner join   ZC_BusinessUserEmail as _User              on  _User.Email  = _AssignCompany.Mail
                                                            and _User.Email  = _AssignPurchaseOrg.Mail
                                                            and _User.Email  = _AssignPlant.Mail
                                                            and _User.UserID = $session.user
  association [0..1] to ZC_WF_PrType_VH              as _PrTypeText         on  $projection.PrType = _PrTypeText.Zvalue1
  association [0..1] to ZC_WF_ApplyDepart_VH         as _ApplyDepartText    on  $projection.ApplyDepart = _ApplyDepartText.Zvalue1

  // MOD BEGIN BY XINLEI XU 2025/05/14
  //  association [0..1] to ztbc_1001               as _OrderTypeText      on  $projection.OrderType = _OrderTypeText.zvalue1
  //                                                                       and _OrderTypeText.zid    = 'ZMM003'
  association [0..1] to I_PurchasingDocumentTypeText as _OrderTypeText      on  $projection.OrderType                     = _OrderTypeText.PurchasingDocumentType
                                                                            and _OrderTypeText.PurchasingDocumentCategory = 'F'
                                                                            and _OrderTypeText.Language                   = $session.system_language
  // MOD BEGIN BY XINLEI XU 2025/05/14

  association [0..1] to ztbc_1001                    as _BuyPurposeText     on  $projection.BuyPurpoose = _BuyPurposeText.zvalue1
                                                                            and _BuyPurposeText.zid     = 'ZMM002'
  association [0..1] to ZC_WF_Location_VH            as _KyotenText         on  $projection.Kyoten = _KyotenText.Zvalue1
  association [0..1] to ZC_WF_ApprovalStatus_VH      as _ApprovalStatusText on  $projection.ApproveStatus = _ApprovalStatusText.Zvalue1

  // ADD BEGIN BY XINLEI XU 2025/02/21
  association [0..*] to ZC_TMM_1012                  as _Attachment         on  $projection.UUID = _Attachment.PrUuid
  // ADD END BY XINLEI XU 2025/02/21

  // ADD BEGIN BY XINLEI XU 2025/04/22 CR#4359
  association [0..1] to I_Supplier                   as _Supplier           on  $projection.Supplier = _Supplier.Supplier
  association [0..1] to I_PurchasingGroup            as _PurchasingGroup    on  $projection.PurchaseGrp = _PurchasingGroup.PurchasingGroup
  association [0..1] to ZC_BusinessUserEmail         as _UserEmail          on  $projection.LocalCreatedBy = _UserEmail.UserID
  // ADD END BY XINLEI XU 2025/04/22 CR#4359
{
  key _main.uuid                                                                   as UUID,
      _main.apply_depart                                                           as ApplyDepart,
      _main.pr_no                                                                  as PrNo,
      _main.pr_item                                                                as PrItem,
      _main.pr_type                                                                as PrType,
      _main.order_type                                                             as OrderType,
      _main.supplier                                                               as Supplier,
      _main.company_code                                                           as CompanyCode,
      _main.purchase_org                                                           as PurchaseOrg,
      _main.purchase_grp                                                           as PurchaseGrp,
      _main.plant                                                                  as Plant,
      _main.currency                                                               as Currency,
      _main.item_category                                                          as ItemCategory,
      _main.account_type                                                           as AccountType,
      _main.mat_id                                                                 as MatID,
      _main.mat_desc                                                               as MatDesc,
      _main.material_group                                                         as MaterialGroup,
      _main.quantity                                                               as Quantity,
      _main.unit                                                                   as Unit,
      _main.price                                                                  as Price,
      _main.unit_price                                                             as UnitPrice,
      _main.delivery_date                                                          as DeliveryDate,
      @Consumption.valueHelpDefinition: [{  entity:{ name: 'I_StorageLocationStdVH', element: 'StorageLocation' },
                                            additionalBinding: [{ localElement: 'Plant', element: 'Plant', usage: #FILTER }] }]
      _main.location                                                               as Location,
      _main.return_item                                                            as ReturnItem,
      _main.free                                                                   as Free,
      _main.gl_account                                                             as GlAccount,
      _main.cost_center                                                            as CostCenter,
      _main.wbs_elemnt                                                             as WbsElemnt,
      _main.order_id                                                               as OrderId,
      _main.asset_no                                                               as AssetNo,
      _main.tax                                                                    as Tax,
      _main.item_text                                                              as ItemText,
      _main.pr_by                                                                  as PrBy,
      _main.track_no                                                               as TrackNo,
      _main.ean                                                                    as Ean,
      _main.customer_rec                                                           as CustomerRec,
      _main.asset_ori                                                              as AssetOri,
      _main.memo_text                                                              as MemoText,
      _main.buy_purpoose                                                           as BuyPurpoose,
      _main.is_link                                                                as IsLink,
      _main.approve_status                                                         as ApproveStatus,
      _main.purchase_order                                                         as PurchaseOrder,
      _main.purchase_order_item                                                    as PurchaseOrderItem,
      _main.kyoten                                                                 as Kyoten,
      _main.is_approve                                                             as IsApprove,
      _main.supplier_mat                                                           as SupplierMat,
      _main.polink_by                                                              as PolinkBy,
      _main.document_info_record_doc_type                                          as DocumentInfoRecordDocType,
      _main.document_info_record_doc_numbe                                         as DocumentInfoRecordDocNumber,
      _main.document_info_record_doc_versi                                         as DocumentInfoRecordDocVersion,
      _main.document_info_record_doc_part                                          as DocumentInfoRecordDocPart,
      _main.apply_date                                                             as ApplyDate,
      _main.apply_time                                                             as ApplyTime,
      _main.created_at                                                             as CreatedAt,
      @Semantics.user.createdBy: true
      _main.local_created_by                                                       as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      _main.local_created_at                                                       as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      _main.local_last_changed_by                                                  as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _main.local_last_changed_at                                                  as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      _main.lat_cahanged_at                                                        as LatCahangedAt,
      cast('' as bapi_mtype preserving type)                                       as Type,
      cast('' as abap.sstring(256))                                                as ResultText,
      cast('' as abap.sstring(1033))                                               as Message,
      _main.workflow_id                                                            as WorkflowId,
      _main.instance_id                                                            as InstanceId,
      _main.application_id                                                         as ApplicationId,
      _ApplyDepartText.Zvalue2                                                     as ApplyDepartText,
      _PrTypeText.Zvalue2                                                          as PrTypeText,
      // _OrderTypeText.zvalue3                                                       as OrderTypeText,
      _OrderTypeText.PurchasingDocumentTypeName                                    as OrderTypeText,
      _BuyPurposeText.zvalue3                                                      as BuyPurposeText,
      _KyotenText.Zvalue2                                                          as KyotenText,
      _ApprovalStatusText.Zvalue2                                                  as ApproveStatusText,

      // ADD BEGIN BY XINLEI XU 2025/04/21 CR#4359
      case when _main.is_link = '1'
           then concat( concat( _ApprovalStatusText.Zvalue2, '/' ), '連携要')
           else concat( concat( _ApprovalStatusText.Zvalue2, '/' ), '連携不要')
           end                                                                     as POLinkStatus,

      cast( _main.price / _main.unit_price  as abap.dec( 18, 5 ) )                 as NetPrice,
      cast( _main.quantity / _main.unit_price * _main.price as abap.dec( 18, 3 ) ) as Amount,
      // ADD END BY XINLEI XU 2025/04/21 CR#4359

      _Attachment,
      _Supplier,
      _PurchasingGroup,
      _UserEmail
}
