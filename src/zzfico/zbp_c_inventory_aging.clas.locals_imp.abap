CLASS lhc_inventoryaging DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_filterdata,
        companycode  TYPE zc_inventory_aging-companycode,
        fiscalyear   TYPE zc_inventory_aging-fiscalyear,
        fiscalperiod TYPE zc_inventory_aging-fiscalperiod,
        ledger       TYPE zc_inventory_aging-ledger,
      END OF ty_filterdata,

      BEGIN OF lty_request,
        filterdata TYPE ty_filterdata,
        user       TYPE string,
        username   TYPE string,
        datetime   TYPE string,
      END OF lty_request,

      BEGIN OF ty_inventoryamtbyfsclperd,
        costestimate                TYPE i_inventoryamtbyfsclperd-costestimate,
        material                    TYPE i_inventoryamtbyfsclperd-material,
        valuationarea               TYPE i_inventoryamtbyfsclperd-valuationarea,
        valuationquantity           TYPE i_inventoryamtbyfsclperd-valuationquantity,
        amountincompanycodecurrency TYPE i_inventoryamtbyfsclperd-amountincompanycodecurrency,
        baseunit                    TYPE i_productplantbasic-baseunit,
        profitcenter                TYPE i_productplantbasic-profitcenter,
        mrpresponsible              TYPE i_productplantbasic-mrpresponsible,
        producttype                 TYPE i_product-producttype,
        currency                    TYPE i_companycode-currency,
      END OF ty_inventoryamtbyfsclperd,

      BEGIN OF ty_finalproductinfo,
        product  TYPE matnr,
        plant    TYPE werks_d,
        material TYPE matnr,
      END OF ty_finalproductinfo,

      BEGIN OF ty_materialdocumentitem,
        materialdocumentyear    TYPE i_materialdocumentitem_2-materialdocumentyear,
        materialdocument        TYPE i_materialdocumentitem_2-materialdocument,
        materialdocumentitem    TYPE i_materialdocumentitem_2-materialdocumentitem,
        postingdate             TYPE i_materialdocumentitem_2-postingdate,
        goodsmovementtype       TYPE i_materialdocumentitem_2-goodsmovementtype,
        plant                   TYPE i_materialdocumentitem_2-plant,
        material                TYPE i_materialdocumentitem_2-material,
*        isautomaticallycreated    TYPE i_materialdocumentitem_2-isautomaticallycreated,
        quantityinbaseunit      TYPE i_materialdocumentitem_2-quantityinbaseunit,
        supplier                TYPE i_materialdocumentitem_2-supplier,
        issgorrcvgmaterial      TYPE i_materialdocumentitem_2-issgorrcvgmaterial,
        issuingorreceivingplant TYPE i_materialdocumentitem_2-issuingorreceivingplant,
        debitcreditcode         TYPE i_materialdocumentitem_2-debitcreditcode,
*        rvslofgoodsreceiptisallowed TYPE i_materialdocumentitem_2-rvslofgoodsreceiptisallowed,
      END OF ty_materialdocumentitem,

      BEGIN OF ty_goosreceipt,
        plant              TYPE i_materialdocumentitem_2-plant,
        material           TYPE i_materialdocumentitem_2-material,
        postingdate        TYPE i_materialdocumentitem_2-postingdate,
        quantityinbaseunit TYPE i_materialdocumentitem_2-quantityinbaseunit,
        goodsmovementtype  TYPE i_materialdocumentitem_2-goodsmovementtype,
      END OF ty_goosreceipt,

      BEGIN OF ty_receipt,
        plant                   TYPE i_materialdocumentitem_2-plant,
        material                TYPE i_materialdocumentitem_2-material,
        postingdate             TYPE i_materialdocumentitem_2-postingdate,
        postingdate_receipt     TYPE i_materialdocumentitem_2-postingdate,
        goodsmovementtype       TYPE i_materialdocumentitem_2-goodsmovementtype,
        supplier                TYPE i_materialdocumentitem_2-supplier,
        quantityinbaseunit      TYPE i_materialdocumentitem_2-quantityinbaseunit,
        issgorrcvgmaterial      TYPE i_materialdocumentitem_2-issgorrcvgmaterial,
        issuingorreceivingplant TYPE i_materialdocumentitem_2-issuingorreceivingplant,
        delflag                 TYPE abap_boolean,
      END OF ty_receipt,

      BEGIN OF ty_qc_vendor,
        calendaryear        TYPE ztfi_1004-calendaryear,
        calendarmonth       TYPE ztfi_1004-calendarmonth,
        plant               TYPE i_materialdocumentitem_2-plant,
        material            TYPE i_materialdocumentitem_2-material,
        postingdate         TYPE i_materialdocumentitem_2-postingdate,
        postingdate_receipt TYPE i_materialdocumentitem_2-postingdate,
        quantityinbaseunit  TYPE i_materialdocumentitem_2-quantityinbaseunit,
      END OF ty_qc_vendor,

      BEGIN OF ty_productplant,
        plant       TYPE i_materialdocumentitem_2-plant,
        material    TYPE i_materialdocumentitem_2-material,
        postingdate TYPE i_materialdocumentitem_2-postingdate,
      END OF ty_productplant,

      BEGIN OF ty_stock,
        plant              TYPE i_materialdocumentitem_2-plant,
        material           TYPE i_materialdocumentitem_2-material,
        postingdate        TYPE i_materialdocumentitem_2-postingdate,
        quantityinbaseunit TYPE i_materialdocumentitem_2-quantityinbaseunit,
      END OF ty_stock,

      BEGIN OF ty_entries,
        plant         TYPE ztfi_1004-plant,
        material      TYPE ztfi_1004-material,
        postingdate   TYPE i_materialdocumentitem_2-postingdate,
        calendaryear  TYPE ztfi_1004-calendaryear,
        calendarmonth TYPE ztfi_1004-calendarmonth,
      END OF ty_entries,

      BEGIN OF ty_ztfi_1019,
        plant   TYPE ztfi_1019-plant,
        product TYPE ztfi_1019-product,
        age     TYPE ztfi_1019-age,
        qty     TYPE ztfi_1019-qty,
      END OF ty_ztfi_1019,

      BEGIN OF ty_ztbc_1001_zfi003,
        goodsmovementtype TYPE i_materialdocumentitem_2-goodsmovementtype,
      END OF ty_ztbc_1001_zfi003,

      BEGIN OF ty_ztbc_1001_zfi004,
        supplier                TYPE i_materialdocumentitem_2-supplier,
        issuingorreceivingplant TYPE i_materialdocumentitem_2-issuingorreceivingplant,
      END OF ty_ztbc_1001_zfi004.

    CONSTANTS:
      BEGIN OF lsc_producttype,
        zroh TYPE string VALUE 'ZROH',
        zhlb TYPE string VALUE 'ZHLB',
        zfrt TYPE string VALUE 'ZFRT',
      END OF lsc_producttype,

      lc_event_recalculate       TYPE string VALUE 'ReCalculate',
      lc_fiscalyear_init         TYPE string VALUE '2025',
      lc_fiscalperiod_init       TYPE string VALUE '002',
      lc_invspecialstocktype_t   TYPE string VALUE 'T',
      lc_invspecialstocktype_k   TYPE string VALUE 'K',
      lc_invspecialstocktype_e   TYPE string VALUE 'E',
      lc_currencyrole_10         TYPE string VALUE '10',
      lc_purhistorycategory_q    TYPE string VALUE 'Q',
      lc_billingdocumenttype_f2  TYPE string VALUE 'F2',
      lc_billingdocumenttype_iv2 TYPE string VALUE 'IV2',
      lc_zid_zfi003              TYPE string VALUE 'ZFI003',
      lc_zid_zfi004              TYPE string VALUE 'ZFI004',
      lc_goodsmovementtype_309   TYPE string VALUE '309',
      lc_goodsmovementtype_310   TYPE string VALUE '310',
      lc_debitcreditcode_s       TYPE string VALUE 'S',
      lc_fiyearvariant_v3        TYPE string VALUE 'V3',
      lc_periodtype_m            TYPE string VALUE 'M',
      lc_dd_01                   TYPE n LENGTH 2 VALUE '01',
      lc_sign_i                  TYPE c LENGTH 1 VALUE 'I',
      lc_option_eq               TYPE c LENGTH 2 VALUE 'EQ',
      lc_option_bt               TYPE c LENGTH 2 VALUE 'BT',
      lc_maxage_36               TYPE i VALUE '36',
      lc_age_1                   TYPE i VALUE '1',
      lc_month_1                 TYPE i VALUE '1',
      lc_month_3                 TYPE i VALUE '3'.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR inventoryaging RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION inventoryaging~processlogic RESULT result.

    METHODS recalculate CHANGING cs_data TYPE lty_request.

    METHODS read FOR READ
      IMPORTING keys FOR READ inventoryaging RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK inventoryaging.
ENDCLASS.

CLASS lhc_inventoryaging IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD processlogic.
    DATA:
      ls_request TYPE lty_request.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR ls_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                           pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                 CHANGING  data = ls_request ).
      CASE lv_event.
        WHEN lc_event_recalculate.
          recalculate( CHANGING cs_data = ls_request ).
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD recalculate.

    DATA:
      lt_inventoryamtbyfsclperd      TYPE STANDARD TABLE OF ty_inventoryamtbyfsclperd,
      lt_inventoryamtbyfsclperd_sum  TYPE STANDARD TABLE OF ty_inventoryamtbyfsclperd,
      lt_finalproductinfo            TYPE STANDARD TABLE OF ty_finalproductinfo,
      lt_usagelist                   TYPE STANDARD TABLE OF zcl_bom_where_used=>ty_usagelist,
      lt_materialdocumentitem        TYPE STANDARD TABLE OF ty_materialdocumentitem,
      lt_receipt                     TYPE STANDARD TABLE OF ty_receipt,
      lt_receipt2                    TYPE STANDARD TABLE OF ty_receipt,             "309
      lt_receipt3                    TYPE STANDARD TABLE OF ty_receipt,             "309期初库存部分
      lt_receipt4                    TYPE STANDARD TABLE OF ty_receipt,             "关联公司
      lt_receipt5                    TYPE STANDARD TABLE OF ty_receipt,             "关联公司期初库存部分
      lt_receipt_tmp                 TYPE STANDARD TABLE OF ty_receipt,
      lt_receipt_tmp2                TYPE STANDARD TABLE OF ty_receipt,
      lt_receipt_309                 TYPE STANDARD TABLE OF ty_receipt,
      lt_receipt_vendor              TYPE STANDARD TABLE OF ty_receipt, "关联公司
      lt_receipt_qc                  TYPE STANDARD TABLE OF ty_receipt, "期初
      lt_receipt_oriqc               TYPE STANDARD TABLE OF ty_receipt, "期初
      lt_receipt_309new              TYPE STANDARD TABLE OF ty_receipt, "309转化
      lt_receipt_vennew              TYPE STANDARD TABLE OF ty_receipt, "关联公司转化
      lt_qc_vendor                   TYPE STANDARD TABLE OF ty_qc_vendor, "关联公司期初
      lt_entries                     TYPE STANDARD TABLE OF ty_entries, "过账日期上个期间
      lt_matdocitem_issue            TYPE STANDARD TABLE OF ty_materialdocumentitem,
      lt_goosreceipt                 TYPE STANDARD TABLE OF ty_goosreceipt,
      lt_goosreceipt_309from         TYPE STANDARD TABLE OF ty_goosreceipt,
      lt_materialdocumentitem_309    TYPE STANDARD TABLE OF ty_materialdocumentitem,
      lt_matdocitem_309from          TYPE STANDARD TABLE OF ty_materialdocumentitem,
      lt_productplant                TYPE STANDARD TABLE OF ty_productplant,
      lt_stock                       TYPE STANDARD TABLE OF ty_stock,
      lt_materialdocumentitem_309tmp TYPE STANDARD TABLE OF ty_materialdocumentitem,
      lt_ztbc_1001_zfi003            TYPE STANDARD TABLE OF ty_ztbc_1001_zfi003,
      lt_ztbc_1001_zfi004            TYPE STANDARD TABLE OF ty_ztbc_1001_zfi004,
*      lt_ztfi_1004                   TYPE STANDARD TABLE OF ty_ztfi_1004,
*      lt_ztfi_1004_last              TYPE STANDARD TABLE OF ty_ztfi_1004,
      lt_ztfi_1019                   TYPE STANDARD TABLE OF ty_ztfi_1019,
      lt_ztfi_1019_last              TYPE STANDARD TABLE OF ty_ztfi_1019,
      lt_ztfi_1019_tmp               TYPE STANDARD TABLE OF ty_ztfi_1019,
      lt_ztfi_1019_cal               TYPE STANDARD TABLE OF ty_ztfi_1019,
      lt_ztfi_1019_cal_tmp           TYPE STANDARD TABLE OF ty_ztfi_1019,
      lt_ztfi_1019_db                TYPE STANDARD TABLE OF ztfi_1019,
      lr_postingdate                 TYPE RANGE OF i_materialdocumentitem_2-postingdate,
      lr_mvtype                      TYPE RANGE OF bwart,
      lr_fiscalyearperiod            TYPE RANGE OF i_fiscalyearperiodforvariant-fiscalyearperiod,
      ls_finalproductinfo            TYPE ty_finalproductinfo,
      ls_materialdocumentitem_309tmp TYPE ty_materialdocumentitem,
      ls_receipt                     TYPE ty_receipt,
      ls_receipt_309new              TYPE ty_receipt,
      ls_receipt_vennew              TYPE ty_receipt,
      ls_receipt_tmp2                TYPE ty_receipt,
      ls_qc_vendor                   TYPE ty_qc_vendor,
      ls_entries                     TYPE ty_entries,
      ls_ztbc_1001_zfi003            TYPE ty_ztbc_1001_zfi003,
      ls_ztbc_1001_zfi004            TYPE ty_ztbc_1001_zfi004,
      ls_productplant                TYPE ty_productplant,
      ls_stock                       TYPE ty_stock,
