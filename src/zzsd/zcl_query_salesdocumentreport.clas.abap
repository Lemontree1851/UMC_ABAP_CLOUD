CLASS zcl_query_salesdocumentreport DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_QUERY_SALESDOCUMENTREPORT IMPLEMENTATION.


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
        material                    TYPE matnr,
        plant                       TYPE werks_d,
        ztype(10)                   TYPE c,
        controllingareacurrency     TYPE i_productcostestimateitem-controllingareacurrency,
        " MOD BEGIN BY XINLEI XU 2025/02/18
        " totalamountinctrlgareacrcy  TYPE i_productcostestimateitem-totalamountinctrlgareacrcy,
        totalpriceininctrlgareacrcy TYPE i_productcostestimateitem-totalpriceininctrlgareacrcy,
        " MOD END BY XINLEI XU 2025/02/18
      END OF ty_productcost.
    DATA:lt_productcost TYPE STANDARD TABLE OF ty_productcost.
    DATA:ls_productcost TYPE ty_productcost.
    DATA:ls_res_api1  TYPE ty_res_api1.
    DATA:lv_path    TYPE string.
    DATA:lt_collect TYPE STANDARD TABLE OF ty_collect.
    DATA:ls_collect TYPE ty_collect.

    CONSTANTS:lc_exchangetype TYPE string VALUE '0',
              lc_ppr0(4)      TYPE c VALUE 'PPR0',
              lc_zyr0(4)      TYPE c VALUE 'ZYR0',
              lc_zzr0(4)      TYPE c VALUE 'ZZR0',
*&--ADD BEGIN BY XINLEI XU 2025/04/15 CR#4277
              lc_zycm(4)      TYPE c VALUE 'ZYCM',
              lc_zzcm(4)      TYPE c VALUE 'ZZCM',
              lc_zygp(4)      TYPE c VALUE 'ZYGP',
              lc_zzgp(4)      TYPE c VALUE 'ZZGP'.

    DATA: lv_conditionratevalue_n(15)   TYPE p DECIMALS 2,
          lv_conditionquantity1(10)     TYPE p DECIMALS 2,
          lv_materialcost2000per_n(15)  TYPE p DECIMALS 2,
          lv_conditionquantity2(10)     TYPE p DECIMALS 2,
          lv_manufacturingcostper_n(15) TYPE p DECIMALS 2,
          lv_conditionquantity3(10)     TYPE p DECIMALS 2.
*&--ADD END BY XINLEI XU 2025/04/15 CR#4277

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
      SELECT customer,
             customername
        FROM i_customer WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_result
       WHERE customer = @lt_result-soldtoparty
        INTO TABLE @DATA(lt_customer).
      SORT lt_customer BY customer.

      "取利润中心
      SELECT product,
             plant,
             profitcenter
        FROM i_productplantbasic WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_result
       WHERE product = @lt_result-product
         AND plant = @lt_result-salesorganization
        INTO TABLE @DATA(lt_productplantbasic).
      SORT lt_productplantbasic BY product plant.

      "取物料组
      SELECT product,
             productgroup
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
          FROM i_salesspcfcproductgroup1text WITH PRIVILEGED ACCESS
         WHERE language = @sy-langu
          INTO TABLE @DATA(lt_group1text).
        SORT lt_group1text BY  salesspcfcproductgroup1.

        SELECT salesspcfcproductgroup2,salesspcfcproductgroup2name
          FROM i_salesspcfcproductgroup2text WITH PRIVILEGED ACCESS
         WHERE language = @sy-langu
          INTO TABLE @DATA(lt_group2text).
        SORT lt_group2text BY  salesspcfcproductgroup2.

        SELECT salesspcfcproductgroup3,salesspcfcproductgroup3name
          FROM i_salesspcfcproductgroup3text WITH PRIVILEGED ACCESS
         WHERE language = @sy-langu
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
      SELECT plant,
             plantname,
             valuationarea
        FROM i_plant WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_result
       WHERE plant = @lt_result-salesorganization
        INTO TABLE @DATA(lt_plant).
      SORT lt_plant BY plant.

      "取客户帐户设置组
      SELECT customer,
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
*&--MOD BEGIN BY XINLEI XU 2025/04/15 CR#4277
*     WHERE conditiontype = 'ZYR0' " 'ZYP0' MOD BY XINLEI XU 2025/02/16
      WHERE conditiontype IN ( @lc_zyr0, @lc_zycm, @lc_zygp )
        AND conditiontable = '305'
*&--MOD END BY XINLEI XU 2025/04/15 CR#4277
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
*&--MOD BEGIN BY XINLEI XU 2025/04/15 CR#4277
*     WHERE conditiontype IN ('PPR0','ZZR0')
      WHERE conditiontype IN ( @lc_ppr0, @lc_zzr0, @lc_zzcm, @lc_zzgp )
        AND conditiontable = '305'
*&--MOD END BY XINLEI XU 2025/04/15 CR#4277
        AND conditionisdeleted = @space
        AND conditionvaliditystartdate LE @lv_endda
        AND conditionvalidityenddate   GE @lv_begda
      INTO TABLE @lt_slsprcgconditionrecord.
    ENDIF.

    SORT lt_slsprcgconditionrecord BY conditionrecord.

*&--ADD BEGIN BY XINLEI XU 2025/04/27 阶梯价逻辑BUG Fixed
    IF lt_slsprcgconditionrecord IS NOT INITIAL.
      SELECT conditionrecord,
             conditionsequentialnumber,
             conditionscaleline,
             conditionscalequantity,
             conditionratevalue,
             conditionrateamount,
             conditioncurrency
        FROM i_slsprcgcndnrecordscale WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_slsprcgconditionrecord
       WHERE conditionrecord = @lt_slsprcgconditionrecord-conditionrecord
        INTO TABLE @DATA(lt_recordscale).
      SORT lt_recordscale BY conditionrecord conditionscalequantity DESCENDING.

      SELECT a~conditionrecord,
             COUNT( * ) AS count
        FROM @lt_recordscale AS a
       GROUP BY a~conditionrecord
        INTO TABLE @DATA(lt_recordscale_count).
      SORT lt_recordscale_count BY conditionrecord.
    ENDIF.
