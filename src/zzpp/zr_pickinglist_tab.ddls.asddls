@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Picking List Custom Table Data'
define root view entity ZR_PICKINGLIST_TAB
  as select from ztpp_1015

  association [0..1] to I_ProductText                  as _ProductText         on  $projection.Material  = _ProductText.Product
                                                                               and _ProductText.Language = $session.system_language
  association [0..1] to I_StorageLocation              as _StorageLocationFrom on  $projection.Plant               = _StorageLocationFrom.Plant
                                                                               and $projection.StorageLocationFrom = _StorageLocationFrom.StorageLocation
  association [0..1] to I_StorageLocation              as _StorageLocationTo   on  $projection.Plant             = _StorageLocationTo.Plant
                                                                               and $projection.StorageLocationTo = _StorageLocationTo.StorageLocation
  association [0..1] to I_DocumentInfoRecordLbtryOffcT as _Laboratory          on  $projection.LaboratoryOrDesignOffice = _Laboratory.LaboratoryOrDesignOffice
                                                                               and _Laboratory.Language                 = $session.system_language
  association [0..1] to ZC_DeleteFlagVH                as _DeleteFlagText      on  $projection.DeleteFlag = _DeleteFlagText.Zvalue1
{
  key reservation                 as Reservation,
  key reservation_item            as ReservationItem,
      plant                       as Plant,
      material                    as Material,
      material_group              as MaterialGroup,
      laboratory_or_design_office as LaboratoryOrDesignOffice,
      external_product_group      as ExternalProductGroup,
      size_or_dimension_text      as SizeOrDimensionText,
      base_unit                   as BaseUnit,
      g_r_slips_quantity          as GR_SlipsQuantity,
      storage_location_from       as StorageLocationFrom,
      storage_location_to         as StorageLocationTo,
      storage_location_from_stock as StorageLocationFromStock,
      storage_location_to_stock   as StorageLocationToStock,
      total_required_quantity     as TotalRequiredQuantity,
      total_short_fall_quantity   as TotalShortFallQuantity,
      total_transfer_quantity     as TotalTransferQuantity,
      m_c_a_r_d_quantity          as M_CARD_Quantity,
      m_c_a_r_d                   as M_CARD,
      delete_flag                 as DeleteFlag,
      created_date                as CreatedDate,
      created_time                as CreatedTime,
      created_by_user             as CreatedByUser,
      created_by_user_name        as CreatedByUserName,
      last_changed_date           as LastChangedDate,
      last_changed_time           as LastChangedTime,
      last_changed_by_user        as LastChangedByUser,
      last_changed_by_user_name   as LastChangedByUserName,
      local_last_changed_at       as LocalLastChangedAt,

      _ProductText,
      _StorageLocationFrom,
      _StorageLocationTo,
      _Laboratory,
      _DeleteFlagText
}
