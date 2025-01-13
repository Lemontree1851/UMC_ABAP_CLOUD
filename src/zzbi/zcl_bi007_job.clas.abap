CLASS zcl_bi007_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mr_bukrs         TYPE RANGE OF bukrs,
          mr_year          TYPE RANGE OF gjahr,
          mr_monat         TYPE RANGE OF poper,
          mr_forcastyear   TYPE RANGE OF gjahr,
          mr_forcastperiod TYPE RANGE OF poper,
          mr_plant         TYPE RANGE OF werks_d,
          mr_prod          TYPE RANGE OF matnr,
          mr_cust          TYPE RANGE OF kunnr.
ENDCLASS.



CLASS ZCL_BI007_JOB IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #( ( selname = 'S_BUKRS' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'BUKRS' length = 4 param_text = 'Company Code' )
                                ( selname = 'P_YEAR'  changeable_ind = abap_true kind = if_apj_dt_exec_object=>parameter mandatory_ind = '' datatype = 'GJAHR' length = 4 param_text = 'Fiscal Year' )
                                ( selname = 'P_MONAT' changeable_ind = abap_true kind = if_apj_dt_exec_object=>parameter mandatory_ind = '' datatype = 'POPER' length = 3 param_text = 'Fiscal Period' )
                                ( selname = 'S_PLANT' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'WERKS_D' length = 4 param_text = 'Plant' )
                                ( selname = 'S_PROD' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'MATNR' length = 40 param_text = 'Product' )
                                ( selname = 'S_CUST' changeable_ind = abap_true kind = if_apj_dt_exec_object=>select_option datatype = 'KUNNR' length = 10 param_text = 'Customer' )
                              ).

