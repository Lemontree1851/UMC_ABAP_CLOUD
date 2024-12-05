CLASS zcl_salesdocumentreport DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_salesdocumentreport IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA:
      lt_data              TYPE STANDARD TABLE OF zr_salesdocumentreport,
      lw_data              LIKE LINE OF lt_data,
      lt_output            TYPE STANDARD TABLE OF zr_salesdocumentreport,
      lr_salesorganization TYPE RANGE OF zr_salesdocumentreport-salesorganization,  "販売組織
*      lr_yeardate          TYPE RANGE OF zr_salesdocumentreport-yeardate,           "年月
      lr_customer          TYPE RANGE OF zr_salesdocumentreport-customer,           "得意先
      lr_product           TYPE RANGE OF zr_salesdocumentreport-product,            "品目
*      lr_plantype          TYPE RANGE OF zr_salesdocumentreport-plantype,           "計画タイプ
      ls_salesorganization LIKE LINE OF  lr_salesorganization,
*      ls_yeardate          LIKE LINE OF  lr_yeardate,
      ls_customer          LIKE LINE OF  lr_customer,
      ls_product           LIKE LINE OF  lr_product.
*      ls_plantype          LIKE LINE OF  lr_plantype.

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

    DATA:lt_version0 TYPE STANDARD TABLE OF ty_planversion,
         ls_version0 TYPE ty_planversion.

    DATA:lt_version1 TYPE STANDARD TABLE OF ty_planversion,
         ls_version1 TYPE ty_planversion.

    DATA:lt_version2 TYPE STANDARD TABLE OF ty_planversion,
         ls_version2 TYPE ty_planversion.

    DATA:lt_version3 TYPE STANDARD TABLE OF ty_planversion,
         ls_version3 TYPE ty_planversion.

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

    CONSTANTS:
      lc_exchangetype    TYPE string VALUE '0'.

    TRY.
        "Get and add filter
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option) ##NO_HANDLER.
    ENDTRY.

    DATA(lv_top)    = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)   = io_request->get_paging( )->get_offset( ).
    DATA(lt_fields) = io_request->get_requested_elements( ).
    DATA(lt_sort)   = io_request->get_sort_elements( ).

    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).

      LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).

        CASE ls_filter_cond-name.
          WHEN 'SALESORGANIZATION'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_salesorganization.
            APPEND ls_salesorganization TO lr_salesorganization.
            CLEAR ls_salesorganization.
          WHEN 'YEARDATE'.
            DATA(lr_yeardate) = ls_filter_cond-range.
            READ TABLE lr_yeardate INTO DATA(lrs_yeardate) INDEX 1.
            DATA(lv_yeardate) = lrs_yeardate-low.
          WHEN 'CUSTOMER'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_customer.
            APPEND ls_customer TO lr_customer.
            CLEAR ls_customer.
          WHEN 'PRODUCT'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_product.
            APPEND ls_product TO lr_product.
            CLEAR ls_product.
          WHEN 'PLANTYPE'.
            DATA(lr_plantype) = ls_filter_cond-range.
            READ TABLE lr_plantype INTO DATA(lrs_plantype) INDEX 1.
            DATA(lv_ztype1) = lrs_plantype-low.
          WHEN 'SPLITRANGE'.
            DATA(r_splitrange) = ls_filter_cond-range.
            READ TABLE r_splitrange INTO DATA(rs_splitrange) INDEX 1.
            IF sy-subrc = 0.
              SPLIT rs_splitrange-low AT '-' INTO DATA(lv_splitstart) DATA(lv_splitend).
            ENDIF.
          WHEN OTHERS.

        ENDCASE.

      ENDLOOP.

    ENDLOOP.

    DATA: lt_salesplan         TYPE TABLE OF string,
          lv_pattern           TYPE string,
          lv_salesplan_version TYPE string,
          lv_max_number        TYPE i,
          lv_number            TYPE i,
          lv_second_char       TYPE c LENGTH 1,
          lv_third_char        TYPE c LENGTH 1.

    DATA(lv_typeab) = lv_ztype1 && '%'.  " lv_ztype1 与百分号连接

    SELECT
      createdbyuser,
      salesplan,
      salesplanversion
    FROM c_salesplanvaluehelp WITH PRIVILEGED ACCESS
    WHERE salesplanversion LIKE @lv_typeab
    INTO TABLE @lt_planversion.

