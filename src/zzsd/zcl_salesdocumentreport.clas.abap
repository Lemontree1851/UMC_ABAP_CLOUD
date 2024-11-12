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
      lt_data              TYPE STANDARD TABLE OF zr_salesdocumentreport,
      lw_data              LIKE LINE OF lt_data,
      lt_output            TYPE STANDARD TABLE OF zr_salesdocumentreport,
      lr_salesorganization TYPE RANGE OF zr_salesdocumentreport-salesorganization,  "販売組織
      lr_yeardate          TYPE RANGE OF zr_salesdocumentreport-yeardate,           "年月
      lr_customer          TYPE RANGE OF zr_salesdocumentreport-customer,           "得意先
      lr_product           TYPE RANGE OF zr_salesdocumentreport-product,            "品目
      lr_plantype          TYPE RANGE OF zr_salesdocumentreport-plantype,           "計画タイプ
      ls_salesorganization LIKE LINE OF  lr_salesorganization,
      ls_yeardate          LIKE LINE OF  lr_yeardate,
      ls_customer          LIKE LINE OF  lr_customer,
      ls_product           LIKE LINE OF  lr_product,
      ls_plantype          LIKE LINE OF  lr_plantype.


    CONSTANTS:
      lc_exchangetype     TYPE string VALUE '0'.

    IF io_request->is_data_requested( ).
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
            WHEN 'salesorganization'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_salesorganization.
              APPEND ls_salesorganization TO lr_salesorganization.
              CLEAR ls_salesorganization.
            WHEN 'yeardate'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_yeardate.
              APPEND ls_yeardate TO lr_yeardate.
              CLEAR ls_yeardate.
            WHEN 'customer'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_customer.
              APPEND ls_customer TO lr_customer.
              CLEAR ls_customer.
            WHEN 'product'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_product.
              APPEND ls_product TO lr_product.
              CLEAR ls_product.
            WHEN 'plantype'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_plantype.
              APPEND ls_plantype TO lr_plantype.
              CLEAR ls_plantype.
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

      " 使用 CONCATENATE 生成模式
      CONCATENATE ls_plantype-low '%' INTO lv_pattern.

      " 查询并存储结果
      SELECT salesplanversion FROM c_salesplanvaluehelp
        WHERE salesplanversion LIKE @lv_pattern
        INTO TABLE @lt_salesplan.

      " 初始化最大值和对应版本
      DATA(lv_salesplan_versions) = ''.

      " 循环处理所有的第二个字符 '0', '1', '2', '3'
      DO 4 TIMES.
        DATA(lv_index) = sy-index - 1.
        DATA(lv_second_char_value) = lv_index.  " 0, 1, 2, 3

        " 初始化最大值
        lv_max_number = -1.
        lv_salesplan_version = ''.

        LOOP AT lt_salesplan INTO DATA(lv_salesplan_version_current).
          " 获取第二个字符
          lv_second_char = lv_salesplan_version_current+1(1).

          " 检查第二个字符是否匹配
          IF lv_second_char = lv_second_char_value.
            " 获取第三个字符数字
            lv_third_char = lv_salesplan_version_current+2(1).

            " 将字符转换为数字
            lv_number = lv_third_char.

            " 更新最大值和对应版本
            IF lv_number IS NOT INITIAL AND lv_number > lv_max_number.
              lv_max_number = lv_number.
              lv_salesplan_version = lv_salesplan_version_current.
            ENDIF.
          ENDIF.
        ENDLOOP.

        " 根据第二个字符保存结果
        CASE lv_index.
          WHEN 0.
            DATA(lv_salesplan_version0) = lv_salesplan_version.
          WHEN 1.
            DATA(lv_salesplan_version1) = lv_salesplan_version.
          WHEN 2.
            DATA(lv_salesplan_version2) = lv_salesplan_version.
          WHEN 3.
            DATA(lv_salesplan_version3) = lv_salesplan_version.
        ENDCASE.
      ENDDO.

*"販売計画のマスタデータについて"

*      SELECT
*        a~salesorganization,
*        a~salesoffice,
*        a~salesgroup,
*        a~soldtoparty,
*        a~product,
*        a~productgroup,
*        a~plant,
*        a~profitcenter,
**        c~CustomerName
*        d~MatlAccountAssignmentGroup,
*        e~ProductName
*        FROM I_SlsPerformancePlanActualCube( P_EXCHANGERATETYPE = '0',
*                                             P_CREATEDBYUSER   = CreatedByUser,
*                                             P_SALESPLAN        = SalesPlan,
*                                             P_SALESPLANVERSION = @lv_salesplan_version,
*                                             P_DISPLAYCURRENCY  = 'JPY' ) WITH PRIVILEGED ACCESS AS a
*        LEFT JOIN C_SalesPlanValueHelp WITH PRIVILEGED ACCESS AS b
*
**        LEFT JOIN I_Customer WITH PRIVILEGED ACCESS AS c
**          ON c~Customer = a~CustomerGroup
*        LEFT JOIN I_ProductSalesDelivery WITH PRIVILEGED ACCESS AS d
*          ON d~Product = a~Product
*        LEFT JOIN I_ProductText WITH PRIVILEGED ACCESS AS e
*          ON e~Product = a~Product
*        INTO TABLE @DATA(lt_result).
*
*      SELECT
*        a~SalesPlanQuantity,
*        a~SalesPlanPeriodName
*        FROM I_SlsPerformancePlanActualCube WITH PRIVILEGED ACCESS AS a
*        LEFT JOIN C_SalesPlanValueHelp WITH PRIVILEGED ACCESS AS b
*          ON  a~P_EXCHANGERATETYPE = '0'
*          AND a~P_CREATEDBYUSER    = b~CreatedByUser
*          AND a~P_SALESPLAN        = b~SalesPlan
*          AND a~P_SALESPLANVERSION = @lv_salesplan_version0
*          AND a~P_DISPLAYCURRENCY  = 'JPY'
*        INTO TABLE @DATA(lt_result0) .
*
*      SELECT
*        a~SalesPlanAmountInDspCrcy,
*        a~SalesPlanPeriodName
*        FROM I_SlsPerformancePlanActualCube WITH PRIVILEGED ACCESS AS a
*        LEFT JOIN C_SalesPlanValueHelp WITH PRIVILEGED ACCESS AS b
*          ON  a~P_EXCHANGERATETYPE = '0'
*          AND a~P_CREATEDBYUSER    = b~CreatedByUser
*          AND a~P_SALESPLAN        = b~SalesPlan
*          AND a~P_SALESPLANVERSION = @lv_salesplan_version1
*          AND a~P_DISPLAYCURRENCY  = 'JPY'
*        INTO TABLE @DATA(lt_result1).
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


      " Filtering
      zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
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
    ENDIF.
  ENDMETHOD.
ENDCLASS.