*    DATA(lv_current_date) = cl_abap_context_info=>get_system_date( ).
*    DATA(lv_first_date_of_month) = |{ lv_current_date+0(4) }{ lv_current_date+4(2) }01|.
*    DATA lv_last_date_of_pre_month TYPE datum.
*    lv_last_date_of_pre_month = lv_first_date_of_month - 1.
*
*    SELECT SINGLE * FROM i_fiscalcalendardate
*    WHERE fiscalyearvariant = 'V3'
*    AND calendardate = @lv_last_date_of_pre_month
*    INTO @DATA(ls_fiscaldate).
*
*    et_parameter_val = VALUE #( ( selname = 'P_YEAR' sign = 'I' option = 'EQ' low = ls_fiscaldate-fiscalyear )
*                                ( selname = 'P_MONAT' sign = 'I' option = 'EQ' low = ls_fiscaldate-fiscalperiod )
*                              ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    "Step 1. Extract selection
    LOOP AT it_parameters INTO DATA(ls_para).
      CASE ls_para-selname.
        WHEN 'S_BUKRS'.
          APPEND CORRESPONDING #( ls_para ) TO mr_bukrs.
        WHEN 'P_YEAR'.
          APPEND CORRESPONDING #( ls_para ) TO mr_year.
        WHEN 'P_MONAT'.
          APPEND CORRESPONDING #( ls_para ) TO mr_monat.
        WHEN 'S_PLANT'.
          APPEND CORRESPONDING #( ls_para ) TO mr_plant.
        WHEN 'S_PROD'.
          APPEND CORRESPONDING #( ls_para ) TO mr_prod.
        WHEN 'S_CUST'.
          APPEND CORRESPONDING #( ls_para ) TO mr_cust.
      ENDCASE.
    ENDLOOP.

    "Step 1.1 Default YEAR&MONAT
    READ TABLE it_parameters TRANSPORTING NO FIELDS WITH KEY selname = 'P_MONAT'.
    IF sy-subrc <> 0 .
      DATA:lv_date_local TYPE aedat.
      DATA:lv_datetime   TYPE string.
      DATA:lmr_year      LIKE LINE OF mr_year.
      DATA:lmr_monat     LIKE LINE OF mr_monat.

      GET TIME STAMP FIELD DATA(lv_timestamp_local).
      lv_datetime     = lv_timestamp_local.
      lv_date_local   = lv_datetime+0(6) && '01'.
      lv_date_local   = lv_date_local - 1.

      CLEAR lmr_year.
      lmr_year-sign   = 'I'.
      lmr_year-option = 'EQ'.
      lmr_year-low    = lv_date_local+0(4).
      APPEND lmr_year TO mr_year.

      CLEAR lmr_monat.
      lmr_monat-sign   = 'I'.
      lmr_monat-option = 'EQ'.
      lmr_monat-low    = lv_date_local+4(2).
      APPEND lmr_monat TO mr_monat.

    ENDIF.

    "Step 2. Get Data
    DATA(lo_data_handler) = NEW zcl_bi007_data( ir_companycode = mr_bukrs
                                                ir_fiscalyear = mr_year
                                                ir_fiscalperiod = mr_monat
                                                ir_forcastyear = mr_forcastyear
                                                ir_forcastperiod = mr_forcastperiod
                                                ir_plant = mr_plant
                                                ir_product = mr_prod
                                                ir_customer = mr_cust
                                              ).
    DATA lt_data TYPE STANDARD TABLE OF zi_bi007_report.
    lo_data_handler->get_data( IMPORTING et_data = lt_data ).

    "Step 3. Update Table
    IF lt_data IS NOT INITIAL.
      DATA: lt_save_data TYPE STANDARD TABLE OF ztbi_bi007_j01.
      lt_save_data = CORRESPONDING #( lt_data MAPPING actual_price = actualprice
                                                      company_code = companycode
                                                      company_code_name = companycodename
                                                      currency = currency
                                                      customer = customer
                                                      customer_name = customername
                                                      fiscal_period = forcastfiscalperiod
                                                      fiscal_year = forcastfiscalyear
                                                      fiscal_year_month = fiscalyearmonth
                                                      inventory_amount = inventoryamount
                                                      period = forcastperiod
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
                                                      base_year_month = basefiscalyearmonth
                                    ).

      "先删除上个月的预测数据，只保留上月执行的当月预测
      DATA: lv_last_base_year_month TYPE c LENGTH 6,
            lv_last_base_year       TYPE gjahr,
            lv_last_base_month      TYPE c LENGTH 2,
            lv_base_year            TYPE c LENGTH 4,
            lv_base_month           TYPE c LENGTH 2.

      READ TABLE mr_year INTO DATA(ls_year) INDEX 1.
      IF sy-subrc = 0.
        lv_base_year = ls_year-low.
      ENDIF.

      READ TABLE mr_monat INTO DATA(ls_monat) INDEX 1.
      IF sy-subrc = 0.
        lv_base_month = ls_monat-low.
      ENDIF.

      IF lv_base_year IS NOT INITIAL AND lv_base_month IS NOT INITIAL.
        IF lv_base_month = '01'.
          lv_last_base_year = lv_base_year - 1.
          lv_last_base_month = '12'.
        ELSE.
          lv_last_base_month = lv_base_month - 1.
          lv_last_base_year = lv_base_year.
        ENDIF.

        IF strlen( lv_last_base_month ) < 2.
          lv_last_base_month = '0' && lv_last_base_month.
        ENDIF.
        lv_last_base_year_month = |{ lv_last_base_year }{ lv_last_base_month }|.
      ENDIF.


      IF lv_last_base_year_month IS NOT INITIAL AND lv_base_year IS NOT INITIAL AND lv_base_month IS NOT INITIAL.
        DELETE FROM ztbi_bi007_j01 WHERE base_year_month = @lv_last_base_year_month AND ( fiscal_year <> @lv_base_year OR period <> @lv_base_month ).
      ENDIF.

      MODIFY ztbi_bi007_j01 FROM TABLE @lt_save_data.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