*&--ADD END BY XINLEI XU 2025/04/27

    "Obtain 305 condition table
*&--MOD BEGIN BY XINLEI XU 2025/04/15 CR#4277
*   lv_path = |/API_SLSPRICINGCONDITIONRECORD_SRV/A_SlsPrcgCndnRecdValidity?$filter=ConditionType%20eq%20'{ lc_ppr0 }'%20or%20ConditionType%20eq%20'{ lc_zzr0 }'%20or%20ConditionType%20eq%20'{ lc_zyr0 }'|.
    lv_path = |/API_SLSPRICINGCONDITIONRECORD_SRV/A_SlsPrcgCndnRecdValidity?$filter=| &&
              |ConditionType%20eq%20'{ lc_ppr0 }'%20or%20| &&
              |ConditionType%20eq%20'{ lc_zzr0 }'%20or%20| &&
              |ConditionType%20eq%20'{ lc_zyr0 }'%20or%20| &&

              |ConditionType%20eq%20'{ lc_zycm }'%20or%20| &&
              |ConditionType%20eq%20'{ lc_zygp }'%20or%20| &&
              |ConditionType%20eq%20'{ lc_zzcm }'%20or%20| &&
              |ConditionType%20eq%20'{ lc_zzgp }'|.
*&--MOD END BY XINLEI XU 2025/04/15 CR#4277

    "Call API
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>get
        iv_format      = 'json'
        iv_select      = 'ConditionRecord,ConditionType,SalesOrganization,DistributionChannel,Customer,Material'
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
            ls_result_p-conditioncurrency            = ls_slsprcgconditionrecord-conditioncurrency.
*&--ADD BEGIN BY XINLEI XU 2025/04/16 CR#4277
          ELSE.
            DELETE ls_res_api-d-results.
            CONTINUE.
*&--ADD END BY XINLEI XU 2025/04/16 CR#4277
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

