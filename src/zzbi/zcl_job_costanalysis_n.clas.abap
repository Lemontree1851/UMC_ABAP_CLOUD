CLASS zcl_job_costanalysis_n DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA: mo_table TYPE REF TO data,
          mo_out   TYPE REF TO if_oo_adt_classrun_out.

    DATA:
      lv_currency  TYPE i_companycode-currency,
      lr_plant     TYPE RANGE OF werks_d,
      ls_plant     LIKE LINE OF lr_plant,
      lv_yearmonth TYPE c LENGTH 6,
      mv_year      TYPE c LENGTH 4,
      mv_month     TYPE n LENGTH 2.

    DATA:
      ls_ztbi_1001 TYPE ztbi_1001,
      lt_ztbi_1001 TYPE STANDARD TABLE OF ztbi_1001,
      ls_ztbi_1002 TYPE ztbi_1002,
      lt_ztbi_1002 TYPE STANDARD TABLE OF ztbi_1002.

    TYPES: BEGIN OF ty_response_res,
             project_no          TYPE string,
             requisition_version TYPE string,
           END OF ty_response_res,
           BEGIN OF ty_response_d,
             results TYPE TABLE OF ty_response_res WITH DEFAULT KEY,
           END OF ty_response_d,
           BEGIN OF ty_response,
             d TYPE ty_response_d,
           END OF ty_response.
    DATA:
      lt_qms_t01_quo_h TYPE STANDARD TABLE OF ty_response_res,
      ls_response      TYPE ty_response.

    TYPES: BEGIN OF ty_response_rest02,
             sap_mat_id          TYPE matnr,
             plant               TYPE c LENGTH 4,
             project_no          TYPE string,
             item_no             TYPE string,
             requisition_version TYPE string,
             smt_prod_cost       TYPE string,
             ai_prod_cost        TYPE string,
             fat_prod_cost       TYPE string,
             companycode         TYPE c LENGTH 4,
             currency            TYPE i_companycode-currency,
           END OF ty_response_rest02,
           BEGIN OF ty_response_dt02,
             results TYPE TABLE OF ty_response_rest02 WITH DEFAULT KEY,
           END OF ty_response_dt02,
           BEGIN OF ty_responset02,
             d TYPE ty_response_dt02,
           END OF ty_responset02.
    DATA:
      lt_qms_t02_quo_d TYPE STANDARD TABLE OF ty_response_rest02,
      ls_responset02   TYPE ty_responset02.

    TYPES: BEGIN OF ty_response_rest07,
             sales_number    TYPE string,
             quo_version     TYPE string,
             sales_d_no      TYPE string,
             sap_mat_id      TYPE matnr,  "製品
             material_number TYPE matnr,  "部品
             person_no1      TYPE string,
             submit_price    TYPE string,
             submit_curr     TYPE string,
             plant           TYPE c LENGTH 4,
             companycode     TYPE c LENGTH 4,
             currency        TYPE i_companycode-currency,
           END OF ty_response_rest07,
           BEGIN OF ty_response_dt07,
             results TYPE TABLE OF ty_response_rest07 WITH DEFAULT KEY,
           END OF ty_response_dt07,
           BEGIN OF ty_responset07,
             d TYPE ty_response_dt07,
           END OF ty_responset07.
    DATA:
      lt_qms_t07_all         TYPE STANDARD TABLE OF ty_response_rest07,
      lt_qms_t07_sum         TYPE STANDARD TABLE OF ty_response_rest07,
      ls_qms_t07_sum         TYPE ty_response_rest07,
      lt_qms_t07_quotation_d TYPE STANDARD TABLE OF ty_response_rest07,
      ls_responset07         TYPE ty_responset07.

    DATA:
      lt_data  TYPE STANDARD TABLE OF ztbi_1001,
      ls_data  TYPE ztbi_1001,
      lt_dataj TYPE STANDARD TABLE OF ztbi_1002,
      ls_dataj TYPE ztbi_1002.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en"></p>
      "!
      init_application_log,
      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime.
*    METHODS get_parameter_id.
    CLASS-DATA:
      mo_application_log TYPE REF TO if_bali_log.
ENDCLASS.



CLASS zcl_job_costanalysis_n IMPLEMENTATION.


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
      CATCH cx_bali_runtime INTO  DATA(cx_erro).
        DATA ls_msg TYPE scx_t100key.
        DATA(lv_msg) = cx_erro->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #( ( selname        = 'P_Plant'
                                  kind           = if_apj_dt_exec_object=>select_option
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = 'プラント'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true )
                                ( selname        = 'P_Year'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = '会計年度'
                                  changeable_ind = abap_true )
                                ( selname        = 'P_Month'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'char'
                                  length         = 2
                                  param_text     = '会計期間'
                                  changeable_ind = abap_true ) ).

    " Return the default parameters values here
    " et_parameter_val
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA: lv_err         TYPE c LENGTH 1,
          lv_date        TYPE datum,
          lv_datetime    TYPE string,
          lv_currencyold TYPE i_companycode-currency,
          lv_msg         TYPE cl_bali_free_text_setter=>ty_text.

    " get parameter id
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
*        WHEN 'P_Compan'.
*          mv_companycode = ls_parameter-low.
        WHEN 'P_Plant'.
*          mv_plant = ls_parameter-low.
          MOVE-CORRESPONDING ls_parameter TO ls_plant.
          APPEND ls_plant TO lr_plant.
        WHEN 'P_Year'.
          mv_year = ls_parameter-low.
        WHEN 'P_Month'.
          mv_month = ls_parameter-low.
      ENDCASE.
    ENDLOOP.

    DATA: lv_datum   TYPE datum,
          lv_gjahr   TYPE gjahr,
          lv_poper   TYPE poper,
          lv_popern2 TYPE n LENGTH 2.

*   Parameterの実行日付
    GET TIME STAMP FIELD DATA(lv_timestamp).
    lv_datetime = lv_timestamp.
    lv_date     = lv_datetime+0(8).

    IF mv_year IS INITIAL.
      zzcl_common_utils=>get_fiscal_year_period( EXPORTING iv_date   = lv_date
                                                 IMPORTING ev_year   = lv_gjahr
                                                           ev_period = lv_poper ).
      lv_popern2 = lv_poper.
      lv_datum = lv_gjahr && lv_popern2 && '01'.
      lv_datum = lv_datum - 1.
      mv_year  = lv_datum+0(4).
      mv_month = lv_datum+4(2).
    ENDIF.

    " 获取日志对象
    init_application_log( ).

*    プラント Parameterの存在Check
    SELECT i_plant~plant,
           i_valuationarea~\_companycode-companycode AS companycode
      FROM i_plant WITH PRIVILEGED ACCESS
      INNER JOIN i_valuationarea ON i_plant~valuationarea = i_valuationarea~valuationarea
     WHERE i_plant~plant IN @lr_plant
     INTO TABLE @DATA(lt_plant).

    IF sy-subrc <> 0.
      CLEAR lv_msg.
      MESSAGE e007(zfico_001) INTO lv_msg.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'E' ).
        CATCH cx_bali_runtime INTO DATA(cx_erro).
          DATA(lv_msge) = cx_erro->get_text( ).
      ENDTRY.
      RETURN.
    ENDIF.
    SORT lt_plant BY plant.

