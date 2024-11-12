@ObjectModel.query.implementedBy: 'ABAP:ZCL_COSTANALYSISCOM'
define root custom entity ZR_COSTANALYSISCOM
{
  key zYear              : abap.numc( 4 );       
  key zMonth             : abap.numc( 2 );       
  key YearMonth          : abap.char( 6 );   
  @Consumption.valueHelpDefinition: [ { entity: { element: 'CompanyCode', name: 'I_CompanyCodeStdVH' } } ]                         
  key Companycode        : abap.char( 4 );                                     
  key Plant              : abap.char( 4 );   
  @Consumption.valueHelpDefinition: [ { entity: { element: 'Product', name: 'I_ProductStdVH' } } ]                                              
  key Product            : abap.char( 40 );                            
  key ProductDescription : abap.char( 40 );    
  @Consumption.valueHelpDefinition: [ { entity: { element: 'Material', name: 'ZC_BOMMaterialVH' } } ]                                    
  key Material           : abap.char( 40 );                             
      CompanycodeText    : abap.char( 40 );  
      PlantText          : abap.char( 40 );                             
      MaterialDescription: abap.char( 40 );                                       
      Quantity           : abap.char( 6 );       
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Customer_VH', element: 'Customer' } } ]                      
      Customer           : abap.char( 10 );                               
      CustomerName       : abap.char( 40 );                                   
      EstimatedPrice     : abap.char( 15 );                                   
      FinalPrice         : abap.char( 15 );                               
      FinalPostingDate   : abap.char( 8 );                                       
      FinalSupplier      : abap.char( 10 );                                   
      FixedSupplier      : abap.char( 40 );                                   
      StandardPrice      : abap.char( 6 );                                   
      MovingAveragePrice : abap.char( 6 );                                       
      Currency           : abap.char( 6 );                               
      BillingQuantity    : abap.char( 15 );                                   
      BillingQuantityUnit: abap.char( 2 );                                       
}