*&--MOD BEGIN BY XINLEI XU 2025/02/19
*    "获取加工费
*    IF lt_result IS NOT INITIAL.
*
*      lv_path = |/YY1_PRODUCTCOSTESTIMATED_CDS/YY1_ProductCostEstimateD|.
*      "lv_path = |/YY1_PRODUCTCOSTESTIMATED_CDS/YY1_ProductCostEstimateD?$filter=CostingDate%20eq%20datetime'{ lv_local_begda_s }T00:00:00'|.
*
*      "Call API
*      zzcl_common_utils=>request_api_v2(
*        EXPORTING
*          iv_path        = lv_path
*          iv_method      = if_web_http_client=>get
*          iv_format      = 'json'
*        IMPORTING
*          ev_status_code = DATA(lv_stat_code1)
*          ev_response    = DATA(lv_resbody_api1) ).
*      TRY.
*          /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api1
*                  CHANGING  data = ls_res_api1 ).
*
*        CATCH cx_root INTO DATA(lx_root4) ##NO_HANDLER.
*      ENDTRY.
*
*      "只保留符合条件的成本估算
*      LOOP AT ls_res_api1-d-results INTO DATA(ls_result_p1).
*        READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY salesorganization = ls_result_p1-plant
*                                                             product           = ls_result_p1-material.
*        IF sy-subrc <> 0.
*          DELETE ls_res_api1-d-results.
*          CONTINUE.
*        ENDIF.
*        "时间戳格式转换成日期格式
*        ls_result_p1-costingdate_d = CONV string( ls_result_p1-costingdate DIV 1000000 ).
*        MODIFY ls_res_api1-d-results  FROM ls_result_p1 TRANSPORTING costingdate_d .
*
*      ENDLOOP.
*
*      "保留日期最大的
*      SORT ls_res_api1-d-results BY plant material costingdate DESCENDING.
*      DELETE ADJACENT DUPLICATES FROM ls_res_api1-d-results COMPARING plant material .
*
*
*      SORT ls_res_api1-d-results BY costestimate.
*
*      IF ls_res_api1-d-results IS NOT INITIAL.
*        "取成本估算号码 取全部主键 防止去重
*        SELECT
*         costingreferenceobject,
*         costestimate,
*         costingtype,
*         costingdate,
*         costingversion,
*         valuationvariant,
*         costisenteredmanually,
*         costingitem,
*
*         costcomponent,
*         controllingareacurrency,
*         " MOD BEGIN BY XINLEI XU 2025/02/18
*         " totalamountinctrlgareacrcy,
*         totalpriceininctrlgareacrcy,
*         " MOD END BY XINLEI XU 2025/02/18
*         costingpriceunitqty
*        FROM i_productcostestimateitem WITH PRIVILEGED ACCESS "#EC CI_FAE_LINES_ENSURED
*        FOR ALL ENTRIES IN @ls_res_api1-d-results
*       WHERE costestimate = @ls_res_api1-d-results-costestimate
*        INTO TABLE  @DATA(lt_productcostestimateitem).
*        SORT lt_productcostestimateitem BY costestimate costcomponent.
*
*      ENDIF.
*      LOOP AT lt_productcostestimateitem INTO DATA(ls_productcostestimateitem).
*
*        READ TABLE ls_res_api1-d-results INTO ls_result_p1 WITH KEY costestimate = ls_productcostestimateitem-costestimate BINARY SEARCH.
*        IF sy-subrc = 0.
*          ls_productcost-material = ls_result_p1-material.
*          ls_productcost-plant = ls_result_p1-plant .
*          ls_productcost-controllingareacurrency  = ls_productcostestimateitem-controllingareacurrency  .
*          " MOD BEGIN BY XINLEI XU 2025/02/18
*          " ls_productcost-totalamountinctrlgareacrcy = ls_productcostestimateitem-totalamountinctrlgareacrcy / ls_productcostestimateitem-costingpriceunitqty .
*          ls_productcost-totalpriceininctrlgareacrcy = ls_productcostestimateitem-totalpriceininctrlgareacrcy.
*          " MOD END BY XINLEI XU 2025/02/18
*
*          IF ls_productcostestimateitem-costcomponent = '101'
*          OR ls_productcostestimateitem-costcomponent = '102'
*          OR ls_productcostestimateitem-costcomponent = '103' .
*            " MOD BEGIN BY XINLEI XU 2025/02/18
*            " 加工费
*            " ls_productcost-ztype = 'PROCESS'.
*            " 材料费
*            ls_productcost-ztype = 'RAW'.
*            " MOD END BY XINLEI XU 2025/02/18
*          ELSEIF ls_productcostestimateitem-costcomponent = '201'
*              OR ls_productcostestimateitem-costcomponent = '202'
*              OR ls_productcostestimateitem-costcomponent = '203'
*              OR ls_productcostestimateitem-costcomponent = '204'
*              OR ls_productcostestimateitem-costcomponent = '205'
*              OR ls_productcostestimateitem-costcomponent = '206'
*              OR ls_productcostestimateitem-costcomponent = '207'
*              OR ls_productcostestimateitem-costcomponent = '208'
*              OR ls_productcostestimateitem-costcomponent = '209'.
*            " MOD BEGIN BY XINLEI XU 2025/02/18
*            " 材料费
*            " ls_productcost-ztype = 'RAW'.
*            " 加工费
*            ls_productcost-ztype = 'PROCESS'.
*            " MOD END BY XINLEI XU 2025/02/18
*          ELSE.
*            ls_productcost-ztype = ''.
*          ENDIF.
*        ENDIF.
*        COLLECT ls_productcost INTO lt_productcost.
*      ENDLOOP.
*    SORT lt_productcost BY material plant ztype.

    IF lt_result IS NOT INITIAL.
      DATA(lv_system_date) = cl_abap_context_info=>get_system_date( ).
      SELECT costingreferenceobject,
             costestimate,
             costingtype,
             costingdate,
             costingversion,
             valuationvariant,
             costisenteredmanually,
             product,
             plant,
             controllingareacurrency,
             costinglotsize
        FROM i_productcostestimate WITH PRIVILEGED ACCESS "#EC CI_FAE_LINES_ENSURED
         FOR ALL ENTRIES IN @lt_result
       WHERE product = @lt_result-product
         AND plant = @lt_result-salesorganization
         AND costestimatestatus = 'FR'
         AND costingdate < @lv_system_date
        INTO TABLE @DATA(lt_productcostestimate).

      " 保留 操作当時の日付に最大値
      SORT lt_productcostestimate BY product plant costingdate DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_productcostestimate COMPARING product plant.

      IF lt_productcostestimate IS NOT INITIAL.
        SELECT costestimate,
               costingdate,
               SUM( costcomponentcostfield1amt +
                    costcomponentcostfield3amt +
                    costcomponentcostfield5amt ) AS raw_amount,
               SUM( costcomponentcostfield11amt +
                    costcomponentcostfield13amt +
                    costcomponentcostfield15amt +
                    costcomponentcostfield17amt +
                    costcomponentcostfield23amt +
                    costcomponentcostfield25amt ) AS process_amount
          FROM i_prodcostestcostcomprawdex WITH PRIVILEGED ACCESS "#EC CI_FAE_LINES_ENSURED
         WHERE iscostcomponentsplitlowerlevel = ''
           AND costisinctrlgareacrcy = ''
           AND costingdate < @lv_system_date
         GROUP BY costestimate,
                  costingdate
          INTO TABLE @DATA(lt_productcostcom).
        SORT lt_productcostcom BY costestimate costingdate.
      ENDIF.
*&--MOD END BY XINLEI XU 2025/02/19

      SELECT *
        FROM ztbc_1001 WITH PRIVILEGED ACCESS
       WHERE zid   = 'ZSD017'
         AND zkey1 = 'GL_ACCOUNT'
        INTO TABLE @DATA(lt_ztbc_1001).       "#EC CI_ALL_FIELDS_NEEDED
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
        CLEAR: lv_conditionratevalue_n,
               lv_materialcost2000per_n,
               lv_manufacturingcostper_n,
               lv_conditionquantity1,
               lv_conditionquantity2,
               lv_conditionquantity3.

        ls_output-salesorganization = ls_result-salesorganization.
        ls_output-customer = ls_result-soldtoparty.
        ls_output-yeardate = ls_months-month.
        ls_output-product = ls_result-product.
        ls_output-plantype = lv_ztype1.
        ls_output-profitcenter = ls_result-profitcenter.
        ls_output-salesoffice = ls_result-salesoffice.
        ls_output-salesgroup = ls_result-salesgroup.
        ls_output-matlaccountassignmentgroup = ls_result-salesgroup.

        READ TABLE lt_customer INTO DATA(ls_cus) WITH KEY customer = ls_result-soldtoparty BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-customername = ls_cus-customername.
        ENDIF.

        READ TABLE lt_plant INTO DATA(ls_plant) WITH KEY plant = ls_result-salesorganization BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-plant = ls_plant-plant. " ADD BY XINLEI XU 2025/02/17
          ls_output-plantname = ls_plant-plantname.
          ls_output-companycode = ls_plant-valuationarea.
        ENDIF.

        READ TABLE lt_userdescription INTO DATA(ls_userdescription) WITH KEY userid = ls_result-username .
        IF sy-subrc = 0.
          ls_output-createdbyuser = ls_userdescription-userdescription.
        ENDIF.

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

        READ TABLE lt_producttext INTO DATA(ls_producttext) WITH KEY product = ls_result-product BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-productname = ls_producttext-productname.
        ENDIF.

        READ TABLE lt_customersalesarea INTO DATA(ls_customersalesarea) WITH KEY customer = ls_result-soldtoparty BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-customeraccountassignmentgroup = ls_customersalesarea-customeraccountassignmentgroup.
        ENDIF.

