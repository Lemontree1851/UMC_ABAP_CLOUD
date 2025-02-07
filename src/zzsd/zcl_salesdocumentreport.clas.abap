CLASS zcl_salesdocumentreport DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SALESDOCUMENTREPORT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA:
      lt_data                   TYPE STANDARD TABLE OF zr_salesdocumentreport,
      lw_data                   LIKE LINE OF lt_data,
      lt_output                 TYPE STANDARD TABLE OF zr_salesdocumentreport,
      lr_salesorganization      TYPE RANGE OF zr_salesdocumentreport-salesorganization,  "販売組織
      lr_salesorganization_auth TYPE RANGE OF zr_salesdocumentreport-salesorganization,  "販売組織
      lr_customer               TYPE RANGE OF zr_salesdocumentreport-customer,           "得意先
      lr_product                TYPE RANGE OF zr_salesdocumentreport-product,            "品目
      lr_conditioncurrency      TYPE RANGE OF zr_salesdocumentreport-conditioncurrency,  "通貨
      ls_salesorganization      LIKE LINE OF  lr_salesorganization,
      ls_customer               LIKE LINE OF  lr_customer,
      ls_product                LIKE LINE OF  lr_product,
      ls_conditioncurrency      LIKE LINE OF  lr_conditioncurrency.
    TYPES:
      BEGIN OF ty_finalproductinfo,
        highlevelmaterial            TYPE matnr,
        plant                        TYPE werks_d,
        billofmaterialcomponent      TYPE matnr,
        material                     TYPE matnr,
        validitystartdate            TYPE matnr,
        billofmaterialitemnumber     TYPE n LENGTH 4,
        billofmaterialitemquantity   TYPE i_billofmaterialitemdex_3-billofmaterialitemquantity,
        billofmaterialitemunit       TYPE meins,
        billofmaterialvariant        TYPE i_materialbomlink-billofmaterialvariant,
        billofmaterial               TYPE i_materialbomlink-billofmaterial,
        billofmaterialitemnodenumber TYPE i_billofmaterialitemdex_3-billofmaterialitemnodenumber,
        billofmaterialcategory       TYPE i_materialbomlink-billofmaterialcategory,
      END OF ty_finalproductinfo.

    TYPES:
      BEGIN OF ty_planversion,
        createdbyuser    TYPE c_salesplanvaluehelp-createdbyuser,
        salesplan        TYPE c_salesplanvaluehelp-salesplan,
        salesplanversion TYPE c_salesplanvaluehelp-salesplanversion,
      END OF ty_planversion.

    DATA:lt_planversion TYPE STANDARD TABLE OF ty_planversion,
         ls_planversion TYPE ty_planversion.

    DATA:lt_version TYPE STANDARD TABLE OF ty_planversion,
         ls_version TYPE ty_planversion.

    DATA:lt_version0 TYPE STANDARD TABLE OF ty_planversion,
         ls_version0 TYPE ty_planversion.

    DATA:lt_version1 TYPE STANDARD TABLE OF ty_planversion,
         ls_version1 TYPE ty_planversion.

    DATA:lt_version2 TYPE STANDARD TABLE OF ty_planversion,
         ls_version2 TYPE ty_planversion.

    DATA:lt_version3 TYPE STANDARD TABLE OF ty_planversion,
         ls_version3 TYPE ty_planversion.

    DATA:lv_version0 TYPE   sales_plan_version.
    DATA:lv_version1 TYPE   sales_plan_version.
    DATA:lv_version2 TYPE   sales_plan_version.
    DATA:lv_version3 TYPE   sales_plan_version.

    DATA: lv_grossprofit           TYPE p DECIMALS 0,
          lv_contributionprofit    TYPE p DECIMALS 0,
          lt_usagelist             TYPE STANDARD TABLE OF zcl_bom_where_used=>ty_usagelist,
          lt_highlevelmaterialinfo TYPE STANDARD TABLE OF zcl_bom_where_used=>ty_usagelist,
          lt_finalproductinfo      TYPE STANDARD TABLE OF ty_finalproductinfo,
          ls_finalproductinfo      TYPE ty_finalproductinfo.

    DATA:
      lv_previousperiod TYPE monat,
      lv_poper          TYPE poper,
      lv_amt(8)         TYPE p DECIMALS 2,
      lv_amt_bukrs(8)   TYPE p DECIMALS 2,
      lv_amt_2000(8)    TYPE p DECIMALS 2,
      lv_amt_3000(8)    TYPE p DECIMALS 2,
      lv_year           TYPE c LENGTH 4,
      lv_lastyear       TYPE c LENGTH 4,
      lv_month          TYPE monat,
      lv_nextmonth      TYPE budat,
      lv_from           TYPE budat,
      lv_to             TYPE budat,
      lv_i              TYPE i,
      lv_j              TYPE i,
      lv_num_parent     TYPE n LENGTH 2,
      lv_num_son        TYPE n LENGTH 2,
      lv_num            TYPE n LENGTH 2,
      lv_index          TYPE i,
      lv_peinh(7)       TYPE p DECIMALS 3,
      lv_length         TYPE i.
    TYPES: BEGIN OF ty_results,
             conditionrecord              TYPE string,
             conditiontype                TYPE string,
             conditionvaliditystartdate_d TYPE d,
             conditionvalidityenddate_d   TYPE d,
             salesorganization            TYPE string,
             distributionchannel          TYPE string,
             material                     TYPE matnr,
             customer                     TYPE kunnr,

             "i_slsperformanceplanactualcube
             conditionratevalue           TYPE string,
             conditionratevalueunit       TYPE waers,
             conditionquantityunit        TYPE string,
             conditionquantity            TYPE string,
             conditionscalequantity       TYPE string,
             conditionscaleamount         TYPE string,
             conditioncurrency            TYPE string,
             conditionscaleamountcurrency TYPE waers,
           END OF ty_results,
           BEGIN OF ty_collect,
             conditiontype                TYPE string,
             conditionvaliditystartdate_d TYPE d,
             salesorganization            TYPE string,
             distributionchannel          TYPE string,
             material                     TYPE string,
             customer                     TYPE string,
             conditionquantityunit        TYPE string,
             counts                       TYPE i,
           END OF ty_collect,
           tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_d,
             results TYPE tt_results,
           END OF ty_d,
           BEGIN OF ty_res_api,
             d TYPE ty_d,
           END OF ty_res_api.
    DATA:ls_res_api TYPE ty_res_api.
    TYPES:
      BEGIN OF ty_results1,
        costestimate(12) TYPE n,
        material         TYPE string,
        plant            TYPE string,
        companycode      TYPE string,
        valuationarea    TYPE string,
        costingdate_d    TYPE d,
        costingdate      TYPE timestamp,
      END OF ty_results1,
      tt_results1 TYPE STANDARD TABLE OF ty_results1 WITH DEFAULT KEY,
      BEGIN OF ty_d1,
        results TYPE tt_results1,
      END OF ty_d1,
      BEGIN OF ty_res_api1,
        d TYPE ty_d1,
      END OF ty_res_api1.
    TYPES:
      BEGIN OF ty_productcost,
        material                   TYPE matnr,
        plant                      TYPE werks_d,
        ztype(10)                  TYPE c,
        controllingareacurrency    TYPE i_productcostestimateitem-controllingareacurrency,
        totalamountinctrlgareacrcy TYPE i_productcostestimateitem-totalamountinctrlgareacrcy,
      END OF ty_productcost.
    DATA:lt_productcost TYPE STANDARD TABLE OF ty_productcost.
    DATA:ls_productcost TYPE ty_productcost.
    DATA:ls_res_api1  TYPE ty_res_api1.
    DATA:lv_path    TYPE string.
    DATA:lt_collect TYPE STANDARD TABLE OF ty_collect.
    DATA:ls_collect TYPE ty_collect.
    CONSTANTS:lc_exchangetype    TYPE string VALUE '0'.
    CONSTANTS:lc_ppr0(4) TYPE c VALUE 'PPR0'.
    CONSTANTS:lc_zyr0(4) TYPE c VALUE 'ZYR0'.
    CONSTANTS:lc_zzr0(4) TYPE c VALUE 'ZZR0'.
    TRY.
        "Get and add filter
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option) ##NO_HANDLER.
    ENDTRY.

    DATA(lv_top)    = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)   = io_request->get_paging( )->get_offset( ).
    DATA(lt_fields) = io_request->get_requested_elements( ).
    DATA(lt_sort)   = io_request->get_sort_elements( ).

    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
    DATA(lv_user_salesorg) = zzcl_common_utils=>get_salesorg_by_user( lv_user_email ).
    SPLIT lv_user_salesorg AT '&' INTO TABLE DATA(lt_salesorg).
    lr_salesorganization_auth = VALUE #( FOR salesorganization IN lt_salesorg ( sign = 'I' option = 'EQ' low = salesorganization ) ).

    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).

      LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).

        CASE ls_filter_cond-name.
          WHEN 'SALESORGANIZATION'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_salesorganization.
            IF ls_salesorganization-low IN lr_salesorganization_auth AND lr_salesorganization_auth IS NOT INITIAL.
              APPEND ls_salesorganization TO lr_salesorganization.
            ENDIF.
            CLEAR ls_salesorganization.
          WHEN 'CUSTOMER'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_customer.

            ls_customer-low = |{ ls_customer-low ALPHA = IN }|.
            APPEND ls_customer TO lr_customer.
            CLEAR ls_customer.
          WHEN 'PRODUCT'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_product.
            APPEND ls_product TO lr_product.
            CLEAR ls_product.
*          WHEN 'PLANTYPE'.
*            DATA(lr_plantype) = ls_filter_cond-range.
*            READ TABLE lr_plantype INTO DATA(lrs_plantype) INDEX 1.
*            DATA(lv_ztype1) = lrs_plantype-low.
          WHEN 'SPLITRANGE'.
            DATA(r_splitrange) = ls_filter_cond-range.
            READ TABLE r_splitrange INTO DATA(rs_splitrange) INDEX 1.
            IF sy-subrc = 0.
              SPLIT rs_splitrange-low AT '-' INTO DATA(lv_splitstart) DATA(lv_splitend).
            ENDIF.
          WHEN 'CONDITIONCURRENCY'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_conditioncurrency.
            APPEND ls_conditioncurrency TO lr_conditioncurrency.
            CLEAR ls_conditioncurrency.
          WHEN 'SALESPLANVERSION0'.
            DATA(lr_version0) = ls_filter_cond-range.
            READ TABLE lr_version0 INTO DATA(lrs_version0) INDEX 1.
            lv_version0 = lrs_version0-low.
          WHEN 'SALESPLANVERSION1'.
            DATA(lr_version1) = ls_filter_cond-range.
            READ TABLE lr_version1 INTO DATA(lrs_version1) INDEX 1.
            lv_version1 = lrs_version1-low.
          WHEN 'SALESPLANVERSION2'.
            DATA(lr_version2) = ls_filter_cond-range.
            READ TABLE lr_version2 INTO DATA(lrs_version2) INDEX 1.
            lv_version2 = lrs_version2-low.
          WHEN 'SALESPLANVERSION3'.
            DATA(lr_version3) = ls_filter_cond-range.
            READ TABLE lr_version3 INTO DATA(lrs_version3) INDEX 1.
            lv_version3 = lrs_version3-low.
          WHEN OTHERS.

        ENDCASE.

      ENDLOOP.

    ENDLOOP.

    READ TABLE lt_filter_cond TRANSPORTING NO FIELDS WITH KEY name = 'SALESORGANIZATION'.
    IF sy-subrc <> 0.
      lr_salesorganization = lr_salesorganization_auth.
    ENDIF.
    "不存在为空的情况
    IF lr_salesorganization IS INITIAL .
      CLEAR ls_salesorganization.
      ls_salesorganization-sign = 'I'.
      ls_salesorganization-option = 'EQ' .
      ls_salesorganization-low = '' .
      INSERT ls_salesorganization INTO TABLE lr_salesorganization.
    ENDIF.
