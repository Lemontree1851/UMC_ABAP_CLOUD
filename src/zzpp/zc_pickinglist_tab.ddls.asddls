@EndUserText.label: 'Picking List Custom Table Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_PICKINGLIST_TAB
  provider contract transactional_query
  as projection on ZR_PICKINGLIST_TAB
{
  key      Reservation,
  key      ReservationItem,
           Plant,
           Material,
           MaterialGroup,
           LaboratoryOrDesignOffice,
           ExternalProductGroup,
           SizeOrDimensionText,
           BaseUnit,
           GR_SlipsQuantity,
           StorageLocationFrom,
           StorageLocationTo,
           StorageLocationFromStock,
           StorageLocationToStock,
           TotalRequiredQuantity,
           TotalShortFallQuantity,
           TotalTransferQuantity,
           M_CARD_Quantity,
           M_CARD,
           DeleteFlag,
           CreatedDate,
           CreatedTime,
           CreatedByUser,
           CreatedByUserName,
           LastChangedDate,
           LastChangedTime,
           LastChangedByUser,
           LastChangedByUserName,
           LocalLastChangedAt,

           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PICKINGLIST'
  virtual  RowNo           : abap.numc(4),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PICKINGLIST'
  virtual  PostingStatus   : abap.char(10),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PICKINGLIST'
           @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  virtual  PostingQuantity : abap.quan(13,3),
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PICKINGLIST'
  virtual  DetailsJson     : abap.string,

           /* Associations */
           _Laboratory.LaboratoryOrDesignOfficeName,
           _ProductText.ProductName                 as MaterialName,
           _StorageLocationFrom.StorageLocationName as StorageLocationFromName,
           _StorageLocationTo.StorageLocationName   as StorageLocationToName,
           _DeleteFlagText.Zvalue2                  as DeleteFlagText
}
