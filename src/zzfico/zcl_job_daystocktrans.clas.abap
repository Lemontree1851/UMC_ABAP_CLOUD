CLASS zcl_job_daystocktrans DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_last,
        companycode         TYPE i_billingdocumentitem-companycode,
        plant               TYPE i_billingdocumentitem-plant,
        soldtoparty         TYPE i_billingdocumentitem-soldtoparty,
*        producttype         TYPE mtart,
        billingquantity     TYPE i_billingdocumentitem-billingquantity,
        billingquantityunit TYPE i_billingdocumentitem-billingquantityunit,
        netamount           TYPE i_billingdocumentitem-netamount,
        transactioncurrency TYPE i_billingdocumentitem-transactioncurrency,
      END OF ty_last,
      tt_last TYPE STANDARD TABLE OF ty_last WITH DEFAULT KEY,

      BEGIN OF ty_next,
        material        TYPE matnr,
        producttype     TYPE mtart,
        plant           TYPE werks_d,
        customer        TYPE kunnr,
        requirement_qty TYPE menge_d,
        salesforcast    TYPE i_billingdocumentitem-netamount,
        salesprice      TYPE i_billingdocumentitem-netamount,
      END OF ty_next,
      tt_next TYPE STANDARD TABLE OF ty_next WITH DEFAULT KEY,

      BEGIN OF ty_response_h,
        project_no          TYPE string,
        requisition_version TYPE string,
        valid_f             TYPE string,
        valid_t             TYPE string,
      END OF ty_response_h,
      BEGIN OF ty_response_h_r,
        results TYPE TABLE OF ty_response_h WITH DEFAULT KEY,
      END OF ty_response_h_r,
      BEGIN OF ty_response_h_d,
        d TYPE ty_response_h_r,
      END OF ty_response_h_d,

      BEGIN OF ty_response_d,
        material            TYPE string,
        project_no          TYPE string,
        requisition_version TYPE string,
        sales_price         TYPE string,
      END OF ty_response_d,
      BEGIN OF ty_response_d_r,
        results TYPE TABLE OF ty_response_d WITH DEFAULT KEY,
      END OF ty_response_d_r,
      BEGIN OF ty_response_d_d,
        d TYPE ty_response_d_r,
      END OF ty_response_d_d.

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



CLASS zcl_job_daystocktrans IMPLEMENTATION.

  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #( ( selname        = 'P_COMPANYCODE'
                                  kind           = if_apj_dt_exec_object=>select_option
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = '会社コード'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true )
                                  ( selname        = 'P_PLANT'
                                  kind           = if_apj_dt_exec_object=>select_option
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = 'プラント'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true ) ).

    " Return the default parameters values here
    " et_parameter_val
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.

    DATA:
      lt_1015              TYPE STANDARD TABLE OF ztfi_1015,
      ls_1015              TYPE ztfi_1015,
      lt_1016              TYPE STANDARD TABLE OF ztfi_1016,
      ls_1016              TYPE ztfi_1016,
      ls_response_h        TYPE ty_response_h_d,
      ls_response_d        TYPE ty_response_d_d,

      lv_price             TYPE p LENGTH 12 DECIMALS 3,
      lv_zfrt_price        TYPE p LENGTH 12 DECIMALS 3,
      lv_zhlb_price        TYPE p LENGTH 12 DECIMALS 3,
      lv_zroh_price        TYPE p LENGTH 12 DECIMALS 3,
      lv_valuationquantity TYPE p LENGTH 12 DECIMALS 3,

      lt_last              TYPE tt_last,
      lt_next              TYPE tt_next,
      lr_companycode       TYPE RANGE OF bukrs,
      lr_plant             TYPE RANGE OF werks_d,
      ls_companycode       LIKE LINE OF lr_companycode,
      ls_plant             LIKE LINE OF lr_plant,
      lv_last_start        TYPE datum,
      lv_last_end          TYPE datum,
      lv_next_start        TYPE datum,
      lv_next_end          TYPE datum,
      lv_next_start_c(19)  TYPE c,
      lv_next_end_c(19)    TYPE c,
      lv_date              TYPE datum,
      lv_datetime          TYPE string,
      lv_gjahr             TYPE gjahr,
      lv_poper             TYPE poper,
      lv_msg               TYPE cl_bali_free_text_setter=>ty_text.

    " 获取日志对象
    init_application_log( ).

    LOOP AT it_parameters INTO DATA(ls_parameters).
