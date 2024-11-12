@EndUserText.label: 'Workflow Approval User'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_WF_ApprovalUser
  as projection on ZR_WF_ApprovalUser
{
  key WorkflowId,
  key ApplicationId,
  key Node,
  key Zseq,
      UserName,
      EmailAddress,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _ApprovalPath : redirected to ZC_WF_ApprovalPath,
      _ApprovalNode : redirected to parent ZC_WF_ApprovalNode
}
