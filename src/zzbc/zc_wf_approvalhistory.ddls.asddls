@EndUserText.label: 'Workflow Approval History'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_WF_ApprovalHistory
  provider contract transactional_query
  as projection on ZR_WF_ApprovalHistory
{
  key WorkflowId,
  key InstanceId,
  key Zseq,
      ApplicationId,
      CurrentNode,
      NextNode,
      Operator,
      ApprovalStatus,
      Remark,
      EmailAddress,
      Del,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
