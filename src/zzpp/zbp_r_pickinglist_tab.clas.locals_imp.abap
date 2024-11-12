CLASS lhc_pickinglist DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_messageitem,
            type        TYPE string,
            title       TYPE string,
            description TYPE string,
            subtitle    TYPE string,
          END OF lty_messageitem.
    TYPES:BEGIN OF lty_item.
            INCLUDE TYPE zc_pickinglist_std.
    TYPES:  reservation     TYPE ztpp_1015-reservation,
            reservationitem TYPE ztpp_1015-reservation_item,
          END OF lty_item.
    TYPES:BEGIN OF lty_request,
            items        TYPE TABLE OF lty_item WITH DEFAULT KEY,
            user         TYPE string,
            username     TYPE string,
            datetime     TYPE string,
            messageitems TYPE TABLE OF lty_messageitem WITH DEFAULT KEY,
          END OF lty_request.

    TYPES:BEGIN OF lty_document_item,
            plant                          TYPE i_reservationdocumentitemtp-plant,
            product                        TYPE i_reservationdocumentitemtp-product,
            storage_location               TYPE i_reservationdocumentitemtp-storagelocation,
            resvnitmrequiredqtyinentryunit TYPE string,
            entry_unit                     TYPE string,
            goods_movement_is_allowed      TYPE xsdboolean,
          END OF lty_document_item,
          BEGIN OF lty_document,
            reservation                  TYPE i_reservationdocumenttp-reservation,
            goods_movement_type          TYPE i_reservationdocumenttp-goodsmovementtype,
            reservation_date             TYPE string,
            issuing_or_receiving_plant   TYPE i_reservationdocumenttp-issuingorreceivingplant,
            issuingorreceivingstorageloc TYPE i_reservationdocumenttp-issuingorreceivingstorageloc,
            to_reservation_document_item TYPE TABLE OF lty_document_item WITH DEFAULT KEY,
          END OF lty_document,
          BEGIN OF lty_response,
            d TYPE lty_document,
          END OF lty_response.

    CONSTANTS: lc_type_e TYPE string VALUE `Error`,
               lc_type_s TYPE string VALUE `Success`.

    CONSTANTS: lc_event_create TYPE string VALUE `STD_CREATE`,
               lc_event_save   TYPE string VALUE `TAB_SAVE`,
               lc_event_delete TYPE string VALUE `TAB_DELETE`.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR pickinglist RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION pickinglist~processlogic RESULT result.

    METHODS create CHANGING cs_data TYPE lty_request.
    METHODS save CHANGING cs_data TYPE lty_request.
    METHODS delete CHANGING cs_data TYPE lty_request.

    METHODS get_message IMPORTING io_message    TYPE REF TO if_abap_behv_message
                        RETURNING VALUE(rv_msg) TYPE string.
ENDCLASS.

