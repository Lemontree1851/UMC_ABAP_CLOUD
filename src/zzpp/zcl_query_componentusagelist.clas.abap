CLASS zcl_query_componentusagelist DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_query_componentusagelist IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    TYPES:
      BEGIN OF ty_finalproductinfo,
        highlevelmaterial            TYPE matnr,
        plant                        TYPE werks_d,
        billofmaterialcomponent      TYPE matnr,
        material                     TYPE matnr,
        validitystartdate            TYPE matnr,
        billofmaterialitemnumber     TYPE n LENGTH 4,
        billofmaterialitemquantity   TYPE i_billofmaterialitemdex_3-billofmaterialitemquantity,
        billofmaterialitemunit       TYPE meins,
        billofmaterialvariant        TYPE i_materialbomlink-billofmaterialvariant,
        billofmaterial               TYPE i_materialbomlink-billofmaterial,
        billofmaterialitemnodenumber TYPE i_billofmaterialitemdex_3-billofmaterialitemnodenumber,
        billofmaterialcategory       TYPE i_materialbomlink-billofmaterialcategory,
      END OF ty_finalproductinfo.

    DATA:
      lt_usagelist                 TYPE STANDARD TABLE OF zcl_bom_where_used=>ty_usagelist,
      lt_highlevelmaterialinfo     TYPE STANDARD TABLE OF zcl_bom_where_used=>ty_usagelist,
      lt_data                      TYPE STANDARD TABLE OF zc_componentusagelist,
      lt_finalproductinfo          TYPE STANDARD TABLE OF ty_finalproductinfo,
      lr_plant                     TYPE RANGE OF zc_componentusagelist-plant,
      lr_billofmaterialcomponent   TYPE RANGE OF zc_componentusagelist-billofmaterialcomponent,
      lr_productmanufacturernumber TYPE RANGE OF zc_componentusagelist-productmanufacturernumber,
      lr_suppliermaterialnumber    TYPE RANGE OF zc_componentusagelist-suppliermaterialnumber,
      lr_profilecode               TYPE RANGE OF i_productplantbasic-profilecode,
      ls_plant                     LIKE LINE OF lr_plant,
      ls_billofmaterialcomponent   LIKE LINE OF lr_billofmaterialcomponent,
      ls_productmanufacturernumber LIKE LINE OF lr_productmanufacturernumber,
      ls_suppliermaterialnumber    LIKE LINE OF lr_suppliermaterialnumber,
      ls_data                      TYPE zc_componentusagelist,
      ls_finalproductinfo          TYPE ty_finalproductinfo,
      lv_nodisplaynonproduct       TYPE abap_boolean.

    CONSTANTS:
      lc_sign_i           TYPE string VALUE 'I',
      lc_option_eq        TYPE string VALUE 'EQ',
      lc_producttype_zfrt TYPE string VALUE 'ZFRT',
      lc_profilecode_z5   TYPE string VALUE 'Z5',
      lc_alpha_in         TYPE string VALUE 'IN',
      lc_separator_comma  TYPE string VALUE ','.

