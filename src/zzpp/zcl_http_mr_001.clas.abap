CLASS zcl_http_mr_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_http_mr_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        plant      TYPE string,
        time_stamp TYPE string,
      END OF ty_req,

      BEGIN OF ty_mritems,
*        _material_requisition_no TYPE ztpp_1010-material_requisition_no,
        _item_no              TYPE string,
        _material             TYPE ztpp_1010-material,
        _storage_location     TYPE ztpp_1010-storage_location,
        _base_unit            TYPE ztpp_1010-base_unit,
        _quantity             TYPE ztpp_1010-quantity,
        _created_date         TYPE string, "ztpp_1010-created_date,
        _created_time         TYPE string, "ztpp_1010-created_time,
        _created_by_user      TYPE ztpp_1010-created_by_user,
        _last_changed_date    TYPE string, "ztpp_1010-last_changed_date,
        _last_changed_time    TYPE string, "ztpp_1010-last_changed_time,
        _last_changed_by_user TYPE ztpp_1010-last_changed_by_user,
        _delete_flag          TYPE ztpp_1010-delete_flag,
        _manufacturing_order  TYPE ztpp_1010-manufacturing_order,
        _product              TYPE ztpp_1010-product,
      END OF ty_mritems,
      tt_mritems TYPE STANDARD TABLE OF ty_mritems WITH DEFAULT KEY,

      BEGIN OF ty_material_requisition,
        _plant                   TYPE ztpp_1009-plant,
        _material_requisition_no TYPE ztpp_1009-material_requisition_no,
        _type                    TYPE ztpp_1009-type,
        _m_r_status              TYPE ztpp_1009-m_r_status,
        _line_warehouse_status   TYPE ztpp_1009-line_warehouse_status,
        _requisition_date        TYPE string, "ztpp_1009-requisition_date,
        _created_date            TYPE string, "ztpp_1009-created_date,
        _created_time            TYPE string, "ztpp_1009-created_time,
        _created_by_user         TYPE ztpp_1009-created_by_user,
        _last_changed_date       TYPE string, "ztpp_1009-last_changed_date,
        _last_changed_time       TYPE string, "ztpp_1009-last_changed_time,
        _last_changed_by_user    TYPE ztpp_1009-last_changed_by_user,
        _delete_flag             TYPE ztpp_1009-delete_flag,
        _m_r_items               TYPE tt_mritems,
      END OF ty_material_requisition,
      tt_material_requisition TYPE STANDARD TABLE OF ty_material_requisition WITH DEFAULT KEY,

      BEGIN OF ty_data,
        _material_requisition TYPE tt_material_requisition,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res.

    DATA:
      lo_root_exc  TYPE REF TO cx_root,
      lr_type      TYPE RANGE OF ztpp_1009-type,
      lr_plant     TYPE RANGE OF werks_d,
      lt_mr        TYPE tt_material_requisition,
      ls_req       TYPE ty_req,
      ls_res       TYPE ty_res,
      ls_mr        TYPE ty_material_requisition,
      ls_mritems   TYPE ty_mritems,
      lv_plant     TYPE werks_d,
      lv_timestamp TYPE timestamp.

    CONSTANTS:
      lc_zid_zpp001    TYPE string     VALUE 'ZPP001',
      lc_zkey1_type    TYPE string     VALUE 'TYPE',
      lc_zkey3_send    TYPE string     VALUE 'UWMSSEND',
      lc_msgid_zpp_001 TYPE string     VALUE 'ZPP_001',
      lc_alpha_out     TYPE string     VALUE 'OUT',
      lc_delflg_w      TYPE string     VALUE 'W',
      lc_sign_i        TYPE c LENGTH 1 VALUE 'I',
      lc_opt_eq        TYPE c LENGTH 2 VALUE 'EQ'.

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    IF lv_req_body IS NOT INITIAL.
      xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).
    ENDIF.

    lv_plant     = ls_req-plant.
    lv_timestamp = ls_req-time_stamp.

    TRY.
        "Check time stamp of input parameter must be not valuable at the same time
        IF lv_timestamp IS INITIAL.
          "前回送信時間を送信していください！
          MESSAGE ID lc_msgid_zpp_001 TYPE 'E' NUMBER 059 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Obtain MR type
        SELECT @lc_sign_i,
               @lc_opt_eq,
               zvalue1
          FROM ztbc_1001
         WHERE zid = @lc_zid_zpp001
           AND zkey1 = @lc_zkey1_type
           AND zkey3 = @lc_zkey3_send
           AND zvalue3 = @abap_true
          INTO TABLE @lr_type.

        IF lv_plant IS NOT INITIAL.
          lr_plant = VALUE #( sign = lc_sign_i option = lc_opt_eq ( low = lv_plant ) ).
        ENDIF.

        IF lr_type IS NOT INITIAL.
          "Obtain data of material_requisition
          SELECT plant,
                 material_requisition_no,
                 type,
                 m_r_status,
                 line_warehouse_status,
                 requisition_date,
                 created_date,
                 created_time,
                 created_by_user,
                 last_changed_date,
                 last_changed_time,
                 last_changed_by_user,
                 delete_flag
            FROM ztpp_1009
           WHERE plant IN @lr_plant
             AND type IN @lr_type
             AND line_warehouse_status <> @abap_true
             AND concat( last_changed_date,last_changed_time ) >= @lv_timestamp
             AND material_requisition_no NOT IN ( SELECT material_requisition_no FROM ztpp_1009
                                                   WHERE plant IN @lr_plant
                                                     AND type IN @lr_type
                                                     AND concat( created_date,created_time ) > @lv_timestamp
                                                     AND ( m_r_status <> @abap_true OR delete_flag = @abap_true ) )
            INTO TABLE @DATA(lt_ztpp_1009).
          IF sy-subrc = 0.
            SELECT material_requisition_no,
                   item_no,
                   manufacturing_order,
                   product,
                   material,
                   storage_location,
                   base_unit,
                   quantity,
                   created_date,
                   created_time,
                   created_by_user,
                   last_changed_date,
                   last_changed_time,
                   last_changed_by_user,
                   delete_flag
              FROM ztpp_1010 AS a
               FOR ALL ENTRIES IN @lt_ztpp_1009
             WHERE material_requisition_no = @lt_ztpp_1009-material_requisition_no
              INTO TABLE @DATA(lt_ztpp_1010).      "#EC CI_NO_TRANSFORM
          ENDIF.
        ENDIF.

        IF lt_ztpp_1009 IS NOT INITIAL.
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

    SORT lt_ztpp_1009 BY plant material_requisition_no.
    SORT lt_ztpp_1010 BY material_requisition_no item_no.

    LOOP AT lt_ztpp_1009 INTO DATA(ls_ztpp_1009).
      ls_mr-_plant                   = ls_ztpp_1009-plant.
      ls_mr-_material_requisition_no = ls_ztpp_1009-material_requisition_no.
      ls_mr-_type                    = ls_ztpp_1009-type.
      ls_mr-_m_r_status              = ls_ztpp_1009-m_r_status.
      ls_mr-_line_warehouse_status   = ls_ztpp_1009-line_warehouse_status.
      ls_mr-_requisition_date        = ls_ztpp_1009-requisition_date.
      ls_mr-_created_date            = ls_ztpp_1009-created_date.
      ls_mr-_created_time            = ls_ztpp_1009-created_time.
      ls_mr-_created_by_user         = ls_ztpp_1009-created_by_user.
      ls_mr-_last_changed_date       = ls_ztpp_1009-last_changed_date.
      ls_mr-_last_changed_time       = ls_ztpp_1009-last_changed_time.
      ls_mr-_last_changed_by_user    = ls_ztpp_1009-last_changed_by_user.
      ls_mr-_delete_flag             = ls_ztpp_1009-delete_flag.

      READ TABLE lt_ztpp_1010 TRANSPORTING NO FIELDS WITH KEY material_requisition_no = ls_ztpp_1009-material_requisition_no
                                                     BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_ztpp_1010 INTO DATA(ls_ztpp_1010) FROM sy-tabix.
          IF ls_ztpp_1010-material_requisition_no <> ls_ztpp_1009-material_requisition_no.
            EXIT.
          ENDIF.

          IF |{ ls_ztpp_1010-created_date }{ ls_ztpp_1010-created_time }| > lv_timestamp
          AND ( ls_ztpp_1010-delete_flag = abap_true OR ls_ztpp_1010-delete_flag = lc_delflg_w ).
            CONTINUE.
          ENDIF.

          ls_mritems-_manufacturing_order     = |{ ls_ztpp_1010-manufacturing_order ALPHA = OUT }|.
          ls_mritems-_storage_location        = ls_ztpp_1010-storage_location.
          ls_mritems-_item_no                 = |{ ls_ztpp_1010-item_no ALPHA = OUT }|.
          CONDENSE ls_mritems-_item_no.

          ls_mritems-_product = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_out iv_input = ls_ztpp_1010-product ).
          ls_mritems-_material = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_out iv_input = ls_ztpp_1010-material ).

          TRY.
              ls_mritems-_base_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                     iv_input = ls_ztpp_1010-base_unit ).
            CATCH zzcx_custom_exception INTO lo_root_exc.
              ls_mritems-_base_unit = ls_ztpp_1010-base_unit.
          ENDTRY.

          ls_mritems-_quantity             = ls_ztpp_1010-quantity.
          ls_mritems-_created_date         = ls_ztpp_1010-created_date.
          ls_mritems-_created_time         = ls_ztpp_1010-created_time.
          ls_mritems-_created_by_user      = ls_ztpp_1010-created_by_user.
          ls_mritems-_last_changed_date    = ls_ztpp_1010-last_changed_date.
          ls_mritems-_last_changed_time    = ls_ztpp_1010-last_changed_time.
          ls_mritems-_last_changed_by_user = ls_ztpp_1010-last_changed_by_user.
          ls_mritems-_delete_flag          = ls_ztpp_1010-delete_flag.
          APPEND ls_mritems TO ls_mr-_m_r_items."ls_res-_data-_material_requisition-_m_r_items.
          CLEAR ls_mritems.
        ENDLOOP.
      ENDIF.

      APPEND ls_mr TO ls_res-_data-_material_requisition.
      CLEAR ls_mr.
    ENDLOOP.

    "ABAP->JSON
    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    "Set request data
    response->set_text( lv_res_body ).
  ENDMETHOD.
ENDCLASS.
