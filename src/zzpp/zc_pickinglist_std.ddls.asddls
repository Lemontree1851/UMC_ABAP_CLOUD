@EndUserText.label: 'Picking List Standard Data'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_QUERY_PICKINGLIST_STD'
define custom entity ZC_PICKINGLIST_STD
{
  key RowNo                        : abap.numc(4);
      Plant                        : werks_d;
      Material                     : matnr;
      MaterialName                 : maktx;
      StorageLocationTo            : lgort_d;
      StorageLocationToName        : abap.char(16);
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      TotalRequiredQuantity        : menge_d;
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      TotalShortFallQuantity       : menge_d;
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      StorageLocationToStock       : menge_d;
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      M_CARD_Quantity              : menge_d;
      BaseUnit                     : meins;
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      TotalTransferQuantity        : menge_d;
      StorageLocationFrom          : lgort_d;
      StorageLocationFromName      : abap.char(16);
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      StorageLocationFromStock     : menge_d;
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      GR_SlipsQuantity             : menge_d;
      SizeOrDimensionText          : groes;
      M_CARD                       : maktx;
      LaboratoryOrDesignOffice     : labor;
      LaboratoryOrDesignOfficeName : abap.char(30);
      ExternalProductGroup         : abap.char(18);
      MaterialGroup                : matkl;

      // Only use filter
      RequisitionDate              : abap.dats;
      MRPController                : dispo;
      ProductionSupervisor         : abap.char(3);

      // Details
      DetailsJson                  : abap.string;
}
