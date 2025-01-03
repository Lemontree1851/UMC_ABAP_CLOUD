CLASS zcl_query_pickinglist_std DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_query_pickinglist_std IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    TYPES: BEGIN OF lty_detail.
             INCLUDE TYPE ztpp_1016.
    TYPES:   plant                     TYPE zc_pickinglist_std-plant,
             material                  TYPE zc_pickinglist_std-material,
             material_name             TYPE zc_pickinglist_std-materialname,
             total_required_quantity   TYPE zc_pickinglist_std-totalrequiredquantity,
             storage_location_to_stock TYPE zc_pickinglist_std-storagelocationtostock,
             total_short_fall_quantity TYPE zc_pickinglist_std-totalshortfallquantity,
             storage_location_to       TYPE zc_pickinglist_std-storagelocationto,
             storage_location_to_name  TYPE zc_pickinglist_std-storagelocationtoname,
             product_name              TYPE zc_pickinglist_std-materialname,
             short_quantity_color      TYPE string,
           END OF lty_detail.

    TYPES: BEGIN OF ty_response_res,
             plant_id   TYPE string,
             loc_id     TYPE string,
             mat_id     TYPE string,
             upn_qty    TYPE string,
             mat_is_upn TYPE string,
           END OF ty_response_res,
           BEGIN OF ty_response_d,
             results TYPE TABLE OF ty_response_res WITH DEFAULT KEY,
           END OF ty_response_d,
           BEGIN OF ty_response,
             d TYPE ty_response_d,
           END OF ty_response.

    DATA: ls_data     TYPE zc_pickinglist_std,
          lt_data     TYPE TABLE OF zc_pickinglist_std,
          lt_detail   TYPE TABLE OF lty_detail,
          lr_material TYPE RANGE OF zc_pickinglist_std-material.
    DATA: ls_response TYPE ty_response.
    DATA: lv_rowno TYPE i,
          lv_index TYPE i.
    DATA: lv_required_quantity TYPE menge_d,
          lv_residue_stock     TYPE menge_d,
          lv_short_quantity    TYPE menge_d.

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          CASE ls_filter_cond-name.
            WHEN 'PLANT'.
              DATA(lr_plant) = ls_filter_cond-range.
            WHEN 'REQUISITIONDATE'.
              DATA(lr_requisitiondate) = ls_filter_cond-range.
              lr_requisitiondate[ 1 ]-option = zzcl_common_utils=>lc_range_option_le.
            WHEN 'STORAGELOCATIONTO'.
              DATA(lr_storagelocationto) = ls_filter_cond-range.
            WHEN 'STORAGELOCATIONFROM'.
              DATA(lr_storagelocationfrom) = ls_filter_cond-range.
            WHEN 'MATERIAL'.
              lr_material = VALUE #( FOR range IN ls_filter_cond-range (
                     sign   = range-sign
                     option = range-option
                     low    = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = range-low  )
                     high   = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = range-high )
              ) ).
            WHEN 'MRPCONTROLLER'.
              DATA(lr_mrpcontroller) = ls_filter_cond-range.
            WHEN 'PRODUCTIONSUPERVISOR'.
              DATA(lr_productionsupervisor) = ls_filter_cond-range.
            WHEN 'MATERIALGROUP'.
              DATA(lr_productgroup) = ls_filter_cond-range.
            WHEN 'LABORATORYORDESIGNOFFICE'.
              DATA(lr_laboratoryordesignoffice) = ls_filter_cond-range.
            WHEN 'EXTERNALPRODUCTGROUP'.
              DATA(lr_externalproductgroup) = ls_filter_cond-range.
            WHEN 'SIZEORDIMENSIONTEXT'.
              DATA(lr_sizeordimensiontext) = ls_filter_cond-range.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      CATCH cx_rap_query_filter_no_range.
        "handle exception
        io_response->set_data( lt_data ).
    ENDTRY.

    SELECT a~reservation,
           a~reservationitem,
           a~matlcomprequirementdate AS requisitiondate,
           a~material,
           a~plant,
           a~manufacturingorder,
           ( a~requiredquantity - a~withdrawnquantity ) AS requiredquantity,
           a~entryunit,
           a~storagelocation,
           a~inventoryspecialstockvalntype,
           a~productionsupervisor,
           a~assemblymrpcontroller AS mrpcontroller,
           a~confirmedavailablequantity,
           a~assembly AS product,
           b~baseunit,
           b~sizeordimensiontext,
           b~laboratoryordesignoffice,
           b~productgroup,
           b~externalproductgroup,
           \_storagelocation-storagelocationname ##SELECT_WITH_PRIVILEGED_ACCESS[_STORAGELOCATION]
      FROM i_mfgorderoperationcomponent WITH PRIVILEGED ACCESS AS a
      JOIN i_product WITH PRIVILEGED ACCESS AS b ON b~product = a~material
     WHERE b~producttype <> 'ZHLB'
       AND a~reservationisfinallyissued <> @abap_true
       AND a~matlcompismarkedfordeletion <> @abap_true
       AND a~isbulkmaterialcomponent <> @abap_true
       AND a~materialcomponentisphantomitem <> @abap_true
       AND a~requiredquantity IS NOT INITIAL
       AND a~goodsmovementisallowed = @abap_true
       AND a~goodsmovementtype = '261'
       AND a~inventoryspecialstockvalntype = ''
       AND a~plant IN @lr_plant
       AND a~material IN @lr_material
       AND a~matlcomprequirementdate IN @lr_requisitiondate
       AND a~storagelocation IN @lr_storagelocationto
       AND a~assemblymrpcontroller IN @lr_mrpcontroller
       AND a~productionsupervisor IN @lr_productionsupervisor
       AND b~productgroup IN @lr_productgroup
       AND b~laboratoryordesignoffice IN @lr_laboratoryordesignoffice
       AND b~externalproductgroup IN @lr_externalproductgroup
       AND b~sizeordimensiontext IN @lr_sizeordimensiontext
      INTO TABLE @DATA(lt_mfgorder).

    IF lt_mfgorder IS NOT INITIAL.
      TRY.
          DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
          " Get UWMS Access configuration
          SELECT SINGLE *
            FROM zc_tbc1001
           WHERE zid = 'ZBC002'
             AND zvalue1 = @lv_system_url
            INTO @DATA(ls_config).
          ##NO_HANDLER
        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      SELECT product,
             productname
        FROM i_producttext WITH PRIVILEGED ACCESS
       WHERE language = @sy-langu
        INTO TABLE @DATA(lt_producttext).
      SORT lt_producttext BY product.

      " 保管場所（TO)利用可能在庫数量を取得する
      DATA(lt_temp1) = lt_mfgorder.
      SORT lt_temp1 BY plant material storagelocation inventoryspecialstockvalntype.
      DELETE ADJACENT DUPLICATES FROM lt_temp1 COMPARING plant material storagelocation inventoryspecialstockvalntype.
      SELECT stock~plant,
             stock~material,
             stock~storagelocation,
             \_storagelocation-storagelocationname ##SELECT_WITH_PRIVILEGED_ACCESS[_STORAGELOCATION],
             stock~inventoryspecialstocktype,
             SUM( stock~matlwrhsstkqtyinmatlbaseunit ) AS matlwrhsstkqtyinmatlbaseunit,
             stock~materialbaseunit
        FROM i_materialstock_2 WITH PRIVILEGED ACCESS AS stock
        JOIN @lt_temp1 AS order ON  order~plant = stock~plant
                                AND order~material = stock~material
                                AND order~storagelocation = stock~storagelocation
                                AND order~inventoryspecialstockvalntype = stock~inventoryspecialstocktype
       WHERE stock~storagelocation IS NOT INITIAL
       GROUP BY stock~plant,
                stock~material,
                stock~storagelocation,
                \_storagelocation-storagelocationname,
                stock~inventoryspecialstocktype,
                stock~materialbaseunit
        INTO TABLE @DATA(lt_to_stock).
