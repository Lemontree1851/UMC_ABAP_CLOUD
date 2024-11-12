CLASS zcl_purinfomasterlist DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_purinfomasterlist IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA:
      lt_data                      TYPE STANDARD TABLE OF zr_purinfomasterlist,
      lw_data                      LIKE LINE OF lt_data,
      lt_output                    TYPE STANDARD TABLE OF zr_purinfomasterlist,
      lr_purchasinginforecord      TYPE RANGE OF zr_purinfomasterlist-purchasinginforecord,      "購買情報
      lr_plant                     TYPE RANGE OF zr_purinfomasterlist-plant,                     "プラント
      lr_purchasingorganization    TYPE RANGE OF zr_purinfomasterlist-purchasingorganization,    "購買組織
      lr_material                  TYPE RANGE OF zr_purinfomasterlist-material,                  "品目
      lr_suppliermaterialnumber    TYPE RANGE OF zr_purinfomasterlist-suppliermaterialnumber,    "仕入先品目コード
      lr_supplier                  TYPE RANGE OF zr_purinfomasterlist-supplier,                  "仕入先コード
      lr_purchasinggroup           TYPE RANGE OF zr_purinfomasterlist-purchasinggroup,           "購買グループ
      lr_creationdate_1            TYPE RANGE OF zr_purinfomasterlist-creationdate_1,            "登録日
      lr_creationdate_2            TYPE RANGE OF zr_purinfomasterlist-creationdate_2,            "Quotation creation date
      lr_manufacturernumber        TYPE RANGE OF zr_purinfomasterlist-manufacturernumber,        "Manufacturer code
      lr_productmanufacturernumber TYPE RANGE OF zr_purinfomasterlist-productmanufacturernumber, "MPN
      lr_latestoffer               TYPE RANGE OF zr_purinfomasterlist-latestoffer,               "Latest offer
      lr_supplierisfixed           TYPE RANGE OF zr_purinfomasterlist-supplierisfixed,           "固定仕入先
      lr_incotermsclassification   TYPE RANGE OF zr_purinfomasterlist-incotermsclassification,   "基軸通貨
*      lr_plusday                   TYPE RANGE OF zr_purinfomasterlist-plusday,                   "Plus day
      ls_purchasinginforecord      LIKE LINE OF  lr_purchasinginforecord,
      ls_plant                     LIKE LINE OF  lr_plant,
      ls_purchasingorganization    LIKE LINE OF  lr_purchasingorganization,
      ls_material                  LIKE LINE OF  lr_material,
      ls_suppliermaterialnumber    LIKE LINE OF  lr_suppliermaterialnumber,
      ls_supplier                  LIKE LINE OF  lr_supplier,
      ls_purchasinggroup           LIKE LINE OF  lr_purchasinggroup,
      ls_creationdate_1            LIKE LINE OF  lr_creationdate_1,
      ls_creationdate_2            LIKE LINE OF  lr_creationdate_2,
      ls_manufacturernumber        LIKE LINE OF  lr_manufacturernumber,
      ls_productmanufacturernumber LIKE LINE OF  lr_productmanufacturernumber,
      ls_latestoffer               LIKE LINE OF  lr_latestoffer,
      ls_supplierisfixed           LIKE LINE OF  lr_supplierisfixed,
      ls_incotermsclassification   LIKE LINE OF  lr_incotermsclassification.
