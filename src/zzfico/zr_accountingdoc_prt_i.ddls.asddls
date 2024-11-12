@EndUserText.label: 'Print Material Requisition Item'
@ObjectModel.query.implementedBy:'ABAP:ZCL_ACCOUNTDOC_PRT_I'
define custom entity ZR_ACCOUNTINGDOC_PRT_I
{
  key Companycode                 : abap.char(4);
  key fiscalyear                  : gjahr;
  key accountingdocument          : belnr_d;
  key LedgerGLLineItem            : abap.char(6);
      yy1_f_fins1z01_cob          : abap.char(10);
      yy1_f_fins1z02_cob          : abap.char(50);
      yy1_f_fins2z01_cob          : abap.char(10);
      yy1_f_fins2z02_cob          : abap.char(50);
      glaccount                   : hkont;
      glaccountname               : abap.char(50);
      documentitemtext            : abap.char(50);
      taxcode                     : abap.char(5);
      profitcenter                : abap.char(50);
      costcenter                  : kostl;
      exchangerate                : prctr;
      financialaccounttype        : abap.char(1);
      customer                    : kunnr;
      customerName                : abap.char(50);
      supplier                    : kunnr;
      supplierName                : abap.char(50);
      bp                          : kunnr;
      bpName                      : abap.char(50);

      transactioncurrency         : waers;
      debitcreditcode             : shkzg;
      @Semantics                  : { amount : {currencyCode: 'transactioncurrency'} }
      amountintransactioncurrency : abap.curr( 23,2);
      @Semantics                  : { amount : {currencyCode: 'transactioncurrency'} }
      debitamountintranscrcy      : abap.curr( 23,2);
      @Semantics                  : { amount : {currencyCode: 'transactioncurrency'} }
      creditamountintranscrcy     : abap.curr( 23,2);
      masterfixedasset            : anln1;
      fixedasset                  : anln2;
      fixedassetdescription       : abap.char(50);
      companycodecurrency         : waers;
      @Semantics                  : { amount : {currencyCode: 'companycodecurrency'} }
      amountincompanycodecurrency : abap.curr( 23,2);
      @Semantics                  : { amount : {currencyCode: 'companycodecurrency'} }
      debitamountincocodecrcy     : abap.curr( 23,2);
      @Semantics                  : { amount : {currencyCode: 'companycodecurrency'} }
      creditamountincocodecrcy    : abap.curr( 23,2);
      assignmentreference         : abap.char(18);
      billofexchangeissuedate     : datum;
      billofexchangedomiciletext  : abap.char(60);
      duecalculationbasedate : datum;

}
