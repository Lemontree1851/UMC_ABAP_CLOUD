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
      END OF ty_inventoryamtbyfsclperd,

      BEGIN OF ty_goosmovment,
        plant    TYPE i_materialdocumentitem_2-plant,
        material TYPE i_materialdocumentitem_2-material,
        receipt  TYPE i_materialdocumentitem_2-quantityinbaseunit,
        issue    TYPE i_materialdocumentitem_2-quantityinbaseunit,
      END OF ty_goosmovment,

      BEGIN OF ty_ztfi_1004,
        plant    TYPE ztfi_1004-plant,
        material TYPE ztfi_1004-material,
        age      TYPE ztfi_1019-age,
        qty      TYPE ztfi_1004-qty,
      END OF ty_ztfi_1004,

      BEGIN OF ty_ztfi_1019,
        plant   TYPE ztfi_1019-plant,
        product TYPE ztfi_1019-product,
        age     TYPE ztfi_1019-age,
        qty     TYPE ztfi_1019-qty,
      END OF ty_ztfi_1019.

    CONSTANTS:
      lc_event_recalculate TYPE string VALUE 'RECALCULATE',
      lc_debitcreditcode_s TYPE string VALUE 'S',
      lc_dd_01             TYPE n LENGTH 2 VALUE '01',
      lc_month_1           TYPE i VALUE '1',
      lc_month_3           TYPE i VALUE '3'.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR inventoryaging RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION inventoryaging~processlogic RESULT result.

    METHODS recalculate CHANGING cs_data TYPE lty_request.

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
      lt_inventoryamtbyfsclperd     TYPE STANDARD TABLE OF ty_inventoryamtbyfsclperd,
      lt_inventoryamtbyfsclperd_sum TYPE STANDARD TABLE OF ty_inventoryamtbyfsclperd,
      lt_goosmovment                TYPE STANDARD TABLE OF ty_goosmovment,
      lt_ztfi_1004                  TYPE STANDARD TABLE OF ty_ztfi_1004,
      lt_ztfi_1019                  TYPE STANDARD TABLE OF ty_ztfi_1019,
      lt_ztfi_1019_tmp              TYPE STANDARD TABLE OF ty_ztfi_1019,
      lt_ztfi_1019_cal              TYPE STANDARD TABLE OF ty_ztfi_1019,
      lt_ztfi_1019_cal_tmp          TYPE STANDARD TABLE OF ty_ztfi_1019,
      lt_ztfi_1019_db               TYPE STANDARD TABLE OF ztfi_1019,
      ls_ztfi_1019_cal              TYPE ty_ztfi_1019,
      ls_ztfi_1019_db               TYPE ztfi_1019,
      ls_goosmovment                TYPE ty_goosmovment,
      lv_companycode                TYPE zc_inventory_aging-companycode,
      lv_fiscalyear                 TYPE zc_inventory_aging-fiscalyear,
      lv_fiscalperiod               TYPE zc_inventory_aging-fiscalperiod,
      lv_ledger                     TYPE zc_inventory_aging-ledger,
      lv_goodsissueqty              TYPE i_materialdocumentitem_2-quantityinbaseunit,
      lv_qty                        TYPE ztfi_1004-qty,
      lv_begindate_month            TYPE d,
      lv_enddate_month              TYPE d,
      lv_date_lastmonth             TYPE d.

    IF cs_data-filterdata-fiscalyear = '2025' AND cs_data-filterdata-fiscalperiod = '2'.
      SELECT a~plant,
             a~material,
             a~age,
             a~qty
        FROM ztfi_1004 AS a
       INNER JOIN i_productvaluationareavh WITH PRIVILEGED ACCESS AS b
          ON b~valuationarea = a~plant
       INNER JOIN i_ledgercompanycodecrcyroles WITH PRIVILEGED ACCESS AS c
          ON c~companycode = c~companycode
       WHERE a~calendaryear = @cs_data-filterdata-fiscalyear
         AND a~calendarmonth = @cs_data-filterdata-fiscalperiod
         AND b~companycode = @cs_data-filterdata-companycode
         AND c~ledger = @cs_data-filterdata-ledger
        INTO TABLE @DATA(lt_ztfi_1004_tmp).

      LOOP AT lt_ztfi_1004_tmp INTO DATA(ls_ztfi_1004_tmp).
        ls_ztfi_1019_db-ledger       = cs_data-filterdata-ledger.
        ls_ztfi_1019_db-companycode  = cs_data-filterdata-companycode.
        ls_ztfi_1019_db-plant        = ls_ztfi_1004_tmp-plant.
        ls_ztfi_1019_db-fiscalyear   = cs_data-filterdata-fiscalyear.
        ls_ztfi_1019_db-fiscalperiod = cs_data-filterdata-fiscalperiod.
        ls_ztfi_1019_db-product      = ls_ztfi_1004_tmp-material.
        ls_ztfi_1019_db-age          = ls_ztfi_1004_tmp-age.
        ls_ztfi_1019_db-qty          = ls_ztfi_1004_tmp-qty.
        CONDENSE ls_ztfi_1019_db-age.

        APPEND ls_ztfi_1019_db TO lt_ztfi_1019_db.
        CLEAR ls_ztfi_1019_db.
      ENDLOOP.
    ELSE.
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
             d~producttype,
             e~producttypename,
             f~productdescription
        FROM i_productvaluationareavh WITH PRIVILEGED ACCESS AS a
       INNER JOIN i_companycode WITH PRIVILEGED ACCESS AS b
          ON b~companycode = a~companycode
       INNER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS c
          ON c~plant = a~valuationarea
       INNER JOIN i_product WITH PRIVILEGED ACCESS AS d
          ON d~product = c~product
        LEFT OUTER JOIN i_producttypetext_2 WITH PRIVILEGED ACCESS AS e
          ON e~producttype = d~producttype
         AND e~language = 'J'"@sy-langu
        LEFT OUTER JOIN i_productdescription WITH PRIVILEGED ACCESS AS f
          ON f~product = c~product
         AND f~language = 'J'"@sy-langu
       WHERE a~companycode = @lv_companycode
        INTO TABLE @DATA(lt_productplantbasic).
      IF sy-subrc = 0.
        "Obtain data of inventory amount for fiscal period
        SELECT costestimate,
               material,
               valuationarea,
               valuationquantity,
               amountincompanycodecurrency
          FROM i_inventoryamtbyfsclperd( p_fiscalperiod = @lv_fiscalperiod, p_fiscalyear = @lv_fiscalyear ) WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_productplantbasic
         WHERE companycode = @lt_productplantbasic-companycode
           AND valuationarea = @lt_productplantbasic-valuationarea
           AND material = @lt_productplantbasic-product
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
        lv_begindate_month = lv_fiscalyear && lv_fiscalperiod+1(2) && lc_dd_01.

        "Get date of last month(subtract 1 month)
        zzcl_common_utils=>calc_date_subtract(
          EXPORTING
            date      = lv_begindate_month
            month     = lc_month_1
          RECEIVING
            calc_date = lv_date_lastmonth ).

        "Get month begin date(add 3 month)
        zzcl_common_utils=>calc_date_add(
          EXPORTING
            date      = lv_begindate_month
            month     = lc_month_3
          RECEIVING
            calc_date = lv_begindate_month ).

        "Get month end date
        zzcl_common_utils=>get_enddate_of_month(
          EXPORTING
            iv_date           = lv_begindate_month
          RECEIVING
            rv_month_end_date = lv_enddate_month ).

        SELECT plant,
               material,
               age,
               qty
          FROM ztfi_1004
           FOR ALL ENTRIES IN @lt_productplantbasic
         WHERE plant = @lt_productplantbasic-valuationarea
           AND material = @lt_productplantbasic-product
           AND calendaryear = @lv_fiscalyear
           AND calendarmonth = @lv_fiscalperiod
          INTO TABLE @lt_ztfi_1004_tmp.

        MOVE-CORRESPONDING lt_ztfi_1004_tmp TO lt_ztfi_1004.

        "Obtain data of material document item
        SELECT a~materialdocumentyear,
               a~materialdocument,
               a~materialdocumentitem,
               a~plant,
               a~material,
               a~debitcreditcode,
               a~quantityinbaseunit
          FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS a
           FOR ALL ENTRIES IN @lt_productplantbasic
         WHERE a~companycode = @lt_productplantbasic-companycode
           AND a~plant = @lt_productplantbasic-valuationarea
           AND a~material = @lt_productplantbasic-product
           AND a~issgorrcvgspclstockind <> 'T'
           AND postingdate BETWEEN @lv_begindate_month AND @lv_enddate_month
           AND NOT EXISTS ( SELECT materialdocument FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
                             WHERE reversedmaterialdocumentyear = a~materialdocumentyear
                               AND reversedmaterialdocument = a~materialdocument
                               AND reversedmaterialdocumentitem = a~materialdocumentitem )
          INTO TABLE @DATA(lt_materialdocumentitem).

        LOOP AT lt_materialdocumentitem INTO DATA(ls_materialdocumentitem).
          ls_goosmovment-plant = ls_materialdocumentitem-plant.
          ls_goosmovment-material = ls_materialdocumentitem-material.