*      SORT lt_to_stock BY plant material inventoryspecialstocktype storagelocation matlwrhsstkqtyinmatlbaseunit DESCENDING.
      SORT lt_to_stock BY plant material storagelocation matlwrhsstkqtyinmatlbaseunit DESCENDING.

      " 保管場所（TO)供給要素311在庫移動指示入出庫予定を取得する
      DATA(lt_temp2) = lt_mfgorder.
      SORT lt_temp2 BY plant material storagelocation.
      DELETE ADJACENT DUPLICATES FROM lt_temp2 COMPARING plant material storagelocation.
      SELECT reservation~plant,
             reservation~product AS material,
             reservation~issuingorreceivingplant,
             reservation~issuingorreceivingstorageloc,
             SUM( reservation~resvnitmrequiredqtyinbaseunit ) AS resvnitmrequiredqtyinbaseunit,
             reservation~baseunit
        FROM i_reservationdocumentitem WITH PRIVILEGED ACCESS AS reservation
        JOIN @lt_temp2 AS order ON  order~plant = reservation~plant
                                AND order~material = reservation~product
                                AND order~plant = reservation~issuingorreceivingplant
                                AND order~storagelocation = reservation~issuingorreceivingstorageloc
       WHERE reservation~reservationitemisfinallyissued <> 'X'
         AND reservation~reservationitmismarkedfordeltn <> 'X'
         AND reservation~goodsmovementtype = '311'
         AND reservation~goodsmovementisallowed = 'X'
       GROUP BY reservation~plant,
                reservation~product,
                reservation~issuingorreceivingplant,
                reservation~issuingorreceivingstorageloc,
                reservation~baseunit
        INTO TABLE @DATA(lt_to_stock_311).
      SORT lt_to_stock_311 BY plant material issuingorreceivingplant issuingorreceivingstorageloc.

      " 保管場所（From)利用可能在庫数量を取得する
      DATA(lt_temp3) = lt_mfgorder.
      SORT lt_temp3 BY plant material.
      DELETE ADJACENT DUPLICATES FROM lt_temp3 COMPARING plant material.
      SELECT stock~plant,
             stock~material,
             stock~storagelocation,
             \_storagelocation-storagelocationname ##SELECT_WITH_PRIVILEGED_ACCESS[_STORAGELOCATION],
             SUM( stock~matlwrhsstkqtyinmatlbaseunit ) AS matlwrhsstkqtyinmatlbaseunit,
             stock~materialbaseunit
        FROM i_materialstock_2 WITH PRIVILEGED ACCESS AS stock
        JOIN @lt_temp3 AS order ON  order~plant = stock~plant
                                AND order~material = stock~material
       WHERE stock~storagelocation IS NOT INITIAL
         AND stock~storagelocation IN @lr_storagelocationfrom
       GROUP BY stock~plant,
                stock~material,
                stock~storagelocation,
                \_storagelocation-storagelocationname,
                stock~materialbaseunit
        INTO TABLE @DATA(lt_to_stock_from).
      SORT lt_to_stock_from BY plant material storagelocation matlwrhsstkqtyinmatlbaseunit DESCENDING.

      SELECT product,
             nmbrofgrorgislipstoprintqty
        FROM i_productstorage_2 WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_mfgorder
       WHERE product = @lt_mfgorder-material
        INTO TABLE @DATA(lt_productstorage).
      SORT lt_productstorage BY product.

      SELECT laboratoryordesignoffice,
             laboratoryordesignofficename
        FROM i_documentinforecordlbtryoffct WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_mfgorder
       WHERE laboratoryordesignoffice = @lt_mfgorder-laboratoryordesignoffice
         AND language = @sy-langu
        INTO TABLE @DATA(lt_laboratory).
      SORT lt_laboratory BY laboratoryordesignoffice.

      DATA(lo_unit) = cl_uom_conversion=>create( ).

      LOOP AT lt_mfgorder INTO DATA(ls_mfgorder) GROUP BY ( plant           = ls_mfgorder-plant
                                                            material        = ls_mfgorder-material
                                                            storagelocation = ls_mfgorder-storagelocation )
                                                 ASSIGNING FIELD-SYMBOL(<lfs_group>).
        CLEAR: ls_data,lt_detail.

        ls_data-plant = <lfs_group>-plant.
        ls_data-material = <lfs_group>-material.
        ls_data-storagelocationto = <lfs_group>-storagelocation.

        READ TABLE lt_producttext INTO DATA(ls_producttext) WITH KEY product = <lfs_group>-material BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-materialname = ls_producttext-productname.
        ENDIF.

        READ TABLE lt_to_stock INTO DATA(ls_to_stock) WITH KEY plant = <lfs_group>-plant
                                                               material = <lfs_group>-material
                                                               storagelocation = <lfs_group>-storagelocation
                                                               BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-storagelocationtostock += ls_to_stock-matlwrhsstkqtyinmatlbaseunit.
        ENDIF.

        READ TABLE lt_to_stock_311 INTO DATA(ls_to_stock_311) WITH KEY plant = <lfs_group>-plant
                                                                       material = <lfs_group>-material
                                                                       issuingorreceivingplant = <lfs_group>-plant
                                                                       issuingorreceivingstorageloc = <lfs_group>-storagelocation
                                                                       BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-storagelocationtostock += ls_to_stock_311-resvnitmrequiredqtyinbaseunit.
        ENDIF.

        LOOP AT lt_to_stock_from INTO DATA(ls_to_stock_from) WHERE plant    = <lfs_group>-plant
                                                               AND material = <lfs_group>-material
                                                               AND storagelocation <> ls_data-storagelocationto.
          ls_data-storagelocationfrom = ls_to_stock_from-storagelocation.
          ls_data-storagelocationfromname = ls_to_stock_from-storagelocationname.
          ls_data-storagelocationfromstock = ls_to_stock_from-matlwrhsstkqtyinmatlbaseunit.
          EXIT.
        ENDLOOP.

        READ TABLE lt_productstorage INTO DATA(ls_productstorage) WITH KEY product = <lfs_group>-material BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-gr_slipsquantity = ls_productstorage-nmbrofgrorgislipstoprintqty.
        ENDIF.

        LOOP AT GROUP <lfs_group> ASSIGNING FIELD-SYMBOL(<lfs_group_item>).
          lv_index += 1.
          IF lv_index = 1.
            ls_data-storagelocationtoname = <lfs_group_item>-storagelocationname.
            ls_data-baseunit = <lfs_group_item>-baseunit.
            ls_data-sizeordimensiontext = <lfs_group_item>-sizeordimensiontext.
            ls_data-laboratoryordesignoffice = <lfs_group_item>-laboratoryordesignoffice.
            ls_data-externalproductgroup = <lfs_group_item>-externalproductgroup.
            ls_data-materialgroup = <lfs_group_item>-productgroup.

            READ TABLE lt_laboratory INTO DATA(ls_laboratory) WITH KEY laboratoryordesignoffice = <lfs_group_item>-laboratoryordesignoffice BINARY SEARCH.
            IF sy-subrc = 0.
              ls_data-laboratoryordesignofficename = ls_laboratory-laboratoryordesignofficename.
            ENDIF.
          ENDIF.

          ls_data-totalrequiredquantity += <lfs_group_item>-requiredquantity.

          APPEND VALUE #( manufacturing_order          = |{ <lfs_group_item>-manufacturingorder ALPHA = OUT }|
                          product                      = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_group_item>-product )
                          material                     = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_group_item>-material )
                          base_unit                    = <lfs_group_item>-baseunit
                          required_quantity            = <lfs_group_item>-requiredquantity
                          confirmed_available_quantity = <lfs_group_item>-confirmedavailablequantity
                          storage_location             = <lfs_group_item>-storagelocation
                          requisition_date             = <lfs_group_item>-requisitiondate
                          production_supervisor        = <lfs_group_item>-productionsupervisor
                          m_r_p_controller             = <lfs_group_item>-mrpcontroller
          ) TO lt_detail.
        ENDLOOP.

        " 合計製造指図所要量＞合計保管場所(TO)利用可能在庫数量の場合に欠品品目対象になる
        IF ls_data-totalrequiredquantity > ls_data-storagelocationtostock.
          lv_rowno += 1.
          ls_data-rowno = lv_rowno.
          ls_data-totalshortfallquantity = ls_data-totalrequiredquantity - ls_data-storagelocationtostock.
          ls_data-totaltransferquantity  = ls_data-totalshortfallquantity.

          IF ls_config IS NOT INITIAL AND ls_data-storagelocationfrom IS NOT INITIAL.
            DATA(lv_filter) = |PLANT_ID eq '{ ls_data-plant }' and MAT_ID eq '{ ls_data-material }' and LOC_ID eq '{ ls_data-storagelocationfrom }'|.
            CONDENSE ls_config-zvalue2 NO-GAPS. " ODATA_URL
            CONDENSE ls_config-zvalue3 NO-GAPS. " TOKEN_URL
            CONDENSE ls_config-zvalue4 NO-GAPS. " CLIENT_ID
            CONDENSE ls_config-zvalue5 NO-GAPS. " CLIENT_SECRET
            zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |{ ls_config-zvalue2 }/odata/v2/TableService/INV03_HT_LIST|
                                                                    iv_odata_filter  = lv_filter
                                                                    iv_token_url     = CONV #( ls_config-zvalue3 )
                                                                    iv_client_id     = CONV #( ls_config-zvalue4 )
                                                                    iv_client_secret = CONV #( ls_config-zvalue5 )
                                                                    iv_authtype      = 'OAuth2.0'
                                                          IMPORTING ev_status_code   = DATA(lv_status_code)
                                                                    ev_response      = DATA(lv_response) ).
            IF lv_status_code = 200.
              xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
