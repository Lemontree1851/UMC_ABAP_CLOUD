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
    DATA lv_filter  TYPE string.
    DATA lv_filter2 TYPE string.

    DATA:lv_unitprice_standard TYPE p DECIMALS 3,
         lv_unitprice_plnt     TYPE p DECIMALS 3,
         lv_price              TYPE p DECIMALS 6,
         lv_count              TYPE i.

    DATA: lv_current_date             TYPE sy-datum. " 系统当前日期


    " 获取系统当前日期
    lv_current_date = sy-datum.


    TYPES: BEGIN OF ty_record,
             conditionrecord              TYPE i_purgprcgconditionrecord-conditionrecord,
             conditionvalidityenddate     TYPE string,
             conditionvaliditystartdate   TYPE string,
             purchasinginforecord         TYPE i_purginforecdorgplntdataapi01-purchasinginforecord,
             material                     TYPE i_purchasinginforecordapi01-material,
             supplier                     TYPE i_purchasinginforecordapi01-supplier,
             plant                        TYPE i_purginforecdorgplntdataapi01-plant,
             purchasingorganization       TYPE i_purginforecdorgplntdataapi01-purchasingorganization,
             purchasinginforecordcategory TYPE i_purginforecdorgplntdataapi01-purchasinginforecordcategory,
             validitystartdate            TYPE datum,
             validityenddate              TYPE datum,
             creationdate                 TYPE datum,
             creationtime                 TYPE uzeit,
           END OF ty_record,

           BEGIN OF ty_result,
             results TYPE TABLE OF ty_record WITH DEFAULT KEY,
           END OF ty_result,

           BEGIN OF ty_response,
             d TYPE ty_result,
           END OF ty_response.

    TYPES: BEGIN OF ty_valuation,
             product            TYPE  matnr,
             valuationarea      TYPE  bwkey,
             standardprice      TYPE  stprs,
             valuationclass     TYPE  bklas,
             priceunitqty       TYPE  peinh,
             currency           TYPE  waers,
             movingaverageprice TYPE  verpr,
           END OF ty_valuation,
           tt_valuation TYPE STANDARD TABLE OF ty_valuation WITH DEFAULT KEY,
           BEGIN OF ty_valuation_d,
             results TYPE tt_valuation,
           END OF ty_valuation_d,
           BEGIN OF ty_valuation_api,
             d TYPE ty_valuation_d,
           END OF ty_valuation_api.

    DATA:ls_response       TYPE ty_response.

    DATA:
      lt_recdvalidity  TYPE STANDARD TABLE OF ty_record,
      lt_valuation_api TYPE STANDARD TABLE OF ty_valuation,
      ls_valuation_api TYPE ty_valuation,
      ls_valuation_ecn TYPE ty_valuation_api.

    DATA:lv_path2   TYPE string,
         lv_dotimes TYPE p LENGTH 5 DECIMALS 3,
         lv_dec     TYPE i.


