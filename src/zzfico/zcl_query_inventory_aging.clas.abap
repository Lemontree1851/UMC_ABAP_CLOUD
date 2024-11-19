CLASS zcl_query_inventory_aging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_query_inventory_aging IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    TYPES:
      BEGIN OF ty_inventoryamtbyfsclperd,
        costestimate                TYPE i_inventoryamtbyfsclperd-costestimate,
        material                    TYPE i_inventoryamtbyfsclperd-material,
        valuationarea               TYPE i_inventoryamtbyfsclperd-valuationarea,
        valuationquantity           TYPE i_inventoryamtbyfsclperd-valuationquantity,
        amountincompanycodecurrency TYPE i_inventoryamtbyfsclperd-amountincompanycodecurrency,
      END OF ty_inventoryamtbyfsclperd,

      BEGIN OF ty_finalproductinfo,
        product  TYPE matnr,
        plant    TYPE werks_d,
        material TYPE matnr,
      END OF ty_finalproductinfo.

    DATA:
      lt_data                       TYPE STANDARD TABLE OF zc_inventory_aging,
      lt_inventoryamtbyfsclperd     TYPE STANDARD TABLE OF ty_inventoryamtbyfsclperd,
      lt_inventoryamtbyfsclperd_sum TYPE STANDARD TABLE OF ty_inventoryamtbyfsclperd,
      lt_finalproductinfo           TYPE STANDARD TABLE OF ty_finalproductinfo,
      lt_usagelist                  TYPE STANDARD TABLE OF zcl_bom_where_used=>ty_usagelist,
      lr_searchterm2                TYPE RANGE OF i_businesspartner-searchterm2,
      ls_data                       TYPE zc_inventory_aging,
      ls_finalproductinfo           TYPE ty_finalproductinfo,
      lv_companycode                TYPE zc_inventory_aging-companycode,
      lv_fiscalyear                 TYPE zc_inventory_aging-fiscalyear,
      lv_fiscalperiod               TYPE zc_inventory_aging-fiscalperiod,
      lv_ledger                     TYPE zc_inventory_aging-ledger,
      lv_valuationunitprice         TYPE zc_inventory_aging-valuationunitprice,
      lv_searchterm2                TYPE i_businesspartner-searchterm2,
      lv_fiscalyearperiod           TYPE i_fiscalyearperiodforvariant-fiscalyearperiod,
      lv_fiscalperiodstartdate      TYPE d,
      lv_fiscalperiodenddate        TYPE d.

    CONSTANTS:
      lc_alpha_out        TYPE string VALUE 'OUT',
      lc_fiyearvariant_v3 TYPE string VALUE 'V3',
      lc_sign_i           TYPE c LENGTH 1 VALUE 'I',
      lc_option_eq        TYPE c LENGTH 2 VALUE 'EQ'.

    TRY.
        "Get and add filter
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
    ENDTRY.

    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
      LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
        CASE ls_filter_cond-name.
          WHEN 'COMPANYCODE'.
            lv_companycode = str_rec_l_range-low.
          WHEN 'FISCALYEAR'.
            lv_fiscalyear = str_rec_l_range-low.
          WHEN 'FISCALPERIOD'.
            lv_fiscalperiod = str_rec_l_range-low.
          WHEN 'LEDGER'.
            lv_ledger = str_rec_l_range-low.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.

    "Obtain data of history inventory aging
    SELECT plant,
           product,
           age,
           qty
      FROM ztfi_1019
     WHERE ledger = @lv_ledger
       AND companycode = @lv_companycode
       AND fiscalyear = @lv_fiscalyear
       AND fiscalperiod = @lv_fiscalperiod
       AND ledger = @lv_ledger
      INTO TABLE @DATA(lt_ztfi_1019).
*    IF sy-subrc = 0.
    "Obtain data of company code currency
