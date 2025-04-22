CLASS zcl_ofpartition DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:BEGIN OF ty_date_range,
            startdate TYPE datum,
            enddate   TYPE datum,
          END OF ty_date_range.
    INTERFACES if_rap_query_provider .
    METHODS:
      get_splitqty IMPORTING x          TYPE i "一个月内要分配的日期数量
                             y          TYPE menge_d "可分配的总数量
                             z          TYPE i "分割的最小单位数量
                             n          TYPE i "一个月内的第几个要分配的日期
                   RETURNING VALUE(qty) TYPE menge_d."对应日期分配到的数量
    CLASS-METHODS:
      get_process_date_range
        RETURNING VALUE(date_range) TYPE ty_date_range.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_OFPARTITION IMPLEMENTATION.


  METHOD get_process_date_range.
    "获取要处理的PIR数据范围
    "从执行当月初起往后24个月月末
    date_range-startdate = cl_abap_context_info=>get_system_date( ).
    date_range-startdate = date_range-startdate(6) && '01'.
    date_range-enddate = zzcl_common_utils=>calc_date_add( date = date_range-startdate month = 24 ).
    date_range-enddate = zzcl_common_utils=>get_enddate_of_month( iv_date = date_range-enddate ).
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
                 validend(6)   TYPE c,
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

*&--ADD BEGIN BY XINLEI XU 2025/02/27
        TYPES: BEGIN OF ty_ofpartition,
                 _customer                 TYPE kunnr,
                 _plant                    TYPE werks_d,
                 _material                 TYPE matnr,
                 _requirement_date         TYPE datum,
                 _material_by_customer(35) TYPE c,
                 _material_name            TYPE maktx,
                 _requirement_qty          TYPE menge_d,
                 _unit                     TYPE meins,
               END OF ty_ofpartition.

        DATA: lt_response       TYPE TABLE OF zce_ofpartition,
              lt_split_of_group TYPE TABLE OF ty_ofpartition.
*&--ADD END BY XINLEI XU 2025/02/27

        DATA: lt_split_of TYPE TABLE OF ty_ofpartition, " zce_ofpartition,
              ls_split_of TYPE ty_ofpartition. " zce_ofpartition.
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
*&--ADD BEGIN BY XINLEI XU 2025/02/18
            WHEN 'MATERIALBYCUSTOMER'.
              DATA(r_materialbycustomer) = ls_ranges-range.
*&--ADD END BY XINLEI XU 2025/02/18
            WHEN 'PLANT'.
              DATA(r_plant) = ls_ranges-range.
            WHEN 'MATERIAL'.
              DATA(r_material) = ls_ranges-range.
            WHEN 'SPLITRANGE'.
              DATA(r_splitrange) = ls_ranges-range.
          ENDCASE.
        ENDLOOP.

