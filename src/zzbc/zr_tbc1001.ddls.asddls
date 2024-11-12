@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '##GENERATED ZTBC_1001'
define root view entity ZR_TBC1001
  as select from ztbc_1001 as CommonConfig
{
  key zid                   as ZID,
  key zseq                  as Zseq,
      zkey1                 as Zkey1,
      zkey2                 as Zkey2,
      zkey3                 as Zkey3,
      zkey4                 as Zkey4,
      zkey5                 as Zkey5,
      zkey6                 as Zkey6,
      zkey7                 as Zkey7,
      zkey8                 as Zkey8,
      zkey9                 as Zkey9,
      zvalue1               as Zvalue1,
      zvalue2               as Zvalue2,
      zvalue3               as Zvalue3,
      zvalue4               as Zvalue4,
      zvalue5               as Zvalue5,
      zvalue6               as Zvalue6,
      zvalue7               as Zvalue7,
      zvalue8               as Zvalue8,
      zvalue9               as Zvalue9,
      zremark               as Zremark,
      zprogram              as Zprogram,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