*    IF io_request->is_data_requested( ).
    TRY.
        "Get and add filter
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
    ENDTRY.

    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
      LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
        CASE ls_filter_cond-name.
          WHEN 'PLANT'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_plant.
            APPEND ls_plant TO lr_plant.
            CLEAR ls_plant.
          WHEN 'BILLOFMATERIALCOMPONENT'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_billofmaterialcomponent.
            APPEND ls_billofmaterialcomponent TO lr_billofmaterialcomponent.
            CLEAR ls_billofmaterialcomponent.
          WHEN 'PRODUCTMANUFACTURERNUMBER'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_productmanufacturernumber.
            APPEND ls_productmanufacturernumber TO lr_productmanufacturernumber.
            CLEAR ls_productmanufacturernumber.
          WHEN 'SUPPLIERMATERIALNUMBER'.
            MOVE-CORRESPONDING str_rec_l_range TO ls_suppliermaterialnumber.
            APPEND ls_suppliermaterialnumber TO lr_suppliermaterialnumber.
            CLEAR ls_suppliermaterialnumber.
          WHEN 'NODISPLAYNONPRODUCT'.
            lv_nodisplaynonproduct = str_rec_l_range-low.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.

    IF lv_nodisplaynonproduct = abap_true.
      lr_profilecode = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lc_profilecode_z5 ) ).
    ENDIF.

    "Obtain data of bill of material component
    SELECT a~product,
           a~productmanufacturernumber,
           b~plant,
           b~mrpresponsible,
           c~productdescription
      FROM i_product WITH PRIVILEGED ACCESS AS a
     INNER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b
        ON b~product = a~product
      LEFT OUTER JOIN i_productdescription WITH PRIVILEGED ACCESS AS c
        ON c~product = a~product
       AND c~language = @sy-langu
     WHERE a~product IN @lr_billofmaterialcomponent
       AND a~productmanufacturernumber IN @lr_productmanufacturernumber
       AND a~producttype <> @lc_producttype_zfrt
       AND b~plant IN @lr_plant
       AND b~profilecode IN @lr_profilecode
      INTO TABLE @DATA(lt_component).
    IF sy-subrc = 0.
      "Obtain data of purchasing info record
      SELECT a~material,
             a~plant,
             b~suppliermaterialnumber
        FROM i_mppurchasingsourceitem WITH PRIVILEGED ACCESS AS a
       INNER JOIN i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS b
          ON b~supplier = a~supplier
         AND b~material = a~material
         FOR ALL ENTRIES IN @lt_component
       WHERE a~material = @lt_component-product
         AND a~plant = @lt_component-plant
         AND a~supplierisfixed = @abap_true
         AND b~suppliermaterialnumber IN @lr_suppliermaterialnumber
        INTO TABLE @DATA(lt_mppurchasingsourceitem).

      SORT lt_component BY plant product.

      LOOP AT lt_component INTO DATA(ls_component).
        "Obtain data of high level material of component
        zcl_bom_where_used=>get_data(
          EXPORTING
            iv_plant                   = ls_component-plant
            iv_billofmaterialcomponent = ls_component-product
          IMPORTING
            et_usagelist               = lt_usagelist ).

        APPEND LINES OF lt_usagelist TO lt_highlevelmaterialinfo.
        CLEAR lt_usagelist.
      ENDLOOP.

      IF lt_highlevelmaterialinfo IS NOT INITIAL.
        "Obtain data of bill of material item details
        SELECT billofmaterialcategory,
               billofmaterial,
               billofmaterialitemnodenumber,
               alternativeitemstrategy,
               alternativeitempriority
          FROM i_billofmaterialitembasic WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_highlevelmaterialinfo
         WHERE billofmaterialcategory = @lt_highlevelmaterialinfo-billofmaterialcategory
           AND billofmaterial = @lt_highlevelmaterialinfo-billofmaterial
           AND billofmaterialitemnodenumber = @lt_highlevelmaterialinfo-billofmaterialitemnodenumber
           INTO TABLE @DATA(lt_billofmaterialitembasic).

        "Obtain data of bill of material
        SELECT billofmaterialcategory,
               billofmaterial,
               billofmaterialvariant,
               billofmaterialitemnodenumber,
               billofmaterialitemunit
          FROM i_billofmaterialitemdex_3 WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_highlevelmaterialinfo
         WHERE billofmaterialcategory = @lt_highlevelmaterialinfo-billofmaterialcategory
           AND billofmaterial = @lt_highlevelmaterialinfo-billofmaterial
           AND billofmaterialvariant = @lt_highlevelmaterialinfo-billofmaterialvariant
           AND billofmaterialitemnodenumber = @lt_highlevelmaterialinfo-billofmaterialitemnodenumber
          INTO TABLE @DATA(lt_billofmaterialitemdex_3).

        DATA(lt_highlevelmaterialinfo_tmp) = lt_highlevelmaterialinfo.
        SORT lt_highlevelmaterialinfo_tmp BY plant material.
        DELETE ADJACENT DUPLICATES FROM lt_highlevelmaterialinfo_tmp
                              COMPARING plant material.

        LOOP AT lt_highlevelmaterialinfo_tmp INTO DATA(ls_highlevelmaterialinfo).
          "Obtain data of root level material of component(high level material)
          zcl_bom_where_used=>get_data(
            EXPORTING
              iv_plant                   = ls_highlevelmaterialinfo-plant
              iv_billofmaterialcomponent = ls_highlevelmaterialinfo-material
              iv_getusagelistroot        = abap_true
            IMPORTING
              et_usagelist               = lt_usagelist ).

          IF lt_usagelist IS NOT INITIAL.
            LOOP AT lt_usagelist INTO DATA(ls_usagelist).
              MOVE-CORRESPONDING ls_usagelist TO ls_finalproductinfo.
              ls_finalproductinfo-highlevelmaterial = ls_highlevelmaterialinfo-material.
              APPEND ls_finalproductinfo TO lt_finalproductinfo.
              CLEAR ls_finalproductinfo.
            ENDLOOP.
