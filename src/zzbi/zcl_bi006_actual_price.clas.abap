CLASS zcl_bi006_actual_price DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
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

ENDCLASS.



CLASS zcl_bi006_actual_price IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_inventory           TYPE STANDARD TABLE OF zi_bi006_inventory_detail WITH DEFAULT KEY,
          lt_price               TYPE STANDARD TABLE OF ty_price,
          lv_date                TYPE datum.
    lt_inventory = CORRESPONDING #( it_original_data  ).

    CHECK lt_inventory IS NOT INITIAL.

    SELECT c~companycode,
           f~fiscalyear,
           f~fiscalperiod,
           f~fiscalperiodenddate
    FROM i_companycode AS c
    INNER JOIN i_fiscalcalendardate AS f
    ON c~fiscalyearvariant = f~fiscalyearvariant
    FOR ALL ENTRIES IN @lt_inventory
    WHERE c~companycode = @lt_inventory-companycode
    AND f~fiscalyear = @lt_inventory-fiscalyear
    AND f~fiscalperiod = @lt_inventory-fiscalperiod
    INTO TABLE @DATA(lt_posting_date).

    SORT lt_posting_date BY companycode ASCENDING fiscalyear ASCENDING fiscalperiod ASCENDING fiscalperiodenddate DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_posting_date COMPARING companycode fiscalyear fiscalperiod.

    LOOP AT lt_posting_date INTO DATA(ls_posting_date).
      lv_date = ls_posting_date-fiscalperiodenddate.
      SELECT costestimate,
              currencyrole,
              ledger,
              fiscalperiod,
              fiscalyear,
              fiscalyearperiod,
              material,
              valuationarea,
              materialpriceunitqty,
              materialpricecontrol,
              actualprice
     FROM i_inventorypricebykeydate( p_calendardate = @lv_date )
     FOR ALL ENTRIES IN @lt_inventory
     WHERE ledger = @lt_inventory-ledger
     AND material = @lt_inventory-product
     AND currencyrole = '10'
     AND valuationarea = @lt_inventory-valuationarea
     APPENDING CORRESPONDING FIELDS OF TABLE @lt_price.
    ENDLOOP.

    SORT lt_price BY fiscalyear fiscalperiod material valuationarea materialpricecontrol.

    LOOP AT lt_inventory INTO DATA(ls_inventory).
      CLEAR: lv_date, ls_posting_date.
      READ TABLE lt_posting_date INTO ls_posting_date WITH KEY companycode = ls_inventory-companycode.
      IF sy-subrc = 0.
        lv_date = ls_posting_date-fiscalperiodenddate.
      ENDIF.

      READ TABLE lt_price INTO DATA(ls_price) WITH KEY fiscalyear = ls_inventory-fiscalyear
                                                       fiscalperiod = ls_inventory-fiscalperiod
                                                       material = ls_inventory-product
                                                       valuationarea = ls_inventory-valuationarea
                                                       materialpricecontrol = 'V'
                                                       BINARY SEARCH.
      IF sy-subrc = 0.
        IF ls_price-materialpriceunitqty <> 0.
          ls_inventory-actualprice = ls_price-actualprice / ls_price-materialpriceunitqty.
        ELSE.
          ls_inventory-actualprice = ls_price-actualprice.
        ENDIF.
      ELSE.
        READ TABLE lt_price INTO ls_price WITH KEY fiscalyear = ls_inventory-fiscalyear
                                                        fiscalperiod = ls_inventory-fiscalperiod
                                                        material = ls_inventory-product
                                                        valuationarea = ls_inventory-valuationarea
                                                        materialpricecontrol = 'S'
                                                        BINARY SEARCH.
        IF sy-subrc = 0.
          IF ls_price-materialpriceunitqty <> 0.
            ls_inventory-actualprice = ls_price-actualprice / ls_price-materialpriceunitqty.
          ELSE.
            ls_inventory-actualprice = ls_price-actualprice.
          ENDIF.
        ENDIF.
      ENDIF.

      MODIFY lt_inventory FROM ls_inventory.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_inventory ).


  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.

ENDCLASS.
