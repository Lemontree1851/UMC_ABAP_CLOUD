CLASS lhc_paipaycalculation DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF lty_request,
            status  TYPE c LENGTH 1,
            message TYPE c LENGTH 100,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR paipaycalculation RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE paipaycalculation.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE paipaycalculation.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE paipaycalculation.

    METHODS read FOR READ
      IMPORTING keys FOR READ paipaycalculation RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK paipaycalculation.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION paipaycalculation~processlogic RESULT result.

    METHODS calcu_a CHANGING ct_data  TYPE lty_request_t
                             cv_bukrs TYPE bukrs
                             cv_gjahr TYPE gjahr
                             cv_monat TYPE monat.

    METHODS calcu_b CHANGING ct_data  TYPE lty_request_t
                             cv_bukrs TYPE bukrs
                             cv_gjahr TYPE gjahr
                             cv_monat TYPE monat.

ENDCLASS.

CLASS lhc_paipaycalculation IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD processlogic.
    DATA lt_request TYPE TABLE OF lty_request.
    CHECK keys IS NOT INITIAL.
* Get parameter
    DATA(lv_bukrs) = keys[ 1 ]-%param-companycode.
    DATA(lv_gjahr) = keys[ 1 ]-%param-fiscalyear.
    DATA(lv_monat) = keys[ 1 ]-%param-period.
    DATA(lv_ztype) = keys[ 1 ]-%param-ztype.

    CASE lv_ztype.
      WHEN 'A'. "品番別
        calcu_a( CHANGING cv_bukrs = lv_bukrs
                          cv_gjahr = lv_gjahr
                          cv_monat = lv_monat
                          ct_data  = lt_request ).


      WHEN 'B'. "購買グルー合計
        calcu_b( CHANGING cv_bukrs = lv_bukrs
                          cv_gjahr = lv_gjahr
                          cv_monat = lv_monat
                          ct_data  = lt_request ).
    ENDCASE.

    DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

    APPEND VALUE #( %cid   = keys[ 1 ]-%cid
                    %param = VALUE #( zzkey = lv_json ) ) TO result.
  ENDMETHOD.

  METHOD calcu_a.
    TYPES:
      BEGIN OF ts_mrp,
        product        TYPE matnr,
        plant          TYPE werks_d,
        mrpresponsible TYPE dispo,
        sort           TYPE c LENGTH 20,
      END OF ts_mrp,

      BEGIN OF ts_chgamt,
        matnr     TYPE matnr,
        plant     TYPE werks_d,
        ekgrp     TYPE ekgrp,
        ebeln     TYPE ebeln,
        ebelp     TYPE ebelp,
        amount(8) TYPE p DECIMALS 2,
      END OF ts_chgamt,

      BEGIN OF ts_ekgrp,
        product TYPE matnr,
        plant   TYPE werks_d,
        ekgrp   TYPE ekgrp,
      END OF ts_ekgrp,

      BEGIN OF ts_invtotalamt,
        matnr  TYPE matnr,
        plant  TYPE werks_d,
        amt(8) TYPE p DECIMALS 2,
      END OF ts_invtotalamt,

      BEGIN OF ts_kunnramt,
        customer     TYPE kunnr,
        profitcenter TYPE prctr,
        amt(8)       TYPE p DECIMALS 2,
      END OF ts_kunnramt,

      BEGIN OF ts_bom,
        plant     TYPE werks_d,
        raw       TYPE matnr,
        parent01  TYPE matnr,
        bklas01   TYPE bklas,
        cost01(8) TYPE p DECIMALS 2,
        qty01(12) TYPE p DECIMALS 3,
        parent02  TYPE matnr,
        bklas02   TYPE bklas,
        cost02(8) TYPE p DECIMALS 2,
        qty02(12) TYPE p DECIMALS 3,
        parent03  TYPE matnr,
        bklas03   TYPE bklas,
        cost03(8) TYPE p DECIMALS 2,
        qty03(12) TYPE p DECIMALS 3,
        parent04  TYPE matnr,
        bklas04   TYPE bklas,
        cost04(8) TYPE p DECIMALS 2,
        qty04(12) TYPE p DECIMALS 3,
        parent05  TYPE matnr,
        bklas05   TYPE bklas,
        cost05(8) TYPE p DECIMALS 2,
        qty05(12) TYPE p DECIMALS 3,
        parent06  TYPE matnr,
        bklas06   TYPE bklas,
        cost06(8) TYPE p DECIMALS 2,
        qty06(12) TYPE p DECIMALS 3,
        parent07  TYPE matnr,
        bklas07   TYPE bklas,
        cost07(8) TYPE p DECIMALS 2,
        qty07(12) TYPE p DECIMALS 3,
        parent08  TYPE matnr,
        bklas08   TYPE bklas,
        cost08(8) TYPE p DECIMALS 2,
        qty08(12) TYPE p DECIMALS 3,
        parent09  TYPE matnr,
        bklas09   TYPE bklas,
        cost09(8) TYPE p DECIMALS 2,
        qty09(12) TYPE p DECIMALS 3,
        parent10  TYPE matnr,
        bklas10   TYPE bklas,
        cost10(8) TYPE p DECIMALS 2,
        qty10(12) TYPE p DECIMALS 3,
      END OF ts_bom,

      BEGIN OF ts_matnrcost,
        plant      TYPE werks_d,
        matnr      TYPE matnr,
        tot2000(9) TYPE p DECIMALS 2,
        tot3000(9) TYPE p DECIMALS 2,
      END OF ts_matnrcost.

    DATA:
      lv_previousperiod TYPE monat,
      lv_poper          TYPE poper,
      lv_amt(8)         TYPE p DECIMALS 2,
      lv_amt_bukrs(8)   TYPE p DECIMALS 2,
      lv_amt_2000(8)    TYPE p DECIMALS 2,
      lv_amt_3000(8)    TYPE p DECIMALS 2,
      lv_year           TYPE c LENGTH 4,
      lv_lastyear       TYPE c LENGTH 4,
      lv_month          TYPE monat,
      lv_nextmonth      TYPE budat,
      lv_from           TYPE budat,
      lv_to             TYPE budat,
      lv_i              TYPE i,
      lv_j              TYPE i,
      lv_num_parent     TYPE n LENGTH 2,
      lv_num_son        TYPE n LENGTH 2,
      lv_num            TYPE n LENGTH 2,
      lv_index          TYPE i,
      lv_peinh(7)       TYPE p DECIMALS 3,
      lv_length         TYPE i.

    FIELD-SYMBOLS: <fs> TYPE any.

    DATA:
      lt_1010         TYPE STANDARD TABLE OF ztfi_1010,
      ls_1010         TYPE ztfi_1010,
      lt_mrp          TYPE STANDARD TABLE OF ts_mrp,
      ls_mrp          TYPE ts_mrp,
      lt_purgroup     TYPE STANDARD TABLE OF ts_ekgrp,
      ls_purgroup     TYPE ts_ekgrp,
      lt_chgamt_tmp1  TYPE STANDARD TABLE OF ts_chgamt,
      lt_chgamt_ekgrp TYPE STANDARD TABLE OF ts_chgamt,
      ls_chgamt_ekgrp TYPE ts_chgamt,
      lt_chgamt_tmp2  TYPE STANDARD TABLE OF ts_chgamt,
      lt_chgamt_matnr TYPE STANDARD TABLE OF ts_chgamt,
      ls_chgamt_matnr TYPE ts_chgamt,
      lt_invtotalamt  TYPE STANDARD TABLE OF ts_invtotalamt,
      ls_invtotalamt  TYPE ts_invtotalamt,
      lt_kunnramt     TYPE STANDARD TABLE OF ts_kunnramt,
      ls_kunnramt     TYPE ts_kunnramt,
      lt_bom          TYPE STANDARD TABLE OF ts_bom,
      ls_bom          TYPE ts_bom,
      lt_bom_temp     TYPE STANDARD TABLE OF ts_bom,
      lt_matnrcost    TYPE STANDARD TABLE OF ts_matnrcost,
      ls_matnrcost    TYPE ts_matnrcost,
      ls_request      TYPE lty_request,

      lr_sort         TYPE RANGE OF i_businesspartner-searchterm2,
      lrs_sort        LIKE LINE OF lr_sort,
      lr_ekgrp        TYPE RANGE OF ekgrp,
      lrs_ekgrp       LIKE LINE OF lr_ekgrp,
      lr_plant        TYPE RANGE OF werks_d,
      lrs_plant       LIKE LINE OF lr_plant,
      lr_bom          TYPE RANGE OF matnr,
      lrs_bom         LIKE LINE OF lr_bom.

    CONSTANTS:
      lc_hkont TYPE c LENGTH 4 VALUE '004*',
      lc_2000  TYPE c LENGTH 4 VALUE '2000',
      lc_3000  TYPE c LENGTH 4 VALUE '3000'.

