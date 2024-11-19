@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow Approval History'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_WF_ApprovalHistory
  as select from ztbc_1011 as ApprovalHistory
{
  key workflow_id           as WorkflowId,
  key instance_id           as InstanceId,
  key zseq                  as Zseq,
      application_id        as ApplicationId,
      current_node          as CurrentNode,
      next_node             as NextNode,
      operator              as Operator,
      approval_status       as ApprovalStatus,
      remark                as Remark,
      email_address         as EmailAddress,
      del                   as Del,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
