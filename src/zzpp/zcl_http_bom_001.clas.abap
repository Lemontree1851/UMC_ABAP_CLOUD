CLASS zcl_http_bom_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_http_bom_001 IMPLEMENTATION.
  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        plant                    TYPE string,
        material                 TYPE string,
        time_stamp               TYPE string,
        bill_of_material_variant TYPE string,
        validity_start_date      TYPE string,
        require_quantity         TYPE menge_d,
      END OF ty_req,

      "BOM sub items
      BEGIN OF ty_subitems,
        b_o_m_sub_item_number_value   TYPE i_billofmaterialsubitemsbasic-bomsubitemnumbervalue,
        bomsubiteminstallationpoint   TYPE i_billofmaterialsubitemsbasic-bomsubiteminstallationpoint,
        billofmaterialsubitemquantity TYPE i_billofmaterialsubitemsbasic-billofmaterialsubitemquantity,
        bill_of_material_item_unit    TYPE i_billofmaterialsubitemsbasic-billofmaterialitemunit,
      END OF ty_subitems,
      tt_subitems TYPE STANDARD TABLE OF ty_subitems WITH DEFAULT KEY,

      "BOM data
      BEGIN OF ty_bom,
        b_o_m_hdr_root_matl_hier_node TYPE i_materialbomlink-material,
        hdr_root_mat_description      TYPE string,
        plant                         TYPE i_materialbomlink-plant,
        explode_b_o_m_level_value     TYPE i,
        b_o_m_hdr_matl_hier_node      TYPE i_materialbomlink-material,
        hdr_mat_description           TYPE string,
        bill_of_material              TYPE i_billofmaterialheaderdex_2-billofmaterial,
        bill_of_material_variant      TYPE i_billofmaterialheaderdex_2-billofmaterialvariant,
        billofmaterialvariantusage    TYPE i_billofmaterialheaderdex_2-billofmaterialvariantusage,
        bill_of_material_version      TYPE i_billofmaterialheaderdex_2-billofmaterialversion,
        bomheaderquantityinbaseunit   TYPE i_billofmaterialheaderdex_2-bomheaderquantityinbaseunit,
        b_o_m_header_base_unit        TYPE i_billofmaterialheaderdex_2-bomheaderbaseunit,
        bill_of_material_status       TYPE i_billofmaterialheaderdex_2-billofmaterialstatus,
        header_validity_start_date    TYPE string,
        header_validity_end_date      TYPE string,
        headerengineeringchgnmbrdoc   TYPE i_billofmaterialheaderdex_2-headerengineeringchgnmbrdoc,
        record_creation_date          TYPE string,
        created_by_user               TYPE i_billofmaterialheaderdex_2-createdbyuser,
        last_change_date_time         TYPE i_billofmaterialwithkeydate-lastchangedatetime,
        bill_of_material_item_number  TYPE i_billofmaterialitemdex_3-billofmaterialitemnumber,
        billofmaterialitemcategory    TYPE i_billofmaterialitemdex_3-billofmaterialitemcategory,
        bill_of_material_component    TYPE i_billofmaterialitemdex_3-billofmaterialcomponent,
        component_description         TYPE string,
        billofmaterialitemquantity    TYPE i_billofmaterialitemdex_3-billofmaterialitemquantity,
        bill_of_material_item_unit    TYPE i_billofmaterialitemdex_3-billofmaterialitemunit,
        componentquantityincompuom    TYPE p LENGTH 13 DECIMALS 3,
        componentquantityinbaseuom    TYPE p LENGTH 13 DECIMALS 3,
        component_base_unit           TYPE i_product-baseunit,
        prod_order_issue_location     TYPE i_billofmaterialitemdex_3-prodorderissuelocation,
        alternative_item_group        TYPE i_billofmaterialitemdex_3-alternativeitemgroup,
        alternative_item_priority     TYPE i_billofmaterialitemdex_3-alternativeitempriority,
        alternative_item_strategy     TYPE i_billofmaterialitemdex_3-alternativeitemstrategy,
        usage_probability_percent     TYPE i_billofmaterialitemdex_3-usageprobabilitypercent,
        product_is_to_be_discontinued TYPE i_productsupplyplanning-productistobediscontinued,
        discontinuation_group         TYPE i_billofmaterialitemdex_3-discontinuationgroup,
        follow_up_group               TYPE i_billofmaterialitemdex_3-followupgroup,
        is_material_provision         TYPE i_billofmaterialitemdex_3-ismaterialprovision,
        b_o_m_item_is_spare_part      TYPE i_billofmaterialitemdex_3-bomitemissparepart,
        is_bulk_material              TYPE i_billofmaterialitemdex_3-isbulkmaterial,
        material_is_co_product        TYPE i_billofmaterialitemdex_3-materialiscoproduct,
        b_o_m_item_sorter             TYPE i_billofmaterialitemdex_3-bomitemsorter,
        b_o_m_item_description        TYPE i_billofmaterialitemdex_3-bomitemdescription,
        b_o_m_item_text2              TYPE i_billofmaterialitemdex_3-bomitemtext2,
        component_scrap_in_percent    TYPE i_billofmaterialitemdex_3-componentscrapinpercent,
        validity_start_date           TYPE string,
        validity_end_date             TYPE string,
        engineering_change_document   TYPE i_billofmaterialitemdex_3-engineeringchangedocument,
        is_deleted                    TYPE i_billofmaterialitemdex_3-isdeleted,
        item_last_change_date_time    TYPE i_billofmaterialitemdex_3-lastchangedatetime,
        sub_items                     TYPE tt_subitems,

        bill_of_material_category     TYPE i_billofmaterialsubitemsbasic-billofmaterialcategory,
        bill_of_material_root         TYPE i_billofmaterialheaderdex_2-billofmaterial,
        bill_of_material_root_variant TYPE i_billofmaterialheaderdex_2-billofmaterialvariant,
        bill_of_material_item_index   TYPE i,
        billofmaterialitemnodenumber  TYPE i_billofmaterialsubitemsbasic-billofmaterialitemnodenumber,
      END OF ty_bom,
      tt_bom TYPE STANDARD TABLE OF ty_bom WITH DEFAULT KEY,

      BEGIN OF ty_data,
        bom TYPE tt_bom,
      END OF ty_data,

      BEGIN OF ty_res,
        msgty TYPE string,
        msg   TYPE string,
        data  TYPE ty_data,
      END OF ty_res.

    DATA:
      lo_root_exc        TYPE REF TO cx_root,
      lr_bomvariant      TYPE RANGE OF i_materialbomlink-billofmaterialvariant,
      lt_bomlist         TYPE STANDARD TABLE OF zcl_explodebom=>ty_bomlist,
      lt_bom             TYPE tt_bom,
      ls_bomvariant      LIKE LINE OF lr_bomvariant,
      ls_req             TYPE ty_req,
      ls_res             TYPE ty_res,
      ls_bom             TYPE ty_bom,
      ls_bom_tmp         TYPE ty_bom,
      ls_subitems        TYPE ty_subitems,
      lv_plant           TYPE i_materialbomlink-plant,
      lv_material        TYPE i_materialbomlink-material,
      lv_timestamp       TYPE timestamp,
      lv_timestampl      TYPE timestampl,
      lv_bomvariant      TYPE i_materialbomlink-billofmaterialvariant,
      lv_validdate       TYPE datuv,
      lv_requirequantity TYPE menge_d,
      lv_date            TYPE d,
      lv_time            TYPE t.

    CONSTANTS:
      lc_zid_zpp005        TYPE ztbc_1001-zid  VALUE 'ZPP005',
      lcmsgid              TYPE string         VALUE 'ZPP_001',
      lcmsgty              TYPE string         VALUE 'E',
      lc_alpha_in          TYPE string         VALUE 'IN',
      lc_alpha_out         TYPE string         VALUE 'OUT',
      lc_explosiontype_3   TYPE ze_explodetype VALUE '3',
      lc_requirequantity_1 TYPE menge_d        VALUE 1,
      lc_bomvariant_01     TYPE c LENGTH 2     VALUE '01',
      lc_appl_pp01         TYPE c LENGTH 4     VALUE 'PP01',
      lc_sign_i            TYPE c LENGTH 1     VALUE 'I',
      lc_opt_le            TYPE c LENGTH 2     VALUE 'LE'.

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).

    lv_plant = ls_req-plant.
    lv_timestampl = ls_req-time_stamp.
    lv_material = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_req-material ).

    IF ls_req-bill_of_material_variant IS NOT INITIAL.
      lv_bomvariant = |{ ls_req-bill_of_material_variant ALPHA = IN }|.
    ELSE.
      lv_bomvariant = lc_bomvariant_01.
    ENDIF.

    IF ls_req-validity_start_date IS NOT INITIAL.
      lv_validdate = ls_req-validity_start_date.
    ELSE.
      lv_validdate = cl_abap_context_info=>get_system_date( ).
    ENDIF.
    IF ls_req-require_quantity IS NOT INITIAL.
      lv_requirequantity = ls_req-require_quantity.
    ELSE.
      lv_requirequantity = lc_requirequantity_1.
    ENDIF.

    TRY.
        "Check plant of input parameter must be valuable
        IF lv_plant IS INITIAL.
          "プラントを送信していください！
          MESSAGE ID lcmsgid TYPE lcmsgty NUMBER 001 INTO ls_res-msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check material or time stamp of input parameter must be valuable
        IF lv_material IS INITIAL AND lv_timestampl IS INITIAL.
          "品目或いは前回送信時間は送信していください！
          MESSAGE ID lcmsgid TYPE lcmsgty NUMBER 011 INTO ls_res-msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check material and time stamp of input parameter must be not valuable at the same time
        IF lv_material IS NOT INITIAL AND lv_timestampl IS NOT INITIAL.
          "品目と前回送信時間は一つしか送信できません！
          MESSAGE ID lcmsgid TYPE lcmsgty NUMBER 012 INTO ls_res-msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check plant of input parameter must be existent
        SELECT COUNT(*)
          FROM i_plant
         WHERE plant = @lv_plant.
        IF sy-subrc <> 0.
          "プラント&1存在しません！
          MESSAGE ID lcmsgid TYPE lcmsgty NUMBER 002 WITH lv_plant INTO ls_res-msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        IF lv_material IS NOT INITIAL.
          "Check material and plant of input parameter must be existent
          SELECT COUNT(*)
            FROM i_productplantbasic WITH PRIVILEGED ACCESS
           WHERE product = @lv_material
             AND plant = @lv_plant.
          IF sy-subrc <> 0.
            "プラント&1品目&2存在しません！
            MESSAGE ID lcmsgid TYPE lcmsgty NUMBER 013 WITH lv_plant lv_material INTO ls_res-msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ENDIF.
        ENDIF.

        "Obtain language and time zone of plant
        SELECT SINGLE
               zvalue2 AS language,
               zvalue3 AS zonlo_in,
               zvalue4 AS zonlo_out
          FROM ztbc_1001
         WHERE zid = @lc_zid_zpp005
           AND zvalue1 = @lv_plant
          INTO @DATA(ls_ztbc_1001).

        "Convert date and time from time zone of plant to zero zone
        CONVERT TIME STAMP lv_timestampl
                TIME ZONE ls_ztbc_1001-zonlo_in
                INTO DATE lv_date
                     TIME lv_time.

        lv_timestampl = lv_date && lv_time.

        ls_bomvariant-sign = lc_sign_i.
        ls_bomvariant-option = lc_opt_le.
        ls_bomvariant-low = lv_bomvariant.
        APPEND ls_bomvariant TO lr_bomvariant.

        IF lv_material IS NOT INITIAL.
          "Obtain data of bill of material
          SELECT a~billofmaterial,
                 MAX( a~billofmaterialvariant ) AS billofmaterialvariant,
                 a~material,
                 a~plant,
                 a~billofmaterialvariantusage,
                 a~billofmaterialcategory
            FROM i_materialbomlink WITH PRIVILEGED ACCESS AS a
           INNER JOIN i_billofmaterialwithkeydate WITH PRIVILEGED ACCESS AS b
              ON b~billofmaterialcategory = a~billofmaterialcategory
             AND b~billofmaterialvariantusage = a~billofmaterialvariantusage
             AND b~billofmaterial = a~billofmaterial
             AND b~billofmaterialvariant = a~billofmaterialvariant
           WHERE a~material = @lv_material
             AND a~plant = @lv_plant
             AND a~billofmaterialvariant IN @lr_bomvariant
             AND b~headervaliditystartdate <= @lv_validdate
             AND b~headervalidityenddate >= @lv_validdate
           GROUP BY a~billofmaterial,a~material,a~plant,a~billofmaterialvariantusage,a~billofmaterialcategory
            INTO TABLE @DATA(lt_materialbomlink).
        ELSE.
          "Obtain data of bill of material
          SELECT a~billofmaterial,
                 MAX( a~billofmaterialvariant ) AS billofmaterialvariant,
                 a~material,
                 a~plant,
                 a~billofmaterialvariantusage,
                 a~billofmaterialcategory
            FROM i_materialbomlink WITH PRIVILEGED ACCESS AS a
           INNER JOIN i_billofmaterialitemdex_3 WITH PRIVILEGED ACCESS AS b
              ON b~billofmaterialcategory = a~billofmaterialcategory
             AND b~billofmaterial = a~billofmaterial
             AND b~billofmaterialvariant = a~billofmaterialvariant
           INNER JOIN i_bomcomponentwithkeydate WITH PRIVILEGED ACCESS AS c
              ON c~billofmaterialcategory = a~billofmaterialcategory
             AND c~billofmaterial = a~billofmaterial
             AND c~billofmaterialvariant = a~billofmaterialvariant
           INNER JOIN i_billofmaterialwithkeydate WITH PRIVILEGED ACCESS AS d
              ON d~billofmaterialcategory = a~billofmaterialcategory
             AND d~billofmaterialvariantusage = a~billofmaterialvariantusage
             AND d~billofmaterial = a~billofmaterial
             AND d~billofmaterialvariant = a~billofmaterialvariant
           WHERE a~plant = @lv_plant
             AND a~billofmaterialvariant IN @lr_bomvariant
             AND d~headervaliditystartdate <= @lv_validdate
             AND d~headervalidityenddate >= @lv_validdate
             AND ( b~lastchangedatetime >= @lv_timestampl
                OR c~lastchangedatetime >= @lv_timestampl )
           GROUP BY a~billofmaterial,a~material,a~plant,a~billofmaterialvariantusage,a~billofmaterialcategory
            INTO TABLE @lt_materialbomlink.
        ENDIF.

        SORT lt_materialbomlink BY billofmaterial billofmaterialvariant material plant billofmaterialvariantusage.
        DELETE ADJACENT DUPLICATES FROM lt_materialbomlink
                              COMPARING billofmaterial
                                        billofmaterialvariant
                                        material
                                        plant
                                        billofmaterialvariantusage.

        LOOP AT lt_materialbomlink INTO DATA(ls_materialbomlink).
