CLASS zcl_http_confirmmfgord_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_http_confirmmfgord_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        _u_m_e_s_i_d                  TYPE string,
        _plant                        TYPE string,
        _manufacturing_order          TYPE string,
        _manufacturingorderoperation2 TYPE string,
        _confirmation_yield_quantity  TYPE string,
        _confirmation_scrap_quantity  TYPE string,
        _variance_reason_code         TYPE string,
        _op_confirmed_work_quantity1  TYPE string,
        _op_work_quantity_unit1       TYPE string,
        _op_confirmed_work_quantity2  TYPE string,
        _op_work_quantity_unit2       TYPE string,
        _op_confirmed_work_quantity3  TYPE string,
        _op_work_quantity_unit3       TYPE string,
        _op_confirmed_work_quantity4  TYPE string,
        _op_work_quantity_unit4       TYPE string,
        _op_confirmed_work_quantity5  TYPE string,
        _op_work_quantity_unit5       TYPE string,
        _op_confirmed_work_quantity6  TYPE string,
        _op_work_quantity_unit6       TYPE string,
        _posting_date                 TYPE string,
        _confirmation_text            TYPE string,
        _work_center                  TYPE string,
        _creator                      TYPE string,
      END OF ty_req,

      BEGIN OF ty_data,
        _u_m_e_s_i_d                  TYPE string,
        _mfg_order_confirmation_group TYPE string,
        _mfg_order_confirmation       TYPE string,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res,

      BEGIN OF ty_req_api,
        _plant                       TYPE string,
        _order_i_d                   TYPE string,
        _order_operation             TYPE string,
        _confirmation_yield_quantity TYPE string,
        _confirmation_scrap_quantity TYPE string,
        _variance_reason_code        TYPE string,
        _op_confirmed_work_quantity1 TYPE string,
        _op_work_quantity_unit1      TYPE string,
        _op_confirmed_work_quantity2 TYPE string,
        _op_work_quantity_unit2      TYPE string,
        _op_confirmed_work_quantity3 TYPE string,
        _op_work_quantity_unit3      TYPE string,
        _op_confirmed_work_quantity4 TYPE string,
        _op_work_quantity_unit4      TYPE string,
        _op_confirmed_work_quantity5 TYPE string,
        _op_work_quantity_unit5      TYPE string,
        _op_confirmed_work_quantity6 TYPE string,
        _op_work_quantity_unit6      TYPE string,
        _posting_date                TYPE string,
        _confirmation_text           TYPE string,
        _work_center                 TYPE string,
        _sequence                    TYPE string,
        _final_confirmation_type     TYPE string,
        apiconfhasnogoodsmovements   TYPE string,
      END OF ty_req_api,

      BEGIN OF ty_d,
        confirmation_group TYPE string,
        confirmation_count TYPE string,
      END OF ty_d,

      BEGIN OF ty_message,
        value TYPE string,
      END OF ty_message,

      BEGIN OF ty_error,
        message TYPE ty_message,
      END OF ty_error,

      BEGIN OF ty_res_api,
        d     TYPE ty_d,
        error TYPE ty_error,
      END OF ty_res_api.

    DATA:
      lo_root_exc                  TYPE REF TO cx_root,
      lt_ztpp_1004                 TYPE STANDARD TABLE OF ztpp_1004,
      lt_ztpp_1005                 TYPE STANDARD TABLE OF ztpp_1005,
      ls_ztpp_1004                 TYPE ztpp_1004,
      ls_ztpp_1005                 TYPE ztpp_1005,
      ls_req                       TYPE ty_req,
      ls_res                       TYPE ty_res,
      ls_req_api                   TYPE ty_req_api,
      ls_res_api                   TYPE ty_res_api,
      lv_path                      TYPE string,
      lv_monat                     TYPE monat,
      lv_previous_processed        TYPE ztpp_1004-messagetype,
      ls_error                     TYPE zzcl_odata_utils=>gty_error,
      lv_fiscalyearperiod_previous TYPE i_fiscalyearperiodforvariant-fiscalyearperiod,
      lv_period                    TYPE i_fiscalyearperiodforvariant-fiscalperiod,
      lv_date                      TYPE d,
      lv_value                     TYPE string.

    CONSTANTS:
      lc_zid_zpp005       TYPE ztbc_1001-zid VALUE 'ZPP005',
      lc_zid_zpp020       TYPE ztbc_1001-zid VALUE 'ZPP020',
      lc_zid_zpp021       TYPE ztbc_1001-zid VALUE 'ZPP021',
      lc_datfm_5          TYPE xudatfm       VALUE '5',
      lc_fiyearvariant_v3 TYPE string        VALUE 'V3',
      lc_msgid            TYPE string        VALUE 'ZPP_001',
      lc_msgty            TYPE string        VALUE 'E',
      lc_msgty_s          TYPE string        VALUE 'S',
      lc_msgty_w          TYPE string        VALUE 'W',
      lc_stat_code_201    TYPE string        VALUE '201',
      lc_stat_code_500    TYPE string        VALUE '500',
      lc_alpha_in         TYPE string        VALUE 'IN',
      lc_updateflag_i     TYPE string        VALUE 'I',
      lc_updateflag_c     TYPE string        VALUE 'C',
      lc_sequence_0       TYPE string        VALUE '0',
      lc_finalconftype_1  TYPE string        VALUE '1',
      lc_count_10         TYPE i             VALUE '10',
      lc_second_in_ms     TYPE i             VALUE '1000',
      lc_pgmid            TYPE string        VALUE 'ZCL_HTTP_CONFIRMMFGORD_001',
      lc_dd_01            TYPE n LENGTH 2    VALUE '01',
      lc_hour_08          TYPE n LENGTH 2    VALUE '08',
      lc_minute_00        TYPE n LENGTH 2    VALUE '00',
      lc_second_00        TYPE n LENGTH 2    VALUE '00'.

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).
    REPLACE ALL OCCURRENCES OF 'ManufacturingOrderOperation_2' IN lv_req_body WITH 'Manufacturingorderoperation2' .

    "JSON->ABAP
    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = lv_req_body
        pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
      CHANGING
        data             = ls_req ).

    ls_ztpp_1004-umesid                        = ls_req-_u_m_e_s_i_d.
    ls_ztpp_1004-plant                         = ls_req-_plant.
    ls_ztpp_1004-manufacturingorder            = |{ ls_req-_manufacturing_order ALPHA = IN }|.
    ls_ztpp_1004-manufacturingorderoperation_2 = |{ ls_req-_manufacturingorderoperation2 ALPHA = IN }|.
    ls_ztpp_1004-confirmationyieldquantity     = ls_req-_confirmation_yield_quantity.
    ls_ztpp_1004-confirmationscrapquantity     = ls_req-_confirmation_scrap_quantity.
    ls_ztpp_1004-variancereasoncode            = ls_req-_variance_reason_code.
    ls_ztpp_1004-opconfirmedworkquantity1      = ls_req-_op_confirmed_work_quantity1.
    ls_ztpp_1004-opworkquantityunit1           = ls_req-_op_work_quantity_unit1.
    ls_ztpp_1004-opconfirmedworkquantity2      = ls_req-_op_confirmed_work_quantity2.
    ls_ztpp_1004-opworkquantityunit2           = ls_req-_op_work_quantity_unit2.
    ls_ztpp_1004-opconfirmedworkquantity3      = ls_req-_op_confirmed_work_quantity3.
    ls_ztpp_1004-opworkquantityunit3           = ls_req-_op_work_quantity_unit3.
    ls_ztpp_1004-opconfirmedworkquantity4      = ls_req-_op_confirmed_work_quantity4.
    ls_ztpp_1004-opworkquantityunit4           = ls_req-_op_work_quantity_unit4.
    ls_ztpp_1004-opconfirmedworkquantity5      = ls_req-_op_confirmed_work_quantity5.
    ls_ztpp_1004-opworkquantityunit5           = ls_req-_op_work_quantity_unit5.
    ls_ztpp_1004-opconfirmedworkquantity6      = ls_req-_op_confirmed_work_quantity6.
    ls_ztpp_1004-opworkquantityunit6           = ls_req-_op_work_quantity_unit6.
    ls_ztpp_1004-postingdate                   = ls_req-_posting_date.
    ls_ztpp_1004-confirmationtext              = ls_req-_confirmation_text.
    ls_ztpp_1004-workcenter                    = ls_req-_work_center.
    ls_ztpp_1004-creator                       = ls_req-_creator.

    TRY.
