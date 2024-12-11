CLASS zcl_productionplan DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_productionplan IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    TYPES:
      BEGIN OF ts_matnr,
        plant                  TYPE werks_d,
        dispo                  TYPE dispo,
        mtart                  TYPE mtart,
        matnr                  TYPE matnr,
        idnrk                  TYPE matnr,
        stufe                  TYPE stufe,
        verid                  TYPE verid,
        plantype               TYPE c LENGTH 1,
        zday                   TYPE n LENGTH 2,
        mdv01                  TYPE arbpl, "Production Line
        capacity               TYPE c LENGTH 30,
        project                TYPE c LENGTH 30,
        remark                 TYPE c LENGTH 20,
        stockqty               TYPE labst,
        rounding               TYPE c LENGTH 30,
        delta                  TYPE c LENGTH 30,
        historyso              TYPE c LENGTH 30,
        futureso               TYPE c LENGTH 30,
        balanceqty(8)          TYPE p DECIMALS 3,
        summary(8)             TYPE p DECIMALS 3,
        summarycolor           TYPE c LENGTH 1,
        mnglg(7)               TYPE p DECIMALS 3,
        objkt                  TYPE aeobjekt,
        isphantomitem          TYPE dumps,
        specialprocurementtype TYPE c LENGTH 2,
      END OF ts_matnr,

      BEGIN OF ts_mrp_api,  "api structue
        material                   TYPE matnr,
        mrpplant                   TYPE werks_d,
        mrpelementopenquantity(9)  TYPE p DECIMALS 3,
        mrpavailablequantity(9)    TYPE p DECIMALS 3,
        mrpelement                 TYPE c LENGTH 12,
        mrpelementavailyorrqmtdate TYPE string,
        mrpelementcategory         TYPE c LENGTH 2,
        mrpelementdocumenttype     TYPE c LENGTH 4,
        productionversion          TYPE c LENGTH 4,
        sourcemrpelement           TYPE c LENGTH 12,
      END OF ts_mrp_api,
      tt_mrp_api TYPE STANDARD TABLE OF ts_mrp_api WITH DEFAULT KEY,

      BEGIN OF ts_mrp_d,
        __count TYPE string,
        results TYPE tt_mrp_api,
      END OF ts_mrp_d,

      BEGIN OF ts_message,
        lang  TYPE string,
        value TYPE string,
      END OF ts_message,

      BEGIN OF ts_error,
        code    TYPE string,
        message TYPE ts_message,
      END OF ts_error,

      BEGIN OF ts_res_mrp_api,
        d     TYPE ts_mrp_d,
        error TYPE ts_error,
      END OF ts_res_mrp_api,

      BEGIN OF ts_plnd_api,
        product              TYPE matnr,
        plant                TYPE werks_d,
        mrparea              TYPE c LENGTH 10,
        plndindeprqmttype    TYPE c LENGTH 4,
        plndindeprqmtversion TYPE c LENGTH 2,
        requirementplan      TYPE c LENGTH 10,
        requirementsegment   TYPE c LENGTH 40,
        plndindeprqmtperiod  TYPE c LENGTH 8,
        periodtype           TYPE c LENGTH 1,
        workingdaydate       TYPE datum,
        plannedquantity      TYPE menge_d,
      END OF ts_plnd_api,
      tt_plnd_api TYPE STANDARD TABLE OF ts_plnd_api WITH DEFAULT KEY,

      BEGIN OF ts_plnd_d,
        __count TYPE string,
        results TYPE tt_plnd_api,
      END OF ts_plnd_d,

      BEGIN OF ts_res_plnd_api,
        d     TYPE ts_plnd_d,
        error TYPE ts_error,
      END OF ts_res_plnd_api,

      BEGIN OF ts_ecn,
        changenumber                TYPE  aennr,
        changenumberobjecttype      TYPE  aetyp,
        objmgmtrecdobjectinternalid TYPE  aeobjekt,
        objmgmtrecddescription      TYPE  cc_oitxt,
        changenumberstatus          TYPE  n LENGTH 2,
        changenumbervalidfromdate   TYPE  cc_andat,
      END OF ts_ecn,
      tt_ecn TYPE STANDARD TABLE OF ts_ecn WITH DEFAULT KEY,
      BEGIN OF ts_ecn_d,
        results TYPE tt_ecn,
      END OF ts_ecn_d,
      BEGIN OF ts_ecn_api,
        d TYPE ts_ecn_d,
      END OF ts_ecn_api,

      BEGIN OF ts_tmpdb,
        matnr     TYPE matnr,
        idnrk     TYPE matnr,
        rqmng     TYPE menge_d,
        rqdat(10) TYPE c,
        dist      TYPE c LENGTH 5,
      END OF ts_tmpdb.

    DATA:
      lt_matnr        TYPE STANDARD TABLE OF ts_matnr,
      ls_matnr        TYPE ts_matnr,
      lt_bom          TYPE STANDARD TABLE OF ts_matnr,
      ls_bom          TYPE ts_matnr,
      lt_para         TYPE TABLE FOR FUNCTION IMPORT i_supplydemanditemtp~getpeggingwithitems,
      ls_para         TYPE STRUCTURE FOR FUNCTION IMPORT i_supplydemanditemtp~getpeggingwithitems,
      lt_mrp_api      TYPE STANDARD TABLE OF ts_mrp_api,
      ls_mrp_api      TYPE ts_mrp_api,
      lt_para_p       TYPE TABLE FOR FUNCTION IMPORT i_supplydemanditemtp~getpeggingwithitems,
      ls_para_p       TYPE STRUCTURE FOR FUNCTION IMPORT i_supplydemanditemtp~getpeggingwithitems,
      lt_mrp_pegging  TYPE STANDARD TABLE OF ts_mrp_api,
      ls_res_mrp_api  TYPE ts_res_mrp_api,
      lt_stock        TYPE STANDARD TABLE OF ts_mrp_api,
      ls_stock        TYPE ts_mrp_api,
      lt_delta        TYPE STANDARD TABLE OF ts_mrp_api,
      ls_delta        TYPE ts_mrp_api,
      lt_history      TYPE STANDARD TABLE OF ts_mrp_api,
      ls_history      TYPE ts_mrp_api,
      lt_future       TYPE STANDARD TABLE OF ts_mrp_api,
      ls_future       TYPE ts_mrp_api,
      lt_require      TYPE STANDARD TABLE OF ts_mrp_api,
      ls_require      TYPE ts_mrp_api,
      lt_reserve      TYPE STANDARD TABLE OF ts_mrp_api,
      ls_reserve      TYPE ts_mrp_api,
      lt_plnd_api     TYPE STANDARD TABLE OF ts_plnd_api,
      ls_plnd_api     TYPE ts_plnd_api,
      ls_res_plnd_api TYPE ts_res_plnd_api,
      lt_ecn_api      TYPE STANDARD TABLE OF ts_ecn,
      ls_ecn_api      TYPE ts_ecn,
      ls_res_ecn      TYPE ts_ecn_api,
      lt_tmpdb        TYPE STANDARD TABLE OF ts_tmpdb,
      ls_tmpdb        TYPE ts_tmpdb,
      "output
      lt_output       TYPE STANDARD TABLE OF zr_productionplan,
      ls_output       TYPE zr_productionplan,
      "range table
      lr_plnum        TYPE RANGE OF i_plannedorder-plannedorder,
      lrs_plnum       LIKE LINE OF lr_plnum,
      lr_orderid      TYPE RANGE OF i_manufacturingorderitem-manufacturingorder,
      lrs_orderid     LIKE LINE OF lr_orderid.


    DATA:
      lv_path         TYPE string,
      lv_filter       TYPE string,
      lv_count        TYPE i,
      lv_month        TYPE monat,
      lv_nextmonth    TYPE monat,
      lv_year         TYPE c LENGTH 4,
      lv_date         TYPE budat,
      lv_capacity(12) TYPE p,
      lv_value(12)    TYPE p DECIMALS 2.


    "Dynamic table
    DATA:
      cl_stru    TYPE REF TO cl_abap_structdescr,
      cl_tabl    TYPE REF TO cl_abap_tabledescr,
      dy_table   TYPE REF TO data,
      dy_line    TYPE REF TO data,
      compdesc   TYPE abap_componentdescr,
      components TYPE abap_component_tab.

    DATA:
      lv_dayc       TYPE c LENGTH 30,
      lv_day        TYPE d,
      lv_vdate      TYPE d,
      lv_color      TYPE c LENGTH 30,
      lv_index      TYPE n LENGTH 3,
      lv_qty        TYPE menge_d,
      lv_qty_t      TYPE menge_d,
      lv_atp        TYPE menge_d,
      lv_atp_t      TYPE menge_d,
      lv_sum        TYPE menge_d,
      lv_field      TYPE menge_d,
      lv_field2(12) TYPE p.

    FIELD-SYMBOLS:
      <lt_tab>     TYPE STANDARD TABLE,
      <ls_tab>     TYPE any,
      <ls_tab2>    TYPE any,
      <l_field>    TYPE any,
      <l_field2>   TYPE any,
      <l_color>    TYPE any,
      <l_plant>    TYPE any,
      <l_idnrk>    TYPE any,
      <l_matnr>    TYPE any,
      <l_verid>    TYPE any,
      <l_planitem> TYPE any,
      <l_plantype> TYPE any,
      <l_dispo>    TYPE any,
      <l_fevor>    TYPE any,
      <l_stufe>    TYPE any,
      <l_mdv01>    TYPE any,
      <l_capacity> TYPE any,
      <l_remark>   TYPE any,
      <l_stockqty> TYPE any,
      <l_rounding> TYPE any,
      <l_delta>    TYPE any,
      <l_history>  TYPE any,
      <l_future>   TYPE any,
      <l_balance>  TYPE any.

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          CASE ls_filter_cond-name.
            WHEN 'PLANT'.
              DATA(lr_werks) = ls_filter_cond-range.
            WHEN 'MRPRESPONSIBLE'.
              DATA(lr_dispo) = ls_filter_cond-range.
            WHEN 'PRODUCTIONSUPERVISOR'.
              DATA(lr_fevor) = ls_filter_cond-range.
            WHEN 'PRODUCT'.
              DATA(lr_matnr) = ls_filter_cond-range.
            WHEN 'ZDAY'.
              DATA(lr_zday) = ls_filter_cond-range.
              READ TABLE lr_zday INTO DATA(lrs_zday) INDEX 1.
              DATA(lv_zday) = lrs_zday-low.
            WHEN 'EXPAND'.
              DATA(lr_expand) = ls_filter_cond-range.
              READ TABLE lr_expand INTO DATA(lrs_expand) INDEX 1.
              DATA(lv_expand) = lrs_expand-low.
            WHEN 'PLANCHECK'.
              DATA(lr_plancheck) = ls_filter_cond-range.
              READ TABLE lr_plancheck INTO DATA(lrs_plancheck) INDEX 1.
              DATA(lv_plancheck) = lrs_plancheck-low.
            WHEN 'THEORY'.
              DATA(lr_theory) = ls_filter_cond-range.
              READ TABLE lr_theory INTO DATA(lrs_theory) INDEX 1.
              DATA(lv_theory) = lrs_theory-low.
            WHEN 'ECN'.
              DATA(lr_ecn) = ls_filter_cond-range.
              READ TABLE lr_ecn INTO DATA(lrs_ecn) INDEX 1.
              DATA(lv_ecn) = lrs_ecn-low.
            WHEN 'WO'.
              DATA(lr_wo) = ls_filter_cond-range.
              READ TABLE lr_wo INTO DATA(lrs_wo) INDEX 1.
              DATA(lv_wo) = lrs_wo-low.
            WHEN 'EXOUT'.
              DATA(lr_out) = ls_filter_cond-range.
              READ TABLE lr_out INTO DATA(lrs_out) INDEX 1.
              DATA(lv_out) = lrs_out-low.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      CATCH cx_rap_query_filter_no_range.
        "handle exception
        io_response->set_data( lt_output ).
    ENDTRY.

