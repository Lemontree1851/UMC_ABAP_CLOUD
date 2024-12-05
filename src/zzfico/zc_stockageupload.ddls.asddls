@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Aging Upload'

define root view entity ZC_STOCKAGEUPLOAD
  provider contract transactional_query
  as projection on ZR_STOCKAGEUPLOAD
{
  key           InventoryType,
                @Consumption.valueHelpDefinition: [{ entity:  { name:'ZC_LedgerVH', element: 'Ledger' }}]
  key           Ledger,
  key           CalendarYear,
  key           CalendarMonth,
                @Consumption.valueHelpDefinition: [{ entity:  { name:'I_CompanyCodeStdVH', element: 'CompanyCode' }}]
  key           CompanyCode,
                @Consumption.valueHelpDefinition: [{ entity:  { name:'I_PlantStdVH', element: 'Plant' }}]
  key           Plant,
  key           Material,

  key           Age,

                Qty,
                CreatedBy,
                CreatedAt,
                LastChangedBy,
                //LastChangedAt,
                LocalLastChangedAt,
                cast(_Product.BaseUnit as meins preserving type ) as BaseUnit ,
                _ProductText.ProductName,
                _CompanyCode.CompanyCodeName,
                _Plant.PlantName,
                @UI.hidden: true
                _CreateUser.PersonFullName as CreateUserName,
                @UI.hidden: true
                _UpdateUser.PersonFullName as UpdateUserName
}