*        "Check UMESID of input parameter must be valuable
*        IF ls_ztpp_1004-umesid IS INITIAL.
*          "UMESIDを送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 026 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.

        "Check plant of input parameter must be valuable
        IF ls_ztpp_1004-plant IS INITIAL.
          "プラントを送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 001 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ELSE.
          "Check plant of input parameter must be existent
          SELECT COUNT(*)
            FROM i_plant
           WHERE plant = @ls_ztpp_1004-plant.
          IF sy-subrc <> 0.
            "プラント&1存在しません！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 002 WITH ls_ztpp_1004-plant INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.
        ENDIF.

        "Check manufacturing order of input parameter must be valuable
        IF ls_ztpp_1004-manufacturingorder IS INITIAL.
          "製造指図を送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 015 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Check manufacturing order operation of input parameter must be valuable
        IF ls_ztpp_1004-manufacturingorderoperation_2 IS INITIAL.
          "作業番号を送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 031 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Check posting date of input parameter must be valuable
        IF ls_ztpp_1004-postingdate IS INITIAL.
          "転記日付を送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 045 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Obtain attribute of input parameter fields
        SELECT zvalue2,
               zvalue4
          FROM ztbc_1001
         WHERE zid = @lc_zid_zpp020
           AND zvalue1 = @ls_ztpp_1004-plant
           AND zvalue3 = @abap_true
          INTO TABLE @DATA(lt_ztbc_1001).

        LOOP AT lt_ztbc_1001 INTO DATA(ls_ztbc_1001).
          ASSIGN COMPONENT ls_ztbc_1001-zvalue2 OF STRUCTURE ls_ztpp_1004 TO FIELD-SYMBOL(<fs_value>).
          IF sy-subrc = 0.
            IF <fs_value> IS INITIAL.
              "&1を送信してください
              MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 113 WITH ls_ztbc_1001-zvalue4 INTO ls_res-_msg.
              RAISE EXCEPTION TYPE cx_abap_api_state.
            ENDIF.
          ENDIF.
        ENDLOOP.

