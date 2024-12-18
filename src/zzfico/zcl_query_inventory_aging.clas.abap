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

    DATA:
      lt_data         TYPE STANDARD TABLE OF zc_inventory_aging,
      lr_searchterm2  TYPE RANGE OF i_businesspartner-searchterm2,
      ls_data         TYPE zc_inventory_aging,
      lv_companycode  TYPE zc_inventory_aging-companycode,
      lv_fiscalyear   TYPE zc_inventory_aging-fiscalyear,
      lv_fiscalperiod TYPE zc_inventory_aging-fiscalperiod,
      lv_ledger       TYPE zc_inventory_aging-ledger,
      lv_searchterm2  TYPE i_businesspartner-searchterm2,
      lv_totalamount  TYPE zc_inventory_aging-inventoryamount,
      lv_age          TYPE ztfi_1019-age,
      lv_actualprice  TYPE p DECIMALS 6.

    CONSTANTS:
      BEGIN OF lsc_age,
        a001 TYPE ztfi_1019-age VALUE '001',
        a002 TYPE ztfi_1019-age VALUE '002',
        a003 TYPE ztfi_1019-age VALUE '003',
        a004 TYPE ztfi_1019-age VALUE '004',
        a005 TYPE ztfi_1019-age VALUE '005',
        a006 TYPE ztfi_1019-age VALUE '006',
        a007 TYPE ztfi_1019-age VALUE '007',
        a008 TYPE ztfi_1019-age VALUE '008',
        a009 TYPE ztfi_1019-age VALUE '009',
        a010 TYPE ztfi_1019-age VALUE '010',
        a011 TYPE ztfi_1019-age VALUE '011',
        a012 TYPE ztfi_1019-age VALUE '012',
        a013 TYPE ztfi_1019-age VALUE '013',
        a014 TYPE ztfi_1019-age VALUE '014',
        a015 TYPE ztfi_1019-age VALUE '015',
        a016 TYPE ztfi_1019-age VALUE '016',
        a017 TYPE ztfi_1019-age VALUE '017',
        a018 TYPE ztfi_1019-age VALUE '018',
        a019 TYPE ztfi_1019-age VALUE '019',
        a020 TYPE ztfi_1019-age VALUE '020',
        a021 TYPE ztfi_1019-age VALUE '021',
        a022 TYPE ztfi_1019-age VALUE '022',
        a023 TYPE ztfi_1019-age VALUE '023',
        a024 TYPE ztfi_1019-age VALUE '024',
        a025 TYPE ztfi_1019-age VALUE '025',
        a026 TYPE ztfi_1019-age VALUE '026',
        a027 TYPE ztfi_1019-age VALUE '027',
        a028 TYPE ztfi_1019-age VALUE '028',
        a029 TYPE ztfi_1019-age VALUE '029',
        a030 TYPE ztfi_1019-age VALUE '030',
        a031 TYPE ztfi_1019-age VALUE '031',
        a032 TYPE ztfi_1019-age VALUE '032',
        a033 TYPE ztfi_1019-age VALUE '033',
        a034 TYPE ztfi_1019-age VALUE '034',
        a035 TYPE ztfi_1019-age VALUE '035',
        a036 TYPE ztfi_1019-age VALUE '036',
      END OF lsc_age,

      lc_chargeablesupplyflag_y TYPE string VALUE 'Y',
      lc_chargeablesupplyflag_n TYPE string VALUE 'N',
      lc_sign_i                 TYPE c LENGTH 1 VALUE 'I',
      lc_option_eq              TYPE c LENGTH 2 VALUE 'EQ'.

    TRY.
        "Get and add filter
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option) ##NO_HANDLER.
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
    SELECT *
      FROM ztfi_1019
     WHERE ledger = @lv_ledger
       AND companycode = @lv_companycode
       AND fiscalyear = @lv_fiscalyear
       AND fiscalperiod = @lv_fiscalperiod
      INTO TABLE @DATA(lt_ztfi_1019).
    IF sy-subrc = 0.
      "Obtain data of product description
      SELECT product,
             productdescription
        FROM i_productdescription
         FOR ALL ENTRIES IN @lt_ztfi_1019
       WHERE product = @lt_ztfi_1019-product
         AND language = @sy-langu
        INTO TABLE @DATA(lt_productdescription).

      DATA(lt_ztfi_1019_tmp) = lt_ztfi_1019.
      SORT lt_ztfi_1019_tmp BY producttype.
      DELETE ADJACENT DUPLICATES FROM lt_ztfi_1019_tmp
                            COMPARING producttype.

      "Obtain data of product type text
      SELECT producttype,
             producttypename
        FROM i_producttypetext_2
         FOR ALL ENTRIES IN @lt_ztfi_1019_tmp
       WHERE producttype = @lt_ztfi_1019_tmp-producttype
         AND language = @sy-langu
        INTO TABLE @DATA(lt_producttypetext).

      lt_ztfi_1019_tmp = lt_ztfi_1019.
      SORT lt_ztfi_1019_tmp BY profitcenter.
      DELETE ADJACENT DUPLICATES FROM lt_ztfi_1019_tmp
                            COMPARING profitcenter.

      "Obtain data of profit center text
      SELECT profitcenter,
             profitcentername,
             profitcenterlongname
        FROM i_profitcentertext WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_ztfi_1019_tmp
       WHERE profitcenter = @lt_ztfi_1019_tmp-profitcenter
         AND language = @sy-langu
        INTO TABLE @DATA(lt_profitcentertext).

      lt_ztfi_1019_tmp = lt_ztfi_1019.
      SORT lt_ztfi_1019_tmp BY plant mrpresponsible.
      DELETE ADJACENT DUPLICATES FROM lt_ztfi_1019_tmp
                            COMPARING plant mrpresponsible.

      "Obtain data of MRP controller name
      SELECT plant,
             mrpcontroller,
             mrpcontrollername
        FROM i_mrpcontrollervh
         FOR ALL ENTRIES IN @lt_ztfi_1019_tmp
       WHERE plant = @lt_ztfi_1019_tmp-plant
         AND mrpcontroller = @lt_ztfi_1019_tmp-mrpresponsible
        INTO TABLE @DATA(lt_mrpcontrollervh).

      LOOP AT lt_ztfi_1019_tmp INTO DATA(ls_ztfi_1019_tmp).
        IF ls_ztfi_1019_tmp-mrpresponsible IS NOT INITIAL.
          DATA(lv_length) = strlen( ls_ztfi_1019_tmp-mrpresponsible ).
          DATA(lv_offset) = lv_length - 2.

          IF lv_offset >= 0.
            lr_searchterm2 = VALUE #( BASE lr_searchterm2 sign = lc_sign_i option = lc_option_eq
                                                        ( low = ls_ztfi_1019_tmp-mrpresponsible+lv_offset(2) ) ).
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

      SORT lt_ztfi_1019 BY plant product age.

      DATA(lt_ztfi_1019_header) = lt_ztfi_1019.
      DELETE ADJACENT DUPLICATES FROM lt_ztfi_1019_header
                            COMPARING plant product.

      DELETE lt_ztfi_1019 WHERE qty = 0.
    ENDIF.

    SORT lt_productdescription BY product.
    SORT lt_producttypetext BY producttype.
    SORT lt_profitcentertext BY profitcenter.
    SORT lt_mrpcontrollervh BY plant mrpcontroller.
    SORT lt_businesspartner BY searchterm2.

    LOOP AT lt_ztfi_1019_header INTO DATA(ls_ztfi_1019_header).
      ls_data-companycode          = ls_ztfi_1019_header-companycode.
      ls_data-plant                = ls_ztfi_1019_header-plant.
      ls_data-fiscalyear           = ls_ztfi_1019_header-fiscalyear.
      ls_data-fiscalperiod         = ls_ztfi_1019_header-fiscalperiod.
      ls_data-product              = ls_ztfi_1019_header-product.
      ls_data-producttype          = ls_ztfi_1019_header-producttype.
      ls_data-mrpresponsible       = ls_ztfi_1019_header-mrpresponsible.
      ls_data-profitcenter         = ls_ztfi_1019_header-profitcenter.
      ls_data-valuationquantity    = ls_ztfi_1019_header-valuationquantity.
      ls_data-baseunit             = ls_ztfi_1019_header-baseunit.
      ls_data-actualcost           = ls_ztfi_1019_header-actualcost.
      ls_data-inventoryamount      = ls_ztfi_1019_header-inventoryamount.
      ls_data-materialpriceunitqty = ls_ztfi_1019_header-materialpriceunitqty.
      ls_data-valuationunitprice   = ls_ztfi_1019_header-valuationunitprice.
      ls_data-valuationamount      = ls_ztfi_1019_header-valuationamount.
      ls_data-valuationafteramount = ls_ztfi_1019_header-valuationafteramount.
      ls_data-valuationloss        = ls_ztfi_1019_header-valuationloss.
      ls_data-currency             = ls_ztfi_1019_header-currency.

      "Read data of product description
      READ TABLE lt_productdescription INTO DATA(ls_productdescription) WITH KEY product = ls_ztfi_1019_header-product
                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-productdescription = ls_productdescription-productdescription.
      ENDIF.

      "Read data of product type text
      READ TABLE lt_producttypetext INTO DATA(ls_producttypetext) WITH KEY producttype = ls_ztfi_1019_header-producttype
                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-producttypename = ls_producttypetext-producttypename.
      ENDIF.

      "Read data of profit center text
      READ TABLE lt_profitcentertext INTO DATA(ls_profitcentertext) WITH KEY profitcenter = ls_ztfi_1019_header-profitcenter
                                                                    BINARY SEARCH.
      IF sy-subrc = 0.
        IF ls_profitcentertext-profitcenterlongname IS NOT INITIAL.
          ls_data-profitcenterlongname = ls_profitcentertext-profitcenterlongname.
        ELSE.
          ls_data-profitcenterlongname = ls_profitcentertext-profitcentername.
        ENDIF.
      ENDIF.

      "Read data of MRP controller name
      READ TABLE lt_mrpcontrollervh INTO DATA(ls_mrpcontrollervh) WITH KEY plant = ls_ztfi_1019_header-plant
                                                                           mrpcontroller = ls_ztfi_1019_header-mrpresponsible
                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-mrpcontrollername = ls_mrpcontrollervh-mrpcontrollername.
      ENDIF.

