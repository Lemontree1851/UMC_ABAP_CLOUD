
@AbapCatalog.sqlViewName: 'ZPAYCAL'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '支払方法変更计算'
define root view ZR_PAYMETHOD_CAL as select from I_OperationalAcctgDocItem as A 
inner join I_SupplierCompany as B on
A.CompanyCode = B.CompanyCode and A.Supplier = B.Supplier
inner join I_JournalEntry as C on
C.CompanyCode = A.CompanyCode and C.FiscalYear = A.FiscalYear and C.AccountingDocument = A.AccountingDocument
{
    key A.CompanyCode,
    key A.AccountingDocument,
    key A.FiscalYear,
    key A.AccountingDocumentItem,    
    A.PostingDate,
    dats_add_days( 
        dats_add_months( 
            cast(  concat( left( A.PostingDate , 6 ), '01' ) as abap.dats ), --FirstDay
            1, 'FAIL'), 
        -1, 'FAIL') 
    as LastDay,
    A.Supplier,
    A.PaymentMethod,

    A.NetDueDate,
    A.PaymentTerms,
    A.CompanyCodeCurrency,
    A.AmountInCompanyCodeCurrency,
    B.AccountingClerkPhoneNumber,//変更後支払条件
    B.AccountingClerkFaxNumber
    
}
where 
//A.PaymentTerms is not initial and
B.AccountingClerkPhoneNumber is not initial
and A.ClearingItem is initial 
and A.SpecialGLCode is initial    
and A.FinancialAccountType = 'K'
and C.IsReversal is initial
and C.IsReversed is initial
