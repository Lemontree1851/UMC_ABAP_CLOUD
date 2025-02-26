CLASS lhc_zr_mfgorderassignso DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES: BEGIN OF lty_messageitem,
             type        TYPE string,
             title       TYPE string,
             description TYPE string,
             subtitle    TYPE string,
           END OF lty_messageitem,
           BEGIN OF ty_salesorderlist,
             plant                       TYPE zc_mfgorderassignso-productionplant,
             manufacturing_order         TYPE zc_mfgorderassignso-manufacturingorder,
             requested_delivery_date     TYPE i_salesorderscheduleline-requesteddeliverydate,
             sales_order                 TYPE i_salesdocumentitem-salesdocument,
             sales_order_item            TYPE string,
             sales_order_item_i          TYPE i_salesdocumentitem-salesdocumentitem,
             material                    TYPE i_salesdocumentitem-material,
             requestedquantityinbaseunit TYPE i_salesdocumentitem-requestedquantityinbaseunit,
             purchase_order_by_customer  TYPE i_salesdocumentitem-purchaseorderbycustomer,
             sequence                    TYPE zc_mfgorderassignsoitem-sequence,
             assign_qty                  TYPE zc_mfgorderassignsoitem-assignqty,
             un_assign_qty               TYPE zc_mfgorderassignsoitem-assignqty,
             total_assign_qty            TYPE zc_mfgorderassignsoitem-totalassignqty,
             base_unit                   TYPE i_salesdocumentitem-baseunit,
           END OF ty_salesorderlist,
           BEGIN OF ty_request,
             production_plant             TYPE zc_mfgorderassignso-productionplant,
             manufacturing_order          TYPE zc_mfgorderassignso-manufacturingorder,
             m_r_p_controller             TYPE zc_mfgorderassignso-mrpcontroller,
             production_supervisor        TYPE zc_mfgorderassignso-productionsupervisor,
             material                     TYPE zc_mfgorderassignso-material,
             mfg_order_planned_start_date TYPE string,
             mfg_order_planned_total_qty  TYPE zc_mfgorderassignso-mfgorderplannedtotalqty,
             available_assign_qty         TYPE zc_mfgorderassignso-availableassignqty,
             items                        TYPE TABLE OF ty_salesorderlist WITH DEFAULT KEY,
             message_items                TYPE TABLE OF lty_messageitem WITH DEFAULT KEY,
           END OF ty_request.

    CONSTANTS: lc_type_e TYPE string VALUE `Error`,
               lc_type_s TYPE string VALUE `Success`.

    CONSTANTS: lc_event_change_qty TYPE string VALUE `ChangeAssignQty`,
               lc_event_change_mat TYPE string VALUE `ChangeAssignMaterial`.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_mfgorderassignso RESULT result.

    METHODS getsalesorderlist FOR MODIFY
      IMPORTING keys FOR ACTION zr_mfgorderassignso~getsalesorderlist RESULT result.
    METHODS saveassignsalesorder FOR MODIFY
      IMPORTING keys FOR ACTION zr_mfgorderassignso~saveassignsalesorder RESULT result.
    METHODS savechangerow FOR MODIFY
      IMPORTING keys FOR ACTION zr_mfgorderassignso~savechangerow RESULT result.
    METHODS savechangeassignsalesorder FOR MODIFY
      IMPORTING keys FOR ACTION zr_mfgorderassignso~savechangeassignsalesorder RESULT result.
    METHODS deletesoitem FOR MODIFY
      IMPORTING keys FOR ACTION zr_mfgorderassignso~deletesoitem RESULT result.

ENDCLASS.

