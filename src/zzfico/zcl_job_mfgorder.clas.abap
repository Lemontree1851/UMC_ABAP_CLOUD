CLASS zcl_job_mfgorder DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
*****************************************************************
*       Type Table 1
*****************************************************************
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
    DATA:lv_table TYPE string.
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
    DATA:
      lt_mfgorder_001     TYPE STANDARD TABLE OF zc_mfgorder_001,
      lt_mfgorder_001_out TYPE STANDARD TABLE OF zc_mfgorder_001,
      ls_mfgorder_001     TYPE zc_mfgorder_001.
    DATA:lv_path     TYPE string.
    DATA:ls_res_api  TYPE ty_res_api.
    DATA:ls_res_api1 TYPE ty_res_api1.
    DATA:lc_alpha_out     TYPE string        VALUE 'OUT'.
    DATA lv_msg TYPE cl_bali_free_text_setter=>ty_text .
*****************************************************************
*       Type Table 2
*****************************************************************

    DATA:
      lt_mfgorder_002     TYPE STANDARD TABLE OF zc_mfgorder_002,
      lt_mfgorder_002_out TYPE STANDARD TABLE OF zc_mfgorder_002,
      ls_mfgorder_002     TYPE zc_mfgorder_002.
    TYPES:
      BEGIN OF ty_results_2,
        currencypair                TYPE string,
        calendardate                TYPE timestamp,
        calendardate_d              TYPE sy-datum,
        exchangeratetype            TYPE string,

        sourcecurrency              TYPE string,

        targetcurrency              TYPE string,
        exchangerate                TYPE string,
        numberofsourcecurrencyunits TYPE string,
        numberoftargetcurrencyunits TYPE string,

      END OF ty_results_2,
      tt_results_2 TYPE STANDARD TABLE OF ty_results_2 WITH DEFAULT KEY,
      BEGIN OF ty_d_2,
        results TYPE tt_results_2,
      END OF ty_d_2,
      BEGIN OF ty_res_api_2,
        d TYPE ty_d_2,
      END OF ty_res_api_2.

    DATA:ls_res_api_2  TYPE ty_res_api_2.
*****************************************************************
*       Type Table 3
*****************************************************************

    DATA:lv_glaccount1(10) TYPE c,
         lv_glaccount2(10) TYPE c.
    DATA:
      lt_mfgorder_003     TYPE STANDARD TABLE OF zc_mfgorder_003,
      lt_mfgorder_003_out TYPE STANDARD TABLE OF zc_mfgorder_003,
      ls_mfgorder_003     TYPE zc_mfgorder_003.




    METHODS:
      save_table_01,
      save_table_02,
      save_table_03.
    CLASS-METHODS:
      init_application_log,

      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime.
    CLASS-DATA:
      mo_application_log TYPE REF TO if_bali_log.
ENDCLASS.



CLASS zcl_job_mfgorder IMPLEMENTATION.



  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
                                ( selname        = 'P_COMPANYCODE'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = '会社コード'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_false )
                                  ( selname        = 'P_PLANT'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = 'プラント'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_false )
                                  ( selname        = 'P_YEAR'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = '会計年度'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true )
                                  ( selname        = 'P_MONTH'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'char'
                                  length         = 2
                                  param_text     = '会計期間'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true )
                                  ( selname        = 'P_TABLE'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'char'
                                  length         = 2
                                  param_text     = 'テーブル名（1または2または3）'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_false ) ).

    " Return the default parameters values here
    " et_parameter_val
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    DATA lv_msg TYPE cl_bali_free_text_setter=>ty_text .
    " 获取日志对象
    init_application_log( ).
*****************************************************************
*       Filter
*****************************************************************
    LOOP AT it_parameters INTO DATA(ls_parameters).
*     Parameterの会社コード
      IF ls_parameters-selname = 'P_COMPAN'.
        IF ls_parameters-low IS NOT INITIAL.
          MOVE-CORRESPONDING ls_parameters TO lrs_companycode.
          INSERT lrs_companycode INTO TABLE lr_companycode.
        ENDIF.
      ENDIF.

*     Parameterのプラント
      IF ls_parameters-selname = 'P_PLANT'.
        IF ls_parameters-low IS NOT INITIAL.
          MOVE-CORRESPONDING ls_parameters TO  lrs_plant.
          INSERT lrs_plant INTO TABLE lr_plant.
        ENDIF.
      ENDIF.