*   会社コード Parameterの存在Check
    SELECT i_companycode~companycode,
           i_companycode~currency
      FROM i_companycode WITH PRIVILEGED ACCESS
      INNER JOIN @lt_plant AS plant ON plant~companycode = i_companycode~companycode
     INTO TABLE @DATA(lt_currency).
    SORT lt_currency BY companycode.

    IF sy-subrc <> 0.
      CLEAR lv_msg.
      MESSAGE e027(zfico_001) INTO lv_msg.
      TRY.
          add_message_to_log( i_text = lv_msg i_type = 'E' ).
        CATCH cx_bali_runtime INTO cx_erro.
          DATA(lv_msgm) = cx_erro->get_text( ).
      ENDTRY.
      RETURN.
    ENDIF.

    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        " Get UQMS Access configuration
        SELECT SINGLE *
          FROM zc_tbc1001
         WHERE zid = 'ZBC003'
           AND zvalue1 = @lv_system_url
          INTO @DATA(ls_config).

        CONDENSE ls_config-zvalue2 NO-GAPS. " ODATA_URL
        CONDENSE ls_config-zvalue3 NO-GAPS. " TOKEN_URL
        CONDENSE ls_config-zvalue4 NO-GAPS. " CLIENT_ID
        CONDENSE ls_config-zvalue5 NO-GAPS. " CLIENT_SECRET
      CATCH cx_abap_context_info_error INTO DATA(cx_erra).
        "handle exception
        DATA(lv_msga) = cx_erra->get_text( ).
    ENDTRY.

    IF ls_config IS NOT INITIAL.
      DATA: lv_fiscalyear       TYPE i_fiscalyearperiodforvariant-fiscalyear,
            lv_fiscalperiod     TYPE i_fiscalyearperiodforvariant-fiscalperiod,
            lv_next_start       TYPE datum,
            lv_next_end         TYPE datum,
            lv_next_start_c(19) TYPE c,
            lv_next_end_c(19)   TYPE c.

      DATA: lv_price1 TYPE p LENGTH 16 DECIMALS 3,
            lv_price2 TYPE p LENGTH 16 DECIMALS 3.

      lv_yearmonth = mv_year && mv_month.

      lv_fiscalyear = mv_year.
      lv_fiscalperiod = mv_month.

      SELECT SINGLE fiscalperiodstartdate,fiscalperiodenddate
        FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS AS fiscal
       WHERE fiscalyearvariant = 'V3'
         AND fiscalyear   = @lv_fiscalyear
         AND fiscalperiod = @lv_fiscalperiod
        INTO @DATA(ls_fiscal).

      lv_next_start = ls_fiscal-fiscalperiodstartdate.
      lv_next_end   = ls_fiscal-fiscalperiodenddate.

      lv_next_start_c = lv_next_start+0(4) && '-' && lv_next_start+4(2) && '-' && lv_next_start+6(2) && 'T00:00:00'.
      lv_next_end_c   = lv_next_end+0(4) && '-' && lv_next_end+4(2) && '-' && lv_next_end+6(2)  && 'T00:00:00'.
      DATA(lv_filter) = |(VALID_F ge datetime'{ lv_next_start_c }' and VALID_F le datetime'{ lv_next_end_c }') | &&
                        |or (VALID_T ge datetime'{ lv_next_start_c }' and VALID_T le datetime'{ lv_next_end_c }') | &&
                        |or (VALID_F le datetime'{ lv_next_start_c }' and VALID_T ge datetime'{ lv_next_end_c }')|.

      DATA(lv_top)  = 1000.
      DATA(lv_skip) = -1000.
      DO.
        lv_skip += 1000.
        zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |{ ls_config-zvalue2 }/odata/v2/TableService/QMS_T01_QUO_H?$top={ lv_top }&$skip={ lv_skip }|
                                                                iv_odata_filter  = lv_filter
                                                                iv_token_url     = CONV #( ls_config-zvalue3 )
                                                                iv_client_id     = CONV #( ls_config-zvalue4 )
                                                                iv_client_secret = CONV #( ls_config-zvalue5 )
                                                                iv_authtype      = 'OAuth2.0'
                                                      IMPORTING ev_status_code   = DATA(lv_status_code)
                                                                ev_response      = DATA(lv_response) ).

        IF lv_status_code = 200.
          REPLACE ALL OCCURRENCES OF `\/Date(` IN lv_response  WITH ``.
          REPLACE ALL OCCURRENCES OF `)\/` IN lv_response  WITH ``.

          /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                     CHANGING  data = ls_response ).

          IF ls_response-d-results IS NOT INITIAL.
            APPEND LINES OF ls_response-d-results TO lt_qms_t01_quo_h.
          ELSE.
            EXIT.
          ENDIF.
        ELSE.
          TRY.
              add_message_to_log( i_text = 'データはQMS_T01_QUO_Hで存在していません' i_type = 'E' ).
            CATCH cx_bali_runtime INTO DATA(cx_errb).
              DATA(lv_msgb) = cx_errb->get_text( ).
          ENDTRY.
          RETURN.
        ENDIF.
        CLEAR ls_response.
      ENDDO.
      SORT lt_qms_t01_quo_h BY project_no requisition_version.

      DATA(lv_skip2) = -1000.
      DO.
        lv_skip2 += 1000.
        zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |{ ls_config-zvalue2 }/odata/v2/TableService/QMS_T02_QUO_D?$top={ lv_top }&$skip={ lv_skip2 }|
                                                                iv_token_url     = CONV #( ls_config-zvalue3 )
                                                                iv_client_id     = CONV #( ls_config-zvalue4 )
                                                                iv_client_secret = CONV #( ls_config-zvalue5 )
                                                                iv_authtype      = 'OAuth2.0'
                                                      IMPORTING ev_status_code   = DATA(lv_status_codet02)
                                                                ev_response      = DATA(lv_responset02) ).
        IF lv_status_codet02 = 200.
          REPLACE ALL OCCURRENCES OF `\/Date(` IN lv_responset02  WITH ``.
          REPLACE ALL OCCURRENCES OF `)\/` IN lv_responset02  WITH ``.

          /ui2/cl_json=>deserialize( EXPORTING json = lv_responset02
                                     CHANGING  data = ls_responset02 ).

          IF ls_responset02-d-results IS NOT INITIAL.
            LOOP AT ls_responset02-d-results ASSIGNING FIELD-SYMBOL(<lfs_responset02>).
              READ TABLE lt_qms_t01_quo_h TRANSPORTING NO FIELDS WITH KEY project_no          = <lfs_responset02>-project_no
                                                                          requisition_version = <lfs_responset02>-requisition_version
                                                                          BINARY SEARCH.
              IF sy-subrc = 0.
                IF  <lfs_responset02>-sap_mat_id IS NOT INITIAL
                AND <lfs_responset02>-plant IN lr_plant.

                  READ TABLE lt_plant INTO DATA(ls_plantc) WITH KEY plant = <lfs_responset02>-plant BINARY SEARCH.
                  IF sy-subrc = 0.
                    <lfs_responset02>-companycode = ls_plantc-companycode.
                  ENDIF.

                  READ TABLE lt_currency INTO DATA(ls_currency) WITH KEY companycode = ls_plantc-companycode.
                  IF sy-subrc = 0.
                    <lfs_responset02>-currency = ls_currency-currency.
                  ENDIF.

                  APPEND <lfs_responset02> TO lt_qms_t02_quo_d.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ELSE.
            EXIT.
          ENDIF.
        ELSE.
          TRY.
              add_message_to_log( i_text = 'データはQMS_T02_QUO_Dで存在していません' i_type = 'E' ).
            CATCH cx_bali_runtime INTO DATA(cx_errc).
              DATA(lv_msgc) = cx_errc->get_text( ).
          ENDTRY.
          RETURN.
        ENDIF.
        CLEAR ls_responset02.
      ENDDO.
      SORT lt_qms_t02_quo_d BY project_no requisition_version item_no sap_mat_id.

      DATA(lv_skip3) = -1000.
      DO.
        lv_skip3 += 1000.
        zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |{ ls_config-zvalue2 }/odata/v2/TableService/QMS_T07_QUOTATION_D?$top={ lv_top }&$skip={ lv_skip3 }&sap-language={ zzcl_common_utils=>get_current_language(  ) }|
                                                                iv_token_url     = CONV #( ls_config-zvalue3 )
                                                                iv_client_id     = CONV #( ls_config-zvalue4 )
                                                                iv_client_secret = CONV #( ls_config-zvalue5 )
                                                                iv_authtype      = 'OAuth2.0'
                                                      IMPORTING ev_status_code   = DATA(lv_status_codet07)
                                                                ev_response      = DATA(lv_responset07) ).
        IF lv_status_codet07 = 200.
          REPLACE ALL OCCURRENCES OF `\/Date(` IN lv_responset07  WITH ``.
          REPLACE ALL OCCURRENCES OF `)\/` IN lv_responset07  WITH ``.

          /ui2/cl_json=>deserialize( EXPORTING json = lv_responset07
                                     CHANGING  data = ls_responset07 ).

          IF ls_responset07-d-results IS NOT INITIAL.
            DELETE ls_responset07-d-results WHERE material_number IS INITIAL.
            LOOP AT ls_responset07-d-results ASSIGNING FIELD-SYMBOL(<fs_responset07>).
              READ TABLE lt_qms_t02_quo_d INTO DATA(lv_t02)
                WITH KEY project_no           = <fs_responset07>-sales_number
                         requisition_version  = <fs_responset07>-quo_version
                         item_no              = <fs_responset07>-sales_d_no