*      ls_plusday                   LIKE LINE OF  lr_plusday.

    DATA:lv_unitprice_standard TYPE p DECIMALS 3,
         lv_unitprice_plnt     TYPE p DECIMALS 3,
         lv_price              TYPE p DECIMALS 6.

    DATA: lv_current_date             TYPE sy-datum. " 系统当前日期


    " 获取系统当前日期
    lv_current_date = sy-datum.


    TYPES: BEGIN OF ty_record,
             conditionrecord              TYPE i_purgprcgconditionrecord-conditionrecord,
             conditionvalidityenddate     TYPE string,
             conditionvaliditystartdate   TYPE string,
             purchasinginforecord         TYPE i_purginforecdorgplntdataapi01-purchasinginforecord,
             plant                        TYPE i_purginforecdorgplntdataapi01-plant,
             purchasingorganization       TYPE i_purginforecdorgplntdataapi01-purchasingorganization,
             purchasinginforecordcategory TYPE i_purginforecdorgplntdataapi01-purchasinginforecordcategory,
             validitystartdate            TYPE datum,
             validityenddate              TYPE datum,
           END OF ty_record,

           BEGIN OF ty_result,
             results TYPE TABLE OF ty_record WITH DEFAULT KEY,
           END OF ty_result,

           BEGIN OF ty_response,
             d TYPE ty_result,
           END OF ty_response.

    TYPES: BEGIN OF ts_valuation,
             product            TYPE  matnr,
             valuationarea      TYPE  bwkey,
             standardprice      TYPE  stprs,
             valuationclass     TYPE  bklas,
             priceunitqty       TYPE  peinh,
             currency           TYPE  waers,
             movingaverageprice TYPE  verpr,
           END OF ts_valuation,
           tt_valuation TYPE STANDARD TABLE OF ts_valuation WITH DEFAULT KEY,
           BEGIN OF ts_valuation_d,
             results TYPE tt_valuation,
           END OF ts_valuation_d,
           BEGIN OF ts_valuation_api,
             d TYPE ts_valuation_d,
           END OF ts_valuation_api.

    DATA:ls_response       TYPE ty_response.

    DATA:
      lt_valuation_api TYPE STANDARD TABLE OF ts_valuation,
      ls_valuation_api TYPE ts_valuation,
      ls_valuation_ecn TYPE ts_valuation_api.

    DATA:lv_path2          TYPE string.