*&--MOD BEGIN BY XINLEI XU 2025/02/19
*        "加工费
*        READ TABLE lt_productcost INTO ls_productcost WITH KEY material          = ls_result-product
*                                                               plant             = ls_result-salesorganization
*                                                               ztype             = 'PROCESS' BINARY SEARCH.
*        IF sy-subrc = 0.
*          " MOD BEGIN BY XINLEI XU 2025/02/18
*          " ls_output-manufacturingcost_n = ls_productcost-totalamountinctrlgareacrcy.
*          ls_output-manufacturingcost_n = ls_productcost-totalpriceininctrlgareacrcy.
*          " MOD END BY XINLEI XU 2025/02/18
*          ls_output-currency1           = ls_productcost-controllingareacurrency.
*        ENDIF.
*        "材料费
*        READ TABLE lt_productcost INTO ls_productcost WITH KEY material          = ls_result-product
*                                                               plant             = ls_result-salesorganization
*                                                               ztype             = 'RAW' BINARY SEARCH.
*        IF sy-subrc = 0.
*          " MOD BEGIN BY XINLEI XU 2025/02/18
*          " ls_output-materialcost2000_n = ls_productcost-totalamountinctrlgareacrcy.
*          ls_output-materialcost2000_n = ls_productcost-totalpriceininctrlgareacrcy.
*          " MOD END BY XINLEI XU 2025/02/18
*          ls_output-currency           = ls_productcost-controllingareacurrency.
*        ENDIF.

        READ TABLE lt_productcostestimate INTO DATA(ls_productcostestimate) WITH KEY product = ls_result-product
                                                                                     plant   = ls_result-salesorganization
                                                                                     BINARY SEARCH.
        IF sy-subrc = 0.
          READ TABLE lt_productcostcom INTO DATA(ls_productcostcom) WITH KEY costestimate = ls_productcostestimate-costestimate
                                                                             costingdate = ls_productcostestimate-costingdate
                                                                             BINARY SEARCH.
          IF sy-subrc = 0.
            " 加工费
            ls_output-currency1 = ls_productcostestimate-controllingareacurrency.
            ls_output-manufacturingcost_n = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                                  iv_currency = ls_productcostestimate-controllingareacurrency
                                                                                  iv_input = ls_productcostcom-process_amount ).
            IF ls_productcostestimate-costinglotsize IS NOT INITIAL.
              ls_output-manufacturingcost_n = ceil( ls_output-manufacturingcost_n / ls_productcostestimate-costinglotsize * 100 ) / 100.
            ENDIF.

            " 材料费
            ls_output-currency = ls_productcostestimate-controllingareacurrency.
            ls_output-materialcost2000_n = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                                 iv_currency = ls_productcostestimate-controllingareacurrency
                                                                                 iv_input = ls_productcostcom-raw_amount ).
            IF ls_productcostestimate-costinglotsize IS NOT INITIAL.
              ls_output-materialcost2000_n = ceil( ls_output-materialcost2000_n / ls_productcostestimate-costinglotsize * 100 ) / 100.
            ENDIF.
          ENDIF.
        ENDIF.
*&--MOD END BY XINLEI XU 2025/02/19

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
          ls_output-salesamount_n = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                          iv_currency = ls_output-displaycurrency1
                                                                          iv_input = ls_output-salesamount_n ).
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
          ls_output-contributionprofittotal_n = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                                      iv_currency = ls_output-displaycurrency2
                                                                                      iv_input = ls_output-contributionprofittotal_n ).
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
          ls_output-grossprofittotal_n = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                               iv_currency = ls_output-displaycurrency3
                                                                               iv_input = ls_output-grossprofittotal_n ).
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

        DATA: lv_has_ppr0 TYPE abap_boolean.
        IF lv_ztype1 = 'A'.
          LOOP AT ls_res_api-d-results INTO DATA(ls_305) WHERE conditiontype                = 'ZYR0'
                                                           AND salesorganization            = ls_result-salesorganization
                                                           AND distributionchannel          = '10'
                                                           AND material                     = ls_result-product
                                                           AND customer                     = ls_result-soldtoparty
                                                           AND conditionquantityunit        = ls_result-salesplanunit
                                                           AND conditionvaliditystartdate_d LE ls_months-endda
                                                           AND conditionvalidityenddate_d   GE ls_months-begda.
