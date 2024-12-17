@VDM.viewType: #COMPOSITE

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'SupplierCompany'
@ObjectModel.modelingPattern: #VALUE_HELP_PROVIDER
@ObjectModel.supportedCapabilities: [ #CDS_MODELING_DATA_SOURCE, #CDS_MODELING_ASSOCIATION_TARGET, #VALUE_HELP_PROVIDER ]
@ObjectModel.usageType.dataClass: #ORGANIZATIONAL
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #L

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Search.searchable: true
@Consumption.ranked: true

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Supplier Company Value Help'
define view entity ZC_SupplierCompanyVH
  as select distinct from I_SupplierCompany                                           
{
      @ObjectModel.text.element: ['SupplierCompanyName']
      @Search: {
           defaultSearchElement: true,
           ranking: #HIGH,
           fuzzinessThreshold: 0.8
          }
      @UI.textArrangement: #TEXT_LAST
  key Supplier as SupplierCompany,
       @UI.textArrangement: #TEXT_LAST
      @Search: {
           defaultSearchElement: true,
           ranking: #MEDIUM,
           fuzzinessThreshold: 0.8
          }
  key CompanyCode,
  @Semantics.text: true
  @Search: { defaultSearchElement: true, ranking: #LOW }
  @Search.fuzzinessThreshold: 0.8  
  _Supplier.SupplierName as SupplierCompanyName
}
