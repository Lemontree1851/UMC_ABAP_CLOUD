CLASS lsc_zr_materialrequisition DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zr_materialrequisition IMPLEMENTATION.
  METHOD save_modified.

*    IF zbp_r_materialrequisition=>mapped_material_document IS NOT INITIAL.
*      DATA lv_timestamp TYPE tzntstmpl.
*      GET TIME STAMP FIELD lv_timestamp.
*
*      LOOP AT zbp_r_materialrequisition=>mapped_material_document-materialdocumentitem ASSIGNING FIELD-SYMBOL(<keys_item>).
*        CONVERT KEY OF i_materialdocumentitemtp FROM <keys_item>-%pid TO <keys_item>-%key.
*      ENDLOOP.
*    ENDIF.

  ENDMETHOD.
ENDCLASS.

CLASS lhc_materialrequisition DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_messageitem,
            type        TYPE string,
            title       TYPE string,
            description TYPE string,
            subtitle    TYPE string,
          END OF lty_messageitem.
    TYPES: BEGIN OF lty_header,
             cost_center_name        TYPE i_costcentertext-costcentername,
             customer_name           TYPE i_customer-customername,
             local_last_changed_at_s TYPE string.
             INCLUDE                 TYPE ztpp_1009.
    TYPES: END OF lty_header.
    TYPES: BEGIN OF lty_item,
             material_description    TYPE i_productdescription-productdescription,
             storage_location_name   TYPE i_storagelocation-storagelocationname,
             standard_price          TYPE i_productvaluationbasic-standardprice,
             currency                TYPE i_productvaluationbasic-currency,
             order_is_closed         TYPE i_mfgorderwithstatus-orderisclosed,
             local_last_changed_at_s TYPE string,
             recorduuid              TYPE sysuuid_c36.
             INCLUDE                 TYPE ztpp_1010.
    TYPES: END OF lty_item.
    TYPES:BEGIN OF lty_request,
            header       TYPE lty_header,
            items        TYPE TABLE OF lty_item WITH DEFAULT KEY,
            user         TYPE string,
            username     TYPE string,
            datetime     TYPE string,
            messageitems TYPE TABLE OF lty_messageitem WITH DEFAULT KEY,
          END OF lty_request.

    TYPES:BEGIN OF lty_document_item,
            goods_movement_type         TYPE i_materialdocumentitem_2-goodsmovementtype,
            plant                       TYPE i_materialdocumentitem_2-plant,
            material                    TYPE i_materialdocumentitem_2-material,
            storage_location            TYPE i_materialdocumentitem_2-storagelocation,
            quantity_in_entry_unit      TYPE string,
            entry_unit                  TYPE string,
            cost_center                 TYPE i_materialdocumentitem_2-costcenter,
            manufacturing_order         TYPE i_materialdocumentitem_2-manufacturingorder,
            material_document_item_text TYPE i_materialdocumentitem_2-materialdocumentitemtext,
          END OF lty_document_item,
          BEGIN OF lty_document,
            material_document_year    TYPE i_materialdocumentheader_2-materialdocumentyear,
            material_document         TYPE i_materialdocumentheader_2-materialdocument,
            goods_movement_code       TYPE i_goodsmovementcode-goodsmovementcode,
            posting_date              TYPE string,
            document_date             TYPE string,
            to_material_document_item TYPE TABLE OF lty_document_item WITH DEFAULT KEY,
          END OF lty_document,
          BEGIN OF lty_response,
            d TYPE lty_document,
          END OF lty_response.

    CONSTANTS: lc_type_e TYPE string VALUE `Error`,
               lc_type_s TYPE string VALUE `Success`,
               lc_type_w TYPE string VALUE `Warning`.

    CONSTANTS: lc_mode_insert TYPE string VALUE `I`,
               lc_mode_update TYPE string VALUE `U`.

    CONSTANTS: lc_application_type_im TYPE ztpp_1009-type   VALUE `31`,
               lc_nr_object_mr        TYPE ztbc_1002-object VALUE `MRNUM`,
               lc_nr_object_im        TYPE ztbc_1002-object VALUE `IMNUM`,
               lc_template_id         TYPE zzt_prt_template-template_id VALUE `YY1_MRPRINT`,
               lc_posting             TYPE c VALUE `P`,
               lc_posting_cancel      TYPE c VALUE `C`,
               lc_config_zpp001       TYPE ztbc_1001-zid VALUE `ZPP001`,
               lc_config_zpp005       TYPE ztbc_1001-zid VALUE `ZPP005`,
               lc_config_zpp010       TYPE ztbc_1001-zid VALUE `ZPP010`.

    CONSTANTS: lc_prefix_mr(2) TYPE c VALUE `MR`,
               lc_prefix_im(2) TYPE c VALUE `IM`.

    CONSTANTS: lc_movementtype_201 TYPE bwart VALUE `201`,
               lc_movementtype_261 TYPE bwart VALUE `261`,
               lc_movementtype_551 TYPE bwart VALUE `551`.

    CONSTANTS: lc_event_query          TYPE string VALUE `QUERY`,
               lc_event_save           TYPE string VALUE `SAVE`,
               lc_event_delete         TYPE string VALUE `DELETE`,
               lc_event_resent         TYPE string VALUE `RESENT`,
               lc_event_print          TYPE string VALUE `PRINT`,
               lc_event_approval       TYPE string VALUE `APPROVAL`,
               lc_event_cancelapproval TYPE string VALUE `CANCELAPPROVAL`,
               lc_event_posting        TYPE string VALUE `POSTING`,
               lc_event_cancelposting  TYPE string VALUE `CANCELPOSTING`.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR materialrequisition RESULT result.

*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE materialrequisition.
*
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE materialrequisition.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE materialrequisition.
*
*    METHODS read FOR READ
*      IMPORTING keys FOR READ materialrequisition RESULT result.
*
*    METHODS lock FOR LOCK
*      IMPORTING keys FOR LOCK materialrequisition.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION materialrequisition~processlogic RESULT result.

    METHODS query CHANGING cs_data TYPE lty_request.
    METHODS save CHANGING cs_data TYPE lty_request.
    METHODS zdelete CHANGING cs_data TYPE lty_request.
    METHODS resent CHANGING cs_data TYPE lty_request.
    METHODS print CHANGING cs_data TYPE lty_request.

    METHODS approval
      IMPORTING iv_model TYPE string
      CHANGING  cs_data  TYPE lty_request.
    METHODS posting
      IMPORTING iv_model TYPE string
      CHANGING  cs_data  TYPE lty_request.

    METHODS get_providedkeys IMPORTING iv_value               TYPE ztpp_1009-material_requisition_no
                             RETURNING VALUE(rv_providedkeys) TYPE zzt_prt_record-provided_keys.

    METHODS sendemail IMPORTING iv_materialrequisitionno TYPE ztpp_1009-material_requisition_no
                                iv_content               TYPE xstring
                                iv_datetime              TYPE string
                      RETURNING VALUE(rv_error_text)     TYPE string.
ENDCLASS.