*          "Explode
*          READ ENTITIES OF i_billofmaterialtp_2 PRIVILEGED ENTITY billofmaterial
*               EXECUTE explodebom
*               FROM VALUE #(
*               ( billofmaterial = ls_materialbomlink-billofmaterial
*                 plant = ls_materialbomlink-plant
*                 material = ls_materialbomlink-material
*                 billofmaterialcategory = ls_materialbomlink-billofmaterialcategory
*                 billofmaterialvariant = ls_materialbomlink-billofmaterialvariant
*
*                 %param-bomexplosionapplication = lc_appl_pp01
*                 %param-requiredquantity = 1
*                 %param-explodebomlevelvalue = 0
*                 %param-bomexplosionismultilevel = 'X'
*                 %param-bomexplosionisalternateprio = 'X'
*               )
*               )
*               RESULT DATA(lt_result)
*               FAILED DATA(ls_failed)
*               REPORTED DATA(ls_reported) .
*
*          IF lt_result IS NOT INITIAL.
*            LOOP AT lt_result INTO DATA(ls_result).
*              ls_bom-b_o_m_hdr_root_matl_hier_node = ls_result-%param-material.
*              ls_bom-_plant                         = ls_result-%param-plant.
*              ls_bom-explode_b_o_m_level_value     = ls_result-%param-explodebomlevelvalue.
*              ls_bom-b_o_m_hdr_matl_hier_node      = ls_result-%param-bomhdrmatlhiernode.
*              ls_bom-_bill_of_material              = ls_result-%param-billofmaterial.
*              ls_bom-bill_of_material_variant      = ls_result-%param-billofmaterialvariant.
*              ls_bom-billofmaterialvariantusage     = ls_result-%param-billofmaterialvariantusage.
*              ls_bom-bill_of_material_version      = ls_result-%param-billofmaterialversion.
*              ls_bom-bill_of_material_item_number  = ls_result-%param-billofmaterialitemnumber.
*              ls_bom-billofmaterialitemcategory     = ls_result-%param-billofmaterialitemcategory.
*              ls_bom-bill_of_material_component    = ls_result-%param-billofmaterialcomponent.
*              ls_bom-billofmaterialitemquantity     = ls_result-%param-billofmaterialitemquantity.
*              ls_bom-componentquantityincompuom     = ls_result-%param-componentquantityincompuom.
*              ls_bom-componentquantityinbaseuom     = ls_result-%param-componentquantityinbaseuom.
*              ls_bom-prod_order_issue_location     = ls_result-%param-prodorderissuelocation.
*              ls_bom-alternative_item_group        = ls_result-%param-alternativeitemgroup.
*              ls_bom-alternative_item_priority     = ls_result-%param-alternativeitempriority.
*              ls_bom-alternative_item_strategy     = ls_result-%param-alternativeitemstrategy.
*              ls_bom-usage_probability_percent     = ls_result-%param-usageprobabilitypercent.
*              ls_bom-discontinuation_group         = ls_result-%param-discontinuationgroup.
*              ls_bom-follow_up_group               = ls_result-%param-followupgroup.
*              ls_bom-is_material_provision         = ls_result-%param-ismaterialprovision.
*              ls_bom-is_bulk_material              = ls_result-%param-isbulkmaterial.
*              ls_bom-material_is_co_product        = ls_result-%param-materialiscoproduct.
*              ls_bom-b_o_m_item_sorter             = ls_result-%param-bomitemsorter.
*              ls_bom-b_o_m_item_description        = ls_result-%param-bomitemdescription.
*              ls_bom-b_o_m_item_text2              = ls_result-%param-bomitemtext2.
*
*              TRY.
*                  ls_bom-_bill_of_material_item_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
*                                                                                                      iv_input = ls_result-%param-billofmaterialitemunit ).
*                CATCH zzcx_custom_exception INTO lo_root_exc.
*                  ls_bom-_bill_of_material_item_unit = ls_result-%param-billofmaterialitemunit.
*              ENDTRY.
*
*              ls_bom-bill_of_material_category     = ls_result-%param-billofmaterialcategory.
*              ls_bom-bill_of_material_root         = ls_result-%param-billofmaterialroot.
*              ls_bom-bill_of_material_root_variant = ls_result-%param-billofmaterialvariant.
*              ls_bom-bill_of_material_item_index   = ls_result-%param-billofmaterialitemindex.
*              ls_bom-billofmaterialitemnodenumber   = ls_result-%param-billofmaterialitemnodenumber.
*              APPEND ls_bom TO lt_bom.
*              CLEAR ls_bom.
*            ENDLOOP.
*          ENDIF.
*
*          CLEAR lt_result.

          "Explode BOM
          zcl_explodebom=>get_data(
            EXPORTING
              iv_explosiontype               = lc_explosiontype_3
              iv_plant                       = ls_materialbomlink-plant
              iv_material                    = ls_materialbomlink-material
              iv_billofmaterialcategory      = ls_materialbomlink-billofmaterialcategory
              iv_billofmaterialvariant       = lv_bomvariant
              iv_bomexplosionapplication     = lc_appl_pp01
              iv_bomexplosiondate            = lv_validdate
              iv_headermaterial              = ls_materialbomlink-material
              iv_headerbillofmaterialvariant = ls_materialbomlink-billofmaterialvariant
              iv_requiredquantity            = lv_requirequantity
              iv_quantityinheritance         = abap_true
            CHANGING
              ct_bomlist                     = lt_bomlist ).

          LOOP AT lt_bomlist INTO DATA(ls_bomlist).
            ls_bom-b_o_m_hdr_root_matl_hier_node = ls_bomlist-material.
            ls_bom-plant                         = ls_bomlist-plant.
            ls_bom-explode_b_o_m_level_value     = ls_bomlist-explodebomlevelvalue.
            ls_bom-b_o_m_hdr_matl_hier_node      = ls_bomlist-bomhdrmatlhiernode.
            ls_bom-bill_of_material              = ls_bomlist-billofmaterial.
            ls_bom-bill_of_material_variant      = ls_bomlist-billofmaterialvariant.
            ls_bom-billofmaterialvariantusage    = ls_bomlist-billofmaterialvariantusage.
            ls_bom-bill_of_material_version      = ls_bomlist-billofmaterialversion.
            ls_bom-bill_of_material_item_number  = ls_bomlist-billofmaterialitemnumber.
            ls_bom-billofmaterialitemcategory    = ls_bomlist-billofmaterialitemcategory.
            ls_bom-bill_of_material_component    = ls_bomlist-billofmaterialcomponent.
            ls_bom-billofmaterialitemquantity    = ls_bomlist-billofmaterialitemquantity.
            ls_bom-componentquantityincompuom    = ls_bomlist-componentquantityincompuom.
            ls_bom-componentquantityinbaseuom    = ls_bomlist-componentquantityinbaseuom.
            ls_bom-prod_order_issue_location     = ls_bomlist-prodorderissuelocation.
            ls_bom-alternative_item_group        = ls_bomlist-alternativeitemgroup.
            ls_bom-alternative_item_priority     = ls_bomlist-alternativeitempriority.
            ls_bom-alternative_item_strategy     = ls_bomlist-alternativeitemstrategy.
            ls_bom-usage_probability_percent     = ls_bomlist-usageprobabilitypercent.
            ls_bom-discontinuation_group         = ls_bomlist-discontinuationgroup.
            ls_bom-follow_up_group               = ls_bomlist-followupgroup.
            ls_bom-is_material_provision         = ls_bomlist-ismaterialprovision.
            ls_bom-is_bulk_material              = ls_bomlist-isbulkmaterial.
            ls_bom-material_is_co_product        = ls_bomlist-materialiscoproduct.
            ls_bom-b_o_m_item_sorter             = ls_bomlist-bomitemsorter.
            ls_bom-b_o_m_item_description        = ls_bomlist-bomitemdescription.
            ls_bom-b_o_m_item_text2              = ls_bomlist-bomitemtext2.

            TRY.
                ls_bom-bill_of_material_item_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                                    iv_input = ls_bomlist-billofmaterialitemunit ).
              CATCH zzcx_custom_exception INTO lo_root_exc.
                ls_bom-bill_of_material_item_unit = ls_bomlist-billofmaterialitemunit.
            ENDTRY.

            ls_bom-bill_of_material_category     = ls_bomlist-billofmaterialcategory.
            ls_bom-bill_of_material_root         = ls_bomlist-billofmaterialroot.
            ls_bom-bill_of_material_root_variant = ls_bomlist-billofmaterialvariant.
            ls_bom-bill_of_material_item_index   = ls_bomlist-billofmaterialitemindex.
            ls_bom-billofmaterialitemnodenumber  = ls_bomlist-billofmaterialitemnodenumber.
            APPEND ls_bom TO lt_bom.
            CLEAR ls_bom.
          ENDLOOP.

          CLEAR lt_bomlist.
        ENDLOOP.

        IF lt_bom IS NOT INITIAL.
          "Obtain data of BOM header
          SELECT billofmaterialcategory,
                 billofmaterial,
                 billofmaterialvariant,
                 billofmaterialstatus,
                 headervaliditystartdate,
                 headervalidityenddate,
                 engineeringchangedocument,
                 recordcreationdate,
                 createdbyuser,
                 lastchangedatetime,
                 bomheaderquantityinbaseunit,
                 bomheaderbaseunit
            FROM i_billofmaterialwithkeydate WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_bom
           WHERE billofmaterialcategory = @lt_bom-bill_of_material_category
             AND billofmaterial = @lt_bom-bill_of_material
             AND billofmaterialvariant = @lt_bom-bill_of_material_variant
            INTO TABLE @DATA(lt_billofmaterialwithkeydate).

          "Obtain data of BOM items
          SELECT billofmaterialcategory,
                 billofmaterial,
                 billofmaterialitemnodenumber,
                 bomitemissparepart,
                 componentscrapinpercent,
                 validitystartdate,
                 validityenddate,
                 engineeringchangedocument,
                 isdeleted,
                 lastchangedatetime
            FROM i_billofmaterialitemdex_3 WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_bom
           WHERE billofmaterialcategory = @lt_bom-bill_of_material_category
             AND billofmaterial = @lt_bom-bill_of_material
             AND billofmaterialitemnodenumber = @lt_bom-billofmaterialitemnodenumber
            INTO TABLE @DATA(lt_billofmaterialitemdex_3).

          "Obtain data of BOM sub items
          SELECT billofmaterialcategory,
                 billofmaterial,
                 billofmaterialitemnodenumber,
                 bomsubitemnumbervalue,
                 bomsubiteminstallationpoint,
                 billofmaterialsubitemquantity,
                 billofmaterialitemunit
            FROM i_billofmaterialsubitemsbasic WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_bom
           WHERE billofmaterialcategory = @lt_bom-bill_of_material_category
             AND billofmaterial = @lt_bom-bill_of_material
             AND billofmaterialitemnodenumber = @lt_bom-billofmaterialitemnodenumber
            INTO TABLE @DATA(lt_billofmaterialsubitemsbasic).

          DATA(lt_bom_tmp) = lt_bom.
          SORT lt_bom_tmp BY b_o_m_hdr_root_matl_hier_node.
          DELETE ADJACENT DUPLICATES FROM lt_bom_tmp
                                COMPARING b_o_m_hdr_root_matl_hier_node.

          IF lt_bom_tmp IS NOT INITIAL.
            "Obtain data of BOM root material description
            SELECT product,
                   productdescription
              FROM i_productdescription WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_bom_tmp
             WHERE product = @lt_bom_tmp-b_o_m_hdr_root_matl_hier_node
               AND language = @sy-langu"ls_ztbc_1001-language
              INTO TABLE @DATA(lt_productdescription).
          ENDIF.

          lt_bom_tmp = lt_bom.
          SORT lt_bom_tmp BY b_o_m_hdr_matl_hier_node.
          DELETE ADJACENT DUPLICATES FROM lt_bom_tmp
                                COMPARING b_o_m_hdr_matl_hier_node.

          IF lt_bom_tmp IS NOT INITIAL.
            "Obtain data of BOM material description
            SELECT product,
                   productdescription
              FROM i_productdescription WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_bom_tmp
             WHERE product = @lt_bom_tmp-b_o_m_hdr_matl_hier_node
               AND language = @sy-langu"ls_ztbc_1001-language
               APPENDING TABLE @lt_productdescription.
          ENDIF.

          lt_bom_tmp = lt_bom.
          SORT lt_bom_tmp BY bill_of_material_component.
          DELETE ADJACENT DUPLICATES FROM lt_bom_tmp
                                COMPARING bill_of_material_component.

          IF lt_bom_tmp IS NOT INITIAL.
            "Obtain data of BOM component description
            SELECT product,
                   productdescription
              FROM i_productdescription WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_bom_tmp
             WHERE product = @lt_bom_tmp-bill_of_material_component
               AND language = @sy-langu"ls_ztbc_1001-language
               APPENDING TABLE @lt_productdescription.

            "Obtain data of units of measure of BOM component
            SELECT product,