***-------------------------ADD -----------20241207---begin-----***
    DATA: lv_begda TYPE d,
          lv_endda TYPE d.
    TYPES: BEGIN OF ty_month,
             month TYPE n LENGTH 6,
             begda TYPE d,
             endda TYPE d,
           END OF ty_month.
    DATA: lt_months TYPE TABLE OF ty_month,
          ls_months TYPE ty_month,
          lv_datum  TYPE d.
    DATA:lv_local_date TYPE bldat.
    DATA:lv_local_time TYPE uzeit.
    DATA: lv_local_begda TYPE d,
          lv_local_endda TYPE d.
    DATA:lv_local_begda_s(10) TYPE c.
    DATA:lv_local_endda_s(10) TYPE c.
    DATA:lv_timestamp TYPE abp_creation_tstmpl .
    GET TIME STAMP FIELD lv_timestamp.
    TRY.
        "获取执行报表的用户的local时间的月
        DATA(lv_timezone) = cl_abap_context_info=>get_user_time_zone( ).
        "时间戳格式转换成日期格式
        CONVERT TIME STAMP lv_timestamp TIME ZONE lv_timezone INTO DATE lv_local_date TIME lv_local_time .
        lv_local_begda = lv_local_date+0(6) && '01'.
        lv_local_endda = lv_local_date+0(6) && '01'.
        "lv_local_begda = zzcl_common_utils=>calc_date_add( date = lv_begda month = 3 ).
        "lv_local_endda = zzcl_common_utils=>calc_date_add( date = lv_endda month = 3 ).
        lv_local_endda = zzcl_common_utils=>get_enddate_of_month( lv_local_endda ).

        lv_local_begda_s = lv_local_begda+0(4) && '-' && lv_local_begda+4(2) && '-' && lv_local_begda+6(2).
      CATCH cx_abap_context_info_error INTO DATA(e) ##NO_HANDLER.
        "handle exception
    ENDTRY.

    IF lv_version0 IS NOT INITIAL.

      DATA(lv_ztype1) = lv_version0+0(1).

    ELSEIF lv_version1 IS NOT INITIAL.

      lv_ztype1 = lv_version1+0(1).

    ENDIF.


    DATA(lv_typeab) = lv_ztype1 && '%'.

    SELECT
      createdbyuser,
      salesplan,
      salesplanversion
    FROM c_salesplanvaluehelp WITH PRIVILEGED ACCESS
    WHERE salesplanversion LIKE @lv_typeab
    AND ( salesplanversion = @lv_version0 OR salesplanversion = @lv_version1 OR
    salesplanversion = @lv_version2 OR salesplanversion = @lv_version3 )
    INTO TABLE @lt_planversion.

    "计算两位之后最大的和以0、1、2、3开头的各自最大的
    LOOP AT lt_planversion INTO ls_planversion.
      IF ls_version-salesplanversion+2 < ls_planversion-salesplanversion+2.
        ls_version = ls_planversion.
      ENDIF.
      CASE ls_planversion-salesplanversion+1(1).
        WHEN '0'.
          IF ls_version0-salesplanversion+1 < ls_planversion-salesplanversion+1.
            ls_version0 = ls_planversion.
          ENDIF.
        WHEN '1'.
          IF ls_version1-salesplanversion+1 < ls_planversion-salesplanversion+1.
            ls_version1 = ls_planversion.
          ENDIF.
        WHEN '2'.
          IF ls_version2-salesplanversion+1 < ls_planversion-salesplanversion+1.
            ls_version2 = ls_planversion.
          ENDIF.
        WHEN '3'.
          IF ls_version3-salesplanversion+1 < ls_planversion-salesplanversion+1.
            ls_version3 = ls_planversion.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    "根据所有计划版本最大的取