* Get the parent
* 1.1-1.3 品目取得
    SELECT a~product,
           a~producttype,
           a~lowlevelcode,
           b~plant,
           b~mrpresponsible
      FROM i_product WITH PRIVILEGED ACCESS AS a
      INNER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b
        ON ( a~product = b~product )
     WHERE a~product IN @lr_matnr
       AND a~ismarkedfordeletion = @space
       AND b~plant IN @lr_werks
       AND b~mrpresponsible IN @lr_dispo
       AND b~procurementtype = 'E'
       AND b~productionsupervisor IN @lr_fevor
       AND ( b~specialprocurementtype = '52'
          OR b~specialprocurementtype = @space )
      INTO TABLE @DATA(lt_marc).
* 2.1 BOM展開下位全品目取得
* if expand bom = 'X', expand
    IF lv_expand = 'X'.
      SORT lt_marc BY plant lowlevelcode product.
      LOOP AT lt_marc INTO DATA(ls_marc).
        READ TABLE lt_bom
                   WITH KEY plant = ls_marc-plant
                            idnrk = ls_marc-product TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.
        ls_bom-plant = ls_marc-plant.
        ls_bom-matnr = ls_marc-product.
        ls_bom-stufe = 0.
        ls_bom-mtart = ls_marc-producttype.
        ls_bom-idnrk = ls_marc-product.
        ls_bom-dispo = ls_marc-mrpresponsible.
        ls_bom-objkt = ls_marc-product.
        APPEND ls_bom TO lt_bom.
        CLEAR: ls_bom.
        " Call BOI
        READ ENTITIES OF i_billofmaterialtp_2 PRIVILEGED
          ENTITY billofmaterial
          EXECUTE explodebom
          FROM VALUE #(
             ( plant = ls_marc-plant
               material = ls_marc-product
               billofmaterialcategory = 'M'
              "billofmaterialvariant = iv_headerbillofmaterialvariant

               %param-bomexplosionapplication = 'PP01'
               %param-requiredquantity = 1
               %param-explodebomlevelvalue = 0
               %param-bomexplosionismultilevel = 'X'
             ) )
         RESULT DATA(lt_result)
         FAILED DATA(ls_failed)
         REPORTED DATA(ls_reported).

        LOOP AT lt_result INTO DATA(ls_data).
          IF ls_data-%param-materialtype <> 'ZROH'
         AND ls_data-%param-materialtype IS NOT INITIAL.
            ls_bom-plant = ls_data-plant.
            ls_bom-matnr = ls_data-material.
            ls_bom-stufe = ls_data-%param-explodebomlevelvalue.
            ls_bom-mtart = ls_data-%param-materialtype.
            ls_bom-idnrk = ls_data-%param-billofmaterialcomponent.
            ls_bom-mnglg = ls_data-%param-componentquantityinbaseuom.
            ls_bom-objkt = ls_data-%param-billofmaterialcomponent.
            ls_bom-isphantomitem = ls_data-%param-isphantomitem.
            ls_bom-specialprocurementtype = ls_data-%param-specialprocurementtype.
            APPEND ls_bom TO lt_bom.
            CLEAR: ls_bom.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ELSE.
* only ZFRT
      LOOP AT lt_marc INTO ls_marc.
        ls_bom-plant = ls_marc-plant.
        ls_bom-matnr = ls_marc-product.
        ls_bom-stufe = 0.
        ls_bom-mtart = ls_marc-producttype.
        ls_bom-idnrk = ls_marc-product.
        ls_bom-dispo = ls_marc-mrpresponsible.
        ls_bom-objkt = ls_marc-product.
        APPEND ls_bom TO lt_bom.
        CLEAR: ls_bom.
      ENDLOOP.
    ENDIF.

* Get referent data of bom component
    DATA(lt_bom_tmp) = lt_bom[].
    SORT lt_bom_tmp BY mtart idnrk.
    DELETE ADJACENT DUPLICATES FROM lt_bom_tmp COMPARING mtart idnrk.
    SELECT plant,
           product,
           mrpresponsible,
           procurementtype,
           specialprocurementtype
      FROM i_productplantbasic WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_bom_tmp
     WHERE product = @lt_bom_tmp-idnrk
       AND ismarkedfordeletion = @space
       AND plant = @lt_bom_tmp-plant
       AND ( ( procurementtype = 'E'
         AND ( specialprocurementtype = '52'
            OR specialprocurementtype = @space ) )
       OR ( procurementtype = 'F'
         AND specialprocurementtype = '30' ) )
      INTO TABLE @DATA(lt_marc_zhlb).
