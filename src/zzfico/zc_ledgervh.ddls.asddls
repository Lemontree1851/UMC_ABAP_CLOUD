@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Ledger'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.dataCategory: #VALUE_HELP
define root view entity ZC_LedgerVH
  as select from I_Ledger
  association [0..1] to I_LedgerText as _LedgerText on  _LedgerText.Ledger= $projection.Ledger 
                                                    and _LedgerText.Language = $session.system_language
{
      @ObjectModel.text.element: ['LedgerName']
      @Search.defaultSearchElement: true
  key Ledger,
      _LedgerText.LedgerName as LedgerName

}
