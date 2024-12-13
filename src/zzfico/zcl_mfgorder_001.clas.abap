CLASS zcl_mfgorder_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_mfgorder_001 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TYPES:
      BEGIN OF ty_data,
        orderid                       TYPE i_mfgorderactlplantgtldgrcost-orderid,                       "key
        partnercostcenter             TYPE i_mfgorderactlplantgtldgrcost-partnercostcenter,             "key
        partnercostctractivitytype    TYPE i_mfgorderactlplantgtldgrcost-partnercostctractivitytype,    "key
        unitofmeasure                 TYPE i_mfgorderactlplantgtldgrcost-unitofmeasure,                 "key
        plant                         TYPE i_mfgorderactlplantgtldgrcost-plant,                         "key
        orderitem                     TYPE i_mfgorderactlplantgtldgrcost-orderitem,                     "key
        workcenterinternalid          TYPE i_mfgorderactlplantgtldgrcost-workcenterinternalid,          "key
        orderoperation                TYPE i_mfgorderactlplantgtldgrcost-orderoperation,                "key
        glaccount                     TYPE i_mfgorderactlplantgtldgrcost-glaccount,                     "key
        curplanprojslsordvalnstrategy TYPE i_mfgorderactlplantgtldgrcost-curplanprojslsordvalnstrategy, "key
        companycode                   TYPE i_mfgorderactlplantgtldgrcost-companycode,
        producedproduct               TYPE i_mfgorderactlplantgtldgrcost-producedproduct,
        planqtyincostsourceunit       TYPE i_mfgorderactlplantgtldgrcost-planqtyincostsourceunit,
        actualqtyincostsourceunit     TYPE i_mfgorderactlplantgtldgrcost-actualqtyincostsourceunit,
        yearperiod                    TYPE fins_fyearperiod,                                            "new key
      END OF ty_data,
      BEGIN OF ty_data1,

        assembly    TYPE i_mfgorderactlplantgtldgrcost-producedproduct, "
        material    TYPE i_mfgorderactlplantgtldgrcost-producedproduct,
        zfrtproduct TYPE i_mfgorderactlplantgtldgrcost-producedproduct,
      END OF ty_data1,
      BEGIN OF ty_data2,
        "manufacturingorder        TYPE i_manufacturingorder-manufacturingorder,
        product                   TYPE i_mfgorderactlplantgtldgrcost-producedproduct,
        mfgorderconfirmedyieldqty TYPE i_manufacturingorder-mfgorderconfirmedyieldqty,
        productionsupervisor      TYPE i_manufacturingorder-productionsupervisor,
      END OF ty_data2.
    TYPES:
      BEGIN OF ty_results,
        accountingcostrateuuid     TYPE string,
        companycode                TYPE string,
        costcenter                 TYPE string,
        activitytype               TYPE string,
        currency                   TYPE string,
        controllingarea            TYPE string,
        validitystartfiscalyear    TYPE string,
        validitystartfiscalperiod  TYPE string,
        validityendfiscalyear      TYPE string,
        validityendfiscalperiod    TYPE string,
        costratefixedamount        TYPE string,
        costratevarblamount        TYPE string,
        costratescalefactor        TYPE string,
        costctractivitytypeqtyunit TYPE string,
        ledger                     TYPE string,
        costrateisoverwritemode    TYPE string,
      END OF ty_results,
      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,
      BEGIN OF ty_res_api,
        value TYPE tt_results,
      END OF ty_res_api,

      BEGIN OF ty_results1,
        accountingcostrateuuid     TYPE string,
        companycode                TYPE string,
        costcenter                 TYPE string,
        activitytype               TYPE string,
        currency                   TYPE string,
        controllingarea            TYPE string,
        validitystartfiscalyear    TYPE string,
        validitystartfiscalperiod  TYPE string,
        validityendfiscalyear      TYPE string,
        validityendfiscalperiod    TYPE string,
        costratefixedamount        TYPE string,
        costratevarblamount        TYPE string,
        costratescalefactor        TYPE string,
        costctractivitytypeqtyunit TYPE string,
        ledger                     TYPE string,
        costrateisoverwritemode    TYPE string,
        depreciationkeyname(50)    TYPE c,
      END OF ty_results1,
      tt_results1 TYPE STANDARD TABLE OF ty_results1 WITH DEFAULT KEY,

      BEGIN OF ty_res_api1,
        value TYPE tt_results1,
      END OF ty_res_api1.
    TYPES:
      BEGIN OF ty_results3,
        isassembly              TYPE string,
        "companycode             TYPE string,
        plant                   TYPE string,
        "manufacturingorder         TYPE string,
        billofmaterialcomponent TYPE string,
        material                TYPE string,
      END OF ty_results3,

      tt_results3 TYPE STANDARD TABLE OF ty_results3 WITH DEFAULT KEY,
      BEGIN OF ty_d,
        results TYPE tt_results3,
      END OF ty_d,
      BEGIN OF ty_res_api3,
        d TYPE ty_d,
      END OF ty_res_api3.
    DATA:ls_res_api3  TYPE ty_res_api3.
    DATA:
      lv_orderby_string TYPE string,
      lv_select_string  TYPE string.
    "select options
    DATA:
      lr_plant        TYPE RANGE OF zc_mfgorder_001-plant,
      lrs_plant       LIKE LINE OF lr_plant,
      lr_companycode  TYPE RANGE OF zc_mfgorder_001-companycode,
      lrs_companycode LIKE LINE OF lr_companycode.
    DATA:
      lv_calendaryear  TYPE calendaryear,
      lv_calendarmonth TYPE calendarmonth.
    DATA:lv_date_f TYPE aedat.
    DATA:lv_date_t TYPE aedat.
    DATA:lv_date_s TYPE aedat.
    DATA:lv_date_e TYPE aedat.
    DATA:lv_calendarmonth_s TYPE string.
    DATA:
      lt_mfgorder_001     TYPE STANDARD TABLE OF zc_mfgorder_001,
      lt_mfgorder_001_out TYPE STANDARD TABLE OF zc_mfgorder_001,
      ls_mfgorder_001     TYPE zc_mfgorder_001.
    DATA:lv_path     TYPE string.
    DATA:ls_res_api  TYPE ty_res_api.
    DATA:ls_res_api1 TYPE ty_res_api1.
    DATA:lc_alpha_out     TYPE string        VALUE 'OUT'.

    DATA:lv_zero TYPE i_manufacturingorder-mfgorderconfirmedyieldqty.
    IF io_request->is_data_requested( ).

      TRY.
          "get and add filter
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option) ##NO_HANDLER.

      ENDTRY.
      DATA(lv_top)     = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).
      DATA(lt_fields)  = io_request->get_requested_elements( ).
      DATA(lt_sort)    = io_request->get_sort_elements( ).
