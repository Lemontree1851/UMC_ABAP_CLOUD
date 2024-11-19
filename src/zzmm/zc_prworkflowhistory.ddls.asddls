@EndUserText.label: 'Workflow Approval History'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_PRWORKFLOWhistory
  provider contract transactional_query
  as projection on ZR_PRWORKFLOWHIstory
{
  key     WorkflowId,
  key     InstanceId,
  key     Zseq,
  key     ApplicationId,
  key     CurrentNode,
  key     UserZseq,
          NextNode,
          Operator,
          ApprovalStatus,
          Remark,
          CreatedBy,
          CreatedAt,
          LastChangedBy,
          LastChangedAt,
          LocalLastChangedAt
}