*    SELECT
*      salesorganization,
*      salesoffice,
*      salesgroup,
*      soldtoparty,
*      product,
*      productgroup,
*      plant,
*      profitcenter,
*      salesplanperiodname,
*      salesplanunit
*    FROM i_slsperformanceplanactualcube(
*      p_exchangeratetype = 0,
*      p_displaycurrency  = 'JPY',
*      p_salesplan        = @ls_version-salesplan,
*      p_salesplanversion = @ls_version-salesplanversion,
*      p_createdbyuser    = @ls_version-createdbyuser ) WITH PRIVILEGED ACCESS
*    WHERE salesorganization IN @lr_salesorganization
*      AND soldtoparty       IN @lr_customer
*      AND product           IN @lr_product
*      AND sddocument = '0000000000'
*    INTO TABLE @DATA(lt_result).

    "根据0开头计划版本最大的取
    SELECT
      salesorganization,
      salesoffice,
      salesgroup,
      soldtoparty,
      product,
      productgroup,
      plant,
      profitcenter,
      salesplanperiodname,
      salesplanquantity,
      salesplanunit,
      salesplanperiodname AS username
    FROM i_slsperformanceplanactualcube(
      p_exchangeratetype = 0,
      p_displaycurrency  = 'JPY',
      p_salesplan        = @ls_version0-salesplan,
      p_salesplanversion = @ls_version0-salesplanversion,
      p_createdbyuser    = @ls_version0-createdbyuser ) WITH PRIVILEGED ACCESS
    WHERE salesorganization IN @lr_salesorganization
      AND soldtoparty       IN @lr_customer
      AND product           IN @lr_product
      AND sddocument = '0000000000'
    INTO TABLE @DATA(lt_result0).

    "根据1开头计划版本最大的取
    SELECT
      salesorganization,
      salesoffice,
      salesgroup,
      soldtoparty,
      product,
      productgroup,
      plant,
      profitcenter,
      salesplanperiodname,
      salesplanamountindspcrcy,
      displaycurrency,
      salesplanunit,
      salesplanperiodname AS username
    FROM i_slsperformanceplanactualcube(
      p_exchangeratetype = 0,
      p_displaycurrency  = 'JPY',
      p_salesplan        = @ls_version1-salesplan,
      p_salesplanversion = @ls_version1-salesplanversion,
      p_createdbyuser    = @ls_version1-createdbyuser ) WITH PRIVILEGED ACCESS
    WHERE salesorganization IN @lr_salesorganization
      AND soldtoparty       IN @lr_customer
      AND product           IN @lr_product
       AND sddocument = '0000000000'
    INTO TABLE @DATA(lt_result1).

    "根据2开头计划版本最大的取
    SELECT
      salesorganization,
      salesoffice,
      salesgroup,
      soldtoparty,
      product,
      productgroup,
      plant,
      profitcenter,
      salesplanperiodname,
      salesplanamountindspcrcy,
      displaycurrency,
      salesplanunit,
      salesplanperiodname AS username
    FROM i_slsperformanceplanactualcube(
      p_exchangeratetype = 0,
      p_displaycurrency  = 'JPY',
      p_salesplan        = @ls_version2-salesplan,
      p_salesplanversion = @ls_version2-salesplanversion,
      p_createdbyuser    = @ls_version2-createdbyuser ) WITH PRIVILEGED ACCESS
    WHERE salesorganization IN @lr_salesorganization
      AND soldtoparty       IN @lr_customer
      AND product           IN @lr_product
       AND sddocument = '0000000000'
    INTO TABLE @DATA(lt_result2).

    "根据3开头计划版本最大的取
    SELECT
      salesorganization,
      salesoffice,
      salesgroup,
      soldtoparty,
      product,
      productgroup,
      plant,
      profitcenter,
      salesplanperiodname,
      salesplanamountindspcrcy,
      displaycurrency,
      salesplanunit,
      salesplanperiodname AS username
    FROM i_slsperformanceplanactualcube(
      p_exchangeratetype = 0,
      p_displaycurrency  = 'JPY',
      p_salesplan        = @ls_version3-salesplan,
      p_salesplanversion = @ls_version3-salesplanversion,
      p_createdbyuser    = @ls_version3-createdbyuser ) WITH PRIVILEGED ACCESS
    WHERE salesorganization IN @lr_salesorganization
      AND soldtoparty       IN @lr_customer
      AND product           IN @lr_product
      AND sddocument = '0000000000'
    INTO TABLE @DATA(lt_result3).

    "需要取0 1 2 3开头版本最大的值
    IF lt_result0 IS NOT INITIAL OR lt_result1 IS NOT INITIAL OR lt_result2 IS NOT INITIAL OR lt_result3 IS NOT INITIAL.
      "0 1 2 3的创建人不一样 要分别匹配
      READ TABLE lt_result0 INTO DATA(ls_result0_temp0) INDEX 1.
      ls_result0_temp0-username = ls_version0-createdbyuser.
      MODIFY lt_result0 FROM ls_result0_temp0 TRANSPORTING username WHERE salesplanperiodname IS NOT INITIAL.

      READ TABLE lt_result1 INTO DATA(ls_result1_temp) INDEX 1.
      ls_result1_temp-username = ls_version1-createdbyuser.
      MODIFY lt_result1 FROM ls_result1_temp TRANSPORTING username WHERE salesplanperiodname IS NOT INITIAL.

      READ TABLE lt_result2 INTO DATA(ls_result2_temp) INDEX 1.
      ls_result2_temp-username = ls_version2-createdbyuser.
      MODIFY lt_result2 FROM ls_result2_temp TRANSPORTING username WHERE salesplanperiodname IS NOT INITIAL.

      READ TABLE lt_result3 INTO DATA(ls_result3_temp) INDEX 1.
      ls_result3_temp-username = ls_version3-createdbyuser.
      MODIFY lt_result3 FROM ls_result3_temp TRANSPORTING username WHERE salesplanperiodname IS NOT INITIAL.


      DATA(lt_result) = lt_result0.
      MOVE-CORRESPONDING lt_result1 TO lt_result KEEPING TARGET LINES.
      MOVE-CORRESPONDING lt_result2 TO lt_result KEEPING TARGET LINES.
      MOVE-CORRESPONDING lt_result3 TO lt_result KEEPING TARGET LINES.
      "0 1 2 3开头版本里存在重复key 如果非常规情况下 某key的0 1 2 3同时存在，需要保留 0开头的单位
      SORT lt_result BY salesorganization salesoffice salesgroup soldtoparty product productgroup plant profitcenter salesplanperiodname salesplanunit DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_result COMPARING salesorganization salesoffice salesgroup soldtoparty product productgroup plant profitcenter salesplanperiodname.
    ENDIF.

    IF lt_result IS NOT INITIAL.
      "取客户名称
      SELECT
        customer,
        customername
      FROM i_customer WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_result
      WHERE customer = @lt_result-soldtoparty
      AND language = 'J'
      INTO TABLE @DATA(lt_customer).
      SORT lt_customer BY customer.

      "取利润中心
      SELECT
      product,plant,profitcenter
      FROM
      i_productplantbasic
      FOR ALL ENTRIES IN @lt_result
      WHERE product = @lt_result-product
      AND plant = @lt_result-salesorganization
      INTO TABLE @DATA(lt_productplantbasic).
      SORT lt_productplantbasic BY product plant.

      "取物料组
      SELECT
        product,productgroup
      FROM i_product WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_result
      WHERE product = @lt_result-product
      INTO TABLE @DATA(lt_product).
      SORT lt_product BY product.

      "取物料组1\物料组2\物料组3\物料账户设置组\管理分类
      SELECT
        a~product,
        a~firstsalesspecproductgroup,
        a~secondsalesspecproductgroup,
        a~thirdsalesspecproductgroup,
        a~accountdetnproductgroup,
        b~matlaccountassignmentgroup
      FROM i_productsalesdelivery WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_matlaccountassignmentgroup  WITH PRIVILEGED ACCESS AS b
      ON a~accountdetnproductgroup = b~matlaccountassignmentgroup
      FOR ALL ENTRIES IN @lt_result
      WHERE a~product = @lt_result-product
      INTO TABLE @DATA(lt_psdmaag).
      SORT lt_psdmaag BY product.

      IF lt_psdmaag IS NOT INITIAL.

        SELECT salesspcfcproductgroup1,salesspcfcproductgroup1name
            FROM i_salesspcfcproductgroup1text
        WHERE language = 'J'
         INTO TABLE @DATA(lt_group1text).
        SORT lt_group1text BY  salesspcfcproductgroup1.

        SELECT salesspcfcproductgroup2,salesspcfcproductgroup2name
          FROM i_salesspcfcproductgroup2text
        WHERE language = 'J'
         INTO TABLE @DATA(lt_group2text).
        SORT lt_group2text BY  salesspcfcproductgroup2.

        SELECT salesspcfcproductgroup3,salesspcfcproductgroup3name
          FROM i_salesspcfcproductgroup3text
        WHERE language = 'J'
         INTO TABLE @DATA(lt_group3text).
        SORT lt_group3text BY  salesspcfcproductgroup3.

      ENDIF.

      "取品名
      SELECT
        product,
        productname
      FROM i_producttext WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_result
      WHERE product = @lt_result-product
      INTO TABLE @DATA(lt_producttext).
      SORT lt_producttext BY product.

      "取工厂名称
      SELECT
        plant,
        plantname,
        valuationarea
      FROM i_plant WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_result
      WHERE plant = @lt_result-salesorganization
      AND language = 'J'
      INTO TABLE @DATA(lt_plant).
      SORT lt_plant BY plant.

      "取客户帐户设置组
      SELECT
        customer,
        customeraccountassignmentgroup,
        salesoffice,
        salesgroup
      FROM i_customersalesarea WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_result
      WHERE customer = @lt_result-soldtoparty
      INTO TABLE @DATA(lt_customersalesarea).
      SORT lt_customersalesarea BY customer.
    ENDIF.

    "取账号名称
    SELECT userid,
           userdescription
      FROM i_user WITH PRIVILEGED ACCESS
       FOR ALL ENTRIES IN @lt_planversion
     WHERE userid = @lt_planversion-createdbyuser
      INTO TABLE @DATA(lt_userdescription).   "#EC CI_FAE_LINES_ENSURED

    SORT lt_userdescription BY userid.

    "取单价
    lv_begda = lv_splitstart && '01'.
    lv_endda = lv_splitend   && '01'.
    "lv_begda = zzcl_common_utils=>calc_date_add( date = lv_begda month = 3 ).
    "lv_endda = zzcl_common_utils=>calc_date_add( date = lv_endda month = 3 ).
    lv_endda = zzcl_common_utils=>get_enddate_of_month( lv_endda ).
    IF lv_ztype1 = 'A'.
      SELECT
        conditionrecord,
        conditiontype,
        conditionvaliditystartdate,
        conditionratevalue,
        conditionratevalueunit,
        conditionvalidityenddate,
        conditionquantityunit,
        conditionquantity,
        conditionscalequantity,
        conditionscaleamount,
        conditioncurrency,
        conditionscaleamountcurrency
      FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
      WHERE conditiontype = 'ZYP0'
        AND conditionisdeleted = @space
        AND conditionvaliditystartdate LE @lv_endda
        AND conditionvalidityenddate   GE @lv_begda
      INTO TABLE @DATA(lt_slsprcgconditionrecord).

    ELSEIF lv_ztype1 = 'B'.
      SELECT
        conditionrecord,
        conditiontype,
        conditionvaliditystartdate,
        conditionratevalue,
        conditionratevalueunit,
        conditionvalidityenddate,
        conditionquantityunit,
        conditionquantity,
        conditionscalequantity,
        conditionscaleamount,
        conditioncurrency,
        conditionscaleamountcurrency
      FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
      WHERE conditiontype IN ('PPR0','ZZR0')
        AND conditionisdeleted = @space
        AND conditionvaliditystartdate LE @lv_endda
        AND conditionvalidityenddate   GE @lv_begda
      INTO TABLE @lt_slsprcgconditionrecord.
    ENDIF.

    SORT lt_slsprcgconditionrecord BY conditionrecord.


    "Obtain 305 condition table
    lv_path = |/API_SLSPRICINGCONDITIONRECORD_SRV/A_SlsPrcgCndnRecdValidity?$filter=ConditionType%20eq%20'{ lc_ppr0 }'%20or%20ConditionType%20eq%20'{ lc_zzr0 }'%20or%20ConditionType%20eq%20'{ lc_zyr0 }'|.

    "Call API
    zzcl_common_utils=>request_api_v2(
      EXPORTING
       iv_path        = lv_path
        iv_method      = if_web_http_client=>get
        iv_format      = 'json'
        iv_select = 'ConditionRecord,ConditionType,SalesOrganization,DistributionChannel,Customer,Material'

      IMPORTING
        ev_status_code = DATA(lv_stat_code)
        ev_response    = DATA(lv_resbody_api) ).
    TRY.
        /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api
          CHANGING  data = ls_res_api ).
        LOOP AT ls_res_api-d-results INTO DATA(ls_result_p).

          READ TABLE lt_slsprcgconditionrecord INTO DATA(ls_slsprcgconditionrecord) WITH KEY conditionrecord = ls_result_p-conditionrecord BINARY SEARCH.
          IF sy-subrc = 0.
            ls_result_p-conditionvaliditystartdate_d = ls_slsprcgconditionrecord-conditionvaliditystartdate.
            ls_result_p-conditionvalidityenddate_d   = ls_slsprcgconditionrecord-conditionvalidityenddate.
            ls_result_p-conditionratevalue           = ls_slsprcgconditionrecord-conditionratevalue.
            ls_result_p-conditionratevalueunit       = ls_slsprcgconditionrecord-conditionratevalueunit.
            ls_result_p-conditionquantityunit        = ls_slsprcgconditionrecord-conditionquantityunit.
            ls_result_p-conditionquantity            = ls_slsprcgconditionrecord-conditionquantity.
            ls_result_p-conditionscalequantity       = ls_slsprcgconditionrecord-conditionscalequantity.
            ls_result_p-conditionscaleamount         = ls_slsprcgconditionrecord-conditionscaleamount.
            ls_result_p-conditionscaleamountcurrency = ls_slsprcgconditionrecord-conditionscaleamountcurrency.
            ls_result_p-conditioncurrency = ls_slsprcgconditionrecord-conditioncurrency.
          ENDIF.
          ls_result_p-customer = |{ ls_result_p-customer ALPHA = IN }|.
          ls_result_p-material = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = 'IN'
                                                                                iv_input = ls_result_p-material ).
          IF ls_result_p-conditioncurrency NOT IN lr_conditioncurrency.
            DELETE ls_res_api-d-results.
            CONTINUE.
          ENDIF.
          MODIFY ls_res_api-d-results FROM ls_result_p.
          MOVE-CORRESPONDING ls_result_p TO ls_collect.
          ls_collect-counts = 1.
          COLLECT ls_collect INTO lt_collect.
        ENDLOOP.
        SORT ls_res_api-d-results BY salesorganization distributionchannel material customer conditionquantityunit conditionvaliditystartdate_d DESCENDING.
        "阶梯价格 ConditionScaleQuantity≤No.2のSalesPlanQuantityの行を取得する
        DATA(lt_tiered) = ls_res_api-d-results.
        SORT lt_tiered BY salesorganization distributionchannel material customer conditionquantityunit conditionvaliditystartdate_d conditionscalequantity DESCENDING.

        DELETE lt_collect WHERE counts = 1.
      CATCH cx_root INTO DATA(lx_root3) ##NO_HANDLER.
    ENDTRY.

    "获取涉及到的月份
    IF lv_splitstart <= lv_splitend."防止死循环
      lv_datum = lv_splitstart && '01'.
      DO.
        ls_months-month = lv_datum(6).
        ls_months-begda = lv_datum.
        lv_datum = zzcl_common_utils=>get_enddate_of_month( lv_datum ).
        ls_months-endda = lv_datum.
        APPEND ls_months TO lt_months.
        lv_datum = lv_datum + 1.
        IF lv_datum(6) > lv_splitend.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.

    "获取加工费
    IF lt_result IS NOT INITIAL.

      lv_path = |/YY1_PRODUCTCOSTESTIMATED_CDS/YY1_ProductCostEstimateD|.
      "lv_path = |/YY1_PRODUCTCOSTESTIMATED_CDS/YY1_ProductCostEstimateD?$filter=CostingDate%20eq%20datetime'{ lv_local_begda_s }T00:00:00'|.

      "Call API
      zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_path
          iv_method      = if_web_http_client=>get
          iv_format      = 'json'
        IMPORTING
          ev_status_code = DATA(lv_stat_code1)
          ev_response    = DATA(lv_resbody_api1) ).
      TRY.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api1
                  CHANGING  data = ls_res_api1 ).

        CATCH cx_root INTO DATA(lx_root4) ##NO_HANDLER.
      ENDTRY.

      "只保留符合条件的成本估算
      LOOP AT ls_res_api1-d-results INTO DATA(ls_result_p1).
        READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY salesorganization = ls_result_p1-plant
                                                             product           = ls_result_p1-material.
        IF sy-subrc <> 0.
          DELETE ls_res_api1-d-results.
          CONTINUE.
        ENDIF.
        "时间戳格式转换成日期格式
        ls_result_p1-costingdate_d = CONV string( ls_result_p1-costingdate DIV 1000000 ).
        MODIFY ls_res_api1-d-results  FROM ls_result_p1 TRANSPORTING costingdate_d .

      ENDLOOP.

      "保留日期最大的
      SORT ls_res_api1-d-results BY plant material costingdate DESCENDING.
      DELETE ADJACENT DUPLICATES FROM ls_res_api1-d-results COMPARING plant material .


      SORT ls_res_api1-d-results BY costestimate.

      IF ls_res_api1-d-results IS NOT INITIAL.
        "取成本估算号码 取全部主键 防止去重
        SELECT
         costingreferenceobject,
         costestimate,
         costingtype,
         costingdate,
         costingversion,
         valuationvariant,
         costisenteredmanually,
         costingitem,

         costcomponent,
         controllingareacurrency,
         totalamountinctrlgareacrcy,
         costingpriceunitqty
        FROM i_productcostestimateitem WITH PRIVILEGED ACCESS "#EC CI_FAE_LINES_ENSURED
        FOR ALL ENTRIES IN @ls_res_api1-d-results
       WHERE costestimate = @ls_res_api1-d-results-costestimate
        INTO TABLE  @DATA(lt_productcostestimateitem).
        SORT lt_productcostestimateitem BY costestimate costcomponent.

      ENDIF.
      LOOP AT lt_productcostestimateitem INTO DATA(ls_productcostestimateitem).

        READ TABLE ls_res_api1-d-results INTO ls_result_p1 WITH KEY costestimate = ls_productcostestimateitem-costestimate BINARY SEARCH.
        IF sy-subrc = 0.
          ls_productcost-material = ls_result_p1-material.
          ls_productcost-plant = ls_result_p1-plant .
          ls_productcost-controllingareacurrency  = ls_productcostestimateitem-controllingareacurrency  .
          ls_productcost-totalamountinctrlgareacrcy = ls_productcostestimateitem-totalamountinctrlgareacrcy / ls_productcostestimateitem-costingpriceunitqty .

          IF ls_productcostestimateitem-costcomponent = '101'
          OR ls_productcostestimateitem-costcomponent = '102'
          OR ls_productcostestimateitem-costcomponent = '103' .
            "加工费
            ls_productcost-ztype = 'PROCESS'.

          ELSEIF ls_productcostestimateitem-costcomponent = '201'
              OR ls_productcostestimateitem-costcomponent = '202'
              OR ls_productcostestimateitem-costcomponent = '203'
              OR ls_productcostestimateitem-costcomponent = '204'
              OR ls_productcostestimateitem-costcomponent = '205'
              OR ls_productcostestimateitem-costcomponent = '206'
              OR ls_productcostestimateitem-costcomponent = '207'
              OR ls_productcostestimateitem-costcomponent = '208'
              OR ls_productcostestimateitem-costcomponent = '209'.
            "材料费
            ls_productcost-ztype = 'RAW'.
          ELSE.

            ls_productcost-ztype = ''.
          ENDIF.

        ENDIF.
        COLLECT ls_productcost INTO lt_productcost.

      ENDLOOP.

      SORT lt_productcost BY material plant ztype.

      SELECT *
        FROM ztbc_1001 WITH PRIVILEGED ACCESS
       WHERE zid   = 'ZSD017'
         AND zkey1 = 'GL_ACCOUNT'
        INTO TABLE @DATA(lt_ztbc_1001).       "#EC CI_ALL_FIELDS_NEEDED