*****************************************************************
*       Sort
*****************************************************************
*      IF lt_sort IS NOT INITIAL.
*        CLEAR lv_orderby_string.
*        LOOP AT lt_sort INTO DATA(ls_sort).
*          IF ls_sort-descending = abap_true.
*            CONCATENATE lv_orderby_string ls_sort-element_name 'DESCENDING' INTO lv_orderby_string SEPARATED BY space.
*          ELSE.
*            CONCATENATE lv_orderby_string ls_sort-element_name 'ASCENDING' INTO lv_orderby_string SEPARATED BY space.
*          ENDIF.
*        ENDLOOP.
*      ELSE.
*        lv_orderby_string = 'PRODUCT'.
*      ENDIF.

*****************************************************************
*       Filter
*****************************************************************
      READ TABLE lt_filter_cond INTO DATA(ls_companycode_cond) WITH KEY name = 'COMPANYCODE' .
      IF sy-subrc EQ 0.
        LOOP AT ls_companycode_cond-range INTO DATA(ls_sel_opt_companycode).
          MOVE-CORRESPONDING ls_sel_opt_companycode TO lrs_companycode.
          INSERT lrs_companycode INTO TABLE lr_companycode.
        ENDLOOP.
      ENDIF.

      READ TABLE lt_filter_cond INTO DATA(ls_plant_cond) WITH KEY name = 'PLANT' .
      IF sy-subrc EQ 0.
        LOOP AT ls_plant_cond-range INTO DATA(ls_sel_opt_plant).
          MOVE-CORRESPONDING ls_sel_opt_plant TO lrs_plant.
          INSERT lrs_plant INTO TABLE lr_plant.
        ENDLOOP.
      ENDIF.

      READ TABLE lt_filter_cond INTO DATA(ls_year_cond) WITH KEY name = 'CALENDARYEAR' .
      IF sy-subrc EQ 0.
        READ TABLE ls_year_cond-range INTO DATA(ls_sel_opt_year) INDEX 1.
        IF sy-subrc EQ 0 .
          lv_calendaryear = ls_sel_opt_year-low.
        ENDIF.
      ENDIF.

      READ TABLE lt_filter_cond INTO DATA(ls_month_cond) WITH KEY name = 'CALENDARMONTH' .
      IF sy-subrc EQ 0.
        READ TABLE ls_month_cond-range INTO DATA(ls_sel_opt_month) INDEX 1.
        IF sy-subrc EQ 0 .
          lv_calendarmonth = ls_sel_opt_month-low.
          lv_calendarmonth_s =  |{ lv_calendarmonth ALPHA = OUT }|.
          CONDENSE lv_calendarmonth_s.
          IF lv_calendarmonth_s < 10.
            lv_calendarmonth_s = '0' && lv_calendarmonth_s.
          ENDIF.
          lv_date_f = lv_calendaryear && lv_calendarmonth_s && '01'.
          lv_date_f = zzcl_common_utils=>calc_date_add( date = lv_date_f month = 3 ).
          lv_date_f = lv_date_f+0(6) && '01'.
          lv_date_t = lv_date_f+0(6) && '31'.
        ENDIF.
      ENDIF.
