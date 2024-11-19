CLASS zcl_mfgorderinfo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_mfgorderinfo IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.
    TYPES: BEGIN OF ty_status,
             manufacturing_order(12) TYPE c,
             status_code(5)          TYPE c,
             status_short_name(4)    TYPE c,
           END OF ty_status,
           BEGIN OF ty_result,
             results TYPE TABLE OF ty_status WITH DEFAULT KEY,
           END OF ty_result,
           BEGIN OF ty_response,
             d TYPE ty_result,
           END OF ty_response.

    CONSTANTS: lc_error         TYPE string VALUE `Error`,
               lc_config_zpp014 TYPE ztbc_1001-zid VALUE `ZPP014`.

    DATA: lt_original_data TYPE STANDARD TABLE OF zc_mfgorderinfo WITH DEFAULT KEY.
    DATA: lr_component TYPE RANGE OF matnr.
    DATA: ls_response TYPE ty_response.
    DATA: lv_count         TYPE sy-tabix,
          lv_mapping_count TYPE sy-tabix,
          lv_version_info  TYPE string.

    lt_original_data = CORRESPONDING #( it_original_data ).

    IF lt_original_data IS NOT INITIAL.
      SELECT manufacturingorder,
             productionversion
        FROM zc_mfgorderinfo
         FOR ALL ENTRIES IN @lt_original_data
       WHERE manufacturingorder = @lt_original_data-manufacturingorder
        INTO TABLE @DATA(lt_mfgorder).
      SORT lt_mfgorder BY manufacturingorder.

      SELECT reservation,
             reservationitem,
             recordtype,
             manufacturingorder,
             assembly,
             material,
             plant,
             alternativeitemgroup,
             alternativeitemstrategy
        FROM i_mfgorderoperationcomponent WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_original_data
       WHERE manufacturingorder = @lt_original_data-manufacturingorder
         AND materialcompisalternativeitem = @abap_true
         AND requiredquantity IS NOT INITIAL
        INTO TABLE @DATA(lt_component).

      SORT lt_component BY manufacturingorder.

      SELECT *
        FROM zc_tbc1001
       WHERE zid = @lc_config_zpp014
        INTO TABLE @DATA(lt_config).          "#EC CI_ALL_FIELDS_NEEDED

      LOOP AT lt_component INTO DATA(ls_component).
        CASE ls_component-alternativeitemstrategy.
          WHEN '1'.
            " SUBALTGROUP
            IF NOT line_exists( lt_config[ zvalue2 = ls_component-alternativeitemgroup ] ).
              DELETE lt_component.
            ENDIF.
          WHEN '2'.
            " MAINALTGROUP
            IF NOT line_exists( lt_config[ zvalue1 = ls_component-alternativeitemgroup ] ).
              DELETE lt_component.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.

      IF lt_component IS NOT INITIAL.
        SELECT *
          FROM ztpp_1017
           FOR ALL ENTRIES IN @lt_component
         WHERE material = @lt_component-assembly
           AND plant = @lt_component-plant
           AND delete_flag = ''
          INTO TABLE @DATA(lt_versioninfo).

        SORT lt_versioninfo BY material plant component delete_flag.

        ##ITAB_DB_SELECT
        SELECT a~material,
               a~plant,
               a~version_info,
               COUNT( 1 ) AS count
          FROM @lt_versioninfo AS a
         GROUP BY a~material,
                  a~plant,
                  a~version_info
          INTO TABLE @DATA(lt_count_version).
        SORT lt_count_version BY material plant version_info.
      ENDIF.

      zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = |/API_PRODUCTION_ORDER_2_SRV/A_ProductionOrderStatus_2?sap-language={ zzcl_common_utils=>get_current_language(  ) }|
                                                   iv_method      = if_web_http_client=>get
                                         IMPORTING ev_status_code = DATA(lv_status_code)
                                                   ev_response    = DATA(lv_response) ).
      IF lv_status_code = 200.
        xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore )
          ( xco_cp_json=>transformation->boolean_to_abap_bool )
        ) )->write_to( REF #( ls_response ) ).

        DATA(lt_response) = ls_response-d-results.
        SORT lt_response BY manufacturing_order status_code.
      ENDIF.

      LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<lfs_original_data>).
        CLEAR: lr_component, lv_count, lv_mapping_count.

        READ TABLE lt_mfgorder INTO DATA(ls_mfgorder) WITH KEY manufacturingorder = <lfs_original_data>-manufacturingorder
                                                               BINARY SEARCH.

        READ TABLE lt_component INTO ls_component WITH KEY manufacturingorder = <lfs_original_data>-manufacturingorder
                                                           BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_component INTO ls_component WHERE manufacturingorder = <lfs_original_data>-manufacturingorder.
            lv_count += 1.
          ENDLOOP.

          <lfs_original_data>-finalversion = lc_error.

          IF line_exists( lt_count_version[ material = ls_component-assembly
                                            plant    = ls_component-plant
                                            count    = lv_count ] ).
            CLEAR lv_version_info.
            LOOP AT lt_count_version INTO DATA(ls_count_version) WHERE material = ls_component-assembly
                                                                   AND plant    = ls_component-plant
                                                                   AND count    = lv_count.
              IF ls_count_version-version_info <> lv_version_info.
                CLEAR lv_mapping_count.
              ENDIF.

              lv_version_info = ls_count_version-version_info.

              LOOP AT lt_component INTO ls_component WHERE manufacturingorder = <lfs_original_data>-manufacturingorder.
                IF line_exists( lt_versioninfo[ material     = ls_component-assembly
                                                plant        = ls_component-plant
                                                version_info = ls_count_version-version_info
                                                component    = ls_component-material ] ).
                  lv_mapping_count += 1.
                ENDIF.
              ENDLOOP.
              " 全匹配且数量一致时
              IF lv_mapping_count = lv_count.
                <lfs_original_data>-finalversion = ls_count_version-version_info.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ELSE.
          <lfs_original_data>-finalversion = ls_mfgorder-productionversion.
        ENDIF.

        " Status
        DATA(lv_manufacturingorder) = |{ <lfs_original_data>-manufacturingorder ALPHA = OUT }|.
        CONDENSE lv_manufacturingorder NO-GAPS.
        LOOP AT lt_response INTO DATA(ls_line) WHERE manufacturing_order = lv_manufacturingorder.
          IF <lfs_original_data>-statusname IS INITIAL.
            <lfs_original_data>-statusname = ls_line-status_short_name.
          ELSE.
            <lfs_original_data>-statusname = |{ <lfs_original_data>-statusname } { ls_line-status_short_name }|.
          ENDIF.
        ENDLOOP.

        CLEAR ls_mfgorder.
      ENDLOOP.
    ENDIF.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.

ENDCLASS.