*
*
*      "BOM 展开
*      DATA: lt_bomlist_tmp TYPE STANDARD TABLE OF zcl_explodebom=>ty_bomlist,
*            lt_bomlist     TYPE STANDARD TABLE OF zcl_explodebom=>ty_bomlist,
*            ls_bomlist_tmp TYPE zcl_explodebom=>ty_bomlist.
*      SELECT a~billofmaterial,
*             a~material,
*             a~plant,
*             a~billofmaterialvariantusage,
*             a~billofmaterialvariant,
*             b~mrpresponsible,
*             a~billofmaterialcategory
*      FROM i_materialbomlink WITH PRIVILEGED ACCESS AS a
*      LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b
*      ON   b~product = a~material
*      AND  b~plant = a~plant
*      FOR ALL ENTRIES IN @lt_result
*      WHERE a~material = @lt_result-product
*        AND a~plant = @lt_result-salesorganization
*        AND a~billofmaterialvariantusage = '1'
*        "AND a~billofmaterialvariant IN @lr_variant
*        "AND b~mrpresponsible IN @lr_mrpresponsible
*       INTO TABLE @DATA(lt_bomlink).
*      "物料工厂维度下多个的话 暂时取第一个
*      SORT lt_bomlink BY plant material billofmaterialvariant.
*      DELETE ADJACENT DUPLICATES FROM lt_bomlink COMPARING plant material.
*
*
*      LOOP AT lt_bomlink INTO DATA(ls_materialbomlink).
*        "Explode BOM
*        zcl_explodebom=>get_data(
*          EXPORTING
*            iv_explosiontype               = '4'
*            iv_plant                       = ls_materialbomlink-plant
*            iv_material                    = ls_materialbomlink-material
*            iv_billofmaterialcategory      = ls_materialbomlink-billofmaterialcategory
**            iv_billofmaterialvariant       = lv_variant
*            iv_bomexplosionapplication     = 'PP01'
*            iv_bomexplosiondate            = sy-datum
*            iv_headermaterial              = ls_materialbomlink-material
*            iv_headerbillofmaterialvariant = ls_materialbomlink-billofmaterialvariant
*            iv_requiredquantity            = '1'
*          CHANGING
*            ct_bomlist                     = lt_bomlist_tmp ).
*
*        ls_bomlist_tmp-headermaterial =  ls_materialbomlink-material.
*        MODIFY lt_bomlist_tmp FROM ls_bomlist_tmp TRANSPORTING headermaterial WHERE headermaterial IS NOT INITIAL.
*        APPEND LINES OF lt_bomlist_tmp TO lt_bomlist.
*        CLEAR lt_bomlist_tmp.
*
*      ENDLOOP.
*
*      "
*      IF lt_bomlist IS NOT INITIAL.
*        SELECT product,
*             valuationarea,
*             valuationtype,
*             valuationclass,
*             prodcostestnumber
*        FROM i_productvaluationbasic WITH PRIVILEGED ACCESS
*        FOR ALL ENTRIES IN @lt_result
*       WHERE product = @lt_result-product
*         AND valuationarea IN @lr_salesorganization
*         INTO TABLE @DATA(lt_prodcostno).
*        SORT lt_prodcostno BY product valuationclass.
*
*        SELECT costingreferenceobject,
*              costestimate,
*              costingtype,
*              costingdate,
*              costingversion,
*              valuationvariant,
*              costisenteredmanually,
*              costestimatevaliditystartdate,
*              costinglotsize
*         FROM i_productcostestimate WITH PRIVILEGED ACCESS "#EC CI_FAE_LINES_ENSURED
*         FOR ALL ENTRIES IN @lt_prodcostno
*         WHERE costestimate = @lt_prodcostno-prodcostestnumber
*        AND costestimatevaliditystartdate >= @lv_begda
*        AND costestimatevaliditystartdate <= @lv_endda
*          AND costestimatestatus = 'FR'
*         INTO TABLE @DATA(lt_lotsize).
*        SORT lt_lotsize BY costestimate costestimatevaliditystartdate DESCENDING.
*
*
*        SELECT costingreferenceobject,
*               costestimate,
*               costingtype,
*               costingdate,
*               costingversion,
*               valuationvariant,
*               costisenteredmanually,
*               costingitem,
*               plant,
*               product,
*               baseunit,
*               quantityinbaseunit,
*               transfercostestimate,
*               transfercostingdate,
*               companycodecurrency,
*               totalamountincocodecrcy
*          FROM i_productcostestimateitem WITH PRIVILEGED ACCESS "#EC CI_FAE_LINES_ENSURED
*          FOR ALL ENTRIES IN @lt_prodcostno
*         WHERE costestimate = @lt_prodcostno-prodcostestnumber
*           AND costingdate >= @lv_begda
*           AND costingdate <= @lv_endda
*           AND ( costingitemcategory = 'M'
*              OR costingitemcategory = 'I' )
*          INTO TABLE @DATA(lt_costitem).
*        SORT lt_costitem BY product plant costingdate DESCENDING.
*
*      ENDIF.


    ENDIF.
    "拼接出结果
    DATA: ls_output TYPE zr_salesdocumentreport.
    LOOP AT lt_months INTO ls_months.
      DATA: lv_begda_m TYPE d,
            lv_endda_m TYPE d.
      lv_begda_m = ls_months-month && '01'.
      lv_endda_m = ls_months-month && '01'.
      lv_endda_m = zzcl_common_utils=>get_enddate_of_month( lv_endda ).
      LOOP AT lt_result INTO DATA(ls_result) WHERE salesplanperiodname = ls_months-month.

        ls_output-salesorganization = ls_result-salesorganization.

        "ls_result-plant = ls_result-salesorganization.

        ls_output-customer = ls_result-soldtoparty.

        ls_output-yeardate = ls_months-month.

        ls_output-product = ls_result-product.

        ls_output-plantype = lv_ztype1.

        READ TABLE lt_customer INTO DATA(ls_cus) WITH KEY customer = ls_result-soldtoparty BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-customername = ls_cus-customername.
        ENDIF.

        ls_output-profitcenter = ls_result-profitcenter.

        READ TABLE lt_plant INTO DATA(ls_plant) WITH KEY plant = ls_result-salesorganization BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-plantname = ls_plant-plantname.
          ls_output-companycode = ls_plant-valuationarea.
        ENDIF.

        ls_output-salesoffice = ls_result-salesoffice.


        READ TABLE lt_userdescription INTO DATA(ls_userdescription) WITH KEY userid = ls_result-username .
        IF sy-subrc = 0.
          ls_output-createdbyuser = ls_userdescription-userdescription.
        ENDIF.


        ls_output-salesgroup = ls_result-salesgroup.

        ls_output-matlaccountassignmentgroup = ls_result-salesgroup.

        READ TABLE lt_psdmaag INTO DATA(ls_psdmaag) WITH KEY product = ls_result-product BINARY SEARCH.
        IF sy-subrc = 0.

          ls_output-firstsalesspecproductgroup  = ls_psdmaag-firstsalesspecproductgroup.

          ls_output-secondsalesspecproductgroup = ls_psdmaag-secondsalesspecproductgroup.

          ls_output-thirdsalesspecproductgroup  = ls_psdmaag-thirdsalesspecproductgroup.

          ls_output-accountdetnproductgroup     = ls_psdmaag-accountdetnproductgroup.

          CASE ls_psdmaag-matlaccountassignmentgroup.
            WHEN '01'.
              ls_output-matlaccountassignmentgroup = '量産'.
            WHEN '02' OR '03'.
              ls_output-matlaccountassignmentgroup = '部品・その他'.
            WHEN '04'.
              ls_output-matlaccountassignmentgroup = 'イニシャル'.
            WHEN '05' OR '06'.
              ls_output-matlaccountassignmentgroup = '開発'.
            WHEN OTHERS.
              "ls_output-matlaccountassignmentgroup = '未定義'.
          ENDCASE.
        ENDIF.

        "ls_output-productgroup = ls_result-productgroup.


        READ TABLE lt_producttext INTO DATA(ls_producttext) WITH KEY product = ls_result-product BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-productname = ls_producttext-productname.
        ENDIF.

        READ TABLE lt_customersalesarea INTO DATA(ls_customersalesarea) WITH KEY customer = ls_result-soldtoparty BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-customeraccountassignmentgroup = ls_customersalesarea-customeraccountassignmentgroup.
        ENDIF.


