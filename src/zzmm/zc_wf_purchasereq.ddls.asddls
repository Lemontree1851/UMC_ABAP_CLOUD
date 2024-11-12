@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_WF_PURCHASEREQ'
define root view entity ZC_WF_PURCHASEREQ
  provider contract transactional_query
  as projection on ZR_WF_PURCHASEREQ
{

  key       ApplyDepart,
  key       PrNo,

            PrType,
            ApplyDate,
            ApplyTime,

            PrBy,
            PurchaseOrg,
            Kyoten,
            /* Associations */
            _WF_PURCHASEREQitem : redirected to composition child ZC_WF_PURCHASEREQITEM
            
}