*    IF io_request->is_data_requested( ).
    TRY.
        "Get and add filter
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
        IF sy-subrc = 0.
        ENDIF.
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
            ls_material-low  = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = ls_material-low  ).
            ls_material-high = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = ls_material-high ).
            APPEND ls_material TO lr_material.
            CLEAR ls_material.
          WHEN 'SUPPLIERMATERIALNUMBER'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_suppliermaterialnumber.
            APPEND ls_suppliermaterialnumber TO lr_suppliermaterialnumber.
            CLEAR ls_suppliermaterialnumber.
          WHEN 'SUPPLIER'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_supplier.
            ls_supplier-low = |{ ls_supplier-low ALPHA = IN }|.
            ls_supplier-high = |{ ls_supplier-high ALPHA = IN }|.
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
        AND d~incotermsclassification IN @lr_incotermsclassification
        AND d~purchasinggroup IN @lr_purchasinggroup
        AND a~purchasinginforecord IN @lr_purchasinginforecord
        AND a~supplier IN @lr_supplier
        AND a~material IN @lr_material
        AND a~suppliermaterialnumber IN @lr_suppliermaterialnumber
        AND a~creationdate IN @lr_creationdate_1
        AND b~manufacturernumber IN @lr_manufacturernumber
        AND b~productmanufacturernumber IN @lr_productmanufacturernumber
        AND o~supplierisfixed IN @lr_supplierisfixed
        AND d~plant IN @lr_plant
        AND d~purchasingorganization IN @lr_purchasingorganization
      INTO TABLE @DATA(lt_purinfoitem2).

    IF sy-subrc = 0.
      SORT lt_purinfoitem2.
      DELETE ADJACENT DUPLICATES FROM lt_purinfoitem2 COMPARING ALL FIELDS.

      DATA(lt_supplier) = lt_purinfoitem2.
      SORT lt_supplier BY supplier.
      DELETE ADJACENT DUPLICATES FROM lt_supplier COMPARING supplier.

      DATA(lt_material) = lt_purinfoitem2.
      SORT lt_material BY material.
      DELETE ADJACENT DUPLICATES FROM lt_material COMPARING material.

      DATA(lt_plant) = lt_purinfoitem2.
      SORT lt_plant BY plant.
      DELETE ADJACENT DUPLICATES FROM lt_plant COMPARING plant.

      DATA(lt_organization) = lt_purinfoitem2.
      SORT lt_organization BY purchasingorganization.
      DELETE ADJACENT DUPLICATES FROM lt_organization COMPARING purchasingorganization.

      DATA(lt_itemcategory) = lt_purinfoitem2.
      SORT lt_itemcategory BY purchasinginforecordcategory.
      DELETE ADJACENT DUPLICATES FROM lt_itemcategory COMPARING purchasinginforecordcategory.

      DATA(lv_path) = |/API_PURGPRCGCONDITIONRECORD_SRV/A_PurgPrcgCndnRecdValidity?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
      DATA(lv_select) = |ConditionRecord,ConditionValidityStartDate,ConditionValidityEndDate,PurchasingInfoRecord| &&
                        |,Supplier,Material,Plant,PurchasingOrganization,PurchasingInfoRecordCategory|.

      lv_filter = |ConditionType eq 'PPR0'|.

      CLEAR lv_count.
      LOOP AT lt_plant INTO DATA(ls_plant1).
        lv_count += 1.
        IF lv_count = 1.
          lv_filter = |{ lv_filter } and (Plant eq '{ ls_plant1-plant }'|.
          lv_filter2 = |(ValuationArea eq '{ ls_plant1-plant }'|.
        ELSE.
          lv_filter = |{ lv_filter } or Plant eq '{ ls_plant1-plant }'|.
          lv_filter2 = |{ lv_filter2 } or ValuationArea eq '{ ls_plant1-plant }'|.
        ENDIF.
      ENDLOOP.
      lv_filter = |{ lv_filter })|.
      lv_filter2 = |{ lv_filter2 })|.

      IF lines( lt_supplier ) < 20.
        CLEAR lv_count.
        LOOP AT lt_supplier INTO DATA(ls_supplier1).
          lv_count += 1.
          IF lv_count = 1.
            lv_filter = |{ lv_filter } and (Supplier eq '{ ls_supplier1-supplier }'|.
          ELSE.
            lv_filter = |{ lv_filter } or Supplier eq '{ ls_supplier1-supplier }'|.
          ENDIF.
        ENDLOOP.
        lv_filter = |{ lv_filter })|.
      ENDIF.

      IF lines( lt_material ) < 20.
        CLEAR lv_count.
        LOOP AT lt_material INTO DATA(ls_material1).
          lv_count += 1.
          IF lv_count = 1.
            lv_filter = |{ lv_filter } and (Material eq '{ ls_material1-material }'|.
            lv_filter2 = |{ lv_filter2 } and (Product eq '{ ls_material1-material }'|.
          ELSE.
            lv_filter = |{ lv_filter } or Material eq '{ ls_material1-material }'|.
            lv_filter2 = |{ lv_filter2 } or Product eq '{ ls_material1-material }'|.
          ENDIF.
        ENDLOOP.
        lv_filter = |{ lv_filter })|.
        lv_filter2 = |{ lv_filter2 })|.
      ENDIF.

      CLEAR lv_count.
      LOOP AT lt_organization INTO DATA(ls_organization).
        lv_count += 1.
        IF lv_count = 1.
          lv_filter = |{ lv_filter } and (PurchasingOrganization eq '{ ls_organization-purchasingorganization }'|.
        ELSE.
          lv_filter = |{ lv_filter } or PurchasingOrganization eq '{ ls_organization-purchasingorganization }'|.
        ENDIF.
      ENDLOOP.
      lv_filter = |{ lv_filter })|.

      CLEAR lv_count.
      LOOP AT lt_itemcategory INTO DATA(ls_itemcategory).
        lv_count += 1.
        IF lv_count = 1.
          lv_filter = |{ lv_filter } and (PurchasingInfoRecordCategory eq '{ ls_itemcategory-purchasinginforecordcategory }'|.
        ELSE.
          lv_filter = |{ lv_filter } or PurchasingInfoRecordCategory eq '{ ls_itemcategory-purchasinginforecordcategory }'|.
        ENDIF.
      ENDLOOP.
      lv_filter = |{ lv_filter })|.

