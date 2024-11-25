@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '先々在庫推移分析'
@Metadata.allowExtensions: true
define root view entity ZI_BI005_REPORT
  as select from ztbi_1003
{
  key yearmonth             as YearMonth,
  key type                  as Type,
  key companycode           as Companycode,
  key plant                 as Plant,
  key product               as Product,
  key customer              as Customer,
      companycodetext       as CompanycodeText,
      planttext             as PlantText,
      productdescription    as ProductDescription,
      materialtype          as MaterialType,
      materialtypetext      as MaterialTypeText,
      customertext          as CustomerText,
      @Semantics.quantity.unitOfMeasure : 'Unit'
      balanceopenning       as BalanceOpenning,
      @Semantics.quantity.unitOfMeasure : 'Unit'
      supply                as Supply,
      @Semantics.quantity.unitOfMeasure : 'Unit'
      demand                as Demand,
      @Semantics.quantity.unitOfMeasure : 'Unit'
      balanceclosing        as BalanceClosing,
      unit                  as Unit,
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      standardprice         as StandardPrice,
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      actualprice           as ActualPrice,
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      closinginventorytotal as ClosingInventoryTotal,
      companycodecurrency   as CompanyCodeCurrency
}
