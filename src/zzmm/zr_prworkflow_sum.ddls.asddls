@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Purchase Requisition Workflow SUM'
define view entity ZR_PRWORKFLOW_SUM
  as select from ztmm_1006
{

  key     apply_depart as ApplyDepart_sum,
  key     pr_no        as PrNo_sum,

          sum( price * quantity /  
          (
              case  unit_price
              when 0 then 1
              else unit_price
              end
          )
          )            as amount_sum

}
group by
  apply_depart,
  pr_no
