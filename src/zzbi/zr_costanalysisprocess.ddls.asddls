@ObjectModel.query.implementedBy: 'ABAP:ZCL_COSTANALYSISPROCESS'
define root custom entity ZR_COSTANALYSISPROCESS
{
  key zYear              : abap.char( 4 );       
  key zMonth             : abap.char( 2 );       
  key YearMonth          : abap.char( 6 );    
  @Consumption.valueHelpDefinition: [ { entity: { element: 'CompanyCode', name: 'I_CompanyCodeStdVH' } } ]                      
  key Companycode        : abap.char( 4 );                                                           
  key Plant              : abap.char( 4 );    
  @Consumption.valueHelpDefinition: [ { entity: { element: 'Product', name: 'I_ProductStdVH' } } ]                                                  
  key Product            : abap.char( 40 );                            
  key ProductDescription : abap.char( 40 ); 
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Customer_VH', element: 'Customer' } } ]
      Customer           : abap.char( 10 );                               
      CustomerName       : abap.char( 40 );   
      CompanycodeText    : abap.char( 40 ); 
      PlantText          : abap.char( 40 ); 
      EstimatedPrice_SMT : abap.char( 6 );                                   
      EstimatedPrice_AI  : abap.char( 6 );                                
      EstimatedPrice_FAT : abap.char( 6 );                             
      ActualPrice_SMT    : abap.char( 6 );                          
      ActualPrice_AI     : abap.char( 6 );                       
      ActualPrice_FAT    : abap.char( 6 );                      
      Currency           : abap.char( 6 );                          
      BillingQuantity    : abap.char( 6 );                         
      BillingQuantityUnit: abap.char( 2 );                                  
       
      
}