* Delete DB
    SELECT *
      FROM ztfi_1010
     WHERE companycode = @cv_bukrs
       AND fiscalyear = @cv_gjahr
       AND period = @cv_monat
      INTO TABLE @DATA(lt_del).
    IF lt_del IS NOT INITIAL.
      DELETE ztfi_1010 FROM TABLE @lt_del.
      IF sy-subrc <> 0.
        ls_request-status = 'E'.
        ls_request-message = TEXT-001.
        APPEND ls_request TO ct_data.
        RETURN.
      ENDIF.
    ENDIF.

* 2.00 Get currency
    SELECT SINGLE currency
      FROM i_companycode
     WHERE companycode = @cv_bukrs
      INTO @DATA(lv_waers).

* 2.01 Get plant
    SELECT valuationarea
      FROM i_valuationarea WITH PRIVILEGED ACCESS
     WHERE companycode = @cv_bukrs
      INTO TABLE @DATA(lt_plant).

    LOOP AT lt_plant INTO DATA(ls_plant).
      lrs_plant-sign = 'I'.
      lrs_plant-option = 'EQ'.
      lrs_plant-low = ls_plant-valuationarea.
      APPEND lrs_plant TO lr_plant.
      CLEAR: lrs_plant.
    ENDLOOP.

* 2.02 Get matnr
    SELECT product,
           plant
      FROM i_productplantbasic WITH PRIVILEGED ACCESS
     WHERE plant IN @lr_plant
      INTO TABLE @DATA(lt_product).

    "Filter 6th = 'D'
    LOOP AT lt_product INTO DATA(ls_product).
*      DATA(lv_matnr) = zzcl_common_utils=>conversion_matn1(
*                                            EXPORTING iv_alpha = 'OUT'
*                                                      iv_input = ls_product-product ).
*      IF lv_matnr+0(5) <> 'D'.
*        DELETE lt_product.
*        CONTINUE.
*      ENDIF.
      lv_length = strlen( ls_product-product ).
      lv_length = lv_length - 1.
      IF ls_product-product+lv_length(1) <> '2'.
        DELETE lt_product.
        CONTINUE.
      ENDIF.
    ENDLOOP.

* 2.03 Get last 2 characters of mrpresponsible
    IF lt_product IS NOT INITIAL.
      SELECT product,
             plant,
             mrpresponsible
        FROM i_productplantbasic WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_product
       WHERE plant = @lt_product-plant
        INTO TABLE @lt_mrp.

      LOOP AT lt_mrp ASSIGNING FIELD-SYMBOL(<lfs_mrp>).
        DATA(lv_len) = strlen( <lfs_mrp>-mrpresponsible ) - 2.
        IF lv_len < 0.
          CONTINUE.
        ENDIF.
        lrs_sort-sign = 'I'.
        lrs_sort-option = 'EQ'.
        lrs_sort-low = <lfs_mrp>-mrpresponsible+lv_len(2).
        APPEND lrs_sort TO lr_sort.
        CLEAR: lrs_sort.

        <lfs_mrp>-sort = <lfs_mrp>-mrpresponsible+lv_len(2).

        lrs_ekgrp-sign = 'I'.
        lrs_ekgrp-option = 'CP'.
        lrs_ekgrp-low = '*' && <lfs_mrp>-mrpresponsible+lv_len(2).
        APPEND lrs_ekgrp TO lr_ekgrp.
        CLEAR: lrs_ekgrp.
      ENDLOOP.
    ENDIF.
    SORT lr_sort BY low.
    DELETE ADJACENT DUPLICATES FROM lr_sort COMPARING low.
    SORT lr_ekgrp BY low.
    DELETE ADJACENT DUPLICATES FROM lr_ekgrp COMPARING low.

* 2.04 得意先BPコード
    IF lr_sort IS NOT INITIAL.
      SELECT businesspartner,
             businesspartnername,
             searchterm2
        FROM i_businesspartner WITH PRIVILEGED ACCESS
       WHERE searchterm2 IN @lr_sort
        INTO TABLE @DATA(lt_bp).
    ENDIF.

* 2.07 Get maktx
    IF lt_product IS NOT INITIAL.
      SELECT product,
             productdescription
        FROM i_productdescription WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_product
       WHERE product = @lt_product-product
         AND language = @sy-langu
        INTO TABLE @DATA(lt_makt).

* 2.08 利益センタ
      SELECT product,
             plant,
             profitcenter
        FROM i_productplantbasic WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_product
       WHERE product = @lt_product-product
         AND plant = @lt_product-plant
        INTO TABLE @DATA(lt_prctr).
      IF sy-subrc = 0.
* 2.09 利益センタのテキスト
        SELECT profitcenter,
               profitcentername
          FROM i_profitcentertext WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_prctr
         WHERE language = @sy-langu
           AND profitcenter = @lt_prctr-profitcenter
          INTO TABLE @DATA(lt_prctrname).
      ENDIF.
    ENDIF.

* 2.10 購買グループ
    IF lr_ekgrp IS NOT INITIAL.
      SELECT purchasinggroup,
             purchasinggroupname
        FROM i_purchasinggroup WITH PRIVILEGED ACCESS
       WHERE purchasinggroup IN @lr_ekgrp
        INTO TABLE @DATA(lt_ekgrp).
    ENDIF.

* 2.11 期首の購買グループ金額
* 4.04 期首の売上高を取得
    lv_previousperiod = cv_monat - 1.
    IF lv_previousperiod <> 0.
      SELECT companycode,
             fiscalyear,
             period,
             profitcenter,
             purchasinggroup,
             begpurgrpamt,
             begchgmaterialamt,
             begcustomerrev,
             begrev,
             currency
        FROM ztfi_1009
        FOR ALL ENTRIES IN @lt_prctr          "#EC CI_FAE_LINES_ENSURED
       WHERE companycode = @cv_bukrs
         AND fiscalyear = @cv_gjahr
         AND period = @lv_previousperiod
         AND profitcenter = @lt_prctr-profitcenter
         AND purchasinggroup IN @lr_ekgrp
        INTO TABLE @DATA(lt_ztfi_1009).
      IF sy-subrc <> 0.
* 2.12 有償支給品の仕入金額取得
* 4.05 期首の売上高を取得
        SELECT companycode,
               fiscalyear,
               period,
               profitcenter,
               purchasinggroup,
               purgrpamount,
               chargeableamount,
               customerrevenue,
               revenue
          FROM ztfi_1011
          FOR ALL ENTRIES IN @lt_prctr        "#EC CI_FAE_LINES_ENSURED
       WHERE companycode = @cv_bukrs
         AND fiscalyear = @cv_gjahr
         AND period = @lv_previousperiod
         AND profitcenter = @lt_prctr-profitcenter
         AND purchasinggroup IN @lr_ekgrp
        INTO TABLE @DATA(lt_ztfi_1011).
      ENDIF.
    ENDIF.

* 2.13 購買グループ単位の購買発注伝票
* 2.14 有償支給品の購買発注伝票(from 2.13)
    SORT lt_product BY product.
    SORT lt_bp BY businesspartner.

    SELECT purchaseorder,
           purchaseorderitem,
           purchasinggroup,
           supplier,
           material,
           plant
      FROM c_purchaseorderitemdex WITH PRIVILEGED ACCESS
     WHERE purchasinggroup IN @lr_ekgrp
       AND companycode = @cv_bukrs
      INTO TABLE @DATA(lt_po).
    LOOP AT lt_po INTO DATA(ls_po).
      "購買グループ単位の購買発注伝票
      ls_chgamt_ekgrp-ekgrp = ls_po-purchasinggroup.
      ls_chgamt_ekgrp-ebeln = ls_po-purchaseorder.
      ls_chgamt_ekgrp-ebelp = ls_po-purchaseorderitem.
      APPEND ls_chgamt_ekgrp TO lt_chgamt_tmp1.
      CLEAR: ls_chgamt_ekgrp.

      "有償支給品の購買発注伝票
      READ TABLE lt_product INTO ls_product
           WITH KEY product = ls_po-material BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_bp INTO DATA(ls_bp)
             WITH KEY businesspartner = ls_po-supplier BINARY SEARCH.
        IF sy-subrc = 0.
          ls_chgamt_matnr-matnr = ls_po-material.
          ls_chgamt_matnr-plant = ls_po-plant.
          ls_chgamt_matnr-ebeln = ls_po-purchaseorder.
          ls_chgamt_matnr-ebelp = ls_po-purchaseorderitem.
          APPEND ls_chgamt_matnr TO lt_chgamt_tmp2.
          CLEAR: ls_chgamt_matnr.
        ENDIF.
      ENDIF.
    ENDLOOP.

* edit date for ekbe
    lv_from = cv_gjahr && cv_monat && '01'.
    IF cv_monat = 12.
      lv_year = cv_gjahr + 1.
      lv_nextmonth = lv_year && '01' && '01'.
    ELSE.
      lv_month = cv_monat + 1.
      lv_nextmonth = cv_gjahr && lv_month && '01'.
    ENDIF.
    lv_to = lv_nextmonth - 1.