*                        sap_mat_id           = <fs_responset07>-sap_mat_id  " DEL BY XINLEI XU 2025/03/28 BUG Fixed
                         BINARY SEARCH.
              IF sy-subrc = 0.
                <fs_responset07>-plant       = lv_t02-plant.
                <fs_responset07>-companycode = lv_t02-companycode.
                <fs_responset07>-currency    = lv_t02-currency.
                <fs_responset07>-sap_mat_id  = lv_t02-sap_mat_id. " ADD BY XINLEI XU 2025/03/28 BUG Fixed
                APPEND <fs_responset07> TO lt_qms_t07_all.
              ENDIF.
            ENDLOOP.
          ELSE.
            EXIT.
          ENDIF.
        ELSE.
          TRY.
              add_message_to_log( i_text = 'データはQQMS_T07_QUOTATION_Dで存在していません' i_type = 'E' ).
            CATCH cx_bali_runtime INTO DATA(cx_errf).
              DATA(lv_msgf) = cx_errf->get_text( ).
          ENDTRY.
          RETURN.
        ENDIF.
        CLEAR lv_responset07.
      ENDDO.

      SORT lt_qms_t07_all BY sap_mat_id quo_version.

      LOOP AT lt_qms_t07_all ASSIGNING FIELD-SYMBOL(<lfs_qms_t07>)
                          GROUP BY ( sap_mat_id  = <lfs_qms_t07>-sap_mat_id
                                     quo_version = <lfs_qms_t07>-quo_version ).
        CLEAR ls_qms_t07_sum .
        ls_qms_t07_sum  = <lfs_qms_t07>.
        CLEAR ls_qms_t07_sum-submit_price.
        LOOP AT GROUP <lfs_qms_t07> ASSIGNING FIELD-SYMBOL(<lfs_qms_t07g>).
          ls_qms_t07_sum-submit_price = ls_qms_t07_sum-submit_price + <lfs_qms_t07g>-submit_price.
        ENDLOOP.
        APPEND ls_qms_t07_sum TO lt_qms_t07_sum.
      ENDLOOP.

      SORT lt_qms_t07_sum BY sap_mat_id   ASCENDING
                             quo_version  ASCENDING
                             submit_price ASCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_qms_t07_sum COMPARING sap_mat_id.

      LOOP AT lt_qms_t07_all ASSIGNING FIELD-SYMBOL(<lfs_t07_all>).
        lv_currency = <lfs_t07_all>-currency.
        READ TABLE lt_qms_t07_sum TRANSPORTING NO FIELDS WITH KEY sap_mat_id  = <lfs_t07_all>-sap_mat_id
                                                                  quo_version = <lfs_t07_all>-quo_version
                                                                  BINARY SEARCH.
        IF sy-subrc = 0.
          IF <lfs_t07_all>-submit_curr NE lv_currency.
            TRY.
                lv_currencyold = <lfs_t07_all>-submit_curr.
                cl_exchange_rates=>convert_to_local_currency(
                  EXPORTING
                    date              = lv_date
                    foreign_amount    = <lfs_t07_all>-submit_price
                    foreign_currency  = lv_currencyold
                    local_currency    = lv_currency
                  IMPORTING
                    local_amount      = <lfs_t07_all>-submit_price
                ).
              CATCH cx_exchange_rates INTO DATA(cx_errd).
                DATA ls_msgd TYPE scx_t100key.
                DATA(lv_msgd) = cx_errd->get_text( ).
            ENDTRY.
            <lfs_t07_all>-submit_curr = lv_currency.
          ENDIF.
          APPEND <lfs_t07_all> TO lt_qms_t07_quotation_d.
        ENDIF.
      ENDLOOP.
    ENDIF.

*   品目マスタから製品が属される利益センタを抽出
    IF lt_qms_t07_quotation_d IS NOT INITIAL.
      SELECT product~plant,
             product~product,
             product~profitcenter,
             ptext~profitcentername
        FROM i_productplantbasic WITH PRIVILEGED ACCESS AS product
