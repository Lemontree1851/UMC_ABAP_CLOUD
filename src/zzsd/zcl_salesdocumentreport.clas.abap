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

    DATA: lv_grossprofit        TYPE p DECIMALS 0,
          lv_contributionprofit TYPE p DECIMALS 0.

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
      d~productname,
      e~product,
      f~billofmaterial,
      f~billofmaterialvariant,
      g~customer,
      k~plantname,
      i~matlaccountassignmentgroup,
      l~materialcost2000,
      l~materialcost3000
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
   LEFT JOIN i_billofmaterialitemdex_3 WITH PRIVILEGED ACCESS AS f
   ON f~billofmaterialcomponent = a~product
   LEFT JOIN i_customercompany WITH PRIVILEGED ACCESS AS g
   ON g~companycode = a~salesorganization
   LEFT JOIN i_customersalesarea WITH PRIVILEGED ACCESS AS h
   ON h~salesorganization = a~salesorganization
   AND h~customer = g~customer
   LEFT JOIN i_customer WITH PRIVILEGED ACCESS AS b
   ON b~customername = a~soldtoparty
   AND b~customer = g~customer
   LEFT JOIN i_plant WITH PRIVILEGED ACCESS AS k
   ON k~plant = a~plant
   LEFT JOIN i_productsalesdelivery WITH PRIVILEGED ACCESS AS j
   ON j~product = a~product
   LEFT JOIN i_matlaccountassignmentgroup WITH PRIVILEGED ACCESS AS i
   ON i~matlaccountassignmentgroup = j~accountdetnproductgroup
   LEFT JOIN ztfi_1010 AS l
   ON l~product = a~product
   AND l~customer = g~customer
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

    LOOP AT lt_data INTO lw_data.  " 循环遍历 lt_dataS
      APPEND lw_data TO lt_output.  " 将当前行的 lw_data 追加到 lt_output 内表
    ENDLOOP.

****6.02上位BOM番号により、上位半製品/製品の品番取得

    IF sy-subrc = 0.
      DATA(lt_plant) = lt_result1.
      SORT lt_plant BY plant.
      DELETE ADJACENT DUPLICATES FROM lt_plant COMPARING plant.
    ENDIF.

    IF lt_plant IS NOT INITIAL.

      SELECT
         material,
         billofmaterial,
         billofmaterialvariant,
         plant
       FROM i_materialbomlinkdex WITH PRIVILEGED ACCESS
       FOR ALL ENTRIES IN @lt_plant
        WHERE billofmaterial = @lt_plant-billofmaterial
          AND billofmaterialvariant = @lt_plant-billofmaterialvariant
          AND plant = @lt_plant-plant
       INTO TABLE @DATA(lt_material1).

    ENDIF.

****6.03有償支給品の品番により、上位BOM番号取得

    IF sy-subrc = 0.
      DATA(lt_material) = lt_material1.
      SORT lt_material BY material.
      DELETE ADJACENT DUPLICATES FROM lt_material COMPARING material.
    ENDIF.

    IF lt_material IS NOT INITIAL.

      SELECT
         billofmaterial,
         billofmaterialvariant
       FROM i_billofmaterialitemdex_3 WITH PRIVILEGED ACCESS
       FOR ALL ENTRIES IN @lt_material
        WHERE billofmaterialcomponent = @lt_material-material
       INTO TABLE @DATA(lt_bom1).

    ENDIF.

****6.04上位BOM番号により、上位半製品/製品の品番取得

    IF sy-subrc = 0.
      DATA(lt_bom2) = lt_bom1.
      SORT lt_bom2 BY billofmaterial billofmaterialvariant.
      DELETE ADJACENT DUPLICATES FROM lt_bom2 COMPARING billofmaterial billofmaterialvariant.
    ENDIF.

    IF lt_bom2 IS NOT INITIAL.

      SELECT
         material,
         billofmaterial,
         billofmaterialvariant
       FROM i_materialbomlinkdex WITH PRIVILEGED ACCESS
       FOR ALL ENTRIES IN @lt_bom2
        WHERE billofmaterial = @lt_bom2-billofmaterial
          AND billofmaterialvariant = @lt_bom2-billofmaterialvariant
       INTO TABLE @DATA(lt_material2).

    ENDIF.

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

*********************