*                   alternativeunit,
                   baseunit
              FROM i_productunitsofmeasure WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_bom_tmp
             WHERE product = @lt_bom_tmp-bill_of_material_component
              INTO TABLE @DATA(lt_productunitsofmeasure).

            "Obtain data of discontinued indicator of BOM component
            SELECT product,
                   plant,
                   productistobediscontinued
              FROM i_productsupplyplanning WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_bom_tmp
             WHERE product = @lt_bom_tmp-bill_of_material_component
               AND plant = @lt_bom_tmp-plant
              INTO TABLE @DATA(lt_productsupplyplanning).
          ENDIF.
        ENDIF.

        DATA(lv_lines) = lines( lt_bom ).
        ls_res-msgty = 'S'.

        "BOMマスタ连携成功 &1 件！
        MESSAGE ID lcmsgid TYPE lcmsgty NUMBER 014 WITH lv_lines INTO ls_res-msg.
      CATCH cx_root INTO lo_root_exc.
        ls_res-msgty = 'E'.
    ENDTRY.

    SORT lt_bom BY bill_of_material_category bill_of_material_root bill_of_material_root_variant bill_of_material_item_index.
    SORT lt_billofmaterialwithkeydate BY billofmaterialcategory billofmaterial billofmaterialvariant.
    SORT lt_billofmaterialitemdex_3 BY billofmaterialcategory billofmaterial billofmaterialitemnodenumber.
    SORT lt_billofmaterialsubitemsbasic BY billofmaterialcategory billofmaterial billofmaterialitemnodenumber.
    SORT lt_productdescription BY product.
    SORT lt_productunitsofmeasure BY product.
    SORT lt_productsupplyplanning BY product plant.

    "Read data of BOM
    LOOP AT lt_bom INTO ls_bom.
      "Read data of BOM header
      READ TABLE lt_billofmaterialwithkeydate INTO DATA(ls_billofmaterialwithkeydate) WITH KEY billofmaterialcategory = ls_bom-bill_of_material_category
                                                                                               billofmaterial = ls_bom-bill_of_material_root
                                                                                               billofmaterialvariant = ls_bom-bill_of_material_root_variant
                                                                                      BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-bill_of_material_status     = ls_billofmaterialwithkeydate-billofmaterialstatus.
        ls_bom_tmp-header_validity_start_date  = ls_billofmaterialwithkeydate-headervaliditystartdate.
        ls_bom_tmp-header_validity_end_date    = ls_billofmaterialwithkeydate-headervalidityenddate.
        ls_bom_tmp-headerengineeringchgnmbrdoc = ls_billofmaterialwithkeydate-engineeringchangedocument.
        ls_bom_tmp-record_creation_date        = ls_billofmaterialwithkeydate-recordcreationdate.
        ls_bom_tmp-created_by_user             = ls_billofmaterialwithkeydate-createdbyuser.
        ls_bom_tmp-bomheaderquantityinbaseunit = ls_billofmaterialwithkeydate-bomheaderquantityinbaseunit.

        TRY.
            ls_bom_tmp-b_o_m_header_base_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                               iv_input = ls_billofmaterialwithkeydate-bomheaderbaseunit ).
          CATCH zzcx_custom_exception INTO lo_root_exc.
            ls_bom_tmp-b_o_m_header_base_unit = ls_billofmaterialwithkeydate-bomheaderbaseunit.
        ENDTRY.

        lv_timestamp = trunc( ls_billofmaterialwithkeydate-lastchangedatetime ).

        "Convert date and time from zero zone to time zone of plant
        CONVERT TIME STAMP lv_timestamp
                TIME ZONE ls_ztbc_1001-zonlo_out
                INTO DATE lv_date
                     TIME lv_time.

        lv_timestamp = lv_date && lv_time.
        ls_bom_tmp-last_change_date_time = lv_timestamp + frac( ls_billofmaterialwithkeydate-lastchangedatetime ).
      ENDIF.

      "Read data of BOM items
      READ TABLE lt_billofmaterialitemdex_3 INTO DATA(ls_billofmaterialitemdex_3) WITH KEY billofmaterialcategory = ls_bom-bill_of_material_category
                                                                                           billofmaterial = ls_bom-bill_of_material_root
                                                                                           billofmaterialitemnodenumber = ls_bom-billofmaterialitemnodenumber
                                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-b_o_m_item_is_spare_part    = ls_billofmaterialitemdex_3-bomitemissparepart.
        ls_bom_tmp-component_scrap_in_percent  = ls_billofmaterialitemdex_3-componentscrapinpercent.
        ls_bom_tmp-validity_start_date         = ls_billofmaterialitemdex_3-validitystartdate.
        ls_bom_tmp-validity_end_date           = ls_billofmaterialitemdex_3-validityenddate.
        ls_bom_tmp-engineering_change_document = ls_billofmaterialitemdex_3-engineeringchangedocument.
        ls_bom_tmp-is_deleted                  = ls_billofmaterialitemdex_3-isdeleted.

        lv_timestamp = trunc( ls_billofmaterialitemdex_3-lastchangedatetime ).

        "Convert date and time from zero zone to time zone of plant
        CONVERT TIME STAMP lv_timestamp
                TIME ZONE ls_ztbc_1001-zonlo_out
                INTO DATE lv_date
                     TIME lv_time.

        lv_timestamp = lv_date && lv_time.
        ls_bom_tmp-item_last_change_date_time = lv_timestamp + frac( ls_billofmaterialitemdex_3-lastchangedatetime ).
      ENDIF.

      "Read data of BOM sub items
      READ TABLE lt_billofmaterialsubitemsbasic TRANSPORTING NO FIELDS WITH KEY billofmaterialcategory = ls_bom-bill_of_material_category
                                                                                billofmaterial = ls_bom-bill_of_material_root
                                                                                billofmaterialitemnodenumber = ls_bom-billofmaterialitemnodenumber
                                                                       BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_billofmaterialsubitemsbasic INTO DATA(ls_billofmaterialsubitemsbasic) FROM sy-tabix.
          IF ls_billofmaterialsubitemsbasic-billofmaterialcategory <> ls_bom-bill_of_material_category
          OR ls_billofmaterialsubitemsbasic-billofmaterial <> ls_bom-bill_of_material_root
          OR ls_billofmaterialsubitemsbasic-billofmaterialitemnodenumber <> ls_bom-billofmaterialitemnodenumber.
            EXIT.
          ENDIF.

          ls_subitems-b_o_m_sub_item_number_value   = ls_billofmaterialsubitemsbasic-bomsubitemnumbervalue.
          ls_subitems-bomsubiteminstallationpoint   = ls_billofmaterialsubitemsbasic-bomsubiteminstallationpoint.
          ls_subitems-billofmaterialsubitemquantity = ls_billofmaterialsubitemsbasic-billofmaterialsubitemquantity.

          TRY.
              ls_subitems-bill_of_material_item_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                                      iv_input = ls_billofmaterialsubitemsbasic-billofmaterialitemunit ).
            CATCH zzcx_custom_exception INTO lo_root_exc.
              ls_subitems-bill_of_material_item_unit = ls_billofmaterialsubitemsbasic-billofmaterialitemunit.
          ENDTRY.

          APPEND ls_subitems TO ls_bom_tmp-sub_items.
          CLEAR ls_subitems.
        ENDLOOP.
      ENDIF.

      "Read data of BOM root material description
      READ TABLE lt_productdescription INTO DATA(ls_productdescription) WITH KEY product = ls_bom-b_o_m_hdr_root_matl_hier_node
                                                                        BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-hdr_root_mat_description = ls_productdescription-productdescription.
      ENDIF.

      "Read data of BOM material description
      READ TABLE lt_productdescription INTO ls_productdescription WITH KEY product = ls_bom-b_o_m_hdr_matl_hier_node
                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-hdr_mat_description = ls_productdescription-productdescription.
      ENDIF.

      "Read data of BOM component description
      READ TABLE lt_productdescription INTO ls_productdescription WITH KEY product = ls_bom-bill_of_material_component
                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-component_description = ls_productdescription-productdescription.
      ENDIF.

      "Read data of base unit of BOM component
      READ TABLE lt_productunitsofmeasure INTO DATA(ls_productunitsofmeasure) WITH KEY product = ls_bom-bill_of_material_component
                                                                              BINARY SEARCH.
      IF sy-subrc = 0.
        TRY.
            ls_bom_tmp-component_base_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                            iv_input = ls_productunitsofmeasure-baseunit ).
          CATCH zzcx_custom_exception INTO lo_root_exc.
            ls_bom_tmp-component_base_unit = ls_productunitsofmeasure-baseunit.
        ENDTRY.
      ENDIF.

      "Read data of discontinued indicator of BOM component
      READ TABLE lt_productsupplyplanning INTO DATA(ls_productsupplyplanning) WITH KEY product = ls_bom-bill_of_material_component
                                                                                       plant = ls_bom-plant
                                                                              BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-product_is_to_be_discontinued = ls_productsupplyplanning-productistobediscontinued.
      ENDIF.

      APPEND ls_bom_tmp TO ls_res-data-bom.
      CLEAR ls_bom_tmp.
    ENDLOOP.

    DATA(lv_res_body) = xco_cp_json=>data->from_abap( ls_res )->apply( VALUE #(
                          ( xco_cp_json=>transformation->underscore_to_pascal_case ) ) )->to_string( ).

