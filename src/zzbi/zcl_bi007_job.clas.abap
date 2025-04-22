CLASS zcl_bi007_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
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

*&--ADD BEGIN BY XINLEI XU 2025/04/03
    CLASS-METHODS:
      init_application_log,
      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime.
    CLASS-DATA:
      mo_application_log TYPE REF TO if_bali_log.
*&--ADD END BY XINLEI XU 2025/04/03
ENDCLASS.



CLASS ZCL_BI007_JOB IMPLEMENTATION.


  METHOD add_message_to_log.
    TRY.
        IF sy-batch = abap_true.
          DATA(lo_free_text) = cl_bali_free_text_setter=>create(
                                 severity = COND #( WHEN i_type IS NOT INITIAL
                                                    THEN i_type
                                                    ELSE if_bali_constants=>c_severity_status )
                                 text     = i_text ).

          lo_free_text->set_detail_level( detail_level = '1' ).

          mo_application_log->add_item( item = lo_free_text ).

          cl_bali_log_db=>get_instance( )->save_log( log = mo_application_log
                                                     assign_to_current_appl_job = abap_true ).

        ELSE.
*          mo_out->write( i_text ).
        ENDIF.
      CATCH cx_bali_runtime ##NO_HANDLER.
    ENDTRY.
*&--ADD END BY XINLEI XU 2025/04/03
  ENDMETHOD.


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

    " create log handle
    init_application_log(  ).

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
          ls_para-low  = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = ls_para-low ).
          ls_para-high = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = ls_para-high ).
          APPEND CORRESPONDING #( ls_para ) TO mr_prod.
        WHEN 'S_CUST'.
          ls_para-low = |{ ls_para-low  ALPHA = IN }|.
          ls_para-low = |{ ls_para-high ALPHA = IN }|.
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
      DATA:lv_poper      TYPE poper.
      DATA:lv_popern2    TYPE n LENGTH 2.
      DATA:lv_gjahr TYPE gjahr.

      GET TIME STAMP FIELD DATA(lv_timestamp_local).
      lv_datetime     = lv_timestamp_local.
      lv_date_local   = lv_datetime+0(8).
      zzcl_common_utils=>get_fiscal_year_period( EXPORTING iv_date   = lv_date_local
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
    DATA(lo_data_handler) = NEW zcl_bi007_data( ir_companycode = mr_bukrs
                                                ir_fiscalyear = mr_year
                                                ir_fiscalperiod = mr_monat
                                                ir_forcastyear = mr_forcastyear
                                                ir_forcastperiod = mr_forcastperiod
                                                ir_plant = mr_plant
                                                ir_product = mr_prod
                                                ir_customer = mr_cust ).
    DATA lt_data TYPE STANDARD TABLE OF zi_bi007_report.
    lo_data_handler->get_data( IMPORTING et_data = lt_data ).

    "Step 3. Update Table
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
                                                    base_year_month = basefiscalyearmonth ).

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
******Modify start on 20250418*******************
*      lv_base_month = ls_monat-low.
      lv_base_month = ls_monat-low+1(2).
******Modify end on 20250418*******************
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
*&--ADD BEGIN BY XINLEI XU 2025/04/08
      SELECT COUNT(*)
        FROM ztbi_bi007_j01
       WHERE base_year_month = @lv_last_base_year_month AND ( fiscal_year <> @lv_base_year OR period <> @lv_base_month )
        INTO @DATA(lv_count1).
      IF lv_count1 > 0.
        DELETE FROM ztbi_bi007_j01 WHERE base_year_month = @lv_last_base_year_month AND ( fiscal_year <> @lv_base_year OR period <> @lv_base_month ).
      ENDIF.
    ENDIF.

*****Add start on 20250418************************
    DATA:
      lv_start_year      TYPE gjahr,
      lv_start_poper     TYPE monat,
      lv_start_yearmonth TYPE c LENGTH 6,
      lv_end_year        TYPE gjahr,
      lv_end_poper       TYPE monat,
      lv_end_yearmonth   TYPE c LENGTH 6,
      lv_diff            TYPE i.

    IF lv_base_month = '12'.
      lv_start_year = lv_base_year + 1.
      lv_start_poper = '01'.
    ELSE.
      lv_start_year = lv_base_year.
      lv_start_poper = lv_base_month + 1.
    ENDIF.
    lv_start_yearmonth = |{ lv_start_year }{ lv_start_poper }|.

    lv_end_poper = lv_start_poper + 11.
    lv_diff = lv_end_poper - 12.
    IF lv_diff = 0.
      lv_end_year = lv_start_year.
      lv_end_poper = '12'.
    ELSE.
      lv_end_year = lv_start_year + 1.
      lv_end_poper = lv_diff.
    ENDIF.
    lv_end_yearmonth = |{ lv_end_year }{ lv_end_poper }|.
