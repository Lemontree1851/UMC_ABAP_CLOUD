CLASS zcl_http_mfgorderconf_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_MFGORDERCONF_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        _plant                        TYPE string,
        _manufacturing_order          TYPE string,
        _manufacturingorderoperation2 TYPE string,
      END OF ty_req,

      BEGIN OF ty_confirmation,
        _manufacturing_order          TYPE i_manufacturingorderoperation-manufacturingorder,
        _plant                        TYPE i_manufacturingorderoperation-plant,
        manufacturingorderoperation_2 TYPE i_manufacturingorderoperation-manufacturingorderoperation_2,
        _confirm_no                   TYPE i_mfgorderconfirmation-mfgorderconfirmationgroup,
        _confirm_index                TYPE i_mfgorderconfirmation-mfgorderconfirmation,
        _discard_reason_i_d           TYPE i_mfgorderconfirmation-variancereasoncode,
        _discard_quantity             TYPE i_mfgorderconfirmation-confirmationscrapquantity,
        _finished_quantity            TYPE i_mfgorderconfirmation-confirmationyieldquantity,
        _process_date                 TYPE string, "i_mfgorderconfirmation-postingdate,
        _remarks                      TYPE i_mfgorderconfirmation-confirmationtext,
        _line_id                      TYPE i_workcenter-workcenter,
        _update_date                  TYPE string, "i_mfgorderconfirmation-mfgorderconfirmationentrydate,
        _updater_name                 TYPE i_mfgorderconfirmation-enteredbyuser,
        _reversed                     TYPE i_mfgorderconfirmation-isreversed,
        _reversal                     TYPE i_mfgorderconfirmation-isreversal,
        _revert_confirm_index         TYPE string, "i_mfgorderconfirmation-cancldmfgorderconfcount,
        _set_up                       TYPE i_mfgorderconfirmation-opconfirmedworkquantity1,
        _machine_work_time            TYPE i_mfgorderconfirmation-opconfirmedworkquantity2,
        _human_work_time              TYPE i_mfgorderconfirmation-opconfirmedworkquantity3,
        _area                         TYPE i_mfgorderconfirmation-opconfirmedworkquantity4,
        _electrical_energy            TYPE i_mfgorderconfirmation-opconfirmedworkquantity5,
        _other_manufacturing_costs    TYPE i_mfgorderconfirmation-opconfirmedworkquantity6,
        _real_human_count             TYPE i_manufacturingorderoperation-numberoftimetickets,
        _real_work_time               TYPE i_mfgorderconfirmation-opconfirmedworkquantity3,
        _u_m_e_s_i_d                  TYPE string,
      END OF ty_confirmation,
      tt_confirmation TYPE STANDARD TABLE OF ty_confirmation WITH DEFAULT KEY,

      BEGIN OF ty_data,
        _confirmation TYPE tt_confirmation,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res.

    DATA:
      lo_root_exc     TYPE REF TO cx_root,
      lr_operation    TYPE RANGE OF i_manufacturingorderoperation-manufacturingorderoperation_2,
      ls_operation    LIKE LINE OF lr_operation,
      ls_confirmation TYPE ty_confirmation,
      ls_req          TYPE ty_req,
      ls_res          TYPE ty_res,
      lv_plant        TYPE i_plant-plant,
      lv_order        TYPE i_manufacturingorder-manufacturingorder,
      lv_operation    TYPE i_manufacturingorderoperation-manufacturingorderoperation_2.

    CONSTANTS:
      lc_msgid         TYPE string VALUE 'ZPP_001',
      lc_msgty         TYPE string VALUE 'E',
      lc_alpha_in      TYPE string VALUE 'IN',
      lc_sign_i        TYPE string VALUE 'I',
      lc_opt_eq        TYPE string VALUE 'EQ',
      lc_unit_s        TYPE string VALUE 'S',
      lc_unit_m        TYPE string VALUE 'M',
      lc_hour_sec_3600 TYPE i      VALUE '3600',
      lc_hour_min_60   TYPE i      VALUE '60',
      lc_tickets_1     TYPE i      VALUE '1'.