*&--MOD BEGIN BY XINLEI XU 2025/02/24
*     INNER JOIN @lt_qms_t07_quotation_d AS t07
*             ON ( t07~sap_mat_id      = product~product
*             OR   t07~material_number = product~product )
*            AND t07~plant = product~plant
        LEFT JOIN i_profitcentertext WITH PRIVILEGED ACCESS AS ptext
               ON ptext~profitcenter = product~profitcenter
              AND ptext~language     = @sy-langu
          FOR ALL ENTRIES IN @lt_qms_t07_quotation_d
        WHERE product~plant = @lt_qms_t07_quotation_d-plant
          AND ( product~product = @lt_qms_t07_quotation_d-sap_mat_id OR
                product~product = @lt_qms_t07_quotation_d-material_number )
*&--MOD END BY XINLEI XU 2025/02/24
       INTO TABLE @DATA(lt_productplantbasic).
      SORT lt_productplantbasic BY plant product.

*&--DEL BEGIN BY XINLEI XU 2025/04/10
*    ENDIF.

*   該当月の支払請求書を抽出
*   各部品の最終受入単価を取得する
*   発注伝票を取得
*   最終受入仕入を取得
*    DATA(lt_qms_t07) = lt_qms_t07_quotation_d.
*    SORT lt_qms_t07 BY material_number ASCENDING.
*    DELETE ADJACENT DUPLICATES FROM lt_qms_t07 COMPARING material_number.

*    IF lt_qms_t07 IS NOT INITIAL.
*      SELECT  companycodet~companycodename,
*              aplant~plantname,
*              suplrinvc~supplierinvoice, "仕入先請求書番号
*              suplrinvc~purchaseorderitemmaterial AS material,       "構成部品
*              suplrinvc~quantityinpurchaseorderunit AS quantity,       "数量
*              suplrinvc~plant,          "プラント
*
*              supplier~postingdate,     "転記日付
*              supplier~companycode,     "会社コード
*              supplier~invoicegrossamount AS supplierinvoiceitemamount, "請求書金額
*              supplier~documentcurrency AS currency,  "通貨
*
**              suplrinvc~supplierinvoiceitemamount, "請求書金額
**              suplrinvc~\_currency-currency,  "通貨
*
*              itempurord~purchaseorder, "発注伝票
*              t07~material_number,
*              t07~currency AS currencyold,
*              product1~productdescription AS materialdescription,
*              product2~productdescription AS productdescription,
*              t07~sap_mat_id,
*              purchase~supplier         "最終受入仕入先
*        FROM @lt_qms_t07 AS t07
*   INNER JOIN i_suplrinvcitempurordrefapi01 WITH PRIVILEGED ACCESS AS suplrinvc
*          ON t07~material_number       = suplrinvc~purchaseorderitemmaterial
*         AND suplrinvc~plant           = t07~plant
*  INNER JOIN i_supplierinvoiceapi01 WITH PRIVILEGED ACCESS AS supplier
*          ON supplier~supplierinvoice = suplrinvc~supplierinvoice
*         AND supplier~companycode      = t07~companycode
*  INNER JOIN i_suplrinvcitempurordrefapi01 WITH PRIVILEGED ACCESS AS itempurord
*          ON itempurord~supplierinvoice = supplier~supplierinvoice
*  INNER JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS purchase
*          ON purchase~purchaseorder = itempurord~purchaseorder
*
*   LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS product1
*          ON product1~product  = t07~material_number
*         AND product1~language = @sy-langu
*   LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS product2
*          ON product2~product  = t07~sap_mat_id
*         AND product2~language = @sy-langu
*   LEFT JOIN i_companycode WITH PRIVILEGED ACCESS AS companycodet
*          ON companycodet~companycode  = supplier~companycode
*         AND companycodet~language     = @sy-langu
*   LEFT JOIN i_plant WITH PRIVILEGED ACCESS AS aplant
*          ON aplant~plant   = suplrinvc~plant
*         AND aplant~language     = @sy-langu
**       WHERE supplier~postingdate     >= @lv_next_start
**         AND supplier~postingdate     <= @lv_next_end
*       WHERE supplier~postingdate     <= @lv_next_end
*         AND supplier~reversedocument = @space
*        INTO TABLE @DATA(lt_supplier).
*
*      SORT lt_supplier BY supplierinvoice ASCENDING
*                          plant           ASCENDING
*                          material        ASCENDING
*                          postingdate     DESCENDING.
*      DELETE ADJACENT DUPLICATES FROM lt_supplier COMPARING supplierinvoice plant material.
*&--DEL END BY XINLEI XU 2025/04/10

*&--ADD BEGIN BY XINLEI XU 2025/04/10
      SELECT invoice_h~fiscalyear,
             invoice_h~supplierinvoice,
             invoice_h~companycode,
             invoice_h~postingdate,
             invoice_h~documentcurrency AS currency,

             invoice_i~supplierinvoiceitem,
             invoice_i~plant,
             invoice_i~purchaseorderitemmaterial AS material,
             invoice_i~purchaseorderitemmaterial AS material_number,
             invoice_i~supplierinvoiceitemamount,
             invoice_i~quantityinpurchaseorderunit AS quantity,
             invoice_i~purchaseorder,

             po~supplier, " 最終受入仕入先
             supplier~suppliername
        FROM i_supplierinvoiceapi01 AS invoice_h
        JOIN i_suplrinvcitempurordrefapi01 WITH PRIVILEGED ACCESS AS invoice_i
                                           ON invoice_i~fiscalyear = invoice_h~fiscalyear
                                          AND invoice_i~supplierinvoice = invoice_h~supplierinvoice
        LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS po ON po~purchaseorder = invoice_i~purchaseorder
        LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS supplier ON supplier~supplier = po~supplier
         FOR ALL ENTRIES IN @lt_qms_t07_quotation_d
       WHERE invoice_h~companycode = @lt_qms_t07_quotation_d-companycode
         AND invoice_i~plant = @lt_qms_t07_quotation_d-plant
         AND invoice_i~purchaseorderitemmaterial = @lt_qms_t07_quotation_d-material_number
        INTO TABLE @DATA(lt_supplier).

      SORT lt_supplier BY companycode plant material
                          fiscalyear DESCENDING
                          supplierinvoice DESCENDING
                          supplierinvoiceitem DESCENDING.

      DELETE ADJACENT DUPLICATES FROM lt_supplier COMPARING companycode plant material.

      SELECT plant,
             plantname
        FROM i_plant WITH PRIVILEGED ACCESS
        INTO TABLE @DATA(lt_plantname).
      SORT lt_plantname BY plant.

      SELECT product,
             productdescription AS productdescription
        FROM i_productdescription WITH PRIVILEGED ACCESS
       WHERE language = @sy-langu
        INTO TABLE @DATA(lt_productdesc).
      SORT lt_productdesc BY product.

      SELECT companycode,
             companycodename
        FROM i_companycode WITH PRIVILEGED ACCESS
        INTO TABLE @DATA(lt_companycodename).
      SORT lt_companycodename BY companycode.
