@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '納受領出力'
define root view entity ZR_DELIVERYRECEIPT
  as select from I_DeliveryDocumentItem as _Item
    inner join   I_DeliveryDocument     as _HeadAuthority   on _Item.DeliveryDocument = _HeadAuthority.DeliveryDocument
  //权限控制
    inner join   ZR_TBC1013             as _AssignSalesOrg  on _AssignSalesOrg.SalesOrganization = _HeadAuthority.SalesOrganization
    inner join   ZR_TBC1018             as _AssignShipPoint on _AssignShipPoint.ShippingPoint = _HeadAuthority.ShippingPoint
    inner join   ZC_BusinessUserEmail   as _User            on  _User.Email  = _AssignSalesOrg.Mail
                                                            and _User.Email  = _AssignShipPoint.Mail
                                                            and _User.UserID = $session.user
  association [0..1] to I_DeliveryDocument           as _Head               on  _Item.DeliveryDocument = _Head.DeliveryDocument
  association [0..1] to I_SalesDocument              as _SalesDocument      on  $projection.ReferenceSDDocument = _SalesDocument.SalesDocument
  association [0..1] to I_Customer                   as _Customer           on  $projection.shiptoparty = _Customer.Customer
  association [0..1] to I_SalesDocItemPricingElement as _ItemPricingElement on  $projection.ReferenceSDDocument             = _ItemPricingElement.SalesDocument
                                                                            and _ItemPricingElement.ConditionType           = 'PPR0'
                                                                            and _ItemPricingElement.ConditionInactiveReason is initial
  association [0..1] to ztsd_1007                    as _SD1007             on  $projection.DeliveryDocument     = _SD1007.delivery_document
                                                                            and $projection.DeliveryDocumentItem = _SD1007.delivery_document_item
  association [0..1] to ztbc_1001                    as _BC1001             on  $projection.shippingpoint = _BC1001.zvalue1
                                                                            and _BC1001.zid               = 'ZSD007'
{
  key _Item.DeliveryDocument,
  key _Item.DeliveryDocumentItem,
      _Item.ReferenceSDDocument,
      _Item.ReferenceSDDocumentItem,
      _Item.DeliveryDocumentItemText,
      _Head.OverallSDProcessStatus,
      _Head.DeliveryDocumentType,
      _Head.ShippingPoint,
      _Head.SoldToParty,
      _Head.ShipToParty,
      _Head.IntcoExtPlndTransfOfCtrlDteTme,
      _Head.CreatedByUser,
      _Head.DeliveryDate,
      _Head.CreationDate,
      _Head.SalesOrganization,
      _SalesDocument.SalesOffice,
      _Item.Material,
      _Item.MaterialByCustomer,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      _Item.ActualDeliveryQuantity,
      _Item.DeliveryQuantityUnit,
      case when _ItemPricingElement.ConditionQuantity is null or _ItemPricingElement.ConditionQuantity = 0
        then 0
        else cast( _ItemPricingElement.ConditionRateValue / _ItemPricingElement.ConditionQuantity as abap.dec(23,2) )
      end                         as ConditionRateValue,
      _ItemPricingElement.ConditionQuantity,
      _ItemPricingElement.ConditionQuantityUnit,
      _ItemPricingElement.ConditionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _ItemPricingElement.ConditionAmount,
      _ItemPricingElement.TransactionCurrency,

      _Customer,
      _SD1007.delivery_receipt_no as DeliveryReceiptNo,
      _BC1001
      //      _Customer.PostalCode,
      //      _Customer.CityName,
      //      _Customer.CustomerName

}