*****************************************************************
*       Check Data
*****************************************************************
*****************************************************************
*       Get Data
*****************************************************************
      DATA:lv_fromfiscalyearperiod TYPE fins_fyearperiod.
      DATA:lv_tofiscalyearperiod TYPE fins_fyearperiod.
      DATA:lv_period TYPE fins_fyearperiod.
      DATA:lt_mfgorderactlplantgtldgrcost TYPE STANDARD TABLE OF ty_data.
      DATA:ls_mfgorderactlplantgtldgrcost TYPE ty_data.
      DATA:lt_component TYPE STANDARD TABLE OF ty_data1.
      DATA:ls_component TYPE ty_data1.
      DATA:lt_data TYPE STANDARD TABLE OF ty_data.
      DATA:lt_sum_qty TYPE STANDARD TABLE OF ty_data2.
      DATA:ls_sum_qty TYPE ty_data2.

      IF lv_calendaryear IS NOT INITIAL AND lv_calendarmonth IS NOT INITIAL.

        CLEAR lv_period.
        lv_period = lv_calendaryear && '0' && lv_calendarmonth.
        "包含完成品和半制品
        SELECT
          orderid,                           "key
          partnercostcenter,                 "key
          partnercostctractivitytype,        "key
          unitofmeasure,                     "key
          plant,                             "key
          orderitem,                         "key
          workcenterinternalid,              "key
          orderoperation,                    "key
          glaccount,                         "key
          curplanprojslsordvalnstrategy,     "key
          companycode,
          producedproduct,
          planqtyincostsourceunit,
          actualqtyincostsourceunit
        FROM i_mfgorderactlplantgtldgrcost(
                   p_fromfiscalyearperiod    = @lv_period,
                   p_tofiscalyearperiod      = @lv_period,
                   p_ledger                  = '0L',
                   p_currencyrole            = '10',
                   p_targetcostvariant       = '000' )
        WITH PRIVILEGED ACCESS
        WHERE plant IN @lr_plant
        AND companycode IN @lr_companycode
        INTO TABLE @lt_mfgorderactlplantgtldgrcost.

        ls_mfgorderactlplantgtldgrcost-yearperiod = lv_period.
        MODIFY lt_mfgorderactlplantgtldgrcost FROM ls_mfgorderactlplantgtldgrcost
        TRANSPORTING yearperiod WHERE orderid IS NOT INITIAL.

        APPEND LINES OF lt_mfgorderactlplantgtldgrcost TO lt_data.
        CLEAR lt_mfgorderactlplantgtldgrcost.

      ENDIF.

      IF lt_data IS NOT INITIAL.

        "matnr 范围
        DATA(lt_matnr) = lt_data.
        SORT lt_matnr BY producedproduct.
        DELETE ADJACENT DUPLICATES FROM lt_matnr COMPARING producedproduct.


        "成品信息
        SELECT
         a~product
         FROM i_product WITH PRIVILEGED ACCESS AS a
         JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b
         ON a~product = b~product
         FOR ALL ENTRIES IN @lt_matnr
         WHERE a~product =  @lt_matnr-producedproduct
         "AND plant IN @lr_plant
         AND producttype = 'ZFRT'
         INTO TABLE @DATA(lt_productplant).
        SORT lt_productplant BY product.
        DELETE ADJACENT DUPLICATES FROM lt_productplant COMPARING product.

        "order 范围
        DATA(lt_order) = lt_data.
        SORT lt_order BY orderid.
        DELETE ADJACENT DUPLICATES FROM lt_order COMPARING orderid.

        "从BOM list中提取产品的半成品信息