*     Parameterの会社コード
      IF ls_parameters-selname = 'P_COMPAN'.
        MOVE-CORRESPONDING ls_parameters TO ls_companycode.
        APPEND ls_companycode TO lr_companycode.
      ENDIF.

*     Parameterのプラント
      IF ls_parameters-selname = 'P_PLANT'.
        MOVE-CORRESPONDING ls_parameters TO ls_plant.
        APPEND ls_plant TO lr_plant.
      ENDIF.
    ENDLOOP.

*   Parameterの実行日付
    GET TIME STAMP FIELD DATA(lv_timestamp).
    lv_datetime = lv_timestamp.
    lv_date     = lv_datetime+0(8).

    zzcl_common_utils=>get_fiscal_year_period( EXPORTING iv_date = lv_date
                                             IMPORTING ev_year   = lv_gjahr
                                                       ev_period = lv_poper ).

*   前月
    lv_last_start = lv_date+0(6) && '01'.
    lv_last_start = lv_last_start - 1.
    lv_last_start = zzcl_common_utils=>get_begindate_of_month( EXPORTING iv_date = lv_last_start ).
    lv_last_end   = zzcl_common_utils=>get_enddate_of_month( EXPORTING iv_date = lv_last_start ).

*   翌月
    lv_next_start = zzcl_common_utils=>calc_date_add( EXPORTING date = lv_last_start month = 2 ).
    lv_next_end = zzcl_common_utils=>get_enddate_of_month( EXPORTING iv_date = lv_next_start ).

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

*   日別、得意先別、品目タイプ別の在庫金額の抽出
    SELECT a~companycode,                             "会社コード
           a~material AS product,                     "品目
           a~valuationarea AS plant,                  "プラント
           a~valuationquantity,                       "評価数量
           a~companycodecurrency AS currency,         "通貨
           b~producttype,                             "製品タイプ
           c~materialtypename,                        "製品タイプテキスト
           e~businesspartner,                         "ビジネスパートナ
           e~businesspartnername,                     "ビジネスパートナ名
           f~movingaverageprice,                      "移動平均価
           f~standardprice,                           "標準原価
           CASE f~movingaverageprice                  "移動平均価
               WHEN 0 THEN f~standardprice
               ELSE f~movingaverageprice
           END AS averageprice
      FROM i_inventoryamtbyfsclperd( p_fiscalperiod = @lv_poper , p_fiscalyear = @lv_gjahr ) WITH PRIVILEGED ACCESS AS a
      INNER JOIN i_product WITH PRIVILEGED ACCESS AS b ON b~product = a~material
      INNER JOIN i_productvaluationbasic WITH PRIVILEGED ACCESS AS f ON f~product = a~material
                                                                    AND f~valuationarea = a~valuationarea
      LEFT JOIN i_producttypetext WITH PRIVILEGED ACCESS AS c ON c~producttype = b~producttype
                                                             AND c~language = 'J'
      LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS d ON d~plant = a~valuationarea
                                                              AND d~product = a~material
                                                              AND d~mrpresponsible IS NOT INITIAL
      LEFT JOIN i_businesspartner WITH PRIVILEGED ACCESS AS e ON e~searchterm2 = right( d~mrpresponsible,2 )
      WHERE a~companycode IN @lr_companycode
        AND a~valuationarea IN @lr_plant
        AND a~ledger = '0L'
        AND ( a~invtryvalnspecialstocktype = 'O'
         OR   a~invtryvalnspecialstocktype = 'T'
         OR   a~invtryvalnspecialstocktype = @space )
        AND b~producttype IN ( 'ZFRT','ZHLB','ZROH' )
      INTO TABLE @DATA(lt_productplant).

    SORT lt_productplant BY companycode     ASCENDING
                            plant           ASCENDING
                            businesspartner ASCENDING.
*                            producttype     ASCENDING.

