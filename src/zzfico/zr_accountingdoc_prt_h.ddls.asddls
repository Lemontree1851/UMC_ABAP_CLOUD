@EndUserText.label: 'Print Material Requisition Item'
@ObjectModel.query.implementedBy:'ABAP:ZCL_ACCOUNTDOC_PRT_H'
define custom entity ZR_ACCOUNTINGDOC_PRT_H
{
  key Companycode                    : abap.char(4);
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
      AccountingDocumentTypeName     : abap.char(20);
      AccountingDocumentCategory     : abap.char(1);
      CompanycodeText                : abap.char(25);

      transactioncurrency            : waers;
      @Semantics                     : { amount : {currencyCode: 'transactioncurrency'} }
      debitamountintranscrcy         : abap.curr( 23,2);
      @Semantics                     : { amount : {currencyCode: 'transactioncurrency'} }
      creditamountintranscrcy        : abap.curr( 23,2);

      parkedbyusername               : abap.char(4);
      workitem                       : abap.numc(12);
      createdbyusername              : abap.char(80);
      accountingdoccreationdate_W    : bldat;
      accountingdoccategory_W        : abap.char(1);
      accountingdocumentstatusname   : abap.char(60);
      WrkflwTskCreationUTCDateTime   : abap.dec(21,7);

}
