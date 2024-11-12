@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MM-013棚卸検数結果一括登録'
define root view entity ZR_PHYSICALINVENTORYUPLOAD 
as select from ztmm_1008
{
    key uuid as UUID,
    plant as Plant,
    storagelocation as Storagelocation,
    inventoryspecialstocktype as Inventoryspecialstocktype,
    material as Material,
    supplier as Supplier,
    quantity as Quantity,
    unitofentry as Unitofentry,
    physicalinventoryitemiszero as Physicalinventoryitemiszero,
    batch as Batch,
    reasonforphysinvtrydifference as Reasonforphysinvtrydifference,
    baseunit as Baseunit,
    status as Status,
    message as Message,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt,
    local_last_changed_at as LocalLastChangedAt
    
}
