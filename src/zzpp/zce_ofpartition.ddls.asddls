@EndUserText.label: 'Order Forecast Partition'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_OFPARTITION'
define root custom entity ZCE_OFPARTITION
  //  with parameters
  //    //      @Consumption.hidden: true
  //    SplitRange : char13
{
      // DEL BEGIN BY XINLEI XU 2025/02/27 性能优化
      //  key Customer           : kunnr;
      //  key Plant              : werks_d;
      //  key Material           : matnr;
      //  key RequirementDate    : abap.dats;
      //      MaterialByCustomer : abap.char(35); //matnr; MOD BY XINLEI XU 2025/02/18
      //      MaterialName       : maktx;
      //      @Semantics.quantity.unitOfMeasure: 'Unit'
      //      RequirementQty     : menge_d;
      //      Unit               : meins;
      // DEL END BY XINLEI XU 2025/02/27

      // ADD BEGIN BY XINLEI XU 2025/02/27 性能优化
  key UUID               : sysuuid_x16;
      DataJson           : abap.string;
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Customer_VH', element: 'Customer' } } ]
      Customer           : kunnr;
      Plant              : werks_d;
      Material           : matnr;
      RequirementDate    : abap.dats;
      MaterialByCustomer : abap.char(35); //matnr; MOD BY XINLEI XU 2025/02/18
      MaterialName       : maktx;
      @Semantics.quantity.unitOfMeasure: 'Unit'
      RequirementQty     : menge_d;
      Unit               : meins;
      // ADD END BY XINLEI XU 2025/02/27

      ProcessStart       : abap.char(8);
      ProcessEnd         : abap.char(8);
      SplitRange         : char13;
}
