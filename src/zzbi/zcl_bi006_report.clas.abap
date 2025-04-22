CLASS zcl_bi006_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      ty_t_companycode  TYPE RANGE OF ztfi_1019-companycode,
      ty_t_product      TYPE RANGE OF ztfi_1019-product,
      ty_t_customer     TYPE RANGE OF kunnr,
      ty_t_fiscalyear   TYPE RANGE OF ztfi_1019-fiscalyear,
      ty_t_fiscalperiod TYPE RANGE OF ztfi_1019-fiscalperiod,
      ty_t_plant        TYPE RANGE OF ztfi_1019-plant.


    METHODS: extract_filter IMPORTING io_request      TYPE REF TO if_rap_query_request
                            EXPORTING er_companycode  TYPE ty_t_companycode
                                      er_fiscalyear   TYPE ty_t_fiscalyear
                                      er_fiscalperiod TYPE ty_t_fiscalperiod
                                      er_plant        TYPE ty_t_plant
                                      er_product      TYPE ty_t_product
                                      er_customer     TYPE ty_t_customer
                            RAISING   cx_rap_query_filter_no_range.
ENDCLASS.



CLASS ZCL_BI006_REPORT IMPLEMENTATION.


  METHOD extract_filter.
    DATA: ls_companycode  TYPE LINE OF ty_t_companycode,
          ls_product      TYPE LINE OF ty_t_product,
          ls_customer     TYPE LINE OF ty_t_customer,
          ls_fiscalyear   TYPE LINE OF ty_t_fiscalyear,
          ls_fiscalperiod TYPE LINE OF ty_t_fiscalperiod,
          ls_plant        TYPE LINE OF ty_t_plant.

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
          WHEN 'FISCALYEAR'.
            CLEAR ls_fiscalyear.
            ls_fiscalyear-sign   = ls_range-sign.
            ls_fiscalyear-option = ls_range-option.
            ls_fiscalyear-low    = ls_range-low.
            ls_fiscalyear-high    = ls_range-high.
            APPEND ls_fiscalyear TO er_fiscalyear.
          WHEN 'PERIOD'.
            CLEAR ls_fiscalperiod.
            ls_fiscalperiod-sign   = ls_range-sign.
            ls_fiscalperiod-option = ls_range-option.
            ls_fiscalperiod-low    = ls_range-low.
            ls_fiscalperiod-high    = ls_range-high.
            APPEND ls_fiscalperiod TO er_fiscalperiod.
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
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA:
      lr_companycode  TYPE ty_t_companycode,
      lr_product      TYPE ty_t_product,
      lr_customer     TYPE ty_t_customer,
      lr_fiscalyear   TYPE ty_t_fiscalyear,
      lr_fiscalperiod TYPE ty_t_fiscalperiod,
      lr_plant        TYPE ty_t_plant,
      lt_data         TYPE STANDARD TABLE OF zi_bi006_report WITH DEFAULT KEY.

    "Step 1 Extract Filter
    TRY.
        extract_filter( EXPORTING io_request = io_request
                        IMPORTING er_companycode = lr_companycode
                                  er_fiscalyear = lr_fiscalyear
                                  er_fiscalperiod = lr_fiscalperiod
                                  er_plant = lr_plant
                                  er_product = lr_product
                                  er_customer = lr_customer
                      ).
      CATCH cx_rap_query_filter_no_range.
        io_response->set_data( lt_data ).
        RETURN.
    ENDTRY.

    "Step 2. Get Data
*&--MOD BEGIN BY XINLEI XU 2025/04/03 直接从JOB结果表中取值
*    DATA(lo_data_handler) = NEW zcl_bi006_data( ).
*    lo_data_handler->get_data( EXPORTING ir_companycode = lr_companycode
*                                         ir_fiscalyear = lr_fiscalyear
*                                         ir_fiscalperiod = lr_fiscalperiod
*                                         ir_plant = lr_plant
*                                         ir_product = lr_product
*                                         ir_customer = lr_customer
*                               IMPORTING et_data = lt_data ).
    SELECT *
      FROM zi_bi006_report_job WITH PRIVILEGED ACCESS
     WHERE companycode IN @lr_companycode
       AND fiscalyear IN @lr_fiscalyear
       AND fiscalperiod IN @lr_fiscalperiod
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