*        SELECT
*          assembly, "上层
*          material "下层
*        FROM i_mfgorderoperationcomponent
*        WITH PRIVILEGED ACCESS
*         FOR ALL ENTRIES IN @lt_order
*        WHERE manufacturingorder = @lt_order-orderid
*        AND plant IN @lr_plant
*        AND companycode IN @lr_companycode
*        AND materialisdirectlyproduced = 'X'
*         INTO TABLE @lt_component.
*        SORT lt_component BY material.


        DATA:lv_isassembly TYPE c VALUE 'X'.

        "从会计科目表明细中提取主要材料和辅助材料的帐户和金额合计
        lv_path = |/API_BILL_OF_MATERIAL_SRV;v=0002/MaterialBOMItem?$filter=IsAssembly%20eq%20'{ lv_isassembly }'|.
        "Call API
        zzcl_common_utils=>request_api_v2(
          EXPORTING
           iv_path        = lv_path
            iv_method      = if_web_http_client=>get
            iv_format      = 'json'
            iv_select = 'BillOfMaterialComponent,Material'
          IMPORTING
            ev_status_code = DATA(lv_stat_code3)
            ev_response    = DATA(lv_resbody_api3) ).
        TRY.
            "JSON->ABAP
            "  xco_cp_json=>data->from_string( lv_resbody_api3 )->apply( VALUE #(
            "      ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api3 ) ).
            /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api3
               CHANGING  data = ls_res_api3 ).
            LOOP AT ls_res_api3-d-results INTO DATA(ls_result3).

              "IF  ls_result3-plant IN lr_plant.
              CLEAR ls_component.
              "ls_component-assembly = ls_result3-billofmaterialcomponent.
              "ls_component-material = ls_result3-material.
              ls_component-assembly = ls_result3-material.
              ls_component-material = ls_result3-billofmaterialcomponent.
              APPEND ls_component TO lt_component.

              " ENDIF.
            ENDLOOP.
            SORT lt_component BY material assembly.
            DELETE ADJACENT DUPLICATES FROM lt_component COMPARING material assembly.

          CATCH cx_root INTO DATA(lx_root3) ##NO_HANDLER.
        ENDTRY.


        DATA:lv_next TYPE i_mfgorderactlplantgtldgrcost-producedproduct.

        LOOP AT lt_component INTO ls_component.
          DO 20 TIMES.
            IF lv_next IS INITIAL.
              lv_next = ls_component-assembly.
            ENDIF.
            READ TABLE lt_productplant INTO DATA(ls_productplant) WITH KEY product = lv_next BINARY SEARCH.
            IF sy-subrc = 0.
              "当前就是顶层物料
              ls_component-zfrtproduct = lv_next.
              MODIFY lt_component FROM ls_component TRANSPORTING zfrtproduct.
              CLEAR lv_next.
              EXIT.
            ELSE.
              "不是顶层物料继续向下找
              READ TABLE lt_component INTO DATA(ls_component_next) WITH KEY material = lv_next BINARY SEARCH.
              IF sy-subrc = 0.
                lv_next = ls_component_next-assembly.
              ENDIF.
            ENDIF.
          ENDDO.
          CLEAR lv_next.
        ENDLOOP.

        "抽取当月完成品工单的实际入库数量（ 此时包含半成品 ）
        IF lt_order IS NOT INITIAL.
          SELECT
            manufacturingorder,
            product,
            mfgorderconfirmedyieldqty,
            productionunit,
            productionsupervisor
          FROM i_manufacturingorder
          WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_order
          WHERE manufacturingorder = @lt_order-orderid
          "AND productionplant IN @lr_plant
          AND companycode IN @lr_companycode
           INTO TABLE @DATA(lt_manufacturingorder).
          SORT lt_manufacturingorder BY manufacturingorder.
          LOOP AT lt_manufacturingorder INTO DATA(ls_manufacturingorder).
            "READ TABLE lt_productplant TRANSPORTING NO FIELDS WITH KEY product = ls_manufacturingorder-product BINARY SEARCH.
            "IF sy-subrc = 0.
            CLEAR ls_sum_qty.
            ls_sum_qty-product = ls_manufacturingorder-product.
            ls_sum_qty-mfgorderconfirmedyieldqty = ls_manufacturingorder-mfgorderconfirmedyieldqty.
            ls_sum_qty-productionsupervisor = ls_manufacturingorder-productionsupervisor.
            COLLECT ls_sum_qty INTO lt_sum_qty.
            "ENDIF.
          ENDLOOP.
          SORT lt_sum_qty BY product.
        ENDIF.
        "提取月末时的实际工资率和计划工资率
        lv_path = |/api_cost_rate/srvd_a2x/sap/costrate/0001/ActualCostRate?$filter=ValidityStartFiscalYear%20eq%20'{ lv_calendaryear }'%20and%20ValidityStartFiscalPeriod%20eq%20'{ lv_calendarmonth_s }'&$top=1000|.
        "Call API
        zzcl_common_utils=>request_api_v4(
          EXPORTING
            iv_path        = lv_path
            iv_method      = if_web_http_client=>get
          IMPORTING
            ev_status_code = DATA(lv_stat_code)
            ev_response    = DATA(lv_resbody_api) ).
        TRY.
            "JSON->ABAP
            "xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
            "   ( xco_cp_json=>transformation->boolean_to_abap_bool ) ) )->write_to( REF #( ls_res_api ) ).
            /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api
                               CHANGING  data = ls_res_api ).

          CATCH cx_root INTO DATA(lx_root1) ##NO_HANDLER.
        ENDTRY.

        lv_path = |/api_cost_rate/srvd_a2x/sap/costrate/0001/PlanCostRate?$filter=ValidityStartFiscalYear%20eq%20'{ lv_calendaryear }'%20and%20ValidityStartFiscalPeriod%20eq%20'{ lv_calendarmonth_s }'&$top=1000|.
        "Call API
        zzcl_common_utils=>request_api_v4(
          EXPORTING
            iv_path        = lv_path
            iv_method      = if_web_http_client=>get
            iv_format      = 'json'
          IMPORTING
            ev_status_code = DATA(lv_stat_code1)
            ev_response    = DATA(lv_resbody_api1) ).
        TRY.
            "JSON->ABAP
            "xco_cp_json=>data->from_string( lv_resbody_api1 )->apply( VALUE #(
            "   ( xco_cp_json=>transformation->boolean_to_abap_bool ) ) )->write_to( REF #( ls_res_api1 ) ).
            /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api1
                     CHANGING  data = ls_res_api1 ).

          CATCH cx_root INTO DATA(lx_root2) ##NO_HANDLER.
        ENDTRY.

