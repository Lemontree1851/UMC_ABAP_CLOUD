CLASS zcl_bom DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BOM IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TYPES:
      BEGIN OF ty_changemaster_ent,
        objmgmtrecdobject    TYPE aeusobj,
        sapobjecttechnicalid TYPE aeobjekt,
      END OF ty_changemaster_ent.

    DATA:
      lt_bomlist_tmp       TYPE STANDARD TABLE OF zcl_explodebom=>ty_bomlist,
      lt_bomlist           TYPE STANDARD TABLE OF zcl_explodebom=>ty_bomlist,
      lt_changemaster_ent  TYPE STANDARD TABLE OF ty_changemaster_ent,
      lt_data              TYPE STANDARD TABLE OF zr_bom,
      lr_plant             TYPE RANGE OF zr_bom-plant,
      lr_material          TYPE RANGE OF zr_bom-material,
      lr_mrpresponsible    TYPE RANGE OF zr_bom-mrpresponsible,
      lr_variant           TYPE RANGE OF zr_bom-billofmaterialvariant,
      ls_material          LIKE LINE OF lr_material,
      ls_mrpresponsible    LIKE LINE OF lr_mrpresponsible,
      ls_variant           LIKE LINE OF lr_variant,
      ls_changemaster_ent  TYPE ty_changemaster_ent,
      ls_data              TYPE zr_bom,
      lv_plant             TYPE zr_bom-plant,
      lv_appid             TYPE zr_bom-bomexplosionapplication,
      lv_variant           TYPE zr_bom-billofmaterialvariant,
      lv_startdate         TYPE zr_bom-headervaliditystartdate,
      lv_reqquantity       TYPE zr_bom-requiredquantity,
      lv_explosiontype     TYPE zr_bom-bomexplosiontype,
      lv_showsubparts      TYPE zr_bom-showsubparts,
      lv_localposition     TYPE zr_bom-localposition,
      lv_objmgmtrecdobject TYPE aeusobj,
      lv_minimumgroup      TYPE abap_boolean.

    CONSTANTS:
      lc_msgid                     TYPE string VALUE 'ZPP_001',
      lc_msgty                     TYPE string VALUE 'E',
      lc_alpha_in                  TYPE string VALUE 'IN',
      lc_alpha_out                 TYPE string VALUE 'OUT',
      lc_separator                 TYPE string VALUE '、',
      lc_sapobjecttype_material    TYPE string VALUE 'Material',
      lc_changenumberobjecttype_41 TYPE string VALUE '41',
      lc_itemgroup_main            TYPE string VALUE 'Main',
      lc_itemgroup_sub             TYPE string VALUE 'Sub',
      lc_discfollowupgroup_stop    TYPE string VALUE 'Stop',
      lc_discfollowupgroup_new     TYPE string VALUE 'New',
      lc_localposition_h           TYPE string VALUE 'H',
      lc_localposition_v           TYPE string VALUE 'V',
      lc_profilecode_z0            TYPE string VALUE 'Z0',
      lc_profilecode_z2            TYPE string VALUE 'Z2',
      lc_profilecode_z3            TYPE string VALUE 'Z3',
      lc_profilecode_lock          TYPE string VALUE 'Purcahse Lock',
      lc_changenumberobjecttype    TYPE aetyp  VALUE '41',
      lc_priority_01               TYPE n LENGTH 2  VALUE '01',
*      lc_priority_02            TYPE n LENGTH 2  VALUE '02',
*      lc_itemcategory_l         TYPE c LENGTH 1  VALUE 'L',
      lc_ispurcondrec_yes          TYPE c LENGTH 10 VALUE 'YES',
      lc_ispurcondrec_no           TYPE c LENGTH 10 VALUE 'NO',
      lc_sign_i                    TYPE c LENGTH 1 VALUE 'I',
      lc_opt_eq                    TYPE c LENGTH 2 VALUE 'EQ',
      lc_opt_le                    TYPE c LENGTH 2 VALUE 'LE'.

    IF io_request->is_data_requested( ).
      TRY.
          "Get and add filter
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option) ##NO_HANDLER.
      ENDTRY.

