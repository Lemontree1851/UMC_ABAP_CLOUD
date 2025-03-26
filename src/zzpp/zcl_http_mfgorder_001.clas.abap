CLASS zcl_http_mfgorder_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_http_mfgorder_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        plant      TYPE string,
        order      TYPE string,
        time_stamp TYPE string,
      END OF ty_req,

      "ManufacturingOrder
      BEGIN OF ty_order,
        _manufacturing_order           TYPE i_manufacturingorder-manufacturingorder,
        _manufacturing_order_type      TYPE i_manufacturingorder-manufacturingordertype,
        _material                      TYPE i_manufacturingorder-material,
        _product_description           TYPE i_productdescription-productdescription,
        _manufacturing_order_text      TYPE i_manufacturingorder-manufacturingordertext,
        _production_plant              TYPE i_manufacturingorder-productionplant,
        _leading_order                 TYPE i_manufacturingorder-leadingorder,
        _superior_order                TYPE i_manufacturingorder-superiororder,
        _order_is_created              TYPE i_mfgorderwithstatus-orderiscreated,
        _order_is_released             TYPE i_mfgorderwithstatus-orderisreleased,
        _order_is_printed              TYPE i_mfgorderwithstatus-orderisprinted,
        _order_is_partially_printed    TYPE i_mfgorderwithstatus-orderispartiallyprinted,
        _order_is_confirmed            TYPE i_mfgorderwithstatus-orderisconfirmed,
        _order_is_partially_confirmed  TYPE i_mfgorderwithstatus-orderispartiallyconfirmed,
        _order_is_delivered            TYPE i_mfgorderwithstatus-orderisdelivered,
        _order_is_deleted              TYPE i_mfgorderwithstatus-orderisdeleted,
        _order_is_product_costed       TYPE i_mfgorderwithstatus-orderisproductcosted,
        _order_is_pre_costed           TYPE i_mfgorderwithstatus-orderisprecosted,
        _settlement_rule_is_created    TYPE i_mfgorderwithstatus-settlementruleiscreated,
        _order_is_partially_released   TYPE i_mfgorderwithstatus-orderispartiallyreleased,
        _order_is_locked               TYPE i_mfgorderwithstatus-orderislocked,
        orderistechnicallycompleted    TYPE i_mfgorderwithstatus-orderistechnicallycompleted,
        _order_is_closed               TYPE i_mfgorderwithstatus-orderisclosed,
        orderisdistributionrelevant    TYPE i_mfgorderwithstatus-orderisdistributionrelevant,
        _order_release_is_rejected     TYPE i_mfgorderwithstatus-orderreleaseisrejected,
        _order_is_partially_delivered  TYPE i_mfgorderwithstatus-orderispartiallydelivered,
        _order_is_marked_for_deletion  TYPE i_mfgorderwithstatus-orderismarkedfordeletion,
        orderhascostcalculationerror   TYPE i_mfgorderwithstatus-orderhascostcalculationerror,
        settlementruleiscrtedmanually  TYPE i_mfgorderwithstatus-settlementruleiscrtedmanually,
        _order_is_scheduled            TYPE i_mfgorderwithstatus-orderisscheduled,
        orderhasgeneratedoperations    TYPE i_mfgorderwithstatus-orderhasgeneratedoperations,
        orderistobehandledinbatches    TYPE i_mfgorderwithstatus-orderistobehandledinbatches,
        materialavailyisnotchecked     TYPE i_mfgorderwithstatus-materialavailyisnotchecked,
        _mfg_order_planned_total_qty   TYPE i_manufacturingorder-mfgorderplannedtotalqty,
        _actual_delivered_quantity     TYPE i_manufacturingorder-actualdeliveredquantity,
        _mfg_order_planned_start_date  TYPE string, "i_manufacturingorder-mfgorderplannedstartdate,
*        _mfg_order_planned_start_time  TYPE string, "i_manufacturingorder-mfgorderplannedstarttime,
        _mfg_order_planned_end_date    TYPE string, "i_manufacturingorder-mfgorderplannedenddate,