*        LOOP AT ls_res_api-value INTO DATA(ls_data1).
*
*          lv_calendarmonth_s =  |{ ls_data1-validitystartfiscalperiod ALPHA = OUT }|.
*          CONDENSE lv_calendarmonth_s.
*          IF lv_calendarmonth_s < 10.
*            lv_calendarmonth_s = '0' && lv_calendarmonth_s.
*          ENDIF.
*          lv_date_s = ls_data1-validitystartfiscalyear && lv_calendarmonth_s && '01'.
*
*          lv_calendarmonth_s =  |{ ls_data1-validityendfiscalperiod  ALPHA = OUT }|.
*          CONDENSE lv_calendarmonth_s.
*          IF lv_calendarmonth_s < 10.
*            lv_calendarmonth_s = '0' && lv_calendarmonth_s.
*          ENDIF.
*          lv_date_e = ls_data1-validityendfiscalyear && lv_calendarmonth_s && '31'.
*
*
*          IF lv_date_s <=  lv_date_f
*          AND lv_date_f <=  lv_date_e.
*          ELSE.
*
*            DELETE ls_res_api-value.
*
*          ENDIF.
*
*        ENDLOOP.
*
*        LOOP AT ls_res_api1-value INTO DATA(ls_data2).
*
*          lv_calendarmonth_s =  |{ ls_data2-validitystartfiscalperiod ALPHA = OUT }|.
*          CONDENSE lv_calendarmonth_s.
*          IF lv_calendarmonth_s < 10.
*            lv_calendarmonth_s = '0' && lv_calendarmonth_s.
*          ENDIF.
*          lv_date_s = ls_data2-validitystartfiscalyear && lv_calendarmonth_s && '01'.
*
*          lv_calendarmonth_s =  |{ ls_data2-validityendfiscalperiod  ALPHA = OUT }|.
*          CONDENSE lv_calendarmonth_s.
*          IF lv_calendarmonth_s < 10.
*            lv_calendarmonth_s = '0' && lv_calendarmonth_s.
*          ENDIF.
*          lv_date_e = ls_data2-validityendfiscalyear && lv_calendarmonth_s && '31'.
*
*
*          IF lv_date_s <=  lv_date_f
*          AND lv_date_f <=  lv_date_e.
*          ELSE.
*
*            DELETE ls_res_api1-value.
*
*          ENDIF.
*
*        ENDLOOP.

        "CostCenter 范围
        DATA(lt_costc) = lt_data.
        SORT lt_costc BY partnercostcenter.
        DELETE ADJACENT DUPLICATES FROM lt_costc COMPARING partnercostcenter.
        IF lt_costc IS NOT INITIAL.
          "提取成本中心工序信息 提取成本中心文本
          SELECT
          a~costcenter,
          department,
          costcenterdescription
          FROM
          i_costcenter WITH PRIVILEGED ACCESS AS a
          JOIN i_costcentertext WITH PRIVILEGED ACCESS AS b
          ON a~costcenter = b~costcenter
          FOR ALL ENTRIES IN @lt_costc
          WHERE a~costcenter = @lt_costc-partnercostcenter
          AND b~language = 'J'
          "and ControllingArea = ???
          "and ValidityEndDate = ???
          INTO TABLE @DATA(lt_costcenter).
          SORT lt_costcenter BY costcenter.
        ENDIF.
        "提取活动类型文本
        SELECT
        costctractivitytype,
        costctractivitytypename
        FROM
        i_costcenteractivitytypetext
        WITH PRIVILEGED ACCESS
        WHERE language = 'J'
        "and ControllingArea = ???
        "and ValidityEndDate = ???
        INTO TABLE @DATA(lt_costcenteractivitytypetext).
        SORT lt_costcenteractivitytypetext BY costctractivitytype.
        IF lt_productplant IS NOT INITIAL.
          "品目マスタから品目テキストを抽出
          SELECT
          product,
          productdescription
          FROM
          i_productdescription
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_productplant
          WHERE product = @lt_productplant-product
          AND language  = 'J'
          INTO TABLE @DATA(lt_productdescription).
          SORT lt_productdescription BY product.
        ENDIF.
        IF lt_productplant IS NOT INITIAL.
*          "品目マスタからMRP管理者を抽出
*          SELECT
*          product,
*          plant,
*          mrpresponsible
*          FROM i_productplantmrp
*          WITH PRIVILEGED ACCESS
*          FOR ALL ENTRIES IN @lt_productplant
*          WHERE product = @lt_productplant-product
*          "and MRPArea = ???
*          INTO TABLE @DATA(lt_productplantmrp).
*          SORT lt_productplantmrp BY product plant.

          "品目マスタからMRP管理者を抽出
          SELECT
          product,
          plant,
          mrpresponsible
          FROM i_productplantbasic
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_productplant
          WHERE product = @lt_productplant-product
          "and MRPArea = ???
          INTO TABLE @DATA(lt_productplantmrp).
          SORT lt_productplantmrp BY product plant.

        ENDIF.
        "BPマスタから得意先のBPコードとBPテキストを抽出
        SELECT
        businesspartner,
        businesspartnername,
        searchterm2
        FROM i_businesspartner
        WITH PRIVILEGED ACCESS
        WHERE searchterm2 IS NOT INITIAL
        INTO TABLE @DATA(lt_businesspartner).
        SORT lt_businesspartner BY searchterm2.
        IF lt_productplant IS NOT INITIAL.
          "品目マスタから製品が属される利益センタを抽出