*      DATA(lv_top)    = io_request->get_paging( )->get_page_size( ).
*      DATA(lv_skip)   = io_request->get_paging( )->get_offset( ).
*      DATA(lt_fields) = io_request->get_requested_elements( ).
*      DATA(lt_sort) = io_request->get_sort_elements( ).

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
          CASE ls_filter_cond-name.
            WHEN 'PLANT'.
              DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
              DATA(lv_user_plant) = zzcl_common_utils=>get_plant_by_user( lv_user_email ).

              IF lv_user_plant IS NOT INITIAL.
                SPLIT lv_user_plant AT '&' INTO TABLE DATA(lt_plant).
                lr_plant = VALUE #( FOR plant IN lt_plant ( sign = 'I' option = 'EQ' low = plant ) ).
                IF str_rec_l_range-low IN lr_plant.
                  lv_plant = str_rec_l_range-low.
                ENDIF.
              ENDIF.
            WHEN 'MATERIAL'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_material.
              ls_material-low  = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_material-low ).
              ls_material-high = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_material-high ).
              APPEND ls_material TO lr_material.
              CLEAR ls_material.
            WHEN 'MRPRESPONSIBLE'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_mrpresponsible.
              APPEND ls_mrpresponsible TO lr_mrpresponsible.
              CLEAR ls_mrpresponsible.
            WHEN 'BOMEXPLOSIONAPPLICATION'.
              lv_appid = str_rec_l_range-low.
            WHEN 'BILLOFMATERIALVARIANT'.
              lv_variant = |{ str_rec_l_range-low ALPHA = IN }|.
            WHEN 'HEADERVALIDITYSTARTDATE'.
              lv_startdate = str_rec_l_range-low.
            WHEN 'REQUIREDQUANTITY'.
              lv_reqquantity = str_rec_l_range-low.
            WHEN 'BOMEXPLOSIONTYPE'.
              lv_explosiontype = str_rec_l_range-low.
            WHEN 'SHOWSUBPARTS'.
              lv_showsubparts = str_rec_l_range-low.
            WHEN 'LOCALPOSITION'.
              lv_localposition = str_rec_l_range-low.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      ENDLOOP.

      "单层
      IF lv_explosiontype = '1'.
        IF lv_variant IS NOT INITIAL.
          ls_variant-sign = lc_sign_i.
          ls_variant-option = lc_opt_eq.
          ls_variant-low = lv_variant.
          APPEND ls_variant TO lr_variant.
        ENDIF.
        "多层
      ELSE.
        "最上层=可选BOM输入值
        IF lv_explosiontype = '2'.
          ls_variant-sign = lc_sign_i.
          ls_variant-option = lc_opt_eq.
          ls_variant-low = lv_variant.
          APPEND ls_variant TO lr_variant.
        ENDIF.

        "所有层<=可选BOM输入值
        IF lv_explosiontype = '3'.
          ls_variant-sign = lc_sign_i.
          ls_variant-option = lc_opt_le.
          ls_variant-low = lv_variant.
          APPEND ls_variant TO lr_variant.
        ENDIF.
      ENDIF.

      IF lv_explosiontype = '3'.
        "Obtain data of bill of material
        SELECT a~billofmaterial,
               MAX( a~billofmaterialvariant ) AS billofmaterialvariant,
               a~material,
               a~plant,
               a~billofmaterialcategory
          FROM i_materialbomlink WITH PRIVILEGED ACCESS AS a
         INNER JOIN i_billofmaterialwithkeydate WITH PRIVILEGED ACCESS AS b
            ON b~billofmaterialcategory = a~billofmaterialcategory
           AND b~billofmaterialvariantusage = a~billofmaterialvariantusage
           AND b~billofmaterial = a~billofmaterial
           AND b~billofmaterialvariant = a~billofmaterialvariant
         INNER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS c
            ON c~product = a~material
           AND c~plant = a~plant
         WHERE a~billofmaterialvariant IN @lr_variant
           AND a~material IN @lr_material
           AND a~plant = @lv_plant
           AND bomexplosionapplication = @lv_appid
           AND b~headervaliditystartdate <= @lv_startdate
           AND b~headervalidityenddate >= @lv_startdate
           AND c~mrpresponsible IN @lr_mrpresponsible
         GROUP BY a~billofmaterial,
                  a~material,
                  a~plant,
                  a~billofmaterialcategory
          INTO TABLE @DATA(lt_materialbomlink).
      ELSE.
        "Obtain data of bill of material
        SELECT a~billofmaterial,
               a~billofmaterialvariant,
               a~material,
               a~plant,
               a~billofmaterialcategory
          FROM i_materialbomlink WITH PRIVILEGED ACCESS AS a
         INNER JOIN i_billofmaterialwithkeydate WITH PRIVILEGED ACCESS AS b
            ON b~billofmaterialcategory = a~billofmaterialcategory
           AND b~billofmaterialvariantusage = a~billofmaterialvariantusage
           AND b~billofmaterial = a~billofmaterial
           AND b~billofmaterialvariant = a~billofmaterialvariant
         INNER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS c
            ON c~product = a~material
           AND c~plant = a~plant
         WHERE a~billofmaterialvariant IN @lr_variant
           AND a~material IN @lr_material
           AND a~plant = @lv_plant
           AND bomexplosionapplication = @lv_appid
           AND b~headervaliditystartdate <= @lv_startdate
           AND b~headervalidityenddate >= @lv_startdate
           AND c~mrpresponsible IN @lr_mrpresponsible
          INTO TABLE @lt_materialbomlink.
      ENDIF.

      SORT lt_materialbomlink BY billofmaterialcategory material plant billofmaterialvariant.

      LOOP AT lt_materialbomlink INTO DATA(ls_materialbomlink).
        "Explode BOM
        zcl_explodebom=>get_data(
          EXPORTING
            iv_explosiontype               = lv_explosiontype
            iv_plant                       = ls_materialbomlink-plant
            iv_material                    = ls_materialbomlink-material
            iv_billofmaterialcategory      = ls_materialbomlink-billofmaterialcategory
            iv_billofmaterialvariant       = lv_variant
            iv_bomexplosionapplication     = lv_appid
            iv_bomexplosiondate            = lv_startdate
            iv_headermaterial              = ls_materialbomlink-material
            iv_headerbillofmaterialvariant = ls_materialbomlink-billofmaterialvariant
            iv_requiredquantity            = lv_reqquantity
          CHANGING
            ct_bomlist                     = lt_bomlist_tmp ).

        APPEND LINES OF lt_bomlist_tmp TO lt_bomlist.
        CLEAR lt_bomlist_tmp.
      ENDLOOP.

      IF lt_bomlist IS NOT INITIAL.
        lt_bomlist_tmp = lt_bomlist.
        SORT lt_bomlist_tmp BY headermaterial plant.
        DELETE ADJACENT DUPLICATES FROM lt_bomlist_tmp
                              COMPARING headermaterial plant.

        "Obtain data of product plant(header material)
        SELECT product,
               plant,
               mrpresponsible
          FROM i_productplantbasic WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_bomlist_tmp
         WHERE product = @lt_bomlist_tmp-headermaterial
           AND plant = @lt_bomlist_tmp-plant
           AND mrpresponsible IN @lr_mrpresponsible
          INTO TABLE @DATA(lt_productplantbasic).

        LOOP AT lt_bomlist_tmp INTO DATA(ls_bomlist).