*   前月の販売製品の販売数量及び売上高抽
    SELECT a~companycode,
           a~plant,
           a~soldtoparty,
*           b~producttype,
           a~billingquantity,
           a~billingquantityunit,
           a~netamount,
           a~transactioncurrency
      FROM i_billingdocumentitem AS a
       INNER JOIN i_product WITH PRIVILEGED ACCESS AS b ON b~product = a~product
     WHERE companycode IN @lr_companycode
       AND plant IN @lr_plant
       AND billingdocumentdate >= @lv_last_start
       AND billingdocumentdate <= @lv_last_end
      INTO TABLE @lt_last.

    DATA(lt_last_tmp) = lt_last.
    CLEAR lt_last.
    SORT lt_last_tmp BY companycode ASCENDING
                        plant       ASCENDING
                        soldtoparty ASCENDING
*                        producttype ASCENDING
                        billingquantityunit ASCENDING
                        transactioncurrency ASCENDING.
    LOOP AT lt_last_tmp ASSIGNING FIELD-SYMBOL(<fs_l_group_last>).
      IF <fs_l_group_last>-transactioncurrency NE lv_currency.
        TRY.
            cl_exchange_rates=>convert_to_local_currency(
              EXPORTING
                date              = lv_date
                foreign_amount    = <fs_l_group_last>-netamount
                foreign_currency  = <fs_l_group_last>-transactioncurrency
                local_currency    = lv_currency
              IMPORTING
                local_amount      = <fs_l_group_last>-netamount
            ).
          CATCH cx_exchange_rates.
        ENDTRY.
        <fs_l_group_last>-transactioncurrency = lv_currency.
      ENDIF.
      COLLECT <fs_l_group_last> INTO lt_last.
    ENDLOOP.

*   当月売上予測所要量を抽出
    DATA(lt_tmpsql) = lt_productplant.
    SORT lt_tmpsql BY product ASCENDING
                      plant   ASCENDING
                      businesspartner ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_tmpsql COMPARING product plant businesspartner.

    SELECT a~material,
           b~producttype,
           a~plant,
           a~customer,
           a~requirement_qty
      FROM ztpp_1012 AS a
      INNER JOIN @lt_tmpsql AS b ON b~product = a~material
                                AND b~plant = a~plant
                                AND b~businesspartner = a~customer
     WHERE a~requirement_date >= @lv_next_start
       AND a~requirement_date <= @lv_next_end
        INTO TABLE @lt_next.

    DATA(lt_next_tmp) = lt_next.
    CLEAR lt_next.
    SORT lt_next_tmp BY material ASCENDING
                        producttype ASCENDING
                        plant ASCENDING
                        customer ASCENDING.
    LOOP AT lt_next_tmp INTO DATA(ls_next).
      COLLECT ls_next INTO lt_next.
    ENDLOOP.

*   売上予測単価を抽出
    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        " Get USAP Access configuration
        SELECT SINGLE *
          FROM zc_tbc1001
         WHERE zid = 'ZBC003'
           AND zvalue1 = @lv_system_url
          INTO @DATA(ls_config).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    IF ls_config IS NOT INITIAL.
      lv_next_start_c = lv_next_start+0(4) && '-' && lv_next_start+4(2) && '-' && lv_next_start+6(2) && 'T00:00:00'.
      lv_next_end_c   = lv_next_end+0(4) && '-' && lv_next_end+4(2) && '-' && lv_next_end+6(2)  && 'T00:00:00'.
      DATA(lv_filter) = |(VALID_F ge datetime'{ lv_next_start_c }' and VALID_F le datetime'{ lv_next_end_c }') | &&
                        |or (VALID_T ge datetime'{ lv_next_start_c }' and VALID_T le datetime'{ lv_next_end_c }') | &&
                        |or (VALID_F le datetime'{ lv_next_start_c }' and VALID_T ge datetime'{ lv_next_end_c }')|.

      CONDENSE ls_config-zvalue2 NO-GAPS. " ODATA_URL
      CONDENSE ls_config-zvalue3 NO-GAPS. " TOKEN_URL
      CONDENSE ls_config-zvalue4 NO-GAPS. " CLIENT_ID
      CONDENSE ls_config-zvalue5 NO-GAPS. " CLIENT_SECRET
      zzcl_common_utils=>get_usap_cdata( EXPORTING iv_odata_url     = |{ ls_config-zvalue2 }/odata/v2/TableService/QMS_T01_QUO_H|
                                                   iv_odata_filter  = lv_filter
                                                   iv_token_url     = CONV #( ls_config-zvalue3 )
                                                   iv_client_id     = CONV #( ls_config-zvalue4 )
                                                   iv_client_secret = CONV #( ls_config-zvalue5 )
                                         IMPORTING ev_status_code   = DATA(lv_status_code)
                                                   ev_response      = DATA(lv_response) ).
      IF lv_status_code = 200.
        REPLACE ALL OCCURRENCES OF `\/Date(` IN lv_response  WITH ``.
        REPLACE ALL OCCURRENCES OF `)\/` IN lv_response  WITH ``.

        xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