*        DATA:lv_mcost TYPE zr_salesdocumentreport-manufacturingcost_n.
*        CLEAR lv_mcost .
*
*        LOOP AT lt_bomlist INTO DATA(ls_bomlist) WHERE headermaterial = ls_result-product.
*
*          READ TABLE lt_prodcostno INTO DATA(ls_prodcostno) WITH KEY product = ls_bomlist-billofmaterialcomponent valuationarea = ls_result-salesorganization BINARY SEARCH.
*          IF sy-subrc = 0.
*            "寻找对应期间的有效数据
*            LOOP AT lt_lotsize INTO DATA(ls_lotsize) WHERE costestimate = ls_prodcostno-prodcostestnumber
*            AND costestimatevaliditystartdate >= lv_begda_m AND costestimatevaliditystartdate <= lv_endda_m.
*              EXIT.
*            ENDLOOP.
*            IF sy-subrc <> 0.
*              CLEAR ls_lotsize.
*            ENDIF.
*            LOOP AT lt_costitem INTO DATA(ls_costitem) WHERE product = ls_bomlist-billofmaterialcomponent AND plant = ls_result-salesorganization
*            AND costingdate >= lv_begda_m AND costingdate <= lv_endda_m.
*              EXIT.
*            ENDLOOP.
*            IF sy-subrc <> 0.
*              CLEAR ls_costitem.
*            ENDIF.
*
*            IF ls_lotsize IS NOT INITIAL AND ls_costitem IS NOT INITIAL.
*              lv_peinh = ls_costitem-quantityinbaseunit / ls_lotsize-costinglotsize.
*              ls_output-manufacturingcost_n += ls_costitem-totalamountincocodecrcy / ls_lotsize-costinglotsize * lv_peinh.
*              ls_output-currency1 = ls_costitem-companycodecurrency.
*
*              "CostingItemCategory=M类型"
*            ENDIF.
*          ENDIF.
*
*        ENDLOOP.

        "加工费
        READ TABLE lt_productcost INTO ls_productcost WITH KEY material          = ls_result-product
                                                               plant             = ls_result-salesorganization
                                                               ztype             = 'PROCESS' BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-manufacturingcost_n = ls_productcost-totalamountinctrlgareacrcy.
          ls_output-currency1           = ls_productcost-controllingareacurrency.
        ENDIF.
        "材料费
        READ TABLE lt_productcost INTO ls_productcost WITH KEY material          = ls_result-product
                                                               plant             = ls_result-salesorganization
                                                               ztype             = 'RAW' BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-materialcost2000_n = ls_productcost-totalamountinctrlgareacrcy.
          ls_output-currency           = ls_productcost-controllingareacurrency.
        ENDIF.


        READ TABLE lt_result1 INTO DATA(ls_result1) WITH KEY salesorganization   = ls_result-salesorganization
                                                             salesoffice         = ls_result-salesoffice
                                                             salesgroup          = ls_result-salesgroup
                                                             soldtoparty         = ls_result-soldtoparty
                                                             product             = ls_result-product
                                                             productgroup        = ls_result-productgroup
                                                             plant               = ls_result-plant
                                                             profitcenter        = ls_result-profitcenter
                                                             salesplanperiodname = ls_result-salesplanperiodname.
        IF sy-subrc = 0.
          ls_output-salesamount_n = ls_result1-salesplanamountindspcrcy.
          ls_output-displaycurrency1 = ls_result1-displaycurrency.
        ENDIF.

        READ TABLE lt_result2 INTO DATA(ls_result2) WITH KEY salesorganization   = ls_result-salesorganization
                                                             salesoffice         = ls_result-salesoffice
                                                             salesgroup          = ls_result-salesgroup
                                                             soldtoparty         = ls_result-soldtoparty
                                                             product             = ls_result-product
                                                             productgroup        = ls_result-productgroup
                                                             plant               = ls_result-plant
                                                             profitcenter        = ls_result-profitcenter
                                                             salesplanperiodname = ls_result-salesplanperiodname.
        IF sy-subrc = 0.
          ls_output-contributionprofittotal_n = ls_result2-salesplanamountindspcrcy.
          ls_output-displaycurrency2 = ls_result2-displaycurrency.
        ENDIF.

        READ TABLE lt_result3 INTO DATA(ls_result3) WITH KEY salesorganization   = ls_result-salesorganization
                                                             salesoffice         = ls_result-salesoffice
                                                             salesgroup          = ls_result-salesgroup
                                                             soldtoparty         = ls_result-soldtoparty
                                                             product             = ls_result-product
                                                             productgroup        = ls_result-productgroup
                                                             plant               = ls_result-plant
                                                             profitcenter        = ls_result-profitcenter
                                                             salesplanperiodname = ls_result-salesplanperiodname.
        IF sy-subrc = 0.
          ls_output-grossprofittotal_n = ls_result3-salesplanamountindspcrcy.
          ls_output-displaycurrency3 = ls_result3-displaycurrency.
        ENDIF.
        READ TABLE lt_result0 INTO DATA(ls_result0_temp) WITH KEY salesorganization   = ls_result-salesorganization
                                                                  salesoffice         = ls_result-salesoffice
                                                                  salesgroup          = ls_result-salesgroup
                                                                  soldtoparty         = ls_result-soldtoparty
                                                                  product             = ls_result-product
                                                                  productgroup        = ls_result-productgroup
                                                                  plant               = ls_result-plant
                                                                  profitcenter        = ls_result-profitcenter
                                                                  salesplanperiodname = ls_result-salesplanperiodname.
        IF sy-subrc <> 0.
          CLEAR ls_result0_temp.
        ENDIF.
        IF lv_ztype1 = 'A'.
          LOOP AT ls_res_api-d-results INTO DATA(ls_305) WHERE conditiontype                = 'ZYR0'
                                                             AND salesorganization            = ls_result-salesorganization
                                                             AND distributionchannel          = '10'
                                                             AND material                     = ls_result-product
                                                             AND customer                     = ls_result-soldtoparty
                                                             AND conditionquantityunit        = ls_result-salesplanunit
                                                             AND conditionvaliditystartdate_d LE ls_months-endda
                                                             AND conditionvalidityenddate_d   GE ls_months-begda.
            "如果上述取值条件全部一致的条件有多行，视为有阶梯价
            READ TABLE lt_collect TRANSPORTING NO FIELDS WITH KEY
            salesorganization = ls_result-salesorganization
            distributionchannel = '10'
            material = ls_result-product
            customer = ls_result-soldtoparty
            conditionquantityunit = ls_result-salesplanunit
            conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d.
            IF sy-subrc = 0.

              LOOP AT lt_tiered INTO DATA(ls_tiered) WHERE conditiontype = 'ZYR0'
                                  AND salesorganization = ls_305-salesorganization
                                  AND distributionchannel = '10'
                                  AND material = ls_305-material
                                  AND customer = ls_305-customer
                                  AND conditionquantityunit = ls_result-salesplanunit
                                  AND conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d
                                  AND conditionscalequantity <= ls_result0_temp-salesplanquantity.

                "ls_output-conditionratevalue_n   = ls_tiered-conditionscaleamount / ls_tiered-conditionquantity.
                "ls_output-conditionratevalueunit = ls_tiered-conditionscaleamountcurrency.
                "单价有小数
                ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount(
                                           iv_alpha = 'OUT'
                                           iv_currency = ls_tiered-conditionscaleamountcurrency
                                           iv_input = ls_tiered-conditionscaleamount ).
                ls_output-conditionratevalue_n   = ls_output-conditionratevalue_n / ls_tiered-conditionquantity.
                ls_output-displaycurrency1 = ls_305-conditionratevalueunit.
                "之前排序过 从阶梯数量小于等于计划数量的行中取阶梯数量最大的那一行
                EXIT.
              ENDLOOP.

            ELSE.
              "ls_output-conditionratevalue_n   = ls_305-conditionratevalue / ls_305-conditionquantity.
              "ls_output-conditionratevalueunit = ls_305-conditionratevalueunit.
              ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount(
                           iv_alpha = 'OUT'
                           iv_currency = ls_305-conditionratevalueunit
                           iv_input = ls_305-conditionratevalue ).
              ls_output-conditionratevalue_n   = ls_output-conditionratevalue_n / ls_305-conditionquantity.
              ls_output-displaycurrency1 = ls_305-conditionratevalueunit.
            ENDIF.
            "之前排序过 有效起止日期被包含在对象月中且日期最大的那条
            EXIT.
          ENDLOOP.

        ELSEIF lv_ztype1 = 'B'.

          LOOP AT ls_res_api-d-results INTO ls_305 WHERE conditiontype = 'PPR0'
                                                     AND salesorganization = ls_result-salesorganization
                                                     AND distributionchannel = '10'
                                                     AND material = ls_result-product
                                                     AND customer = ls_result-soldtoparty
                                                     AND conditionquantityunit = ls_result-salesplanunit
                                                     AND conditionvaliditystartdate_d LE ls_months-endda
                                                     AND conditionvalidityenddate_d GE ls_months-begda.
            "如果上述取值条件全部一致的条件有多行，视为有阶梯价
            READ TABLE lt_collect TRANSPORTING NO FIELDS WITH KEY
            salesorganization = ls_result-salesorganization
            distributionchannel = '10'
            material = ls_result-product
            customer = ls_result-soldtoparty
            conditionquantityunit = ls_result-salesplanunit
            conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d.
            IF sy-subrc = 0.

              LOOP AT lt_tiered INTO ls_tiered WHERE conditiontype = 'PPR0'
                                                 AND salesorganization = ls_305-salesorganization
                                                 AND distributionchannel = '10'
                                                 AND material = ls_305-material
                                                 AND customer = ls_305-customer
                                                 AND conditionquantityunit = ls_result-salesplanunit
                                                 AND conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d
                                                 AND conditionscalequantity <= ls_result0_temp-salesplanquantity.

                "ls_output-conditionratevalue_n   = ls_tiered-conditionscaleamount / ls_tiered-conditionquantity.
                "ls_output-conditionratevalueunit = ls_tiered-conditionscaleamountcurrency.
                "单价有小数
                ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount(
                                           iv_alpha = 'OUT'
                                           iv_currency = ls_tiered-conditionscaleamountcurrency
                                           iv_input = ls_tiered-conditionscaleamount ).
                ls_output-conditionratevalue_n   = ls_output-conditionratevalue_n / ls_tiered-conditionquantity.
                ls_output-displaycurrency1 = ls_305-conditionratevalueunit.
                "之前排序过 从阶梯数量小于等于计划数量的行中取阶梯数量最大的那一行
                EXIT.
              ENDLOOP.

            ELSE.
              "ls_output-conditionratevalue_n   = ls_305-conditionratevalue / ls_305-conditionquantity.
              "ls_output-conditionratevalueunit = ls_305-conditionratevalueunit.
              "单价有小数
              ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount(
                           iv_alpha = 'OUT'
                           iv_currency = ls_305-conditionratevalueunit
                           iv_input = ls_305-conditionratevalue ).
              ls_output-conditionratevalue_n   = ls_output-conditionratevalue_n / ls_305-conditionquantity.
              ls_output-displaycurrency1 = ls_305-conditionratevalueunit.
            ENDIF.
            "之前排序过 有效起止日期被包含在对象月中且日期最大的那条
            EXIT.
          ENDLOOP.
          IF sy-subrc <> 0.

            LOOP AT ls_res_api-d-results INTO ls_305 WHERE conditiontype = 'ZZR0'
                                                       AND salesorganization = ls_result-salesorganization
                                                       AND distributionchannel = '10'
                                                       AND material = ls_result-product
                                                       AND customer = ls_result-soldtoparty
                                                       AND conditionquantityunit = ls_result-salesplanunit
                                                       AND conditionvaliditystartdate_d LE ls_months-endda
                                                       AND conditionvalidityenddate_d GE ls_months-begda.
              "如果上述取值条件全部一致的条件有多行，视为有阶梯价
              READ TABLE lt_collect TRANSPORTING NO FIELDS WITH KEY
              salesorganization = ls_result-salesorganization
              distributionchannel = '10'
              material = ls_result-product
              customer = ls_result-soldtoparty
              conditionquantityunit = ls_result-salesplanunit
              conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d.
              IF sy-subrc = 0.

                LOOP AT lt_tiered INTO ls_tiered WHERE conditiontype = 'ZZR0'
                                                   AND salesorganization = ls_305-salesorganization
                                                   AND distributionchannel = '10'
                                                   AND material = ls_305-material
                                                   AND customer = ls_305-customer
                                                   AND conditionquantityunit = ls_result-salesplanunit
                                                   AND conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d
                                                   AND conditionscalequantity <= ls_result0_temp-salesplanquantity.

                  "ls_output-conditionratevalue_n   = ls_tiered-conditionscaleamount / ls_tiered-conditionquantity.
                  "ls_output-conditionratevalueunit = ls_tiered-conditionscaleamountcurrency.
                  "单价有小数
                  ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount(
                                             iv_alpha = 'OUT'
                                             iv_currency = ls_tiered-conditionscaleamountcurrency
                                             iv_input = ls_tiered-conditionscaleamount ).
                  ls_output-conditionratevalue_n   = ls_output-conditionratevalue_n / ls_tiered-conditionquantity.
                  ls_output-displaycurrency1 = ls_305-conditionratevalueunit.
                  "之前排序过 从阶梯数量小于等于计划数量的行中取阶梯数量最大的那一行
                  EXIT.
                ENDLOOP.

              ELSE.
                "ls_output-conditionratevalue_n   = ls_305-conditionratevalue / ls_305-conditionquantity.
                "ls_output-conditionratevalueunit = ls_305-conditionratevalueunit.
                "单价有小数
                ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount(
                             iv_alpha = 'OUT'
                             iv_currency = ls_305-conditionratevalueunit
                             iv_input = ls_305-conditionratevalue ).
                ls_output-conditionratevalue_n   = ls_output-conditionratevalue_n / ls_305-conditionquantity.

                ls_output-displaycurrency1 = ls_305-conditionratevalueunit.
              ENDIF.
              "之前排序过 有效起止日期被包含在对象月中且日期最大的那条
              EXIT.
            ENDLOOP.
          ENDIF.
        ENDIF.

        "贡献利润(单价):单价 - 材料费
        ls_output-materialcost2000per_n = ls_output-conditionratevalue_n - ls_output-materialcost2000_n.

        "销售总利润(单价)：单价 - 材料费 - 加工费
        ls_output-manufacturingcostper_n = ls_output-conditionratevalue_n - ls_output-materialcost2000_n - ls_output-manufacturingcost_n.


        READ TABLE lt_result0 INTO DATA(ls_result0) WITH KEY salesorganization   = ls_result-salesorganization
                                                             salesoffice         = ls_result-salesoffice
                                                             salesgroup          = ls_result-salesgroup
                                                             soldtoparty         = ls_result-soldtoparty
                                                             product             = ls_result-product
                                                             productgroup        = ls_result-productgroup
                                                             plant               = ls_result-plant
                                                             profitcenter        = ls_result-profitcenter
                                                             salesplanperiodname = ls_result-salesplanperiodname.
        IF sy-subrc = 0.

          "QTY
          ls_output-salesplanamountindspcrcy_n = ls_result0-salesplanquantity.
          ls_output-salesplanunit              = ls_result0-salesplanunit.

          "销售额
          ls_output-salesamount_n    = ls_result0-salesplanquantity * ls_output-conditionratevalue_n.
          ls_output-displaycurrency1 = ls_output-conditionratevalueunit.

          "贡献利润
          ls_output-contributionprofittotal_n = ls_result0-salesplanquantity * ls_output-materialcost2000per_n."
          ls_output-displaycurrency2          = ls_output-currency.

          "销售总利润
          ls_output-grossprofittotal_n = ls_result0-salesplanquantity * ls_output-manufacturingcostper_n.
          ls_output-displaycurrency2   = ls_output-currency1.

        ENDIF.


        "数据再处理！！！ 防止影响上面mapping
        ls_output-customer = |{ ls_output-customer ALPHA = OUT }|.

        READ TABLE lt_product INTO DATA(ls_product1) WITH KEY product = ls_result-product BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-productgroup = ls_product1-productgroup.
        ENDIF.

        READ TABLE lt_productplantbasic INTO DATA(ls_productplantbasic) WITH KEY product = ls_result-product plant = ls_result-salesorganization BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-profitcenter = ls_productplantbasic-profitcenter.
        ENDIF.

        READ TABLE lt_customersalesarea INTO ls_customersalesarea WITH KEY customer = ls_result-soldtoparty BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-salesoffice = ls_customersalesarea-salesoffice.
          ls_output-salesgroup = ls_customersalesarea-salesgroup.
        ENDIF.

        READ TABLE lt_group1text INTO DATA(ls_group1text) WITH KEY salesspcfcproductgroup1 = ls_output-firstsalesspecproductgroup BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-firstsalesspecproductgroup = ls_output-firstsalesspecproductgroup && '('  && ls_group1text-salesspcfcproductgroup1name  && ')' .
        ENDIF.
        READ TABLE lt_group2text INTO DATA(ls_group2text) WITH KEY salesspcfcproductgroup2 = ls_output-secondsalesspecproductgroup BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-secondsalesspecproductgroup = ls_output-secondsalesspecproductgroup && '('  && ls_group2text-salesspcfcproductgroup2name  && ')' .
        ENDIF.
        READ TABLE lt_group3text INTO DATA(ls_group3text) WITH KEY salesspcfcproductgroup3 = ls_output-thirdsalesspecproductgroup BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-thirdsalesspecproductgroup = ls_output-thirdsalesspecproductgroup && '('  && ls_group3text-salesspcfcproductgroup3name  && ')' .
        ENDIF.

        LOOP AT lt_ztbc_1001 INTO DATA(ls_ztbc_1001).
          CASE ls_ztbc_1001-zseq.
            WHEN '00000001'.
              ls_output-glaccount1     = ls_ztbc_1001-zvalue1.
              ls_output-glaccountname1 = ls_ztbc_1001-zvalue2.
            WHEN '00000002'.
              ls_output-glaccount2     = ls_ztbc_1001-zvalue1.
              ls_output-glaccountname2 = ls_ztbc_1001-zvalue2.
            WHEN '00000003'.
              ls_output-glaccount3     = ls_ztbc_1001-zvalue1.
              ls_output-glaccountname3 = ls_ztbc_1001-zvalue2.
          ENDCASE.
        ENDLOOP.

        APPEND ls_output TO lt_output.
        CLEAR ls_output.
      ENDLOOP.
    ENDLOOP.

    SORT lt_output BY salesorganization customer profitcenter salesoffice salesgroup product createdbyuser plantype yeardate.

    READ TABLE lt_output INTO ls_output INDEX 1.
    IF sy-subrc = 0.

      "前台用第一行去构造layout 需要第一行拥有最多列
      "不会有超过50列 一旦到最后一列直接退出
      DO 50 TIMES.
        DATA:lv_yeardatetemp TYPE bldat.
        DATA:lv_yeardatetemp1(6) TYPE c.
        lv_index = sy-index - 1.
        lv_yeardatetemp =  zzcl_common_utils=>calc_date_add( date = lv_splitstart && '01' month = lv_index ).
        lv_yeardatetemp1 = lv_yeardatetemp+0(6).

        READ TABLE lt_output TRANSPORTING NO FIELDS WITH KEY salesorganization = ls_output-salesorganization customer = ls_output-customer product = ls_output-product
        plantype = ls_output-plantype yeardate = lv_yeardatetemp1.
        IF sy-subrc <> 0.
          CLEAR :ls_output-conditionratevalue_n,ls_output-salesplanamountindspcrcy_n,
          ls_output-salesamount_n,ls_output-contributionprofittotal_n,ls_output-grossprofittotal_n,
          ls_output-materialcost2000per_n,ls_output-manufacturingcostper_n .
          ls_output-yeardate = lv_yeardatetemp1.
          APPEND ls_output TO lt_output.
        ENDIF.
        IF lv_yeardatetemp1 = lv_splitend.
          EXIT.
        ENDIF.
      ENDDO.

      SORT lt_output BY salesorganization customer profitcenter salesoffice salesgroup product createdbyuser plantype yeardate.
    ENDIF.