*&--ADD END BY XINLEI XU 2025/04/10

      LOOP AT lt_supplier ASSIGNING FIELD-SYMBOL(<lfs_supplierc>).
        CLEAR lv_currency.
        READ TABLE lt_qms_t07_quotation_d INTO DATA(ls_qms_t07) WITH KEY companycode = <lfs_supplierc>-companycode
                                                                         plant = <lfs_supplierc>-plant
                                                                         material_number = <lfs_supplierc>-material_number.
        IF sy-subrc = 0.
          lv_currency = ls_qms_t07-currency.
        ENDIF.

        IF <lfs_supplierc>-currency NE lv_currency.
          TRY.
              lv_currencyold = <lfs_supplierc>-currency.
              cl_exchange_rates=>convert_to_local_currency(
                EXPORTING
                  date              = lv_date
                  foreign_amount    = <lfs_supplierc>-supplierinvoiceitemamount
                  foreign_currency  = lv_currencyold
                  local_currency    = lv_currency
                IMPORTING
                  local_amount      = <lfs_supplierc>-supplierinvoiceitemamount
              ).
            CATCH cx_exchange_rates INTO DATA(cx_errg).
              DATA ls_msgg TYPE scx_t100key.
              DATA(lv_msgg) = cx_errg->get_text( ).
          ENDTRY.
          <lfs_supplierc>-currency = lv_currency.
        ENDIF.
      ENDLOOP.
    ENDIF.

*&--DEL BEGIN BY XINLEI XU 2025/04/10
*    SELECT t07~companycode,
*           companycodet~companycodename,
*           t07~plant,
*           aplant~plantname,
*           t07~material_number,
*           product1~productdescription AS materialdescription,
*           t07~sap_mat_id,
*           product2~productdescription AS productdescription
*      FROM @lt_qms_t07_quotation_d AS t07
* LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS product1
*        ON product1~product  = t07~material_number
*       AND product1~language = @sy-langu
* LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS product2
*        ON product2~product  = t07~sap_mat_id
*       AND product2~language = @sy-langu
* LEFT JOIN i_companycode WITH PRIVILEGED ACCESS AS companycodet
*        ON companycodet~companycode = t07~companycode
*       AND companycodet~language    = @sy-langu
* LEFT JOIN i_plant WITH PRIVILEGED ACCESS AS aplant
*        ON aplant~plant    = t07~plant
*       AND aplant~language = @sy-langu
*      INTO TABLE @DATA(lt_name).
*&--DEL END BY XINLEI XU 2025/04/10

*   各部品の最終受入日付を取得
    IF lt_supplier IS NOT INITIAL.
      SELECT sup~supplierinvoice,    "仕入先請求書番号
             sup~postingdate         "最終受入日付
        FROM i_supplierinvoiceapi01 WITH PRIVILEGED ACCESS AS sup
*&--MOD BEGIN BY XINLEI XU 2025/02/24
*      JOIN  @lt_supplier AS supplier
*        ON supplier~supplierinvoice = sup~supplierinvoice
         FOR ALL ENTRIES IN @lt_supplier
       WHERE sup~companycode = @lt_supplier-companycode
         AND sup~supplierinvoice = @lt_supplier-supplierinvoice
*&--MOD END BY XINLEI XU 2025/02/24
         AND sup~reversedocument = @space
       INTO TABLE @DATA(lt_sup).
      SORT lt_sup BY supplierinvoice.
    ENDIF.

****    購買情報マスタから各部品の固定仕入先情報を取得
    IF lt_qms_t07_quotation_d IS NOT INITIAL.
      SELECT info~supplier,"仕入先番号(複数取得した場合は「/」で区切りする)
             plntdata~plant,
             info~material,
             supplier~suppliername
        FROM i_purchasinginforecordapi01    WITH PRIVILEGED ACCESS AS info
        JOIN i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS AS plntdata
          ON info~purchasinginforecord = plntdata~purchasinginforecord
        LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS supplier ON supplier~supplier = info~supplier
*&--MOD BEGIN BY XINLEI XU 2025/02/24
*      JOIN  @lt_qms_t07_quotation_d AS t07
*         ON plntdata~plant     = t07~plant
*        AND info~material      = t07~material_number "部品
          FOR ALL ENTRIES IN @lt_qms_t07_quotation_d
        WHERE plntdata~plant = @lt_qms_t07_quotation_d-plant
          AND info~material  = @lt_qms_t07_quotation_d-material_number
*&--MOD END BY XINLEI XU 2025/02/24
         INTO TABLE @DATA(lt_info).
      SORT lt_info BY plant material.

*    各部品の最新標準単価＆実際単価を取得
      SELECT basic~valuationarea AS plant,
             basic~product AS material,
             basic~standardprice,
             basic~movingaverageprice,
             basic~priceunitqty,
             basic~currency
        FROM i_productvaluationbasic WITH PRIVILEGED ACCESS AS basic
*&--MOD BEGIN BY XINLEI XU 2025/02/24
*        JOIN @lt_qms_t07_quotation_d AS t07
*          ON basic~valuationarea = t07~plant
*         AND basic~product       = t07~material_number "部品
          FOR ALL ENTRIES IN @lt_qms_t07_quotation_d
        WHERE basic~valuationarea = @lt_qms_t07_quotation_d-plant
          AND basic~product       = @lt_qms_t07_quotation_d-material_number
*&--MOD END BY XINLEI XU 2025/02/24
         INTO TABLE @DATA(lt_basic).
      SORT lt_basic BY plant material.

*    販売請求書から当月製品の販売数量を取得
      SELECT bil~companycode,         "会社コード
             bil~billingdocumentdate, "請求書日付
             bil~product AS material, "製品
             bil~billingquantity,     "請求書数量
             bil~billingquantityunit  "請求書数量単位
        FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS bil
*&--MOD BEGIN BY XINLEI XU 2025/02/24
*        JOIN @lt_qms_t07_quotation_d AS t07
*          ON t07~sap_mat_id = bil~product      "製品
*       WHERE bil~companycode  = t07~companycode
         FOR ALL ENTRIES IN @lt_qms_t07_quotation_d
       WHERE bil~companycode = @lt_qms_t07_quotation_d-companycode
         AND bil~product     = @lt_qms_t07_quotation_d-sap_mat_id
*&--MOD END BY XINLEI XU 2025/02/24
         AND bil~billingdocumentdate >= @lv_next_start
         AND bil~billingdocumentdate <= @lv_next_end
        INTO TABLE @DATA(lt_bil).
      SORT lt_bil BY material.

*    品目マスタからMRP管理者を抽出
      SELECT mrp~plant,
             mrp~product AS material,
             mrp~mrpresponsible  " MRP管理者
        FROM i_productplantbasic WITH PRIVILEGED ACCESS AS mrp
*&--MOD BEGIN BY XINLEI XU 2025/02/24
*        JOIN @lt_qms_t07_quotation_d AS t07
*          ON mrp~plant    = t07~plant
*         AND mrp~product  = t07~material_number
         FOR ALL ENTRIES IN @lt_qms_t07_quotation_d
       WHERE mrp~plant = @lt_qms_t07_quotation_d-plant
         AND mrp~product = @lt_qms_t07_quotation_d-material_number