********基础数据获取********
*得意先名*品名

    "按第二位数字排序
    SORT lt_planversion BY salesplanversion+1(1) DESCENDING.

    "获取排序后的第一条记录，即第二位数字最大的记录
    READ TABLE lt_planversion INDEX 1 INTO DATA(lw_versionmax).

    SELECT
      a~salesorganization,
      a~salesoffice,
      a~salesgroup,
      a~soldtoparty,
      a~product AS product_a,
      a~productgroup,
      a~plant,
      a~profitcenter,
      b~customername,
      c~customeraccountassignmentgroup,
      d~productname,
      e~product,
      g~customer,
      k~plantname,
      j~firstsalesspecproductgroup,
      j~secondsalesspecproductgroup,
      j~thirdsalesspecproductgroup,
      j~accountdetnproductgroup,
      i~matlaccountassignmentgroup,
      l~materialcost2000,
      l~materialcost3000,
      m~mrpresponsible,
      n~profitcenter AS profitcenter_bom
    FROM i_slsperformanceplanactualcube(
      p_exchangeratetype = 0,
      p_displaycurrency  = 'JPY',
      p_salesplan        = @lw_versionmax-salesplan,
      p_salesplanversion = @lw_versionmax-salesplanversion,
      p_createdbyuser    = @lw_versionmax-createdbyuser ) WITH PRIVILEGED ACCESS AS a
   LEFT JOIN i_producttext WITH PRIVILEGED ACCESS AS d
   ON d~product = a~product
   LEFT JOIN i_product WITH PRIVILEGED ACCESS AS e
   ON e~product = a~product
   LEFT JOIN i_customercompany WITH PRIVILEGED ACCESS AS g
   ON g~companycode = a~salesorganization
   LEFT JOIN i_customersalesarea WITH PRIVILEGED ACCESS AS h
   ON h~salesorganization = a~salesorganization
   AND h~customer = g~customer
   LEFT JOIN i_customer WITH PRIVILEGED ACCESS AS b
   ON b~customername = a~soldtoparty
   AND b~customer = g~customer
   LEFT JOIN i_customersalesarea WITH PRIVILEGED ACCESS AS c
   ON c~customer = g~customer
   AND c~salesorganization = a~salesorganization
   LEFT JOIN i_plant WITH PRIVILEGED ACCESS AS k
   ON k~plant = a~plant
   LEFT JOIN i_productsalesdelivery WITH PRIVILEGED ACCESS AS j
   ON j~product = a~product
   LEFT JOIN i_matlaccountassignmentgroup WITH PRIVILEGED ACCESS AS i
   ON i~matlaccountassignmentgroup = j~accountdetnproductgroup
   LEFT JOIN ztfi_1010 AS l
   ON l~product = a~product
   AND l~customer = g~customer
   LEFT JOIN i_productplantmrp WITH PRIVILEGED ACCESS AS m
   ON m~plant = a~plant
   AND m~product = a~product
   LEFT JOIN i_profitcentertoproduct WITH PRIVILEGED ACCESS AS n
   ON n~plant = a~plant
   AND n~product = a~product
   AND n~companycode = a~plant
   WHERE a~product IN @lr_product
     AND a~plant IN @lr_salesorganization
     AND g~customer IN @lr_customer
    INTO TABLE @DATA(lt_result1).

    LOOP AT  lt_result1 INTO DATA(lw_result1).
      MOVE-CORRESPONDING lw_result1 TO lw_data.
      " 判断 lw_result1-materialcost2000 是否为空
      IF lw_result1-materialcost2000 IS INITIAL.
        lw_data-materialcost2000 = lw_result1-materialcost3000.
      ENDIF.

      " 根据 MatlAccountAssignmentGroup 的值判断输出文本
      CASE lw_result1-matlaccountassignmentgroup.
        WHEN '01'.
          lw_data-matlaccountassignmentgroup = '量産'.
        WHEN '02' OR '03'.
          lw_data-matlaccountassignmentgroup = '部品・その他'.
        WHEN '04'.
          lw_data-matlaccountassignmentgroup = 'イニシャル'.
        WHEN '05' OR '06'.
          lw_data-matlaccountassignmentgroup = '開発'.
        WHEN OTHERS.
          lw_data-matlaccountassignmentgroup = '未定義'.
      ENDCASE.

      APPEND lw_data TO lt_data.
    ENDLOOP.