***-------------------------ADD by ----------20241207---end-------***

*    DATA: lt_salesplan         TYPE TABLE OF string,
*          lv_pattern           TYPE string,
*          lv_salesplan_version TYPE string,
*          lv_max_number        TYPE i,
*          lv_number            TYPE i,
*          lv_second_char       TYPE c LENGTH 1,
*          lv_third_char        TYPE c LENGTH 1.
*
*    DATA(lv_typeab) = lv_ztype1 && '%'.  " lv_ztype1 与百分号连接
*
*    SELECT
*      createdbyuser,
*      salesplan,
*      salesplanversion
*    FROM c_salesplanvaluehelp WITH PRIVILEGED ACCESS
*    WHERE salesplanversion LIKE @lv_typeab
*    INTO TABLE @lt_planversion.
*
*********基础数据获取********
**得意先名*品名
*
*    "按第二位数字排序
*    SORT lt_planversion BY salesplanversion+1(1) DESCENDING.
*
*    "获取排序后的第一条记录，即第二位数字最大的记录
*    READ TABLE lt_planversion INDEX 1 INTO DATA(lw_versionmax).
*    IF 1 = 2.
*      SELECT
*        a~salesorganization,
*        a~salesoffice,
*        a~salesgroup,
*        a~soldtoparty,
*        a~product AS product_a,
*        a~productgroup,
*        a~plant,
*        a~profitcenter,
*        b~customername,
*        c~customeraccountassignmentgroup,
*        d~productname,
*        e~product,
*        g~customer,
*        k~plantname,
*        j~firstsalesspecproductgroup,
*        j~secondsalesspecproductgroup,
*        j~thirdsalesspecproductgroup,
*        j~accountdetnproductgroup,
*        i~matlaccountassignmentgroup,
*        l~materialcost2000,
*        l~materialcost3000,
*        m~mrpresponsible,
*        n~profitcenter AS profitcenter_bom
*      FROM i_slsperformanceplanactualcube(
*        p_exchangeratetype = 0,
*        p_displaycurrency  = 'JPY',
*        p_salesplan        = @lw_versionmax-salesplan,
*        p_salesplanversion = @lw_versionmax-salesplanversion,
*        p_createdbyuser    = @lw_versionmax-createdbyuser ) WITH PRIVILEGED ACCESS AS a
*     LEFT JOIN i_producttext WITH PRIVILEGED ACCESS AS d
*     ON d~product = a~product
*     LEFT JOIN i_product WITH PRIVILEGED ACCESS AS e
*     ON e~product = a~product
*     LEFT JOIN i_customercompany WITH PRIVILEGED ACCESS AS g
*     ON g~companycode = a~salesorganization
*     LEFT JOIN i_customersalesarea WITH PRIVILEGED ACCESS AS h
*     ON h~salesorganization = a~salesorganization
*     AND h~customer = g~customer
*     LEFT JOIN i_customer WITH PRIVILEGED ACCESS AS b
*     ON b~customername = a~soldtoparty
*     AND b~customer = g~customer
*     LEFT JOIN i_customersalesarea WITH PRIVILEGED ACCESS AS c
*     ON c~customer = g~customer
*     AND c~salesorganization = a~salesorganization
*     LEFT JOIN i_plant WITH PRIVILEGED ACCESS AS k
*     ON k~plant = a~plant
*     LEFT JOIN i_productsalesdelivery WITH PRIVILEGED ACCESS AS j
*     ON j~product = a~product
*     LEFT JOIN i_matlaccountassignmentgroup WITH PRIVILEGED ACCESS AS i
*     ON i~matlaccountassignmentgroup = j~accountdetnproductgroup
*     LEFT JOIN ztfi_1010 AS l
*     ON l~product = a~product
*     AND l~customer = g~customer
*     LEFT JOIN i_productplantmrp WITH PRIVILEGED ACCESS AS m
*     ON m~plant = a~plant
*     AND m~product = a~product
*     LEFT JOIN i_profitcentertoproduct WITH PRIVILEGED ACCESS AS n
*     ON n~plant = a~plant
*     AND n~product = a~product
*     AND n~companycode = a~plant
*     WHERE a~product IN @lr_product
*       AND a~plant IN @lr_salesorganization
*       AND g~customer IN @lr_customer
*      INTO TABLE @DATA(lt_result1).
*    ENDIF.
*
*    "Obtain data of high level material of component
*    zcl_bom_where_used=>get_data(
*      EXPORTING
*        iv_plant                   = '1100'
*        iv_billofmaterialcomponent = 'ZTEST_FG001'
*      IMPORTING
*        et_usagelist               = lt_usagelist ).
*
*
*
*    LOOP AT  lt_result1 INTO DATA(lw_result1).
*      MOVE-CORRESPONDING lw_result1 TO lw_data.
*      " 判断 lw_result1-materialcost2000 是否为空
*      IF lw_result1-materialcost2000 IS INITIAL.
*        lw_data-materialcost2000 = lw_result1-materialcost3000.
*      ENDIF.
*
*      " 根据 MatlAccountAssignmentGroup 的值判断输出文本
*      CASE lw_result1-matlaccountassignmentgroup.
*        WHEN '01'.
*          lw_data-matlaccountassignmentgroup = '量産'.
*        WHEN '02' OR '03'.
*          lw_data-matlaccountassignmentgroup = '部品・その他'.
*        WHEN '04'.
*          lw_data-matlaccountassignmentgroup = 'イニシャル'.
*        WHEN '05' OR '06'.
*          lw_data-matlaccountassignmentgroup = '開発'.
*        WHEN OTHERS.
*          lw_data-matlaccountassignmentgroup = '未定義'.
*      ENDCASE.
*
*      APPEND lw_data TO lt_data.
*    ENDLOOP.
*
**    LOOP AT lt_data INTO lw_data.  " 循环遍历 lt_dataS
**      APPEND lw_data TO lt_output.  " 将当前行的 lw_data 追加到 lt_output 内表
**    ENDLOOP.
*
**    * 6.01-6.08 BOM番号
*
*    SORT lt_result1 BY plant product.
*
*    LOOP AT lt_result1 INTO DATA(ls_result1).
*      "Obtain data of high level material of component
*      zcl_bom_where_used=>get_data(
*        EXPORTING
*          iv_plant                   = ls_result1-plant
*          iv_billofmaterialcomponent = ls_result1-product
*        IMPORTING
*          et_usagelist               = lt_usagelist ).
*
*      APPEND LINES OF lt_usagelist TO lt_highlevelmaterialinfo.
*      CLEAR lt_usagelist.
*    ENDLOOP.
*********計画数量********
*
*    CLEAR lt_version0.
*
*    " 筛选第二位数字为 '0' 的记录
*    LOOP AT lt_planversion INTO ls_planversion.
*      IF ls_planversion-salesplanversion+1(1) = '0'.
*        APPEND ls_planversion TO lt_version0.
*      ENDIF.
*    ENDLOOP.
*
*    " 如果有筛选结果，按第三位数字排序
*    IF lt_version0 IS NOT INITIAL.
*      SORT lt_version0 BY salesplanversion+2(1) DESCENDING.
*
*      " 获取第三位数字最大的记录
*      READ TABLE lt_version0 INDEX 1 INTO DATA(lw_version0).
*    ENDIF.
*
*    SELECT
*      salesplanquantity,
*      salesplanperiodname
*    FROM i_slsperformanceplanactualcube(
*      p_exchangeratetype = 0,
*      p_displaycurrency  = 'JPY',
*      p_salesplan        = @lw_version0-salesplan,
*      p_salesplanversion = @lw_version0-salesplanversion,
*      p_createdbyuser    = @lw_version0-createdbyuser ) WITH PRIVILEGED ACCESS
*    INTO TABLE @DATA(lt_result2).
*
*    IF sy-subrc = 0.
*      DATA(lt_read2) = lt_result2.
*      SORT lt_read2 BY salesplanperiodname salesplanquantity.
*      DELETE ADJACENT DUPLICATES FROM lt_read2 COMPARING salesplanperiodname salesplanquantity.
*    ENDIF.
*
**********単価*********
*    IF lv_ztype1 = 'A'.
*
*      IF lt_read2 IS NOT INITIAL.
*
*        " 遍历 lt_read2，匹配年份和月份，并获取第一条记录
*        LOOP AT lt_read2 INTO DATA(lw_reada).
*          " 提取 salesplanperiodname 的年份和月份
*          DATA(lv_salesplanperiodnamea) = lw_reada-salesplanperiodname(4) && '-' && lw_reada-salesplanperiodname+4(2). " yyyy-MM 格式
*
*          " 查询与年份和月份匹配的 conditionvaliditystartdate 数据
*          DATA(lv_patterna) = lv_salesplanperiodnamea && '-%'. " 拼接成 LIKE 的模式，例如 "2024-11-%"
*
*          SELECT conditionratevalue,
*                 conditionvaliditystartdate
*            FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
*            WHERE conditiontype      = 'ZYP0'
*              AND conditionisdeleted = @space
*              AND conditionvaliditystartdate LIKE @lv_patterna
*            INTO TABLE @DATA(lt_ratevalue_tempa).
*
*          IF lt_ratevalue_tempa IS NOT INITIAL.
*            SORT lt_ratevalue_tempa BY conditionvaliditystartdate ASCENDING. " 根据具体排序字段排序
*            READ TABLE lt_ratevalue_tempa INTO DATA(ls_conditionratevaluea) INDEX 1. " 取排序后的第一条记录
*            lw_data-conditionratevalue = ls_conditionratevaluea-conditionratevalue.
*            lw_data-salesamount = ls_conditionratevaluea-conditionratevalue * lw_reada-salesplanquantity.
*          ENDIF.
*        ENDLOOP.
*
*      ELSE.
*
*        " 遍历 lt_read2，匹配年份和月份，并获取第一条记录
*        LOOP AT lt_read2 INTO DATA(lw_readb).
*          " 提取 salesplanperiodname 的年份和月份
*          DATA(lv_salesplanperiodnameb) = lw_reada-salesplanperiodname(4) && '-' && lw_reada-salesplanperiodname+4(2). " yyyy-MM 格式
*
*          " 查询与年份和月份匹配的 conditionvaliditystartdate 数据
*          DATA(lv_patternb) = lv_salesplanperiodnameb && '-%'. " 拼接成 LIKE 的模式，例如 "2024-11-%"
*
*          SELECT conditionratevalue,
*                 conditionvaliditystartdate
*            FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
*            WHERE conditiontype      = 'PPR0'
*              AND conditionisdeleted = @space
*              AND conditionvaliditystartdate LIKE @lv_patternb
*            INTO TABLE @DATA(lt_ratevalue_tempbppr0).
*
*          IF lt_ratevalue_tempbppr0 IS INITIAL.
*
*            SELECT conditionratevalue,
*                   conditionvaliditystartdate
*            FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
*            WHERE conditiontype      = 'ZZR0'
*              AND conditionisdeleted = @space
*              AND conditionvaliditystartdate LIKE @lv_patternb
*            INTO TABLE @DATA(lt_ratevalue_tempbzzr0).
*
*          ENDIF.
*
*          IF lt_ratevalue_tempbppr0 IS NOT INITIAL.
*            SORT lt_ratevalue_tempbppr0 BY conditionvaliditystartdate ASCENDING. " 根据具体排序字段排序
*            READ TABLE lt_ratevalue_tempbppr0 INTO DATA(ls_conditionratevaluebppr0) INDEX 1. " 取排序后的第一条记录
*            lw_data-conditionratevalue = ls_conditionratevaluebppr0-conditionratevalue.
*            lw_data-salesamount = ls_conditionratevaluebppr0-conditionratevalue * lw_readb-salesplanquantity.
*          ELSE.
*
*            SORT lt_ratevalue_tempbzzr0 BY conditionvaliditystartdate ASCENDING. " 根据具体排序字段排序
*            READ TABLE lt_ratevalue_tempbzzr0 INTO DATA(ls_conditionratevaluebzzr0) INDEX 1. " 取排序后的第一条记录
*            lw_data-conditionratevalue = ls_conditionratevaluebzzr0-conditionratevalue.
*            lw_data-salesamount = ls_conditionratevaluebzzr0-conditionratevalue * lw_readb-salesplanquantity.
*          ENDIF.
*
*        ENDLOOP.
*
*      ENDIF.
*    ENDIF.
*
**********売上*********
*    CLEAR lt_version1.
*
*    " 筛选第二位数字为 '1' 的记录
*    LOOP AT lt_planversion INTO ls_planversion.
*      IF ls_planversion-salesplanversion+1(1) = '1'.
*        APPEND ls_planversion TO lt_version1.
*      ENDIF.
*    ENDLOOP.
*
*    " 如果有筛选结果，按第三位数字排序
*    IF lt_version1 IS NOT INITIAL.
*      SORT lt_version1 BY salesplanversion+2(1) DESCENDING.
*
*      " 获取第三位数字最大的记录
*      READ TABLE lt_version1 INDEX 1 INTO DATA(lw_version1).
*    ENDIF.
*
*    SELECT
*      salesplanamountindspcrcy,
*      salesplanperiodname
*    FROM i_slsperformanceplanactualcube(
*      p_exchangeratetype = 0,
*      p_displaycurrency  = 'JPY',
*      p_salesplan        = @lw_version1-salesplan,
*      p_salesplanversion = @lw_version1-salesplanversion,
*      p_createdbyuser    = @lw_version1-createdbyuser ) WITH PRIVILEGED ACCESS
*    INTO TABLE @DATA(lt_result3).
*
*    IF sy-subrc = 0.
*      DATA(lt_read3) = lt_result3.
*      SORT lt_read3 BY salesplanamountindspcrcy salesplanperiodname.
*      DELETE ADJACENT DUPLICATES FROM lt_read3 COMPARING salesplanamountindspcrcy salesplanperiodname.
*    ENDIF.
*
**********貢献利益*********
*    CLEAR lt_version2.
*
*    " 筛选第二位数字为 '2' 的记录
*    LOOP AT lt_planversion INTO ls_planversion.
*      IF ls_planversion-salesplanversion+1(1) = '2'.
*        APPEND ls_planversion TO lt_version2.
*      ENDIF.
*    ENDLOOP.
*
*    " 如果有筛选结果，按第三位数字排序
*    IF lt_version2 IS NOT INITIAL.
*      SORT lt_version2 BY salesplanversion+2(1) DESCENDING.
*
*      " 获取第三位数字最大的记录
*      READ TABLE lt_version2 INDEX 1 INTO DATA(lw_version2).
*    ENDIF.
*
*    SELECT
*      salesplanamountindspcrcy,
*      salesplanperiodname
*    FROM i_slsperformanceplanactualcube(
*      p_exchangeratetype = 0,
*      p_displaycurrency  = 'JPY',
*      p_salesplan        = @lw_version2-salesplan,
*      p_salesplanversion = @lw_version2-salesplanversion,
*      p_createdbyuser    = @lw_version2-createdbyuser ) WITH PRIVILEGED ACCESS
*    INTO TABLE @DATA(lt_result4).
*
**********貢献利益(単価)********
*    SORT lt_result4 BY salesplanperiodname DESCENDING.
*    LOOP AT  lt_read2 INTO DATA(lw_contributionprofit).
*      READ TABLE lt_result4 INTO DATA(lw_result4)
*          WITH KEY salesplanperiodname = lw_contributionprofit-salesplanperiodname
*               BINARY SEARCH.
*
*      IF lw_result4-salesplanamountindspcrcy IS NOT INITIAL AND lw_contributionprofit-salesplanquantity IS NOT INITIAL.
*        lv_contributionprofit = ( lw_result4-salesplanamountindspcrcy * 100 ) / lw_contributionprofit-salesplanquantity.
*      ELSE.
*
*        lw_data-contributionprofit = round(
*         val = lv_contributionprofit
*         dec = 0
*         mode = cl_abap_math=>round_half_up
*         ).
*      ENDIF.
*
*    ENDLOOP.
*
**********貢献利益********
*
*
**********売上総利益*********
*    CLEAR lt_version3.
*
*    " 筛选第二位数字为 '3' 的记录
*    LOOP AT lt_planversion INTO ls_planversion.
*      IF ls_planversion-salesplanversion+1(1) = '3'.
*        APPEND ls_planversion TO lt_version3.
*      ENDIF.
*    ENDLOOP.
*
*    " 如果有筛选结果，按第三位数字排序
*    IF lt_version3 IS NOT INITIAL.
*      SORT lt_version3 BY salesplanversion+2(1) DESCENDING.
*
*      " 获取第三位数字最大的记录
*      READ TABLE lt_version3 INDEX 1 INTO DATA(lw_version3).
*    ENDIF.
*
*    SELECT
*      salesplanamountindspcrcy,
*      salesplanperiodname
*    FROM i_slsperformanceplanactualcube(
*      p_exchangeratetype = 0,
*      p_displaycurrency  = 'JPY',
*      p_salesplan        = @lw_version3-salesplan,
*      p_salesplanversion = @lw_version3-salesplanversion,
*      p_createdbyuser    = @lw_version3-createdbyuser ) WITH PRIVILEGED ACCESS
*    INTO TABLE @DATA(lt_result5).
*
**********売上総利益(単価)********
*    SORT lt_result5 BY salesplanperiodname DESCENDING.
*    LOOP AT  lt_read2 INTO DATA(lw_grossprofit).
*
*      READ TABLE lt_result5 INTO DATA(lw_result5)
*          WITH KEY salesplanperiodname = lw_grossprofit-salesplanperiodname
*               BINARY SEARCH.
*
*      IF lw_result5-salesplanamountindspcrcy IS NOT INITIAL AND lw_grossprofit-salesplanquantity IS NOT INITIAL.
*        lv_grossprofit = ( lw_result5-salesplanamountindspcrcy * 100 ) / lw_grossprofit-salesplanquantity.
*      ELSE.
*
*        lw_data-grossprofit = round(
*         val = lv_grossprofit
*         dec = 0
*         mode = cl_abap_math=>round_half_up
*         ).
*      ENDIF.
*    ENDLOOP.
*************************************************************
**     test 数据集
*************************************************************
    "DATA:
    "  ls_output            TYPE  zr_salesdocumentreport.