*     Parameterのプラント
      IF ls_parameters-selname = 'P_YEAR'.
        lv_calendaryear = ls_parameters-low.
      ENDIF.
*     Parameterのプラント
      IF ls_parameters-selname = 'P_MONTH'.
        lv_calendarmonth = ls_parameters-low.
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
      IF ls_parameters-selname = 'P_TABLE'.
        lv_table = ls_parameters-low.
        CONDENSE lv_table .
      ENDIF.
    ENDLOOP.


*****************************************************************
*       Get Data table 1
*****************************************************************
    IF lv_table IS INITIAL OR lv_table = '1'.
      save_table_01( ).
    ENDIF.
*****************************************************************
*       Get Data table 2
*****************************************************************
    IF lv_table IS INITIAL OR lv_table = '2'.
      save_table_02( ).
    ENDIF.
*****************************************************************
*       Get Data table 3
*****************************************************************
    IF lv_table IS INITIAL OR lv_table = '3'.
      save_table_03( ).
    ENDIF.


    if lv_table is NOT INITIAL AND lv_table ne '1' AND lv_table ne '2' AND lv_table ne '3'.
          lv_msg = '表名' && lv_table && '不存在' .
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'E' ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ENDIF.
  ENDMETHOD.
  METHOD save_table_01.
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
       AND plant IN @lr_plant
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
      lv_path = |/API_BILL_OF_MATERIAL_SRV;v=0002/MaterialBOMItem?$filter=IsAssembly%20eq%20'{ lv_isassembly }'%20|.
      "Call API
      zzcl_common_utils=>request_api_v2(
        EXPORTING
         iv_path        = lv_path
          iv_method      = if_web_http_client=>get
          iv_format      = 'json'
        IMPORTING
          ev_status_code = DATA(lv_stat_code3)
          ev_response    = DATA(lv_resbody_api3) ).
      TRY.
          "JSON->ABAP
          xco_cp_json=>data->from_string( lv_resbody_api3 )->apply( VALUE #(
              ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api3 ) ).
          LOOP AT ls_res_api3-d-results INTO DATA(ls_result3).

            IF  ls_result3-plant IN lr_plant.
              CLEAR ls_component.
              "ls_component-assembly = ls_result3-billofmaterialcomponent.
              "ls_component-material = ls_result3-material.
              ls_component-assembly = ls_result3-material.
              ls_component-material = ls_result3-billofmaterialcomponent.
              APPEND ls_component TO lt_component.

            ENDIF.
          ENDLOOP.
          SORT lt_component BY material assembly.
          DELETE ADJACENT DUPLICATES FROM lt_component COMPARING material assembly.

        CATCH cx_root INTO DATA(lx_root3).
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
        AND productionplant IN @lr_plant
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

        CATCH cx_root INTO DATA(lx_root1).
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

        CATCH cx_root INTO DATA(lx_root2).
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
          "IF ls_actualcostrate-costratescalefactor IS NOT INITIAL.
          "ls_mfgorder_001-actualcostrate = ls_actualcostrate-costratefixedamount / ls_actualcostrate-costratescalefactor ."'実際賃率'
          ls_mfgorder_001-actualcostrate = ls_actualcostrate-costratefixedamount  ."'実際賃率'

          "ls_mfgorder_001-currency2 = ls_actualcostrate-currency.
          ls_mfgorder_001-costratescalefactor2 = ls_actualcostrate-costratescalefactor.
          "ENDIF.
          "ls_mfgorder_001-actualcostrate = lv_curr.

          "IF ls_actualcostrate-costratescalefactor IS NOT INITIAL.
          "ls_mfgorder_001-totalactualcost  = ls_actualcostrate-costratefixedamount * ls_data-actualqtyincostsourceunit / ls_actualcostrate-costratescalefactor. "'加工費実績合計'
          ls_mfgorder_001-totalactualcost  = ls_actualcostrate-costratefixedamount * ls_data-actualqtyincostsourceunit . "'加工費実績合計'

          "ENDIF.


          READ TABLE lt_sum_qty INTO DATA(ls_sum_qty1) WITH KEY product = ls_mfgorder_001-product BINARY SEARCH.
          IF sy-subrc = 0 AND ls_sum_qty1-mfgorderconfirmedyieldqty IS NOT INITIAL AND ls_actualcostrate-costratescalefactor IS NOT INITIAL.
            "ls_mfgorder_001-actualcost1pc  = ls_actualcostrate-costratefixedamount * ls_data-actualqtyincostsourceunit / ls_sum_qty1-mfgorderconfirmedyieldqty / ls_actualcostrate-costratescalefactor. "'加工費実績（1単位）'
            ls_mfgorder_001-actualcost1pc  = ls_actualcostrate-costratefixedamount * ls_data-actualqtyincostsourceunit / ls_sum_qty1-mfgorderconfirmedyieldqty . "'加工費実績（1単位）'
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
          "IF ls_plancostrate-costratescalefactor IS NOT INITIAL.
          "ls_mfgorder_001-plancostrate = ls_plancostrate-costratevarblamount / ls_plancostrate-costratescalefactor. "'計画賃率'
          ls_mfgorder_001-plancostrate = ls_plancostrate-costratevarblamount . "'計画賃率'

          "ls_mfgorder_001-currency1  = ls_plancostrate-currency.
          ls_mfgorder_001-costratescalefactor1 = ls_plancostrate-costratescalefactor.
          "ENDIF.
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
    DATA:lt_ztfi_1020 TYPE STANDARD TABLE OF ztfi_1020 .
    IF lt_mfgorder_001 IS NOT INITIAL.
      lv_calendarmonth = |{ lv_calendarmonth ALPHA = IN }|.
      lv_calendaryear =  |{ lv_calendaryear ALPHA = IN }|.
      DELETE FROM ztfi_1020 WHERE companycode IN @lr_companycode AND plant IN @lr_plant
      AND calendaryear = @lv_calendaryear AND calendarmonth = @lv_calendarmonth.
      MOVE-CORRESPONDING lt_mfgorder_001 TO lt_ztfi_1020.
      MODIFY ztfi_1020 FROM TABLE @lt_ztfi_1020.
      COMMIT WORK.
      lv_msg = 'ztfi_1020保存成功'.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'S' ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ENDIF.
  ENDMETHOD.
  METHOD save_table_02.

    SELECT
  billingdocument,
  billingdocumentitem,
  product ,
  companycode ,
  plant   ,
  soldtoparty ,
  billingquantity ,
  billingquantityunit ,
  netamount   ,
  transactioncurrency,
  billingdocumentdate
  FROM i_billingdocumentitem
  WITH PRIVILEGED ACCESS
  WHERE companycode IN @lr_companycode
        AND plant IN @lr_plant
        AND billingdocumentdate >= @lv_date_f
        AND billingdocumentdate <= @lv_date_t
 INTO TABLE @DATA(lt_billingdocumentitem).

    IF lt_billingdocumentitem IS NOT INITIAL.
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
      "BPマスタから得意先のBPコードとBPテキストを抽出
      SELECT
      businesspartner,
      businesspartnername
      FROM i_businesspartner
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_billingdocumentitem
      WHERE businesspartner = @lt_billingdocumentitem-soldtoparty
      INTO TABLE @DATA(lt_businesspartner).
      SORT lt_businesspartner BY businesspartner.

      "品目マスタから品目テキストを抽出
      SELECT
      product,
      productdescription
      FROM
      i_productdescription
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_billingdocumentitem
      WHERE product = @lt_billingdocumentitem-product
      AND language  = 'J'
      INTO TABLE @DATA(lt_productdescription).
      SORT lt_productdescription BY product.
    ENDIF.

    "  SELECT * FROM i_mktdatafxratecube WHERE targetcurrency = 'JPY' AND exchangeratetype = 'M' AND calendardate >= @lv_date_f
    "  INTO TABLE @DATA(lt_mktdatafxratecube).

    lv_path = |/YY1_MktDataFXRateCube_CDS/YY1_MktDataFXRateCube|.
    "Call API
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>get
        iv_format      = 'json'
      IMPORTING
        ev_status_code = DATA(lv_stat_code_2)
        ev_response    = DATA(lv_resbody_api_2) ).
    "JSON->ABAP
    "  xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
    "      ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api ) ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api_2
                 CHANGING  data = ls_res_api_2 ).

    LOOP AT ls_res_api_2-d-results INTO DATA(ls_result_p).
      "时间戳格式转换成日期格式
      ls_result_p-calendardate_d = CONV string( ls_result_p-calendardate DIV 1000000 ).
      MODIFY ls_res_api_2-d-results  FROM ls_result_p TRANSPORTING calendardate_d .
    ENDLOOP.

    SORT ls_res_api_2-d-results BY sourcecurrency targetcurrency calendardate_d DESCENDING.

    LOOP AT lt_billingdocumentitem INTO DATA(ls_data).
      CLEAR ls_mfgorder_002.

      ls_mfgorder_002-calendaryear = |{ lv_calendaryear ALPHA = IN }|."'年月'
      ls_mfgorder_002-calendarmonth = |{ lv_calendarmonth ALPHA = IN }|."'年月'
      ls_mfgorder_002-yearmonth = lv_calendaryear && '0' && lv_calendarmonth."'年月'
      ls_mfgorder_002-companycode = ls_data-companycode."'会社コード'
      ls_mfgorder_002-plant = ls_data-plant."'プラント'
      ls_mfgorder_002-salesperformanceactualquantity = ls_data-billingquantity.
      ls_mfgorder_002-salesperfactualquantityunit = ls_data-billingquantityunit.
      ls_mfgorder_002-salesperfactlamtindspcurrency = ls_data-netamount.
      ls_mfgorder_002-displaycurrency = ls_data-transactioncurrency.
      IF ls_data-transactioncurrency NE 'JPY'.

        LOOP AT ls_res_api_2-d-results INTO DATA(ls_result) WHERE sourcecurrency = ls_data-transactioncurrency AND targetcurrency = 'JPY'.

          IF ls_result-calendardate_d <= ls_data-billingdocumentdate.
            ls_data-transactioncurrency = 'JPY'.
            ls_mfgorder_002-displaycurrency = 'JPY'.
            ls_mfgorder_002-salesperfactlamtindspcurrency = ls_mfgorder_002-salesperfactlamtindspcurrency * ls_result-exchangerate.
            EXIT.
          ELSE.
            CONTINUE.
          ENDIF.
        ENDLOOP.



      ENDIF.
      "ls_mfgorder_002-salesperfactlamtindspcurrency = zzcl_common_utils=>conversion_amount(
      "                            iv_alpha = 'OUT'
      "                           iv_currency = ls_data-transactioncurrency
      "                            iv_input = ls_mfgorder_002-salesperfactlamtindspcurrency ).

      ls_mfgorder_002-salesperfactualquantityunit = ls_data-billingquantityunit .
      "TRY.
      "    ls_mfgorder_002-salesperfactualquantityunit             = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = 'OUT'
      "                                                                                                   iv_input = ls_data-billingquantityunit ).
      "  CATCH zzcx_custom_exception INTO DATA(lo_root_exc).
      "ENDTRY.

      ls_mfgorder_002-product = ls_data-product.
      ls_mfgorder_002-soldtoparty = ls_data-soldtoparty.
      "'会社コードテキスト'
      READ TABLE lt_companycode INTO DATA(ls_companycode) WITH KEY companycode = ls_data-companycode BINARY SEARCH.
      IF sy-subrc = 0.
        ls_mfgorder_002-companycodetext = ls_companycode-companycodename."'会社コードテキスト'
      ENDIF.
      "'プラントテキスト'
      READ TABLE lt_plant INTO DATA(ls_plant) WITH KEY plant = ls_data-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_mfgorder_002-planttext = ls_plant-plantname."'プラントテキスト'
      ENDIF.
      "'製品テキスト'
      READ TABLE lt_productdescription INTO DATA(ls_productdescription) WITH KEY product = ls_mfgorder_002-product BINARY SEARCH.
      IF sy-subrc = 0.
        ls_mfgorder_002-productdescription = ls_productdescription-productdescription."'製品テキスト'
      ENDIF.
      READ TABLE lt_businesspartner INTO DATA(ls_businesspartner) WITH KEY businesspartner = ls_mfgorder_002-soldtoparty BINARY SEARCH.
      IF sy-subrc = 0.
        ls_mfgorder_002-soldtoparty = |{ ls_mfgorder_002-soldtoparty ALPHA = OUT }|."'年月'
        "'得意先テキスト'
        ls_mfgorder_002-businesspartnername = ls_businesspartner-businesspartnername.
      ENDIF.

      ls_mfgorder_002-product = zzcl_common_utils=>conversion_matn1(
                                   EXPORTING iv_alpha = 'OUT'
                                             iv_input = ls_mfgorder_002-product ).
      ls_mfgorder_002-orderid = ls_data-billingdocument.
      ls_mfgorder_002-orderitem = ls_data-billingdocumentitem.
      APPEND ls_mfgorder_002 TO lt_mfgorder_002.
    ENDLOOP.
    DATA:lt_ztfi_1021 TYPE STANDARD TABLE OF ztfi_1021 .
    IF lt_mfgorder_002 IS NOT INITIAL.
      lv_calendarmonth = |{ lv_calendarmonth ALPHA = IN }|.
      lv_calendaryear =  |{ lv_calendaryear ALPHA = IN }|.
      DELETE FROM ztfi_1021 WHERE companycode IN @lr_companycode AND plant IN @lr_plant
      AND calendaryear = @lv_calendaryear AND calendarmonth = @lv_calendarmonth.
      MOVE-CORRESPONDING lt_mfgorder_002 TO lt_ztfi_1021.
      MODIFY ztfi_1021 FROM TABLE @lt_ztfi_1021.
      COMMIT WORK.
      lv_msg = 'ztfi_1021保存成功'.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'S' ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ENDIF.

  ENDMETHOD.
  METHOD save_table_03.

    lv_glaccount1 = '0050301000'.
    lv_glaccount2 = '0050302000'.

    "从会计科目表明细中提取主要材料和辅助材料的帐户和金额合计
    lv_path = |/API_OPLACCTGDOCITEMCUBE_SRV/A_OperationalAcctgDocItemCube?$filter=FiscalYear%20eq%20'{ lv_calendaryear }'%20and%20(%20GLAccount%20eq%20'{ lv_glaccount1 }'%20or%20GLAccount%20eq%20'{ lv_glaccount2 }'%20)|.


    SELECT
    a~companycode                 ,
    a~plant                       ,
    a~postingdate                 ,
    a~product                     ,
    a~glaccount                   ,
    a~amountincompanycodecurrency ,
    a~companycodecurrency         ,
    a~profitcenter                ,
    a~costcenter                  ,
    a~quantity,

    a~accountingdocument,
    a~ledgergllineitem,
    b~accountingdocumenttype
    FROM  i_journalentryitem WITH PRIVILEGED ACCESS AS a
    JOIN i_journalentry WITH PRIVILEGED ACCESS AS b
    ON a~companycode = b~companycode
    AND a~accountingdocument = b~accountingdocument
    AND a~fiscalyear = b~fiscalyear
    WHERE a~companycode IN @lr_companycode
    AND a~plant IN @lr_plant
    AND a~fiscalyear = @lv_calendaryear
    AND a~fiscalperiod = @lv_calendarmonth
    AND ( a~glaccount = @lv_glaccount1  OR a~glaccount = @lv_glaccount2 )
    AND a~sourceledger = '0L'
    AND a~ledger = '0L'
    INTO TABLE @DATA(lt_operationalacctgdocitem).

    IF lt_operationalacctgdocitem IS NOT INITIAL.

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

      "品目マスタから品目テキストを抽出
      SELECT
      product,
      productdescription
      FROM
      i_productdescription
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_operationalacctgdocitem
      WHERE product = @lt_operationalacctgdocitem-product
      AND language  = 'J'
      INTO TABLE @DATA(lt_productdescription).
      SORT lt_productdescription BY product.

      "品目マスタからMRP管理者を抽出
