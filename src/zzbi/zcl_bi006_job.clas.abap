CLASS zcl_bi006_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
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

    "Step 1.1 Default YEAR&MONAT
    READ TABLE it_parameters TRANSPORTING NO FIELDS WITH KEY selname = 'S_MONAT'.
    IF sy-subrc <> 0 .
      DATA:lv_date_local TYPE aedat.
      DATA:lv_datetime   TYPE string.
      DATA:lmr_year      LIKE LINE OF mr_year.
      DATA:lmr_monat     LIKE LINE OF mr_monat.
      DATA:lv_poper      TYPE poper.
      DATA:lv_popern2    TYPE n LENGTH 2.
      DATA:lv_gjahr TYPE gjahr.

      GET TIME STAMP FIELD DATA(lv_timestamp_local).
      lv_datetime     = lv_timestamp_local.
      lv_date_local   = lv_datetime+0(8).
      zzcl_common_utils=>get_fiscal_year_period( EXPORTING iv_date = lv_date_local
                                         IMPORTING ev_year   = lv_gjahr
                                                   ev_period = lv_poper ).
      lv_popern2      = lv_poper.
      lv_date_local   = lv_gjahr && lv_popern2 && '01'.
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


  METHOD if_oo_adt_classrun~main.
    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.
    lt_parameters = VALUE #( ( selname = 'P_BUKRS'
                               kind    = if_apj_dt_exec_object=>select_option
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '1100' )
                               ( selname = 'P_BUKRS'
                               kind    = if_apj_dt_exec_object=>select_option
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '1400' )
                               ( selname = 'P_PLANT'
                               kind    = if_apj_dt_exec_object=>select_option
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '1100' )
                               ( selname = 'P_PLANT'
                               kind    = if_apj_dt_exec_object=>select_option
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '1400' )
*                               ( selname = 'P_GJAHR'
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '2024' )
*                               ( selname = 'P_POPER'
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '009' )
                                ).
    TRY.
        if_apj_dt_exec_object~get_parameters( IMPORTING et_parameter_val = lt_parameters ).

        if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_root INTO DATA(lo_root).
        out->write( |Exception has occured: { lo_root->get_text(  ) }| ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
