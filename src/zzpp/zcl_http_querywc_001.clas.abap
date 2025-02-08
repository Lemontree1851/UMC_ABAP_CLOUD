CLASS zcl_http_querywc_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_http_querywc_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        plant       TYPE string,
        work_center TYPE string,
      END OF ty_req,

      BEGIN OF ty_workcenter,
        _plant            TYPE i_workcenter-plant,
        _work_center      TYPE i_workcenter-workcenter,
        _work_center_text TYPE i_workcentertext-workcentertext,
        _cost_center      TYPE i_workcentercostcenter-costcenter,
        _sent_time_stamp  TYPE string,
      END OF ty_workcenter,
      tt_workcenter TYPE STANDARD TABLE OF ty_workcenter WITH DEFAULT KEY,

      BEGIN OF ty_data,
        _work_center TYPE tt_workcenter,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res.

    DATA:
      lt_ztpp_1001  TYPE STANDARD TABLE OF ztpp_1001,
      lo_root_exc   TYPE REF TO cx_root,
      ls_ztpp_1001  TYPE ztpp_1001,
      ls_req        TYPE ty_req,
      ls_res        TYPE ty_res,
      ls_workcenter TYPE ty_workcenter,
      lv_plant      TYPE i_workcenter-plant,
      lv_workcenter TYPE i_workcenter-workcenter,
      lv_timestamp  TYPE timestamp,
      lv_date       TYPE d,
      lv_time       TYPE t.

    CONSTANTS:
      lc_zid_zpp005 TYPE ztbc_1001-zid VALUE 'ZPP005',
      lc_msgid      TYPE string        VALUE 'ZPP_001',
      lc_msgty      TYPE string        VALUE 'E',
      lc_month_3    TYPE i             VALUE '3'.

    GET TIME STAMP FIELD DATA(lv_timestamp_start).

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).

    lv_plant = ls_req-plant.
    lv_workcenter = ls_req-work_center.

    TRY.
        "Check plant of input parameter must be valuable
        IF lv_plant IS INITIAL.
          "プラントを送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 001 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Check plant of input parameter must be existent
        SELECT COUNT(*)
          FROM i_plant
         WHERE plant = @lv_plant.
        IF sy-subrc <> 0.
          "プラント&1存在しません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 002 WITH lv_plant INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Obtain language and time zone of plant
        SELECT SINGLE
               zvalue2 AS language,
               zvalue3 AS zonlo_in,
               zvalue4 AS zonlo_out
          FROM ztbc_1001
         WHERE zid = @lc_zid_zpp005
           AND zvalue1 = @lv_plant
          INTO @DATA(ls_ztbc_1001).

        IF lv_workcenter IS NOT INITIAL.
          "Check work center of input parameter must be existent
          SELECT COUNT(*)
            FROM i_workcenter WITH PRIVILEGED ACCESS
           WHERE workcenter = @lv_workcenter.
          IF sy-subrc <> 0.
            "作業区&1存在しません！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 003 WITH lv_workcenter INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.

          "Obtain data of work center
          SELECT DISTINCT
                 i_workcenter~plant,
                 i_workcenter~workcenter,
                 i_workcentertext~workcentertext,
                 i_workcentercostcenter~costcenter
            FROM i_workcenter WITH PRIVILEGED ACCESS
            LEFT OUTER JOIN i_workcentertext WITH PRIVILEGED ACCESS
              ON i_workcentertext~workcentertypecode = i_workcenter~workcentertypecode
             AND i_workcentertext~workcenterinternalid = i_workcenter~workcenterinternalid
             AND i_workcentertext~language = @sy-langu"ls_ztbc_1001-language
            LEFT OUTER JOIN i_workcentercostcenter WITH PRIVILEGED ACCESS
              ON i_workcentercostcenter~workcenterinternalid = i_workcenter~workcenterinternalid
             AND i_workcentercostcenter~workcentertypecode = i_workcenter~workcentertypecode
           WHERE i_workcenter~plant = @lv_plant
             AND i_workcenter~workcenter = @lv_workcenter
            INTO TABLE @DATA(lt_workcenter).
          IF sy-subrc <> 0.
            "プラント&1作業区&2存在しません！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 004 WITH lv_plant lv_workcenter INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.
        ELSE.
          "Obtain data of work center
          SELECT DISTINCT
                 i_workcenter~plant,
                 i_workcenter~workcenter,
                 i_workcentertext~workcentertext,
                 i_workcentercostcenter~costcenter
            FROM i_workcenter WITH PRIVILEGED ACCESS
            LEFT OUTER JOIN i_workcentertext WITH PRIVILEGED ACCESS
              ON i_workcentertext~workcentertypecode = i_workcenter~workcentertypecode
             AND i_workcentertext~workcenterinternalid = i_workcenter~workcenterinternalid
             AND i_workcentertext~language = @sy-langu"ls_ztbc_1001-language
            LEFT OUTER JOIN i_workcentercostcenter WITH PRIVILEGED ACCESS
              ON i_workcentercostcenter~workcenterinternalid = i_workcenter~workcenterinternalid
             AND i_workcentercostcenter~workcentertypecode = i_workcenter~workcentertypecode
           WHERE i_workcenter~plant = @lv_plant
            INTO TABLE @lt_workcenter.
        ENDIF.

        DATA(lv_lines) = lines( lt_workcenter ).
        ls_res-_msgty = 'S'.

        "プラント&1作業区连携成功 &2 件！
        MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 009 WITH lv_plant lv_lines INTO ls_res-_msg.

      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    lv_timestamp = cl_abap_context_info=>get_system_date( ) && cl_abap_context_info=>get_system_time( ).

    "Convert date and time from zero zone to time zone of plant
    CONVERT TIME STAMP lv_timestamp
            TIME ZONE ls_ztbc_1001-zonlo_out
            INTO DATE lv_date
                 TIME lv_time.

    LOOP AT lt_workcenter INTO DATA(ls_workcenter_tmp).
      ls_workcenter-_plant = ls_workcenter_tmp-plant.
      ls_workcenter-_work_center = ls_workcenter_tmp-workcenter.
      ls_workcenter-_work_center_text = ls_workcenter_tmp-workcentertext.
      ls_workcenter-_cost_center = ls_workcenter_tmp-costcenter.
      ls_workcenter-_sent_time_stamp = lv_date && lv_time.
      APPEND ls_workcenter TO ls_res-_data-_work_center.
      CLEAR ls_workcenter.

      "Set data of log
      ls_ztpp_1001-plant = ls_workcenter_tmp-plant.
      ls_ztpp_1001-workcenter = ls_workcenter_tmp-workcenter.
      ls_ztpp_1001-workcentertext = ls_workcenter_tmp-workcentertext.
      ls_ztpp_1001-costcenter = ls_workcenter_tmp-costcenter.
      ls_ztpp_1001-language = sy-langu."ls_ztbc_1001-language.
      ls_ztpp_1001-sentdate = cl_abap_context_info=>get_system_date( ).
      ls_ztpp_1001-senttime = cl_abap_context_info=>get_system_time( ).
      APPEND ls_ztpp_1001 TO lt_ztpp_1001.
      CLEAR ls_ztpp_1001.
    ENDLOOP.

    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
    "Set request data
    response->set_text( lv_res_body ).

    IF ls_res-_msgty = 'S'.
      "Subtracts 3 Months from Date
      lv_date = xco_cp=>sy->date( )->subtract( iv_month = lc_month_3
                                             )->as( xco_cp_time=>format->abap
                                             )->value.
      "Modify database of log
      MODIFY ztpp_1001 FROM TABLE @lt_ztpp_1001.
      "Only save data of 3 months recently
      DELETE FROM ztpp_1001 WHERE sentdate < @lv_date.
    ENDIF.

