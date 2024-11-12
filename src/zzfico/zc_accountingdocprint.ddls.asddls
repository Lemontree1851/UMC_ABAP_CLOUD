@EndUserText.label: 'Query CDS'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_ACCOUNTDOCHEADER'
    }
}
define root custom entity ZC_ACCOUNTINGDOCPRINT
{


  key companycode                    : abap.char(4);
  key fiscalyear                     : gjahr;
  key accountingdocument             : belnr_d;
      documentdate                   : bldat;
      postingdate                    : bldat;
      accountingdocumentheadertext   : butxt;
      accountingdoccreatedbyuser     : usnam;
      creationtime                   : uzeit;
      accountingdocumentcreationdate : bldat;
      lastchangedate                 : bldat;
      LedgerGroup                    : abap.char(4);
      FiscalPeriod                   : monat;    
      accountingdocumenttype         : blart;     
      AccountingDocumentTypeName: abap.char(20);
      AccountingDocumentCategory     : abap.char(1);
      CompanycodeText                : abap.char(25);
      companycodecurrency            : abap.cuky;
            @Semantics                     : { amount : {currencyCode: 'companycodecurrency'} }
      amountincompanycodecurrency    : abap.curr(23,2);

}
