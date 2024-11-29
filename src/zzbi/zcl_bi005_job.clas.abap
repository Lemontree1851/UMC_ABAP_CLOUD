CLASS zcl_bi005_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
*      BEGIN OF ty_podataanalysis.
*        INCLUDE TYPE zr_podataanalysis.
*    TYPES:
*        yearmonth TYPE n LENGTH 6,
*      END OF ty_podataanalysis,

      BEGIN OF ty_results,
        plant                    TYPE werks_d,
        material                 TYPE matnr,
*        supplier                 TYPE lifnr,
        deliverydate             TYPE datum,
        schedulelinedeliverydate TYPE datum,
        confirmedquantity        TYPE p LENGTH 7 DECIMALS 0,
        orderquantity            TYPE p LENGTH 7 DECIMALS 0,
      END OF ty_results,
      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,
      BEGIN OF ty_podataanalysis_api,
        count TYPE i,
        value TYPE tt_results,
      END OF ty_podataanalysis_api,

*     部品の入庫予測データ
      BEGIN OF ty_supply,
        yearmonth      TYPE n LENGTH 6,
        plant          TYPE werks_d,
        material       TYPE matnr,
*        supplier       TYPE lifnr,
        supplyquantity TYPE p LENGTH 7 DECIMALS 0,
      END OF ty_supply,

*     各品目の出庫予測データ
      BEGIN OF ty_demand,
        yearmonth      TYPE n LENGTH 6,
        plant          TYPE werks_d,
        material       TYPE matnr,
        customer       TYPE kunnr,

        demandquantity TYPE p LENGTH 7 DECIMALS 0,
      END OF ty_demand,

*----------------------------------------------uweb调用参考
      BEGIN OF ty_response_res,
        plant            TYPE string,
        material         TYPE string,
*        supplier         TYPE lifnr,
        arrange_end_date TYPE string,
        arrange_qty_sum  TYPE string,
      END OF ty_response_res,

      BEGIN OF ty_response_d,
        results TYPE TABLE OF ty_response_res WITH DEFAULT KEY,
      END OF ty_response_d,

      BEGIN OF ty_response,
        d TYPE ty_response_d,
      END OF ty_response,

*----------------------------------------------Material BOM Item调用参考
      BEGIN OF ty_response_res_bom,
        plant                      TYPE string,
        material                   TYPE matnr,
*        supplier                   TYPE lifnr,
        billofmaterialcomponent    TYPE string,
        billofmaterialitemquantity TYPE string,
        isassembly                 TYPE string,
      END OF ty_response_res_bom,

      BEGIN OF ty_response_d_bom,
        results TYPE TABLE OF ty_response_res_bom WITH DEFAULT KEY,
      END OF ty_response_d_bom,

      BEGIN OF ty_response_bom,
        d TYPE ty_response_d_bom,
      END OF ty_response_bom.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS:
      init_application_log,
      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime.
    CLASS-DATA:
      mo_application_log TYPE REF TO if_bali_log.
ENDCLASS.



CLASS zcl_bi005_job IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.
*    lt_parameters = VALUE #( ( selname = 'P_BUKRS'
*                               kind    = if_apj_dt_exec_object=>select_option
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '1100' )
*                               ( selname = 'P_BUKRS'
*                               kind    = if_apj_dt_exec_object=>select_option
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '1400' )
*                               ( selname = 'P_PLANT'
*                               kind    = if_apj_dt_exec_object=>select_option
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '1100' )
*                               ( selname = 'P_PLANT'
*                               kind    = if_apj_dt_exec_object=>select_option
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '1400' )
*                               ( selname = 'P_GJAHR'
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '2024' )
*                               ( selname = 'P_POPER'
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '009' ) ).
    TRY.
        if_apj_dt_exec_object~get_parameters( IMPORTING et_parameter_val = lt_parameters ).

        if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_root INTO DATA(lo_root).
        out->write( |Exception has occured: { lo_root->get_text(  ) }| ).
    ENDTRY.
  ENDMETHOD.

  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #( ( selname        = 'P_BUKRS'
                                  kind           = if_apj_dt_exec_object=>select_option
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = '会社コード'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true )

                                  ( selname      = 'P_PLANT'
                                  kind           = if_apj_dt_exec_object=>select_option
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = 'プラント'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true )

                                  ( selname      = 'P_GJAHR'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'numb'
                                  length         = 4
                                  param_text     = '会計年度'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true )

                                  ( selname      = 'P_POPER'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'numb'
                                  length         = 3
                                  param_text     = '会計期間'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true ) ).

    " Return the default parameters values here
    " et_parameter_val
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.

    DATA:
      lr_companycode    TYPE RANGE OF bukrs,
      lr_plant          TYPE RANGE OF werks_d,
      ls_companycode    LIKE LINE OF lr_companycode,
      ls_plant          LIKE LINE OF lr_plant,
      ls_podataanalysis TYPE ty_podataanalysis_api,
      lt_podataanalysis TYPE tt_results,
      lv_gjahr          TYPE gjahr,
      lv_poper          TYPE poper,
      lv_lastpoper      TYPE poper,
      lv_count          TYPE i,
      lv_filter         TYPE string,
      lv_filter2        TYPE string,
      lv_filter3        TYPE string,
      lt_supply         TYPE STANDARD TABLE OF ty_supply,