*    SELECT SINGLE
*           currency
*      FROM i_companycode WITH PRIVILEGED ACCESS
*     WHERE companycode = @lv_companycode
*      INTO @DATA(lv_currency).

    "Obtain data of product
    SELECT a~valuationarea,
           b~currency,
           c~product,
           c~baseunit,
           c~profitcenter,
           c~mrpresponsible,
           d~producttype,
           e~producttypename,
           f~productdescription,
           g~mrpcontrollername
      FROM i_productvaluationareavh WITH PRIVILEGED ACCESS AS a
     INNER JOIN i_companycode WITH PRIVILEGED ACCESS AS b
        ON b~companycode = a~companycode
     INNER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS c
        ON c~plant = a~valuationarea
     INNER JOIN i_product WITH PRIVILEGED ACCESS AS d
        ON d~product = c~product
      LEFT OUTER JOIN i_producttypetext_2 WITH PRIVILEGED ACCESS AS e
        ON e~producttype = d~producttype
       AND e~language = @sy-langu
      LEFT OUTER JOIN i_productdescription WITH PRIVILEGED ACCESS AS f
        ON f~product = c~product
       AND f~language = @sy-langu
      LEFT OUTER JOIN i_mrpcontrollervh WITH PRIVILEGED ACCESS AS g
        ON g~plant = a~valuationarea
       AND g~mrpcontroller = c~mrpresponsible
     WHERE a~companycode = @lv_companycode
      INTO TABLE @DATA(lt_productplantbasic).