*      lv_dotimes = ceil( lines( lt_material ) / 200 ).
*
*      DO lv_dotimes TIMES.
*        CLEAR:
*          lv_filter2,
*          lv_count.
*
*        lv_filter2 = lv_filter.
*        DATA(lv_from) = ( sy-index - 1 ) * 200 + 1.
*        DATA(lv_to)   = sy-index * 200.
*
*        LOOP AT lt_material INTO DATA(ls_material1)
*          FROM lv_from TO lv_to.
*          lv_count += 1.
*          IF lv_count = 1.
*            lv_filter2 = |{ lv_filter2 } and (Material eq '{ ls_material1-material }'|.
*          ELSE.
*            lv_filter2 = |{ lv_filter2 } or Material eq '{ ls_material1-material }'|.
*          ENDIF.
*        ENDLOOP.
*        lv_filter2 = |{ lv_filter2 })|.
*
*        zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
*                                                     iv_method      = if_web_http_client=>get
*                                                     iv_select      = lv_select
*                                                     iv_filter      = lv_filter2
*                                           IMPORTING ev_status_code = DATA(lv_status_code)
*                                                     ev_response    = DATA(lv_response) ).
*        IF lv_status_code = 200.
*          REPLACE ALL OCCURRENCES OF `PurchasingInfoRecordCategory` IN lv_response  WITH `Purchasinginforecordcategory`.
*          REPLACE ALL OCCURRENCES OF `\/Date(` IN lv_response  WITH ``.
*          REPLACE ALL OCCURRENCES OF `)\/` IN lv_response  WITH ``.
*          /ui2/cl_json=>deserialize(
*                                         EXPORTING json = lv_response
*                                         CHANGING data = ls_response ).
*          APPEND LINES OF ls_response-d-results TO lt_recdvalidity.
*        ENDIF.
*      ENDDO.

      zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                   iv_method      = if_web_http_client=>get
                                                   iv_select      = lv_select
                                                   iv_filter      = lv_filter
                                         IMPORTING ev_status_code = DATA(lv_status_code)
                                                   ev_response    = DATA(lv_response) ).
      IF lv_status_code = 200.
        REPLACE ALL OCCURRENCES OF `PurchasingInfoRecordCategory` IN lv_response  WITH `Purchasinginforecordcategory`.
        REPLACE ALL OCCURRENCES OF `\/Date(` IN lv_response  WITH ``.
        REPLACE ALL OCCURRENCES OF `)\/` IN lv_response  WITH ``.
        /ui2/cl_json=>deserialize(
                                       EXPORTING json = lv_response
                                       CHANGING data = ls_response ).
        APPEND LINES OF ls_response-d-results TO lt_recdvalidity.
      ENDIF.

      lv_path2 = |/YY1_PRODUCTVALUATION_CDS/YY1_ProductValuation?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
      "Call API
      zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_path2
          iv_method      = if_web_http_client=>get
          iv_filter      = lv_filter2
          iv_format      = 'json'
        IMPORTING
          ev_status_code = DATA(lv_stat_code)
          ev_response    = DATA(lv_resbody_api) ).
      /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api
                                 CHANGING data = ls_valuation_ecn ).
      IF lv_stat_code = '200'
      AND ls_valuation_ecn-d-results IS NOT INITIAL.
        APPEND LINES OF ls_valuation_ecn-d-results TO lt_valuation_api.

        SORT lt_valuation_api BY product ASCENDING
                                 valuationarea ASCENDING.
      ENDIF.

      SORT lt_recdvalidity BY material ASCENDING
                              supplier ASCENDING
                              plant    ASCENDING
                              purchasingorganization ASCENDING
                              purchasinginforecordcategory ASCENDING
                              conditionvaliditystartdate DESCENDING.

      IF lt_recdvalidity IS NOT INITIAL.

        DATA(lt_recdvalidity_tmp) = lt_recdvalidity.
        SORT lt_recdvalidity_tmp BY conditionrecord ASCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_recdvalidity_tmp COMPARING conditionrecord.

        SELECT
          a~conditionscalequantity,
          a~conditionratevalue,
          a~conditionrecord,
          a~creationdate AS creationdate_2
        FROM i_purgprcgconditionrecord WITH PRIVILEGED ACCESS AS a
