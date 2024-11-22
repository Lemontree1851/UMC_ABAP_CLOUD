@EndUserText.label: 'Data Import Logs'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_SHOW_APPLICATION_LOG'
@UI: {
    headerInfo: {
       typeNamePlural: 'Log Entries'
    },
    presentationVariant: [{
       visualizations: [{type: #AS_LINEITEM}]
    }]
}
define custom entity ZZC_DTIMP_LOGS
{
      @EndUserText.label: 'Log Handle'
  key LogHandle     : balloghndl;

      @UI.lineItem  : [ { position: 20, importance: #HIGH } ]
      @UI.identification: [ { position: 10, importance: #HIGH } ]
      @EndUserText.label: 'Item No.'
  key LogItemNumber : balmnr;

      @UI.hidden    : true
      Severity      : symsgty;

      @UI.lineItem  : [ { position: 10, importance: #HIGH, criticality: 'Criticality' } ]
      @EndUserText.label: 'Severity'
      SeverityText  : abap.char(10);

      @UI.hidden    : true
      Category      : abap.char(1);
      @UI.hidden    : true
      Criticality   : abap.int1;
      @UI.hidden    : true
      DetailLevel   : ballevel;

      @EndUserText.label: 'Time Stamp'
      Timestamp     : abap.utclong;

      @UI.lineItem  : [ { position: 100, importance: #HIGH, cssDefault.width: '60rem' } ]
      @UI.identification: [ { position: 100, importance: #HIGH } ]
      @EndUserText.label: 'Message text'
      MessageText   : abap.sstring( 512 );
}