*    LOOP AT lt_data INTO lw_data.  " 循环遍历 lt_dataS
*      APPEND lw_data TO lt_output.  " 将当前行的 lw_data 追加到 lt_output 内表
*    ENDLOOP.

*    * 6.01-6.08 BOM番号

    SORT lt_result1 BY plant product.

    LOOP AT lt_result1 INTO DATA(ls_result1).
      "Obtain data of high level material of component
      zcl_bom_where_used=>get_data(
        EXPORTING
          iv_plant                   = ls_result1-plant
          iv_billofmaterialcomponent = ls_result1-product
        IMPORTING
          et_usagelist               = lt_usagelist ).

      APPEND LINES OF lt_usagelist TO lt_highlevelmaterialinfo.
      CLEAR lt_usagelist.
    ENDLOOP.
********計画数量********

    CLEAR lt_version0.

    " 筛选第二位数字为 '0' 的记录
    LOOP AT lt_planversion INTO ls_planversion.
      IF ls_planversion-salesplanversion+1(1) = '0'.
        APPEND ls_planversion TO lt_version0.
      ENDIF.
    ENDLOOP.

    " 如果有筛选结果，按第三位数字排序
    IF lt_version0 IS NOT INITIAL.
      SORT lt_version0 BY salesplanversion+2(1) DESCENDING.

      " 获取第三位数字最大的记录
      READ TABLE lt_version0 INDEX 1 INTO DATA(lw_version0).
    ENDIF.

    SELECT
      salesplanquantity,
      salesplanperiodname
    FROM i_slsperformanceplanactualcube(
      p_exchangeratetype = 0,
      p_displaycurrency  = 'JPY',
      p_salesplan        = @lw_version0-salesplan,
      p_salesplanversion = @lw_version0-salesplanversion,
      p_createdbyuser    = @lw_version0-createdbyuser ) WITH PRIVILEGED ACCESS
    INTO TABLE @DATA(lt_result2).

    IF sy-subrc = 0.
      DATA(lt_read2) = lt_result2.
      SORT lt_read2 BY salesplanperiodname salesplanquantity.
      DELETE ADJACENT DUPLICATES FROM lt_read2 COMPARING salesplanperiodname salesplanquantity.
    ENDIF.