*      lt_zmm80        TYPE STANDARD TABLE OF ty_supply,
*      lt_zmm06        TYPE STANDARD TABLE OF ty_supply,
      lt_demand         TYPE STANDARD TABLE OF ty_demand,
      lt_bi1003         TYPE STANDARD TABLE OF ztbi_1003,
      ls_bi1003         TYPE ztbi_1003,
      ls_supply         TYPE ty_supply,
      ls_demand         TYPE ty_demand,
      lt_uweb_api       TYPE STANDARD TABLE OF ty_response_res,
      lt_bom_api        TYPE STANDARD TABLE OF ty_response_res_bom,
      lt_demand_zroh    TYPE STANDARD TABLE OF ty_demand,             "原材料
      lt_demand_zhlb    TYPE STANDARD TABLE OF ty_demand,             "半製品
      ls_response       TYPE ty_response,
      ls_response_bom   TYPE ty_response_bom,
      lv_next_qty       TYPE p LENGTH 8 DECIMALS 0,
      lv_bom_qty        TYPE p LENGTH 10 DECIMALS 0,
      lv_msg            TYPE cl_bali_free_text_setter=>ty_text.


    " 获取日志对象
    init_application_log( ).

    LOOP AT it_parameters INTO DATA(ls_parameters).

      CASE ls_parameters-selname.
*     Parameterの会社コード
        WHEN 'P_BUKRS'.
          MOVE-CORRESPONDING ls_parameters TO ls_companycode.
          APPEND ls_companycode TO lr_companycode.
*     Parameterのプラント
        WHEN 'P_PLANT'.
          MOVE-CORRESPONDING ls_parameters TO ls_plant.
          APPEND ls_plant TO lr_plant.
*     Parameterの会計年度
        WHEN 'P_GJAHR'.
          lv_gjahr = ls_parameters-low.
*     Parameterの会計期間
        WHEN 'P_POPER'.
          lv_poper = ls_parameters-low.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

*   会社コード Parameterの存在Check
    SELECT SINGLE COUNT( * )
      FROM i_companycode WITH PRIVILEGED ACCESS
     WHERE companycode IN @lr_companycode.

    IF sy-subrc <> 0.
      CLEAR lv_msg.
      MESSAGE e027(zfico_001) WITH ls_companycode-low INTO lv_msg.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'E' ).
        CATCH cx_bali_runtime.
      ENDTRY.
      RETURN.
    ENDIF.

*   プラント Parameterの存在Check
    SELECT SINGLE COUNT( * )
      FROM i_plant WITH PRIVILEGED ACCESS
     WHERE plant IN @lr_plant.
    IF sy-subrc <> 0.
      CLEAR lv_msg.
      MESSAGE e007(zfico_001) WITH ls_plant-low INTO lv_msg.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'E' ).
        CATCH cx_bali_runtime.
      ENDTRY.
      RETURN.
    ENDIF.

*   前会計期間の編集
    IF lv_poper = '001'.
*      lv_poper = '012'.
      DATA(lv_lastyearperiod) = |{ lv_gjahr - 1 }012|.
    ELSE.
      lv_lastpoper = lv_poper - 1.
      lv_lastyearperiod = |{ lv_gjahr }{ lv_lastpoper }|.
    ENDIF.

    DATA(lv_yearperiod) = |{ lv_gjahr }{ lv_poper }|.

*   画面入力された月の後12カ月の編集
    SELECT SINGLE
           fiscalperiodstartdate,
           fiscalperiodenddate
      FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
     WHERE fiscalyearvariant = 'V3'
       AND fiscalyearperiod    = @lv_yearperiod
      INTO ( @DATA(lv_now_start), @DATA(lv_now_end) ).

    DATA(lv_next_start) = zzcl_common_utils=>calc_date_add( EXPORTING date = lv_now_start month = 11 ).
    DATA(lv_next_end) = zzcl_common_utils=>get_enddate_of_month( EXPORTING iv_date = lv_next_start ).

*   前月の在庫実績を抽出
    SELECT a~companycode,           "会社コード
           b~companycodename,       "会社コードテキスト
           a~plant,                 "プラント
           c~plantname,             "プラントテキスト