* 2.15 有償支給品の仕入れ金額
    IF lt_chgamt_tmp2 IS NOT INITIAL.
      SELECT purchaseorder,
             purchaseorderitem,
             accountassignmentnumber,
             purchasinghistorydocumenttype,
             purchasinghistorydocumentyear,
             purchasinghistorydocument,
             purchasinghistorydocumentitem,
             debitcreditcode,
             material,
             plant,
             purordamountincompanycodecrcy,
             purchasinggroup
        FROM c_purchaseorderhistorydex WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_chgamt_tmp2
       WHERE purchaseorder = @lt_chgamt_tmp2-ebeln
         AND purchaseorderitem = @lt_chgamt_tmp2-ebelp
         AND ( purchasinghistorycategory = 'Q'
            OR purchasinghistorycategory = 'N' )
         AND ( postingdate >= @lv_from
           AND postingdate <= @lv_to )
        INTO TABLE @DATA(lt_ekbe_matnr).
    ENDIF.
* 2.16 購買グループ単位の仕入れ金額
    IF lt_chgamt_tmp1 IS NOT INITIAL.
      SELECT purchaseorder,
             purchaseorderitem,
             accountassignmentnumber,
             purchasinghistorydocumenttype,
             purchasinghistorydocumentyear,
             purchasinghistorydocument,
             purchasinghistorydocumentitem,
             debitcreditcode,
             material,
             plant,
             purordamountincompanycodecrcy,
             purchasinggroup
        FROM c_purchaseorderhistorydex WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_chgamt_tmp1
       WHERE purchaseorder = @lt_chgamt_tmp1-ebeln
         AND purchaseorderitem = @lt_chgamt_tmp1-ebelp
         AND ( purchasinghistorycategory = 'Q'
            OR purchasinghistorycategory = 'N' )
         AND ( postingdate >= @lv_from
           AND postingdate <= @lv_to )
        INTO TABLE @DATA(lt_ekbe_ekgrp).
    ENDIF.
* 3.01-3.08 BOM番号
    DATA(lt_product_tmp) = lt_product[].
    DO.
* find the upper bom code
      SELECT billofmaterial,
             billofmaterialvariant,
             billofmaterialitemnodenumber,
             bominstceinternalchangenumber,
             billofmaterialcomponent
        FROM i_billofmaterialitemdex_3 WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_product_tmp
       WHERE billofmaterialcomponent = @lt_product_tmp-product
         AND isdeleted = @space
        INTO TABLE @DATA(lt_up).
      " Exit loop if not find upper bom
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
* get material number by bom code
      IF lt_up IS NOT INITIAL.
        SELECT billofmaterial,
               billofmaterialvariant,
               material,
               plant,
               billofmaterialvariantusage
          FROM i_materialbomlinkdex WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_up
         WHERE billofmaterial = @lt_up-billofmaterial
           AND billofmaterialvariant = @lt_up-billofmaterialvariant
           AND plant IN @lr_plant
          INTO TABLE @DATA(lt_expode).
      ENDIF.
* get the cost bom to check
      IF lt_expode IS NOT INITIAL.
        SELECT costingreferenceobject,
               costestimate,
               costingtype,
               costingdate,
               costingversion,
               valuationvariant,
               costisenteredmanually,
               product,
               plant,
               costestimatevaliditystartdate,
               billofmaterial,
               alternativebillofmaterial
          FROM i_productcostestimate WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_expode
         WHERE product = @lt_expode-material
           AND plant IN @lr_plant
           AND costingvariant = 'PYC1'
           AND costestimatevaliditystartdate <= @lv_to
           AND costestimatestatus = 'FR'
          INTO TABLE @DATA(lt_costbom).
* get lasted date value
        SORT lt_costbom BY product plant
                           costestimatevaliditystartdate DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_costbom COMPARING product plant.
      ENDIF.
      IF lt_costbom IS NOT INITIAL.
        SELECT  billofmaterialcategory,
                billofmaterial,
                billofmaterialvariant,
                billofmaterialitemnodenumber,
                bominstceinternalchangenumber,
                billofmaterialcomponent
          FROM i_billofmaterialitemdex_3 WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_costbom
         WHERE billofmaterial = @lt_costbom-billofmaterial
           AND billofmaterialvariant = @lt_costbom-alternativebillofmaterial
           AND isdeleted = @space
           INTO TABLE @DATA(lt_costbomexpode).

      ENDIF.

* Check costbom with material bom
      SORT lt_costbomexpode BY billofmaterialcomponent billofmaterialvariant.
      LOOP AT lt_up INTO DATA(ls_up).
        READ TABLE lt_costbomexpode
             WITH KEY billofmaterialcomponent = ls_up-billofmaterialcomponent
                      billofmaterialvariant = ls_up-billofmaterialvariant BINARY SEARCH
             TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          DELETE lt_up.
          CONTINUE.
        ENDIF.
      ENDLOOP.

      SORT lt_up BY billofmaterial billofmaterialvariant.
      LOOP AT lt_expode INTO DATA(ls_expode).
        READ TABLE lt_up
             WITH KEY billofmaterial = ls_expode-billofmaterial
                      billofmaterialvariant = ls_expode-billofmaterialvariant BINARY SEARCH
             TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          DELETE lt_expode.
          CONTINUE.
        ELSE.
          lrs_bom-sign = 'I'.
          lrs_bom-option = 'EQ'.
          lrs_bom-low = ls_expode-material.
          APPEND lrs_bom TO lr_bom.
          CLEAR: lrs_bom.
        ENDIF.
      ENDLOOP.


* edit bom hierarchy
      DATA(lt_bom_tmp) = lt_bom[].
      CLEAR: lt_bom.
      lv_index = lv_index + 1.
      lv_num_parent = lv_index.
      IF lv_index = 1.
* Prepare the last layer
        LOOP AT lt_expode INTO ls_expode.
          ls_bom-parent01 = ls_expode-material.
          ls_bom-plant = ls_expode-plant.

          READ TABLE lt_up INTO ls_up
               WITH KEY billofmaterial = ls_expode-billofmaterial
                        billofmaterialvariant = ls_expode-billofmaterialvariant BINARY SEARCH.
          IF sy-subrc = 0.
            ls_bom-raw = ls_up-billofmaterialcomponent.
          ENDIF.
          APPEND ls_bom TO lt_bom.
          CLEAR: ls_bom.
        ENDLOOP.

      ELSE.
* Expand bom from second to last layer to the first layer
        DATA(lv_field) = 'PARENT' && lv_num_parent.
        lv_num_son = lv_num_parent - 1.
        DATA(lv_field_son) = 'PARENT' && lv_num_son.
        SORT lt_bom_tmp BY plant (lv_field_son).

        LOOP AT lt_expode INTO ls_expode.
          READ TABLE lt_up INTO ls_up
               WITH KEY billofmaterial = ls_expode-billofmaterial
                        billofmaterialvariant = ls_expode-billofmaterialvariant BINARY SEARCH.
          IF sy-subrc = 0.
            READ TABLE lt_bom_tmp INTO ls_bom
                 WITH KEY plant = ls_expode-plant
                          (lv_field_son) = ls_up-billofmaterialcomponent BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_tabix) = sy-tabix.
              ASSIGN COMPONENT lv_field OF STRUCTURE ls_bom TO <fs>.
              <fs> = ls_expode-material.
              APPEND ls_bom TO lt_bom.
              DELETE lt_bom_tmp INDEX lv_tabix.
              CONTINUE.
            ENDIF.
            CLEAR: ls_bom.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF lt_bom_tmp IS NOT INITIAL.
        APPEND LINES OF lt_bom_tmp TO lt_bom_temp.
      ENDIF.
      CLEAR: lt_product_tmp.
      LOOP AT lt_expode INTO ls_expode.
        ls_product-product = ls_expode-material.
        ls_product-plant = ls_expode-plant.
        APPEND ls_product TO lt_product_tmp.
        CLEAR: ls_product.
      ENDLOOP.
    ENDDO.
    APPEND LINES OF lt_bom_temp TO lt_bom.

    SORT lr_bom BY low.
    DELETE ADJACENT DUPLICATES FROM lr_bom COMPARING low.
* 3.09前期末在庫金額を取得
    lv_lastyear = cv_gjahr - 1.
    SELECT companycode,
           fiscalyear,
           period,
           profitcenter,
           businesspartner,
           purchasinggroup,
           prestockamt,
           currency
      FROM ztfi_1008
      FOR ALL ENTRIES IN @lt_prctr
     WHERE fiscalyear = @lv_lastyear
       AND period = '12'
       AND profitcenter = @lt_prctr-profitcenter
       AND purchasinggroup IN @lr_ekgrp
      INTO TABLE @DATA(lt_1008).
    IF sy-subrc <> 0.
* 3.10 前期末在庫金額を取得する
      SELECT companycode,
             fiscalyear,
             period,
             profitcenter,
             purchasinggroup,
             currentstocktotal
        FROM ztfi_1011
        FOR ALL ENTRIES IN @lt_prctr
       WHERE fiscalyear = @lv_lastyear
         AND period = '12'
         AND profitcenter = @lt_prctr-profitcenter
         AND purchasinggroup IN @lr_ekgrp
        INTO TABLE @DATA(lt_1011).
    ENDIF.