*        _mfg_order_planned_end_time    TYPE string, "i_manufacturingorder-mfgorderplannedendtime,
        _mrp_controller                TYPE i_manufacturingorder-mrpcontroller,
        _production_supervisor         TYPE i_manufacturingorder-productionsupervisor,
        _project_element               TYPE i_enterpriseprojectelement_2-projectelement,
        _sales_order                   TYPE i_manufacturingorder-salesorder,
        _sales_order_item              TYPE i_manufacturingorder-salesorderitem,
        _sales_order_schedule_line     TYPE i_manufacturingorderitem-salesorderscheduleline,
        _is_completely_delivered       TYPE i_manufacturingorder-iscompletelydelivered,
        _storage_location              TYPE i_manufacturingorder-storagelocation,
        _production_version            TYPE i_manufacturingorder-productionversion,
        _bill_of_material_internal_i_d TYPE i_manufacturingorder-billofmaterialinternalid,
        billofmaterialvariantusage     TYPE i_manufacturingorder-billofmaterialvariantusage,
        _bill_of_material_variant      TYPE i_manufacturingorder-billofmaterialvariant,
        _procurement_type              TYPE i_productplantbasic-procurementtype,
        _created_by_user               TYPE i_manufacturingorder-createdbyuser,
        _creation_date                 TYPE c LENGTH 8,
        _creation_time                 TYPE c LENGTH 6,
        _last_changed_by_user          TYPE i_manufacturingorder-lastchangedbyuser,
        _last_change_date              TYPE c LENGTH 8,
        _last_change_time              TYPE c LENGTH 6,
        _sent_time_stamp               TYPE timestamp,
      END OF ty_order,
      tt_order TYPE STANDARD TABLE OF ty_order WITH DEFAULT KEY,

      "BOM
      BEGIN OF ty_bom,
        _manufacturing_order           TYPE i_manufacturingorder-manufacturingorder,
        billofmaterialitemnumber_2     TYPE i_mfgorderoperationcomponent-billofmaterialitemnumber_2,
        _material                      TYPE i_mfgorderoperationcomponent-material,
        _product_description           TYPE i_productdescription-productdescription,
        _required_quantity             TYPE i_mfgorderoperationcomponent-requiredquantity,
        _base_unit                     TYPE i_mfgorderoperationcomponent-baseunit,
        _b_o_m_item_category           TYPE i_mfgorderoperationcomponent-bomitemcategory,
        manufacturingorderoperation_2  TYPE i_mfgorderoperationcomponent-manufacturingorderoperation_2,
        _manufacturing_order_sequence  TYPE i_mfgorderoperationcomponent-manufacturingordersequence,
        _plant                         TYPE i_mfgorderoperationcomponent-plant,
        _storage_location              TYPE i_mfgorderoperationcomponent-storagelocation,
        _batch                         TYPE i_mfgorderoperationcomponent-batch,
        materialcompisalternativeitem  TYPE i_mfgorderoperationcomponent-materialcompisalternativeitem,
        _alternative_item_group        TYPE i_mfgorderoperationcomponent-alternativeitemgroup,
        _alternative_item_strategy     TYPE i_mfgorderoperationcomponent-alternativeitemstrategy,
        _alternative_item_priority     TYPE i_mfgorderoperationcomponent-alternativeitempriority,
        _usage_probability_percent     TYPE i_mfgorderoperationcomponent-usageprobabilitypercent,
        alternativemstrreservationitem TYPE i_mfgorderoperationcomponent-alternativemstrreservationitem,
        _is_bulk_material_component    TYPE i_mfgorderoperationcomponent-isbulkmaterialcomponent,
        matlcompismarkedforbackflush   TYPE i_mfgorderoperationcomponent-matlcompismarkedforbackflush,
        matlcompismarkedfordeletion    TYPE i_mfgorderoperationcomponent-matlcompismarkedfordeletion,
        materialcomponentisphantomitem TYPE i_mfgorderoperationcomponent-materialcomponentisphantomitem,
        matlcompdiscontinuationtype    TYPE i_mfgorderoperationcomponent-matlcompdiscontinuationtype,
        _discontinuation_group         TYPE i_mfgorderoperationcomponent-discontinuationgroup,
        matlcompisfollowupmaterial     TYPE i_mfgorderoperationcomponent-matlcompisfollowupmaterial,
        _follow_up_group               TYPE i_mfgorderoperationcomponent-followupgroup,
        _follow_up_material            TYPE i_mfgorderoperationcomponent-followupmaterial,
        _follow_up_material_is_active  TYPE i_mfgorderoperationcomponent-followupmaterialisactive,
        discontinuationmasterresvnitem TYPE i_mfgorderoperationcomponent-discontinuationmasterresvnitem,
        _component_scrap_in_percent    TYPE i_mfgorderoperationcomponent-componentscrapinpercent,
        _material_is_directly_produced TYPE i_mfgorderoperationcomponent-materialisdirectlyproduced,
        _material_is_directly_procured TYPE i_mfgorderoperationcomponent-materialisdirectlyprocured,
        _material_provision_type       TYPE i_mfgorderoperationcomponent-materialprovisiontype,
        matlcomponentspareparttype     TYPE i_mfgorderoperationcomponent-matlcomponentspareparttype,
        _confirmed_available_quantity  TYPE i_mfgorderoperationcomponent-confirmedavailablequantity,
        _withdrawn_quantity            TYPE i_mfgorderoperationcomponent-withdrawnquantity,
        materialcomporiginalquantity   TYPE i_mfgorderoperationcomponent-materialcomporiginalquantity,
        _reservation                   TYPE i_mfgorderoperationcomponent-reservation,
        _reservation_item              TYPE i_mfgorderoperationcomponent-reservationitem,
        _goods_movement_type           TYPE i_mfgorderoperationcomponent-goodsmovementtype,
        _material_component_sort_text  TYPE i_mfgorderoperationcomponent-materialcomponentsorttext,
        _procurement_type_item         TYPE i_productplantbasic-procurementtype,
      END OF ty_bom,
      tt_bom TYPE STANDARD TABLE OF ty_bom WITH DEFAULT KEY,

      "Routing
      BEGIN OF ty_routing,
        _manufacturing_order           TYPE i_manufacturingorder-manufacturingorder,
        manufacturingorderoperation_2  TYPE i_manufacturingorderoperation-manufacturingorderoperation_2,
        _work_center                   TYPE i_workcenter-workcenter,
        _plant                         TYPE i_manufacturingorderoperation-plant,
        _operation_control_profile     TYPE i_manufacturingorderoperation-operationcontrolprofile,
        _op_planned_total_quantity     TYPE i_manufacturingorderoperation-opplannedtotalquantity,
        _operation_unit                TYPE i_manufacturingorderoperation-operationunit,
        _op_total_confirmed_yield_qty  TYPE i_manufacturingorderoperation-optotalconfirmedyieldqty,
        _op_total_confirmed_scrap_qty  TYPE i_manufacturingorderoperation-optotalconfirmedscrapqty,
        _number_of_time_tickets        TYPE i_manufacturingorderoperation-numberoftimetickets,
        _operation_confirmation        TYPE i_manufacturingorderoperation-operationconfirmation,
        _operation_reference_quantity  TYPE i_manufacturingorderoperation-operationreferencequantity,
        _op_confirmed_work_quantity1   TYPE i_manufacturingorderoperation-opconfirmedworkquantity1,
        _op_work_quantity_unit1        TYPE i_manufacturingorderoperation-opworkquantityunit1,
        workcenterstandardworkqty1     TYPE i_manufacturingorderoperation-workcenterstandardworkqty1,
        workcenterstandardworkqtyunit1 TYPE i_manufacturingorderoperation-workcenterstandardworkqtyunit1,
        _op_confirmed_work_quantity2   TYPE i_manufacturingorderoperation-opconfirmedworkquantity2,
        _op_work_quantity_unit2        TYPE i_manufacturingorderoperation-opworkquantityunit2,
        workcenterstandardworkqty2     TYPE i_manufacturingorderoperation-workcenterstandardworkqty2,
        workcenterstandardworkqtyunit2 TYPE i_manufacturingorderoperation-workcenterstandardworkqtyunit2,
        _op_confirmed_work_quantity3   TYPE i_manufacturingorderoperation-opconfirmedworkquantity3,
        _op_work_quantity_unit3        TYPE i_manufacturingorderoperation-opworkquantityunit3,
        workcenterstandardworkqty3     TYPE i_manufacturingorderoperation-workcenterstandardworkqty3,
        workcenterstandardworkqtyunit3 TYPE i_manufacturingorderoperation-workcenterstandardworkqtyunit3,
        _op_confirmed_work_quantity4   TYPE i_manufacturingorderoperation-opconfirmedworkquantity4,
        _op_work_quantity_unit4        TYPE i_manufacturingorderoperation-opworkquantityunit4,
        workcenterstandardworkqty4     TYPE i_manufacturingorderoperation-workcenterstandardworkqty4,
        workcenterstandardworkqtyunit4 TYPE i_manufacturingorderoperation-workcenterstandardworkqtyunit4,
        _op_confirmed_work_quantity5   TYPE i_manufacturingorderoperation-opconfirmedworkquantity5,
        _op_work_quantity_unit5        TYPE i_manufacturingorderoperation-opworkquantityunit5,
        workcenterstandardworkqty5     TYPE i_manufacturingorderoperation-workcenterstandardworkqty5,
        workcenterstandardworkqtyunit5 TYPE i_manufacturingorderoperation-workcenterstandardworkqtyunit5,
        _op_confirmed_work_quantity6   TYPE i_manufacturingorderoperation-opconfirmedworkquantity6,
        _op_work_quantity_unit6        TYPE i_manufacturingorderoperation-opworkquantityunit6,
        workcenterstandardworkqty6     TYPE i_manufacturingorderoperation-workcenterstandardworkqty6,
        workcenterstandardworkqtyunit6 TYPE i_manufacturingorderoperation-workcenterstandardworkqtyunit6,
      END OF ty_routing,
      tt_routing TYPE STANDARD TABLE OF ty_routing WITH DEFAULT KEY,

      BEGIN OF ty_data,
        _order   TYPE tt_order,
        _bom     TYPE tt_bom,
        _routing TYPE tt_routing,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res.

    DATA:
      lo_root_exc  TYPE REF TO cx_root,
      ls_req       TYPE ty_req,
      ls_res       TYPE ty_res,
      ls_order     TYPE ty_order,
      ls_bom       TYPE ty_bom,
      ls_routing   TYPE ty_routing,
      lv_plant     TYPE i_manufacturingorder-productionplant,
      lv_order     TYPE i_manufacturingorder-manufacturingorder,
      lv_timestamp TYPE timestamp,
      lv_date      TYPE d,
      lv_time      TYPE t.

    CONSTANTS:
      lc_zid_zpp005 TYPE ztbc_1001-zid VALUE 'ZPP005',
      lc_msgid      TYPE string        VALUE 'ZPP_001',
      lc_msgty      TYPE string        VALUE 'E',
      lc_alpha_out  TYPE string        VALUE 'OUT'.

    GET TIME STAMP FIELD DATA(lv_timestamp_start).

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    IF lv_req_body IS NOT INITIAL.
      xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).
    ENDIF.

    lv_plant = ls_req-plant.
    lv_order = |{ ls_req-order ALPHA = IN }|.
    lv_timestamp = ls_req-time_stamp.

    TRY.
        "Check plant of input parameter must be valuable
        IF lv_plant IS INITIAL.
          "プラントを送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 001 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check manufacturing order or time stamp of input parameter must be valuable
        IF lv_order IS INITIAL AND lv_timestamp IS INITIAL.
          "製造指図或いは前回送信時間は送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 005 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check manufacturing order and time stamp of input parameter must be not valuable at the same time
        IF lv_order IS NOT INITIAL AND lv_timestamp IS NOT INITIAL.
          "製造指図と前回送信時間は一つしか送信できません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 006 INTO ls_res-_msg.
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

        IF lv_order IS NOT INITIAL.
          "Check manufacturing order and plant of input parameter must be existent
          SELECT COUNT(*)
            FROM i_manufacturingorder WITH PRIVILEGED ACCESS
           WHERE manufacturingorder = @lv_order
             AND productionplant = @lv_plant.
          IF sy-subrc <> 0.
            "プラント&1製造指図&2存在しません！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 007 WITH lv_plant lv_order INTO ls_res-_msg.
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
        CONVERT TIME STAMP lv_timestamp
                TIME ZONE ls_ztbc_1001-zonlo_in
                INTO DATE lv_date
                     TIME lv_time.

        lv_timestamp = lv_date && lv_time.

        IF lv_order IS NOT INITIAL.
          "Obtain data of manufacturing order
          SELECT manufacturingorder AS _manufacturing_order,
                 manufacturingordertype AS _manufacturing_order_type,
                 material AS _material,
                 productdescription AS _product_description,
                 manufacturingordertext AS _manufacturing_order_text,
                 productionplant AS _production_plant,
                 leadingorder AS _leading_order,
                 superiororder AS _superior_order,
                 mfgorderplannedtotalqty AS _mfg_order_planned_total_qty,
                 actualdeliveredquantity AS _actual_delivered_quantity,
                 mfgorderplannedstartdate AS _mfg_order_planned_start_date,
                 mfgorderplannedstarttime AS _mfg_order_planned_start_time,
                 mfgorderplannedenddate AS _mfg_order_planned_end_date,
                 mfgorderplannedendtime AS _mfg_order_planned_end_time,
                 mrpcontroller AS _mrp_controller,
                 a~productionsupervisor AS _production_supervisor,
                 wbselementinternalid_2,
                 salesorder AS _sales_order,
                 salesorderitem AS _sales_order_item,
                 iscompletelydelivered AS _is_completely_delivered,
                 storagelocation AS _storage_location,
                 productionversion AS _production_version,
                 billofmaterialinternalid AS _bill_of_material_internal_i_d,
                 billofmaterialvariantusage,
                 billofmaterialvariant AS _bill_of_material_variant,
                 createdbyuser AS _created_by_user,
                 creationdate AS _creation_date,
                 creationtime AS _creation_time,
                 lastchangedbyuser AS _last_changed_by_user,
                 lastchangedate AS _last_change_date,
                 lastchangetime AS _last_change_time,
                 c~procurementtype AS _procurement_type
            FROM i_manufacturingorder WITH PRIVILEGED ACCESS AS a
            LEFT OUTER JOIN i_productdescription WITH PRIVILEGED ACCESS AS b
              ON b~product = a~material
             AND b~language = @sy-langu"ls_ztbc_1001-language
            LEFT OUTER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS c
              ON c~product = a~material
             AND c~plant = a~productionplant
           WHERE a~manufacturingorder = @lv_order
             AND a~productionplant = @lv_plant
             INTO TABLE @DATA(lt_manufacturingorder).
        ELSE.
          "Obtain data of manufacturing order
          SELECT manufacturingorder
            FROM i_manufacturingorder WITH PRIVILEGED ACCESS
           WHERE ( concat( creationdate,creationtime ) >= @lv_timestamp
                OR concat( lastchangedate,lastchangetime ) >= @lv_timestamp )
             AND productionplant = @lv_plant
            INTO TABLE @DATA(lt_manufacturingorder_entries).

          "Obtain data of manufacturing order related to material document
          SELECT b~manufacturingorder
            FROM i_materialdocumentheader_2 WITH PRIVILEGED ACCESS AS a
           INNER JOIN i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS b
              ON b~materialdocumentyear = a~materialdocumentyear
             AND b~materialdocument = a~materialdocument
           WHERE concat( a~creationdate,a~creationtime ) >= @lv_timestamp
             AND b~manufacturingorder IS NOT INITIAL
       APPENDING TABLE @lt_manufacturingorder_entries.

          "Delete duplicates data
          SORT lt_manufacturingorder_entries BY manufacturingorder.
          DELETE ADJACENT DUPLICATES FROM lt_manufacturingorder_entries
                                COMPARING manufacturingorder.

          IF lt_manufacturingorder_entries IS NOT INITIAL.
            "Obtain data of manufacturing order
            SELECT manufacturingorder AS _manufacturing_order,
                   manufacturingordertype AS _manufacturing_order_type,
                   material AS _material,
                   productdescription AS _product_description,
                   manufacturingordertext AS _manufacturing_order_text,
                   productionplant AS _production_plant,
                   leadingorder AS _leading_order,
                   superiororder AS _superior_order,
                   mfgorderplannedtotalqty AS _mfg_order_planned_total_qty,
                   actualdeliveredquantity AS _actual_delivered_quantity,
                   mfgorderplannedstartdate AS _mfg_order_planned_start_date,
                   mfgorderplannedstarttime AS _mfg_order_planned_start_time,
                   mfgorderplannedenddate AS _mfg_order_planned_end_date,
                   mfgorderplannedendtime AS _mfg_order_planned_end_time,
                   mrpcontroller AS _mrp_controller,
                   a~productionsupervisor AS _production_supervisor,
                   wbselementinternalid_2,
                   salesorder AS _sales_order,
                   salesorderitem AS _sales_order_item,
                   iscompletelydelivered AS _is_completely_delivered,
                   storagelocation AS _storage_location,
                   productionversion AS _production_version,
                   billofmaterialinternalid AS _bill_of_material_internal_i_d,
                   billofmaterialvariantusage,
                   billofmaterialvariant AS _bill_of_material_variant,
                   createdbyuser AS _created_by_user,
                   creationdate AS _creation_date,
                   creationtime AS _creation_time,
                   lastchangedbyuser AS _last_changed_by_user,
                   lastchangedate AS _last_change_date,
                   lastchangetime AS _last_change_time,
                   c~procurementtype AS _procurement_type
              FROM i_manufacturingorder WITH PRIVILEGED ACCESS AS a
              LEFT OUTER JOIN i_productdescription WITH PRIVILEGED ACCESS AS b
                ON b~product = a~material
               AND b~language = @sy-langu"ls_ztbc_1001-language
              LEFT OUTER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS c
                ON c~product = a~material
               AND c~plant = a~productionplant
               FOR ALL ENTRIES IN @lt_manufacturingorder_entries
             WHERE a~manufacturingorder = @lt_manufacturingorder_entries-manufacturingorder
               AND a~productionplant = @lv_plant
              INTO TABLE @lt_manufacturingorder.
          ENDIF.
        ENDIF.

        IF lt_manufacturingorder IS NOT INITIAL.
          "Obtain data of enterprise project element
          SELECT wbselementinternalid,
                 projectelement
            FROM i_enterpriseprojectelement_2 WITH PRIVILEGED ACCESS "#EC CI_NO_TRANSFORM
             FOR ALL ENTRIES IN @lt_manufacturingorder
           WHERE wbselementinternalid = @lt_manufacturingorder-wbselementinternalid_2
            INTO TABLE @DATA(lt_enterpriseprojectelement_2).

          "Obtain data of manufacturing order header with status
          SELECT manufacturingorder AS _manufacturing_order,
                 orderiscreated AS _order_is_created,
                 orderisreleased AS _order_is_released,
                 orderisprinted AS _order_is_printed,
                 orderispartiallyprinted AS _order_is_partially_printed,
                 orderisconfirmed AS _order_is_confirmed,
                 orderispartiallyconfirmed AS _order_is_partially_confirmed,
                 orderisdelivered AS _order_is_delivered,
                 orderisdeleted AS _order_is_deleted,
                 orderisproductcosted AS _order_is_product_costed,
                 orderisprecosted AS _order_is_pre_costed,
                 settlementruleiscreated AS _settlement_rule_is_created,
                 orderispartiallyreleased AS _order_is_partially_released,
                 orderislocked AS _order_is_locked,
                 orderistechnicallycompleted AS orderistechnicallycompleted,
                 orderisclosed AS _order_is_closed,
                 orderisdistributionrelevant,
                 orderreleaseisrejected AS _order_release_is_rejected,
                 orderispartiallydelivered AS _order_is_partially_delivered,
                 orderismarkedfordeletion AS _order_is_marked_for_deletion,
                 orderhascostcalculationerror,
                 settlementruleiscrtedmanually,
                 orderisscheduled AS _order_is_scheduled,
                 orderhasgeneratedoperations,
                 orderistobehandledinbatches,
                 materialavailyisnotchecked
            FROM i_mfgorderwithstatus WITH PRIVILEGED ACCESS "#EC CI_NO_TRANSFORM
             FOR ALL ENTRIES IN @lt_manufacturingorder
           WHERE manufacturingorder = @lt_manufacturingorder-_manufacturing_order
            INTO TABLE @DATA(lt_mfgorderwithstatus).

          "Obtain data of manufacturing order item
          SELECT manufacturingorder AS _manufacturing_order,
                 salesorderscheduleline AS _sales_order_schedule_line,
                 materialprocurementtype AS _material_procurement_type
            FROM i_manufacturingorderitem WITH PRIVILEGED ACCESS "#EC CI_NO_TRANSFORM
             FOR ALL ENTRIES IN @lt_manufacturingorder
           WHERE manufacturingorder = @lt_manufacturingorder-_manufacturing_order
            INTO TABLE @DATA(lt_manufacturingorderitem).

          "Obtain data of BOM
          SELECT manufacturingorder AS _manufacturing_order,
                 billofmaterialitemnumber_2,
                 material AS _material,
                 productdescription AS _product_description,
                 requiredquantity AS _required_quantity,
                 baseunit AS _base_unit,
                 bomitemcategory AS _b_o_m_item_category,
                 manufacturingorderoperation_2,
                 manufacturingordersequence AS _manufacturing_order_sequence,
                 plant AS _plant,
                 storagelocation AS _storage_location,
                 batch AS _batch,
                 materialcompisalternativeitem,
                 alternativeitemgroup AS _alternative_item_group,
                 alternativeitemstrategy AS _alternative_item_strategy,
                 alternativeitempriority AS _alternative_item_priority,
                 usageprobabilitypercent AS _usage_probability_percent,
                 alternativemstrreservationitem,
                 isbulkmaterialcomponent AS _is_bulk_material_component,
                 matlcompismarkedforbackflush,
                 matlcompismarkedfordeletion,
                 materialcomponentisphantomitem,
                 matlcompdiscontinuationtype,
                 discontinuationgroup AS _discontinuation_group,
                 matlcompisfollowupmaterial,
                 followupgroup AS _follow_up_group,
                 followupmaterial AS _follow_up_material,
                 followupmaterialisactive AS _follow_up_material_is_active,
                 discontinuationmasterresvnitem,
                 componentscrapinpercent AS _component_scrap_in_percent,
                 materialisdirectlyproduced AS _material_is_directly_produced,
                 materialisdirectlyprocured AS _material_is_directly_procured,
                 materialprovisiontype AS _material_provision_type,
                 matlcomponentspareparttype,
                 reservationisfinallyissued AS _reservation_is_finally_issued,
                 confirmedavailablequantity AS _confirmed_available_quantity,
                 withdrawnquantity AS _withdrawn_quantity,
                 materialcomporiginalquantity,
                 reservation AS _reservation,
                 reservationitem AS _reservation_item,
                 goodsmovementtype AS _goods_movement_type,
                 materialcomponentsorttext AS _material_component_sort_text
            FROM i_mfgorderoperationcomponent WITH PRIVILEGED ACCESS AS a "#EC CI_NO_TRANSFORM
            LEFT OUTER JOIN i_productdescription WITH PRIVILEGED ACCESS AS b
              ON b~product = a~material
             AND b~language = @sy-langu"ls_ztbc_1001-language
             FOR ALL ENTRIES IN @lt_manufacturingorder
           WHERE a~manufacturingorder = @lt_manufacturingorder-_manufacturing_order
            INTO TABLE @DATA(lt_mfgorderoperationcomponent).
          IF sy-subrc = 0.
            "Obtain data of product plant
            SELECT product,
                   plant,
                   procurementtype
              FROM i_productplantbasic WITH PRIVILEGED ACCESS "#EC CI_NO_TRANSFORM
               FOR ALL ENTRIES IN @lt_mfgorderoperationcomponent
             WHERE product = @lt_mfgorderoperationcomponent-_material
               AND plant = @lt_mfgorderoperationcomponent-_plant
              INTO TABLE @DATA(lt_productplantbasic).
          ENDIF.

          "Obtain data of routing
          SELECT a~manufacturingorder AS _manufacturing_order,
                 a~manufacturingorderoperation_2,
                 b~workcenter AS _work_center,
                 a~plant AS _plant,
                 a~operationcontrolprofile AS _operation_control_profile,
                 a~opplannedtotalquantity AS _op_planned_total_quantity,
                 a~operationunit AS _operation_unit,
                 a~optotalconfirmedyieldqty AS _op_total_confirmed_yield_qty,
                 a~optotalconfirmedscrapqty AS _op_total_confirmed_scrap_qty,
                 a~numberoftimetickets AS _number_of_time_tickets,
                 a~operationconfirmation AS _operation_confirmation,
                 a~operationreferencequantity AS _operation_reference_quantity,
                 a~opconfirmedworkquantity1 AS _op_confirmed_work_quantity1,
                 a~opworkquantityunit1 AS _op_work_quantity_unit1,
                 a~workcenterstandardworkqty1,
                 a~workcenterstandardworkqtyunit1,
                 a~opconfirmedworkquantity2 AS _op_confirmed_work_quantity2,
                 a~opworkquantityunit2 AS _op_work_quantity_unit2,
                 a~workcenterstandardworkqty2,
                 a~workcenterstandardworkqtyunit2,
                 a~opconfirmedworkquantity3 AS _op_confirmed_work_quantity3,
                 a~opworkquantityunit3 AS _op_work_quantity_unit3,
                 a~workcenterstandardworkqty3,
                 a~workcenterstandardworkqtyunit3,
                 a~opconfirmedworkquantity4 AS _op_confirmed_work_quantity4,
                 a~opworkquantityunit4 AS _op_work_quantity_unit4,
                 a~workcenterstandardworkqty4,
                 a~workcenterstandardworkqtyunit4,
                 a~opconfirmedworkquantity5 AS _op_confirmed_work_quantity5,
                 a~opworkquantityunit5 AS _op_work_quantity_unit5,
                 a~workcenterstandardworkqty5,
                 a~workcenterstandardworkqtyunit5,
                 a~opconfirmedworkquantity6 AS _op_confirmed_work_quantity6,
                 a~opworkquantityunit6 AS _op_work_quantity_unit6,
                 a~workcenterstandardworkqty6,
                 a~workcenterstandardworkqtyunit6
            FROM i_manufacturingorderoperation WITH PRIVILEGED ACCESS AS a "#EC CI_NO_TRANSFORM
            LEFT OUTER JOIN i_workcenter WITH PRIVILEGED ACCESS AS b
              ON b~workcenterinternalid = a~workcenterinternalid
             AND b~workcentertypecode = a~workcentertypecode_2
             FOR ALL ENTRIES IN @lt_manufacturingorder
           WHERE a~manufacturingorder = @lt_manufacturingorder-_manufacturing_order
            INTO TABLE @DATA(lt_manufacturingorderoperation).
        ENDIF.

        DATA(lv_lines) = lines( lt_manufacturingorder ).
        ls_res-_msgty = 'S'.

        "プラント&1製造指図连携成功 &2 件！
        MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 008 WITH lv_plant lv_lines INTO ls_res-_msg.
      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    SORT lt_manufacturingorder BY _manufacturing_order.
    SORT lt_enterpriseprojectelement_2 BY wbselementinternalid.
    SORT lt_mfgorderwithstatus BY _manufacturing_order.
    SORT lt_manufacturingorderitem BY _manufacturing_order.
    SORT lt_mfgorderoperationcomponent BY _manufacturing_order billofmaterialitemnumber_2.
    SORT lt_productplantbasic BY product plant.
    SORT lt_manufacturingorderoperation BY _manufacturing_order manufacturingorderoperation_2.

    lv_timestamp = cl_abap_context_info=>get_system_date( ) && cl_abap_context_info=>get_system_time( ).

    "Convert date and time from zero zone to time zone of plant
    CONVERT TIME STAMP lv_timestamp
            TIME ZONE ls_ztbc_1001-zonlo_out
            INTO DATE lv_date
                 TIME lv_time.

    "Read data of manufacturing order
    LOOP AT lt_manufacturingorder INTO DATA(ls_manufacturingorder).
      MOVE-CORRESPONDING ls_manufacturingorder TO ls_order.
      ls_order-_sent_time_stamp = lv_date && lv_time.

      lv_timestamp = ls_order-_creation_date && ls_order-_creation_time.

      "Convert date and time from zero zone to time zone of plant
      CONVERT TIME STAMP lv_timestamp
              TIME ZONE ls_ztbc_1001-zonlo_out
              INTO DATE ls_order-_creation_date
                   TIME ls_order-_creation_time.

      lv_timestamp = ls_order-_last_change_date && ls_order-_last_change_time.

      "Convert date and time from zero zone to time zone of plant
      CONVERT TIME STAMP lv_timestamp
              TIME ZONE ls_ztbc_1001-zonlo_out
              INTO DATE ls_order-_last_change_date
                   TIME ls_order-_last_change_time.

      "Read data of enterprise project element
      READ TABLE lt_enterpriseprojectelement_2 INTO DATA(ls_enterpriseprojectelement_2) WITH KEY wbselementinternalid = ls_manufacturingorder-wbselementinternalid_2
                                                                                        BINARY SEARCH.
      IF sy-subrc = 0.
        ls_order-_project_element = ls_enterpriseprojectelement_2-projectelement.
      ENDIF.

      "Read data of manufacturing order header with status
      READ TABLE lt_mfgorderwithstatus INTO DATA(ls_mfgorderwithstatus) WITH KEY _manufacturing_order = ls_manufacturingorder-_manufacturing_order
                                                                        BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_mfgorderwithstatus TO ls_order.
      ENDIF.

      "Read data of manufacturing order item
      READ TABLE lt_manufacturingorderitem INTO DATA(ls_manufacturingorderitem) WITH KEY _manufacturing_order = ls_manufacturingorder-_manufacturing_order
                                                                                BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_manufacturingorderitem TO ls_order.
      ENDIF.

      APPEND ls_order TO ls_res-_data-_order.
      CLEAR ls_order.

      "Read data of BOM
      READ TABLE lt_mfgorderoperationcomponent TRANSPORTING NO FIELDS WITH KEY _manufacturing_order = ls_manufacturingorder-_manufacturing_order
                                                                      BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_mfgorderoperationcomponent INTO DATA(ls_mfgorderoperationcomponent) FROM sy-tabix.
          IF ls_mfgorderoperationcomponent-_manufacturing_order <> ls_manufacturingorder-_manufacturing_order.
            EXIT.
          ENDIF.

          MOVE-CORRESPONDING ls_mfgorderoperationcomponent TO ls_bom.

          "Read data of product plant
          READ TABLE lt_productplantbasic INTO DATA(ls_productplantbasic) WITH KEY product = ls_mfgorderoperationcomponent-_material
                                                                                   plant = ls_mfgorderoperationcomponent-_plant
                                                                          BINARY SEARCH.
          IF sy-subrc = 0.
            ls_bom-_procurement_type_item = ls_productplantbasic-procurementtype.
          ENDIF.

          TRY.
              ls_bom-_base_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out iv_input = ls_bom-_base_unit ).
            CATCH zzcx_custom_exception INTO lo_root_exc ##NO_HANDLER.
          ENDTRY.

          APPEND ls_bom TO ls_res-_data-_bom.
          CLEAR ls_bom.
        ENDLOOP.
      ENDIF.

      "Read data of routing
      READ TABLE lt_manufacturingorderoperation TRANSPORTING NO FIELDS WITH KEY _manufacturing_order = ls_manufacturingorder-_manufacturing_order
                                                                       BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_manufacturingorderoperation INTO DATA(ls_manufacturingorderoperation) FROM sy-tabix.
          IF ls_manufacturingorderoperation-_manufacturing_order <> ls_manufacturingorder-_manufacturing_order.
            EXIT.
          ENDIF.

          MOVE-CORRESPONDING ls_manufacturingorderoperation TO ls_routing.
          TRY.
              ls_routing-_operation_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out iv_input = ls_routing-_operation_unit ).

              ls_routing-_op_work_quantity_unit1        = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-_op_work_quantity_unit1 ).
              ls_routing-_op_work_quantity_unit2        = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-_op_work_quantity_unit2 ).
              ls_routing-_op_work_quantity_unit3        = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-_op_work_quantity_unit3 ).
              ls_routing-_op_work_quantity_unit4        = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-_op_work_quantity_unit4 ).
              ls_routing-_op_work_quantity_unit5        = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-_op_work_quantity_unit5 ).
              ls_routing-_op_work_quantity_unit6        = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-_op_work_quantity_unit6 ).

              ls_routing-workcenterstandardworkqtyunit1 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-workcenterstandardworkqtyunit1 ).
              ls_routing-workcenterstandardworkqtyunit2 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-workcenterstandardworkqtyunit2 ).
              ls_routing-workcenterstandardworkqtyunit3 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-workcenterstandardworkqtyunit3 ).
              ls_routing-workcenterstandardworkqtyunit4 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-workcenterstandardworkqtyunit4 ).
              ls_routing-workcenterstandardworkqtyunit5 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-workcenterstandardworkqtyunit5 ).
              ls_routing-workcenterstandardworkqtyunit6 = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                               iv_input = ls_routing-workcenterstandardworkqtyunit6 ).
            CATCH zzcx_custom_exception INTO lo_root_exc ##NO_HANDLER.
          ENDTRY.
          APPEND ls_routing TO ls_res-_data-_routing.
          CLEAR ls_routing.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF 'orderistechnicallycompleted' IN lv_res_body WITH 'OrderIsTechnicallyCompleted'.
    REPLACE ALL OCCURRENCES OF 'orderisdistributionrelevant' IN lv_res_body WITH 'OrderIsDistributionRelevant'.
    REPLACE ALL OCCURRENCES OF 'orderhascostcalculationerror' IN lv_res_body WITH 'OrderHasCostCalculationError'.
    REPLACE ALL OCCURRENCES OF 'settlementruleiscrtedmanually' IN lv_res_body WITH 'SettlementRuleIsCrtedManually'.
    REPLACE ALL OCCURRENCES OF 'orderhasgeneratedoperations' IN lv_res_body WITH 'OrderHasGeneratedOperations'.
    REPLACE ALL OCCURRENCES OF 'orderistobehandledinbatches' IN lv_res_body WITH 'OrderIsToBeHandledInBatches'.
    REPLACE ALL OCCURRENCES OF 'materialavailyisnotchecked' IN lv_res_body WITH 'MaterialAvailyIsNotChecked'.
    REPLACE ALL OCCURRENCES OF 'billofmaterialvariantusage' IN lv_res_body WITH 'BillOfMaterialVariantUsage'.
    REPLACE ALL OCCURRENCES OF 'billofmaterialitemnumber2' IN lv_res_body WITH 'BillOfMaterialItemNumber_2'.
    REPLACE ALL OCCURRENCES OF 'manufacturingorderoperation2' IN lv_res_body WITH 'ManufacturingOrderOperation_2'.
    REPLACE ALL OCCURRENCES OF 'materialcompisalternativeitem' IN lv_res_body WITH 'MaterialCompIsAlternativeItem'.
    REPLACE ALL OCCURRENCES OF 'alternativemstrreservationitem' IN lv_res_body WITH 'AlternativeMstrReservationItem'.
    REPLACE ALL OCCURRENCES OF 'matlcompismarkedforbackflush' IN lv_res_body WITH 'MatlCompIsMarkedForBackflush'.
    REPLACE ALL OCCURRENCES OF 'matlcompismarkedfordeletion' IN lv_res_body WITH 'MatlCompIsMarkedForDeletion'.
    REPLACE ALL OCCURRENCES OF 'materialcomponentisphantomitem' IN lv_res_body WITH 'MaterialComponentIsPhantomItem'.
    REPLACE ALL OCCURRENCES OF 'matlcompdiscontinuationtype' IN lv_res_body WITH 'MatlCompDiscontinuationType'.
    REPLACE ALL OCCURRENCES OF 'matlcompisfollowupmaterial' IN lv_res_body WITH 'MatlCompIsFollowUpMaterial'.
    REPLACE ALL OCCURRENCES OF 'discontinuationmasterresvnitem' IN lv_res_body WITH 'DiscontinuationMasterResvnItem'.
    REPLACE ALL OCCURRENCES OF 'matlcomponentspareparttype' IN lv_res_body WITH 'MatlComponentSparePartType'.
    REPLACE ALL OCCURRENCES OF 'materialcomporiginalquantity' IN lv_res_body WITH 'MaterialCompOriginalQuantity'.
    REPLACE ALL OCCURRENCES OF 'manufacturingorderoperation2' IN lv_res_body WITH 'ManufacturingOrderOperation_2'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqty1' IN lv_res_body WITH 'WorkCenterStandardWorkQty1'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqtyunit1' IN lv_res_body WITH 'WorkCenterStandardWorkQtyUnit1'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqty2' IN lv_res_body WITH 'WorkCenterStandardWorkQty2'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqtyunit2' IN lv_res_body WITH 'WorkCenterStandardWorkQtyUnit2'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqty3' IN lv_res_body WITH 'WorkCenterStandardWorkQty3'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqtyunit3' IN lv_res_body WITH 'WorkCenterStandardWorkQtyUnit3'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqty4' IN lv_res_body WITH 'WorkCenterStandardWorkQty4'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqtyunit4' IN lv_res_body WITH 'WorkCenterStandardWorkQtyUnit4'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqty5' IN lv_res_body WITH 'WorkCenterStandardWorkQty5'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqtyunit5' IN lv_res_body WITH 'WorkCenterStandardWorkQtyUnit5'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqty6' IN lv_res_body WITH 'WorkCenterStandardWorkQty6'.
    REPLACE ALL OCCURRENCES OF 'workcenterstandardworkqtyunit6' IN lv_res_body WITH 'WorkCenterStandardWorkQtyUnit6'.

    "Set request data
    response->set_text( lv_res_body ).

*&--ADD BEGIN BY XINLEI XU 2025/02/08
    GET TIME STAMP FIELD DATA(lv_timestamp_end).
    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        DATA(lv_request_url) = |https://{ lv_system_url }/sap/bc/http/sap/z_http_mfgorder_001|.
        ##NO_HANDLER
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    DATA(lv_request_body) = xco_cp_json=>data->from_abap( ls_req )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    DATA(lv_count) = lines( ls_res-_data-_order ).

    zzcl_common_utils=>add_interface_log( EXPORTING iv_interface_id   = |IF026|
                                                    iv_interface_desc = |製造指図連携|
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