*          ( xco_cp_json=>transformation->pascal_case_to_underscore )
*          ( xco_cp_json=>transformation->boolean_to_abap_bool )
        ) )->write_to( REF #( ls_response_h ) ).

        IF ls_response_h-d-results IS NOT INITIAL.
          DATA(lt_results_h) = ls_response_h-d-results.
          SORT lt_results_h BY valid_t DESCENDING valid_f DESCENDING.
        ENDIF.
      ELSE.
        TRY.
            add_message_to_log( i_text = '' i_type = 'E' ).
          CATCH cx_bali_runtime.
        ENDTRY.
        RETURN.
      ENDIF.
    ENDIF.

*     売上予測の編集
    lt_next_tmp = lt_next.
    CLEAR lt_next.
    LOOP AT lt_next_tmp ASSIGNING FIELD-SYMBOL(<fs_l_group_next>)
      GROUP BY ( plant       = <fs_l_group_next>-plant          "プラント
*                 producttype = <fs_l_group_next>-producttype    "品目タイプ
                 customer    = <fs_l_group_next>-customer ).    "ビジネスパートナ

      DATA(lv_salesforcast) = <fs_l_group_next>-salesforcast.

      LOOP AT GROUP <fs_l_group_next> ASSIGNING FIELD-SYMBOL(<fs_l_next>).
        IF ls_config IS NOT INITIAL.
          DATA(ls_results_h) = lt_results_h[ 1 ].
          lv_filter = |SAP_MAT_ID eq '{ <fs_l_next>-material }' and PROJECT_NO eq '{ ls_results_h-project_no }' and REQUISITION_VERSION eq '{ ls_results_h-requisition_version }'|.
          CONDENSE ls_config-zvalue2 NO-GAPS. " ODATA_URL
          CONDENSE ls_config-zvalue3 NO-GAPS. " TOKEN_URL
          CONDENSE ls_config-zvalue4 NO-GAPS. " CLIENT_ID
          CONDENSE ls_config-zvalue5 NO-GAPS. " CLIENT_SECRET
          zzcl_common_utils=>get_usap_cdata( EXPORTING iv_odata_url     = |{ ls_config-zvalue2 }/odata/v2/TableService/QMS_T02_QUO_D|
                                                       iv_odata_filter  = lv_filter
                                                       iv_token_url     = CONV #( ls_config-zvalue3 )
                                                       iv_client_id     = CONV #( ls_config-zvalue4 )
                                                       iv_client_secret = CONV #( ls_config-zvalue5 )
                                             IMPORTING ev_status_code   = lv_status_code
                                                       ev_response      = lv_response ).
          IF lv_status_code = 200.
            xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
*              ( xco_cp_json=>transformation->pascal_case_to_underscore )
              ( xco_cp_json=>transformation->boolean_to_abap_bool )
            ) )->write_to( REF #( ls_response_d ) ).

            IF ls_response_d-d-results IS NOT INITIAL.
              DATA(lv_sales_price) = ls_response_d-d-results[ 1 ]-sales_price.
              EXIT.
            ENDIF.
          ELSE.
            TRY.
                add_message_to_log( i_text = '' i_type = 'E' ).
              CATCH cx_bali_runtime.
            ENDTRY.
            RETURN.
          ENDIF.
        ENDIF.
        TRY.
            <fs_l_next>-salesforcast = <fs_l_next>-requirement_qty * lv_sales_price.
            lv_salesforcast = lv_salesforcast + <fs_l_next>-salesforcast.
          CATCH cx_root.
            "handle exception
        ENDTRY.
      ENDLOOP.
      <fs_l_group_next>-salesprice = lv_sales_price.
      <fs_l_group_next>-salesforcast = lv_salesforcast.
      APPEND <fs_l_group_next> TO lt_next.
    ENDLOOP.

*     データを日別、得意先別、品目タイプ別に集計
    LOOP AT lt_productplant ASSIGNING FIELD-SYMBOL(<fs_l_group2>)
      GROUP BY ( companycode     = <fs_l_group2>-companycode
                 plant           = <fs_l_group2>-plant
                 businesspartner = <fs_l_group2>-businesspartner ).
*                 producttype     = <fs_l_group2>-producttype ).

