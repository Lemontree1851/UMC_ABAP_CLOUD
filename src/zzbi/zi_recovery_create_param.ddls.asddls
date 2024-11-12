@EndUserText.label: 'Recovery Management Create Param'
define abstract entity ZI_RECOVERY_CREATE_PARAM
{
  @Consumption.valueHelpDefinition: [{ entity:{ element: 'CompanyCode' , name: 'I_CompanyCode' } }]
  CompanyCode  : bukrs;

  @Consumption.valueHelpDefinition: [{ entity:{ element: 'RecoverType', name: 'ZI_RECOVER_TYPE_VH' } }]
  RecoveryType : ze_recycle_type;

  @Consumption.valueHelpDefinition: [{ entity:{ element: 'Customer' , name: 'I_Customer' } }]
  Customer     : kunnr;

  @Consumption.filter:{ multipleSelections: false, selectionType: #SINGLE }
  //  @Consumption.valueHelpDefinition: [{ entity:{ element: 'CalendarYear', name: 'I_CalendarYear' }  }]
  @Semantics.calendar.year: true
  RecoveryYear : gjahr;
}
