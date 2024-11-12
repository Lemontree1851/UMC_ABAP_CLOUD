@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help of Split Unit'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.supportedCapabilities: [ #CDS_MODELING_ASSOCIATION_TARGET, #CDS_MODELING_DATA_SOURCE ]
@ObjectModel.dataCategory: #VALUE_HELP
define view entity ZC_SPLITUNITVH
  as select from    DDCDS_CUSTOMER_DOMAIN_VALUE( p_domain_name: 'ZD_SPLITUNIT')   as _Key
    left outer join DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZD_SPLITUNIT') as _Text on  _Text.domain_name    = _Key.domain_name
                                                                                           and _Text.value_position = _Key.value_position
                                                                                           and _Text.language       = $session.system_language
{
       @ObjectModel.text.element: ['text']
  key  _Key.value_low,
       _Text.text
}
