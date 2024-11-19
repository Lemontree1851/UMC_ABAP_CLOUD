@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Purchase Requisition Workflow SUM'
define view entity ZR_PRWORKFLOW_SUM
  as select from ztmm_1006
{

  key     apply_depart as ApplyDepart_sum,
  key     pr_no        as PrNo_sum,
          sum( case when unit_price <> 0
                  then price * quantity / unit_price
                  else 0
               end )   as amount_sum

}
group by
  apply_depart,
  pr_no