*        "Check yield to be confirmed quantity of input parameter must be valuable
*        IF ls_ztpp_1004-confirmationyieldquantity IS INITIAL.
*          "歩留数量を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 032 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check activity 1 currently to be confirmed quantity of input parameter must be valuable
*        IF ls_ztpp_1004-opconfirmedworkquantity1 IS INITIAL.
*          "確認済作業数量 1を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 033 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check unit of measure for the activity 1 to be confirmed of input parameter must be valuable
*        IF ls_ztpp_1004-opworkquantityunit1 IS INITIAL.
*          "確認済作業数量単位 1を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 034 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check activity 2 currently to be confirmed quantity of input parameter must be valuable
*        IF ls_ztpp_1004-opconfirmedworkquantity2 IS INITIAL.
*          "確認済作業数量 2を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 035 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check unit of measure for the activity 2 to be confirmed of input parameter must be valuable
*        IF ls_ztpp_1004-opworkquantityunit2 IS INITIAL.
*          "確認済作業数量単位 2を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 036 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check activity 3 currently to be confirmed quantity of input parameter must be valuable
*        IF ls_ztpp_1004-opconfirmedworkquantity3 IS INITIAL.
*          "確認済作業数量 3を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 037 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check unit of measure for the activity 3 to be confirmed of input parameter must be valuable
*        IF ls_ztpp_1004-opworkquantityunit3 IS INITIAL.
*          "確認済作業数量単位 3を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 038 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check activity 4 currently to be confirmed quantity of input parameter must be valuable
*        IF ls_ztpp_1004-opconfirmedworkquantity4 IS INITIAL.
*          "確認済作業数量 4を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 039 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check unit of measure for the activity 4 to be confirmed of input parameter must be valuable
*        IF ls_ztpp_1004-opworkquantityunit4 IS INITIAL.
*          "確認済作業数量単位 4を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 040 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check activity 5 currently to be confirmed quantity of input parameter must be valuable
*        IF ls_ztpp_1004-opconfirmedworkquantity5 IS INITIAL.
*          "確認済作業数量 5を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 041 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check unit of measure for the activity 5 to be confirmed of input parameter must be valuable
*        IF ls_ztpp_1004-opworkquantityunit5 IS INITIAL.
*          "確認済作業数量単位 5を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 042 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check activity 6 currently to be confirmed quantity of input parameter must be valuable
*        IF ls_ztpp_1004-opconfirmedworkquantity6 IS INITIAL.
*          "確認済作業数量 6を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 043 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check unit of measure for the activity 6 to be confirmed of input parameter must be valuable
*        IF ls_ztpp_1004-opworkquantityunit6 IS INITIAL.
*          "確認済作業数量単位 6を送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 044 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.
*
*        "Check confirmation text of input parameter must be valuable
*        IF ls_ztpp_1004-confirmationtext IS INITIAL.
*          "確認テキストを送信していください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 046 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_api_state.
*        ENDIF.

        "Check manufacturing order and plant of input parameter must be existent
        SELECT COUNT(*)
          FROM i_manufacturingorder WITH PRIVILEGED ACCESS
         WHERE manufacturingorder = @ls_ztpp_1004-manufacturingorder
           AND productionplant = @ls_ztpp_1004-plant.
        IF sy-subrc <> 0.
          "プラント&1製造指図&2存在しません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 007 WITH ls_ztpp_1004-plant ls_ztpp_1004-manufacturingorder INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check manufacturing order operation of input parameter must be existent
        SELECT COUNT(*)
          FROM i_manufacturingorderoperation WITH PRIVILEGED ACCESS
         WHERE manufacturingorder = @ls_ztpp_1004-manufacturingorder
           AND manufacturingorderoperation_2 = @ls_ztpp_1004-manufacturingorderoperation_2.
        IF sy-subrc <> 0.
          "製造指図&1の作業番号&2が存在しません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 047 WITH ls_ztpp_1004-manufacturingorder ls_ztpp_1004-manufacturingorderoperation_2 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