* Filter data
    IF lv_out = 'X'.  "外注品目除外
      DELETE lt_marc_zhlb WHERE procurementtype = 'F'.
    ENDIF.
    SORT lt_marc_zhlb BY plant product.
    LOOP AT lt_bom ASSIGNING FIELD-SYMBOL(<ls_bom>).
      IF <ls_bom>-mtart = 'ZHLB'.
        READ TABLE lt_marc_zhlb INTO DATA(ls_marc_zhlb)
             WITH KEY plant = <ls_bom>-plant
                      product = <ls_bom>-idnrk BINARY SEARCH.
        IF sy-subrc <> 0.
          DELETE lt_bom.
          CONTINUE.
        ELSE.
          <ls_bom>-dispo = ls_marc_zhlb-mrpresponsible.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Rounding
    IF lt_bom IS NOT INITIAL.
      SELECT product,                         "#EC CI_FAE_LINES_ENSURED
             plant,
             lotsizeroundingquantity
        FROM i_productplantsupplyplanning
        FOR ALL ENTRIES IN @lt_bom
       WHERE product = @lt_bom-idnrk
         AND plant = @lt_bom-plant
        INTO TABLE @DATA(lt_rounding).

* 2.2 製造バージョン情報取得
      SELECT plant,
             material,
             productionversion,
             billofoperationstype,
             billofoperationsgroup,
             billofoperationsvariant,
             productionline
        FROM i_productionversion WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_bom
       WHERE plant = @lt_bom-plant
         AND material = @lt_bom-idnrk
         AND productionversionislocked = @space
        INTO TABLE @DATA(lt_prodver).
    ENDIF.
* 2.3 作業区ID取得
    IF lt_prodver IS NOT INITIAL.
      SELECT workcenterinternalid,
             workcenter
        FROM i_workcenter
        FOR ALL ENTRIES IN @lt_prodver
       WHERE workcenter = @lt_prodver-productionline
        INTO TABLE @DATA(lt_workcenter).

* 2.4 作業手順情報取得

      SELECT billofoperationstype,
             billofoperationsgroup,
             billofoperationsvariant,
             workcenterinternalid,
             standardworkquantity2,
             standardworkquantityunit2
        FROM i_mfgboooperationchangestate
        FOR ALL ENTRIES IN @lt_prodver
       WHERE billofoperationstype = @lt_prodver-billofoperationstype
         AND billofoperationsgroup = @lt_prodver-billofoperationsgroup
         AND billofoperationsvariant = @lt_prodver-billofoperationsvariant
         AND isdeleted = @space
         AND isimplicitlydeleted = @space
        INTO TABLE @DATA(lt_operation).
    ENDIF.
* 2.6 ~ 2.13
    "只有getitem单独读物料才能返回availableqty.
    LOOP AT lt_bom INTO ls_bom.
      READ ENTITIES OF i_supplydemanditemtp PRIVILEGED
            ENTITY supplydemanditem
            EXECUTE getitem
            FROM VALUE #( ( %param-material = ls_bom-idnrk
                            %param-mrparea = ls_bom-plant
                            %param-mrpplant = ls_bom-plant ) )
            RESULT DATA(lt_sdi_result)
            FAILED DATA(lt_sdi_failed)
            REPORTED DATA(lt_sdi_reported).
      READ TABLE lt_sdi_result INTO DATA(ls_result) INDEX 1.
      LOOP AT lt_sdi_result INTO DATA(ls_item).
        ls_mrp_api-material = ls_item-%param-material.
        ls_mrp_api-mrpplant = ls_item-%param-mrpplant.
        ls_mrp_api-mrpelementopenquantity = ls_item-%param-mrpelementopenquantity.
        ls_mrp_api-mrpavailablequantity = ls_item-%param-mrpavailablequantity.
        ls_mrp_api-mrpelement = ls_item-%param-mrpelement.
        ls_mrp_api-mrpelementavailyorrqmtdate = ls_item-%param-mrpelementavailyorrqmtdate.
        ls_mrp_api-mrpelementcategory = ls_item-%param-mrpelementcategory.
        ls_mrp_api-mrpelementdocumenttype = ls_item-%param-mrpelementdocumenttype.
        ls_mrp_api-productionversion = ls_item-%param-productionversion.
        ls_mrp_api-sourcemrpelement = ls_item-%param-sourcemrpelement_2.

        APPEND ls_mrp_api TO lt_mrp_api.
        CLEAR: ls_mrp_api.

      ENDLOOP.
    ENDLOOP.
    "只有GetPeggingWithItems能读取到VC和FE类型
    LOOP AT lt_bom INTO ls_bom.
      ls_para_p-%param-mrparea = ls_bom-plant.
      ls_para_p-%param-mrpplant = ls_bom-plant.
      ls_para_p-%param-material = ls_bom-idnrk.
      APPEND ls_para_p TO lt_para_p.
    ENDLOOP.
    READ ENTITIES OF i_supplydemanditemtp PRIVILEGED
         ENTITY supplydemanditem
          EXECUTE getpeggingwithitems
          FROM lt_para_p
         RESULT DATA(lt_sdi_result_p)
         FAILED DATA(lt_sdi_failed_p)
         REPORTED DATA(lt_sdi_reported_p).
    IF lt_sdi_failed_p IS INITIAL.
      LOOP AT lt_sdi_result_p INTO DATA(ls_result_p).
        LOOP AT ls_result_p-%param-_supplydemanditemgetitemr INTO DATA(ls_p).
          ls_mrp_api-material = ls_p-material.
          ls_mrp_api-mrpplant = ls_p-mrpplant.
          ls_mrp_api-mrpelementopenquantity = ls_p-mrpelementopenquantity.
          ls_mrp_api-mrpavailablequantity = ls_p-mrpavailablequantity.
          ls_mrp_api-mrpelement = ls_p-mrpelement.
          ls_mrp_api-mrpelementavailyorrqmtdate = ls_p-mrpelementavailyorrqmtdate.
          ls_mrp_api-mrpelementcategory = ls_p-mrpelementcategory.
          ls_mrp_api-mrpelementdocumenttype = ls_p-mrpelementdocumenttype.
          ls_mrp_api-productionversion = ls_p-productionversion.
          ls_mrp_api-sourcemrpelement = ls_p-sourcemrpelement.
          APPEND ls_mrp_api TO lt_mrp_pegging.
          CLEAR: ls_mrp_api.
        ENDLOOP.
      ENDLOOP.

    ENDIF.


    IF lv_plancheck = 'X'.   "計画手配検査
      lt_bom_tmp[] = lt_bom[].
      CLEAR: lt_bom.
      LOOP AT lt_bom_tmp INTO ls_bom.
        READ TABLE lt_mrp_api INTO ls_mrp_api
             WITH KEY material = ls_bom-idnrk
                      mrpelementcategory = 'PA'
                      mrpelementdocumenttype = 'LA'.
        IF sy-subrc = 0
       AND ls_mrp_api-mrpelementopenquantity <> 0.
          APPEND ls_bom TO lt_bom.
        ENDIF.
      ENDLOOP.

    ENDIF.

