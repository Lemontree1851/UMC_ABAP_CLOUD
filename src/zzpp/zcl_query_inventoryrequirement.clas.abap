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
             high_level_material           TYPE matnr,
             planned_order                 TYPE i_plannedorder-plannedorder,
             manufacturing_order           TYPE i_manufacturingorder-manufacturingorder,
             product                       TYPE matnr,
             yearmonth(6)                  TYPE n,
             yearweek(6)                   TYPE n,
             update_seq                    TYPE sy-index,
             balance_9                     TYPE menge_d,
             balance_r                     TYPE menge_d,
             calculation_seq               TYPE sy-index,
           END OF ty_record,
           BEGIN OF ty_result,
             results TYPE TABLE OF ty_record WITH DEFAULT KEY,
           END OF ty_result,
           BEGIN OF ty_response,
             count TYPE i,
             d     TYPE ty_result,
           END OF ty_response.

*    TYPES: BEGIN OF ty_horizontal,
*             plant                          TYPE string,
*             m_r_p_controller               TYPE string,
*             m_r_p_controller_name          TYPE string,
*             m_r_p_area                     TYPE string,
*             purchasing_group               TYPE string,
*             a_b_c_indicator                TYPE string,
*             external_product_group         TYPE string,
*             lot_sizing_procedure           TYPE string,
*             product_group                  TYPE string,
*             product                        TYPE string,
*             product_description            TYPE string,
*             industry_standard_name         TYPE string,
*             e_o_l_group                    TYPE string,
*             is_main_product                TYPE string,
*             supplier                       TYPE string,
*             supplier_name                  TYPE string,
*             supplier_material_number       TYPE string,
*             product_manufacturer_number    TYPE string,
*             manufacturer_number            TYPE string,
*             material_planned_delivery_durn TYPE string,
*             minimum_purchase_order_qty     TYPE string,
*             supplier_price                 TYPE string,
*             standard_price                 TYPE string,
*             supplier_certorigin_country    TYPE string,
*             shipment_notice_qty            TYPE string, " 出荷通知数量
*             out_of_stock_date              TYPE string, " 欠品日付
*             safety_stock                   TYPE string, " 安全在庫
*             stock_qty                      TYPE string, " 在庫数量
*             classification                 TYPE string, " 分類
*             past_qty                       TYPE string, " 過去
*             future_qty                     TYPE string, " 未来
*             total_qty                      TYPE string, " 合計
*           END OF ty_horizontal.

    TYPES: BEGIN OF ty_vertical,
             plant                          TYPE werks_d,
             m_r_p_controller               TYPE string,
             m_r_p_controller_name          TYPE string,
             m_r_p_area                     TYPE string,
             product                        TYPE matnr,
             product_description            TYPE string,
             m_r_p_elements                 TYPE string,  " MRP要素
             date                           TYPE string,  " 日付
             required_qty                   TYPE menge_d, " 所要数
             stock_qty                      TYPE menge_d, " 在庫数
             supplied_qty                   TYPE menge_d, " 供給数
             available_stock                TYPE menge_d, " 利用可能在庫
             remaining_qty                  TYPE menge_d, " 在庫残数
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
             material_planned_delivery_durn TYPE plifz,
             minimum_purchase_order_qty     TYPE menge_d,
             supplier_price                 TYPE i_purginforecdorgplntdataapi01-netpriceamount,
             standard_price                 TYPE i_purginforecdorgplntdataapi01-netpriceamount,
             supplier_certorigin_country    TYPE string,
           END OF ty_vertical.

    TYPES:BEGIN OF ty_outofstockdate,
            product TYPE matnr,
            date    TYPE string,
          END OF ty_outofstockdate,
          BEGIN OF ty_update_sequence,
            product                    TYPE matnr,
            sequence                   TYPE sy-index,
            mrpelementavailyorrqmtdate TYPE i_supplydemanditemtp-mrpelementavailyorrqmtdate,
            yearmonth(6)               TYPE n,
            yearweek(6)                TYPE n,
            quantity                   TYPE menge_d,
          END OF ty_update_sequence.

    CONSTANTS: lc_classification_0 TYPE string VALUE `0.FORECAST`,
               lc_classification_1 TYPE string VALUE `1.SUPPLY`,
               lc_classification_5 TYPE string VALUE `5.DEMAND`,
               lc_classification_s TYPE string VALUE `SUBDEMAND`,
               lc_classification_9 TYPE string VALUE `9.BALANCE`,
               lc_classification_r TYPE string VALUE `R.BALANCE`.

    CONSTANTS: lc_config_zpp015 TYPE ztbc_1001-zid VALUE `ZPP015`,
               lc_config_zpp016 TYPE ztbc_1001-zid VALUE `ZPP016`,
               lc_config_zpp017 TYPE ztbc_1001-zid VALUE `ZPP017`,
               lc_config_zpp019 TYPE ztbc_1001-zid VALUE `ZPP019`.

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

    DATA: lt_data            TYPE TABLE OF zc_inventoryrequirement,
          ls_horizontal      TYPE zspp_1003, "ty_horizontal,
          lt_horizontal      TYPE TABLE OF zspp_1003, "ty_horizontal,
          ls_vertical        TYPE ty_vertical,
          lt_vertical        TYPE TABLE OF ty_vertical,
          lt_dynamic_col     TYPE zzcl_common_utils=>tt_add_coll,
          lt_outofstockdate  TYPE TABLE OF ty_outofstockdate,
          lt_update_sequence TYPE TABLE OF ty_update_sequence.

    DATA: lr_plant            TYPE RANGE OF i_plant-plant,
          lr_config_category  TYPE RANGE OF i_supplydemanditemtp-mrpelementcategory,
          lr_config_stocktype TYPE RANGE OF i_stockquantitycurrentvalue_2-inventorystocktype.

    DATA: ls_response TYPE ty_response.

    DATA: lv_periodenddate   TYPE datum,
          lv_filter          TYPE string,
          lv_count           TYPE sy-index,
          lv_update_seq      TYPE sy-index,
          lv_calculation_seq TYPE sy-index,
          lv_quantity        TYPE menge_d,
          lv_col_date        TYPE datum,
          lv_begin_month(2)  TYPE n,
          lv_end_month(2)    TYPE n,
          lv_col_month(2)    TYPE n,
          lv_past_9balance   TYPE menge_d,
          lv_past_rbalance   TYPE menge_d,
          lv_future_9balance TYPE menge_d,
          lv_future_rbalance TYPE menge_d,
          lv_sum_9balance    TYPE menge_d,
          lv_sum_rbalance    TYPE menge_d.

    DATA: lv_previous_available_stock TYPE menge_d,
          lv_previous_remaining_qty   TYPE menge_d.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.

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
                lv_periodenddate = ls_filter_cond-range[ 1 ]-low.
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
             goodsreceiptduration,
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

*&--Authorization Check
      DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
      DATA(lv_plant_check) = zzcl_common_utils=>get_plant_by_user( lv_user_email ).
      IF lv_plant_check IS INITIAL.
        CLEAR lt_fixed_data.
      ELSE.
        SPLIT lv_plant_check AT '&' INTO TABLE DATA(lt_plant_check).
        CLEAR lr_plant.
        lr_plant = VALUE #( FOR plant IN lt_plant_check ( sign = 'I' option = 'EQ' low = plant ) ).
        DELETE lt_fixed_data WHERE plant NOT IN lr_plant.
      ENDIF.
*&--Authorization Check

      IF lt_fixed_data IS NOT INITIAL.
        SORT lt_fixed_data BY product.

        SELECT *
          FROM zc_tbc1001
         WHERE zid IN ( @lc_config_zpp015, @lc_config_zpp016, @lc_config_zpp017, @lc_config_zpp019 )
           AND zvalue1 = @lv_selectionrule
          INTO TABLE @DATA(lt_config).        "#EC CI_ALL_FIELDS_NEEDED
        SORT lt_config BY zid.

        IF lt_config IS NOT INITIAL.
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
            DATA(lv_whether_safety) = ls_config_pp017-zvalue3. " Yes/No
          ENDIF.

          " 入庫処理日数考慮要否
          DATA(lt_config_pp019) = lt_config.
          DELETE lt_config_pp019 WHERE zid <> lc_config_zpp019 OR zvalue1 <> lv_selectionrule.
          READ TABLE lt_config_pp019 INTO DATA(ls_config_pp019) INDEX 1.
          IF sy-subrc = 0.
            DATA(lv_whether_process) = ls_config_pp019-zvalue2. " Yes/No
          ENDIF.
        ENDIF.

        " Begin 購買関連情報取得
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

        IF lines( lt_temp ) < 30.
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
        ENDIF.

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

