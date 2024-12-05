@EndUserText.label: '用于获取SO库存地点的表函数'
@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
//@ClientHandling.type: #CLIENT_INDEPENDENT
//@ClientHandling.algorithm: #NONE
define table function ZTF_SALESORDERSTORLOC
with parameters
  @Environment.systemField:#CLIENT
  clnt : mandt
returns {
  Client : abap.clnt;
  SalesDocument : vbeln_vl;
  SalesDocumentItem : abap.numc(6);
  StorageLocation : abap.char(4);
  
}
implemented by method ZCL_TF_BATCHCREATIONDN=>GET_STORLOC;