*           profitcenter,          "利益センタ
           materialtype,            "品目タイプ
           materialtypename,        "品目タイプテキスト
           a~material,              "品目
           d~productdescription AS productname,           "品目テキスト
           businesspartner,         "得意先
           businesspartnername,     "得意先テキスト
           valuationquantity,       "数量
           movingaverageprice,      "実際原価
           standardprice,           "標準原価
           displaycurrency,         "通貨
           unit
      FROM ztfi_1016 AS a
      LEFT JOIN i_companycode WITH PRIVILEGED ACCESS AS b
             ON b~companycode = a~companycode
            AND b~language = @sy-langu
      LEFT JOIN i_plant WITH PRIVILEGED ACCESS AS c
             ON c~plant = a~plant
            AND c~language = @sy-langu
      LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS d
             ON d~product = a~material
            AND d~language = @sy-langu
     WHERE a~companycode IN @lr_companycode
       AND a~plant       IN @lr_plant
       AND yearmonth    = @lv_lastyearperiod
*       and ( a~material   = 'K9Y25-60E/DMAN:CU0'
*        or   a~material   = 'AH1ASY02535AC'
*        or   a~material   = 'AH1ASY02535AC-SMTB' )
      INTO TABLE @DATA(lt_1016).

    IF sy-subrc <> 0.
      RETURN.
    ELSE.
      SORT lt_1016 BY plant       ASCENDING
                      material    ASCENDING
                      companycode ASCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_1016 COMPARING plant material companycode.

    ENDIF.

    DATA(lt_material) = lt_1016.
    SORT lt_material BY material.
    DELETE lt_material WHERE materialtype <> 'ZROH'.    "原材料の品目
    DELETE ADJACENT DUPLICATES FROM lt_material COMPARING material.

    DATA(lt_plant) = lt_1016.
    SORT lt_plant BY plant.
    DELETE ADJACENT DUPLICATES FROM lt_plant COMPARING plant.

*    DATA(lt_supplier) = lt_1016.
*    SORT lt_supplier BY businesspartner.
*    DELETE ADJACENT DUPLICATES FROM lt_supplier COMPARING businesspartner.

    CLEAR lv_count.
    LOOP AT lt_plant INTO DATA(ls_plant1).
      lv_count += 1.
      IF lv_count = 1.
        lv_filter = |(Plant eq '{ ls_plant1-plant }'|.
      ELSE.
        lv_filter = |{ lv_filter } or Plant eq '{ ls_plant1-plant }'|.
      ENDIF.
    ENDLOOP.
    lv_filter = |{ lv_filter })|.
    lv_filter3 = lv_filter.

*    IF lines( lt_supplier ) < 20.
*      CLEAR lv_count.
*      LOOP AT lt_supplier INTO DATA(ls_supplier).
*        lv_count += 1.
*        IF lv_count = 1.
*          lv_filter = |{ lv_filter } and (Supplier eq '{ ls_supplier-businesspartner }'|.
*        ELSE.
*          lv_filter = |{ lv_filter } or Supplier eq '{ ls_supplier-businesspartner }'|.
*        ENDIF.
*      ENDLOOP.
*      lv_filter = |{ lv_filter })|.
*      lv_filter2 = lv_filter.
*    ELSE.
*      lv_filter = |{ lv_filter } and Supplier ne ''|.
*      lv_filter2 = lv_filter.
*    ENDIF.

    IF lines( lt_material ) < 40.
      CLEAR lv_count.
      LOOP AT lt_material INTO DATA(ls_material).
        lv_count += 1.
        IF lv_count = 1.
          lv_filter = |{ lv_filter } and (Material eq '{ ls_material-material }'|.
        ELSE.
          lv_filter = |{ lv_filter } or Material eq '{ ls_material-material }'|.
        ENDIF.
      ENDLOOP.
      lv_filter = |{ lv_filter })|.
    ELSE.
      lv_filter = |{ lv_filter } and Material ne ''|.
    ENDIF.

    DATA(lv_top) = 5000.
    DATA(lv_skip) = 0.
    DATA(lv_while) = abap_on.

*   部品の入庫予測データを取得
*   PO登録した後の原材料Supplyの数字を取得する（ZMM80）
    WHILE lv_while IS NOT INITIAL.
      clear lv_while.
      DATA(lv_path) = |/zui_podataanalysis_o4/srvd/sap/zui_podataanalysis_o4/0001/PODataAnalysis?$count=true&$top={ lv_top }&$skip={ lv_skip }&sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
      DATA(lv_select) = |Plant,Material,Supplier,DeliveryDate,ScheduleLineDeliveryDate,ConfirmedQuantity,OrderQuantity|.
      zzcl_common_utils=>request_api_v4( EXPORTING iv_path        = lv_path
                                                   iv_method      = if_web_http_client=>get
                                                   iv_select      = lv_select
                                                   iv_filter      = lv_filter
                                                   iv_format      = 'json'
                                         IMPORTING ev_status_code = DATA(lv_status_code)
                                                   ev_response    = DATA(lv_response) ).
      IF lv_status_code = 200.
        REPLACE ALL OCCURRENCES OF `@odata.count` IN lv_response  WITH `count`.
