@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Business User Email'
define root view entity ZC_BusinessUserEmail
  as select from I_BusinessUserBasic
{
  key BusinessPartner,
      LastName,
      FirstName,
      PersonFullName,
      UserID,
      _WorkplaceAddress.DefaultEmailAddress as Email
}
