@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 001-Job Saved Data'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BI003_REPORT_001_JOB
  as select from ztbi_bi003_j01
{
  key uuid                       as Uuid,
      recovery_management_number as RecoveryManagementNumber,
      recovery_type              as RecoveryType,
      recovery_num               as RecoveryNum,
      company_code               as CompanyCode,
      company_name               as CompanyName,
      customer                   as Customer,
      customer_name              as CustomerName,
      recovery_year              as RecoveryYear,
      machine                    as Machine,
      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      recovery_necessary_amount  as RecoveryNecessaryAmount,
      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText: { label:  'Recovery Already', quickInfo: 'Recovery Already' }

      recovery_already           as RecoveryAlready,
      currency                   as Currency,
      @EndUserText: { label:  'Recovery Percentage', quickInfo: 'Recovery Percentage' }
      recovery_percentage        as RecoveryPercentage,
      recovery_status            as RecoveryStatus,
      @ObjectModel.text.element: [ 'CreatedName' ]
      created_by                 as CreatedBy,
      created_name               as CreatedName,
      created_date               as CreatedDate,
      recover_status_description as RecoverStatusDescription,
      recover_type_description   as RecoverTypeDescription,
      job_run_by                 as JobRunBy,
      job_run_date               as JobRunDate,
      job_run_time               as JobRunTime
}