*      "Obtain data of product
*      SELECT a~plant,
*             a~product,
*             a~baseunit,
*             a~profitcenter,
*             a~mrpresponsible,
*             b~producttype,
*             c~producttypename,
*             d~productdescription,
*             e~mrpcontrollername
*        FROM i_productplantbasic WITH PRIVILEGED ACCESS AS a
*       INNER JOIN i_product WITH PRIVILEGED ACCESS AS b
*          ON b~product = a~product
*        LEFT OUTER JOIN i_producttypetext_2 WITH PRIVILEGED ACCESS AS c
*          ON c~producttype = b~producttype
*         AND c~language = @sy-langu
*        LEFT OUTER JOIN i_productdescription WITH PRIVILEGED ACCESS AS d
*          ON d~product = a~product
*         AND d~language = @sy-langu
*        LEFT OUTER JOIN i_mrpcontrollervh WITH PRIVILEGED ACCESS AS e
*          ON e~plant = a~plant
*         AND e~mrpcontroller = a~mrpresponsible
*        FOR ALL ENTRIES IN @lt_ztfi_1019
*       WHERE a~plant = @lt_ztfi_1019-plant
*         AND a~product = @lt_ztfi_1019-product
*        INTO TABLE @DATA(lt_productplantbasic).
    IF sy-subrc = 0.
      "Obtain data of inventory amount for fiscal period
      SELECT costestimate,
             material,
             valuationarea,
             valuationquantity,
             amountincompanycodecurrency
        FROM i_inventoryamtbyfsclperd( p_fiscalperiod = @lv_fiscalperiod, p_fiscalyear = @lv_fiscalyear ) WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_productplantbasic
       WHERE valuationarea = @lt_productplantbasic-valuationarea
         AND material = @lt_productplantbasic-product
         AND companycode = @lv_companycode
         AND ledger = @lv_ledger
         AND invtryvalnspecialstocktype <> 'T'
         AND invtryvalnspecialstocktype <> 'E'
         AND valuationquantity <> 0
         AND amountincompanycodecurrency <> 0
        INTO TABLE @lt_inventoryamtbyfsclperd.

      LOOP AT lt_inventoryamtbyfsclperd INTO DATA(ls_inventoryamtbyfsclperd).
        CLEAR ls_inventoryamtbyfsclperd-costestimate.
        COLLECT ls_inventoryamtbyfsclperd INTO lt_inventoryamtbyfsclperd_sum.
      ENDLOOP.

      CLEAR lt_inventoryamtbyfsclperd.

      DATA lt_productplantbasic_tmp LIKE lt_productplantbasic.

      SORT lt_inventoryamtbyfsclperd_sum BY valuationarea material.

      LOOP AT lt_productplantbasic INTO DATA(ls_productplantbasic).
        CLEAR ls_inventoryamtbyfsclperd.

        "Read data of inventory amount for fiscal period
        READ TABLE lt_inventoryamtbyfsclperd_sum INTO ls_inventoryamtbyfsclperd WITH KEY valuationarea = ls_productplantbasic-valuationarea
                                                                                         material = ls_productplantbasic-product
                                                                                BINARY SEARCH.
        IF ls_inventoryamtbyfsclperd-valuationquantity <> 0.
          APPEND ls_productplantbasic TO lt_productplantbasic_tmp.
          APPEND ls_inventoryamtbyfsclperd TO lt_inventoryamtbyfsclperd.
        ENDIF.
      ENDLOOP.

      lt_productplantbasic = lt_productplantbasic_tmp.
    ENDIF.

    IF lt_productplantbasic IS NOT INITIAL.
      LOOP AT lt_productplantbasic INTO ls_productplantbasic.
        IF ls_productplantbasic-mrpresponsible IS NOT INITIAL.
          DATA(lv_length) = strlen( ls_productplantbasic-mrpresponsible ).
          DATA(lv_offset) = lv_length - 2.

          IF lv_offset >= 0.
            lr_searchterm2 = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = ls_productplantbasic-mrpresponsible+lv_offset(2) ) ).
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

      "Obtain data of profit center text
      SELECT profitcenter,
             profitcentername,
             profitcenterlongname
        FROM i_profitcentertext WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_productplantbasic
       WHERE profitcenter = @lt_productplantbasic-profitcenter
         AND language = @sy-langu
        INTO TABLE @DATA(lt_profitcentertext).

      lv_fiscalyearperiod = lv_fiscalyear && lv_fiscalperiod.

      "Obtain data of fiscal year period for fiscal year variant
      SELECT SINGLE
             fiscalperiodstartdate,
             fiscalperiodenddate
        FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
       WHERE fiscalyearvariant = @lc_fiyearvariant_v3
         AND fiscalyearperiod = @lv_fiscalyearperiod
        INTO (@lv_fiscalperiodstartdate,@lv_fiscalperiodenddate).

      "Obtain data of inventory price by key date
      SELECT material,
             valuationarea,
             actualprice
        FROM i_inventorypricebykeydate( p_calendardate = @lv_fiscalperiodenddate )  WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_productplantbasic
       WHERE material = @lt_productplantbasic-product
         AND valuationarea = @lt_productplantbasic-valuationarea
         AND currencyrole = '10'
         AND ledger = @lv_ledger
         AND inventoryspecialstocktype <> 'T'
        INTO TABLE @DATA(lt_inventorypricebykeydate).

      "Obtain data of supplier invoice
      SELECT a~purchaseorder,
             a~purchaseorderitem,
             a~accountassignmentnumber,
             a~purchasinghistorydocumenttype,
             a~purchasinghistorydocumentyear,
             a~purchasinghistorydocument,
             a~purchasinghistorydocumentitem,
             a~purordamountincompanycodecrcy,
             a~quantity,
             a~plant,
             a~material
        FROM c_purchaseorderhistorydex WITH PRIVILEGED ACCESS AS a
       INNER JOIN c_supplierinvoicedex WITH PRIVILEGED ACCESS AS b
          ON b~supplierinvoice = a~purchasinghistorydocument
         FOR ALL ENTRIES IN @lt_productplantbasic
       WHERE a~plant = @lt_productplantbasic-valuationarea
         AND a~material = @lt_productplantbasic-product
         AND b~companycode = @lv_companycode
         AND a~purchasinghistorycategory = 'Q'
         AND a~postingdate <= @lv_fiscalperiodenddate
         AND a~purordamountincompanycodecrcy <> 0
         AND b~fiscalyear = @lv_fiscalperiodstartdate+0(4)
         AND b~reversedocument = @space
         AND b~postingdate BETWEEN @lv_fiscalperiodstartdate AND @lv_fiscalperiodenddate
        INTO TABLE @DATA(lt_purchaseorderhistorydex).

      SORT lt_purchaseorderhistorydex BY plant material purchasinghistorydocument DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_purchaseorderhistorydex COMPARING plant material.

      DATA(lt_productplantbasic_zhlb) = lt_productplantbasic.
      DELETE lt_productplantbasic_zhlb WHERE producttype <> 'ZHLB'.

      LOOP AT lt_productplantbasic_zhlb INTO DATA(ls_productplantbasic_zhlb).
        "Obtain data of root level material of component(high level material)
        zcl_bom_where_used=>get_data(
          EXPORTING
            iv_plant                   = ls_productplantbasic_zhlb-valuationarea
            iv_billofmaterialcomponent = ls_productplantbasic_zhlb-product
            iv_getusagelistroot        = abap_true
          IMPORTING
            et_usagelist               = lt_usagelist ).

        IF lt_usagelist IS NOT INITIAL.
          LOOP AT lt_usagelist INTO DATA(ls_usagelist).
            ls_finalproductinfo-product  = ls_productplantbasic_zhlb-product.
            ls_finalproductinfo-plant    = ls_productplantbasic_zhlb-valuationarea.
            ls_finalproductinfo-material = ls_usagelist-material.
            COLLECT ls_finalproductinfo INTO lt_finalproductinfo.
            CLEAR ls_finalproductinfo.
          ENDLOOP.
