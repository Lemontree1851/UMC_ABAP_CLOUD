CLASS zcl_bi007_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      ty_t_companycode  TYPE RANGE OF ztfi_1019-companycode,
      ty_t_product      TYPE RANGE OF ztfi_1019-product,
      ty_t_customer     TYPE RANGE OF kunnr,
      ty_t_fiscalyear   TYPE RANGE OF ztfi_1019-fiscalyear,
      ty_t_fiscalperiod TYPE RANGE OF ztfi_1019-fiscalperiod,
      ty_t_plant        TYPE RANGE OF ztfi_1019-plant,
      ty_t_data         TYPE STANDARD TABLE OF zi_bi007_report.


    METHODS: get_data EXPORTING et_data         TYPE ty_t_data,

      constructor IMPORTING ir_companycode   TYPE ty_t_companycode
                            ir_fiscalyear    TYPE ty_t_fiscalyear
                            ir_fiscalperiod  TYPE ty_t_fiscalperiod
                            ir_forcastyear   TYPE ty_t_fiscalyear
                            ir_forcastperiod TYPE ty_t_fiscalperiod
                            ir_plant         TYPE ty_t_plant
                            ir_product       TYPE ty_t_product
                            ir_customer      TYPE ty_t_customer.
  PROTECTED SECTION.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_searchterm,
             searchterm TYPE c LENGTH 20,
           END OF ty_searchterm.

    TYPES: BEGIN OF ty_price,
             costestimate         TYPE n LENGTH 12,
             currencyrole         TYPE c LENGTH 2,
             ledger               TYPE fins_ledger,
             fiscalperiod         TYPE poper,
             fiscalyear           TYPE gjahr,
             fiscalyearperiod     TYPE fins_fyearperiod,
             material             TYPE matnr,
             valuationarea        TYPE bwkey,
             materialpriceunitqty TYPE peinh,
             materialpricecontrol TYPE vprsv,
             actualprice          TYPE dmbtr,
           END OF ty_price.

    DATA: mr_companycode   TYPE ty_t_companycode,
          mr_fiscalyear    TYPE ty_t_fiscalyear,
          mr_fiscalperiod  TYPE ty_t_fiscalperiod,
          mr_forcastyear   TYPE ty_t_fiscalyear,
          mr_forcastperiod TYPE ty_t_fiscalperiod,
          mr_plant         TYPE ty_t_plant,
          mr_product       TYPE ty_t_product,
          mr_customer      TYPE ty_t_customer.



ENDCLASS.



