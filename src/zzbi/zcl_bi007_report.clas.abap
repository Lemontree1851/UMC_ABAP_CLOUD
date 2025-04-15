CLASS zcl_bi007_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      ty_t_companycode   TYPE RANGE OF ztfi_1019-companycode,
      ty_t_product       TYPE RANGE OF ztfi_1019-product,
      ty_t_customer      TYPE RANGE OF kunnr,
      ty_t_fiscalyear    TYPE RANGE OF ztfi_1019-fiscalyear,
      ty_t_fiscalperiod  TYPE RANGE OF ztfi_1019-fiscalperiod,
      ty_t_plant         TYPE RANGE OF ztfi_1019-plant,
      ty_t_baseyearmonth TYPE RANGE OF ztbi_bi007_j01-base_year_month.

    METHODS: extract_filter IMPORTING io_request       TYPE REF TO if_rap_query_request
                            EXPORTING er_companycode   TYPE ty_t_companycode
                                      er_fiscalyear    TYPE ty_t_fiscalyear
                                      er_fiscalperiod  TYPE ty_t_fiscalperiod
                                      er_forcastyear   TYPE ty_t_fiscalyear
                                      er_forcastperiod TYPE ty_t_fiscalperiod
                                      er_plant         TYPE ty_t_plant
                                      er_product       TYPE ty_t_product
                                      er_customer      TYPE ty_t_customer
                                      er_baseyearmonth TYPE ty_t_baseyearmonth
                            RAISING   cx_rap_query_filter_no_range.
ENDCLASS.


CLASS zcl_bi007_report IMPLEMENTATION.


  METHOD extract_filter.
    DATA: ls_companycode   TYPE LINE OF ty_t_companycode,
          ls_product       TYPE LINE OF ty_t_product,
          ls_customer      TYPE LINE OF ty_t_customer,
          ls_fiscalyear    TYPE LINE OF ty_t_fiscalyear,
          ls_fiscalperiod  TYPE LINE OF ty_t_fiscalperiod,
          ls_forcastyear   TYPE LINE OF ty_t_fiscalyear,
          ls_forcastperiod TYPE LINE OF ty_t_fiscalperiod,
          ls_plant         TYPE LINE OF ty_t_plant,
          ls_baseyearmonth TYPE LINE OF ty_t_baseyearmonth.


    DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).

    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
      LOOP AT ls_filter_cond-range INTO DATA(ls_range).
        CASE ls_filter_cond-name.
          WHEN 'COMPANYCODE'.
            CLEAR ls_companycode.
            ls_companycode-sign   = ls_range-sign.
            ls_companycode-option = ls_range-option.
            ls_companycode-low    = ls_range-low.
            ls_companycode-high = ls_range-high.
            APPEND ls_companycode TO er_companycode.
          WHEN 'BASEFISCALYEAR'.
            CLEAR ls_fiscalyear.
            ls_fiscalyear-sign   = ls_range-sign.
            ls_fiscalyear-option = ls_range-option.
            ls_fiscalyear-low    = ls_range-low.
            ls_fiscalyear-high    = ls_range-high.
            APPEND ls_fiscalyear TO er_fiscalyear.
          WHEN 'BASEPERIOD'.
            CLEAR ls_fiscalperiod.
            ls_fiscalperiod-sign   = ls_range-sign.
            ls_fiscalperiod-option = ls_range-option.
            ls_fiscalperiod-low    = ls_range-low.
            ls_fiscalperiod-high    = ls_range-high.
            APPEND ls_fiscalperiod TO er_fiscalperiod.
          WHEN 'FORCASTFISCALYEAR'.
            CLEAR ls_forcastyear.
            ls_forcastyear-sign   = ls_range-sign.
            ls_forcastyear-option = ls_range-option.
            ls_forcastyear-low    = ls_range-low.
            ls_forcastyear-high    = ls_range-high.
            APPEND ls_forcastyear TO er_forcastyear.
          WHEN 'FORCASTFISCALPERIOD'.
            CLEAR ls_forcastperiod.
            ls_forcastperiod-sign   = ls_range-sign.
            ls_forcastperiod-option = ls_range-option.
            ls_forcastperiod-low    = ls_range-low.
            ls_forcastperiod-high    = ls_range-high.
            APPEND ls_forcastperiod TO er_forcastperiod.
          WHEN 'PRODUCT'.
            CLEAR ls_product.
            ls_product-sign   = ls_range-sign.
            ls_product-option = ls_range-option.
            ls_product-low    = ls_range-low.
            ls_product-high = ls_range-high.
            APPEND ls_product TO er_product.
          WHEN 'CUSTOMER'.
            CLEAR ls_customer.
            ls_customer-sign   = ls_range-sign.
            ls_customer-option = ls_range-option.
            ls_customer-low    = ls_range-low.
            ls_customer-high = ls_range-high.
            APPEND ls_customer TO er_customer.
          WHEN 'PLANT'.
            CLEAR ls_plant.
            ls_plant-sign   = ls_range-sign.
            ls_plant-option = ls_range-option.
            ls_plant-low    = ls_range-low.
            ls_plant-high = ls_range-high.
            APPEND ls_plant TO er_plant.
