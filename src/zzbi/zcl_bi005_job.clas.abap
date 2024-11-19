CLASS zcl_bi005_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_podataanalysis.
        INCLUDE TYPE zr_podataanalysis.
    TYPES:
        yearmonth TYPE N LENGTH 6,
      END OF ty_podataanalysis.


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
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '1100' )
*                               ( selname = 'P_PLANT'
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '1100' ) ).
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
      lr_companycode TYPE RANGE OF bukrs,
      lr_plant       TYPE RANGE OF werks_d,
      ls_companycode LIKE LINE OF lr_companycode,
      ls_plant       LIKE LINE OF lr_plant,
      lt_response    TYPE STANDARD TABLE OF zr_podataanalysis,
      lv_gjahr       TYPE gjahr,
      lv_poper       TYPE poper,
      lv_count       TYPE i,
      lv_filter      TYPE string,

      lv_msg         TYPE cl_bali_free_text_setter=>ty_text.


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
    SELECT SINGLE currency
      FROM i_companycode
     WHERE companycode IN @lr_companycode
     INTO @DATA(lv_currency).

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
      FROM i_plant
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
      lv_lastyearperiod = |{ lv_gjahr }{ lv_poper - 1 }|.
    ENDIF.

    DATA(lv_yearperiod) = |{ lv_gjahr }{ lv_poper }|.

*   画面入力された月の後12カ月の編集
    SELECT SINGLE
           fiscalperiodstartdate,
           fiscalperiodenddate
      FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
     WHERE fiscalyearvariant = 'V3'
       AND fiscalyearperiod    = @lv_yearperiod
      INTO @DATA(ls_fiscal).

    DATA(lv_next_start) = zzcl_common_utils=>calc_date_add( EXPORTING date = ls_fiscal-fiscalperiodstartdate month = 11 ).
    DATA(lv_next_end) = zzcl_common_utils=>get_enddate_of_month( EXPORTING iv_date = lv_next_start ).

*   前月の在庫実績を抽出
    SELECT companycode,           "会社コード
           plant,                 "プラント
*           profitcenter,          "利益センタ
           materialtype,          "品目タイプ
           material,              "品目
           businesspartner,       "得意先
           valuationquantity,     "数量
           movingaverageprice,    "実際原価
           standardprice          "標準原価
      FROM ztfi_1016
     WHERE companycode IN @lr_companycode
       AND plant       IN @lr_plant
       AND yearmonth    = @lv_lastyearperiod
      INTO TABLE @DATA(lt_1016).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lt_material) = lt_1016.
    SORT lt_material BY material.
    DELETE lt_material WHERE materialtype <> 'ZROH'.    "原材料の品目
    DELETE ADJACENT DUPLICATES FROM lt_material COMPARING material.

    DATA(lt_plant) = lt_1016.
    SORT lt_plant BY plant.
    DELETE ADJACENT DUPLICATES FROM lt_plant COMPARING plant.

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

*   部品の入庫予測データを取得
    DATA(lv_path) = |/zui_podataanalysis_o4/srvd/sap/zui_podataanalysis_o4/0001/PODataAnalysis|.
*    DATA(lv_select) = |Plant,Material,DeliveryDate,ScheduleLineDeliveryDate,ConfirmedQuantity,OrderQuantity|.
    zzcl_common_utils=>request_api_v4( EXPORTING iv_path        = lv_path
                                                 iv_method      = if_web_http_client=>get
                                                 iv_filter      = lv_filter
                                                 iv_format      = 'json'
                                       IMPORTING ev_status_code = DATA(lv_status_code)
                                                 ev_response    = DATA(lv_response) ).
    IF lv_status_code = 200.
      xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ) )->write_to( REF #( lt_response ) ).

      DELETE lt_response WHERE ( ( deliverydate IS NOT INITIAL AND ( deliverydate < ls_fiscal-fiscalperiodstartdate OR deliverydate > ls_fiscal-fiscalperiodenddate ) OR
                                   deliverydate IS INITIAL AND ( schedulelinedeliverydate < ls_fiscal-fiscalperiodstartdate OR schedulelinedeliverydate > ls_fiscal-fiscalperiodenddate )  ) ).

      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<fs_l_response>).


      ENDLOOP.
    ENDIF.












  ENDMETHOD.

  METHOD init_application_log.
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object      = 'ZZ_LOG_BI002'
                                                                       subobject   = 'ZZ_LOG_BI002_SUB'
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