*          SELECT
*          plant,
*          product,
*          profitcenter
*          FROM i_profitcentertoproduct
*          WITH PRIVILEGED ACCESS
*          FOR ALL ENTRIES IN @lt_productplant
*          WHERE product = @lt_productplant-product
*          "AND ValidityStartDate  = ????
*          INTO TABLE @DATA(lt_profitcentertoproduct).
*          SORT lt_profitcentertoproduct BY plant product.

          "品目マスタから製品が属される利益センタを抽出
          SELECT
          plant,
          product,
          profitcenter
          FROM i_productplantbasic
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_productplant
          WHERE product = @lt_productplant-product
          "AND ValidityStartDate  = ????
          INTO TABLE @DATA(lt_profitcentertoproduct).
          SORT lt_profitcentertoproduct BY plant product.

        ENDIF.
        IF lt_profitcentertoproduct IS NOT INITIAL.
          "品目マスタから製品が属される利益センタを抽出
          SELECT
          profitcenter,
          profitcentername AS profitcenterlongname
          FROM i_profitcentertext
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_profitcentertoproduct
          WHERE profitcenter = @lt_profitcentertoproduct-profitcenter
          AND language = 'J'
          "AND ControllingArea  = ????
          "AND ValidityEndDate  = ????
          INTO TABLE @DATA(lt_profitcentertext).
          SORT lt_profitcentertext BY profitcenter.
        ENDIF.
        IF lt_data IS NOT INITIAL.
          SELECT companycode, companycodename
          FROM i_companycode
          WITH PRIVILEGED ACCESS
          WHERE language = 'J'
          INTO TABLE @DATA(lt_companycode).
          SORT lt_companycode BY companycode.

          SELECT plant, plantname
           FROM i_plant
           WITH PRIVILEGED ACCESS
           WHERE language = 'J'
           INTO TABLE @DATA(lt_plant).
          SORT lt_plant BY plant.
        ENDIF.

        LOOP AT lt_data INTO DATA(ls_data).

          CLEAR ls_mfgorder_001.

          "'年月' YearMonth
          "'会社コード' Companycode
          "'プラント' Plant
          "'製品' Product
          "'得意先' BusinessPartner
          "'利益センタ' ProfitCenter
          "'原価センタ' CostCenter
          "'活動タイプ' ActivityType
          "'会社コードテキスト' CompanycodeText
          "'プラントテキスト' PlantText
          "'製品テキスト' ProductDescription
          "'入庫数量' MfgOrderConfirmedYieldQty
          "'得意先テキスト' BusinessPartnerName
          "'利益センタテキスト' ProfitCenterLongName
          "'原価センタテキスト' CostCenterDescription
          "'活動タイプテキスト' CostCtrActivityTypeName
          "'部署（工程）' Department
          "'計画工数' PlanQtyInCostSourceUnit
          "'実績工数' ActualQtyInCostSourceUnit
          "'工数単位' UnitOfMeasure
          "'計画賃率' PlanCostRate
          "'実際賃率' ActualCostRate
          "'加工費実績合計' TotalActualCost
          "'加工費実績（1単位）' ActualCost1PC
          ls_mfgorder_001-calendaryear = |{ lv_calendaryear ALPHA = IN }|."'年月'
          ls_mfgorder_001-calendarmonth = |{ lv_calendarmonth ALPHA = IN }|."'年月'
          ls_mfgorder_001-yearmonth = ls_data-yearperiod."'年月'
          ls_mfgorder_001-companycode = ls_data-companycode."'会社コード'
          ls_mfgorder_001-plant = ls_data-plant."'プラント'
          ls_mfgorder_001-costcenter = ls_data-partnercostcenter. "'原価センタ'
          ls_mfgorder_001-activitytype = ls_data-partnercostctractivitytype."'活動タイプ'
          ls_mfgorder_001-planqtyincostsourceunit   = ls_data-planqtyincostsourceunit. "'計画工数'
          ls_mfgorder_001-actualqtyincostsourceunit = ls_data-actualqtyincostsourceunit."'実績工数'
          "ls_mfgorder_001-unitofmeasure             = ls_data-unitofmeasure."'工数単位'

          "'製品'
          READ TABLE lt_productplant INTO ls_productplant WITH KEY product = ls_data-producedproduct BINARY SEARCH.
          IF sy-subrc = 0.
            "当前就是顶层物料
            ls_mfgorder_001-product = ls_data-producedproduct."'製品'
          ELSE.
            "不是顶层物料找关系
            READ TABLE lt_component INTO ls_component_next WITH KEY material = ls_data-producedproduct BINARY SEARCH.
            IF sy-subrc = 0.
              ls_mfgorder_001-product = ls_component_next-zfrtproduct."'製品'
            ENDIF.
          ENDIF.

          "'得意先' "'得意先テキスト'
          READ TABLE lt_productplantmrp INTO DATA(ls_productplantmrp) WITH KEY product = ls_mfgorder_001-product plant = ls_data-plant BINARY SEARCH.
          IF sy-subrc = 0.
            DATA:lv_str2(2) TYPE c.
            DATA:lv_i TYPE i.
            CLEAR lv_str2.
            lv_i = strlen( ls_productplantmrp-mrpresponsible ).
            lv_i = lv_i - 2.
            IF lv_i >= 0.
              lv_str2 = ls_productplantmrp-mrpresponsible+lv_i(2).
              READ TABLE lt_businesspartner INTO DATA(ls_businesspartner) WITH KEY searchterm2 = lv_str2 BINARY SEARCH.
              IF sy-subrc = 0.

                "'得意先'
                ls_mfgorder_001-businesspartner = ls_businesspartner-businesspartner.
                "'得意先テキスト'
                ls_mfgorder_001-businesspartnername = ls_businesspartner-businesspartnername.
              ENDIF.
            ENDIF.
          ENDIF.

          "'利益センタ'
          READ TABLE lt_profitcentertoproduct INTO DATA(ls_profitcentertoproduct) WITH KEY plant = ls_data-plant product = ls_mfgorder_001-product BINARY SEARCH.
          IF sy-subrc = 0.
            ls_mfgorder_001-profitcenter = ls_profitcentertoproduct-profitcenter."'利益センタ'
            "'利益センタテキスト'
            READ TABLE lt_profitcentertext INTO DATA(ls_profitcentertext) WITH KEY profitcenter = ls_profitcentertoproduct-profitcenter BINARY SEARCH.
            IF sy-subrc = 0.
              ls_mfgorder_001-profitcenterlongname = ls_profitcentertext-profitcenterlongname."'利益センタテキスト'
            ENDIF.
          ENDIF.
          "'会社コードテキスト'
          READ TABLE lt_companycode INTO DATA(ls_companycode) WITH KEY companycode = ls_data-companycode BINARY SEARCH.
          IF sy-subrc = 0.
            ls_mfgorder_001-companycodetext = ls_companycode-companycodename."'会社コードテキスト'
          ENDIF.
          "'プラントテキスト'
          READ TABLE lt_plant INTO DATA(ls_plant) WITH KEY plant = ls_data-plant BINARY SEARCH.
          IF sy-subrc = 0.
            ls_mfgorder_001-planttext = ls_plant-plantname."'プラントテキスト'
          ENDIF.
          "'製品テキスト'
          READ TABLE lt_productdescription INTO DATA(ls_productdescription) WITH KEY product = ls_mfgorder_001-product BINARY SEARCH.
          IF sy-subrc = 0.
            ls_mfgorder_001-productdescription = ls_productdescription-productdescription."'製品テキスト'
          ENDIF.

          "'製品テキスト'
          "用的是制品物料