* 2.6 在庫取得
    LOOP AT lt_mrp_api INTO ls_mrp_api WHERE mrpelementcategory = 'WB'.
      ls_stock-material = ls_mrp_api-material.
      ls_stock-mrpplant = ls_mrp_api-mrpplant.
      ls_stock-mrpelementopenquantity = ls_mrp_api-mrpelementopenquantity.
      APPEND ls_stock TO lt_stock.
      CLEAR: ls_stock.
    ENDLOOP.
    " Sum
    DATA(lt_stock_tmp) = lt_stock[].
    CLEAR: lt_stock.
    SORT lt_stock_tmp BY material mrpplant.
    LOOP AT lt_stock_tmp INTO DATA(ls_stock_tmp)
         GROUP BY ( material = ls_stock_tmp-material
                    mrpplant = ls_stock_tmp-mrpplant )
         REFERENCE INTO DATA(stock).
      LOOP AT GROUP stock ASSIGNING FIELD-SYMBOL(<lfs_stock>).
        ls_stock-mrpelementopenquantity = ls_stock-mrpelementopenquantity + <lfs_stock>-mrpelementopenquantity.
      ENDLOOP.
      ls_stock-material = <lfs_stock>-material.
      ls_stock-mrpplant = <lfs_stock>-mrpplant.
      APPEND ls_stock TO lt_stock.
      CLEAR: ls_stock.
    ENDLOOP.

* 2.7 DELTA取得
    LOOP AT lt_mrp_api INTO ls_mrp_api
         GROUP BY ( material = ls_mrp_api-material
                    mrpplant = ls_mrp_api-mrpplant )
         REFERENCE INTO DATA(api).
      LOOP AT GROUP api ASSIGNING FIELD-SYMBOL(<lfs_api>).

      ENDLOOP.
      "Delta最後行
      ls_delta-material = <lfs_api>-material.
      ls_delta-mrpplant = <lfs_api>-mrpplant.
      ls_delta-mrpavailablequantity = <lfs_api>-mrpavailablequantity.
      APPEND ls_delta TO lt_delta.
      CLEAR: ls_delta.
    ENDLOOP.
* 2.8 過去～今月までの受注取得
* 2.9 今月～未来までの受注取得
    "実行日付の月末日
    DATA(lv_datum) = cl_abap_context_info=>get_system_date( ).
    lv_year = lv_datum+0(4).
    lv_month = lv_datum+4(2).
    IF lv_month = '12'.
      lv_nextmonth = '01'.
      lv_year = lv_year + 1.
    ELSE.
      lv_nextmonth = lv_month + 1.
    ENDIF.
    lv_datum = lv_year && lv_nextmonth && '01'.
    lv_date = lv_datum - 1.

    LOOP AT lt_mrp_pegging INTO ls_mrp_api
         GROUP BY ( material = ls_mrp_api-material
                    mrpplant = ls_mrp_api-mrpplant )
         REFERENCE INTO DATA(pegging).
      LOOP AT GROUP pegging ASSIGNING <lfs_api>.
        IF <lfs_api>-mrpelementcategory = 'VC'.
          IF <lfs_api>-mrpelementavailyorrqmtdate <= lv_date.
            ls_history-mrpelementopenquantity = ls_history-mrpelementopenquantity
                                              + <lfs_api>-mrpelementopenquantity.
          ELSE.
            ls_future-mrpelementopenquantity = ls_future-mrpelementopenquantity
                                             + <lfs_api>-mrpelementopenquantity.
          ENDIF.
        ENDIF.
      ENDLOOP.
      "history
      ls_history-material = <lfs_api>-material.
      ls_history-mrpplant = <lfs_api>-mrpplant.
      ls_history-mrpelementopenquantity = abs( ls_history-mrpelementopenquantity ).
      APPEND ls_history TO lt_history.
      CLEAR: ls_history.
      "future
      ls_future-material = <lfs_api>-material.
      ls_future-mrpplant = <lfs_api>-mrpplant.
      ls_future-mrpelementopenquantity = abs( ls_future-mrpelementopenquantity ).
      APPEND ls_future TO lt_future.
      CLEAR: ls_future.
    ENDLOOP.


* 2.10 確定済の計画手配取得
    LOOP AT lt_mrp_api INTO ls_mrp_api
         WHERE mrpelementcategory = 'PA'
           AND mrpelementdocumenttype = 'LA'.
      lrs_plnum-sign = 'I'.
      lrs_plnum-option = 'EQ'.
      lrs_plnum-low = ls_mrp_api-mrpelement.
      APPEND lrs_plnum TO lr_plnum.
      CLEAR: lrs_plnum.
    ENDLOOP.
    IF lr_plnum IS NOT INITIAL.
      SELECT plannedorder,
             plannedordertype,
             material,
             mrpplant,
             productionversion,
             plndorderplannedstartdate,
             plannedtotalqtyinbaseunit
        FROM i_plannedorder WITH PRIVILEGED ACCESS
       WHERE plannedorder IN @lr_plnum
         AND plannedorderisfirm = 'X'
        INTO TABLE @DATA(lt_confirmedplan).

* 2.11 未確定の計画手配取得
      SELECT plannedorder,
             plannedordertype,
             material,
             mrpplant,
             productionversion,
             plndorderplannedstartdate,
             plannedtotalqtyinbaseunit,
             plndordercommittedqty
        FROM i_plannedorder WITH PRIVILEGED ACCESS
       WHERE plannedorder IN @lr_plnum
         AND plannedorderisfirm = @space
        INTO TABLE @DATA(lt_unconfirmplan).
    ENDIF.
* 合计未确定和ATP的数量，用于比较颜色
    DATA(lt_un_tmp) = lt_unconfirmplan[].
    CLEAR: lt_unconfirmplan.
    DATA: ls_unconfirm LIKE LINE OF lt_unconfirmplan.
    LOOP AT lt_un_tmp INTO DATA(ls_un_tmp)
            GROUP BY ( material = ls_un_tmp-material
                       mrpplant = ls_un_tmp-mrpplant
                       "productionversion = ls_un_tmp-productionversion
                       plndorderplannedstartdate = ls_un_tmp-plndorderplannedstartdate )
            REFERENCE INTO DATA(unconfirm).

      LOOP AT GROUP unconfirm ASSIGNING FIELD-SYMBOL(<lfs_unconfirm>).
        ls_unconfirm-plannedtotalqtyinbaseunit = ls_unconfirm-plannedtotalqtyinbaseunit
                                               + <lfs_unconfirm>-plannedtotalqtyinbaseunit.
        ls_unconfirm-plndordercommittedqty = ls_unconfirm-plndordercommittedqty
                                           + <lfs_unconfirm>-plndordercommittedqty.
      ENDLOOP.
      ls_unconfirm-mrpplant = <lfs_unconfirm>-mrpplant.
      ls_unconfirm-material = <lfs_unconfirm>-material.
      ls_unconfirm-productionversion = <lfs_unconfirm>-productionversion.
      ls_unconfirm-plndorderplannedstartdate = <lfs_unconfirm>-plndorderplannedstartdate.
      APPEND ls_unconfirm TO lt_unconfirmplan.
      CLEAR: ls_unconfirm.
    ENDLOOP.

* 2.12 製造指図取得
    LOOP AT lt_mrp_pegging INTO ls_mrp_api WHERE mrpelementcategory = 'FE'.
      lrs_orderid-sign = 'I'.
      lrs_orderid-option = 'EQ'.
      lrs_orderid-low = ls_mrp_api-mrpelement.
      APPEND lrs_orderid TO lr_orderid.
      CLEAR: lrs_orderid.
    ENDLOOP.

    IF lr_orderid IS NOT INITIAL.
      SELECT manufacturingorder,
             manufacturingorderitem,
             product,
             productionversion,
             mfgorderplannedstartdate,
             mfgorderitemgoodsreceiptqty,
             mfgorderplannedtotalqty
        FROM i_manufacturingorderitem
       WHERE manufacturingorder IN @lr_orderid
        INTO TABLE @DATA(lt_order).
    ENDIF.
* 2.12 従属所要取得
    CLEAR: lr_plnum.
    LOOP AT lt_mrp_pegging INTO ls_mrp_api
        WHERE mrpelementcategory = 'SB'.
      lrs_plnum-sign = 'I'.
      lrs_plnum-option = 'EQ'.
      lrs_plnum-low = ls_mrp_api-sourcemrpelement.
      APPEND lrs_plnum TO lr_plnum.
      CLEAR: lrs_plnum.
    ENDLOOP.

    IF lr_plnum IS NOT INITIAL.
      SELECT plannedorder
        FROM i_plannedorder
       WHERE plannedorder IN @lr_plnum
         AND plannedorderisfirm = 'X'
        INTO TABLE @DATA(lt_sb).
    ENDIF.

    DATA(lt_mrp_tmp) = lt_mrp_pegging[].
    SORT lt_mrp_tmp BY mrpelementcategory sourcemrpelement.
    LOOP AT lt_sb INTO DATA(ls_sb).
      READ TABLE lt_mrp_tmp INTO ls_mrp_api
                 WITH KEY mrpelementcategory = 'SB'
                          sourcemrpelement = ls_sb-plannedorder BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_mrp_api TO ls_require.
        APPEND ls_require TO lt_require.
        CLEAR: ls_require.
      ENDIF.
    ENDLOOP.