*     json => abap
*      xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
*        ( xco_cp_json=>transformation->pascal_case_to_underscore )
*      ) )->write_to( REF #( ls_podataanalysis ) ).
        /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                   CHANGING  data = ls_podataanalysis ).

        APPEND LINES OF ls_podataanalysis-value TO lt_podataanalysis.
        if lines( lt_podataanalysis ) < ls_podataanalysis-count.
            lv_while = abap_on.
            lv_top = ls_podataanalysis-count - lines( lt_podataanalysis ).
            lv_skip = 5000 * sy-index.
        ENDIF.
      ENDIF.
    ENDWHILE.

    DELETE lt_podataanalysis WHERE ( ( deliverydate IS NOT INITIAL AND ( deliverydate < lv_now_start OR deliverydate > lv_next_end ) OR
                                 deliverydate IS INITIAL AND ( schedulelinedeliverydate < lv_now_start OR schedulelinedeliverydate > lv_next_end )  ) ).

    LOOP AT lt_podataanalysis ASSIGNING FIELD-SYMBOL(<fs_l_response>).
      IF <fs_l_response>-deliverydate IS NOT INITIAL.
        ls_supply-yearmonth = <fs_l_response>-deliverydate+0(6).
      ELSEIF <fs_l_response>-schedulelinedeliverydate IS NOT INITIAL.
        ls_supply-yearmonth = <fs_l_response>-schedulelinedeliverydate+0(6).
      ENDIF.

      IF <fs_l_response>-confirmedquantity IS NOT INITIAL.
        ls_supply-supplyquantity = <fs_l_response>-confirmedquantity.
      ELSEIF <fs_l_response>-orderquantity IS NOT INITIAL.
        ls_supply-supplyquantity = <fs_l_response>-orderquantity.
      ENDIF.
      ls_supply-material = <fs_l_response>-material.
      ls_supply-plant    = <fs_l_response>-plant.
*        ls_supply-supplier = <fs_l_response>-supplier.
      COLLECT ls_supply INTO lt_supply.
      CLEAR ls_supply.
    ENDLOOP.


*   PO登録されない原材料のSupplyの数字を取得する（ZMM06）
*    DATA(lv_select) = |Plant,Material,DeliveryDate,ScheduleLineDeliveryDate,ConfirmedQuantity,OrderQuantity|.
    DATA(lv_start_c) = lv_now_start+0(4) && '-' && lv_now_start+4(2) && '-' && lv_now_start+6(2) && 'T00:00:00'.
    DATA(lv_next_end_c)   = lv_next_end+0(4) && '-' && lv_next_end+4(2) && '-' && lv_next_end+6(2)  && 'T00:00:00'.
    lv_filter2 = |{ lv_filter2 } and ARRANGE_END_DATE be datetime'{ lv_start_c }' and ARRANGE_END_DATE le datetime'{ lv_next_end_c }'|.
    zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |http://220.248.121.53:11380/srv/odata/v2/TableService/PCH09_LIST?sap-language={ zzcl_common_utils=>get_current_language(  ) }|
                                                            iv_client_id     = CONV #( 'Tom' )
                                                            iv_client_secret = CONV #( '1' )
                                                            iv_authtype      = 'Basic'
                                                  IMPORTING ev_status_code   = DATA(lv_status_code_uweb)
                                                            ev_response      = DATA(lv_response_uweb) ).
    IF lv_status_code_uweb = 200.
      REPLACE ALL OCCURRENCES OF `\/Date(` IN lv_response_uweb  WITH ``.
      REPLACE ALL OCCURRENCES OF `)\/` IN lv_response_uweb  WITH ``.

