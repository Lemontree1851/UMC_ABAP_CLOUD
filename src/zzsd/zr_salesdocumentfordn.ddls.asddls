@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TWX21検収データ取込み機能 DN'
define root view entity ZR_SALESDOCUMENTFORDN
  as select from I_SalesDocument
  association [0..1] to I_DeliveryBlockReasonText as _DeliveryBlockReasonText on  $projection.DeliveryBlockReason   = _DeliveryBlockReasonText.DeliveryBlockReason
                                                                              and _DeliveryBlockReasonText.Language = $session.system_language
  association [0..1] to I_BusinessPartner         as _SoldToPartyName         on  $projection.SoldToParty = _SoldToPartyName.BusinessPartner
  association [0..1] to I_BusinessPartner         as _BillToPartyName         on  $projection.BillToParty = _BillToPartyName.BusinessPartner
  association [0..1] to I_BusinessPartner         as _ShipToPartyName         on  $projection.ShipToParty = _ShipToPartyName.BusinessPartner
{
  key SalesDocument,
  key _Item.SalesDocumentItem,
      SalesOrganization,
      PurchaseOrderByCustomer,
      DeliveryBlockReason,
      SoldToParty,
      _Partner[ PartnerFunction = 'BP' ].Customer       as BillToParty,
      _Item._Partner[ PartnerFunction = 'SH' ].Customer as ShipToParty,

      _Item,
      _DeliveryBlockReasonText,
      _BillToPartyName,
      _SoldToPartyName,
      _ShipToPartyName
}