* 3.11有償支給品当期末在庫金額を取得
    lv_poper = cv_monat.
    SELECT ledger,
           companycode,
           costestimate,
           material,
           valuationarea,
           amountincompanycodecurrency
      FROM i_inventoryamtbyfsclperd( p_fiscalperiod = @lv_poper,
                                     p_fiscalyear = @cv_gjahr )
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_product
     WHERE material = @lt_product-product
       AND valuationarea IN @lr_plant
      INTO TABLE @DATA(lt_invamt).

* 3.12上位半製品/製品の評価クラスを取得する
    SELECT product,
           valuationarea,
           valuationtype,
           valuationclass
      FROM i_productvaluationbasic WITH PRIVILEGED ACCESS
     WHERE product IN @lr_bom
       AND valuationarea IN @lr_plant
      INTO TABLE @DATA(lt_bklas).

* 3.13上位半製品/製品の在庫数量を取得
    SELECT ledger,
           companycode,
           costestimate,
           material,
           valuationarea,
           valuationquantity,
           unitofmeasure
      FROM i_inventoryamtbyfsclperd( p_fiscalperiod = @lv_poper,
                                     p_fiscalyear = @cv_gjahr )
      WITH PRIVILEGED ACCESS
     WHERE material IN @lr_bom
       AND valuationarea IN @lr_plant
      INTO TABLE @DATA(lt_invqty).

* 3.14原価積み上げ番号を取得
    SELECT product,
           valuationarea,
           valuationtype,
           valuationclass,
           prodcostestnumber
      FROM i_productvaluationbasic WITH PRIVILEGED ACCESS
     WHERE product IN @lr_bom
       AND valuationarea IN @lr_plant
      INTO TABLE @DATA(lt_prodcostno).

    SELECT product,
           valuationarea,
           valuationtype,
           valuationclass,
           prodcostestnumber
      FROM i_productvaluationbasic WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_product
     WHERE product = @lt_product-product
       AND valuationarea IN @lr_plant
      APPENDING TABLE @lt_prodcostno.

    IF lt_prodcostno IS NOT INITIAL.
* 3.15上位品番の原価計算ロットサイズ
      SELECT costingreferenceobject,
             costestimate,
             costingtype,
             costingdate,
             costingversion,
             valuationvariant,
             costisenteredmanually,
             costestimatevaliditystartdate,
             costinglotsize
        FROM i_productcostestimate WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_prodcostno
       WHERE costestimate = @lt_prodcostno-prodcostestnumber
         AND costestimatevaliditystartdate <= @lv_to
         AND costestimatestatus = 'FR'
        INTO TABLE @DATA(lt_lotsize).
* 3.16 上位品番の標準原価-材料費を取得
      SELECT costingreferenceobject,
             costestimate,
             costingtype,
             costingdate,
             costingversion,
             valuationvariant,
             costisenteredmanually,
             costingitem,
             plant,
             product,
             totalpriceincompanycodecrcy,
             baseunit,
             quantityinbaseunit,
             transfercostestimate,
             transfercostingdate
        FROM i_productcostestimateitem WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_prodcostno
       WHERE costestimate = @lt_prodcostno-prodcostestnumber
         AND costingdate <= @lv_to
         AND ( costingitemcategory = 'M'
            OR costingitemcategory = 'I' )
        INTO TABLE @DATA(lt_costitem).

      SORT lt_lotsize BY costestimate
                         costestimatevaliditystartdate DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_lotsize COMPARING costestimate costestimatevaliditystartdate.
      SORT lt_costitem BY costestimate
                          costingdate DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_costitem COMPARING costestimate costingdate.
    ENDIF.
* 4.01会計仕訳から有償支給得意先の会計伝票(Customer from 2.04)
* 4.02会計仕訳から有償支給得意先の売上高金額(GLAccount=4*/ProfitCenter from 2.09)
    SELECT sourceledger,
           companycode,
           fiscalyear,
           accountingdocument,
           ledgergllineitem,
           ledger,
           glaccount,
           profitcenter,
           companycodecurrency,
           amountincompanycodecurrency,
           customer
      FROM i_journalentryitem WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_bp
     WHERE sourceledger = '0L'
       AND companycode = @cv_bukrs
       AND fiscalyear = @cv_gjahr
       AND ledger = '0L'
       AND isreversal = @space
       AND isreversed = @space
       AND glaccount LIKE @lc_hkont
       AND fiscalperiod = @lv_poper
       AND customer = @lt_bp-businesspartner
      INTO TABLE @DATA(lt_bseg).

* 4.03会計仕訳から会社レベルの総売上高取得する(GLAccount=4*)
    SELECT sourceledger,
           companycode,
           fiscalyear,
           accountingdocument,
           ledgergllineitem,
           ledger,
           glaccount,
           companycodecurrency,
           amountincompanycodecurrency
      FROM i_journalentryitem WITH PRIVILEGED ACCESS
     WHERE sourceledger = '0L'
       AND companycode = @cv_bukrs
       AND fiscalyear = @cv_gjahr
       AND ledger = '0L'
       AND isreversal = @space
       AND isreversed = @space
       AND glaccount LIKE @lc_hkont
       AND fiscalperiod = @lv_poper
      INTO TABLE @DATA(lt_bseg_bukrs).

* edit purchasing group
    LOOP AT lt_mrp INTO ls_mrp.
      READ TABLE lt_ekgrp INTO DATA(ls_ekgrp)
           WITH KEY purchasinggroup+1(2) = ls_mrp-mrpresponsible+1(2).
      IF sy-subrc = 0.
        ls_purgroup-plant = ls_mrp-plant.
        ls_purgroup-product = ls_mrp-product.
        ls_purgroup-ekgrp = ls_ekgrp-purchasinggroup.
        APPEND ls_purgroup TO lt_purgroup.
        CLEAR: ls_purgroup.
      ENDIF.
    ENDLOOP.
* 購買グループ仕入れ金額sum
    SORT lt_ekbe_ekgrp BY purchasinggroup.
    LOOP AT lt_ekbe_ekgrp INTO DATA(ls_ekbe)
                    GROUP BY ( purchasinggroup = ls_ekbe-purchasinggroup )
                REFERENCE INTO DATA(member).
      LOOP AT GROUP member ASSIGNING FIELD-SYMBOL(<lfs_member>).
        IF <lfs_member>-debitcreditcode = 'S'.
          lv_amt = lv_amt + <lfs_member>-purordamountincompanycodecrcy.
        ELSE.
          lv_amt = lv_amt - <lfs_member>-purordamountincompanycodecrcy.
        ENDIF.
      ENDLOOP.
      ls_chgamt_ekgrp-ekgrp = <lfs_member>-purchasinggroup.
      ls_chgamt_ekgrp-amount = lv_amt.
      APPEND ls_chgamt_ekgrp TO lt_chgamt_ekgrp.
      CLEAR: ls_chgamt_ekgrp, lv_amt.
    ENDLOOP.
* 有償支給品の仕入金額sum
    SORT lt_ekbe_matnr BY material plant.
    LOOP AT lt_ekbe_matnr INTO DATA(ls_ekbe_matnr)
                     GROUP BY ( material = ls_ekbe_matnr-material
                                plant = ls_ekbe_matnr-plant )
                     REFERENCE INTO DATA(member_matnr).
      LOOP AT GROUP member_matnr ASSIGNING FIELD-SYMBOL(<lfs_matnr>).
        IF <lfs_matnr>-debitcreditcode = 'S'.
          lv_amt = lv_amt + <lfs_matnr>-purordamountincompanycodecrcy.
        ELSE.
          lv_amt = lv_amt - <lfs_matnr>-purordamountincompanycodecrcy.
        ENDIF.
      ENDLOOP.
      ls_chgamt_matnr-matnr = <lfs_matnr>-material.
      ls_chgamt_matnr-plant = <lfs_matnr>-plant.
      ls_chgamt_matnr-amount = lv_amt.
      APPEND ls_chgamt_matnr TO lt_chgamt_matnr.
      CLEAR: ls_chgamt_matnr, lv_amt.
    ENDLOOP.
* 有償支給品当期末在庫金額sum
    SORT lt_invamt BY material valuationarea.
    LOOP AT lt_invamt INTO DATA(ls_invamt)
            GROUP BY ( material = ls_invamt-material
                       valuationarea = ls_invamt-valuationarea )
            REFERENCE INTO DATA(member_invamt).
      LOOP AT GROUP member_invamt ASSIGNING FIELD-SYMBOL(<lfs_invamt>).
        lv_amt = lv_amt + <lfs_invamt>-amountincompanycodecurrency.
      ENDLOOP.
      ls_invtotalamt-matnr = <lfs_invamt>-material.
      ls_invtotalamt-plant = <lfs_invamt>-valuationarea.
      ls_invtotalamt-amt = lv_amt.
      APPEND ls_invtotalamt TO lt_invtotalamt.
      CLEAR: ls_invtotalamt, lv_amt.
    ENDLOOP.
