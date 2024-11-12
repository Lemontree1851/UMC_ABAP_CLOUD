@EndUserText.label: 'OF一覧照会'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_OFLIST'
define custom entity ZCE_OFLIST
  // with parameters parameter_name : parameter_type
{
  key Product                       : matnr;
  key Plant                         : werks_d;
  key MRPArea                       : abap.char(10);
  key PlndIndepRqmtType             : abap.char(4);
  key PlndIndepRqmtVersion          : abap.char(2);
  key RequirementPlan               : abap.char(10);
  key RequirementSegment            : abap.char(40);
  key PlndIndepRqmtPeriod           : abap.char(8);
  key PeriodType                    : abap.char(1);
      ProductDescription            : maktx;
      MaterialByCustomer            : matnr;
      PlndIndepRqmtIsActive         : abap_boolean;
      MfgOrderConfirmationEntryDate : abap.char(8);
      RequirementDate               : abap.char(8);
      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      PlannedQuantity               : menge_d;
      UnitOfMeasure                 : meins;
      LastChangedByUser             : aenam;
      LastChangeDate                : abap.char(8);
      Remark                        : abap.char(100);
      ProfitCenter                  : prctr;
      IntervalDays                  : int4;
}