*      xco_cp_json=>data->from_string( lv_response_uweb )->apply( VALUE #(
**        ( xco_cp_json=>transformation->boolean_to_abap_bool )
*      ) )->write_to( REF #( ls_response ) ).
      /ui2/cl_json=>deserialize( EXPORTING json = lv_response_uweb
                                 CHANGING  data = ls_response ).

      IF ls_response-d-results IS NOT INITIAL.
        APPEND LINES OF ls_response-d-results TO lt_uweb_api.
        LOOP AT lt_uweb_api ASSIGNING FIELD-SYMBOL(<fs_l_uweb_api>).
          IF <fs_l_uweb_api>-arrange_end_date < 0.
            ls_supply-yearmonth = '190001'.
          ELSEIF <fs_l_uweb_api>-arrange_end_date = '253402214400000'.
            ls_supply-yearmonth = '999912'.
          ELSE.
*            <fs_l_uweb_api>-arrange_end_date = xco_cp_time=>unix_timestamp(
*                        iv_unix_timestamp = <fs_l_uweb_api>-arrange_end_date / 1000
*                     )->get_moment( )->as( xco_cp_time=>format->abap )->value+0(8).
            ls_supply-yearmonth = xco_cp_time=>unix_timestamp(
                        iv_unix_timestamp = <fs_l_uweb_api>-arrange_end_date / 1000
                     )->get_moment( )->as( xco_cp_time=>format->abap )->value+0(6).
          ENDIF.
          ls_supply-supplyquantity = <fs_l_uweb_api>-arrange_qty_sum.
          ls_supply-material = <fs_l_uweb_api>-material.
          ls_supply-plant    = <fs_l_response>-plant.
*          ls_supply-supplier = <fs_l_uweb_api>-supplier.
          COLLECT ls_supply INTO lt_supply.
          CLEAR ls_supply.
        ENDLOOP.
      ENDIF.
    ENDIF.

    DATA(lt_material_zfrt) = lt_1016.
    SORT lt_material_zfrt BY material.
    DELETE lt_material_zfrt WHERE materialtype <> 'ZFRT'.    "製品の品目
    DELETE ADJACENT DUPLICATES FROM lt_material_zfrt COMPARING material.

*   得意先内示データから製品の所要量を取得
    SELECT a~material,
           a~requirement_date,
           a~plant,
           a~customer,
           a~requirement_qty
      FROM ztpp_1012 AS a
      INNER JOIN @lt_material_zfrt AS b ON b~material = a~material
*                                       AND b~businesspartner = a~customer
     WHERE a~plant IN @lr_plant
       AND a~requirement_date >= @lv_now_start
       AND a~requirement_date <= @lv_next_end
      INTO TABLE @DATA(lt_1012).

    IF sy-subrc = 0.
      LOOP AT lt_1012 ASSIGNING FIELD-SYMBOL(<fs_l_1012>).
        ls_demand-yearmonth = <fs_l_1012>-requirement_date+0(6).
        ls_demand-material = <fs_l_1012>-material.
        ls_demand-plant    = <fs_l_1012>-plant.
        ls_demand-customer = <fs_l_1012>-customer.
        ls_demand-demandquantity = <fs_l_1012>-requirement_qty.
        COLLECT ls_demand INTO lt_demand.
        CLEAR ls_demand.
      ENDLOOP.
    ENDIF.

*   各製品の構成半製品を取得
    lv_path = |/API_BILL_OF_MATERIAL_SRV;v=0002/MaterialBOMItem?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
    lv_filter3 = |BillOfMaterialVariant eq '1' and { lv_filter3 }|.
    lv_select = |Plant,Material,BillOfMaterialComponent,BillOfMaterialItemQuantity,IsAssembly|.
    zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                 iv_method      = if_web_http_client=>get
                                                 iv_select      = lv_select
                                                 iv_filter      = lv_filter3
                                                 iv_format      = 'json'
                                       IMPORTING ev_status_code = lv_status_code
                                                 ev_response    = lv_response ).
    IF lv_status_code = 200.
*     json => abap
      /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                 CHANGING  data = ls_response_bom ).
      IF ls_response_bom-d-results IS NOT INITIAL.
        MOVE-CORRESPONDING ls_response_bom-d-results TO lt_bom_api.
      ENDIF.
    ENDIF.

    SORT lt_demand
      BY yearmonth ASCENDING
         plant     ASCENDING
         material  ASCENDING.
*         customer  ASCENDING.

    SORT lt_supply
      BY yearmonth ASCENDING
         plant     ASCENDING
         material  ASCENDING.
*         supplier  ASCENDING.

    SORT lt_bom_api
      BY plant    ASCENDING
         material ASCENDING.

    GET TIME STAMP FIELD DATA(lv_timestamp).

*    DELETE lt_demand FROM 2.

    LOOP AT lt_demand ASSIGNING FIELD-SYMBOL(<fs_l_group>)
      GROUP BY ( yearmonth = <fs_l_group>-yearmonth ).

      LOOP AT GROUP <fs_l_group> ASSIGNING FIELD-SYMBOL(<fs_l_demand>).
        ls_bi1003-type               = '在庫予測'.
        ls_bi1003-created_by         = sy-uname.
        ls_bi1003-created_at         = lv_timestamp.
        ls_bi1003-last_changed_by    = sy-uname.
        ls_bi1003-last_changed_at    = lv_timestamp.
        zzcl_common_utils=>get_fiscal_year_period( EXPORTING iv_date   = |{ <fs_l_demand>-yearmonth }01|
                                                   IMPORTING ev_year   = lv_gjahr
                                                             ev_period = lv_poper ).
        ls_bi1003-yearmonth          = |{ lv_gjahr }{ lv_poper }|.
        ls_bi1003-plant              = <fs_l_demand>-plant.

*       前月の在庫実績の製品
        READ TABLE lt_1016 ASSIGNING FIELD-SYMBOL(<fs_l_1016>)
          WITH KEY plant    = <fs_l_demand>-plant
                   material = <fs_l_demand>-material