*****Add end on 20250418***************************************

    TRY.
******Modify start on 20250418**********************************
*        add_message_to_log( i_text = |YearMonth: { lv_base_year }、{ lv_base_month }|
*                            i_type = 'S' ).
        add_message_to_log( i_text = |YearMonth: { lv_start_yearmonth } - { lv_end_yearmonth }|
                            i_type = 'S' ).
******Modify end on 20250418************************************
      CATCH cx_bali_runtime ##NO_HANDLER.
    ENDTRY.

    IF lv_base_year IS NOT INITIAL AND lv_base_month IS NOT INITIAL.
      DATA(lv_base_year_month) = |{ lv_base_year }{ lv_base_month }|.

      TRY.
******Modify start on 20250418**********************************
*          add_message_to_log( i_text = |YearMonth: { lv_base_year_month }|
*                              i_type = 'S' ).
          add_message_to_log( i_text = |YearMonth: { lv_start_yearmonth } - { lv_end_yearmonth }|
                              i_type = 'S' ).
******Modify end on 20250418************************************
        CATCH cx_bali_runtime ##NO_HANDLER.
      ENDTRY.

      SELECT COUNT(*)
        FROM ztbi_bi007_j01
       WHERE company_code IN @mr_bukrs
         AND base_year_month = @lv_base_year_month
         AND plant IN @mr_plant
         AND product IN @mr_prod
         AND customer IN @mr_cust
        INTO @DATA(lv_count2).

      IF lv_count2 > 0.
        DELETE FROM ztbi_bi007_j01 WHERE company_code IN @mr_bukrs
                                     AND base_year_month = @lv_base_year_month
                                     AND plant IN @mr_plant
                                     AND product IN @mr_prod
                                     AND customer IN @mr_cust.
      ENDIF.
    ENDIF.

    TRY.
        add_message_to_log( i_text = |テーブル ZTBI_BI007_J01 データ { lv_count1 + lv_count2 }件削除。|
                            i_type = 'S' ).
      CATCH cx_bali_runtime ##NO_HANDLER.
    ENDTRY.
*&--ADD END BY XINLEI XU 2025/04/08

    MODIFY ztbi_bi007_j01 FROM TABLE @lt_save_data.
*&--ADD BEGIN BY XINLEI XU 2025/04/03
    IF sy-subrc = 0.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
      TRY.
          add_message_to_log( i_text = |テーブル ZTBI_BI007_J01 データの更新に失敗しました。|
                              i_type = 'E' ).
        CATCH cx_bali_runtime ##NO_HANDLER.
      ENDTRY.
      RETURN.
    ENDIF.

    TRY.
        add_message_to_log( i_text = |テーブル ZTBI_BI007_J01 データ { lines( lt_save_data ) }件更新。|
                            i_type = 'S' ).
      CATCH cx_bali_runtime ##NO_HANDLER.
    ENDTRY.
*&--ADD END BY XINLEI XU 2025/04/03
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.
    lt_parameters = VALUE #( ( selname = 'S_BUKRS'
                               kind    = if_apj_dt_exec_object=>select_option
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '1100' )
                             ( selname      = 'P_YEAR'
                               kind    = if_apj_dt_exec_object=>parameter
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '2024' )

                             ( selname = 'P_MONAT'
                               kind    = if_apj_dt_exec_object=>parameter
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '12' )
                            ).
    TRY.
        if_apj_dt_exec_object~get_parameters( IMPORTING et_parameter_val = lt_parameters ).

        if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_root INTO DATA(lo_root).
        out->write( |Exception has occured: { lo_root->get_text(  ) }| ).
    ENDTRY.
  ENDMETHOD.


  METHOD init_application_log.
*&--ADD BEGIN BY XINLEI XU 2025/04/03
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object    = 'ZZ_LOG_BI007'
                                                                       subobject = 'ZZ_LOG_BI007_SUB' ) ).
      CATCH cx_bali_runtime ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
