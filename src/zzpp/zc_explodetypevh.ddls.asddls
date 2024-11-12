@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.resultSet.sizeCategory: #XS
@EndUserText.label: 'Position Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.dataCategory: #VALUE_HELP
//@Search.searchable: true
define view entity ZC_ExplodeTypeVH
  as select from    DDCDS_CUSTOMER_DOMAIN_VALUE( p_domain_name: 'ZD_EXPLODETYPE')   as _Key
    left outer join DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZD_EXPLODETYPE') as _Text on  _Text.domain_name    = _Key.domain_name
                                                                                          and _Text.value_position = _Key.value_position
                                                                                          and _Text.language       = 'E'
{
//       @Search.defaultSearchElement: true
       @ObjectModel.text.element: ['text']
  key  _Key.value_low,
//        @UI.hidden: true
       _Text.text
}
