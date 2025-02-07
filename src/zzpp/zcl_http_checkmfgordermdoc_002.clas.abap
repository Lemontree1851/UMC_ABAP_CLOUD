CLASS zcl_http_checkmfgordermdoc_002 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_CHECKMFGORDERMDOC_002 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        plant                        TYPE string,
        mfg_order_confirmation_group TYPE string,
        mfg_order_confirmation       TYPE string,
        milestone_is_confirmed       TYPE string,
      END OF ty_req,

      BEGIN OF ty_data,
        _material TYPE string,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res,

      BEGIN OF ty_results,
        confirmation_group     TYPE i_mfgorderconfirmation-mfgorderconfirmationgroup,
        confirmation_count     TYPE i_mfgorderconfirmation-mfgorderconfirmation,
        material_document      TYPE i_materialdocumentitemtp-materialdocument,
        material_document_item TYPE i_materialdocumentitemtp-materialdocumentitem,
        material_document_year TYPE i_materialdocumentitemtp-materialdocumentyear,
      END OF ty_results,
      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,

      BEGIN OF ty_d,
        results TYPE tt_results,
      END OF ty_d,

      BEGIN OF ty_res_api,
        d TYPE ty_d,
      END OF ty_res_api,

      BEGIN OF ty_stock,
        material                     TYPE i_materialstock_2-material,
        plant                        TYPE i_materialstock_2-plant,
        storagelocation              TYPE i_materialstock_2-storagelocation,
        batch                        TYPE i_materialstock_2-batch,
        supplier                     TYPE i_materialstock_2-supplier,
        sddocument                   TYPE i_materialstock_2-sddocument,
        sddocumentitem               TYPE i_materialstock_2-sddocumentitem,
        wbselementinternalid         TYPE i_materialstock_2-wbselementinternalid,
        customer                     TYPE i_materialstock_2-customer,
        specialstockidfgstockowner   TYPE i_materialstock_2-specialstockidfgstockowner,
        inventorystocktype           TYPE i_materialstock_2-inventorystocktype,
        inventoryspecialstocktype    TYPE i_materialstock_2-inventoryspecialstocktype,
        fiscalyearvariant            TYPE i_materialstock_2-fiscalyearvariant,
        matldoclatestpostgdate       TYPE i_materialstock_2-matldoclatestpostgdate,
        materialbaseunit             TYPE i_materialstock_2-materialbaseunit,
        costestimate                 TYPE i_materialstock_2-costestimate,
        resourceid                   TYPE i_materialstock_2-resourceid,
        matlwrhsstkqtyinmatlbaseunit TYPE i_materialstock_2-matlwrhsstkqtyinmatlbaseunit,
      END OF ty_stock,

      BEGIN OF ty_require,
        material             TYPE i_materialdocumentitem_2-material,
        plant                TYPE i_materialdocumentitem_2-plant,
        storagelocation      TYPE i_materialdocumentitem_2-storagelocation,
        batch                TYPE i_materialdocumentitem_2-batch,
        salesorder           TYPE i_materialdocumentitem_2-salesorder,
        salesorderitem       TYPE i_materialdocumentitem_2-salesorderitem,
        wbselementinternalid TYPE i_materialdocumentitem_2-wbselementinternalid,
        quantityinbaseunit   TYPE i_materialdocumentitem_2-quantityinbaseunit,
      END OF ty_require.

    DATA:
      lo_root_exc  TYPE REF TO cx_root,
      lr_type      TYPE RANGE OF i_mfgorderwithstatus-manufacturingordertype,
      lt_require   TYPE STANDARD TABLE OF ty_require,
      lt_stock     TYPE STANDARD TABLE OF ty_stock,
      lt_stock_sum TYPE STANDARD TABLE OF ty_stock,
      ls_req       TYPE ty_req,
      ls_res       TYPE ty_res,
      ls_res_api   TYPE ty_res_api,
      ls_require   TYPE ty_require,
      ls_stock_sum TYPE ty_stock,
      lv_plant     TYPE i_mfgorderconfirmation-plant,
      lv_group     TYPE i_mfgorderconfirmation-mfgorderconfirmationgroup,
      lv_count     TYPE i_mfgorderconfirmation-mfgorderconfirmation,
      lv_milestone TYPE i_mfgorderconfirmation-milestoneconfirmationtype,
      lv_path      TYPE string,
      lv_qty_short TYPE p LENGTH 8 DECIMALS 3.

    CONSTANTS:
      lc_zid_zpp008      TYPE string     VALUE 'ZPP008',
      lc_specproctype_52 TYPE string     VALUE '52',
      lc_msgid           TYPE string     VALUE 'ZPP_001',
      lc_msgty           TYPE string     VALUE 'E',
      lc_stat_code_500   TYPE string     VALUE '500',
      lc_sign_e          TYPE c LENGTH 1 VALUE 'E',
      lc_opt_eq          TYPE c LENGTH 2 VALUE 'EQ',
      lc_gmtype_101      TYPE i_materialdocumentitemtp-goodsmovementtype VALUE '101',
      lc_gmtype_531      TYPE i_materialdocumentitemtp-goodsmovementtype VALUE '531',
      lc_stocktype_01    TYPE i_materialstock_2-inventorystocktype       VALUE '01'.


    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).

    lv_plant = ls_req-plant.
    lv_group = ls_req-mfg_order_confirmation_group.
    lv_count = ls_req-mfg_order_confirmation.
    lv_milestone = ls_req-milestone_is_confirmed.

    TRY.
        "Check plant of input parameter must be valuable
        IF lv_plant IS INITIAL.
          "プラントを送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 001 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Check confirmation number of input parameter must be valuable
        IF lv_group IS INITIAL.
          "作業確認番号を送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 019 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Check confirmation counter of input parameter must be valuable
        IF lv_count IS INITIAL.
          "確認カウンタを送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 020 INTO ls_res-_msg.
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

        "Obtain data of manufacturing order confirmation
        SELECT SINGLE
               manufacturingorder,
               isreversed,
               isreversal,
               milestoneconfirmationtype
          FROM i_mfgorderconfirmation WITH PRIVILEGED ACCESS
         WHERE mfgorderconfirmationgroup = @lv_group
           AND mfgorderconfirmation = @lv_count
           AND plant = @lv_plant
          INTO @DATA(ls_mfgorderconfirmation).
        IF sy-subrc = 0.
          IF ls_mfgorderconfirmation-isreversed = 'X' OR ls_mfgorderconfirmation-isreversal = 'X'.
            "作業実績は既に取消しました！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 022 INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.

          IF ls_mfgorderconfirmation-milestoneconfirmationtype = '' AND lv_milestone = 'X'.
            "作業確認はマイルストーン確認ではありません！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 072 INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.

          "Obtain manufacturing order type
          SELECT @lc_sign_e,
                 @lc_opt_eq,
                 zvalue1
            FROM ztbc_1001
           WHERE zid = @lc_zid_zpp008
             AND zvalue2 = @lv_plant
            INTO TABLE @lr_type.

          "Obtain data of manufacturing order header with status
          SELECT SINGLE
                 material,
                 orderistechnicallycompleted
            FROM i_mfgorderwithstatus WITH PRIVILEGED ACCESS
           WHERE manufacturingorder = @ls_mfgorderconfirmation-manufacturingorder
             AND manufacturingordertype IN @lr_type
            INTO @DATA(ls_mfgorderwithstatus).
          IF sy-subrc = 0.
            IF ls_mfgorderwithstatus-material IS INITIAL.
              "製造指図&1の品目は存在しません！
              MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 073 WITH ls_mfgorderconfirmation-manufacturingorder INTO ls_res-_msg.
              RAISE EXCEPTION TYPE cx_abap_api_state.
            ENDIF.

            IF ls_mfgorderwithstatus-orderistechnicallycompleted = 'X'.
              "製造指図&1は既に完了（TECO）しました！
              MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 016 WITH ls_mfgorderconfirmation-manufacturingorder INTO ls_res-_msg.
              RAISE EXCEPTION TYPE cx_abap_api_state.
            ENDIF.
          ENDIF.

          "/API_PROD_ORDER_CONFIRMATION_2_SRV/ProdnOrdConf2(ConfirmationGroup='{ConfirmationGroup}',ConfirmationCount='{ConfirmationCount}')/to_ProdnOrdConfMatlDocItm
          lv_path = |/API_PROD_ORDER_CONFIRMATION_2_SRV/ProdnOrdConf2(ConfirmationGroup='{ lv_group }',ConfirmationCount='{ lv_count }')/to_ProdnOrdConfMatlDocItm|.

          "Call API of reading the material documents for goods movements belonging to the confirmation
          zzcl_common_utils=>request_api_v2(
            EXPORTING
              iv_path        = lv_path
              iv_method      = if_web_http_client=>get
            IMPORTING
              ev_status_code = DATA(lv_stat_code)
              ev_response    = DATA(lv_resbody_api) ).

          "Could not fetch SCRF token
          IF lv_stat_code = lc_stat_code_500.
            ls_res-_msg = lv_resbody_api.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.

          "JSON->ABAP
          xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
              ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_res_api ) ).

          IF ls_res_api-d-results IS NOT INITIAL.
            "Obtain data of material document item
            SELECT materialdocumentyear,
                   materialdocument,
                   materialdocumentitem,
                   material,
                   plant,
                   storagelocation,
                   batch,
                   salesorder,
                   salesorderitem,
                   wbselementinternalid,
                   quantityinbaseunit
              FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @ls_res_api-d-results
             WHERE materialdocumentyear = @ls_res_api-d-results-material_document_year
               AND materialdocument = @ls_res_api-d-results-material_document
               AND materialdocumentitem = @ls_res_api-d-results-material_document_item
               AND goodsmovementtype IN (@lc_gmtype_101,@lc_gmtype_531)
               INTO TABLE @DATA(lt_materialdocumentitem).
            IF sy-subrc = 0.
              "Obtain data of storage location
              SELECT product,
                     plant,
                     storagelocation
                FROM i_productstoragelocationbasic WITH PRIVILEGED ACCESS
                 FOR ALL ENTRIES IN @lt_materialdocumentitem
               WHERE product = @lt_materialdocumentitem-material
                 AND plant = @lt_materialdocumentitem-plant
                 AND storagelocation = @lt_materialdocumentitem-storagelocation
                 AND ismarkedfordeletion = 'X'
                INTO TABLE @DATA(lt_productstoragelocationbasic).
              IF sy-subrc <> 0.
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
                   FOR ALL ENTRIES IN @lt_materialdocumentitem
                 WHERE material = @lt_materialdocumentitem-material
                   AND plant = @lt_materialdocumentitem-plant
                   AND storagelocation = @lt_materialdocumentitem-storagelocation
                   AND batch = @lt_materialdocumentitem-batch
                   AND sddocument = @lt_materialdocumentitem-salesorder
                   AND sddocumentitem = @lt_materialdocumentitem-salesorderitem
                   AND wbselementinternalid = @lt_materialdocumentitem-wbselementinternalid
                   AND inventorystocktype = @lc_stocktype_01
                  INTO TABLE @lt_stock.
              ENDIF.

              "Obtain product plant
              SELECT product,
                     plant
                FROM i_productplantbasic WITH PRIVILEGED ACCESS
                 FOR ALL ENTRIES IN @lt_materialdocumentitem
               WHERE product = @lt_materialdocumentitem-material
                 AND plant = @lt_materialdocumentitem-plant
                 AND specialprocurementtype = @lc_specproctype_52
                INTO TABLE @DATA(lt_productplantbasic).
            ELSE.
              "入出庫伝票は取得できません！
              MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 023 INTO ls_res-_msg.
              RAISE EXCEPTION TYPE cx_abap_api_state.
            ENDIF.
          ENDIF.
        ELSE.
          "作業確認番号&1確認カウンタ&2存在しません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 021 WITH lv_group lv_count INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        ls_res-_msgty = 'S'.
      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    "Sum require quantity
    LOOP AT lt_materialdocumentitem INTO DATA(ls_materialdocumentitem).
      ls_require-material             = ls_materialdocumentitem-material.
      ls_require-plant                = ls_materialdocumentitem-plant.
      ls_require-storagelocation      = ls_materialdocumentitem-storagelocation.
      ls_require-batch                = ls_materialdocumentitem-batch.
      ls_require-salesorder           = ls_materialdocumentitem-salesorder.
      ls_require-salesorderitem       = ls_materialdocumentitem-salesorderitem.
      ls_require-wbselementinternalid = ls_materialdocumentitem-wbselementinternalid.
      ls_require-quantityinbaseunit   = ls_materialdocumentitem-quantityinbaseunit.
      COLLECT ls_require INTO lt_require.
      CLEAR ls_require.
    ENDLOOP.

    "Sum stock quantity
    LOOP AT lt_stock INTO DATA(ls_stock).
      ls_stock_sum-material                     = ls_stock-material.
      ls_stock_sum-plant                        = ls_stock-plant.
      ls_stock_sum-storagelocation              = ls_stock-storagelocation.
      ls_stock_sum-batch                        = ls_stock-batch.
      ls_stock_sum-sddocument                   = ls_stock-sddocument.
      ls_stock_sum-sddocumentitem               = ls_stock-sddocumentitem.
      ls_stock_sum-wbselementinternalid         = ls_stock-wbselementinternalid.
      ls_stock_sum-matlwrhsstkqtyinmatlbaseunit = ls_stock-matlwrhsstkqtyinmatlbaseunit.
      COLLECT ls_stock_sum INTO lt_stock_sum.
      CLEAR ls_stock_sum.
    ENDLOOP.

    SORT lt_require BY material plant storagelocation batch salesorder salesorderitem wbselementinternalid.
    SORT lt_stock_sum BY material plant storagelocation batch sddocument sddocumentitem wbselementinternalid.
    SORT lt_productstoragelocationbasic BY product plant storagelocation.
    SORT lt_productplantbasic BY product plant.

    LOOP AT lt_productplantbasic INTO DATA(ls_productplantbasic).
      DELETE lt_require WHERE material = ls_productplantbasic-product AND plant = ls_productplantbasic-plant.
    ENDLOOP.
    IF sy-subrc = 0 AND lt_require IS INITIAL.
      ls_res-_msgty = 'S'.
    ELSE.
      LOOP AT lt_require INTO ls_require.
        "Read data of storage location
        READ TABLE lt_productstoragelocationbasic INTO DATA(ls_productstoragelocationbasic) WITH KEY product = ls_require-material
                                                                                                     plant = ls_require-plant
                                                                                                     storagelocation = ls_require-storagelocation
                                                                                            BINARY SEARCH.
        IF sy-subrc = 0.
          "保管場所&1の品目&2の在庫は利用できません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 024 WITH ls_require-storagelocation ls_require-material INTO ls_res-_msg.
          ls_res-_msgty = 'E'.
          CLEAR ls_res-_data.
          EXIT.
        ENDIF.

        CLEAR ls_stock_sum.
        "Read data of material stock
        READ TABLE lt_stock_sum INTO ls_stock_sum WITH KEY material = ls_require-material
                                                           plant = ls_require-plant
                                                           storagelocation = ls_require-storagelocation
                                                           batch = ls_require-batch
                                                           sddocument = ls_require-salesorder
                                                           sddocumentitem = ls_require-salesorderitem
                                                           wbselementinternalid = ls_require-wbselementinternalid
                                                  BINARY SEARCH.
        "Require quantity > Stock quantity
        IF ls_require-quantityinbaseunit > ls_stock_sum-matlwrhsstkqtyinmatlbaseunit.
          IF ls_stock_sum-matlwrhsstkqtyinmatlbaseunit >= 0.
            lv_qty_short = ls_require-quantityinbaseunit - ls_stock_sum-matlwrhsstkqtyinmatlbaseunit.
          ELSE.
            lv_qty_short = ls_require-quantityinbaseunit.
          ENDIF.

          ls_res-_data-_material = ls_require-material.

          "品目&1が足りません、不足数量は&2！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 050 WITH ls_require-material lv_qty_short INTO ls_res-_msg.
          ls_res-_msgty = 'E'.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF ls_res-_msgty = 'S'.
        "品目は全て足りています、生産実績取消は可能です！
        MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 051 INTO ls_res-_msg.
      ENDIF.
    ENDIF.

    "ABAP->JSON
    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    "Set request data
    response->set_text( lv_res_body ).
  ENDMETHOD.
ENDCLASS.