*         high level material没有更高的high level material，则high level material为root level material，即final product
        ELSE.
          ls_finalproductinfo-product  = ls_productplantbasic_zhlb-product.
          ls_finalproductinfo-plant    = ls_productplantbasic_zhlb-valuationarea.
          ls_finalproductinfo-material = ls_productplantbasic_zhlb-product.
          COLLECT ls_finalproductinfo INTO lt_finalproductinfo.
          CLEAR ls_finalproductinfo.
        ENDIF.

        CLEAR lt_usagelist.
      ENDLOOP.

      DATA(lt_productplantbasic_zfrt) = lt_productplantbasic.
      DELETE lt_productplantbasic_zfrt WHERE producttype <> 'ZFRT'.

      IF lt_productplantbasic_zfrt IS NOT INITIAL.
        "Obtain data of billing document item
        SELECT a~billingdocument,
               a~billingdocumentitem,
               a~product,
               a~plant,
               a~creationdate,
               a~creationtime,
               a~billingquantity,
               a~netamount
          FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS a
         INNER JOIN i_billingdocumentbasic WITH PRIVILEGED ACCESS AS b
            ON b~billingdocument = a~billingdocument
           FOR ALL ENTRIES IN @lt_productplantbasic_zfrt
         WHERE a~product = @lt_productplantbasic_zfrt-product
           AND a~plant = @lt_productplantbasic_zfrt-valuationarea
           AND a~companycode = @lv_companycode
           AND a~billingdocumentdate <= @lv_fiscalperiodenddate
           AND b~billingdocumentiscancelled = @abap_false
           AND b~cancelledbillingdocument = @space
           AND b~billingdocumenttype IN ('F2','IV2')
           AND b~billingdocumentdate BETWEEN @lv_fiscalperiodstartdate AND @lv_fiscalperiodenddate
          INTO TABLE @DATA(lt_billingdocumentitem).

        SORT lt_billingdocumentitem BY product plant creationdate DESCENDING creationtime DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_billingdocumentitem COMPARING product plant.
      ENDIF.

      IF lt_finalproductinfo IS NOT INITIAL.
        "Obtain data of billing document item
        SELECT a~billingdocument,
               a~billingdocumentitem,
               a~product,
               a~plant,
               a~billingquantity,
               a~netamount
          FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS a
         INNER JOIN i_billingdocumentbasic WITH PRIVILEGED ACCESS AS b
            ON b~billingdocument = a~billingdocument
           FOR ALL ENTRIES IN @lt_finalproductinfo
         WHERE a~product = @lt_finalproductinfo-material
           AND a~plant = @lt_finalproductinfo-plant
           AND a~companycode = @lv_companycode
           AND b~billingdocumentiscancelled = @abap_false
           AND b~cancelledbillingdocument = @space
           AND b~billingdocumenttype IN ('F2','IV2')
           AND b~billingdocumentdate BETWEEN @lv_fiscalperiodstartdate AND @lv_fiscalperiodenddate
          INTO TABLE @DATA(lt_billingdocumentitem_final).
      ENDIF.
    ENDIF.
