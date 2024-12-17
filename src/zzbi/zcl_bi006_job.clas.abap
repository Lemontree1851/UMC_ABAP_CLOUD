CLASS zcl_bi006_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mr_bukrs TYPE RANGE OF bukrs,
          mr_year  TYPE RANGE OF gjahr,
          mr_monat TYPE RANGE OF poper,
          mr_plant TYPE RANGE OF werks_d,
          mr_prod  TYPE RANGE OF matnr,
          mr_cust  TYPE RANGE OF kunnr.
ENDCLASS.



CLASS ZCL_BI006_JOB IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #( ( selname = 'S_BUKRS' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'BUKRS' length = 4 param_text = 'Company Code' )
                                ( selname = 'S_YEAR' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'GJAHR' length = 4 param_text = 'Fiscal Year' )
                                ( selname = 'S_MONAT' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'POPER' length = 3 param_text = 'Fiscal Period' )
                                ( selname = 'S_PLANT' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'WERKS_D' length = 4 param_text = 'Plant' )
                                ( selname = 'S_PROD' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'MATNR' length = 40 param_text = 'Product' )
                                ( selname = 'S_CUST' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'KUNNR' length = 10 param_text = 'Customer' )
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
        WHEN 'S_MONAT'.
          APPEND CORRESPONDING #( ls_para ) TO mr_monat.
        WHEN 'S_PLANT'.
          APPEND CORRESPONDING #( ls_para ) TO mr_plant.
        WHEN 'S_PROD'.
          APPEND CORRESPONDING #( ls_para ) TO mr_prod.
        WHEN 'S_CUST'.
          APPEND CORRESPONDING #( ls_para ) TO mr_cust.
      ENDCASE.
    ENDLOOP.

    "Step 2. Get Data
    DATA(lo_data_handler) = NEW zcl_bi006_data(  ).
    DATA lt_data TYPE STANDARD TABLE OF zi_bi006_report.
    lo_data_handler->get_data( EXPORTING ir_companycode = mr_bukrs
                                         ir_fiscalyear = mr_year
                                         ir_fiscalperiod = mr_monat
                                         ir_plant = mr_plant
                                         ir_product = mr_prod
                                         ir_customer = mr_cust
                               IMPORTING et_data = lt_data
                             ).

    "Step 3. Update Table
    IF lt_data IS NOT INITIAL.
      DATA: lt_save_data TYPE STANDARD TABLE OF ztbi_bi006_j01.
      lt_save_data = CORRESPONDING #( lt_data MAPPING actual_price = actualprice
                                                      company_code = companycode
                                                      company_code_name = companycodename
                                                      currency = currency
                                                      customer = customer
                                                      customer_name = customername
                                                      fiscal_period = fiscalperiod
                                                      fiscal_year = fiscalyear
                                                      fiscal_year_month = fiscalyearmonth
                                                      inventory_amount = inventoryamount
                                                      period = period
                                                      plant = plant
                                                      plant_name = plantname
                                                      product = product
                                                      product_name = productname
                                                      product_type = producttype
                                                      product_type_name = producttypename
                                                      profit_center = profitcenter
                                                      profit_center_name = profitcentername
                                                      qty = qty
                                                      type = type
                                                      valuation_area = valuationarea
                                    ).

      MODIFY ztbi_bi006_j01 FROM TABLE @lt_save_data.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
