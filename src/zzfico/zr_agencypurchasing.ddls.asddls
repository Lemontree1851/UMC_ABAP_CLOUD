@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '代理購買仕訳生成'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_AGENCYPURCHASING
  as select from    I_JournalEntryItem as Item1
    inner join      ztbc_1001                   on  ztbc_1001.zid     = 'ZFI001'
                                                and ztbc_1001.zvalue1 = Item1.GLAccount
    left outer join I_JournalEntryItem as item2 on  Item1.ReferenceDocumentContext =  item2.ReferenceDocumentContext
                                                and Item1.ReferenceDocument        =  item2.ReferenceDocument
                                                and Item1.CompanyCode              != item2.CompanyCode
                                                and item2.Ledger                   =  '0L'
                                                and item2.TaxCode              is not initial
    left outer join I_JournalEntryItem as item3 on  Item1.CompanyCode          = item3.CompanyCode
                                                and Item1.AccountingDocument   = item3.AccountingDocument
                                                and Item1.FiscalYear           = item3.FiscalYear
                                                and item3.FinancialAccountType = 'K'
                                                and item3.Ledger               = '0L'
    left outer join ztfi_1014 on  ztfi_1014.postingdate            = Item1.PostingDate
                              and ztfi_1014.companycode            = Item1.CompanyCode
                              and ztfi_1014.companycode2           = item2.CompanyCode
                              and ztfi_1014.companycodecurrency    = Item1.CompanyCodeCurrency
                              and ztfi_1014.taxcode                = Item1.TaxCode
    left outer join I_JournalEntryItem as Jour1 on Jour1.CompanyCode = Item1.CompanyCode
                                              and Jour1.AccountingDocument = ztfi_1014.accountingdocument1
                                              and Jour1.FiscalYear = Item1.FiscalYear
                                              and Jour1.IsReversed = 'X'
    left outer join I_JournalEntryItem as Jour2 on Jour2.CompanyCode = item2.CompanyCode 
                                              and Jour2.AccountingDocument = ztfi_1014.accountingdocument2
                                              and Jour2.FiscalYear = Item1.FiscalYear
                                              and Jour2.IsReversed = 'X'                                 
{
      //      @UI.selectionField: [{ position: 10 }]
      //      @UI.lineItem: [{ position: 10, label: '年度期間' }]
//  key Item1.PostingDate,
  key substring( Item1.PostingDate ,1,6 ) as PostingDate,  
      //      @UI.selectionField: [{ position: 20 }]
      //      @UI.lineItem: [{ position: 20, label: '転記先会社コード' }]
  key Item1.CompanyCode,
      //      @UI.selectionField: [{ position: 30 }]
      //      @UI.lineItem: [{ position: 30, label: '決済対象会社コード' }]

      //      @UI.lineItem: [{ position: 40, label: '通貨' }]
  key Item1.CompanyCodeCurrency,
      //      @UI.lineItem: [{ position: 50, label: '税コード' }]
  key Item1.TaxCode,
      item2.CompanyCode                                                            as CompanyCode2,
//      Item1.Ledger,
      Item1.GLAccount,
//      Item1.AccountingDocument,
//      Item1.FiscalYear,
//      Item1.FiscalYearPeriod,
//      Item1.ReferenceDocumentContext,
//      Item1.ReferenceDocument,
      //      @UI.lineItem: [{ position: 60, label: '会社間取引税抜き額' }]
      //      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @Semantics                  : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      sum( Item1.AmountInCompanyCodeCurrency )                                     as Currency1,

      //      @UI.lineItem: [{ position: 80, label: '会社間取引税込額' }]
      //      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @Semantics                  : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      sum( item3.AmountInCompanyCodeCurrency * -1 )                                     as Currency2,
      //      @UI.lineItem: [{ position: 70, label: '会社間取引消費税額' }]
      //      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @Semantics                  : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      sum( item3.AmountInCompanyCodeCurrency * -1 - Item1.AmountInCompanyCodeCurrency ) as Currency3,
      //      @UI.lineItem: [{ position: 90, label: '転記先会社仕訳' }]
      case when Jour1.AccountingDocument = ztfi_1014.accountingdocument1 then ' '
      else ztfi_1014.accountingdocument1 end as accountingdocument1,
      //      @UI.lineItem: [{ position: 100, label: '決済対象会社仕訳' }]

      case when Jour2.AccountingDocument = ztfi_1014.accountingdocument2 then ' '
      else ztfi_1014.accountingdocument2 end as accountingdocument2,  
      //      @UI.lineItem: [{ position: 110, label: 'メッセージ' }]
      ztfi_1014.message,
      ztfi_1014.uuid1,
      ztfi_1014.uuid2
}
where
      Item1.TaxCode              is not initial
  and item3.FinancialAccountType = 'K'
  and Item1.Ledger               = '0L'
  and Item1.AccountingDocumentType = 'RE'
group by
  Item1.PostingDate,
//  substring( Item1.PostingDate ,1,6 ) as PostingDate,
  Jour1.AccountingDocument,
  Jour2.AccountingDocument,
  ztfi_1014.accountingdocument1,
  ztfi_1014.accountingdocument2,
  ztfi_1014.message,
  Item1.CompanyCode,
  item2.CompanyCode,
  Item1.CompanyCodeCurrency,
  Item1.TaxCode,
  Item1.GLAccount,
//  Item1.AccountingDocument,
//  Item1.Ledger,
//  item2.Ledger,
//  item3.Ledger,
//  Item1.FiscalYearPeriod,
//  Item1.ReferenceDocumentContext,
//  Item1.ReferenceDocument,
//  Item1.FiscalYear,
  ztfi_1014.uuid1,
  ztfi_1014.uuid2