*&--MOD BEGIN BY XINLEI XU 2025/04/27 阶梯价逻辑BUG Fixed
*            "如果上述取值条件全部一致的条件有多行，视为有阶梯价
*            READ TABLE lt_collect TRANSPORTING NO FIELDS WITH KEY salesorganization = ls_result-salesorganization
*                                                                  distributionchannel = '10'
*                                                                  material = ls_result-product
*                                                                  customer = ls_result-soldtoparty
*                                                                  conditionquantityunit = ls_result-salesplanunit
*                                                                  conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d.
*            IF sy-subrc = 0.
*              LOOP AT lt_tiered INTO DATA(ls_tiered) WHERE conditiontype = 'ZYR0'
*                                                       AND salesorganization = ls_305-salesorganization
*                                                       AND distributionchannel = '10'
*                                                       AND material = ls_305-material
*                                                       AND customer = ls_305-customer
*                                                       AND conditionquantityunit = ls_result-salesplanunit
*                                                       AND conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d
*                                                       AND conditionscalequantity <= ls_result0_temp-salesplanquantity.
*                "单价有小数
*                ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount( iv_alpha = 'OUT'
*                                                                                       iv_currency = ls_tiered-conditionscaleamountcurrency
*                                                                                       iv_input = ls_tiered-conditionscaleamount ).
**&--ADD BEGIN BY XINLEI XU 2025/04/16
*                lv_conditionratevalue_n = ls_output-conditionratevalue_n.
*                lv_conditionquantity1 = ls_tiered-conditionquantity.
**&--ADD END BY XINLEI XU 2025/04/16
*                ls_output-conditionratevalue_n = ls_output-conditionratevalue_n / ls_tiered-conditionquantity.
*                ls_output-displaycurrency1 = ls_tiered-conditionscaleamountcurrency.
*                "之前排序过 从阶梯数量小于等于计划数量的行中取阶梯数量最大的那一行
*                EXIT.
*              ENDLOOP.
            READ TABLE lt_recordscale_count INTO DATA(ls_recordscale_count) WITH KEY conditionrecord = ls_305-conditionrecord BINARY SEARCH.
            IF sy-subrc = 0 AND ls_recordscale_count-count > 1.
              " 阶梯价格
              LOOP AT lt_recordscale INTO DATA(ls_recordscale) WHERE conditionrecord = ls_305-conditionrecord.
                IF ls_result0_temp-salesplanquantity >= ls_recordscale-conditionscalequantity.
                  ls_output-conditionratevalue_n = ls_recordscale-conditionrateamount.
                  lv_conditionratevalue_n = ls_output-conditionratevalue_n.
                  lv_conditionquantity1 = ls_305-conditionquantity.
                  ls_output-conditionratevalue_n = ls_output-conditionratevalue_n / ls_305-conditionquantity.
                  ls_output-displaycurrency1 = ls_recordscale-conditioncurrency.
                  EXIT.
                ENDIF.
              ENDLOOP.
*&--MOD END BY XINLEI XU 2025/04/27 阶梯价逻辑BUG Fixed
            ELSE.
              ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount( iv_alpha = 'OUT'
                                                                                     iv_currency = ls_305-conditionratevalueunit
                                                                                     iv_input = ls_305-conditionratevalue ).
*&--ADD BEGIN BY XINLEI XU 2025/04/16
              lv_conditionratevalue_n = ls_output-conditionratevalue_n.
              lv_conditionquantity1 = ls_305-conditionquantity.
*&--ADD END BY XINLEI XU 2025/04/16
              ls_output-conditionratevalue_n = ls_output-conditionratevalue_n / ls_305-conditionquantity.
              ls_output-displaycurrency1 = ls_305-conditionratevalueunit.
            ENDIF.
            "之前排序过 有效起止日期被包含在对象月中且日期最大的那条
            EXIT.
          ENDLOOP.

*&--ADD BEGIN BY XINLEI XU 2025/04/15 CR#4277
          " 贡献利润(单价)
          LOOP AT ls_res_api-d-results INTO ls_305 WHERE conditiontype                = lc_zycm
                                                     AND salesorganization            = ls_result-salesorganization
                                                     AND distributionchannel          = '10'
                                                     AND material                     = ls_result-product
                                                     AND customer                     = ls_result-soldtoparty
                                                     AND conditionquantityunit        = ls_result-salesplanunit
                                                     AND conditionvaliditystartdate_d LE ls_months-endda
                                                     AND conditionvalidityenddate_d   GE ls_months-begda.
            READ TABLE lt_recordscale_count INTO ls_recordscale_count WITH KEY conditionrecord = ls_305-conditionrecord BINARY SEARCH.
            IF sy-subrc = 0 AND ls_recordscale_count-count > 1.
              " 阶梯价格
              LOOP AT lt_recordscale INTO ls_recordscale WHERE conditionrecord = ls_305-conditionrecord.
                IF ls_result0_temp-salesplanquantity >= ls_recordscale-conditionscalequantity.
                  ls_output-materialcost2000per_n = ls_recordscale-conditionrateamount.
                  lv_materialcost2000per_n = ls_output-materialcost2000per_n.
                  lv_conditionquantity2 = ls_305-conditionquantity.
                  ls_output-materialcost2000per_n = ceil( ls_output-materialcost2000per_n / ls_305-conditionquantity * 100 ) / 100.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ELSE.
              ls_output-materialcost2000per_n = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                                      iv_currency = ls_305-conditionratevalueunit
                                                                                      iv_input = ls_305-conditionratevalue ).
              lv_materialcost2000per_n = ls_output-materialcost2000per_n.
              lv_conditionquantity2 = ls_305-conditionquantity.
              ls_output-materialcost2000per_n = ceil( ls_output-materialcost2000per_n / ls_305-conditionquantity * 100 ) / 100.
            ENDIF.
            "之前排序过 有效起止日期被包含在对象月中且日期最大的那条
            EXIT.
          ENDLOOP.

          " 销售总利润(单价)
          LOOP AT ls_res_api-d-results INTO ls_305 WHERE conditiontype                = lc_zygp
                                                     AND salesorganization            = ls_result-salesorganization
                                                     AND distributionchannel          = '10'
                                                     AND material                     = ls_result-product
                                                     AND customer                     = ls_result-soldtoparty
                                                     AND conditionquantityunit        = ls_result-salesplanunit
                                                     AND conditionvaliditystartdate_d LE ls_months-endda
                                                     AND conditionvalidityenddate_d   GE ls_months-begda.
            READ TABLE lt_recordscale_count INTO ls_recordscale_count WITH KEY conditionrecord = ls_305-conditionrecord BINARY SEARCH.
            IF sy-subrc = 0 AND ls_recordscale_count-count > 1.
              " 阶梯价格
              LOOP AT lt_recordscale INTO ls_recordscale WHERE conditionrecord = ls_305-conditionrecord.
                IF ls_result0_temp-salesplanquantity >= ls_recordscale-conditionscalequantity.
                  ls_output-manufacturingcostper_n = ls_recordscale-conditionrateamount.
                  lv_manufacturingcostper_n = ls_output-manufacturingcostper_n.
                  lv_conditionquantity3 = ls_305-conditionquantity.
                  ls_output-manufacturingcostper_n = ceil( ls_output-manufacturingcostper_n / ls_305-conditionquantity * 100 ) / 100.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ELSE.
              ls_output-manufacturingcostper_n = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                                       iv_currency = ls_305-conditionratevalueunit
                                                                                       iv_input = ls_305-conditionratevalue ).
              lv_manufacturingcostper_n = ls_output-manufacturingcostper_n.
              lv_conditionquantity3 = ls_305-conditionquantity.
              ls_output-manufacturingcostper_n = ceil( ls_output-manufacturingcostper_n / ls_305-conditionquantity * 100 ) / 100.
            ENDIF.
            "之前排序过 有效起止日期被包含在对象月中且日期最大的那条
            EXIT.
          ENDLOOP.