*    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 "compress = 'X'
*                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF 'Bomsubiteminstallationpoint' IN lv_res_body WITH 'BOMSubItemInstallationPoint'.
    REPLACE ALL OCCURRENCES OF 'Billofmaterialsubitemquantity' IN lv_res_body WITH 'BillOfMaterialSubItemQuantity'.
    REPLACE ALL OCCURRENCES OF 'Billofmaterialvariantusage' IN lv_res_body WITH 'BillOfMaterialVariantUsage'.
    REPLACE ALL OCCURRENCES OF 'Bomheaderquantityinbaseunit' IN lv_res_body WITH 'BOMHeaderQuantityInBaseUnit'.
    REPLACE ALL OCCURRENCES OF 'Headerengineeringchgnmbrdoc' IN lv_res_body WITH 'HeaderEngineeringChgNmbrDoc'.
    REPLACE ALL OCCURRENCES OF 'Billofmaterialitemcategory' IN lv_res_body WITH 'BillOfMaterialItemCategory'.
    REPLACE ALL OCCURRENCES OF 'Billofmaterialitemquantity' IN lv_res_body WITH 'BillOfMaterialItemQuantity'.
    REPLACE ALL OCCURRENCES OF 'Componentquantityincompuom' IN lv_res_body WITH 'ComponentQuantityInCompUom'.
    REPLACE ALL OCCURRENCES OF 'Componentquantityinbaseuom' IN lv_res_body WITH 'ComponentQuantityInBaseUom'.
    REPLACE ALL OCCURRENCES OF 'Billofmaterialitemnodenumber' IN lv_res_body WITH 'BillOfMaterialItemNodeNumber'.

    "Set request data
    response->set_text( lv_res_body ).
  ENDMETHOD.
ENDCLASS.
