@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow Approval Node'
define  root view entity ZR_PRWORKFLOW_HIstory

  as select from ztbc_1011 as ApprovalHistory
 {
  key workflow_id           as WorkflowId,
  key instance_id        as InstanceId,
  del,
  max(zseq) as zseq_max

}

group by
  workflow_id,
  instance_id,
  del
having del is initial
    