*        INNER JOIN I_ChangeDocument WITH PRIVILEGED ACCESS as b on b~ChangeDocObject = a~ConditionRecord
        FOR ALL ENTRIES IN @lt_recdvalidity_tmp
        WHERE a~conditionrecord = @lt_recdvalidity_tmp-conditionrecord
          AND a~creationdate IN @lr_creationdate_2
        INTO TABLE @DATA(lt_purinfoitem1).

        SORT lt_purinfoitem1 BY conditionrecord ASCENDING.

      ENDIF.

*      LOOP AT  lt_recdvalidity INTO DATA(lw_recdvalidity1).
*
*        READ TABLE lt_purinfoitem1 INTO DATA(lw_purinfoitem1) WITH KEY conditionrecord = lw_recdvalidity1-conditionrecord.
*        IF sy-subrc = 0.
*          lw_data-conditionscalequantity = lw_purinfoitem1-conditionscalequantity.
*          lw_data-conditionratevalue     = lw_purinfoitem1-conditionratevalue.
*          lw_data-creationdate_2         = lw_purinfoitem1-creationdate_2.
*        ELSE.
*          lw_data-conditionscalequantity = ' '.
*          lw_data-conditionratevalue     = ' '.
*          lw_data-creationdate_2         = ' '.
*        ENDIF.
*      ENDLOOP.
*      CLEAR lw_purinfoitem1.
    ENDIF.

    LOOP AT  lt_purinfoitem2 INTO DATA(lw_data2).
      MOVE-CORRESPONDING lw_data2 TO lw_data.

      IF lw_data-material IS NOT INITIAL AND lw_data-plant IS NOT INITIAL AND lw_data-supplier IS NOT INITIAL.
        lw_data-loginflag = 'X'.
      ELSE.
        lw_data-loginflag = ''.
      ENDIF.

      lw_data-deliverylt = lw_data2-materialplanneddeliverydurn + lv_plusday.

      IF lw_data2-materialpriceunitqty <> 0.
        lv_unitprice_plnt = zzcl_common_utils=>conversion_amount( iv_alpha    = zzcl_common_utils=>lc_alpha_out
                                                                  iv_currency = lw_data2-currency_plnt
                                                                  iv_input    = lw_data2-netpriceamount ).
        lv_unitprice_plnt = lv_unitprice_plnt / lw_data2-materialpriceunitqty.

        IF lw_data2-currency_plnt = 'JPY'.
          lv_dec = 3.
        ELSE.
          lv_dec = 5.
        ENDIF.

        lw_data-standardpurchaseorderquantity = round(
        val = lv_unitprice_plnt
        dec = lv_dec
        mode = cl_abap_math=>round_half_up
        ).
      ELSE.
        lw_data-unitprice_plnt = 0.
        lw_data-standardpurchaseorderquantity = 0.
      ENDIF.

      IF lv_unitprice_plnt IS NOT INITIAL AND lw_data2-zvalue2 IS NOT INITIAL AND lw_data2-zvalue2 <> 0.
        lw_data-taxprice = lv_unitprice_plnt * lw_data2-zvalue2 / 100.
      ELSE.
        " 如果有字段为空或为零，设置税价为零或其他默认值
        lw_data-taxprice = 0.
      ENDIF.

      " 查找对应的单价信息
      READ TABLE lt_valuation_api INTO DATA(lw_unitprice)
          WITH KEY product = lw_data-material
               valuationarea = lw_data-plant
               BINARY SEARCH.

      IF sy-subrc = 0. " 如果找到记录
        lw_data-unitprice_plnt = zzcl_common_utils=>conversion_amount( iv_alpha    = zzcl_common_utils=>lc_alpha_in
                                                                  iv_currency = lw_unitprice-currency
                                                                  iv_input    = lw_unitprice-standardprice ).
        lw_data-valuationclass    = lw_unitprice-valuationclass.
        lw_data-priceunitqty      = lw_unitprice-priceunitqty.
        lw_data-currency_standard = lw_unitprice-currency.

        IF lw_unitprice-priceunitqty IS NOT INITIAL AND lw_unitprice-standardprice IS NOT INITIAL.

          " 计算标准单价
          lv_unitprice_standard = lw_unitprice-standardprice / lw_unitprice-priceunitqty.

          IF lw_unitprice-currency = 'JPY'.
            lv_dec = 3.
          ELSE.
            lv_dec = 5.
          ENDIF.

          " 四舍五入至3位小数
          lw_data-unitprice_standard = round(
              val = lv_unitprice_standard
              dec = lv_dec
              mode = cl_abap_math=>round_half_up
          ).
        ELSE.
          lw_data-unitprice_standard = 0.
        ENDIF.

        lv_price = abs( lw_data-unitprice_standard - lw_data-standardpurchaseorderquantity ).

