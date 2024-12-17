CLASS zcl_get_inv_aging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_inventorypricebykeydate,
        fiscalyearperiod TYPE i_inventorypricebykeydate-fiscalyearperiod,
        ledger           TYPE i_inventorypricebykeydate-ledger,
        material         TYPE i_inventorypricebykeydate-material,
        valuationarea    TYPE i_inventorypricebykeydate-valuationarea,
        actualprice      TYPE i_inventorypricebykeydate-actualprice,
      END OF ty_inventorypricebykeydate,

      BEGIN OF ty_inventoryamtbyfsclperd,
        fiscalperiod                TYPE i_inventoryamtbyfsclperd-fiscalperiod,
        fiscalyear                  TYPE i_inventoryamtbyfsclperd-fiscalyear,
        costestimate                TYPE i_inventoryamtbyfsclperd-costestimate,
        ledger                      TYPE i_inventoryamtbyfsclperd-ledger,
        material                    TYPE i_inventoryamtbyfsclperd-material,
        valuationarea               TYPE i_inventoryamtbyfsclperd-valuationarea,
        amountincompanycodecurrency TYPE i_inventoryamtbyfsclperd-amountincompanycodecurrency,
      END OF ty_inventoryamtbyfsclperd.

    CONSTANTS:
      lc_fiyearvariant_v3      TYPE string VALUE 'V3',
      lc_currencyrole_10       TYPE string VALUE '10',
      lc_invspecialstocktype_t TYPE string VALUE 'T',
      lc_invspecialstocktype_e TYPE string VALUE 'E',
      lc_sign_i                TYPE c LENGTH 1 VALUE 'I',
      lc_option_eq             TYPE c LENGTH 2 VALUE 'EQ'.
ENDCLASS.



