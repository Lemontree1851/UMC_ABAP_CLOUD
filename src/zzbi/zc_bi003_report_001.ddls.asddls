@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comsuption View for ZI_BI003_001'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BI003_REPORT_001
  provider contract transactional_query
  as projection on ZI_BI003_REPORT_001
{
  key Uuid,

      @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZC_RECOVERY_NUMBER_VH', element: 'RecoveryManagementNumber' } }]
      RecoveryManagementNumber,

      @Consumption.valueHelpDefinition: [{ entity:{ element: 'RecoverType', name: 'ZI_RECOVER_TYPE_VH' } }]
      @ObjectModel.text.element: [ 'RecoverTypeDescription' ]
      RecoveryType,
      RecoveryNum,

      @Consumption.valueHelpDefinition: [{ entity:{ element: 'CompanyCode' , name: 'I_CompanyCode' } }]
      @ObjectModel.text.element: [ 'CompanyName' ]
      CompanyCode,
      CompanyName,

      @Consumption.valueHelpDefinition: [{ entity:{ element: 'Customer', name: 'I_Customer' } }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      Customer,
      CustomerName,

      @Consumption.filter:{ selectionType: #SINGLE, multipleSelections: false }
      RecoveryYear,
      Machine,

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      RecoveryNecessaryAmount,

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText: { label:  'Recovery Already', quickInfo: 'Recovery Already' }
      RecoveryAlready,
      Currency,

      @EndUserText: { label:  'Recovery Percentage', quickInfo: 'Recovery Percentage' }
      RecoveryPercentage,

      @Consumption.valueHelpDefinition: [{ entity:{ element: 'RecoverStatus', name: 'ZI_RECOVER_STATUS_VH' }  }]
      @ObjectModel.text.element: [ 'RecoverStatusDescription' ]
      RecoveryStatus,

      @ObjectModel.text.element: [ 'CreatedName' ]
      CreatedBy,
      CreatedName,
      CreatedDate,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      RecoverStatusDescription,
      RecoverTypeDescription
}
