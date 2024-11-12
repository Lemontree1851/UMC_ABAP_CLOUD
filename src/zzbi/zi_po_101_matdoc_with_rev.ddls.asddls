@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Material Documents With Rev. Status'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PO_101_MATDOC_WITH_REV
  as select from I_MaterialDocumentItem_2 as Matdoc
{
  key Matdoc.MaterialDocument                                                       as MaterialDocument,
  key Matdoc.MaterialDocumentYear                                                   as MaterialDocumentYear,
  key Matdoc.MaterialDocumentItem                                                   as MaterialDocumentItem,

      concat(concat( MaterialDocumentYear, MaterialDocument), MaterialDocumentItem) as CombineKey,
      Matdoc.PurchaseOrder,
      Matdoc.PurchaseOrderItem,
      Matdoc.PostingDate,
      Matdoc.Plant,
      Matdoc.Material,
      Matdoc.Batch,
      Matdoc.GoodsMovementType,
      Matdoc.GoodsMovementIsCancelled,



      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      Matdoc.QuantityInEntryUnit,
      Matdoc.EntryUnit,

      Matdoc.FiscalYearPeriod,

      case FiscalYearPeriod
      when '0000000' then cast('0000' as gjahr)
      else cast( substring(FiscalYearPeriod, 1, 4)  as gjahr) end                   as FiscalYear,

      case FiscalYearPeriod
      when '0000000' then cast('00' as monat)
      else cast( substring(FiscalYearPeriod, 6, 2)  as monat) end                   as FiscalMonth
}
where
      Matdoc.GoodsMovementIsCancelled =  ''
  and Matdoc.PurchaseOrder            <> ''
  and Matdoc.GoodsMovementType        =  '101'
