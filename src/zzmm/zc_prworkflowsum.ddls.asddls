@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_PRWORKFLOWSUM '
define root view entity ZC_PRWORKFLOWSUM
  provider contract transactional_query
  as projection on ZR_PRWORKFLOWSUM
{

  key   ApplyDepart,
  key   PrNo,
        Currency,
        AmountSum
}