GET TIME STAMP FIELD DATA(lv_timestamp_start).

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).
    REPLACE ALL OCCURRENCES OF 'ManufacturingOrderOperation_2' IN lv_req_body WITH 'Manufacturingorderoperation2' .

    "JSON->ABA
    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = lv_req_body
        pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
      CHANGING
        data             = ls_req ).

    lv_plant     = ls_req-_plant.
    lv_order     = |{ ls_req-_manufacturing_order ALPHA = IN }|.
    lv_operation = |{ ls_req-_manufacturingorderoperation2 ALPHA = IN }|.

    TRY.
        "Check plant of input parameter must be valuable
        IF lv_plant IS INITIAL.
          "プラントを送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 001 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Check manufacturing order of input parameter must be valuable
        IF lv_order IS INITIAL.
          "製造指図を送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 015 INTO ls_res-_msg.
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

        "Check manufacturing order and plant of input parameter must be existent
        SELECT COUNT(*)
          FROM i_manufacturingorder WITH PRIVILEGED ACCESS
         WHERE manufacturingorder = @lv_order
           AND productionplant = @lv_plant.
        IF sy-subrc <> 0.
          "プラント&1製造指図&2存在しません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 007 WITH lv_plant lv_order INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        IF lv_operation IS NOT INITIAL.
          ls_operation-sign   = lc_sign_i.
          ls_operation-option = lc_opt_eq.
          ls_operation-low    = lv_operation.
          APPEND ls_operation TO lr_operation.
        ENDIF.

        "Obtain data of manufacturing order operation
        SELECT manufacturingorder,
               manufacturingorderoperation_2,
               plant,
               operationconfirmation,
               numberoftimetickets,
               billofoperationstype,
               billofoperationsgroup,
               billofoperationsvariant,
               billofoperationssequence,
               boooperationinternalid
          FROM i_manufacturingorderoperation WITH PRIVILEGED ACCESS
         WHERE manufacturingorder = @lv_order
           AND plant = @lv_plant
           AND manufacturingorderoperation_2 IN @lr_operation
          INTO TABLE @DATA(lt_manufacturingorderoperation).
        IF sy-subrc = 0.
          "Obtain data of manufacturing order confirmation
          SELECT a~mfgorderconfirmationgroup,
                 a~mfgorderconfirmation,
                 a~confirmationyieldquantity,
                 a~confirmationscrapquantity,
                 a~variancereasoncode,
                 a~postingdate,
                 a~confirmationtext,
                 a~mfgorderconfirmationentrydate,
                 a~enteredbyuser,
                 b~workcenter,
                 a~isreversed,
                 a~isreversal,
                 a~cancldmfgorderconfcount,
                 a~opconfirmedworkquantity1,
                 a~opworkquantityunit1,
                 a~opconfirmedworkquantity2,
                 a~opworkquantityunit2,
                 a~opconfirmedworkquantity3,
                 a~opworkquantityunit3,
                 a~opconfirmedworkquantity4,
                 a~opconfirmedworkquantity5,
                 a~opconfirmedworkquantity6,
                 a~opworkquantityunit6
            FROM i_mfgorderconfirmation WITH PRIVILEGED ACCESS AS a
            LEFT OUTER JOIN i_workcenter WITH PRIVILEGED ACCESS AS b
              ON b~workcenterinternalid = a~workcenterinternalid
             AND b~workcentertypecode = a~workcentertypecode
             FOR ALL ENTRIES IN @lt_manufacturingorderoperation
           WHERE a~mfgorderconfirmationgroup = @lt_manufacturingorderoperation-operationconfirmation
            INTO TABLE @DATA(lt_mfgorderconfirmation).
          IF sy-subrc <> 0.
            "製造指図&1の生産実績明細が見つかりません！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 066 WITH lv_order INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ENDIF.

          "Obtain data of routing operation
          SELECT billofoperationstype,
                 billofoperationsgroup,
                 billofoperationsvariant,
                 billofoperationssequence,
                 boooperationinternalid,
                 numberoftimetickets
            FROM i_mfgboooperationchangestate WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_manufacturingorderoperation
           WHERE billofoperationstype = @lt_manufacturingorderoperation-billofoperationstype
             AND billofoperationsgroup = @lt_manufacturingorderoperation-billofoperationsgroup
             AND billofoperationsvariant = @lt_manufacturingorderoperation-billofoperationsvariant
             AND billofoperationssequence = @lt_manufacturingorderoperation-billofoperationssequence
             AND boooperationinternalid = @lt_manufacturingorderoperation-boooperationinternalid
            INTO TABLE @DATA(lt_mfgboooperationchangestate).
        ELSE.
          "製造指図&1作業番号&2の生産実績が見つかりません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 078 WITH lv_order lv_operation INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Obtain data of umesid
        SELECT FROM ztpp_1004 WITH PRIVILEGED ACCESS
         INNER JOIN @lt_mfgorderconfirmation AS mfgorderconfirmation
            ON ztpp_1004~mfgorderconfirmationgroup = mfgorderconfirmation~mfgorderconfirmationgroup
           AND ztpp_1004~mfgorderconfirmation      = mfgorderconfirmation~mfgorderconfirmation
           AND ztpp_1004~updateflag                = 'I'
           AND ztpp_1004~messagetype               = 'S'
        FIELDS ztpp_1004~umesid,
               ztpp_1004~mfgorderconfirmationgroup,
               ztpp_1004~mfgorderconfirmation,
               ztpp_1004~manufacturingorder
         ORDER BY ztpp_1004~manufacturingorder        ASCENDING,
                  ztpp_1004~mfgorderconfirmationgroup ASCENDING,
                  ztpp_1004~mfgorderconfirmation      ASCENDING
          INTO TABLE @DATA(lt_ztpp_1004).

        DATA(lv_lines) = lines( lt_mfgorderconfirmation ).
        ls_res-_msgty = 'S'.

        "プラント&1製造指図&2生産実績連携成功 &3 件！
        MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 071 WITH lv_plant lv_order lv_lines INTO ls_res-_msg.
      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    SORT lt_manufacturingorderoperation BY manufacturingorder manufacturingorderoperation_2.
    SORT lt_mfgorderconfirmation BY mfgorderconfirmationgroup mfgorderconfirmation.
    SORT lt_mfgboooperationchangestate BY billofoperationstype billofoperationsgroup billofoperationsvariant billofoperationssequence boooperationinternalid.

    LOOP AT lt_manufacturingorderoperation INTO DATA(ls_manufacturingorderoperation).
      "Read data of manufacturing order confirmation
      READ TABLE lt_mfgorderconfirmation TRANSPORTING NO FIELDS WITH KEY mfgorderconfirmationgroup = ls_manufacturingorderoperation-operationconfirmation
                                                                BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_mfgorderconfirmation INTO DATA(ls_mfgorderconfirmation) FROM sy-tabix.
          IF ls_mfgorderconfirmation-mfgorderconfirmationgroup <> ls_manufacturingorderoperation-operationconfirmation.
            EXIT.
          ENDIF.

          ls_confirmation-_manufacturing_order          = ls_manufacturingorderoperation-manufacturingorder.
          ls_confirmation-_plant                        = ls_manufacturingorderoperation-plant.
          ls_confirmation-manufacturingorderoperation_2 = ls_manufacturingorderoperation-manufacturingorderoperation_2.

          IF ls_manufacturingorderoperation-numberoftimetickets > 0.
            ls_confirmation-_real_human_count = ls_manufacturingorderoperation-numberoftimetickets.
          ELSE.
            "Read data of routing operation
            READ TABLE lt_mfgboooperationchangestate INTO DATA(ls_mfgboooperationchangestate) WITH KEY billofoperationstype = ls_manufacturingorderoperation-billofoperationstype
                                                                                                       billofoperationsgroup = ls_manufacturingorderoperation-billofoperationsgroup
                                                                                                       billofoperationsvariant = ls_manufacturingorderoperation-billofoperationsvariant
                                                                                                       billofoperationssequence = ls_manufacturingorderoperation-billofoperationssequence
                                                                                                       boooperationinternalid = ls_manufacturingorderoperation-boooperationinternalid
                                                                                              BINARY SEARCH.
            IF sy-subrc = 0.
              ls_confirmation-_real_human_count = ls_mfgboooperationchangestate-numberoftimetickets.
            ENDIF.
          ENDIF.

          IF ls_confirmation-_real_human_count < lc_tickets_1.
            ls_confirmation-_real_human_count = lc_tickets_1.
          ENDIF.

          ls_confirmation-_confirm_no                = ls_mfgorderconfirmation-mfgorderconfirmationgroup.
          ls_confirmation-_confirm_index             = ls_mfgorderconfirmation-mfgorderconfirmation.
          ls_confirmation-_discard_reason_i_d        = ls_mfgorderconfirmation-variancereasoncode.
          ls_confirmation-_discard_quantity          = ls_mfgorderconfirmation-confirmationscrapquantity.
          ls_confirmation-_finished_quantity         = ls_mfgorderconfirmation-confirmationyieldquantity.
          ls_confirmation-_process_date              = ls_mfgorderconfirmation-postingdate.
          ls_confirmation-_remarks                   = ls_mfgorderconfirmation-confirmationtext.
          ls_confirmation-_line_id                   = ls_mfgorderconfirmation-workcenter.
          ls_confirmation-_line_id                   = ls_mfgorderconfirmation-workcenter.
          ls_confirmation-_update_date               = ls_mfgorderconfirmation-mfgorderconfirmationentrydate.
          ls_confirmation-_updater_name              = ls_mfgorderconfirmation-enteredbyuser.
          ls_confirmation-_reversed                  = ls_mfgorderconfirmation-isreversed.
          ls_confirmation-_reversal                  = ls_mfgorderconfirmation-isreversal.
          ls_confirmation-_set_up                    = ls_mfgorderconfirmation-opconfirmedworkquantity1.
          ls_confirmation-_machine_work_time         = ls_mfgorderconfirmation-opconfirmedworkquantity2.
          ls_confirmation-_human_work_time           = ls_mfgorderconfirmation-opconfirmedworkquantity3.
          ls_confirmation-_area                      = ls_mfgorderconfirmation-opconfirmedworkquantity4.
          ls_confirmation-_electrical_energy         = ls_mfgorderconfirmation-opconfirmedworkquantity5.
          ls_confirmation-_other_manufacturing_costs = ls_mfgorderconfirmation-opconfirmedworkquantity6.

          IF ls_mfgorderconfirmation-cancldmfgorderconfcount IS NOT INITIAL.
            ls_confirmation-_revert_confirm_index = ls_mfgorderconfirmation-cancldmfgorderconfcount.
          ENDIF.

          CASE ls_mfgorderconfirmation-opworkquantityunit1.
            WHEN lc_unit_s.
              ls_confirmation-_set_up = ls_confirmation-_set_up / lc_hour_sec_3600.
            WHEN lc_unit_m.
              ls_confirmation-_set_up = ls_confirmation-_set_up / lc_hour_min_60.
          ENDCASE.

          CASE ls_mfgorderconfirmation-opworkquantityunit2.
            WHEN lc_unit_s.
              ls_confirmation-_machine_work_time = ls_confirmation-_machine_work_time / lc_hour_sec_3600.
            WHEN lc_unit_m.
              ls_confirmation-_machine_work_time = ls_confirmation-_machine_work_time / lc_hour_min_60.
          ENDCASE.

          CASE ls_mfgorderconfirmation-opworkquantityunit3.
            WHEN lc_unit_s.
              ls_confirmation-_human_work_time = ls_confirmation-_human_work_time / lc_hour_sec_3600.
            WHEN lc_unit_m.
              ls_confirmation-_human_work_time = ls_confirmation-_human_work_time / lc_hour_min_60.
          ENDCASE.

          CASE ls_mfgorderconfirmation-opworkquantityunit6.
            WHEN lc_unit_s.
              ls_confirmation-_other_manufacturing_costs = ls_confirmation-_other_manufacturing_costs / lc_hour_sec_3600.
            WHEN lc_unit_m.
              ls_confirmation-_other_manufacturing_costs = ls_confirmation-_other_manufacturing_costs / lc_hour_min_60.
          ENDCASE.

          IF ls_confirmation-_machine_work_time > 0.
            ls_confirmation-_real_work_time = ls_confirmation-_machine_work_time.
          ELSEIF ls_confirmation-_human_work_time > 0.
            ls_confirmation-_real_work_time = ls_confirmation-_human_work_time / ls_confirmation-_real_human_count.
          ENDIF.

          READ TABLE lt_ztpp_1004 INTO DATA(ls_ztpp_1004) WITH KEY
            manufacturingorder        = ls_manufacturingorderoperation-manufacturingorder
            mfgorderconfirmationgroup = ls_mfgorderconfirmation-mfgorderconfirmationgroup
            mfgorderconfirmation      = ls_mfgorderconfirmation-mfgorderconfirmation
            BINARY SEARCH.
          IF sy-subrc = 0.
            ls_confirmation-_u_m_e_s_i_d = ls_ztpp_1004-umesid.
          ENDIF.

          APPEND ls_confirmation TO ls_res-_data-_confirmation.
          CLEAR ls_confirmation.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    "ABAP->JSON
    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF 'manufacturingorderoperation2' IN lv_res_body WITH 'ManufacturingOrderOperation_2'.

    "Set request data
    response->set_text( lv_res_body ).

*&--ADD BEGIN BY XINLEI XU 2025/02/08
    GET TIME STAMP FIELD DATA(lv_timestamp_end).
    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        DATA(lv_request_url) = |https://{ lv_system_url }/sap/bc/http/sap/z_http_mfgorderconf_001|.
        ##NO_HANDLER
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    DATA(lv_request_body) = xco_cp_json=>data->from_abap( ls_req )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    DATA(lv_count) = lines( ls_res-_data-_confirmation ).

    zzcl_common_utils=>add_interface_log( EXPORTING iv_interface_id   = |IF064|
                                                    iv_interface_desc = |生産実績記録連携|
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