*         Goods Receipt
          IF ls_materialdocumentitem-debitcreditcode = lc_debitcreditcode_s.
            ls_goosmovment-receipt = ls_materialdocumentitem-quantityinbaseunit.
*         Goods Issue
          ELSE.
            ls_goosmovment-issue = ls_materialdocumentitem-quantityinbaseunit.
          ENDIF.

          COLLECT ls_goosmovment INTO lt_goosmovment.
          CLEAR ls_goosmovment.
        ENDLOOP.

        DATA(lv_fiscalyear_lastmonth) = lv_date_lastmonth+0(4).
        DATA(lv_fiscalperiod_lastmonth) = lv_date_lastmonth+4(2).

        SELECT plant,
               product,
               age,
               qty
          FROM ztfi_1019
           FOR ALL ENTRIES IN @lt_productplantbasic
         WHERE plant = @lt_productplantbasic-valuationarea
           AND product = @lt_productplantbasic-product
           AND fiscalyear = @lv_fiscalyear_lastmonth
           AND fiscalperiod = @lv_fiscalperiod_lastmonth
          INTO TABLE @lt_ztfi_1019.

        LOOP AT lt_ztfi_1019 INTO DATA(ls_ztfi_1019).
          ls_ztfi_1019-age = ls_ztfi_1019-age + 1.

          IF ls_ztfi_1019-age > 36.
            ls_ztfi_1019-age = 36.
          ENDIF.

          COLLECT ls_ztfi_1019 INTO lt_ztfi_1019_tmp.
          CLEAR ls_ztfi_1019.
        ENDLOOP.

        lt_ztfi_1019 = lt_ztfi_1019_tmp.
        DATA(lt_ztfi_1019_309) = lt_ztfi_1019.

        "Obtain data of material document item
        SELECT a~materialdocumentyear,
               a~materialdocument,
               a~materialdocumentitem,
               a~plant,
               a~material,
               isautomaticallycreated,
               a~quantityinbaseunit
          FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS a
           FOR ALL ENTRIES IN @lt_productplantbasic
         WHERE a~companycode = @lt_productplantbasic-companycode
           AND a~plant = @lt_productplantbasic-valuationarea
           AND a~goodsmovementtype = '309'
           AND postingdate BETWEEN @lv_begindate_month AND @lv_enddate_month
           AND NOT EXISTS ( SELECT materialdocument FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
                             WHERE reversedmaterialdocumentyear = a~materialdocumentyear
                               AND reversedmaterialdocument = a~materialdocument
                               AND reversedmaterialdocumentitem = a~materialdocumentitem )
          INTO TABLE @DATA(lt_materialdocumentitem_309).
      ENDIF.

      SORT lt_goosmovment BY plant material.
      SORT lt_ztfi_1019 BY plant product age DESCENDING.

      LOOP AT lt_inventoryamtbyfsclperd INTO ls_inventoryamtbyfsclperd.
        CLEAR ls_goosmovment.
        READ TABLE lt_goosmovment INTO ls_goosmovment WITH KEY plant = ls_inventoryamtbyfsclperd-valuationarea
                                                               material = ls_inventoryamtbyfsclperd-material
                                                      BINARY SEARCH.

        "目前为止的总库存数量-当月所有的入库库存总数量
        IF ls_inventoryamtbyfsclperd-valuationquantity - ls_goosmovment-receipt > 0.
          "当月入库的合计库存数量的库龄是1个月
          ls_ztfi_1019_cal-plant   = ls_inventoryamtbyfsclperd-valuationarea.
          ls_ztfi_1019_cal-product = ls_inventoryamtbyfsclperd-material.
          ls_ztfi_1019_cal-age     = 1.
          ls_ztfi_1019_cal-qty     = ls_goosmovment-receipt.
          APPEND ls_ztfi_1019_cal TO lt_ztfi_1019_cal.
          CLEAR ls_ztfi_1019_cal.

          lv_goodsissueqty = ls_goosmovment-issue.

          READ TABLE lt_ztfi_1019 TRANSPORTING NO FIELDS WITH KEY plant = ls_inventoryamtbyfsclperd-valuationarea
                                                                  product = ls_inventoryamtbyfsclperd-material
                                                         BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_ztfi_1019 ASSIGNING FIELD-SYMBOL(<fs_ztfi_1019>) FROM sy-tabix.
              IF <fs_ztfi_1019>-plant <> ls_inventoryamtbyfsclperd-valuationarea
              OR  <fs_ztfi_1019>-product <> ls_inventoryamtbyfsclperd-material.
                EXIT.
              ENDIF.

              IF <fs_ztfi_1019>-qty >= lv_goodsissueqty.
                <fs_ztfi_1019>-qty = <fs_ztfi_1019>-qty - lv_goodsissueqty.
                CLEAR lv_goodsissueqty.
              ELSE.
                lv_goodsissueqty = lv_goodsissueqty - <fs_ztfi_1019>-qty.
                CLEAR <fs_ztfi_1019>-qty.
              ENDIF.

              "扣减完毕
              IF lv_goodsissueqty = 0.
                APPEND <fs_ztfi_1019> TO lt_ztfi_1019_cal.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ELSEIF ls_inventoryamtbyfsclperd-valuationquantity - ls_goosmovment-receipt < 0.
          "当月的库存数量对应的库龄就是1个月
          ls_ztfi_1019_cal-plant   = ls_inventoryamtbyfsclperd-valuationarea.
          ls_ztfi_1019_cal-product = ls_inventoryamtbyfsclperd-material.
          ls_ztfi_1019_cal-age     = 1.
          ls_ztfi_1019_cal-qty     = ls_inventoryamtbyfsclperd-valuationquantity.
          APPEND ls_ztfi_1019_cal TO lt_ztfi_1019_cal.
          CLEAR ls_ztfi_1019_cal.
        ENDIF.
      ENDLOOP.

      SORT lt_ztfi_1004 BY plant material age DESCENDING.
      SORT lt_ztfi_1019_cal BY plant product age.

      "期初ADD-ON导入存在的情况下
      LOOP AT lt_ztfi_1004 INTO DATA(ls_ztfi_1004).
        lv_qty = ls_ztfi_1004-qty.

        READ TABLE lt_ztfi_1019_cal TRANSPORTING NO FIELDS WITH KEY plant = ls_ztfi_1004-plant
                                                                    product = ls_ztfi_1004-material
                                                           BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_ztfi_1019_cal ASSIGNING FIELD-SYMBOL(<fs_ztfi_1019_cal>) FROM sy-tabix.
            IF <fs_ztfi_1019_cal>-plant <> ls_ztfi_1004-plant
            OR <fs_ztfi_1019_cal>-product <> ls_ztfi_1004-material.
              EXIT.
            ENDIF.

            IF lv_qty >= <fs_ztfi_1019_cal>-qty.
              lv_qty = lv_qty - <fs_ztfi_1019_cal>-qty.

              ls_ztfi_1019_cal-plant   = <fs_ztfi_1019_cal>-plant.
              ls_ztfi_1019_cal-product = <fs_ztfi_1019_cal>-product.
              ls_ztfi_1019_cal-qty     = <fs_ztfi_1019_cal>-qty.
              ls_ztfi_1019_cal-age     = ls_ztfi_1004-age.
              COLLECT ls_ztfi_1019_cal INTO lt_ztfi_1019_cal_tmp.
              CLEAR ls_ztfi_1019_cal.

              CLEAR <fs_ztfi_1019_cal>-qty.
            ELSE.
              ls_ztfi_1019_cal-plant   = <fs_ztfi_1019_cal>-plant.
              ls_ztfi_1019_cal-product = <fs_ztfi_1019_cal>-product.
              ls_ztfi_1019_cal-qty     = lv_qty.
              ls_ztfi_1019_cal-age     = ls_ztfi_1004-age.
              COLLECT ls_ztfi_1019_cal INTO lt_ztfi_1019_cal_tmp.
              CLEAR ls_ztfi_1019_cal.

              ls_ztfi_1019_cal-plant   = <fs_ztfi_1019_cal>-plant.
              ls_ztfi_1019_cal-product = <fs_ztfi_1019_cal>-product.
              ls_ztfi_1019_cal-qty     = <fs_ztfi_1019_cal>-qty - lv_qty.
              ls_ztfi_1019_cal-age     = <fs_ztfi_1019_cal>-age.
              COLLECT ls_ztfi_1019_cal INTO lt_ztfi_1019_cal_tmp.
              CLEAR ls_ztfi_1019_cal.

              CLEAR <fs_ztfi_1019_cal>-qty.
            ENDIF.

            "扣减完毕
            IF lv_qty = 0.
              EXIT.
            ENDIF.
          ENDLOOP.

          LOOP AT lt_ztfi_1019_cal_tmp INTO ls_ztfi_1019_cal.
            COLLECT ls_ztfi_1019_cal INTO lt_ztfi_1019_cal.
          ENDLOOP.

          CLEAR lt_ztfi_1019_cal_tmp.
        ENDIF.
      ENDLOOP.

      DATA(lt_materialdocumentitem_309tmp) = lt_materialdocumentitem_309.
      DELETE lt_materialdocumentitem_309tmp WHERE isautomaticallycreated = abap_true.

      SORT lt_materialdocumentitem_309 BY materialdocumentyear materialdocument isautomaticallycreated.
      SORT lt_materialdocumentitem_309tmp BY plant material.
      SORT lt_ztfi_1019_309 BY plant product age DESCENDING.

      "309
      LOOP AT lt_materialdocumentitem_309tmp INTO DATA(ls_materialdocumentitem_309tmp).
        READ TABLE lt_materialdocumentitem_309 INTO DATA(ls_materialdocumentitem_309) WITH KEY materialdocumentyear = ls_materialdocumentitem_309tmp-materialdocumentyear
                                                                                               materialdocument = ls_materialdocumentitem_309tmp-materialdocument
                                                                                               isautomaticallycreated = abap_false
                                                                                      BINARY SEARCH.
        IF sy-subrc = 0.
          READ TABLE lt_ztfi_1019_309 TRANSPORTING NO FIELDS WITH KEY plant = ls_materialdocumentitem_309-plant
                                                                      product = ls_materialdocumentitem_309-material
                                                             BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_ztfi_1019_309 INTO DATA(ls_ztfi_1019_309) FROM sy-tabix.
              IF ls_ztfi_1019_309-plant <> ls_materialdocumentitem_309-plant
              OR ls_ztfi_1019_309-product <> ls_materialdocumentitem_309-material.
                EXIT.
              ENDIF.

              lv_qty = ls_ztfi_1019_309-qty.

              READ TABLE lt_ztfi_1019_cal TRANSPORTING NO FIELDS WITH KEY plant = ls_materialdocumentitem_309tmp-plant
                                                                          product = ls_materialdocumentitem_309tmp-material
                                                                 BINARY SEARCH.
              IF sy-subrc = 0.
                LOOP AT lt_ztfi_1019_cal ASSIGNING <fs_ztfi_1019_cal> FROM sy-tabix.
                  IF <fs_ztfi_1019_cal>-plant <> ls_materialdocumentitem_309tmp-plant
                  OR <fs_ztfi_1019_cal>-product <> ls_materialdocumentitem_309tmp-material.
                    EXIT.
                  ENDIF.

                  IF lv_qty >= <fs_ztfi_1019_cal>-qty.
                    lv_qty = lv_qty - <fs_ztfi_1019_cal>-qty.

                    ls_ztfi_1019_cal-plant   = <fs_ztfi_1019_cal>-plant.
                    ls_ztfi_1019_cal-product = <fs_ztfi_1019_cal>-product.
                    ls_ztfi_1019_cal-qty     = <fs_ztfi_1019_cal>-qty.
                    ls_ztfi_1019_cal-age     = ls_ztfi_1019_309-age.
                    COLLECT ls_ztfi_1019_cal INTO lt_ztfi_1019_cal_tmp.
                    CLEAR ls_ztfi_1019_cal.

                    CLEAR <fs_ztfi_1019_cal>-qty.
                  ELSE.
                    ls_ztfi_1019_cal-plant   = <fs_ztfi_1019_cal>-plant.
                    ls_ztfi_1019_cal-product = <fs_ztfi_1019_cal>-product.
                    ls_ztfi_1019_cal-qty     = lv_qty.
                    ls_ztfi_1019_cal-age     = ls_ztfi_1019_309-age.
                    COLLECT ls_ztfi_1019_cal INTO lt_ztfi_1019_cal_tmp.
                    CLEAR ls_ztfi_1019_cal.

                    ls_ztfi_1019_cal-plant   = <fs_ztfi_1019_cal>-plant.
                    ls_ztfi_1019_cal-product = <fs_ztfi_1019_cal>-product.
                    ls_ztfi_1019_cal-qty     = <fs_ztfi_1019_cal>-qty - lv_qty.
                    ls_ztfi_1019_cal-age     = <fs_ztfi_1019_cal>-age.
                    COLLECT ls_ztfi_1019_cal INTO lt_ztfi_1019_cal_tmp.
                    CLEAR ls_ztfi_1019_cal.

                    CLEAR <fs_ztfi_1019_cal>-qty.
                  ENDIF.

                  "扣减完毕
                  IF lv_qty = 0.
                    EXIT.
                  ENDIF.
                ENDLOOP.

                LOOP AT lt_ztfi_1019_cal_tmp INTO ls_ztfi_1019_cal.
                  COLLECT ls_ztfi_1019_cal INTO lt_ztfi_1019_cal.
                ENDLOOP.

                CLEAR lt_ztfi_1019_cal_tmp.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDLOOP.

      DELETE lt_ztfi_1019_cal WHERE qty = 0.

      DATA lv_timestampl TYPE timestampl.

      GET TIME STAMP FIELD lv_timestampl.

      LOOP AT lt_ztfi_1019_cal INTO ls_ztfi_1019_cal.
        ls_ztfi_1019_db-ledger       = lv_ledger.
        ls_ztfi_1019_db-companycode  = lv_companycode.
        ls_ztfi_1019_db-plant        = ls_ztfi_1019_cal-plant.
        ls_ztfi_1019_db-fiscalyear   = lv_fiscalyear.
        ls_ztfi_1019_db-fiscalperiod = lv_fiscalperiod.
        ls_ztfi_1019_db-product      = ls_ztfi_1019_cal-product.
        ls_ztfi_1019_db-age          = ls_ztfi_1019_cal-age.
        ls_ztfi_1019_db-qty          = ls_ztfi_1019_cal-qty.
        CONDENSE ls_ztfi_1019-age.

        ls_ztfi_1019_db-last_changed_by = ''.
        ls_ztfi_1019_db-last_changed_at = ''.
        ls_ztfi_1019_db-local_last_changed_at = ''.
        APPEND ls_ztfi_1019_db TO lt_ztfi_1019_db.
        CLEAR ls_ztfi_1019_db.
      ENDLOOP.
    ENDIF.

    IF lt_ztfi_1019_db IS NOT INITIAL.
      MODIFY ztfi_1019 FROM TABLE @lt_ztfi_1019_db.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

CLASS lsc_zc_inventory_aging DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zc_inventory_aging IMPLEMENTATION.
  METHOD save_modified.
  ENDMETHOD.
ENDCLASS.
