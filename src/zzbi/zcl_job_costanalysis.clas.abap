CLASS zcl_job_costanalysis DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mo_application_log TYPE REF TO if_bali_log,
          mo_table           TYPE REF TO data,
          mo_out             TYPE REF TO if_oo_adt_classrun_out.

    DATA:
      lv_yearmonth   TYPE c LENGTH 6,
      lv_yearmonths  TYPE string,
      mv_companycode TYPE c LENGTH 4,
      mv_plant       TYPE c LENGTH 4,
      mv_year        TYPE c LENGTH 4,
      mv_month       TYPE c LENGTH 2.

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
             sap_mat_id      TYPE matnr,
             material_number TYPE matnr,
             person_no1      TYPE string,
             submit_price    TYPE string,
             submit_curr     TYPE string,
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

    METHODS:
      "! <p class="shorttext synchronized" lang="en"></p>
      "!
      "! @parameter it_parameters | <p class="shorttext synchronized" lang="en"></p>
      get_parameter_id IMPORTING it_parameters TYPE if_apj_dt_exec_object=>tt_templ_val,

      init_application_log,
      save_job_info,

      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime,

      get_file_content IMPORTING i_uuid TYPE sysuuid_x16,
      get_configuration IMPORTING i_uuid TYPE sysuuid_x16,
      get_data_from_excel,
      process_logic.
ENDCLASS.



CLASS zcl_job_costanalysis IMPLEMENTATION.
  METHOD if_apj_rt_exec_object~execute.
    " get parameter id
    get_parameter_id( it_parameters ).

  ENDMETHOD.

  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #( ( selname        = 'P_Companycode'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = '会社コード'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true )
                                ( selname        = 'P_Plant'
                                  kind           = if_apj_dt_exec_object=>parameter
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
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true )
                                ( selname        = 'P_Month'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'char'
                                  length         = 2
                                  param_text     = '会計期間'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true ) ).

    " Return the default parameters values here
    " et_parameter_val

    " 获取日志对象
    init_application_log( ).

*   会社コード Parameterの存在Check
    SELECT COUNT( * )
      FROM i_companycode
     WHERE companycode = @mv_companycode.

    IF sy-subrc <> 0.
      TRY.
          add_message_to_log( i_text = |Record for Company Code { mv_companycode } not found.|
                              i_type = if_bali_constants=>c_severity_error ).
        CATCH cx_bali_runtime.
          " handle exception
      ENDTRY.
      RETURN.
    ENDIF.