*    ENDIF.


    SORT lt_productplantbasic BY valuationarea product.
    SORT lt_businesspartner BY searchterm2.
    SORT lt_profitcentertext BY profitcenter.
    SORT lt_inventorypricebykeydate BY material valuationarea.
    SORT lt_finalproductinfo BY product plant.
    SORT lt_billingdocumentitem_final BY product plant.
    SORT lt_ztfi_1019 BY plant product age.

    LOOP AT lt_productplantbasic INTO ls_productplantbasic.
      ls_data-companycode        = lv_companycode.
      ls_data-fiscalyear         = lv_fiscalyear.
      ls_data-fiscalperiod       = lv_fiscalperiod.
      ls_data-currency           = ls_productplantbasic-currency.
      ls_data-plant              = ls_productplantbasic-valuationarea.
      ls_data-product            = ls_productplantbasic-product.
      ls_data-productdescription = ls_productplantbasic-productdescription.
      ls_data-producttype        = ls_productplantbasic-producttype.
      ls_data-producttypename    = ls_productplantbasic-producttypename.
      ls_data-mrpresponsible     = ls_productplantbasic-mrpresponsible.
      ls_data-mrpcontrollername  = ls_productplantbasic-mrpcontrollername.
      ls_data-profitcenter       = ls_productplantbasic-profitcenter.
      ls_data-baseunit           = ls_productplantbasic-baseunit.