*        SELECT
*        product,
*        plant,
*        mrpresponsible
*        FROM i_productplantmrp
*        WITH PRIVILEGED ACCESS
*        FOR ALL ENTRIES IN @lt_operationalacctgdocitem
*        WHERE product = @lt_operationalacctgdocitem-product
*        "and MRPArea = ???
*        INTO TABLE @DATA(lt_productplantmrp).
*        SORT lt_productplantmrp BY product plant.

      SELECT
      product,
      plant,
      mrpresponsible
      FROM i_productplantbasic
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_operationalacctgdocitem
      WHERE product = @lt_operationalacctgdocitem-product
      "and MRPArea = ???
      INTO TABLE @DATA(lt_productplantmrp).
      SORT lt_productplantmrp BY product plant.

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

      "品目マスタから製品が属される利益センタを抽出
      SELECT
      profitcenter,
      profitcentername AS profitcenterlongname
      FROM i_profitcentertext
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_operationalacctgdocitem
      WHERE profitcenter = @lt_operationalacctgdocitem-profitcenter
      AND language = 'J'
      "AND ControllingArea  = ????
      "AND ValidityEndDate  = ????
      INTO TABLE @DATA(lt_profitcentertext).
      SORT lt_profitcentertext BY profitcenter.

      DATA:lv_zamount1 TYPE i_operationalacctgdocitem-amountincompanycodecurrency.
      DATA:lv_zamount2 TYPE i_operationalacctgdocitem-amountincompanycodecurrency.

      LOOP AT lt_operationalacctgdocitem INTO DATA(ls_data).

        CLEAR ls_mfgorder_003.

        ls_mfgorder_003-calendaryear = |{ lv_calendaryear ALPHA = IN }|."'年月'
        ls_mfgorder_003-calendarmonth = |{ lv_calendarmonth ALPHA = IN }|."'年月'
        ls_mfgorder_003-yearmonth = lv_calendaryear && '0' && lv_calendarmonth."'年月'
        ls_mfgorder_003-companycode = ls_data-companycode."'会社コード'
        ls_mfgorder_003-plant = ls_data-plant."'プラント'
        ls_mfgorder_003-profitcenter = ls_data-profitcenter."'利益センタ'
        ls_mfgorder_003-displaycurrency = ls_data-companycodecurrency."'照会通貨'
        ls_mfgorder_003-product = ls_data-product.
        ls_mfgorder_003-accountingdocumenttype = ls_data-accountingdocumenttype.

        ls_mfgorder_003-accountingdocument = ls_data-accountingdocument.
        ls_mfgorder_003-ledgergllineitem = ls_data-ledgergllineitem.



        "IF ls_data-quantity IS NOT INITIAL AND ls_data-glaccount = lv_glaccount1.
        "  ls_mfgorder_003-zamount1 = ls_data-amountincompanycodecurrency / ls_data-quantity.
        "ENDIF.
        "IF ls_data-quantity IS NOT INITIAL AND ls_data-glaccount = lv_glaccount2.
        "  ls_mfgorder_003-zamount2 = ls_data-amountincompanycodecurrency / ls_data-quantity.
        "ENDIF.
        IF ls_data-glaccount = lv_glaccount1.
          ls_mfgorder_003-zamount1 = ls_data-amountincompanycodecurrency .
        ENDIF.
        IF  ls_data-glaccount = lv_glaccount2.
          ls_mfgorder_003-zamount2 = ls_data-amountincompanycodecurrency .
        ENDIF.
        "'得意先' "'得意先テキスト'
        READ TABLE lt_productplantmrp INTO DATA(ls_productplantmrp) WITH KEY product = ls_mfgorder_003-product plant = ls_data-plant BINARY SEARCH.
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
              ls_mfgorder_003-soldtoparty = ls_businesspartner-businesspartner.
              "'得意先テキスト'
              ls_mfgorder_003-businesspartnername = ls_businesspartner-businesspartnername.
            ENDIF.
          ENDIF.
        ENDIF.

        "'利益センタテキスト'
        READ TABLE lt_profitcentertext INTO DATA(ls_profitcentertext) WITH KEY profitcenter = ls_data-profitcenter BINARY SEARCH.
        IF sy-subrc = 0.
          ls_mfgorder_003-profitcenterlongname = ls_profitcentertext-profitcenterlongname."'利益センタテキスト'
        ENDIF.

        "'会社コードテキスト'
        READ TABLE lt_companycode INTO DATA(ls_companycode) WITH KEY companycode = ls_data-companycode BINARY SEARCH.
        IF sy-subrc = 0.
          ls_mfgorder_003-companycodetext = ls_companycode-companycodename."'会社コードテキスト'
        ENDIF.
        "'プラントテキスト'
        READ TABLE lt_plant INTO DATA(ls_plant) WITH KEY plant = ls_data-plant BINARY SEARCH.
        IF sy-subrc = 0.
          ls_mfgorder_003-planttext = ls_plant-plantname."'プラントテキスト'
        ENDIF.
        "'製品テキスト'
        READ TABLE lt_productdescription INTO DATA(ls_productdescription) WITH KEY product = ls_mfgorder_003-product BINARY SEARCH.
        IF sy-subrc = 0.
          ls_mfgorder_003-productdescription = ls_productdescription-productdescription."'製品テキスト'
        ENDIF.

        ls_mfgorder_003-profitcenter = |{ ls_mfgorder_003-profitcenter ALPHA = OUT }|.
        ls_mfgorder_003-soldtoparty = |{ ls_mfgorder_003-soldtoparty ALPHA = OUT }|.

        "ls_mfgorder_003-zamount1 = zzcl_common_utils=>conversion_amount(
        "                            iv_alpha = 'OUT'
        "                            iv_currency =  ls_data-companycodecurrency
        "                            iv_input = ls_mfgorder_003-zamount1 ).
        "ls_mfgorder_003-zamount2 = zzcl_common_utils=>conversion_amount(
        "                             iv_alpha = 'OUT'
        "                             iv_currency = ls_data-companycodecurrency
        "                            iv_input = ls_mfgorder_003-zamount2 ).

