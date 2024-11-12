@EndUserText.label: 'Workflow Approval Node'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_WF_ApprovalNode
  as projection on ZR_WF_ApprovalNode
{
  key WorkflowId,
  key ApplicationId,
  key Node,
      NodeName,
      AutoConver,
      Active,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _ApprovalPath : redirected to parent ZC_WF_ApprovalPath,
      _ApprovalUser : redirected to composition child ZC_WF_ApprovalUser
}