*          ls_changemaster_ent-objmgmtrecdobject+0(40) = ls_bomlist-headermaterial.
*          ls_changemaster_ent-objmgmtrecdobject+40(4) = ls_bomlist-plant.
*          ls_changemaster_ent-objmgmtrecdobject+44(1) = ls_bomlist-billofmaterialvariantusage.
          ls_changemaster_ent-sapobjecttechnicalid    = ls_bomlist-headermaterial.
          APPEND ls_changemaster_ent TO lt_changemaster_ent.
          CLEAR ls_changemaster_ent.
        ENDLOOP.
*
*        "Obtain data of change number object management record
*        SELECT a~objmgmtrecdobject,
*               b~changenumber,
*               b~sapobjecttechnicalid,
*               b~objmgmtrecdobjrevisionlevel
*          FROM i_chgmstrobjectmgmtrecordtp_2 WITH PRIVILEGED ACCESS AS a
*         INNER JOIN i_chgmstrobjectmgmtrecordtp_2 WITH PRIVILEGED ACCESS AS b
*            ON b~changenumber = a~changenumber
*           AND b~changenumberobjecttype = @lc_changenumberobjecttype
*         INNER JOIN i_changemastertp_2 WITH PRIVILEGED ACCESS AS c
*            ON c~changenumber = a~changenumber
*           FOR ALL ENTRIES IN @lt_changemaster_ent
*         WHERE a~objmgmtrecdobject = @lt_changemaster_ent-objmgmtrecdobject
*           AND b~sapobjecttechnicalid = @lt_changemaster_ent-sapobjecttechnicalid
*           AND c~changenumberismrkdfordeletion = @abap_false
*           AND c~changenumbervalidfromdate <= @lv_startdate
*          INTO TABLE @DATA(lt_chgmstrobjectmgmtrecordtp_2).

        "Obtain data of change number object management record
        SELECT changenumber,
               sapobjecttechnicalid,
               objmgmtrecdobjrevisionlevel
          FROM i_chgmstrobjectmgmtrecordtp_2 WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_changemaster_ent
         WHERE sapobjecttechnicalid = @lt_changemaster_ent-sapobjecttechnicalid
           AND sapobjecttype = @lc_sapobjecttype_material
           AND changenumberobjecttype = @lc_changenumberobjecttype_41
          INTO TABLE @DATA(lt_chgmstrobjectmgmtrecordtp_2).

        lt_bomlist_tmp = lt_bomlist.
        SORT lt_bomlist_tmp BY billofmaterialcomponent plant.
        DELETE ADJACENT DUPLICATES FROM lt_bomlist_tmp
                              COMPARING billofmaterialcomponent plant.

        "Obtain data of product plant(component)
        SELECT product,
               plant,
               profilecode
          FROM i_productplantbasic WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_bomlist_tmp
         WHERE product = @lt_bomlist_tmp-billofmaterialcomponent
           AND plant = @lt_bomlist_tmp-plant
           AND mrpresponsible IN @lr_mrpresponsible
          INTO TABLE @DATA(lt_productplantbasic_com).

        "Obtain data of product
        SELECT a~product,
               a~productmanufacturernumber,
               a~netweight,
               a~weightunit,
               b~businesspartnerfullname
          FROM i_product WITH PRIVILEGED ACCESS AS a
          LEFT OUTER JOIN i_businesspartner WITH PRIVILEGED ACCESS AS b
            ON b~businesspartner = a~manufacturernumber
           FOR ALL ENTRIES IN @lt_bomlist_tmp
         WHERE product = @lt_bomlist_tmp-billofmaterialcomponent
          INTO TABLE @DATA(lt_product).

        "Obtain data of condition record
        SELECT b~material,
               b~plant
          FROM i_purgprcgconditionrecord WITH PRIVILEGED ACCESS AS a
         INNER JOIN i_purginforecdprcgcndnvaldtytp WITH PRIVILEGED ACCESS AS b
            ON b~conditionrecord = a~conditionrecord
           FOR ALL ENTRIES IN @lt_bomlist_tmp
         WHERE b~material = @lt_bomlist_tmp-billofmaterialcomponent
           AND b~plant = @lt_bomlist_tmp-plant
           AND b~conditionvaliditystartdate <= @lv_startdate
           AND b~conditionvalidityenddate >= @lv_startdate
           AND a~conditionisdeleted = @abap_false
          INTO TABLE @DATA(lt_purgprcgcndnrecdvalidity).

        lt_bomlist_tmp = lt_bomlist.
        SORT lt_bomlist_tmp BY billofmaterialcategory billofmaterial billofmaterialvariant.
        DELETE ADJACENT DUPLICATES FROM lt_bomlist_tmp
                              COMPARING billofmaterialcategory
                                        billofmaterial
                                        billofmaterialvariant.

        "Obtain data of BOM header
        SELECT billofmaterialcategory,
               billofmaterial,
               billofmaterialvariant,
               bomheadertext
          FROM i_billofmaterialheaderdex_2 WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_bomlist_tmp
         WHERE billofmaterialcategory = @lt_bomlist_tmp-billofmaterialcategory
           AND billofmaterial = @lt_bomlist_tmp-billofmaterial
           AND billofmaterialvariant = @lt_bomlist_tmp-billofmaterialvariant
          INTO TABLE @DATA(lt_billofmaterialheaderdex_2).

        lt_bomlist_tmp = lt_bomlist.
        SORT lt_bomlist_tmp BY billofmaterialcategory billofmaterial billofmaterialvariant billofmaterialitemnodenumber.
        DELETE ADJACENT DUPLICATES FROM lt_bomlist_tmp
                              COMPARING billofmaterialcategory
                                        billofmaterial
                                        billofmaterialvariant
                                        billofmaterialitemnodenumber.

        "Obtain data of BOM item
        SELECT billofmaterialcategory,
               billofmaterial,
               billofmaterialvariant,
               billofmaterialitemnodenumber,
               billofmaterialitemnumber,
               bomitemissparepart,
               engineeringchangedocument
          FROM i_billofmaterialitemdex_3 WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_bomlist_tmp
         WHERE billofmaterialcategory = @lt_bomlist_tmp-billofmaterialcategory
           AND billofmaterial = @lt_bomlist_tmp-billofmaterial
           AND billofmaterialvariant = @lt_bomlist_tmp-billofmaterialvariant
