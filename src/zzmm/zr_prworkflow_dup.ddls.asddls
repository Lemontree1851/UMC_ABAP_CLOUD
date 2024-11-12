@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Requisition Workflow'
define view entity ZR_PRWORKFLOW_dup 
  as select  from ztmm_1006
{

   key   apply_depart                           as ApplyDepart_dup,
   key   pr_no                                  as PrNo_dup,
   max(pr_item) as PrItem_dup
 

}
group by apply_depart , pr_no