*        DATA(lt_parameters) = io_request->get_parameters( ).

        "获取要取值的范围, 执行当月初，到24个月后的月末
        DATA(lv_date_range) = get_process_date_range( ).
        DATA(lv_startdate) = lv_date_range-startdate.
        DATA(lv_enddate) = lv_date_range-enddate.
        "获取OF数据
        SELECT
          _of~customer,
          _of~plant,
          _of~material,
          _of~requirementdate,
          substring( _of~requirementdate, 1, 6 ) AS requirementmonth,
          _of~requirementqty,
          _of~unitofmeasure,
          _of~createdat
        FROM zc_orderforecast AS _of
        "begin add by zoukun at 20250305
        LEFT JOIN ztbc_1001 AS _config
          ON _config~zid = 'ZPP013'
          AND _config~zvalue1 = _of~plant
        LEFT JOIN i_customermaterial_2 WITH PRIVILEGED ACCESS AS _custmat
          ON _custmat~salesorganization = _config~zvalue2
          AND _custmat~product = _of~material
          AND _custmat~customer = _of~customer
        "end add by zoukun at 20250305
        WHERE _of~customer IN @r_customer
          AND _of~plant IN @r_plant
          AND _of~material IN @r_material
          AND _custmat~materialbycustomer IN @r_materialbycustomer
          AND _of~requirementdate >= @lv_startdate
          AND _of~requirementdate <= @lv_enddate
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
          root~customer,
          root~plant,
          root~splitmaterial AS material,
          root~splitunit,
          root~shipunit,
          root~validend
        FROM zc_ofsplitrule AS root
        "begin add by zoukun at 20250305
        LEFT JOIN ztbc_1001 AS _config
          ON _config~zid = 'ZPP013'
          AND _config~zvalue1 = root~plant
        LEFT JOIN i_customermaterial_2 WITH PRIVILEGED ACCESS AS _custmat
          ON _custmat~salesorganization = _config~zvalue2
          AND _custmat~product = root~splitmaterial
          AND _custmat~customer = root~customer
        "end add by zoukun at 20250305
        WHERE root~customer IN @r_customer
          AND root~plant IN @r_plant
          AND root~splitmaterial IN @r_material
          AND _custmat~materialbycustomer IN @r_materialbycustomer
          AND root~deleteflag  = ''
          AND root~validend >= @current_month
        INTO TABLE @DATA(lt_ofsplitrule).
        "一个维度在不同的有效期内 可能会有不同的分割方式
        "且后续需要有效期升序排序，比如一条2025/01按月分割，一条9999/12按周分割， 那么需要2025年一月以前的数据按月分割，之后的数据按周分割
        SORT lt_ofsplitrule BY customer plant material validend.
        DELETE ADJACENT DUPLICATES FROM lt_ofsplitrule COMPARING customer plant material validend.

        SORT lt_orderforecast BY customer plant material requirementdate createdat DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_orderforecast COMPARING customer plant material requirementdate.

        "通过createdat字段 只保留最新一批数据
        DATA(lt_of_key) = lt_orderforecast.
        SORT lt_of_key BY customer plant material createdat DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_of_key COMPARING customer plant material.
        SORT lt_of_key BY customer plant material createdat.

        LOOP AT lt_orderforecast INTO DATA(ls_temp).
          READ TABLE lt_of_key TRANSPORTING NO FIELDS WITH KEY customer = ls_temp-customer
            plant = ls_temp-plant material = ls_temp-material createdat = ls_temp-createdat BINARY SEARCH.
          IF sy-subrc <> 0.
            DELETE lt_orderforecast.
            CONTINUE.
          ENDIF.
        ENDLOOP.

        "获取前端传入的分割范围
*        READ TABLE lt_parameters INTO DATA(ls_parameters) WITH KEY parameter_name = 'SPLITRANGE'.
        READ TABLE r_splitrange INTO DATA(rs_splitrange) INDEX 1.
        IF sy-subrc = 0.
          SPLIT rs_splitrange-low AT '-' INTO DATA(lv_splitstart) DATA(lv_splitend).
        ENDIF.
        " 由于最初程序设计的分割范围必输，所以程序逻辑都是以必输来考虑的，
        " 现在分割范围可能没有值，但逻辑不好改动,所以将分割范围设置为数据开始范围的前一个月
        IF lv_splitstart IS INITIAL.
          lv_splitstart = zzcl_common_utils=>calc_date_subtract( date = lv_startdate month = 1 ).
          lv_splitstart = lv_splitstart(6).
        ENDIF.
        IF lv_splitend IS INITIAL.
          lv_splitend = lv_splitstart.
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
        DATA lv_validend(7) TYPE c.
        DATA lv_splitdate TYPE datum.
        "分割起始日期
        DATA(lv_splitstartdate) = CONV datum( lv_splitstart && '01' ).
        "分割结束日期
        DATA(lv_splitenddate) = zzcl_common_utils=>get_enddate_of_month( lv_splitend && '01' ).

        "获取非工作日
        SELECT *
          FROM ztpp_1018
          INTO TABLE @DATA(lt_factorycalendar).         "#EC CI_NOWHERE
        SORT lt_factorycalendar BY plant holiday_date.
        "确定分割范围内哪些日期需要分配数量
        LOOP AT lt_ofsplitrule INTO DATA(ls_ofsplitrule).
          lv_validend = ls_ofsplitrule-validend.
          REPLACE FIRST OCCURRENCE OF '/' IN lv_validend WITH ''.
          CASE ls_ofsplitrule-splitunit.
            WHEN 'M'."按月分割
              WHILE 1 = 1.
                lv_index = sy-index - 1.
                MOVE-CORRESPONDING ls_ofsplitrule TO ls_split_date.
                ls_split_date-validend = lv_validend.
                ls_split_date-splitdate = zzcl_common_utils=>calc_date_add( date = lv_splitstart && '01' month = lv_index ).
                "如果当前日期非工作日则需要向后延，找到下一个工作日