*           AND billofmaterialitemnodenumber = @lt_bomlist_tmp-billofmaterialitemnodenumber
           AND billofmaterialitemnumber = @lt_bomlist_tmp-billofmaterialitemnumber
           AND validitystartdate <= @lv_startdate
           AND validityenddate >= @lv_startdate
          INTO TABLE @DATA(lt_billofmaterialitemdex_3).

        "Obtain data of BOM sub items
        SELECT billofmaterialcategory,
               billofmaterial,
               billofmaterialitemnodenumber,
               bomsubitemnumbervalue,
               bomsubiteminstallationpoint,
               billofmaterialsubitemquantity
          FROM i_billofmaterialsubitemsbasic WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_bomlist_tmp
         WHERE billofmaterialcategory = @lt_bomlist_tmp-billofmaterialcategory
           AND billofmaterial = @lt_bomlist_tmp-billofmaterial
           AND billofmaterialitemnodenumber = @lt_bomlist_tmp-billofmaterialitemnodenumber
          INTO TABLE @DATA(lt_billofmaterialsubitemsbasic).

        lt_bomlist_tmp = lt_bomlist.
        SORT lt_bomlist_tmp BY materialgroup.
        DELETE ADJACENT DUPLICATES FROM lt_bomlist_tmp
                              COMPARING materialgroup.

        "Obtain data of product group text
        SELECT productgroup,
               productgroupname
          FROM i_productgrouptext_2 WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_bomlist_tmp
         WHERE productgroup = @lt_bomlist_tmp-materialgroup
           AND language = @sy-langu
          INTO TABLE @DATA(lt_productgrouptext_2).
      ENDIF.

      SORT lt_billofmaterialheaderdex_2 BY billofmaterialcategory billofmaterial billofmaterialvariant.
      SORT lt_billofmaterialitemdex_3 BY billofmaterialcategory billofmaterial billofmaterialvariant billofmaterialitemnumber.
      SORT lt_product BY product.
      SORT lt_productplantbasic BY product plant.
      SORT lt_productplantbasic_com BY product plant.
      SORT lt_purgprcgcndnrecdvalidity BY material plant.
      SORT lt_billofmaterialsubitemsbasic BY billofmaterialcategory billofmaterial billofmaterialitemnodenumber bomsubitemnumbervalue.
      SORT lt_chgmstrobjectmgmtrecordtp_2 BY sapobjecttechnicalid changenumber.
      SORT lt_productgrouptext_2 BY productgroup.

      IF lv_explosiontype = 4.
        SORT lt_bomlist BY explodebomlevelvalue material plant billofmaterialvariant headermaterial billofmaterialitemnumber.
        DELETE ADJACENT DUPLICATES FROM lt_bomlist
                              COMPARING explodebomlevelvalue material plant billofmaterialvariant headermaterial billofmaterialitemnumber.
      ENDIF.

      lt_bomlist_tmp = lt_bomlist.
      DELETE lt_bomlist_tmp WHERE alternativeitemgroup IS INITIAL.
      SORT lt_bomlist_tmp BY material plant billofmaterialvariant headermaterial explodebomlevelvalue alternativeitemgroup alternativeitempriority.

      LOOP AT lt_bomlist INTO ls_bomlist.
        IF  lv_showsubparts = abap_false
        AND ls_bomlist-alternativeitempriority IS NOT INITIAL AND ls_bomlist-alternativeitempriority <> lc_priority_01.
          CONTINUE.
        ENDIF.

        MOVE-CORRESPONDING ls_bomlist TO ls_data.

        TRY.
            ls_data-billofmaterialitemunit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                            iv_input = ls_bomlist-billofmaterialitemunit ).

            ls_data-billofmaterialitembaseunit = zzcl_common_utils=>conversion_cunit(
                                                   EXPORTING iv_alpha = lc_alpha_out
                                                             iv_input = ls_bomlist-billofmaterialitembaseunit ).
          CATCH zzcx_custom_exception INTO DATA(lo_exc).
            ls_data-billofmaterialitemunit     = ls_bomlist-billofmaterialitemunit.
            ls_data-billofmaterialitembaseunit = ls_bomlist-billofmaterialitembaseunit.
        ENDTRY.

        "Read data of product plant(header material)
        READ TABLE lt_productplantbasic INTO DATA(ls_productplantbasic) WITH KEY product = ls_bomlist-headermaterial
                                                                                 plant = ls_bomlist-plant
                                                                        BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-mrpresponsible = ls_productplantbasic-mrpresponsible.
        ELSE.
          CONTINUE.
        ENDIF.

        "Read data of product plant(component)
        READ TABLE lt_productplantbasic_com INTO DATA(ls_productplantbasic_com) WITH KEY product = ls_bomlist-billofmaterialcomponent
                                                                                         plant = ls_bomlist-plant
                                                                                BINARY SEARCH.
        IF sy-subrc = 0.
          IF ls_productplantbasic_com-profilecode = lc_profilecode_z0
          OR ls_productplantbasic_com-profilecode = lc_profilecode_z2
          OR ls_productplantbasic_com-profilecode = lc_profilecode_z3.
            ls_data-profilecode = lc_profilecode_lock.
          ENDIF.
        ENDIF.

