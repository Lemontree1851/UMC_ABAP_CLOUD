CLASS zcl_http_mfgorder_002 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_http_mfgorder_002 IMPLEMENTATION.
  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        time_stamp TYPE string,
      END OF ty_req,

      BEGIN OF ty_data,
        _reservation                  TYPE string,
        _reservation_item             TYPE string,
        _manufacturing_order          TYPE ztpp_1016-manufacturing_order,
        _product                      TYPE i_manufacturingorder-product,
        _mfg_order_planned_total_qty  TYPE i_manufacturingorder-mfgorderplannedtotalqty,
        _mfg_order_planned_start_date TYPE string,
        _production_version           TYPE i_manufacturingorder-productionversion,
        _production_version_text      TYPE i_productionversion-productionversiontext,
        _last_change_date             TYPE string,"ztpp_1015-last_changed_date,
        _last_change_time             TYPE string,"ztpp_1015-last_changed_time,
        _deleted_flag                 TYPE ztpp_1015-delete_flag,
        _plant                        TYPE ztpp_1015-plant,
      END OF ty_data,
      tt_data TYPE STANDARD TABLE OF ty_data WITH DEFAULT KEY,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE tt_data,
      END OF ty_res.

    DATA:
      lo_root_exc  TYPE REF TO cx_root,
      ls_req       TYPE ty_req,
      ls_res       TYPE ty_res,
      ls_data      TYPE ty_data,
      lv_timestamp TYPE timestamp.

    CONSTANTS:
      lc_msgid_zpp_001 TYPE string VALUE 'ZPP_001',
      lc_alpha_out     TYPE string VALUE 'OUT'.

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).

    lv_timestamp = ls_req-time_stamp.

    TRY.
        "Check time stamp of input parameter must be not valuable at the same time
        IF lv_timestamp IS INITIAL.
          "前回送信時間を送信していください！
          MESSAGE ID lc_msgid_zpp_001 TYPE 'E' NUMBER 059 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Obtain data of picking list header and item
        SELECT a~reservation,
               a~reservation_item,
               a~delete_flag,
               a~last_changed_date,
               a~last_changed_time,
               a~plant,
               b~manufacturing_order,
               c~product,
               c~mfgorderplannedtotalqty,
               c~mfgorderplannedstartdate,
               c~productionversion,
               d~productionversiontext
          FROM ztpp_1015 AS a
         INNER JOIN ztpp_1016 AS b
            ON b~reservation = a~reservation
           AND b~reservation_item = a~reservation_item
         INNER JOIN i_manufacturingorder WITH PRIVILEGED ACCESS AS c
            ON c~manufacturingorder = b~manufacturing_order
          LEFT OUTER JOIN i_productionversion WITH PRIVILEGED ACCESS AS d
            ON d~material = c~product
           AND d~plant = c~productionplant
           AND d~productionversion = c~productionversion
         WHERE concat( a~last_changed_date,a~last_changed_time ) >= @lv_timestamp
           AND concat( a~created_date,a~created_time ) > @lv_timestamp
           AND b~short_quantity <> 0
          INTO TABLE @DATA(lt_ztpp_1015).
        IF lt_ztpp_1015 IS NOT INITIAL.
          ls_res-_msgty = 'S'.
          "データ連携成功！
          MESSAGE ID lc_msgid_zpp_001 TYPE 'S' NUMBER 088 INTO ls_res-_msg.
        ELSE.
          "対象データ取得無し！
          MESSAGE ID lc_msgid_zpp_001 TYPE 'E' NUMBER 089 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.
      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    SORT lt_ztpp_1015 BY reservation reservation_item manufacturing_order.

    LOOP AT lt_ztpp_1015 INTO DATA(ls_ztpp_1015).
      ls_data-_reservation = |{ ls_ztpp_1015-reservation ALPHA = OUT }|.
      CONDENSE ls_data-_reservation.
      ls_data-_reservation_item = |{ ls_ztpp_1015-reservation_item ALPHA = OUT }|.
      CONDENSE ls_data-_reservation_item.
      ls_data-_manufacturing_order = |{ ls_ztpp_1015-manufacturing_order ALPHA = OUT }|.
      ls_data-_product = zzcl_common_utils=>conversion_matn1( iv_alpha = lc_alpha_out iv_input = ls_ztpp_1015-product ).
      ls_data-_mfg_order_planned_total_qty  = ls_ztpp_1015-mfgorderplannedtotalqty.
      ls_data-_mfg_order_planned_start_date = ls_ztpp_1015-mfgorderplannedstartdate.
      ls_data-_production_version           = ls_ztpp_1015-productionversion.
      ls_data-_production_version_text      = ls_ztpp_1015-productionversiontext.
      ls_data-_last_change_date             = ls_ztpp_1015-last_changed_date.
      ls_data-_last_change_time             = ls_ztpp_1015-last_changed_time.
      ls_data-_deleted_flag                 = ls_ztpp_1015-delete_flag.
      ls_data-_plant                        = ls_ztpp_1015-plant.
      APPEND ls_data TO ls_res-_data.
      CLEAR ls_data.
    ENDLOOP.

    "ABAP->JSON
    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    "Set request data
    response->set_text( lv_res_body ).
  ENDMETHOD.
ENDCLASS.