*********単価*********
    IF lv_ztype1 = 'A'.

      IF lt_read2 IS NOT INITIAL.

        " 遍历 lt_read2，匹配年份和月份，并获取第一条记录
        LOOP AT lt_read2 INTO DATA(lw_reada).
          " 提取 salesplanperiodname 的年份和月份
          DATA(lv_salesplanperiodnamea) = lw_reada-salesplanperiodname(4) && '-' && lw_reada-salesplanperiodname+4(2). " yyyy-MM 格式

          " 查询与年份和月份匹配的 conditionvaliditystartdate 数据
          DATA(lv_patterna) = lv_salesplanperiodnamea && '-%'. " 拼接成 LIKE 的模式，例如 "2024-11-%"

          SELECT conditionratevalue,
                 conditionvaliditystartdate
            FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
            WHERE conditiontype      = 'ZYP0'
              AND conditionisdeleted = @space
              AND conditionvaliditystartdate LIKE @lv_patterna
            INTO TABLE @DATA(lt_ratevalue_tempa).

          IF lt_ratevalue_tempa IS NOT INITIAL.
            SORT lt_ratevalue_tempa BY conditionvaliditystartdate ASCENDING. " 根据具体排序字段排序
            READ TABLE lt_ratevalue_tempa INTO DATA(ls_conditionratevaluea) INDEX 1. " 取排序后的第一条记录
            lw_data-conditionratevalue = ls_conditionratevaluea-conditionratevalue.
            lw_data-salesamount = ls_conditionratevaluea-conditionratevalue * lw_reada-salesplanquantity.
          ENDIF.
        ENDLOOP.

      ELSE.

        " 遍历 lt_read2，匹配年份和月份，并获取第一条记录
        LOOP AT lt_read2 INTO DATA(lw_readb).
          " 提取 salesplanperiodname 的年份和月份
          DATA(lv_salesplanperiodnameb) = lw_reada-salesplanperiodname(4) && '-' && lw_reada-salesplanperiodname+4(2). " yyyy-MM 格式

          " 查询与年份和月份匹配的 conditionvaliditystartdate 数据
          DATA(lv_patternb) = lv_salesplanperiodnameb && '-%'. " 拼接成 LIKE 的模式，例如 "2024-11-%"

          SELECT conditionratevalue,
                 conditionvaliditystartdate
            FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
            WHERE conditiontype      = 'PPR0'
              AND conditionisdeleted = @space
              AND conditionvaliditystartdate LIKE @lv_patternb
            INTO TABLE @DATA(lt_ratevalue_tempbppr0).

          IF lt_ratevalue_tempbppr0 IS INITIAL.

            SELECT conditionratevalue,
                   conditionvaliditystartdate
            FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
            WHERE conditiontype      = 'ZZR0'
              AND conditionisdeleted = @space
              AND conditionvaliditystartdate LIKE @lv_patternb
            INTO TABLE @DATA(lt_ratevalue_tempbzzr0).

          ENDIF.

          IF lt_ratevalue_tempbppr0 IS NOT INITIAL.
            SORT lt_ratevalue_tempbppr0 BY conditionvaliditystartdate ASCENDING. " 根据具体排序字段排序
            READ TABLE lt_ratevalue_tempbppr0 INTO DATA(ls_conditionratevaluebppr0) INDEX 1. " 取排序后的第一条记录
            lw_data-conditionratevalue = ls_conditionratevaluebppr0-conditionratevalue.
            lw_data-salesamount = ls_conditionratevaluebppr0-conditionratevalue * lw_readb-salesplanquantity.
          ELSE.

            SORT lt_ratevalue_tempbzzr0 BY conditionvaliditystartdate ASCENDING. " 根据具体排序字段排序
            READ TABLE lt_ratevalue_tempbzzr0 INTO DATA(ls_conditionratevaluebzzr0) INDEX 1. " 取排序后的第一条记录
            lw_data-conditionratevalue = ls_conditionratevaluebzzr0-conditionratevalue.
            lw_data-salesamount = ls_conditionratevaluebzzr0-conditionratevalue * lw_readb-salesplanquantity.
          ENDIF.

        ENDLOOP.

      ENDIF.
    ENDIF.

