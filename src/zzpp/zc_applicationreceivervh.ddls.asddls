@VDM.viewType: #COMPOSITE

@ObjectModel: {
  dataCategory : #VALUE_HELP,
  supportedCapabilities: [ #SQL_DATA_SOURCE,
                           #CDS_MODELING_DATA_SOURCE,
                           #CDS_MODELING_ASSOCIATION_TARGET,
                           #VALUE_HELP_PROVIDER,
                           #SEARCHABLE_ENTITY
  ],
  usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MASTER
  }
}

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'MR Application Receiver Value Help'
define view entity ZC_ApplicationReceiverVH
  as select from ZR_ApplicationReceiverVH
{
      @UI.hidden: true
  key UUID,
      Plant,
      Customer,
      @UI.lineItem: [{ position: 10, cssDefault.width: '10rem' }]
      @EndUserText.label: 'Receiver'
      Receiver,
      @EndUserText.label: 'Mail Address'
      case when _EmailCopy.text is not initial and MailAddress is not initial
           then concat_with_space( _EmailCopy.text, MailAddress, 2 )
           when _EmailCopy.text is initial
           then MailAddress
           else '' end as MailAddress
}
where
  Receiver is not initial