*&--MOD END BY XINLEI XU 2025/02/24
       INTO TABLE @DATA(lt_mrp).
      SORT lt_mrp BY plant material.
    ENDIF.

*     得意先BPコードと名称を抽出
    SELECT busi~searchterm2,
           busi~businesspartner,    "ビジネスパートナ
           busi~businesspartnername "ビジネスパートナ名
      FROM i_businesspartner WITH PRIVILEGED ACCESS AS busi
      JOIN @lt_mrp AS mrp ON busi~searchterm2 = substring( mrp~mrpresponsible ,2,2 )   "「MRP管理者」末2桁
       INTO TABLE @DATA(lt_busi).
    SORT lt_busi BY searchterm2.
    DELETE ADJACENT DUPLICATES FROM lt_busi COMPARING searchterm2.

    LOOP AT lt_qms_t07_quotation_d ASSIGNING FIELD-SYMBOL(<lfs_qmst07>).
      lv_currency = <lfs_qmst07>-currency.

      CLEAR ls_data.
      ls_data-zyear       = mv_year.
      ls_data-zmonth      = mv_month.
      ls_data-yearmonth   = lv_yearmonth.
      ls_data-companycode = <lfs_qmst07>-companycode.
      ls_data-plant       = <lfs_qmst07>-plant.
      ls_data-product     = <lfs_qmst07>-sap_mat_id.
      ls_data-material    = <lfs_qmst07>-material_number.

      READ TABLE lt_companycodename INTO DATA(ls_companycodename) WITH KEY companycode = <lfs_qmst07>-companycode BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-companycodetext = ls_companycodename-companycodename.
      ENDIF.

      READ TABLE lt_plantname INTO DATA(ls_plantname) WITH KEY plant = <lfs_qmst07>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-planttext = ls_plantname-plantname.
      ENDIF.

      READ TABLE lt_productdesc INTO DATA(ls_productdesc) WITH KEY product = <lfs_qmst07>-sap_mat_id BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-productdescription = ls_productdesc-productdescription.
      ENDIF.

      READ TABLE lt_productdesc INTO ls_productdesc WITH KEY product = <lfs_qmst07>-material_number BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-materialdescription = ls_productdesc-productdescription.
      ENDIF.

      READ TABLE lt_productplantbasic ASSIGNING FIELD-SYMBOL(<lfs_productplantbasic>) WITH KEY product = ls_data-material
                                                                                               plant   = ls_data-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-profitcenter     = <lfs_productplantbasic>-profitcenter.
        ls_data-profitcentername = <lfs_productplantbasic>-profitcentername.
      ENDIF.

      ls_data-quantity = <lfs_qmst07>-person_no1.

      READ TABLE lt_mrp ASSIGNING FIELD-SYMBOL(<lfs_mrp>) WITH KEY plant    = <lfs_qmst07>-plant
                                                                   material = <lfs_qmst07>-material_number BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_busi ASSIGNING FIELD-SYMBOL(<lfs_busi>) WITH KEY searchterm2 = <lfs_mrp>-mrpresponsible+1(2) BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-customer     = <lfs_busi>-businesspartner.
          ls_data-customername = <lfs_busi>-businesspartnername.
        ENDIF.
      ENDIF.

      ls_data-estimatedprice = zzcl_common_utils=>conversion_amount( iv_alpha = 'IN'
                                                                     iv_currency = lv_currency
                                                                     iv_input = <lfs_qmst07>-submit_price ).

      READ TABLE lt_supplier INTO DATA(ls_supplier) WITH KEY companycode = <lfs_qmst07>-companycode
                                                             plant = <lfs_qmst07>-plant
                                                             material = <lfs_qmst07>-material_number
                                                             BINARY SEARCH.
      IF sy-subrc = 0.
        IF ls_supplier-quantity IS NOT INITIAL.
          ls_data-finalprice = ls_supplier-supplierinvoiceitemamount / ls_supplier-quantity.
        ENDIF.
        READ TABLE lt_sup ASSIGNING FIELD-SYMBOL(<lfs_sup>) WITH KEY supplierinvoice = ls_supplier-supplierinvoice BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-finalpostingdate = <lfs_sup>-postingdate.
        ENDIF.

        ls_data-finalsupplier = ls_supplier-supplier.
        ls_data-finalsuppliername = ls_supplier-suppliername.
        ls_data-finalpurchaseorder = ls_supplier-purchaseorder.
      ENDIF.

*&--MOD BEGIN BY XINLEI XU 2025/04/01
*
*      LOOP AT lt_info ASSIGNING FIELD-SYMBOL(<lfs_info>)
*                WHERE plant    = <lfs_qmst07>-plant
*                  AND material = <lfs_qmst07>-material_number.
*        IF ls_data-fixedsupplier IS INITIAL.
*          ls_data-fixedsupplier = <lfs_info>-supplier.
*        ELSE.
*          ls_data-fixedsupplier = ls_data-fixedsupplier && '/' && <lfs_info>-supplier.
*        ENDIF.
*      ENDLOOP.

      LOOP AT lt_info ASSIGNING FIELD-SYMBOL(<lfs_info>) WHERE plant    = <lfs_qmst07>-plant
                                                           AND material = <lfs_qmst07>-material_number.
        IF ls_data-fixedsupplier IS INITIAL.
          ls_data-fixedsupplier = |{ <lfs_info>-supplier ALPHA = OUT }|.
          ls_data-fixedsuppliername = <lfs_info>-suppliername.
        ELSE.
          ls_data-fixedsupplier = ls_data-fixedsupplier && '/' && |{ <lfs_info>-supplier ALPHA = OUT }|.
          ls_data-fixedsuppliername = ls_data-fixedsuppliername && '/' && ls_data-fixedsuppliername.
        ENDIF.
      ENDLOOP.