*********売上*********
    CLEAR lt_version1.

    " 筛选第二位数字为 '1' 的记录
    LOOP AT lt_planversion INTO ls_planversion.
      IF ls_planversion-salesplanversion+1(1) = '1'.
        APPEND ls_planversion TO lt_version1.
      ENDIF.
    ENDLOOP.

    " 如果有筛选结果，按第三位数字排序
    IF lt_version1 IS NOT INITIAL.
      SORT lt_version1 BY salesplanversion+2(1) DESCENDING.

      " 获取第三位数字最大的记录
      READ TABLE lt_version1 INDEX 1 INTO DATA(lw_version1).
    ENDIF.

    SELECT
      salesplanamountindspcrcy,
      salesplanperiodname
    FROM i_slsperformanceplanactualcube(
      p_exchangeratetype = 0,
      p_displaycurrency  = 'JPY',
      p_salesplan        = @lw_version1-salesplan,
      p_salesplanversion = @lw_version1-salesplanversion,
      p_createdbyuser    = @lw_version1-createdbyuser ) WITH PRIVILEGED ACCESS
    INTO TABLE @DATA(lt_result3).

    IF sy-subrc = 0.
      DATA(lt_read3) = lt_result3.
      SORT lt_read3 BY salesplanamountindspcrcy salesplanperiodname.
      DELETE ADJACENT DUPLICATES FROM lt_read3 COMPARING salesplanamountindspcrcy salesplanperiodname.
    ENDIF.

*********貢献利益*********
    CLEAR lt_version2.

    " 筛选第二位数字为 '2' 的记录
    LOOP AT lt_planversion INTO ls_planversion.
      IF ls_planversion-salesplanversion+1(1) = '2'.
        APPEND ls_planversion TO lt_version2.
      ENDIF.
    ENDLOOP.

    " 如果有筛选结果，按第三位数字排序
    IF lt_version2 IS NOT INITIAL.
      SORT lt_version2 BY salesplanversion+2(1) DESCENDING.

      " 获取第三位数字最大的记录
      READ TABLE lt_version2 INDEX 1 INTO DATA(lw_version2).
    ENDIF.

    SELECT
      salesplanamountindspcrcy,
      salesplanperiodname
    FROM i_slsperformanceplanactualcube(
      p_exchangeratetype = 0,
      p_displaycurrency  = 'JPY',
      p_salesplan        = @lw_version2-salesplan,
      p_salesplanversion = @lw_version2-salesplanversion,
      p_createdbyuser    = @lw_version2-createdbyuser ) WITH PRIVILEGED ACCESS
    INTO TABLE @DATA(lt_result4).

*********貢献利益(単価)********
    SORT lt_result4 BY salesplanperiodname DESCENDING.
    LOOP AT  lt_read2 INTO DATA(lw_contributionprofit).
      READ TABLE lt_result4 INTO DATA(lw_result4)
          WITH KEY salesplanperiodname = lw_contributionprofit-salesplanperiodname
               BINARY SEARCH.

      IF lw_result4-salesplanamountindspcrcy IS NOT INITIAL AND lw_contributionprofit-salesplanquantity IS NOT INITIAL.
        lv_contributionprofit = ( lw_result4-salesplanamountindspcrcy * 100 ) / lw_contributionprofit-salesplanquantity.
      ELSE.

        lw_data-contributionprofit = round(
         val = lv_contributionprofit
         dec = 0
         mode = cl_abap_math=>round_half_up
         ).
      ENDIF.

    ENDLOOP.

*********貢献利益********


*********売上総利益*********
    CLEAR lt_version3.

    " 筛选第二位数字为 '3' 的记录
    LOOP AT lt_planversion INTO ls_planversion.
      IF ls_planversion-salesplanversion+1(1) = '3'.
        APPEND ls_planversion TO lt_version3.
      ENDIF.
    ENDLOOP.

    " 如果有筛选结果，按第三位数字排序
    IF lt_version3 IS NOT INITIAL.
      SORT lt_version3 BY salesplanversion+2(1) DESCENDING.

      " 获取第三位数字最大的记录
      READ TABLE lt_version3 INDEX 1 INTO DATA(lw_version3).
    ENDIF.

    SELECT
      salesplanamountindspcrcy,
      salesplanperiodname
    FROM i_slsperformanceplanactualcube(
      p_exchangeratetype = 0,
      p_displaycurrency  = 'JPY',
      p_salesplan        = @lw_version3-salesplan,
      p_salesplanversion = @lw_version3-salesplanversion,
      p_createdbyuser    = @lw_version3-createdbyuser ) WITH PRIVILEGED ACCESS
    INTO TABLE @DATA(lt_result5).

