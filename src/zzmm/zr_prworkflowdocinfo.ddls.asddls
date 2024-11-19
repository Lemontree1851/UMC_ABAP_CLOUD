@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Requisition Workflow Doc Info'
define root view entity  ZR_PRWORKFLOWDOCINFO
  as select from I_DocumentInfoRecord
{
  key DocumentInfoRecordDocType,
  key DocumentInfoRecordDocNumber,
  key DocumentInfoRecordDocVersion,
  key DocumentInfoRecordDocPart,
  DocumentInfoRecord,
  _DocDesc[1:Language = $session.system_language].DocumentDescription        as DocumentDescription,
  ExternalDocumentStatus,
  _DocStatus._Text[1:Language = $session.system_language].DocumentStatusName as DocumentStatusName,
  DocInfoRecdIsMarkedForDeletion
}