*&--MOD END BY XINLEI XU 2025/04/01

      READ TABLE lt_basic ASSIGNING FIELD-SYMBOL(<lfs_basic>) WITH KEY plant    = <lfs_qmst07>-plant
                                                                       material = <lfs_qmst07>-material_number BINARY SEARCH.
      IF sy-subrc = 0.
        CLEAR:lv_price1,lv_price2.
        TRY.
            lv_price1 = <lfs_basic>-standardprice / <lfs_basic>-priceunitqty.
            lv_price2 = <lfs_basic>-movingaverageprice / <lfs_basic>-priceunitqty.

            lv_price1 = zzcl_common_utils=>conversion_amount(
                                          iv_alpha = 'OUT'
                                          iv_currency = <lfs_basic>-currency
                                          iv_input = lv_price1 ).
            lv_price2 = zzcl_common_utils=>conversion_amount(
                                          iv_alpha = 'OUT'
                                          iv_currency = <lfs_basic>-currency
                                          iv_input = lv_price2 ).

            ls_data-standardprice      = lv_price1.
            ls_data-movingaverageprice = lv_price2.
          CATCH cx_root INTO DATA(xexc).
            ls_data-standardprice      = lv_price1.
            ls_data-movingaverageprice = lv_price2.
        ENDTRY.

        ls_data-standardprice      = condense( ls_data-standardprice ).
        ls_data-movingaverageprice = condense( ls_data-movingaverageprice ).

        IF <lfs_basic>-currency NE lv_currency.
          TRY.
              cl_exchange_rates=>convert_to_local_currency(
                EXPORTING
                  date              = lv_date
                  foreign_amount    = <lfs_basic>-standardprice
                  foreign_currency  = <lfs_basic>-currency
                  local_currency    = lv_currency
                IMPORTING
                  local_amount      = <lfs_basic>-standardprice
              ).
              cl_exchange_rates=>convert_to_local_currency(
                EXPORTING
                  date              = lv_date
                  foreign_amount    = <lfs_basic>-movingaverageprice
                  foreign_currency  = <lfs_basic>-currency
                  local_currency    = lv_currency
                IMPORTING
                  local_amount      = <lfs_basic>-movingaverageprice
              ).
            CATCH cx_exchange_rates INTO DATA(cx_erre).
              DATA ls_msge TYPE scx_t100key.
              DATA(lv_msgee) = cx_erre->get_text( ).
          ENDTRY.
          <lfs_basic>-currency = lv_currency.
        ENDIF.
        ls_data-currency = <lfs_basic>-currency.
      ENDIF.

      READ TABLE lt_bil ASSIGNING FIELD-SYMBOL(<lfs_bil>) WITH KEY material = <lfs_qmst07>-sap_mat_id BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-billingquantity     = <lfs_bil>-billingquantity.
        ls_data-billingquantityunit = <lfs_bil>-billingquantityunit.
      ENDIF.

      ls_data-sales_number = <lfs_qmst07>-sales_number.
      ls_data-quo_version  = <lfs_qmst07>-quo_version.
      ls_data-sales_d_no   = <lfs_qmst07>-sales_d_no.
      APPEND ls_data TO lt_data.
    ENDLOOP.

    IF lt_data IS NOT INITIAL.
      MODIFY ztbi_1001 FROM TABLE @lt_data.

      TRY.
          add_message_to_log( i_text = '部品費逆ザヤ防止分析が更新に成功しました' i_type = 'S' ).
        CATCH cx_bali_runtime  INTO DATA(cx_errh).
          DATA ls_msgh TYPE scx_t100key.
          DATA(lv_msgh) = cx_errh->get_text( ).
      ENDTRY.
    ELSE.
      TRY.
          add_message_to_log( i_text = '部品費逆ザヤ防止分析が更新に失敗しました' i_type = 'E' ).
        CATCH cx_bali_runtime INTO DATA(cx_erri).
          DATA ls_msgi TYPE scx_t100key.
          DATA(lv_msgi) = cx_erri->get_text( ).
      ENDTRY.
    ENDIF.

    DATA: lv_month      TYPE n LENGTH 3,
          lv_yearmonthn TYPE ztfi_1020-yearmonth.

    lv_month = mv_month.
    lv_yearmonthn = mv_year && lv_month.

*     工程別加工費実績から各製品の加工費実績を取得
    IF lt_qms_t02_quo_d IS NOT INITIAL.
      SELECT mfgorder~product,
             mfgorder~producedproduct,
             mfgorder~productionsupervisor,
             mfgorder~companycode,
             mfgorder~totalactualcost,
             mfgorder~mfgorderconfirmedyieldqty AS yieldqty
        FROM ztfi_1020 AS mfgorder
*&--MOD BEGIN BY XINLEI XU 2025/02/24
*      JOIN @lt_qms_t02_quo_d AS t02
*        ON mfgorder~product = t02~sap_mat_id
*     WHERE mfgorder~companycode = t02~companycode
          FOR ALL ENTRIES IN @lt_qms_t02_quo_d
        WHERE mfgorder~companycode = @lt_qms_t02_quo_d-companycode
          AND mfgorder~product = @lt_qms_t02_quo_d-sap_mat_id
*&--MOD END BY XINLEI XU 2025/02/24
          AND mfgorder~yearmonth   = @lv_yearmonthn
        INTO TABLE @DATA(lt_mfgorder).

*      販売請求書から当月製品の販売数量を取得
      SELECT bill~companycode,
             bill~billingdocumentdate,
             bill~product,
             bill~billingquantity,
             bill~billingquantityunit
        FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS bill
*&--MOD BEGIN BY XINLEI XU 2025/02/24
*        JOIN @lt_qms_t02_quo_d AS t02
*          ON t02~sap_mat_id = bill~product
*       WHERE bill~companycode = t02~companycode
         FOR ALL ENTRIES IN @lt_qms_t02_quo_d
       WHERE bill~companycode = @lt_qms_t02_quo_d-companycode
         AND bill~product = @lt_qms_t02_quo_d-sap_mat_id
*&--MOD END BY XINLEI XU 2025/02/24
         AND bill~billingdocumentdate >= @lv_next_start
         AND bill~billingdocumentdate <= @lv_next_end
       INTO TABLE @DATA(lt_bill).
      SORT lt_bill BY product.

      SELECT basic~valuationarea AS plant,"プラント
             basic~product,             "部品
             basic~currency             "会社コード通貨
        FROM i_productvaluationbasic WITH PRIVILEGED ACCESS AS basic
*&--MOD BEGIN BY XINLEI XU 2025/02/24
*        JOIN @lt_qms_t02_quo_d AS t02
*          ON basic~valuationarea = t02~plant
*         AND basic~product       = t02~sap_mat_id
         FOR ALL ENTRIES IN @lt_qms_t02_quo_d
       WHERE basic~valuationarea = @lt_qms_t02_quo_d-plant
         AND basic~product = @lt_qms_t02_quo_d-sap_mat_id
