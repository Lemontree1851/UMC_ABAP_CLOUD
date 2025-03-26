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
        time_stamp_to            TYPE string,
        bill_of_material_variant TYPE string,
        validity_start_date      TYPE string,
        require_quantity         TYPE menge_d,
      END OF ty_req,

      "BOM sub items
      BEGIN OF ty_subitems,
        _b_o_m_sub_item_number_value  TYPE i_billofmaterialsubitemsbasic-bomsubitemnumbervalue,
        bomsubiteminstallationpoint   TYPE i_billofmaterialsubitemsbasic-bomsubiteminstallationpoint,
        billofmaterialsubitemquantity TYPE i_billofmaterialsubitemsbasic-billofmaterialsubitemquantity,
        _bill_of_material_item_unit   TYPE i_billofmaterialsubitemsbasic-billofmaterialitemunit,
      END OF ty_subitems,
      tt_subitems TYPE STANDARD TABLE OF ty_subitems WITH DEFAULT KEY,

      "BOM data
      BEGIN OF ty_bom,
        _b_o_m_hdr_root_matl_hier_node TYPE i_materialbomlink-material,
        _hdr_root_mat_description      TYPE string,
        _plant                         TYPE i_materialbomlink-plant,
        _explode_b_o_m_level_value     TYPE i,
        _b_o_m_hdr_matl_hier_node      TYPE i_materialbomlink-material,
        _hdr_mat_description           TYPE string,
        _bill_of_material              TYPE i_billofmaterialheaderdex_2-billofmaterial,
        _bill_of_material_variant      TYPE i_billofmaterialheaderdex_2-billofmaterialvariant,
        billofmaterialvariantusage     TYPE i_billofmaterialheaderdex_2-billofmaterialvariantusage,
        _bill_of_material_version      TYPE i_billofmaterialheaderdex_2-billofmaterialversion,
        bomheaderquantityinbaseunit    TYPE i_billofmaterialheaderdex_2-bomheaderquantityinbaseunit,
        _b_o_m_header_base_unit        TYPE i_billofmaterialheaderdex_2-bomheaderbaseunit,
        _bill_of_material_status       TYPE i_billofmaterialheaderdex_2-billofmaterialstatus,
        _header_validity_start_date    TYPE string,
        _header_validity_end_date      TYPE string,
        headerengineeringchgnmbrdoc    TYPE i_billofmaterialheaderdex_2-headerengineeringchgnmbrdoc,
        _record_creation_date          TYPE string,
        _created_by_user               TYPE i_billofmaterialheaderdex_2-createdbyuser,
        _last_change_date_time         TYPE i_billofmaterialwithkeydate-lastchangedatetime,
        _bill_of_material_item_number  TYPE i_billofmaterialitemdex_3-billofmaterialitemnumber,
        billofmaterialitemcategory     TYPE i_billofmaterialitemdex_3-billofmaterialitemcategory,
        _bill_of_material_component    TYPE i_billofmaterialitemdex_3-billofmaterialcomponent,
        _component_description         TYPE string,
        billofmaterialitemquantity     TYPE i_billofmaterialitemdex_3-billofmaterialitemquantity,
        _bill_of_material_item_unit    TYPE i_billofmaterialitemdex_3-billofmaterialitemunit,
        componentquantityincompuom     TYPE p LENGTH 13 DECIMALS 3,
        componentquantityinbaseuom     TYPE p LENGTH 13 DECIMALS 3,
        _component_base_unit           TYPE i_product-baseunit,
        _prod_order_issue_location     TYPE i_billofmaterialitemdex_3-prodorderissuelocation,
        _alternative_item_group        TYPE i_billofmaterialitemdex_3-alternativeitemgroup,
        _alternative_item_priority     TYPE i_billofmaterialitemdex_3-alternativeitempriority,
        _alternative_item_strategy     TYPE i_billofmaterialitemdex_3-alternativeitemstrategy,
        _usage_probability_percent     TYPE i_billofmaterialitemdex_3-usageprobabilitypercent,
        _product_is_to_be_discontinued TYPE i_productsupplyplanning-productistobediscontinued,
        _discontinuation_group         TYPE i_billofmaterialitemdex_3-discontinuationgroup,
        _follow_up_group               TYPE i_billofmaterialitemdex_3-followupgroup,
        _is_material_provision         TYPE i_billofmaterialitemdex_3-ismaterialprovision,
        _b_o_m_item_is_spare_part      TYPE i_billofmaterialitemdex_3-bomitemissparepart,
        _is_bulk_material              TYPE i_billofmaterialitemdex_3-isbulkmaterial,
        _material_is_co_product        TYPE i_billofmaterialitemdex_3-materialiscoproduct,
        _b_o_m_item_sorter             TYPE i_billofmaterialitemdex_3-bomitemsorter,
        _b_o_m_item_description        TYPE i_billofmaterialitemdex_3-bomitemdescription,
        _b_o_m_item_text2              TYPE i_billofmaterialitemdex_3-bomitemtext2,
        _component_scrap_in_percent    TYPE i_billofmaterialitemdex_3-componentscrapinpercent,
        _validity_start_date           TYPE string,
        _validity_end_date             TYPE string,
        _engineering_change_document   TYPE i_billofmaterialitemdex_3-engineeringchangedocument,
        _is_deleted                    TYPE i_billofmaterialitemdex_3-isdeleted,
        _item_last_change_date_time    TYPE i_billofmaterialitemdex_3-lastchangedatetime,
        _sub_items                     TYPE tt_subitems,

        _bill_of_material_category     TYPE i_billofmaterialsubitemsbasic-billofmaterialcategory,
        _bill_of_material_root         TYPE i_billofmaterialheaderdex_2-billofmaterial,
        _bill_of_material_root_variant TYPE i_billofmaterialheaderdex_2-billofmaterialvariant,
        _bill_of_material_item_index   TYPE i,
        billofmaterialitemnodenumber   TYPE i_billofmaterialsubitemsbasic-billofmaterialitemnodenumber,
      END OF ty_bom,
      tt_bom TYPE STANDARD TABLE OF ty_bom WITH DEFAULT KEY,

      BEGIN OF ty_data,
        _bom TYPE tt_bom,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res.

    DATA:
      lo_root_exc        TYPE REF TO cx_root,
      lr_bomvariant      TYPE RANGE OF i_materialbomlink-billofmaterialvariant,
      lr_producttype     TYPE RANGE OF i_product-producttype,
      lr_timestampl      TYPE RANGE OF timestampl,
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
      lv_timestampl_to   TYPE timestampl,
      lv_bomvariant      TYPE i_materialbomlink-billofmaterialvariant,
      lv_validdate       TYPE datuv,
      lv_requirequantity TYPE menge_d,
      lv_date            TYPE d,
      lv_time            TYPE t.

    CONSTANTS:
      lc_zid_zpp005        TYPE ztbc_1001-zid  VALUE 'ZPP005',
      lc_msgid             TYPE string         VALUE 'ZPP_001',
      lc_msgty             TYPE string         VALUE 'E',
      lc_alpha_in          TYPE string         VALUE 'IN',
      lc_alpha_out         TYPE string         VALUE 'OUT',
      lc_explosiontype_3   TYPE ze_explodetype VALUE '3',
      lc_requirequantity_1 TYPE menge_d        VALUE 1,
      lc_bomvariant_01     TYPE c LENGTH 2     VALUE '01',
      lc_appl_pp01         TYPE c LENGTH 4     VALUE 'PP01',
      lc_sign_i            TYPE c LENGTH 1     VALUE 'I',
      lc_opt_le            TYPE c LENGTH 2     VALUE 'LE',
      lc_opt_ge            TYPE c LENGTH 2     VALUE 'GE',
      lc_opt_bt            TYPE c LENGTH 2     VALUE 'BT'.

    GET TIME STAMP FIELD DATA(lv_timestamp_start).

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    IF lv_req_body IS NOT INITIAL.
      xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).
    ENDIF.

    lv_plant = ls_req-plant.
    lv_timestampl = ls_req-time_stamp.
    lv_timestampl_to = ls_req-time_stamp_to.
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
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 001 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check material or time stamp of input parameter must be valuable
        IF lv_material IS INITIAL AND lv_timestampl IS INITIAL.
          "品目或いは前回送信時間は送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 011 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check material and time stamp of input parameter must be not valuable at the same time
        IF lv_material IS NOT INITIAL AND lv_timestampl IS NOT INITIAL.
          "品目と前回送信時間は一つしか送信できません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 012 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check plant of input parameter must be existent
        SELECT COUNT(*)
          FROM i_plant
         WHERE plant = @lv_plant.
        IF sy-subrc <> 0.
          "プラント&1存在しません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 002 WITH lv_plant INTO ls_res-_msg.
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
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 013 WITH lv_plant lv_material INTO ls_res-_msg.
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

        "Convert date and time from time zone of plant to zero zone
        CONVERT TIME STAMP lv_timestampl_to
                TIME ZONE ls_ztbc_1001-zonlo_in
                INTO DATE lv_date
                     TIME lv_time.

        lv_timestampl_to = lv_date && lv_time.

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
*          lr_producttype = VALUE #( sign = lc_sign_i option = 'EQ' ( low = 'ZFRT' ) ).

          IF lv_timestampl_to IS INITIAL.
            lr_timestampl = VALUE #( sign = lc_sign_i option = 'GE' ( low = lv_timestampl ) ).
          ELSE.
            lr_timestampl = VALUE #( sign = lc_sign_i option = 'BT' ( low = lv_timestampl high = lv_timestampl_to ) ).
          ENDIF.

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
           INNER JOIN i_product WITH PRIVILEGED ACCESS AS e
              ON e~product = a~material
           WHERE a~plant = @lv_plant
             AND a~billofmaterialvariant IN @lr_bomvariant
             AND d~headervaliditystartdate <= @lv_validdate
             AND d~headervalidityenddate >= @lv_validdate
