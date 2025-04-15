CLASS zcl_http_checkmfgordermdoc_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_CHECKMFGORDERMDOC_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        plant TYPE string,
        order TYPE string,
      END OF ty_req,

      BEGIN OF ty_stocks,
        _plant                         TYPE i_mfgorderoperationcomponent-plant,
        _assembly                      TYPE i_mfgorderoperationcomponent-assembly,
        _material                      TYPE i_mfgorderoperationcomponent-material,
        _required_quantity             TYPE i_mfgorderoperationcomponent-requiredquantity,
        _base_unit                     TYPE i_mfgorderoperationcomponent-baseunit,
        _storage_location              TYPE i_mfgorderoperationcomponent-storagelocation,
        _batch                         TYPE i_mfgorderoperationcomponent-batch,
        matlcompismarkedforbackflush   TYPE i_mfgorderoperationcomponent-matlcompismarkedforbackflush,
        _withdrawn_quantity            TYPE i_mfgorderoperationcomponent-withdrawnquantity,
        _reservation                   TYPE i_mfgorderoperationcomponent-reservation,
        _reservationitem               TYPE i_mfgorderoperationcomponent-reservationitem,
        _goods_movement_type           TYPE i_mfgorderoperationcomponent-goodsmovementtype,
        _is_batch_management_required  TYPE i_product-isbatchmanagementrequired,
        matlwrhsstkqtyinmatlbaseunit   TYPE i_materialstock_2-matlwrhsstkqtyinmatlbaseunit,
        _material_is_directly_produced TYPE i_mfgorderoperationcomponent-materialisdirectlyproduced,
      END OF ty_stocks,
      tt_stocks TYPE STANDARD TABLE OF ty_stocks WITH DEFAULT KEY,

      BEGIN OF ty_data,
        _stocks TYPE tt_stocks,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res.

    DATA:
      lo_root_exc  TYPE REF TO cx_root,
      lr_backflush TYPE RANGE OF i_mfgorderoperationcomponent-matlcompismarkedforbackflush,
      lr_gmallowed TYPE RANGE OF i_mfgorderoperationcomponent-goodsmovementisallowed,
      lr_ordertype TYPE RANGE OF i_mfgorderwithstatus-manufacturingordertype,
      ls_backflush LIKE LINE OF lr_backflush,
      ls_gmallowed LIKE LINE OF lr_gmallowed,
      ls_req       TYPE ty_req,
      ls_res       TYPE ty_res,
      ls_stocks    TYPE ty_stocks,
      lv_plant     TYPE i_mfgorderoperationcomponent-plant,
      lv_order     TYPE i_mfgorderoperationcomponent-manufacturingorder.

    CONSTANTS:
      lc_zid_zpp008   TYPE ztbc_1001-zid VALUE 'ZPP008',
      lc_msgid        TYPE string VALUE 'ZPP_001',
      lc_msgty        TYPE string VALUE 'E',
      lc_alpha_out    TYPE string VALUE 'OUT',
      lc_sign_i       TYPE c LENGTH 1 VALUE 'I',
      lc_opt_eq       TYPE c LENGTH 2 VALUE 'EQ',
      lc_gmtype_261   TYPE i_mfgorderoperationcomponent-goodsmovementtype VALUE '261',
      lc_stocktype_01 TYPE i_materialstock_2-inventorystocktype           VALUE '01'.

    GET TIME STAMP FIELD DATA(lv_timestamp_start).

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    IF lv_req_body IS NOT INITIAL.
      xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).
    ENDIF.

    lv_plant = ls_req-plant.
    lv_order = |{ ls_req-order ALPHA = IN }|.

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

        "Obtain data of manufacturing order header with status
        SELECT SINGLE
               orderistechnicallycompleted,
               reservation,
               leadingorder,
               manufacturingordertype
          FROM i_mfgorderwithstatus WITH PRIVILEGED ACCESS
         WHERE manufacturingorder = @lv_order
           AND productionplant = @lv_plant
          INTO @DATA(ls_mfgorderwithstatus).
        IF sy-subrc = 0.
          IF ls_mfgorderwithstatus-orderistechnicallycompleted = 'X'.
            "製造指図&1は既に完了（TECO）しました！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 016 WITH lv_order INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.

          IF ls_mfgorderwithstatus-reservation IS INITIAL.
            "入出庫予定が存在しません！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 017 INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.
        ELSE.
          "プラント&1製造指図&2存在しません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 007 WITH lv_plant lv_order INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        IF ls_mfgorderwithstatus-leadingorder IS INITIAL.
          ls_backflush-sign   = lc_sign_i.
          ls_backflush-option = lc_opt_eq.
          ls_backflush-low    = abap_true.
          APPEND ls_backflush TO lr_backflush.

          ls_gmallowed-sign   = lc_sign_i.
          ls_gmallowed-option = lc_opt_eq.
          ls_gmallowed-low    = abap_true.
          APPEND ls_gmallowed TO lr_gmallowed.
        ELSE.
          "Obtain data of minimum manufacturing order using leading order
          SELECT MIN( manufacturingorder )
            FROM i_mfgorderwithstatus WITH PRIVILEGED ACCESS
           WHERE leadingorder = @ls_mfgorderwithstatus-leadingorder
            INTO @DATA(lv_manufacturingorder_min).

          IF lv_order = lv_manufacturingorder_min.
            ls_backflush-sign   = lc_sign_i.
            ls_backflush-option = lc_opt_eq.
            ls_backflush-low    = abap_true.
            APPEND ls_backflush TO lr_backflush.

            ls_gmallowed-sign   = lc_sign_i.
            ls_gmallowed-option = lc_opt_eq.
            ls_gmallowed-low    = abap_true.
            APPEND ls_gmallowed TO lr_gmallowed.
          ENDIF.
        ENDIF.

        "Obtain data of reservation items
        SELECT reservation,
               reservationitem,
               material,
               plant,
               storagelocation,
               batch,
               assembly,
               requiredquantity,
               withdrawnquantity,
               baseunit,
               matlcompismarkedforbackflush,
               goodsmovementtype,
               salesorder,
               salesorderitem,
               wbselementinternalid_2,
               materialisdirectlyproduced
          FROM i_mfgorderoperationcomponent WITH PRIVILEGED ACCESS
         WHERE reservation = @ls_mfgorderwithstatus-reservation
           AND matlcompismarkedfordeletion = @space
           AND materialcomponentisphantomitem = @space
           AND goodsmovementtype = @lc_gmtype_261
           AND matlcompismarkedforbackflush IN @lr_backflush
           AND goodsmovementisallowed IN @lr_gmallowed
           AND requiredquantity > 0
          INTO TABLE @DATA(lt_mfgorderoperationcomponent).
        IF sy-subrc = 0.
          "Obtain data of storage location
          SELECT product,
                 plant,
                 storagelocation
            FROM i_productstoragelocationbasic WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_mfgorderoperationcomponent
           WHERE product = @lt_mfgorderoperationcomponent-material
             AND plant = @lt_mfgorderoperationcomponent-plant
             AND storagelocation = @lt_mfgorderoperationcomponent-storagelocation
             AND ismarkedfordeletion = 'X'
            INTO TABLE @DATA(lt_productstoragelocationbasic). "#EC CI_NO_TRANSFORM

          "Obtain data of product
          SELECT product,
                 isbatchmanagementrequired
            FROM i_product WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_mfgorderoperationcomponent
           WHERE product = @lt_mfgorderoperationcomponent-material
            INTO TABLE @DATA(lt_product).          "#EC CI_NO_TRANSFORM

          "Obtain data of material stock
          SELECT material,
                 plant,
                 storagelocation,
                 batch,
                 supplier,
                 sddocument,
                 sddocumentitem,
                 wbselementinternalid,
                 customer,
                 specialstockidfgstockowner,
                 inventorystocktype,
                 inventoryspecialstocktype,
                 fiscalyearvariant,
                 matldoclatestpostgdate,
                 materialbaseunit,
                 costestimate,
                 resourceid,
                 matlwrhsstkqtyinmatlbaseunit
            FROM i_materialstock_2 WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_mfgorderoperationcomponent
           WHERE material = @lt_mfgorderoperationcomponent-material
             AND plant = @lt_mfgorderoperationcomponent-plant
             AND storagelocation = @lt_mfgorderoperationcomponent-storagelocation
             AND batch = @lt_mfgorderoperationcomponent-batch
             AND sddocument = @lt_mfgorderoperationcomponent-salesorder
             AND sddocumentitem = @lt_mfgorderoperationcomponent-salesorderitem
             AND wbselementinternalid = @lt_mfgorderoperationcomponent-wbselementinternalid_2
             AND inventorystocktype = @lc_stocktype_01
            INTO TABLE @DATA(lt_materialstock_2).  "#EC CI_NO_TRANSFORM

          ls_res-_msgty = 'S'.
          "製造指図&1の構成品目の在庫を参照してください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 025 WITH lv_order INTO ls_res-_msg.
        ELSE.
          "Obtain manufacturing order type
          SELECT @lc_sign_i,
                 @lc_opt_eq,
                 zvalue1
            FROM ztbc_1001
           WHERE zid = @lc_zid_zpp008
             AND zvalue2 = @lv_plant
            INTO TABLE @lr_ordertype.

          IF lr_ordertype IS NOT INITIAL AND ls_mfgorderwithstatus-manufacturingordertype IN lr_ordertype.
            ls_res-_msgty = 'S'.
          ELSE.
            "製造指図&1の入出庫予定&2の明細が見つかりません！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 018 WITH lv_order ls_mfgorderwithstatus-reservation INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.
        ENDIF.
      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    SORT lt_mfgorderoperationcomponent BY reservation reservationitem.
    SORT lt_productstoragelocationbasic BY product plant storagelocation.
    SORT lt_product BY product.
    SORT lt_materialstock_2 BY material plant storagelocation batch sddocument sddocumentitem wbselementinternalid.

    LOOP AT lt_mfgorderoperationcomponent INTO DATA(ls_mfgorderoperationcomponent).
      "Read data of storage location
      READ TABLE lt_productstoragelocationbasic INTO DATA(ls_productstoragelocationbasic) WITH KEY product = ls_mfgorderoperationcomponent-material
                                                                                                   plant = ls_mfgorderoperationcomponent-plant
                                                                                                   storagelocation = ls_mfgorderoperationcomponent-storagelocation
                                                                                          BINARY SEARCH.
      IF sy-subrc = 0.
        "保管場所&1の品目&2の在庫は利用できません！
        MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 024 WITH ls_mfgorderoperationcomponent-storagelocation ls_mfgorderoperationcomponent-material INTO ls_res-_msg.
        ls_res-_msgty = 'E'.
        CLEAR ls_res-_data.

        EXIT.
      ENDIF.

      "Read data of material stock
      READ TABLE lt_materialstock_2 TRANSPORTING NO FIELDS WITH KEY material = ls_mfgorderoperationcomponent-material
                                                                    plant = ls_mfgorderoperationcomponent-plant
                                                                    storagelocation = ls_mfgorderoperationcomponent-storagelocation
                                                                    batch = ls_mfgorderoperationcomponent-batch
                                                                    sddocument = ls_mfgorderoperationcomponent-salesorder
                                                                    sddocumentitem = ls_mfgorderoperationcomponent-salesorderitem
                                                                    wbselementinternalid = ls_mfgorderoperationcomponent-wbselementinternalid_2
                                                               BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_materialstock_2 INTO DATA(ls_materialstock_2) FROM sy-tabix.
          IF ls_materialstock_2-material <> ls_mfgorderoperationcomponent-material
          OR ls_materialstock_2-plant <> ls_mfgorderoperationcomponent-plant
          OR ls_materialstock_2-storagelocation <> ls_mfgorderoperationcomponent-storagelocation
          OR ls_materialstock_2-batch <> ls_mfgorderoperationcomponent-batch
          OR ls_materialstock_2-sddocument <> ls_mfgorderoperationcomponent-salesorder
          OR ls_materialstock_2-sddocumentitem <> ls_mfgorderoperationcomponent-salesorderitem
          OR ls_materialstock_2-wbselementinternalid <> ls_mfgorderoperationcomponent-wbselementinternalid_2.
            EXIT.
          ENDIF.

          ls_stocks-matlwrhsstkqtyinmatlbaseunit = ls_stocks-matlwrhsstkqtyinmatlbaseunit + ls_materialstock_2-matlwrhsstkqtyinmatlbaseunit.
        ENDLOOP.
      ENDIF.

      ls_stocks-_plant                         = ls_mfgorderoperationcomponent-plant.
      ls_stocks-_assembly                      = ls_mfgorderoperationcomponent-assembly.
      ls_stocks-_material                      = ls_mfgorderoperationcomponent-material.
      ls_stocks-_required_quantity             = ls_mfgorderoperationcomponent-requiredquantity.
      ls_stocks-_storage_location              = ls_mfgorderoperationcomponent-storagelocation.
      ls_stocks-_batch                         = ls_mfgorderoperationcomponent-batch.
      ls_stocks-matlcompismarkedforbackflush   = ls_mfgorderoperationcomponent-matlcompismarkedforbackflush.
      ls_stocks-_withdrawn_quantity            = ls_mfgorderoperationcomponent-withdrawnquantity.
      ls_stocks-_reservation                   = ls_mfgorderoperationcomponent-reservation.
      ls_stocks-_reservationitem               = ls_mfgorderoperationcomponent-reservationitem.
      ls_stocks-_goods_movement_type           = ls_mfgorderoperationcomponent-goodsmovementtype.
      ls_stocks-_material_is_directly_produced = ls_mfgorderoperationcomponent-materialisdirectlyproduced.

      TRY.
          ls_stocks-_base_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                iv_input = ls_mfgorderoperationcomponent-baseunit ).
        CATCH zzcx_custom_exception INTO lo_root_exc.
          ls_stocks-_base_unit = ls_mfgorderoperationcomponent-baseunit.
      ENDTRY.

      "Read data of product
      READ TABLE lt_product INTO DATA(ls_product) WITH KEY product = ls_mfgorderoperationcomponent-material BINARY SEARCH.
      IF sy-subrc = 0.
        ls_stocks-_is_batch_management_required = ls_product-isbatchmanagementrequired.
      ENDIF.

      APPEND ls_stocks TO ls_res-_data-_stocks.
      CLEAR ls_stocks.
    ENDLOOP.

    "ABAP->JSON
    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF 'matlcompismarkedforbackflush' IN lv_res_body WITH 'MatlCompIsMarkedForBackflush'.
    REPLACE ALL OCCURRENCES OF 'matlwrhsstkqtyinmatlbaseunit' IN lv_res_body WITH 'MatlWrhsStkQtyInMatlBaseUnit'.

    "Set request data
    response->set_text( lv_res_body ).

*&--ADD BEGIN BY XINLEI XU 2025/02/08
    GET TIME STAMP FIELD DATA(lv_timestamp_end).
    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        DATA(lv_request_url) = |https://{ lv_system_url }/sap/bc/http/sap/z_http_checkmfgordermdoc_001|.
        ##NO_HANDLER
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    DATA(lv_request_body) = xco_cp_json=>data->from_abap( ls_req )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    DATA(lv_count) = lines( ls_res-_data-_stocks ).

    zzcl_common_utils=>add_interface_log( EXPORTING iv_interface_id   = |IF030|
                                                    iv_interface_desc = |生産実績のチェック|
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