*        IF ls_bomlist-alternativeitempriority = lc_priority_01 AND ls_bomlist-alternativeitemgroup IS NOT INITIAL.
*          IF ls_bomlist-billofmaterialitemcategory IS NOT INITIAL.
*            IF ls_bomlist-billofmaterialitemcategory = lc_itemcategory_l.
*              ls_data-alternativeitemgroup = ls_bomlist-alternativeitemgroup && lc_itemgroup_main.
*            ELSE.
*              ls_data-alternativeitemgroup = ls_bomlist-alternativeitemgroup && lc_itemgroup_main && ls_bomlist-billofmaterialitemcategory.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
*        IF ls_bomlist-alternativeitempriority = lc_priority_02 AND ls_bomlist-alternativeitemgroup IS NOT INITIAL.
*          IF ls_bomlist-billofmaterialitemcategory IS NOT INITIAL.
*            IF ls_bomlist-billofmaterialitemcategory = lc_itemcategory_l.
*              ls_data-alternativeitemgroup = ls_bomlist-alternativeitemgroup && lc_itemgroup_sub.
*            ELSE.
*              ls_data-alternativeitemgroup = ls_bomlist-alternativeitemgroup && lc_itemgroup_sub && ls_bomlist-billofmaterialitemcategory.
*            ENDIF.
*          ENDIF.
*        ENDIF.

        "Read data of alternative item group
        READ TABLE lt_bomlist_tmp INTO DATA(ls_bomlist_tmp) WITH KEY material = ls_bomlist-material
                                                                     plant = ls_bomlist-plant
                                                                     billofmaterialvariant = ls_bomlist-billofmaterialvariant
                                                                     headermaterial = ls_bomlist-headermaterial
                                                                     explodebomlevelvalue = ls_bomlist-explodebomlevelvalue
                                                                     alternativeitemgroup = ls_bomlist-alternativeitemgroup
                                                            BINARY SEARCH.
        IF sy-subrc = 0.
          "Minimum alternative item group
          IF ls_bomlist_tmp-billofmaterialitemnumber = ls_bomlist-billofmaterialitemnumber.
            ls_data-alternativeitemgroup = ls_bomlist-alternativeitemgroup && lc_itemgroup_main.
          ELSE.
            ls_data-alternativeitemgroup = ls_bomlist-alternativeitemgroup && lc_itemgroup_sub.
          ENDIF.
        ENDIF.

        IF ls_bomlist-followupgroup IS INITIAL.
          IF ls_bomlist-discontinuationgroup IS NOT INITIAL.
            ls_data-discontinuationfollowupgroup = ls_bomlist-discontinuationgroup && lc_discfollowupgroup_stop.
          ENDIF.
        ELSE.
          ls_data-discontinuationfollowupgroup = ls_bomlist-followupgroup && lc_discfollowupgroup_new.
        ENDIF.

        "Read data of BOM header
        READ TABLE lt_billofmaterialheaderdex_2 INTO DATA(ls_billofmaterialheaderdex_2) WITH KEY billofmaterialcategory = ls_bomlist-billofmaterialcategory
                                                                                                 billofmaterial = ls_bomlist-billofmaterial
                                                                                                 billofmaterialvariant = ls_bomlist-billofmaterialvariant
                                                                                        BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-bomheadertext = ls_billofmaterialheaderdex_2-bomheadertext.
        ENDIF.

        "Read data of product
        READ TABLE lt_product INTO DATA(ls_product) WITH KEY product = ls_bomlist-billofmaterialcomponent BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-productmanufacturernumber = ls_product-productmanufacturernumber.
          ls_data-businesspartnerfullname   = ls_product-businesspartnerfullname.
          ls_data-netweight                 = ls_product-netweight.

          TRY.
              ls_data-weightunit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                  iv_input = ls_product-weightunit ).
            CATCH zzcx_custom_exception INTO lo_exc.
              ls_data-weightunit = ls_product-weightunit.
          ENDTRY.
        ENDIF.

        "Read data of condition record
        READ TABLE lt_purgprcgcndnrecdvalidity TRANSPORTING NO FIELDS WITH KEY material = ls_bomlist-billofmaterialcomponent
                                                                               plant = ls_bomlist-plant
                                                                      BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-ispurconditionrecord = lc_ispurcondrec_yes.
        ELSE.
          ls_data-ispurconditionrecord = lc_ispurcondrec_no.
        ENDIF.

        "Read data of product group text
        READ TABLE lt_productgrouptext_2 INTO DATA(ls_productgrouptext_2) WITH KEY productgroup = ls_bomlist-materialgroup
                                                                          BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-productgroupname = ls_productgrouptext_2-productgroupname.
        ENDIF.

        "Read data of BOM item
        READ TABLE lt_billofmaterialitemdex_3 INTO DATA(ls_billofmaterialitemdex_3) WITH KEY billofmaterialcategory = ls_bomlist-billofmaterialcategory
                                                                                             billofmaterial = ls_bomlist-billofmaterial
                                                                                             billofmaterialvariant = ls_bomlist-billofmaterialvariant
                                                                                             billofmaterialitemnumber = ls_bomlist-billofmaterialitemnumber
                                                                                    BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-bomitemissparepart = ls_billofmaterialitemdex_3-bomitemissparepart.
          ls_data-changenumber       = ls_billofmaterialitemdex_3-engineeringchangedocument.
        ENDIF.