CLASS lhc_pickinglist IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

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
        WHEN lc_event_create.
          create( CHANGING cs_data = ls_request ).
        WHEN lc_event_save.
          save( CHANGING cs_data = ls_request ).
        WHEN lc_event_delete.
          delete( CHANGING cs_data = ls_request ).
        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD create.
    DATA: lt_head_table TYPE TABLE OF ztpp_1015,
          ls_head_table TYPE ztpp_1015,
          lt_item_table TYPE TABLE OF ztpp_1016,
          ls_item_table TYPE ztpp_1016,
          lt_temp_table TYPE TABLE OF ztpp_1016,
          ls_temp_table TYPE ztpp_1016.
    DATA: ls_document      TYPE lty_document,
          ls_document_item TYPE lty_document_item,
          ls_response      TYPE lty_response,
          ls_error         TYPE zzcl_odata_utils=>gty_error.

    DATA: lv_message   TYPE string,
          lv_timestamp TYPE tzntstmpl,
          lv_unit      TYPE string,
          lv_itemno    TYPE i.

    CLEAR ls_document.
    DATA(lv_postingdate) = |{ cs_data-datetime+0(4) }-{ cs_data-datetime+4(2) }-{ cs_data-datetime+6(2) }T00:00:00|.

    SELECT *
      FROM i_storagelocation WITH PRIVILEGED ACCESS
       FOR ALL ENTRIES IN @cs_data-items
     WHERE plant = @cs_data-items-plant
       AND storagelocation = @cs_data-items-storagelocationfrom
      INTO TABLE @DATA(lt_storagelocation).
    SORT lt_storagelocation BY plant storagelocation.

    LOOP AT cs_data-items INTO DATA(ls_item).
      lv_itemno += 1.

      READ TABLE lt_storagelocation TRANSPORTING NO FIELDS WITH KEY plant = ls_item-plant
                                                                    storagelocation = ls_item-storagelocationfrom
                                                                    BINARY SEARCH.
      IF sy-subrc <> 0.
        MESSAGE e092(zpp_001) WITH ls_item-rowno ls_item-plant ls_item-storagelocationfrom INTO lv_message.
        APPEND VALUE #( type        = lc_type_e
                        title       = TEXT-001
                        subtitle    = lv_message
                        description = ls_error-error-message-value ) TO cs_data-messageitems.
      ENDIF.

      IF cs_data-messageitems IS INITIAL.
        IF lv_itemno = 1.
          ls_document = VALUE #( goods_movement_type          = '311'
                                 issuing_or_receiving_plant   = ls_item-plant
                                 issuingorreceivingstorageloc = ls_item-storagelocationto
                                 reservation_date             = lv_postingdate ).
        ENDIF.

        ls_document_item = VALUE #( plant                          = ls_item-plant
                                    product                        = ls_item-material
                                    storage_location               = ls_item-storagelocationfrom
                                    resvnitmrequiredqtyinentryunit = ls_item-totaltransferquantity
                                    entry_unit                     = ls_item-baseunit
                                    goods_movement_is_allowed      = abap_true ).
        CONDENSE ls_document_item-resvnitmrequiredqtyinentryunit NO-GAPS.
        APPEND ls_document_item TO ls_document-to_reservation_document_item.

        TRY.
            DATA(lv_base_unit) = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = ls_item-baseunit ).
            ##NO_HANDLER
          CATCH zzcx_custom_exception.
            " handle exception
        ENDTRY.

        APPEND VALUE #( reservation_item            = lv_itemno
                        plant                       = ls_item-plant
                        material                    = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = ls_item-material )
                        material_group              = ls_item-materialgroup
                        laboratory_or_design_office = ls_item-laboratoryordesignoffice
                        external_product_group      = ls_item-externalproductgroup
                        size_or_dimension_text      = ls_item-sizeordimensiontext
                        base_unit                   = lv_base_unit
                        g_r_slips_quantity          = ls_item-gr_slipsquantity
                        storage_location_from       = ls_item-storagelocationfrom
                        storage_location_to         = ls_item-storagelocationto
                        storage_location_from_stock = ls_item-storagelocationfromstock
                        storage_location_to_stock   = ls_item-storagelocationtostock
                        total_required_quantity     = ls_item-totalrequiredquantity
                        total_short_fall_quantity   = ls_item-totalshortfallquantity
                        total_transfer_quantity     = ls_item-totaltransferquantity
                        m_c_a_r_d_quantity          = ls_item-m_card_quantity
                        m_c_a_r_d                   = ls_item-m_card
                        created_date                = cs_data-datetime+0(8)
                        created_time                = cs_data-datetime+8(6)
                        created_by_user             = cs_data-user
                        created_by_user_name        = cs_data-username
                        last_changed_date           = cs_data-datetime+0(8)
                        last_changed_time           = cs_data-datetime+8(6)
                        last_changed_by_user        = cs_data-user
                        last_changed_by_user_name   = cs_data-username ) TO lt_head_table.

        /ui2/cl_json=>deserialize( EXPORTING json = ls_item-detailsjson
                                             pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                   CHANGING  data = lt_temp_table ).

        LOOP AT lt_temp_table ASSIGNING FIELD-SYMBOL(<lfs_temp_table>).
          TRY.
              lv_base_unit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_temp_table>-base_unit ).
              ##NO_HANDLER
            CATCH zzcx_custom_exception.
              " handle exception
          ENDTRY.
          <lfs_temp_table>-reservation_item          = lv_itemno.
          <lfs_temp_table>-manufacturing_order       = |{ <lfs_temp_table>-manufacturing_order ALPHA = IN }|.
          <lfs_temp_table>-product                   = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_temp_table>-product ).
          <lfs_temp_table>-base_unit                 = lv_base_unit.
          <lfs_temp_table>-created_date              = cs_data-datetime+0(8).
          <lfs_temp_table>-created_time              = cs_data-datetime+8(6).
          <lfs_temp_table>-created_by_user           = cs_data-user.
          <lfs_temp_table>-created_by_user_name      = cs_data-username.
          <lfs_temp_table>-last_changed_date         = cs_data-datetime+0(8).
          <lfs_temp_table>-last_changed_time         = cs_data-datetime+8(6).
          <lfs_temp_table>-last_changed_by_user      = cs_data-user.
          <lfs_temp_table>-last_changed_by_user_name = cs_data-username.
        ENDLOOP.
        APPEND LINES OF lt_temp_table TO lt_item_table.
      ENDIF.
    ENDLOOP.

    IF cs_data-messageitems IS NOT INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_document )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    REPLACE ALL OCCURRENCES OF `Issuingorreceivingstorageloc`   IN lv_requestbody WITH 'IssuingOrReceivingStorageLoc'.
    REPLACE ALL OCCURRENCES OF `Resvnitmrequiredqtyinentryunit` IN lv_requestbody WITH 'ResvnItmRequiredQtyInEntryUnit'.
    REPLACE ALL OCCURRENCES OF `ToReservationDocumentItem`      IN lv_requestbody WITH 'to_ReservationDocumentItem'.

    GET TIME STAMP FIELD lv_timestamp.
    zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = |/API_RESERVATION_DOCUMENT_SRV/A_ReservationDocumentHeader?sap-language={ zzcl_common_utils=>get_current_language(  ) }|
                                                 iv_method      = if_web_http_client=>post
                                                 iv_body        = lv_requestbody
                                       IMPORTING ev_status_code = DATA(lv_status_code)
                                                 ev_response    = DATA(lv_response) ).
    IF lv_status_code = 201. " created
      xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore )
        ( xco_cp_json=>transformation->boolean_to_abap_bool )
      ) )->write_to( REF #( ls_response ) ).

      CLEAR ls_head_table.
      ls_head_table-reservation = ls_response-d-reservation.
      ls_head_table-local_last_changed_at = lv_timestamp.
      MODIFY lt_head_table FROM ls_head_table TRANSPORTING reservation local_last_changed_at WHERE local_last_changed_at IS INITIAL.

      CLEAR ls_item_table.
      ls_item_table-reservation = ls_response-d-reservation.
      ls_item_table-local_last_changed_at = lv_timestamp.
      MODIFY lt_item_table FROM ls_item_table TRANSPORTING reservation local_last_changed_at WHERE local_last_changed_at IS INITIAL.

      MODIFY ztpp_1015 FROM TABLE @lt_head_table.
      MODIFY ztpp_1016 FROM TABLE @lt_item_table.

      MESSAGE s080(zpp_001) WITH |{ TEXT-003 } { ls_response-d-reservation }| INTO lv_message.
      APPEND VALUE #( type        = lc_type_s
                      title       = TEXT-002
                      subtitle    = lv_message
                      description = lv_message ) TO cs_data-messageitems.
    ELSE.
      /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                 CHANGING  data = ls_error ).

      APPEND VALUE #( type        = lc_type_e
                      title       = TEXT-001
                      subtitle    = lv_message
                      description = ls_error-error-message-value ) TO cs_data-messageitems.
    ENDIF.
  ENDMETHOD.

  METHOD save.
    DATA: lv_message   TYPE string,
          lv_timestamp TYPE tzntstmpl.

    LOOP AT cs_data-items ASSIGNING FIELD-SYMBOL(<lfs_item>).
      MODIFY ENTITIES OF i_reservationdocumenttp PRIVILEGED
      ENTITY reservationdocumentitem
      UPDATE FROM VALUE #( ( %tky-reservation     = <lfs_item>-reservation
                             %tky-reservationitem = <lfs_item>-reservationitem
                             %tky-recordtype      = ''
                             storagelocation      = <lfs_item>-storagelocationfrom
                             resvnitmrequiredqtyinentryunit = <lfs_item>-totaltransferquantity
                             %control-storagelocation = cl_abap_behv=>flag_changed
                             %control-resvnitmrequiredqtyinentryunit = cl_abap_behv=>flag_changed ) )
      FAILED DATA(ls_update_failed)
      REPORTED DATA(ls_update_reported).

      IF ls_update_failed IS INITIAL.
        GET TIME STAMP FIELD lv_timestamp.
        UPDATE ztpp_1015 SET storage_location_from     = @<lfs_item>-storagelocationfrom,
                             total_transfer_quantity   = @<lfs_item>-totaltransferquantity,
                             last_changed_date         = @cs_data-datetime+0(8),
                             last_changed_time         = @cs_data-datetime+8(6),
                             last_changed_by_user      = @cs_data-user,
                             last_changed_by_user_name = @cs_data-username,
                             local_last_changed_at     = @lv_timestamp
                       WHERE reservation = @<lfs_item>-reservation
                         AND reservation_item = @<lfs_item>-reservationitem.

        DATA(lv_reservation) = |{ <lfs_item>-reservation ALPHA = OUT }|.
        DATA(lv_reservationitem) = |{ <lfs_item>-reservationitem ALPHA = OUT }|.
        MESSAGE s091(zpp_001) WITH lv_reservation lv_reservationitem TEXT-004 INTO lv_message.
        APPEND VALUE #( type        = lc_type_s
                        title       = TEXT-002
                        subtitle    = lv_message
                        description = lv_message ) TO cs_data-messageitems.

      ELSE.
        LOOP AT ls_update_reported-reservationdocumentitem INTO DATA(ls_reported).
          lv_message = get_message( ls_reported-%msg ).

          APPEND VALUE #( type        = lc_type_e
                          title       = TEXT-001
                          subtitle    = lv_message
                          description = lv_message ) TO cs_data-messageitems.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA: lv_message   TYPE string,
          lv_timestamp TYPE tzntstmpl.

    LOOP AT cs_data-items ASSIGNING FIELD-SYMBOL(<lfs_item>).
      MODIFY ENTITIES OF i_reservationdocumenttp PRIVILEGED
      ENTITY reservationdocumentitem
      UPDATE FROM VALUE #( ( %tky-reservation        = <lfs_item>-reservation
                             %tky-reservationitem    = <lfs_item>-reservationitem
                             %tky-recordtype         = ''
                             reservationitmismarkedfordeltn = abap_true
                             %control-reservationitmismarkedfordeltn = cl_abap_behv=>flag_changed ) )
      FAILED DATA(ls_update_failed)
      REPORTED DATA(ls_update_reported).

      IF ls_update_failed IS INITIAL.
        GET TIME STAMP FIELD lv_timestamp.
        UPDATE ztpp_1015 SET delete_flag               = @abap_true,
                             last_changed_date         = @cs_data-datetime+0(8),
                             last_changed_time         = @cs_data-datetime+8(6),
                             last_changed_by_user      = @cs_data-user,
                             last_changed_by_user_name = @cs_data-username,
                             local_last_changed_at     = @lv_timestamp
                       WHERE reservation = @<lfs_item>-reservation
                         AND reservation_item = @<lfs_item>-reservationitem.

        DATA(lv_reservation) = |{ <lfs_item>-reservation ALPHA = OUT }|.
        DATA(lv_reservationitem) = |{ <lfs_item>-reservationitem ALPHA = OUT }|.
        MESSAGE s091(zpp_001) WITH lv_reservation lv_reservationitem TEXT-005 INTO lv_message.
        APPEND VALUE #( type        = lc_type_s
                        title       = TEXT-002
                        subtitle    = lv_message
                        description = lv_message ) TO cs_data-messageitems.

      ELSE.
        LOOP AT ls_update_reported-reservationdocumentitem INTO DATA(ls_reported).
          lv_message = get_message( ls_reported-%msg ).

          APPEND VALUE #( type        = lc_type_e
                          title       = TEXT-001
                          subtitle    = lv_message
                          description = lv_message ) TO cs_data-messageitems.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_message.
    MESSAGE ID io_message->if_t100_message~t100key-msgid
       TYPE io_message->m_severity
     NUMBER io_message->if_t100_message~t100key-msgno
       WITH io_message->if_t100_dyn_msg~msgv1
            io_message->if_t100_dyn_msg~msgv2
            io_message->if_t100_dyn_msg~msgv3
            io_message->if_t100_dyn_msg~msgv4 INTO rv_msg.
  ENDMETHOD.

ENDCLASS.
