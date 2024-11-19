@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'JournalEntryItem'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_JournalEntryItem 
  as select from    I_JournalEntryItem as Item1
    inner join      ztbc_1001                   on  ztbc_1001.zid     = 'ZFI001'
                                                and ztbc_1001.zvalue1 = Item1.GLAccount                         
{
  key Item1.CompanyCode,
  key Item1.CompanyCodeCurrency,
  key Item1.TaxCode,
  key Item1.PostingDate as aPostingDate,  
//           case when Item1.PostingDate is initial then '000000'
//           else substring( Item1.PostingDate ,1,6 ) end as PostingDate,  
      '202411' as PostingDate,    
//      substring( Item1.PostingDate ,1,6 ) as PostingDate, 
      '20240101' as zPostingDate,  
      Item1.GLAccount,
      Item1.ReferenceDocumentContext,
      Item1.ReferenceDocument,
      Item1.AccountingDocument,
      Item1.FiscalYear,
      Item1.Ledger,
      Item1.AccountingDocumentType,
      @Semantics                  : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      Item1.AmountInCompanyCodeCurrency
}
where Item1.TaxCode              is not initial
  and Item1.PostingDate          is not initial
  and Item1.Ledger               = '0L'
  and Item1.AccountingDocumentType = 'RE'