*      ls_ztfi_1014                   TYPE ty_ztfi_1004,
      ls_ztfi_1019_cal               TYPE ty_ztfi_1019,
      ls_ztfi_1019_db                TYPE ztfi_1019,
      ls_goosreceipt                 TYPE ty_goosreceipt,
      ls_goosreceipt_309from         TYPE ty_goosreceipt,
      lv_companycode                 TYPE zc_inventory_aging-companycode,
      lv_fiscalyear                  TYPE zc_inventory_aging-fiscalyear,
      lv_fiscalperiod                TYPE zc_inventory_aging-fiscalperiod,
      lv_fiscalperiod_tmp            TYPE zc_inventory_aging-fiscalperiod,
      lv_ledger                      TYPE zc_inventory_aging-ledger,
      lv_valuationunitprice          TYPE zc_inventory_aging-valuationunitprice,
      lv_goodsissueqty               TYPE i_materialdocumentitem_2-quantityinbaseunit,
      lv_totalqty                    TYPE i_materialdocumentitem_2-quantityinbaseunit,
      lv_qty                         TYPE i_materialdocumentitem_2-quantityinbaseunit,
      lv_timestampl                  TYPE timestampl,
      lv_fiscalyearperiod            TYPE i_fiscalyearperiodforvariant-fiscalyearperiod,
      lv_fiscalyear_last             TYPE i_fiscalyearperiodforvariant-fiscalyear,
      lv_fiscalperiod_last           TYPE i_fiscalyearperiodforvariant-fiscalperiod,
      lv_value                       TYPE p DECIMALS 2,
      lv_fiscalperiodstartdate       TYPE d,
      lv_fiscalperiodenddate         TYPE d,
      lv_age                         TYPE i.

*    IF cs_data-filterdata-fiscalyear = lc_fiscalyear_init AND cs_data-filterdata-fiscalperiod = lc_fiscalperiod_init.
*    IF cs_data-filterdata-fiscalyear = '2024' AND cs_data-filterdata-fiscalperiod = '005'.
*      SELECT a~plant,
*             a~material,
*             a~age,
*             a~qty
*        FROM ztfi_1004 AS a
*       INNER JOIN i_productvaluationareavh WITH PRIVILEGED ACCESS AS b
*          ON b~valuationarea = a~plant
*       INNER JOIN i_ledgercompanycodecrcyroles WITH PRIVILEGED ACCESS AS c
*          ON c~companycode = b~companycode
*       WHERE a~calendaryear = @cs_data-filterdata-fiscalyear
*         AND a~calendarmonth = @cs_data-filterdata-fiscalperiod+1(2)
*         AND b~companycode = @cs_data-filterdata-companycode
*         AND c~ledger = @cs_data-filterdata-ledger
*        INTO TABLE @DATA(lt_ztfi_1004_tmp).
*      IF sy-subrc = 0.
*        "Obtain data of inventory amount for fiscal period
*        SELECT costestimate,
*               material,
*               valuationarea,
*               valuationquantity,
*               amountincompanycodecurrency
*          FROM i_inventoryamtbyfsclperd( p_fiscalperiod = @cs_data-filterdata-fiscalperiod, p_fiscalyear = @cs_data-filterdata-fiscalyear ) WITH PRIVILEGED ACCESS
*           FOR ALL ENTRIES IN @lt_ztfi_1004_tmp
*         WHERE valuationarea = @lt_ztfi_1004_tmp-plant
*           AND material = @lt_ztfi_1004_tmp-material
*           AND companycode = @cs_data-filterdata-companycode
*           AND ledger = @cs_data-filterdata-ledger
*           AND invtryvalnspecialstocktype <> @lc_invspecialstocktype_t
*           AND invtryvalnspecialstocktype <> @lc_invspecialstocktype_e
*           AND valuationquantity <> 0
*           AND amountincompanycodecurrency <> 0
*          INTO TABLE @lt_inventoryamtbyfsclperd.
*
*        LOOP AT lt_inventoryamtbyfsclperd INTO DATA(ls_inventoryamtbyfsclperd).
*          CLEAR ls_inventoryamtbyfsclperd-costestimate.
*          COLLECT ls_inventoryamtbyfsclperd INTO lt_inventoryamtbyfsclperd_sum.
*        ENDLOOP.
*      ENDIF.
*
*      SORT lt_inventoryamtbyfsclperd_sum BY valuationarea material.
*
*      LOOP AT lt_ztfi_1004_tmp INTO DATA(ls_ztfi_1004_tmp).
*        CLEAR ls_inventoryamtbyfsclperd.
*
*        "Read data of inventory amount for fiscal period
*        READ TABLE lt_inventoryamtbyfsclperd_sum INTO ls_inventoryamtbyfsclperd WITH KEY valuationarea = ls_ztfi_1004_tmp-plant
*                                                                                         material = ls_ztfi_1004_tmp-material
*                                                                                BINARY SEARCH.
*        IF ls_inventoryamtbyfsclperd-valuationquantity <> 0.
*          ls_ztfi_1019_db-ledger       = cs_data-filterdata-ledger.
*          ls_ztfi_1019_db-companycode  = cs_data-filterdata-companycode.
*          ls_ztfi_1019_db-plant        = ls_ztfi_1004_tmp-plant.
*          ls_ztfi_1019_db-fiscalyear   = cs_data-filterdata-fiscalyear.
*          ls_ztfi_1019_db-fiscalperiod = cs_data-filterdata-fiscalperiod.
*          ls_ztfi_1019_db-product      = ls_ztfi_1004_tmp-material.
*          ls_ztfi_1019_db-age          = ls_ztfi_1004_tmp-age.
*          ls_ztfi_1019_db-qty          = ls_ztfi_1004_tmp-qty.
*          CONDENSE ls_ztfi_1019_db-age.
*
*          GET TIME STAMP FIELD lv_timestampl.
*          ls_ztfi_1019_db-last_changed_by = ''.
*          ls_ztfi_1019_db-last_changed_at = lv_timestampl.
*          ls_ztfi_1019_db-local_last_changed_at = lv_timestampl.
*          APPEND ls_ztfi_1019_db TO lt_ztfi_1019_db.
*          CLEAR ls_ztfi_1019_db.
*        ENDIF.
*      ENDLOOP.
*    ELSE.
    lv_companycode  = cs_data-filterdata-companycode.
    lv_fiscalyear   = cs_data-filterdata-fiscalyear.
    lv_fiscalperiod = cs_data-filterdata-fiscalperiod.
    lv_ledger       = cs_data-filterdata-ledger.

    "Obtain data of product
    SELECT a~companycode,
           a~valuationarea,
           b~currency,
           c~product,
           c~baseunit,
           c~profitcenter,
           c~mrpresponsible,
           d~producttype
      FROM i_productvaluationareavh WITH PRIVILEGED ACCESS AS a
     INNER JOIN i_companycode WITH PRIVILEGED ACCESS AS b
        ON b~companycode = a~companycode
     INNER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS c
        ON c~plant = a~valuationarea
     INNER JOIN i_product WITH PRIVILEGED ACCESS AS d
        ON d~product = c~product
     WHERE a~companycode = @lv_companycode
      INTO TABLE @DATA(lt_productplantbasic).
    IF sy-subrc = 0.
      "Obtain data of inventory amount for fiscal period
      SELECT costestimate,
             material,
             valuationarea,
             valuationquantity,
             amountincompanycodecurrency
        FROM i_inventoryamtbyfsclperd( p_fiscalperiod = @lv_fiscalperiod, p_fiscalyear = @lv_fiscalyear ) WITH PRIVILEGED ACCESS "#EC CI_NO_TRANSFORM
         FOR ALL ENTRIES IN @lt_productplantbasic
       WHERE companycode = @lt_productplantbasic-companycode
         AND valuationarea = @lt_productplantbasic-valuationarea
         AND material = @lt_productplantbasic-product
         AND ledger = @lv_ledger
         AND invtryvalnspecialstocktype <> @lc_invspecialstocktype_t
*         AND invtryvalnspecialstocktype <> @lc_invspecialstocktype_k
         AND invtryvalnspecialstocktype <> @lc_invspecialstocktype_e
         AND valuationquantity <> 0
*         AND amountincompanycodecurrency <> 0
        INTO TABLE @lt_inventoryamtbyfsclperd.

      LOOP AT lt_inventoryamtbyfsclperd INTO DATA(ls_inventoryamtbyfsclperd).
        CLEAR ls_inventoryamtbyfsclperd-costestimate.
        COLLECT ls_inventoryamtbyfsclperd INTO lt_inventoryamtbyfsclperd_sum.
      ENDLOOP.

      lv_fiscalyearperiod = lv_fiscalyear && lv_fiscalperiod.

      "Obtain data of fiscal year period for fiscal year variant
      SELECT SINGLE
             fiscalperiodstartdate,
             fiscalperiodenddate
        FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
       WHERE fiscalyearvariant = @lc_fiyearvariant_v3
         AND fiscalyearperiod = @lv_fiscalyearperiod
        INTO (@lv_fiscalperiodstartdate,@lv_fiscalperiodenddate).

      "Obtain data of material stock for periods
      SELECT material,
             plant,
             storagelocation,
             batch,
             supplier,
             sddocument,
             sddocumentitem,
             wbselementinternalid,
             customer,
             inventorystocktype,
             inventoryspecialstocktype,
             fiscalyearvariant,
             materialbaseunit,
             matlwrhsstkqtyinmatlbaseunit
        FROM i_materialstocktimeseries( p_startdate = @lv_fiscalperiodstartdate, p_enddate = @lv_fiscalperiodenddate, p_periodtype = @lc_periodtype_m ) WITH PRIVILEGED ACCESS "#EC CI_NO_TRANSFORM
         FOR ALL ENTRIES IN @lt_productplantbasic
       WHERE material = @lt_productplantbasic-product
         AND plant = @lt_productplantbasic-valuationarea
         AND companycode = @lt_productplantbasic-companycode
         AND matlwrhsstkqtyinmatlbaseunit <> 0
        INTO TABLE @DATA(lt_materialstocktimeseries).

      SORT lt_inventoryamtbyfsclperd BY valuationarea material.

      LOOP AT lt_materialstocktimeseries INTO DATA(ls_materialstocktimeseries).
        "Read data of inventory amount for fiscal period
        READ TABLE lt_inventoryamtbyfsclperd TRANSPORTING NO FIELDS WITH KEY valuationarea = ls_materialstocktimeseries-plant
                                                                             material = ls_materialstocktimeseries-material
                                                                    BINARY SEARCH.
        IF sy-subrc <> 0.
          CLEAR ls_inventoryamtbyfsclperd.
          ls_inventoryamtbyfsclperd-material = ls_materialstocktimeseries-material.
          ls_inventoryamtbyfsclperd-valuationarea = ls_materialstocktimeseries-plant.
          ls_inventoryamtbyfsclperd-valuationquantity = ls_materialstocktimeseries-matlwrhsstkqtyinmatlbaseunit.
          COLLECT ls_inventoryamtbyfsclperd INTO lt_inventoryamtbyfsclperd_sum.
        ENDIF.
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

          ls_inventoryamtbyfsclperd-baseunit       = ls_productplantbasic-baseunit.
          ls_inventoryamtbyfsclperd-profitcenter   = ls_productplantbasic-profitcenter.
          ls_inventoryamtbyfsclperd-mrpresponsible = ls_productplantbasic-mrpresponsible.
          ls_inventoryamtbyfsclperd-producttype    = ls_productplantbasic-producttype.
          ls_inventoryamtbyfsclperd-currency       = ls_productplantbasic-currency.
          APPEND ls_inventoryamtbyfsclperd TO lt_inventoryamtbyfsclperd.
        ENDIF.
      ENDLOOP.

      lt_productplantbasic = lt_productplantbasic_tmp.
    ENDIF.