*&--ADD END BY XINLEI XU 2025/04/15 CR#4277

        ELSEIF lv_ztype1 = 'B'.
          LOOP AT ls_res_api-d-results INTO ls_305 WHERE conditiontype = 'PPR0'
                                                     AND salesorganization = ls_result-salesorganization
                                                     AND distributionchannel = '10'
                                                     AND material = ls_result-product
                                                     AND customer = ls_result-soldtoparty
                                                     AND conditionquantityunit = ls_result-salesplanunit
                                                     AND conditionvaliditystartdate_d LE ls_months-endda
                                                     AND conditionvalidityenddate_d GE ls_months-begda.

            lv_has_ppr0 = abap_true. " ADD BY XINLEI XU 2025/04/15 CR#4277

*&--MOD BEGIN BY XINLEI XU 2025/04/27 阶梯价逻辑BUG Fixed
*            "如果上述取值条件全部一致的条件有多行，视为有阶梯价
*            READ TABLE lt_collect TRANSPORTING NO FIELDS WITH KEY salesorganization = ls_result-salesorganization
*                                                                  distributionchannel = '10'
*                                                                  material = ls_result-product
*                                                                  customer = ls_result-soldtoparty
*                                                                  conditionquantityunit = ls_result-salesplanunit
*                                                                  conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d.
*            IF sy-subrc = 0.
*              LOOP AT lt_tiered INTO ls_tiered WHERE conditiontype = 'PPR0'
*                                                 AND salesorganization = ls_305-salesorganization
*                                                 AND distributionchannel = '10'
*                                                 AND material = ls_305-material
*                                                 AND customer = ls_305-customer
*                                                 AND conditionquantityunit = ls_result-salesplanunit
*                                                 AND conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d
*                                                 AND conditionscalequantity <= ls_result0_temp-salesplanquantity.
*                "单价有小数
*                ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount( iv_alpha = 'OUT'
*                                                                                       iv_currency = ls_tiered-conditionscaleamountcurrency
*                                                                                       iv_input = ls_tiered-conditionscaleamount ).
**&--ADD BEGIN BY XINLEI XU 2025/04/16
*                lv_conditionratevalue_n = ls_output-conditionratevalue_n.
*                lv_conditionquantity1 = ls_tiered-conditionquantity.
**&--ADD END BY XINLEI XU 2025/04/16
*                ls_output-conditionratevalue_n = ls_output-conditionratevalue_n / ls_tiered-conditionquantity.
*                ls_output-displaycurrency1 = ls_tiered-conditionscaleamountcurrency.
*                "之前排序过 从阶梯数量小于等于计划数量的行中取阶梯数量最大的那一行
*                EXIT.
*              ENDLOOP.
            READ TABLE lt_recordscale_count INTO ls_recordscale_count WITH KEY conditionrecord = ls_305-conditionrecord BINARY SEARCH.
            IF sy-subrc = 0 AND ls_recordscale_count-count > 1.
              " 阶梯价格
              LOOP AT lt_recordscale INTO ls_recordscale WHERE conditionrecord = ls_305-conditionrecord.
                IF ls_result0_temp-salesplanquantity >= ls_recordscale-conditionscalequantity.
                  ls_output-conditionratevalue_n = ls_recordscale-conditionrateamount.
                  lv_conditionratevalue_n = ls_output-conditionratevalue_n.
                  lv_conditionquantity1 = ls_305-conditionquantity.
                  ls_output-conditionratevalue_n = ls_output-conditionratevalue_n / ls_305-conditionquantity.
                  ls_output-displaycurrency1 = ls_recordscale-conditioncurrency.
                  EXIT.
                ENDIF.
              ENDLOOP.
*&--MOD END BY XINLEI XU 2025/04/27 阶梯价逻辑BUG Fixed
            ELSE.
              "单价有小数
              ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount( iv_alpha = 'OUT'
                                                                                     iv_currency = ls_305-conditionratevalueunit
                                                                                     iv_input = ls_305-conditionratevalue ).
*&--ADD BEGIN BY XINLEI XU 2025/04/16
              lv_conditionratevalue_n = ls_output-conditionratevalue_n.
              lv_conditionquantity1 = ls_305-conditionquantity.