* 上位品目別の直接材料費

    SORT lt_bklas BY product valuationarea.
    SORT lt_prodcostno BY product valuationarea.
    SORT lt_lotsize BY costestimate.
    SORT lt_costitem BY costestimate.
    SORT lt_invqty BY material valuationarea.
    LOOP AT lt_bom ASSIGNING FIELD-SYMBOL(<lfs_bom>).

      " 1st layer
      READ TABLE lt_bklas INTO DATA(ls_bklas)
             WITH KEY product = <lfs_bom>-parent01
                      valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-bklas01 = ls_bklas-valuationclass.  "評価クラス
      ENDIF.
      READ TABLE lt_invqty INTO DATA(ls_invqty)
           WITH KEY material = <lfs_bom>-parent01
                    valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-qty01 = ls_invqty-valuationquantity.   "評価数量
      ENDIF.
      READ TABLE lt_prodcostno INTO DATA(ls_prodcostno)
           WITH KEY product = <lfs_bom>-parent01
                    valuationarea = <lfs_bom>-bklas01 BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_lotsize INTO DATA(ls_lotsize)
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        READ TABLE lt_costitem INTO DATA(ls_costitem)
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        IF ls_lotsize-costinglotsize <> 0.
          lv_peinh = ls_costitem-quantityinbaseunit / ls_lotsize-costinglotsize.
          <lfs_bom>-cost01 = ls_costitem-totalpriceincompanycodecrcy / ls_lotsize-costinglotsize
                           * lv_peinh.       "材料費
        ENDIF.
      ENDIF.
      " 2nd layer
      CLEAR: ls_lotsize, ls_costitem.
      READ TABLE lt_bklas INTO ls_bklas
             WITH KEY product = <lfs_bom>-parent02
                      valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-bklas02 = ls_bklas-valuationclass.  "評価クラス
      ENDIF.
      READ TABLE lt_invqty INTO ls_invqty
           WITH KEY material = <lfs_bom>-parent02
                    valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-qty02 = ls_invqty-valuationquantity.   "評価数量
      ENDIF.
      READ TABLE lt_prodcostno INTO ls_prodcostno
           WITH KEY product = <lfs_bom>-parent02
                    valuationarea = <lfs_bom>-bklas02 BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_lotsize INTO ls_lotsize
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        READ TABLE lt_costitem INTO ls_costitem
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        IF ls_lotsize-costinglotsize <> 0.
          lv_peinh = ls_costitem-quantityinbaseunit / ls_lotsize-costinglotsize.
          <lfs_bom>-cost02 = ls_costitem-totalpriceincompanycodecrcy / ls_lotsize-costinglotsize
                           * lv_peinh.       "材料費
        ENDIF.
      ENDIF.
      " 3rd layer
      CLEAR: ls_lotsize, ls_costitem.
      READ TABLE lt_bklas INTO ls_bklas
             WITH KEY product = <lfs_bom>-parent03
                      valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-bklas03 = ls_bklas-valuationclass.  "評価クラス
      ENDIF.
      READ TABLE lt_invqty INTO ls_invqty
           WITH KEY material = <lfs_bom>-parent03
                    valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-qty03 = ls_invqty-valuationquantity.   "評価数量
      ENDIF.
      READ TABLE lt_prodcostno INTO ls_prodcostno
           WITH KEY product = <lfs_bom>-parent03
                    valuationarea = <lfs_bom>-bklas03 BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_lotsize INTO ls_lotsize
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        READ TABLE lt_costitem INTO ls_costitem
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        IF ls_lotsize-costinglotsize <> 0.
          lv_peinh = ls_costitem-quantityinbaseunit / ls_lotsize-costinglotsize.
          <lfs_bom>-cost03 = ls_costitem-totalpriceincompanycodecrcy / ls_lotsize-costinglotsize
                           * lv_peinh.       "材料費
        ENDIF.
      ENDIF.
      " 4th layer
      CLEAR: ls_lotsize, ls_costitem.
      READ TABLE lt_bklas INTO ls_bklas
             WITH KEY product = <lfs_bom>-parent04
                      valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-bklas04 = ls_bklas-valuationclass.  "評価クラス
      ENDIF.
      READ TABLE lt_invqty INTO ls_invqty
           WITH KEY material = <lfs_bom>-parent04
                    valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-qty04 = ls_invqty-valuationquantity.   "評価数量
      ENDIF.
      READ TABLE lt_prodcostno INTO ls_prodcostno
           WITH KEY product = <lfs_bom>-parent04
                    valuationarea = <lfs_bom>-bklas04 BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_lotsize INTO ls_lotsize
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        READ TABLE lt_costitem INTO ls_costitem
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        IF ls_lotsize-costinglotsize <> 0.
          lv_peinh = ls_costitem-quantityinbaseunit / ls_lotsize-costinglotsize.
          <lfs_bom>-cost04 = ls_costitem-totalpriceincompanycodecrcy / ls_lotsize-costinglotsize
                           * lv_peinh.       "材料費
        ENDIF.
      ENDIF.
      " 5th layer
      CLEAR: ls_lotsize, ls_costitem.
      READ TABLE lt_bklas INTO ls_bklas
             WITH KEY product = <lfs_bom>-parent05
                      valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-bklas05 = ls_bklas-valuationclass.  "評価クラス
      ENDIF.
      READ TABLE lt_invqty INTO ls_invqty
           WITH KEY material = <lfs_bom>-parent05
                    valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-qty05 = ls_invqty-valuationquantity.   "評価数量
      ENDIF.
      READ TABLE lt_prodcostno INTO ls_prodcostno
           WITH KEY product = <lfs_bom>-parent05
                    valuationarea = <lfs_bom>-bklas05 BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_lotsize INTO ls_lotsize
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        READ TABLE lt_costitem INTO ls_costitem
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        IF ls_lotsize-costinglotsize <> 0.
          lv_peinh = ls_costitem-quantityinbaseunit / ls_lotsize-costinglotsize.
          <lfs_bom>-cost05 = ls_costitem-totalpriceincompanycodecrcy / ls_lotsize-costinglotsize
                           * lv_peinh.       "材料費
        ENDIF.
      ENDIF.
      " 6th layer
      CLEAR: ls_lotsize, ls_costitem.
      READ TABLE lt_bklas INTO ls_bklas
             WITH KEY product = <lfs_bom>-parent06
                      valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-bklas06 = ls_bklas-valuationclass.  "評価クラス
      ENDIF.
      READ TABLE lt_invqty INTO ls_invqty
           WITH KEY material = <lfs_bom>-parent06
                    valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-qty06 = ls_invqty-valuationquantity.   "評価数量
      ENDIF.
      READ TABLE lt_prodcostno INTO ls_prodcostno
           WITH KEY product = <lfs_bom>-parent06
                    valuationarea = <lfs_bom>-bklas06 BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_lotsize INTO ls_lotsize
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        READ TABLE lt_costitem INTO ls_costitem
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        IF ls_lotsize-costinglotsize <> 0.
          lv_peinh = ls_costitem-quantityinbaseunit / ls_lotsize-costinglotsize.
          <lfs_bom>-cost06 = ls_costitem-totalpriceincompanycodecrcy / ls_lotsize-costinglotsize
                           * lv_peinh.       "材料費
        ENDIF.
      ENDIF.
      " 7th layer
      CLEAR: ls_lotsize, ls_costitem.
      READ TABLE lt_bklas INTO ls_bklas
             WITH KEY product = <lfs_bom>-parent07
                      valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-bklas07 = ls_bklas-valuationclass.  "評価クラス
      ENDIF.
      READ TABLE lt_invqty INTO ls_invqty
           WITH KEY material = <lfs_bom>-parent07
                    valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-qty07 = ls_invqty-valuationquantity.   "評価数量
      ENDIF.
      READ TABLE lt_prodcostno INTO ls_prodcostno
           WITH KEY product = <lfs_bom>-parent07
                    valuationarea = <lfs_bom>-bklas07 BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_lotsize INTO ls_lotsize
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        READ TABLE lt_costitem INTO ls_costitem
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        IF ls_lotsize-costinglotsize <> 0.
          lv_peinh = ls_costitem-quantityinbaseunit / ls_lotsize-costinglotsize.
          <lfs_bom>-cost07 = ls_costitem-totalpriceincompanycodecrcy / ls_lotsize-costinglotsize
                           * lv_peinh.       "材料費
        ENDIF.
      ENDIF.
      " 8th layer
      CLEAR: ls_lotsize, ls_costitem.
      READ TABLE lt_bklas INTO ls_bklas
             WITH KEY product = <lfs_bom>-parent08
                      valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-bklas08 = ls_bklas-valuationclass.  "評価クラス
      ENDIF.
      READ TABLE lt_invqty INTO ls_invqty
           WITH KEY material = <lfs_bom>-parent08
                    valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-qty08 = ls_invqty-valuationquantity.   "評価数量
      ENDIF.
      READ TABLE lt_prodcostno INTO ls_prodcostno
           WITH KEY product = <lfs_bom>-parent08
                    valuationarea = <lfs_bom>-bklas08 BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_lotsize INTO ls_lotsize
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        READ TABLE lt_costitem INTO ls_costitem
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        IF ls_lotsize-costinglotsize <> 0.
          lv_peinh = ls_costitem-quantityinbaseunit / ls_lotsize-costinglotsize.
          <lfs_bom>-cost08 = ls_costitem-totalpriceincompanycodecrcy / ls_lotsize-costinglotsize
                           * lv_peinh.       "材料費
        ENDIF.
      ENDIF.
      " 9th layer
      CLEAR: ls_lotsize, ls_costitem.
      READ TABLE lt_bklas INTO ls_bklas
             WITH KEY product = <lfs_bom>-parent09
                      valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-bklas09 = ls_bklas-valuationclass.  "評価クラス
      ENDIF.
      READ TABLE lt_invqty INTO ls_invqty
           WITH KEY material = <lfs_bom>-parent09
                    valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-qty09 = ls_invqty-valuationquantity.   "評価数量
      ENDIF.
      READ TABLE lt_prodcostno INTO ls_prodcostno
           WITH KEY product = <lfs_bom>-parent09
                    valuationarea = <lfs_bom>-bklas09 BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_lotsize INTO ls_lotsize
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        READ TABLE lt_costitem INTO ls_costitem
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        IF ls_lotsize-costinglotsize <> 0.
          lv_peinh = ls_costitem-quantityinbaseunit / ls_lotsize-costinglotsize.
          <lfs_bom>-cost09 = ls_costitem-totalpriceincompanycodecrcy / ls_lotsize-costinglotsize
                           * lv_peinh.       "材料費
        ENDIF.
      ENDIF.
      " 10th layer
      CLEAR: ls_lotsize, ls_costitem.
      READ TABLE lt_bklas INTO ls_bklas
             WITH KEY product = <lfs_bom>-parent10
                      valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-bklas10 = ls_bklas-valuationclass.  "評価クラス
      ENDIF.
      READ TABLE lt_invqty INTO ls_invqty
           WITH KEY material = <lfs_bom>-parent10
                    valuationarea = <lfs_bom>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_bom>-qty10 = ls_invqty-valuationquantity.   "評価数量
      ENDIF.
      READ TABLE lt_prodcostno INTO ls_prodcostno
           WITH KEY product = <lfs_bom>-parent10
                    valuationarea = <lfs_bom>-bklas10 BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_lotsize INTO ls_lotsize
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        READ TABLE lt_costitem INTO ls_costitem
             WITH KEY costestimate = ls_prodcostno-prodcostestnumber BINARY SEARCH.
        IF ls_lotsize-costinglotsize <> 0.
          lv_peinh = ls_costitem-quantityinbaseunit / ls_lotsize-costinglotsize.
          <lfs_bom>-cost10 = ls_costitem-totalpriceincompanycodecrcy / ls_lotsize-costinglotsize
                           * lv_peinh.       "材料費
        ENDIF.
      ENDIF.
    ENDLOOP.
