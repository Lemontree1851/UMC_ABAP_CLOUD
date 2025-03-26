@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 003 Recovery Neccessary Total Amount'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BI003_REPORT_REC_NEC_AMT_I
  as select from ZI_BI003_REPORT_003_PO( p_recover_type:'IN' )
{
  key RecoveryManagementNumber,
  key _Matdoc.FiscalYearPeriod as FiscalYearPeriod,

      _CompanyCode.Currency    as CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      cast ( cast( currency_conversion( amount => NetPriceAmount,
                        exchange_rate_date => _PurchaseOrder.CreationDate,
                        source_currency => DocumentCurrency,
                        target_currency => _CompanyCode.Currency
                 ) as abap.dec( 16, 2 ) ) * OrderQuantity
             as dmbtr
           )                   as TotalAmount
}
//union select from ZI_BI003_REPORT_003_ACCOUTING(p_recover_type: 'IN')
union all select from ZI_BI003_REPORT_003_ACCOUTING(p_recover_type: 'IN') // MOD BY XINLEI XU 2025/02/11
{
  key RecoveryManagementNumber,
  key FiscalYearPeriod,
      CompanyCodeCurrency         as CompanyCurrency,
      AmountInCompanyCodeCurrency as TotalAmount
}
// ADD BEGIN BY XINLEI XU 2025/02/11
union all select from ztbi_bi003_j03       as _table
  inner join          ZR_TBC1012           as _AssignCompany on _AssignCompany.CompanyCode = _table.company_code
  inner join          ZC_BusinessUserEmail as _User          on  _User.Email  = _AssignCompany.Mail
                                                             and _User.UserID = $session.user
{
  key _table.recovery_management_number as RecoveryManagementNumber,
  key _table.fiscal_year_period         as FiscalYearPeriod,
      _table.company_currency           as CompanyCurrency,
      _table.recovery_necessary_amount  as TotalAmount
}
where
  _table.job_run_by = 'UPLOAD'
// ADD END BY XINLEI XU 2025/02/10

// ADD BEGIN BY XINLEI XU 2025/03/25
union all select from ZI_BI003_REPORT_REC_NEC_AMT_GS( p_product_group:'400' )
{
  key RecoveryManagementNumber,
  key FiscalYearPeriod,
      CompanyCurrency,
      cast('0.00' as dmbtr) as TotalAmount
}
where
  substring( RecoveryManagementNumber , 1 ,2 ) = 'IN'
// ADD END BY XINLEI XU 2025/03/25
