@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Binding GLaccount Upload'
define root view entity ZC_BDGLUPLOAD
  provider contract transactional_query
  as projection on ZR_BDGLUPLOAD
{
  key UUID,
      ChartOfAccounts, //勘定コード表
      GLAccount, //G/L勘定
      GLAccountName,//G/L勘定テキスト
      FinancialStatementItem, //連結勘定
      FinancialStatementItemText, //連結勘定テキスト
      Status,  // ステータス
      Message, // メッセージ
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
