@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 003 PO Info'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_REPORT_003_PO
  with parameters
    p_recover_type : ze_recycle_type
  as select from ZI_BI003_REPORT_002_PO(p_recover_type: $parameters.p_recover_type) as poitem
  //left outer join I_PurOrdAccountAssignmentAPI01                                     as PoAccount on  poitem.PurchaseOrder     = PoAccount.PurchaseOrder
  //                                                                                                and poitem.PurchaseOrderItem = PoAccount.PurchaseOrderItem
  association [0..1] to I_JournalEntryItem           as _JournalItem   on  _JournalItem.PurchasingDocument     = $projection.PurchaseOrder
                                                                       and _JournalItem.PurchasingDocumentItem = $projection.PurchaseOrderItem
                                                                       and _JournalItem.SourceLedger           = '0L'
                                                                       and _JournalItem.Ledger                 = '0L'
                                                                       and _JournalItem.CompanyCode            = $projection.CompanyCode
                                                                       and _JournalItem.IsReversed             = ''
                                                                       and _JournalItem.IsReversal             = ''
                                                                       and _JournalItem.DebitCreditCode        = 'S'
                                                                       //and _JournalItem.ValueDate              = '00000000' //排除中间科目
                                                                       and ( ( _JournalItem.TransactionTypeDetermination = 'BSX' and _JournalItem.Quantity > 0 )
                                                                       or ( _JournalItem.TransactionTypeDetermination = 'ANL' and _JournalItem.Quantity = 0 ) 
                                                                       or ( _JournalItem.TransactionTypeDetermination = 'KBS' and _JournalItem.Quantity > 0 ))

  association [0..1] to I_FixedAsset                 as _FixedAsset    on  _FixedAsset.MasterFixedAsset = $projection.FixedAsset
                                                                       and _FixedAsset.CompanyCode      = $projection.CompanyCode
                                                                       and _FixedAsset.FixedAsset       = '0000'
  association [0..1] to I_GlAccountTextInCompanycode as _GLAccountText on  _GLAccountText.GLAccount   = $projection.glaccount
                                                                       and _GLAccountText.CompanyCode = $projection.CompanyCode
                                                                       and _GLAccountText.Language    = $session.system_language
  association [0..1] to I_Product                    as _Product       on  _Product.Product = $projection.Material
{
  key poitem.PurchaseOrder,
  key poitem.PurchaseOrderItem,
      poitem.RecoveryManagementNumber,
      poitem.DocumentCurrency,
      poitem.BaseUnit,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      poitem.OrderQuantity,

      @Semantics.amount.currencyCode: 'DocumentCurrency'
      poitem.NetPriceAmount,

      poitem.ProfitCenter,

      poitem.CompanyCode,
      poitem.Material,
      poitem.PurchaseOrderItemText, // ADD BY XINLEI XU 2025/03/19
      poitem.ProductOldID,
      poitem.CombineKey,

      _Product,

      /* Associations */
      poitem._CompanyCode,
      poitem._Matdoc,
      poitem._ProductText,
      poitem._PurchaseOrder,

      _JournalItem.MasterFixedAsset as FixedAsset,
      _JournalItem.GLAccount,
      _JournalItem.AccountingDocument,
      _JournalItem.LedgerGLLineItem,
      //      _PurOrdAcctAssignment[AccountAssignmentNumber = '01'].FixedAsset,
      //      _PurOrdAcctAssignment[AccountAssignmentNumber = '01'].GLAccount,

      _GLAccountText,

      poitem._ProfitCenterText,
      _FixedAsset

}