*                ls_split_date-splitdate = zzcl_common_utils=>get_workingday( iv_date = ls_split_date-splitdate iv_plant = ls_ofsplitrule-plant ).
                lv_splitdate = ls_split_date-splitdate.
                READ TABLE lt_factorycalendar INTO DATA(ls_factorycalendar) WITH KEY plant = ls_ofsplitrule-plant
                  holiday_date = lv_splitdate BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_split_date-splitdate = ls_factorycalendar-next_workday.
                ELSE.
                  ls_split_date-splitdate = lv_splitdate.
                ENDIF.
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
                ls_split_date-validend = lv_validend.
                ls_split_date-splitdate = zzcl_common_utils=>calc_date_add( date = lv_splitstart && '01' month = lv_index ).

                "上旬
*                ls_split_date-splitdate = zzcl_common_utils=>get_workingday( iv_date = ls_split_date-splitdate(6) && '01' iv_plant = ls_ofsplitrule-plant ).
                lv_splitdate = ls_split_date-splitdate(6) && '01'.
                READ TABLE lt_factorycalendar INTO ls_factorycalendar WITH KEY plant = ls_ofsplitrule-plant
                  holiday_date = lv_splitdate BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_split_date-splitdate = ls_factorycalendar-next_workday.
                ELSE.
                  ls_split_date-splitdate = lv_splitdate.
                ENDIF.
                "如果日期已经超过了要分割的区间则不用处理
                IF ( ls_split_date-splitdate > lv_splitenddate ).
                  EXIT.
                ENDIF.
                ls_split_date-splitmonth = ls_split_date-splitdate(6).
                ls_split_date-dateindex = 1."按旬分割每月有3个日期
                APPEND ls_split_date TO lt_split_date.
                "中旬
*                ls_split_date-splitdate = zzcl_common_utils=>get_workingday( iv_date = ls_split_date-splitdate(6) && '11' iv_plant = ls_ofsplitrule-plant ).
                lv_splitdate = ls_split_date-splitdate(6) && '11'.
                READ TABLE lt_factorycalendar INTO ls_factorycalendar WITH KEY plant = ls_ofsplitrule-plant
                  holiday_date = lv_splitdate BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_split_date-splitdate = ls_factorycalendar-next_workday.
                ELSE.
                  ls_split_date-splitdate = lv_splitdate.
                ENDIF.
                "如果日期已经超过了要分割的区间则不用处理
                IF ( ls_split_date-splitdate > lv_splitenddate ).
                  EXIT.
                ENDIF.
                ls_split_date-splitmonth = ls_split_date-splitdate(6).
                ls_split_date-dateindex = 2."按旬分割每月有3个日期
                APPEND ls_split_date TO lt_split_date.
                "下旬
*                ls_split_date-splitdate = zzcl_common_utils=>get_workingday( iv_date = ls_split_date-splitdate(6) && '21' iv_plant = ls_ofsplitrule-plant ).
                lv_splitdate = ls_split_date-splitdate(6) && '21'.
                READ TABLE lt_factorycalendar INTO ls_factorycalendar WITH KEY plant = ls_ofsplitrule-plant
                  holiday_date = lv_splitdate BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_split_date-splitdate = ls_factorycalendar-next_workday.
                ELSE.
                  ls_split_date-splitdate = lv_splitdate.
                ENDIF.
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
              ls_split_date-validend = lv_validend.
              TRY.
                  " 获取当前周数
                  cl_scal_utils=>date_get_week(
                    EXPORTING
                      iv_date = lv_splitstartdate
                    IMPORTING
                      ev_year = DATA(lv_year)
                      ev_week = DATA(lv_week) ).
                  "获取当前周的第一个工作日
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
                lv_monday = zzcl_common_utils=>get_workingday( iv_date = lv_monday iv_plant = ls_ofsplitrule-plant ).
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
              ls_split_date-validend = lv_validend.
              CLEAR the_last_month.
              WHILE 1 = 1.
                IF sy-index > 1.
                  lv_work_day = lv_work_day + 1.
                ENDIF.