*      TRY.
*          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
*        CATCH cx_uuid_error.
*          "handle exception
*      ENDTRY.

      MOVE-CORRESPONDING <fs_l_group2> TO ls_1015.

      CLEAR:
        lv_price,
        lv_valuationquantity,
        lv_zfrt_price,
        lv_zhlb_price,
        lv_zroh_price.
      LOOP AT GROUP <fs_l_group2> ASSIGNING FIELD-SYMBOL(<fs_l_productplant>).
*         製品
        IF <fs_l_productplant>-producttype = 'ZFRT'.
          lv_zfrt_price = lv_zfrt_price +  <fs_l_productplant>-valuationquantity * <fs_l_productplant>-averageprice.
        ENDIF.
*         半製品
        IF <fs_l_productplant>-producttype = 'ZHLB'.
          lv_zhlb_price = lv_zhlb_price +  <fs_l_productplant>-valuationquantity * <fs_l_productplant>-averageprice.
        ENDIF.
*         原材料
        IF <fs_l_productplant>-producttype = 'ZROH'.
          lv_zroh_price = lv_zroh_price +  <fs_l_productplant>-valuationquantity * <fs_l_productplant>-averageprice.
        ENDIF.
*        評価数量
        lv_valuationquantity = lv_valuationquantity + <fs_l_productplant>-valuationquantity.
      ENDLOOP.

      ls_1015-valuationquantity = lv_valuationquantity.
*     合計
      ls_1015-total = lv_zfrt_price + lv_zhlb_price + lv_zroh_price.
      ls_1015-excudate          = lv_date.                   "日付
      ls_1015-finishedgoods     = lv_zfrt_price.             "製品
      ls_1015-semifinishedgoods = lv_zhlb_price.             "半製品
      ls_1015-material          = lv_zroh_price.             "原材料

*       売上実績（先月）
      READ TABLE lt_last INTO DATA(ls_last) WITH KEY companycode = <fs_l_group2>-companycode
                                                     plant       = <fs_l_group2>-plant
                                                     soldtoparty = <fs_l_group2>-businesspartner.
*                                                     producttype = <fs_l_group2>-producttype.
      IF sy-subrc = 0.
        ls_1015-salesperfactlamtindspcurrency = ls_last-netamount.
        ls_1015-salesperformanceactualquantity = ls_last-billingquantity.
        ls_1015-saleactual = ls_last-netamount.
      ENDIF.

*     売上予測（翌月）
      CLEAR ls_next.
      READ TABLE lt_next INTO ls_next WITH KEY plant    = <fs_l_group2>-plant
                                                     producttype = <fs_l_group2>-producttype
                                                     customer = <fs_l_group2>-businesspartner.
      IF sy-subrc = 0.
        ls_1015-necessraryquantity = ls_next-requirement_qty.
        ls_1015-salesprice = ls_next-salesprice.
        ls_1015-saleforcast = ls_next-salesforcast.   "金额转换？
      ENDIF.

      GET TIME STAMP FIELD lv_timestamp.
      ls_1015-displaycurrency = <fs_l_group2>-currency.  "照会通貨