*             AND ( b~lastchangedatetime >= @lv_timestampl
*                OR c~lastchangedatetime >= @lv_timestampl )
             AND ( b~lastchangedatetime IN @lr_timestampl
                OR c~lastchangedatetime IN @lr_timestampl )
             AND e~producttype IN @lr_producttype
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

        IF lt_materialbomlink IS NOT INITIAL.
          "Obtain data of BOM header
          SELECT billofmaterialcategory,
                 billofmaterial,
                 billofmaterialvariant,
                 billofmaterialvariantusage
            FROM i_billofmaterialheaderdex_2 WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_materialbomlink
           WHERE billofmaterialcategory = @lt_materialbomlink-billofmaterialcategory
             AND billofmaterial = @lt_materialbomlink-billofmaterial
             AND billofmaterialvariant = @lt_materialbomlink-billofmaterialvariant
             AND billofmaterialvariantusage = @lt_materialbomlink-billofmaterialvariantusage
             AND bomisarchivedfordeletion = @abap_true
            INTO TABLE @DATA(lt_billofmaterialheaderdex_2).
        ENDIF.

        SORT lt_billofmaterialheaderdex_2 BY billofmaterialcategory billofmaterial billofmaterialvariant billofmaterialvariantusage.

        LOOP AT lt_materialbomlink INTO DATA(ls_materialbomlink).
          "Read data of BOM header
          READ TABLE lt_billofmaterialheaderdex_2 TRANSPORTING NO FIELDS WITH KEY billofmaterialcategory = ls_materialbomlink-billofmaterialcategory
                                                                                  billofmaterial = ls_materialbomlink-billofmaterial
                                                                                  billofmaterialvariant = ls_materialbomlink-billofmaterialvariant
                                                                                  billofmaterialvariantusage = ls_materialbomlink-billofmaterialvariantusage
                                                                         BINARY SEARCH.
          IF sy-subrc = 0.
            ls_bom-_b_o_m_hdr_root_matl_hier_node = ls_materialbomlink-material.
            ls_bom-_plant                         = ls_materialbomlink-plant.
            ls_bom-_bill_of_material              = ls_materialbomlink-billofmaterial.
            ls_bom-_bill_of_material_variant      = ls_materialbomlink-billofmaterialvariant.
            ls_bom-_is_deleted                    = abap_true.
            APPEND ls_bom TO ls_res-_data-_bom.
            CLEAR ls_bom.

            CONTINUE.
          ENDIF.

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
            ls_bom-_b_o_m_hdr_root_matl_hier_node = ls_bomlist-material.
            ls_bom-_plant                         = ls_bomlist-plant.
            ls_bom-_explode_b_o_m_level_value     = ls_bomlist-explodebomlevelvalue.
            ls_bom-_b_o_m_hdr_matl_hier_node      = ls_bomlist-bomhdrmatlhiernode.
            ls_bom-_bill_of_material              = ls_bomlist-billofmaterial.
            ls_bom-_bill_of_material_variant      = ls_bomlist-billofmaterialvariant.
            ls_bom-billofmaterialvariantusage     = ls_bomlist-billofmaterialvariantusage.
            ls_bom-_bill_of_material_version      = ls_bomlist-billofmaterialversion.
            ls_bom-_bill_of_material_item_number  = ls_bomlist-billofmaterialitemnumber.
            ls_bom-billofmaterialitemcategory     = ls_bomlist-billofmaterialitemcategory.
            ls_bom-_bill_of_material_component    = ls_bomlist-billofmaterialcomponent.
            ls_bom-billofmaterialitemquantity     = ls_bomlist-billofmaterialitemquantity.
            ls_bom-componentquantityincompuom     = ls_bomlist-componentquantityincompuom.
            ls_bom-componentquantityinbaseuom     = ls_bomlist-componentquantityinbaseuom.
            ls_bom-_prod_order_issue_location     = ls_bomlist-prodorderissuelocation.
            ls_bom-_alternative_item_group        = ls_bomlist-alternativeitemgroup.
            ls_bom-_alternative_item_priority     = ls_bomlist-alternativeitempriority.
            ls_bom-_alternative_item_strategy     = ls_bomlist-alternativeitemstrategy.
            ls_bom-_usage_probability_percent     = ls_bomlist-usageprobabilitypercent.
            ls_bom-_discontinuation_group         = ls_bomlist-discontinuationgroup.
            ls_bom-_follow_up_group               = ls_bomlist-followupgroup.
            ls_bom-_is_material_provision         = ls_bomlist-ismaterialprovision.
            ls_bom-_is_bulk_material              = ls_bomlist-isbulkmaterial.
            ls_bom-_material_is_co_product        = ls_bomlist-materialiscoproduct.
            ls_bom-_b_o_m_item_sorter             = ls_bomlist-bomitemsorter.
            ls_bom-_b_o_m_item_description        = ls_bomlist-bomitemdescription.
            ls_bom-_b_o_m_item_text2              = ls_bomlist-bomitemtext2.

            TRY.
                ls_bom-_bill_of_material_item_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                                    iv_input = ls_bomlist-billofmaterialitemunit ).
              CATCH zzcx_custom_exception INTO lo_root_exc.
                ls_bom-_bill_of_material_item_unit = ls_bomlist-billofmaterialitemunit.
            ENDTRY.

            ls_bom-_bill_of_material_category     = ls_bomlist-billofmaterialcategory.
            ls_bom-_bill_of_material_root         = ls_bomlist-billofmaterialroot.
            ls_bom-_bill_of_material_root_variant = ls_bomlist-billofmaterialvariant.
            ls_bom-_bill_of_material_item_index   = ls_bomlist-billofmaterialitemindex.
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
           WHERE billofmaterialcategory = @lt_bom-_bill_of_material_category
             AND billofmaterial = @lt_bom-_bill_of_material
             AND billofmaterialvariant = @lt_bom-_bill_of_material_variant
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
           WHERE billofmaterialcategory = @lt_bom-_bill_of_material_category
             AND billofmaterial = @lt_bom-_bill_of_material
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
           WHERE billofmaterialcategory = @lt_bom-_bill_of_material_category
             AND billofmaterial = @lt_bom-_bill_of_material
             AND billofmaterialitemnodenumber = @lt_bom-billofmaterialitemnodenumber
            INTO TABLE @DATA(lt_billofmaterialsubitemsbasic).

          DATA(lt_bom_tmp) = lt_bom.
          SORT lt_bom_tmp BY _b_o_m_hdr_root_matl_hier_node.
          DELETE ADJACENT DUPLICATES FROM lt_bom_tmp
                                COMPARING _b_o_m_hdr_root_matl_hier_node.

          IF lt_bom_tmp IS NOT INITIAL.
            "Obtain data of BOM root material description
            SELECT product,
                   productdescription
              FROM i_productdescription WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_bom_tmp
             WHERE product = @lt_bom_tmp-_b_o_m_hdr_root_matl_hier_node
               AND language = @sy-langu"ls_ztbc_1001-language
              INTO TABLE @DATA(lt_productdescription).
          ENDIF.

          lt_bom_tmp = lt_bom.
          SORT lt_bom_tmp BY _b_o_m_hdr_matl_hier_node.
          DELETE ADJACENT DUPLICATES FROM lt_bom_tmp
                                COMPARING _b_o_m_hdr_matl_hier_node.

          IF lt_bom_tmp IS NOT INITIAL.
            "Obtain data of BOM material description
            SELECT product,
                   productdescription
              FROM i_productdescription WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_bom_tmp
             WHERE product = @lt_bom_tmp-_b_o_m_hdr_matl_hier_node
               AND language = @sy-langu"ls_ztbc_1001-language
               APPENDING TABLE @lt_productdescription.
          ENDIF.

          lt_bom_tmp = lt_bom.
          SORT lt_bom_tmp BY _bill_of_material_component.
          DELETE ADJACENT DUPLICATES FROM lt_bom_tmp
                                COMPARING _bill_of_material_component.

          IF lt_bom_tmp IS NOT INITIAL.
            "Obtain data of BOM component description
            SELECT product,
                   productdescription
              FROM i_productdescription WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_bom_tmp
             WHERE product = @lt_bom_tmp-_bill_of_material_component
               AND language = @sy-langu"ls_ztbc_1001-language
               APPENDING TABLE @lt_productdescription.

            "Obtain data of units of measure of BOM component
            SELECT product,
