@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_PRWORKFLOWDOCINFO '
define root view entity ZC_PRWORKFLOWDOCINFO
  provider contract transactional_query
  as projection on ZR_PRWORKFLOWDOCINFO
{
  key DocumentInfoRecordDocType,
  key DocumentInfoRecordDocNumber,
  key DocumentInfoRecordDocVersion,
  key DocumentInfoRecordDocPart,
  DocumentInfoRecord,
  DocumentDescription,
  ExternalDocumentStatus,
  DocumentStatusName,
  DocInfoRecdIsMarkedForDeletion
}