*&--MOD BEGIN BY XINLEI XU 2025/03/04 Optimize for speed
*          xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
*             ( xco_cp_json=>transformation->pascal_case_to_underscore )
*             ( xco_cp_json=>transformation->boolean_to_abap_bool )
*          ) )->write_to( REF #( ls_response ) ).

          /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                               pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                     CHANGING  data = ls_response ).
*&--MOD END BY XINLEI XU 2025/03/04

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
            <lfs_mrpdata>-product = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_mrpdata>-material ).

            " 入庫処理日数考慮要否
            IF lv_whether_process = lc_str_yes.
              READ TABLE lt_fixed_data INTO DATA(ls_fixed_data) WITH KEY product = <lfs_mrpdata>-product BINARY SEARCH.
              IF sy-subrc = 0.
                " - 入庫処理日数
                <lfs_mrpdata>-mrpelementavailyorrqmtdate = zzcl_common_utils=>calc_date_subtract( date = <lfs_mrpdata>-mrpelementavailyorrqmtdate
                                                                                                  day  = CONV #( ls_fixed_data-goodsreceiptduration ) ).
              ELSE.
                CLEAR ls_fixed_data.
              ENDIF.
            ENDIF.

            <lfs_mrpdata>-yearmonth = <lfs_mrpdata>-mrpelementavailyorrqmtdate+0(6).
            TRY.
                cl_scal_utils=>date_get_week(
                  EXPORTING
                    iv_date = <lfs_mrpdata>-mrpelementavailyorrqmtdate
                  IMPORTING
                    ev_year_week = <lfs_mrpdata>-yearweek ).
                ##NO_HANDLER
              CATCH cx_scal.
                "handle exception
            ENDTRY.

            IF <lfs_mrpdata>-m_r_p_element_category = lc_mrpelement_category_sb.
              <lfs_mrpdata>-planned_order = |{ <lfs_mrpdata>-source_m_r_p_element ALPHA = IN }|.
            ENDIF.
            IF <lfs_mrpdata>-m_r_p_element_category = lc_mrpelement_category_ar.
              <lfs_mrpdata>-manufacturing_order = |{ <lfs_mrpdata>-source_m_r_p_element ALPHA = IN }|.
            ENDIF.
          ENDLOOP.
          SORT lt_mrpdata BY material.
        ENDIF.
        " End MRP計画データ取得

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

          " Begin 安全在庫集約
          IF lv_whether_safety = lc_str_yes.
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
          " By Day
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

          " By Week
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~yearweek,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_forecast AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant,
                    a~yearweek
            INTO TABLE @DATA(lt_week_forecast).
          SORT lt_week_forecast BY material yearweek.

          " By Month
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~yearmonth,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_forecast AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant,
                    a~yearmonth
            INTO TABLE @DATA(lt_month_forecast).
          SORT lt_month_forecast BY material yearmonth.
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
            SELECT plannedorder,
                   i_plannedorder~product
              FROM i_plannedorder
               FOR ALL ENTRIES IN @lt_filter_mrpdata_sb
             WHERE plannedorder = @lt_filter_mrpdata_sb-planned_order
              INTO TABLE @DATA(lt_plannedorder).
            SORT lt_plannedorder BY plannedorder.
          ENDIF.

          IF lt_filter_mrpdata_ar IS NOT INITIAL.
            SELECT manufacturingorder,
                   product
              FROM i_manufacturingorder
               FOR ALL ENTRIES IN @lt_filter_mrpdata_ar
             WHERE manufacturingorder = @lt_filter_mrpdata_ar-manufacturing_order
              INTO TABLE @DATA(lt_manufacturingorder).
            SORT lt_manufacturingorder BY manufacturingorder.
          ENDIF.

          SORT lt_filter_mrpdata BY product mrpelementavailyorrqmtdate.

          CLEAR: lt_outofstockdate,lt_update_sequence.
          lv_update_seq = 1.
          LOOP AT lt_filter_mrpdata INTO DATA(ls_filter_mrpdata)
                                    GROUP BY ( product = ls_filter_mrpdata-product )
                                    ASSIGNING FIELD-SYMBOL(<lfs_filter_mrpdata_group>).
            CLEAR: lv_calculation_seq, lv_quantity.
            READ TABLE lt_sum_stockinfo INTO DATA(ls_sum_stockinfo)
                                         WITH KEY product = <lfs_filter_mrpdata_group>-product BINARY SEARCH.
            IF sy-subrc = 0.
              lv_quantity += ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit.
            ENDIF.

            READ TABLE lt_sum_safety_stock INTO DATA(ls_sum_safety_stock)
                                           WITH KEY material = <lfs_filter_mrpdata_group>-product BINARY SEARCH.
            IF sy-subrc = 0.
              lv_quantity += ls_sum_safety_stock-m_r_p_element_open_quantity.
            ENDIF.

            LOOP AT GROUP <lfs_filter_mrpdata_group> ASSIGNING FIELD-SYMBOL(<lfs_filter_mrpdata>).
              lv_calculation_seq += 1.
              " 上位品目
              IF <lfs_filter_mrpdata>-m_r_p_element_category = lc_mrpelement_category_sb.
                READ TABLE lt_plannedorder INTO DATA(ls_plannedorder)
                                            WITH KEY plannedorder = <lfs_filter_mrpdata>-planned_order
                                            BINARY SEARCH.
                IF sy-subrc = 0.
                  <lfs_filter_mrpdata>-high_level_material = ls_plannedorder-product.
                ELSE.
                  CLEAR ls_plannedorder.
                ENDIF.
              ELSEIF <lfs_filter_mrpdata>-m_r_p_element_category = lc_mrpelement_category_ar.
                READ TABLE lt_manufacturingorder INTO DATA(ls_manufacturingorder)
                                                  WITH KEY manufacturingorder = <lfs_filter_mrpdata>-manufacturing_order
                                                  BINARY SEARCH.
                IF sy-subrc = 0.
                  <lfs_filter_mrpdata>-high_level_material = ls_manufacturingorder-product.
                ELSE.
                  CLEAR ls_manufacturingorder.
                ENDIF.
              ENDIF.

              " 累加
              lv_quantity += <lfs_filter_mrpdata>-m_r_p_element_open_quantity.

              " 9.BALANCE
              <lfs_filter_mrpdata>-balance_9 = lv_quantity.
              " R.BALANCE
              <lfs_filter_mrpdata>-balance_r = lv_quantity.
              " Calculation order
              <lfs_filter_mrpdata>-calculation_seq = lv_calculation_seq.

              " 计算 R.BALANCE 用
              IF <lfs_filter_mrpdata>-m_r_p_element_category = lc_mrpelement_category_la. " 出荷通知
                APPEND VALUE #( product   = <lfs_filter_mrpdata>-product
                                sequence  = lv_update_seq
                                mrpelementavailyorrqmtdate = <lfs_filter_mrpdata>-mrpelementavailyorrqmtdate
                                yearmonth = <lfs_filter_mrpdata>-yearmonth
                                yearweek  = <lfs_filter_mrpdata>-yearweek
                                quantity  = <lfs_filter_mrpdata>-m_r_p_element_open_quantity ) TO lt_update_sequence.
                lv_update_seq += 1.
              ELSE.
                <lfs_filter_mrpdata>-update_seq = lv_update_seq.
              ENDIF.

              " 最初欠品日付
              IF <lfs_filter_mrpdata>-balance_9 < 0 AND NOT line_exists( lt_outofstockdate[ product = <lfs_filter_mrpdata_group>-product ] ).
                APPEND VALUE #( product = <lfs_filter_mrpdata_group>-product
                                date    = <lfs_filter_mrpdata>-mrpelementavailyorrqmtdate+0(4) && '/' &&
                                          <lfs_filter_mrpdata>-mrpelementavailyorrqmtdate+4(2) && '/' &&
                                          <lfs_filter_mrpdata>-mrpelementavailyorrqmtdate+6(2)
                ) TO lt_outofstockdate.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
          SORT lt_update_sequence BY product sequence.
          " End MRP計画データ集約

          " Begin 出荷通知数量取得
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate >= @lv_system_date
             AND m_r_p_element_category = @lc_mrpelement_category_la
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant
            INTO TABLE @DATA(lt_ship_qty).
          SORT lt_ship_qty BY material.

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
            INTO TABLE @DATA(lt_ship_qty_date).
          SORT lt_ship_qty_date BY material mrpelementavailyorrqmtdate.
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

          " Begin 指定期間内のSUPPLY取得
          " By Day
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~mrpelementavailyorrqmtdate,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
             AND m_r_p_element_open_quantity > 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant,
                    a~mrpelementavailyorrqmtdate
            INTO TABLE @DATA(lt_period_supply).
          SORT lt_period_supply BY material mrpelementavailyorrqmtdate.

          " By Week
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~yearweek,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
             AND m_r_p_element_open_quantity > 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant,
                    a~yearweek
            INTO TABLE @DATA(lt_week_supply).
          SORT lt_week_supply BY material yearweek.

          " By Month
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~yearmonth,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
             AND m_r_p_element_open_quantity > 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant,
                    a~yearmonth
            INTO TABLE @DATA(lt_month_supply).
          SORT lt_month_supply BY material yearmonth.
          " End 指定期間内のSUPPLY取得

          " Begin 列「未来」のSUPPLYデータ処理
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate > @lv_periodenddate
             AND m_r_p_element_open_quantity > 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant
            INTO TABLE @DATA(lt_future_supply).
          SORT lt_future_supply BY material.
          " End 列「未来」のSUPPLYデータ処理

          " Begin 列「合計」のSUPPLYデータ処理
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE m_r_p_element_open_quantity > 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant
            INTO TABLE @DATA(lt_sum_supply).
          SORT lt_sum_supply BY material.
          " End 列「合計」のSUPPLYデータ処理

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

          " Begin 指定期間内のDEMAND取得
          " By Day
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~mrpelementavailyorrqmtdate,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
             AND m_r_p_element_open_quantity < 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant,
                    a~mrpelementavailyorrqmtdate
            INTO TABLE @DATA(lt_period_demand).
          SORT lt_period_demand BY material mrpelementavailyorrqmtdate.

          " By Week
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~yearweek,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
             AND m_r_p_element_open_quantity < 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant,
                    a~yearweek
            INTO TABLE @DATA(lt_week_demand).
          SORT lt_week_demand BY material yearweek.

          " By Month
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~yearmonth,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
             AND m_r_p_element_open_quantity < 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant,
                    a~yearmonth
            INTO TABLE @DATA(lt_month_demand).
          SORT lt_month_demand BY material yearmonth.
          " End 指定期間内のDEMAND取得

          " Begin 列「未来」のDEMANDデータ処理
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate > @lv_periodenddate
             AND m_r_p_element_open_quantity < 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant
            INTO TABLE @DATA(lt_future_demand).
          SORT lt_future_demand BY material.
          " End 列「未来」のDEMANDデータ処理

          " Begin 列「合計」のDEMANDデータ処理
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
            FROM @lt_filter_mrpdata AS a
           WHERE m_r_p_element_open_quantity < 0
           GROUP BY a~material,
                    a~m_r_p_area,
                    a~m_r_p_plant
            INTO TABLE @DATA(lt_sum_demand).
          SORT lt_sum_demand BY material.
          " End 列「合計」のDEMANDデータ処理

          " DEMAND明細表示
          IF lv_showdemand = abap_true.
            " Begin「過去」のSUBDEMANDデータ処理
            ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
            SELECT a~material,
                   a~m_r_p_area,
                   a~m_r_p_plant,
                   a~high_level_material,
                   SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
              FROM @lt_filter_mrpdata AS a
             WHERE mrpelementavailyorrqmtdate < @lv_system_date
               AND m_r_p_element_open_quantity < 0
               AND high_level_material IS NOT INITIAL
             GROUP BY a~material,
                      a~m_r_p_area,
                      a~m_r_p_plant,
                      a~high_level_material
              INTO TABLE @DATA(lt_past_subdemand).
            SORT lt_past_subdemand BY material high_level_material.
            " End 「過去」のSUBDEMANDデータ処理

            " Begin 指定期間内のSUBDEMAND取得
            " By Day
            ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
            SELECT a~material,
                   a~m_r_p_area,
                   a~m_r_p_plant,
                   a~high_level_material,
                   a~mrpelementavailyorrqmtdate,
                   SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
              FROM @lt_filter_mrpdata AS a
             WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
               AND m_r_p_element_open_quantity < 0
               AND high_level_material IS NOT INITIAL
             GROUP BY a~material,
                      a~m_r_p_area,
                      a~m_r_p_plant,
                      a~high_level_material,
                      a~mrpelementavailyorrqmtdate
              INTO TABLE @DATA(lt_period_subdemand).
            SORT lt_period_subdemand BY material high_level_material mrpelementavailyorrqmtdate.

            " By Week
            ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
            SELECT a~material,
                   a~m_r_p_area,
                   a~m_r_p_plant,
                   a~high_level_material,
                   a~yearweek,
                   SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
              FROM @lt_filter_mrpdata AS a
             WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
               AND m_r_p_element_open_quantity < 0
               AND high_level_material IS NOT INITIAL
             GROUP BY a~material,
                      a~m_r_p_area,
                      a~m_r_p_plant,
                      a~high_level_material,
                      a~yearweek
              INTO TABLE @DATA(lt_week_subdemand).
            SORT lt_week_subdemand BY material high_level_material yearweek.

            " By Month
            ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
            SELECT a~material,
                   a~m_r_p_area,
                   a~m_r_p_plant,
                   a~high_level_material,
                   a~yearmonth,
                   SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
              FROM @lt_filter_mrpdata AS a
             WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
               AND m_r_p_element_open_quantity < 0
               AND high_level_material IS NOT INITIAL
             GROUP BY a~material,
                      a~m_r_p_area,
                      a~m_r_p_plant,
                      a~high_level_material,
                      a~yearmonth
              INTO TABLE @DATA(lt_month_subdemand).
            SORT lt_month_subdemand BY material high_level_material yearmonth.
            " End 指定期間内のSUBDEMAND取得

            " Begin 列「未来」のSUBDEMANDデータ処理
            ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
            SELECT a~material,
                   a~m_r_p_area,
                   a~m_r_p_plant,
                   a~high_level_material,
                   SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
              FROM @lt_filter_mrpdata AS a
             WHERE mrpelementavailyorrqmtdate > @lv_periodenddate
               AND m_r_p_element_open_quantity < 0
               AND high_level_material IS NOT INITIAL
             GROUP BY a~material,
                      a~m_r_p_area,
                      a~m_r_p_plant,
                      a~high_level_material
              INTO TABLE @DATA(lt_future_subdemand).
            SORT lt_future_subdemand BY material high_level_material.
            " End 列「未来」のSUBDEMANDデータ処理

            " Begin 列「合計」のSUBDEMANDデータ処理
            ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
            SELECT a~material,
                   a~m_r_p_area,
                   a~m_r_p_plant,
                   a~high_level_material,
                   SUM( a~m_r_p_element_open_quantity ) AS m_r_p_element_open_quantity
              FROM @lt_filter_mrpdata AS a
             WHERE m_r_p_element_open_quantity < 0
               AND high_level_material IS NOT INITIAL
             GROUP BY a~material,
                      a~m_r_p_area,
                      a~m_r_p_plant,
                      a~high_level_material
              INTO TABLE @DATA(lt_sum_subdemand).
            SORT lt_sum_subdemand BY material high_level_material.
            " End 列「合計」のSUBDEMANDデータ処理
          ENDIF.

          " Begin 指定期間内のBALANCE取得
          " By Day
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~mrpelementavailyorrqmtdate,
                 a~balance_9,
                 a~balance_r,
                 a~calculation_seq
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
            INTO TABLE @DATA(lt_period_balance).
          SORT lt_period_balance BY material mrpelementavailyorrqmtdate calculation_seq.

          " By Week
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~yearweek,
                 a~balance_9,
                 a~balance_r,
                 a~calculation_seq
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
            INTO TABLE @DATA(lt_week_balance).
          SORT lt_week_balance BY material yearweek calculation_seq.

          " By Month
          ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
          SELECT a~material,
                 a~m_r_p_area,
                 a~m_r_p_plant,
                 a~yearmonth,
                 a~balance_9,
                 a~balance_r,
                 a~calculation_seq
            FROM @lt_filter_mrpdata AS a
           WHERE mrpelementavailyorrqmtdate BETWEEN @lv_system_date AND @lv_periodenddate
            INTO TABLE @DATA(lt_month_balance).
          SORT lt_month_balance BY material yearmonth calculation_seq.
          " End 指定期間内のBALANCE取得
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

