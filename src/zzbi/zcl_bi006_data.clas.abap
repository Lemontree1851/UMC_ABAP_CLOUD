CLASS zcl_bi006_data DEFINITION
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
      ty_t_data         TYPE STANDARD TABLE OF zi_bi006_report.


    METHODS: get_data IMPORTING ir_companycode  TYPE ty_t_companycode
                                ir_fiscalyear   TYPE ty_t_fiscalyear
                                ir_fiscalperiod TYPE ty_t_fiscalperiod
                                ir_plant        TYPE ty_t_plant
                                ir_product      TYPE ty_t_product
                                ir_customer     TYPE ty_t_customer
                                iv_detail_only  TYPE abap_bool DEFAULT abap_false
                      EXPORTING et_data         TYPE ty_t_data.
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
             standardprice        TYPE dmbtr,
           END OF ty_price.

ENDCLASS.



CLASS ZCL_BI006_DATA IMPLEMENTATION.


  METHOD get_data.
    DATA: lr_companycode TYPE RANGE OF i_companycode-companycode.

    "Step 1. Get ztfi_1019
    SELECT a~ledger,
           a~companycode,
           a~plant,
           a~fiscalyear,
           a~fiscalperiod,
           a~product,
           a~age,
           a~qty,
           b~currency,
           b~companycodename,
           b~controllingarea,
           c~plantname,
           c~valuationarea,
           d~producttype
    FROM ztfi_1019 AS a
    LEFT OUTER JOIN i_companycode AS b
    ON a~companycode = b~companycode
    LEFT OUTER JOIN i_plant AS c
    ON a~plant = c~plant
    LEFT OUTER JOIN i_product AS d
    ON a~product = d~product
    WHERE a~companycode IN @ir_companycode
    AND a~fiscalyear IN @ir_fiscalyear
    AND a~fiscalperiod IN @ir_fiscalperiod
    AND a~plant IN @ir_plant
    AND a~product IN @ir_product
    INTO TABLE @DATA(lt_detail).

*&--Authorization Check
    IF sy-batch = abap_false.
      DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
      DATA(lv_company) = zzcl_common_utils=>get_company_by_user( lv_user_email ).
      IF lv_company IS INITIAL.
        CLEAR lt_detail.
      ELSE.
        SPLIT lv_company AT '&' INTO TABLE DATA(lt_company_check).
        CLEAR lr_companycode.
        lr_companycode = VALUE #( FOR company IN lt_company_check ( sign = 'I' option = 'EQ' low = company ) ).
        DELETE lt_detail WHERE companycode NOT IN lr_companycode.
      ENDIF.
    ENDIF.
