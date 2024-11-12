@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Aging Upload'

define root view entity ZC_STOCKAGEUPLOAD
  provider contract transactional_query
  as projection on ZR_STOCKAGEUPLOAD
{
                @Consumption.valueHelpDefinition: [{ entity:  { name:'ZC_LedgerVH', element: 'Ledger' }}]
  key           Ledger,
  key           CalendarYear,
  key           CalendarMonth,
                //@ObjectModel.text.element: ['CompanyCodeName']
                @Consumption.valueHelpDefinition: [{ entity:  { name:'I_CompanyCodeStdVH', element: 'CompanyCode' }}]
  key           CompanyCode,
                //@ObjectModel.text.element: ['PlantName']
                @Consumption.valueHelpDefinition: [{ entity:  { name:'I_PlantStdVH', element: 'Plant' }}]
  key           Plant,
                //@ObjectModel.text.element: ['ProductName']
  key           Material,

  key           Age,

                Qty,
                //Status,  // ステータス
                //Message, // メッセージ
                CreatedBy,
                CreatedAt,
                LastChangedBy,
                //LastChangedAt,
                LocalLastChangedAt,

                //@UI.hidden: true
                _ProductText.ProductName,
                 //@UI.hidden: true
                _CompanyCode.CompanyCodeName,
                //@UI.hidden: true
                _Plant.PlantName,
                @UI.hidden: true
                _CreateUser.PersonFullName as CreateUserName,
                @UI.hidden: true
                _UpdateUser.PersonFullName as UpdateUserName
}