*&--ADD BEGIN BY XINLEI XU 2025/02/08
    GET TIME STAMP FIELD DATA(lv_timestamp_end).
    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        DATA(lv_request_url) = |https://{ lv_system_url }/sap/bc/http/sap/z_http_querywc_001|.
        ##NO_HANDLER
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    DATA(lv_request_body) = xco_cp_json=>data->from_abap( ls_req )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    DATA(lv_count) = lines( ls_res-_data-_work_center ).

    zzcl_common_utils=>add_interface_log( EXPORTING iv_interface_id   = |IF025|
                                                    iv_interface_desc = |作業区マスタ連携|
                                                    iv_request_method = CONV #( if_web_http_client=>get )
                                                    iv_request_url    = lv_request_url
                                                    iv_request_body   = lv_request_body
                                                    iv_status_code    = CONV #( response->get_status( )-code )
                                                    iv_response       = response->get_text( )
                                                    iv_record_count   = lv_count
                                                    iv_run_start_time = CONV #( lv_timestamp_start )
                                                    iv_run_end_time   = CONV #( lv_timestamp_end )
                                          IMPORTING ev_log_uuid       = DATA(lv_log_uuid) ).
*&--ADD END BY XINLEI XU 2025/02/08
  ENDMETHOD.
ENDCLASS.