* 2.13 入出庫予定取得
    LOOP AT lt_mrp_pegging INTO ls_mrp_api
         WHERE mrpelementcategory = 'AR'.
      MOVE-CORRESPONDING ls_mrp_api TO ls_reserve.
      ls_reserve-mrpelementopenquantity = abs( ls_mrp_api-mrpelementopenquantity ).
      APPEND ls_reserve TO lt_reserve.
      CLEAR: ls_reserve.
    ENDLOOP.

* 2.14 出荷計画取得
    lt_bom_tmp[] = lt_bom[].
    CLEAR: lv_count.
    SORT lt_bom_tmp BY plant idnrk.
    IF lt_bom_tmp IS NOT INITIAL.
      SELECT product,
             plant,
             mrparea,
             plndindeprqmttype,
             plndindeprqmtversion,
             requirementplan,
             requirementsegment,
             plndindeprqmtperiod,
             periodtype,
             workingdaydate,
             plannedquantity
        FROM i_plndindeprqmtitemtp WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_bom_tmp
       WHERE product = @lt_bom_tmp-idnrk
         AND plant = @lt_bom_tmp-plant
         AND plndindeprqmtversion = '03'
        INTO TABLE @lt_plnd_api.
    ENDIF.


* 2.16 ECN取得
    lv_path = |/YY1_CHANGEMSTROBJECTMGMTRE_CDS/YY1_ChangeMstrObjectMgmtRe|.
    "Call API
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>get
        iv_format      = 'json'
      IMPORTING
        ev_status_code = DATA(lv_stat_code)
        ev_response    = DATA(lv_resbody_api) ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api
                               CHANGING data = ls_res_ecn ).
    IF lv_stat_code = '200'
   AND ls_res_ecn-d-results IS NOT INITIAL.
      APPEND LINES OF ls_res_ecn-d-results TO lt_ecn_api.
    ENDIF.

* Edit value
    "Create main data
    lv_datum = cl_abap_context_info=>get_system_date( ).     "Current date
    SORT lt_history BY material mrpplant.
    SORT lt_future  BY material mrpplant.
    SORT lt_delta   BY material mrpplant.
    SORT lt_stock   BY material mrpplant.
    SORT lt_prodver BY plant material.
    SORT lt_operation BY billofoperationstype billofoperationsgroup billofoperationsvariant.
    SORT lt_rounding BY product plant.
    LOOP AT lt_bom INTO ls_bom.
      ls_matnr-matnr  =  ls_bom-matnr.
      ls_matnr-plant  =  ls_bom-plant.
      ls_matnr-idnrk  =  ls_bom-idnrk.
      ls_matnr-stufe  =  ls_bom-stufe.
      ls_matnr-dispo  =  ls_bom-dispo.
      ls_matnr-mnglg  =  ls_bom-mnglg.

      READ TABLE lt_rounding INTO DATA(ls_rounding)
           WITH KEY product = ls_bom-idnrk
                    plant = ls_bom-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_matnr-rounding = ls_rounding-lotsizeroundingquantity.
      ENDIF.

      IF  ls_bom-mtart = 'ZFRT'.
        ls_matnr-plantype = 'I'.    "出荷計画
        APPEND ls_matnr TO lt_matnr.
      ENDIF.

      LOOP AT lt_prodver INTO DATA(ls_prodver)
                         WHERE plant = ls_bom-plant
                           AND material = ls_bom-idnrk.
        ls_matnr-verid = ls_prodver-productionversion.
        ls_matnr-mdv01 = ls_prodver-productionline.
        IF lv_ecn = 'X'.
          ls_matnr-plantype = 'C'. "ECO番号
          APPEND ls_matnr TO lt_matnr.
        ENDIF.
        IF lv_wo = 'X'.
          ls_matnr-plantype = 'K'.   "指図番号
          APPEND ls_matnr TO lt_matnr.
        ENDIF.

        ls_matnr-plantype = 'O'.  "製造指図
        "capacity
        LOOP AT lt_operation INTO DATA(ls_operation)
                      WHERE billofoperationstype = ls_prodver-billofoperationstype
                        AND billofoperationsgroup = ls_prodver-billofoperationsgroup
                        AND billofoperationsvariant = ls_prodver-billofoperationsvariant.
          lv_value = lv_value + ls_operation-standardworkquantity2.
        ENDLOOP.
        IF lv_value <> 0.
          lv_capacity = 3600 / lv_value.
          ls_matnr-capacity = lv_capacity.
          CONDENSE ls_matnr-capacity NO-GAPS.
          CLEAR: lv_value, lv_capacity.
        ENDIF.
        "BalanceQty
        LOOP AT lt_order INTO DATA(ls_order)
             WHERE product = ls_bom-idnrk
               AND productionversion = ls_prodver-productionversion
               AND mfgorderplannedstartdate <= lv_datum.
          ls_matnr-balanceqty = ls_matnr-balanceqty + ls_order-mfgorderplannedtotalqty
                              - ls_order-mfgorderitemgoodsreceiptqty.
        ENDLOOP.
        APPEND ls_matnr TO lt_matnr.
        CLEAR: ls_matnr-balanceqty.

        ls_matnr-plantype = 'P'.  "計画手配
        APPEND ls_matnr TO lt_matnr.
        CLEAR: ls_matnr-verid, ls_matnr-mdv01, ls_matnr-capacity, ls_matnr-balanceqty.
      ENDLOOP.

      ls_matnr-plantype = 'W'.  "未処分
      "HistorySO
      READ TABLE lt_history INTO ls_history
           WITH KEY material = ls_bom-idnrk
                    mrpplant = ls_bom-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_matnr-historyso = ls_history-mrpelementopenquantity.
        CONDENSE ls_matnr-historyso NO-GAPS.
      ENDIF.
      "FutureSO
      READ TABLE lt_future INTO ls_future
           WITH KEY material = ls_bom-idnrk
                    mrpplant = ls_bom-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_matnr-futureso = ls_future-mrpelementopenquantity.
        CONDENSE ls_matnr-futureso NO-GAPS.
      ENDIF.
      "Delta
      READ TABLE lt_delta INTO ls_delta
           WITH KEY material = ls_bom-idnrk
                    mrpplant = ls_bom-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_matnr-delta = ls_delta-mrpavailablequantity.
        CONDENSE ls_matnr-delta NO-GAPS.
      ENDIF.
      "stockqty
      READ TABLE lt_stock INTO ls_stock
           WITH KEY material = ls_bom-idnrk
                    mrpplant = ls_bom-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_matnr-stockqty = ls_stock-mrpelementopenquantity.
      ENDIF.
      APPEND ls_matnr TO lt_matnr.

      IF lv_theory = 'X'.  "理论在库
        ls_matnr-plantype = 'Z'.
        CLEAR :ls_matnr-historyso,ls_matnr-futureso,ls_matnr-delta.
        APPEND ls_matnr TO lt_matnr.
      ENDIF.
      CLEAR: ls_matnr.
    ENDLOOP.

    "Create dynamic table
    CLEAR components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-PLANT' ).
    compdesc-name  = 'PLANT'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-MRPRESPONSIBLE' ).
    compdesc-name  = 'DISPO'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-PRODUCT' ).
    compdesc-name  = 'MATNR'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-IDNRK' ).
    compdesc-name  = 'IDNRK'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-STUFE' ).
    compdesc-name  = 'STUFE'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-VERID' ).
    compdesc-name  = 'VERID'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-PLANTYPE' ).
    compdesc-name  = 'PLANTYPE'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-MDV01' ).
    compdesc-name  = 'MDV01'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-CAPACITY' ).
    compdesc-name  = 'CAPACITY'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-REMARK' ).
    compdesc-name  = 'REMARK'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-PROJECT' ).
    compdesc-name  = 'PROJECT'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-STOCKQTY' ).
    compdesc-name  = 'STOCKQTY'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-ROUNDING' ).
    compdesc-name  = 'ROUNDING'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-DELTA' ).
    compdesc-name  = 'DELTA'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-HISTORYSO' ).
    compdesc-name  = 'HISTORYSO'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-FUTURESO' ).
    compdesc-name  = 'FUTURESO'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-BALANCEQTY' ).
    compdesc-name  = 'BALANCEQTY'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-SUMMARY' ).
    compdesc-name  = 'SUMMARY'.
    APPEND compdesc TO components.
    compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-PLANTYPE' ).
    compdesc-name  = 'SUMMARYCOLOR'.
    APPEND compdesc TO components.

    "Current date
    lv_datum = cl_abap_context_info=>get_system_date( ).
    lv_day = lv_datum - 1.