CLASS lhc_materialrequisition IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD create.
*  ENDMETHOD.
*
*  METHOD update.
*  ENDMETHOD.
*
*  METHOD delete.
**********************************************************************
* Deprecated, requires BTP user information
**********************************************************************
*    DATA: lv_message   TYPE string,
*          lv_timestamp TYPE tzntstmpl,
*          lv_itemno    TYPE i.
*
*    READ ENTITIES OF zr_materialrequisition IN LOCAL MODE
*    ENTITY materialrequisition
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT FINAL(lt_result).
*
*    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
*      CLEAR lv_message.
*      lv_itemno = <lfs_result>-itemno.
*
*      " check header and item status
*      IF <lfs_result>-mrstatus = abap_on.
*        MESSAGE e062(zpp_001) WITH |{ <lfs_result>-materialrequisitionno }({ lv_itemno })| INTO lv_message.
*      ELSEIF <lfs_result>-itemdeleteflag IS NOT INITIAL.
*        MESSAGE e063(zpp_001) WITH |{ <lfs_result>-materialrequisitionno }({ lv_itemno })| INTO lv_message.
*      ENDIF.
*
*      IF lv_message IS NOT INITIAL.
*        INSERT VALUE #( materialrequisitionno = <lfs_result>-materialrequisitionno
*                        itemno                = <lfs_result>-itemno ) INTO TABLE failed-materialrequisition.
*
*        INSERT VALUE #( materialrequisitionno = <lfs_result>-materialrequisitionno
*                        itemno                = <lfs_result>-itemno
*                        %msg = new_message_with_text( text = lv_message ) ) INTO TABLE reported-materialrequisition.
*      ENDIF.
*    ENDLOOP.
*
*    IF failed-materialrequisition IS INITIAL.
*      LOOP AT lt_result ASSIGNING <lfs_result>.
*        GET TIME STAMP FIELD lv_timestamp.
*        UPDATE ztpp_1010
*           SET delete_flag = abap_on,
*               local_last_changed_at = @lv_timestamp
*         WHERE material_requisition_no = @<lfs_result>-materialrequisitionno
*           AND item_no = @<lfs_result>-itemno.
*        IF sy-subrc = 0.
*          SELECT COUNT(*)
*            FROM ztpp_1010
*           WHERE material_requisition_no = @<lfs_result>-materialrequisitionno
*             AND item_no = @<lfs_result>-itemno
*             AND delete_flag IS INITIAL.
*          IF sy-subrc <> 0.
*            " The all items have all been deleted
*            UPDATE ztpp_1009
*               SET delete_flag = abap_on,
*                   local_last_changed_at = @lv_timestamp
*             WHERE material_requisition_no = @<lfs_result>-materialrequisitionno.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD read.
*    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>) GROUP BY <lfs_key>-%tky.
*      SELECT SINGLE *
*        FROM zc_materialrequisition
*       WHERE materialrequisitionno = @<lfs_key>-materialrequisitionno
*         AND itemno = @<lfs_key>-itemno
*        INTO @DATA(ls_data).
*
*      IF sy-subrc = 0.
*        INSERT CORRESPONDING #( ls_data ) INTO TABLE result.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD lock.
*  ENDMETHOD.

  METHOD processlogic.
    DATA: ls_request TYPE lty_request.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR ls_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                           pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                 CHANGING  data = ls_request ).

      CASE lv_event.
        WHEN lc_event_query.
          query( CHANGING cs_data = ls_request ).
        WHEN lc_event_save.
          save( CHANGING cs_data = ls_request ).
        WHEN lc_event_delete.
          zdelete( CHANGING cs_data = ls_request ).
        WHEN lc_event_resent.
          resent( CHANGING cs_data = ls_request ).
        WHEN lc_event_print.
          print( CHANGING cs_data = ls_request ).
        WHEN lc_event_approval.
          approval( EXPORTING iv_model = lc_event_approval CHANGING cs_data = ls_request ).
        WHEN lc_event_cancelapproval.
          approval( EXPORTING iv_model = lc_event_cancelapproval CHANGING cs_data = ls_request ).
        WHEN lc_event_posting.
          posting( EXPORTING iv_model = lc_event_posting CHANGING cs_data = ls_request ).
        WHEN lc_event_cancelposting.
          posting( EXPORTING iv_model = lc_event_cancelposting CHANGING cs_data = ls_request ).
        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD query.
    DATA lv_message TYPE string.

    SELECT SINGLE *
      FROM ztpp_1009
     WHERE material_requisition_no = @cs_data-header-material_requisition_no
      INTO @DATA(ls_header).

    IF ls_header-m_r_status = abap_on.
      MESSAGE e062(zpp_001) WITH ls_header-material_requisition_no INTO lv_message.
    ELSEIF ls_header-delete_flag IS NOT INITIAL.
      MESSAGE e063(zpp_001) WITH ls_header-material_requisition_no INTO lv_message.
    ENDIF.

    IF lv_message IS NOT INITIAL.
      APPEND VALUE #( type        = lc_type_e
                      title       = TEXT-001
                      subtitle    = lv_message
                      description = lv_message ) TO cs_data-messageitems.
      RETURN.
    ENDIF.

    cs_data-header = CORRESPONDING #( ls_header ).
    cs_data-header-local_last_changed_at_s = cs_data-header-local_last_changed_at.

    SELECT SINGLE customername
      FROM i_customer_vh
     WHERE customer = @cs_data-header-customer
      INTO @cs_data-header-customer_name.

    SELECT SINGLE costcentername
      FROM zc_costcentervh
     WHERE costcenter = @cs_data-header-cost_center
      INTO @cs_data-header-cost_center_name.

    " conversion output
    cs_data-header-customer    = |{ cs_data-header-customer ALPHA = OUT }|.
    cs_data-header-cost_center = |{ cs_data-header-cost_center ALPHA = OUT }|.

    SELECT *
      FROM ztpp_1010
     WHERE material_requisition_no = @cs_data-header-material_requisition_no
       AND delete_flag IS INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @cs_data-items.
    IF sy-subrc = 0.
      SELECT storagelocation,
             storagelocationname
        FROM i_storagelocation
        WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @cs_data-items
       WHERE storagelocation = @cs_data-items-storage_location
        INTO TABLE @DATA(lt_storagelocation).
      SORT lt_storagelocation BY storagelocation.

      SELECT manufacturingorder,
             item,
             material,
             materialdescription,
             standardprice,
             currency,
             orderisclosed
        FROM zc_manufacturingorderproductvh
        WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @cs_data-items
       WHERE manufacturingorder = @cs_data-items-manufacturing_order
         AND material = @cs_data-items-material
        INTO TABLE @DATA(lt_order).
      SORT lt_order BY manufacturingorder material.

      LOOP AT cs_data-items ASSIGNING FIELD-SYMBOL(<lfs_item>).
        READ TABLE lt_storagelocation INTO DATA(ls_storagelocation) WITH KEY storagelocation = <lfs_item>-storage_location
                                                                    BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_item>-storage_location_name = ls_storagelocation-storagelocationname.
        ENDIF.

        READ TABLE lt_order INTO DATA(ls_order) WITH KEY manufacturingorder = <lfs_item>-manufacturing_order
                                                         material = <lfs_item>-material BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_item>-material_description = ls_order-materialdescription.
          <lfs_item>-standard_price = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                            iv_currency = ls_order-currency
                                                                            iv_input = ls_order-standardprice ).
          <lfs_item>-currency = ls_order-currency.
          <lfs_item>-order_is_closed = ls_order-orderisclosed.
        ENDIF.
        <lfs_item>-local_last_changed_at_s = <lfs_item>-local_last_changed_at.
        " conversion output
        <lfs_item>-manufacturing_order = |{ <lfs_item>-manufacturing_order ALPHA = OUT }|.
        <lfs_item>-product  = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_item>-product ).
        <lfs_item>-material = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_item>-material ).
        TRY.
            <lfs_item>-base_unit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_item>-base_unit ).
            ##NO_HANDLER
          CATCH zzcx_custom_exception.
            " handle exception
        ENDTRY.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD save.
    DATA: ls_header TYPE ztpp_1009,
          lt_items  TYPE TABLE OF ztpp_1010.

    DATA: lv_mode(1)        TYPE c,
          lv_message        TYPE string,
          lv_timestamp      TYPE tzntstmpl,
          lv_requisition_no TYPE ztpp_1009-material_requisition_no,
          lv_timezone       TYPE tznzone.

    IF cs_data-header-material_requisition_no IS INITIAL.
      " Insert
      lv_mode = lc_mode_insert.

      " UTC+8 UTC+9
      SELECT SINGLE zvalue4
        FROM zc_tbc1001
       WHERE zid = @lc_config_zpp005
         AND zvalue1 = @cs_data-header-plant
        INTO @lv_timezone.
      IF sy-subrc = 0.
        lv_timestamp = cs_data-datetime.
        CONVERT TIME STAMP lv_timestamp
                TIME ZONE lv_timezone
                INTO DATE DATA(lv_date) TIME DATA(lv_time).
      ENDIF.

      " Generate Material Requisition No
      TRY.
          DATA(lv_nr_number) = zzcl_common_utils=>get_number_next(
                                      iv_object = COND #( WHEN cs_data-header-type = lc_application_type_im
                                                          THEN lc_nr_object_im
                                                          ELSE lc_nr_object_mr )
                                      iv_datum  = lv_date
                                      iv_nrlen  = 4 ).
        CATCH zzcx_custom_exception INTO DATA(lx_custom_exception).
          " handle exception
          DATA(lv_error_text) = lx_custom_exception->get_longtext( ).
          cs_data-messageitems = VALUE #( ( type        = lc_type_e
                                            title       = TEXT-001
                                            subtitle    = lv_error_text
                                            description = lv_error_text ) ).
          RETURN.
      ENDTRY.

      " type = 31
      IF cs_data-header-type = lc_application_type_im.
        lv_requisition_no = |{ lc_prefix_im }{ lv_nr_number }|.
      ELSE.
        lv_requisition_no = |{ lc_prefix_mr }{ lv_nr_number }|.
      ENDIF.

      cs_data-header-material_requisition_no = lv_requisition_no.
      GET TIME STAMP FIELD lv_timestamp.

      ls_header = CORRESPONDING #( cs_data-header ).
      lt_items  = CORRESPONDING #( cs_data-items  ).

      IF NOT line_exists( lt_items[ delete_flag = '' ] ).
        DATA(lv_delete_flag) = abap_on.
      ELSE.
        lv_delete_flag = abap_off.
      ENDIF.

      ls_header = VALUE #( BASE ls_header
                           customer                  = |{ ls_header-customer ALPHA = IN }|
                           delete_flag               = lv_delete_flag
                           created_date              = cs_data-datetime+0(8)
                           created_time              = cs_data-datetime+8(6)
                           created_by_user           = cs_data-user
                           created_by_user_name      = cs_data-username
                           last_changed_date         = cs_data-datetime+0(8)
                           last_changed_time         = cs_data-datetime+8(6)
                           last_changed_by_user      = cs_data-user
                           last_changed_by_user_name = cs_data-username
                           local_last_changed_at     = lv_timestamp ).

      LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<lfs_item>).
        <lfs_item>-material_requisition_no   = lv_requisition_no.
        <lfs_item>-manufacturing_order       = |{ <lfs_item>-manufacturing_order ALPHA = IN }|.
        <lfs_item>-product                   = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_item>-product ).
        <lfs_item>-material                  = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_item>-material ).
        <lfs_item>-created_date              = cs_data-datetime+0(8).
        <lfs_item>-created_time              = cs_data-datetime+8(6).
        <lfs_item>-created_by_user           = cs_data-user.
        <lfs_item>-created_by_user_name      = cs_data-username.
        <lfs_item>-last_changed_date         = cs_data-datetime+0(8).
        <lfs_item>-last_changed_time         = cs_data-datetime+8(6).
        <lfs_item>-last_changed_by_user      = cs_data-user.
        <lfs_item>-last_changed_by_user_name = cs_data-username.
        <lfs_item>-local_last_changed_at     = lv_timestamp.
        TRY.
            <lfs_item>-base_unit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_item>-base_unit ).
            ##NO_HANDLER
          CATCH zzcx_custom_exception.
            " handle exception
        ENDTRY.
      ENDLOOP.
    ELSE.
      " Update
      lv_mode = lc_mode_update.
      lv_requisition_no = cs_data-header-material_requisition_no.

      SELECT SINGLE *
        FROM ztpp_1009
       WHERE material_requisition_no = @lv_requisition_no
        INTO @DATA(ls_db_header).

      IF cs_data-header-local_last_changed_at_s <> ls_db_header-local_last_changed_at.
        MESSAGE e060(zpp_001) INTO lv_message.
        cs_data-messageitems = VALUE #( ( type        = lc_type_e
                                          title       = TEXT-001
                                          subtitle    = lv_message
                                          description = lv_message ) ).
      ELSE.
        GET TIME STAMP FIELD lv_timestamp.
        ls_header = CORRESPONDING #( ls_db_header ).
        lt_items  = CORRESPONDING #( cs_data-items ).

        IF NOT line_exists( lt_items[ delete_flag = '' ] ).
          lv_delete_flag = abap_on.
        ELSE.
          lv_delete_flag = abap_off.
        ENDIF.

        ls_header = VALUE #( BASE ls_header
                                  customer                  = |{ cs_data-header-customer ALPHA = IN }|
                                  cost_center               = |{ cs_data-header-cost_center ALPHA = IN }|
                                  receiver                  = cs_data-header-receiver
                                  requisition_date          = cs_data-header-requisition_date
                                  line_warehouse_status     = cs_data-header-line_warehouse_status
                                  delete_flag               = lv_delete_flag
                                  last_changed_date         = cs_data-datetime+0(8)
                                  last_changed_time         = cs_data-datetime+8(6)
                                  last_changed_by_user      = cs_data-user
                                  last_changed_by_user_name = cs_data-username
                                  local_last_changed_at     = lv_timestamp ).
        SELECT *
          FROM ztpp_1010
         WHERE material_requisition_no = @lv_requisition_no
          INTO TABLE @DATA(lt_db_items).      "#EC CI_ALL_FIELDS_NEEDED
        SORT lt_db_items BY item_no.

        LOOP AT cs_data-items INTO DATA(ls_item).
          READ TABLE lt_db_items INTO DATA(ls_db_item) WITH KEY item_no = ls_item-item_no BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_item-local_last_changed_at_s <> ls_db_item-local_last_changed_at.
              MESSAGE e060(zpp_001) INTO lv_message.
              cs_data-messageitems = VALUE #( ( type        = lc_type_e
                                                title       = TEXT-001
                                                subtitle    = lv_message
                                                description = lv_message ) ).
            ENDIF.

            READ TABLE lt_items ASSIGNING <lfs_item> WITH KEY item_no = ls_item-item_no BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_item>-material_requisition_no   = lv_requisition_no.
              <lfs_item>-manufacturing_order       = |{ ls_item-manufacturing_order ALPHA = IN }|.
              <lfs_item>-product                   = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = ls_item-product ).
              <lfs_item>-material                  = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = ls_item-material ).
              <lfs_item>-created_date              = ls_db_item-created_date.
              <lfs_item>-created_time              = ls_db_item-created_time.
              <lfs_item>-created_by_user           = ls_db_item-created_by_user.
              <lfs_item>-created_by_user_name      = ls_db_item-created_by_user_name.
              <lfs_item>-last_changed_date         = cs_data-datetime+0(8).
              <lfs_item>-last_changed_time         = cs_data-datetime+8(6).
              <lfs_item>-last_changed_by_user      = cs_data-user.
              <lfs_item>-last_changed_by_user_name = cs_data-username.
              <lfs_item>-local_last_changed_at     = lv_timestamp.
              TRY.
                  <lfs_item>-base_unit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = ls_item-base_unit ).
                  ##NO_HANDLER
                CATCH zzcx_custom_exception.
                  " handle exception
              ENDTRY.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF cs_data-messageitems IS NOT INITIAL.
      RETURN.
    ENDIF.

    CLEAR lv_message.
    MODIFY ztpp_1009 FROM @ls_header.
    IF sy-subrc = 0.
      MODIFY ztpp_1010 FROM TABLE @lt_items.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE if_abap_behv_message=>severity-error NUMBER sy-msgno
           INTO lv_message
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
      MESSAGE ID sy-msgid TYPE if_abap_behv_message=>severity-error NUMBER sy-msgno
         INTO lv_message
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF lv_message IS INITIAL.
      IF lv_mode = lc_mode_insert.
        MESSAGE s052(zpp_001) WITH lv_requisition_no INTO lv_message.
      ELSEIF lv_mode = lc_mode_update.
        MESSAGE s061(zpp_001) WITH lv_requisition_no INTO lv_message.
      ENDIF.
      cs_data-messageitems = VALUE #( ( type        = lc_type_s
                                        title       = TEXT-002
                                        subtitle    = lv_message
                                        description = lv_message ) ).
    ELSE.
      cs_data-messageitems = VALUE #( ( type        = lc_type_e
                                        title       = TEXT-001
                                        subtitle    = lv_message
                                        description = lv_message ) ).
    ENDIF.

    IF line_exists( lt_items[ delete_flag = 'W' ] ).
      SELECT SINGLE zvalue2
        FROM zc_tbc1001
       WHERE zid = @lc_config_zpp010
         AND zvalue1 = @ls_header-plant
        INTO @DATA(lv_amount).

      MESSAGE w105(zpp_001) WITH lv_amount INTO lv_message.
      APPEND VALUE #( type        = lc_type_w
                      title       = TEXT-003
                      subtitle    = lv_message
                      description = lv_message ) TO cs_data-messageitems .
    ENDIF.
  ENDMETHOD.

  METHOD zdelete.
    DATA: lv_message   TYPE string,
          lv_timestamp TYPE tzntstmpl,
          lv_itemno    TYPE i.

    READ ENTITIES OF zr_materialrequisition IN LOCAL MODE
    ENTITY materialrequisition
    ALL FIELDS WITH VALUE #( FOR item IN cs_data-items ( %key-materialrequisitionno = item-material_requisition_no
                                                         %key-itemno = item-item_no ) )
    RESULT DATA(lt_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      CLEAR lv_message.
      lv_itemno = <lfs_result>-itemno.

      " check header and item status
      IF <lfs_result>-mrstatus = abap_on.
        MESSAGE e062(zpp_001) WITH |{ <lfs_result>-materialrequisitionno }({ lv_itemno })| INTO lv_message.
      ELSEIF <lfs_result>-itemdeleteflag IS NOT INITIAL.
        MESSAGE e063(zpp_001) WITH |{ <lfs_result>-materialrequisitionno }({ lv_itemno })| INTO lv_message.
      ENDIF.

      IF lv_message IS NOT INITIAL.
        APPEND VALUE #( type        = lc_type_e
                        title       = TEXT-001
                        subtitle    = lv_message
                        description = lv_message ) TO cs_data-messageitems.
      ENDIF.
    ENDLOOP.

    IF cs_data-messageitems IS INITIAL.
      LOOP AT lt_result ASSIGNING <lfs_result>.
        lv_itemno = <lfs_result>-itemno.
        GET TIME STAMP FIELD lv_timestamp.

        UPDATE ztpp_1010
           SET delete_flag               = @abap_on,
               last_changed_date         = @cs_data-datetime+0(8),
               last_changed_time         = @cs_data-datetime+8(6),
               last_changed_by_user      = @cs_data-user,
               last_changed_by_user_name = @cs_data-username,
               local_last_changed_at     = @lv_timestamp
         WHERE material_requisition_no   = @<lfs_result>-materialrequisitionno
           AND item_no                   = @<lfs_result>-itemno.
        IF sy-subrc = 0.
          SELECT COUNT(*)
            FROM ztpp_1010
           WHERE material_requisition_no = @<lfs_result>-materialrequisitionno
             AND item_no = @<lfs_result>-itemno
             AND delete_flag IS INITIAL.
          IF sy-subrc <> 0.
            " The all items have all been deleted
            UPDATE ztpp_1009
               SET delete_flag               = @abap_on,
                   last_changed_date         = @cs_data-datetime+0(8),
                   last_changed_time         = @cs_data-datetime+8(6),
                   last_changed_by_user      = @cs_data-user,
                   last_changed_by_user_name = @cs_data-username,
                   local_last_changed_at     = @lv_timestamp
             WHERE material_requisition_no   = @<lfs_result>-materialrequisitionno.
          ENDIF.
          MESSAGE s064(zpp_001) WITH |{ <lfs_result>-materialrequisitionno }({ lv_itemno })| INTO lv_message.
          APPEND VALUE #( type        = lc_type_s
                          title       = TEXT-002
                          subtitle    = lv_message
                          description = lv_message ) TO cs_data-messageitems.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD resent.
    DATA: lv_message TYPE string.

    READ ENTITIES OF zr_materialrequisition IN LOCAL MODE
    ENTITY materialrequisition
    ALL FIELDS WITH VALUE #( FOR item IN cs_data-items ( %key-materialrequisitionno = item-material_requisition_no
                                                         %key-itemno = item-item_no ) )
    RESULT DATA(lt_result).

    SORT lt_result BY materialrequisitionno.
    DELETE ADJACENT DUPLICATES FROM lt_result COMPARING materialrequisitionno.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      " check delete status
      IF <lfs_result>-headerdeleteflag IS NOT INITIAL.
        MESSAGE e063(zpp_001) WITH <lfs_result>-materialrequisitionno INTO lv_message.
        APPEND VALUE #( type        = lc_type_e
                        title       = TEXT-001
                        subtitle    = lv_message
                        description = lv_message ) TO cs_data-messageitems.
        CONTINUE.
      ENDIF.

      CLEAR: lv_message.
      " generate attachment
      zzcl_common_utils=>generate_attachment(
        EXPORTING
          iv_templateid   = lc_template_id
          iv_providedkeys = get_providedkeys( <lfs_result>-materialrequisitionno )
        IMPORTING
          ev_has_error    = DATA(lv_has_error)
          ev_message      = lv_message
          ev_content      = DATA(lv_content) ).
      IF lv_has_error IS INITIAL.
        " send email
        DATA(lv_error_text) = sendemail( iv_materialrequisitionno = <lfs_result>-materialrequisitionno
                                         iv_content               = lv_content
                                         iv_datetime              = cs_data-datetime ).
        IF lv_error_text IS INITIAL.
          MESSAGE s069(zpp_001) WITH <lfs_result>-materialrequisitionno INTO lv_message.
          APPEND VALUE #( type        = lc_type_s
                          title       = TEXT-002
                          subtitle    = lv_message
                          description = lv_message ) TO cs_data-messageitems.
        ELSE.
          lv_message = |{ <lfs_result>-materialrequisitionno } { lv_error_text }|.
          APPEND VALUE #( type        = lc_type_e
                          title       = TEXT-001
                          subtitle    = lv_message
                          description = lv_message ) TO cs_data-messageitems.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD print.
    DATA: ls_item      TYPE lty_item,
          lv_timestamp TYPE timestamp,
          lv_timezone  TYPE tznzone,
          lv_filename  TYPE string,
          lv_message   TYPE string.

    READ ENTITIES OF zr_materialrequisition IN LOCAL MODE
    ENTITY materialrequisition
    ALL FIELDS WITH VALUE #( FOR item IN cs_data-items ( %key-materialrequisitionno = item-material_requisition_no
                                                         %key-itemno = item-item_no ) )
    RESULT DATA(lt_result).

    SORT lt_result BY materialrequisitionno.
    DELETE ADJACENT DUPLICATES FROM lt_result COMPARING materialrequisitionno.

    " UTC+8 UTC+9
    SELECT SINGLE zvalue4
      FROM zc_tbc1001
     WHERE zid = @lc_config_zpp005
       AND zvalue1 = @cs_data-header-plant
      INTO @lv_timezone.
    IF sy-subrc = 0.
      lv_timestamp = cs_data-datetime.
      CONVERT TIME STAMP lv_timestamp
              TIME ZONE lv_timezone
              INTO DATE DATA(lv_date) TIME DATA(lv_time).
    ELSE.
      lv_date = cs_data-datetime+0(8).
      lv_time = cs_data-datetime+8(6).
    ENDIF.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      " check delete status
      IF <lfs_result>-headerdeleteflag IS NOT INITIAL.
        MESSAGE e063(zpp_001) WITH <lfs_result>-materialrequisitionno INTO lv_message.
        APPEND VALUE #( type        = lc_type_e
                        title       = TEXT-001
                        subtitle    = lv_message
                        description = lv_message ) TO cs_data-messageitems.
        CONTINUE.
      ENDIF.

      CLEAR: lv_filename,lv_message,ls_item.
      lv_filename = |{ <lfs_result>-materialrequisitionno }_{ lv_date }{ lv_time }.pdf|.

      MODIFY ENTITIES OF zzc_prt_record
      ENTITY record
      EXECUTE createprintrecord
      AUTO FILL CID WITH VALUE #( ( %param-templateid   = lc_template_id
                                    %param-providedkeys = get_providedkeys( <lfs_result>-materialrequisitionno )
                                    %param-filename     = lv_filename ) )
      MAPPED FINAL(mapped)
      REPORTED FINAL(reported)
      FAILED FINAL(failed).
      IF mapped-record IS NOT INITIAL.
        TRY.
            cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = mapped-record[ 1 ]-recorduuid
                                                     IMPORTING uuid_c36 = ls_item-recorduuid ).
            ##NO_HANDLER
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
        MODIFY cs_data-items FROM ls_item TRANSPORTING recorduuid
                                          WHERE material_requisition_no = <lfs_result>-materialrequisitionno.
        MESSAGE s074(zpp_001) WITH <lfs_result>-materialrequisitionno INTO lv_message.
        APPEND VALUE #( type        = lc_type_s
                        title       = TEXT-002
                        subtitle    = lv_message
                        description = lv_message ) TO cs_data-messageitems.
      ELSE.
        MESSAGE e070(zpp_001) WITH <lfs_result>-materialrequisitionno INTO lv_message.
        APPEND VALUE #( type        = lc_type_e
                        title       = TEXT-001
                        subtitle    = lv_message
                        description = lv_message ) TO cs_data-messageitems.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD approval.
    DATA: lv_message   TYPE string,
          lv_timestamp TYPE tzntstmpl,
          lv_status    TYPE ztpp_1009-m_r_status,
          lv_itemno    TYPE i.

    READ ENTITIES OF zr_materialrequisition IN LOCAL MODE
    ENTITY materialrequisition
    ALL FIELDS WITH VALUE #( FOR item IN cs_data-items ( %key-materialrequisitionno = item-material_requisition_no
                                                         %key-itemno = item-item_no ) )
    RESULT DATA(lt_result).

    SORT lt_result BY materialrequisitionno.
    DELETE ADJACENT DUPLICATES FROM lt_result COMPARING materialrequisitionno.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      CLEAR lv_message.

      IF iv_model = lc_event_approval.
        " check header status
        IF <lfs_result>-mrstatus = abap_on.
          MESSAGE e062(zpp_001) WITH <lfs_result>-materialrequisitionno INTO lv_message.
        ELSEIF <lfs_result>-headerdeleteflag IS NOT INITIAL.
          MESSAGE e063(zpp_001) WITH <lfs_result>-materialrequisitionno INTO lv_message.
        ENDIF.
      ELSEIF iv_model = lc_event_cancelapproval.
        " check header status
        IF <lfs_result>-mrstatus IS INITIAL.
          MESSAGE e067(zpp_001) WITH <lfs_result>-materialrequisitionno INTO lv_message.
        ELSE.
          SELECT *
            FROM zc_materialrequisition
           WHERE materialrequisitionno = @<lfs_result>-materialrequisitionno
             AND postingstatus IS NOT INITIAL
            INTO TABLE @DATA(lt_exist).       "#EC CI_ALL_FIELDS_NEEDED
          IF sy-subrc = 0.
            LOOP AT lt_exist INTO DATA(ls_exist).
              lv_itemno = ls_exist-itemno.
              MESSAGE e075(zpp_001) WITH |{ <lfs_result>-materialrequisitionno }({ lv_itemno })| INTO lv_message.
              APPEND VALUE #( type        = lc_type_e
                              title       = TEXT-001
                              subtitle    = lv_message
                              description = lv_message ) TO cs_data-messageitems.
            ENDLOOP.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lv_message IS NOT INITIAL.
        APPEND VALUE #( type        = lc_type_e
                        title       = TEXT-001
                        subtitle    = lv_message
                        description = lv_message ) TO cs_data-messageitems.
      ENDIF.
    ENDLOOP.

    IF cs_data-messageitems IS INITIAL.
      IF iv_model = lc_event_approval.
        lv_status = abap_on.
      ELSEIF iv_model = lc_event_cancelapproval.
        lv_status = abap_off.
      ENDIF.
      LOOP AT lt_result ASSIGNING <lfs_result>.
        GET TIME STAMP FIELD lv_timestamp.
        UPDATE ztpp_1009
           SET m_r_status                 = @lv_status,
               last_changed_date          = @cs_data-datetime+0(8),
               last_changed_time          = @cs_data-datetime+8(6),
               last_changed_by_user       = @cs_data-user,
               last_changed_by_user_name  = @cs_data-username,
               last_approved_date         = @cs_data-datetime+0(8),
               last_approved_time         = @cs_data-datetime+8(6),
               last_approved_by_user      = @cs_data-user,
               last_approved_by_user_name = @cs_data-username,
               local_last_changed_at      = @lv_timestamp
         WHERE material_requisition_no    = @<lfs_result>-materialrequisitionno.
        IF sy-subrc = 0.
          IF iv_model = lc_event_approval.
            " generate attachment
            zzcl_common_utils=>generate_attachment(
              EXPORTING
                iv_templateid   = lc_template_id
                iv_providedkeys = get_providedkeys( <lfs_result>-materialrequisitionno )
              IMPORTING
                ev_has_error    = DATA(lv_has_error)
                ev_message      = lv_message
                ev_content      = DATA(lv_content) ).
            IF lv_has_error IS INITIAL.
              " send email
              DATA(lv_error_text) = sendemail( iv_materialrequisitionno = <lfs_result>-materialrequisitionno
                                               iv_content               = lv_content
                                               iv_datetime              = cs_data-datetime ).
              IF lv_error_text IS NOT INITIAL.
                lv_message = |{ <lfs_result>-materialrequisitionno } { lv_error_text }|.
                APPEND VALUE #( type        = lc_type_w
                                title       = TEXT-003
                                subtitle    = lv_message
                                description = lv_message ) TO cs_data-messageitems.
                MESSAGE s104(zpp_001) WITH <lfs_result>-materialrequisitionno INTO lv_message.
              ELSE.
                MESSAGE s065(zpp_001) WITH <lfs_result>-materialrequisitionno INTO lv_message.
              ENDIF.
            ENDIF.
          ELSEIF iv_model = lc_event_cancelapproval.
            MESSAGE s068(zpp_001) WITH <lfs_result>-materialrequisitionno INTO lv_message.
          ENDIF.
          APPEND VALUE #( type        = lc_type_s
                          title       = TEXT-002
                          subtitle    = lv_message
                          description = lv_message ) TO cs_data-messageitems.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