*&--ADD END BY XINLEI XU 2025/04/16
              ls_output-conditionratevalue_n = ls_output-conditionratevalue_n / ls_305-conditionquantity.
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
*&--MOD BEGIN BY XINLEI XU 2025/04/27 阶梯价逻辑BUG Fixed
*              "如果上述取值条件全部一致的条件有多行，视为有阶梯价
*              READ TABLE lt_collect TRANSPORTING NO FIELDS WITH KEY salesorganization = ls_result-salesorganization
*                                                                    distributionchannel = '10'
*                                                                    material = ls_result-product
*                                                                    customer = ls_result-soldtoparty
*                                                                    conditionquantityunit = ls_result-salesplanunit
*                                                                    conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d.
*              IF sy-subrc = 0.
*                LOOP AT lt_tiered INTO ls_tiered WHERE conditiontype = 'ZZR0'
*                                                   AND salesorganization = ls_305-salesorganization
*                                                   AND distributionchannel = '10'
*                                                   AND material = ls_305-material
*                                                   AND customer = ls_305-customer
*                                                   AND conditionquantityunit = ls_result-salesplanunit
*                                                   AND conditionvaliditystartdate_d = ls_305-conditionvaliditystartdate_d
*                                                   AND conditionscalequantity <= ls_result0_temp-salesplanquantity.
*                  "单价有小数
*                  ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount( iv_alpha = 'OUT'
*                                                                                         iv_currency = ls_tiered-conditionscaleamountcurrency
*                                                                                         iv_input = ls_tiered-conditionscaleamount ).
**&--ADD BEGIN BY XINLEI XU 2025/04/16
*                  lv_conditionratevalue_n = ls_output-conditionratevalue_n.
*                  lv_conditionquantity1 = ls_tiered-conditionquantity.
**&--ADD END BY XINLEI XU 2025/04/16
*                  ls_output-conditionratevalue_n = ls_output-conditionratevalue_n / ls_tiered-conditionquantity.
*                  ls_output-displaycurrency1 = ls_tiered-conditionscaleamountcurrency.
*                  "之前排序过 从阶梯数量小于等于计划数量的行中取阶梯数量最大的那一行
*                  EXIT.
*                ENDLOOP.
              READ TABLE lt_recordscale_count INTO ls_recordscale_count WITH KEY conditionrecord = ls_305-conditionrecord BINARY SEARCH.
              IF sy-subrc = 0 AND ls_recordscale_count-count > 1.
                " 阶梯价格
                LOOP AT lt_recordscale INTO ls_recordscale WHERE conditionrecord = ls_305-conditionrecord.
                  IF ls_result0_temp-salesplanquantity >= ls_recordscale-conditionscalequantity.
                    ls_output-conditionratevalue_n = ls_recordscale-conditionrateamount.
                    lv_conditionratevalue_n = ls_output-conditionratevalue_n.
                    lv_conditionquantity1 = ls_305-conditionquantity.
                    ls_output-conditionratevalue_n = ls_output-conditionratevalue_n / ls_305-conditionquantity.
                    ls_output-displaycurrency1 = ls_recordscale-conditioncurrency.
                    EXIT.
                  ENDIF.
                ENDLOOP.
*&--MOD END BY XINLEI XU 2025/04/27 阶梯价逻辑BUG Fixed
              ELSE.
                "单价有小数
                ls_output-conditionratevalue_n = zzcl_common_utils=>conversion_amount( iv_alpha = 'OUT'
                                                                                       iv_currency = ls_305-conditionratevalueunit
                                                                                       iv_input = ls_305-conditionratevalue ).
*&--ADD BEGIN BY XINLEI XU 2025/04/16
                lv_conditionratevalue_n = ls_output-conditionratevalue_n.
                lv_conditionquantity1 = ls_305-conditionquantity.
*&--ADD END BY XINLEI XU 2025/04/16
                ls_output-conditionratevalue_n = ls_output-conditionratevalue_n / ls_305-conditionquantity.
                ls_output-displaycurrency1 = ls_305-conditionratevalueunit.
              ENDIF.
              "之前排序过 有效起止日期被包含在对象月中且日期最大的那条
              EXIT.
            ENDLOOP.
          ENDIF.
*&--AD BEGIN BY XINLEI XU 2025/04/15 CR#4277
          IF lv_has_ppr0 = abap_false.
            " 贡献利润(单价)
            LOOP AT ls_res_api-d-results INTO ls_305 WHERE conditiontype                = lc_zzcm
                                                       AND salesorganization            = ls_result-salesorganization
                                                       AND distributionchannel          = '10'
                                                       AND material                     = ls_result-product
                                                       AND customer                     = ls_result-soldtoparty
                                                       AND conditionquantityunit        = ls_result-salesplanunit
                                                       AND conditionvaliditystartdate_d LE ls_months-endda
                                                       AND conditionvalidityenddate_d   GE ls_months-begda.
              READ TABLE lt_recordscale_count INTO ls_recordscale_count WITH KEY conditionrecord = ls_305-conditionrecord BINARY SEARCH.
              IF sy-subrc = 0 AND ls_recordscale_count-count > 1.
                " 阶梯价格
                LOOP AT lt_recordscale INTO ls_recordscale WHERE conditionrecord = ls_305-conditionrecord.
                  IF ls_result0_temp-salesplanquantity >= ls_recordscale-conditionscalequantity.
                    ls_output-materialcost2000per_n = ls_recordscale-conditionrateamount.
                    lv_materialcost2000per_n = ls_output-materialcost2000per_n.
                    lv_conditionquantity2 = ls_305-conditionquantity.
                    ls_output-materialcost2000per_n = ceil( ls_output-materialcost2000per_n / ls_305-conditionquantity * 100 ) / 100.
                    EXIT.
                  ENDIF.
                ENDLOOP.
              ELSE.
                ls_output-materialcost2000per_n = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                                        iv_currency = ls_305-conditionratevalueunit
                                                                                        iv_input = ls_305-conditionratevalue ).
                lv_materialcost2000per_n = ls_output-materialcost2000per_n.
                lv_conditionquantity2 = ls_305-conditionquantity.
                ls_output-materialcost2000per_n = ceil( ls_output-materialcost2000per_n / ls_305-conditionquantity * 100 ) / 100.
              ENDIF.
              "之前排序过 有效起止日期被包含在对象月中且日期最大的那条
              EXIT.
            ENDLOOP.

            " 销售总利润(单价)
            LOOP AT ls_res_api-d-results INTO ls_305 WHERE conditiontype                = lc_zzgp
                                                       AND salesorganization            = ls_result-salesorganization
                                                       AND distributionchannel          = '10'
                                                       AND material                     = ls_result-product
                                                       AND customer                     = ls_result-soldtoparty
                                                       AND conditionquantityunit        = ls_result-salesplanunit
                                                       AND conditionvaliditystartdate_d LE ls_months-endda
                                                       AND conditionvalidityenddate_d   GE ls_months-begda.
              READ TABLE lt_recordscale_count INTO ls_recordscale_count WITH KEY conditionrecord = ls_305-conditionrecord BINARY SEARCH.
              IF sy-subrc = 0 AND ls_recordscale_count-count > 1.
                " 阶梯价格
                LOOP AT lt_recordscale INTO ls_recordscale WHERE conditionrecord = ls_305-conditionrecord.
                  IF ls_result0_temp-salesplanquantity >= ls_recordscale-conditionscalequantity.
                    ls_output-manufacturingcostper_n = ls_recordscale-conditionrateamount.
                    lv_manufacturingcostper_n = ls_output-manufacturingcostper_n.
                    lv_conditionquantity3 = ls_305-conditionquantity.
                    ls_output-manufacturingcostper_n = ceil( ls_output-manufacturingcostper_n / ls_305-conditionquantity * 100 ) / 100.
                    EXIT.
                  ENDIF.
                ENDLOOP.
              ELSE.
                ls_output-manufacturingcostper_n = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                                         iv_currency = ls_305-conditionratevalueunit
                                                                                         iv_input = ls_305-conditionratevalue ).
                lv_manufacturingcostper_n = ls_output-manufacturingcostper_n.
                lv_conditionquantity3 = ls_305-conditionquantity.
                ls_output-manufacturingcostper_n = ceil( ls_output-manufacturingcostper_n / ls_305-conditionquantity * 100 ) / 100.
              ENDIF.
              "之前排序过 有效起止日期被包含在对象月中且日期最大的那条
              EXIT.
            ENDLOOP.
