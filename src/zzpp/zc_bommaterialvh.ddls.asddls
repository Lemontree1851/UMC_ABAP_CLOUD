@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material by Bill of Material Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {
  dataCategory : #VALUE_HELP,
  usageType: {
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
    } }
@Search.searchable: true
define view entity ZC_BOMMaterialVH as select from I_MaterialBOMLink
  association [0..1] to I_ProductDescription as _Description on $projection.Material  = _Description.Product
                                                            and _Description.Language = $session.system_language
{
  @Search.defaultSearchElement: true
  key Material,
  key _Description.ProductDescription as MaterialDescription,
  key Plant,
  key BillOfMaterialVariantUsage,
  key BillOfMaterialVariant,
  key BillOfMaterialCategory
}