*    DELETE lt_productplantbasic WHERE product <> 'ZTEST_RAW001' AND product <> 'ZTEST_RAW002' .
*    DELETE lt_productplantbasic WHERE product <> 'ZTEST_RAW002'.

    IF lt_productplantbasic IS NOT INITIAL.
      "Obtain data of inventory price by key date
      SELECT material,
             valuationarea,
             inventoryprice, "actualprice,
             materialpriceunitqty
        FROM i_inventorypricebykeydate( p_calendardate = @lv_fiscalperiodenddate )  WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_productplantbasic
       WHERE material = @lt_productplantbasic-product
         AND valuationarea = @lt_productplantbasic-valuationarea
         AND currencyrole = @lc_currencyrole_10
         AND ledger = @lv_ledger
         AND inventoryspecialstocktype <> @lc_invspecialstocktype_t
        INTO TABLE @DATA(lt_inventorypricebykeydate).

      DATA(lt_productplantbasic_zroh) = lt_productplantbasic.
      DELETE lt_productplantbasic_zroh WHERE producttype <> lsc_producttype-zroh.

      IF lt_productplantbasic_zroh IS NOT INITIAL.
        "Obtain data of supplier invoice
        SELECT a~purchaseorder,
               a~purchaseorderitem,
               a~accountassignmentnumber,
               a~purchasinghistorydocumenttype,
               a~purchasinghistorydocumentyear,
               a~purchasinghistorydocument,
               a~purchasinghistorydocumentitem,
               a~referencedocumentfiscalyear,
               a~referencedocument,
               a~plant,
               a~material
          FROM c_purchaseorderhistorydex WITH PRIVILEGED ACCESS AS a
         INNER JOIN c_supplierinvoicedex WITH PRIVILEGED ACCESS AS b
            ON b~supplierinvoice = a~purchasinghistorydocument
           FOR ALL ENTRIES IN @lt_productplantbasic_zroh
         WHERE a~plant = @lt_productplantbasic_zroh-valuationarea
           AND a~material = @lt_productplantbasic_zroh-product
           AND a~purchasinghistorycategory = @lc_purhistorycategory_q
           AND a~debitcreditcode = @lc_debitcreditcode_s
           AND a~postingdate <= @lv_fiscalperiodenddate
           AND a~purordamountincompanycodecrcy <> 0
           AND b~companycode = @lv_companycode
           AND b~fiscalyear = @lv_fiscalyear "lv_fiscalperiodstartdate+0(4)
           AND b~reversedocument = @space
           AND b~postingdate BETWEEN @lv_fiscalperiodstartdate AND @lv_fiscalperiodenddate
          INTO TABLE @DATA(lt_purchaseorderhistorydex_tmp).
        IF sy-subrc = 0.
          SORT lt_purchaseorderhistorydex_tmp BY plant material purchasinghistorydocument DESCENDING .
          DELETE ADJACENT DUPLICATES FROM lt_purchaseorderhistorydex_tmp COMPARING plant material.

          "Obtain data of supplier invoice
          SELECT purchaseorder,
                 purchaseorderitem,
                 accountassignmentnumber,
                 purchasinghistorydocumenttype,
                 purchasinghistorydocumentyear,
                 purchasinghistorydocument,
                 purchasinghistorydocumentitem,
                 referencedocumentfiscalyear,
                 referencedocument,
                 purordamountincompanycodecrcy,
                 quantityinbaseunit,
                 plant,
                 material
            FROM c_purchaseorderhistorydex WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_purchaseorderhistorydex_tmp
           WHERE purchasinghistorydocumentyear = @lt_purchaseorderhistorydex_tmp-referencedocumentfiscalyear
             AND purchasinghistorydocument = @lt_purchaseorderhistorydex_tmp-referencedocument
             AND plant = @lt_purchaseorderhistorydex_tmp-plant
             AND material = @lt_purchaseorderhistorydex_tmp-material
             AND debitcreditcode = @lc_debitcreditcode_s
            INTO TABLE @DATA(lt_purchaseorderhistorydex).
        ENDIF.
      ENDIF.

      DATA(lt_productplantbasic_zhlb) = lt_productplantbasic.
      DELETE lt_productplantbasic_zhlb WHERE producttype <> lsc_producttype-zhlb.

      LOOP AT lt_productplantbasic_zhlb INTO DATA(ls_productplantbasic_zhlb).
        "Obtain data of root level material of component(high level material)
        zcl_bom_where_used=>get_data_boi(
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
            APPEND ls_finalproductinfo TO lt_finalproductinfo.
            CLEAR ls_finalproductinfo.
          ENDLOOP.
*       high level material没有更高的high level material，则high level material为root level material，即final product
        ELSE.
          ls_finalproductinfo-product  = ls_productplantbasic_zhlb-product.
          ls_finalproductinfo-plant    = ls_productplantbasic_zhlb-valuationarea.
          ls_finalproductinfo-material = ls_productplantbasic_zhlb-product.
          APPEND ls_finalproductinfo TO lt_finalproductinfo.
          CLEAR ls_finalproductinfo.
        ENDIF.

        CLEAR lt_usagelist.
      ENDLOOP.

      SORT lt_finalproductinfo BY product plant material.
      DELETE ADJACENT DUPLICATES FROM lt_finalproductinfo
                            COMPARING product plant material.

      DATA(lt_productplantbasic_zfrt) = lt_productplantbasic.
      DELETE lt_productplantbasic_zfrt WHERE producttype <> lsc_producttype-zfrt.

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
           AND a~netamount > 0
           AND b~billingdocumentiscancelled = @abap_false
           AND b~cancelledbillingdocument = @space
           AND b~billingdocumenttype IN (@lc_billingdocumenttype_f2,@lc_billingdocumenttype_iv2)
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
           AND a~netamount > 0
           AND b~billingdocumentiscancelled = @abap_false
           AND b~cancelledbillingdocument = @space
           AND b~billingdocumenttype IN (@lc_billingdocumenttype_f2,@lc_billingdocumenttype_iv2)
           AND b~billingdocumentdate BETWEEN @lv_fiscalperiodstartdate AND @lv_fiscalperiodenddate
          INTO TABLE @DATA(lt_billingdocumentitem_final).
      ENDIF.

      "获取当前期间日期最后一天的前36个月日期
      zzcl_common_utils=>calc_date_subtract(
          EXPORTING
            date      = lv_fiscalperiodenddate
            month     = lc_maxage_36
          RECEIVING
            calc_date = DATA(lv_date_36m) ).

      lr_postingdate = VALUE #( sign = lc_sign_i option = lc_option_bt ( low = lv_date_36m high = lv_fiscalperiodenddate ) ).

      "Obtain movement type
      SELECT zid,
             zvalue1,
             zvalue2
        FROM ztbc_1001
       WHERE zid IN (@lc_zid_zfi003,@lc_zid_zfi004)
        INTO TABLE @DATA(lt_ztbc_1001).

      SORT lt_ztbc_1001 BY zid zvalue1 zvalue2.

      "获取入库移动类型+特殊库存类型
      LOOP AT lt_ztbc_1001 INTO DATA(ls_ztbc_1001).
        IF ls_ztbc_1001-zid = lc_zid_zfi003.
          lr_mvtype = VALUE #( BASE lr_mvtype sign = lc_sign_i option = lc_option_eq ( low = ls_ztbc_1001-zvalue1 ) ).

          IF ls_ztbc_1001-zvalue2 = abap_true.
            ls_ztbc_1001_zfi003-goodsmovementtype = ls_ztbc_1001-zvalue1.
            APPEND ls_ztbc_1001_zfi003 TO lt_ztbc_1001_zfi003.
            CLEAR ls_ztbc_1001_zfi003.
          ENDIF.
        ELSE.
          ls_ztbc_1001_zfi004-supplier = |{ ls_ztbc_1001-zvalue1 ALPHA = IN }|.
          ls_ztbc_1001_zfi004-issuingorreceivingplant = ls_ztbc_1001-zvalue2.
          APPEND ls_ztbc_1001_zfi004 TO lt_ztbc_1001_zfi004.
          CLEAR ls_ztbc_1001_zfi004.
        ENDIF.
      ENDLOOP.

      IF lr_mvtype IS NOT INITIAL.
        "获取最近36个月的入库记录
        SELECT materialdocumentyear,
               materialdocument,
               materialdocumentitem,
               postingdate,
               goodsmovementtype,
               plant,
               material,
               quantityinbaseunit,
               supplier,
               issgorrcvgmaterial,
               issuingorreceivingplant
          FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_productplantbasic
         WHERE plant = @lt_productplantbasic-valuationarea
           AND material = @lt_productplantbasic-product
           AND companycode = @lv_companycode
           AND debitcreditcode = @lc_debitcreditcode_s
*           AND rvslofgoodsreceiptisallowed = @abap_false
           AND goodsmovementtype IN @lr_mvtype
*           AND inventoryspecialstocktype = @space
           AND inventoryspecialstocktype <> @lc_invspecialstocktype_t
*           AND inventoryspecialstocktype <> @lc_invspecialstocktype_k
           AND inventoryspecialstocktype <> @lc_invspecialstocktype_e
           AND postingdate IN @lr_postingdate
          INTO TABLE @lt_materialdocumentitem.
        IF sy-subrc = 0.
          "Obtain material document of reverse
          SELECT materialdocumentyear,
                 materialdocument,
                 materialdocumentitem,
                 reversedmaterialdocumentyear,
                 reversedmaterialdocument,
                 reversedmaterialdocumentitem
            FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_materialdocumentitem
           WHERE reversedmaterialdocumentyear = @lt_materialdocumentitem-materialdocumentyear
             AND reversedmaterialdocument = @lt_materialdocumentitem-materialdocument
             AND reversedmaterialdocumentitem = @lt_materialdocumentitem-materialdocumentitem
            INTO TABLE @DATA(lt_materialdocumentitem_rev).
        ENDIF.
      ENDIF.

      SORT lt_ztbc_1001_zfi003 BY goodsmovementtype.
      SORT lt_ztbc_1001_zfi004 BY supplier.
      SORT lt_materialdocumentitem_rev BY reversedmaterialdocumentyear reversedmaterialdocument reversedmaterialdocumentitem.

      LOOP AT lt_materialdocumentitem INTO DATA(ls_materialdocumentitem).
        "Read material document of reversing
        READ TABLE lt_materialdocumentitem_rev TRANSPORTING NO FIELDS WITH KEY reversedmaterialdocumentyear = ls_materialdocumentitem-materialdocumentyear
                                                                               reversedmaterialdocument = ls_materialdocumentitem-materialdocument
                                                                               reversedmaterialdocumentitem = ls_materialdocumentitem-materialdocumentitem
                                                                      BINARY SEARCH.
        "No reversing for material document
        CHECK sy-subrc <> 0.

        ls_receipt-plant              = ls_materialdocumentitem-plant.
        ls_receipt-material           = ls_materialdocumentitem-material.
        ls_receipt-postingdate        = ls_materialdocumentitem-postingdate.
        ls_receipt-quantityinbaseunit = ls_materialdocumentitem-quantityinbaseunit.

        "判断是否是类309物料
        READ TABLE lt_ztbc_1001_zfi003 TRANSPORTING NO FIELDS WITH KEY goodsmovementtype = ls_materialdocumentitem-goodsmovementtype
                                                              BINARY SEARCH.
        IF sy-subrc = 0.
          ls_receipt-goodsmovementtype = abap_true.
          ls_receipt-issgorrcvgmaterial = ls_materialdocumentitem-issgorrcvgmaterial.
          ls_receipt-issuingorreceivingplant = ls_materialdocumentitem-issuingorreceivingplant.

          "类309
          COLLECT ls_receipt INTO lt_receipt_309.
        ELSE.
          "根据供应商，到配置表匹配关联公司的原始工厂，并将原始物料=物料
          READ TABLE lt_ztbc_1001_zfi004 INTO ls_ztbc_1001_zfi004 WITH KEY supplier = ls_materialdocumentitem-supplier
                                                                  BINARY SEARCH.
          IF sy-subrc = 0.
            ls_receipt-supplier = ls_materialdocumentitem-supplier.
            ls_receipt-issgorrcvgmaterial = ls_materialdocumentitem-material.
            ls_receipt-issuingorreceivingplant = ls_ztbc_1001_zfi004-issuingorreceivingplant.

            "关联公司
            COLLECT ls_receipt INTO lt_receipt_vendor.
          ENDIF.
        ENDIF.

        COLLECT ls_receipt INTO lt_receipt_tmp.
        CLEAR ls_receipt.
      ENDLOOP.

      SORT lt_receipt_tmp BY plant material postingdate DESCENDING.

      "获取类别为A的期初数据
      SELECT calendaryear,
             calendarmonth,
             plant,
             material,
             age,
             qty
        FROM ztfi_1004
         FOR ALL ENTRIES IN @lt_productplantbasic
       WHERE plant = @lt_productplantbasic-valuationarea
         AND material = @lt_productplantbasic-product
         AND inventorytype = 'A'
         AND ledger = @lv_ledger
        INTO TABLE @DATA(lt_ztfi_1004_tmp).


      LOOP AT lt_ztfi_1004_tmp INTO DATA(ls_ztfi_1004_tmp).
        lv_fiscalperiod_tmp = ls_ztfi_1004_tmp-calendarmonth.
        lv_fiscalyearperiod = ls_ztfi_1004_tmp-calendaryear && lv_fiscalperiod_tmp.
        lr_fiscalyearperiod = VALUE #( BASE lr_fiscalyearperiod sign = lc_sign_i option = lc_option_eq ( low = lv_fiscalyearperiod ) ).
      ENDLOOP.

      IF lr_fiscalyearperiod IS NOT INITIAL.
        "Obtain data of fiscal year period for fiscal year variant
        SELECT fiscalyearperiod,
               fiscalperiodstartdate,
               fiscalperiodenddate
          FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
         WHERE fiscalyearvariant = @lc_fiyearvariant_v3
           AND fiscalyearperiod IN @lr_fiscalyearperiod
          INTO TABLE @DATA(lt_fiscalyearperiodforvariant).

        SORT lt_fiscalyearperiodforvariant BY fiscalyearperiod.

        "期初数据转化为入库记录
        LOOP AT lt_ztfi_1004_tmp INTO ls_ztfi_1004_tmp.
          lv_fiscalperiod_tmp = ls_ztfi_1004_tmp-calendarmonth.
          lv_fiscalyearperiod = ls_ztfi_1004_tmp-calendaryear && lv_fiscalperiod_tmp.

          READ TABLE lt_fiscalyearperiodforvariant INTO DATA(ls_fiscalyearperiodforvariant) WITH KEY fiscalyearperiod = lv_fiscalyearperiod
                                                                                            BINARY SEARCH.
          IF sy-subrc = 0.
            lv_age = ls_ztfi_1004_tmp-age - 1.

            "获取当前日期指定月数前的日期
            zzcl_common_utils=>calc_date_subtract(
                EXPORTING
                  date      = ls_fiscalyearperiodforvariant-fiscalperiodenddate
                  month     = lv_age
                RECEIVING
                  calc_date = ls_fiscalyearperiodforvariant-fiscalperiodenddate ).

            ls_receipt-plant = ls_ztfi_1004_tmp-plant.
            ls_receipt-material = ls_ztfi_1004_tmp-material.
            ls_receipt-postingdate = ls_fiscalyearperiodforvariant-fiscalperiodenddate.
            ls_receipt-quantityinbaseunit = ls_ztfi_1004_tmp-qty.
            COLLECT ls_receipt INTO lt_receipt_oriqc.
            CLEAR ls_receipt.
          ENDIF.
        ENDLOOP.
      ENDIF.

*      SORT lt_receipt_oriqc BY plant material postingdate DESCENDING.
*      APPEND LINES OF lt_receipt_qc TO lt_receipt_tmp.

      "只保留累计入库数量（排除类309&关联公司的入库记录）>=期末库存数量的数据
      LOOP AT lt_inventoryamtbyfsclperd INTO ls_inventoryamtbyfsclperd.
        READ TABLE lt_receipt_tmp TRANSPORTING NO FIELDS WITH KEY plant = ls_inventoryamtbyfsclperd-valuationarea
                                                                  material = ls_inventoryamtbyfsclperd-material
                                                         BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_receipt_tmp INTO ls_receipt FROM sy-tabix.
            IF ls_receipt-plant <> ls_inventoryamtbyfsclperd-valuationarea
            OR ls_receipt-material <> ls_inventoryamtbyfsclperd-material.
              EXIT.
            ENDIF.

            APPEND ls_receipt TO lt_receipt.

            "排除类309&关联公司的入库记录
            IF ls_receipt-goodsmovementtype IS INITIAL AND ls_receipt-supplier IS INITIAL.
              "累计入库数量
              lv_totalqty = lv_totalqty + ls_receipt-quantityinbaseunit.

              IF lv_totalqty >= ls_inventoryamtbyfsclperd-valuationquantity.
                EXIT.
              ENDIF.
            ENDIF.
          ENDLOOP.

          CLEAR lv_totalqty.
        ENDIF.
      ENDLOOP.

      "类309
      IF lt_receipt_309 IS NOT INITIAL.
        CLEAR lt_materialdocumentitem.

        "获取原始物料的库存
        SELECT materialdocumentyear,
               materialdocument,
               materialdocumentitem,
               postingdate,
               goodsmovementtype,
               plant,
               material,
               quantityinbaseunit,
               supplier,
               issgorrcvgmaterial,
               issuingorreceivingplant,
               debitcreditcode
*               rvslofgoodsreceiptisallowed
          FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_receipt_309
         WHERE plant = @lt_receipt_309-issuingorreceivingplant
           AND material = @lt_receipt_309-issgorrcvgmaterial
           AND postingdate < @lt_receipt_309-postingdate
           AND companycode = @lv_companycode
*           AND rvslofgoodsreceiptisallowed = @abap_false
*           AND inventoryspecialstocktype = @space
           AND inventoryspecialstocktype <> @lc_invspecialstocktype_t
           AND inventoryspecialstocktype <> @lc_invspecialstocktype_k
           AND inventoryspecialstocktype <> @lc_invspecialstocktype_e
          INTO TABLE @lt_materialdocumentitem.
        IF sy-subrc = 0.
          CLEAR lt_materialdocumentitem_rev.

          "Obtain material document of reverse
          SELECT materialdocumentyear,
                 materialdocument,
                 materialdocumentitem,
                 reversedmaterialdocumentyear,
                 reversedmaterialdocument,
                 reversedmaterialdocumentitem
            FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_materialdocumentitem
           WHERE reversedmaterialdocumentyear = @lt_materialdocumentitem-materialdocumentyear
             AND reversedmaterialdocument = @lt_materialdocumentitem-materialdocument
             AND reversedmaterialdocumentitem = @lt_materialdocumentitem-materialdocumentitem
            INTO TABLE @lt_materialdocumentitem_rev.
        ENDIF.

        CLEAR lt_receipt_tmp.

        SORT lt_materialdocumentitem BY plant material.
        SORT lt_receipt_309 BY plant material postingdate DESCENDING.
        SORT lt_materialdocumentitem_rev BY reversedmaterialdocumentyear reversedmaterialdocument reversedmaterialdocumentitem.

        LOOP AT lt_receipt_309 INTO DATA(ls_receipt_309).
          READ TABLE lt_materialdocumentitem TRANSPORTING NO FIELDS WITH KEY plant = ls_receipt_309-issuingorreceivingplant
                                                                             material = ls_receipt_309-issgorrcvgmaterial
                                                                    BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_materialdocumentitem INTO ls_materialdocumentitem FROM sy-tabix.
              IF ls_materialdocumentitem-plant <> ls_receipt_309-issuingorreceivingplant
              OR ls_materialdocumentitem-material <> ls_receipt_309-issgorrcvgmaterial.
                EXIT.
              ENDIF.

              IF ls_materialdocumentitem-postingdate < ls_receipt_309-postingdate.
                ls_stock-plant       = ls_receipt_309-issuingorreceivingplant.
                ls_stock-material    = ls_receipt_309-issgorrcvgmaterial.
                ls_stock-postingdate = ls_receipt_309-postingdate.

                IF ls_materialdocumentitem-debitcreditcode = lc_debitcreditcode_s.
                  ls_stock-quantityinbaseunit = ls_materialdocumentitem-quantityinbaseunit.
                ELSE.
                  ls_stock-quantityinbaseunit = - ls_materialdocumentitem-quantityinbaseunit.
                ENDIF.

                COLLECT ls_stock INTO lt_stock.
                CLEAR ls_stock.

                "获取当前期间前36个月日期
                zzcl_common_utils=>calc_date_subtract(
                    EXPORTING
                      date      = ls_receipt_309-postingdate
                      month     = lc_maxage_36
                    RECEIVING
                      calc_date = lv_date_36m ).

                IF ls_materialdocumentitem-postingdate >= lv_date_36m.
*                   Goods Receipt
                  IF lr_mvtype IS NOT INITIAL AND ls_materialdocumentitem-goodsmovementtype IN lr_mvtype.
                    IF ls_materialdocumentitem-debitcreditcode = lc_debitcreditcode_s.
*                    AND ls_materialdocumentitem-rvslofgoodsreceiptisallowed = abap_false.
                      "Read material document of reversing
                      READ TABLE lt_materialdocumentitem_rev TRANSPORTING NO FIELDS WITH KEY reversedmaterialdocumentyear = ls_materialdocumentitem-materialdocumentyear
                                                                                             reversedmaterialdocument = ls_materialdocumentitem-materialdocument
                                                                                             reversedmaterialdocumentitem = ls_materialdocumentitem-materialdocumentitem
                                                                                    BINARY SEARCH.
                      "No reversing for material document
                      IF sy-subrc <> 0.
                        ls_receipt-plant              = ls_receipt_309-issuingorreceivingplant.
                        ls_receipt-material           = ls_receipt_309-issgorrcvgmaterial.
                        ls_receipt-postingdate        = ls_receipt_309-postingdate.
                        ls_receipt-postingdate_receipt = ls_materialdocumentitem-postingdate.
                        ls_receipt-quantityinbaseunit = ls_materialdocumentitem-quantityinbaseunit.
                        COLLECT ls_receipt INTO lt_receipt_tmp.
                        CLEAR ls_receipt.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDLOOP.

        SORT lt_stock BY plant material postingdate.
        SORT lt_receipt_tmp BY plant material postingdate postingdate_receipt DESCENDING.

        "只保留累计入库数量>=期末库存数量的数据(入库记录扣减)
        LOOP AT lt_stock ASSIGNING FIELD-SYMBOL(<fs_stock>).
          READ TABLE lt_receipt_tmp TRANSPORTING NO FIELDS WITH KEY plant = <fs_stock>-plant
                                                                    material = <fs_stock>-material
                                                                    postingdate = <fs_stock>-postingdate
                                                           BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_receipt_tmp INTO DATA(ls_receipt_tmp) FROM sy-tabix.
              IF ls_receipt_tmp-plant <> <fs_stock>-plant
              OR ls_receipt_tmp-material <> <fs_stock>-material
              OR ls_receipt_tmp-postingdate <> <fs_stock>-postingdate.
                EXIT.
              ENDIF.

              IF <fs_stock>-quantityinbaseunit >= ls_receipt_tmp-quantityinbaseunit.
                <fs_stock>-quantityinbaseunit = <fs_stock>-quantityinbaseunit - ls_receipt_tmp-quantityinbaseunit.
                lv_qty = ls_receipt_tmp-quantityinbaseunit.
              ELSE.
                lv_qty = <fs_stock>-quantityinbaseunit.
                CLEAR <fs_stock>-quantityinbaseunit.
              ENDIF.

              ls_receipt-plant = ls_receipt_tmp-plant.
              ls_receipt-material = ls_receipt_tmp-material.
              ls_receipt-postingdate = ls_receipt_tmp-postingdate.
              ls_receipt-postingdate_receipt = ls_receipt_tmp-postingdate_receipt.
              ls_receipt-quantityinbaseunit = lv_qty.
              APPEND ls_receipt TO lt_receipt2.
              CLEAR ls_receipt.

              IF <fs_stock>-quantityinbaseunit = 0.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDLOOP.

        DELETE lt_stock WHERE quantityinbaseunit = 0.
*        SORT lt_receipt2 BY plant material postingdate postingdate_receipt.

        IF lt_stock IS NOT INITIAL.
          CLEAR lt_ztfi_1004_tmp.

          "获取类别为A的期初数据
          SELECT calendaryear,
                 calendarmonth,
                 plant,
                 material,
                 age,
                 qty
            FROM ztfi_1004
             FOR ALL ENTRIES IN @lt_stock
           WHERE plant = @lt_stock-plant
             AND material = @lt_stock-material
             AND inventorytype = 'A'
             AND ledger = @lv_ledger
            INTO TABLE @lt_ztfi_1004_tmp.

          CLEAR lr_fiscalyearperiod.

          LOOP AT lt_ztfi_1004_tmp INTO ls_ztfi_1004_tmp.
            lv_fiscalperiod_tmp = ls_ztfi_1004_tmp-calendarmonth.
            lv_fiscalyearperiod = ls_ztfi_1004_tmp-calendaryear && lv_fiscalperiod_tmp.
            lr_fiscalyearperiod = VALUE #( BASE lr_fiscalyearperiod sign = lc_sign_i option = lc_option_eq ( low = lv_fiscalyearperiod ) ).
          ENDLOOP.

          IF lr_fiscalyearperiod IS NOT INITIAL.
            CLEAR lt_fiscalyearperiodforvariant.

            "Obtain data of fiscal year period for fiscal year variant
            SELECT fiscalyearperiod,
                   fiscalperiodstartdate,
                   fiscalperiodenddate
              FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
             WHERE fiscalyearvariant = @lc_fiyearvariant_v3
               AND fiscalyearperiod IN @lr_fiscalyearperiod
              INTO TABLE @lt_fiscalyearperiodforvariant.

            SORT lt_fiscalyearperiodforvariant BY fiscalyearperiod.

            CLEAR lt_receipt_qc.

            "期初数据转化为入库记录
            LOOP AT lt_ztfi_1004_tmp INTO ls_ztfi_1004_tmp.
              lv_fiscalperiod_tmp = ls_ztfi_1004_tmp-calendarmonth.
              lv_fiscalyearperiod = ls_ztfi_1004_tmp-calendaryear && lv_fiscalperiod_tmp.

              READ TABLE lt_fiscalyearperiodforvariant INTO ls_fiscalyearperiodforvariant WITH KEY fiscalyearperiod = lv_fiscalyearperiod
                                                                                          BINARY SEARCH.
              IF sy-subrc = 0.
                lv_age = ls_ztfi_1004_tmp-age - 1.

                "获取当前日期指定月数前的日期
                zzcl_common_utils=>calc_date_subtract(
                    EXPORTING
                      date      = ls_fiscalyearperiodforvariant-fiscalperiodenddate
                      month     = lv_age
                    RECEIVING
                      calc_date = ls_fiscalyearperiodforvariant-fiscalperiodenddate ).

                ls_receipt-plant = ls_ztfi_1004_tmp-plant.
                ls_receipt-material = ls_ztfi_1004_tmp-material.
                ls_receipt-postingdate_receipt = ls_fiscalyearperiodforvariant-fiscalperiodenddate.
                ls_receipt-quantityinbaseunit = ls_ztfi_1004_tmp-qty.
                COLLECT ls_receipt INTO lt_receipt_qc.
                CLEAR ls_receipt.
              ENDIF.
            ENDLOOP.
          ENDIF.

          SORT lt_receipt_qc BY plant material postingdate_receipt DESCENDING.

          "只保留累计入库数量>=期末库存数量的数据(期初库存扣减)
          LOOP AT lt_stock ASSIGNING <fs_stock>.
            READ TABLE lt_receipt_qc TRANSPORTING NO FIELDS WITH KEY plant = <fs_stock>-plant
                                                                     material = <fs_stock>-material
                                                            BINARY SEARCH.
            IF sy-subrc = 0.
              LOOP AT lt_receipt_qc ASSIGNING FIELD-SYMBOL(<fs_receipt>) FROM sy-tabix.
                IF <fs_receipt>-plant <> <fs_stock>-plant
                OR <fs_receipt>-material <> <fs_stock>-material.
                  EXIT.
                ENDIF.

                IF <fs_stock>-quantityinbaseunit >= <fs_receipt>-quantityinbaseunit.
                  <fs_stock>-quantityinbaseunit = <fs_stock>-quantityinbaseunit - <fs_receipt>-quantityinbaseunit.
                  lv_qty = <fs_receipt>-quantityinbaseunit.
                  CLEAR <fs_receipt>-quantityinbaseunit.
                ELSE.
                  <fs_receipt>-quantityinbaseunit = <fs_receipt>-quantityinbaseunit - <fs_stock>-quantityinbaseunit.
                  lv_qty = <fs_stock>-quantityinbaseunit.
                  CLEAR <fs_stock>-quantityinbaseunit.
                ENDIF.

                ls_receipt-plant = <fs_receipt>-plant.
                ls_receipt-material = <fs_receipt>-material.
                ls_receipt-postingdate = <fs_stock>-postingdate.
                ls_receipt-postingdate_receipt = <fs_receipt>-postingdate_receipt.
                ls_receipt-quantityinbaseunit = lv_qty.
*                APPEND ls_receipt TO lt_receipt3.
                COLLECT ls_receipt INTO lt_receipt2.
                CLEAR ls_receipt.

                IF <fs_stock>-quantityinbaseunit = 0.
                  EXIT.
                ENDIF.
              ENDLOOP.

              DELETE lt_receipt_qc WHERE quantityinbaseunit = 0.
            ENDIF.
          ENDLOOP.
        ENDIF.

*        SORT lt_receipt3 BY plant material postingdate postingdate_receipt.
        SORT lt_receipt2 BY plant material postingdate postingdate_receipt.

        LOOP AT lt_receipt_309 INTO ls_receipt_309.
          READ TABLE lt_receipt2 TRANSPORTING NO FIELDS WITH KEY plant = ls_receipt_309-issuingorreceivingplant
                                                                 material = ls_receipt_309-issgorrcvgmaterial
                                                                 postingdate = ls_receipt_309-postingdate
                                                        BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_receipt2 INTO DATA(ls_receipt2) FROM sy-tabix.
              IF ls_receipt2-plant <> ls_receipt_309-issuingorreceivingplant
              OR ls_receipt2-material <> ls_receipt_309-issgorrcvgmaterial
              OR ls_receipt2-postingdate <> ls_receipt_309-postingdate.
                EXIT.
              ENDIF.

              IF ls_receipt_309-quantityinbaseunit >= ls_receipt2-quantityinbaseunit.
                ls_receipt_309-quantityinbaseunit = ls_receipt_309-quantityinbaseunit - ls_receipt2-quantityinbaseunit.

                ls_receipt_309new-plant = ls_receipt2-plant.
                ls_receipt_309new-material = ls_receipt2-material.
                ls_receipt_309new-postingdate = ls_receipt2-postingdate.
                ls_receipt_309new-quantityinbaseunit = ls_receipt2-quantityinbaseunit.
                ls_receipt_309new-postingdate_receipt = ls_receipt2-postingdate_receipt.
                APPEND ls_receipt_309new TO lt_receipt_309new.
                CLEAR ls_receipt_309new.
              ELSE.
                ls_receipt_309new-plant = ls_receipt2-plant.
                ls_receipt_309new-material = ls_receipt2-material.
                ls_receipt_309new-postingdate = ls_receipt2-postingdate.
                ls_receipt_309new-quantityinbaseunit = ls_receipt_309-quantityinbaseunit.
                ls_receipt_309new-postingdate_receipt = ls_receipt2-postingdate_receipt.
                APPEND ls_receipt_309new TO lt_receipt_309new.
                CLEAR ls_receipt_309new.

                CLEAR ls_receipt_309-quantityinbaseunit.
              ENDIF.

              "扣减完毕
              IF ls_receipt_309-quantityinbaseunit = 0.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.

*        "不够，扣减期初库存
*        IF ls_receipt_309-quantityinbaseunit > 0.
*          READ TABLE lt_receipt3 TRANSPORTING NO FIELDS WITH KEY plant = ls_receipt_309-issuingorreceivingplant
*                                                                 material = ls_receipt_309-issgorrcvgmaterial
*                                                                 postingdate = ls_receipt_309-postingdate
*                                                        BINARY SEARCH.
*          IF sy-subrc = 0.
*            LOOP AT lt_receipt3 INTO DATA(ls_receipt3) FROM sy-tabix.
*              IF ls_receipt3-plant <> ls_receipt_309-plant
*              OR ls_receipt3-material <> ls_receipt_309-material
*              OR ls_receipt3-postingdate <> ls_receipt_309-postingdate.
*                EXIT.
*              ENDIF.
*
*              IF ls_receipt_309-quantityinbaseunit >= ls_receipt3-quantityinbaseunit.
*                ls_receipt_309-quantityinbaseunit = ls_receipt_309-quantityinbaseunit - ls_receipt3-quantityinbaseunit.
*
*                ls_receipt_309new-plant = ls_receipt3-quantityinbaseunit.
*                ls_receipt_309new-material = ls_receipt3-material.
*                ls_receipt_309new-postingdate = ls_receipt3-postingdate.
*                ls_receipt_309new-quantityinbaseunit = ls_receipt3-quantityinbaseunit.
*                ls_receipt_309new-postingdate_receipt = ls_receipt3-postingdate_receipt.
*                APPEND ls_receipt_309new TO lt_receipt_309new.
*                CLEAR ls_receipt_309new.
*              ELSE.
*                ls_receipt_309new-plant = ls_receipt3-quantityinbaseunit.
*                ls_receipt_309new-material = ls_receipt3-material.
*                ls_receipt_309new-postingdate = ls_receipt3-postingdate.
*                ls_receipt_309new-quantityinbaseunit = ls_receipt_309-quantityinbaseunit.
*                ls_receipt_309new-postingdate_receipt = ls_receipt3-postingdate_receipt.
*                APPEND ls_receipt_309new TO lt_receipt_309new.
*                CLEAR ls_receipt_309new.
*
*                CLEAR ls_receipt_309-quantityinbaseunit.
*              ENDIF.
*
*              "扣减完毕
*              IF ls_receipt_309-quantityinbaseunit = 0.
*                EXIT.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.
*        ENDIF.
        ENDLOOP.
      ENDIF.

      "关联公司
      IF lt_receipt_vendor IS NOT INITIAL.
        CLEAR lt_materialdocumentitem.

        "获取原始物料的库存
        SELECT materialdocumentyear,
               materialdocument,
               materialdocumentitem,
               postingdate,
               goodsmovementtype,
               plant,
               material,
               quantityinbaseunit,
               supplier,
               issgorrcvgmaterial,
               issuingorreceivingplant,
               debitcreditcode
*               rvslofgoodsreceiptisallowed
          FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_receipt_vendor
         WHERE plant = @lt_receipt_vendor-issuingorreceivingplant
           AND material = @lt_receipt_vendor-issgorrcvgmaterial
           AND postingdate < @lt_receipt_vendor-postingdate
           AND companycode = @lv_companycode
*           AND rvslofgoodsreceiptisallowed = @abap_false
*           AND inventoryspecialstocktype = @space
           AND inventoryspecialstocktype <> @lc_invspecialstocktype_t
           AND inventoryspecialstocktype <> @lc_invspecialstocktype_k
           AND inventoryspecialstocktype <> @lc_invspecialstocktype_e
          INTO TABLE @lt_materialdocumentitem.
        IF sy-subrc = 0.
          CLEAR lt_materialdocumentitem_rev.

          "Obtain material document of reverse
          SELECT materialdocumentyear,
                 materialdocument,
                 materialdocumentitem,
                 reversedmaterialdocumentyear,
                 reversedmaterialdocument,
                 reversedmaterialdocumentitem
            FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS "#EC CI_NO_TRANSFORM
             FOR ALL ENTRIES IN @lt_materialdocumentitem
           WHERE reversedmaterialdocumentyear = @lt_materialdocumentitem-materialdocumentyear
             AND reversedmaterialdocument = @lt_materialdocumentitem-materialdocument
             AND reversedmaterialdocumentitem = @lt_materialdocumentitem-materialdocumentitem
            INTO TABLE @lt_materialdocumentitem_rev.
        ENDIF.

        "Obtain data of fiscal year period for fiscal year variant
        SELECT fiscalyearperiod,
               fiscalyear,
               fiscalperiod,
               fiscalperiodstartdate,
               fiscalperiodenddate
          FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_receipt_vendor
         WHERE fiscalperiodstartdate <= @lt_receipt_vendor-postingdate
           AND fiscalperiodenddate >= @lt_receipt_vendor-postingdate
           AND fiscalyearvariant = @lc_fiyearvariant_v3
          INTO TABLE @DATA(lt_fiscalyearperiod_new).
        IF sy-subrc = 0.
          SELECT fiscalyearperiod,
                 fiscalyear,
                 fiscalperiod,
                 nextfiscalperiod,
                 nextfiscalperiodfiscalyear
            FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS "#EC CI_NO_TRANSFORM
             FOR ALL ENTRIES IN @lt_fiscalyearperiod_new
           WHERE nextfiscalperiod = @lt_fiscalyearperiod_new-fiscalperiod
             AND nextfiscalperiodfiscalyear = @lt_fiscalyearperiod_new-fiscalyear
             AND fiscalyearvariant = @lc_fiyearvariant_v3
            INTO TABLE @DATA(lt_fiscalyearperiod_last).
        ENDIF.

        CLEAR:
          lt_stock,
          lt_receipt_tmp.

        SORT lt_materialdocumentitem BY plant material.
        SORT lt_materialdocumentitem_rev BY reversedmaterialdocumentyear reversedmaterialdocument reversedmaterialdocumentitem.
        SORT lt_fiscalyearperiod_last BY nextfiscalperiod nextfiscalperiodfiscalyear.

        LOOP AT lt_receipt_vendor INTO DATA(ls_receipt_vendor).
          READ TABLE lt_materialdocumentitem TRANSPORTING NO FIELDS WITH KEY plant = ls_receipt_vendor-issuingorreceivingplant
                                                                             material = ls_receipt_vendor-issgorrcvgmaterial
                                                                    BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_materialdocumentitem INTO ls_materialdocumentitem FROM sy-tabix.
              IF ls_materialdocumentitem-plant <> ls_receipt_vendor-issuingorreceivingplant
              OR ls_materialdocumentitem-material <> ls_receipt_vendor-issgorrcvgmaterial.
                EXIT.
              ENDIF.

              IF ls_materialdocumentitem-postingdate < ls_receipt_vendor-postingdate.
                ls_stock-plant       = ls_receipt_vendor-issuingorreceivingplant.
                ls_stock-material    = ls_receipt_vendor-issgorrcvgmaterial.
                ls_stock-postingdate = ls_receipt_vendor-postingdate.

                IF ls_materialdocumentitem-debitcreditcode = lc_debitcreditcode_s.
                  ls_stock-quantityinbaseunit = ls_materialdocumentitem-quantityinbaseunit.
                ELSE.
                  ls_stock-quantityinbaseunit = - ls_materialdocumentitem-quantityinbaseunit.
                ENDIF.

                COLLECT ls_stock INTO lt_stock.
                CLEAR ls_stock.

                "获取当前期间前36个月日期
                zzcl_common_utils=>calc_date_subtract(
                    EXPORTING
                      date      = ls_receipt_vendor-postingdate
                      month     = lc_maxage_36
                    RECEIVING
                      calc_date = lv_date_36m ).

                IF ls_materialdocumentitem-postingdate >= lv_date_36m.
                  "Goods Receipt
                  IF lr_mvtype IS NOT INITIAL AND ls_materialdocumentitem-goodsmovementtype IN lr_mvtype.
                    IF ls_materialdocumentitem-debitcreditcode = lc_debitcreditcode_s.
*                    AND ls_materialdocumentitem-rvslofgoodsreceiptisallowed = abap_false.
                      "Read material document of reversing
                      READ TABLE lt_materialdocumentitem_rev TRANSPORTING NO FIELDS WITH KEY reversedmaterialdocumentyear = ls_materialdocumentitem-materialdocumentyear
                                                                                             reversedmaterialdocument = ls_materialdocumentitem-materialdocument
                                                                                             reversedmaterialdocumentitem = ls_materialdocumentitem-materialdocumentitem
                                                                                    BINARY SEARCH.
                      "No reversing for material document
                      IF sy-subrc <> 0.
                        ls_receipt-plant              = ls_receipt_vendor-issuingorreceivingplant.
                        ls_receipt-material           = ls_receipt_vendor-issgorrcvgmaterial.
                        ls_receipt-postingdate        = ls_receipt_vendor-postingdate.
                        ls_receipt-postingdate_receipt = ls_materialdocumentitem-postingdate.
                        ls_receipt-quantityinbaseunit = ls_materialdocumentitem-quantityinbaseunit.
                        COLLECT ls_receipt INTO lt_receipt_tmp.
                        CLEAR ls_receipt.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.

          "获取过账日期的上个期间数据（用于获取类别为B的期初数据）
          ls_entries-plant = ls_receipt_vendor-issuingorreceivingplant.
          ls_entries-material = ls_receipt_vendor-issgorrcvgmaterial.
          ls_entries-postingdate = ls_receipt_vendor-postingdate.

          LOOP AT lt_fiscalyearperiod_new INTO DATA(ls_fiscalyearperiod_new) WHERE fiscalperiodstartdate <= ls_receipt_vendor-postingdate
                                                                               AND fiscalperiodenddate >= ls_receipt_vendor-postingdate.

            READ TABLE lt_fiscalyearperiod_last INTO DATA(ls_fiscalyearperiod_last) WITH KEY nextfiscalperiod = ls_fiscalyearperiod_new-fiscalperiod
                                                                                             nextfiscalperiodfiscalyear = ls_fiscalyearperiod_new-fiscalyear
                                                                                    BINARY SEARCH.
            IF sy-subrc = 0.
              ls_entries-calendaryear = ls_fiscalyearperiod_last-fiscalyear.
              ls_entries-calendarmonth = ls_fiscalyearperiod_last-fiscalperiod.
              APPEND ls_entries TO lt_entries.
              CLEAR ls_entries.
            ENDIF.

            EXIT.
          ENDLOOP.
        ENDLOOP.

        IF lt_entries IS NOT INITIAL.
          CLEAR lt_ztfi_1004_tmp.

          "获取类别为B的期初数据
          SELECT calendaryear,
                 calendarmonth,
                 plant,
                 material,
                 age,
                 qty
            FROM ztfi_1004
             FOR ALL ENTRIES IN @lt_entries
           WHERE calendaryear = @lt_entries-calendaryear
             AND calendarmonth = @lt_entries-calendarmonth
             AND plant = @lt_entries-plant
             AND material = @lt_entries-material
             AND inventorytype = 'B'
             AND ledger = @lv_ledger
            INTO TABLE @lt_ztfi_1004_tmp.

          CLEAR lr_fiscalyearperiod.

          LOOP AT lt_ztfi_1004_tmp INTO ls_ztfi_1004_tmp.
            lv_fiscalperiod_tmp = ls_ztfi_1004_tmp-calendarmonth.
            lv_fiscalyearperiod = ls_ztfi_1004_tmp-calendaryear && lv_fiscalperiod_tmp.
            lr_fiscalyearperiod = VALUE #( BASE lr_fiscalyearperiod sign = lc_sign_i option = lc_option_eq ( low = lv_fiscalyearperiod ) ).
          ENDLOOP.

          IF lr_fiscalyearperiod IS NOT INITIAL.
            CLEAR lt_fiscalyearperiodforvariant.

            "Obtain data of fiscal year period for fiscal year variant
            SELECT fiscalyearperiod,
                   fiscalperiodstartdate,
                   fiscalperiodenddate
              FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
             WHERE fiscalyearvariant = @lc_fiyearvariant_v3
               AND fiscalyearperiod IN @lr_fiscalyearperiod
              INTO TABLE @lt_fiscalyearperiodforvariant.

            SORT lt_fiscalyearperiodforvariant BY fiscalyearperiod.

            "B类型期初数据转化为入库记录
            LOOP AT lt_ztfi_1004_tmp INTO ls_ztfi_1004_tmp.
              lv_fiscalperiod_tmp = ls_ztfi_1004_tmp-calendarmonth.
              lv_fiscalyearperiod = ls_ztfi_1004_tmp-calendaryear && lv_fiscalperiod_tmp.

              READ TABLE lt_fiscalyearperiodforvariant INTO ls_fiscalyearperiodforvariant WITH KEY fiscalyearperiod = lv_fiscalyearperiod
                                                                                          BINARY SEARCH.
              IF sy-subrc = 0.
                lv_age = ls_ztfi_1004_tmp-age - 1.

                "获取当前日期指定月数前的日期
                zzcl_common_utils=>calc_date_subtract(
                    EXPORTING
                      date      = ls_fiscalyearperiodforvariant-fiscalperiodenddate
                      month     = lv_age
                    RECEIVING
                      calc_date = ls_fiscalyearperiodforvariant-fiscalperiodenddate ).

                ls_qc_vendor-calendaryear = ls_ztfi_1004_tmp-calendaryear.
                ls_qc_vendor-calendarmonth = ls_ztfi_1004_tmp-calendarmonth.
                ls_qc_vendor-plant = ls_ztfi_1004_tmp-plant.
                ls_qc_vendor-material = ls_ztfi_1004_tmp-material.
                ls_qc_vendor-postingdate_receipt = ls_fiscalyearperiodforvariant-fiscalperiodenddate.
                ls_qc_vendor-quantityinbaseunit = ls_ztfi_1004_tmp-qty.
                COLLECT ls_qc_vendor INTO lt_qc_vendor.
                CLEAR ls_qc_vendor.
              ENDIF.
            ENDLOOP.
          ENDIF.

          SORT lt_qc_vendor BY calendaryear calendarmonth plant material postingdate_receipt.

          LOOP AT lt_receipt_vendor INTO ls_receipt_vendor.
            "获取过账日期所在的期间
            LOOP AT lt_fiscalyearperiod_new INTO ls_fiscalyearperiod_new WHERE fiscalperiodstartdate <= ls_receipt_vendor-postingdate
                                                                           AND fiscalperiodenddate >= ls_receipt_vendor-postingdate.
              "获取过账日期所在的期间的上一个期间
              READ TABLE lt_fiscalyearperiod_last INTO ls_fiscalyearperiod_last WITH KEY nextfiscalperiod = ls_fiscalyearperiod_new-fiscalperiod
                                                                                         nextfiscalperiodfiscalyear = ls_fiscalyearperiod_new-fiscalyear
                                                                                BINARY SEARCH.
              IF sy-subrc = 0.
                READ TABLE lt_qc_vendor TRANSPORTING NO FIELDS WITH KEY calendaryear = ls_fiscalyearperiod_last-fiscalyear
                                                                        calendarmonth = ls_fiscalyearperiod_last-fiscalperiod
                                                                        plant = ls_receipt_vendor-issuingorreceivingplant
                                                                        material = ls_receipt_vendor-issgorrcvgmaterial
                                                               BINARY SEARCH.
*               存在关联公司期初数据
                IF sy-subrc = 0.
                  LOOP AT lt_qc_vendor INTO ls_qc_vendor FROM sy-tabix.
                    IF ls_qc_vendor-calendaryear <> ls_fiscalyearperiod_last-fiscalyear
                    OR ls_qc_vendor-calendarmonth <> ls_fiscalyearperiod_last-fiscalperiod
                    OR ls_qc_vendor-plant <> ls_receipt_vendor-issuingorreceivingplant
                    OR ls_qc_vendor-material <> ls_receipt_vendor-issgorrcvgmaterial.
                      EXIT.
                    ENDIF.

                    IF ls_receipt_vendor-quantityinbaseunit >= ls_qc_vendor-quantityinbaseunit.
                      ls_receipt_vendor-quantityinbaseunit = ls_receipt_vendor-quantityinbaseunit - ls_qc_vendor-quantityinbaseunit.

                      ls_receipt-plant = ls_receipt_vendor-issuingorreceivingplant.
                      ls_receipt-material = ls_receipt_vendor-issgorrcvgmaterial.
                      ls_receipt-postingdate = ls_receipt_vendor-postingdate.
                      ls_receipt-quantityinbaseunit = ls_qc_vendor-quantityinbaseunit.
                      ls_receipt-postingdate_receipt = ls_qc_vendor-postingdate_receipt.
                      APPEND ls_receipt TO lt_receipt4.
                      CLEAR ls_receipt.
                    ELSE.
                      ls_receipt-plant = ls_receipt_vendor-issuingorreceivingplant.
                      ls_receipt-material = ls_receipt_vendor-issgorrcvgmaterial.
                      ls_receipt-postingdate = ls_receipt_vendor-postingdate.
                      ls_receipt-quantityinbaseunit = ls_receipt_vendor-quantityinbaseunit.
                      ls_receipt-postingdate_receipt = ls_qc_vendor-postingdate_receipt.
                      APPEND ls_receipt TO lt_receipt4.
                      CLEAR ls_receipt.

                      CLEAR ls_receipt_vendor-quantityinbaseunit.
                    ENDIF.

                    "扣减完毕
                    IF ls_receipt_vendor-quantityinbaseunit = 0.
                      EXIT.
                    ENDIF.
                  ENDLOOP.

                  "关联公司期初数据也不够扣减，则剩下部分直接作为对应账龄
                  IF ls_receipt_vendor-quantityinbaseunit > 0.
                    ls_receipt-plant = ls_receipt_vendor-issuingorreceivingplant.
                    ls_receipt-material = ls_receipt_vendor-issgorrcvgmaterial.
                    ls_receipt-postingdate = ls_receipt_vendor-postingdate.
                    ls_receipt-quantityinbaseunit = ls_receipt_vendor-quantityinbaseunit.
                    ls_receipt-postingdate_receipt = ls_qc_vendor-postingdate_receipt.
                    APPEND ls_receipt TO lt_receipt4.
                    CLEAR ls_receipt.
                  ENDIF.
                ENDIF.
              ENDIF.

              EXIT.
            ENDLOOP.
          ENDLOOP.
        ENDIF.

        SORT lt_stock BY plant material postingdate.
        SORT lt_receipt_tmp BY plant material postingdate postingdate_receipt DESCENDING.

        "只保留累计入库数量>=期末库存数量的数据(入库记录扣减)
        LOOP AT lt_stock ASSIGNING <fs_stock>.
          READ TABLE lt_receipt_tmp TRANSPORTING NO FIELDS WITH KEY plant = <fs_stock>-plant
                                                                    material = <fs_stock>-material
                                                                    postingdate = <fs_stock>-postingdate
                                                           BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_receipt_tmp INTO ls_receipt_tmp FROM sy-tabix.
              IF ls_receipt_tmp-plant <> <fs_stock>-plant
              OR ls_receipt_tmp-material <> <fs_stock>-material
              OR ls_receipt_tmp-postingdate <> <fs_stock>-postingdate.
                EXIT.
              ENDIF.

              IF <fs_stock>-quantityinbaseunit >= ls_receipt_tmp-quantityinbaseunit.
                <fs_stock>-quantityinbaseunit = <fs_stock>-quantityinbaseunit - ls_receipt_tmp-quantityinbaseunit.
                lv_qty = ls_receipt_tmp-quantityinbaseunit.
              ELSE.
                lv_qty = <fs_stock>-quantityinbaseunit.
                CLEAR <fs_stock>-quantityinbaseunit.
              ENDIF.

              ls_receipt-plant = ls_receipt_tmp-plant.
              ls_receipt-material = ls_receipt_tmp-material.
              ls_receipt-postingdate = ls_receipt_tmp-postingdate.
              ls_receipt-postingdate_receipt = ls_receipt_tmp-postingdate_receipt.
              ls_receipt-quantityinbaseunit = lv_qty.
              APPEND ls_receipt TO lt_receipt4.
              CLEAR ls_receipt.

              IF <fs_stock>-quantityinbaseunit = 0.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDLOOP.

*      "只保留累计入库数量>=期末库存数量的数据(入库记录扣减)
*      LOOP AT lt_stock ASSIGNING <fs_stock>.
*        "获取过账日期所在的期间
*        LOOP AT lt_fiscalyearperiod_new INTO ls_fiscalyearperiod_new WHERE fiscalperiodstartdate <= <fs_stock>-postingdate
*                                                                       AND fiscalperiodenddate >= <fs_stock>-postingdate.
*          EXIT.
*        ENDLOOP.
*        IF sy-subrc = 0.
*          "获取过账日期所在的期间的上一个期间
*          READ TABLE lt_fiscalyearperiod_last INTO ls_fiscalyearperiod_last WITH KEY nextfiscalperiod = ls_fiscalyearperiod_new-fiscalperiod
*                                                                                     nextfiscalperiodfiscalyear = ls_fiscalyearperiod_new-fiscalyear
*                                                                            BINARY SEARCH.
*          IF sy-subrc = 0.
*            READ TABLE lt_qc_vendor TRANSPORTING NO FIELDS WITH KEY calendaryear = ls_fiscalyearperiod_last-fiscalyear
*                                                                    calendarmonth = ls_fiscalyearperiod_last-fiscalperiod
*                                                                    plant = <fs_stock>-plant
*                                                                    material = <fs_stock>-material
*                                                           BINARY SEARCH.
*            IF sy-subrc = 0.
*              LOOP AT lt_qc_vendor INTO ls_qc_vendor FROM sy-tabix.
*                IF ls_qc_vendor-calendaryear <> ls_fiscalyearperiod_last-fiscalyear
*                OR ls_qc_vendor-calendarmonth <> ls_fiscalyearperiod_last-fiscalperiod
*                OR ls_qc_vendor-plant <> <fs_stock>-plant
*                OR ls_qc_vendor-material <> <fs_stock>-material.
*                  EXIT.
*                ENDIF.
*
*                IF <fs_stock>-quantityinbaseunit >= ls_qc_vendor-quantityinbaseunit.
*                  <fs_stock>-quantityinbaseunit = <fs_stock>-quantityinbaseunit - ls_qc_vendor-quantityinbaseunit.
*
*                  ls_receipt-plant = <fs_stock>-plant.
*                  ls_receipt-material = <fs_stock>-material.
*                  ls_receipt-postingdate = <fs_stock>-postingdate.
*                  ls_receipt-quantityinbaseunit = ls_qc_vendor-quantityinbaseunit.
*                  ls_receipt-postingdate_receipt = ls_qc_vendor-postingdate_receipt.
*                  APPEND ls_receipt TO lt_receipt4.
*                  CLEAR ls_receipt.
*                ELSE.
*                  ls_receipt-plant = <fs_stock>-plant.
*                  ls_receipt-material = <fs_stock>-material.
*                  ls_receipt-postingdate = <fs_stock>-postingdate.
*                  ls_receipt-quantityinbaseunit = <fs_stock>-quantityinbaseunit.
*                  ls_receipt-postingdate_receipt = ls_qc_vendor-postingdate_receipt.
*                  APPEND ls_receipt TO lt_receipt4.
*                  CLEAR ls_receipt.
*
*                  CLEAR <fs_stock>-quantityinbaseunit.
*                ENDIF.
*
*                "扣减完毕
*                IF <fs_stock>-quantityinbaseunit = 0.
*                  EXIT.
*                ENDIF.
*              ENDLOOP.
*            ENDIF.
*          ENDIF.
*        ELSE.
*          READ TABLE lt_receipt_tmp TRANSPORTING NO FIELDS WITH KEY plant = <fs_stock>-plant
*                                                                    material = <fs_stock>-material
*                                                                    postingdate = <fs_stock>-postingdate
*                                                           BINARY SEARCH.
*          IF sy-subrc = 0.
*            LOOP AT lt_receipt_tmp INTO ls_receipt_tmp FROM sy-tabix.
*              IF ls_receipt_tmp-plant <> <fs_stock>-plant
*              OR ls_receipt_tmp-material <> <fs_stock>-material
*              OR ls_receipt_tmp-postingdate <> <fs_stock>-postingdate.
*                EXIT.
*              ENDIF.
*
*              IF <fs_stock>-quantityinbaseunit >= ls_receipt_tmp-quantityinbaseunit.
*                <fs_stock>-quantityinbaseunit = <fs_stock>-quantityinbaseunit - ls_receipt_tmp-quantityinbaseunit.
*                lv_qty = ls_receipt_tmp-quantityinbaseunit.
*              ELSE.
*                lv_qty = <fs_stock>-quantityinbaseunit.
*                CLEAR <fs_stock>-quantityinbaseunit.
*              ENDIF.
*
*              ls_receipt-plant = ls_receipt_tmp-plant.
*              ls_receipt-material = ls_receipt_tmp-material.
*              ls_receipt-postingdate = ls_receipt_tmp-postingdate.
*              ls_receipt-postingdate_receipt = ls_receipt_tmp-postingdate_receipt.
*              ls_receipt-quantityinbaseunit = lv_qty.
*              APPEND ls_receipt TO lt_receipt4.
*              CLEAR ls_receipt.
*
*              IF <fs_stock>-quantityinbaseunit = 0.
*                EXIT.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.

        DELETE lt_stock WHERE quantityinbaseunit = 0.
*      SORT lt_receipt4 BY plant material postingdate postingdate_receipt DESCENDING.

        IF lt_stock IS NOT INITIAL.
          CLEAR lt_ztfi_1004_tmp.

          "获取类别为A的期初数据
          SELECT calendaryear,
                 calendarmonth,
                 plant,
                 material,
                 age,
                 qty
            FROM ztfi_1004
             FOR ALL ENTRIES IN @lt_stock
           WHERE plant = @lt_stock-plant
             AND material = @lt_stock-material
             AND inventorytype = 'A'
             AND ledger = @lv_ledger
            INTO TABLE @lt_ztfi_1004_tmp.

          CLEAR lr_fiscalyearperiod.

          LOOP AT lt_ztfi_1004_tmp INTO ls_ztfi_1004_tmp.
            lv_fiscalperiod_tmp = ls_ztfi_1004_tmp-calendarmonth.
            lv_fiscalyearperiod = ls_ztfi_1004_tmp-calendaryear && lv_fiscalperiod_tmp.
            lr_fiscalyearperiod = VALUE #( BASE lr_fiscalyearperiod sign = lc_sign_i option = lc_option_eq ( low = lv_fiscalyearperiod ) ).
          ENDLOOP.

          IF lr_fiscalyearperiod IS NOT INITIAL.
            CLEAR lt_fiscalyearperiodforvariant.

            "Obtain data of fiscal year period for fiscal year variant
            SELECT fiscalyearperiod,
                   fiscalperiodstartdate,
                   fiscalperiodenddate
              FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
             WHERE fiscalyearvariant = @lc_fiyearvariant_v3
               AND fiscalyearperiod IN @lr_fiscalyearperiod
              INTO TABLE @lt_fiscalyearperiodforvariant.

            SORT lt_fiscalyearperiodforvariant BY fiscalyearperiod.

            CLEAR lt_receipt_qc.

            "期初数据转化为入库记录
            LOOP AT lt_ztfi_1004_tmp INTO ls_ztfi_1004_tmp.
              lv_fiscalyearperiod = ls_ztfi_1004_tmp-calendaryear && ls_ztfi_1004_tmp-calendarmonth.

              READ TABLE lt_fiscalyearperiodforvariant INTO ls_fiscalyearperiodforvariant WITH KEY fiscalyearperiod = lv_fiscalyearperiod
                                                                                          BINARY SEARCH.
              IF sy-subrc = 0.
                lv_age = ls_ztfi_1004_tmp-age - 1.

                "获取当前日期指定月数前的日期
                zzcl_common_utils=>calc_date_subtract(
                    EXPORTING
                      date      = ls_fiscalyearperiodforvariant-fiscalperiodenddate
                      month     = lv_age
                    RECEIVING
                      calc_date = ls_fiscalyearperiodforvariant-fiscalperiodenddate ).

                ls_receipt-plant = ls_ztfi_1004_tmp-plant.
                ls_receipt-material = ls_ztfi_1004_tmp-material.
                ls_receipt-postingdate_receipt = ls_fiscalyearperiodforvariant-fiscalperiodenddate.
                ls_receipt-quantityinbaseunit = ls_ztfi_1004_tmp-qty.
                COLLECT ls_receipt INTO lt_receipt_qc.
                CLEAR ls_receipt.
              ENDIF.
            ENDLOOP.
          ENDIF.

          SORT lt_receipt_qc BY plant material postingdate_receipt DESCENDING.

          "只保留累计入库数量>=期末库存数量的数据(期初库存扣减)
          LOOP AT lt_stock ASSIGNING <fs_stock>.
            READ TABLE lt_receipt_qc TRANSPORTING NO FIELDS WITH KEY plant = <fs_stock>-plant
                                                                     material = <fs_stock>-material
                                                            BINARY SEARCH.
            IF sy-subrc = 0.
              LOOP AT lt_receipt_qc ASSIGNING <fs_receipt> FROM sy-tabix.
                IF <fs_receipt>-plant <> <fs_stock>-plant
                OR <fs_receipt>-material <> <fs_stock>-material.
                  EXIT.
                ENDIF.

                IF <fs_stock>-quantityinbaseunit >= <fs_receipt>-quantityinbaseunit.
                  <fs_stock>-quantityinbaseunit = <fs_stock>-quantityinbaseunit - <fs_receipt>-quantityinbaseunit.
                  lv_qty = <fs_receipt>-quantityinbaseunit.
                  CLEAR <fs_receipt>-quantityinbaseunit.
                ELSE.
                  <fs_receipt>-quantityinbaseunit = <fs_receipt>-quantityinbaseunit - <fs_stock>-quantityinbaseunit.
                  lv_qty = <fs_stock>-quantityinbaseunit.
                  CLEAR <fs_stock>-quantityinbaseunit.
                ENDIF.

                ls_receipt-plant = <fs_receipt>-plant.
                ls_receipt-material = <fs_receipt>-material.
                ls_receipt-postingdate = <fs_stock>-postingdate.
                ls_receipt-postingdate_receipt = <fs_receipt>-postingdate_receipt.
                ls_receipt-quantityinbaseunit = lv_qty.
*                APPEND ls_receipt TO lt_receipt5.
                COLLECT ls_receipt INTO lt_receipt4.
                CLEAR ls_receipt.

                IF <fs_stock>-quantityinbaseunit = 0.
                  EXIT.
                ENDIF.
              ENDLOOP.

              DELETE lt_receipt_qc WHERE quantityinbaseunit = 0.
            ENDIF.
          ENDLOOP.
        ENDIF.

*        SORT lt_receipt5 BY plant material postingdate postingdate_receipt.
        SORT lt_receipt4 BY plant material postingdate postingdate_receipt.

        LOOP AT lt_receipt_vendor INTO ls_receipt_vendor.
          READ TABLE lt_receipt4 TRANSPORTING NO FIELDS WITH KEY plant = ls_receipt_vendor-issuingorreceivingplant
                                                                 material = ls_receipt_vendor-issgorrcvgmaterial
                                                                 postingdate = ls_receipt_vendor-postingdate
                                                        BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_receipt4 INTO DATA(ls_receipt4) FROM sy-tabix.
              IF ls_receipt4-plant <> ls_receipt_vendor-issuingorreceivingplant
              OR ls_receipt4-material <> ls_receipt_vendor-issgorrcvgmaterial
              OR ls_receipt4-postingdate <> ls_receipt_vendor-postingdate.
                EXIT.
              ENDIF.

              IF ls_receipt_vendor-quantityinbaseunit >= ls_receipt4-quantityinbaseunit.
                ls_receipt_vendor-quantityinbaseunit = ls_receipt_vendor-quantityinbaseunit - ls_receipt4-quantityinbaseunit.

                ls_receipt_vennew-plant = ls_receipt4-plant.
                ls_receipt_vennew-material = ls_receipt4-material.
                ls_receipt_vennew-postingdate = ls_receipt4-postingdate.
                ls_receipt_vennew-quantityinbaseunit = ls_receipt4-quantityinbaseunit.
                ls_receipt_vennew-postingdate_receipt = ls_receipt4-postingdate_receipt.
                APPEND ls_receipt_vennew TO lt_receipt_vennew.
                CLEAR ls_receipt_vennew.
              ELSE.
                ls_receipt_vennew-plant = ls_receipt4-plant.
                ls_receipt_vennew-material = ls_receipt4-material.
                ls_receipt_vennew-postingdate = ls_receipt4-postingdate.
                ls_receipt_vennew-quantityinbaseunit = ls_receipt_vendor-quantityinbaseunit.
                ls_receipt_vennew-postingdate_receipt = ls_receipt4-postingdate_receipt.
                APPEND ls_receipt_vennew TO lt_receipt_vennew.
                CLEAR ls_receipt_vennew.

                CLEAR ls_receipt_vendor-quantityinbaseunit.
              ENDIF.

              "扣减完毕
              IF ls_receipt_vendor-quantityinbaseunit = 0.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.

          "不够，扣减期初库存
*        IF ls_receipt_vendor-quantityinbaseunit > 0.
*          READ TABLE lt_receipt5 TRANSPORTING NO FIELDS WITH KEY plant = ls_receipt_vendor-issuingorreceivingplant
*                                                                 material = ls_receipt_vendor-issgorrcvgmaterial
*                                                                 postingdate = ls_receipt_vendor-postingdate
*                                                        BINARY SEARCH.
*          IF sy-subrc = 0.
*            LOOP AT lt_receipt5 INTO DATA(ls_receipt5) FROM sy-tabix.
*              IF ls_receipt5-plant <> ls_receipt_vendor-plant
*              OR ls_receipt5-material <> ls_receipt_vendor-material
*              OR ls_receipt5-postingdate <> ls_receipt_vendor-postingdate.
*                EXIT.
*              ENDIF.
*
*              IF ls_receipt_vendor-quantityinbaseunit >= ls_receipt5-quantityinbaseunit.
*                ls_receipt_vendor-quantityinbaseunit = ls_receipt_vendor-quantityinbaseunit - ls_receipt5-quantityinbaseunit.
*
*                ls_receipt_vennew-plant = ls_receipt5-quantityinbaseunit.
*                ls_receipt_vennew-material = ls_receipt5-material.
*                ls_receipt_vennew-postingdate = ls_receipt5-postingdate.
*                ls_receipt_vennew-quantityinbaseunit = ls_receipt5-quantityinbaseunit.
*                ls_receipt_vennew-postingdate_receipt = ls_receipt5-postingdate_receipt.
*                APPEND ls_receipt_vennew TO lt_receipt_vennew.
*                CLEAR ls_receipt_vennew.
*              ELSE.
*                ls_receipt_vennew-plant = ls_receipt5-quantityinbaseunit.
*                ls_receipt_vennew-material = ls_receipt5-material.
*                ls_receipt_vennew-postingdate = ls_receipt5-postingdate.
*                ls_receipt_vennew-quantityinbaseunit = ls_receipt_vendor-quantityinbaseunit.
*                ls_receipt_vennew-postingdate_receipt = ls_receipt5-postingdate_receipt.
*                APPEND ls_receipt_vennew TO lt_receipt_vennew.
*                CLEAR ls_receipt_vennew.
*
*                CLEAR ls_receipt_vendor-quantityinbaseunit.
*              ENDIF.
*
*              "扣减完毕
*              IF ls_receipt_vendor-quantityinbaseunit = 0.
*                EXIT.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.
*        ENDIF.
        ENDLOOP.
      ENDIF.

      "类309和关联公司数据
      lt_receipt_tmp = lt_receipt.
      DELETE lt_receipt_tmp WHERE goodsmovementtype IS INITIAL
                              AND supplier IS INITIAL.

      SORT lt_receipt_309new BY plant material postingdate.
      SORT lt_receipt_vennew BY plant material postingdate.
      SORT lt_receipt BY plant material postingdate.

      LOOP AT lt_receipt_tmp INTO ls_receipt_tmp.
        IF ls_receipt_tmp-goodsmovementtype IS NOT INITIAL.
          READ TABLE lt_receipt_309new TRANSPORTING NO FIELDS WITH KEY plant = ls_receipt_tmp-issuingorreceivingplant
                                                                       material = ls_receipt_tmp-issgorrcvgmaterial
                                                                       postingdate = ls_receipt_tmp-postingdate
                                                              BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_receipt_309new INTO ls_receipt_309new FROM sy-tabix.
              IF ls_receipt_309new-plant <> ls_receipt_tmp-issuingorreceivingplant
              OR ls_receipt_309new-material <> ls_receipt_tmp-issgorrcvgmaterial
              OR ls_receipt_309new-postingdate <> ls_receipt_tmp-postingdate.
                EXIT.
              ENDIF.

              ls_receipt_tmp2 = ls_receipt_tmp.
              ls_receipt_tmp2-postingdate = ls_receipt_309new-postingdate_receipt.
              ls_receipt_tmp2-quantityinbaseunit = ls_receipt_309new-quantityinbaseunit.
              APPEND ls_receipt_tmp2 TO lt_receipt_tmp2.
              CLEAR ls_receipt_tmp2.
            ENDLOOP.

            READ TABLE lt_receipt ASSIGNING <fs_receipt> WITH KEY plant = ls_receipt_tmp-plant
                                                                  material = ls_receipt_tmp-material
                                                                  postingdate = ls_receipt_tmp-postingdate
                                                         BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_receipt>-delflag = abap_true.
            ENDIF.
          ENDIF.
        ENDIF.

        IF ls_receipt_tmp-supplier IS NOT INITIAL.
          READ TABLE lt_receipt_vennew TRANSPORTING NO FIELDS WITH KEY plant = ls_receipt_tmp-issuingorreceivingplant
                                                                       material = ls_receipt_tmp-issgorrcvgmaterial
                                                                       postingdate = ls_receipt_tmp-postingdate
                                                              BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_receipt_vennew INTO ls_receipt_vennew FROM sy-tabix.
              IF ls_receipt_vennew-plant <> ls_receipt_tmp-issuingorreceivingplant
              OR ls_receipt_vennew-material <> ls_receipt_tmp-issgorrcvgmaterial
              OR ls_receipt_vennew-postingdate <> ls_receipt_tmp-postingdate.
                EXIT.
              ENDIF.

              ls_receipt_tmp2 = ls_receipt_tmp.
              ls_receipt_tmp2-postingdate = ls_receipt_vennew-postingdate_receipt.
              ls_receipt_tmp2-quantityinbaseunit = ls_receipt_vennew-quantityinbaseunit.
              APPEND ls_receipt_tmp2 TO lt_receipt_tmp2.
              CLEAR ls_receipt_tmp2.
            ENDLOOP.

            READ TABLE lt_receipt ASSIGNING <fs_receipt> WITH KEY plant = ls_receipt_tmp-plant
                                                                  material = ls_receipt_tmp-material
                                                                  postingdate = ls_receipt_tmp-postingdate
                                                         BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_receipt>-delflag = abap_true.
            ENDIF.
          ELSE.
            "当做普通入库处理
            READ TABLE lt_receipt ASSIGNING <fs_receipt> WITH KEY plant = ls_receipt_tmp-plant
                                                                  material = ls_receipt_tmp-material
                                                                  postingdate = ls_receipt_tmp-postingdate
                                                         BINARY SEARCH.
            IF sy-subrc = 0.
              CLEAR <fs_receipt>-supplier.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      DELETE lt_receipt WHERE delflag = abap_true.

      APPEND LINES OF lt_receipt_tmp2 TO lt_receipt.

      SORT lt_receipt BY plant material postingdate DESCENDING.
      SORT lt_receipt_oriqc BY plant material postingdate DESCENDING.

      LOOP AT lt_inventoryamtbyfsclperd INTO ls_inventoryamtbyfsclperd.
        ls_ztfi_1019_db-ledger         = lv_ledger.
        ls_ztfi_1019_db-companycode    = lv_companycode.
        ls_ztfi_1019_db-plant          = ls_inventoryamtbyfsclperd-valuationarea.
        ls_ztfi_1019_db-fiscalyear     = lv_fiscalyear.
        ls_ztfi_1019_db-fiscalperiod   = lv_fiscalperiod.
        ls_ztfi_1019_db-product        = ls_inventoryamtbyfsclperd-material.
        ls_ztfi_1019_db-baseunit       = ls_inventoryamtbyfsclperd-baseunit.
        ls_ztfi_1019_db-profitcenter   = ls_inventoryamtbyfsclperd-profitcenter.
        ls_ztfi_1019_db-mrpresponsible = ls_inventoryamtbyfsclperd-mrpresponsible.
        ls_ztfi_1019_db-producttype    = ls_inventoryamtbyfsclperd-producttype.
        ls_ztfi_1019_db-currency       = ls_inventoryamtbyfsclperd-currency.

        READ TABLE lt_receipt TRANSPORTING NO FIELDS WITH KEY plant = ls_inventoryamtbyfsclperd-valuationarea
                                                              material = ls_inventoryamtbyfsclperd-material
                                                     BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_receipt INTO ls_receipt FROM sy-tabix.
            IF ls_receipt-plant <> ls_inventoryamtbyfsclperd-valuationarea
            OR ls_receipt-material <> ls_inventoryamtbyfsclperd-material.
              EXIT.
            ENDIF.

            IF ls_inventoryamtbyfsclperd-valuationquantity >= ls_receipt-quantityinbaseunit.
              ls_inventoryamtbyfsclperd-valuationquantity = ls_inventoryamtbyfsclperd-valuationquantity - ls_receipt-quantityinbaseunit.
              lv_qty = ls_receipt-quantityinbaseunit.
            ELSE.
              lv_qty = ls_inventoryamtbyfsclperd-valuationquantity.
              CLEAR ls_inventoryamtbyfsclperd-valuationquantity.
            ENDIF.

            ls_ztfi_1019_db-qty = lv_qty.

*            lv_value = ( lv_fiscalperiodenddate - ls_receipt-postingdate ) / 30.
*            lv_age = trunc( lv_value ) + 1.

            DATA(lv_months) = zzcl_common_utils=>months_between_two_dates( EXPORTING iv_date_from = ls_receipt-postingdate
                                                                                     iv_date_to   = lv_fiscalperiodenddate ).

            "月份差值，需要包含起始日期的月份
            lv_age = lv_months + 1.

            IF lv_age > lc_maxage_36.
              lv_age = lc_maxage_36 + 1.
            ENDIF.

            ls_ztfi_1019_db-age = lv_age.
            COLLECT ls_ztfi_1019_db INTO lt_ztfi_1019_db.

            DATA(lv_flg_data) = abap_true.

            "扣减完毕
            IF ls_inventoryamtbyfsclperd-valuationquantity = 0.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.

        "不够，扣减期初库存
        IF ls_inventoryamtbyfsclperd-valuationquantity > 0.
          READ TABLE lt_receipt_oriqc TRANSPORTING NO FIELDS WITH KEY plant = ls_inventoryamtbyfsclperd-valuationarea
                                                                      material = ls_inventoryamtbyfsclperd-material
                                                             BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_receipt_oriqc INTO ls_receipt FROM sy-tabix.
              IF ls_receipt-plant <> ls_inventoryamtbyfsclperd-valuationarea
              OR ls_receipt-material <> ls_inventoryamtbyfsclperd-material.
                EXIT.
              ENDIF.

              IF ls_inventoryamtbyfsclperd-valuationquantity >= ls_receipt-quantityinbaseunit.
                ls_inventoryamtbyfsclperd-valuationquantity = ls_inventoryamtbyfsclperd-valuationquantity - ls_receipt-quantityinbaseunit.
                lv_qty = ls_receipt-quantityinbaseunit.
              ELSE.
                lv_qty = ls_inventoryamtbyfsclperd-valuationquantity.
                CLEAR ls_inventoryamtbyfsclperd-valuationquantity.
              ENDIF.

              ls_ztfi_1019_db-qty = lv_qty.

*              lv_value = ( lv_fiscalperiodenddate - ls_receipt-postingdate ) / 30.
*              lv_age = trunc( lv_value ) + 1.

              lv_months = zzcl_common_utils=>months_between_two_dates( EXPORTING iv_date_from = ls_receipt-postingdate
                                                                                 iv_date_to   = lv_fiscalperiodenddate ).

              "月份差值，需要包含起始日期的月份
              lv_age = lv_months + 1.

              IF lv_age > lc_maxage_36.
                lv_age = lc_maxage_36 + 1.
              ENDIF.

              ls_ztfi_1019_db-age = lv_age.
              COLLECT ls_ztfi_1019_db INTO lt_ztfi_1019_db.

              lv_flg_data = abap_true.

              "扣减完毕
              IF ls_inventoryamtbyfsclperd-valuationquantity = 0.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.

        "没有库龄数据
        IF lv_flg_data <> abap_true.
          APPEND ls_ztfi_1019_db TO lt_ztfi_1019_db.
        ENDIF.

        CLEAR:
          ls_ztfi_1019_db,
          lv_flg_data.
      ENDLOOP.

      SORT lt_inventorypricebykeydate BY material valuationarea.
      SORT lt_purchaseorderhistorydex BY plant material.
      SORT lt_billingdocumentitem_final BY product plant.

*      DELETE lt_ztfi_1019_db WHERE product <> 'ZTEST_FG001'.

      LOOP AT lt_ztfi_1019_db ASSIGNING FIELD-SYMBOL(<fs_ztfi_1019_db>).
        "Read data of inventory amount for fiscal period
        READ TABLE lt_inventoryamtbyfsclperd_sum INTO ls_inventoryamtbyfsclperd WITH KEY valuationarea = <fs_ztfi_1019_db>-plant
                                                                                         material = <fs_ztfi_1019_db>-product
                                                                                BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_ztfi_1019_db>-valuationquantity = ls_inventoryamtbyfsclperd-valuationquantity.
          <fs_ztfi_1019_db>-inventoryamount   = ls_inventoryamtbyfsclperd-amountincompanycodecurrency.
        ENDIF.

        "Read data of product valuation
        READ TABLE lt_inventorypricebykeydate INTO DATA(ls_inventorypricebykeydate) WITH KEY material = <fs_ztfi_1019_db>-product
                                                                                             valuationarea = <fs_ztfi_1019_db>-plant
                                                                                    BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_ztfi_1019_db>-actualcost           = ls_inventorypricebykeydate-inventoryprice. "actualprice.
          <fs_ztfi_1019_db>-materialpriceunitqty = ls_inventorypricebykeydate-materialpriceunitqty.
        ENDIF.

        "Read data of supplier invoice
        READ TABLE lt_purchaseorderhistorydex INTO DATA(ls_purchaseorderhistorydex) WITH KEY plant = <fs_ztfi_1019_db>-plant
                                                                                             material = <fs_ztfi_1019_db>-product
                                                                                    BINARY SEARCH.
        IF sy-subrc = 0.
          IF ls_purchaseorderhistorydex-quantityinbaseunit <> 0.
            <fs_ztfi_1019_db>-valuationunitprice = ls_purchaseorderhistorydex-purordamountincompanycodecrcy / ls_purchaseorderhistorydex-quantityinbaseunit.
            <fs_ztfi_1019_db>-valuationamount    = ls_purchaseorderhistorydex-purordamountincompanycodecrcy / ls_purchaseorderhistorydex-quantityinbaseunit
                                                 * <fs_ztfi_1019_db>-valuationquantity.
          ENDIF.
        ENDIF.

        "Read data of billing document item
        READ TABLE lt_billingdocumentitem INTO DATA(ls_billingdocumentitem) WITH KEY product = <fs_ztfi_1019_db>-product
                                                                                     plant = <fs_ztfi_1019_db>-plant
                                                                            BINARY SEARCH.
        IF sy-subrc = 0.
          IF ls_billingdocumentitem-billingquantity <> 0.
            <fs_ztfi_1019_db>-valuationunitprice = ls_billingdocumentitem-netamount / ls_billingdocumentitem-billingquantity.
            <fs_ztfi_1019_db>-valuationamount    = ls_billingdocumentitem-netamount / ls_billingdocumentitem-billingquantity
                                                 * <fs_ztfi_1019_db>-valuationquantity.
          ENDIF.
        ENDIF.

        "Read data of root product
        READ TABLE lt_finalproductinfo INTO ls_finalproductinfo WITH KEY product = <fs_ztfi_1019_db>-product
                                                                         plant = <fs_ztfi_1019_db>-plant
                                                                BINARY SEARCH.
        IF sy-subrc = 0.
          "Read data of billing document item
          READ TABLE lt_billingdocumentitem_final TRANSPORTING NO FIELDS WITH KEY product = ls_finalproductinfo-material
                                                                                  plant = ls_finalproductinfo-plant
                                                                              BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_billingdocumentitem_final INTO DATA(ls_billingdocumentitem_final) FROM sy-tabix.
              IF ls_billingdocumentitem_final-product <> ls_finalproductinfo-material
              OR ls_billingdocumentitem_final-plant <> ls_finalproductinfo-plant.
                EXIT.
              ENDIF.

              IF ls_billingdocumentitem_final-billingquantity <> 0.
                lv_valuationunitprice = ls_billingdocumentitem_final-netamount / ls_billingdocumentitem_final-billingquantity.
              ENDIF.

              "Get the smallest unit price
              IF <fs_ztfi_1019_db>-valuationunitprice = 0.
                <fs_ztfi_1019_db>-valuationunitprice = lv_valuationunitprice.
              ELSE.
                IF <fs_ztfi_1019_db>-valuationunitprice > lv_valuationunitprice.
                  <fs_ztfi_1019_db>-valuationunitprice = lv_valuationunitprice.
                ENDIF.
              ENDIF.
            ENDLOOP.

            <fs_ztfi_1019_db>-valuationamount = <fs_ztfi_1019_db>-valuationunitprice * <fs_ztfi_1019_db>-valuationquantity.
          ENDIF.
        ENDIF.

        IF <fs_ztfi_1019_db>-valuationamount = 0.
          <fs_ztfi_1019_db>-valuationafteramount = <fs_ztfi_1019_db>-inventoryamount.
        ELSE.
          IF <fs_ztfi_1019_db>-inventoryamount - <fs_ztfi_1019_db>-valuationamount >= 0.
            <fs_ztfi_1019_db>-valuationafteramount = <fs_ztfi_1019_db>-valuationamount.
            <fs_ztfi_1019_db>-valuationloss        = <fs_ztfi_1019_db>-inventoryamount - <fs_ztfi_1019_db>-valuationamount.
          ELSE.
            <fs_ztfi_1019_db>-valuationafteramount = <fs_ztfi_1019_db>-inventoryamount.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

*    DELETE lt_ztfi_1019_db WHERE qty = 0.

    GET TIME STAMP FIELD lv_timestampl.

    LOOP AT lt_ztfi_1019_db ASSIGNING FIELD-SYMBOL(<fs_ztfi_1019>).
      <fs_ztfi_1019>-last_changed_by = ''.
      <fs_ztfi_1019>-last_changed_at = lv_timestampl.
      <fs_ztfi_1019>-local_last_changed_at = lv_timestampl.
    ENDLOOP.
*    ENDIF.

    IF lt_ztfi_1019_db IS NOT INITIAL.
      DELETE FROM ztfi_1019 WHERE ledger = @lv_ledger AND companycode = @lv_companycode
                              AND fiscalyear = @lv_fiscalyear AND fiscalperiod = @lv_fiscalperiod.

      MODIFY ztfi_1019 FROM TABLE @lt_ztfi_1019_db.
    ENDIF.

*    DELETE FROM ztfi_1019 WHERE fiscalyear = '2024' AND fiscalperiod = '008'.
*                             and ( product = 'ZTEST_RAW001' OR product = 'ZTEST_RAW002' ).
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.
ENDCLASS.

*CLASS lsc_zc_inventory_aging DEFINITION INHERITING FROM cl_abap_behavior_saver.
*  PROTECTED SECTION.
*    METHODS save_modified REDEFINITION.
*ENDCLASS.
*
*CLASS lsc_zc_inventory_aging IMPLEMENTATION.
*  METHOD save_modified.
*  ENDMETHOD.
*ENDCLASS.