*&--Authorization Check

    CHECK lt_detail IS NOT INITIAL.

    "分组
    DATA: lt_raw        LIKE lt_detail,
          lt_fin        LIKE lt_detail,
          lt_raw_group  LIKE lt_detail,
          lt_fin_group  LIKE lt_detail,
          lt_group_data LIKE lt_detail,
          lt_group_temp LIKE lt_group_data.

    IF iv_detail_only = abap_false.
      lt_raw = lt_detail.
      lt_fin = lt_detail.

      DELETE lt_raw WHERE NOT ( producttype = 'ZROH' AND age > '012' ).
      DELETE lt_fin WHERE NOT ( (  producttype = 'ZFRT' OR producttype = 'ZHLB' )
                                AND  age > '003'
                               ).

      lt_raw_group = lt_raw.
      SORT lt_raw_group BY companycode plant product fiscalyear fiscalperiod.
      DELETE ADJACENT DUPLICATES FROM lt_raw_group COMPARING companycode plant product fiscalyear fiscalperiod.

      lt_fin_group = lt_fin.
      SORT lt_fin_group BY companycode plant product fiscalyear fiscalperiod.
      DELETE ADJACENT DUPLICATES FROM lt_fin_group COMPARING companycode plant product fiscalyear fiscalperiod.

      "SUM Product Aging Quantity
      LOOP AT lt_raw_group INTO DATA(ls_raw_group).
        CLEAR ls_raw_group-qty.
        LOOP AT lt_raw INTO DATA(ls_raw) WHERE companycode = ls_raw_group-companycode
                                           AND plant = ls_raw_group-plant
                                           AND product = ls_raw_group-product
                                           AND fiscalyear = ls_raw_group-fiscalyear
                                           AND fiscalperiod = ls_raw_group-fiscalperiod.
          ls_raw_group-qty = ls_raw_group-qty + ls_raw-qty.
        ENDLOOP.

        MODIFY lt_raw_group FROM ls_raw_group.
      ENDLOOP.

      LOOP AT lt_fin_group INTO DATA(ls_fin_group).
        CLEAR ls_fin_group-qty.
        LOOP AT lt_fin INTO DATA(ls_fin) WHERE companycode = ls_fin_group-companycode
                                           AND plant = ls_fin_group-plant
                                           AND product = ls_fin_group-product
                                           AND fiscalyear = ls_fin_group-fiscalyear
                                           AND fiscalperiod = ls_fin_group-fiscalperiod.
          ls_fin_group-qty = ls_fin_group-qty + ls_fin-qty.
        ENDLOOP.

        MODIFY lt_fin_group FROM ls_fin_group.
      ENDLOOP.

      APPEND LINES OF lt_fin_group TO lt_group_data.
      APPEND LINES OF lt_raw_group TO lt_group_data.
    ELSE.
      lt_group_data = lt_detail.
    ENDIF.

    "Select Other Master Data
    CHECK lt_group_data IS NOT INITIAL.
    lt_group_temp = lt_group_data.
    SORT lt_group_temp BY product ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_group_temp COMPARING product.

    IF lt_group_temp IS NOT INITIAL.
      SELECT product,
             productname
            FROM i_producttext
            WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_group_temp
            WHERE product = @lt_group_temp-product
            AND language = @sy-langu
            INTO TABLE @DATA(lt_producttext).
    ENDIF.

    lt_group_temp = lt_group_data.
    SORT lt_group_temp BY producttype ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_group_temp COMPARING producttype.

    IF lt_group_temp IS NOT INITIAL.
      SELECT producttype,
             producttypename
             FROM i_producttypetext_2
             WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_group_temp
             WHERE producttype = @lt_group_temp-producttype
             AND language = @sy-langu
             INTO TABLE @DATA(lt_producttypetext).
    ENDIF.

    lt_group_temp = lt_group_data.
    SORT lt_group_temp BY product ASCENDING plant ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_group_temp COMPARING product plant.

    IF lt_group_temp IS NOT INITIAL.
      SELECT product,
             plant,
             profitcenter,
             mrpresponsible
             FROM i_productplantbasic
             WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_group_temp
             WHERE product = @lt_group_temp-product
             AND plant = @lt_group_temp-plant
             INTO TABLE @DATA(lt_product_plant).
    ENDIF.

    DATA: lt_searchterm  TYPE STANDARD TABLE OF ty_searchterm,
          ls_searchterm  LIKE LINE OF lt_searchterm,
          lv_length      TYPE i,
          lv_start_pos   TYPE i,
          lv_searchterm2 TYPE c LENGTH 2.

    LOOP AT lt_product_plant INTO DATA(ls_product_plant).
      lv_length = strlen( ls_product_plant-mrpresponsible ).
      IF lv_length >= 2.
        lv_start_pos = lv_length - 2.
        lv_searchterm2 = ls_product_plant-mrpresponsible+lv_start_pos(2).

        READ TABLE lt_searchterm WITH KEY searchterm = lv_searchterm2 TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          CLEAR ls_searchterm.
          ls_searchterm-searchterm = lv_searchterm2.
          APPEND ls_searchterm TO lt_searchterm.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lt_searchterm IS NOT INITIAL.
      SELECT businesspartner,
             businesspartnername,
             searchterm2
        FROM i_businesspartner
        WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_searchterm
        WHERE searchterm2 = @lt_searchterm-searchterm
        INTO TABLE @DATA(lt_partner).

      SORT lt_partner BY businesspartner DESCENDING.
    ENDIF.

    DATA(lv_system_date) = cl_abap_context_info=>get_system_date(  ).
    DATA lt_product_plant_temp LIKE lt_product_plant.
    lt_product_plant_temp = lt_product_plant.
    SORT lt_product_plant_temp BY profitcenter ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_product_plant_temp COMPARING profitcenter.

    IF lt_product_plant_temp IS NOT INITIAL.
      SELECT profitcenter,
             profitcentername,
             controllingarea
             FROM i_profitcentertext
             WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_product_plant_temp
             WHERE profitcenter = @lt_product_plant_temp-profitcenter
             AND language = @sy-langu
             AND validitystartdate <= @lv_system_date
             AND validityenddate >= @lv_system_date
             INTO TABLE @DATA(lt_profitcentertext).
    ENDIF.

    "Actual Price
    SELECT c~companycode,
           f~fiscalyear,
           f~fiscalperiod,
           f~fiscalperiodenddate
    FROM i_companycode AS c
    INNER JOIN i_fiscalcalendardate AS f
    ON c~fiscalyearvariant = f~fiscalyearvariant
    FOR ALL ENTRIES IN @lt_group_data
    WHERE c~companycode = @lt_group_data-companycode
    AND f~fiscalyear = @lt_group_data-fiscalyear
    AND f~fiscalperiod = @lt_group_data-fiscalperiod
    INTO TABLE @DATA(lt_posting_date).

    SORT lt_posting_date BY companycode ASCENDING fiscalyear ASCENDING fiscalperiod ASCENDING fiscalperiodenddate DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_posting_date COMPARING companycode fiscalyear fiscalperiod.

    DATA: lt_price TYPE STANDARD TABLE OF ty_price,
          lv_date  TYPE datum.

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
              actualprice,
              standardprice
     FROM i_inventorypricebykeydate( p_calendardate = @lv_date )
     FOR ALL ENTRIES IN @lt_group_data
     WHERE ledger = @lt_group_data-ledger
     AND material = @lt_group_data-product
     AND currencyrole = '10'
     AND valuationarea = @lt_group_data-valuationarea
     AND ( materialpricecontrol = 'V' OR  materialpricecontrol = 'S' )
     AND inventoryspecialstocktype = ''
     APPENDING CORRESPONDING FIELDS OF TABLE @lt_price.
    ENDLOOP.

    SORT lt_price BY fiscalyear fiscalperiod material valuationarea materialpricecontrol.

    "Loop Process
    DATA: ls_data LIKE LINE OF et_data.

    LOOP AT lt_group_data INTO DATA(ls_group_data).
      CLEAR ls_data.
      MOVE-CORRESPONDING ls_group_data TO ls_data.
      ls_data-type = '長滞在庫'.

      IF ls_data-fiscalperiod IS NOT INITIAL.
        ls_data-fiscalyearmonth = |{ ls_data-fiscalyear }{ ls_data-fiscalperiod+1(2) }|.
        ls_data-period = ls_data-fiscalperiod+1(2).
      ENDIF.

      "Product Name
      READ TABLE lt_producttext INTO DATA(ls_producttext) WITH KEY product = ls_data-product.
      IF sy-subrc = 0.
        ls_data-productname = ls_producttext-productname.
      ENDIF.

      "product type name
      READ TABLE lt_producttypetext INTO DATA(ls_producttypetext) WITH KEY producttype = ls_data-producttype.
      IF sy-subrc = 0.
        ls_data-producttypename = ls_producttypetext-producttypename.
      ENDIF.

      "Profit center
      CLEAR: lv_searchterm2, lv_length, lv_start_pos, ls_product_plant.
      READ TABLE lt_product_plant INTO ls_product_plant WITH KEY product = ls_data-product
                                                                       plant = ls_data-plant.

      IF sy-subrc = 0.
        ls_data-profitcenter = ls_product_plant-profitcenter.

        lv_length = strlen( ls_product_plant-mrpresponsible ).
        IF lv_length >= 2.
          lv_start_pos = lv_length - 2.
          lv_searchterm2 = ls_product_plant-mrpresponsible+lv_start_pos(2).
        ENDIF.
      ENDIF.

      "Profit Center Text
      READ TABLE lt_profitcentertext INTO DATA(ls_profitcentertext) WITH KEY profitcenter = ls_data-profitcenter
                                                                             controllingarea = ls_group_data-controllingarea.
      IF sy-subrc = 0.
        ls_data-profitcentername = ls_profitcentertext-profitcentername.
      ENDIF.

      "Business Partner
      READ TABLE lt_partner INTO DATA(ls_partner) WITH KEY searchterm2 = lv_searchterm2.
      IF sy-subrc = 0.
        ls_data-customer = ls_partner-businesspartner.
        ls_data-customername = ls_partner-businesspartnername.
      ENDIF.

      "Price
      CLEAR: lv_date, ls_posting_date.
      READ TABLE lt_posting_date INTO ls_posting_date WITH KEY companycode = ls_data-companycode.
      IF sy-subrc = 0.
        lv_date = ls_posting_date-fiscalperiodenddate.
      ENDIF.

      READ TABLE lt_price INTO DATA(ls_price) WITH KEY fiscalyear = ls_data-fiscalyear
                                                       fiscalperiod = ls_data-fiscalperiod
                                                       material = ls_data-product
                                                       valuationarea = ls_data-valuationarea
                                                       materialpricecontrol = 'V'
                                                       BINARY SEARCH.
      IF sy-subrc = 0.
        IF ls_price-materialpriceunitqty <> 0.
          ls_data-actualprice = ls_price-actualprice / ls_price-materialpriceunitqty.
        ELSE.
          ls_data-actualprice = ls_price-actualprice.
        ENDIF.
      ELSE.
        READ TABLE lt_price INTO ls_price WITH KEY fiscalyear = ls_data-fiscalyear
                                                        fiscalperiod = ls_data-fiscalperiod
                                                        material = ls_data-product
                                                        valuationarea = ls_data-valuationarea
                                                        materialpricecontrol = 'S'
                                                        BINARY SEARCH.
        IF sy-subrc = 0.
          IF ls_price-materialpriceunitqty <> 0.
            ls_data-actualprice = ls_price-standardprice / ls_price-materialpriceunitqty.
          ELSE.
            ls_data-actualprice = ls_price-standardprice.
          ENDIF.
        ENDIF.
      ENDIF.

      ls_data-inventoryamount = ls_data-actualprice * ls_data-qty.


      IF ir_customer IS NOT INITIAL AND ls_data-customer NOT IN ir_customer.
        CONTINUE.
      ENDIF.

      "Add age field: for BI007 usage, not used in BI006
      IF iv_detail_only = abap_false.
        CLEAR ls_data-age.
      ENDIF.

      APPEND ls_data TO et_data.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