*                lv_work_day = zzcl_common_utils=>get_workingday( iv_date = lv_work_day iv_plant = ls_ofsplitrule-plant ).
*                ls_split_date-splitdate = lv_work_day.
                lv_splitdate = lv_work_day.
                READ TABLE lt_factorycalendar INTO ls_factorycalendar WITH KEY plant = ls_ofsplitrule-plant
                  holiday_date = lv_splitdate BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_split_date-splitdate = ls_factorycalendar-next_workday.
                ELSE.
                  ls_split_date-splitdate = lv_splitdate.
                ENDIF.
                lv_work_day = ls_split_date-splitdate.
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
        "1.先删除掉分割日期超过有效期的数据
        LOOP AT lt_split_date INTO ls_split_date.
          IF ls_split_date-splitmonth > ls_split_date-validend.
            DELETE lt_split_date.
            CONTINUE.
          ENDIF.
        ENDLOOP.
        "2.保留同一个期间内有效期最早的分割类型
        DATA(lt_split_date_temp) = lt_split_date.
        SORT lt_split_date_temp BY customer plant material splitmonth validend.
        DELETE ADJACENT DUPLICATES FROM lt_split_date_temp COMPARING customer plant material splitmonth.
        "3.删除同一个期间内不是最早有效期的分割类型数据
        LOOP AT lt_split_date_temp INTO DATA(ls_split_date_temp).
          DELETE lt_split_date WHERE customer = ls_split_date_temp-customer AND plant = ls_split_date_temp-plant AND
            material = ls_split_date_temp-material AND splitmonth = ls_split_date_temp-splitmonth AND splitunit <> ls_split_date_temp-splitunit.
        ENDLOOP..

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
        SORT lt_of_key BY customer plant material.
        SORT lt_split_date BY customer plant material splitdate.
        SORT lt_split_coll BY customer plant material requirementmonth.

        "确定OF分割后的数量
        LOOP AT lt_of_key INTO DATA(ls_of_key).
*&--MOD BEGIN BY XINLEI XU 2025/02/27
*          ls_split_of-_customer = ls_of_key-customer.
          ls_split_of-_customer = |{ ls_of_key-customer ALPHA = OUT }|.
*&--MOD END BY XINLEI XU 2025/02/27
          ls_split_of-_plant = ls_of_key-plant.
          ls_split_of-_material = ls_of_key-material.
          READ TABLE lt_additional INTO DATA(ls_additional) WITH KEY customer = ls_of_key-customer
            plant = ls_of_key-plant material = ls_of_key-material BINARY SEARCH.
          IF sy-subrc = 0.
            ls_split_of-_material_by_customer = ls_additional-materialbycustomer.
            ls_split_of-_material_name = ls_additional-productname.
          ENDIF.

*&--ADD BEGIN BY XINLEI XU 2025/02/18
          IF ls_split_of-_material_by_customer NOT IN r_materialbycustomer.
            CONTINUE.
          ENDIF.