*        IF lv_price IS NOT INITIAL AND lw_data-materialpriceunitqty IS NOT INITIAL.
        IF lv_price IS NOT INITIAL AND lw_data-unitprice_standard IS NOT INITIAL.

          DATA lv_rate TYPE p DECIMALS 6.
          DATA lv_rate_display TYPE p DECIMALS 2.

*          lv_rate = lv_price / lw_data-materialpriceunitqty.
          lv_rate = lv_price / lw_data-unitprice_standard.

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

      lw_data-supplier = |{ lw_data-supplier ALPHA = OUT }|.

*      READ TABLE lt_recdvalidity INTO DATA(lw_recdvalidity) WITH KEY material = lw_data-material
*      DATA(lt_lt_recdvalidity_tmp) = lt_recdvalidity.
*      delete lt_lt_recdvalidity_tmp WHERE material <> lw_data-material
*                                       or supplier <> lw_data-supplier
*                                       or plant <> lw_data-plant
*                                       or purchasinginforecordcategory <> lw_data-purchasinginforecordcategory
*                                       or purchasingorganization <> lw_data-purchasingorganization.

      READ TABLE lt_recdvalidity TRANSPORTING NO FIELDS WITH KEY material = lw_data-material
                                                                     supplier = lw_data-supplier
                                                                        plant = lw_data-plant
                                                       purchasingorganization = lw_data-purchasingorganization
                                                 purchasinginforecordcategory = lw_data-purchasinginforecordcategory
                                                             BINARY SEARCH.

      IF sy-subrc = 0.
        DATA(lv_lastflg) = abap_on.
        LOOP AT lt_recdvalidity INTO DATA(lw_recdvalidity) FROM sy-tabix
*        LOOP AT lt_lt_recdvalidity_tmp INTO DATA(lw_recdvalidity).
          WHERE material = lw_data-material
            AND supplier = lw_data-supplier
            AND plant = lw_data-plant
            AND purchasingorganization = lw_data-purchasingorganization
            AND purchasinginforecordcategory = lw_data-purchasinginforecordcategory.

          IF lw_recdvalidity-conditionvaliditystartdate < 0.
            lw_recdvalidity-validitystartdate = '19000101'.
          ELSEIF lw_recdvalidity-validitystartdate = '253402214400000'.
            lw_recdvalidity-validitystartdate = '99991231'.
          ELSE.
            lw_recdvalidity-validitystartdate = xco_cp_time=>unix_timestamp(
                        iv_unix_timestamp = lw_recdvalidity-conditionvaliditystartdate / 1000
                     )->get_moment( )->as( xco_cp_time=>format->abap )->value+0(8).
          ENDIF.
          IF lw_recdvalidity-conditionvalidityenddate < 0.
            lw_recdvalidity-validityenddate = '19000101'.
          ELSEIF lw_recdvalidity-conditionvalidityenddate = '253402214400000'.
            lw_recdvalidity-validityenddate = '99991231'.
          ELSE.
            lw_recdvalidity-validityenddate = xco_cp_time=>unix_timestamp(
                        iv_unix_timestamp = lw_recdvalidity-conditionvalidityenddate / 1000
                     )->get_moment( )->as( xco_cp_time=>format->abap )->value+0(8).
          ENDIF.
          READ TABLE lt_purinfoitem1 INTO DATA(lw_purinfoitem1) WITH KEY conditionrecord = lw_recdvalidity-conditionrecord BINARY SEARCH.
          IF sy-subrc = 0.
            lw_data-conditionscalequantity = lw_purinfoitem1-conditionscalequantity.
            lw_data-conditionratevalue     = lw_purinfoitem1-conditionratevalue.
            lw_data-creationdate_2         = lw_purinfoitem1-creationdate_2.
          ELSE.
            CONTINUE.
