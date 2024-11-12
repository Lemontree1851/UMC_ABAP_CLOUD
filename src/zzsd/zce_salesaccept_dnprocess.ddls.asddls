@EndUserText.label: 'TWX21検収データ取込み機能'
define root custom entity ZCE_SALESACCEPT_DNPROCESS
  // with parameters parameter_name : parameter_type
{
  key DeliveryDocument            : vbeln_vl;
  key DeliveryDocumentItem        : posnr;
      //==========excel上传的数据=============
      FileType                    : abap.char(1);
      //発注者コード
      PurchaseFrom                : abap.string;
      //受注者コード
      SoldTo                      : abap.string;
      //注文番号
      PurchaseOrderByCustomer     : abap.char(35);
      //発注者品名コード
      ProductByPurchase           : matnr;
      //検収日
      AcceptDate                  : abap.char(8);
      //検収数量
      @Semantics.quantity.unitOfMeasure: 'AcceptUnit'
      AcceptQuantity              : menge_d;
      AcceptUnit                  : meins;
      //
      ProcessDate                 : abap.char(8);
      //==========返回的报表数据=============
      SalesDocument               : vbeln;
      SalesDocumentItem           : posnr;
      SalesOrganization           : vkorg;
      DeliveryDocumentType        : abap.char(4);
      DeliveryDocumentText        : abap.string;
      @Consumption.valueHelpDefinition: [
        { entity                  :  { name:    'I_Customer_VH',
                     element      : 'Customer' }
        }]
      SoldToParty                 : kunnr;
      SoldToPartyName             : abap.string;
      BillToParty                 : kunnr;
      BillToPartyName             : abap.string;
      //      PurchaseOrderByCustomer//和excel传入字段相同
      DeliveryBlockReason         : abap.char(2);
      DeliveryBlockReasonText     : abap.char(20);
      UnderlyingPurchaseOrderItem : posex;
      Product                     : matnr;
      MaterialByCustomer          : abap.char(35);
      Plant                       : werks_d;
      ShippingPoint               : abap.char(4);
      ShipToParty                 : kunnr;
      ShipToPartyName             : abap.string;
      StorageLocation             : lgort_d;
      CommittedDeliveryDate       : abap.char(8);
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      OrderQuantity               : kwmeng;
      OrderQuantityUnit           : vrkme;
      IncotermsClassification     : abap.char(3);
      IncotermsLocation1          : abap.char(70);
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      DeliveredQtyInOrderQtyUnit  : menge_d;
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      UnDeliveredQty              : menge_d;
      Type                        : msgty;
      Message                     : abap.string;


}