* 当期末在庫金額を計算2000/3000
    LOOP AT lt_bom INTO ls_bom
            GROUP BY ( plant = ls_bom-plant
                       raw = ls_bom-raw )
            REFERENCE INTO DATA(member_cost).
      LOOP AT GROUP member_cost ASSIGNING FIELD-SYMBOL(<lfs_cost>).
        IF <lfs_cost>-bklas01 = lc_2000.
          lv_amt_2000 = lv_amt_2000 + <lfs_cost>-cost01.
        ELSEIF <lfs_cost>-bklas01 = lc_3000.
          lv_amt_3000 = lv_amt_3000 + <lfs_cost>-cost01.
        ENDIF.
        IF <lfs_cost>-bklas02 = lc_2000.
          lv_amt_2000 = lv_amt_2000 + <lfs_cost>-cost02.
        ELSEIF <lfs_cost>-bklas02 = lc_3000.
          lv_amt_3000 = lv_amt_3000 + <lfs_cost>-cost02.
        ENDIF.
        IF <lfs_cost>-bklas03 = lc_2000.
          lv_amt_2000 = lv_amt_2000 + <lfs_cost>-cost03.
        ELSEIF <lfs_cost>-bklas03 = lc_3000.
          lv_amt_3000 = lv_amt_3000 + <lfs_cost>-cost03.
        ENDIF.
        IF <lfs_cost>-bklas04 = lc_2000.
          lv_amt_2000 = lv_amt_2000 + <lfs_cost>-cost04.
        ELSEIF <lfs_cost>-bklas04 = lc_3000.
          lv_amt_3000 = lv_amt_3000 + <lfs_cost>-cost04.
        ENDIF.
        IF <lfs_cost>-bklas05 = lc_2000.
          lv_amt_2000 = lv_amt_2000 + <lfs_cost>-cost05.
        ELSEIF <lfs_cost>-bklas05 = lc_3000.
          lv_amt_3000 = lv_amt_3000 + <lfs_cost>-cost05.
        ENDIF.
        IF <lfs_cost>-bklas06 = lc_2000.
          lv_amt_2000 = lv_amt_2000 + <lfs_cost>-cost06.
        ELSEIF <lfs_cost>-bklas06 = lc_3000.
          lv_amt_3000 = lv_amt_3000 + <lfs_cost>-cost06.
        ENDIF.
        IF <lfs_cost>-bklas07 = lc_2000.
          lv_amt_2000 = lv_amt_2000 + <lfs_cost>-cost07.
        ELSEIF <lfs_cost>-bklas07 = lc_3000.
          lv_amt_3000 = lv_amt_3000 + <lfs_cost>-cost07.
        ENDIF.
        IF <lfs_cost>-bklas08 = lc_2000.
          lv_amt_2000 = lv_amt_2000 + <lfs_cost>-cost08.
        ELSEIF <lfs_cost>-bklas08 = lc_3000.
          lv_amt_3000 = lv_amt_3000 + <lfs_cost>-cost08.
        ENDIF.
        IF <lfs_cost>-bklas09 = lc_2000.
          lv_amt_2000 = lv_amt_2000 + <lfs_cost>-cost09.
        ELSEIF <lfs_cost>-bklas09 = lc_3000.
          lv_amt_3000 = lv_amt_3000 + <lfs_cost>-cost09.
        ENDIF.
        IF <lfs_cost>-bklas10 = lc_2000.
          lv_amt_2000 = lv_amt_2000 + <lfs_cost>-cost10.
        ELSEIF <lfs_cost>-bklas10 = lc_3000.
          lv_amt_3000 = lv_amt_3000 + <lfs_cost>-cost10.
        ENDIF.
      ENDLOOP.
      ls_matnrcost-matnr = <lfs_cost>-raw.
      ls_matnrcost-plant = <lfs_cost>-plant.
      ls_matnrcost-tot2000 = lv_amt_2000.
      ls_matnrcost-tot3000 = lv_amt_3000.
      APPEND ls_matnrcost TO lt_matnrcost.
      CLEAR: ls_matnrcost, lv_amt_2000, lv_amt_3000.
    ENDLOOP.
* 該当得意先の総売上高
    SORT lt_bp BY businesspartner.
    LOOP AT lt_bseg INTO DATA(ls_bseg).
      READ TABLE lt_bp INTO ls_bp
           WITH KEY businesspartner = ls_bseg-customer BINARY SEARCH.
      IF sy-subrc <> 0.
        DELETE lt_bseg.
        CONTINUE.
      ENDIF.
    ENDLOOP.
    SORT lt_bseg BY profitcenter customer.
    LOOP AT lt_bseg INTO ls_bseg
            GROUP BY ( profitcenter = ls_bseg-profitcenter
                       customer = ls_bseg-customer )
            REFERENCE INTO DATA(member_customer).
      LOOP  AT GROUP member_customer ASSIGNING FIELD-SYMBOL(<lfs_customer>).
        lv_amt = lv_amt + <lfs_customer>-amountincompanycodecurrency.
      ENDLOOP.
      ls_kunnramt-profitcenter = <lfs_customer>-profitcenter.
      ls_kunnramt-customer = <lfs_customer>-customer.
      ls_kunnramt-amt = lv_amt.
      APPEND ls_kunnramt TO lt_kunnramt.
      CLEAR: ls_kunnramt, lv_amt.
    ENDLOOP.
* 会社レベルの総売上高
    LOOP AT lt_bseg_bukrs INTO DATA(ls_bseg_bukrs).
      lv_amt_bukrs = lv_amt_bukrs + ls_bseg_bukrs-amountincompanycodecurrency.
    ENDLOOP.