*    * 3.01-3.08 BOM番号
*    DATA(lt_product_tmp) = lt_product[].
*    DO.
** find the upper bom code
*      SELECT billofmaterial,
*             billofmaterialvariant,
*             billofmaterialitemnodenumber,
*             bominstceinternalchangenumber,
*             billofmaterialcomponent
*        FROM i_billofmaterialitemdex_3 WITH PRIVILEGED ACCESS
*        FOR ALL ENTRIES IN @lt_product_tmp
*       WHERE billofmaterialcomponent = @lt_product_tmp-product
*         AND isdeleted = @space
*        INTO TABLE @DATA(lt_up).
*      " Exit loop if not find upper bom
*      IF sy-subrc <> 0.
*        EXIT.
*      ENDIF.
** get material number by bom code
*      IF lt_up IS NOT INITIAL.
*        SELECT billofmaterial,
*               billofmaterialvariant,
*               material,
*               plant,
*               billofmaterialvariantusage
*          FROM i_materialbomlinkdex WITH PRIVILEGED ACCESS
*          FOR ALL ENTRIES IN @lt_up
*         WHERE billofmaterial = @lt_up-billofmaterial
*           AND billofmaterialvariant = @lt_up-billofmaterialvariant
*           AND plant IN @lr_plant
*          INTO TABLE @DATA(lt_expode).
*      ENDIF.
** get the cost bom to check
*      IF lt_expode IS NOT INITIAL.
*        SELECT costingreferenceobject,
*               costestimate,
*               costingtype,
*               costingdate,
*               costingversion,
*               valuationvariant,
*               costisenteredmanually,
*               product,
*               plant,
*               costestimatevaliditystartdate,
*               billofmaterial,
*               alternativebillofmaterial
*          FROM i_productcostestimate WITH PRIVILEGED ACCESS
*          FOR ALL ENTRIES IN @lt_expode
*         WHERE product = @lt_expode-material
*           AND plant IN @lr_plant
*           AND costingvariant = 'PYC1'
*           AND costestimatevaliditystartdate <= @lv_to
*           AND costestimatestatus = 'FR'
*          INTO TABLE @DATA(lt_costbom).
** get lasted date value
*        SORT lt_costbom BY product plant
*                           costestimatevaliditystartdate DESCENDING.
*        DELETE ADJACENT DUPLICATES FROM lt_costbom COMPARING product plant.
*      ENDIF.
*      IF lt_costbom IS NOT INITIAL.
*        SELECT  billofmaterialcategory,
*                billofmaterial,
*                billofmaterialvariant,
*                billofmaterialitemnodenumber,
*                bominstceinternalchangenumber,
*                billofmaterialcomponent
*          FROM i_billofmaterialitemdex_3 WITH PRIVILEGED ACCESS
*          FOR ALL ENTRIES IN @lt_costbom
*         WHERE billofmaterial = @lt_costbom-billofmaterial
*           AND billofmaterialvariant = @lt_costbom-alternativebillofmaterial
*           AND isdeleted = @space
*           INTO TABLE @DATA(lt_costbomexpode).
*
*      ENDIF.
*
** Check costbom with material bom
*      SORT lt_costbomexpode BY billofmaterialcomponent billofmaterialvariant.
*      LOOP AT lt_up INTO DATA(ls_up).
*        READ TABLE lt_costbomexpode
*             WITH KEY billofmaterialcomponent = ls_up-billofmaterialcomponent
*                      billofmaterialvariant = ls_up-billofmaterialvariant BINARY SEARCH
*             TRANSPORTING NO FIELDS.
*        IF sy-subrc <> 0.
*          DELETE lt_up.
*          CONTINUE.
*        ENDIF.
*      ENDLOOP.
*
*      SORT lt_up BY billofmaterial billofmaterialvariant.
*      LOOP AT lt_expode INTO DATA(ls_expode).
*        READ TABLE lt_up
*             WITH KEY billofmaterial = ls_expode-billofmaterial
*                      billofmaterialvariant = ls_expode-billofmaterialvariant BINARY SEARCH
*             TRANSPORTING NO FIELDS.
*        IF sy-subrc <> 0.
*          DELETE lt_expode.
*          CONTINUE.
*        ELSE.
*          lrs_bom-sign = 'I'.
*          lrs_bom-option = 'EQ'.
*          lrs_bom-low = ls_expode-material.
*          APPEND lrs_bom TO lr_bom.
*          CLEAR: lrs_bom.
*        ENDIF.
*      ENDLOOP.
*
*
** edit bom hierarchy
*      DATA(lt_bom_tmp) = lt_bom[].
*      CLEAR: lt_bom.
*      lv_index = lv_index + 1.
*      lv_num_parent = lv_index.
*      IF lv_index = 1.
** Prepare the last layer
*        LOOP AT lt_expode INTO ls_expode.
*          ls_bom-parent01 = ls_expode-material.
*          ls_bom-plant = ls_expode-plant.
*
*          READ TABLE lt_up INTO ls_up
*               WITH KEY billofmaterial = ls_expode-billofmaterial
*                        billofmaterialvariant = ls_expode-billofmaterialvariant BINARY SEARCH.
*          IF sy-subrc = 0.
*            ls_bom-raw = ls_up-billofmaterialcomponent.
*          ENDIF.
*          APPEND ls_bom TO lt_bom.
*          CLEAR: ls_bom.
*        ENDLOOP.
*
*      ELSE.
** Expand bom from second to last layer to the first layer
*        DATA(lv_field) = 'PARENT' && lv_num_parent.
*        lv_num_son = lv_num_parent - 1.
*        DATA(lv_field_son) = 'PARENT' && lv_num_son.
*        SORT lt_bom_tmp BY plant (lv_field_son).
*
*        LOOP AT lt_expode INTO ls_expode.
*          READ TABLE lt_up INTO ls_up
*               WITH KEY billofmaterial = ls_expode-billofmaterial
*                        billofmaterialvariant = ls_expode-billofmaterialvariant BINARY SEARCH.
*          IF sy-subrc = 0.
*            READ TABLE lt_bom_tmp INTO ls_bom
*                 WITH KEY plant = ls_expode-plant
*                          (lv_field_son) = ls_up-billofmaterialcomponent BINARY SEARCH.
*            IF sy-subrc = 0.
*              DATA(lv_tabix) = sy-tabix.
*              ASSIGN COMPONENT lv_field OF STRUCTURE ls_bom TO <fs>.
*              <fs> = ls_expode-material.
*              APPEND ls_bom TO lt_bom.
*              DELETE lt_bom_tmp INDEX lv_tabix.
*              CONTINUE.
*            ENDIF.
*            CLEAR: ls_bom.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*      IF lt_bom_tmp IS NOT INITIAL.
*        APPEND LINES OF lt_bom_tmp TO lt_bom_temp.
*      ENDIF.
*      CLEAR: lt_product_tmp.
*      LOOP AT lt_expode INTO ls_expode.
*        ls_product-product = ls_expode-material.
*        ls_product-plant = ls_expode-plant.
*        APPEND ls_product TO lt_product_tmp.
*        CLEAR: ls_product.
*      ENDLOOP.
*    ENDDO.
*    APPEND LINES OF lt_bom_temp TO lt_bom.




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