*&--Output data
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

        " 購買関連情報
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
      ENDLOOP.

      CASE lv_displaydimension.
          " 横表示
        WHEN 'H'.
          CLEAR: lt_dynamic_col, lv_count, lv_col_date.
          lv_col_date = lv_system_date.

          CASE lv_displayunit.
            WHEN 'D'. " Day - display up to 180 days
              SELECT SINGLE days_between( @lv_system_date, @lv_periodenddate ) + 1 FROM i_timezone INTO @DATA(lv_days).
              IF lv_days > 180.
                lv_count = 180.
              ELSE.
                lv_count = lv_days.
              ENDIF.

              APPEND VALUE #( name = |Y_M_D{ lv_col_date }| types = 'MENGE_D' ) TO lt_dynamic_col.
              lv_count -= 1.

              DO lv_count TIMES.
                lv_col_date = zzcl_common_utils=>calc_date_add( date = lv_col_date day = 1 ).
                APPEND VALUE #( name = |Y_M_D{ lv_col_date }| types = 'MENGE_D' ) TO lt_dynamic_col.
              ENDDO.

            WHEN 'W'. " Week - display up to 3 year, 52 * 3 = 156 weeks
              TRY.
                  cl_scal_utils=>date_get_week(
                    EXPORTING
                      iv_date = lv_system_date
                    IMPORTING
                      ev_year = DATA(lv_begin_year)
                      ev_week = DATA(lv_begin_week) ).

                  cl_scal_utils=>date_get_week(
                    EXPORTING
                      iv_date = lv_periodenddate
                    IMPORTING
                      ev_year = DATA(lv_end_year)
                      ev_week = DATA(lv_end_week) ).
                  ##NO_HANDLER
                CATCH cx_scal.
                  "handle exception
              ENDTRY.

              IF lv_end_year - lv_begin_year > 3.
                lv_count = 156.
              ELSEIF lv_end_year - lv_begin_year = 0.
                lv_count = lv_end_week - lv_begin_week + 1.
              ELSE.
                lv_count = ( lv_end_year - lv_begin_year - 1 ) * 52 + ( 52 - lv_begin_week ) + lv_end_week.
              ENDIF.

              APPEND VALUE #( name = |Y_W{ lv_begin_year }{ lv_begin_week }| types = 'MENGE_D' ) TO lt_dynamic_col.
              lv_count -= 1.

              IF lv_count > 0.
                DO lv_count TIMES.
                  lv_col_date = zzcl_common_utils=>calc_date_add( date = lv_col_date day = 7 ).
                  TRY.
                      cl_scal_utils=>date_get_week(
                        EXPORTING
                          iv_date = lv_col_date
                        IMPORTING
                          ev_year = DATA(lv_col_year)
                          ev_week = DATA(lv_col_week) ).
                      ##NO_HANDLER
                    CATCH cx_scal.
                      "handle exception
                  ENDTRY.
                  APPEND VALUE #( name = |Y_W{ lv_col_year }{ lv_col_week }| types = 'MENGE_D' ) TO lt_dynamic_col.
                ENDDO.
              ENDIF.

            WHEN 'M'. " Month - display up to 3 year, 12 * 3 = 36 months
              CLEAR: lv_begin_year, lv_end_year, lv_begin_month, lv_end_month, lv_col_month.
              lv_begin_year  = lv_system_date+0(4).
              lv_end_year    = lv_periodenddate+0(4).
              lv_begin_month = lv_system_date+4(2).
              lv_end_month   = lv_periodenddate+4(2).

              IF lv_end_year - lv_begin_year > 3.
                lv_count = 36.
              ELSEIF lv_end_year - lv_begin_year = 0.
                lv_count = lv_end_month - lv_begin_month + 1.
              ELSE.
                lv_count = ( lv_end_year - lv_begin_year - 1 ) * 12 + ( 12 - lv_begin_month ) + lv_end_month.
              ENDIF.

              APPEND VALUE #( name = |Y_M{ lv_begin_year }{ lv_begin_month }| types = 'MENGE_D' ) TO lt_dynamic_col.
              lv_count -= 1.
              IF lv_count > 0.
                lv_col_year = lv_begin_year.
                lv_col_month = lv_begin_month.
                DO lv_count TIMES.
                  lv_col_month += 1.
                  IF lv_col_month > 12.
                    lv_col_year += 1.
                    lv_col_month = 1.
                  ENDIF.
                  APPEND VALUE #( name = |Y_M{ lv_col_year }{ lv_col_month }| types = 'MENGE_D' ) TO lt_dynamic_col.
                ENDDO.
              ENDIF.
            WHEN OTHERS.
          ENDCASE.

          LOOP AT lt_fixed_data ASSIGNING <lfs_fixed_data>.
            CLEAR ls_horizontal.
            ls_horizontal = CORRESPONDING #( <lfs_fixed_data> ).
            ls_horizontal-m_r_p_area = lv_mrparea.
            ls_horizontal-supplier = |{ ls_horizontal-supplier ALPHA = OUT }|.
            CONDENSE ls_horizontal-supplier NO-GAPS.
            ls_horizontal-product = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = ls_horizontal-product ).
            CONDENSE ls_horizontal-product NO-GAPS.

            " 購買関連情報
            READ TABLE lt_purginforecdorgplntdata INTO ls_purginforecdorgplntdata
                                                  WITH KEY plant = <lfs_fixed_data>-plant
                                                           purchasinginforecord = <lfs_fixed_data>-purchasinginforecord
                                                           BINARY SEARCH.
            IF sy-subrc = 0.
              ls_horizontal = CORRESPONDING #( BASE ( ls_horizontal ) ls_purginforecdorgplntdata ).
            ELSE.
              CLEAR ls_purginforecdorgplntdata.
            ENDIF.

            " 在庫数量
            READ TABLE lt_sum_stockinfo INTO ls_sum_stockinfo WITH KEY product = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              ls_horizontal-stock_qty = ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit.
            ELSE.
              CLEAR ls_sum_stockinfo.
            ENDIF.

            " 安全在庫
            READ TABLE lt_sum_safety_stock INTO ls_sum_safety_stock WITH KEY material = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              ls_horizontal-safety_stock = ls_sum_safety_stock-m_r_p_element_open_quantity.
            ELSE.
              CLEAR ls_sum_safety_stock.
            ENDIF.

            " 出荷通知数量
            READ TABLE lt_ship_qty INTO DATA(ls_ship_qty) WITH KEY material = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              ls_horizontal-shipment_notice_qty = ls_ship_qty-m_r_p_element_open_quantity.
            ELSE.
              CLEAR ls_ship_qty.
            ENDIF.

            " 欠品日付
            READ TABLE lt_outofstockdate INTO DATA(ls_outofstockdate) WITH KEY product = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              ls_horizontal-out_of_stock_date = ls_outofstockdate-date.
            ELSE.
              CLEAR ls_outofstockdate.
            ENDIF.

            " Begin 列「過去」
            READ TABLE lt_past_forecast INTO DATA(ls_past_forecast) WITH KEY material = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_past_forecast) = ls_past_forecast-m_r_p_element_open_quantity.
            ELSE.
              CLEAR lv_past_forecast.
            ENDIF.

            READ TABLE lt_past_supply INTO DATA(ls_past_supply) WITH KEY material = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_past_supply) = ls_past_supply-m_r_p_element_open_quantity.
            ELSE.
              CLEAR lv_past_supply.
            ENDIF.

            READ TABLE lt_past_demand INTO DATA(ls_past_demand) WITH KEY material = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_past_demand) = ls_past_demand-m_r_p_element_open_quantity.
            ELSE.
              CLEAR lv_past_demand.
            ENDIF.

            " 列「過去」の9.BALANCE
            CLEAR lv_past_9balance.
            lv_past_9balance = ls_horizontal-stock_qty + ls_horizontal-safety_stock + lv_past_supply + lv_past_demand.

            " 列「過去」のR.BALANCE = 9.BALANCE＋ 未来期間に一番目の出荷通知
            CLEAR lv_past_rbalance.
            lv_past_rbalance = lv_past_9balance.
            READ TABLE lt_ship_qty_date INTO DATA(ls_ship_qty_date) WITH KEY material = <lfs_fixed_data>-product.
            IF sy-subrc = 0.
              lv_past_rbalance = lv_past_9balance + ls_ship_qty_date-m_r_p_element_open_quantity.
            ELSE.
              CLEAR ls_ship_qty_date.
            ENDIF.
            " End 列「過去」

            " Begin 列「未来」
            READ TABLE lt_future_forecast INTO DATA(ls_future_forecast) WITH KEY material = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_future_forecast) = ls_future_forecast-m_r_p_element_open_quantity.
            ELSE.
              CLEAR lv_future_forecast.
            ENDIF.

            READ TABLE lt_future_supply INTO DATA(ls_future_supply) WITH KEY material = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_future_supply) = ls_future_supply-m_r_p_element_open_quantity.
            ELSE.
              CLEAR lv_future_supply.
            ENDIF.

            READ TABLE lt_future_demand INTO DATA(ls_future_demand) WITH KEY material = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_future_demand) = ls_future_demand-m_r_p_element_open_quantity.
            ELSE.
              CLEAR lv_future_demand.
            ENDIF.

            " 列「未来」の9.BALANCE
            CLEAR lv_future_9balance.
            lv_future_9balance = lv_future_supply + lv_future_demand.
            " End 列「未来」

            " Begin 列「合計」
            READ TABLE lt_sum_forecast INTO DATA(ls_sum_forecast) WITH KEY material = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_sum_forecast) = ls_sum_forecast-m_r_p_element_open_quantity.
            ELSE.
              CLEAR lv_sum_forecast.
            ENDIF.

            READ TABLE lt_sum_supply INTO DATA(ls_sum_supply) WITH KEY material = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_sum_supply) = ls_sum_supply-m_r_p_element_open_quantity.
            ELSE.
              CLEAR lv_sum_supply.
            ENDIF.

            READ TABLE lt_sum_demand INTO DATA(ls_sum_demand) WITH KEY material = <lfs_fixed_data>-product BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_sum_demand) = ls_sum_demand-m_r_p_element_open_quantity.
            ELSE.
              CLEAR lv_sum_demand.
            ENDIF.

            " 列「合計」の9.BALANCE
            CLEAR lv_sum_9balance.
            lv_sum_9balance = ls_horizontal-stock_qty + ls_horizontal-safety_stock + lv_sum_supply + lv_sum_demand.
            " 列「合計」のR.BALANCE = 9.BALANCE
            CLEAR lv_sum_rbalance.
            lv_sum_rbalance = lv_sum_9balance.
            " End 列「合計」

            DO 3 TIMES.
              CASE sy-index.
                WHEN 1.
                  " 選択条件「購買関連明細行表示」
                  " はい：ForecastとR.BALANCEを表示する。
                  IF lv_showdetaillines = abap_true.
                    ls_horizontal-classification = lc_classification_0. " 0.FORECAST
                    ls_horizontal-past_qty = lv_past_forecast.
                    ls_horizontal-future_qty = lv_future_forecast.
                    ls_horizontal-total_qty = lv_sum_forecast.
                    APPEND ls_horizontal TO lt_horizontal.
                  ENDIF.
                WHEN 2.
                  ls_horizontal-classification = lc_classification_1. " 1.SUPPLY
                  ls_horizontal-past_qty = lv_past_supply.
                  ls_horizontal-future_qty = lv_future_supply.
                  ls_horizontal-total_qty = lv_sum_supply.
                  APPEND ls_horizontal TO lt_horizontal.
                WHEN 3.
                  ls_horizontal-classification = lc_classification_5. " 5.DEMAND
                  ls_horizontal-past_qty = lv_past_demand.
                  ls_horizontal-future_qty = lv_future_demand.
                  ls_horizontal-total_qty = lv_sum_demand.
                  APPEND ls_horizontal TO lt_horizontal.
                WHEN OTHERS.
              ENDCASE.
            ENDDO.

            " DEMAND明細表示
            IF lv_showdemand = abap_true.
              DATA(lt_subdemand_mrpdata) = lt_filter_mrpdata.
              DELETE lt_subdemand_mrpdata WHERE m_r_p_element_category <> lc_mrpelement_category_sb
                                            AND m_r_p_element_category <> lc_mrpelement_category_ar.
              SORT lt_subdemand_mrpdata BY material high_level_material.
              DELETE ADJACENT DUPLICATES FROM lt_subdemand_mrpdata COMPARING material high_level_material.

              DATA(ls_subdemand) = ls_horizontal.
              CLEAR lv_count.
              LOOP AT lt_subdemand_mrpdata INTO DATA(ls_subdemand_mrpdata) WHERE material = <lfs_fixed_data>-product.
                lv_count += 1.
                " SUBDEMAND
                ls_subdemand-classification = |5.{ lc_classification_s }{ lv_count }|.
                " 上位品目
                ls_subdemand-high_level_material = ls_subdemand_mrpdata-high_level_material.
                " 上位品目の最終製品取得
                zcl_bom_where_used=>get_data(
                   EXPORTING
                     iv_plant                   = ls_subdemand-plant
                     iv_billofmaterialcomponent = ls_subdemand-high_level_material
                     iv_getusagelistroot        = abap_true
                   IMPORTING
                     et_usagelist               = DATA(lt_usagelist) ).
                IF lt_usagelist IS NOT INITIAL.
                  SORT lt_usagelist BY material.
                  DELETE ADJACENT DUPLICATES FROM lt_usagelist COMPARING material.
                  LOOP AT lt_usagelist INTO DATA(ls_usagelist).
                    IF ls_subdemand-final_product IS INITIAL.
                      ls_subdemand-final_product = ls_usagelist-material.
                    ELSE.
                      ls_subdemand-final_product = |{ ls_subdemand-final_product },{ ls_usagelist-material }|.
                    ENDIF.
                  ENDLOOP.
                ELSE.
                  ls_subdemand-final_product = ls_subdemand-high_level_material.
                ENDIF.
                CLEAR lt_usagelist.

                " 過去の各上位品目SUBDEMAND
                READ TABLE lt_past_subdemand INTO DATA(ls_past_subdemand)
                                              WITH KEY material = <lfs_fixed_data>-product
                                                       high_level_material = ls_subdemand_mrpdata-high_level_material BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_subdemand-past_qty = ls_past_subdemand-m_r_p_element_open_quantity.
                ELSE.
                  CLEAR: ls_subdemand-past_qty, ls_past_subdemand.
                ENDIF.

                " 未来の各上位品目SUBDEMAND
                READ TABLE lt_future_subdemand INTO DATA(ls_future_subdemand)
                                                WITH KEY material = <lfs_fixed_data>-product
                                                         high_level_material = ls_subdemand_mrpdata-high_level_material BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_subdemand-future_qty = ls_future_subdemand-m_r_p_element_open_quantity.
                ELSE.
                  CLEAR: ls_subdemand-future_qty, ls_future_subdemand.
                ENDIF.

                " 合計の各上位品目SUBDEMAND
                READ TABLE lt_sum_subdemand INTO DATA(ls_sum_subdemand)
                                             WITH KEY material = <lfs_fixed_data>-product
                                                      high_level_material = ls_subdemand_mrpdata-high_level_material BINARY SEARCH.
                IF sy-subrc = 0.
                  ls_subdemand-total_qty = ls_sum_subdemand-m_r_p_element_open_quantity.
                ELSE.
                  CLEAR: ls_subdemand-total_qty, ls_sum_subdemand.
                ENDIF.
                APPEND ls_subdemand TO lt_horizontal.
              ENDLOOP.
            ENDIF.

            DO 2 TIMES.
              CASE sy-index.
                WHEN 1.
                  ls_horizontal-classification = lc_classification_9. " 9.BALANCE
                  ls_horizontal-past_qty = lv_past_9balance.
                  ls_horizontal-future_qty = lv_future_9balance.
                  ls_horizontal-total_qty = lv_sum_9balance.
                  APPEND ls_horizontal TO lt_horizontal.
                WHEN 2.
                  " 選択条件「購買関連明細行表示」
                  " はい：ForecastとR.BALANCEを表示する。
                  IF lv_showdetaillines = abap_true.
                    ls_horizontal-classification = lc_classification_r. " R.BALANCE
                    ls_horizontal-past_qty = lv_past_rbalance.
                    ls_horizontal-total_qty = lv_sum_rbalance.
                    APPEND ls_horizontal TO lt_horizontal.
                  ENDIF.
                WHEN OTHERS.
              ENDCASE.
            ENDDO.
          ENDLOOP.
          SORT lt_horizontal BY product classification.

          SORT lt_dynamic_col BY name.
          DATA(dref) = zzcl_common_utils=>get_all_fields( is_table = 'ZSPP_1003'
                                                          it_type  = lt_dynamic_col ).
          ASSIGN dref->* TO <table>.
          IF <table> IS ASSIGNED.
            <table> = CORRESPONDING #( lt_horizontal ).

            LOOP AT <table> ASSIGNING FIELD-SYMBOL(<lfs_line>).
              " 0.FORECAST
              IF <lfs_line>-('classification') = lc_classification_0.
                CASE lv_displayunit.
                  WHEN 'D'. " Day
                    LOOP AT lt_period_forecast INTO DATA(ls_period_forecast) WHERE material = <lfs_line>-('product').
                      READ TABLE lt_dynamic_col INTO DATA(ls_dynamic_col)
                                                WITH KEY name = |Y_M_D{ ls_period_forecast-mrpelementavailyorrqmtdate }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO FIELD-SYMBOL(<lfs_colvalue>).
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_period_forecast-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_period_forecast.
                  WHEN 'W'. " Week
                    LOOP AT lt_week_forecast INTO DATA(ls_week_forecast) WHERE material = <lfs_line>-('product').
                      READ TABLE lt_dynamic_col INTO ls_dynamic_col
                                                WITH KEY name = |Y_W{ ls_week_forecast-yearweek }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_week_forecast-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_week_forecast.
                  WHEN 'M'. " Month
                    LOOP AT lt_month_forecast INTO DATA(ls_month_forecast) WHERE material = <lfs_line>-('product').
                      READ TABLE lt_dynamic_col INTO ls_dynamic_col
                                                WITH KEY name = |Y_M{ ls_month_forecast-yearmonth }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_month_forecast-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_month_forecast.
                  WHEN OTHERS.
                ENDCASE.
              ENDIF.

              " 1.SUPPLY
              IF <lfs_line>-('classification') = lc_classification_1.
                CASE lv_displayunit.
                  WHEN 'D'. " Day
                    LOOP AT lt_period_supply INTO DATA(ls_period_supply) WHERE material = <lfs_line>-('product').
                      READ TABLE lt_dynamic_col INTO ls_dynamic_col
                                                WITH KEY name = |Y_M_D{ ls_period_supply-mrpelementavailyorrqmtdate }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_period_supply-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_period_supply.
                  WHEN 'W'. " Week
                    LOOP AT lt_week_supply INTO DATA(ls_week_supply) WHERE material = <lfs_line>-('product').
                      READ TABLE lt_dynamic_col INTO ls_dynamic_col
                                                WITH KEY name = |Y_W{ ls_week_supply-yearweek }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_week_supply-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_week_supply.
                  WHEN 'M'. " Month
                    LOOP AT lt_month_supply INTO DATA(ls_month_supply) WHERE material = <lfs_line>-('product').
                      READ TABLE lt_dynamic_col INTO ls_dynamic_col
                                                WITH KEY name = |Y_M{ ls_month_supply-yearmonth }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_month_supply-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_month_supply.
                  WHEN OTHERS.
                ENDCASE.
              ENDIF.

              " 5.DEMAND
              IF <lfs_line>-('classification') = lc_classification_5.
                CASE lv_displayunit.
                  WHEN 'D'. " Day
                    LOOP AT lt_period_demand INTO DATA(ls_period_demand) WHERE material = <lfs_line>-('product').
                      READ TABLE lt_dynamic_col INTO ls_dynamic_col
                                                WITH KEY name = |Y_M_D{ ls_period_demand-mrpelementavailyorrqmtdate }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_period_demand-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_period_demand.
                  WHEN 'W'. " Week
                    LOOP AT lt_week_demand INTO DATA(ls_week_demand) WHERE material = <lfs_line>-('product').
                      READ TABLE lt_dynamic_col INTO ls_dynamic_col
                                                WITH KEY name = |Y_W{ ls_week_demand-yearweek }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_week_demand-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_week_demand.
                  WHEN 'M'. " Month
                    LOOP AT lt_month_demand INTO DATA(ls_month_demand) WHERE material = <lfs_line>-('product').
                      READ TABLE lt_dynamic_col INTO ls_dynamic_col
                                                WITH KEY name = |Y_M{ ls_month_demand-yearmonth }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_month_demand-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_month_demand.
                  WHEN OTHERS.
                ENDCASE.
              ENDIF.

              " 9.BALANCE
              IF <lfs_line>-('classification') = lc_classification_9.
                CASE lv_displayunit.
                  WHEN 'D'. " Day
                    CLEAR lv_count.
                    LOOP AT lt_dynamic_col INTO ls_dynamic_col.
                      lv_count += 1.
                      ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                      IF <lfs_colvalue> IS ASSIGNED.
                        LOOP AT lt_period_balance INTO DATA(ls_period_balance) WHERE material = <lfs_line>-('product')
                                                                                 AND mrpelementavailyorrqmtdate = ls_dynamic_col-name+5(8).
                          <lfs_colvalue> = ls_period_balance-balance_9.
                        ENDLOOP.
                        IF sy-subrc <> 0.
                          " 读不到时，等于前一天的值
                          <lfs_colvalue> = ls_period_balance-balance_9.
                        ENDIF.

                        IF lv_count = 1 AND ls_period_balance-balance_9 IS INITIAL.
                          <lfs_colvalue> = <lfs_line>-('past_qty').
                          ls_period_balance-balance_9 = <lfs_line>-('past_qty').
                        ENDIF.
                      ENDIF.
                    ENDLOOP.

                    " + 指定期間最終日の9.BALANCE
                    <lfs_line>-('future_qty') = ls_period_balance-balance_9 + <lfs_line>-('future_qty').
                    " 列「未来」のR.BALANCE = 列「未来」9.BALANCE
                    CLEAR lv_future_rbalance.
                    lv_future_rbalance = <lfs_line>-('future_qty').

                    CLEAR: ls_dynamic_col, ls_period_balance.

                  WHEN 'W'. " Week
                    CLEAR lv_count.
                    LOOP AT lt_dynamic_col INTO ls_dynamic_col.
                      lv_count += 1.
                      ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                      IF <lfs_colvalue> IS ASSIGNED.
                        LOOP AT lt_week_balance INTO DATA(ls_week_balance) WHERE material = <lfs_line>-('product')
                                                                             AND yearweek = ls_dynamic_col-name+3(6).
                          <lfs_colvalue> = ls_week_balance-balance_9.
                        ENDLOOP.
                        IF sy-subrc <> 0.
                          " 读不到时，等于前一天的值
                          <lfs_colvalue> = ls_week_balance-balance_9.
                        ENDIF.

                        IF lv_count = 1 AND ls_week_balance-balance_9 IS INITIAL.
                          <lfs_colvalue> = <lfs_line>-('past_qty').
                          ls_week_balance-balance_9 = <lfs_line>-('past_qty').
                        ENDIF.
                      ENDIF.
                    ENDLOOP.

                    " + 指定期間最終の9.BALANCE
                    <lfs_line>-('future_qty') = ls_week_balance-balance_9 + <lfs_line>-('future_qty').
                    " 列「未来」のR.BALANCE = 列「未来」9.BALANCE
                    CLEAR lv_future_rbalance.
                    lv_future_rbalance = <lfs_line>-('future_qty').

                    CLEAR: ls_dynamic_col, ls_week_balance.

                  WHEN 'M'. " Month
                    CLEAR lv_count.
                    LOOP AT lt_dynamic_col INTO ls_dynamic_col.
                      lv_count += 1.
                      ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                      IF <lfs_colvalue> IS ASSIGNED.
                        LOOP AT lt_month_balance INTO DATA(ls_month_balance) WHERE material = <lfs_line>-('product')
                                                                               AND yearmonth = ls_dynamic_col-name+3(6).
                          <lfs_colvalue> = ls_month_balance-balance_9.
                        ENDLOOP.
                        IF sy-subrc <> 0.
                          " 读不到时，等于前一天的值
                          <lfs_colvalue> = ls_month_balance-balance_9.
                        ENDIF.

                        IF lv_count = 1 AND ls_month_balance-balance_9 IS INITIAL.
                          <lfs_colvalue> = <lfs_line>-('past_qty').
                          ls_month_balance-balance_9 = <lfs_line>-('past_qty').
                        ENDIF.
                      ENDIF.
                    ENDLOOP.

                    " + 指定期間最終の9.BALANCE
                    <lfs_line>-('future_qty') = ls_month_balance-balance_9 + <lfs_line>-('future_qty').
                    " 列「未来」のR.BALANCE = 列「未来」9.BALANCE
                    CLEAR lv_future_rbalance.
                    lv_future_rbalance = <lfs_line>-('future_qty').

                    CLEAR: ls_dynamic_col, ls_month_balance.
                  WHEN OTHERS.
                ENDCASE.

                " 计算 R.BALANCE 用
                lv_past_9balance = <lfs_line>-('past_qty').
              ENDIF.

              " R.BALANCE
              IF <lfs_line>-('classification') = lc_classification_r.
                " 列「未来」のR.BALANCE
                <lfs_line>-('future_qty') = lv_future_rbalance.

                CASE lv_displayunit.
                  WHEN 'D'. " Day
                    CLEAR lv_count.
                    LOOP AT lt_dynamic_col INTO ls_dynamic_col.
                      lv_count += 1.
                      ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                      IF <lfs_colvalue> IS ASSIGNED.
                        LOOP AT lt_period_balance INTO ls_period_balance WHERE material = <lfs_line>-('product')
                                                                           AND mrpelementavailyorrqmtdate = ls_dynamic_col-name+5(8).
                          <lfs_colvalue> = ls_period_balance-balance_r.
                        ENDLOOP.
                        IF sy-subrc <> 0.
                          " 读不到时，等于前一天的值
                          <lfs_colvalue> = ls_period_balance-balance_r.
                        ENDIF.

                        IF lv_count = 1 AND ls_period_balance-balance_r IS INITIAL.
                          <lfs_colvalue> = lv_past_9balance.
                          ls_period_balance-balance_r = lv_past_9balance.
                        ENDIF.

                        " + 出荷通知数量
                        LOOP AT lt_update_sequence INTO DATA(ls_update_sequence) WHERE product = <lfs_line>-('product').
                          IF ls_dynamic_col-name+5(8) < ls_update_sequence-mrpelementavailyorrqmtdate.
                            <lfs_colvalue> += ls_update_sequence-quantity.
                            EXIT.
                          ELSEIF ls_dynamic_col-name+5(8) = ls_update_sequence-mrpelementavailyorrqmtdate.
                            EXIT.
                          ENDIF.
                        ENDLOOP.
                      ENDIF.
                    ENDLOOP.
                    CLEAR: ls_dynamic_col, ls_period_balance, ls_update_sequence.

                  WHEN 'W'. " Week
                    CLEAR lv_count.
                    LOOP AT lt_dynamic_col INTO ls_dynamic_col.
                      lv_count += 1.
                      ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                      IF <lfs_colvalue> IS ASSIGNED.
                        LOOP AT lt_week_balance INTO ls_week_balance WHERE material = <lfs_line>-('product')
                                                                       AND yearweek = ls_dynamic_col-name+3(6).
                          <lfs_colvalue> = ls_week_balance-balance_r.
                        ENDLOOP.
                        IF sy-subrc <> 0.
                          " 读不到时，等于前一天的值
                          <lfs_colvalue> = ls_week_balance-balance_r.
                        ENDIF.

                        IF lv_count = 1 AND ls_week_balance-balance_r IS INITIAL.
                          <lfs_colvalue> = lv_past_9balance.
                          ls_week_balance-balance_r = lv_past_9balance.
                        ENDIF.

                        " + 出荷通知数量
                        LOOP AT lt_update_sequence INTO ls_update_sequence WHERE product = <lfs_line>-('product').
                          IF ls_dynamic_col-name+3(6) < ls_update_sequence-yearweek.
                            <lfs_colvalue> += ls_update_sequence-quantity.
                            EXIT.
                          ELSEIF ls_dynamic_col-name+3(6) = ls_update_sequence-yearweek.
                            EXIT.
                          ENDIF.
                        ENDLOOP.
                      ENDIF.
                    ENDLOOP.
                    CLEAR: ls_dynamic_col, ls_week_balance, ls_update_sequence.

                  WHEN 'M'. " Month
                    CLEAR lv_count.
                    LOOP AT lt_dynamic_col INTO ls_dynamic_col.
                      lv_count += 1.
                      ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                      IF <lfs_colvalue> IS ASSIGNED.
                        LOOP AT lt_month_balance INTO ls_month_balance WHERE material = <lfs_line>-('product')
                                                                         AND yearmonth = ls_dynamic_col-name+3(6).
                          <lfs_colvalue> = ls_month_balance-balance_r.
                        ENDLOOP.
                        IF sy-subrc <> 0.
                          " 读不到时，等于前一天的值
                          <lfs_colvalue> = ls_month_balance-balance_r.
                        ENDIF.

                        IF lv_count = 1 AND ls_month_balance-balance_r IS INITIAL.
                          <lfs_colvalue> = lv_past_9balance.
                          ls_month_balance-balance_r = lv_past_9balance.
                        ENDIF.

                        " + 出荷通知数量
                        LOOP AT lt_update_sequence INTO ls_update_sequence WHERE product = <lfs_line>-('product').
                          IF ls_dynamic_col-name+3(6) < ls_update_sequence-yearmonth.
                            <lfs_colvalue> += ls_update_sequence-quantity.
                            EXIT.
                          ELSEIF ls_dynamic_col-name+3(6) = ls_update_sequence-yearmonth.
                            EXIT.
                          ENDIF.
                        ENDLOOP.
                      ENDIF.
                    ENDLOOP.
                    CLEAR: ls_dynamic_col, ls_month_balance, ls_update_sequence.
                  WHEN OTHERS.
                ENDCASE.
              ENDIF.

              " SUBDEMAND
              IF find( val = <lfs_line>-('classification') sub = lc_classification_s ) > 0.
                CASE lv_displayunit.
                  WHEN 'D'. " Day
                    LOOP AT lt_period_subdemand INTO DATA(ls_period_subdemand) WHERE material = <lfs_line>-('product')
                                                                                 AND high_level_material = <lfs_line>-('high_level_material').
                      READ TABLE lt_dynamic_col INTO ls_dynamic_col
                                                WITH KEY name = |Y_M_D{ ls_period_subdemand-mrpelementavailyorrqmtdate }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_period_subdemand-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_period_subdemand.
                  WHEN 'W'. " Week
                    LOOP AT lt_week_subdemand INTO DATA(ls_week_subdemand) WHERE material = <lfs_line>-('product')
                                                                             AND high_level_material = <lfs_line>-('high_level_material').
                      READ TABLE lt_dynamic_col INTO ls_dynamic_col
                                                WITH KEY name = |Y_W{ ls_week_subdemand-yearweek }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_week_subdemand-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_week_subdemand.
                  WHEN 'M'. " Month
                    LOOP AT lt_month_subdemand INTO DATA(ls_month_subdemand) WHERE material = <lfs_line>-('product')
                                                                               AND high_level_material = <lfs_line>-('high_level_material').
                      READ TABLE lt_dynamic_col INTO ls_dynamic_col
                                                WITH KEY name = |Y_M{ ls_month_subdemand-yearmonth }| BINARY SEARCH.
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT ls_dynamic_col-name OF STRUCTURE <lfs_line> TO <lfs_colvalue>.
                        IF <lfs_colvalue> IS ASSIGNED.
                          <lfs_colvalue> = ls_month_subdemand-m_r_p_element_open_quantity.
                        ENDIF.
                      ELSE.
                        CLEAR ls_dynamic_col.
                      ENDIF.
                    ENDLOOP.
                    CLEAR ls_month_subdemand.
                  WHEN OTHERS.
                ENDCASE.
              ENDIF.
            ENDLOOP.

            <lfs_data>-dynamicdata = xco_cp_json=>data->from_abap( <table> )->apply( VALUE #(
               ( xco_cp_json=>transformation->underscore_to_pascal_case )
            ) )->to_string( ).
          ENDIF.

          " 縦表示
        WHEN 'V'.
          LOOP AT lt_filter_mrpdata INTO ls_filter_mrpdata GROUP BY ( product = ls_filter_mrpdata-product )
                                                           ASSIGNING FIELD-SYMBOL(<lfs_group>).
            CLEAR: ls_sum_stockinfo, ls_sum_safety_stock.
            CLEAR: lv_previous_available_stock,
                   lv_previous_remaining_qty.

            " 在庫行
            READ TABLE lt_sum_stockinfo INTO ls_sum_stockinfo WITH KEY product = <lfs_group>-product BINARY SEARCH.
            IF sy-subrc = 0.
              APPEND INITIAL LINE TO lt_vertical ASSIGNING FIELD-SYMBOL(<lfs_vertical_stock>).
            ELSE.
              CLEAR ls_sum_stockinfo.
              UNASSIGN <lfs_vertical_stock>.
            ENDIF.

            " 安全在庫行
            READ TABLE lt_sum_safety_stock INTO ls_sum_safety_stock WITH KEY material = <lfs_group>-product BINARY SEARCH.
            IF sy-subrc = 0.
              APPEND INITIAL LINE TO lt_vertical ASSIGNING FIELD-SYMBOL(<lfs_vertical_safety_stock>).
            ELSE.
              CLEAR ls_sum_safety_stock.
              UNASSIGN <lfs_vertical_safety_stock>.
            ENDIF.

            " 前行(安全在庫行)の利用可能在庫
            lv_previous_available_stock = ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit +
                                          ls_sum_safety_stock-m_r_p_element_open_quantity.

            " 前行(安全在庫行)の在庫残数
            lv_previous_remaining_qty = ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit.

            " 明細行
            LOOP AT GROUP <lfs_group> ASSIGNING FIELD-SYMBOL(<lfs_group_item>).
              APPEND INITIAL LINE TO lt_vertical ASSIGNING FIELD-SYMBOL(<lfs_vertical>).
              <lfs_vertical>-plant = <lfs_group_item>-m_r_p_plant.
              <lfs_vertical>-m_r_p_area = <lfs_group_item>-m_r_p_area.
              <lfs_vertical>-product = <lfs_group_item>-material.
              <lfs_vertical>-date = <lfs_group_item>-mrpelementavailyorrqmtdate+0(4) && '/' &&
                                    <lfs_group_item>-mrpelementavailyorrqmtdate+4(2) && '/' &&
                                    <lfs_group_item>-mrpelementavailyorrqmtdate+6(2).
              <lfs_vertical>-supplier = <lfs_group_item>-mrpelementbusinesspartner.
              <lfs_vertical>-supplier_name = <lfs_group_item>-mrpelementbusinesspartnername.

              <lfs_vertical>-required_qty    = 0. " 所要数
              <lfs_vertical>-stock_qty       = 0. " 在庫数
              <lfs_vertical>-supplied_qty    = 0. " 供給数
              <lfs_vertical>-available_stock = 0. " 利用可能在庫
              <lfs_vertical>-remaining_qty   = 0. " 在庫残数

              IF <lfs_group_item>-m_r_p_element_open_quantity < 0.
                " 所要数
                <lfs_vertical>-required_qty = <lfs_group_item>-m_r_p_element_open_quantity.
              ELSEIF <lfs_group_item>-m_r_p_element_open_quantity > 0.
                " 供給数
                <lfs_vertical>-supplied_qty = <lfs_group_item>-m_r_p_element_open_quantity.
              ENDIF.

              " 利用可能在庫 = 前行の利用可能在庫+所要数＋供給数
              <lfs_vertical>-available_stock = lv_previous_available_stock +
                                               <lfs_vertical>-required_qty +
                                               <lfs_vertical>-supplied_qty.
              " 在庫残数 = 前行の在庫残数＋現在行の所要数
              <lfs_vertical>-remaining_qty   = lv_previous_remaining_qty +
                                               <lfs_vertical>-required_qty.

              " 前行の利用可能在庫
              lv_previous_available_stock = <lfs_vertical>-available_stock.
              " 前行の在庫残数
              lv_previous_remaining_qty = <lfs_vertical>-remaining_qty.

              READ TABLE lt_fixed_data INTO ls_fixed_data WITH KEY product = <lfs_group_item>-product BINARY SEARCH.
              IF sy-subrc = 0.
                <lfs_vertical> = CORRESPONDING #( BASE ( <lfs_vertical> ) ls_fixed_data ).

                " MRP要素
                CASE ls_fixed_data-procurementtype.
                  WHEN 'E'.
                    <lfs_vertical>-m_r_p_elements = |{ <lfs_group_item>-m_r_p_element }/{ <lfs_group_item>-m_r_p_element_item }/| &&
                                                    |{ <lfs_group_item>-m_r_p_element_schedule_line }/{ <lfs_group_item>-m_r_p_element_document_type }|.
                  WHEN 'F'.
                    IF <lfs_group_item>-m_r_p_element_category = lc_mrpelement_category_sb.
                      <lfs_vertical>-m_r_p_elements = <lfs_group_item>-high_level_material.
                    ELSEIF <lfs_group_item>-m_r_p_element_category = lc_mrpelement_category_ar.
                      <lfs_vertical>-m_r_p_elements = <lfs_group_item>-high_level_material.
                    ELSE.
                      <lfs_vertical>-m_r_p_elements = |{ <lfs_group_item>-m_r_p_element }/{ <lfs_group_item>-m_r_p_element_item }/| &&
                                                      |{ <lfs_group_item>-m_r_p_element_schedule_line }/{ <lfs_group_item>-m_r_p_element_document_type }|.
                    ENDIF.
                  WHEN OTHERS.
                ENDCASE.

                READ TABLE lt_purginforecdorgplntdata INTO ls_purginforecdorgplntdata
                                                      WITH KEY plant = <lfs_vertical>-plant
                                                               purchasinginforecord = ls_fixed_data-purchasinginforecord
                                                               BINARY SEARCH.
                IF sy-subrc = 0.
                  <lfs_vertical> = CORRESPONDING #( BASE ( <lfs_vertical> ) ls_purginforecdorgplntdata ).
                ELSE.
                  CLEAR ls_purginforecdorgplntdata.
                ENDIF.
              ELSE.
                CLEAR ls_fixed_data.
              ENDIF.

              " 縦表示のステータス
              READ TABLE lt_posupplierconfirmation INTO DATA(ls_posupplierconfirmation)
                                                    WITH KEY purchaseorder = <lfs_group_item>-m_r_p_element
                                                             purchaseorderitem = <lfs_group_item>-m_r_p_element_item
                                                             BINARY SEARCH.
              IF sy-subrc = 0.
                <lfs_vertical>-status = ls_posupplierconfirmation-supplierconfirmationcategory.
              ELSE.
                CLEAR ls_posupplierconfirmation.
              ENDIF.

              <lfs_vertical>-supplier = |{ <lfs_vertical>-supplier ALPHA = OUT }|.
              CONDENSE <lfs_vertical>-supplier NO-GAPS.
              <lfs_vertical>-product = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_vertical>-product ).
              CONDENSE <lfs_vertical>-product NO-GAPS.
            ENDLOOP.

            " 在庫行
            IF <lfs_vertical_stock> IS ASSIGNED.
              <lfs_vertical_stock> = CORRESPONDING #( <lfs_vertical> EXCEPT date
                                                                            m_r_p_elements
                                                                            required_qty
                                                                            stock_qty
                                                                            supplied_qty
                                                                            available_stock
                                                                            remaining_qty ).
              <lfs_vertical_stock>-m_r_p_elements = '在庫'.
              READ TABLE lt_sum_stockinfo INTO ls_sum_stockinfo WITH KEY product = <lfs_group>-product BINARY SEARCH.
              IF sy-subrc = 0.
                " 所要数
                <lfs_vertical_stock>-required_qty = 0.
                " 在庫数
                <lfs_vertical_stock>-stock_qty = ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit.
                " 供給数
                <lfs_vertical_stock>-supplied_qty = 0.
                " 利用可能在庫 = 在庫
                <lfs_vertical_stock>-available_stock = ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit.
                " 在庫残数 = 在庫
                <lfs_vertical_stock>-remaining_qty = ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit.
              ENDIF.
            ENDIF.

            " 安全在庫行
            IF <lfs_vertical_safety_stock> IS ASSIGNED.
              <lfs_vertical_safety_stock> = CORRESPONDING #( <lfs_vertical> EXCEPT date
                                                                                   m_r_p_elements
                                                                                   required_qty
                                                                                   stock_qty
                                                                                   supplied_qty
                                                                                   available_stock
                                                                                   remaining_qty ).
              <lfs_vertical_safety_stock>-m_r_p_elements = '安全在庫'.
              READ TABLE lt_sum_safety_stock INTO ls_sum_safety_stock WITH KEY material = <lfs_group>-product BINARY SEARCH.
              IF sy-subrc = 0.
                " 所要数
                <lfs_vertical_safety_stock>-required_qty = ls_sum_safety_stock-m_r_p_element_open_quantity.
                " 在庫数
                <lfs_vertical_safety_stock>-stock_qty = 0.
                " 供給数
                <lfs_vertical_safety_stock>-supplied_qty = 0.
                " 利用可能在庫 = 在庫数+安全在庫
                <lfs_vertical_safety_stock>-available_stock = ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit +
                                                              ls_sum_safety_stock-m_r_p_element_open_quantity.
                " 在庫残数 = 在庫
                <lfs_vertical_safety_stock>-remaining_qty = ls_sum_stockinfo-matlwrhsstkqtyinmatlbaseunit.
              ENDIF.
            ENDIF.
          ENDLOOP.

          SORT lt_vertical BY product date.
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
