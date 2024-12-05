@EndUserText.label: 'Print Parameter'
define abstract entity ZZR_PRT_PARAMETER
{
  TemplateID             : abap.char(15);
  IsExternalProvidedData : abap_boolean;
  ExternalProvidedData   : zze_filecontent;
  ProvidedKeys           : zze_zzkey;
  FileName               : zze_filename;
}