*      IF ls_ztfi_1019_header-product+5(1) = 'D'.
*        ls_data-chargeablesupplyflag = 'Y'.
*      ELSE.
*        ls_data-chargeablesupplyflag = 'N'.
*      ENDIF.

      lv_length = strlen( ls_ztfi_1019_header-product ).
      lv_offset = lv_length - 1.

      IF lv_offset >= 0 AND ls_ztfi_1019_header-product+lv_offset(1) = '2'.
        ls_data-chargeablesupplyflag = lc_chargeablesupplyflag_y.
      ELSE.
        ls_data-chargeablesupplyflag = lc_chargeablesupplyflag_n.
      ENDIF.

      IF ls_ztfi_1019_header-mrpresponsible IS NOT INITIAL.
        lv_length = strlen( ls_ztfi_1019_header-mrpresponsible ).
        lv_offset = lv_length - 2.

        IF lv_offset >= 0.
          lv_searchterm2 = ls_ztfi_1019_header-mrpresponsible+lv_offset(2).

          "Read data of business partner
          READ TABLE lt_businesspartner INTO DATA(ls_businesspartner) WITH KEY searchterm2 = lv_searchterm2
                                                                      BINARY SEARCH.
          IF sy-subrc = 0.
            ls_data-businesspartner     = ls_businesspartner-businesspartner.
            ls_data-businesspartnername = ls_businesspartner-businesspartnername.
          ENDIF.
        ENDIF.
      ENDIF.

      "计算月底实际价格（用于调整尾差）
      lv_actualprice = ls_data-inventoryamount / ls_data-valuationquantity.

      READ TABLE lt_ztfi_1019 TRANSPORTING NO FIELDS WITH KEY plant = ls_ztfi_1019_header-plant
                                                              product = ls_ztfi_1019_header-product
                                                     BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_ztfi_1019 INTO DATA(ls_ztfi_1019) FROM sy-tabix.
          IF ls_ztfi_1019-plant <> ls_ztfi_1019_header-plant
          OR ls_ztfi_1019-product <> ls_ztfi_1019_header-product.
            EXIT.
          ENDIF.

          "获取最小的库龄（用于调整尾差）
          IF lv_age IS INITIAL.
            lv_age = ls_ztfi_1019-age.
          ENDIF.

          CASE ls_ztfi_1019-age.
            WHEN lsc_age-a001.
              ls_data-quantitymonth1 = ls_ztfi_1019-qty.
              ls_data-amountmonth1   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a002.
              ls_data-quantitymonth2 = ls_ztfi_1019-qty.
              ls_data-amountmonth2   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a003.
              ls_data-quantitymonth3 = ls_ztfi_1019-qty.
              ls_data-amountmonth3   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a004.
              ls_data-quantitymonth4 = ls_ztfi_1019-qty.
              ls_data-amountmonth4   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a005.
              ls_data-quantitymonth5 = ls_ztfi_1019-qty.
              ls_data-amountmonth5   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a006.
              ls_data-quantitymonth6 = ls_ztfi_1019-qty.
              ls_data-amountmonth6   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a007.
              ls_data-quantitymonth7 = ls_ztfi_1019-qty.
              ls_data-amountmonth7   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a008.
              ls_data-quantitymonth8 = ls_ztfi_1019-qty.
              ls_data-amountmonth8   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a009.
              ls_data-quantitymonth9 = ls_ztfi_1019-qty.
              ls_data-amountmonth9   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a010.
              ls_data-quantitymonth10 = ls_ztfi_1019-qty.
              ls_data-amountmonth10   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a011.
              ls_data-quantitymonth11 = ls_ztfi_1019-qty.
              ls_data-amountmonth11   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a012.
              ls_data-quantitymonth12 = ls_ztfi_1019-qty.
              ls_data-amountmonth12   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a013.
              ls_data-quantitymonth13 = ls_ztfi_1019-qty.
              ls_data-amountmonth13   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a014.
              ls_data-quantitymonth14 = ls_ztfi_1019-qty.
              ls_data-amountmonth14   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a015.
              ls_data-quantitymonth15 = ls_ztfi_1019-qty.
              ls_data-amountmonth15   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a016.
              ls_data-quantitymonth16 = ls_ztfi_1019-qty.
              ls_data-amountmonth16   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a017.
              ls_data-quantitymonth17 = ls_ztfi_1019-qty.
              ls_data-amountmonth17   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a018.
              ls_data-quantitymonth18 = ls_ztfi_1019-qty.
              ls_data-amountmonth18   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a019.
              ls_data-quantitymonth19 = ls_ztfi_1019-qty.
              ls_data-amountmonth19   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a020.
              ls_data-quantitymonth20 = ls_ztfi_1019-qty.
              ls_data-amountmonth20   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a021.
              ls_data-quantitymonth21 = ls_ztfi_1019-qty.
              ls_data-amountmonth21   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a022.
              ls_data-quantitymonth22 = ls_ztfi_1019-qty.
              ls_data-amountmonth22   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a023.
              ls_data-quantitymonth23 = ls_ztfi_1019-qty.
              ls_data-amountmonth23   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a024.
              ls_data-quantitymonth24 = ls_ztfi_1019-qty.
              ls_data-amountmonth24   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a025.
              ls_data-quantitymonth25 = ls_ztfi_1019-qty.
              ls_data-amountmonth25   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a026.
              ls_data-quantitymonth26 = ls_ztfi_1019-qty.
              ls_data-amountmonth26   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a027.
              ls_data-quantitymonth27 = ls_ztfi_1019-qty.
              ls_data-amountmonth27   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a028.
              ls_data-quantitymonth28 = ls_ztfi_1019-qty.
              ls_data-amountmonth28   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a029.
              ls_data-quantitymonth29 = ls_ztfi_1019-qty.
              ls_data-amountmonth29   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a030.
              ls_data-quantitymonth30 = ls_ztfi_1019-qty.
              ls_data-amountmonth30   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a031.
              ls_data-quantitymonth31 = ls_ztfi_1019-qty.
              ls_data-amountmonth31   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a032.
              ls_data-quantitymonth32 = ls_ztfi_1019-qty.
              ls_data-amountmonth32   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a033.
              ls_data-quantitymonth33 = ls_ztfi_1019-qty.
              ls_data-amountmonth33   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a034.
              ls_data-quantitymonth34 = ls_ztfi_1019-qty.
              ls_data-amountmonth34   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a035.
              ls_data-quantitymonth35 = ls_ztfi_1019-qty.
              ls_data-amountmonth35   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
            WHEN lsc_age-a036.
              ls_data-quantitymonth36 = ls_ztfi_1019-qty.
              ls_data-amountmonth36   = ls_ztfi_1019-qty * lv_actualprice."ls_data-actualcost.
          ENDCASE.

          lv_totalamount = lv_totalamount + ls_ztfi_1019-qty * lv_actualprice.
        ENDLOOP.

        "尾差
        lv_totalamount = ls_data-inventoryamount - lv_totalamount.

        IF lv_totalamount <> 0.
          CASE lv_age.
            WHEN lsc_age-a001.
              ls_data-amountmonth1 = ls_data-amountmonth1 + lv_totalamount.
            WHEN lsc_age-a002.
              ls_data-amountmonth2 = ls_data-amountmonth2 + lv_totalamount.
            WHEN lsc_age-a003.
              ls_data-amountmonth3 = ls_data-amountmonth3 + lv_totalamount.
            WHEN lsc_age-a004.
              ls_data-amountmonth4 = ls_data-amountmonth4 + lv_totalamount.
            WHEN lsc_age-a005.
              ls_data-amountmonth5 = ls_data-amountmonth5 + lv_totalamount.
            WHEN lsc_age-a006.
              ls_data-amountmonth6 = ls_data-amountmonth6 + lv_totalamount.
            WHEN lsc_age-a007.
              ls_data-amountmonth7 = ls_data-amountmonth7 + lv_totalamount.
            WHEN lsc_age-a008.
              ls_data-amountmonth8 = ls_data-amountmonth8 + lv_totalamount.
            WHEN lsc_age-a009.
              ls_data-amountmonth9 = ls_data-amountmonth9 + lv_totalamount.
            WHEN lsc_age-a010.
              ls_data-amountmonth10 = ls_data-amountmonth10 + lv_totalamount.
            WHEN lsc_age-a011.
              ls_data-amountmonth11 = ls_data-amountmonth11 + lv_totalamount.
            WHEN lsc_age-a012.
              ls_data-amountmonth12 = ls_data-amountmonth12 + lv_totalamount.
            WHEN lsc_age-a013.
              ls_data-amountmonth13 = ls_data-amountmonth13 + lv_totalamount.
            WHEN lsc_age-a014.
              ls_data-amountmonth14 = ls_data-amountmonth14 + lv_totalamount.
            WHEN lsc_age-a015.
              ls_data-amountmonth15 = ls_data-amountmonth15 + lv_totalamount.
            WHEN lsc_age-a016.
              ls_data-amountmonth16 = ls_data-amountmonth16 + lv_totalamount.
            WHEN lsc_age-a017.
              ls_data-amountmonth17 = ls_data-amountmonth17 + lv_totalamount.
            WHEN lsc_age-a018.
              ls_data-amountmonth18 = ls_data-amountmonth18 + lv_totalamount.
            WHEN lsc_age-a019.
              ls_data-amountmonth19 = ls_data-amountmonth19 + lv_totalamount.
            WHEN lsc_age-a020.
              ls_data-amountmonth20 = ls_data-amountmonth20 + lv_totalamount.
            WHEN lsc_age-a021.
              ls_data-amountmonth21 = ls_data-amountmonth21 + lv_totalamount.
            WHEN lsc_age-a022.
              ls_data-amountmonth22 = ls_data-amountmonth22 + lv_totalamount.
            WHEN lsc_age-a023.
              ls_data-amountmonth23 = ls_data-amountmonth23 + lv_totalamount.
            WHEN lsc_age-a024.
              ls_data-amountmonth24 = ls_data-amountmonth24 + lv_totalamount.
            WHEN lsc_age-a025.
              ls_data-amountmonth25 = ls_data-amountmonth25 + lv_totalamount.
            WHEN lsc_age-a026.
              ls_data-amountmonth26 = ls_data-amountmonth26 + lv_totalamount.
            WHEN lsc_age-a027.
              ls_data-amountmonth27 = ls_data-amountmonth27 + lv_totalamount.
            WHEN lsc_age-a028.
              ls_data-amountmonth28 = ls_data-amountmonth28 + lv_totalamount.
            WHEN lsc_age-a029.
              ls_data-amountmonth29 = ls_data-amountmonth29 + lv_totalamount.
            WHEN lsc_age-a030.
              ls_data-amountmonth30 = ls_data-amountmonth30 + lv_totalamount.
            WHEN lsc_age-a031.
              ls_data-amountmonth31 = ls_data-amountmonth31 + lv_totalamount.
            WHEN lsc_age-a032.
              ls_data-amountmonth32 = ls_data-amountmonth32 + lv_totalamount.
            WHEN lsc_age-a033.
              ls_data-amountmonth33 = ls_data-amountmonth33 + lv_totalamount.
            WHEN lsc_age-a034.
              ls_data-amountmonth34 = ls_data-amountmonth34 + lv_totalamount.
            WHEN lsc_age-a035.
              ls_data-amountmonth35 = ls_data-amountmonth35 + lv_totalamount.
            WHEN lsc_age-a036.
              ls_data-amountmonth36 = ls_data-amountmonth36 + lv_totalamount.
          ENDCASE.
        ENDIF.

        CLEAR lv_totalamount.
      ENDIF.

      APPEND ls_data TO lt_data.
      CLEAR ls_data.
    ENDLOOP.

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

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