CLASS zcl_bi007_data IMPLEMENTATION.


  METHOD constructor.
    mr_companycode = ir_companycode.
    mr_fiscalyear = ir_fiscalyear.
    mr_fiscalperiod = ir_fiscalperiod.
    mr_forcastyear = ir_forcastyear.
    mr_forcastperiod = ir_forcastperiod.
    mr_plant = ir_plant.
    mr_product = ir_product.
    mr_customer = ir_customer.
  ENDMETHOD.


  METHOD get_data.
    "Step 1. Get ztfi_1019 Data
    DATA: lt_inventory TYPE STANDARD TABLE OF zi_bi006_report.

    DATA(lo_bi006_handler) = NEW zcl_bi006_data(  ).

    lo_bi006_handler->get_data(
      EXPORTING
        ir_companycode  = mr_companycode
        ir_fiscalyear   = mr_fiscalyear
        ir_fiscalperiod = mr_fiscalperiod
        ir_plant        = mr_plant
        ir_product      = mr_product
        ir_customer     = mr_customer
        iv_detail_only  = abap_true
      IMPORTING
        et_data         = lt_inventory
    ).

    CHECK lt_inventory IS NOT INITIAL.

    "Step 2. Get ztbi_1003 book quantity
    DATA: lv_base_year  TYPE gjahr,
          lv_base_poper TYPE poper,
          lv_yearmonth  TYPE c LENGTH 6,
          lv_yearpoper  TYPE c LENGTH 7.

    READ TABLE mr_fiscalyear INTO DATA(ls_fiscalyear) INDEX 1.
    IF sy-subrc = 0.
      lv_base_year = ls_fiscalyear-low.
    ENDIF.

    READ TABLE mr_fiscalperiod INTO DATA(ls_fiscalperiod) INDEX 1.
    IF sy-subrc = 0.
      lv_base_poper = ls_fiscalperiod-low.
    ENDIF.

    IF lv_base_year IS INITIAL OR lv_base_poper IS INITIAL.
      RETURN.
    ENDIF.

    lv_yearmonth = |{ lv_base_year }{ lv_base_poper+1(2) }|.
    lv_yearpoper = |{ lv_base_year }{ lv_base_poper }|.

    DATA: lt_inventory_tmp LIKE lt_inventory.
    lt_inventory_tmp = lt_inventory.
    SORT lt_inventory_tmp BY companycode plant product.
    DELETE ADJACENT DUPLICATES FROM lt_inventory_tmp COMPARING companycode plant product.

    IF lt_inventory_tmp IS NOT INITIAL.
      SELECT yearmonth,
             type,
             companycode,
             plant,
             product,
             customer,
             demand
      FROM ztbi_1003
      FOR ALL ENTRIES IN @lt_inventory_tmp
      WHERE companycode = @lt_inventory_tmp-companycode
      AND plant = @lt_inventory_tmp-plant
      AND product = @lt_inventory_tmp-product
      AND customer IN @mr_customer
      AND yearmonth > @lv_yearpoper
      INTO TABLE @DATA(lt_book).
    ENDIF.

    "Combine data
    DATA: lv_start_year            TYPE gjahr,
          lv_start_poper           TYPE c LENGTH 2,
          lv_start_yearmonth       TYPE c LENGTH 6,
          lv_forcast_year          TYPE gjahr,
          lv_forcast_poper         TYPE c LENGTH 2,
          lv_forcast_yearmonth     TYPE c LENGTH 6,
          lv_forcast_period        TYPE c LENGTH 7,
          lv_look_back_start_age   TYPE ztfi_1019-age,
          lv_look_back_dynamic_age TYPE ztfi_1019-age,
          lv_index                 TYPE i,
          lv_do_count              TYPE i,
          lv_demand                TYPE ztbi_1003-demand,
          lv_inventory             TYPE ztfi_1019-qty,
          lv_calc_flag             TYPE abap_bool,
          ls_data                  LIKE LINE OF et_data,
          lt_inventory_group       LIKE lt_inventory,
          lt_inventory1            LIKE lt_inventory,
          lt_inventory2            LIKE lt_inventory,
          lv_book_total            TYPE ztbi_1003-demand,
          lv_inventory_total       TYPE ztfi_1019-qty.

    "Initial Forcast start month = base month + 1.
    IF  lv_base_poper = '012'.
      lv_start_year = lv_base_year + 1.
      lv_start_poper = '01'.
    ELSE.
      lv_start_year = lv_base_year.
      lv_start_poper = lv_base_poper+1(2) + 1.
    ENDIF.
    lv_start_poper = |{ lv_start_poper ALPHA = IN }|.
    lv_start_yearmonth = |{ lv_start_year }{ lv_start_poper }|.
    CLEAR lv_calc_flag.

    lt_inventory_group = lt_inventory.
    SORT lt_inventory_group BY companycode fiscalyear fiscalperiod plant product customer ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_inventory_group COMPARING companycode fiscalyear fiscalperiod plant product customer.

    SORT lt_inventory BY companycode ASCENDING plant ASCENDING product ASCENDING customer ASCENDING fiscalyearmonth ASCENDING age DESCENDING.
    SORT lt_book BY companycode plant product yearmonth.


    LOOP AT lt_inventory_group INTO DATA(ls_inventory).
      "The first run forcast constants
      lv_forcast_year = lv_start_year.
      lv_forcast_poper = lv_start_poper.
      lv_forcast_yearmonth = lv_start_yearmonth.
      lv_forcast_period = |{ lv_forcast_year }0{ lv_forcast_poper }|.
      lv_index = 1.
      lv_do_count = 1.
      CLEAR: lv_book_total, lv_inventory_total, lv_calc_flag.

      "The first run inventory look back constants
      IF ls_inventory-producttype = 'ZROH'.
        lv_look_back_start_age = '012'.
      ELSE.
        lv_look_back_start_age = '003'.
      ENDIF.
      lv_look_back_dynamic_age = lv_look_back_start_age.

      DO 12 TIMES.

        CLEAR: ls_data, lv_demand, lv_inventory, lv_index.

        "Calculate book value
        " for example : base month: 08 forcast 09: book value = ztbi_1003 09 book value
        "               base month: 08 forcast 10: book value = ztbi_1003 09 book value + 10 book value.
        READ TABLE lt_book WITH KEY companycode = ls_inventory-companycode
                                    plant = ls_inventory-plant
                                    product = ls_inventory-product
                                    "customer = ls_inventory-customer
                                    yearmonth = lv_forcast_period
                                    BINARY SEARCH
                                    TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          lv_index = sy-tabix.

          "First Calculate the current month demand, then add to total, reduce loop count.
          LOOP AT lt_book INTO DATA(ls_book) FROM lv_index WHERE companycode = ls_inventory-companycode
                                           AND  plant = ls_inventory-plant
                                           AND  product = ls_inventory-product
                                           "AND  customer = ls_inventory-customer
                                           AND  yearmonth = lv_forcast_period.
            lv_demand = lv_demand + ls_book-demand.
          ENDLOOP.

          "Total book value from first month to current month
          lv_book_total = lv_book_total + lv_demand.
        ENDIF.

