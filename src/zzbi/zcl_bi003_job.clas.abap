CLASS zcl_bi003_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mr_bukrs TYPE RANGE OF bukrs,
          mr_year  TYPE RANGE OF gjahr.

    METHODS: update_report_001,
      update_report_002,
      update_report_003,
      update_report_004,
      update_report_005.
ENDCLASS.



CLASS zcl_bi003_job IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.

    et_parameter_def = VALUE #( ( selname = 'S_BUKRS' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'BUKRS' length = 4 param_text = 'Company Code' )
                                ( selname = 'S_YEAR' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'GJAHR' length = 4 param_text = 'Year' )
                              ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    "Step 1. Extract selection
    LOOP AT it_parameters INTO DATA(ls_para).
      CASE ls_para-selname.
        WHEN 'S_BUKRS'.
          APPEND CORRESPONDING #( ls_para ) TO mr_bukrs.
        WHEN 'S_YEAR'.
          APPEND CORRESPONDING #( ls_para ) TO mr_year.
      ENDCASE.
    ENDLOOP.

    "Update Report Data
    update_report_001(  ).
    update_report_002(  ).
    update_report_003(  ).
    update_report_004(  ).
    update_report_005(  ).
  ENDMETHOD.


  METHOD update_report_001.
    DATA: lt_save TYPE STANDARD TABLE OF ztbi_bi003_j01,
          ls_save TYPE ztbi_bi003_j01.

    SELECT *
    FROM zc_bi003_report_001 WHERE companycode IN @mr_bukrs
    AND recoveryyear IN @mr_year
    INTO TABLE @DATA(lt_report).

    CHECK lt_report IS NOT INITIAL.

    LOOP AT lt_report INTO DATA(ls_report).
      CLEAR ls_save.
      ls_save-company_code = ls_report-companycode.
      ls_save-company_name = ls_report-companyname.
      ls_save-created_by = ls_report-createdby.
      ls_save-created_name = ls_report-createdname.
      ls_save-created_date = ls_report-createddate.
      ls_save-currency = ls_report-currency.
      ls_save-customer = ls_report-customer.
      ls_save-customer_name = ls_report-customername.
      ls_save-job_run_by = sy-uname.
      ls_save-job_run_date = cl_abap_context_info=>get_system_date( ).
      ls_save-job_run_time = cl_abap_context_info=>get_system_time( ).
      ls_save-machine = ls_report-machine.
      ls_save-recovery_already = ls_report-recoveryalready.
      ls_save-recovery_management_number = ls_report-recoverymanagementnumber.
      ls_save-recovery_necessary_amount = ls_report-recoverynecessaryamount.
      ls_save-recovery_num = ls_report-recoverynum.
      ls_save-recovery_percentage = ls_report-recoverystatus.
      ls_save-recovery_status = ls_report-recoverystatus.
      ls_save-recovery_type = ls_report-recoverytype.
      ls_save-recovery_year = ls_report-recoveryyear.
      ls_save-recover_status_description = ls_report-recoverstatusdescription.
      ls_save-recover_type_description = ls_report-recovertypedescription.
      ls_save-uuid = ls_report-uuid.
      APPEND ls_save TO lt_save.
    ENDLOOP.

    MODIFY ztbi_bi003_j01 FROM TABLE @lt_save.

  ENDMETHOD.

  METHOD update_report_002.
    DATA: lt_save TYPE STANDARD TABLE OF ztbi_bi003_j02,
          ls_save TYPE ztbi_bi003_j02.

    SELECT *
    FROM zc_bi003_report_002 WHERE companycode IN @mr_bukrs
    AND fiscalyear IN @mr_year
    INTO TABLE @DATA(lt_report).

    CHECK lt_report IS NOT INITIAL.

    LOOP AT lt_report INTO DATA(ls_report).
      CLEAR ls_save.
      ls_save-purchase_order = ls_report-purchaseorder.
      ls_save-purchase_order_item = ls_report-purchaseorderitem.
      ls_save-billing_document = ls_report-billingdocument.
      ls_save-billing_document_item = ls_report-billingdocumentitem.
      ls_save-recovery_management_number = ls_report-recoverymanagementnumber.
      ls_save-document_currency = ls_report-documentcurrency.
      ls_save-base_unit = ls_report-baseunit.
      ls_save-company_currency = ls_report-companycurrency.
      ls_save-order_quantity = ls_report-orderquantity.
      ls_save-net_price_amount = ls_report-netpriceamount.
      ls_save-company_code = ls_report-companycode.
      ls_save-company_code_name = ls_report-companycodename.
      ls_save-spotbuy_material = ls_report-spotbuymaterial.
      ls_save-spotbuy_material_text = ls_report-spotbuymaterialtext.
      ls_save-product_old_id = ls_report-productoldid.
      ls_save-product_old_text = ls_report-productoldtext.
      ls_save-fiscal_year_period = ls_report-fiscalyearperiod.
      ls_save-fiscal_year = ls_report-fiscalyear.
      ls_save-fiscal_month = ls_report-fiscalmonth.
      ls_save-old_material_price = ls_report-oldmaterialprice.
      ls_save-net_price_diff = ls_report-netpricediff.
      ls_save-recovery_necessary_amount = ls_report-recoverynecessaryamount.
      ls_save-sales_order_document = ls_report-salesorderdocument.
      ls_save-sales_order_document_item = ls_report-salesorderdocumentitem.
      ls_save-customer = ls_report-customer.
      ls_save-customer_name = ls_report-customername.
      ls_save-transaction_currency = ls_report-transactioncurrency.
      ls_save-billing_product = ls_report-billingproduct.
      ls_save-billing_product_text = ls_report-billingproducttext.
      ls_save-billing_document_date = ls_report-billingdocumentdate.
      ls_save-profit_center = ls_report-profitcenter.
      ls_save-profit_center_name = ls_report-profitcentername.
      ls_save-billing_quantity_unit = ls_report-billingquantityunit.
      ls_save-billing_quantity = ls_report-billingquantity.
      ls_save-billing_currency = ls_report-billingcurrency.
      ls_save-billing_price = ls_report-billingprice.
      ls_save-condition_type = ls_report-conditiontype.
      ls_save-condition_rate_amount = ls_report-conditionrateamount.
      ls_save-recovery_amount = ls_report-recoveryamount.
      ls_save-job_run_by = sy-uname.
      ls_save-job_run_date = cl_abap_context_info=>get_system_date( ).
      ls_save-job_run_time = cl_abap_context_info=>get_system_time( ).
      APPEND ls_save TO lt_save.
    ENDLOOP.

    MODIFY ztbi_bi003_j02 FROM TABLE @lt_save.
  ENDMETHOD.

  METHOD update_report_003.
    DATA: lt_save TYPE STANDARD TABLE OF ztbi_bi003_j03,
          ls_save TYPE ztbi_bi003_j03.

    SELECT *
    FROM zc_bi003_report_003 WHERE companycode IN @mr_bukrs
    AND fiscalyear IN @mr_year
    INTO TABLE @DATA(lt_report).

    CHECK lt_report IS NOT INITIAL.

    LOOP AT lt_report INTO DATA(ls_report).
      CLEAR ls_save.
      ls_save-purchase_order = ls_report-purchaseorder.
      ls_save-purchase_order_item = ls_report-purchaseorderitem.
      ls_save-source_ledger = ls_report-sourceledger.
      ls_save-company_code = ls_report-companycode.
      ls_save-fiscal_year = ls_report-fiscalyear.
      ls_save-accounting_document = ls_report-accountingdocument.
      ls_save-ledger_gl_line_item = ls_report-ledgergllineitem.
      ls_save-ledger = ls_report-ledger.
      ls_save-billing_document = ls_report-billingdocument.
      ls_save-billing_document_item = ls_report-billingdocumentitem.
      ls_save-fiscal_year_period = ls_report-fiscalyearperiod.
      ls_save-fiscal_month = ls_report-fiscalmonth.
      ls_save-recovery_management_number = ls_report-recoverymanagementnumber.
      ls_save-company_code_name = ls_report-companycodename.
      ls_save-material = ls_report-material.
      ls_save-material_text = ls_report-materialtext.
      ls_save-product_group = ls_report-productgroup.
      ls_save-product_group_name = ls_report-productgroupname.
      ls_save-order_quantity = ls_report-orderquantity.
      ls_save-base_unit = ls_report-baseunit.
      ls_save-net_price_amount = ls_report-netpriceamount.
      ls_save-company_currency = ls_report-companycurrency.
      ls_save-recovery_necessary_amount = ls_report-recoverynecessaryamount.
      ls_save-gl_account = ls_report-glaccount.
      ls_save-gl_account_name = ls_report-glaccountname.
      ls_save-fixed_asset = ls_report-fixedasset.
      ls_save-fixed_asset_description = ls_report-fixedassetdescription.
      ls_save-sales_order_document = ls_report-salesorderdocument.
      ls_save-sales_order_document_item = ls_report-salesorderdocumentitem.
      ls_save-customer = ls_report-customer.
      ls_save-customer_name = ls_report-customername.
      ls_save-transaction_currency = ls_report-transactioncurrency.
      ls_save-billing_product = ls_report-billingproduct.
      ls_save-billing_product_text = ls_report-billingproducttext.
      ls_save-billing_document_date = ls_report-billingdocumentdate.
      ls_save-profit_center = ls_report-profitcenter.
      ls_save-profit_center_name = ls_report-profitcentername.
      ls_save-billing_quantity_unit = ls_report-billingquantityunit.
      ls_save-billing_quantity = ls_report-billingquantity.
      ls_save-billing_currency = ls_report-billingcurrency.
      ls_save-billing_price = ls_report-billingprice.
      ls_save-condition_type = ls_report-conditiontype.
      ls_save-condition_rate_amount = ls_report-conditionrateamount.
      ls_save-recovery_amount = ls_report-recoveryamount.
      ls_save-percentage_of_ap = ls_report-percentageofap.
      ls_save-accounting_posting_amount = ls_report-accountingpostingamount.
      ls_save-job_run_by = sy-uname.
      ls_save-job_run_date = cl_abap_context_info=>get_system_date( ).
      ls_save-job_run_time = cl_abap_context_info=>get_system_time( ).
      APPEND ls_save TO lt_save.
    ENDLOOP.

    MODIFY ztbi_bi003_j03 FROM TABLE @lt_save.
  ENDMETHOD.

  METHOD update_report_004.
    DATA: lt_save TYPE STANDARD TABLE OF ztbi_bi003_j04,
          ls_save TYPE ztbi_bi003_j04.

    SELECT *
    FROM zc_bi003_report_004 WHERE companycode IN @mr_bukrs
    AND fiscalyear IN @mr_year
    INTO TABLE @DATA(lt_report).

    CHECK lt_report IS NOT INITIAL.

    LOOP AT lt_report INTO DATA(ls_report).
      CLEAR ls_save.
      ls_save-purchase_order = ls_report-purchaseorder.
      ls_save-purchase_order_item = ls_report-purchaseorderitem.
      ls_save-billing_document = ls_report-billingdocument.
      ls_save-billing_document_item = ls_report-billingdocumentitem.
      ls_save-company_code = ls_report-companycode.
      ls_save-company_code_name = ls_report-companycodename.
      ls_save-fiscal_year_period = ls_report-fiscalyearperiod.
      ls_save-fiscal_year = ls_report-fiscalyear.
      ls_save-fiscal_month = ls_report-fiscalmonth.
      ls_save-recovery_management_number = ls_report-recoverymanagementnumber.
      ls_save-material = ls_report-material.
      ls_save-material_text = ls_report-materialtext.
      ls_save-product_group = ls_report-productgroup.
      ls_save-product_group_name = ls_report-productgroupname.
      ls_save-order_quantity = ls_report-orderquantity.
      ls_save-base_unit = ls_report-baseunit.
      ls_save-net_price_amount = ls_report-netpriceamount.
      ls_save-company_currency = ls_report-companycurrency.
      ls_save-recovery_necessary_amount = ls_report-recoverynecessaryamount.
      ls_save-gl_account = ls_report-glaccount.
      ls_save-gl_account_name = ls_report-glaccountname.
      ls_save-fixed_asset = ls_report-fixedasset.
      ls_save-fixed_asset_description = ls_report-fixedassetdescription.
      ls_save-sales_order_document = ls_report-salesorderdocument.
      ls_save-sales_order_document_item = ls_report-salesorderdocumentitem.
      ls_save-customer = ls_report-customer.
      ls_save-customer_name = ls_report-customername.
      ls_save-transaction_currency = ls_report-transactioncurrency.
      ls_save-billing_product = ls_report-billingproduct.
      ls_save-billing_product_text = ls_report-billingproducttext.
      ls_save-billing_document_date = ls_report-billingdocumentdate.
      ls_save-profit_center = ls_report-profitcenter.
      ls_save-profit_center_name = ls_report-profitcentername.
      ls_save-billing_quantity_unit = ls_report-billingquantityunit.
      ls_save-billing_quantity = ls_report-billingquantity.
      ls_save-billing_currency = ls_report-billingcurrency.
      ls_save-billing_price = ls_report-billingprice.
      ls_save-condition_type = ls_report-conditiontype.
      ls_save-condition_rate_amount = ls_report-conditionrateamount.
      ls_save-recovery_amount = ls_report-recoveryamount.
      ls_save-job_run_by = sy-uname.
      ls_save-job_run_date = cl_abap_context_info=>get_system_date( ).
      ls_save-job_run_time = cl_abap_context_info=>get_system_time( ).
      APPEND ls_save TO lt_save.
    ENDLOOP.

    MODIFY ztbi_bi003_j04 FROM TABLE @lt_save.
  ENDMETHOD.

  METHOD update_report_005.
    DATA: lt_save TYPE STANDARD TABLE OF ztbi_bi003_j05,
          ls_save TYPE ztbi_bi003_j05.

    SELECT *
    FROM zc_bi003_report_005 WHERE companycode IN @mr_bukrs
    AND fiscalyear IN @mr_year
    INTO TABLE @DATA(lt_report).

    CHECK lt_report IS NOT INITIAL.

    LOOP AT lt_report INTO DATA(ls_report).
      CLEAR ls_save.
      ls_save-material_document = ls_report-materialdocument.
      ls_save-material_document_year = ls_report-materialdocumentyear.
      ls_save-material_document_item = ls_report-materialdocumentitem.
      ls_save-billing_document = ls_report-billingdocument.
      ls_save-billing_document_item = ls_report-billingdocumentitem.
      ls_save-material = ls_report-material.
      ls_save-product_name = ls_report-productname.
      ls_save-recovery_management_number = ls_report-recoverymanagementnumber.
      ls_save-quantity_in_entry_unit = ls_report-quantityinentryunit.
      ls_save-entry_unit = ls_report-entryunit.
      ls_save-fiscal_year_period = ls_report-fiscalyearperiod.
      ls_save-fiscal_year = ls_report-fiscalyear.
      ls_save-fiscal_month = ls_report-fiscalmonth.
      ls_save-company_code = ls_report-companycode.
      ls_save-company_code_name = ls_report-companycodename.
      ls_save-recovery_necessary_amount = ls_report-recoverynecessaryamount.
      ls_save-company_currency = ls_report-companycurrency.
      ls_save-gl_account = ls_report-glaccount.
      ls_save-gl_account_name = ls_report-glaccountname.
      ls_save-sales_order_document = ls_report-salesorderdocument.
      ls_save-sales_order_document_item = ls_report-salesorderdocumentitem.
      ls_save-customer = ls_report-customer.
      ls_save-customer_name = ls_report-customername.
      ls_save-transaction_currency = ls_report-transactioncurrency.
      ls_save-billing_product = ls_report-billingproduct.
      ls_save-billing_product_text = ls_report-billingproducttext.
      ls_save-billing_document_date = ls_report-billingdocumentdate.
      ls_save-profit_center = ls_report-profitcenter.
      ls_save-profit_center_name = ls_report-profitcentername.
      ls_save-billing_quantity_unit = ls_report-billingquantityunit.
      ls_save-billing_quantity = ls_report-billingquantity.
      ls_save-billing_currency = ls_report-billingcurrency.
      ls_save-billing_price = ls_report-billingprice.
      ls_save-condition_type = ls_report-conditiontype.
      ls_save-condition_rate_amount = ls_report-conditionrateamount.
      ls_save-recovery_amount = ls_report-recoveryamount.
      ls_save-job_run_by = sy-uname.
      ls_save-job_run_date = cl_abap_context_info=>get_system_date( ).
      ls_save-job_run_time = cl_abap_context_info=>get_system_time( ).
      APPEND ls_save TO lt_save.
    ENDLOOP.

    MODIFY ztbi_bi003_j05 FROM TABLE @lt_save.

  ENDMETHOD.

ENDCLASS.
