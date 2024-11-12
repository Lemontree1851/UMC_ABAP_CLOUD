@VDM.viewType: #COMPOSITE

@ObjectModel: {
  dataCategory : #VALUE_HELP,
  representativeKey: 'GoodsMovementType',
  supportedCapabilities: [ #SQL_DATA_SOURCE,
                           #CDS_MODELING_DATA_SOURCE,
                           #CDS_MODELING_ASSOCIATION_TARGET,
                           #VALUE_HELP_PROVIDER,
                           #SEARCHABLE_ENTITY
  ],
  usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MASTER
  },
  resultSet.sizeCategory: #XS
}

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Goods Movement Type Value Help - Down List'
define root view entity ZC_GoodsMovementTypeVH
  as select distinct from ztpp_1010
  association [0..1] to I_GoodsMovementTypeT as _Text on  $projection.GoodsMovementType = _Text.GoodsMovementType
                                                      and _Text.Language                = $session.system_language
{
      @ObjectModel.text.element: ['GoodsMovementTypeName']
  key goods_movement_type as GoodsMovementType,
      @UI.hidden: true
      _Text.GoodsMovementTypeName
}
