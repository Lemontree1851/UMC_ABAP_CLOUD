@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print Demo'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@UI: {
  headerInfo: {
    typeName: 'Print Demo',
    typeNamePlural: 'Print Demo'
  }
}
define view entity ZZR_PRT_DEMO
  as select from zzt_prt_demo
{
      @UI.facet: [ {
        id: 'idIdentification',
        type: #IDENTIFICATION_REFERENCE,
        label: 'Record',
        position: 10
      } ]

      @UI.lineItem: [ { position: 10, importance: #MEDIUM, cssDefault.width: '20rem' } ]
      @UI.selectionField: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @EndUserText.label: 'UUID'
  key uuid       as Uuid,
      @UI.lineItem: [ { position: 20, importance: #MEDIUM } ]
      @UI.identification: [{ position: 20 }]
      @EndUserText.label: 'Text'
      file_name  as FileName,
      @UI.lineItem: [ { position: 30, importance: #MEDIUM } ]
      @UI.identification: [{ position: 30 }]
      created_by as CreatedBy,
      @UI.lineItem: [ { position: 40, importance: #MEDIUM } ]
      @UI.identification: [{ position: 40 }]
      created_at as CreatedAt
}
