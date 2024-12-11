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
//  @Consumption.valueHelpDefinition: [ { entity: { element: 'Material', name: 'ZC_BOMMaterialVH' } } ]     
  @Consumption.valueHelpDefinition: [ { entity: { element: 'Product', name: 'I_ProductStdVH' } } ]                                 
  key Material           : abap.char( 40 );                             
      CompanycodeText    : abap.char( 40 );  
      PlantText          : abap.char( 40 );                             
      MaterialDescription: abap.char( 40 );                                       
      Quantity           : abap.char( 6 );       
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Customer_VH', element: 'Customer' } } ]                      
      Customer           : abap.char( 10 );                               
      CustomerName       : abap.char( 40 );   
      @Semantics : { amount : {currencyCode: 'Currency'} }                                
      EstimatedPrice     : abap.curr(15,2);    
      @Semantics : { amount : {currencyCode: 'Currency'} }                               
      FinalPrice         : abap.curr(15,2);                            
      FinalPostingDate   : abap.char( 8 );                                       
      FinalSupplier      : abap.char( 10 );                                   
      FixedSupplier      : abap.char( 40 );                                        
      StandardPrice      : abap.char( 40 );                  
      MovingAveragePrice : abap.char( 40 );   
                                 
      Currency           : waerk;         
      BillingQuantity    : abap.char( 20 );                                   
      BillingQuantityUnit: abap.char( 2 );
      sales_number        : abap.char(25);
      quo_version         : abap.char(25);
      sales_d_no          : abap.char(25);  
      profitcenter        : abap.char(20);
      profitcentername    : abap.char(40);                                   
}