*    IF io_request->is_data_requested( ).
    TRY.
        "Get and add filter
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
    ENDTRY.

    DATA(lv_top)    = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)   = io_request->get_paging( )->get_offset( ).
    DATA(lt_fields) = io_request->get_requested_elements( ).
    DATA(lt_sort)   = io_request->get_sort_elements( ).

    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).

      LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).

        CASE ls_filter_cond-name.
          WHEN 'PURCHASINGINFORECORD'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_purchasinginforecord.
            APPEND ls_purchasinginforecord TO lr_purchasinginforecord.
            CLEAR ls_purchasinginforecord.
          WHEN 'PLANT'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_plant.
            APPEND ls_plant TO lr_plant.
            CLEAR ls_plant.
          WHEN 'PURCHASINGORGANIZATION'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_purchasingorganization.
            APPEND ls_purchasingorganization TO lr_purchasingorganization.
            CLEAR ls_purchasingorganization.
          WHEN 'MATERIAL'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_material.
            APPEND ls_material TO lr_material.
            CLEAR ls_material.
          WHEN 'SUPPLIERMATERIALNUMBER'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_suppliermaterialnumber.
            APPEND ls_suppliermaterialnumber TO lr_suppliermaterialnumber.
            CLEAR ls_suppliermaterialnumber.
          WHEN 'SUPPLIER'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_supplier.
            APPEND ls_supplier TO lr_supplier.
            CLEAR ls_supplier.
          WHEN 'PURCHASINGGROUP'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_purchasinggroup.
            APPEND ls_purchasinggroup TO lr_purchasinggroup.
            CLEAR ls_purchasinggroup.
          WHEN 'CREATIONDATE_1'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_creationdate_1.
            APPEND ls_creationdate_1 TO lr_creationdate_1.
            CLEAR ls_creationdate_1.
          WHEN 'CREATIONDATE_2'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_creationdate_2.
            APPEND ls_creationdate_2 TO lr_creationdate_2.
            CLEAR ls_creationdate_2.
          WHEN 'MANUFACTURERNUMBER'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_manufacturernumber.
            APPEND ls_manufacturernumber TO lr_manufacturernumber.
            CLEAR ls_manufacturernumber.
          WHEN 'PRODUCTMANUFACTURERNUMBER'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_productmanufacturernumber.
            APPEND ls_productmanufacturernumber TO lr_productmanufacturernumber.
            CLEAR ls_productmanufacturernumber.
          WHEN 'LATESTOFFER'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_latestoffer.
            APPEND ls_latestoffer TO lr_latestoffer.
            CLEAR ls_latestoffer.
          WHEN 'SUPPLIERISFIXED'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_supplierisfixed.
            APPEND ls_supplierisfixed TO lr_supplierisfixed.
            CLEAR ls_supplierisfixed.
          WHEN 'INCOTERMSCLASSIFICATION'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_incotermsclassification.
            APPEND ls_incotermsclassification TO lr_incotermsclassification.
            CLEAR ls_incotermsclassification.
          WHEN 'PLUSDAY'.
            DATA(lr_plusday) = ls_filter_cond-range.
            READ TABLE lr_plusday INTO DATA(lrs_plusday) INDEX 1.
            DATA(lv_plusday) = lrs_plusday-low.
          WHEN 'ZTYPE1'.
            DATA(lr_ztype1) = ls_filter_cond-range.
            READ TABLE lr_ztype1 INTO DATA(lrs_ztype1) INDEX 1.
            DATA(lv_ztype1) = lrs_ztype1-low.
          WHEN 'ZTYPE2'.
            DATA(lr_ztype2) = ls_filter_cond-range.
            READ TABLE lr_ztype2 INTO DATA(lrs_ztype2) INDEX 1.
            DATA(lv_ztype2) = lrs_ztype2-low.
          WHEN OTHERS.

        ENDCASE.

      ENDLOOP.

    ENDLOOP.

    DATA(lv_path) = |/API_PURGPRCGCONDITIONRECORD_SRV/A_PurgPrcgCndnRecdValidity?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
    DATA(lv_select) = |$select=ConditionRecord,ConditionValidityStartDate,ConditionValidityEndDate,PurchasingInfoRecord| &&
                      |,Plant,PurchasingOrganization,PurchasingInfoRecordCategory|.
    zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = |{ lv_path }&{ lv_select }|
                                                 iv_method      = if_web_http_client=>get
                                       IMPORTING ev_status_code = DATA(lv_status_code)
                                                 ev_response    = DATA(lv_response) ).
    IF lv_status_code = 200.
      REPLACE ALL OCCURRENCES OF `PurchasingInfoRecordCategory` IN lv_response  WITH `Purchasinginforecordcategory`.
      "ConditionValidityEndDate":"\/Date(253402214400000)\/"
      "ConditionValidityStartDate":"\/Date(1722297600000)\/"
      REPLACE ALL OCCURRENCES OF `\/Date(` IN lv_response  WITH ``.
      REPLACE ALL OCCURRENCES OF `)\/` IN lv_response  WITH ``.

