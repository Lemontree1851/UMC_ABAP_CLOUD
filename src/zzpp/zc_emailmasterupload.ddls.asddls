@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '###GENERATED Core Data Service Entity'
@Metadata.allowExtensions: true
define root view entity ZC_EMAILMASTERUPLOAD
  provider contract transactional_query
  as projection on ZR_EMAILMASTERUPLOAD
{
  key UUID,
      @ObjectModel.text.element: ['PlantName']
      Plant,
      @ObjectModel.text.element: ['CustomerName']
      Customer,
      Receiver,
      @ObjectModel.text.element: ['ReceiverTypeText']
      ReceiverType,
      MailAddress,
      @ObjectModel.text.element: ['CreateUserName']
      CreatedBy,
      CreatedAt,
      @ObjectModel.text.element: ['UpdateUserName']
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      @UI.hidden: true
      _Plant.PlantName,
      @UI.hidden: true
      _Customer.CustomerName,
      @UI.hidden: true
      _EmailCopy.text as ReceiverTypeText,
      @UI.hidden: true
      _CreateUser.PersonFullName as CreateUserName,
      @UI.hidden: true
      _UpdateUser.PersonFullName as UpdateUserName

}