* 品番別table
    SORT lt_mrp BY product plant.
    SORT lt_bp BY searchterm2.
    SORT lt_makt BY product.
    SORT lt_bom BY plant raw.
    SORT lt_bklas BY product valuationarea.
    SORT lt_purgroup BY plant product.
    SORT lt_prctr BY product plant.
    SORT lt_prctrname BY profitcenter.
    SORT lt_ztfi_1009 BY profitcenter purchasinggroup.
    SORT lt_ztfi_1011 BY profitcenter purchasinggroup.
    SORT lt_1008 BY profitcenter purchasinggroup.
    SORT lt_1011 BY profitcenter purchasinggroup.
    SORT lt_invtotalamt BY matnr plant.
    SORT lt_kunnramt BY profitcenter customer.
    SORT lt_matnrcost BY plant matnr.
    SORT lt_chgamt_ekgrp BY ekgrp.
    SORT lt_chgamt_matnr BY matnr plant.

    LOOP AT lt_product INTO ls_product.
      "会社コード
      ls_1010-companycode = cv_bukrs.
      ls_1010-currency = lv_waers.
      "会計年度
      ls_1010-fiscalyear = cv_gjahr.
      "会計期間
      ls_1010-period = cv_monat.
      "得意先コード/仕入先コード
      READ TABLE lt_mrp INTO ls_mrp
           WITH KEY product = ls_product-product
                    plant = ls_product-plant BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_bp INTO ls_bp
             WITH KEY searchterm2 = ls_mrp-sort BINARY SEARCH.
        IF sy-subrc = 0.
          ls_1010-customer = ls_bp-businesspartner.
          ls_1010-customername = ls_bp-businesspartnername.
          ls_1010-supplier = ls_bp-businesspartner.
          ls_1010-suppliername = ls_bp-businesspartnername.
        ENDIF.
      ENDIF.
      "有償支給品番
      ls_1010-product = ls_product-product.
      "有償支給品番テキスト
      READ TABLE lt_makt INTO DATA(ls_makt)
           WITH KEY product = ls_product-product BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1010-productdescription = ls_makt-productdescription.
      ENDIF.
      "利益センタ
      READ TABLE lt_prctr INTO DATA(ls_prctr)
           WITH KEY product = ls_product-product
                    plant = ls_product-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1010-profitcenter = ls_prctr-profitcenter.

        READ TABLE lt_prctrname INTO DATA(ls_prctrname)
             WITH KEY profitcenter = ls_prctr-profitcenter BINARY SEARCH.
        IF sy-subrc = 0.  "利益センタテキスト
          ls_1010-profitcentername = ls_prctrname-profitcentername.
        ENDIF.
      ENDIF.

      "購買グループ
      READ TABLE lt_purgroup INTO ls_purgroup
           WITH KEY plant = ls_product-plant
                    product = ls_product-product BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1010-purchasinggroup = ls_purgroup-ekgrp.
      ENDIF.
      "当期購買グループ仕入れ金額 = 期首購買グループ仕入れ金額 + 当前会计期间采购组单位的采购金额
      "当期有償支給品の仕入れ金額 = 期首有償支給品仕入れ金額 + 当前期间有偿支给品的采购金额
      READ TABLE lt_ztfi_1009 INTO DATA(ls_1009)
           WITH KEY profitcenter = ls_1010-profitcenter
                    purchasinggroup = ls_1010-purchasinggroup BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1010-purgrpamount = ls_1010-purgrpamount + ls_1009-begpurgrpamt. "期首購買グループ仕入れ金額
        ls_1010-chargeableamount = ls_1010-chargeableamount + ls_1009-begchgmaterialamt. "期首有償支給品仕入れ金額
        ls_1010-customerrevenue = ls_1010-customerrevenue + ls_1009-begcustomerrev. "期首得意先の総売上高
        ls_1010-revenue = ls_1010-revenue + ls_1009-begrev. "期首会社レベルの総売上高
      ELSE.
        READ TABLE lt_ztfi_1011 INTO DATA(ls_1011)
             WITH KEY profitcenter = ls_1010-profitcenter
                    purchasinggroup = ls_1010-purchasinggroup BINARY SEARCH.
        IF sy-subrc = 0.
          ls_1010-purgrpamount = ls_1010-purgrpamount + ls_1011-purgrpamount. "期首購買グループ仕入れ金額
          ls_1010-chargeableamount = ls_1010-chargeableamount + ls_1011-chargeableamount."期首有償支給品仕入れ金額
          ls_1010-customerrevenue = ls_1010-customerrevenue + ls_1011-customerrevenue. "期首得意先の総売上高
          ls_1010-revenue = ls_1010-revenue + ls_1011-revenue. "期首会社レベルの総売上高
        ENDIF.
      ENDIF.

      READ TABLE lt_chgamt_ekgrp INTO ls_chgamt_ekgrp
           WITH KEY ekgrp = ls_1010-purchasinggroup BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1010-purgrpamount = ls_1010-purgrpamount + ls_chgamt_ekgrp-amount.
      ENDIF.

      READ TABLE lt_chgamt_matnr INTO ls_chgamt_matnr
           WITH KEY matnr = ls_product-product
                    plant = ls_product-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1010-chargeableamount = ls_1010-chargeableamount + ls_chgamt_matnr-amount.
      ENDIF.
      "在庫金額（前期末）
      READ TABLE lt_1008 INTO DATA(ls_1008)
           WITH KEY profitcenter = ls_1010-profitcenter
                    purchasinggroup = ls_1010-purchasinggroup BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1010-previousstockamount = ls_1008-prestockamt.
      ELSE.
        READ TABLE lt_1011 INTO DATA(ls_tmp)
             WITH KEY profitcenter = ls_1010-profitcenter
                      purchasinggroup = ls_1010-purchasinggroup BINARY SEARCH.
        IF sy-subrc = 0.
          ls_1010-previousstockamount = ls_tmp-currentstocktotal.
        ENDIF.
      ENDIF.
      "在庫金額（当期末）-有償支給品
      READ TABLE lt_invtotalamt INTO ls_invtotalamt
           WITH KEY matnr = ls_product-product
                    plant = ls_product-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1010-currentstockamount = ls_invtotalamt-amt.
      ENDIF.
      "該当得意先の総売上高
      READ TABLE lt_kunnramt INTO ls_kunnramt
           WITH KEY profitcenter = ls_1010-profitcenter
                    customer = ls_1010-customer BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1010-customerrevenue = ls_1010-customerrevenue + ls_kunnramt-amt.
      ENDIF.
      "会社レベルの総売上高
      ls_1010-revenue = ls_1010-revenue + lv_amt_bukrs.
      "2000材料費合計/3000材料費合計
      READ TABLE lt_matnrcost INTO ls_matnrcost
           WITH KEY plant = ls_product-plant
                    matnr = ls_product-product BINARY SEARCH.
      IF sy-subrc = 0.
        ls_1010-materialcost2000 = ls_matnrcost-tot2000.
        ls_1010-materialcost3000 = ls_matnrcost-tot3000.
      ENDIF.

      "With 上位品番
      LOOP AT lt_bom INTO ls_bom
           WHERE plant = ls_product-plant
             AND raw = ls_product-product.
        ls_1010-upperproduct01 = ls_bom-parent01. "上位品番
        ls_1010-valuationclass01 = ls_bom-bklas01. "評価クラス
        ls_1010-cost01 = ls_bom-cost01.            "当期末標準原価-材料費
        ls_1010-valuationquantity01 = ls_bom-qty01. "評価数量

        ls_1010-upperproduct02 = ls_bom-parent02. "上位品番
        ls_1010-valuationclass02 = ls_bom-bklas02. "評価クラス
        ls_1010-cost02 = ls_bom-cost02.            "当期末標準原価-材料費
        ls_1010-valuationquantity02 = ls_bom-qty02. "評価数量

        ls_1010-upperproduct03 = ls_bom-parent03. "上位品番
        ls_1010-valuationclass03 = ls_bom-bklas03. "評価クラス
        ls_1010-cost03 = ls_bom-cost03.            "当期末標準原価-材料費
        ls_1010-valuationquantity03 = ls_bom-qty03. "評価数量

        ls_1010-upperproduct04 = ls_bom-parent04. "上位品番
        ls_1010-valuationclass04 = ls_bom-bklas04. "評価クラス
        ls_1010-cost04 = ls_bom-cost04.            "当期末標準原価-材料費
        ls_1010-valuationquantity04 = ls_bom-qty04. "評価数量

        ls_1010-upperproduct05 = ls_bom-parent05. "上位品番
        ls_1010-valuationclass05 = ls_bom-bklas05. "評価クラス
        ls_1010-cost05 = ls_bom-cost05.            "当期末標準原価-材料費
        ls_1010-valuationquantity05 = ls_bom-qty05. "評価数量

        ls_1010-upperproduct06 = ls_bom-parent06. "上位品番
        ls_1010-valuationclass06 = ls_bom-bklas06. "評価クラス
        ls_1010-cost06 = ls_bom-cost06.            "当期末標準原価-材料費
        ls_1010-valuationquantity06 = ls_bom-qty06. "評価数量

        ls_1010-upperproduct07 = ls_bom-parent07. "上位品番
        ls_1010-valuationclass07 = ls_bom-bklas07. "評価クラス
        ls_1010-cost07 = ls_bom-cost07.            "当期末標準原価-材料費
        ls_1010-valuationquantity07 = ls_bom-qty07. "評価数量

        ls_1010-upperproduct08 = ls_bom-parent08. "上位品番
        ls_1010-valuationclass08 = ls_bom-bklas08. "評価クラス
        ls_1010-cost08 = ls_bom-cost08.            "当期末標準原価-材料費
        ls_1010-valuationquantity08 = ls_bom-qty08. "評価数量

        ls_1010-upperproduct09 = ls_bom-parent09. "上位品番
        ls_1010-valuationclass09 = ls_bom-bklas09. "評価クラス
        ls_1010-cost09 = ls_bom-cost09.            "当期末標準原価-材料費
        ls_1010-valuationquantity09 = ls_bom-qty09. "評価数量

        ls_1010-upperproduct10 = ls_bom-parent10. "上位品番
        ls_1010-valuationclass10 = ls_bom-bklas10. "評価クラス
        ls_1010-cost10 = ls_bom-cost10.            "当期末標準原価-材料費
        ls_1010-valuationquantity10 = ls_bom-qty10. "評価数量

        ls_1010-zeile = ls_1010-zeile + 1.
        APPEND ls_1010 TO lt_1010.
      ENDLOOP.
      "Without bom
      IF sy-subrc <> 0.
        ls_1010-zeile = ls_1010-zeile + 1.
        APPEND ls_1010 TO lt_1010.
      ENDIF.
      CLEAR: ls_1010.
    ENDLOOP.

