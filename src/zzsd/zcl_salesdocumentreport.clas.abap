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
      lr_yeardate          TYPE RANGE OF zr_salesdocumentreport-yeardate,           "年月
      lr_customer          TYPE RANGE OF zr_salesdocumentreport-customer,           "得意先
      lr_product           TYPE RANGE OF zr_salesdocumentreport-product,            "品目
*      lr_plantype          TYPE RANGE OF zr_salesdocumentreport-plantype,           "計画タイプ
      ls_salesorganization LIKE LINE OF  lr_salesorganization,
      ls_yeardate          LIKE LINE OF  lr_yeardate,
      ls_customer          LIKE LINE OF  lr_customer,
      ls_product           LIKE LINE OF  lr_product.
*      ls_plantype          LIKE LINE OF  lr_plantype.

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

    CONSTANTS:
      lc_exchangetype    TYPE string VALUE '0'.

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
          WHEN 'SALESORGANIZATION'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_salesorganization.
            APPEND ls_salesorganization TO lr_salesorganization.
            CLEAR ls_salesorganization.
          WHEN 'YEARDATE'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_yeardate.
            APPEND ls_yeardate TO lr_yeardate.
            CLEAR ls_yeardate.
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

    SELECT
       a~salesorganization AS salesorganization1,
       b~customer,
       b~companycode,
       c~salesorganization,
       d~customername,
       e~material
     FROM i_customersalesarea WITH PRIVILEGED ACCESS AS a
     LEFT JOIN i_customercompany WITH PRIVILEGED ACCESS AS b
       ON a~customer = b~customer
     LEFT JOIN i_salesorganization WITH PRIVILEGED ACCESS AS c
       ON c~salesorganization = a~salesorganization
       AND c~salesorganization = b~companycode
     LEFT JOIN i_customer WITH PRIVILEGED ACCESS AS d
       ON  d~customer = a~customer
       AND d~customer = b~customer
*     LEFT JOIN ztfi_1010 as e
*       ON e~Customer = b~customer
     LEFT JOIN i_materialbomlinkdex WITH PRIVILEGED ACCESS AS e
       ON e~plant = a~salesorganization
     WHERE a~salesorganization IN @lr_salesorganization
       AND b~companycode IN @lr_salesorganization
       AND b~customer IN @lr_customer
       INTO TABLE @DATA(lt_basicdata).

    LOOP AT  lt_basicdata INTO DATA(lw_basicdata).
      MOVE-CORRESPONDING lw_basicdata TO lw_data.
      APPEND lw_data TO lt_data.
    ENDLOOP.

    LOOP AT lt_data INTO lw_data.  " 循环遍历 lt_dataS
      APPEND lw_data TO lt_output.  " 将当前行的 lw_data 追加到 lt_output 内表
    ENDLOOP.

    DATA(lv_typeab) = lv_ztype1 && '%'.  " lv_ztype1 与百分号连接

    SELECT
      createdbyuser,
      salesplan,
      salesplanversion
    FROM c_salesplanvaluehelp WITH PRIVILEGED ACCESS
*    WHERE salesplanversion LIKE @lv_typeab
    INTO TABLE @lt_planversion.

    SELECT *
    FROM c_salesplanvaluehelp WITH PRIVILEGED ACCESS
*    WHERE salesplanversion LIKE @lv_typeab
    INTO TABLE @DATA(lt_planversion2).

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
*      c~\_MatlAccountAssignmentGroup
      d~productname,
      e~product,
      f~billofmaterial,
      f~billofmaterialvariant
    FROM i_slsperformanceplanactualcube(
      p_exchangeratetype = 0,
      p_displaycurrency  = 'JPY',
      p_salesplan        = @lw_versionmax-salesplan,
      p_salesplanversion = @lw_versionmax-salesplanversion,
      p_createdbyuser    = @lw_versionmax-createdbyuser ) WITH PRIVILEGED ACCESS AS a
   LEFT JOIN i_customer WITH PRIVILEGED ACCESS AS b
   ON b~customername = a~soldtoparty
*   LEFT JOIN i_productsalesdelivery WITH PRIVILEGED ACCESS AS c
*   ON c~product = a~product
   LEFT JOIN i_producttext WITH PRIVILEGED ACCESS AS d
   ON d~product = a~product
   LEFT JOIN i_product WITH PRIVILEGED ACCESS AS e
   ON e~product = a~product
   LEFT JOIN i_billofmaterialitemdex_3 WITH PRIVILEGED ACCESS AS f
   ON f~billofmaterialcomponent = a~product
   WHERE a~product IN @lr_product
    INTO TABLE @DATA(lt_result1).

    IF sy-subrc = 0.
      DATA(lt_product) = lt_result1.
      SORT lt_product BY product.
      DELETE ADJACENT DUPLICATES FROM lt_product COMPARING product.
    ENDIF.

