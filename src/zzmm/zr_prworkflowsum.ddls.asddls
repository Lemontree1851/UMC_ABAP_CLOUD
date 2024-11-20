@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Purchase Requisition Workflow SUM'
define root view entity ZR_PRWORKFLOWSUM
  as select from ZR_PRWORKFLOW_dup  
    inner join   ZR_PRWORKFLOW_SUM on  ZR_PRWORKFLOW_dup.ApplyDepart_dup = ZR_PRWORKFLOW_SUM.ApplyDepart_sum
                                   and ZR_PRWORKFLOW_dup.PrNo_dup     = ZR_PRWORKFLOW_SUM.PrNo_sum
{

  key   ZR_PRWORKFLOW_dup.ApplyDepart_dup       as ApplyDepart,
  key   ZR_PRWORKFLOW_dup.PrNo_dup              as PrNo,
        ZR_PRWORKFLOW_SUM.currency             as Currency,
        ZR_PRWORKFLOW_SUM.Amount_Sum as AmountSum

}