*&--ADD END BY XINLEI XU 2025/04/15 CR#4277
          ENDIF.
        ENDIF.

*&--MOD BEGIN BY XINLEI XU 2025/04/15 CR#4277
*        "贡献利润(单价):单价 - 材料费
*        ls_output-materialcost2000per_n = ls_output-conditionratevalue_n - ls_output-materialcost2000_n.
*        "销售总利润(单价)：单价 - 材料费 - 加工费
*        ls_output-manufacturingcostper_n = ls_output-conditionratevalue_n - ls_output-materialcost2000_n - ls_output-manufacturingcost_n.
        IF lv_ztype1 = 'A'.
          "贡献利润(单价): ZYCM
          "销售总利润(单价): ZYGP
        ELSEIF lv_ztype1 = 'B'.
          IF lv_has_ppr0 = abap_true.
            "贡献利润(单价):单价 - 材料费
            ls_output-materialcost2000per_n = ls_output-conditionratevalue_n - ls_output-materialcost2000_n.
            "销售总利润(单价):单价 - 材料费
            ls_output-manufacturingcostper_n = ls_output-conditionratevalue_n - ls_output-materialcost2000_n - ls_output-manufacturingcost_n.
          ELSE.
            "贡献利润(单价): ZZCM
            "销售总利润(单价): ZZGP
          ENDIF.
          CLEAR lv_has_ppr0.
        ENDIF.
*&--MOD END BY XINLEI XU 2025/04/15 CR#4277

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
          ls_output-salesplanunit = ls_result0-salesplanunit.

*&--MOD BEGIN BY XINLEI XU 2025/04/16
          "销售额
          "ls_output-salesamount_n = ls_result0-salesplanquantity * ls_output-conditionratevalue_n.
          "贡献利润
          "ls_output-contributionprofittotal_n = ls_result0-salesplanquantity * ls_output-materialcost2000per_n.
          "销售总利润
          "ls_output-grossprofittotal_n = ls_result0-salesplanquantity * ls_output-manufacturingcostper_n.

          IF lv_conditionquantity1 IS NOT INITIAL.
            ls_output-salesamount_n = ls_result0-salesplanquantity / lv_conditionquantity1 * lv_conditionratevalue_n.
          ELSE.
            ls_output-salesamount_n = ls_result0-salesplanquantity * ls_output-conditionratevalue_n.
          ENDIF.
          IF lv_conditionquantity2 IS NOT INITIAL.
            ls_output-contributionprofittotal_n = ls_result0-salesplanquantity / lv_conditionquantity2 * lv_materialcost2000per_n.
          ELSE.
            ls_output-contributionprofittotal_n = ls_result0-salesplanquantity * ls_output-materialcost2000per_n.
          ENDIF.
          IF lv_conditionquantity3 IS NOT INITIAL.
            ls_output-grossprofittotal_n = ls_result0-salesplanquantity / lv_conditionquantity3 * lv_manufacturingcostper_n.
          ELSE.
            ls_output-grossprofittotal_n = ls_result0-salesplanquantity * ls_output-manufacturingcostper_n.
          ENDIF.
*&--MOD END BY XINLEI XU 2025/04/16

          ls_output-displaycurrency1 = ls_output-conditionratevalueunit.
          ls_output-displaycurrency2 = ls_output-currency.
          ls_output-displaycurrency3 = ls_output-currency1.
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

    "重要非常重要 非常非常重要！！！
    "请给第一key的 添加yeardate 最多列 无值用0填充
    "或者干脆就所有行 无值0
    SORT lt_output BY salesorganization customer profitcenter salesoffice salesgroup product createdbyuser plantype yeardate.

    READ TABLE lt_output INTO ls_output INDEX 1.
    IF sy-subrc = 0.
      DO 50 TIMES.
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

*&--ADD BEGIN BY XINLEI XU 2025/04/17
    LOOP AT lt_output ASSIGNING FIELD-SYMBOL(<lfs_output>).
      zzcl_common_utils=>get_fiscal_year_period(
        EXPORTING
          iv_date   = |{ <lfs_output>-yeardate }01|
        IMPORTING
          ev_year   = DATA(lv_fiscalyear)
          ev_period = DATA(lv_fiscalperiod) ).

      <lfs_output>-yeardate = |{ <lfs_output>-yeardate }_{ lv_fiscalyear }{ lv_fiscalperiod }|.
    ENDLOOP.
*&--ADD END BY XINLEI XU 2025/04/17

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
