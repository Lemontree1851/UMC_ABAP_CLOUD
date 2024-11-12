@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '支払方法変更'
define root view entity ZR_PAYMETHOD_sum
  as select from ztfi_1006
{
  key           uuid                        as UUID,
  key           companycode                 as CompanyCode,
  key           lastdate                    as LastDate,
  key           supplier                    as Supplier,
  key           netduedate                  as NetdueDate,
  key           paymentmethod               as PaymentMethod,
  key           paymentterms                as PaymentTerms,

                amountincompanycodecurrency as AmountInCompanyCodeCurrency,
                companycodecurrency         as CompanyCodeCurrency,
                accountingclerkphonenumber  as AccountingClerkPhoneNumber,
                accountingclerkfaxnumber    as AccountingClerkFaxNumber,
                paymentmethod_a             as PaymentMethod_a,

                status                      as Status,  // ステータス
                message                     as Message, // メッセージ
                @Semantics.user.createdBy: true
                created_by                  as CreatedBy,
                @Semantics.systemDateTime.createdAt: true
                created_at                  as CreatedAt,
                @Semantics.user.lastChangedBy: true
                last_changed_by             as LastChangedBy,
                @Semantics.systemDateTime.lastChangedAt: true
                last_changed_at             as LastChangedAt,
                @Semantics.systemDateTime.localInstanceLastChangedAt: true
                local_last_changed_at       as LocalLastChangedAt
}