*          READ TABLE lt_sum_qty INTO ls_sum_qty WITH KEY product = ls_mfgorder_001-product BINARY SEARCH.
*          IF sy-subrc = 0.
*            ls_mfgorder_001-mfgorderconfirmedyieldqty = ls_sum_qty-mfgorderconfirmedyieldqty."'製品テキスト'
*            ls_mfgorder_001-productionsupervisor = ls_sum_qty-productionsupervisor."'製品テキスト'
*          ENDIF.
          " READ TABLE lt_productplant TRANSPORTING NO FIELDS WITH KEY product = ls_data-producedproduct BINARY SEARCH.
          " IF sy-subrc = 0.
          READ TABLE lt_manufacturingorder INTO DATA(ls_manufacturingorder1) WITH KEY manufacturingorder =  ls_data-orderid BINARY SEARCH.
          IF sy-subrc = 0.
            ls_mfgorder_001-mfgorderconfirmedyieldqty = ls_manufacturingorder1-mfgorderconfirmedyieldqty."'製品テキスト'
            ls_mfgorder_001-productionsupervisor = ls_manufacturingorder1-productionsupervisor."'製品テキスト'
            ls_mfgorder_001-productionunit = ls_manufacturingorder1-productionunit.

          ENDIF.
          "ELSE.
          "ls_mfgorder_001-mfgorderconfirmedyieldqty = lv_zero.
          " ENDIF.
          "'原価センタテキスト' "'部署（工程）'
          READ TABLE lt_costcenter INTO DATA(ls_costcenter) WITH KEY costcenter = ls_data-partnercostcenter BINARY SEARCH.
          IF sy-subrc = 0.
            ls_mfgorder_001-costcenterdescription = ls_costcenter-costcenterdescription."'原価センタテキスト'
            ls_mfgorder_001-department            = ls_costcenter-department."'部署（工程）'
          ENDIF.
          "'活動タイプテキスト'
          READ TABLE lt_costcenteractivitytypetext INTO DATA(ls_costcenteractivitytypetext) WITH KEY costctractivitytype = ls_data-partnercostctractivitytype BINARY SEARCH.
          IF sy-subrc = 0.
            ls_mfgorder_001-costctractivitytypename = ls_costcenteractivitytypetext-costctractivitytypename."'活動タイプテキスト'
          ENDIF.


          "'実際賃率'
          READ TABLE ls_res_api-value INTO DATA(ls_actualcostrate) WITH KEY companycode = ls_data-companycode
                                                                            costcenter  = ls_data-partnercostcenter
                                                                            activitytype = ls_data-partnercostctractivitytype.
          "??controllingarea
          "?? validitystartfiscalyear
          "??validitystartfiscalperiod
          "??validityendfiscalyear
          "??validityendfiscalperiod
          IF sy-subrc = 0.
            "ls_mfgorder_001-actualcostrate = ls_actualcostrate-costratefixedamount. "'実際賃率'
            IF ls_actualcostrate-costratescalefactor IS NOT INITIAL.
              " ls_mfgorder_001-actualcostrate = ls_actualcostrate-costratefixedamount / ls_actualcostrate-costratescalefactor  ."'実際賃率'
              " ls_mfgorder_001-actualcostrate = ls_actualcostrate-costratefixedamount    ."'実際賃率'

              ls_mfgorder_001-costratescalefactor2 = ls_actualcostrate-costratescalefactor.
              ls_mfgorder_001-currency2 = ls_actualcostrate-currency.
            ENDIF.
            "ls_mfgorder_001-actualcostrate = lv_curr.

            IF ls_actualcostrate-costratescalefactor IS NOT INITIAL.
              ls_mfgorder_001-totalactualcost  = ls_actualcostrate-costratefixedamount * ls_data-actualqtyincostsourceunit / ls_actualcostrate-costratescalefactor. "'加工費実績合計'
              "ls_mfgorder_001-totalactualcost  = ls_actualcostrate-costratefixedamount * ls_data-actualqtyincostsourceunit. "'加工費実績合計'
            ENDIF.


            READ TABLE lt_sum_qty INTO DATA(ls_sum_qty1) WITH KEY product = ls_mfgorder_001-product BINARY SEARCH.
            IF sy-subrc = 0 AND ls_sum_qty1-mfgorderconfirmedyieldqty IS NOT INITIAL AND ls_actualcostrate-costratescalefactor IS NOT INITIAL.
              ls_mfgorder_001-actualcost1pc  = ls_actualcostrate-costratefixedamount * ls_data-actualqtyincostsourceunit / ls_sum_qty1-mfgorderconfirmedyieldqty / ls_actualcostrate-costratescalefactor. "'加工費実績（1単位）'
              "ls_mfgorder_001-actualcost1pc  = ls_actualcostrate-costratefixedamount * ls_data-actualqtyincostsourceunit / ls_sum_qty1-mfgorderconfirmedyieldqty. "'加工費実績（1単位）'
            ENDIF.

          ENDIF.


          "'計画賃率'
          READ TABLE ls_res_api1-value INTO DATA(ls_plancostrate) WITH KEY companycode = ls_data-companycode
                                                                            costcenter  = ls_data-partnercostcenter
                                                                            activitytype = ls_data-partnercostctractivitytype.
          "??controllingarea
          "?? validitystartfiscalyear
          "??validitystartfiscalperiod
          "??validityendfiscalyear
          "??validityendfiscalperiod
          IF sy-subrc = 0.
            IF ls_plancostrate-costratescalefactor IS NOT INITIAL.
              ls_mfgorder_001-plancostrate = ls_plancostrate-costratevarblamount / ls_plancostrate-costratescalefactor. "'計画賃率'
              ls_mfgorder_001-currency1  = ls_plancostrate-currency.
              ls_mfgorder_001-costratescalefactor1 = ls_plancostrate-costratescalefactor.
            ENDIF.
          ENDIF.
          ls_mfgorder_001-product = zzcl_common_utils=>conversion_matn1(
                             EXPORTING iv_alpha = 'OUT'
                                       iv_input = ls_mfgorder_001-product ).
          ls_mfgorder_001-producedproduct = zzcl_common_utils=>conversion_matn1(
                             EXPORTING iv_alpha = 'OUT'
                             iv_input = ls_data-producedproduct ).
          " TRY.
          "     ls_mfgorder_001-unitofmeasure             = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
          "                                                                                         iv_input = ls_data-unitofmeasure ).
          "
          "     CATCH zzcx_custom_exception INTO DATA(lo_root_exc).
          ls_mfgorder_001-unitofmeasure             = ls_data-unitofmeasure."'工数単位'
          "   ENDTRY.
          ls_mfgorder_001-businesspartner  = |{ ls_mfgorder_001-businesspartner  ALPHA = OUT }|.
          ls_mfgorder_001-orderid = |{ ls_data-orderid ALPHA = OUT }|.
          IF ls_mfgorder_001-product IS NOT INITIAL AND ls_mfgorder_001-costcenter IS NOT INITIAL.
            APPEND ls_mfgorder_001 TO lt_mfgorder_001.
          ENDIF.
        ENDLOOP.
      ENDIF.

      " Filtering
