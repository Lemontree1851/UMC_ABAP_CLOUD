@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Aging Upload'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_INAGEUPLOAD  
  provider contract transactional_query
  as projection on ZR_INAGEUPLOAD
{
  key UUID,

      Plant,
      Material,
      Age,
      Qty,
      CalendarYear,
      CalendarMonth,
      
      Status,  // ステータス
      Message, // メッセージ
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
