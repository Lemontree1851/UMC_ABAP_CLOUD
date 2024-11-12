define abstract entity ZD_PARAFORPAIDPAYDOC
{
  Zzkey        : zze_zzkey;
  FiscalYear   : gjahr;
  Period       : monat;
  Ztype        : abap.char(1);
  Event        : abap.char( 20 );
}