*
*    CLEAR ls_output.
*    ls_output-salesorganization = '11'.
*    ls_output-yeardate = '202401'.
*    ls_output-customername = '22222'.
*
*    ls_output-conditionratevalue_n = 12.
*    ls_output-salesplanamountindspcrcy_n = 124.
*    ls_output-salesamount_n  = 1234.
*    ls_output-materialcost2000_n = 555555.
*    ls_output-manufacturingcost_n = 8888888.
*    ls_output-FirstSalesSpecProductGroup = '1'.
*    ls_output-SecondSalesSpecProductGroup = '2'.
*    ls_output-ThirdSalesSpecProductGroup = '3'.
*    ls_output-Companycode = '1222'.
*    ls_output-FirstSalesSpecProductGroup = '1222(DDDD)'.
*    APPEND ls_output TO lt_output.
*
*
*    CLEAR ls_output.
*    ls_output-salesorganization = '11'.
*    ls_output-yeardate = '202402'.
*    ls_output-conditionratevalue_n = 1112.
*    ls_output-salesplanamountindspcrcy_n = 0.
*    ls_output-salesamount_n  = 0.
*    ls_output-contributionprofittotal_n = 0.
*    ls_output-grossprofittotal_n = 0.
*    APPEND ls_output TO lt_output.
*
*
*
*    CLEAR ls_output.
*    ls_output-salesorganization = '11'.
*    ls_output-yeardate = '202403'.
*
*    ls_output-conditionratevalue_n = 0.
*    ls_output-salesplanamountindspcrcy_n = 0.
*    ls_output-salesamount_n  = 0.
*    ls_output-contributionprofittotal_n = 0.
*    ls_output-grossprofittotal_n = 0.
*
*    APPEND ls_output TO lt_output.
*    CLEAR ls_output.
*    ls_output-salesorganization = '2'.
*    ls_output-yeardate = '202403'.
*    ls_output-conditionratevalue_n = 0.
*    ls_output-salesplanamountindspcrcy_n = 0.
*    ls_output-salesamount_n  = 0.
*    ls_output-contributionprofittotal_n = 0.
*    ls_output-grossprofittotal_n = 0.
*    APPEND ls_output TO lt_output.
*    CLEAR ls_output.
*    "如果选了202401-202404 但是202404没值 也要有等于0的行
*    ls_output-salesorganization = '32'.
*    ls_output-yeardate = '202404'.
*    ls_output-conditionratevalue_n = 0.
*    ls_output-salesplanamountindspcrcy_n = 124.
*    ls_output-salesamount_n  = 0.
*    ls_output-contributionprofittotal_n = 0.
*    ls_output-grossprofittotal_n = 7.
*    ls_output-materialcost2000per_n = 92929.
*    APPEND ls_output TO lt_output.


    "重要非常重要 非常非常重要！！！
    "请给第一key的 添加yeardate 最多列 无值用0填充
    "或者干脆就所有行 无值0

    SORT lt_output BY salesorganization customer profitcenter salesoffice salesgroup product createdbyuser plantype yeardate.

    READ TABLE lt_output INTO ls_output INDEX 1.
    IF sy-subrc = 0.

      DO 50 TIMES.
        "DATA:lv_yeardatetemp11 TYPE bldat.
        "DATA:lv_yeardatetemp12(6) TYPE c.
        lv_index = sy-index  - 1.
        lv_yeardatetemp =  zzcl_common_utils=>calc_date_add( date = lv_splitstart && '01' month = lv_index ).
        lv_yeardatetemp1 = lv_yeardatetemp+0(6).

        READ TABLE lt_output TRANSPORTING NO FIELDS WITH KEY salesorganization = ls_output-salesorganization customer = ls_output-customer product = ls_output-product
        plantype = ls_output-plantype yeardate = lv_yeardatetemp1.
        IF sy-subrc <> 0.
          CLEAR :ls_output-conditionratevalue_n,ls_output-salesplanamountindspcrcy_n,
          ls_output-salesamount_n,ls_output-contributionprofittotal_n,ls_output-grossprofittotal_n.
          ls_output-yeardate = lv_yeardatetemp1.
          APPEND ls_output TO lt_output.
        ENDIF.
        IF lv_yeardatetemp1 = lv_splitend.
          EXIT.
        ENDIF.
      ENDDO.
      DELETE lt_output WHERE yeardate < lv_splitstart OR yeardate > lv_splitend.

    ENDIF.

    SORT lt_output BY salesorganization customer profitcenter salesoffice salesgroup product createdbyuser plantype yeardate.


*********************

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
