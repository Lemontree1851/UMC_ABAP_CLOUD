@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TFI_1005
  as select from ZTFI_1005
{
  key uuid as Uuid,
  key accountingdocument as Accountingdocument,
  key fiscalyear as Fiscalyear,
  key accountingdocumentitem as Accountingdocumentitem,
  key companycode as Companycode,
  postingdate as Postingdate,
  @Semantics.amount.currencyCode: 'Companycodecurrency'
  amountincompanycodecurrency as Amountincompanycodecurrency,
  companycodecurrency as Companycodecurrency,
  accountingclerkphonenumber as Accountingclerkphonenumber,
  accountingclerkfaxnumber as Accountingclerkfaxnumber,
  paymentmethod_a as PaymentmethodA,
  conditiondate1 as Conditiondate1,
  supplier as Supplier,
  lastdate as Lastdate,
  netduedate as Netduedate,
  paymentmethod as Paymentmethod,
  paymentterms as Paymentterms,
  status as Status,
  message as Message,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
