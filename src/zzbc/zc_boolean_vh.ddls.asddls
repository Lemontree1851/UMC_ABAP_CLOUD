@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'True/False'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet:{ sizeCategory: #XS }
define view entity ZC_BOOLEAN_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZZD_XFLAG' )
{
      @ObjectModel.text.element: ['text']
  key value_low,
      @UI.hidden: true
      text
}
where
  language = $session.system_language
