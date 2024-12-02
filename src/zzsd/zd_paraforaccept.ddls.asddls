define abstract entity ZD_PARAFORACCEPT
{
  Zzkey        : zze_zzkey;
  Ztype        : abap.char(1);
  Event        : abap.char(20);
  periodtype   : abap.char(1);
  acceptperiod : abap.char(2);
}
