@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '先々在庫推移分析'
@Metadata.allowExtensions: true
define root view entity ZI_BI005_REPORT
  as select from ztbi_1003
    inner join   ZR_TBC1012           as _AssignCompany on _AssignCompany.CompanyCode = ztbi_1003.companycode
    inner join   ZC_BusinessUserEmail as _User          on  _User.Email  = _AssignCompany.Mail
                                                        and _User.UserID = $session.user
{
  key ztbi_1003.yearmonth             as YearMonth,
  key ztbi_1003.type                  as Type,
  key ztbi_1003.companycode           as Companycode,
  key ztbi_1003.plant                 as Plant,
  key ztbi_1003.product               as Product,
  key ztbi_1003.customer              as Customer,
      ztbi_1003.companycodetext       as CompanycodeText,
      ztbi_1003.planttext             as PlantText,
      ztbi_1003.productdescription    as ProductDescription,
      ztbi_1003.materialtype          as MaterialType,
      ztbi_1003.materialtypetext      as MaterialTypeText,
      ztbi_1003.customertext          as CustomerText,
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ztbi_1003.balanceopenning       as BalanceOpenning,
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ztbi_1003.supply                as Supply,
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ztbi_1003.demand                as Demand,
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ztbi_1003.balanceclosing        as BalanceClosing,
      ztbi_1003.unit                  as Unit,
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ztbi_1003.standardprice         as StandardPrice,
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ztbi_1003.actualprice           as ActualPrice,
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ztbi_1003.closinginventorytotal as ClosingInventoryTotal,
      ztbi_1003.companycodecurrency   as CompanyCodeCurrency
}
