@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Recover Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet:{ sizeCategory: #XS }
define root view entity ZI_RECOVER_STATUS_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZED_RECYCLE_STATUS' )
{
      @ObjectModel.text.element: [ 'Description' ]
  key value_low as RecoverStatus,
      text      as Description
}
where
  language = $session.system_language