*                   businesspartner = <fs_l_demand>-customer
                   BINARY SEARCH.
        IF sy-subrc = 0
        AND <fs_l_demand>-demandquantity <= <fs_l_1016>-valuationquantity.
          ls_bi1003-customer           = <fs_l_1016>-businesspartner.
          ls_bi1003-customertext       = <fs_l_1016>-businesspartnername.
          ls_bi1003-materialtype       = <fs_l_1016>-materialtype.
          ls_bi1003-materialtypetext   = <fs_l_1016>-materialtypename.

          ls_bi1003-companycode        = <fs_l_1016>-companycode.
          ls_bi1003-product            = <fs_l_1016>-material.
          ls_bi1003-planttext          = <fs_l_1016>-plantname.
          ls_bi1003-companycodetext    = <fs_l_1016>-companycodename.
          ls_bi1003-productdescription = <fs_l_1016>-productname.

          ls_bi1003-balanceopenning = <fs_l_1016>-valuationquantity.    "Balance（期首）
          ls_bi1003-demand          = <fs_l_demand>-demandquantity.     "Demand
          ls_bi1003-balanceclosing  = <fs_l_1016>-valuationquantity     "Balance（期末）
                                    - <fs_l_demand>-demandquantity.

          ls_bi1003-unit   = <fs_l_1016>-unit.     "数量単位
          ls_bi1003-standardprice = <fs_l_1016>-standardprice.            "標準原価
          ls_bi1003-actualprice   = <fs_l_1016>-movingaverageprice.       "実際原価
          ls_bi1003-companycodecurrency = <fs_l_1016>-displaycurrency.    "通貨
*         期末在庫金額
          IF ls_bi1003-actualprice IS NOT INITIAL.
            ls_bi1003-closinginventorytotal = ls_bi1003-actualprice * ls_bi1003-balanceclosing.
          ELSE.
            ls_bi1003-closinginventorytotal = ls_bi1003-standardprice * ls_bi1003-balanceclosing.
          ENDIF.
*         次の月の期首在庫は前月の期末予測在庫になります
          <fs_l_1016>-valuationquantity = ls_bi1003-balanceclosing.

*         製品
          READ TABLE lt_bi1003 ASSIGNING FIELD-SYMBOL(<fs_l_bi1003>)
            WITH KEY yearmonth = ls_bi1003-yearmonth
                     plant     = ls_bi1003-plant
                     product   = ls_bi1003-product.
          IF sy-subrc <> 0.
            APPEND ls_bi1003 TO lt_bi1003.
          ELSE.
            <fs_l_bi1003>-demand         = <fs_l_bi1003>-demand + ls_bi1003-demand.         "Demand
            <fs_l_bi1003>-balanceclosing = ls_bi1003-balanceclosing.                        "Balance（期末）
            <fs_l_bi1003>-closinginventorytotal = ls_bi1003-closinginventorytotal.          "期末在庫金額
          ENDIF.
        ELSE.
          IF  sy-subrc = 0
          AND <fs_l_demand>-demandquantity > <fs_l_1016>-valuationquantity.
            ls_bi1003-customer         = <fs_l_1016>-businesspartner.
            ls_bi1003-customertext     = <fs_l_1016>-businesspartnername.
            ls_bi1003-materialtype     = <fs_l_1016>-materialtype.
            ls_bi1003-materialtypetext = <fs_l_1016>-materialtypename.

            ls_bi1003-companycode        = <fs_l_1016>-companycode.
            ls_bi1003-product            = <fs_l_1016>-material.
            ls_bi1003-planttext          = <fs_l_1016>-plantname.
            ls_bi1003-companycodetext    = <fs_l_1016>-companycodename.
            ls_bi1003-productdescription = <fs_l_1016>-productname.
            ls_bi1003-unit               = <fs_l_1016>-unit.     "数量単位
            ls_bi1003-balanceopenning = <fs_l_1016>-valuationquantity.    "Balance（期首）
            ls_bi1003-demand          = <fs_l_1016>-valuationquantity.    "Demand
            ls_bi1003-balanceclosing  = 0.                                "Balance（期末）
            ls_bi1003-closinginventorytotal = 0.                            "期末在庫金額
            ls_bi1003-standardprice = <fs_l_1016>-standardprice.            "標準原価
            ls_bi1003-actualprice   = <fs_l_1016>-movingaverageprice.       "実際原価
            ls_bi1003-companycodecurrency = <fs_l_1016>-displaycurrency.    "通貨
