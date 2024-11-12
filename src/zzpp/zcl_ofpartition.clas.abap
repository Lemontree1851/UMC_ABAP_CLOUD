CLASS zcl_ofpartition DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
    METHODS:
      get_splitqty IMPORTING x          TYPE i "一个月内要分配的日期数量
                             y          TYPE menge_d "可分配的总数量
                             z          TYPE i "分割的最小单位数量
                             n          TYPE i "一个月内的第几个要分配的日期
                   RETURNING VALUE(qty) TYPE menge_d."对应日期分配到的数量

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ofpartition IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    CASE io_request->get_entity_id( ).
      WHEN 'ZCE_OFPARTITION'.
        TYPES: BEGIN OF ty_split_coll,
                 customer            TYPE zc_orderforecast-customer,
                 plant               TYPE zc_orderforecast-plant,
                 material            TYPE zc_orderforecast-material,
                 requirementmonth(6) TYPE n,
                 requirementqty      TYPE zc_orderforecast-requirementqty,
                 unitofmeasure       TYPE zc_orderforecast-unitofmeasure,
               END OF ty_split_coll.
        DATA: lt_split_coll TYPE TABLE OF ty_split_coll,
              ls_split_coll TYPE ty_split_coll.
        TYPES: BEGIN OF ty_split_date,
                 customer      TYPE zc_ofsplitrule-customer,
                 plant         TYPE zc_ofsplitrule-plant,
                 material      TYPE zc_ofsplitrule-splitmaterial,
                 splitdate     TYPE datn,
                 splitmonth(6) TYPE n,
                 splitunit     TYPE zc_ofsplitrule-splitunit,
                 shipunit      TYPE zc_ofsplitrule-shipunit,
                 dateindex     TYPE i, "当前分割日期是一个月中的第几个日期
                 datecount     TYPE i, "当前月份有几个日期
               END OF ty_split_date.
        DATA: lt_split_date TYPE TABLE OF ty_split_date,
              ls_split_date TYPE ty_split_date.
*        TYPES: BEGIN OF ty_split_of,
*                 customer        TYPE zc_orderforecast-customer,
*                 plant           TYPE zc_orderforecast-plant,
*                 material        TYPE zc_orderforecast-material,
*                 requirementdate TYPE zc_orderforecast-requirementdate,
*                 requirementqty  TYPE zc_orderforecast-requirementqty,
*               END OF ty_split_of.
        DATA: lt_split_of TYPE TABLE OF zce_ofpartition,
              ls_split_of TYPE zce_ofpartition.
        TRY.
            DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range INTO DATA(cx_erro).
            DATA ls_msg TYPE scx_t100key.
            DATA(lv_msg) = cx_erro->get_text( ).