CLASS lhc_zr_mfgorderassignso IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD getsalesorderlist.
    DATA: ls_request  TYPE ty_request,
          lt_response TYPE TABLE OF ty_salesorderlist.

    DATA: lr_plant TYPE RANGE OF i_plant-plant.

    CHECK keys IS NOT INITIAL.
    xco_cp_json=>data->from_string( keys[ 1 ]-%param-zzkey )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( ls_request ) ).

    IF ls_request-material IS NOT INITIAL.
      SELECT soitem~salesdocument AS sales_order,
             soitem~salesdocumentitem AS sales_order_item,
             soitem~salesdocumentitem AS sales_order_item_i,
             soitem~material,
             soitem~plant,
             soitem~requestedquantityinbaseunit,
             soitem~baseunit AS base_unit,
             soitem~purchaseorderbycustomer AS purchase_order_by_customer,
             scheduleline~requesteddeliverydate AS requested_delivery_date,
             sum~totalassignqty AS total_assign_qty,
             CASE WHEN sum~totalassignqty IS NOT NULL
                  THEN soitem~requestedquantityinbaseunit - sum~totalassignqty
                  ELSE soitem~requestedquantityinbaseunit
              END AS un_assign_qty
        FROM i_salesdocumentitem WITH PRIVILEGED ACCESS AS soitem
        JOIN i_salesorderscheduleline WITH PRIVILEGED ACCESS
                      AS scheduleline ON  scheduleline~salesorder = soitem~salesdocument
                                      AND scheduleline~salesorderitem = soitem~salesdocumentitem
                                      AND scheduleline~scheduleline = '0001'
        LEFT OUTER JOIN zr_mfgorderassignsoitem_sumso WITH PRIVILEGED ACCESS
                     AS sum ON  sum~salesorder = soitem~salesdocument
                            AND sum~salesorderitem = soitem~salesdocumentitem
       WHERE soitem~plant = @ls_request-production_plant
         AND soitem~material = @ls_request-material
         AND soitem~salesdocumentrjcnreason <> 'C'
         AND soitem~deliverystatus <> 'C'
        INTO CORRESPONDING FIELDS OF TABLE @lt_response.

*&--Authorization Check
      DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
      DATA(lv_plant) = zzcl_common_utils=>get_plant_by_user( lv_user_email ).
      IF lv_plant IS INITIAL.
        CLEAR lt_response.
      ELSE.
        SPLIT lv_plant AT '&' INTO TABLE DATA(lt_plant_check).
        CLEAR lr_plant.
        lr_plant = VALUE #( FOR plant IN lt_plant_check ( sign = 'I' option = 'EQ' low = plant ) ).
        DELETE lt_response WHERE plant NOT IN lr_plant.
      ENDIF.