*             製品
            READ TABLE lt_bi1003 ASSIGNING <fs_l_bi1003>
              WITH KEY yearmonth = ls_bi1003-yearmonth
                       plant     = ls_bi1003-plant
                       product   = ls_bi1003-product.
            IF sy-subrc <> 0.
              APPEND ls_bi1003 TO lt_bi1003.
            ELSE.
              <fs_l_bi1003>-demand         = <fs_l_bi1003>-demand + ls_bi1003-demand.         "Demand
              <fs_l_bi1003>-balanceclosing = ls_bi1003-balanceclosing.                        "Balance（期末）
              <fs_l_bi1003>-closinginventorytotal = ls_bi1003-closinginventorytotal.          "期末在庫金額
            ENDIF.
            CLEAR ls_bi1003.

            lv_next_qty = <fs_l_demand>-demandquantity - <fs_l_1016>-valuationquantity.
*             次の月の期首在庫は前月の期末予測在庫になります
            <fs_l_1016>-valuationquantity = 0.
          ELSE.
            lv_next_qty = <fs_l_demand>-demandquantity.
          ENDIF.
*         BOM 展开
          DATA(lv_next) = <fs_l_demand>-material.
          WHILE lv_next IS NOT INITIAL .
            LOOP AT lt_bom_api ASSIGNING FIELD-SYMBOL(<fs_l_bom>)
              WHERE plant = <fs_l_demand>-plant
                AND material = lv_next.
*                AND supplier = <fs_l_demand>-customer.
              ls_bi1003-type               = '在庫予測'.
              ls_bi1003-created_by         = sy-uname.
              ls_bi1003-created_at         = lv_timestamp.
              ls_bi1003-last_changed_by    = sy-uname.
              ls_bi1003-last_changed_at    = lv_timestamp.
              ls_bi1003-yearmonth          = |{ lv_gjahr }{ lv_poper }|.
              ls_bi1003-plant              = <fs_l_demand>-plant.

              lv_bom_qty = lv_next_qty * <fs_l_bom>-billofmaterialitemquantity.

*             前月の在庫実績の半製品
              READ TABLE lt_1016 ASSIGNING <fs_l_1016>
                WITH KEY plant    = <fs_l_demand>-plant
                         material = <fs_l_bom>-billofmaterialcomponent
*                         businesspartner = <fs_l_demand>-customer
                         BINARY SEARCH.
              IF sy-subrc = 0.
                ls_bi1003-companycode     = <fs_l_1016>-companycode.
                ls_bi1003-product         = <fs_l_bom>-billofmaterialcomponent.

                ls_bi1003-balanceopenning = <fs_l_1016>-valuationquantity.      "Balance（期首）
                ls_bi1003-unit   = <fs_l_1016>-unit.     "数量単位
                ls_bi1003-standardprice = <fs_l_1016>-standardprice.            "標準原価
                ls_bi1003-actualprice   = <fs_l_1016>-movingaverageprice.       "実際原価
                ls_bi1003-companycodecurrency = <fs_l_1016>-displaycurrency.    "通貨

                ls_bi1003-customer        = <fs_l_1016>-businesspartner.
                ls_bi1003-customertext    = <fs_l_1016>-businesspartnername.
                ls_bi1003-materialtype    = <fs_l_1016>-materialtype.
                ls_bi1003-materialtypetext = <fs_l_1016>-materialtypename.

                ls_bi1003-planttext          = <fs_l_1016>-plantname.
                ls_bi1003-companycodetext    = <fs_l_1016>-companycodename.
                ls_bi1003-productdescription = <fs_l_1016>-productname.

                IF lv_bom_qty <= <fs_l_1016>-valuationquantity
                OR <fs_l_bom>-isassembly IS INITIAL.
                  ls_bi1003-demand          = lv_bom_qty.                       "Demand
                  ls_bi1003-balanceclosing  = <fs_l_1016>-valuationquantity     "Balance（期末）
                                            - lv_bom_qty.
*                 期末在庫金額
                  IF ls_bi1003-actualprice IS NOT INITIAL.
                    ls_bi1003-closinginventorytotal = ls_bi1003-actualprice * ls_bi1003-balanceclosing.
                  ELSE.
                    ls_bi1003-closinginventorytotal = ls_bi1003-standardprice * ls_bi1003-balanceclosing.
                  ENDIF.

*                 次の月の期首在庫は前月の期末予測在庫になります
                  <fs_l_1016>-valuationquantity = ls_bi1003-balanceclosing.

*                 原材料の場合
                  IF <fs_l_bom>-isassembly IS INITIAL.
*                   原材料のSupplyの数字を取得する
                    READ TABLE lt_supply INTO ls_supply
                      WITH KEY yearmonth = <fs_l_demand>-yearmonth
                               plant     = <fs_l_demand>-plant
                               material  = <fs_l_bom>-billofmaterialcomponent
*                               supplier  = <fs_l_demand>-customer
                               BINARY SEARCH.
                    IF sy-subrc = 0.
                      ls_bi1003-supply = ls_supply-supplyquantity.
                      ls_bi1003-balanceclosing  = ls_bi1003-balanceclosing     "Balance（期末）
                                                + ls_bi1003-supply.
                      <fs_l_1016>-valuationquantity = ls_bi1003-balanceclosing.
                    ENDIF.
                  ENDIF.