*          READ TABLE lt_mfgorder_003 ASSIGNING FIELD-SYMBOL(<ls_old>) WITH KEY
*          yearmonth = ls_mfgorder_003-yearmonth
*          companycode = ls_mfgorder_003-companycode
*          plant = ls_mfgorder_003-plant
*          product = ls_mfgorder_003-product
*          profitcenter = ls_mfgorder_003-profitcenter
*          soldtoparty = ls_mfgorder_003-soldtoparty.
*          IF sy-subrc = 0.
*            <ls_old>-zamount1 += ls_mfgorder_003-zamount1.
*            <ls_old>-zamount2 += ls_mfgorder_003-zamount2.
*          ELSE.
        APPEND ls_mfgorder_003 TO lt_mfgorder_003.
        "          ENDIF.

      ENDLOOP.
    ENDIF.
    DATA:lt_ztfi_1022 TYPE STANDARD TABLE OF ztfi_1022 .
    IF lt_mfgorder_003 IS NOT INITIAL.
      lv_calendarmonth = |{ lv_calendarmonth ALPHA = IN }|.
      lv_calendaryear =  |{ lv_calendaryear ALPHA = IN }|.
      DELETE FROM ztfi_1022 WHERE companycode IN @lr_companycode AND plant IN @lr_plant
      AND calendaryear = @lv_calendaryear AND calendarmonth = @lv_calendarmonth.
      MOVE-CORRESPONDING lt_mfgorder_003 TO lt_ztfi_1022.
      MODIFY ztfi_1022 FROM TABLE @lt_ztfi_1022.
      COMMIT WORK.
      lv_msg = 'ztfi_1022保存成功'.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'S' ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ENDIF.

  ENDMETHOD.
  METHOD if_oo_adt_classrun~main.
    " for debugger
    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.
