@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Requisition Workflow'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_WF_PURCHASEREQ
  as select distinct from ztmm_1006
  composition [0..*] of ZR_WF_PURCHASEREQitem as _WF_PURCHASEREQitem
{
 
  key   apply_depart as ApplyDepart,
  key   pr_no        as PrNo,

        pr_type      as PrType,
        apply_date   as ApplyDate,
        apply_time   as ApplyTime,
        pr_by        as PrBy,
        purchase_org as PurchaseOrg,
        kyoten       as Kyoten ,
         _WF_PURCHASEREQitem

       
}
