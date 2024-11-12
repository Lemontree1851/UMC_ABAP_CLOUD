@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Binding GLaccount Upload'
define root view entity ZR_BINDGLUPLOAD
  as select from ztfi_1002
  
  association [0..1] to I_GLAccountText as _glaccounttext on  $projection.GLAccount = _glaccounttext.GLAccount and _glaccounttext.ChartOfAccounts = 'YCOA' and _glaccounttext.Language = 'J'
  association [0..1] to I_BusinessUserVH as _CreateUser  on  $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser  on  $projection.LastChangedBy = _UpdateUser.UserID
 
{
  key chartofaccounts            as ChartOfAccounts,//勘定コード表
  key glaccount                  as GLAccount,//G/L勘定
      //glaccountname              as GLAccountName,//G/L勘定テキスト
      _glaccounttext.GLAccountLongName,
      financialstatement         as FinancialStatement,//連結勘定
      financialstatementitemtext as FinancialStatementItemText,//連結勘定テキスト
      //status                     as Status,  // ステータス
      //message                    as Message, // メッセージ
      @Semantics.user.createdBy: true
      created_by                 as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                 as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by            as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at            as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at      as LocalLastChangedAt,
      _glaccounttext,
      _CreateUser,
      _UpdateUser
}
