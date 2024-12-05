@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Requisition Workflow'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_PRWORKFLOWHIstory
  as select from    ztbc_1011 as ApprovalHistory
    left outer join ztbc_1009 as _ApprovalNode on  ApprovalHistory.workflow_id    = _ApprovalNode.workflow_id
                                               and ApprovalHistory.application_id = _ApprovalNode.application_id
                                               and ApprovalHistory.current_node   = _ApprovalNode.node
{
  key     ApprovalHistory.workflow_id                                                                                     as WorkflowId,
  key     ApprovalHistory.instance_id                                                                                     as InstanceId,
  key     ApprovalHistory.zseq                                                                                            as Zseq,
  key     ApprovalHistory.application_id                                                                                  as ApplicationId,
  key     ApprovalHistory.current_node                                                                                    as CurrentNode,
  key     ApprovalHistory.zseq                                                                                            as UserZseq,
          ApprovalHistory.next_node                                                                                       as NextNode,
          ApprovalHistory.operator                                                                                        as Operator,
          ApprovalHistory.approval_status                                                                                 as ApprovalStatus,
          ApprovalHistory.remark                                                                                          as Remark,

          ApprovalHistory.created_by                                                                                      as CreatedBy,
          ApprovalHistory.created_at                                                                                      as CreatedAt,
          ApprovalHistory.last_changed_by                                                                                 as LastChangedBy,
          ApprovalHistory.last_changed_at                                                                                 as LastChangedAt,
          ApprovalHistory.local_last_changed_at                                                                           as LocalLastChangedAt,
          ltrim(   concat(    ApprovalHistory.current_node      ,   concat( '-' ,_ApprovalNode.node_name)      ) , '0'  ) as nodename,
          cast(case ApprovalHistory.approval_status
          when '2' then
          concat('承認-', ltrim(   concat(    ApprovalHistory.current_node      ,   concat( '-' ,_ApprovalNode.node_name)      ) , '0'  ) )
          when '3' then
          concat('承認-', ltrim(   concat(    ApprovalHistory.current_node      ,   concat( '-' ,_ApprovalNode.node_name)      ) , '0'  ) )
          when '1' then
          concat('却下-', ltrim(   concat(    ApprovalHistory.current_node      ,   concat( '-' ,_ApprovalNode.node_name)      ) , '0'  ) )
          else
          ltrim(   concat(    ApprovalHistory.current_node      ,   concat( '-' ,_ApprovalNode.node_name)      ) , '0'  )
          end as abap.sstring(50)) 
          
                                                                                                                          as title
}
where
  ApprovalHistory.del is initial

union select from ztbc_1011             as ApprovalHistory
  join            ZR_WF_ApprovalUser    as _ApprovalUser on  ApprovalHistory.workflow_id    = _ApprovalUser.WorkflowId
                                                         and ApprovalHistory.application_id = _ApprovalUser.ApplicationId
                                                         and ApprovalHistory.next_node      = _ApprovalUser.Node
  join            ZR_PRWORKFLOW_HIstory as _HistoryMax   on  ApprovalHistory.workflow_id = _HistoryMax.WorkflowId
                                                         and ApprovalHistory.instance_id = _HistoryMax.InstanceId
                                                         and ApprovalHistory.zseq        = _HistoryMax.zseq_max
  left outer join ztbc_1009             as _ApprovalNode on  ApprovalHistory.workflow_id    = _ApprovalNode.workflow_id
                                                         and ApprovalHistory.application_id = _ApprovalNode.application_id
                                                         and ApprovalHistory.next_node      = _ApprovalNode.node
{
  key     ApprovalHistory.workflow_id                                                                                        as WorkflowId,
  key     ApprovalHistory.instance_id                                                                                        as InstanceId,
  key     ApprovalHistory.zseq                                                                                               as Zseq,
  key     ApprovalHistory.application_id                                                                                     as ApplicationId,
  key     ApprovalHistory.next_node                                                                                          as CurrentNode,
  key     _ApprovalUser.Zseq                                                                                                 as UserZseq,
          ApprovalHistory.next_node                                                                                          as NextNode,

          concat(     concat(_ApprovalUser.UserName,'(')      ,   concat(_ApprovalUser.EmailAddress,')')         )           as Operator,
          '0'                                                                                                                as ApprovalStatus,
          '承認待ち'                                                                                                             as Remark,
          ApprovalHistory.created_by                                                                                         as CreatedBy,
          99991231000000.0000000                                                                                             as CreatedAt,
          ApprovalHistory.last_changed_by                                                                                    as LastChangedBy,
          ApprovalHistory.last_changed_at                                                                                    as LastChangedAt,
          ApprovalHistory.local_last_changed_at                                                                              as LocalLastChangedAt,
          ltrim(       concat(    ApprovalHistory.next_node     ,   concat( '-' ,_ApprovalNode.node_name)         ) , '0'  ) as nodename,
          cast(concat('承認待ち-', ltrim(       concat(    ApprovalHistory.next_node     ,   concat( '-' ,_ApprovalNode.node_name)         ) , '0'  ) ) as abap.sstring(50))  as title

}

where
      ApprovalHistory.next_node is not initial
  and ApprovalHistory.del       is initial
