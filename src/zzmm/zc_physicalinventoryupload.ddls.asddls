@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM-013棚卸検数結果一括登録'
define root view entity ZC_PHYSICALINVENTORYUPLOAD 
  provider contract transactional_query
  as projection on ZR_PHYSICALINVENTORYUPLOAD
{
    key UUID,
    Plant,
    Storagelocation,
    Inventoryspecialstocktype,
    Material,
    Supplier,
    Quantity,
    Unitofentry,
    Physicalinventoryitemiszero,
    Batch,
    Reasonforphysinvtrydifference,
    Baseunit,
    Status,
    Message,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt
}
