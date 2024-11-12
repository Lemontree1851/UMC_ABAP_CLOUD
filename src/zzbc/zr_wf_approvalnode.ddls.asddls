@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow Approval Node'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WF_ApprovalNode
  as select from ztbc_1009 as _ApprovalNode

  association to parent ZR_WF_ApprovalPath as _ApprovalPath on  $projection.WorkflowId    = _ApprovalPath.WorkflowId
                                                            and $projection.ApplicationId = _ApprovalPath.ApplicationId
  composition [0..*] of ZR_WF_ApprovalUser as _ApprovalUser
{
  key workflow_id           as WorkflowId,
  key application_id        as ApplicationId,
  key node                  as Node,
      node_name             as NodeName,
      auto_conver           as AutoConver,
      active                as Active,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _ApprovalPath,
      _ApprovalUser
}
