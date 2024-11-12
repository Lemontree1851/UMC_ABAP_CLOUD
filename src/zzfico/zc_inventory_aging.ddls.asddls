@EndUserText.label: '長期滞在＆低価法レポート'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_QUERY_INVENTORY_AGING'
define root custom entity ZC_INVENTORY_AGING
{
  key Ledger               : fins_ledger;
  key CompanyCode          : bukrs;
  key Plant                : werks_d;
  key FiscalYear           : gjahr;
  key FiscalPeriod         : poper;
  key product              : matnr;
      ProductDescription   : maktx;
      ProductType          : mtart;
      ProductTypeName      : abap.char(25);
      MRPResponsible       : abap.char(3);
      MRPControllerName    : abap.char(18);
      ChargeableSupplyFlag : abap.char(5);
      ProfitCenter         : prctr;
      ProfitCenterLongName : abap.char(40);
      BusinessPartner      : abap.char(10);
      BusinessPartnerName  : abap.char(70);
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      ValuationQuantity    : menge_d;
      BaseUnit             : meins;
      //      @Semantics.amount.currencyCode : 'Currency'
      ActualCost           : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'Currency'
      InventoryAmount      : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'Currency'
      ValuationUnitPrice   : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'Currency'
      ValuationAmount      : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'Currency'
      ValuationAfterAmount : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'Currency'
      ValuationLoss        : abap.dec( 15, 2 );
      Currency             : waers;
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth1       : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth1         : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth2       : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth2         : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth3       : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth3         : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth4       : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth4         : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth5       : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth5         : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth6       : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth6         : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth7       : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth7         : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth8       : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth8         : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth9       : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth9         : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth10      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth10        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth11      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth11        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth12      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth12        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth13      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth13        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth14      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth14        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth15      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth15        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth16      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth16        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth17      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth17        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth18      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth18        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth19      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth19        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth20      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth20        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth21      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth21        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth22      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth22        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth23      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth23        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth24      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth24        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth25      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth25        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth26      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth26        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth27      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth27        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth28      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth28        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth29      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth29        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth30      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth30        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth31      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth31        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth32      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth32        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth33      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth33        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth34      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth34        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth35      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth35        : abap.dec( 15, 2 );
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      QuantityMonth36      : menge_d;
      //      @Semantics.amount.currencyCode : 'Currency'
      AmountMonth36        : abap.dec( 15, 2 );

}
