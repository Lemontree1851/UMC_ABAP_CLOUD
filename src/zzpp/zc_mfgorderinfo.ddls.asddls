@EndUserText.label: 'Manufacturing Order Infomation Report'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_MFGORDERINFO
  provider contract transactional_query
  as projection on ZR_MFGORDERINFO
{
  key      ManufacturingOrder,
           ProductionPlant,
           ProductionSupervisor,
           Material,
           _MaterialDescription.ProductDescription as MaterialDescription,
           ProductionVersion,
           MRPController,
           MfgOrderPlannedTotalQty,
           Batch,
           MfgOrderConfirmedYieldQty,
           ProductionUnit,
           MfgOrderPlannedStartDate,
           MfgOrderPlannedEndDate,
           SalesOrder,

           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MFGORDERINFO'
  virtual  StatusName   : abap.string,
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MFGORDERINFO'
  virtual  FinalVersion : abap.string,

           /* Associations */
           _MaterialDescription
}