CLASS ZCL_GET_INV_AGING IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA:
      lt_original_data               TYPE STANDARD TABLE OF zc_inv_aging WITH DEFAULT KEY,
      lt_inventorypricebykeydate     TYPE STANDARD TABLE OF ty_inventorypricebykeydate,
      lt_inventorypricebykeydate_tmp TYPE STANDARD TABLE OF ty_inventorypricebykeydate,
      lt_inventoryamtbyfsclperd      TYPE STANDARD TABLE OF ty_inventoryamtbyfsclperd,
      lt_inventoryamtbyfsclperd_sum  TYPE STANDARD TABLE OF ty_inventoryamtbyfsclperd,
      lr_searchterm2                 TYPE RANGE OF i_businesspartner-searchterm2,
      lr_fiscalyearperiod            TYPE RANGE OF i_fiscalyearperiodforvariant-fiscalyearperiod,
      lv_searchterm2                 TYPE i_businesspartner-searchterm2,
      lv_fiscalyearperiod            TYPE i_fiscalyearperiodforvariant-fiscalyearperiod.

    lt_original_data = CORRESPONDING #( it_original_data ).

    DATA(lt_original_data_tmp) = lt_original_data.
    SORT lt_original_data_tmp BY mrpresponsible.
    DELETE ADJACENT DUPLICATES FROM lt_original_data_tmp
                          COMPARING mrpresponsible.

    LOOP AT lt_original_data_tmp INTO DATA(ls_original_data).
      IF ls_original_data-mrpresponsible IS NOT INITIAL.
        DATA(lv_length) = strlen( ls_original_data-mrpresponsible ).
        DATA(lv_offset) = lv_length - 2.

        IF lv_offset >= 0.
          lr_searchterm2 = VALUE #( BASE lr_searchterm2 sign = lc_sign_i option = lc_option_eq ( low = ls_original_data-mrpresponsible+lv_offset(2) ) ).
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lr_searchterm2 IS NOT INITIAL.
      "Obtain data of business partner
      SELECT businesspartner,
             searchterm2,
             businesspartnername
        FROM i_businesspartner WITH PRIVILEGED ACCESS
       WHERE searchterm2 IN @lr_searchterm2
        INTO TABLE @DATA(lt_businesspartner).
    ENDIF.

    lt_original_data_tmp = lt_original_data.
    SORT lt_original_data_tmp BY profitcenter.
    DELETE ADJACENT DUPLICATES FROM lt_original_data_tmp
                          COMPARING profitcenter.

    IF lt_original_data_tmp IS NOT INITIAL.
      "Obtain data of profit center text
      SELECT profitcenter,
             profitcentername,
             profitcenterlongname
        FROM i_profitcentertext WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_original_data_tmp
       WHERE profitcenter = @lt_original_data_tmp-profitcenter
         AND language = 'J'"@sy-langu
        INTO TABLE @DATA(lt_profitcentertext).
    ENDIF.

    lt_original_data_tmp = lt_original_data.
    SORT lt_original_data_tmp BY fiscalyear fiscalperiod.
    DELETE ADJACENT DUPLICATES FROM lt_original_data_tmp
                          COMPARING fiscalyear fiscalperiod.

    LOOP AT lt_original_data_tmp INTO ls_original_data.
      lv_fiscalyearperiod = ls_original_data-fiscalyear && ls_original_data-fiscalperiod.
      lr_fiscalyearperiod = VALUE #( BASE lr_fiscalyearperiod sign = lc_sign_i option = lc_option_eq ( low = lv_fiscalyearperiod ) ).
    ENDLOOP.

    IF lr_fiscalyearperiod IS NOT INITIAL.
      "Obtain data of fiscal year period for fiscal year variant
      SELECT fiscalyearperiod,
             fiscalyear,
             fiscalperiod,
             fiscalperiodenddate
        FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
       WHERE fiscalyearvariant = @lc_fiyearvariant_v3
         AND fiscalyearperiod IN @lr_fiscalyearperiod
        INTO TABLE @DATA(lt_fiscalyearperiodforvariant).
    ENDIF.

    lt_original_data_tmp = lt_original_data.
    SORT lt_original_data_tmp BY fiscalyear fiscalperiod ledger product plant .
    DELETE ADJACENT DUPLICATES FROM lt_original_data_tmp
                          COMPARING fiscalyear fiscalperiod ledger product plant.

    LOOP AT lt_fiscalyearperiodforvariant INTO DATA(ls_fiscalyearperiodforvariant).
      "Obtain data of inventory price by key date
      SELECT fiscalyearperiod,
             ledger,
             material,
             valuationarea,
             actualprice
        FROM i_inventorypricebykeydate( p_calendardate = @ls_fiscalyearperiodforvariant-fiscalperiodenddate ) WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_original_data_tmp
       WHERE ledger = @lt_original_data_tmp-ledger
         AND material = @lt_original_data_tmp-product
         AND valuationarea = @lt_original_data_tmp-plant
         AND currencyrole = @lc_currencyrole_10
         AND inventoryspecialstocktype <> @lc_invspecialstocktype_t
        INTO TABLE @lt_inventorypricebykeydate_tmp.
      IF sy-subrc = 0.
        APPEND LINES OF lt_inventorypricebykeydate_tmp TO lt_inventorypricebykeydate.
        CLEAR lt_inventorypricebykeydate_tmp.
      ENDIF.

      "Obtain data of inventory amount for fiscal period
      SELECT fiscalperiod,
             fiscalyear,
             costestimate,
             ledger,
             material,
             valuationarea,
             amountincompanycodecurrency
        FROM i_inventoryamtbyfsclperd( p_fiscalperiod = @ls_fiscalyearperiodforvariant-fiscalperiod, p_fiscalyear = @ls_fiscalyearperiodforvariant-fiscalyear ) WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_original_data_tmp
       WHERE ledger = @lt_original_data_tmp-ledger
         AND material = @lt_original_data_tmp-product
         AND valuationarea = @lt_original_data_tmp-plant
         AND invtryvalnspecialstocktype <> @lc_invspecialstocktype_t
         AND invtryvalnspecialstocktype <> @lc_invspecialstocktype_e
         AND valuationquantity <> 0
         AND amountincompanycodecurrency <> 0
        INTO TABLE @lt_inventoryamtbyfsclperd.

      LOOP AT lt_inventoryamtbyfsclperd INTO DATA(ls_inventoryamtbyfsclperd).
        CLEAR ls_inventoryamtbyfsclperd-costestimate.
        COLLECT ls_inventoryamtbyfsclperd INTO lt_inventoryamtbyfsclperd_sum.
      ENDLOOP.

      CLEAR lt_inventoryamtbyfsclperd.
    ENDLOOP.

    SORT lt_businesspartner BY searchterm2.
    SORT lt_profitcentertext BY profitcenter.
    SORT lt_inventorypricebykeydate BY fiscalyearperiod ledger material valuationarea.
    SORT lt_inventoryamtbyfsclperd_sum BY fiscalperiod fiscalyear ledger material valuationarea .

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      IF <fs_original_data>-mrpresponsible IS NOT INITIAL.
        lv_length = strlen( <fs_original_data>-mrpresponsible ).
        lv_offset = lv_length - 2.

        IF lv_offset >= 0.
          lv_searchterm2 = <fs_original_data>-mrpresponsible+lv_offset(2).

          "Read data of business partner
          READ TABLE lt_businesspartner INTO DATA(ls_businesspartner) WITH KEY searchterm2 = lv_searchterm2
                                                                      BINARY SEARCH.
          IF sy-subrc = 0.
            <fs_original_data>-businesspartner     = ls_businesspartner-businesspartner.
            <fs_original_data>-businesspartnername = ls_businesspartner-businesspartnername.
          ENDIF.
        ENDIF.
      ENDIF.

      "Read data of profit center text
      READ TABLE lt_profitcentertext INTO DATA(ls_profitcentertext) WITH KEY profitcenter = <fs_original_data>-profitcenter
                                                                    BINARY SEARCH.
      IF sy-subrc = 0.
        IF ls_profitcentertext-profitcenterlongname IS NOT INITIAL.
          <fs_original_data>-profitcenterlongname = ls_profitcentertext-profitcenterlongname.
        ELSE.
          <fs_original_data>-profitcenterlongname = ls_profitcentertext-profitcentername.
        ENDIF.
      ENDIF.

      lv_fiscalyearperiod = <fs_original_data>-fiscalyear && <fs_original_data>-fiscalperiod.

      "Read data of product valuation
      READ TABLE lt_inventorypricebykeydate INTO DATA(ls_inventorypricebykeydate) WITH KEY fiscalyearperiod = lv_fiscalyearperiod
                                                                                           ledger = <fs_original_data>-ledger
                                                                                           material = <fs_original_data>-product
                                                                                           valuationarea = <fs_original_data>-plant
                                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_original_data>-actualcost = ls_inventorypricebykeydate-actualprice.
      ENDIF.

      "Read data of inventory amount for fiscal period
      READ TABLE lt_inventoryamtbyfsclperd_sum INTO ls_inventoryamtbyfsclperd WITH KEY fiscalperiod = <fs_original_data>-fiscalperiod
                                                                                       fiscalyear = <fs_original_data>-fiscalyear
                                                                                       ledger = <fs_original_data>-ledger
                                                                                       material = <fs_original_data>-product
                                                                                       valuationarea = <fs_original_data>-plant
                                                                              BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_original_data>-inventoryamount = ls_inventoryamtbyfsclperd-amountincompanycodecurrency.
      ENDIF.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.
ENDCLASS.