*&--MOD END BY XINLEI XU 2025/02/24
        INTO TABLE @DATA(lt_basic2).
      SORT lt_basic2 BY plant product.
    ENDIF.

    LOOP AT lt_qms_t02_quo_d ASSIGNING FIELD-SYMBOL(<lfs_t02>).
      CLEAR ls_dataj.
      ls_dataj-zyear       = mv_year.
      ls_dataj-zmonth      = mv_month.
      ls_dataj-yearmonth   = lv_yearmonth.
      ls_dataj-companycode = <lfs_t02>-companycode.
      ls_dataj-plant       = <lfs_t02>-plant.
      ls_dataj-product     = <lfs_t02>-sap_mat_id.

      READ TABLE lt_companycodename INTO ls_companycodename WITH KEY companycode = <lfs_t02>-companycode BINARY SEARCH.
      IF sy-subrc = 0.
        ls_dataj-companycodetext = ls_companycodename-companycodename.
      ENDIF.

      READ TABLE lt_plantname INTO ls_plantname WITH KEY plant = <lfs_t02>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_dataj-planttext = ls_plantname-plantname.
      ENDIF.

      READ TABLE lt_productdesc INTO ls_productdesc WITH KEY product = <lfs_t02>-sap_mat_id BINARY SEARCH.
      IF sy-subrc = 0.
        ls_dataj-productdescription = ls_productdesc-productdescription.
      ENDIF.

      READ TABLE lt_productplantbasic ASSIGNING <lfs_productplantbasic> WITH KEY product = ls_dataj-product
                                                                                 plant   = ls_dataj-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_dataj-profitcenter     = <lfs_productplantbasic>-profitcenter.
        ls_dataj-profitcentername = <lfs_productplantbasic>-profitcentername.
      ENDIF.

      ls_dataj-estimatedprice_smt = <lfs_t02>-smt_prod_cost.
      ls_dataj-estimatedprice_ai = <lfs_t02>-ai_prod_cost.
      ls_dataj-estimatedprice_fat = <lfs_t02>-fat_prod_cost.

      LOOP AT lt_mfgorder ASSIGNING FIELD-SYMBOL(<lfs_mfgorder>) WHERE product = <lfs_t02>-sap_mat_id.
        CASE <lfs_mfgorder>-productionsupervisor.
          WHEN 100.
            ls_dataj-actualprice_smt = ls_dataj-actualprice_smt + <lfs_mfgorder>-totalactualcost.
          WHEN 200.
            ls_dataj-actualprice_ai = ls_dataj-actualprice_ai + <lfs_mfgorder>-totalactualcost.
          WHEN 300.
            ls_dataj-actualprice_fat = ls_dataj-actualprice_fat + <lfs_mfgorder>-totalactualcost.
        ENDCASE.

        IF <lfs_mfgorder>-product = <lfs_mfgorder>-producedproduct.
          CONDENSE ls_dataj-yieldqty NO-GAPS.
          ls_dataj-yieldqty = ls_dataj-yieldqty + <lfs_mfgorder>-yieldqty.
        ENDIF.
      ENDLOOP.
      CONDENSE ls_dataj-yieldqty NO-GAPS.

      TRY.
          ls_dataj-actualprice_smt = ls_dataj-actualprice_smt / ls_dataj-yieldqty.
          ls_dataj-actualprice_ai  = ls_dataj-actualprice_ai  / ls_dataj-yieldqty.
          ls_dataj-actualprice_fat = ls_dataj-actualprice_fat / ls_dataj-yieldqty.
        CATCH cx_root INTO DATA(exc).
          ls_dataj-actualprice_smt = 0.
          ls_dataj-actualprice_ai  = 0.
          ls_dataj-actualprice_fat = 0.
      ENDTRY.

      READ TABLE lt_basic2 ASSIGNING FIELD-SYMBOL(<lfs_basic2>) WITH KEY plant   = <lfs_t02>-plant
                                                                         product = <lfs_t02>-sap_mat_id BINARY SEARCH.
      IF sy-subrc = 0.
        ls_dataj-currency = <lfs_basic2>-currency.
        lv_currencyold = ls_dataj-currency.
        ls_dataj-estimatedprice_smt = zzcl_common_utils=>conversion_amount(
                                      iv_alpha = 'IN'
                                      iv_currency = lv_currencyold
                                      iv_input = ls_dataj-estimatedprice_smt ).
        ls_dataj-estimatedprice_ai = zzcl_common_utils=>conversion_amount(
                                      iv_alpha = 'IN'
                                      iv_currency = lv_currencyold
                                      iv_input = ls_dataj-estimatedprice_ai ).
        ls_dataj-estimatedprice_fat = zzcl_common_utils=>conversion_amount(
                                      iv_alpha = 'IN'
                                      iv_currency = lv_currencyold
                                      iv_input = ls_dataj-estimatedprice_fat ).
        ls_dataj-actualprice_smt = zzcl_common_utils=>conversion_amount(
                                      iv_alpha = 'IN'
                                      iv_currency = lv_currencyold
                                      iv_input = ls_dataj-actualprice_smt ).
        ls_dataj-actualprice_ai = zzcl_common_utils=>conversion_amount(
                                      iv_alpha = 'IN'
                                      iv_currency = lv_currencyold
                                      iv_input = ls_dataj-actualprice_ai ).
        ls_dataj-actualprice_fat = zzcl_common_utils=>conversion_amount(
                                      iv_alpha = 'IN'
                                      iv_currency = lv_currencyold
                                      iv_input = ls_dataj-actualprice_fat ).
      ENDIF.

      READ TABLE lt_bill ASSIGNING FIELD-SYMBOL(<lfs_bill>) WITH KEY product = <lfs_t02>-sap_mat_id BINARY SEARCH.
      IF sy-subrc = 0.
        ls_dataj-billingquantity     = <lfs_bill>-billingquantity.
        ls_dataj-billingquantityunit = <lfs_bill>-billingquantityunit.
      ENDIF.

      ls_dataj-sales_number = <lfs_t02>-project_no.
      ls_dataj-quo_version  = <lfs_t02>-requisition_version.
      ls_dataj-sales_d_no   = <lfs_t02>-item_no.
      APPEND ls_dataj TO lt_dataj.
    ENDLOOP.

    IF lt_dataj IS NOT INITIAL.
      MODIFY ztbi_1002 FROM TABLE @lt_dataj.
      TRY.
          add_message_to_log( i_text = '加工費逆ザヤ防止分析が更新に成功しました' i_type = 'S' ).
        CATCH cx_bali_runtime  INTO DATA(cx_errj).
          DATA ls_msgj TYPE scx_t100key.
          DATA(lv_msgj) = cx_errj->get_text( ).
      ENDTRY.
    ELSE.
      TRY.
          add_message_to_log( i_text = '加工費逆ザヤ防止分析が更新に失敗しました' i_type = 'E' ).
        CATCH cx_bali_runtime INTO DATA(cx_errk).
          DATA ls_msgk TYPE scx_t100key.
          DATA(lv_msgk) = cx_errk->get_text( ).
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.

    lt_parameters = VALUE #( ( selname = 'P_Plant'
                               kind    = if_apj_dt_exec_object=>parameter
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '1100' )
                               ( selname = 'P_Year'
                               kind    = if_apj_dt_exec_object=>parameter
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '2024' )
                               ( selname = 'P_Month'
                               kind    = if_apj_dt_exec_object=>parameter
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '12' )
                          ).
    TRY.
        if_apj_dt_exec_object~get_parameters( IMPORTING et_parameter_val = lt_parameters ).
        if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_root INTO DATA(lo_root).
        out->write( |Exception has occured: { lo_root->get_text(  ) }| ).
    ENDTRY.
  ENDMETHOD.


  METHOD init_application_log.
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object    = 'ZZ_LOG_BI004'
                                                                       subobject = 'ZZ_LOG_BI004_SUB' ) ).
      CATCH cx_bali_runtime INTO DATA(cx_erro).
        DATA(lv_msg) = cx_erro->get_text( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
