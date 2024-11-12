@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Binding GLaccount Upload'
define root view entity ZC_BINDGLUPLOAD
  provider contract transactional_query
  as projection on ZR_BINDGLUPLOAD
{
 
   key ChartOfAccounts, //勘定コード表
     // @ObjectModel.text.element: ['glaccountname']
     @Consumption.valueHelpDefinition: [{ entity:  { name:'I_GLAccountText', element: 'GLAccount' }}]
    key  GLAccount, //G/L勘定
     // GLAccountName,//G/L勘定テキスト
      GLAccountLongName,
      FinancialStatement, //連結勘定
      FinancialStatementItemText, //連結勘定テキスト
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      //LastChangedAt,
      LocalLastChangedAt,
      
      //@UI.hidden: true
      _glaccounttext.GLAccountLongName as glaccountname,
      @UI.hidden: true
      _CreateUser.PersonFullName as CreateUserName,
      @UI.hidden: true
      _UpdateUser.PersonFullName as UpdateUserName
}
