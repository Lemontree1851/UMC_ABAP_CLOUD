CLASS zcl_query_productionorder DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_query_productionorder IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA:
      lt_data                     TYPE STANDARD TABLE OF zc_productionorder,
      lr_user_plant               TYPE RANGE OF zc_productionorder-plant,
      lr_plant                    TYPE RANGE OF zc_productionorder-plant,
      lr_mrpcontroller            TYPE RANGE OF zc_productionorder-mrpcontroller,
      lr_productionsupervisor     TYPE RANGE OF zc_productionorder-productionsupervisor,
      lr_material                 TYPE RANGE OF zc_productionorder-material,
      lr_mfgorderplannedstartdate TYPE RANGE OF zc_productionorder-mfgorderplannedstartdate,
      lr_mfgorderplannedenddate   TYPE RANGE OF zc_productionorder-mfgorderplannedenddate,
      lr_manufacturingordertype   TYPE RANGE OF zc_productionorder-manufacturingordertype,
      lr_manufacturingorder       TYPE RANGE OF zc_productionorder-manufacturingorder,
      ls_plant                    LIKE LINE OF lr_plant,
      ls_mrpcontroller            LIKE LINE OF lr_mrpcontroller,
      ls_productionsupervisor     LIKE LINE OF lr_productionsupervisor,
      ls_material                 LIKE LINE OF lr_material,
      ls_mfgorderplannedstartdate LIKE LINE OF lr_mfgorderplannedstartdate,
      ls_mfgorderplannedenddate   LIKE LINE OF lr_mfgorderplannedenddate,
      ls_manufacturingordertype   LIKE LINE OF lr_manufacturingordertype,
      ls_manufacturingorder       LIKE LINE OF lr_manufacturingorder,
      ls_data                     TYPE zc_productionorder,
      lv_assign_qty               TYPE ztpp_1014-assign_qty.

    CONSTANTS:
      lc_msgid            TYPE string VALUE 'ZPP_001',
      lc_msgty_e          TYPE string VALUE 'E',
      lc_producttype_zfrt TYPE string VALUE 'ZFRT',
      lc_strategygroup_40 TYPE string VALUE '40',
      lc_criticality_1    TYPE string VALUE '1'.

    IF io_request->is_data_requested( ).
      TRY.
          "Get and add filter
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option) ##NO_HANDLER.
      ENDTRY.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
          CASE ls_filter_cond-name.
            WHEN 'PLANT'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_plant.
              APPEND ls_plant TO lr_plant.
              CLEAR ls_plant.
            WHEN 'MRPCONTROLLER'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_mrpcontroller.
              APPEND ls_mrpcontroller TO lr_mrpcontroller.
              CLEAR ls_mrpcontroller.
            WHEN 'PRODUCTIONSUPERVISOR'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_productionsupervisor.
              APPEND ls_productionsupervisor TO lr_productionsupervisor.
              CLEAR ls_productionsupervisor.
            WHEN 'MATERIAL'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_material.
              APPEND ls_material TO lr_material.
              CLEAR ls_material.
            WHEN 'MFGORDERPLANNEDSTARTDATE'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_mfgorderplannedstartdate.
              APPEND ls_mfgorderplannedstartdate TO lr_mfgorderplannedstartdate.
              CLEAR ls_mfgorderplannedstartdate.
            WHEN 'MFGORDERPLANNEDENDDATE'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_mfgorderplannedenddate.
              APPEND ls_mfgorderplannedenddate TO lr_mfgorderplannedenddate.
              CLEAR ls_mfgorderplannedenddate.
            WHEN 'MANUFACTURINGORDERTYPE'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_manufacturingordertype.
              APPEND ls_manufacturingordertype TO lr_manufacturingordertype.
              CLEAR ls_manufacturingordertype.
            WHEN 'MANUFACTURINGORDER'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_manufacturingorder.
              APPEND ls_manufacturingorder TO lr_manufacturingorder.
              CLEAR ls_manufacturingorder.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      ENDLOOP.

      DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