*    プラント Parameterの存在Check
    SELECT COUNT( * )
      FROM i_plant
     WHERE plant = @mv_plant.

    IF sy-subrc <> 0.
      TRY.
          add_message_to_log( i_text = |Record for Plant { mv_plant } not found.|
                              i_type = if_bali_constants=>c_severity_error ).
        CATCH cx_bali_runtime.
          " handle exception
      ENDTRY.
      RETURN.
    ENDIF.

    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        " Get USAP Access configuration
        SELECT SINGLE *
          FROM zc_tbc1001
         WHERE zid = 'ZBC002'
           AND zkey1 = @lv_system_url
          INTO @DATA(ls_config).
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    lv_yearmonth = mv_year && mv_month.
    DATA(lv_filter) = |Valid Date eq '{ lv_yearmonth }'|.
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
      xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore )
        ( xco_cp_json=>transformation->boolean_to_abap_bool )
      ) )->write_to( REF #( ls_response ) ).

      IF ls_response-d-results IS NOT INITIAL.
        lt_qms_t01_quo_h = ls_response-d-results.
        SORT lt_qms_t01_quo_h BY project_no requisition_version.
      ENDIF.
    ENDIF.

    DATA(lv_filtert02) = |Plant eq '{ mv_plant }'|.
    CONDENSE ls_config-zvalue2 NO-GAPS. " ODATA_URL
    CONDENSE ls_config-zvalue3 NO-GAPS. " TOKEN_URL
    CONDENSE ls_config-zvalue4 NO-GAPS. " CLIENT_ID
    CONDENSE ls_config-zvalue5 NO-GAPS. " CLIENT_SECRET
    zzcl_common_utils=>get_usap_cdata( EXPORTING iv_odata_url     = |{ ls_config-zvalue2 }/odata/v2/TableService/QMS_T02_QUO_D|
                                                 iv_odata_filter  = lv_filtert02
                                                 iv_token_url     = CONV #( ls_config-zvalue3 )
                                                 iv_client_id     = CONV #( ls_config-zvalue4 )
                                                 iv_client_secret = CONV #( ls_config-zvalue5 )
                                       IMPORTING ev_status_code   = DATA(lv_status_codet02)
                                                 ev_response      = DATA(lv_responset02) ).
    IF lv_status_codet02 = 200.
      xco_cp_json=>data->from_string( lv_responset02 )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore )
        ( xco_cp_json=>transformation->boolean_to_abap_bool )
      ) )->write_to( REF #( ls_responset02 ) ).

      IF ls_responset02-d-results IS NOT INITIAL.
        LOOP AT ls_responset02-d-results ASSIGNING FIELD-SYMBOL(<lfs_responset02>).
          READ TABLE lt_qms_t01_quo_h TRANSPORTING NO FIELDS
            WITH KEY project_no          = <lfs_responset02>-project_no
                     requisition_version = <lfs_responset02>-requisition_version
                     BINARY SEARCH.
          IF sy-subrc = 0.
            APPEND <lfs_responset02> TO lt_qms_t02_quo_d.
          ENDIF.
        ENDLOOP.
        SORT lt_qms_t02_quo_d BY project_no requisition_version item_no sap_mat_id.
      ENDIF.
    ENDIF.

*    DATA(lv_filtert07) = |Plant eq '{ mv_plant }'|.
    CONDENSE ls_config-zvalue2 NO-GAPS. " ODATA_URL
    CONDENSE ls_config-zvalue3 NO-GAPS. " TOKEN_URL
    CONDENSE ls_config-zvalue4 NO-GAPS. " CLIENT_ID
    CONDENSE ls_config-zvalue5 NO-GAPS. " CLIENT_SECRET
    zzcl_common_utils=>get_usap_cdata( EXPORTING iv_odata_url     = |{ ls_config-zvalue2 }/odata/v2/TableService/QMS_T07_QUOTATION_D|
*                                                 iv_odata_filter  = lv_filtert07
                                                 iv_token_url     = CONV #( ls_config-zvalue3 )
                                                 iv_client_id     = CONV #( ls_config-zvalue4 )
                                                 iv_client_secret = CONV #( ls_config-zvalue5 )
                                       IMPORTING ev_status_code   = DATA(lv_status_codet07)
                                                 ev_response      = DATA(lv_responset07) ).
    IF lv_status_codet07 = 200.
      xco_cp_json=>data->from_string( lv_responset07 )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore )
        ( xco_cp_json=>transformation->boolean_to_abap_bool )
      ) )->write_to( REF #( ls_responset07 ) ).

      IF ls_responset07-d-results IS NOT INITIAL.
        LOOP AT ls_responset07-d-results ASSIGNING FIELD-SYMBOL(<fs_responset07>).
          READ TABLE lt_qms_t02_quo_d TRANSPORTING NO FIELDS
            WITH KEY project_no           = <fs_responset07>-sales_number
                     requisition_version  = <fs_responset07>-quo_version
                     item_no              = <fs_responset07>-sales_d_no
                     sap_mat_id           = <fs_responset07>-sap_mat_id
                     BINARY SEARCH.
          IF sy-subrc = 0.
            APPEND <fs_responset07> TO lt_qms_t07_all.
          ENDIF.
        ENDLOOP.

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
          READ TABLE lt_qms_t07_sum TRANSPORTING NO FIELDS
            WITH KEY sap_mat_id  = <lfs_t07_all>-sap_mat_id
                     quo_version = <lfs_t07_all>-quo_version
                     BINARY SEARCH.
          IF sy-subrc = 0.
            APPEND <lfs_t07_all> TO lt_qms_t07_quotation_d.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF.

*   該当月の支払請求書を抽出
*   各部品の最終受入単価を取得する
*   発注伝票を取得
*   最終受入仕入を取得
    DATA(lt_qms_t07) = lt_qms_t07_quotation_d.
    SORT lt_qms_t07 BY material_number ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_qms_t07 COMPARING material_number.

    IF lt_qms_t07 IS NOT INITIAL.

      lv_yearmonths = lv_yearmonth && '%'.
      SELECT  supplier~companycode,     "会社コード
              companycodet~companycodename,
              supplier~supplierinvoice, "仕入先請求書番号
              suplrinvc~plant,          "プラント
              aplant~plantname,
              suplrinvc~material,       "構成部品
              supplier~postingdate,     "転記日付
              suplrinvc~supplierinvoiceitemamount, "請求書金額
              suplrinvc~\_currency-currency,  "通貨
              suplrinvc~quantity,       "数量
              itempurord~purchaseorder, "発注伝票
              t07~material_number,
              product1~productdescription AS materialdescription,
              product2~productdescription AS productdescription,
              t07~sap_mat_id,
              purchase~supplier         "最終受入仕入先
        FROM i_supplierinvoiceapi01 WITH PRIVILEGED ACCESS AS supplier
  INNER JOIN i_suplrinvcitemmaterialapi01 WITH PRIVILEGED ACCESS AS suplrinvc
          ON supplier~supplierinvoice = suplrinvc~supplierinvoice
  INNER JOIN i_suplrinvcitempurordrefapi01 WITH PRIVILEGED ACCESS AS itempurord
          ON itempurord~supplierinvoice = suplrinvc~supplierinvoice
  INNER JOIN @lt_qms_t07 AS t07
          ON t07~material_number = suplrinvc~material
   LEFT JOIN i_productdescription AS product1
          ON product1~product  = t07~material_number
         AND product1~language = @sy-langu
   LEFT JOIN i_productdescription AS product2
          ON product2~product  = t07~sap_mat_id
         AND product2~language = @sy-langu
  INNER JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS purchase
          ON purchase~purchaseorder = itempurord~purchaseorder
   LEFT JOIN i_companycode AS companycodet
          ON companycodet~companycode  = supplier~companycode
         AND companycodet~language     = @sy-langu
   LEFT JOIN i_plant AS aplant
          ON aplant~plant   = suplrinvc~plant
         AND aplant~language     = @sy-langu
       WHERE supplier~companycode      = @mv_companycode
         AND supplier~postingdate      LIKE @lv_yearmonths
         AND supplier~reversedocument  = @space
         AND suplrinvc~companycode     = @mv_companycode
         AND suplrinvc~plant           = @mv_plant
        INTO TABLE @DATA(lt_supplier).
      SORT lt_supplier BY supplierinvoice ASCENDING
                          plant           ASCENDING
                          material        ASCENDING
                          postingdate     DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_supplier COMPARING supplierinvoice plant material.

    ENDIF.

*   各部品の最終受入日付を取得
    SELECT sup~supplierinvoice,    "仕入先請求書番号
           sup~postingdate         "最終受入日付
      FROM i_supplierinvoiceapi01 WITH PRIVILEGED ACCESS AS sup
      JOIN  @lt_supplier AS supplier
        ON supplier~supplierinvoice = sup~supplierinvoice
     WHERE sup~companycode = @mv_companycode
       AND sup~reversedocument  = @space
     INTO TABLE @DATA(lt_sup).
    SORT lt_sup BY supplierinvoice.

*    購買情報マスタから各部品の固定仕入先情報を取得
    SELECT info~supplier,"仕入先番号(複数取得した場合は「/」で区切りする)
           plntdata~plant,
           info~material
      FROM i_purchasinginforecordapi01    WITH PRIVILEGED ACCESS AS info
      JOIN i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS AS plntdata
        ON info~purchasinginforecord = plntdata~purchasinginforecord
      JOIN  @lt_supplier AS supplier
         ON plntdata~plant     = supplier~plant
        AND info~material      = supplier~material
       INTO TABLE @DATA(lt_info).
    SORT lt_info BY plant material.

*    各部品の最新標準単価＆実際単価を取得
    SELECT basic~valuationarea AS plant,"プラント
           basic~product AS material,             "部品
           basic~standardprice,       "標準原価
           basic~movingaverageprice,  "実際原価
           basic~currency             "会社コード通貨
      FROM i_productvaluationbasic WITH PRIVILEGED ACCESS AS basic
      JOIN @lt_supplier AS supplier
        ON basic~valuationarea = supplier~plant
       AND basic~product       = supplier~material
      INTO TABLE @DATA(lt_basic).
    SORT lt_basic BY plant material.

*    販売請求書から当月製品の販売数量を取得
    SELECT bil~companycode,         "会社コード
           bil~billingdocumentdate, "請求書日付
           bil~product AS material,             "製品
           bil~billingquantity,     "請求書数量
           bil~billingquantityunit  "請求書数量単位
      FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS bil
      JOIN @lt_supplier AS supplier
        ON supplier~material = bil~product
     WHERE bil~companycode  = @mv_companycode
       AND bil~billingdocumentdate LIKE @lv_yearmonths
      INTO TABLE @DATA(lt_bil).
    SORT lt_bil BY material.

*    品目マスタからMRP管理者を抽出
    SELECT mrp~plant,
           mrp~product AS material,
           mrp~mrpresponsible  "MRP管理者
      FROM i_productplantbasic WITH PRIVILEGED ACCESS AS mrp
      JOIN @lt_supplier AS supplier
        ON mrp~plant    = supplier~plant
       AND mrp~product  = supplier~material
     INTO TABLE @DATA(lt_mrp).
    SORT lt_mrp BY plant material.

*     得意先BPコードと名称を抽出
    SELECT busi~searchterm2,
           busi~businesspartner,    "ビジネスパートナ
           busi~businesspartnername "ビジネスパートナ名
      FROM i_businesspartner WITH PRIVILEGED ACCESS AS busi
      JOIN @lt_mrp AS mrp
         ON busi~searchterm2 = substring( mrp~mrpresponsible ,2,2 )   "「MRP管理者」末2桁
       INTO TABLE @DATA(lt_busi).
    SORT lt_busi BY searchterm2.

    LOOP AT lt_supplier ASSIGNING FIELD-SYMBOL(<lfs_supplier>).

      CLEAR ls_data.
      ls_dataj-zyear = mv_year.
      ls_dataj-zmonth = mv_month.
      ls_data-yearmonth = lv_yearmonth.
      ls_data-companycode = <lfs_supplier>-companycode.
      ls_data-companycodetext = <lfs_supplier>-companycodename.
      ls_data-plant           = <lfs_supplier>-plant.
      ls_data-planttext       = <lfs_supplier>-plantname.
      ls_data-product = <lfs_supplier>-sap_mat_id.
      ls_data-material = <lfs_supplier>-material_number.
      ls_data-productdescription = <lfs_supplier>-productdescription.
      ls_data-materialdescription = <lfs_supplier>-materialdescription.
      READ TABLE lt_qms_t07_quotation_d ASSIGNING FIELD-SYMBOL(<lfs_t07>)
        WITH KEY material_number = <lfs_supplier>-material BINARY SEARCH.
      ls_data-quantity = <lfs_t07>-person_no1.

      READ TABLE lt_mrp ASSIGNING FIELD-SYMBOL(<lfs_mrp>)
        WITH KEY plant     = <lfs_supplier>-plant
                 material  = <lfs_supplier>-material BINARY SEARCH.

      READ TABLE lt_busi ASSIGNING FIELD-SYMBOL(<lfs_busi>)
        WITH KEY searchterm2 = <lfs_mrp>-mrpresponsible+1(2) BINARY SEARCH.

      ls_data-customer     = <lfs_busi>-businesspartner.
      ls_data-customername = <lfs_busi>-businesspartnername.
      ls_data-estimatedprice = <lfs_t07>-submit_price.
      ls_data-finalprice = <lfs_supplier>-supplierinvoiceitemamount / <lfs_supplier>-quantity.
      READ TABLE lt_sup ASSIGNING FIELD-SYMBOL(<lfs_sup>)
        WITH KEY supplierinvoice = <lfs_supplier>-supplierinvoice BINARY SEARCH.
      ls_data-finalpostingdate = <lfs_sup>-postingdate.
      ls_data-finalsupplier = <lfs_supplier>-supplier.

      LOOP AT lt_info ASSIGNING FIELD-SYMBOL(<lfs_info>)
                WHERE plant    = <lfs_supplier>-plant
                  AND material = <lfs_supplier>-material.
        IF ls_data-fixedsupplier IS INITIAL.
          ls_data-fixedsupplier = <lfs_info>-supplier.
        ELSE.
          ls_data-fixedsupplier = ls_data-fixedsupplier && '/' && <lfs_info>-supplier.
        ENDIF.
      ENDLOOP.

      READ TABLE lt_basic ASSIGNING FIELD-SYMBOL(<lfs_basic>)
        WITH KEY plant    = <lfs_supplier>-plant
                 material = <lfs_supplier>-material BINARY SEARCH.
      ls_data-standardprice = <lfs_basic>-standardprice.
      ls_data-movingaverageprice = <lfs_basic>-movingaverageprice.
      ls_data-currency = <lfs_basic>-currency.

      READ TABLE lt_bil ASSIGNING FIELD-SYMBOL(<lfs_bil>)
        WITH KEY material = <lfs_supplier>-material BINARY SEARCH.

      ls_data-billingquantity     = <lfs_bil>-billingquantity.
      ls_data-billingquantityunit = <lfs_bil>-billingquantityunit.
      APPEND ls_data TO lt_data.
    ENDLOOP.

    IF lt_data IS NOT INITIAL.

      MODIFY ztbi_1001 FROM TABLE @lt_data.

    ENDIF.

*     工程別加工費実績から各製品の加工費実績を取得
    SELECT mfgorder~product,
           mfgorder~productionsupervisor,
           mfgorder~totalactualcost
      FROM ztfi_1020 AS mfgorder
      JOIN @lt_qms_t02_quo_d AS t02
        ON mfgorder~product = t02~sap_mat_id
     WHERE mfgorder~companycode = @mv_companycode
       AND mfgorder~yearmonth   = @lv_yearmonths
      INTO TABLE @DATA(lt_mfgorder).

*      販売請求書から当月製品の販売数量を取得
    SELECT bill~companycode,
           bill~billingdocumentdate,
           bill~product,
           bill~billingquantity,
           bill~billingquantityunit
      FROM i_billingdocumentitem AS bill
      JOIN @lt_qms_t02_quo_d AS t02
        ON t02~sap_mat_id = bill~product
     WHERE bill~companycode         = @mv_companycode
       AND bill~billingdocumentdate LIKE @lv_yearmonths
     INTO TABLE @DATA(lt_bill).
    SORT lt_bill BY product.

    SELECT basic~valuationarea AS plant,"プラント
           basic~product,             "部品
           basic~currency             "会社コード通貨
      FROM i_productvaluationbasic WITH PRIVILEGED ACCESS AS basic
      JOIN @lt_qms_t02_quo_d AS t02
        ON basic~valuationarea = t02~plant
       AND basic~product       = t02~sap_mat_id
      INTO TABLE @DATA(lt_basic2).
    SORT lt_basic2 BY plant product.

    SELECT aplant~plant,
           aplant~plantname
      FROM i_plant AS aplant
      JOIN @lt_qms_t02_quo_d AS t02
        ON aplant~plant        = t02~plant
       AND aplant~language     = @sy-langu
      INTO TABLE @DATA(lt_aplant).
    SORT lt_aplant BY plant.

    SELECT product1~product,
           product1~productdescription AS productdescription
      FROM i_productdescription AS product1
      JOIN @lt_qms_t02_quo_d AS t02
        ON product1~product  = t02~sap_mat_id
       AND product1~language = @sy-langu
      INTO TABLE @DATA(lt_product).
    SORT lt_product BY product.

    SELECT companycodet~companycode,
           companycodet~companycodename
      FROM i_companycode AS companycodet
     WHERE companycodet~companycode  = @mv_companycode
       AND companycodet~language     = @sy-langu
      INTO TABLE @DATA(lt_companycodet).
    SORT lt_companycodet BY companycode.

    LOOP AT lt_qms_t02_quo_d ASSIGNING FIELD-SYMBOL(<lfs_t02>).
      CLEAR ls_dataj.
      ls_dataj-zyear       = mv_year.
      ls_dataj-zmonth      = mv_month.
      ls_dataj-yearmonth   = lv_yearmonths.
      ls_dataj-companycode = mv_companycode.

      READ TABLE lt_companycodet ASSIGNING FIELD-SYMBOL(<lfs_companycodet>)
        WITH KEY companycode = mv_companycode BINARY SEARCH.
      ls_dataj-companycodetext = <lfs_companycodet>-companycodename.
      ls_dataj-plant = <lfs_t02>-plant.
      READ TABLE lt_aplant ASSIGNING FIELD-SYMBOL(<lfs_aplant>)
        WITH KEY plant = <lfs_t02>-plant BINARY SEARCH.
      ls_dataj-planttext = <lfs_aplant>-plantname.
      ls_dataj-product = <lfs_t02>-sap_mat_id.
      READ TABLE lt_product ASSIGNING FIELD-SYMBOL(<lfs_product>)
        WITH KEY product = <lfs_t02>-sap_mat_id BINARY SEARCH.
      ls_dataj-productdescription = <lfs_product>-productdescription.
*      ls_dataj-customer = '545'.
*      ls_dataj-customername = '54bbnnnnnn5'.
      ls_dataj-estimatedprice_smt = <lfs_t02>-smt_prod_cost.
      ls_dataj-estimatedprice_ai = <lfs_t02>-ai_prod_cost.
      ls_dataj-estimatedprice_fat = <lfs_t02>-fat_prod_cost.

      LOOP AT lt_mfgorder ASSIGNING FIELD-SYMBOL(<lfs_mfgorder>)
                    WHERE product = <lfs_t02>-sap_mat_id.
        CASE <lfs_mfgorder>-productionsupervisor.
          WHEN 100.
            ls_dataj-actualprice_smt = ls_dataj-actualprice_smt + <lfs_mfgorder>-totalactualcost.
          WHEN 200.
            ls_dataj-actualprice_ai = ls_dataj-actualprice_ai + <lfs_mfgorder>-totalactualcost.
          WHEN 300.
            ls_dataj-actualprice_fat = ls_dataj-actualprice_fat + <lfs_mfgorder>-totalactualcost.
        ENDCASE.
      ENDLOOP.

      READ TABLE lt_basic2 ASSIGNING FIELD-SYMBOL(<lfs_basic2>)
        WITH KEY plant    = <lfs_t02>-plant
                 product  = <lfs_t02>-sap_mat_id BINARY SEARCH.
      ls_dataj-currency = <lfs_basic2>-currency.

      READ TABLE lt_bill ASSIGNING FIELD-SYMBOL(<lfs_bill>)
        WITH KEY product = <lfs_t02>-sap_mat_id BINARY SEARCH.
      ls_dataj-billingquantity     = <lfs_bill>-billingquantity.
      ls_dataj-billingquantityunit = <lfs_bill>-billingquantityunit.
      APPEND ls_dataj TO lt_dataj.
    ENDLOOP.

    IF lt_data IS NOT INITIAL.

      MODIFY ztbi_1002 FROM TABLE @lt_dataj.

    ENDIF.

  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.

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

  METHOD get_configuration.

  ENDMETHOD.

  METHOD get_data_from_excel.

  ENDMETHOD.

  METHOD get_file_content.

  ENDMETHOD.

  METHOD get_parameter_id.
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_Companycode'.
          mv_companycode = ls_parameter-low.
        WHEN 'P_Plant'.
          mv_plant = ls_parameter-low.
        WHEN 'P_Year'.
          mv_year = ls_parameter-low.
        WHEN 'P_Month'.
          mv_month = ls_parameter-low.

      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD init_application_log.
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object      = 'ZZ_LOG_BI004'
                                                                       subobject   = 'ZZ_LOG_BI004_SUB'
*                                                                       external_id = CONV #( mv_uuid )
                                                                       ) ).
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.
  ENDMETHOD.

  METHOD process_logic.

  ENDMETHOD.

  METHOD save_job_info.

  ENDMETHOD.

ENDCLASS.