*                   alternativeunit,
                   baseunit
              FROM i_productunitsofmeasure WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_bom_tmp
             WHERE product = @lt_bom_tmp-_bill_of_material_component
              INTO TABLE @DATA(lt_productunitsofmeasure).

            "Obtain data of discontinued indicator of BOM component
            SELECT product,
                   plant,
                   productistobediscontinued
              FROM i_productsupplyplanning WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_bom_tmp
             WHERE product = @lt_bom_tmp-_bill_of_material_component
               AND plant = @lt_bom_tmp-_plant
              INTO TABLE @DATA(lt_productsupplyplanning).
          ENDIF.
        ENDIF.

        DATA(lv_lines) = lines( lt_bom ).
        DATA(lv_lines_del) = lines( ls_res-_data-_bom ).
        ls_res-_msgty = 'S'.

        "BOMマスタデータ连携成功 &1 件！削除された代替BOM &2 件！
        MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 014 WITH lv_lines lv_lines_del INTO ls_res-_msg.
      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    SORT lt_bom BY _bill_of_material_category _bill_of_material_root _bill_of_material_root_variant _bill_of_material_item_index.
    SORT lt_billofmaterialwithkeydate BY billofmaterialcategory billofmaterial billofmaterialvariant.
    SORT lt_billofmaterialitemdex_3 BY billofmaterialcategory billofmaterial billofmaterialitemnodenumber.
    SORT lt_billofmaterialsubitemsbasic BY billofmaterialcategory billofmaterial billofmaterialitemnodenumber.
    SORT lt_productdescription BY product.
    SORT lt_productunitsofmeasure BY product.
    SORT lt_productsupplyplanning BY product plant.

    "Read data of BOM
    LOOP AT lt_bom INTO ls_bom.
      ls_bom_tmp = ls_bom.

      "Read data of BOM header
      READ TABLE lt_billofmaterialwithkeydate INTO DATA(ls_billofmaterialwithkeydate) WITH KEY billofmaterialcategory = ls_bom-_bill_of_material_category
                                                                                               billofmaterial = ls_bom-_bill_of_material_root
                                                                                               billofmaterialvariant = ls_bom-_bill_of_material_root_variant
                                                                                      BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-_bill_of_material_status    = ls_billofmaterialwithkeydate-billofmaterialstatus.
        ls_bom_tmp-_header_validity_start_date = ls_billofmaterialwithkeydate-headervaliditystartdate.
        ls_bom_tmp-_header_validity_end_date   = ls_billofmaterialwithkeydate-headervalidityenddate.
        ls_bom_tmp-headerengineeringchgnmbrdoc = ls_billofmaterialwithkeydate-engineeringchangedocument.
        ls_bom_tmp-_record_creation_date       = ls_billofmaterialwithkeydate-recordcreationdate.
        ls_bom_tmp-_created_by_user            = ls_billofmaterialwithkeydate-createdbyuser.
        ls_bom_tmp-bomheaderquantityinbaseunit = ls_billofmaterialwithkeydate-bomheaderquantityinbaseunit.

        TRY.
            ls_bom_tmp-_b_o_m_header_base_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                               iv_input = ls_billofmaterialwithkeydate-bomheaderbaseunit ).
          CATCH zzcx_custom_exception INTO lo_root_exc.
            ls_bom_tmp-_b_o_m_header_base_unit = ls_billofmaterialwithkeydate-bomheaderbaseunit.
        ENDTRY.

        lv_timestamp = trunc( ls_billofmaterialwithkeydate-lastchangedatetime ).

        "Convert date and time from zero zone to time zone of plant
        CONVERT TIME STAMP lv_timestamp
                TIME ZONE ls_ztbc_1001-zonlo_out
                INTO DATE lv_date
                     TIME lv_time.

        lv_timestamp = lv_date && lv_time.
        ls_bom_tmp-_last_change_date_time = lv_timestamp + frac( ls_billofmaterialwithkeydate-lastchangedatetime ).
      ENDIF.

      "Read data of BOM items
      READ TABLE lt_billofmaterialitemdex_3 INTO DATA(ls_billofmaterialitemdex_3) WITH KEY billofmaterialcategory = ls_bom-_bill_of_material_category
                                                                                           billofmaterial = ls_bom-_bill_of_material_root
                                                                                           billofmaterialitemnodenumber = ls_bom-billofmaterialitemnodenumber
                                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-_b_o_m_item_is_spare_part    = ls_billofmaterialitemdex_3-bomitemissparepart.
        ls_bom_tmp-_component_scrap_in_percent  = ls_billofmaterialitemdex_3-componentscrapinpercent.
        ls_bom_tmp-_validity_start_date         = ls_billofmaterialitemdex_3-validitystartdate.
        ls_bom_tmp-_validity_end_date           = ls_billofmaterialitemdex_3-validityenddate.
        ls_bom_tmp-_engineering_change_document = ls_billofmaterialitemdex_3-engineeringchangedocument.
        ls_bom_tmp-_is_deleted                  = ls_billofmaterialitemdex_3-isdeleted.

        lv_timestamp = trunc( ls_billofmaterialitemdex_3-lastchangedatetime ).

        "Convert date and time from zero zone to time zone of plant
        CONVERT TIME STAMP lv_timestamp
                TIME ZONE ls_ztbc_1001-zonlo_out
                INTO DATE lv_date
                     TIME lv_time.

        lv_timestamp = lv_date && lv_time.
        ls_bom_tmp-_item_last_change_date_time = lv_timestamp + frac( ls_billofmaterialitemdex_3-lastchangedatetime ).
      ENDIF.

      "Read data of BOM sub items
      READ TABLE lt_billofmaterialsubitemsbasic TRANSPORTING NO FIELDS WITH KEY billofmaterialcategory = ls_bom-_bill_of_material_category
                                                                                billofmaterial = ls_bom-_bill_of_material_root
                                                                                billofmaterialitemnodenumber = ls_bom-billofmaterialitemnodenumber
                                                                       BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_billofmaterialsubitemsbasic INTO DATA(ls_billofmaterialsubitemsbasic) FROM sy-tabix.
          IF ls_billofmaterialsubitemsbasic-billofmaterialcategory <> ls_bom-_bill_of_material_category
          OR ls_billofmaterialsubitemsbasic-billofmaterial <> ls_bom-_bill_of_material_root
          OR ls_billofmaterialsubitemsbasic-billofmaterialitemnodenumber <> ls_bom-billofmaterialitemnodenumber.
            EXIT.
          ENDIF.

          ls_subitems-_b_o_m_sub_item_number_value  = ls_billofmaterialsubitemsbasic-bomsubitemnumbervalue.
          ls_subitems-bomsubiteminstallationpoint   = ls_billofmaterialsubitemsbasic-bomsubiteminstallationpoint.
          ls_subitems-billofmaterialsubitemquantity = ls_billofmaterialsubitemsbasic-billofmaterialsubitemquantity.

          TRY.
              ls_subitems-_bill_of_material_item_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                                       iv_input = ls_billofmaterialsubitemsbasic-billofmaterialitemunit ).
            CATCH zzcx_custom_exception INTO lo_root_exc.
              ls_subitems-_bill_of_material_item_unit = ls_billofmaterialsubitemsbasic-billofmaterialitemunit.
          ENDTRY.

          APPEND ls_subitems TO ls_bom_tmp-_sub_items.
          CLEAR ls_subitems.
        ENDLOOP.
      ENDIF.

      "Read data of BOM root material description
      READ TABLE lt_productdescription INTO DATA(ls_productdescription) WITH KEY product = ls_bom-_b_o_m_hdr_root_matl_hier_node
                                                                        BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-_hdr_root_mat_description = ls_productdescription-productdescription.
      ENDIF.

      "Read data of BOM material description
      READ TABLE lt_productdescription INTO ls_productdescription WITH KEY product = ls_bom-_b_o_m_hdr_matl_hier_node
                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-_hdr_mat_description = ls_productdescription-productdescription.
      ENDIF.

      "Read data of BOM component description
      READ TABLE lt_productdescription INTO ls_productdescription WITH KEY product = ls_bom-_bill_of_material_component
                                                                  BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-_component_description = ls_productdescription-productdescription.
      ENDIF.

      "Read data of base unit of BOM component
      READ TABLE lt_productunitsofmeasure INTO DATA(ls_productunitsofmeasure) WITH KEY product = ls_bom-_bill_of_material_component
                                                                              BINARY SEARCH.
      IF sy-subrc = 0.
        TRY.
            ls_bom_tmp-_component_base_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                            iv_input = ls_productunitsofmeasure-baseunit ).
          CATCH zzcx_custom_exception INTO lo_root_exc.
            ls_bom_tmp-_component_base_unit = ls_productunitsofmeasure-baseunit.
        ENDTRY.
      ENDIF.

      "Read data of discontinued indicator of BOM component
      READ TABLE lt_productsupplyplanning INTO DATA(ls_productsupplyplanning) WITH KEY product = ls_bom-_bill_of_material_component
                                                                                       plant = ls_bom-_plant
                                                                              BINARY SEARCH.
      IF sy-subrc = 0.
        ls_bom_tmp-_product_is_to_be_discontinued = ls_productsupplyplanning-productistobediscontinued.
      ENDIF.

      APPEND ls_bom_tmp TO ls_res-_data-_bom.
      CLEAR ls_bom_tmp.
    ENDLOOP.