*      zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
*                                    CHANGING  ct_data   = lt_mfgorder_001 ).
*      IF io_request->is_total_numb_of_rec_requested(  ) .
*        io_response->set_total_number_of_records( lines( lt_mfgorder_001 ) ).
*      ENDIF.
*
*      "Sort
*      zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
*                                 CHANGING  ct_data  = lt_mfgorder_001 ).
*
*      " Paging
*      zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
*                               CHANGING  ct_data   = lt_mfgorder_001 ).
*
*
*
*      io_response->set_data( lt_mfgorder_001 ).




     SORT lt_mfgorder_001 by YearMonth companycode plant product  BusinessPartner ProfitCenter CostCenter  orderid ActivityType .


     SORT lt_mfgorder_001 by orderid  YearMonth Companycode Plant Product producedproduct BusinessPartner ProfitCenter CostCenter ActivityType   .

     LOOP AT lt_mfgorder_001 INTO data(ls_sef).
      if sy-tabix  > 10 .

      DELETE lt_mfgorder_001.
      endif.
     ENDLOOP.

      "排序
      zzcl_odata_utils=>orderby(
                          EXPORTING
                            it_order = io_request->get_sort_elements( )
                          CHANGING
                            ct_data = lt_mfgorder_001 ).

      "过滤
      zzcl_odata_utils=>filtering(
                          EXPORTING
                            io_filter = io_request->get_filter( )
                            it_excluded = VALUE #( ( fieldname = 'CALENDARMONTH' ) )
                          CHANGING
                            ct_data = lt_mfgorder_001 ).

      IF io_request->is_total_numb_of_rec_requested( ).
        io_response->set_total_number_of_records( lines( lt_mfgorder_001 ) ).
      ENDIF.
      IF io_request->is_data_requested( ).
        zzcl_odata_utils=>paging(
          EXPORTING
            io_paging = io_request->get_paging( )
          CHANGING
            ct_data = lt_mfgorder_001
        ).
        io_response->set_data( lt_mfgorder_001 ).
      ENDIF.

    ELSE.

      IF io_request->is_total_numb_of_rec_requested(  ) .
         io_response->set_total_number_of_records( 1 ).
       ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
