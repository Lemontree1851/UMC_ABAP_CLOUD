CLASS zcl_bom_where_used DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_usagelist,
        plant                        TYPE werks_d,
        billofmaterialcomponent      TYPE matnr,
        material                     TYPE matnr,
        validitystartdate            TYPE datuv,
        billofmaterialitemnumber     TYPE n LENGTH 4,
        billofmaterialitemquantity   TYPE i_billofmaterialitemdex_3-billofmaterialitemquantity,
        billofmaterialitemunit       TYPE meins,
        billofmaterialvariant        TYPE i_materialbomlink-billofmaterialvariant,
        billofmaterial               TYPE i_materialbomlink-billofmaterial,
        billofmaterialitemnodenumber TYPE i_billofmaterialitemdex_3-billofmaterialitemnodenumber,
        billofmaterialcategory       TYPE i_materialbomlink-billofmaterialcategory,
      END OF ty_usagelist,
      tt_usagelist TYPE STANDARD TABLE OF ty_usagelist WITH DEFAULT KEY,

      BEGIN OF ty_results,
        plant                          TYPE werks_d,
        bill_of_material_component     TYPE matnr,
        material                       TYPE matnr,
        validity_start_date            TYPE string,
        bill_of_material_item_number   TYPE n LENGTH 4,
        bill_of_material_item_quantity TYPE i_billofmaterialitemdex_3-billofmaterialitemquantity,
        bill_of_material_item_unit     TYPE meins,
        bill_of_material_variant       TYPE i_materialbomlink-billofmaterialvariant,
        bill_of_material               TYPE i_materialbomlink-billofmaterial,
        b_o_m_item_node_number         TYPE i_billofmaterialitemdex_3-billofmaterialitemnodenumber,
        bill_of_material_category      TYPE i_materialbomlink-billofmaterialcategory,
      END OF ty_results,
      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,

      BEGIN OF ty_d,
        results TYPE tt_results,
      END OF ty_d,

      BEGIN OF ty_resquest,
        d TYPE ty_d,
      END OF ty_resquest.

    CLASS-METHODS:
      "! Get data of usage list of component
      "! iv_getusagelistroot: abap_true->get root bills of material of component（highest level material）
      "!                      abap_false->get bills of material of component（high level material）
      get_data IMPORTING iv_plant                   TYPE werks_d
                         iv_billofmaterialcomponent TYPE matnr
                         iv_getusagelistroot        TYPE abap_boolean OPTIONAL
                         is_usagelist_curr          TYPE ty_usagelist OPTIONAL
               EXPORTING et_usagelist               TYPE tt_usagelist,

      "! Get data of usage list of component
      "! iv_getusagelistroot: abap_true->get root bills of material of component（highest level material）
      "!                      abap_false->get bills of material of component（high level material）
      get_data_boi IMPORTING iv_plant                   TYPE werks_d
                             iv_billofmaterialcomponent TYPE matnr
                             iv_getusagelistroot        TYPE abap_boolean OPTIONAL
                             is_usagelist_curr          TYPE ty_usagelist OPTIONAL
                   EXPORTING et_usagelist               TYPE tt_usagelist.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_bom_where_used IMPLEMENTATION.
  METHOD get_data.

    DATA:
      lt_usagelist      TYPE STANDARD TABLE OF ty_usagelist,
      lt_results        TYPE STANDARD TABLE OF ty_usagelist,
      ls_usagelist      TYPE ty_usagelist,
      ls_usagelist_curr TYPE ty_usagelist,
      ls_request        TYPE ty_resquest,
      ls_results        TYPE ty_usagelist,
      lv_path           TYPE string,
      lv_string         TYPE string,
      lv_unix_timestamp TYPE int8.

    CONSTANTS:
      lc_stat_code_200 TYPE if_web_http_response=>http_status-code VALUE '200',
      lc_date_19000101 TYPE d VALUE '19000101'.

    "/API_BOM_WHERE_USED_SRV/A_BOMWhereUsed?$filter=
    lv_path = |/API_BOM_WHERE_USED_SRV/A_BOMWhereUsed?$filter=Plant eq '{ iv_plant }' and BillOfMaterialComponent eq '{ iv_billofmaterialcomponent }'|.

    "Call API of reading bill of material for a component
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>get
      IMPORTING
        ev_status_code = DATA(lv_stat_code)
        ev_response    = DATA(lv_response) ).

    IF lv_stat_code = lc_stat_code_200.
      REPLACE ALL OCCURRENCES OF 'BillOfMaterialItemNodeNumber' IN lv_response WITH 'BOMItemNodeNumber'.

      "JSON->ABAP
      xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_request ) ).

      LOOP AT ls_request-d-results INTO DATA(ls_results_json).
        ls_results-plant                        = ls_results_json-plant.
        ls_results-billofmaterialcomponent      = ls_results_json-bill_of_material_component.
        ls_results-material                     = ls_results_json-material.
        ls_results-billofmaterialitemnumber     = ls_results_json-bill_of_material_item_number.
        ls_results-billofmaterialitemquantity   = ls_results_json-bill_of_material_item_quantity.
        ls_results-billofmaterialitemunit       = ls_results_json-bill_of_material_item_unit.
        ls_results-billofmaterialvariant        = |{ ls_results_json-bill_of_material_variant ALPHA = IN }|.
        ls_results-billofmaterial               = ls_results_json-bill_of_material.
        ls_results-billofmaterialitemnodenumber = ls_results_json-b_o_m_item_node_number.
        ls_results-billofmaterialcategory       = ls_results_json-bill_of_material_category.

        lv_string = ls_results_json-validity_start_date.
        SHIFT lv_string BY 6 PLACES LEFT.
        REPLACE ALL OCCURRENCES OF ')/' IN lv_string WITH ''.
        lv_unix_timestamp = lv_string / 1000.

        IF lv_unix_timestamp > 0.
          DATA(lv_date) = xco_cp_time=>unix_timestamp( iv_unix_timestamp = lv_unix_timestamp )->get_moment(
                                                                                             )->as( xco_cp_time=>format->abap
                                                     )->value+0(8).
          ls_results-validitystartdate = lv_date.
        ELSE.
          ls_results-validitystartdate = lc_date_19000101.
        ENDIF.

        APPEND ls_results TO lt_results.
      ENDLOOP.
    ENDIF.