*                 半製品/原材料
                  READ TABLE lt_bi1003 ASSIGNING <fs_l_bi1003>
                    WITH KEY yearmonth = ls_bi1003-yearmonth
                             plant     = ls_bi1003-plant
                             product   = ls_bi1003-product.
                  IF sy-subrc <> 0.
                    APPEND ls_bi1003 TO lt_bi1003.
                  ELSE.
                    <fs_l_bi1003>-demand         = <fs_l_bi1003>-demand + ls_bi1003-demand.         "Demand
                    <fs_l_bi1003>-balanceclosing = ls_bi1003-balanceclosing.                        "Balance（期末）
                    <fs_l_bi1003>-closinginventorytotal = ls_bi1003-closinginventorytotal.          "期末在庫金額
                  ENDIF.
                ELSEIF lv_bom_qty > <fs_l_1016>-valuationquantity.
*                  ls_bi1003-companycode     = <fs_l_1016>-material.
*                  ls_bi1003-balanceopenning = <fs_l_1016>-valuationquantity.    "Balance（期首）
                  ls_bi1003-demand          = <fs_l_1016>-valuationquantity.    "Demand
                  ls_bi1003-balanceclosing  = 0.                                "Balance（期末）
*                 期末在庫金額
                  ls_bi1003-closinginventorytotal = 0.

*                 半製品
                  READ TABLE lt_bi1003 ASSIGNING <fs_l_bi1003>
                    WITH KEY yearmonth = ls_bi1003-yearmonth
                             plant     = ls_bi1003-plant
                             product   = ls_bi1003-product.
                  IF sy-subrc <> 0.
                    APPEND ls_bi1003 TO lt_bi1003.
                  ELSE.
                    <fs_l_bi1003>-demand         = <fs_l_bi1003>-demand + ls_bi1003-demand.         "Demand
                    <fs_l_bi1003>-balanceclosing = ls_bi1003-balanceclosing.                        "Balance（期末）
                    <fs_l_bi1003>-closinginventorytotal = ls_bi1003-closinginventorytotal.          "期末在庫金額
                  ENDIF.

                  IF <fs_l_bom>-isassembly IS NOT INITIAL.
*                   半製品
                    ls_demand-material = <fs_l_bom>-billofmaterialcomponent.
                    ls_demand-plant    = <fs_l_1016>-plant.
*                    ls_demand-customer = <fs_l_1016>-businesspartner.
                    ls_demand-demandquantity = lv_bom_qty - <fs_l_1016>-valuationquantity.
                    APPEND ls_demand TO lt_demand_zhlb.
                  ENDIF.
*                 次の月の期首在庫は前月の期末予測在庫になります
                  <fs_l_1016>-valuationquantity = 0.
                ELSE.
*                  CONTINUE.
                ENDIF.
              ELSE.
                IF <fs_l_bom>-isassembly IS NOT INITIAL.
*                 半製品
                  ls_demand-material = <fs_l_bom>-billofmaterialcomponent.
                  ls_demand-plant    = <fs_l_demand>-plant.
*                    ls_demand-customer = <fs_l_1016>-businesspartner.
                  ls_demand-demandquantity = lv_bom_qty.
                  APPEND ls_demand TO lt_demand_zhlb.
                ENDIF.
              ENDIF.
              CLEAR:
                ls_demand,
                ls_bi1003,
                lv_bom_qty.
            ENDLOOP.
            CLEAR:
              lv_next,
              lv_next_qty.

            READ TABLE lt_demand_zhlb INTO ls_demand INDEX 1.
            IF sy-subrc = 0.
              lv_next     = ls_demand-material.
              lv_next_qty = ls_demand-demandquantity.
              DELETE lt_demand_zhlb INDEX 1.
            ENDIF.
          ENDWHILE.
        ENDIF.
        CLEAR ls_bi1003.
      ENDLOOP.
    ENDLOOP.

    IF lt_bi1003 IS NOT INITIAL.
      MODIFY ztbi_1003 FROM TABLE @lt_bi1003.
      IF sy-subrc = 0.
        COMMIT WORK.
        CLEAR lv_msg.
        MESSAGE s005(zbi003) INTO lv_msg.
        TRY.
            add_message_to_log( i_text = lv_msg i_type = 'S' ).
          CATCH cx_bali_runtime.
        ENDTRY.
      ELSE.
        ROLLBACK WORK.
        CLEAR lv_msg.
        MESSAGE s006(zbi003) INTO lv_msg.
        TRY.
            add_message_to_log( i_text = lv_msg i_type = 'E' ).
          CATCH cx_bali_runtime.
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD init_application_log.
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object      = 'ZZ_LOG_BI005'
                                                                       subobject   = 'ZZ_LOG_BI005_SUB'
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
