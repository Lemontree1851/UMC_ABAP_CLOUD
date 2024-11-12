@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'The Lastest 101 Material Document for Material'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_MAT_101_MATDOC_LASTEST
  as select from ZI_PO_101_MATDOC_WITH_REV
{
  key Material,
      max(CombineKey) as CombineKey
}
group by
  Material
