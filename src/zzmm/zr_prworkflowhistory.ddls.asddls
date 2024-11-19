@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Requisition Workflow'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_PRWORKFLOWHIstory
  as select from ztbc_1011 as ApprovalHistory
{
  key     workflow_id           as WorkflowId,
  key     instance_id           as InstanceId,
  key     zseq                  as Zseq,
  key     application_id        as ApplicationId,
  key     current_node          as CurrentNode,
  key     zseq                  as UserZseq,
          next_node             as NextNode,
          operator              as Operator,
          approval_status       as ApprovalStatus,
          remark                as Remark,
          created_by            as CreatedBy,
          created_at            as CreatedAt,
          last_changed_by       as LastChangedBy,
          last_changed_at       as LastChangedAt,
          local_last_changed_at as LocalLastChangedAt
}
where
  del is initial

union select from ztbc_1011             as ApprovalHistory
  join            ZR_WF_ApprovalUser    as _ApprovalUser on  ApprovalHistory.workflow_id    = _ApprovalUser.WorkflowId
                                                         and ApprovalHistory.application_id = _ApprovalUser.ApplicationId
                                                         and ApprovalHistory.next_node      = _ApprovalUser.Node
  join            ZR_PRWORKFLOW_HIstory as _HistoryMax   on  ApprovalHistory.workflow_id = _HistoryMax.WorkflowId
                                                         and ApprovalHistory.instance_id = _HistoryMax.InstanceId
                                                         and ApprovalHistory.zseq        = _HistoryMax.zseq_max
{
  key     ApprovalHistory.workflow_id                                                                              as WorkflowId,
  key     ApprovalHistory.instance_id                                                                              as InstanceId,
  key     ApprovalHistory.zseq                                                                                     as Zseq,
  key     ApprovalHistory.application_id                                                                           as ApplicationId,
  key     ApprovalHistory.next_node                                                                                as CurrentNode,
  key     _ApprovalUser.Zseq                                                                                     as UserZseq,
          ApprovalHistory.next_node                                                                                as NextNode,

          concat(     concat(_ApprovalUser.UserName,'(')      ,   concat(_ApprovalUser.EmailAddress,')')         ) as Operator,
          '等待审批'                                                                                                   as ApprovalStatus,
          '等待审批'                                                                                                   as Remark,
          ApprovalHistory.created_by                                                                               as CreatedBy,
          99991231000000.0000000                                                                                   as CreatedAt,
          ApprovalHistory.last_changed_by                                                                          as LastChangedBy,
          ApprovalHistory.last_changed_at                                                                          as LastChangedAt,
          ApprovalHistory.local_last_changed_at                                                                    as LocalLastChangedAt


}

where
      ApprovalHistory.next_node is not initial
  and ApprovalHistory.del       is initial