*        "Check fiscal year and period
*        zzcl_common_utils=>get_fiscal_year_period(
*          EXPORTING
*            iv_date   = ls_ztpp_1004-postingdate
*          IMPORTING
*            ev_year   = DATA(lv_fiscal_year)
*            ev_period = DATA(lv_fiscal_period) ).
*
*        lv_monat = lv_fiscal_period+1(2).
*
*        SELECT COUNT(*)
*          FROM i_companycodeperiod WITH PRIVILEGED ACCESS
*         WHERE companycode = @ls_ztpp_1004-plant
*           AND ( ( fiscalmonthcurrentperiod  = @lv_monat AND productcurrentfiscalyear     = @lv_fiscal_year )
*              OR ( fiscalmonthpreviousperiod = @lv_monat AND prodpreviousperiodfiscalyear = @lv_fiscal_year ) ).
*        IF sy-subrc <> 0.
*          "記日付とS4HCの会計期間をチェックしてください！
*          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 109 INTO ls_res-_msg.
*          RAISE EXCEPTION TYPE cx_abap_invalid_value.
*        ENDIF.

        "Obtain data of company code period(previous fiscal year period)
        SELECT SINGLE
               a~fiscalmonthcurrentperiod,
               a~productcurrentfiscalyear,
               a~fiscalmonthpreviousperiod,
               a~prodpreviousperiodfiscalyear
          FROM i_companycodeperiod WITH PRIVILEGED ACCESS AS a
         INNER JOIN i_productvaluationareavh WITH PRIVILEGED ACCESS AS b
            ON b~companycode = a~companycode
         WHERE b~valuationarea = @ls_ztpp_1004-plant
          INTO @DATA(ls_companycodeperiod).
        IF sy-subrc = 0.
          lv_period = ls_companycodeperiod-fiscalmonthpreviousperiod.
          lv_fiscalyearperiod_previous = ls_companycodeperiod-prodpreviousperiodfiscalyear && lv_period.

          "Obtain data of fiscal year period for fiscal year variant(previous fiscal year period)
          SELECT SINGLE
                 fiscalyearperiod,
                 fiscalperiodstartdate,
                 fiscalperiodenddate
            FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
           WHERE fiscalyearvariant = @lc_fiyearvariant_v3
             AND fiscalyearperiod = @lv_fiscalyearperiod_previous
            INTO @DATA(ls_fiscalyearperiodforvariant).

          IF ls_ztpp_1004-postingdate < ls_fiscalyearperiodforvariant-fiscalperiodstartdate.
            "当月＆前月の転記日付しか処理できません！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 114 INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ENDIF.

          IF  ls_ztpp_1004-postingdate >= ls_fiscalyearperiodforvariant-fiscalperiodstartdate
          AND ls_ztpp_1004-postingdate <= ls_fiscalyearperiodforvariant-fiscalperiodenddate.
            "Obtain data of time zone of plant
            SELECT SINGLE
                   zvalue4
              FROM ztbc_1001
             WHERE zid = @lc_zid_zpp005
               AND zvalue1 = @ls_ztpp_1004-plant
              INTO @DATA(lv_zonlo).

            GET TIME STAMP FIELD DATA(lv_timestampl).

            "Convert date and time from zero zone to time zone of plant
            CONVERT TIME STAMP lv_timestampl
                    TIME ZONE lv_zonlo
                    INTO DATE DATA(lv_system_date)
                         TIME DATA(lv_system_time).

            lv_date = lv_system_date+0(6) && lc_dd_01.

            "Obtain attribute of input parameter fields
            SELECT SINGLE
                   zvalue2
              FROM ztbc_1001
             WHERE zid = @lc_zid_zpp021
               AND zvalue1 = @ls_ztpp_1004-plant
              INTO @DATA(lv_workday_no).

            "カスタマテーブル設定しない＆value2=空欄場合に、チェック対象外になる
            IF lv_workday_no IS NOT INITIAL.
              DATA(lv_number_of_workingdays) = CONV int4( lv_workday_no ).

              IF lv_number_of_workingdays > 0.
                IF zzcl_common_utils=>is_workingday( iv_plant = ls_ztpp_1004-plant iv_date = lv_date ) = abap_true.
                  lv_number_of_workingdays = lv_number_of_workingdays - 1.
                ENDIF.

                "Get specific working day of current month
                DO lv_number_of_workingdays TIMES.
                  "Get working day
                  zzcl_common_utils=>get_workingday(
                    EXPORTING
                      iv_date       = lv_date
                      iv_next       = abap_true
                      iv_plant      = ls_ztpp_1004-plant
                    RECEIVING
                      rv_workingday = lv_date
                  ).
                ENDDO.

                IF lv_system_date > lv_date.
                  TRY.
                      cl_abap_datfm=>conv_date_int_to_ext(
                        EXPORTING im_datint    = lv_date
                                  im_datfmdes  = lc_datfm_5
                        IMPORTING ex_datext    = lv_value ).
                    CATCH cx_abap_datfm_format_unknown.
                      lv_value = lv_date.
                  ENDTRY.

                  "前月の業務処理締め日は &1 です！
                  MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 115 WITH lv_value INTO ls_res-_msg.
                  RAISE EXCEPTION TYPE cx_abap_invalid_value.
                ENDIF.
              ELSEIF lv_number_of_workingdays = 0.
                "前月へ転記できません！
                MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 116 INTO ls_res-_msg.
                RAISE EXCEPTION TYPE cx_abap_invalid_value.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        "Check previous processed
        SELECT umesid,
               plant,
               pgmid,
               creationdate,
               mfgorderconfirmationgroup,
               mfgorderconfirmation,
               updateflag
          FROM ztpp_1004
         WHERE umesid      = @ls_ztpp_1004-umesid
           AND updateflag  = @lc_updateflag_i      "登録
           AND messagetype = @lc_msgty_s
         ORDER BY creationdate DESCENDING
          INTO TABLE @DATA(lt_ztpp_1004_i).

        SELECT umesid,
               plant,
               pgmid,
               creationdate,
               mfgorderconfirmationgroup,
               mfgorderconfirmation,
               updateflag
          FROM ztpp_1004
         WHERE umesid      = @ls_ztpp_1004-umesid
           AND updateflag  = @lc_updateflag_c      "取り消し
           AND messagetype = @lc_msgty_s
         ORDER BY creationdate DESCENDING
          INTO TABLE @DATA(lt_ztpp_1004_c).

        IF lines( lt_ztpp_1004_i ) - lines( lt_ztpp_1004_c ) = 1.
          lv_previous_processed = lc_msgty_w.
        ELSE.
          CLEAR lv_previous_processed.
        ENDIF.

        ls_res-_data-_u_m_e_s_i_d = ls_ztpp_1004-umesid.

        IF lv_previous_processed = lc_msgty_w.
          READ TABLE lt_ztpp_1004_i INTO DATA(ls_ztpp_1004_i) INDEX 1.
          ls_res-_data-_mfg_order_confirmation_group = |{ ls_ztpp_1004_i-mfgorderconfirmationgroup ALPHA = OUT }|.
          ls_res-_data-_mfg_order_confirmation       = |{ ls_ztpp_1004_i-mfgorderconfirmation ALPHA = OUT }|.
          CONDENSE ls_res-_data-_mfg_order_confirmation_group NO-GAPS.
          CONDENSE ls_res-_data-_mfg_order_confirmation NO-GAPS.
          "該当データは前回処理済みです！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 110 INTO ls_res-_msg.
          ls_res-_msgty = lv_previous_processed.
        ELSE.
          "/API_PROD_ORDER_CONFIRMATION_2_SRV/ProdnOrdConf2
          lv_path = '/API_PROD_ORDER_CONFIRMATION_2_SRV/ProdnOrdConf2'.

          MOVE-CORRESPONDING ls_req TO ls_req_api.
          DATA(lv_timestamp) = xco_cp_time=>moment( iv_year   = CONV #( ls_req-_posting_date+0(4) )
                                                    iv_month  = CONV #( ls_req-_posting_date+4(2) )
                                                    iv_day    = CONV #( ls_req-_posting_date+6(2) )
                                                    iv_hour   = lc_hour_08
                                                    iv_minute = lc_minute_00
                                                    iv_second = lc_second_00
                                                  )->get_unix_timestamp( )->value * lc_second_in_ms.

          ls_req_api-_posting_date              = |/Date({ lv_timestamp })/|.
          ls_req_api-_order_i_d                 = ls_req-_manufacturing_order.
          ls_req_api-_order_operation           = ls_req-_manufacturingorderoperation2.
          ls_req_api-apiconfhasnogoodsmovements = abap_false.
          ls_req_api-_sequence                  = lc_sequence_0.
          ls_req_api-_final_confirmation_type   = lc_finalconftype_1.

          DATA(lv_reqbody_api) = /ui2/cl_json=>serialize( data = ls_req_api
                                                          compress = 'X'
                                                          pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

          REPLACE ALL OCCURRENCES OF 'apiconfhasnogoodsmovements' IN lv_reqbody_api WITH 'APIConfHasNoGoodsMovements'.

          "Call API of canceling manufacturing order confirmation
          zzcl_common_utils=>request_api_v2(
            EXPORTING
              iv_path        = lv_path
              iv_method      = if_web_http_client=>post
              iv_body        = lv_reqbody_api
            IMPORTING
              ev_status_code = DATA(lv_stat_code)
              ev_response    = DATA(lv_resbody_api) ).

          "Could not fetch SCRF token
          IF lv_stat_code = lc_stat_code_500.
            ls_res-_msg = lv_resbody_api.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.

          IF lv_stat_code = lc_stat_code_201.
            "JSON->ABAP
            xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
                ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_res_api ) ).
            ls_res-_data-_mfg_order_confirmation_group = |{ ls_res_api-d-confirmation_group ALPHA = OUT }|.
            ls_res-_data-_mfg_order_confirmation       = |{ ls_res_api-d-confirmation_count ALPHA = OUT }|.
            CONDENSE ls_res-_data-_mfg_order_confirmation_group.
            CONDENSE ls_res-_data-_mfg_order_confirmation.
            "作業実績確認は成功しました！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 048 INTO ls_res-_msg.
            ls_res-_msgty = 'S'.
          ELSE.
            "作業実績確認が失敗しました：
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 049 INTO ls_res-_msg.
            /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api
                                       CHANGING  data = ls_error ).
            "ls_res-_msg = ls_res-_msg && ls_res_api-error-message-value.
            ls_res-_msg = ls_res-_msg && ls_error-error-message-value.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.
        ENDIF.

      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    "ABAP->JSON
    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    IF ls_ztpp_1004-umesid IS NOT INITIAL.
      ls_ztpp_1004-pgmid                     = lc_pgmid.
      ls_ztpp_1004-mfgorderconfirmationgroup = ls_res_api-d-confirmation_group.
      ls_ztpp_1004-mfgorderconfirmation      = ls_res_api-d-confirmation_count.
      ls_ztpp_1004-workcenter                = |{ ls_ztpp_1004-workcenter ALPHA = IN }|.
      ls_ztpp_1004-updateflag                = lc_updateflag_i.
      ls_ztpp_1004-messagetype               = ls_res-_msgty.

      IF lv_previous_processed = lc_msgty_w.
        ls_ztpp_1004-mfgorderconfirmationgroup = ls_ztpp_1004_i-mfgorderconfirmationgroup.
        ls_ztpp_1004-mfgorderconfirmation      = ls_ztpp_1004_i-mfgorderconfirmation.
      ENDIF.

      TRY.
          ls_ztpp_1004-opworkquantityunit1 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_ztpp_1004-opworkquantityunit1 ).
          ls_ztpp_1004-opworkquantityunit2 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_ztpp_1004-opworkquantityunit2 ).
          ls_ztpp_1004-opworkquantityunit3 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_ztpp_1004-opworkquantityunit3 ).
          ls_ztpp_1004-opworkquantityunit4 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_ztpp_1004-opworkquantityunit4 ).
          ls_ztpp_1004-opworkquantityunit5 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_ztpp_1004-opworkquantityunit5 ).
          ls_ztpp_1004-opworkquantityunit6 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_ztpp_1004-opworkquantityunit6 ).
        CATCH zzcx_custom_exception INTO lo_root_exc ##NO_HANDLER.
      ENDTRY.

      GET TIME STAMP FIELD ls_ztpp_1004-creationdate.
      APPEND ls_ztpp_1004 TO lt_ztpp_1004.

      MOVE-CORRESPONDING ls_ztpp_1004 TO ls_ztpp_1005.
      ls_ztpp_1005-msgitemno = lc_count_10.
      ls_ztpp_1005-message   = ls_res-_msg.
      APPEND ls_ztpp_1005 TO lt_ztpp_1005.

      "Modify database of log
      MODIFY ztpp_1004 FROM TABLE @lt_ztpp_1004.
      MODIFY ztpp_1005 FROM TABLE @lt_ztpp_1005.
    ENDIF.

    "Set request data
    response->set_text( lv_res_body ).

  ENDMETHOD.
ENDCLASS.
