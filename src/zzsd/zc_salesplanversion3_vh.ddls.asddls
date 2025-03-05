@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Plan Version 3'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_SalesPlanVersion3_VH
  as select from C_SalesPlanValueHelp
{
      @UI.hidden: true
  key SalesPlanUUID,
      SalesPlanVersion,
      SalesPlanVersionDescription,
      SalesPlan,
      SalesPlanDescription,
      CreatedByUser,
      UserDescription
}
where
  substring( SalesPlanVersion,2,1 ) = '3'