*  METHOD posting.
*    DATA: lt_material_document_headers TYPE TABLE FOR CREATE i_materialdocumenttp,
*          ls_material_document_header  TYPE STRUCTURE FOR CREATE i_materialdocumenttp,
*          lt_material_document_items   TYPE TABLE FOR CREATE i_materialdocumenttp\_materialdocumentitem,
*          ls_material_document_item    TYPE STRUCTURE FOR CREATE i_materialdocumenttp\_materialdocumentitem.
*
*    DATA: lv_message      TYPE string,
*          lv_timestamp    TYPE tzntstmpl,
*          lv_documentdate TYPE datum.
*
*    DATA: m TYPE i,
*          n TYPE i.
*
*    SELECT *
*      FROM zc_materialrequisition
*     WHERE materialrequisitionno = @cs_data-header-material_requisition_no
*       AND itemdeleteflag IS INITIAL
*      INTO TABLE @DATA(lt_result).
*    SORT lt_result BY itemno.
*
*    IF lt_result IS INITIAL.
*      MESSAGE e063(zpp_001) WITH cs_data-header-material_requisition_no INTO lv_message.
*      APPEND VALUE #( type        = lc_type_e
*                      title       = TEXT-001
*                      subtitle    = lv_message
*                      description = lv_message ) TO cs_data-messageitems.
*      RETURN.
*    ELSE.
*      CLEAR lv_message.
*
*      DATA(lt_temp) = lt_result.
*      SORT lt_temp BY materialrequisitionno.
*      DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING materialrequisitionno.
*      LOOP AT lt_temp INTO DATA(ls_temp).
*        IF ls_temp-mrstatus IS INITIAL.
*          MESSAGE e067(zpp_001) WITH ls_temp-materialrequisitionno INTO lv_message.
*          APPEND VALUE #( type        = lc_type_e
*                          title       = TEXT-001
*                          subtitle    = lv_message
*                          description = lv_message ) TO cs_data-messageitems.
*        ENDIF.
*      ENDLOOP.
*      IF cs_data-messageitems IS NOT INITIAL.
*        RETURN.
*      ENDIF.
*
*      IF iv_model = lc_event_posting.
*        DELETE lt_result WHERE postingstatus IS NOT INITIAL.
*        IF lt_result IS INITIAL.
*          MESSAGE e079(zpp_001) WITH cs_data-header-material_requisition_no INTO lv_message.
*        ENDIF.
*      ELSEIF iv_model = lc_event_cancelposting.
*        DELETE lt_result WHERE postingstatus IS INITIAL OR postingstatus = lc_cancel.
*        IF lt_result IS INITIAL.
*          MESSAGE e076(zpp_001) WITH cs_data-header-material_requisition_no INTO lv_message.
*        ENDIF.
*      ENDIF.
*
*      IF lv_message IS NOT INITIAL.
*        APPEND VALUE #( type        = lc_type_e
*                        title       = TEXT-001
*                        subtitle    = lv_message
*                        description = lv_message ) TO cs_data-messageitems.
*        RETURN.
*      ENDIF.
*
*      READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>) INDEX 1.
*
*      SELECT SINGLE *
*        FROM zc_tbc1001
*       WHERE zid     = @lc_config_id
*         AND zvalue1 = @<lfs_result>-type
*        INTO @DATA(ls_config).
*
*      lv_documentdate = <lfs_result>-headercreateddate.
*
*      LOOP AT lt_result ASSIGNING <lfs_result>.
*        IF ls_config-zvalue4 IS NOT INITIAL.
*          <lfs_result>-goodsmovementtype = lc_movementtype_551.
*        ELSEIF <lfs_result>-orderisclosed IS NOT INITIAL OR <lfs_result>-manufacturingorder IS INITIAL.
*          <lfs_result>-goodsmovementtype = lc_movementtype_201.
*        ELSE.
*          <lfs_result>-goodsmovementtype = lc_movementtype_261.
*        ENDIF.
*      ENDLOOP.
*
*      LOOP AT lt_result INTO DATA(ls_result) GROUP BY ( goodsmovementtype = ls_result-goodsmovementtype )
*                                             ASSIGNING FIELD-SYMBOL(<lfs_group>).
*        m += 1.
*        CLEAR: ls_material_document_header,
*               lt_material_document_headers,
*               lt_material_document_items,n.
*
*        ls_material_document_header = VALUE #( %cid              = |My%HeaderCID_{ m }|
*                                               goodsmovementcode = '05'
*                                               postingdate       = cs_data-datetime+0(8)
*                                               documentdate      = lv_documentdate ).
*        APPEND ls_material_document_header TO lt_material_document_headers.
*
*        LOOP AT GROUP <lfs_group> ASSIGNING FIELD-SYMBOL(<lfs_group_item>).
*          CLEAR ls_material_document_item.
*
*          n += 1.
*          DATA(lv_itemtext) = |{ <lfs_group_item>-materialrequisitionno }-{ <lfs_group_item>-itemno }|.
*          ls_material_document_item = VALUE #(
*                           %cid_ref = |My%HeaderCID_{ m }|
*                           %target  = VALUE #( ( %cid                     = |My%HeaderCID_{ m }%ItemCID_{ n }|
*                                                 goodsmovementtype        = <lfs_group_item>-goodsmovementtype
*                                                 plant                    = <lfs_group_item>-plant
*                                                 material                 = <lfs_group_item>-material
*                                                 storagelocation          = <lfs_group_item>-storagelocation
*                                                 quantityinentryunit      = <lfs_group_item>-quantity
*                                                 entryunit                = <lfs_group_item>-baseunit
*                                                 costcenter               = COND #( WHEN <lfs_group_item>-goodsmovementtype = lc_movementtype_201
*                                                                                    THEN <lfs_group_item>-costcenter
*                                                                                    ELSE '' )
*                                                 manufacturingorder       = COND #( WHEN <lfs_group_item>-goodsmovementtype = lc_movementtype_261
*                                                                                    THEN <lfs_group_item>-manufacturingorder
*                                                                                    ELSE '' )
*                                                 materialdocumentitemtext = lv_itemtext ) ) ).
*          APPEND ls_material_document_item TO lt_material_document_items.
*        ENDLOOP.
*
*        " Create Material Document（Call Business Object Interfaces）
*        MODIFY ENTITIES OF i_materialdocumenttp PRIVILEGED
*        ENTITY materialdocument
*           CREATE FIELDS ( goodsmovementcode
*                           postingdate
*                           documentdate ) WITH lt_material_document_headers
*           CREATE BY \_materialdocumentitem
*                  FIELDS ( goodsmovementtype
*                           plant
*                           material
*                           storagelocation
*                           quantityinentryunit
*                           entryunit
*                           costcenter
*                           manufacturingorder
*                           materialdocumentitemtext ) WITH lt_material_document_items
*         MAPPED DATA(mapped)
*         FAILED DATA(failed)
*         REPORTED DATA(reported).
*
*        IF failed IS INITIAL.
*          " Stored in the global variable
*          APPEND LINES OF mapped-materialdocument TO zbp_r_materialrequisition=>mapped_material_document-materialdocument.
*          APPEND LINES OF mapped-materialdocumentitem TO zbp_r_materialrequisition=>mapped_material_document-materialdocumentitem.
*
*          LOOP AT lt_material_document_items INTO ls_material_document_item.
*            lv_message = ls_material_document_item-%target[ 1 ]-materialdocumentitemtext.
*            APPEND VALUE #( type        = lc_type_s
*                            title       = TEXT-002
*                            subtitle    = lv_message
*                            description = lv_message ) TO cs_data-messageitems.
*          ENDLOOP.
*        ELSE.
*          LOOP AT lt_material_document_items INTO ls_material_document_item.
*            lv_message = ls_material_document_item-%target[ 1 ]-materialdocumentitemtext.
*            APPEND VALUE #( type        = lc_type_s
*                            title       = TEXT-002
*                            subtitle    = lv_message
*                            description = lv_message ) TO cs_data-messageitems.
*          ENDLOOP.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*  ENDMETHOD.

  METHOD posting.
    DATA: ls_document      TYPE lty_document,
          ls_document_item TYPE lty_document_item,
          ls_response      TYPE lty_response,
          ls_error         TYPE zzcl_odata_utils=>gty_error.

    DATA: lv_message               TYPE string,
          lv_timestamp             TYPE tzntstmpl,
          lv_postingdate           TYPE string,
          lv_documentdate          TYPE string,
          lv_unit                  TYPE string,
          lv_materialrequisitionno TYPE ztpp_1010-material_requisition_no,
          lv_itemnum               TYPE ztpp_1010-item_no,
          lv_itemno                TYPE i.

    SELECT *
      FROM zc_materialrequisition
     WHERE materialrequisitionno = @cs_data-header-material_requisition_no
       AND itemdeleteflag IS INITIAL
      INTO TABLE @DATA(lt_result).
    SORT lt_result BY itemno.

    IF lt_result IS INITIAL.
      MESSAGE e063(zpp_001) WITH cs_data-header-material_requisition_no INTO lv_message.
      APPEND VALUE #( type        = lc_type_e
                      title       = TEXT-001
                      subtitle    = lv_message
                      description = lv_message ) TO cs_data-messageitems.
      RETURN.
    ELSE.
      CLEAR lv_message.

      DATA(lt_temp) = lt_result.
      SORT lt_temp BY materialrequisitionno.
      DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING materialrequisitionno.
      LOOP AT lt_temp INTO DATA(ls_temp).
        IF ls_temp-mrstatus IS INITIAL.
          MESSAGE e067(zpp_001) WITH ls_temp-materialrequisitionno INTO lv_message.
          APPEND VALUE #( type        = lc_type_e
                          title       = TEXT-001
                          subtitle    = lv_message
                          description = lv_message ) TO cs_data-messageitems.
        ELSE.
          IF  iv_model = lc_event_posting
          AND ls_temp-mrstatus <> '31'
          AND ls_temp-linewarehousestatus <> 'X'
          AND ls_temp-uwms_poststatus <> 'P'.
            MESSAGE e107(zpp_001) WITH ls_temp-materialrequisitionno INTO lv_message.
            APPEND VALUE #( type        = lc_type_e
                            title       = TEXT-001
                            subtitle    = lv_message
                            description = lv_message ) TO cs_data-messageitems.
          ENDIF .
        ENDIF.
      ENDLOOP.
      IF cs_data-messageitems IS NOT INITIAL.
        RETURN.
      ENDIF.

      IF iv_model = lc_event_posting.
        DELETE lt_result WHERE postingstatus IS NOT INITIAL.
        IF lt_result IS INITIAL.
          MESSAGE e079(zpp_001) WITH cs_data-header-material_requisition_no INTO lv_message.
        ENDIF.
      ELSEIF iv_model = lc_event_cancelposting.
        DELETE lt_result WHERE postingstatus IS INITIAL OR postingstatus = lc_posting_cancel.
        IF lt_result IS INITIAL.
          MESSAGE e076(zpp_001) WITH cs_data-header-material_requisition_no INTO lv_message.
        ENDIF.
      ENDIF.

      IF lv_message IS NOT INITIAL.
        APPEND VALUE #( type        = lc_type_e
                        title       = TEXT-001
                        subtitle    = lv_message
                        description = lv_message ) TO cs_data-messageitems.
        RETURN.
      ENDIF.

      READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>) INDEX 1.

      IF iv_model = lc_event_posting.
        SELECT SINGLE *
          FROM zc_tbc1001
         WHERE zid     = @lc_config_zpp001
           AND zvalue1 = @<lfs_result>-type
          INTO @DATA(ls_config).              "#EC CI_ALL_FIELDS_NEEDED

        lv_postingdate = |{ cs_data-datetime+0(4) }-{ cs_data-datetime+4(2) }-{ cs_data-datetime+6(2) }T00:00:00|.
        lv_documentdate = |{ <lfs_result>-headercreateddate+0(4) }-{ <lfs_result>-headercreateddate+4(2) }-{ <lfs_result>-headercreateddate+6(2) }T00:00:00|.

        LOOP AT lt_result ASSIGNING <lfs_result>.
          IF ls_config-zvalue4 IS NOT INITIAL.
            <lfs_result>-goodsmovementtype = lc_movementtype_551.
          ELSEIF <lfs_result>-orderisclosed IS NOT INITIAL OR <lfs_result>-manufacturingorder IS INITIAL.
            <lfs_result>-goodsmovementtype = lc_movementtype_201.
          ELSE.
            <lfs_result>-goodsmovementtype = lc_movementtype_261.
          ENDIF.
        ENDLOOP.

        LOOP AT lt_result INTO DATA(ls_result) GROUP BY ( goodsmovementtype = ls_result-goodsmovementtype )
                                               ASSIGNING FIELD-SYMBOL(<lfs_group>).
          CLEAR ls_document.
          ls_document = VALUE #( goods_movement_code = COND #( WHEN <lfs_group>-goodsmovementtype = lc_movementtype_261
                                                               THEN '05'
                                                               ELSE '03' )
                                 posting_date        = lv_postingdate
                                 document_date       = lv_documentdate ).

          LOOP AT GROUP <lfs_group> ASSIGNING FIELD-SYMBOL(<lfs_group_item>).
            CLEAR: ls_document_item, lv_unit.
            lv_itemno = <lfs_group_item>-itemno.
            DATA(lv_itemtext) = |{ <lfs_group_item>-materialrequisitionno }-{ lv_itemno }|.
            TRY.
                lv_unit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_group_item>-baseunit ).
                ##NO_HANDLER
              CATCH zzcx_custom_exception.
                " handle exception
            ENDTRY.

            ls_document_item = VALUE #( goods_movement_type         = <lfs_group_item>-goodsmovementtype
                                        plant                       = <lfs_group_item>-plant
                                        material                    = <lfs_group_item>-material
                                        storage_location            = <lfs_group_item>-storagelocation
                                        quantity_in_entry_unit      = <lfs_group_item>-quantity
                                        entry_unit                  = lv_unit
                                        cost_center                 = COND #( WHEN <lfs_group_item>-goodsmovementtype = lc_movementtype_201
                                                                              THEN <lfs_group_item>-costcenter
                                                                              ELSE '' )
                                        manufacturing_order         = COND #( WHEN <lfs_group_item>-goodsmovementtype = lc_movementtype_261
                                                                              THEN <lfs_group_item>-manufacturingorder
                                                                              ELSE '' )
                                        material_document_item_text = lv_itemtext ).
            CONDENSE ls_document_item-quantity_in_entry_unit NO-GAPS.
            APPEND ls_document_item TO ls_document-to_material_document_item.
          ENDLOOP.

          DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_document )->apply( VALUE #(
            ( xco_cp_json=>transformation->underscore_to_pascal_case )
          ) )->to_string( ).
          REPLACE ALL OCCURRENCES OF `ToMaterialDocumentItem` IN lv_requestbody  WITH 'to_MaterialDocumentItem'.

          GET TIME STAMP FIELD lv_timestamp.
          " create material document
          zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = |/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader?sap-language={ zzcl_common_utils=>get_current_language(  ) }|
                                                       iv_method      = if_web_http_client=>post
                                                       iv_body        = lv_requestbody
                                             IMPORTING ev_status_code = DATA(lv_status_code)
                                                       ev_response    = DATA(lv_response) ).
          IF lv_status_code = 201. " created
            xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
              ( xco_cp_json=>transformation->pascal_case_to_underscore )
              ( xco_cp_json=>transformation->boolean_to_abap_bool )
            ) )->write_to( REF #( ls_response ) ).

            LOOP AT ls_document-to_material_document_item INTO ls_document_item.
              SPLIT ls_document_item-material_document_item_text  AT `-` INTO lv_materialrequisitionno lv_itemnum.
              CONDENSE lv_materialrequisitionno NO-GAPS.
              lv_itemnum = |{ lv_itemnum ALPHA = IN }|.
              UPDATE ztpp_1010
                 SET posting_status            = @lc_posting,
                     goods_movement_type       = @ls_document_item-goods_movement_type,
                     material_document         = @ls_response-d-material_document,
                     posting_date              = @cs_data-datetime+0(8),
                     posting_time              = @cs_data-datetime+8(6),
                     posting_by_user           = @cs_data-user,
                     posting_by_user_name      = @cs_data-username,
                     last_changed_date         = @cs_data-datetime+0(8),
                     last_changed_time         = @cs_data-datetime+8(6),
                     last_changed_by_user      = @cs_data-user,
                     last_changed_by_user_name = @cs_data-username,
                     local_last_changed_at     = @lv_timestamp
               WHERE material_requisition_no   = @lv_materialrequisitionno
                 AND item_no                   = @lv_itemnum.

              MESSAGE s081(zpp_001)
                 WITH ls_document_item-material_document_item_text space
                 INTO lv_message.
              APPEND VALUE #( type        = lc_type_s
                              title       = TEXT-002
                              subtitle    = lv_message
                              description = lv_message ) TO cs_data-messageitems.
            ENDLOOP.
          ELSE.
            /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                       CHANGING  data = ls_error ).

            LOOP AT ls_document-to_material_document_item INTO ls_document_item.
              MESSAGE e077(zpp_001)
                 WITH ls_document_item-material_document_item_text space
                 INTO lv_message.
              APPEND VALUE #( type        = lc_type_e
                              title       = TEXT-001
                              subtitle    = lv_message
                              description = ls_error-error-message-value ) TO cs_data-messageitems.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
      ELSEIF iv_model = lc_event_cancelposting.
        GET TIME STAMP FIELD lv_timestamp.

        LOOP AT lt_result INTO DATA(ls_result1) GROUP BY ( materialdocumentyear = ls_result1-postingdate+0(4)
                                                           materialdocument     = ls_result1-materialdocument )
                                                ASSIGNING FIELD-SYMBOL(<lfs_group1>).
          " cancel material document
          DATA(lv_path) = |/API_MATERIAL_DOCUMENT_SRV/Cancel?sap-language={ zzcl_common_utils=>get_current_language(  ) }| &&
                          |&MaterialDocumentYear='{ <lfs_group1>-materialdocumentyear }'| &&
                          |&MaterialDocument='{ <lfs_group1>-materialdocument }'|.

          zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                       iv_method      = if_web_http_client=>post
                                             IMPORTING ev_status_code = lv_status_code
                                                       ev_response    = lv_response ).
          IF lv_status_code = 200. " success
            xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
              ( xco_cp_json=>transformation->pascal_case_to_underscore )
              ( xco_cp_json=>transformation->boolean_to_abap_bool )
            ) )->write_to( REF #( ls_response ) ).

            DATA(lv_match) = |{ <lfs_group1>-materialdocumentyear }%|.

            UPDATE ztpp_1010
               SET posting_status            = @lc_posting_cancel,
                   cancel_material_document  = @ls_response-d-material_document,
                   cancelled_by_user         = @cs_data-user,
                   cancelled_by_user_name    = @cs_data-username,
                   last_changed_date         = @cs_data-datetime+0(8),
                   last_changed_time         = @cs_data-datetime+8(6),
                   last_changed_by_user      = @cs_data-user,
                   last_changed_by_user_name = @cs_data-username,
                   local_last_changed_at     = @lv_timestamp
             WHERE material_document = @<lfs_group1>-materialdocument
               AND posting_date LIKE @lv_match.
          ELSE.
            /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                       CHANGING  data = ls_error ).
          ENDIF.

          LOOP AT GROUP <lfs_group1> ASSIGNING FIELD-SYMBOL(<lfs_group1_item>).
            lv_itemno = <lfs_group1_item>-itemno.
            IF lv_status_code = 200.
              MESSAGE s082(zpp_001)
                 WITH |{ <lfs_group1_item>-materialrequisitionno }-{ lv_itemno }| space
                 INTO lv_message.
              APPEND VALUE #( type        = lc_type_s
                              title       = TEXT-002
                              subtitle    = lv_message
                              description = lv_message ) TO cs_data-messageitems.
            ELSE.
              MESSAGE e077(zpp_001)
                 WITH |{ <lfs_group1_item>-materialrequisitionno }-{ lv_itemno }| space
                 INTO lv_message.
              APPEND VALUE #( type        = lc_type_e
                              title       = TEXT-001
                              subtitle    = lv_message
                              description = ls_error-error-message-value ) TO cs_data-messageitems.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_providedkeys.
    DATA: BEGIN OF ls_key,
            _material_requisition_no TYPE ztpp_1010-material_requisition_no,
          END OF ls_key.

    ls_key-_material_requisition_no = iv_value.
    rv_providedkeys = /ui2/cl_json=>serialize( data = ls_key pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
  ENDMETHOD.

  METHOD sendemail.
    DATA: lt_recipient    TYPE cl_bcs_mail_message=>tyt_recipient,
          lt_attachment   TYPE zzcl_common_utils=>tt_attachment,
          lv_subject      TYPE cl_bcs_mail_message=>ty_subject,
          lv_main_content TYPE string,
          lv_filename     TYPE string,
          lv_timestamp    TYPE timestamp,
          lv_timezone     TYPE tznzone.

    SELECT *
      FROM zc_materialrequisition
     WHERE materialrequisitionno = @iv_materialrequisitionno
       AND headerdeleteflag IS INITIAL
       AND itemdeleteflag IS INITIAL
      INTO TABLE @DATA(lt_data).

    CHECK lt_data IS NOT INITIAL.
    SORT lt_data BY itemno.
    READ TABLE lt_data INTO DATA(ls_data) INDEX 1.

    SELECT receiver_type AS receivertype,
           mail_address AS mailaddress
      FROM ztpp_1011
      FOR ALL ENTRIES IN @lt_data
     WHERE plant    = @lt_data-plant
       AND customer = @lt_data-customer
      INTO TABLE @DATA(lt_emailmaster).
    IF sy-subrc <> 0.
      MESSAGE e103(zpp_001) INTO rv_error_text.
      RETURN.
    ENDIF.

    lt_recipient = VALUE #( FOR item IN lt_emailmaster ( address = item-mailaddress
                                                         copy    = CONV #( item-receivertype ) ) ).
    " UTC+8 UTC+9
    SELECT SINGLE zvalue4
      FROM zc_tbc1001
     WHERE zid = @lc_config_zpp005
       AND zvalue1 = @ls_data-plant
      INTO @lv_timezone.
    IF sy-subrc = 0.
      lv_timestamp = iv_datetime.
      CONVERT TIME STAMP lv_timestamp
              TIME ZONE lv_timezone
              INTO DATE DATA(lv_date) TIME DATA(lv_time).
    ELSE.
      lv_date = iv_datetime+0(8).
      lv_time = iv_datetime+8(6).
    ENDIF.

    DATA(lv_datetime) = |{ lv_date+0(4) }/{ lv_date+4(2) }/{ lv_date+6(2) } { lv_time+0(2) }:{ lv_time+2(2) }:{ lv_time+4(2) }|.

    lv_main_content = |<p>生産管理担当各位:</p><div style="height: 5px;"></div>|.
    IF ls_data-type = lc_application_type_im.
      lv_filename = |{ iv_materialrequisitionno }_副資材仕損処理依頼書.pdf|.
      lv_subject = |副資材廃棄申請連絡 { iv_materialrequisitionno }　{ lv_datetime }|.
      lv_main_content = lv_main_content &&
                        |<p>副資材仕損処理依頼を発行しました。</p>| &&
                        |<p>SAP システム処理をお願いします。</p><div style="height: 5px;"></div>| &&
                        |<p>顧客名: { ls_data-customer } : { ls_data-customername }</p>| &&
                        |<p>IM番号: { iv_materialrequisitionno }</p>|.
    ELSE.
      lv_filename = |{ iv_materialrequisitionno }_部品払出依頼書.pdf|.
      lv_subject = |部品払出依頼書（MR）{ iv_materialrequisitionno }　{ lv_datetime }|.
      lv_main_content = lv_main_content &&
                        |<p>計画外部品受入(M/R Manage)にて、部品払出依頼を発行しました。</p>| &&
                        |<p>SAP システム処理をお願いします。</p><div style="height: 5px;"></div>| &&
                        |<p>顧客名: { ls_data-customer } : { ls_data-customername }</p>| &&
                        |<p>MR番号: { iv_materialrequisitionno }</p>|.
    ENDIF.

    " table begin
    lv_main_content = lv_main_content &&
                      |<table align="left" border="1" cellspacing="0" cellpadding="5" width="100%" style="margin-bottom: 15px;">| &&
                        |<thead>| &&
                          |<tr>| &&
                            |<th width="200px" align="left">半製品</th>| &&
                            |<th width="200px" align="left">部品品目</th>| &&
                            |<th width="150px" align="left">回路番号</th>| &&
                            |<th width="100px" align="right">数量</th>| &&
                            |<th width="200px" align="left">理由</th>| &&
                          |</tr>| &&
                        |</thead>| &&
                      |<tbody>|.
    LOOP AT lt_data INTO ls_data.
      lv_main_content = lv_main_content &&
                        |<tr>| &&
                          |<td align="left">{ ls_data-product }</td>| &&
                          |<td align="left">{ ls_data-material }</td>| &&
                          |<td align="left">{ ls_data-location }</td>| &&
                          |<td align="right">{ ls_data-quantity }</td>| &&
                          |<td align="left">{ ls_data-reason }-{ ls_data-reasontext } { ls_data-remark }</td>| &&
                        |</tr>|.
    ENDLOOP.
    " table end
    lv_main_content = lv_main_content && |</tbody></table>|.

    IF ls_data-type <> lc_application_type_im.
      lv_main_content = lv_main_content &&
                        |<p>倉庫担当は、現品の払い出し処理をお願いします。</p>| &&
                        |<p>出庫の際は、添付の払出依頼書を部品に添付して下さい。</p><div style="height: 5px;"></div>|.
    ENDIF.
    lv_main_content = lv_main_content && |<p>このメ-ルは、SAP にて自動配信されています。</p>|.

    lt_attachment = VALUE #( ( content_type = 'application/pdf'
                               filename     = lv_filename
                               content      = iv_content ) ).
    TRY.
        zzcl_common_utils=>send_email( EXPORTING iv_subject      = lv_subject
                                                 iv_main_content = lv_main_content
                                                 it_recipient    = lt_recipient
                                                 it_attachment   = lt_attachment
                                       IMPORTING et_status       = DATA(lt_status) ).
      CATCH cx_bcs_mail INTO DATA(lx_bcs_mail).
        " handle exception
*        rv_error_text = lx_bcs_mail->get_longtext(  ).
        MESSAGE ID sy-msgid TYPE 'E'
            NUMBER sy-msgno INTO rv_error_text WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

*CLASS lsc_zr_materialrequisition DEFINITION INHERITING FROM cl_abap_behavior_saver.
*  PROTECTED SECTION.
*
*    METHODS finalize REDEFINITION.
*
*    METHODS check_before_save REDEFINITION.
*
*    METHODS adjust_numbers REDEFINITION.
*
*    METHODS save REDEFINITION.
*
*    METHODS cleanup REDEFINITION.
*
*    METHODS cleanup_finalize REDEFINITION.
*
*ENDCLASS.
*
*CLASS lsc_zr_materialrequisition IMPLEMENTATION.
*
*  METHOD finalize.
*  ENDMETHOD.
*
*  METHOD check_before_save.
*  ENDMETHOD.
*
*  METHOD adjust_numbers.
*  ENDMETHOD.
*
*  METHOD save.
*  ENDMETHOD.
*
*  METHOD cleanup.
*  ENDMETHOD.
*
*  METHOD cleanup_finalize.
*  ENDMETHOD.
*
*ENDCLASS.
