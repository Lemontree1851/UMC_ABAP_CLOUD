CLASS zcl_query_inventoryrequirement DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_query_inventoryrequirement IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    TYPES: BEGIN OF ty_metadata,
             id   TYPE string,
             uri  TYPE string,
             type TYPE string,
           END OF ty_metadata,
           BEGIN OF ty_record,
             metadata                      TYPE ty_metadata,
             material                      TYPE i_supplydemanditemtp-material,
             m_r_p_area                    TYPE i_supplydemanditemtp-mrparea,
             m_r_p_plant                   TYPE i_supplydemanditemtp-mrpplant,
             m_r_p_element_open_quantity   TYPE i_supplydemanditemtp-mrpelementopenquantity,
             mrpelementavailyorrqmtdatestr TYPE string,
             mrpelementavailyorrqmtdate    TYPE i_supplydemanditemtp-mrpelementavailyorrqmtdate,
             mrpelementbusinesspartner     TYPE i_supplydemanditemtp-mrpelementbusinesspartner,
             mrpelementbusinesspartnername TYPE i_supplydemanditemtp-mrpelementbusinesspartnername,
             m_r_p_element_category        TYPE i_supplydemanditemtp-mrpelementcategory,
             m_r_p_element_category_name   TYPE string,
             m_r_p_element_document_type   TYPE i_supplydemanditemtp-mrpelementdocumenttype,
             m_r_p_element                 TYPE i_supplydemanditemtp-mrpelement,
             m_r_p_element_item            TYPE i_supplydemanditemtp-mrpelementitem,
             m_r_p_element_schedule_line   TYPE i_supplydemanditemtp-mrpelementscheduleline,
             source_m_r_p_element          TYPE i_supplydemanditemtp-sourcemrpelement_2,
             source_m_r_p_element_category TYPE i_supplydemanditemtp-sourcemrpelementcategory,
             source_m_r_p_element_item     TYPE i_supplydemanditemtp-sourcemrpelementitem,
             sourcemrpelementscheduleline  TYPE i_supplydemanditemtp-sourcemrpelementscheduleline,
             high_level_material           TYPE string,
           END OF ty_record,
           BEGIN OF ty_result,
             results TYPE TABLE OF ty_record WITH DEFAULT KEY,
           END OF ty_result,
           BEGIN OF ty_response,
             count TYPE i,
             d     TYPE ty_result,
           END OF ty_response.

    TYPES: BEGIN OF ty_horizontal,
             plant                          TYPE string,
             m_r_p_controller               TYPE string,
             m_r_p_controller_name          TYPE string,
             m_r_p_area                     TYPE string,
             purchasing_group               TYPE string,
             a_b_c_indicator                TYPE string,
             external_product_group         TYPE string,
             lot_sizing_procedure           TYPE string,
             product_group                  TYPE string,
             product                        TYPE string,
             product_description            TYPE string,
             industry_standard_name         TYPE string,
             e_o_l_group                    TYPE string,
             is_main_product                TYPE string,
             supplier                       TYPE string,
             supplier_name                  TYPE string,
             supplier_material_number       TYPE string,
             product_manufacturer_number    TYPE string,
             manufacturer_number            TYPE string,
             material_planned_delivery_durn TYPE string,
             minimum_purchase_order_qty     TYPE string,
             supplier_price                 TYPE string,
             standard_price                 TYPE string,
             supplier_certorigin_country    TYPE string,
             classification                 TYPE string,
           END OF ty_horizontal,
           BEGIN OF ty_vertical,
             plant                          TYPE string,
             m_r_p_controller               TYPE string,
             m_r_p_controller_name          TYPE string,
             m_r_p_area                     TYPE string,
             product                        TYPE string,
             product_description            TYPE string,
             m_r_p_elements                 TYPE string,
             date                           TYPE string,
             required_qty                   TYPE string, " 所要数
             stock_qty                      TYPE string, " 在庫数
             supplied_qty                   TYPE string, " 供給数
             available_stock                TYPE string, " 利用可能在庫
             remaining_qty                  TYPE string, " 在庫残数
             supplier                       TYPE string,
             supplier_name                  TYPE string,
             status                         TYPE string,
             purchasing_group               TYPE string,
             a_b_c_indicator                TYPE string,
             external_product_group         TYPE string,
             lot_sizing_procedure           TYPE string,
             product_group                  TYPE string,
             industry_standard_name         TYPE string,
             e_o_l_group                    TYPE string,
             is_main_product                TYPE string,
             supplier_material_number       TYPE string,
             product_manufacturer_number    TYPE string,
             manufacturer_number            TYPE string,
             material_planned_delivery_durn TYPE string,
             minimum_purchase_order_qty     TYPE string,
             supplier_price                 TYPE string,
             standard_price                 TYPE string,
             supplier_certorigin_country    TYPE string,
           END OF ty_vertical.

    CONSTANTS: lc_classification_0 TYPE string VALUE `0.FORECAST`,
               lc_classification_1 TYPE string VALUE `1.SUPPLY`,
               lc_classification_5 TYPE string VALUE `5.DEMAND`,
               lc_classification_9 TYPE string VALUE `9.BALANCE`,
               lc_classification_r TYPE string VALUE `R.BALANCE`.

    CONSTANTS: lc_config_zpp015 TYPE ztbc_1001-zid VALUE `ZPP015`,
               lc_config_zpp016 TYPE ztbc_1001-zid VALUE `ZPP016`,
               lc_config_zpp017 TYPE ztbc_1001-zid VALUE `ZPP017`.

    CONSTANTS: lc_mrpelement_category_sh TYPE i_supplydemanditemtp-mrpelementcategory VALUE `SH`,
               lc_mrpelement_category_ba TYPE i_supplydemanditemtp-mrpelementcategory VALUE `BA`,
               lc_mrpelement_category_sb TYPE i_supplydemanditemtp-mrpelementcategory VALUE `SB`,
               lc_mrpelement_category_ar TYPE i_supplydemanditemtp-mrpelementcategory VALUE `AR`,
               lc_mrpelement_category_la TYPE i_supplydemanditemtp-mrpelementcategory VALUE `LA`,
               lc_mrpelement_category_be TYPE i_supplydemanditemtp-mrpelementcategory VALUE `BE`.

    CONSTANTS: lc_currency_jpy TYPE i_currency-currency VALUE `JPY`,
               lc_str_yes(3)   TYPE c VALUE `Yes`,
               lc_str_no(2)    TYPE c VALUE `No`,
               lc_str_main(4)  TYPE c VALUE `MAIN`.

    DATA: lt_data       TYPE TABLE OF zc_inventoryrequirement,
          ls_horizontal TYPE ty_horizontal,
          lt_horizontal TYPE TABLE OF ty_horizontal,
          ls_vertical   TYPE ty_vertical,
          lt_vertical   TYPE TABLE OF ty_vertical.

    DATA: lr_config_category  TYPE RANGE OF i_supplydemanditemtp-mrpelementcategory,
          lr_config_stocktype TYPE RANGE OF i_stockquantitycurrentvalue_2-inventorystocktype.

    DATA: ls_response TYPE ty_response.

    DATA: lv_count  TYPE i,
          lv_filter TYPE string.

    IF io_request->is_data_requested( ).
      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).

          LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
            CASE ls_filter_cond-name.
              WHEN 'PLANT'.
                DATA(lv_plant) = ls_filter_cond-range[ 1 ]-low.
              WHEN 'MRPAREA'.
                DATA(lv_mrparea) = ls_filter_cond-range[ 1 ]-low.
              WHEN 'MRPCONTROLLER'.
                DATA(lr_mrpcontroller) = ls_filter_cond-range.
              WHEN 'PURCHASINGGROUP'.
                DATA(lr_purchasinggroup) = ls_filter_cond-range.
              WHEN 'PRODUCTGROUP'.
                DATA(lr_productgroup) = ls_filter_cond-range.
              WHEN 'PRODUCTTYPE'.
                DATA(lr_producttype) = ls_filter_cond-range.
              WHEN 'PRODUCT'.
                DATA(lr_product) = ls_filter_cond-range.
                LOOP AT lr_product ASSIGNING FIELD-SYMBOL(<lr_product>).
                  <lr_product>-low  = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lr_product>-low ).
                  <lr_product>-high = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lr_product>-high ).
                ENDLOOP.
              WHEN 'SUPPLIER'.
                DATA(lr_supplier) = ls_filter_cond-range.
                LOOP AT lr_supplier ASSIGNING FIELD-SYMBOL(<lr_supplier>).
                  <lr_supplier>-low  = |{ <lr_supplier>-low  ALPHA = IN }|.
                  <lr_supplier>-high = |{ <lr_supplier>-high ALPHA = IN }|.
                ENDLOOP.
              WHEN 'SUPPLIERMATERIALNUMBER'.
                DATA(lr_suppliermaterialnumber) = ls_filter_cond-range.
              WHEN 'DISPLAYUNIT'.
                DATA(lv_displayunit) = ls_filter_cond-range[ 1 ]-low.
              WHEN 'PERIODENDDATE'.
                DATA(lv_periodenddate) = ls_filter_cond-range[ 1 ]-low.
              WHEN 'DISPLAYDIMENSION'.
                DATA(lv_displaydimension) = ls_filter_cond-range[ 1 ]-low.
              WHEN 'SELECTIONRULE'.
                DATA(lv_selectionrule) = ls_filter_cond-range[ 1 ]-low.
              WHEN 'SHOWINFORMATION'.
                DATA(lv_showinformation) = ls_filter_cond-range[ 1 ]-low.
              WHEN 'SHOWDETAILLINES'.
                DATA(lv_showdetaillines) = ls_filter_cond-range[ 1 ]-low.
              WHEN 'SHOWDEMAND'.
                DATA(lv_showdemand) = ls_filter_cond-range[ 1 ]-low.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.
        CATCH cx_rap_query_filter_no_range.
          "handle exception
          io_response->set_data( lt_data ).
      ENDTRY.

      DATA(lv_system_date) = cl_abap_context_info=>get_system_date( ).

      " 固定表示情報取得
      SELECT plant,
             product,
             purchasinggroup AS purchasing_group,
             mrpcontroller AS m_r_p_controller,
             abcindicator AS a_b_c_indicator,
             procurementtype,
             supplier,
             \_product-externalproductgroup AS external_product_group,
             \_product-productgroup AS product_group,
             \_product-producttype AS product_type,
             \_product-industrystandardname AS industry_standard_name,
             \_product-productmanufacturernumber AS product_manufacturer_number,
             \_product-manufacturernumber AS manufacturer_number,
             \_productdescription-productdescription AS product_description,
             \_mrpcontroller-mrpcontrollername AS m_r_p_controller_name,
             \_productplantsupplyplanning-lotsizingprocedure AS lot_sizing_procedure,
             \_productvaluation-standardprice,
             \_productvaluation-currency,
             \_productvaluation-priceunitqty,
             \_businesspartner-organizationbpname1 AS supplier_name,
             \_purchasinginforecord-purchasinginforecord,
             \_purchasinginforecord-suppliercertorigincountry AS supplier_certorigin_country,
             \_purchasinginforecord-suppliermaterialnumber AS supplier_material_number,
             standardprice AS standard_price,
             eolgroup AS e_o_l_group,
             ismainproduct AS is_main_product,
             supplierprice AS supplier_price
        FROM zc_inventoryrequirement_fixed
       WHERE plant = @lv_plant
         AND product IN @lr_product
         AND mrpcontroller IN @lr_mrpcontroller
         AND purchasinggroup IN @lr_purchasinggroup
         AND \_product-productgroup IN @lr_productgroup
         AND \_product-producttype IN @lr_producttype
         AND supplier IN @lr_supplier
         AND \_purchasinginforecord-suppliermaterialnumber IN @lr_suppliermaterialnumber
        INTO TABLE @DATA(lt_fixed_data).

      IF lt_fixed_data IS NOT INITIAL.

        " Begin 購買関連情報取得
        IF lv_showinformation = abap_true.
          SELECT purchasinginforecord,
                 purchasingorganization,
                 purchasinginforecordcategory,
                 plant,
                 minimumpurchaseorderquantity AS minimum_purchase_order_qty,
                 materialplanneddeliverydurn AS material_planned_delivery_durn,
                 netpriceamount,
                 currency,
                 materialpriceunitqty
            FROM i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_fixed_data
           WHERE purchasinginforecord = @lt_fixed_data-purchasinginforecord
             AND plant = @lt_fixed_data-plant
             AND ismarkedfordeletion IS INITIAL
            INTO TABLE @DATA(lt_purginforecdorgplntdata).
          SORT lt_purginforecdorgplntdata BY plant purchasinginforecord.
        ENDIF.
        " End 購買関連情報取得

        " Begin 在庫データ取得
        DATA(lt_temp) = lt_fixed_data.
        SORT lt_temp BY product.
        DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING product.
        SELECT a~plant,
               a~product,
               a~inventorystocktype,
               SUM( a~matlwrhsstkqtyinmatlbaseunit ) AS matlwrhsstkqtyinmatlbaseunit
          FROM i_stockquantitycurrentvalue_2( p_displaycurrency = @lc_currency_jpy ) WITH PRIVILEGED ACCESS AS a
          JOIN @lt_temp AS b ON b~product = a~product AND b~plant = a~plant
         WHERE valuationareatype = '1'
         GROUP BY a~plant,
                  a~product,
                  a~inventorystocktype
          INTO TABLE @DATA(lt_stockinfo).
        SORT lt_stockinfo BY product.
        " End 在庫データ取得

        " Begin MRP計画データ取得
        IF lv_mrparea IS INITIAL.
          lv_mrparea = lv_plant.
        ENDIF.

        DATA(lv_path)   = |/API_MRP_MATERIALS_SRV_01/SupplyDemandItems?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
        DATA(lv_select) = |Material,MRPArea,MRPPlant,MRPElementOpenQuantity,MRPElementAvailyOrRqmtDate,MRPElementBusinessPartner,| &&
                          |MRPElementBusinessPartnerName,MRPElementCategory,MRPElementCategoryName,MRPElementDocumentType,| &&
                          |MRPElement,MRPElementItem,MRPElementScheduleLine,SourceMRPElement,SourceMRPElementCategory,SourceMRPElementItem,SourceMRPElementScheduleLine|.

        lv_filter = |MRPPlant eq '{ lv_plant }' and MRPArea eq '{ lv_mrparea }'|.
        CLEAR lv_count.
        LOOP AT lt_temp INTO DATA(ls_temp).
          lv_count += 1.
          IF lv_count = 1.
            lv_filter = |{ lv_filter } and (Material eq '{ ls_temp-product }'|.
          ELSE.
            lv_filter = |{ lv_filter } or Material eq '{ ls_temp-product }'|.
          ENDIF.
        ENDLOOP.
        lv_filter = |{ lv_filter })|.
        zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                     iv_method      = if_web_http_client=>get
                                                     iv_select      = lv_select
                                                     iv_filter      = lv_filter
                                           IMPORTING ev_status_code = DATA(lv_status_code)
                                                     ev_response    = DATA(lv_response) ).
        IF lv_status_code = 200.
          REPLACE ALL OCCURRENCES OF `MRPElementAvailyOrRqmtDate`    IN lv_response WITH `Mrpelementavailyorrqmtdatestr`.
          REPLACE ALL OCCURRENCES OF `MRPElementBusinessPartner`     IN lv_response WITH `Mrpelementbusinesspartner`.
          REPLACE ALL OCCURRENCES OF `MRPElementBusinessPartnerName` IN lv_response WITH `Mrpelementbusinesspartnername`.
          REPLACE ALL OCCURRENCES OF `SourceMRPElementScheduleLine`  IN lv_response WITH `Sourcemrpelementscheduleline`.

          REPLACE ALL OCCURRENCES OF `__count`    IN lv_response WITH `count`.
          REPLACE ALL OCCURRENCES OF `__metadata` IN lv_response WITH `metadata`.
          REPLACE ALL OCCURRENCES OF `\/Date(`    IN lv_response  WITH ``.
          REPLACE ALL OCCURRENCES OF `)\/`        IN lv_response  WITH ``.

          xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
            ( xco_cp_json=>transformation->pascal_case_to_underscore )
            ( xco_cp_json=>transformation->boolean_to_abap_bool )
          ) )->write_to( REF #( ls_response ) ).

          DATA(lt_mrpdata) = ls_response-d-results.
          LOOP AT lt_mrpdata ASSIGNING FIELD-SYMBOL(<lfs_mrpdata>).
            IF <lfs_mrpdata>-mrpelementavailyorrqmtdatestr < 0.
              <lfs_mrpdata>-mrpelementavailyorrqmtdate = '19000101'.
            ELSEIF <lfs_mrpdata>-mrpelementavailyorrqmtdatestr = '253402214400000'.
              <lfs_mrpdata>-mrpelementavailyorrqmtdate = '99991231'.
            ELSE.
              <lfs_mrpdata>-mrpelementavailyorrqmtdate = xco_cp_time=>unix_timestamp(
                          iv_unix_timestamp = <lfs_mrpdata>-mrpelementavailyorrqmtdatestr / 1000
                       )->get_moment( )->as( xco_cp_time=>format->abap )->value+0(8).
            ENDIF.
            <lfs_mrpdata>-material = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_mrpdata>-material ).
          ENDLOOP.
          SORT lt_mrpdata BY material.
        ENDIF.
        " End MRP計画データ取得

        SELECT *
          FROM zc_tbc1001
         WHERE zid IN ( @lc_config_zpp015, @lc_config_zpp016, @lc_config_zpp017 )
           AND zvalue1 = @lv_selectionrule
          INTO TABLE @DATA(lt_config).        "#EC CI_ALL_FIELDS_NEEDED
        IF sy-subrc = 0.
          SORT lt_config BY zid.

          " MRPElement範囲取得
          DATA(lt_config_pp015) = lt_config.
          DELETE lt_config_pp015 WHERE zid <> lc_config_zpp015 OR zvalue4 <> lc_str_yes.
          lr_config_category = VALUE #( FOR item IN lt_config_pp015 ( sign = 'I' option = 'EQ' low = item-zvalue3 ) ).

          " 在庫タイプ取得
          DATA(lt_config_pp016) = lt_config.
          DELETE lt_config_pp016 WHERE zid <> lc_config_zpp016 OR zvalue4 <> lc_str_yes.
          lr_config_stocktype = VALUE #( FOR item IN lt_config_pp016 ( sign = 'I' option = 'EQ' low = item-zvalue3 ) ).

          " 安全在庫要否取得
          DATA(lt_config_pp017) = lt_config.
          DELETE lt_config_pp017 WHERE zid <> lc_config_zpp017 OR zvalue1 <> lv_selectionrule.
          READ TABLE lt_config_pp017 INTO DATA(ls_config_pp017) INDEX 1.
          IF sy-subrc = 0.
            DATA(lv_whether) = ls_config_pp017-zvalue3. " Yes/No
          ENDIF.
        ENDIF.

        " Begin 在庫データ集約
        ##ITAB_DB_SELECT
        SELECT a~plant,
               a~product,
               SUM( a~matlwrhsstkqtyinmatlbaseunit ) AS matlwrhsstkqtyinmatlbaseunit
          FROM @lt_stockinfo AS a
         WHERE a~inventorystocktype IN @lr_config_stocktype
         GROUP BY a~plant,
                  a~product
          INTO TABLE @DATA(lt_sum_stockinfo).
        SORT lt_sum_stockinfo BY product.
        " End 在庫データ集約

        IF lt_mrpdata IS NOT INITIAL.
          " 安全在庫取得
          DATA(lt_safety_stock) = lt_mrpdata.
          DELETE lt_safety_stock WHERE m_r_p_element_category <> lc_mrpelement_category_sh.

          " 購買依頼のデータ取得（Forecast行）
          DATA(lt_forecast) = lt_mrpdata.
          DELETE lt_forecast WHERE m_r_p_element_category <> lc_mrpelement_category_ba.

          " Begin 過去のForecast取得
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_forecast AS a
           WHERE mrpelementavailyorrqmtdate < @lv_system_date
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant
            INTO TABLE @DATA(lt_past_forecast).
          SORT lt_past_forecast BY material.
          " End 過去のForecast取得

          " Begin 指定期間内のForecast取得
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~mrpelementavailyorrqmtdate,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_forecast AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant,
                    a~mrpelementavailyorrqmtdate
            INTO TABLE @DATA(lt_period_forecast).
          SORT lt_period_forecast BY material mrpelementavailyorrqmtdate.
          " End 指定期間内のForecast取得

          " Begin 未来のForecast取得
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_forecast AS a
           WHERE mrpelementavailyorrqmtdate > @lv_periodenddate
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant
            INTO TABLE @DATA(lt_future_forecast).
          SORT lt_future_forecast BY material.
          " End 未来のForecast取得

          " Begin 合計のForecast取得
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_forecast AS a
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant
            INTO TABLE @DATA(lt_sum_forecast).
          SORT lt_sum_forecast BY material.
          " End 合計のForecast取得

          " Begin MRP計画データ集約
          DATA(lt_filter_mrpdata) = lt_mrpdata.
          DELETE lt_filter_mrpdata WHERE m_r_p_element_category NOT IN lr_config_category.

          DATA(lt_filter_mrpdata_sb) = lt_filter_mrpdata.
          DELETE lt_filter_mrpdata_sb WHERE m_r_p_element_category <> lc_mrpelement_category_sb.

          DATA(lt_filter_mrpdata_ar) = lt_filter_mrpdata.
          DELETE lt_filter_mrpdata_ar WHERE m_r_p_element_category <> lc_mrpelement_category_ar.

          IF lt_filter_mrpdata_sb IS NOT INITIAL.
            ##ITAB_KEY_IN_SELECT
            SELECT DISTINCT
                   plannedorder,
                   product
              FROM i_plannedorder
              JOIN @lt_filter_mrpdata_sb AS a ON i_plannedorder~plannedorder = a~source_m_r_p_element
              INTO TABLE @DATA(lt_plannedorder).
            SORT lt_plannedorder BY plannedorder.
          ENDIF.

          IF lt_filter_mrpdata_ar IS NOT INITIAL.
            SELECT manufacturingorder,
                   product
              FROM i_manufacturingorder
               FOR ALL ENTRIES IN @lt_filter_mrpdata_ar
             WHERE manufacturingorder = @lt_filter_mrpdata_ar-source_m_r_p_element
              INTO TABLE @DATA(lt_manufacturingorder).
            SORT lt_manufacturingorder BY manufacturingorder.
          ENDIF.
          " End MRP計画データ集約

          " Begin 安全在庫集約
          IF lv_whether = lc_str_yes.
            ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
            SELECT a~material,
                   a~m_r_p_area,
                   a~m_r_p_plant,
                   SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
              FROM @lt_safety_stock AS a
             GROUP BY a~material,
                      a~m_r_p_area,
                      a~m_r_p_plant
              INTO TABLE @DATA(lt_sum_safety_stock).
            SORT lt_sum_safety_stock BY material.
          ENDIF.
          " End 安全在庫集約

          " Begin 出荷通知数量取得
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~mrpelementavailyorrqmtdate,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate >= @lv_system_date
             AND m_r_p_element_category = @lc_mrpelement_category_la
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant,
                    a~mrpelementavailyorrqmtdate
            INTO TABLE @DATA(lt_ship_notification).
          SORT lt_ship_notification BY material mrpelementavailyorrqmtdate.
          " End 出荷通知数量取得

          " Begin「過去」のSUPPLYデータ処理
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate < @lv_system_date
             AND m_r_p_element_open_quantity > 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant
            INTO TABLE @DATA(lt_past_supply).
          SORT lt_past_supply BY material.
          " End「過去」のSUPPLYデータ処理

          " Begin「過去」のDEMANDデータ処理
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate < @lv_system_date
             AND m_r_p_element_open_quantity < 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant
            INTO TABLE @DATA(lt_past_demand).
          SORT lt_past_demand BY material.
          " End 「過去」のDEMANDデータ処理

          " Begin
          " End

          " Begin
          " End

          " Begin
          " End
        ENDIF.


        " 縦表示
        IF lv_displaydimension = 'V' AND lt_filter_mrpdata IS NOT INITIAL.
          DATA(lt_filter_mrpdata_labe) = lt_filter_mrpdata.
          DELETE lt_filter_mrpdata_labe WHERE m_r_p_element_category <> lc_mrpelement_category_la
                                           OR m_r_p_element_category <> lc_mrpelement_category_be.
          " Begin 発注ステータス
          ##ITAB_KEY_IN_SELECT
          SELECT DISTINCT
                 purchaseorder,
                 purchaseorderitem,
                 supplierconfirmationcategory
            FROM i_posupplierconfirmationapi01 WITH PRIVILEGED ACCESS AS a
            JOIN @lt_filter_mrpdata_labe AS b ON a~purchaseorder = b~m_r_p_element
                                             AND a~purchaseorderitem = b~m_r_p_element_item
            INTO TABLE @DATA(lt_posupplierconfirmation).
          SORT lt_posupplierconfirmation BY purchaseorder purchaseorderitem.
          " End 発注ステータス
        ENDIF.



      ENDIF.





















      APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).

      TRY.
          <lfs_data>-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
          ##NO_HANDLER
        CATCH cx_uuid_error.
          " handle exception
      ENDTRY.

      " item data
      LOOP AT lt_fixed_data ASSIGNING FIELD-SYMBOL(<lfs_fixed_data>).
        " 標準原価
        IF <lfs_fixed_data>-priceunitqty IS NOT INITIAL.
          <lfs_fixed_data>-standard_price = <lfs_fixed_data>-standardprice / <lfs_fixed_data>-priceunitqty.
          CONDENSE <lfs_fixed_data>-standard_price NO-GAPS.
          <lfs_fixed_data>-standard_price = zzcl_common_utils=>conversion_amount(
                                              iv_alpha = zzcl_common_utils=>lc_alpha_out
                                              iv_currency = <lfs_fixed_data>-currency
                                              iv_input = <lfs_fixed_data>-standard_price ).
        ELSE.
          CLEAR <lfs_fixed_data>-standard_price.
        ENDIF.

        " EOLグループ
        IF lv_showinformation = abap_true.
          DATA(lv_index) = find( val = <lfs_fixed_data>-industry_standard_name sub = '-' ).
          IF lv_index > 0.
            <lfs_fixed_data>-e_o_l_group = <lfs_fixed_data>-industry_standard_name+0(lv_index).
            SPLIT <lfs_fixed_data>-industry_standard_name AT '-' INTO TABLE DATA(lt_split).
            " 主品目
            IF lines( lt_split ) > 1 AND lt_split[ 2 ] = lc_str_main.
              <lfs_fixed_data>-is_main_product = abap_true.
            ENDIF.
          ELSE.
            <lfs_fixed_data>-e_o_l_group = <lfs_fixed_data>-industry_standard_name.
          ENDIF.

          READ TABLE lt_purginforecdorgplntdata INTO DATA(ls_purginforecdorgplntdata)
                                                 WITH KEY plant = <lfs_fixed_data>-plant
                                                          purchasinginforecord = <lfs_fixed_data>-purchasinginforecord
                                                          BINARY SEARCH.
          IF sy-subrc = 0.
            " 最新仕入単価
            IF ls_purginforecdorgplntdata-materialpriceunitqty IS NOT INITIAL.
              <lfs_fixed_data>-supplier_price = ls_purginforecdorgplntdata-netpriceamount / ls_purginforecdorgplntdata-materialpriceunitqty.
              CONDENSE <lfs_fixed_data>-supplier_price NO-GAPS.
              <lfs_fixed_data>-supplier_price = zzcl_common_utils=>conversion_amount(
                                                  iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                  iv_currency = ls_purginforecdorgplntdata-currency
                                                  iv_input = <lfs_fixed_data>-supplier_price ).

            ELSE.
              CLEAR <lfs_fixed_data>-supplier_price.
            ENDIF.
          ELSE.
            CLEAR ls_purginforecdorgplntdata.
          ENDIF.
        ENDIF.
      ENDLOOP.

      CASE lv_displaydimension.
          " 横表示
        WHEN 'H'.
          LOOP AT lt_fixed_data ASSIGNING <lfs_fixed_data>.
            CLEAR ls_horizontal.
            ls_horizontal = CORRESPONDING #( <lfs_fixed_data> ).

            READ TABLE lt_purginforecdorgplntdata INTO ls_purginforecdorgplntdata
                                                  WITH KEY plant = <lfs_fixed_data>-plant
                                                           purchasinginforecord = <lfs_fixed_data>-purchasinginforecord
                                                           BINARY SEARCH.
            IF sy-subrc = 0.
              ls_horizontal = CORRESPONDING #( BASE ( ls_horizontal ) ls_purginforecdorgplntdata ).
            ENDIF.

            ls_horizontal-supplier = |{ ls_horizontal-supplier ALPHA = OUT }|.
            ls_horizontal-product  = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = ls_horizontal-product ).

            " 選択条件「購買関連明細行表示」
            " はい：ForecastとR.BALANCEを表示する。
            " いいえ：ForecastとR.BALANCEを表示しない。
            IF lv_showdetaillines = abap_true.
              DATA(lv_times) = 5.
            ELSE.
              lv_times = 4.
            ENDIF.

            DO lv_times TIMES.
              CASE sy-index.
                WHEN 1.
                  ls_horizontal-classification = lc_classification_0. " 0.FORECAST
                WHEN 2.
                  ls_horizontal-classification = lc_classification_1. " 1.SUPPLY
                WHEN 3.
                  ls_horizontal-classification = lc_classification_5. " 5.DEMAND
                WHEN 4.
                  ls_horizontal-classification = lc_classification_9. " 9.BALANCE
                WHEN 5.
                  ls_horizontal-classification = lc_classification_r. " R.BALANCE
                WHEN OTHERS.
              ENDCASE.
              APPEND ls_horizontal TO lt_horizontal.
            ENDDO.
          ENDLOOP.

          SORT lt_horizontal BY product classification.
          <lfs_data>-dynamicdata = xco_cp_json=>data->from_abap( lt_horizontal )->apply( VALUE #(
             ( xco_cp_json=>transformation->underscore_to_pascal_case )
          ) )->to_string( ).

          " 縦表示
        WHEN 'V'.
          LOOP AT lt_filter_mrpdata ASSIGNING FIELD-SYMBOL(<lfs_filter_mrpdata>).
            DATA(lv_product) = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_filter_mrpdata>-material ).

            " 在庫行
            READ TABLE lt_sum_stockinfo INTO DATA(ls_sum_stockinfo) WITH KEY product = lv_product BINARY SEARCH.
            IF sy-subrc = 0.
              APPEND INITIAL LINE TO lt_vertical ASSIGNING FIELD-SYMBOL(<lfs_vertical_stock>).
              " 所要数
              <lfs_vertical_stock>-required_qty = 0.
              " 在庫数
              <lfs_vertical_stock>-stock_qty    = ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit.
              " 供給数
              <lfs_vertical_stock>-supplied_qty = 0.
              " 利用可能在庫 = 在庫＋供給数＋所要数
              <lfs_vertical_stock>-available_stock = ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit.
              " 在庫残数 = 在庫＋所要数
              <lfs_vertical_stock>-remaining_qty   = ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit.
            ENDIF.

            " 安全在庫行
            READ TABLE lt_sum_safety_stock INTO DATA(ls_sum_safety_stock) WITH KEY material = lv_product BINARY SEARCH.
            IF sy-subrc = 0.
              APPEND INITIAL LINE TO lt_vertical ASSIGNING FIELD-SYMBOL(<lfs_vertical2_safety_stock>).
              " 所要数
              <lfs_vertical_stock>-required_qty = ls_sum_safety_stock-m_r_p_element_open_quantity.
              " 在庫数
              <lfs_vertical_stock>-stock_qty    = 0.
              " 供給数
              <lfs_vertical_stock>-supplied_qty = 0.
              " 利用可能在庫 = 在庫＋供給数＋所要数
              <lfs_vertical_stock>-available_stock = ls_sum_safety_stock-m_r_p_element_open_quantity.
              " 在庫残数 = 在庫＋所要数
              <lfs_vertical_stock>-remaining_qty   = ls_sum_safety_stock-m_r_p_element_open_quantity.
            ENDIF.

            " 明細行
            APPEND INITIAL LINE TO lt_vertical ASSIGNING FIELD-SYMBOL(<lfs_vertical>).
            <lfs_vertical>-plant = <lfs_filter_mrpdata>-m_r_p_plant.
            <lfs_vertical>-m_r_p_area = <lfs_filter_mrpdata>-m_r_p_area.
            <lfs_vertical>-product = <lfs_filter_mrpdata>-material.
            <lfs_vertical>-date = <lfs_filter_mrpdata>-mrpelementavailyorrqmtdate+0(4) && '/' &&
                                  <lfs_filter_mrpdata>-mrpelementavailyorrqmtdate+4(2) && '/' &&
                                  <lfs_filter_mrpdata>-mrpelementavailyorrqmtdate+6(2).
            <lfs_vertical>-supplier = <lfs_filter_mrpdata>-mrpelementbusinesspartner.
            <lfs_vertical>-supplier_name = <lfs_filter_mrpdata>-mrpelementbusinesspartnername.

            <lfs_vertical>-required_qty    = 0. " 所要数
            <lfs_vertical>-stock_qty       = 0. " 在庫数
            <lfs_vertical>-supplied_qty    = 0. " 供給数
            <lfs_vertical>-available_stock = 0. " 利用可能在庫
            <lfs_vertical>-remaining_qty   = 0. " 在庫残数

            IF <lfs_filter_mrpdata>-m_r_p_element_open_quantity < 0.
              " 所要数
              <lfs_vertical>-required_qty = <lfs_filter_mrpdata>-m_r_p_element_open_quantity.
            ELSEIF <lfs_filter_mrpdata>-m_r_p_element_open_quantity > 0.
              " 供給数
              <lfs_vertical>-supplied_qty = <lfs_filter_mrpdata>-m_r_p_element_open_quantity.
            ENDIF.

            " 利用可能在庫 = 在庫＋供給数＋所要数
            <lfs_vertical>-available_stock = <lfs_vertical>-required_qty + <lfs_vertical>-supplied_qty.
            " 在庫残数 = 在庫＋所要数
            <lfs_vertical>-remaining_qty   = <lfs_vertical>-required_qty.

            READ TABLE lt_fixed_data INTO DATA(ls_fixed_data) WITH KEY product = lv_product BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_vertical> = CORRESPONDING #( BASE ( <lfs_vertical> ) ls_fixed_data ).

              " MRP要素
              CASE ls_fixed_data-procurementtype.
                WHEN 'E'.
                  <lfs_vertical>-m_r_p_elements = |{ <lfs_filter_mrpdata>-m_r_p_element }/{ <lfs_filter_mrpdata>-m_r_p_element_item }/| &&
                                                  |{ <lfs_filter_mrpdata>-m_r_p_element_schedule_line }/{ <lfs_filter_mrpdata>-m_r_p_element_document_type }|.
                WHEN 'F'.
                  IF <lfs_filter_mrpdata>-m_r_p_element_category = lc_mrpelement_category_sb.
                    READ TABLE lt_plannedorder INTO DATA(ls_plannedorder)
                                                WITH KEY plannedorder = <lfs_filter_mrpdata>-source_m_r_p_element
                                                BINARY SEARCH.
                    IF sy-subrc = 0.
                      <lfs_vertical>-m_r_p_elements = ls_plannedorder-product.
                    ENDIF.
                  ELSEIF <lfs_filter_mrpdata>-m_r_p_element_category = lc_mrpelement_category_ar.
                    READ TABLE lt_manufacturingorder INTO DATA(ls_manufacturingorder)
                                                      WITH KEY manufacturingorder = <lfs_filter_mrpdata>-source_m_r_p_element
                                                      BINARY SEARCH.
                    IF sy-subrc = 0.
                      <lfs_vertical>-m_r_p_elements = ls_manufacturingorder-product.
                    ENDIF.
                  ELSE.
                    <lfs_vertical>-m_r_p_elements = |{ <lfs_filter_mrpdata>-m_r_p_element }/{ <lfs_filter_mrpdata>-m_r_p_element_item }/| &&
                                                    |{ <lfs_filter_mrpdata>-m_r_p_element_schedule_line }/{ <lfs_filter_mrpdata>-m_r_p_element_document_type }|.
                  ENDIF.
                WHEN OTHERS.
              ENDCASE.

              READ TABLE lt_purginforecdorgplntdata INTO ls_purginforecdorgplntdata
                                                    WITH KEY plant = <lfs_vertical>-plant
                                                             purchasinginforecord = ls_fixed_data-purchasinginforecord
                                                             BINARY SEARCH.
              IF sy-subrc = 0.
                <lfs_vertical> = CORRESPONDING #( BASE ( <lfs_vertical> ) ls_purginforecdorgplntdata ).
              ENDIF.
            ENDIF.
          ENDLOOP.

          " 縦表示のステータス
          READ TABLE lt_posupplierconfirmation INTO DATA(ls_posupplierconfirmation)
                                                WITH KEY purchaseorder = <lfs_filter_mrpdata>-m_r_p_element
                                                         purchaseorderitem = <lfs_filter_mrpdata>-m_r_p_element_item
                                                         BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_vertical>-status = ls_posupplierconfirmation-supplierconfirmationcategory.
          ENDIF.

          SORT lt_vertical BY product.
          <lfs_data>-dynamicdata = xco_cp_json=>data->from_abap( lt_vertical )->apply( VALUE #(
             ( xco_cp_json=>transformation->underscore_to_pascal_case )
          ) )->to_string( ).
      ENDCASE.

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
    ENDIF.

  ENDMETHOD.

ENDCLASS.
