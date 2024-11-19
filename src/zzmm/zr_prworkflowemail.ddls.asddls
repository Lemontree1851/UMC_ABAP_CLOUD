@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Requisition Workflow'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_PRWORKFLOWEMAIL
  as select from ztbc_1011             as ApprovalHistory
    join         ZR_WF_ApprovalUser    as _ApprovalUser on  ApprovalHistory.workflow_id    = _ApprovalUser.WorkflowId
                                                        and ApprovalHistory.application_id = _ApprovalUser.ApplicationId
                                                        and ApprovalHistory.next_node      = _ApprovalUser.Node
    join         ZR_PRWORKFLOW_HIstory as _HistoryMax   on  ApprovalHistory.workflow_id = _HistoryMax.WorkflowId
                                                        and ApprovalHistory.instance_id = _HistoryMax.InstanceId
                                                        and ApprovalHistory.zseq        = _HistoryMax.zseq_max
{
  key     ApprovalHistory.workflow_id    as WorkflowId,
  key     ApprovalHistory.instance_id    as InstanceId,
  key     ApprovalHistory.zseq           as Zseq,
  key     _ApprovalUser.Zseq as UserZseq,
          ApprovalHistory.application_id as ApplicationId,
          _ApprovalUser.EmailAddress     as EmailAddress


}
where ApprovalHistory.del is initial
