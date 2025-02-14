define abstract entity ZD_PARAFORACCEPT
{
  Zzkey        : zze_zzkey;
  Ztype        : abap.char(1);
  Event        : abap.char(20);
  PeriodType   : abap.char(10);
  AcceptYear   : abap.char(10);
  AcceptPeriod : abap.char(10);
}