*        LOOP AT lt_book INTO DATA(ls_book) WHERE companycode = ls_inventory-companycode
*                                            AND  plant = ls_inventory-plant
*                                            AND  product = ls_inventory-product
*                                            AND  customer = ls_inventory-customer
*                                            AND  yearmonth >= lv_start_yearmonth AND yearmonth <= lv_forcast_yearmonth.
*          lv_demand = lv_demand + ls_book-demand.
*        ENDLOOP.

        "Calculate inventory long-term value
        " for example : base month: 08 forcast 09: look back value = ztbi_1019 Raw material aging 12~36 values, Finished goods: aging 3~36 values
        "               base month: 08 forcast 10: look back value = ztbi_1019 Raw material aging 11~36 values, Finished goods: aging 2~36 values

        CLEAR lv_index.
        READ TABLE lt_inventory WITH KEY companycode = ls_inventory-companycode
                                         plant = ls_inventory-plant
                                         product = ls_inventory-product
                                         customer = ls_inventory-customer
                                         fiscalyearmonth = ls_inventory-fiscalyearmonth
                                         BINARY SEARCH
                                         TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          lv_index = sy-tabix.

          "if the dynamic look back age equals 001, do not need to calculate any more
          IF lv_look_back_dynamic_age > '001'.

            "Look back inventory aging, for example raw material: forcast first month aging qty: 12-36, second month aging qty 11-36, third month 10-36...
            "first calculate the most lastest aging: 12, then add to total, reduce loop count, aging will reduce 1 after each do count
            "
            IF lv_do_count = 1.
              LOOP AT lt_inventory INTO DATA(ls_lookback) FROM lv_index WHERE companycode = ls_inventory-companycode
                                                                    AND  plant = ls_inventory-plant
                                                                    AND  product = ls_inventory-product
                                                                    AND  customer = ls_inventory-customer
                                                                    AND  fiscalyearmonth = ls_inventory-fiscalyearmonth
                                                                    AND age >= lv_look_back_dynamic_age.
                lv_inventory = lv_inventory + ls_lookback-qty.
              ENDLOOP.
            ELSE.
              LOOP AT lt_inventory INTO ls_lookback FROM lv_index WHERE companycode = ls_inventory-companycode
                                                                    AND  plant = ls_inventory-plant
                                                                    AND  product = ls_inventory-product
                                                                    AND  customer = ls_inventory-customer
                                                                    AND  fiscalyearmonth = ls_inventory-fiscalyearmonth
                                                                    AND age = lv_look_back_dynamic_age.
                lv_inventory = lv_inventory + ls_lookback-qty.
              ENDLOOP.
            ENDIF.

            lv_inventory_total = lv_inventory_total + lv_inventory.
          ELSE.
            IF lv_calc_flag = abap_false.
              LOOP AT lt_inventory INTO ls_lookback FROM lv_index WHERE companycode = ls_inventory-companycode
                                                                    AND  plant = ls_inventory-plant
                                                                    AND  product = ls_inventory-product
                                                                    AND  customer = ls_inventory-customer
                                                                    AND  fiscalyearmonth = ls_inventory-fiscalyearmonth
                                                                    AND age = lv_look_back_dynamic_age.
                lv_inventory = lv_inventory + ls_lookback-qty.
                lv_calc_flag = abap_true.
              ENDLOOP.

              lv_inventory_total = lv_inventory_total + lv_inventory.
            ENDIF.
          ENDIF.
        ENDIF.