*           high level material没有更高的high level material，则high level material为root level material，即final product
          ELSE.
            ls_finalproductinfo-highlevelmaterial = ls_highlevelmaterialinfo-material.
            ls_finalproductinfo-plant             = ls_highlevelmaterialinfo-plant.
            ls_finalproductinfo-material          = ls_highlevelmaterialinfo-material.
            APPEND ls_finalproductinfo TO lt_finalproductinfo.
            CLEAR ls_finalproductinfo.
          ENDIF.

          CLEAR lt_usagelist.
        ENDLOOP.

        SORT lt_finalproductinfo BY plant highlevelmaterial material.
        DELETE ADJACENT DUPLICATES FROM lt_finalproductinfo
                              COMPARING plant highlevelmaterial material.

        IF lt_finalproductinfo IS NOT INITIAL.
          "Obtain data of customer material of final product
          SELECT salesorganization,
                 distributionchannel,
                 customer,
                 product,
                 materialbycustomer
            FROM i_customermaterial_2 WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_finalproductinfo
           WHERE product = @lt_finalproductinfo-material
             INTO TABLE @DATA(lt_customermaterial).

          SORT lt_customermaterial BY product materialbycustomer.
          DELETE ADJACENT DUPLICATES FROM lt_customermaterial
                                COMPARING product materialbycustomer.

          "Obtain data of final product description
          SELECT product,
                 productdescription
            FROM i_productdescription WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_finalproductinfo
           WHERE product = @lt_finalproductinfo-material
             AND language = @sy-langu
             INTO TABLE @DATA(lt_productdescription).
        ENDIF.

        "Obtain data of BOM sub items
        SELECT billofmaterialcategory,
               billofmaterial,
               billofmaterialitemnodenumber,
               bomsubitemnumbervalue,
               bomsubiteminstallationpoint
          FROM i_billofmaterialsubitemsbasic WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_highlevelmaterialinfo
         WHERE billofmaterialcategory = @lt_highlevelmaterialinfo-billofmaterialcategory
           AND billofmaterial = @lt_highlevelmaterialinfo-billofmaterial
           AND billofmaterialitemnodenumber = @lt_highlevelmaterialinfo-billofmaterialitemnodenumber
          INTO TABLE @DATA(lt_billofmaterialsubitemsbasic).
      ENDIF.
    ENDIF.

    SORT lt_highlevelmaterialinfo BY plant billofmaterialcomponent.
    SORT lt_billofmaterialitembasic BY billofmaterialcategory billofmaterial billofmaterialitemnodenumber.
    SORT lt_billofmaterialitemdex_3 BY billofmaterialcategory billofmaterial billofmaterialvariant billofmaterialitemnodenumber.
    SORT lt_productdescription BY product.
    SORT lt_mppurchasingsourceitem BY material plant.
    SORT lt_billofmaterialsubitemsbasic BY billofmaterialcategory billofmaterial billofmaterialitemnodenumber bomsubiteminstallationpoint.

    LOOP AT lt_component INTO ls_component.
      ls_data-plant                     = ls_component-plant.
      ls_data-billofmaterialcomponent   = ls_component-product.
      ls_data-componentdescription      = ls_component-productdescription.
      ls_data-productmanufacturernumber = ls_component-productmanufacturernumber.
      ls_data-mrpresponsible            = ls_component-mrpresponsible.

      "Read data of purchasing info record
      READ TABLE lt_mppurchasingsourceitem INTO DATA(ls_mppurchasingsourceitem) WITH KEY material = ls_component-product
                                                                                         plant = ls_component-plant
                                                                                BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-suppliermaterialnumber = ls_mppurchasingsourceitem-suppliermaterialnumber.
      ENDIF.

      "Read data of high level material of component
      READ TABLE lt_highlevelmaterialinfo TRANSPORTING NO FIELDS WITH KEY plant = ls_component-plant
                                                                          billofmaterialcomponent = ls_component-product
                                                                 BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_highlevelmaterialinfo INTO ls_highlevelmaterialinfo FROM sy-tabix.
          IF ls_highlevelmaterialinfo-plant <> ls_component-plant
          OR ls_highlevelmaterialinfo-billofmaterialcomponent <> ls_component-product.
            EXIT.
          ENDIF.

          ls_data-material                    = ls_highlevelmaterialinfo-material.
          ls_data-highlevelmatvaliditystartdate = ls_highlevelmaterialinfo-validitystartdate.
          ls_data-billofmaterialitemnumber      = ls_highlevelmaterialinfo-billofmaterialitemnumber.
          ls_data-billofmaterialitemquantity    = ls_highlevelmaterialinfo-billofmaterialitemquantity.
          ls_data-billofmaterialvariant         = ls_highlevelmaterialinfo-billofmaterialvariant.