*          ls_msg = VALUE #( msgid = 'GENERIC_CDE' msgno = '000' attr1 = cx_erro->get_text( ) ).
*          RAISE EXCEPTION TYPE cx_rap_query_provider
*            EXPORTING
*             textid = ls_msg.

        ENDTRY.
        LOOP AT lt_ranges INTO DATA(ls_ranges).
          CASE ls_ranges-name.
            WHEN 'CUSTOMER'.
              DATA(r_customer) = ls_ranges-range.
            WHEN 'PLANT'.
              DATA(r_plant) = ls_ranges-range.
            WHEN 'MATERIAL'.
              DATA(r_material) = ls_ranges-range.
          ENDCASE.
        ENDLOOP.

        DATA(lt_parameters) = io_request->get_parameters( ).

        "获取要取值的范围
        DATA(temp_startdate) = cl_abap_context_info=>get_system_date( ).
        FINAL(lv_startdate) = CONV datum( temp_startdate(6) && '01' ).
        DATA(temp_enddate) = zzcl_common_utils=>calc_date_add( date = lv_startdate year = 2 ).
        FINAL(lv_enddate) = zzcl_common_utils=>get_enddate_of_month( temp_enddate ).
        "获取OF数据
        SELECT
          customer,
          plant,
          material,
          requirementdate,
          substring( requirementdate, 1, 6 ) AS requirementmonth,
          requirementqty,
          unitofmeasure,
          createdat
        FROM zc_orderforecast
        WHERE customer IN @r_customer
          AND plant IN @r_plant
          AND material IN @r_material
          AND requirementdate >= @lv_startdate
          AND requirementdate <= @lv_enddate
        INTO TABLE @DATA(lt_orderforecast).
        IF lt_orderforecast IS INITIAL.
          IF io_request->is_total_numb_of_rec_requested( ).
            io_response->set_total_number_of_records( 0 ).
          ENDIF.
          EXIT.
        ENDIF.

        "获取分割规则
        FINAL(current_date) = cl_abap_context_info=>get_system_date( ).
        FINAL(current_month) = current_date(4) && '/' && current_date+4(2).
        SELECT
          customer,
          plant,
          splitmaterial AS material,
          splitunit,
          shipunit,
          validend
        FROM zc_ofsplitrule
        WHERE customer IN @r_customer
          AND plant IN @r_plant
          AND splitmaterial IN @r_material
          AND deleteflag  = ''
          AND validend >= @current_month
        INTO TABLE @DATA(lt_ofsplitrule).
        "保留一个有效期
        SORT lt_ofsplitrule BY customer plant material validend.
        DELETE ADJACENT DUPLICATES FROM lt_ofsplitrule COMPARING customer plant material validend.

        SORT lt_orderforecast BY customer plant material requirementdate createdat DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_orderforecast COMPARING customer plant material requirementdate.

        DATA(lt_of_key) = lt_orderforecast.
        SORT lt_of_key BY customer plant material.
        DELETE ADJACENT DUPLICATES FROM lt_of_key COMPARING customer plant material.

        "获取前端传入的分割范围
        READ TABLE lt_parameters INTO DATA(ls_parameters) WITH KEY parameter_name = 'SPLITRANGE'.
        IF sy-subrc = 0.
          SPLIT ls_parameters-value AT '-' INTO DATA(lv_splitstart) DATA(lv_splitend).
        ENDIF.
        IF lv_splitstart IS INITIAL.
          lv_splitstart = cl_abap_context_info=>get_system_date( ).
          lv_splitstart = lv_splitstart(6).
        ENDIF.
        IF lv_splitend IS INITIAL.
          lv_splitend = cl_abap_context_info=>get_system_date( ).
          lv_splitend = lv_splitend(6).
        ENDIF.
        "合并分割范围内的数据
        LOOP AT lt_orderforecast INTO DATA(ls_orderforecast) WHERE requirementmonth >= lv_splitstart AND
          requirementmonth <= lv_splitend.
          MOVE-CORRESPONDING ls_orderforecast TO ls_split_coll.
          COLLECT ls_split_coll INTO lt_split_coll.
          CLEAR ls_split_coll.
        ENDLOOP.
        DATA lv_index TYPE i.
        DATA date_index TYPE i.
        DATA the_last_month(6) TYPE n.
        "分割起始日期
        DATA(lv_splitstartdate) = CONV datum( lv_splitstart && '01' ).
        "分割结束日期
        DATA(lv_splitenddate) = zzcl_common_utils=>get_enddate_of_month( lv_splitend && '01' ).
        "确定分割范围内哪些日期需要分配数量
        LOOP AT lt_ofsplitrule INTO DATA(ls_ofsplitrule).
          CASE ls_ofsplitrule-splitunit.
            WHEN 'M'."按月分割
              WHILE 1 = 1.
                lv_index = sy-index - 1.
                MOVE-CORRESPONDING ls_ofsplitrule TO ls_split_date.
                ls_split_date-splitdate = zzcl_common_utils=>calc_date_add( date = lv_splitstart && '01' month = lv_index ).
                "如果当前日期非工作日则需要向后延，找到下一个工作日
                ls_split_date-splitdate = zzcl_common_utils=>get_workingday( ls_split_date-splitdate ).
                "如果日期已经超过了要分割的区间则不用处理
                IF ( ls_split_date-splitdate > lv_splitenddate ).
                  EXIT.
                ENDIF.
                ls_split_date-splitmonth = ls_split_date-splitdate(6).
                ls_split_date-dateindex = 1."按月分割每月只有一个日期
                APPEND ls_split_date TO lt_split_date.
                CLEAR ls_split_date.

              ENDWHILE.
            WHEN 'J'."按旬分割
              WHILE 1 = 1.
                lv_index = sy-index - 1.
                MOVE-CORRESPONDING ls_ofsplitrule TO ls_split_date.
                ls_split_date-splitdate = zzcl_common_utils=>calc_date_add( date = lv_splitstart && '01' month = lv_index ).

                "上旬
                ls_split_date-splitdate = zzcl_common_utils=>get_workingday( ls_split_date-splitdate(6) && '01' ).
                "如果日期已经超过了要分割的区间则不用处理
                IF ( ls_split_date-splitdate > lv_splitenddate ).
                  EXIT.
                ENDIF.
                ls_split_date-splitmonth = ls_split_date-splitdate(6).
                ls_split_date-dateindex = 1."按旬分割每月有3个日期
                APPEND ls_split_date TO lt_split_date.
                "中旬
                ls_split_date-splitdate = zzcl_common_utils=>get_workingday( ls_split_date-splitdate(6) && '11' ).
                "如果日期已经超过了要分割的区间则不用处理
                IF ( ls_split_date-splitdate > lv_splitenddate ).
                  EXIT.
                ENDIF.
                ls_split_date-splitmonth = ls_split_date-splitdate(6).
                ls_split_date-dateindex = 2."按旬分割每月有3个日期
                APPEND ls_split_date TO lt_split_date.
                "下旬
                ls_split_date-splitdate = zzcl_common_utils=>get_workingday( ls_split_date-splitdate(6) && '21' ).
                "如果日期已经超过了要分割的区间则不用处理
                IF ( ls_split_date-splitdate > lv_splitenddate ).
                  EXIT.
                ENDIF.
                ls_split_date-splitmonth = ls_split_date-splitdate(6).
                ls_split_date-dateindex = 3."按旬分割每月有3个日期
                APPEND ls_split_date TO lt_split_date.

                CLEAR ls_split_date.
              ENDWHILE.
            WHEN 'W'."按周分割
              MOVE-CORRESPONDING ls_ofsplitrule TO ls_split_date.
              TRY.
                  cl_scal_utils=>date_get_week(
                    EXPORTING
                      iv_date = lv_splitstartdate
                    IMPORTING
                      ev_year = DATA(lv_year)
                      ev_week = DATA(lv_week) ).
                  cl_scal_utils=>week_get_first_day(
                    EXPORTING
                      iv_year      = lv_year
                      iv_week      = lv_week
                      iv_year_week = |{ lv_year }{ lv_week }|
                    IMPORTING
                      ev_date      = DATA(lv_monday) ).
                  "如果第一周的周一不在当月，则需要取下一周周一
                  IF lv_monday < lv_splitstartdate.
                    lv_week = lv_week + 1.
                    cl_scal_utils=>week_get_first_day(
                    EXPORTING
                      iv_year      = lv_year
                      iv_week      = lv_week
                      iv_year_week = |{ lv_year }{ lv_week }|
                    IMPORTING
                      ev_date      = lv_monday ).
                  ENDIF.
                CATCH cx_scal INTO DATA(lx_scal).
                  EXIT.
              ENDTRY.
              CLEAR the_last_month.
              WHILE 1 = 1.
                IF sy-index > 1.
                  lv_monday = lv_monday + 7.
                ENDIF.
                lv_monday = zzcl_common_utils=>get_workingday( lv_monday ).
                ls_split_date-splitdate = lv_monday.
                "如果日期已经超过了要分割的区间则不用处理
                IF ( ls_split_date-splitdate > lv_splitenddate ).
                  EXIT.
                ENDIF.
                ls_split_date-splitmonth = ls_split_date-splitdate(6).
                IF the_last_month <> ls_split_date-splitmonth.
                  date_index = 1.
                ELSE.
                  date_index = date_index + 1.
                ENDIF.
                the_last_month = ls_split_date-splitmonth.
                ls_split_date-dateindex = date_index.
                APPEND ls_split_date TO lt_split_date.
              ENDWHILE.
            WHEN 'D'."按日分割
              DATA(lv_work_day) = lv_splitstartdate.
              MOVE-CORRESPONDING ls_ofsplitrule TO ls_split_date.
              CLEAR the_last_month.
              WHILE 1 = 1.
                IF sy-index > 1.
                  lv_work_day = lv_work_day + 1.
                ENDIF.
                lv_work_day = zzcl_common_utils=>get_workingday( lv_work_day ).
                ls_split_date-splitdate = lv_work_day.
                "如果日期已经超过了要分割的区间则不用处理
                IF ( ls_split_date-splitdate > lv_splitenddate ).
                  EXIT.
                ENDIF.
                ls_split_date-splitmonth = ls_split_date-splitdate(6).
                IF the_last_month <> ls_split_date-splitmonth.
                  date_index = 1.
                ELSE.
                  date_index = date_index + 1.
                ENDIF.
                the_last_month = ls_split_date-splitmonth.
                ls_split_date-dateindex = date_index.
                APPEND ls_split_date TO lt_split_date.

              ENDWHILE.
          ENDCASE.
        ENDLOOP.

        " 获取附加数据
        IF lt_of_key IS NOT INITIAL.
          SELECT
            ofkey~customer,
            ofkey~plant,
            ofkey~material,
            _text~productname,
            _custmat~materialbycustomer
          FROM @lt_of_key AS ofkey
          LEFT JOIN i_producttext WITH PRIVILEGED ACCESS AS _text
            ON _text~product = ofkey~material
            AND _text~language = @sy-langu
          LEFT JOIN ztbc_1001 AS _config
            ON _config~zid = 'ZPP013'
            AND _config~zvalue1 = ofkey~plant
          LEFT JOIN i_customermaterial_2 WITH PRIVILEGED ACCESS AS _custmat
            ON _custmat~salesorganization = _config~zvalue2
            AND _custmat~product = ofkey~material
            AND _custmat~customer = ofkey~customer
          INTO TABLE @DATA(lt_additional).
          SORT lt_additional BY customer plant material.
        ENDIF.

        "每月最后一个日期的index 就是当月日期的计数
        SORT lt_split_date BY customer plant material splitmonth splitdate DESCENDING.
        LOOP AT lt_split_date ASSIGNING FIELD-SYMBOL(<fs_split_date>).
          READ TABLE lt_split_date INTO ls_split_date WITH KEY customer = <fs_split_date>-customer
            plant = <fs_split_date>-plant material = <fs_split_date>-material splitmonth = <fs_split_date>-splitmonth BINARY SEARCH.
          IF sy-subrc = 0.
            <fs_split_date>-datecount = ls_split_date-dateindex.
          ENDIF.
        ENDLOOP.
        SORT lt_split_date BY customer plant material splitmonth splitdate.
        sort lt_of_key by customer plant material.
        SORT lt_split_date BY customer plant material splitdate.
        SORT lt_split_coll BY customer plant material requirementmonth.
        "确定OF分割后的数量
        LOOP AT lt_of_key INTO DATA(ls_of_key).
          ls_split_of-customer = ls_of_key-customer.
          ls_split_of-plant = ls_of_key-plant.
          ls_split_of-material = ls_of_key-material.
          READ TABLE lt_additional INTO DATA(ls_additional) WITH KEY customer = ls_of_key-customer
            plant = ls_of_key-plant material = ls_of_key-material BINARY SEARCH.
          IF sy-subrc = 0.
            ls_split_of-materialbycustomer = ls_additional-materialbycustomer.
            ls_split_of-materialname = ls_additional-productname.
          ENDIF.
          DATA(temp_date) = lv_startdate.
          WHILE temp_date <= lv_enddate.
            ls_split_of-requirementdate = temp_date.
            "如果是分割范围内的日期，数量需要重新分配
            IF temp_date >= lv_splitstartdate AND temp_date <= lv_splitenddate.
              READ TABLE lt_split_date INTO ls_split_date WITH KEY customer = ls_of_key-customer
                plant = ls_of_key-plant material = ls_of_key-material splitdate = temp_date BINARY SEARCH.
              IF sy-subrc = 0.
                READ TABLE lt_split_coll INTO ls_split_coll WITH KEY customer = ls_of_key-customer
                  plant = ls_of_key-plant material = ls_of_key-material requirementmonth = ls_split_date-splitmonth BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_split_of-requirementqty = get_splitqty(  x = ls_split_date-datecount
                                                              y = ls_split_coll-requirementqty
                                                              z = ls_split_date-shipunit
                                                              n = ls_split_date-dateindex ).
                ELSE.
                  ls_split_of-requirementqty = 0.
                ENDIF.
              ENDIF.
              "如果是分割范围外的日期，数量直接取原来的
            ELSE.
              READ TABLE lt_orderforecast INTO ls_orderforecast WITH KEY customer = ls_of_key-customer
                plant = ls_of_key-plant material = ls_of_key-material requirementdate = temp_date BINARY SEARCH.
              IF sy-subrc = 0.
                ls_split_of-requirementqty = ls_orderforecast-requirementqty.
              ENDIF.
            ENDIF.
            APPEND ls_split_of TO lt_split_of.
            CLEAR ls_split_of-requirementqty.
            temp_date = temp_date + 1.
          ENDWHILE.
        ENDLOOP.

       " 处理数据时 lt_of_key 已经排序，所以这里的排序可以省略
