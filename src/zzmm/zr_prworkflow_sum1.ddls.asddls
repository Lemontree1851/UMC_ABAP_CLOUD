@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Purchase Requisition Workflow SUM'
define view entity ZR_PRWORKFLOW_SUM1
  as select from ztmm_1006
{

  key     apply_depart as ApplyDepart_sum,
  key     pr_no        as PrNo_sum,
  currency,
      @Semantics.amount.currencyCode : 'currency'  
          sum(
          case when unit_price <> 0 then price * quantity / unit_price
          else 0
          end
          ) as Amount_Sum 

}
group by
  apply_depart,
  pr_no,
  currency
