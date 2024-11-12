@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OF一覧照会'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define root view entity ZR_OFLIST
  as select from I_PlndIndepRqmtByIntKey as _Root
  association [0..*] to I_PlndIndepRqmtItemTP as _PIRItem           on  $projection.PlndIndepRqmtInternalID = _PIRItem.PlndIndepRqmtInternalID
  association [0..1] to I_CustomerMaterial_2  as _CustMat2          on  $projection.Product = _CustMat2.Product
  association [0..1] to I_ProductPlantBasic   as _ProductPlantBasic on  $projection.Product = _ProductPlantBasic.Product
                                                                    and $projection.Plant   = _ProductPlantBasic.Plant
//  association [0..*] to ztpp_1012 as _pp1012
//    on $projection.RequirementPlan = _pp1012.customer
//    and $projection.Product = _pp1012.material
//    and $projection.Plant = _pp1012.plant
//    and $projection.RequirementPlan = _pp1012.customer
//    and $projection.RequirementPlan = _pp1012.customer
{
  key _Root.PlndIndepRqmtInternalID,
      _Root.Product,
      _Root.Plant,
      _Root.MRPArea,
      _Root.PlndIndepRqmtType,
      _Root.PlndIndepRqmtVersion,
      _Root.RequirementPlan,
      _Root.RequirementSegment,
//      _Root.PlndIndepRqmtPeriod,
//      _Root.PeriodType,

      _PIRItem,
      _CustMat2,
      _ProductPlantBasic

      //  _CustMat2.MaterialByCustomer,
      //  _PlndIndepRqmtByIntKey.PlndIndepRqmtIsActive,
      //
      //  @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      //  _Root.PlannedQuantity,
      //  @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      //  _Root.WithdrawalQuantity,
      //  _Root.UnitOfMeasure,
      //  _Root.LastChangedByUser,
      //  _Root.LastChangeDate
}
