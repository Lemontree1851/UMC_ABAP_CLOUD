@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '長期滞在＆低価法レポート'
@Metadata.allowExtensions: true
define root view entity ZC_INV_AGING
  provider contract transactional_query
  as projection on ZR_INV_AGING
{
  key         Ledger,
  key         CompanyCode,
  key         Plant,
  key         FiscalYear,
  key         FiscalPeriod,
  key         Product,
  key         Age,
              Qty,
              FiscalYearPeriod,
              Currency,
              ProductDescription,
              ProductType,
              ProductTypeName,
              ProfitCenter,
              @UI.hidden: true
              MRPResponsible,

              @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GET_INV_AGING'
  virtual     ProfitCenterLongName : abap.char(40),
              @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GET_INV_AGING'
  virtual     BusinessPartner      : abap.char(10),
              @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GET_INV_AGING'
  virtual     BusinessPartnerName  : abap.char(70),
              @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GET_INV_AGING'
              @Semantics.amount.currencyCode : 'Currency'
  virtual     ActualCost           : abap.dec( 15, 2 ),
              @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GET_INV_AGING'
              @Semantics.amount.currencyCode : 'Currency'
  virtual     InventoryAmount      : abap.dec( 15, 2 )
}