*    SELECT single material
*    FROM i_materialbomlinkdex WITH PRIVILEGED ACCESS
*    FOR ALL ENTRIES IN lt_product


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
      SORT lt_read2 BY salesplanquantity salesplanperiodname.
      DELETE ADJACENT DUPLICATES FROM lt_read2 COMPARING salesplanquantity salesplanperiodname.
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

    IF sy-subrc = 0.
      DATA(lt_read4) = lt_result4.
      SORT lt_read4 BY salesplanamountindspcrcy salesplanperiodname.
      DELETE ADJACENT DUPLICATES FROM lt_read4 COMPARING salesplanamountindspcrcy salesplanperiodname.
    ENDIF.

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

    IF sy-subrc = 0.
      DATA(lt_read5) = lt_result5.
      SORT lt_read5 BY salesplanamountindspcrcy salesplanperiodname.
      DELETE ADJACENT DUPLICATES FROM lt_read5 COMPARING salesplanamountindspcrcy salesplanperiodname.
    ENDIF.

*********単価*********
    IF lv_ztype1 = 'A'.

*      SELECT
*        conditionratevalue,
*        SalesPlanPeriodName
*      FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
*      WHERE conditiontype      = 'ZYP0'
*        AND conditionisdeleted = @space
*      FOR ALL ENTRIES IN @lt_read2
*       WHERE ConditionValidityStartDate = @lt_read2-SalesPlanPeriodName
*      INTO @DATA(lv_ratevaluea).

      IF lt_read2 IS NOT INITIAL.
        SELECT conditionratevalue
          FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
*          FOR ALL ENTRIES IN @lt_read2
         WHERE conditiontype      = 'ZYP0'
           AND conditionisdeleted = @space
*           AND conditionvaliditystartdate = @lt_read2-salesplanperiodname

         INTO TABLE @DATA(lt_ratevaluea).
      ENDIF.


    ELSE.

      SELECT SINGLE
         conditionratevalue
       FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
*         FOR ALL ENTRIES IN @lt_read2
       WHERE conditiontype      = 'PPR0'
         AND conditionisdeleted = @space
*       AND ConditionValidityStartDate = @lt_read2-salesplanperiodname
       INTO @DATA(lv_ratevalueb1).

      IF lv_ratevalueb1 IS INITIAL.

        SELECT SINGLE
        conditionratevalue
      FROM i_slsprcgconditionrecord WITH PRIVILEGED ACCESS
*         FOR ALL ENTRIES IN @lt_read2
      WHERE conditiontype      = 'ZZR0'
        AND conditionisdeleted = @space
*       AND ConditionValidityStartDate = @lt_read2-salesplanperiodname
      INTO @DATA(lv_ratevalueb2).

      ENDIF.

    ENDIF.
*********単価*********
*
    "貢献利益"

*      SELECT
*        a~SalesPlanAmountInDspCrcy,
*        a~SalesPlanPeriodName,
*        c~ConditionRateValue
*        FROM I_SlsPerformancePlanActualCube WITH PRIVILEGED ACCESS AS a
*        LEFT JOIN C_SalesPlanValueHelp WITH PRIVILEGED ACCESS AS b
*          ON  a~P_EXCHANGERATETYPE = '0'
*          AND a~P_CREATEDBYUSER    = b~CreatedByUser
*          AND a~P_SALESPLAN        = b~SalesPlan
*          AND a~P_SALESPLANVERSION = @lv_salesplan_version2
*          AND a~P_DISPLAYCURRENCY  = 'JPY'
*        LEFT JOIN I_SlsPrcgConditionRecord WITH PRIVILEGED ACCESS AS c
*          ON c~ConditionType = 'ZYP0'
*          AND c~ConditionIsDeleted = @SPACE
*          AND c~ConditionValidityStartDate = a~SalesPlanPeriodName
*        INTO TABLE @DATA(lt_result2).

*"売上総利益"
*
*      SELECT
*        a~SalesPlanAmountInDspCrcy,
*        a~SalesPlanPeriodName
*        FROM I_SlsPerformancePlanActualCube WITH PRIVILEGED ACCESS AS a
*        LEFT JOIN C_SalesPlanValueHelp WITH PRIVILEGED ACCESS AS b
*          ON  a~P_EXCHANGERATETYPE = '0'
*          AND a~P_CREATEDBYUSER    = b~CreatedByUser
*          AND a~P_SALESPLAN        = b~SalesPlan
*          AND a~P_SALESPLANVERSION = @lv_salesplan_version3
*          AND a~P_DISPLAYCURRENCY  = 'JPY'
*        INTO TABLE @DATA(lt_result3).

*     SELECT
*       ConditionRateValue
*     FROM I_SlsPrcgConditionRecord
*     WHERE ConditionType = 'ZYPO'
*       AND ConditionIsDeleted = SPACE
*       AND ConditionValidityStartDate = lt_result2-SalesPlanPeriodName
*     INTO TABLE @DATA(lt_RateValue).




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