*   Read bills of material for a component in high level
    IF iv_getusagelistroot = abap_false.
      APPEND LINES OF lt_results TO et_usagelist.
*   Read bills of material for a component in root level
    ELSE.
      IF lt_results IS NOT INITIAL.
        LOOP AT lt_results INTO ls_results.
          "保留当前组件的high level数据（如果没有更高的high level数据，则输出为root level数据）
          ls_usagelist_curr = ls_results.

          zcl_bom_where_used=>get_data(
            EXPORTING
              iv_plant                   = ls_results-plant
              iv_billofmaterialcomponent = ls_results-material
              iv_getusagelistroot        = abap_true
              is_usagelist_curr          = ls_usagelist_curr
            IMPORTING
              et_usagelist               = lt_usagelist ).

          APPEND LINES OF lt_usagelist TO et_usagelist.
          CLEAR lt_usagelist.
        ENDLOOP.
      ELSE.
        "传入的high level数据
        IF is_usagelist_curr IS NOT INITIAL.
          APPEND is_usagelist_curr TO et_usagelist.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD get_data_boi.

    DATA:
      lt_usagelist      TYPE STANDARD TABLE OF ty_usagelist,
      lt_results        TYPE STANDARD TABLE OF ty_usagelist,
      ls_usagelist      TYPE ty_usagelist,
      ls_usagelist_curr TYPE ty_usagelist,
      ls_results        TYPE ty_usagelist.

    CONSTANTS:
      lc_validityenddate_99991231 TYPE d VALUE '99991231'.

    "Get where used material
    READ ENTITIES OF i_billofmaterialtp_2
    ENTITY billofmaterial
    EXECUTE getwhereusedmaterial
    FROM VALUE #( (
    %param-billofmaterialcomponent = iv_billofmaterialcomponent
    %param-headervalidityenddate = lc_validityenddate_99991231
*    %param-headervaliditystartdate = '19000101'
    %param-plant = iv_plant
    ) )
    RESULT DATA(lt_result_boi)
    FAILED DATA(ls_failed)
    REPORTED DATA(ls_reported).

    IF lt_result_boi IS NOT INITIAL.
      LOOP AT lt_result_boi INTO DATA(ls_result_boi).
        ls_results-plant                        = ls_result_boi-%param-plant.
        ls_results-billofmaterialcomponent      = ls_result_boi-%param-billofmaterialcomponent.
        ls_results-material                     = ls_result_boi-%param-material.
        ls_results-validitystartdate            = ls_result_boi-%param-validitystartdate.
        ls_results-billofmaterialitemnumber     = ls_result_boi-%param-billofmaterialitemnumber.
        ls_results-billofmaterialitemquantity   = ls_result_boi-%param-billofmaterialitemquantity.
        ls_results-billofmaterialitemunit       = ls_result_boi-%param-billofmaterialitemunit.
        ls_results-billofmaterialvariant        = ls_result_boi-%param-billofmaterialvariant.
        ls_results-billofmaterial               = ls_result_boi-%param-billofmaterial.
        ls_results-billofmaterialitemnodenumber = ls_result_boi-%param-billofmaterialitemnodenumber.
        ls_results-billofmaterialcategory       = ls_result_boi-%param-billofmaterialcategory.
        APPEND ls_results TO lt_results.
        CLEAR ls_results.
      ENDLOOP.
    ENDIF.

*   Read bills of material for a component in high level
    IF iv_getusagelistroot = abap_false.
      APPEND LINES OF lt_results TO et_usagelist.
*   Read bills of material for a component in root level
    ELSE.
      IF lt_results IS NOT INITIAL.
        LOOP AT lt_results INTO ls_results.
          "保留当前组件的high level数据（如果没有更高的high level数据，则输出为root level数据）
          ls_usagelist_curr = ls_results.

          zcl_bom_where_used=>get_data_boi(
            EXPORTING
              iv_plant                   = ls_results-plant
              iv_billofmaterialcomponent = ls_results-material
              iv_getusagelistroot        = abap_true
              is_usagelist_curr          = ls_usagelist_curr
            IMPORTING
              et_usagelist               = lt_usagelist ).

          APPEND LINES OF lt_usagelist TO et_usagelist.
          CLEAR lt_usagelist.
        ENDLOOP.
      ELSE.
        "传入的high level数据
        IF is_usagelist_curr IS NOT INITIAL.
          APPEND is_usagelist_curr TO et_usagelist.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
