CLASS zcl_mfgorderinfo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MFGORDERINFO IMPLEMENTATION.


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

    CONSTANTS: lc_error TYPE string VALUE `Error`.

    DATA: lt_original_data TYPE STANDARD TABLE OF zc_mfgorderinfo WITH DEFAULT KEY.
    DATA: ls_response TYPE ty_response.

    lt_original_data = CORRESPONDING #( it_original_data ).

    IF lt_original_data IS NOT INITIAL.
      SELECT reservation,
             reservationitem,
             recordtype,
             manufacturingorder,
             assembly,
             material,
             plant
        FROM i_mfgorderoperationcomponent WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_original_data
       WHERE manufacturingorder = @lt_original_data-manufacturingorder
         AND materialcompisalternativeitem = @abap_true
         AND requiredquantity IS NOT INITIAL
        INTO TABLE @DATA(lt_component).

      SORT lt_component BY manufacturingorder.

      IF lt_component IS NOT INITIAL.
        SELECT *
          FROM ztpp_1017
           FOR ALL ENTRIES IN @lt_component
         WHERE material = @lt_component-assembly
           AND plant = @lt_component-plant
          INTO TABLE @DATA(lt_versioninfo).

        SORT lt_versioninfo BY material plant component delete_flag.
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

        READ TABLE lt_component INTO DATA(ls_component) WITH KEY manufacturingorder = <lfs_original_data>-manufacturingorder
                                                                 BINARY SEARCH.
        IF sy-subrc = 0.
          IF line_exists( lt_versioninfo[ material = ls_component-assembly
                                          plant    = ls_component-plant ] ).

            READ TABLE lt_versioninfo INTO DATA(ls_versioninfo) WITH KEY material    = ls_component-assembly
                                                                         plant       = ls_component-plant
                                                                         component   = <lfs_original_data>-material
                                                                         delete_flag = ''
                                                                         BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_original_data>-finalversion = ls_versioninfo-version_info.
            ELSE.
              <lfs_original_data>-finalversion = lc_error.
            ENDIF.
          ELSE.
            <lfs_original_data>-finalversion = <lfs_original_data>-productionversion.
          ENDIF.
        ELSE.
          <lfs_original_data>-finalversion = <lfs_original_data>-productionversion.
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
      ENDLOOP.
    ENDIF.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