*                ( xco_cp_json=>transformation->pascal_case_to_underscore )
                ( xco_cp_json=>transformation->boolean_to_abap_bool )
              ) )->write_to( REF #( ls_response ) ).

              IF ls_response-d-results IS NOT INITIAL.
                ls_data-m_card_quantity = ls_response-d-results[ 1 ]-upn_qty.
                ls_data-m_card          = ls_response-d-results[ 1 ]-mat_is_upn.
              ENDIF.
            ENDIF.
          ENDIF.

          SORT lt_detail BY requisition_date manufacturing_order.
          CLEAR lv_required_quantity.
          lv_residue_stock = ls_data-storagelocationtostock.
          LOOP AT lt_detail ASSIGNING FIELD-SYMBOL(<lfs_detail>).
            lv_residue_stock -= lv_required_quantity.
            lv_required_quantity = <lfs_detail>-required_quantity.

            <lfs_detail>-plant                     = ls_data-plant.
            <lfs_detail>-storage_location_to       = ls_data-storagelocationto.
            <lfs_detail>-storage_location_to_name  = ls_data-storagelocationtoname.
            <lfs_detail>-total_required_quantity   = ls_data-totalrequiredquantity.
            <lfs_detail>-total_short_fall_quantity = ls_data-totalshortfallquantity.
            <lfs_detail>-storage_location_to_stock = ls_data-storagelocationtostock.

            READ TABLE lt_producttext INTO ls_producttext WITH KEY product = <lfs_detail>-product BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_detail>-product_name = ls_producttext-productname.
            ENDIF.
            READ TABLE lt_producttext INTO ls_producttext WITH KEY product = <lfs_detail>-material BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_detail>-material_name = ls_producttext-productname.
            ENDIF.

            " 残利用可能在庫（TO)
            <lfs_detail>-residue_stock_quantity = lv_residue_stock.

            "欠品数量
            lv_short_quantity = lv_residue_stock - <lfs_detail>-required_quantity.
            IF lv_short_quantity >= 0.
              <lfs_detail>-short_quantity = 0.
              <lfs_detail>-short_quantity_color = 'green'.
            ELSE.
              <lfs_detail>-short_quantity = abs( lv_short_quantity ).
              <lfs_detail>-short_quantity_color = 'red'.
            ENDIF.

            TRY.
                <lfs_detail>-base_unit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_detail>-base_unit ).
                ##NO_HANDLER
              CATCH zzcx_custom_exception.
                " handle exception
            ENDTRY.
          ENDLOOP.

          ls_data-detailsjson = xco_cp_json=>data->from_abap( lt_detail )->apply( VALUE #(
            ( xco_cp_json=>transformation->underscore_to_pascal_case )
          ) )->to_string( ).

          APPEND ls_data TO lt_data.
        ENDIF.
        CLEAR lv_index.
      ENDLOOP.
    ENDIF.

    " Filtering
    zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
                                           it_excluded = VALUE #( ( fieldname = 'REQUISITIONDATE' )
                                                                  ( fieldname = 'STORAGELOCATIONFROM' )
                                                                  ( fieldname = 'MATERIAL' ) )
                                 CHANGING  ct_data     = lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    "Sort
    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                               CHANGING  ct_data  = lt_data ).
    " Paging
    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                              CHANGING  ct_data   = lt_data ).

    io_response->set_data( lt_data ).
  ENDMETHOD.

ENDCLASS.