*          TRY.
*              ls_data-billofmaterialitemunit = zzcl_common_utils=>conversion_cunit( iv_alpha = lc_alpha_in
*                                                                                    iv_input = ls_highlevelmaterialinfo-billofmaterialitemunit ).
*            CATCH zzcx_custom_exception INTO DATA(lo_exc).
*              ls_data-billofmaterialitemunit = ls_highlevelmaterialinfo-billofmaterialitemunit.
*          ENDTRY.

          CLEAR:
              ls_data-alternativeitemstrategy,
              ls_data-alternativeitempriority.

          "Read data of bill of material item details
          READ TABLE lt_billofmaterialitembasic INTO DATA(ls_billofmaterialitembasic) WITH KEY billofmaterialcategory = ls_highlevelmaterialinfo-billofmaterialcategory
                                                                                               billofmaterial = ls_highlevelmaterialinfo-billofmaterial
                                                                                               billofmaterialitemnodenumber = ls_highlevelmaterialinfo-billofmaterialitemnodenumber
                                                                                      BINARY SEARCH.
          IF sy-subrc = 0.
            ls_data-alternativeitemstrategy = ls_billofmaterialitembasic-alternativeitemstrategy.
            ls_data-alternativeitempriority = ls_billofmaterialitembasic-alternativeitempriority.
          ENDIF.

          CLEAR ls_data-billofmaterialitemunit.

          "Read data of bill of material item
          READ TABLE lt_billofmaterialitemdex_3 INTO DATA(ls_billofmaterialitemdex_3) WITH KEY billofmaterialcategory = ls_highlevelmaterialinfo-billofmaterialcategory
                                                                                               billofmaterial = ls_highlevelmaterialinfo-billofmaterial
                                                                                               billofmaterialvariant = ls_highlevelmaterialinfo-billofmaterialvariant
                                                                                               billofmaterialitemnodenumber = ls_highlevelmaterialinfo-billofmaterialitemnodenumber
                                                                                      BINARY SEARCH.
          IF sy-subrc = 0.
            ls_data-billofmaterialitemunit = ls_billofmaterialitemdex_3-billofmaterialitemunit.
          ENDIF.

          CLEAR ls_data-bomsubiteminstallationpoint.

          "Read data of BOM sub items
          READ TABLE lt_billofmaterialsubitemsbasic TRANSPORTING NO FIELDS WITH KEY billofmaterialcategory = ls_highlevelmaterialinfo-billofmaterialcategory
                                                                                    billofmaterial = ls_highlevelmaterialinfo-billofmaterial
                                                                                    billofmaterialitemnodenumber = ls_highlevelmaterialinfo-billofmaterialitemnodenumber
                                                                           BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_billofmaterialsubitemsbasic INTO DATA(ls_billofmaterialsubitemsbasic) FROM sy-tabix.
              IF ls_billofmaterialsubitemsbasic-billofmaterialcategory <> ls_highlevelmaterialinfo-billofmaterialcategory
              OR ls_billofmaterialsubitemsbasic-billofmaterial <> ls_highlevelmaterialinfo-billofmaterial
              OR ls_billofmaterialsubitemsbasic-billofmaterialitemnodenumber <> ls_highlevelmaterialinfo-billofmaterialitemnodenumber.
                EXIT.
              ENDIF.

              IF ls_billofmaterialsubitemsbasic-bomsubiteminstallationpoint IS NOT INITIAL.
                IF ls_data-bomsubiteminstallationpoint IS INITIAL.
                  ls_data-bomsubiteminstallationpoint = ls_billofmaterialsubitemsbasic-bomsubiteminstallationpoint.
                ELSE.
                  CONCATENATE ls_data-bomsubiteminstallationpoint
                              ls_billofmaterialsubitemsbasic-bomsubiteminstallationpoint
                         INTO ls_data-bomsubiteminstallationpoint
                    SEPARATED BY lc_separator_comma.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.

          "Read data of root level material of component(high level material)
          READ TABLE lt_finalproductinfo TRANSPORTING NO FIELDS WITH KEY plant = ls_highlevelmaterialinfo-plant
                                                                         highlevelmaterial = ls_highlevelmaterialinfo-material
                                                                BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_finalproductinfo INTO ls_finalproductinfo FROM sy-tabix.
              IF ls_finalproductinfo-plant <> ls_highlevelmaterialinfo-plant
              OR ls_finalproductinfo-highlevelmaterial <> ls_highlevelmaterialinfo-material.
                EXIT.
              ENDIF.

              ls_data-product = ls_finalproductinfo-material.

              "Read data of customer material of final product
              READ TABLE lt_customermaterial INTO DATA(ls_customermaterial) WITH KEY product = ls_finalproductinfo-material
                                                                            BINARY SEARCH.
              IF sy-subrc = 0.
                ls_data-materialbycustomer = ls_customermaterial-materialbycustomer.
              ENDIF.

              "Read data of final product description
              READ TABLE lt_productdescription INTO DATA(ls_productdescription) WITH KEY product = ls_finalproductinfo-material
                                                                                BINARY SEARCH.
              IF sy-subrc = 0.
                ls_data-productdescription = ls_productdescription-productdescription.
              ENDIF.

              APPEND ls_data TO lt_data.
              CLEAR:
                ls_data-materialbycustomer,
                ls_data-productdescription.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
      ENDIF.

      CLEAR ls_data.
    ENDLOOP.

    IF lr_suppliermaterialnumber IS NOT INITIAL.
      DELETE lt_data WHERE suppliermaterialnumber NOT IN lr_suppliermaterialnumber.
    ENDIF.

    SORT lt_data BY plant billofmaterialcomponent material billofmaterialvariant product.

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
*    ENDIF.
  ENDMETHOD.
ENDCLASS.