* Insert DB
    IF lt_1010 IS NOT INITIAL.
      INSERT ztfi_1010 FROM TABLE @lt_1010.
      IF sy-subrc = 0.
        ls_request-status = 'S'.
        ls_request-message = TEXT-002.
        APPEND ls_request TO ct_data.
      ENDIF.
    ENDIF.

  ENDMETHOD.
  METHOD calcu_b.
    DATA:
      lt_1011    TYPE STANDARD TABLE OF ztfi_1011,
      ls_1011    TYPE ztfi_1011,
      ls_request TYPE lty_request.

    DATA:
      lv_chargeable(9)      TYPE p DECIMALS 2,
      lv_currentstockamt(9) TYPE p DECIMALS 2,
      lv_semi(10)           TYPE p DECIMALS 2,
      lv_fin(10)            TYPE p DECIMALS 2.

    CONSTANTS:
      lc_2000 TYPE c LENGTH 4 VALUE '2000',
      lc_3000 TYPE c LENGTH 4 VALUE '3000'.

* Delete
    SELECT *                                  "#EC CI_ALL_FIELDS_NEEDED
      FROM ztfi_1011
     WHERE companycode = @cv_bukrs
       AND fiscalyear = @cv_gjahr
       AND period = @cv_monat
      INTO TABLE @DATA(lt_del).
    IF lt_del IS NOT INITIAL.
      DELETE ztfi_1011 FROM TABLE @lt_del.
      IF sy-subrc <> 0.
        ls_request-status = 'E'.
        ls_request-message = TEXT-003.
        APPEND ls_request TO ct_data.
        RETURN.
      ENDIF.
    ENDIF.
* Re-calculate
    SELECT *                                  "#EC CI_ALL_FIELDS_NEEDED
      FROM ztfi_1010
     WHERE companycode = @cv_bukrs
       AND fiscalyear = @cv_gjahr
       AND period = @cv_monat
      INTO TABLE @DATA(lt_1010).

    LOOP AT lt_1010 INTO DATA(ls_1010)
            GROUP BY ( customer = ls_1010-customer
                       supplier = ls_1010-supplier
                       profitcenter = ls_1010-profitcenter
                       purchasinggroup = ls_1010-purchasinggroup )
            REFERENCE INTO DATA(member).
      LOOP AT GROUP member ASSIGNING FIELD-SYMBOL(<lfs_member>).
        lv_chargeable = lv_chargeable + <lfs_member>-chargeableamount.  "当期有償支給品仕入れ金額
        lv_currentstockamt = lv_currentstockamt + <lfs_member>-currentstockamount. "在庫金額（当期末）-有償支給品
        IF <lfs_member>-valuationclass01 = lc_2000.
          lv_semi = lv_semi + <lfs_member>-valuationquantity01 * <lfs_member>-cost01.
        ELSEIF <lfs_member>-valuationclass01 = lc_3000.
          lv_fin = lv_fin + <lfs_member>-valuationquantity01 * <lfs_member>-cost01.
        ENDIF.
        IF <lfs_member>-valuationclass02 = lc_2000.
          lv_semi = lv_semi + <lfs_member>-valuationquantity02 * <lfs_member>-cost02.
        ELSEIF <lfs_member>-valuationclass02 = lc_3000.
          lv_fin = lv_fin + <lfs_member>-valuationquantity02 * <lfs_member>-cost02.
        ENDIF.
        IF <lfs_member>-valuationclass03 = lc_2000.
          lv_semi = lv_semi + <lfs_member>-valuationquantity03 * <lfs_member>-cost03.
        ELSEIF <lfs_member>-valuationclass03 = lc_3000.
          lv_fin = lv_fin + <lfs_member>-valuationquantity03 * <lfs_member>-cost03.
        ENDIF.
        IF <lfs_member>-valuationclass04 = lc_2000.
          lv_semi = lv_semi + <lfs_member>-valuationquantity04 * <lfs_member>-cost04.
        ELSEIF <lfs_member>-valuationclass04 = lc_3000.
          lv_fin = lv_fin + <lfs_member>-valuationquantity04 * <lfs_member>-cost04.
        ENDIF.
        IF <lfs_member>-valuationclass05 = lc_2000.
          lv_semi = lv_semi + <lfs_member>-valuationquantity05 * <lfs_member>-cost05.
        ELSEIF <lfs_member>-valuationclass05 = lc_3000.
          lv_fin = lv_fin + <lfs_member>-valuationquantity05 * <lfs_member>-cost05.
        ENDIF.
        IF <lfs_member>-valuationclass06 = lc_2000.
          lv_semi = lv_semi + <lfs_member>-valuationquantity06 * <lfs_member>-cost06.
        ELSEIF <lfs_member>-valuationclass06 = lc_3000.
          lv_fin = lv_fin + <lfs_member>-valuationquantity06 * <lfs_member>-cost06.
        ENDIF.
        IF <lfs_member>-valuationclass07 = lc_2000.
          lv_semi = lv_semi + <lfs_member>-valuationquantity07 * <lfs_member>-cost07.
        ELSEIF <lfs_member>-valuationclass07 = lc_3000.
          lv_fin = lv_fin + <lfs_member>-valuationquantity07 * <lfs_member>-cost07.
        ENDIF.
        IF <lfs_member>-valuationclass08 = lc_2000.
          lv_semi = lv_semi + <lfs_member>-valuationquantity08 * <lfs_member>-cost08.
        ELSEIF <lfs_member>-valuationclass08 = lc_3000.
          lv_fin = lv_fin + <lfs_member>-valuationquantity08 * <lfs_member>-cost08.
        ENDIF.
        IF <lfs_member>-valuationclass09 = lc_2000.
          lv_semi = lv_semi + <lfs_member>-valuationquantity09 * <lfs_member>-cost09.
        ELSEIF <lfs_member>-valuationclass09 = lc_3000.
          lv_fin = lv_fin + <lfs_member>-valuationquantity09 * <lfs_member>-cost09.
        ENDIF.
        IF <lfs_member>-valuationclass10 = lc_2000.
          lv_semi = lv_semi + <lfs_member>-valuationquantity10 * <lfs_member>-cost10.
        ELSEIF <lfs_member>-valuationclass10 = lc_3000.
          lv_fin = lv_fin + <lfs_member>-valuationquantity10 * <lfs_member>-cost10.
        ENDIF.
      ENDLOOP.

      IF ls_1010-purgrpamount <> 0.
        ls_1011-chargeableamount = lv_chargeable.   "当期有償支給品仕入金額
        ls_1011-chargeablerate = lv_chargeable / ls_1010-purgrpamount.  "当期仕入率
      ENDIF.

      ls_1011-previousstocktotal = ls_1010-previousstockamount.  "在庫金額（前期末）-合計
      ls_1011-currentstockpaid = lv_currentstockamt.  "在庫金額（当期末）-有償支給品
      ls_1011-currentstocksemi = lv_semi * ls_1011-chargeablerate. "在庫金額（当期末）-半製品
      ls_1011-currentstockfin = lv_fin * ls_1011-chargeablerate.  "在庫金額（当期末）-製品
      ls_1011-currentstocktotal = ls_1011-currentstockpaid + ls_1011-currentstocksemi
                                + ls_1011-currentstockfin. "在庫金額（当期末）-合計
      "在庫増減金額
      ls_1011-stockchangeamount = ls_1010-previousstockamount - ls_1011-currentstocktotal.
      "払いだし材料費
      ls_1011-paidmaterialcost = ls_1011-stockchangeamount + ls_1011-chargeableamount.
      "該当得意先の総売上高
      ls_1011-customerrevenue = ls_1010-customerrevenue.
      "会社レベルの総売上高
      ls_1011-revenue = ls_1010-revenue.
      "総売上金額占有率
      IF ls_1011-revenue <> 0.
        ls_1011-revenuerate = ls_1011-customerrevenue / ls_1011-revenue.
      ENDIF.

      APPEND ls_1011 TO lt_1011.
      CLEAR: ls_1011, lv_chargeable, lv_currentstockamt,
             lv_semi, lv_fin.
    ENDLOOP.

* Insert DB
    IF lt_1011 IS NOT INITIAL.
      INSERT ztfi_1011 FROM TABLE @lt_1011.
      IF sy-subrc = 0.
        ls_request-status = 'S'.
        ls_request-message = TEXT-004.
        APPEND ls_request TO ct_data.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_paidpaycalculation DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_paidpaycalculation IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