*    DATA(lv_res_body) = xco_cp_json=>data->from_abap( ls_res )->apply( VALUE #(
*                          ( xco_cp_json=>transformation->underscore_to_pascal_case ) ) )->to_string( ).

    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
                                                 "compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF 'bomsubiteminstallationpoint' IN lv_res_body WITH 'BOMSubItemInstallationPoint'.
    REPLACE ALL OCCURRENCES OF 'billofmaterialsubitemquantity' IN lv_res_body WITH 'BillOfMaterialSubItemQuantity'.
    REPLACE ALL OCCURRENCES OF 'billofmaterialvariantusage' IN lv_res_body WITH 'BillOfMaterialVariantUsage'.
    REPLACE ALL OCCURRENCES OF 'bomheaderquantityinbaseunit' IN lv_res_body WITH 'BOMHeaderQuantityInBaseUnit'.
    REPLACE ALL OCCURRENCES OF 'headerengineeringchgnmbrdoc' IN lv_res_body WITH 'HeaderEngineeringChgNmbrDoc'.
    REPLACE ALL OCCURRENCES OF 'billofmaterialitemcategory' IN lv_res_body WITH 'BillOfMaterialItemCategory'.
    REPLACE ALL OCCURRENCES OF 'billofmaterialitemquantity' IN lv_res_body WITH 'BillOfMaterialItemQuantity'.
    REPLACE ALL OCCURRENCES OF 'componentquantityincompuom' IN lv_res_body WITH 'ComponentQuantityInCompUom'.
    REPLACE ALL OCCURRENCES OF 'componentquantityinbaseuom' IN lv_res_body WITH 'ComponentQuantityInBaseUom'.
    REPLACE ALL OCCURRENCES OF 'billofmaterialitemnodenumber' IN lv_res_body WITH 'BillOfMaterialItemNodeNumber'.

    "Set request data
    response->set_text( lv_res_body ).