* from today
    DO lv_zday TIMES.
      lv_day = lv_day + 1.
      lv_dayc = lv_day.
      CONDENSE lv_dayc.
      compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'LABST' ).
      CONCATENATE 'D' lv_dayc  INTO compdesc-name .
      APPEND compdesc TO components.
      compdesc-type ?= cl_abap_datadescr=>describe_by_name( 'ZR_PRODUCTIONPLAN-PLANTYPE' ).
      CONCATENATE 'COLOR' lv_dayc  INTO compdesc-name .
      APPEND compdesc TO components.
    ENDDO.

*  create table
    cl_stru  = cl_abap_structdescr=>create( components ).
    cl_tabl  = cl_abap_tabledescr=>create( cl_stru ).
    CREATE DATA dy_table TYPE HANDLE cl_tabl.
    ASSIGN dy_table->* TO <lt_tab>.
    CREATE DATA dy_line LIKE LINE OF <lt_tab>.
    ASSIGN dy_line->* TO <ls_tab>.

    LOOP AT lt_matnr ASSIGNING FIELD-SYMBOL(<ls_matnr>).
      ASSIGN COMPONENT 'PLANT' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-plant.
      ASSIGN COMPONENT 'DISPO' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-dispo.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-matnr.
      ASSIGN COMPONENT 'IDNRK' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-idnrk.
      ASSIGN COMPONENT 'STUFE' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-stufe.
      ASSIGN COMPONENT 'VERID' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-verid.
      ASSIGN COMPONENT 'PLANTYPE' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-plantype.
      ASSIGN COMPONENT 'MDV01' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-mdv01.
      ASSIGN COMPONENT 'CAPACITY' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-capacity.
      ASSIGN COMPONENT 'PROJECT' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-project.
      ASSIGN COMPONENT 'STOCKQTY' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-stockqty.
      ASSIGN COMPONENT 'ROUNDING' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-rounding.
      ASSIGN COMPONENT 'DELTA' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-delta.
      ASSIGN COMPONENT 'HISTORYSO' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-historyso.
      ASSIGN COMPONENT 'FUTURESO' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-futureso.
      ASSIGN COMPONENT 'BALANCEQTY' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-balanceqty.
      ASSIGN COMPONENT 'SUMMARY' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-summary.
      ASSIGN COMPONENT 'SUMMARYCOLOR' OF STRUCTURE <ls_tab> TO <l_field>.
      <l_field> = <ls_matnr>-summarycolor.
      APPEND <ls_tab> TO <lt_tab>.
    ENDLOOP.
