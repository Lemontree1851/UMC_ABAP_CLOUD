@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow Approval User'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WF_ApprovalUser
  as select from ztbc_1010 as _ApprovalUser

  association to parent ZR_WF_ApprovalNode as _ApprovalNode on  $projection.WorkflowId    = _ApprovalNode.WorkflowId
                                                            and $projection.ApplicationId = _ApprovalNode.ApplicationId
                                                            and $projection.Node          = _ApprovalNode.Node
  association to ZR_WF_ApprovalPath        as _ApprovalPath on  $projection.WorkflowId    = _ApprovalPath.WorkflowId
                                                            and $projection.ApplicationId = _ApprovalPath.ApplicationId
{
  key workflow_id           as WorkflowId,
  key application_id        as ApplicationId,
  key node                  as Node,
  key zseq                  as Zseq,
      user_name             as UserName,
      email_address         as EmailAddress,
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
      _ApprovalNode
}