*        LOOP AT lt_inventory INTO DATA(ls_lookback) WHERE companycode = ls_inventory-companycode
*                                                      AND  plant = ls_inventory-plant
*                                                      AND  product = ls_inventory-product
*                                                      AND  customer = ls_inventory-customer
*                                                      AND  fiscalyearmonth = ls_inventory-fiscalyearmonth
*                                                      AND age >= lv_look_back_dynamic_age.
*          lv_inventory = lv_inventory + ls_lookback-qty.
*        ENDLOOP.

        MOVE-CORRESPONDING ls_inventory TO ls_data.
        ls_data-type = '長滞予測'.
        "ls_data-qty = lv_inventory - lv_demand.
        ls_data-qty = lv_inventory_total - lv_book_total.
        ls_data-inventoryamount = ls_data-actualprice * ls_data-qty.
        ls_data-basefiscalyear = lv_base_year.
        ls_data-baseperiod = lv_base_poper.

        ls_data-basefiscalyearmonth = lv_yearmonth.
        ls_data-fiscalyearmonth = lv_forcast_yearmonth.
        ls_data-forcastfiscalyear = lv_forcast_year.
        ls_data-forcastfiscalperiod = lv_forcast_poper.
        ls_data-forcastperiod = lv_forcast_poper.

        APPEND ls_data TO et_data.


        "Update Dynamic Year
        IF lv_forcast_poper = '12'.
          lv_forcast_year = lv_forcast_year + 1.
          lv_forcast_poper = '01'.
        ELSE.
          lv_forcast_poper = lv_forcast_poper + 1.
        ENDIF.


        lv_forcast_poper = |{ lv_forcast_poper ALPHA = IN }|.
        lv_forcast_yearmonth = |{ lv_forcast_year }{ lv_forcast_poper }|.
        lv_forcast_period = |{ lv_forcast_year }0{ lv_forcast_poper }|.

        "Update Look back inventory age
        IF lv_look_back_dynamic_age <= '001'.
          lv_look_back_dynamic_age = '001'.
        ELSE.
          lv_look_back_dynamic_age = lv_look_back_dynamic_age - 1.
        ENDIF.

        lv_look_back_dynamic_age = |{ lv_look_back_dynamic_age ALPHA = IN }|.

        lv_do_count = lv_do_count + 1.
      ENDDO.

    ENDLOOP.
    DELETE et_data WHERE forcastfiscalyear NOT IN mr_forcastyear OR forcastperiod NOT IN mr_forcastperiod.


  ENDMETHOD.
ENDCLASS.