*&--Authorization Check

      DELETE lt_response WHERE un_assign_qty IS INITIAL.
      SORT lt_response BY requested_delivery_date sales_order sales_order_item.

      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_response>).
        IF ls_request-available_assign_qty > <lfs_response>-un_assign_qty.
          <lfs_response>-assign_qty = <lfs_response>-un_assign_qty.
          ls_request-available_assign_qty -= <lfs_response>-un_assign_qty.
        ELSEIF ls_request-available_assign_qty > 0.
          <lfs_response>-assign_qty = ls_request-available_assign_qty.
          ls_request-available_assign_qty = 0.
        ENDIF.

        <lfs_response>-sales_order = |{ <lfs_response>-sales_order ALPHA = OUT }|.
        <lfs_response>-sales_order_item = |{ <lfs_response>-sales_order_item ALPHA = OUT }|.

        TRY.
            <lfs_response>-base_unit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_response>-base_unit ).
            ##NO_HANDLER
          CATCH zzcx_custom_exception.
            " handle exception
        ENDTRY.
      ENDLOOP.
    ENDIF.

    DATA(lv_json) = xco_cp_json=>data->from_abap( lt_response )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    REPLACE ALL OCCURRENCES OF `Requestedquantityinbaseunit` IN lv_json  WITH `RequestedQuantityInBaseUnit`.

    APPEND VALUE #( %cid   = keys[ 1 ]-%cid
                    %param = VALUE #( zzkey = lv_json ) ) TO result.
  ENDMETHOD.

  METHOD saveassignsalesorder.
    DATA: ls_request TYPE ty_request,
          lt_append  TYPE TABLE OF ztpp_1014.

    DATA: lv_timestamp  TYPE tzntstmpl,
          lv_sequence   TYPE ztpp_1014-sequence,
          lv_assign_qty TYPE ztpp_1014-assign_qty,
          lv_message    TYPE string.

    CHECK keys IS NOT INITIAL.
    xco_cp_json=>data->from_string( keys[ 1 ]-%param-zzkey )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( ls_request ) ).

    IF ls_request-items IS NOT INITIAL.
      DATA(lv_manufacturing_order) = |{ ls_request-manufacturing_order ALPHA = IN }|.

      SELECT SINGLE
             productionplant AS plant,
             manufacturingorder AS manufacturing_order,
             material,
             mrpcontroller AS m_r_p_controller,
             productionsupervisor AS production_supervisor,
             mfgorderplannedstartdate AS mfg_order_planned_start_date,
             mfgorderplannedtotalqty AS mfg_order_planned_total_qty,
             productionunit AS production_unit
        FROM i_manufacturingorderitem WITH PRIVILEGED ACCESS
       WHERE productionplant = @ls_request-production_plant
         AND manufacturingorder = @lv_manufacturing_order
        INTO @DATA(ls_order).

      LOOP AT ls_request-items ASSIGNING FIELD-SYMBOL(<lfs_item>).
        <lfs_item>-sales_order = |{ <lfs_item>-sales_order ALPHA = IN }|.
      ENDLOOP.

      SELECT MAX( sequence )
        FROM ztpp_1014
       WHERE plant = @ls_request-production_plant
         AND manufacturing_order = @lv_manufacturing_order
        INTO @lv_sequence.

      SELECT *
        FROM ztpp_1014
        FOR ALL ENTRIES IN @ls_request-items
       WHERE plant = @ls_request-production_plant
         AND manufacturing_order = @lv_manufacturing_order
         AND sales_order = @ls_request-items-sales_order
         AND sales_order_item = @ls_request-items-sales_order_item_i
        INTO TABLE @DATA(lt_update).

      SORT lt_update BY sales_order sales_order_item sequence DESCENDING.

      GET TIME STAMP FIELD lv_timestamp.
      LOOP AT ls_request-items INTO DATA(ls_item).
        CLEAR lv_assign_qty.
        lv_sequence += 1.

        READ TABLE lt_update ASSIGNING FIELD-SYMBOL(<lfs_update>)
                                  WITH KEY sales_order = ls_item-sales_order
                                           sales_order_item = ls_item-sales_order_item_i.
        IF sy-subrc = 0.
          lv_assign_qty = <lfs_update>-assign_qty.
          <lfs_update>-remark = |{ <lfs_update>-assign_qty }->0|.
          <lfs_update>-assign_qty = 0.
          <lfs_update>-last_changed_at = lv_timestamp.
          <lfs_update>-last_changed_by = sy-uname.
          <lfs_update>-local_last_changed_at = lv_timestamp.
        ENDIF.

        APPEND INITIAL LINE TO lt_append ASSIGNING FIELD-SYMBOL(<lfs_append>).
        <lfs_append> = CORRESPONDING #( ls_order ).
        <lfs_append>-sales_order = |{ ls_item-sales_order ALPHA = IN }|.
        <lfs_append>-sales_order_item = ls_item-sales_order_item_i.
        <lfs_append>-sequence    = lv_sequence.
        <lfs_append>-assign_qty  = ls_item-assign_qty + lv_assign_qty.
        <lfs_append>-created_at  = lv_timestamp.
        <lfs_append>-created_by  = sy-uname.
        <lfs_append>-last_changed_at = lv_timestamp.
        <lfs_append>-last_changed_by = sy-uname.
        <lfs_append>-local_last_changed_at = lv_timestamp.
      ENDLOOP.

      APPEND LINES OF lt_append TO lt_update.

      MODIFY ztpp_1014 FROM TABLE @lt_update.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE if_abap_behv_message=>severity-success NUMBER sy-msgno
           INTO lv_message
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        APPEND VALUE #( type        = lc_type_e
                        title       = TEXT-001
                        subtitle    = lv_message
                        description = lv_message ) TO ls_request-message_items.
      ENDIF.
    ENDIF.

    DATA(lv_json) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    APPEND VALUE #( %cid   = keys[ 1 ]-%cid
                    %param = VALUE #( zzkey = lv_json ) ) TO result.
  ENDMETHOD.

  METHOD savechangerow.
    DATA: ls_request TYPE ty_request,
          lt_update  TYPE TABLE OF ztpp_1014.

    DATA: lv_sales_order_item TYPE zc_mfgorderassignso-salesorderitem,
          lv_timestamp        TYPE tzntstmpl,
          lv_sequence         TYPE ztpp_1014-sequence,
          lv_message          TYPE string.

    CHECK keys IS NOT INITIAL.
    xco_cp_json=>data->from_string( keys[ 1 ]-%param-zzkey )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( ls_request ) ).

    DATA(lv_event) = keys[ 1 ]-%param-event.

    " only single data
    READ TABLE ls_request-items INTO DATA(ls_item) INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_manufacturing_order) = |{ ls_item-manufacturing_order ALPHA = IN }|.
      DATA(lv_sales_order) = |{ ls_item-sales_order ALPHA = IN }|.
      lv_sales_order_item = |{ ls_item-sales_order_item ALPHA = IN }|.

      IF lv_event = lc_event_change_mat.
        DATA(lv_material) = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = ls_item-material ).
        SELECT SINGLE product,
                      plant
          FROM i_productplantbasic
          WITH PRIVILEGED ACCESS
         WHERE product = @lv_material
           AND plant   = @ls_item-plant
          INTO @DATA(ls_productplantbasic).
        IF sy-subrc <> 0.
          MESSAGE e030(zpp_001) WITH ls_item-material ls_item-plant INTO lv_message.
          APPEND VALUE #( type        = lc_type_e
                          title       = TEXT-001
                          subtitle    = lv_message
                          description = lv_message ) TO ls_request-message_items.
        ELSE.
          SELECT SINGLE
                 productionplant AS plant,
                 manufacturingorder AS manufacturing_order,
                 material,
                 mrpcontroller AS m_r_p_controller,
                 productionsupervisor AS production_supervisor,
                 mfgorderplannedstartdate AS mfg_order_planned_start_date,
                 mfgorderplannedtotalqty AS mfg_order_planned_total_qty,
                 productionunit AS production_unit
            FROM i_manufacturingorderitem WITH PRIVILEGED ACCESS
           WHERE productionplant = @ls_item-plant
             AND manufacturingorder = @lv_manufacturing_order
            INTO @DATA(ls_order).

          SELECT MAX( sequence )
            FROM ztpp_1014
           WHERE plant = @ls_item-plant
             AND manufacturing_order = @lv_manufacturing_order
            INTO @lv_sequence.

          SELECT *
            FROM ztpp_1014
           WHERE plant = @ls_item-plant
             AND manufacturing_order = @lv_manufacturing_order
             AND sequence = @ls_item-sequence
            INTO TABLE @DATA(lt_exist_data).

          SORT lt_exist_data BY sequence DESCENDING.

          GET TIME STAMP FIELD lv_timestamp.
          " Read the line with the largest sequence
          READ TABLE lt_exist_data ASSIGNING FIELD-SYMBOL(<lfs_exist_data>) INDEX 1.
          IF sy-subrc = 0.
            <lfs_exist_data>-remark = |{ <lfs_exist_data>-assign_qty }->0|.
            <lfs_exist_data>-assign_qty = 0.
            <lfs_exist_data>-last_changed_at = lv_timestamp.
            <lfs_exist_data>-last_changed_by = sy-uname.
            <lfs_exist_data>-local_last_changed_at = lv_timestamp.
            APPEND <lfs_exist_data> TO lt_update.
          ENDIF.

          lv_sequence += 1.

          " new line
          APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<lfs_update>).
          <lfs_update> = CORRESPONDING #( ls_order ).
          <lfs_update>-sales_order = lv_sales_order.
          <lfs_update>-sales_order_item = lv_sales_order_item.
          <lfs_update>-sequence    = lv_sequence.
          <lfs_update>-assign_qty  = ls_item-assign_qty.
          <lfs_update>-material    = ls_item-material.
          <lfs_update>-created_at  = lv_timestamp.
          <lfs_update>-created_by  = sy-uname.
          <lfs_update>-last_changed_at = lv_timestamp.
          <lfs_update>-last_changed_by = sy-uname.
          <lfs_update>-local_last_changed_at = lv_timestamp.

          MODIFY ztpp_1014 FROM TABLE @lt_update.
        ENDIF.
      ELSEIF lv_event = lc_event_change_qty.
        GET TIME STAMP FIELD lv_timestamp.
        UPDATE ztpp_1014 SET assign_qty = @ls_item-assign_qty,
                             last_changed_at = @lv_timestamp,
                             last_changed_by = @sy-uname,
                             local_last_changed_at = @lv_timestamp
         WHERE plant = @ls_item-plant
           AND manufacturing_order = @lv_manufacturing_order
           AND sales_order = @lv_sales_order
           AND sales_order_item = @lv_sales_order_item
           AND sequence = @ls_item-sequence.
      ENDIF.
      IF sy-subrc <> 0 AND ls_request-message_items IS INITIAL.
        MESSAGE ID sy-msgid TYPE if_abap_behv_message=>severity-success NUMBER sy-msgno
           INTO lv_message
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        APPEND VALUE #( type        = lc_type_e
                        title       = TEXT-001
                        subtitle    = lv_message
                        description = lv_message ) TO ls_request-message_items.
      ENDIF.
    ENDIF.

    DATA(lv_json) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    APPEND VALUE #( %cid   = keys[ 1 ]-%cid
                    %param = VALUE #( zzkey = lv_json ) ) TO result.
  ENDMETHOD.

  METHOD savechangeassignsalesorder.
    DATA: ls_request TYPE ty_request,
          lt_update  TYPE TABLE OF ztpp_1014.

    DATA: lv_timestamp  TYPE tzntstmpl,
          lv_sequence   TYPE ztpp_1014-sequence,
          lv_assign_qty TYPE ztpp_1014-assign_qty,
          lv_message    TYPE string.

    CHECK keys IS NOT INITIAL.
    xco_cp_json=>data->from_string( keys[ 1 ]-%param-zzkey )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( ls_request ) ).

    " The first line is the line to be split
    READ TABLE ls_request-items INTO DATA(ls_item) INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_manufacturing_order) = |{ ls_item-manufacturing_order ALPHA = IN }|.
      DATA(lv_sales_order) = |{ ls_item-sales_order ALPHA = IN }|.

      SELECT SINGLE
             productionplant AS plant,
             manufacturingorder AS manufacturing_order,
             material,
             mrpcontroller AS m_r_p_controller,
             productionsupervisor AS production_supervisor,
             mfgorderplannedstartdate AS mfg_order_planned_start_date,
             mfgorderplannedtotalqty AS mfg_order_planned_total_qty,
             productionunit AS production_unit
        FROM i_manufacturingorderitem WITH PRIVILEGED ACCESS
       WHERE productionplant = @ls_item-plant
         AND manufacturingorder = @lv_manufacturing_order
        INTO @DATA(ls_order).

      LOOP AT ls_request-items ASSIGNING FIELD-SYMBOL(<lfs_item>).
        <lfs_item>-sales_order = |{ <lfs_item>-sales_order ALPHA = IN }|.
      ENDLOOP.

      SELECT MAX( sequence )
        FROM ztpp_1014
       WHERE plant = @ls_item-plant
         AND manufacturing_order = @lv_manufacturing_order
        INTO @lv_sequence.

      SELECT *
        FROM ztpp_1014
         FOR ALL ENTRIES IN @ls_request-items
       WHERE plant = @ls_item-plant
         AND manufacturing_order = @lv_manufacturing_order
         AND sales_order = @ls_request-items-sales_order
         AND sales_order_item = @ls_request-items-sales_order_item_i
        INTO TABLE @DATA(lt_exist_data).

      SORT lt_exist_data BY sales_order sales_order_item sequence.

      GET TIME STAMP FIELD lv_timestamp.
      LOOP AT ls_request-items INTO ls_item.
        CLEAR lv_assign_qty.

        " The first line is the line to be split
        READ TABLE lt_exist_data ASSIGNING FIELD-SYMBOL(<lfs_exist_data>)
                                  WITH KEY sales_order = ls_item-sales_order
                                           sales_order_item = ls_item-sales_order_item
                                           sequence = ls_item-sequence BINARY SEARCH.
        IF sy-subrc = 0.
          lv_assign_qty = <lfs_exist_data>-assign_qty.
          IF <lfs_exist_data>-remark IS INITIAL.
            <lfs_exist_data>-remark = |{ <lfs_exist_data>-assign_qty }->0|.
            <lfs_exist_data>-assign_qty = 0.
            <lfs_exist_data>-last_changed_at = lv_timestamp.
            <lfs_exist_data>-last_changed_by = sy-uname.
            <lfs_exist_data>-local_last_changed_at = lv_timestamp.
            APPEND <lfs_exist_data> TO lt_update.
          ENDIF.
        ENDIF.

        " append new line
        IF ls_item-sequence IS INITIAL.
          lv_sequence += 1.
          APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<lfs_update>).
          <lfs_update> = CORRESPONDING #( ls_order ).
          <lfs_update>-sales_order = ls_item-sales_order.
          <lfs_update>-sales_order_item = ls_item-sales_order_item_i.
          <lfs_update>-material    = ls_item-material.
          <lfs_update>-sequence    = lv_sequence.
          <lfs_update>-assign_qty  = ls_item-assign_qty + lv_assign_qty.
          <lfs_update>-created_at  = lv_timestamp.
          <lfs_update>-created_by  = sy-uname.
          <lfs_update>-last_changed_at = lv_timestamp.
          <lfs_update>-last_changed_by = sy-uname.
          <lfs_update>-local_last_changed_at = lv_timestamp.
        ENDIF.
      ENDLOOP.

      MODIFY ztpp_1014 FROM TABLE @lt_update.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE if_abap_behv_message=>severity-success NUMBER sy-msgno
           INTO lv_message
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        APPEND VALUE #( type        = lc_type_e
                        title       = TEXT-001
                        subtitle    = lv_message
                        description = lv_message ) TO ls_request-message_items.
      ENDIF.
    ENDIF.

    DATA(lv_json) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    APPEND VALUE #( %cid   = keys[ 1 ]-%cid
                    %param = VALUE #( zzkey = lv_json ) ) TO result.
  ENDMETHOD.

  METHOD deletesoitem.
    DATA: ls_request TYPE ty_request.
    DATA: lv_sales_order_item TYPE zc_mfgorderassignso-salesorderitem,
          lv_message          TYPE string.

    CHECK keys IS NOT INITIAL.
    xco_cp_json=>data->from_string( keys[ 1 ]-%param-zzkey )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( ls_request ) ).

    " only single data
    READ TABLE ls_request-items INTO DATA(ls_item) INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_manufacturing_order) = |{ ls_item-manufacturing_order ALPHA = IN }|.
      DATA(lv_sales_order) = |{ ls_item-sales_order ALPHA = IN }|.
      lv_sales_order_item = |{ ls_item-sales_order_item ALPHA = IN }|.

      DELETE FROM ztpp_1014 WHERE plant = @ls_item-plant
                              AND manufacturing_order = @lv_manufacturing_order
                              AND sales_order = @lv_sales_order
                              AND sales_order_item = @lv_sales_order_item
                              AND sequence = @ls_item-sequence.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE if_abap_behv_message=>severity-success NUMBER sy-msgno
           INTO lv_message
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        APPEND VALUE #( type        = lc_type_e
                        title       = TEXT-001
                        subtitle    = lv_message
                        description = lv_message ) TO ls_request-message_items.
      ENDIF.
    ENDIF.

    DATA(lv_json) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    APPEND VALUE #( %cid   = keys[ 1 ]-%cid
                    %param = VALUE #( zzkey = lv_json ) ) TO result.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_zr_mfgorderassignso DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_mfgorderassignso IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
