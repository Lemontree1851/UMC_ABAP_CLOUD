@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Binding GLaccount Upload'
define root view entity ZR_BDGLUPLOAD
  as select from ztfi_1001
{
  key uuid                       as UUID, 
      chartofaccounts            as ChartOfAccounts,//勘定コード表
      glaccount                  as GLAccount,//G/L勘定
      glaccountname              as GLAccountName,//G/L勘定テキスト
      financialstatement         as FinancialStatementItem,//連結勘定
      financialstatementitemtext as FinancialStatementItemText,//連結勘定テキスト
      status                     as Status,  // ステータス
      message                    as Message, // メッセージ
      @Semantics.user.createdBy: true
      created_by                 as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                 as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by            as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at            as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at      as LocalLastChangedAt
}
