@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '已交货的SO数量'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZR_DELIVERYEDQTY
  as select from    I_SalesOrder                   as vbak
    left outer join I_SalesOrderItem               as vbap   on vbak.SalesOrder = vbap.SalesOrder
    left outer join I_SDDocumentMultiLevelProcFlow as SOFlow on vbak.SalesOrder                       =  SOFlow.PrecedingDocument
                                                             and(
                                                               (
                                                                 (
                                                                   vbak.SalesOrderType                =  'SO-4'
                                                                   or vbak.SalesOrderType             =  'SO-8'
                                                                 )
                                                                 and SOFlow.PrecedingDocumentCategory =  'T'
                                                               )
                                                               or(
                                                                 (
                                                                   vbak.SalesOrderType                <> 'SO-4'
                                                                   and vbak.SalesOrderType            <> 'SO-8'
                                                                 )
                                                                 and SOFlow.PrecedingDocumentCategory =  'J'
                                                               )
                                                             )
{
  SOFlow.PrecedingDocument                as SalesOrder,
  SOFlow.PrecedingDocumentItem            as SalesOrderItem,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  sum(SOFlow.QuantityInBaseUnit)          as DeliveredQuantity,
  SOFlow.BaseUnit
}
group by
  SOFlow.PrecedingDocument,
  SOFlow.PrecedingDocumentItem,
  SOFlow.BaseUnit
