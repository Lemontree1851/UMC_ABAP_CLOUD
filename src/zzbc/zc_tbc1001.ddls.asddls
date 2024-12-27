@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TBC1001'
define root view entity ZC_TBC1001
  provider contract transactional_query
  as projection on ZR_TBC1001
{
  key ZID,
  key Zseq,
      Zkey1,
      Zkey2,
      Zkey3,
      Zkey4,
      Zkey5,
      Zkey6,
      Zkey7,
      Zkey8,
      Zkey9,
      Zvalue1,
      Zvalue2,
      Zvalue3,
      Zvalue4,
      Zvalue5,
      Zvalue6,
      Zvalue7,
      Zvalue8,
      Zvalue9,
      Zremark,
      Zprogram,
      Unmodifiable,
      LocalLastChangedAt
}