*&--ADD BEGIN BY XINLEI XU 2025/04/03
          WHEN 'BASEFISCALYEARMONTH'.
            CLEAR ls_baseyearmonth.
            ls_baseyearmonth-sign   = ls_range-sign.
            ls_baseyearmonth-option = ls_range-option.
            ls_baseyearmonth-low    = ls_range-low.
            ls_baseyearmonth-high = ls_range-high.
            APPEND ls_baseyearmonth TO er_baseyearmonth.
*&--ADD END BY XINLEI XU 2025/04/03
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA: lr_companycode   TYPE ty_t_companycode,
          lr_product       TYPE ty_t_product,
          lr_customer      TYPE ty_t_customer,
          lr_fiscalyear    TYPE ty_t_fiscalyear,
          lr_fiscalperiod  TYPE ty_t_fiscalperiod,
          lr_forcastyear   TYPE ty_t_fiscalyear,
          lr_forcastperiod TYPE ty_t_fiscalperiod,
          lr_plant         TYPE ty_t_plant,
          lr_baseyearmonth TYPE ty_t_baseyearmonth,
          lt_data          TYPE STANDARD TABLE OF zi_bi007_report WITH DEFAULT KEY.

    "Step 1 Extract Filter
    TRY.
        extract_filter( EXPORTING io_request = io_request
                        IMPORTING er_companycode = lr_companycode
                                  er_fiscalyear = lr_fiscalyear
                                  er_fiscalperiod = lr_fiscalperiod
                                  er_forcastyear = lr_forcastyear
                                  er_forcastperiod = lr_forcastperiod
                                  er_plant = lr_plant
                                  er_product = lr_product
                                  er_customer = lr_customer
                                  er_baseyearmonth = lr_baseyearmonth ).
      CATCH cx_rap_query_filter_no_range.
        io_response->set_data( lt_data ).
        RETURN.
    ENDTRY.

    "Step 2. Get Data
*&--MOD BEGIN BY XINLEI XU 2025/04/03 直接从JOB结果表中取值
*    DATA(lo_data_handler) = NEW zcl_bi007_data( ir_companycode = lr_companycode
*                                                ir_fiscalyear = lr_fiscalyear
*                                                ir_fiscalperiod = lr_fiscalperiod
*                                                ir_forcastyear = lr_forcastyear
*                                                ir_forcastperiod = lr_forcastperiod
*                                                ir_plant = lr_plant
*                                                ir_product = lr_product
*                                                ir_customer = lr_customer ).
*
*    lo_data_handler->get_data( IMPORTING et_data = lt_data ).

    SELECT *
      FROM zi_bi007_report_job WITH PRIVILEGED ACCESS
     WHERE companycode IN @lr_companycode
       AND baseyearmonth IN @lr_baseyearmonth
       AND fiscalyear IN @lr_forcastyear      " 予測年度
       AND fiscalperiod IN @lr_forcastperiod  " 予測期間
       AND plant IN @lr_plant
       AND product IN @lr_product
       AND customer IN @lr_customer
      INTO CORRESPONDING FIELDS OF TABLE @lt_data.
*&--MOD END BY XINLEI XU 2025/04/03

    "Step 3. Sorting, Paging
    io_response->set_total_number_of_records( lines( lt_data ) ).

    IF io_request->get_sort_elements( ) IS NOT INITIAL.
      zzcl_odata_utils=>orderby(
        EXPORTING
          it_order = io_request->get_sort_elements( )
        CHANGING
          ct_data  = lt_data ).
    ENDIF.

    zzcl_odata_utils=>paging(
      EXPORTING
        io_paging = io_request->get_paging( )
      CHANGING
        ct_data   = lt_data ).

    io_response->set_data( lt_data ).

  ENDMETHOD.
ENDCLASS.