*        lv_objmgmtrecdobject+0(40) = ls_bomlist-headermaterial.
*        lv_objmgmtrecdobject+40(4) = ls_bomlist-plant.
*        lv_objmgmtrecdobject+44(1) = ls_bomlist-billofmaterialvariantusage.

        "Read data of change number object management record
        READ TABLE lt_chgmstrobjectmgmtrecordtp_2 INTO DATA(ls_chgmstrobjectmgmtrecordtp_2) WITH KEY sapobjecttechnicalid = ls_bomlist-headermaterial
                                                                                                     changenumber = ls_data-changenumber
                                                                                            BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-revisionlevel = ls_chgmstrobjectmgmtrecordtp_2-objmgmtrecdobjrevisionlevel.
        ENDIF.

        IF lv_localposition IS INITIAL.
          APPEND ls_data TO lt_data.
        ELSE.
          READ TABLE lt_billofmaterialsubitemsbasic TRANSPORTING NO FIELDS WITH KEY billofmaterialcategory = ls_bomlist-billofmaterialcategory
                                                                                    billofmaterial = ls_bomlist-billofmaterial
                                                                                    billofmaterialitemnodenumber = ls_bomlist-billofmaterialitemnodenumber
                                                                           BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT lt_billofmaterialsubitemsbasic INTO DATA(ls_billofmaterialsubitemsbasic) FROM sy-tabix.
              IF ls_billofmaterialsubitemsbasic-billofmaterialcategory <> ls_bomlist-billofmaterialcategory
              OR ls_billofmaterialsubitemsbasic-billofmaterial <> ls_bomlist-billofmaterial
              OR ls_billofmaterialsubitemsbasic-billofmaterialitemnodenumber <> ls_bomlist-billofmaterialitemnodenumber.
                EXIT.
              ENDIF.

              IF lv_localposition = lc_localposition_h.
                IF ls_data-bomsubiteminstallationpoint IS INITIAL.
                  ls_data-bomsubiteminstallationpoint = ls_billofmaterialsubitemsbasic-bomsubiteminstallationpoint.
                ELSE.
                  CONCATENATE ls_data-bomsubiteminstallationpoint
                              ls_billofmaterialsubitemsbasic-bomsubiteminstallationpoint
                         INTO ls_data-bomsubiteminstallationpoint
                    SEPARATED BY lc_separator.
                ENDIF.
              ENDIF.

              IF lv_localposition = lc_localposition_v.
                ls_data-bomsubitemnumbervalue         = ls_billofmaterialsubitemsbasic-bomsubitemnumbervalue.
                ls_data-bomsubiteminstallationpoint   = ls_billofmaterialsubitemsbasic-bomsubiteminstallationpoint.
                ls_data-billofmaterialsubitemquantity = ls_billofmaterialsubitemsbasic-billofmaterialsubitemquantity.
                APPEND ls_data TO lt_data.
              ENDIF.
            ENDLOOP.

            IF lv_localposition = lc_localposition_h.
              APPEND ls_data TO lt_data.
            ENDIF.
          ELSE.
            APPEND ls_data TO lt_data.
          ENDIF.
        ENDIF.

        CLEAR ls_data.
      ENDLOOP.

*      "Page
*      DATA(lv_start) = lv_skip + 1.
*      DATA(lv_end) = lv_skip + lv_top.
*
*      APPEND LINES OF lt_data FROM lv_start TO lv_end TO lt_output.
*      io_response->set_total_number_of_records( lines( lt_data ) ).
*      io_response->set_data( lt_output ).

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