*********売上総利益(単価)********
    SORT lt_result5 BY salesplanperiodname DESCENDING.
    LOOP AT  lt_read2 INTO DATA(lw_grossprofit).

      READ TABLE lt_result5 INTO DATA(lw_result5)
          WITH KEY salesplanperiodname = lw_grossprofit-salesplanperiodname
               BINARY SEARCH.

      IF lw_result5-salesplanamountindspcrcy IS NOT INITIAL AND lw_grossprofit-salesplanquantity IS NOT INITIAL.
        lv_grossprofit = ( lw_result5-salesplanamountindspcrcy * 100 ) / lw_grossprofit-salesplanquantity.
      ELSE.

        lw_data-grossprofit = round(
         val = lv_grossprofit
         dec = 0
         mode = cl_abap_math=>round_half_up
         ).
      ENDIF.
    ENDLOOP.
************************************************************
*     test 数据集
************************************************************
    DATA:
     ls_output            TYPE  zr_salesdocumentreport.

    CLEAR ls_output.
    ls_output-salesorganization = '11'.
    ls_output-yeardate = '202401'.

    ls_output-conditionratevalue_n = 12.
    ls_output-salesplanamountindspcrcy_n = 124.
    ls_output-salesamount_n  = 1234.
    ls_output-contributionprofittotal_n = 0.
    ls_output-grossprofittotal_n = 0.
    APPEND ls_output TO lt_output.


    CLEAR ls_output.
    ls_output-salesorganization = '11'.
    ls_output-yeardate = '202402'.
    ls_output-conditionratevalue_n = 1112.
    ls_output-salesplanamountindspcrcy_n = 0.
    ls_output-salesamount_n  = 0.
    ls_output-contributionprofittotal_n = 0.
    ls_output-grossprofittotal_n = 0.
    APPEND ls_output TO lt_output.



    CLEAR ls_output.
    ls_output-salesorganization = '11'.
    ls_output-yeardate = '202403'.

    ls_output-conditionratevalue_n = 0.
    ls_output-salesplanamountindspcrcy_n = 0.
    ls_output-salesamount_n  = 0.
    ls_output-contributionprofittotal_n = 0.
    ls_output-grossprofittotal_n = 0.

    APPEND ls_output TO lt_output.
    CLEAR ls_output.
    ls_output-salesorganization = '2'.
    ls_output-yeardate = '202403'.
    ls_output-conditionratevalue_n = 0.
    ls_output-salesplanamountindspcrcy_n = 0.
    ls_output-salesamount_n  = 0.
    ls_output-contributionprofittotal_n = 0.
    ls_output-grossprofittotal_n = 0.
    APPEND ls_output TO lt_output.
    CLEAR ls_output.
    "如果选了202401-202404 但是202404没值 也要有等于0的行
    ls_output-salesorganization = '32'.
    ls_output-yeardate = '202404'.
    ls_output-conditionratevalue_n = 0.
    ls_output-salesplanamountindspcrcy_n = 124.
    ls_output-salesamount_n  = 0.
    ls_output-contributionprofittotal_n = 0.
    ls_output-grossprofittotal_n = 7.
    APPEND ls_output TO lt_output.


    "重要非常重要 非常非常重要！！！
    "请给第一key的 添加yeardate 最多列 无值用0填充
    "或者干脆就所有行 无值0

    SORT lt_output BY salesorganization customer product plantype.
    READ TABLE lt_output INTO ls_output INDEX 1.
    IF sy-subrc = 0.

      DO 50 TIMES.
        DATA:lv_yeardatetemp TYPE bldat.
        DATA:lv_yeardatetemp1(6) TYPE c.
        lv_index = sy-index.
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


    ENDIF.






    DELETE lt_output WHERE yeardate < lv_splitstart OR yeardate > lv_splitend.

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