*          lw_data-conditionscalequantity = ' '.
*          lw_data-conditionratevalue     = ' '.
*          lw_data-creationdate_2         = ' '.
          ENDIF.
          CLEAR lw_purinfoitem1.

*          lw_data-condition_validity_start_date = lw_recdvalidity-conditionvaliditystartdate.
*          lw_data-condition_validity_end_date   = lw_recdvalidity-conditionvalidityenddate.
          lw_data-condition_validity_start_date = lw_recdvalidity-validitystartdate.
          lw_data-condition_validity_end_date   = lw_recdvalidity-validityenddate.

          IF lw_recdvalidity-conditionvaliditystartdate >= 0
          AND lv_lastflg IS NOT INITIAL.
            lw_data-latestoffer = abap_on.
            CLEAR:
              lv_lastflg.
          ELSE.
            CLEAR lw_data-latestoffer.
          ENDIF.

          TRY.
              lw_data-purgdocorderquantityunit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = lw_data-purgdocorderquantityunit ).
              lw_data-baseunit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = lw_data-baseunit ).
              ##NO_HANDLER
            CATCH zzcx_custom_exception.
              " handle exception
              IF sy-subrc = 0.
              ENDIF.
          ENDTRY.
          TRY.
              DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
              "handle exception
              IF sy-subrc = 0.
              ENDIF.
          ENDTRY.
          lw_data-uuid = lv_uuid.
          APPEND lw_data TO lt_data.
        ENDLOOP.
      ELSE.
*        lw_data-condition_validity_start_date = ' '.
*        lw_data-condition_validity_end_date   = ' '.
*        APPEND lw_data TO lt_data.
      ENDIF.
      CLEAR:
        lw_recdvalidity,
        lw_unitprice,
        lw_data,
        lv_unitprice_plnt,
        lv_dec,
        lv_unitprice_standard,
        lv_price,
        lv_rate,
        lv_rate_display,
        lv_lastflg.
    ENDLOOP.

*    CLEAR lv_unitprice_standard.
*    CLEAR lv_unitprice_plnt.
*    CLEAR lv_rate.
*    CLEAR lv_price.
*    CLEAR lv_rate_display.

    " 如果 lv_ztype1 为 'X'，删除符合条件的记录
    IF lv_ztype1 <> 'X'.
      DELETE lt_data WHERE isdeleted IS NOT INITIAL OR ismarkedfordeletion IS NOT INITIAL.
    ENDIF.

    IF lv_ztype2 = 'X'.
      DELETE lt_data WHERE condition_validity_end_date <= sy-datum OR condition_validity_start_date >= sy-datum.
    ENDIF.

    DELETE lt_data WHERE latestoffer NOT IN lr_latestoffer.

*    LOOP AT lt_data INTO lw_data.  " 循环遍历 lt_dataS
*      APPEND lw_data TO lt_output.  " 将当前行的 lw_data 追加到 lt_output 内表
*    ENDLOOP.

    SORT lt_data
      BY purchasinginforecord ASCENDING
         purchasinginforecordcategory ASCENDING
         condition_validity_start_date ASCENDING
         conditionscalequantity ASCENDING.

    MOVE-CORRESPONDING lt_data[] TO lt_output[].

    " Filtering
    zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
                                           it_excluded = VALUE #( ( fieldname = 'MATERIAL' )
                                                                  ( fieldname = 'SUPPLIER' )
                                                                  ( fieldname = 'CREATIONDATE_1' )
                                                                  ( fieldname = 'CREATIONDATE_2' )
                                                                  ( fieldname = 'PLUSDAY' )
                                                                  ( fieldname = 'ZTYPE1' )
                                                                  ( fieldname = 'ZTYPE2' ) )
                                 CHANGING  ct_data     = lt_output ).

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