*    lt_parameters = VALUE #( ( selname = 'P_ID'
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '8B3CF2B54B611EEFA2D72EB68B20D50C' ) ).
    TRY.
*        if_apj_rt_exec_object~execute( it_parameters = lt_parameters ).
        if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_root INTO DATA(lo_root).
        out->write( |Exception has occured: { lo_root->get_text(  ) }| ).
    ENDTRY.
  ENDMETHOD.

  METHOD init_application_log.
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object      = 'ZZ_LOG_BI001'
                                                                       subobject   = 'ZZ_LOG_BI001_SUB'
*                                                                       external_id = CONV #( mv_uuid )
                                                                       ) ).
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.
  ENDMETHOD.

  METHOD add_message_to_log.
    TRY.
        IF sy-batch = abap_true.
          DATA(lo_free_text) = cl_bali_free_text_setter=>create(
                                 severity = COND #( WHEN i_type IS NOT INITIAL
                                                    THEN i_type
                                                    ELSE if_bali_constants=>c_severity_status )
                                 text     = i_text ).

          lo_free_text->set_detail_level( detail_level = '1' ).

          mo_application_log->add_item( item = lo_free_text ).

          cl_bali_log_db=>get_instance( )->save_log( log = mo_application_log
                                                     assign_to_current_appl_job = abap_true ).

        ELSE.
*          mo_out->write( i_text ).
        ENDIF.
      CATCH cx_bali_runtime INTO DATA(lx_bali_runtime).
        " handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