*        sort lt_split_of by customer plant material requirementdate.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( lt_split_of ) ).
        ENDIF.
        IF io_request->is_data_requested( ).
          zzcl_odata_utils=>paging(
            EXPORTING
              io_paging = io_request->get_paging( )
            CHANGING
              ct_data = lt_split_of
          ).
          io_response->set_data( lt_split_of ).
        ENDIF.

    ENDCASE.
  ENDMETHOD.

  METHOD get_splitqty.
    DATA:
      base_distribution      TYPE i,    "基础分配量
      remaining_qty          TYPE i,    "剩余数量
      full_rounds            TYPE i,    "完整轮次的分配
      remaining_after_rounds TYPE i,    "剩余轮次后的数量
      qty_for_n              TYPE i.    "最终分配给第N个日期的数量

    "计算基础分配量
    base_distribution = ( y DIV ( x * z ) ) * z.
    remaining_qty = y MOD ( x * z ).

    "给N个日期分配基础量的数量
    qty_for_n = base_distribution.

    "计算完整分配轮次
    full_rounds = remaining_qty DIV z.
    remaining_after_rounds = remaining_qty MOD z.

    "判断剩余数量的分配
    IF n <= full_rounds.
      qty_for_n = qty_for_n + z.
    ELSEIF n = full_rounds + 1.
      qty_for_n = qty_for_n + remaining_after_rounds.
    ENDIF.
    qty = qty_for_n.
  ENDMETHOD.
ENDCLASS.