* edit Plan
    lv_datum = cl_abap_context_info=>get_system_date( ).
    lv_day = lv_datum - 1.
    lv_vdate = lv_day + lv_zday.
    LOOP AT <lt_tab> ASSIGNING <ls_tab>.
      ASSIGN COMPONENT 'PLANT' OF STRUCTURE <ls_tab> TO <l_plant>.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <ls_tab> TO <l_matnr>.
      ASSIGN COMPONENT 'IDNRK' OF STRUCTURE <ls_tab> TO <l_idnrk>.
      ASSIGN COMPONENT 'VERID' OF STRUCTURE <ls_tab> TO <l_verid>.
      ASSIGN COMPONENT 'PLANTYPE' OF STRUCTURE <ls_tab> TO <l_plantype>.
      ASSIGN COMPONENT 'PROJECT' OF STRUCTURE <ls_tab> TO <l_planitem>.
      ASSIGN COMPONENT 'DISPO' OF STRUCTURE <ls_tab> TO <l_dispo>.
      ASSIGN COMPONENT 'STUFE' OF STRUCTURE <ls_tab> TO <l_stufe>.
      ASSIGN COMPONENT 'MDV01' OF STRUCTURE <ls_tab> TO <l_mdv01>.
      ASSIGN COMPONENT 'CAPACITY' OF STRUCTURE <ls_tab> TO <l_capacity>.
      ASSIGN COMPONENT 'REMARK' OF STRUCTURE <ls_tab> TO <l_remark>.
      ASSIGN COMPONENT 'STOCKQTY' OF STRUCTURE <ls_tab> TO <l_stockqty>.
      ASSIGN COMPONENT 'ROUNDING' OF STRUCTURE <ls_tab> TO <l_rounding>.
      ASSIGN COMPONENT 'DELTA' OF STRUCTURE <ls_tab> TO <l_delta>.
      ASSIGN COMPONENT 'HISTORYSO' OF STRUCTURE <ls_tab> TO <l_history>.
      ASSIGN COMPONENT 'FUTURESO' OF STRUCTURE <ls_tab> TO <l_future>.
      ASSIGN COMPONENT 'BALANCEQTY' OF STRUCTURE <ls_tab> TO <l_balance>.

      ASSIGN COMPONENT 'SUMMARY' OF STRUCTURE <ls_tab> TO <l_field2>.
      CASE <l_plantype> .
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
        WHEN 'P'.
          <l_planitem> = '計画手配'. "生产计划
          LOOP AT lt_confirmedplan ASSIGNING FIELD-SYMBOL(<lfs_confirm>)
                                   WHERE material = <l_idnrk>
                                     AND mrpplant = <l_plant>
                                     AND productionversion = <l_verid>
                                     AND plndorderplannedstartdate < lv_vdate.
            IF <lfs_confirm>-plndorderplannedstartdate < lv_datum.
              <lfs_confirm>-plndorderplannedstartdate = lv_datum.
            ENDIF.
            CONCATENATE 'D' <lfs_confirm>-plndorderplannedstartdate INTO lv_dayc.
            ASSIGN COMPONENT lv_dayc OF STRUCTURE <ls_tab> TO <l_field>.
            IF sy-subrc = 0.
              <l_field> = <l_field> + <lfs_confirm>-plannedtotalqtyinbaseunit.
              "Summary
              IF <l_field2> IS ASSIGNED.
                <l_field2> = <l_field2> + <lfs_confirm>-plannedtotalqtyinbaseunit.
              ENDIF.
            ENDIF.
            IF lv_theory = 'X'.
              ls_tmpdb-matnr = <l_matnr>.
              ls_tmpdb-idnrk = <l_idnrk>.
              ls_tmpdb-rqmng = <lfs_confirm>-plannedtotalqtyinbaseunit.
              ls_tmpdb-rqdat = lv_dayc.
              COLLECT ls_tmpdb INTO lt_tmpdb.
            ENDIF.

          ENDLOOP.

        WHEN 'O'.
          <l_planitem> = '製造指図'.
          LOOP AT lt_order ASSIGNING FIELD-SYMBOL(<lfs_order>)
                           WHERE product = <l_idnrk>
                             AND productionversion = <l_verid>
                             "AND mfgorderplannedstartdate >= lv_datum
                             AND mfgorderplannedstartdate < lv_vdate.
            IF <lfs_order>-mfgorderplannedstartdate >= lv_datum.
              CONCATENATE 'D' <lfs_order>-mfgorderplannedstartdate INTO lv_dayc.
              ASSIGN COMPONENT lv_dayc OF STRUCTURE <ls_tab> TO <l_field>.
              IF sy-subrc = 0.
                <l_field> = <l_field> + <lfs_order>-mfgorderplannedtotalqty
                          - <lfs_order>-mfgorderitemgoodsreceiptqty.

                "Summary
                IF <l_field2> IS ASSIGNED.
                  <l_field2> = <l_field2> + <lfs_order>-mfgorderplannedtotalqty
                            - <lfs_order>-mfgorderitemgoodsreceiptqty.
                ENDIF.
              ENDIF.
            ENDIF.
            IF lv_theory = 'X'.
              IF <lfs_order>-mfgorderplannedstartdate < lv_datum.
                <lfs_order>-mfgorderplannedstartdate = lv_datum.
                CONCATENATE 'D' <lfs_order>-mfgorderplannedstartdate INTO lv_dayc.
              ENDIF.
              ls_tmpdb-matnr = <l_matnr>.
              ls_tmpdb-idnrk = <l_idnrk>.
              ls_tmpdb-rqmng = <lfs_order>-mfgorderplannedtotalqty
                      - <lfs_order>-mfgorderitemgoodsreceiptqty.
              ls_tmpdb-rqdat = lv_dayc.

              COLLECT ls_tmpdb INTO lt_tmpdb.
            ENDIF.
          ENDLOOP.
        WHEN 'C'. "ECN
          <l_planitem> = 'ECO番号'.

        WHEN 'K'. "
          <l_planitem> = '指図番号'.

        WHEN 'I'.
          <l_planitem> = '出荷計画'."出货计划
          LOOP AT lt_plnd_api ASSIGNING FIELD-SYMBOL(<lfs_plnd>)
                              WHERE product = <l_idnrk>
                                "AND workingdaydate >= lv_datum
                                AND workingdaydate < lv_vdate.
            IF <lfs_plnd>-workingdaydate >= lv_datum.
              CONCATENATE 'D' <lfs_plnd>-workingdaydate INTO lv_dayc.
              ASSIGN COMPONENT lv_dayc OF STRUCTURE <ls_tab> TO <l_field>.
              IF sy-subrc = 0.
                <l_field> = <l_field> + <lfs_plnd>-plannedquantity.

                "Summary
                IF <l_field2> IS ASSIGNED.
                  <l_field2> = <l_field2> + <lfs_plnd>-plannedquantity.
                ENDIF.
              ENDIF.
            ENDIF.

            IF lv_theory = 'X'.
              IF <lfs_plnd>-workingdaydate < lv_datum.
                <lfs_plnd>-workingdaydate = lv_datum.
                CONCATENATE 'D' <lfs_plnd>-workingdaydate INTO lv_dayc.
              ENDIF.
              ls_tmpdb-matnr = <l_matnr>.
              ls_tmpdb-idnrk = <l_idnrk>.
              ls_tmpdb-rqmng = <lfs_plnd>-plannedquantity * -1 .
              ls_tmpdb-rqdat = lv_dayc.
              COLLECT ls_tmpdb INTO lt_tmpdb.
            ENDIF.
          ENDLOOP.

        WHEN 'W'.   "未処分
          <l_planitem> = '未処分'.
          LOOP AT lt_unconfirmplan ASSIGNING <lfs_unconfirm>
                                   WHERE material = <l_idnrk>
                                     AND mrpplant = <l_plant>
                                     "AND productionversion = <l_verid>
                                     AND plndorderplannedstartdate < lv_vdate.
            IF <lfs_unconfirm>-plndorderplannedstartdate < lv_datum.
              <lfs_unconfirm>-plndorderplannedstartdate = lv_datum.
            ENDIF.

            CONCATENATE 'D' <lfs_unconfirm>-plndorderplannedstartdate INTO lv_dayc.
            ASSIGN COMPONENT lv_dayc OF STRUCTURE <ls_tab> TO <l_field>.
            IF sy-subrc = 0.
              <l_field> = <lfs_unconfirm>-plannedtotalqtyinbaseunit.
            ENDIF.
            lv_atp = <lfs_unconfirm>-plndordercommittedqty.
            lv_qty = <lfs_unconfirm>-plannedtotalqtyinbaseunit.
            "Summary
            IF <l_field2> IS ASSIGNED.
              <l_field2> = <l_field2> + <lfs_unconfirm>-plannedtotalqtyinbaseunit.
            ENDIF.
            lv_qty_t = lv_qty_t + <lfs_unconfirm>-plannedtotalqtyinbaseunit.
            lv_atp_t = lv_atp_t + <lfs_unconfirm>-plndordercommittedqty.

            CONCATENATE 'COLOR' <lfs_unconfirm>-plndorderplannedstartdate INTO lv_dayc.
            ASSIGN COMPONENT lv_dayc OF STRUCTURE <ls_tab> TO <l_field>.
            IF sy-subrc = 0.
              IF lv_atp = 0      "赤色
             AND lv_qty <> 0.
                <l_field> = 'R'.
              ENDIF.
              IF lv_atp > 0         "黄色
             AND lv_atp < lv_qty.
                <l_field> = 'Y'.
              ENDIF.
              IF lv_atp >= lv_qty.  "緑色
                <l_field> = 'G'.
              ENDIF.

              IF lv_atp = 0
             AND lv_qty = 0.
                <l_field> = space.
              ENDIF.
            ENDIF.

          ENDLOOP.
          CLEAR: lv_atp, lv_atp_t, lv_qty, lv_qty_t.
        WHEN 'Z'.   "Theory Stock
          <l_planitem> = '理論在庫'.
          LOOP AT lt_require INTO ls_require
                             WHERE material = <l_idnrk>
                               AND mrpplant = <l_plant>
                               AND mrpelementavailyorrqmtdate < lv_vdate.
            IF ls_require-mrpelementavailyorrqmtdate < lv_datum.
              ls_require-mrpelementavailyorrqmtdate = lv_datum.
            ENDIF.
            CONCATENATE 'D' ls_require-mrpelementavailyorrqmtdate INTO lv_dayc.
            ls_tmpdb-matnr = <l_matnr>.
            ls_tmpdb-idnrk = <l_idnrk>.
            ls_tmpdb-rqmng = ls_require-mrpelementopenquantity.
            ls_tmpdb-rqdat = lv_dayc.
            COLLECT ls_tmpdb INTO lt_tmpdb.
          ENDLOOP.


          LOOP AT lt_reserve INTO ls_reserve
                             WHERE material = <l_idnrk>
                               AND mrpplant = <l_plant>
                               AND mrpelementavailyorrqmtdate < lv_vdate.
            IF ls_reserve-mrpelementavailyorrqmtdate < lv_datum.
              ls_reserve-mrpelementavailyorrqmtdate = lv_datum.
            ENDIF.
            CONCATENATE 'D' ls_reserve-mrpelementavailyorrqmtdate INTO lv_dayc.
            ls_tmpdb-matnr = <l_matnr>.
            ls_tmpdb-idnrk = <l_idnrk>.
            ls_tmpdb-rqmng = ls_reserve-mrpelementopenquantity * -1 .
            ls_tmpdb-rqdat = lv_dayc.
            COLLECT ls_tmpdb INTO lt_tmpdb.
          ENDLOOP.

          SORT lt_tmpdb BY rqdat.
          lv_sum = <l_stockqty>.
          LOOP AT lt_tmpdb INTO ls_tmpdb
                  WHERE matnr = <l_matnr>
                    AND idnrk = <l_idnrk>.
            ASSIGN COMPONENT ls_tmpdb-rqdat OF STRUCTURE <ls_tab> TO <l_field>.
            IF sy-subrc = 0.
              <l_field> = lv_sum + ls_tmpdb-rqmng.

              lv_sum = <l_field>.
            ENDIF.
          ENDLOOP.
          CLEAR: lv_sum, lt_tmpdb.
      ENDCASE.
      UNASSIGN: <l_field>, <l_field2>.
    ENDLOOP.