*        IF ls_productplantbasic-product+5(1) = 'D'.
*          ls_data-chargeablesupplyflag = 'Y'.
*        ELSE.
*          ls_data-chargeablesupplyflag = 'N'.
*        ENDIF.

      lv_length = strlen( ls_productplantbasic-product ).
      lv_offset = lv_length - 1.

      IF lv_offset >= 0 AND ls_productplantbasic-product+lv_offset(1) = '2'.
        ls_data-chargeablesupplyflag = 'Y'.
      ELSE.
        ls_data-chargeablesupplyflag = 'N'.
      ENDIF.

      IF ls_productplantbasic-mrpresponsible IS NOT INITIAL.
        lv_length = strlen( ls_productplantbasic-mrpresponsible ).
        lv_offset = lv_length - 2.

        IF lv_offset >= 0.
          lv_searchterm2 = ls_productplantbasic-mrpresponsible+lv_offset(2).

          "Read data of business partner
          READ TABLE lt_businesspartner INTO DATA(ls_businesspartner) WITH KEY searchterm2 = lv_searchterm2
                                                                      BINARY SEARCH.
          IF sy-subrc = 0.
            ls_data-businesspartner     = ls_businesspartner-businesspartner.
            ls_data-businesspartnername = ls_businesspartner-businesspartnername.
          ENDIF.
        ENDIF.
      ENDIF.

      "Read data of profit center text
      READ TABLE lt_profitcentertext INTO DATA(ls_profitcentertext) WITH KEY profitcenter = ls_productplantbasic-profitcenter
                                                                    BINARY SEARCH.
      IF sy-subrc = 0.
        IF ls_profitcentertext-profitcenterlongname IS NOT INITIAL.
          ls_data-profitcenterlongname = ls_profitcentertext-profitcenterlongname.
        ELSE.
          ls_data-profitcenterlongname = ls_profitcentertext-profitcentername.
        ENDIF.
      ENDIF.

      "Read data of inventory amount for fiscal period
      READ TABLE lt_inventoryamtbyfsclperd_sum INTO ls_inventoryamtbyfsclperd WITH KEY valuationarea = ls_productplantbasic-valuationarea
                                                                                       material = ls_productplantbasic-product
                                                                              BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-valuationquantity = ls_inventoryamtbyfsclperd-valuationquantity.
        ls_data-inventoryamount   = ls_inventoryamtbyfsclperd-amountincompanycodecurrency.
      ENDIF.

      "Read data of product valuation
      READ TABLE lt_inventorypricebykeydate INTO DATA(ls_inventorypricebykeydate) WITH KEY material = ls_productplantbasic-product
                                                                                           valuationarea = ls_productplantbasic-valuationarea
                                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-actualcost = ls_inventorypricebykeydate-actualprice.
      ENDIF.

      "Read data of supplier invoice
      READ TABLE lt_purchaseorderhistorydex INTO DATA(ls_purchaseorderhistorydex) WITH KEY plant = ls_productplantbasic-valuationarea
                                                                                           material = ls_productplantbasic-product
                                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        IF ls_purchaseorderhistorydex-quantity <> 0.
          ls_data-valuationunitprice = ls_purchaseorderhistorydex-purordamountincompanycodecrcy / ls_purchaseorderhistorydex-quantity.
          ls_data-valuationamount    = ls_purchaseorderhistorydex-purordamountincompanycodecrcy / ls_purchaseorderhistorydex-quantity
                                     * ls_data-valuationquantity.
        ENDIF.
      ENDIF.

      "Read data of billing document item
      READ TABLE lt_billingdocumentitem INTO DATA(ls_billingdocumentitem) WITH KEY product = ls_productplantbasic-product
                                                                                   plant = ls_productplantbasic-valuationarea
                                                                          BINARY SEARCH.
      IF sy-subrc = 0.
        IF ls_billingdocumentitem-billingquantity <> 0.
          ls_data-valuationunitprice = ls_billingdocumentitem-netamount / ls_billingdocumentitem-billingquantity.
          ls_data-valuationamount    = ls_billingdocumentitem-netamount / ls_billingdocumentitem-billingquantity
                                     * ls_data-valuationquantity.
        ENDIF.
      ENDIF.

      "Read data of root product
      READ TABLE lt_finalproductinfo INTO ls_finalproductinfo WITH KEY product = ls_productplantbasic-product
                                                                       plant = ls_productplantbasic-valuationarea
                                                              BINARY SEARCH.
      IF sy-subrc = 0.
        "Read data of billing document item
        READ TABLE lt_billingdocumentitem_final TRANSPORTING NO FIELDS WITH KEY product = ls_productplantbasic-product
                                                                                plant = ls_productplantbasic-valuationarea
                                                                            BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_billingdocumentitem_final INTO DATA(ls_billingdocumentitem_final) FROM sy-tabix.
            IF ls_billingdocumentitem_final-product <> ls_productplantbasic-product
            OR ls_billingdocumentitem_final-plant <> ls_productplantbasic-valuationarea.
              EXIT.
            ENDIF.

            IF ls_billingdocumentitem_final-billingquantity <> 0.
              lv_valuationunitprice = ls_billingdocumentitem_final-netamount / ls_billingdocumentitem_final-billingquantity.
            ENDIF.

            "Get the smallest unit price
            IF ls_data-valuationunitprice = 0.
              ls_data-valuationunitprice = lv_valuationunitprice.
            ELSE.
              IF ls_data-valuationunitprice > lv_valuationunitprice.
                ls_data-valuationunitprice = lv_valuationunitprice.
              ENDIF.
            ENDIF.
          ENDLOOP.

          ls_data-valuationamount = ls_data-valuationunitprice * ls_data-valuationquantity.
        ENDIF.
      ENDIF.

      IF ls_data-inventoryamount - ls_data-valuationamount > 0.
        ls_data-valuationafteramount = ls_data-inventoryamount - ls_data-valuationamount.
        ls_data-valuationloss        = ls_data-inventoryamount - ls_data-valuationamount.
      ENDIF.

      READ TABLE lt_ztfi_1019 TRANSPORTING NO FIELDS WITH KEY plant = ls_productplantbasic-valuationarea
                                                              product = ls_productplantbasic-product
                                                     BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_ztfi_1019 INTO DATA(ls_ztfi_1019) FROM sy-tabix.
          IF ls_ztfi_1019-plant <> ls_productplantbasic-valuationarea
          OR ls_ztfi_1019-product <> ls_productplantbasic-product.
            EXIT.
          ENDIF.

          CASE ls_ztfi_1019-age.
            WHEN '001'.
              ls_data-quantitymonth1 = ls_ztfi_1019-qty.
              ls_data-amountmonth1   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '002'.
              ls_data-quantitymonth2 = ls_ztfi_1019-qty.
              ls_data-amountmonth2   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '003'.
              ls_data-quantitymonth3 = ls_ztfi_1019-qty.
              ls_data-amountmonth3   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '004'.
              ls_data-quantitymonth4 = ls_ztfi_1019-qty.
              ls_data-amountmonth4   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '005'.
              ls_data-quantitymonth5 = ls_ztfi_1019-qty.
              ls_data-amountmonth5   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '006'.
              ls_data-quantitymonth6 = ls_ztfi_1019-qty.
              ls_data-amountmonth6   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '007'.
              ls_data-quantitymonth7 = ls_ztfi_1019-qty.
              ls_data-amountmonth7   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '008'.
              ls_data-quantitymonth8 = ls_ztfi_1019-qty.
              ls_data-amountmonth8   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '009'.
              ls_data-quantitymonth9 = ls_ztfi_1019-qty.
              ls_data-amountmonth9   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '010'.
              ls_data-quantitymonth10 = ls_ztfi_1019-qty.
              ls_data-amountmonth10   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '011'.
              ls_data-quantitymonth11 = ls_ztfi_1019-qty.
              ls_data-amountmonth11   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '012'.
              ls_data-quantitymonth12 = ls_ztfi_1019-qty.
              ls_data-amountmonth12   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '013'.
              ls_data-quantitymonth13 = ls_ztfi_1019-qty.
              ls_data-amountmonth13   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '014'.
              ls_data-quantitymonth14 = ls_ztfi_1019-qty.
              ls_data-amountmonth14   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '015'.
              ls_data-quantitymonth15 = ls_ztfi_1019-qty.
              ls_data-amountmonth15   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '016'.
              ls_data-quantitymonth16 = ls_ztfi_1019-qty.
              ls_data-amountmonth16   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '017'.
              ls_data-quantitymonth17 = ls_ztfi_1019-qty.
              ls_data-amountmonth17   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '018'.
              ls_data-quantitymonth18 = ls_ztfi_1019-qty.
              ls_data-amountmonth18   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '019'.
              ls_data-quantitymonth19 = ls_ztfi_1019-qty.
              ls_data-amountmonth19   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '020'.
              ls_data-quantitymonth20 = ls_ztfi_1019-qty.
              ls_data-amountmonth20   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '021'.
              ls_data-quantitymonth21 = ls_ztfi_1019-qty.
              ls_data-amountmonth21   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '022'.
              ls_data-quantitymonth22 = ls_ztfi_1019-qty.
              ls_data-amountmonth22   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '023'.
              ls_data-quantitymonth23 = ls_ztfi_1019-qty.
              ls_data-amountmonth23   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '024'.
              ls_data-quantitymonth24 = ls_ztfi_1019-qty.
              ls_data-amountmonth24   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '025'.
              ls_data-quantitymonth25 = ls_ztfi_1019-qty.
              ls_data-amountmonth25   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '026'.
              ls_data-quantitymonth26 = ls_ztfi_1019-qty.
              ls_data-amountmonth26   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '027'.
              ls_data-quantitymonth27 = ls_ztfi_1019-qty.
              ls_data-amountmonth27   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '028'.
              ls_data-quantitymonth28 = ls_ztfi_1019-qty.
              ls_data-amountmonth28   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '029'.
              ls_data-quantitymonth29 = ls_ztfi_1019-qty.
              ls_data-amountmonth29   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '030'.
              ls_data-quantitymonth30 = ls_ztfi_1019-qty.
              ls_data-amountmonth30   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '031'.
              ls_data-quantitymonth31 = ls_ztfi_1019-qty.
              ls_data-amountmonth31   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '032'.
              ls_data-quantitymonth32 = ls_ztfi_1019-qty.
              ls_data-amountmonth32   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '033'.
              ls_data-quantitymonth33 = ls_ztfi_1019-qty.
              ls_data-amountmonth33   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '034'.
              ls_data-quantitymonth34 = ls_ztfi_1019-qty.
              ls_data-amountmonth34   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '035'.
              ls_data-quantitymonth35 = ls_ztfi_1019-qty.
              ls_data-amountmonth35   = ls_ztfi_1019-qty * ls_data-actualcost.
            WHEN '036'.
              ls_data-quantitymonth36 = ls_ztfi_1019-qty.
              ls_data-amountmonth36   = ls_ztfi_1019-qty * ls_data-actualcost.
          ENDCASE.
        ENDLOOP.
      ENDIF.

      APPEND ls_data TO lt_data.
      CLEAR ls_data.
    ENDLOOP.

    io_response->set_total_number_of_records( lines( lt_data ) ).

    "Sort
    IF io_request->get_sort_elements( ) IS NOT INITIAL.
      zzcl_odata_utils=>orderby(
        EXPORTING
          it_order = io_request->get_sort_elements( )
        CHANGING
          ct_data  = lt_data ).
    ENDIF.

    "Page
    zzcl_odata_utils=>paging(
      EXPORTING
        io_paging = io_request->get_paging( )
      CHANGING
        ct_data   = lt_data ).

    io_response->set_data( lt_data ).
  ENDMETHOD.

ENDCLASS.
