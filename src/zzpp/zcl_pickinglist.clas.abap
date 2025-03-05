CLASS zcl_pickinglist DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PICKINGLIST IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
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

    DATA lt_original_data TYPE STANDARD TABLE OF zc_pickinglist_tab WITH DEFAULT KEY.
    DATA lt_detail TYPE TABLE OF lty_detail.
    DATA lv_rowno TYPE i.

    lt_original_data = CORRESPONDING #( it_original_data ).

    IF lt_original_data IS NOT INITIAL.
      DATA(lt_temp) = lt_original_data.
      SORT lt_temp BY reservation reservationitem.
      DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING reservation reservationitem.

      ##ITAB_KEY_IN_SELECT
      SELECT document~reservation,
             document~reservationitem,
             document~goodsmovementtype,
             SUM( document~quantityinbaseunit ) AS quantityinbaseunit
        FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS document
        JOIN @lt_temp AS a ON  a~reservation = document~reservation
                           AND a~reservationitem = document~reservationitem
       WHERE document~goodsmovementtype IN ( '311','312' )
         AND document~materialdocumentitem = '0001'
       GROUP BY document~reservation,
                document~reservationitem,
                document~goodsmovementtype
        INTO TABLE @DATA(lt_materialdocument).
      SORT lt_materialdocument BY reservation reservationitem goodsmovementtype.

      ##ITAB_KEY_IN_SELECT
      SELECT document~reservation,
             document~reservationitem,
             SUM( document~resvnitmrequiredqtyinbaseunit ) AS resvnitmrequiredqtyinbaseunit
        FROM i_reservationdocumentitem WITH PRIVILEGED ACCESS AS document
        JOIN @lt_temp AS a ON  a~reservation = document~reservation
                           AND a~reservationitem = document~reservationitem
       WHERE document~goodsmovementtype = '311'
       GROUP BY document~reservation,
                document~reservationitem
        INTO TABLE @DATA(lt_reservationdocument).
      SORT lt_reservationdocument BY reservation reservationitem.

      SELECT *
        FROM ztpp_1016
         FOR ALL ENTRIES IN @lt_original_data
       WHERE reservation = @lt_original_data-reservation
         AND reservation_item = @lt_original_data-reservationitem
        INTO TABLE @DATA(lt_pp1016).
      SORT lt_pp1016 BY reservation reservation_item.

      IF lt_pp1016 IS NOT INITIAL.
        SELECT product,
               productname
          FROM i_producttext WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_pp1016
         WHERE product = @lt_pp1016-product
           AND language = @sy-langu
          INTO TABLE @DATA(lt_producttext).
        SORT lt_producttext BY product.
      ENDIF.
    ENDIF.

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      CLEAR lt_detail.

      lv_rowno += 1.
      <fs_original_data>-rowno = lv_rowno.

      READ TABLE lt_materialdocument INTO DATA(ls_materialdocument) WITH KEY reservation = <fs_original_data>-reservation
                                                                             reservationitem = <fs_original_data>-reservationitem
                                                                             BINARY SEARCH.
      IF sy-subrc = 0.

        READ TABLE lt_materialdocument INTO ls_materialdocument WITH KEY reservation = <fs_original_data>-reservation
                                                                         reservationitem = <fs_original_data>-reservationitem
                                                                         goodsmovementtype = '311'
                                                                         BINARY SEARCH.
        IF sy-subrc = 0.
          DATA(lv_quantity1) = ls_materialdocument-quantityinbaseunit.
        ELSE.
          CLEAR lv_quantity1.
        ENDIF.

        READ TABLE lt_materialdocument INTO ls_materialdocument WITH KEY reservation = <fs_original_data>-reservation
                                                                         reservationitem = <fs_original_data>-reservationitem
                                                                         goodsmovementtype = '312'
                                                                         BINARY SEARCH.
        IF sy-subrc = 0.
          DATA(lv_quantity2) = ls_materialdocument-quantityinbaseunit.
        ELSE.
          CLEAR lv_quantity2.
        ENDIF.

        READ TABLE lt_reservationdocument INTO DATA(ls_reservationdocument) WITH KEY reservation = <fs_original_data>-reservation
                                                                                     reservationitem = <fs_original_data>-reservationitem
                                                                                     BINARY SEARCH.
        IF sy-subrc = 0.
          DATA(lv_quantity3) = ls_reservationdocument-resvnitmrequiredqtyinbaseunit.
        ELSE.
          CLEAR lv_quantity3.
        ENDIF.

        IF lv_quantity1 - lv_quantity2 = 0.
          <fs_original_data>-postingstatus   = '未転記'.
        ELSEIF lv_quantity1 - lv_quantity2 > 0 AND lv_quantity1 - lv_quantity2 - lv_quantity3 >= 0.
          <fs_original_data>-postingstatus   = '転記済'.
          <fs_original_data>-postingquantity = lv_quantity1 - lv_quantity2.
        ELSEIF lv_quantity1 - lv_quantity2 > 0 AND lv_quantity1 - lv_quantity2 - lv_quantity3 < 0.
          <fs_original_data>-postingstatus   = '一部転記'.
          <fs_original_data>-postingquantity = lv_quantity1 - lv_quantity2.
        ENDIF.
      ELSE.
        <fs_original_data>-postingstatus = '未転記'.
      ENDIF.

      " Detail
      LOOP AT lt_pp1016 INTO DATA(ls_pp1016) WHERE reservation = <fs_original_data>-reservation
                                               AND reservation_item = <fs_original_data>-reservationitem.

        APPEND INITIAL LINE TO lt_detail ASSIGNING FIELD-SYMBOL(<lfs_detail>).
        <lfs_detail> = CORRESPONDING #( ls_pp1016 ).
        IF <lfs_detail>-short_quantity >= 0.
          <lfs_detail>-short_quantity_color = 'red'.
        ELSE.
          <lfs_detail>-short_quantity_color = 'green'.
        ENDIF.

        TRY.
            <lfs_detail>-base_unit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_detail>-base_unit ).
            ##NO_HANDLER
          CATCH zzcx_custom_exception.
            " handle exception
        ENDTRY.

        <lfs_detail>-manufacturing_order       = |{ <lfs_detail>-manufacturing_order ALPHA = OUT }|.
        <lfs_detail>-plant                     = <fs_original_data>-plant.
        <lfs_detail>-material                  = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <fs_original_data>-material ).
        <lfs_detail>-material_name             = <fs_original_data>-materialname.
        <lfs_detail>-total_required_quantity   = <fs_original_data>-totalrequiredquantity.
        <lfs_detail>-storage_location_to_stock = <fs_original_data>-storagelocationtostock.
        <lfs_detail>-total_short_fall_quantity = <fs_original_data>-totalshortfallquantity.
        <lfs_detail>-storage_location_to       = <fs_original_data>-storagelocationto.
        <lfs_detail>-storage_location_to_name  = <fs_original_data>-storagelocationtoname.
        <lfs_detail>-product                   = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = ls_pp1016-product ).
        READ TABLE lt_producttext INTO DATA(ls_producttext) WITH KEY product = ls_pp1016-product BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_detail>-product_name = ls_producttext-productname.
        ENDIF.
      ENDLOOP.

      <fs_original_data>-detailsjson = xco_cp_json=>data->from_abap( lt_detail )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