*      lv_user_email = 'xinlei.xu@sh.shin-china.com'.
      DATA(lv_user_plant) = zzcl_common_utils=>get_plant_by_user( lv_user_email ).
      SPLIT lv_user_plant AT '&' INTO TABLE DATA(lt_user_plant).
      lr_user_plant = VALUE #( FOR plant IN lt_user_plant ( sign = 'I' option = 'EQ' low = plant ) ).

      "Obtain data of manufacturing order item
      SELECT a~manufacturingorder,
             a~productionplant AS plant,
             a~material,
             a~mfgorderplannedstartdate,
             a~mfgorderplannedenddate,
             a~productionunit,
             a~mfgorderplannedtotalqty,
             a~manufacturingordertype,
             a~mrpcontroller,
             a~productionsupervisor,
             a~productionversion,
             b~planningstrategygroup,
             c~producttype,
             d~productdescription
        FROM i_manufacturingorderitem WITH PRIVILEGED ACCESS AS a
       INNER JOIN i_productplantsupplyplanning WITH PRIVILEGED ACCESS AS b
          ON b~product = a~material
         AND b~plant = a~productionplant
       INNER JOIN i_product WITH PRIVILEGED ACCESS AS c
          ON c~product = a~material
        LEFT OUTER JOIN i_productdescription WITH PRIVILEGED ACCESS AS d
          ON d~product = a~material
         AND d~language = @sy-langu
       WHERE a~orderisreleased = @abap_false
         AND a~ismarkedfordeletion = @abap_false
         AND a~orderitemisnotrelevantformrp = @abap_false
         AND a~manufacturingorder IN @lr_manufacturingorder
         AND a~productionplant IN @lr_plant
         AND a~material IN @lr_material
         AND a~mfgorderplannedstartdate IN @lr_mfgorderplannedstartdate
         AND a~mfgorderplannedenddate IN @lr_mfgorderplannedenddate
         AND a~manufacturingordertype IN @lr_manufacturingordertype
         AND a~mrpcontroller IN @lr_mrpcontroller
         AND a~productionsupervisor IN @lr_productionsupervisor
        INTO TABLE @DATA(lt_manufacturingorderitem).

      IF lr_user_plant IS INITIAL.
        CLEAR lt_manufacturingorderitem.
      ELSE.
        DELETE lt_manufacturingorderitem WHERE plant NOT IN lr_user_plant.
      ENDIF.

      IF lt_manufacturingorderitem IS NOT INITIAL.
        "Obtain data of allocation relationship between production order and so
        SELECT plant,
               manufacturing_order,
               sales_order,
               sales_order_item,
               sequence,
               assign_qty
          FROM ztpp_1014
           FOR ALL ENTRIES IN @lt_manufacturingorderitem
         WHERE plant = @lt_manufacturingorderitem-plant
           AND manufacturing_order = @lt_manufacturingorderitem-manufacturingorder
           AND assign_qty <> 0
          INTO TABLE @DATA(lt_ztpp_1014).
      ENDIF.

      SORT lt_manufacturingorderitem BY plant manufacturingorder.
      SORT lt_ztpp_1014 BY plant manufacturing_order sales_order sales_order_item.

      LOOP AT lt_manufacturingorderitem INTO DATA(ls_manufacturingorderitem).
        MOVE-CORRESPONDING ls_manufacturingorderitem TO ls_data.

*        TRY.
*            ls_data-productionunit = zzcl_common_utils=>conversion_cunit( iv_alpha = lc_alpha_out
*                                                                          iv_input = ls_manufacturingorderitem-productionunit ).
*          CATCH zzcx_custom_exception INTO DATA(lo_exc).
*            ls_data-productionunit = ls_manufacturingorderitem-productionunit.
*        ENDTRY.

        "Read data of allocation relationship between production order and so
        READ TABLE lt_ztpp_1014 INTO DATA(ls_ztpp_1014) WITH KEY plant = ls_manufacturingorderitem-plant
                                                                 manufacturing_order = ls_manufacturingorderitem-manufacturingorder
                                                        BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-salesorder = ls_ztpp_1014-sales_order.
          ls_data-salesorderitem = ls_ztpp_1014-sales_order_item.

          LOOP AT lt_ztpp_1014 INTO ls_ztpp_1014 FROM sy-tabix.
            IF ls_ztpp_1014-plant <> ls_manufacturingorderitem-plant
            OR ls_ztpp_1014-manufacturing_order <> ls_manufacturingorderitem-manufacturingorder.
              EXIT.
            ENDIF.

            lv_assign_qty = lv_assign_qty + ls_ztpp_1014-assign_qty.
          ENDLOOP.

          IF ls_data-mfgorderplannedtotalqty > lv_assign_qty.
            ls_data-criticality = lc_criticality_1.
            "製造指図の生産計画数が割当合計数より多くなる。
            MESSAGE ID lc_msgid TYPE lc_msgty_e NUMBER 086 INTO ls_data-message.
          ENDIF.
        ELSE.
          IF ls_data-producttype = lc_producttype_zfrt AND ls_data-planningstrategygroup = lc_strategygroup_40.
            ls_data-criticality = lc_criticality_1.
            "当該製造指図に受注を割当してください。
            MESSAGE ID lc_msgid TYPE lc_msgty_e NUMBER 087 INTO ls_data-message.
          ENDIF.
        ENDIF.

        APPEND ls_data TO lt_data.
        CLEAR:
          ls_data,
          lv_assign_qty.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_data ) ).

      "Sort
      IF io_request->get_sort_elements( ) IS NOT INITIAL.
        zzcl_odata_utils=>orderby(
          EXPORTING
            it_order = io_request->get_sort_elements( )
          CHANGING
            ct_data  = lt_data ).
      ENDIF.

      "Page
      zzcl_odata_utils=>paging(
        EXPORTING
          io_paging = io_request->get_paging( )
        CHANGING
          ct_data   = lt_data ).

      io_response->set_data( lt_data ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