*      xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
*        ( xco_cp_json=>transformation->pascal_case_to_underscore )
*        ( xco_cp_json=>transformation->boolean_to_abap_bool )
*      ) )->write_to( REF #( ls_response ) ).

      /ui2/cl_json=>deserialize(
                                     EXPORTING json = lv_response
                                     CHANGING data = ls_response ).

      DATA(lt_recdvalidity) = ls_response-d-results.
      LOOP AT lt_recdvalidity ASSIGNING FIELD-SYMBOL(<lfs_recdvalidity>).
        IF <lfs_recdvalidity>-conditionvaliditystartdate < 0.
          <lfs_recdvalidity>-validitystartdate = '19000101'.
        ELSEIF <lfs_recdvalidity>-validitystartdate = '253402214400000'.
          <lfs_recdvalidity>-validitystartdate = '99991231'.
        ELSE.
          <lfs_recdvalidity>-validitystartdate = xco_cp_time=>unix_timestamp(
                      iv_unix_timestamp = <lfs_recdvalidity>-conditionvaliditystartdate / 1000
                   )->get_moment( )->as( xco_cp_time=>format->abap )->value+0(8).
        ENDIF.
        IF <lfs_recdvalidity>-conditionvalidityenddate < 0.
          <lfs_recdvalidity>-validityenddate = '19000101'.
        ELSEIF <lfs_recdvalidity>-conditionvalidityenddate = '253402214400000'.
          <lfs_recdvalidity>-validityenddate = '99991231'.
        ELSE.
          <lfs_recdvalidity>-validityenddate = xco_cp_time=>unix_timestamp(
                      iv_unix_timestamp = <lfs_recdvalidity>-conditionvalidityenddate / 1000
                   )->get_moment( )->as( xco_cp_time=>format->abap )->value+0(8).
        ENDIF.
      ENDLOOP.
    ENDIF.

    lv_path2 = |/YY1_PRODUCTVALUATION_CDS/YY1_ProductValuation|.
    "Call API
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path2
        iv_method      = if_web_http_client=>get
        iv_format      = 'json'
      IMPORTING
        ev_status_code = DATA(lv_stat_code)
        ev_response    = DATA(lv_resbody_api) ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api
                               CHANGING data = ls_valuation_ecn ).
    IF lv_stat_code = '200'
   AND ls_valuation_ecn-d-results IS NOT INITIAL.
      APPEND LINES OF ls_valuation_ecn-d-results TO lt_valuation_api.
    ENDIF.

    SORT lt_recdvalidity BY purchasinginforecord
                           plant
                           purchasingorganization
                           purchasinginforecordcategory
                           validitystartdate.

    IF lt_recdvalidity IS NOT INITIAL.

      SELECT
       a~conditionscalequantity,
       a~conditionratevalue,
       a~conditionrecord,
       a~creationdate AS creationdate_2
    FROM i_purgprcgconditionrecord WITH PRIVILEGED ACCESS AS a
    FOR ALL ENTRIES IN @lt_recdvalidity
      WHERE a~conditionrecord = @lt_recdvalidity-conditionrecord
        AND a~creationdate IN @lr_creationdate_2
    INTO TABLE @DATA(lt_purinfoitem1).

    ENDIF.

    LOOP AT  lt_recdvalidity INTO DATA(lw_recdvalidity1).

      READ TABLE lt_purinfoitem1 INTO DATA(lw_purinfoitem1) WITH KEY conditionrecord = lw_recdvalidity1-conditionrecord.
      IF sy-subrc = 0.
        lw_data-conditionscalequantity = lw_purinfoitem1-conditionscalequantity.
        lw_data-conditionratevalue     = lw_purinfoitem1-conditionratevalue.
        lw_data-creationdate_2         = lw_purinfoitem1-creationdate_2.
      ELSE.
        lw_data-conditionscalequantity = ' '.
        lw_data-conditionratevalue     = ' '.
        lw_data-creationdate_2         = ' '.
      ENDIF.
    ENDLOOP.
    CLEAR lw_purinfoitem1.

    SELECT
         a~isdeleted,
         a~purchasinginforecord,
         a~material,
         a~supplier,
         a~suppliermaterialnumber,
         a~suppliermaterialgroup,
         a~suppliercertorigincountry,
         a~suppliercertoriginregion,
         a~purgdocorderquantityunit,
         a~baseunit,
         a~creationdate AS creationdate_1,
         a~suppliersubrange,
         f~productname,
         g~organizationbpname1 AS organizationbpname1_ja,
         g~organizationbpname1 AS organizationbpname1_en,
         b~productgroup,
         b~productoid,
         b~owninventorymanagedproduct,
         b~manufacturernumber,
         b~industrystandardname,
         b~productmanufacturernumber,
         c~firstsalesspecproductgroup,
         c~productsalesorg,
         o~supplierisfixed,
         d~ismarkedfordeletion,
         d~purchasingorganization,
         d~plant,
         d~purchasinginforecordcategory,
         d~materialplanneddeliverydurn,
         d~purchasinggroup,
         d~minimumpurchaseorderquantity,
         d~maximumorderquantity,
         d~supplierconfirmationcontrolkey,
         d~taxcode,
         d~currency AS currency_plnt,
         d~netpriceamount,
         d~materialpriceunitqty,
         d~pricingdatecontrol,
         d~incotermsclassification,
         d~createdbyuser,
         i~purchasinggroupname,
         j~shippingconditionname,
         h~zvalue2
      FROM i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS AS d
        ON d~purchasinginforecord = a~purchasinginforecord
      LEFT JOIN i_product WITH PRIVILEGED ACCESS AS b
        ON b~product = a~material
      LEFT JOIN i_producttext WITH PRIVILEGED ACCESS AS f
        ON f~product = a~material
        AND f~language = @sy-langu
      LEFT JOIN i_businesspartner WITH PRIVILEGED ACCESS AS g
        ON g~businesspartner = a~supplier
      LEFT JOIN i_productsalesdelivery WITH PRIVILEGED ACCESS AS c
        ON c~product = a~material
        AND c~productsalesorg = d~purchasingorganization
      LEFT JOIN i_mppurchasingsourceitem WITH PRIVILEGED ACCESS AS o
        ON o~material = a~material
        AND o~supplier = a~supplier
      LEFT JOIN i_purchasinggroup WITH PRIVILEGED ACCESS AS i
        ON i~purchasinggroup = d~purchasinggroup
      LEFT JOIN i_shippingconditiontext WITH PRIVILEGED ACCESS AS j
        ON j~shippingcondition = d~shippinginstruction
        AND j~language = @sy-langu
      LEFT JOIN ztbc_1001 AS h
        ON zid = 'ZMM001'
        AND zvalue1 = d~taxcode
      WHERE d~plant IN @lr_plant
        AND d~purchasingorganization IN @lr_purchasingorganization
        AND d~purchasinggroup IN @lr_purchasinggroup
        AND a~purchasinginforecord IN @lr_purchasinginforecord
        AND a~supplier IN @lr_supplier
        AND a~material IN @lr_material
        AND a~suppliermaterialnumber IN @lr_suppliermaterialnumber
        AND a~creationdate IN @lr_creationdate_1
        AND b~manufacturernumber IN @lr_manufacturernumber
        AND b~productmanufacturernumber IN @lr_productmanufacturernumber
        AND o~supplierisfixed IN @lr_supplierisfixed
        AND o~plant IN @lr_plant
        AND d~purchasingorganization IN @lr_purchasingorganization
      INTO TABLE @DATA(lt_purinfoitem2).

    LOOP AT  lt_purinfoitem2 INTO DATA(lw_data2).
      MOVE-CORRESPONDING lw_data2 TO lw_data.

      IF lw_data-material IS NOT INITIAL AND lw_data-plant IS NOT INITIAL AND lw_data-supplier IS NOT INITIAL.
        lw_data-loginflag = 'X'.
      ELSE.
        lw_data-loginflag = ''.
      ENDIF.

      lw_data-plusday = lw_data2-materialplanneddeliverydurn + lrs_plusday-low.

      IF lw_data2-materialpriceunitqty <> 0.
        lv_unitprice_plnt = lw_data2-netpriceamount / lw_data2-materialpriceunitqty.

        lw_data-unitprice_plnt = round(
        val = lv_unitprice_plnt
        dec = 3
        mode = cl_abap_math=>round_half_up
        ).
      ELSE.
        lw_data-unitprice_plnt = 0.
      ENDIF.

      IF lv_unitprice_plnt IS NOT INITIAL AND lw_data2-zvalue2 IS NOT INITIAL AND lw_data2-zvalue2 <> 0.
        lw_data-taxprice = lv_unitprice_plnt * lw_data2-zvalue2.
      ELSE.
        " 如果有字段为空或为零，设置税价为零或其他默认值
        lw_data-taxprice = 0.
      ENDIF.

      " 查找对应的单价信息
      READ TABLE lt_valuation_api INTO DATA(lw_unitprice)
          WITH KEY product = lw_data-material
               valuationarea = lw_data-plant.

      IF sy-subrc = 0. " 如果找到记录

        lw_data-valuationclass    = lw_unitprice-valuationclass.
        lw_data-priceunitqty      = lw_unitprice-priceunitqty.
        lw_data-currency_standard = lw_unitprice-currency.

        IF lw_unitprice-priceunitqty IS NOT INITIAL AND lw_unitprice-standardprice IS NOT INITIAL.

          " 计算标准单价
          lv_unitprice_standard = lw_unitprice-standardprice / lw_unitprice-priceunitqty.

          " 四舍五入至3位小数
          lw_data-unitprice_standard = round(
              val = lv_unitprice_standard
              dec = 3
              mode = cl_abap_math=>round_half_up
          ).
        ELSE.
          lw_data-unitprice_standard = 0.
        ENDIF.

        lv_price = lw_data-unitprice_standard - lw_data-unitprice_plnt.

        IF lv_price IS NOT INITIAL AND lw_data-materialpriceunitqty IS NOT INITIAL.

          DATA lv_rate TYPE p DECIMALS 6.
          DATA lv_rate_display TYPE p DECIMALS 2.

          lv_rate = lv_price / lw_data-materialpriceunitqty.

          " 转换为百分比形式
          lv_rate = lv_rate * 100.

          " 四舍五入至2位小数
          lv_rate = round(
              val = lv_rate
              dec = 2
              mode = cl_abap_math=>round_half_up
          ).

          lv_rate_display = lv_rate.

          " 拼接百分号
          lw_data-rate = |{ lv_rate_display }%|.  " 将百分号添加到字符串后面

        ELSE.
          lw_data-rate = '0.00%'.  " 如果没有有效的计算结果，设置为 0%
        ENDIF.

      ELSE. " 如果未找到记录，清空相关字段
        lw_data-valuationclass = ''.
        lw_data-priceunitqty = ''.
        lw_data-currency_standard = ''.
        lw_data-unitprice_standard = ''.
      ENDIF.

      READ TABLE lt_recdvalidity INTO DATA(lw_recdvalidity) WITH KEY purchasinginforecord = lw_data-purchasinginforecord
                                                                                      plant = lw_data-plant
                                                                    purchasingorganization = lw_data-purchasingorganization
                                                               purchasinginforecordcategory = lw_data-purchasinginforecordcategory.
      IF sy-subrc = 0.
        lw_data-condition_validity_start_date = lw_recdvalidity-conditionvaliditystartdate.
        lw_data-condition_validity_end_date   = lw_recdvalidity-conditionvalidityenddate.
      ELSE.
        lw_data-condition_validity_start_date = ' '.
        lw_data-condition_validity_end_date   = ' '.
      ENDIF.
      CLEAR lw_recdvalidity.

      APPEND lw_data TO lt_data.

    ENDLOOP.

    CLEAR lv_unitprice_standard.
    CLEAR lv_unitprice_plnt.
    CLEAR lv_rate.
    CLEAR lv_price.
    CLEAR lv_rate_display.

    " 如果 lv_ztype1 为 'X'，删除符合条件的记录
    IF lv_ztype1 = ' '.
      DELETE lt_data WHERE isdeleted = space AND ismarkedfordeletion = space.
    ENDIF.

    IF lv_ztype2 = 'X'.
      DELETE lt_data WHERE condition_validity_start_date <= sy-datum.
    ENDIF.

    LOOP AT lt_data INTO lw_data.  " 循环遍历 lt_dataS
      APPEND lw_data TO lt_output.  " 将当前行的 lw_data 追加到 lt_output 内表
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