*&--ADD BEGIN BY XINLEI XU 2025/02/08
    GET TIME STAMP FIELD DATA(lv_timestamp_end).
    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        DATA(lv_request_url) = |https://{ lv_system_url }/sap/bc/http/sap/z_http_bom_001|.
        ##NO_HANDLER
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    DATA(lv_request_body) = xco_cp_json=>data->from_abap( ls_req )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    DATA(lv_count) = lines( ls_res-_data-_bom ).

    zzcl_common_utils=>add_interface_log( EXPORTING iv_interface_id   = |IF024|
                                                    iv_interface_desc = |BOMマスタ連携|
                                                    iv_request_method = CONV #( if_web_http_client=>get )
                                                    iv_request_url    = lv_request_url
                                                    iv_request_body   = lv_request_body
                                                    iv_status_code    = CONV #( response->get_status( )-code )
                                                    iv_response       = response->get_text( )
                                                    iv_record_count   = lv_count
                                                    iv_run_start_time = CONV #( lv_timestamp_start )
                                                    iv_run_end_time   = CONV #( lv_timestamp_end )
                                          IMPORTING ev_log_uuid       = DATA(lv_log_uuid) ).
*&--ADD END BY XINLEI XU 2025/02/08
  ENDMETHOD.
ENDCLASS.