*      ls_1015-uuid = lv_uuid.
      ls_1015-created_by         = sy-uname.
      ls_1015-created_at         = lv_timestamp.
      ls_1015-last_changed_by    = sy-uname.
      ls_1015-last_changed_at    = lv_timestamp.
      ls_1015-local_last_changed_at = lv_date.
      APPEND ls_1015 TO lt_1015.
      CLEAR ls_1015.
    ENDLOOP.

    LOOP AT lt_productplant ASSIGNING FIELD-SYMBOL(<fs_l_group_m>)
          GROUP BY ( companycode     = <fs_l_group_m>-companycode
                     plant           = <fs_l_group_m>-plant
                     businesspartner = <fs_l_group_m>-businesspartner
                     product         = <fs_l_group_m>-product ).
*                 producttype     = <fs_l_group2>-producttype ).

*      TRY.
*          lv_uuid = cl_system_uuid=>create_uuid_x16_static(  ).
*        CATCH cx_uuid_error.
*          "handle exception
*      ENDTRY.

      MOVE-CORRESPONDING <fs_l_group_m> TO ls_1016.

      CLEAR:
        lv_price,
        ls_1016-valuationquantity.
      LOOP AT GROUP <fs_l_group_m> ASSIGNING <fs_l_productplant>.
*       評価数量
        ls_1016-valuationquantity = ls_1016-valuationquantity + <fs_l_productplant>-valuationquantity.
      ENDLOOP.

*     合計
      ls_1016-total = ls_1016-valuationquantity * <fs_l_productplant>-averageprice.
      ls_1016-yearmonth         = lv_date+0(6).              "会計期間
      ls_1016-type              = |在庫実績|.                 "タイプ

*      GET TIME STAMP FIELD lv_timestamp.
      ls_1016-displaycurrency    = <fs_l_group_m>-currency.  "照会通貨
      ls_1016-material           = <fs_l_group_m>-product.
      ls_1016-materialtype       = <fs_l_group_m>-producttype.
      ls_1016-created_by         = sy-uname.
      ls_1016-created_at         = lv_timestamp.
      ls_1016-last_changed_by    = sy-uname.
      ls_1016-last_changed_at    = lv_timestamp.
      ls_1016-local_last_changed_at = lv_date.
      APPEND ls_1016 TO lt_1016.
      CLEAR ls_1016.
    ENDLOOP.

    MODIFY ztfi_1015 FROM TABLE @lt_1015.
    IF sy-subrc = 0.
      COMMIT WORK.
      CLEAR lv_msg.
      MESSAGE s006(zfico_001) INTO lv_msg.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'S' ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ELSE.
      ROLLBACK WORK.
      TRY.
          CLEAR lv_msg.
          MESSAGE e005(zfico_001) INTO lv_msg.
          add_message_to_log( i_text = lv_msg i_type = 'E' ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ENDIF.

    DATA(lv_end_date) = zzcl_common_utils=>get_enddate_of_month( EXPORTING iv_date = lv_date ).
*    IF lv_date = lv_end_date.
    MODIFY ztfi_1016 FROM TABLE @lt_1016.
    IF sy-subrc = 0.
      COMMIT WORK.
      CLEAR lv_msg.
      MESSAGE s006(zfico_001) INTO lv_msg.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'S' ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ELSE.
      ROLLBACK WORK.
      CLEAR lv_msg.
      MESSAGE e005(zfico_001) INTO lv_msg.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'E' ).
        CATCH cx_bali_runtime.
      ENDTRY.
    ENDIF.
*    ENDIF.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.
    lt_parameters = VALUE #( ( selname = 'P_COMPAN'
                               kind    = if_apj_dt_exec_object=>parameter
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '1100' )
                               ( selname = 'P_PLANT'
                               kind    = if_apj_dt_exec_object=>parameter
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '1100' ) ).
    TRY.
*        if_apj_dt_exec_object~get_parameters( IMPORTING et_parameter_val = lt_parameters ).

        if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_root INTO DATA(lo_root).
        out->write( |Exception has occured: { lo_root->get_text(  ) }| ).
    ENDTRY.
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
