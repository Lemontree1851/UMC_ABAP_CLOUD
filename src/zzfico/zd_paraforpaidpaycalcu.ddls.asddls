define abstract entity ZD_PARAFORPAIDPAYCALCU
{
  Zzkey        : zze_zzkey;
  CompanyCode  : bukrs;
  FiscalYear   : gjahr;
  Period       : monat;
  Ztype        : abap.char(1);
  Ledge        : abap.char(2);
}