*&--ADD END BY XINLEI XU 2025/02/18

          READ TABLE lt_split_date INTO ls_split_date WITH KEY customer = ls_of_key-customer
            plant = ls_of_key-plant material = ls_of_key-material BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(temp_date) = lv_date_range-startdate.
            WHILE temp_date <= lv_date_range-enddate.
              ls_split_of-_requirement_date = temp_date.
              "如果是分割范围内的日期，数量需要重新分配
              IF temp_date >= lv_splitstartdate AND temp_date <= lv_splitenddate.
                READ TABLE lt_split_date INTO ls_split_date WITH KEY customer = ls_of_key-customer
                  plant = ls_of_key-plant material = ls_of_key-material splitdate = temp_date BINARY SEARCH.
                IF sy-subrc = 0.
                  READ TABLE lt_split_coll INTO ls_split_coll WITH KEY customer = ls_of_key-customer
                    plant = ls_of_key-plant material = ls_of_key-material requirementmonth = ls_split_date-splitmonth BINARY SEARCH.
                  IF sy-subrc = 0.
                    ls_split_of-_requirement_qty = get_splitqty(  x = ls_split_date-datecount
                                                                  y = ls_split_coll-requirementqty
                                                                  z = ls_split_date-shipunit
                                                                  n = ls_split_date-dateindex ).
                  ELSE.
                    ls_split_of-_requirement_qty = 0.
                  ENDIF.
                ENDIF.
                "如果是分割范围外的日期，数量直接取原来的
              ELSE.
                READ TABLE lt_orderforecast INTO ls_orderforecast WITH KEY customer = ls_of_key-customer
                  plant = ls_of_key-plant material = ls_of_key-material requirementdate = temp_date BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_split_of-_requirement_qty = ls_orderforecast-requirementqty.
                ENDIF.
              ENDIF.
              APPEND ls_split_of TO lt_split_of.
              CLEAR ls_split_of-_requirement_qty.
              temp_date = temp_date + 1.
            ENDWHILE.
            "如果没有分割范围数据，可能是此条数据没有分割主数据，但仍要显示原数据
          ELSE.
            temp_date = lv_date_range-startdate.
            WHILE temp_date <= lv_date_range-enddate.
              ls_split_of-_requirement_date = temp_date.
              READ TABLE lt_orderforecast INTO ls_orderforecast WITH KEY customer = ls_of_key-customer
                plant = ls_of_key-plant material = ls_of_key-material requirementdate = temp_date BINARY SEARCH.
              IF sy-subrc = 0.
                ls_split_of-_requirement_qty = ls_orderforecast-requirementqty.
              ENDIF.
              APPEND ls_split_of TO lt_split_of.
              CLEAR ls_split_of-_requirement_qty.
              temp_date = temp_date + 1.
            ENDWHILE.
*            LOOP AT lt_orderforecast INTO ls_orderforecast WHERE customer = ls_of_key-customer AND
*              plant = ls_of_key-plant AND material = ls_of_key-material.
*              ls_split_of-requirementdate = ls_orderforecast-requirementdate.
*              ls_split_of-requirementqty = ls_orderforecast-requirementqty.
*              APPEND ls_split_of TO lt_split_of.
*            ENDLOOP.
            CLEAR ls_split_of.
          ENDIF.
        ENDLOOP.

        " 处理数据时 lt_of_key 已经排序，所以这里的排序可以省略
*        sort lt_split_of by customer plant material requirementdate.

*&--MOD BEGIN BY XINLEI XU 2025/02/27 性能优化
*        IF io_request->is_total_numb_of_rec_requested( ).
*          io_response->set_total_number_of_records( lines( lt_split_of ) ).
*        ENDIF.
*        IF io_request->is_data_requested( ).
*          zzcl_odata_utils=>paging(
*            EXPORTING
*              io_paging = io_request->get_paging( )
*            CHANGING
*              ct_data = lt_split_of
*          ).
*          io_response->set_data( lt_split_of ).
*        ENDIF.

        DATA lv_times TYPE p.
        DATA lv_index_begin TYPE int4.
        DATA lv_index_end TYPE int4.

        DATA(lv_count) = lines( lt_split_of ).
        lv_times = ceil( lv_count / 20000 ).

        IF io_request->is_data_requested( ).
          CLEAR: lv_index_begin, lv_index_end.
          DO lv_times TIMES.
            lv_index_begin += 1.
            lv_index_end = sy-index * 20000.
            IF lv_index_end >= lv_count.
              lv_index_end = lv_count.
            ENDIF.
            CLEAR lt_split_of_group.
            APPEND LINES OF lt_split_of FROM lv_index_begin TO lv_index_end TO lt_split_of_group.

            APPEND INITIAL LINE TO lt_response ASSIGNING FIELD-SYMBOL(<lfs_response>).
            TRY.
                <lfs_response>-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
                ##NO_HANDLER
              CATCH cx_uuid_error.
                " handle exception
            ENDTRY.
            <lfs_response>-datajson = /ui2/cl_json=>serialize( data = lt_split_of_group
                                                              pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

            lv_index_begin = lv_index_end.
          ENDDO.

          IF io_request->is_total_numb_of_rec_requested(  ) .
            io_response->set_total_number_of_records( lines( lt_response ) ).
          ENDIF.

          " Paging
          zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                    CHANGING  ct_data   = lt_response ).

          io_response->set_data( lt_response ).
        ELSE.
          IF io_request->is_total_numb_of_rec_requested(  ) .
            io_response->set_total_number_of_records( CONV #( lv_times ) ).
          ENDIF.
        ENDIF.
*&--MOD END BY XINLEI XU 2025/02/27
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