* edit Output
    LOOP AT <lt_tab> ASSIGNING <ls_tab>.
      ASSIGN COMPONENT 'PLANT' OF STRUCTURE <ls_tab> TO <l_plant>.
      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <ls_tab> TO <l_matnr>.
      ASSIGN COMPONENT 'IDNRK' OF STRUCTURE <ls_tab> TO <l_idnrk>.
      ASSIGN COMPONENT 'VERID' OF STRUCTURE <ls_tab> TO <l_verid>.
      ASSIGN COMPONENT 'PLANTYPE' OF STRUCTURE <ls_tab> TO <l_plantype>.
      ASSIGN COMPONENT 'PROJECT' OF STRUCTURE <ls_tab> TO <l_planitem>.
      ASSIGN COMPONENT 'SUMMARY' OF STRUCTURE <ls_tab> TO <l_field2>.
      ASSIGN COMPONENT 'DISPO' OF STRUCTURE <ls_tab> TO <l_dispo>.
      ASSIGN COMPONENT 'STUFE' OF STRUCTURE <ls_tab> TO <l_stufe>.
      ASSIGN COMPONENT 'MDV01' OF STRUCTURE <ls_tab> TO <l_mdv01>.
      ASSIGN COMPONENT 'CAPACITY' OF STRUCTURE <ls_tab> TO <l_capacity>.
      ASSIGN COMPONENT 'REMARK' OF STRUCTURE <ls_tab> TO <l_remark>.
      ASSIGN COMPONENT 'STOCKQTY' OF STRUCTURE <ls_tab> TO <l_stockqty>.
      ASSIGN COMPONENT 'ROUNDING' OF STRUCTURE <ls_tab> TO <l_rounding>.
      ASSIGN COMPONENT 'DELTA' OF STRUCTURE <ls_tab> TO <l_delta>.
      ASSIGN COMPONENT 'HISTORYSO' OF STRUCTURE <ls_tab> TO <l_history>.
      ASSIGN COMPONENT 'FUTURESO' OF STRUCTURE <ls_tab> TO <l_future>.
      ASSIGN COMPONENT 'BALANCEQTY' OF STRUCTURE <ls_tab> TO <l_balance>.
      ASSIGN COMPONENT 'SUMMARY' OF STRUCTURE <ls_tab> TO <l_field>.
      ASSIGN COMPONENT 'SUMMARYCOLOR' OF STRUCTURE <ls_tab> TO <l_color>.
      ls_output-plant = <l_plant>.
      ls_output-mrpresponsible = <l_dispo>.
      ls_output-product = <l_matnr>.
      ls_output-idnrk = <l_idnrk>.
      ls_output-stufe = <l_stufe>.
      ls_output-verid = <l_verid>.
      ls_output-mdv01 = <l_mdv01>.
      ls_output-plantype = <l_plantype>.
      ls_output-project = <l_planitem>.
      ls_output-capacity = <l_capacity>.
      CONDENSE ls_output-capacity NO-GAPS.
      ls_output-remark = <l_remark>.
      lv_field2 = <l_stockqty>.
      IF lv_field2 <> 0.
        ls_output-stockqty = lv_field2.
        CONDENSE ls_output-stockqty NO-GAPS.
      ENDIF.
      lv_field2 = <l_rounding>.
      IF lv_field2 <> 0.
        ls_output-rounding = lv_field2.
        CONDENSE ls_output-rounding NO-GAPS.
      ENDIF.
      lv_field2 = <l_delta>.
      IF lv_field2 <> 0.
        ls_output-delta = lv_field2.
        CONDENSE ls_output-delta NO-GAPS.
      ENDIF.

      lv_field2 = <l_history>.
      IF lv_field2 <> 0.
        ls_output-historyso = lv_field2.
        CONDENSE ls_output-historyso NO-GAPS.
      ENDIF.

      lv_field2 = <l_future>.
      IF lv_field2 <> 0.
        ls_output-futureso = lv_field2.
        CONDENSE ls_output-futureso NO-GAPS.
      ENDIF.
      lv_field2 = <l_balance>.
      IF lv_field2 <> 0.
        ls_output-balanceqty = lv_field2.
        CONDENSE ls_output-balanceqty NO-GAPS.
      ENDIF.
      lv_field2 = <l_field>.
      IF lv_field2 <> 0.
        ls_output-summary = lv_field2.
        CONDENSE ls_output-summary NO-GAPS.
      ENDIF.
      READ TABLE lt_marc_zhlb INTO ls_marc_zhlb
           WITH KEY plant = <l_plant>
                    product = <l_idnrk> BINARY SEARCH.
      IF sy-subrc = 0.
        ls_output-sobmx = ls_marc_zhlb-specialprocurementtype.
      ENDIF.

      lv_datum = cl_abap_context_info=>get_system_date( ).
      lv_day = lv_datum - 1.
* from today
      DO lv_zday TIMES.
        lv_day = lv_day + 1.
        lv_dayc = lv_day.
        CONDENSE lv_dayc.
        CONCATENATE 'D' lv_dayc INTO lv_dayc.
        ASSIGN COMPONENT lv_dayc OF STRUCTURE <ls_tab> TO <l_field>.
        CONCATENATE 'COLOR' lv_dayc+1(8) INTO lv_dayc.
        ASSIGN COMPONENT lv_dayc OF STRUCTURE <ls_tab> TO <l_color>.
        lv_index = lv_index + 1.
        CONCATENATE 'D' lv_index INTO lv_dayc.
        ASSIGN COMPONENT lv_dayc OF STRUCTURE ls_output TO <l_field2>.

        IF <l_field> IS ASSIGNED
       AND <l_field2> IS ASSIGNED.
          IF <l_field> <> 0.
            lv_field2 = <l_field>.
            <l_field2> = lv_field2.
            CONDENSE <l_field2> NO-GAPS.
          ENDIF.

        ENDIF.

        IF <l_plantype> = 'C'.   "ECN
          READ TABLE lt_ecn_api INTO DATA(ls_ecn)
                                WITH KEY objmgmtrecdobjectinternalid = <l_idnrk>
                                         changenumbervalidfromdate = lv_day.

          IF sy-subrc = 0.
            ASSIGN COMPONENT lv_dayc OF STRUCTURE ls_output TO <l_field>.
            IF sy-subrc = 0.
              <l_field> = ls_ecn-changenumber.
            ENDIF.
          ENDIF.
        ENDIF.

        IF <l_plantype> = 'K'.   "指図番号
          READ TABLE lt_order INTO ls_order
               WITH KEY product = <l_idnrk>
                        productionversion = <l_verid>
                        mfgorderplannedstartdate = lv_day.
          IF sy-subrc = 0.
            ASSIGN COMPONENT lv_dayc OF STRUCTURE ls_output TO <l_field>.
            IF sy-subrc = 0.
              <l_field> = |{ ls_order-manufacturingorder ALPHA = OUT }|.
            ENDIF.
          ENDIF.
        ENDIF.

        IF <l_plantype> = 'W'   "未処分
       AND <l_field> IS ASSIGNED
       AND <l_field2> IS ASSIGNED
       AND <l_color> IS ASSIGNED.
          IF <l_field> <> 0.
            lv_field2 = <l_field>.
            <l_field2> = lv_field2.
            CONCATENATE <l_color> <l_field2> INTO <l_field2>.
            CONDENSE <l_field2> NO-GAPS.
          ENDIF.

        ENDIF.

        IF <l_plantype> = 'Z'  "理論在庫:如果当天为空，就等于之前有值的一天
       AND <l_field> IS ASSIGNED
       AND <l_field2> IS ASSIGNED.
          IF <l_field> <> 0.
            lv_field2 = <l_field>.
            <l_field2> = lv_field2.
            CONDENSE <l_field2> NO-GAPS.
          ELSE.
            <l_field2> = '0'.
            CONDENSE <l_field2> NO-GAPS.
          ENDIF.
        ENDIF.
      ENDDO.

      APPEND ls_output TO lt_output.
      CLEAR: ls_output, lv_index, lv_datum, lv_day, lv_dayc, lv_field.
    ENDLOOP.


    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_output ) ).
    ENDIF.

    "Sort
    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                               CHANGING  ct_data  = lt_output ).

    " Paging
    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                              CHANGING  ct_data   = lt_output ).

    io_response->set_data( lt_output ).


  ENDMETHOD.

ENDCLASS.
