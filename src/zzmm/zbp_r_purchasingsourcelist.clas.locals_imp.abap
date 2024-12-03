CLASS lhc_sourcelist DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_purchasingsourcelist.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR sourcelist RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION sourcelist~processlogic RESULT result.

    METHODS excute CHANGING ct_data TYPE lty_request_t.

ENDCLASS.

CLASS lhc_sourcelist IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD processlogic.
    DATA lt_request TYPE TABLE OF lty_request.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.


    LOOP AT keys INTO DATA(key).
      "key-%param-zzkey = '[' && key-%param-zzkey && ']'.
      CLEAR lt_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).

      CASE lv_event.

        WHEN 'EXCUTE'.
          excute( CHANGING ct_data = lt_request ).

        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD excute.
    TYPES:
      BEGIN OF ts_sourcelist,
        _material                    TYPE string,
        _plant                       TYPE string,
        _validity_start_date         TYPE string,
        _validity_end_date           TYPE string,
        _supplier                    TYPE string,
        _supplying_plant             TYPE string,
        _source_of_supply_is_blocked TYPE abap_bool,
        _purchasing_organization     TYPE string,
        _m_r_p_sourcing_control      TYPE string,
      END OF ts_sourcelist,

      BEGIN OF ty_message,
        lang  TYPE string,
        value TYPE string,
      END OF ty_message,

      BEGIN OF ty_error,
        code    TYPE string,
        message TYPE ty_message,
      END OF ty_error,

      BEGIN OF ty_res_api,
        error TYPE ty_error,
      END OF ty_res_api.

    DATA:
      lt_sourcelist    TYPE STANDARD TABLE OF ts_sourcelist,
      ls_sourcelist    TYPE ts_sourcelist,
      ls_res_api       TYPE ty_res_api,
      lt_header_create TYPE TABLE FOR CREATE i_purchasingsourcelisttp,
      ls_header_create TYPE STRUCTURE FOR CREATE i_purchasingsourcelisttp,
      lt_item_create   TYPE TABLE FOR CREATE i_purchasingsourcelisttp\_purchasingsourceitem,
      ls_item_create   TYPE STRUCTURE FOR CREATE i_purchasingsourcelisttp\_purchasingsourceitem,
      lt_item_update   TYPE TABLE FOR UPDATE i_purchasingsourcelistitemtp,
      ls_item_update   TYPE STRUCTURE FOR UPDATE i_purchasingsourcelistitemtp,
      lt_header_delete TYPE TABLE FOR DELETE i_purchasingsourcelisttp,
      ls_header_delete TYPE STRUCTURE FOR DELETE i_purchasingsourcelisttp,
      lt_item_delete   TYPE TABLE FOR DELETE i_purchasingsourcelistitemtp,
      ls_item_delete   TYPE STRUCTURE FOR DELETE i_purchasingsourcelistitemtp.
    DATA:
      lo_root_exc TYPE REF TO cx_root,
      lv_path     TYPE string,
      lv_usage(1) TYPE c,
      i           TYPE i,
      m           TYPE i,
      n           TYPE i,
      lv_message  TYPE string,
      lv_matnr    TYPE c LENGTH 18,
      lc_null     TYPE c VALUE '-'.


    READ TABLE ct_data ASSIGNING FIELD-SYMBOL(<ls_data>) INDEX 1.
    lv_usage = <ls_data>-xflag. "A/B/C

    CASE lv_usage.
      WHEN 'A'.     "Create
*        LOOP AT ct_data ASSIGNING <ls_data>
*                GROUP BY ( matnr = <ls_data>-material
*                           werks = <ls_data>-plant )
*                  REFERENCE INTO DATA(member).
*          i += 1.
*
*          LOOP AT GROUP member ASSIGNING FIELD-SYMBOL(<lfs_member>).
*            m += 1.
*            "Header
*            ls_header_create-%cid = |My%HeaderCID_{ i }|.
*            ls_header_create-material = zzcl_common_utils=>conversion_matn1(
*                                     EXPORTING iv_alpha = 'IN'
*                                               iv_input = <lfs_member>-material ).
*            ls_header_create-plant = <lfs_member>-plant.
*            APPEND ls_header_create TO lt_header_create.
*            "item
*            ls_item_create-%cid_ref = |My%HeaderCID_{ i }|.
*            ls_item_create-material = ls_header_create-material.
*            ls_item_create-plant = ls_header_create-plant.
*            ls_item_create-%target = VALUE #( (
*                                       %cid = |My%HeaderCID_{ i }_ItemCID_{ m }|
*                                       validitystartdate = <lfs_member>-validitystartdate
*                                       validityenddate = <lfs_member>-validityenddate
*                                       supplier = |{ <lfs_member>-supplier ALPHA = IN }|
*                                       purchasingorganization = <lfs_member>-purchasingorganization
*                                       supplierisfixed = <lfs_member>-supplierisfixed
*                                       sourceofsupplyisblocked = <lfs_member>-sourceofsupplyisblocked
*                                       mrpsourcingcontrol = <lfs_member>-mrpsourcingcontrol
*                                       ) ).
*            APPEND ls_item_create TO lt_item_create.
*
*            CLEAR: ls_item_create.
*          ENDLOOP.
*          SORT lt_header_create BY material plant.
*          DELETE ADJACENT DUPLICATES FROM lt_header_create COMPARING material plant.
*          "BOI
*          MODIFY ENTITIES OF i_purchasingsourcelisttp PRIVILEGED ##EML_IN_LOOP_OK
*              ENTITY purchasingsourcelist CREATE FROM lt_header_create
*               CREATE BY \_purchasingsourceitem FROM lt_item_create
*               FAILED DATA(ls_failed)
*               REPORTED DATA(ls_reported)
*               MAPPED DATA(ls_mapped).
*
*          IF ls_failed IS INITIAL.
*            DATA(lv_status) = 'S'.
*            MESSAGE s006(zmm_001) INTO lv_message.
*          ELSE.
*            lv_status = 'E'.
*            LOOP AT ls_reported-purchasingsourcelist INTO DATA(ls_list).
*              DATA(lv_msgty) = ls_list-%msg->if_t100_dyn_msg~msgty.
*              IF lv_msgty = 'A'
*              OR lv_msgty = 'E'.
*                DATA(lv_text) = ls_list-%msg->if_message~get_text( ).
*                lv_message = zzcl_common_utils=>merge_message(
*                               iv_message1 = lv_message
*                               iv_message2 = lv_text
*                               iv_symbol = '\' ).
*              ENDIF.
*            ENDLOOP.
*
*            LOOP AT ls_reported-purchasingsourcelistitem INTO DATA(ls_listitem).
*              lv_msgty = ls_listitem-%msg->if_t100_dyn_msg~msgty.
*              IF lv_msgty = 'A'
*              OR lv_msgty = 'E'.
*                lv_text = ls_listitem-%msg->if_message~get_text( ).
*                lv_message = zzcl_common_utils=>merge_message(
*                               iv_message1 = lv_message
*                               iv_message2 = lv_text
*                               iv_symbol = '\' ).
*              ENDIF.
*            ENDLOOP.
*          ENDIF.
*
*          CLEAR: i,m.
*        ENDLOOP.
*        LOOP AT ct_data ASSIGNING <ls_data>.
*          <lfs_member>-status = lv_status.
*          <lfs_member>-message = lv_message.
*        ENDLOOP.
        LOOP AT ct_data ASSIGNING <ls_data>.
          ls_sourcelist-_material = <ls_data>-material.
          ls_sourcelist-_plant = <ls_data>-plant.
          ls_sourcelist-_validity_start_date = <ls_data>-validitystartdate+0(4)
                                             && '-' && <ls_data>-validitystartdate+4(2)
                                             && '-' && <ls_data>-validitystartdate+6(2)
                                             && 'T00:00:00'.
          ls_sourcelist-_validity_end_date = <ls_data>-validityenddate+0(4)
                                             && '-' && <ls_data>-validityenddate+4(2)
                                             && '-' && <ls_data>-validityenddate+6(2)
                                             && 'T00:00:00'.
          ls_sourcelist-_supplier = <ls_data>-supplier.

          IF <ls_data>-sourceofsupplyisblocked = 'X'.
            ls_sourcelist-_source_of_supply_is_blocked = abap_true.
          ELSE.
            <ls_data>-sourceofsupplyisblocked = abap_false.
          ENDIF.
          ls_sourcelist-_purchasing_organization = <ls_data>-purchasingorganization.
          ls_sourcelist-_m_r_p_sourcing_control = <ls_data>-mrpsourcingcontrol.
          APPEND ls_sourcelist TO lt_sourcelist.

          lv_path = '/API_PURCHASING_SOURCE_SRV/A_PurchasingSource'.
          DATA(lv_reqbody_api) = /ui2/cl_json=>serialize( data = ls_sourcelist
                                                      compress = 'X'
                                                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
          zzcl_common_utils=>request_api_v2(
            EXPORTING
              iv_path        = lv_path
              iv_method      = if_web_http_client=>post
              iv_body        = lv_reqbody_api
            IMPORTING
              ev_status_code = DATA(lv_stat_code)
              ev_response    = DATA(lv_resbody_api) ).
          xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
              ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_res_api ) ).

          IF lv_stat_code = '201'.
            DATA(lv_status) = 'S'.
            MESSAGE s006(zmm_001) INTO lv_message.
            "Call boi update
            IF <ls_data>-supplierisfixed IS NOT INITIAL.
              SELECT SINGLE
                     a~material,                "#EC CI_FAE_NO_LINES_OK
                     a~plant,
                     b~sourcelistrecord,
                     b~validitystartdate,
                     b~validityenddate,
                     b~supplier,
                     b~purchasingorganization,
                     b~supplierisfixed,
                     b~sourceofsupplyisblocked,
                     b~mrpsourcingcontrol
                FROM i_purchasingsourcelisttp WITH PRIVILEGED ACCESS AS a
                INNER JOIN i_purchasingsourcelistitemtp WITH PRIVILEGED ACCESS AS b
                ON ( a~material = b~material
                 AND a~plant = b~plant )
               WHERE a~material = @<ls_data>-material
                 AND a~plant = @<ls_data>-plant
                 AND b~supplier = @<ls_data>-supplier
                 AND b~purchasingorganization = @<ls_data>-purchasingorganization
                INTO @DATA(ls_list).

              ls_item_update-supplierisfixed = 'X'.
              ls_item_update-%control-supplierisfixed = if_abap_behv=>mk-on.

              ls_item_update-supplier = ls_list-supplier.
              ls_item_update-purchasingorganization = ls_list-purchasingorganization.
              ls_item_update-validitystartdate = ls_list-validitystartdate.
              ls_item_update-validityenddate = ls_list-validityenddate.
              ls_item_update-sourceofsupplyisblocked = ls_list-sourceofsupplyisblocked.
              ls_item_update-mrpsourcingcontrol = ls_list-mrpsourcingcontrol.

              ls_item_update-%key-material = ls_list-material.
              ls_item_update-%key-plant = ls_list-plant.
              ls_item_update-%key-sourcelistrecord = ls_list-sourcelistrecord.
              ls_item_update-material = ls_list-material.
              ls_item_update-plant = ls_list-plant.
              ls_item_update-sourcelistrecord = ls_list-sourcelistrecord.
              APPEND ls_item_update TO lt_item_update.

              IF lt_item_update IS NOT INITIAL.
                MODIFY ENTITIES OF i_purchasingsourcelisttp PRIVILEGED ##EML_IN_LOOP_OK
                  ENTITY purchasingsourcelistitem  UPDATE FROM lt_item_update
                  FAILED DATA(ls_failed)
                  REPORTED DATA(ls_reported)
                  MAPPED DATA(ls_mapped).


                IF sy-subrc = 0
               AND ls_failed IS INITIAL.
                  lv_status = 'S'.
                  MESSAGE s006(zmm_001) INTO lv_message.
                ELSE.
                  lv_status = 'E'.
                  LOOP AT ls_reported-purchasingsourcelistitem INTO DATA(ls_listitem).
                    DATA(lv_msgty) = ls_listitem-%msg->if_t100_dyn_msg~msgty.
                    IF lv_msgty = 'A'
                    OR lv_msgty = 'E'.
                      DATA(lv_text) = ls_listitem-%msg->if_message~get_text( ).
                      lv_message = zzcl_common_utils=>merge_message(
                                     iv_message1 = lv_message
                                     iv_message2 = lv_text
                                     iv_symbol = '\' ).
                    ENDIF.
                  ENDLOOP.
                ENDIF.
              ENDIF.
              CLEAR: ls_list, lt_item_update.
            ENDIF.
          ELSE.
            lv_status = 'E'.
            lv_message = ls_res_api-error-message-value.
          ENDIF.
          <ls_data>-status = lv_status.
          <ls_data>-message = lv_message.
        ENDLOOP.
      WHEN 'B'.     "Update
        LOOP AT ct_data ASSIGNING <ls_data>.
          <ls_data>-material = zzcl_common_utils=>conversion_matn1(
                                   EXPORTING iv_alpha = 'IN'
                                             iv_input = <ls_data>-material ).
        ENDLOOP.
        SELECT a~material,                      "#EC CI_FAE_NO_LINES_OK
               a~plant,
               b~sourcelistrecord,
               b~validitystartdate,
               b~validityenddate,
               b~supplier,
               b~purchasingorganization,
               b~supplierisfixed,
               b~sourceofsupplyisblocked,
               b~mrpsourcingcontrol
          FROM i_purchasingsourcelisttp WITH PRIVILEGED ACCESS AS a
          INNER JOIN i_purchasingsourcelistitemtp WITH PRIVILEGED ACCESS AS b
          ON ( a~material = b~material
           AND a~plant = b~plant )
          FOR ALL ENTRIES IN @ct_data
         WHERE a~material = @ct_data-material
           AND a~plant = @ct_data-plant
          INTO TABLE @DATA(lt_list).

        SORT lt_list BY material plant sourcelistrecord.
        LOOP AT ct_data ASSIGNING <ls_data>.
          READ TABLE lt_list INTO DATA(ls_list1)
               WITH KEY material = <ls_data>-material
                        plant = <ls_data>-plant
                        sourcelistrecord = <ls_data>-sourcelistrecord
               BINARY SEARCH.
          IF sy-subrc = 0.

* check field if changed:
** If import field is initial,the BOI will clear the value.
** So set the database value to the field if initial
            DATA(lv_lifnr) = |{ <ls_data>-supplier ALPHA = IN }|.
            IF <ls_data>-supplier IS NOT INITIAL
           AND lv_lifnr <> ls_list1-supplier.
              ls_item_update-supplier = lv_lifnr.
              ls_item_update-%control-supplier = if_abap_behv=>mk-on.
              DATA(lv_flg) = 'X'.
            ELSE.
              ls_item_update-supplier = ls_list1-supplier.
            ENDIF.

            IF <ls_data>-purchasingorganization IS NOT INITIAL
           AND <ls_data>-purchasingorganization <> ls_list1-purchasingorganization.
              ls_item_update-purchasingorganization = <ls_data>-purchasingorganization.
              ls_item_update-%control-purchasingorganization = if_abap_behv=>mk-on.
              lv_flg = 'X'.
            ELSE.
              ls_item_update-purchasingorganization = ls_list1-purchasingorganization.
            ENDIF.

            IF <ls_data>-validitystartdate IS NOT INITIAL
           AND <ls_data>-validitystartdate <> ls_list1-validitystartdate.
              ls_item_update-validitystartdate = <ls_data>-validitystartdate.
              ls_item_update-%control-validitystartdate = if_abap_behv=>mk-on.
              lv_flg = 'X'.
            ELSE.
              ls_item_update-validitystartdate = ls_list1-validitystartdate.
            ENDIF.

            IF <ls_data>-validityenddate IS NOT INITIAL
             AND <ls_data>-validityenddate <> ls_list1-validityenddate.
              ls_item_update-validityenddate = <ls_data>-validityenddate.
              ls_item_update-%control-validityenddate = if_abap_behv=>mk-on.
              lv_flg = 'X'.
            ELSE.
              ls_item_update-validityenddate = ls_list1-validityenddate.
            ENDIF.

            IF <ls_data>-supplierisfixed IS NOT INITIAL
           AND <ls_data>-supplierisfixed <> ls_list1-supplierisfixed.
              ls_item_update-supplierisfixed = <ls_data>-supplierisfixed.
              IF <ls_data>-supplierisfixed = lc_null.
                CLEAR: ls_item_update-supplierisfixed.
              ENDIF.
              ls_item_update-%control-supplierisfixed = if_abap_behv=>mk-on.
              lv_flg = 'X'.
            ELSE.
              ls_item_update-supplierisfixed = ls_list1-supplierisfixed.
            ENDIF.

            IF <ls_data>-sourceofsupplyisblocked IS NOT INITIAL
           AND <ls_data>-sourceofsupplyisblocked <> ls_list1-sourceofsupplyisblocked.
              ls_item_update-sourceofsupplyisblocked = <ls_data>-sourceofsupplyisblocked.
              IF <ls_data>-sourceofsupplyisblocked = lc_null.
                CLEAR: ls_item_update-sourceofsupplyisblocked.
              ENDIF.
              ls_item_update-%control-sourceofsupplyisblocked = if_abap_behv=>mk-on.
              lv_flg = 'X'.
            ELSE.
              ls_item_update-sourceofsupplyisblocked = ls_list1-sourceofsupplyisblocked.
            ENDIF.

            IF <ls_data>-mrpsourcingcontrol IS NOT INITIAL
             AND <ls_data>-mrpsourcingcontrol <> ls_list1-mrpsourcingcontrol.
              ls_item_update-mrpsourcingcontrol = <ls_data>-mrpsourcingcontrol.
              IF <ls_data>-mrpsourcingcontrol = lc_null.
                CLEAR: ls_item_update-mrpsourcingcontrol.
              ENDIF.
              ls_item_update-%control-mrpsourcingcontrol = if_abap_behv=>mk-on.
              lv_flg = 'X'.
            ELSE.
              ls_item_update-mrpsourcingcontrol = ls_list1-mrpsourcingcontrol.
            ENDIF.
          ENDIF.

          IF ls_item_update IS NOT INITIAL
         AND lv_flg = 'X'.
* Key

            ls_item_update-%key-material = <ls_data>-material.
            ls_item_update-%key-plant = <ls_data>-plant.
            ls_item_update-%key-sourcelistrecord = <ls_data>-sourcelistrecord.
            ls_item_update-material = <ls_data>-material.
            ls_item_update-plant = <ls_data>-plant.
            ls_item_update-sourcelistrecord = <ls_data>-sourcelistrecord.
            APPEND ls_item_update TO lt_item_update.
          ENDIF.
          CLEAR: ls_item_update, lv_flg.
        ENDLOOP.

        IF lt_item_update IS NOT INITIAL.
          MODIFY ENTITIES OF i_purchasingsourcelisttp PRIVILEGED ##EML_IN_LOOP_OK
            ENTITY purchasingsourcelistitem  UPDATE FROM lt_item_update
            FAILED ls_failed
            REPORTED ls_reported
            MAPPED ls_mapped.


          IF sy-subrc = 0
         AND ls_failed IS INITIAL.
            lv_status = 'S'.
            MESSAGE s008(zmm_001) INTO lv_message.
          ELSE.
            lv_status = 'E'.
            LOOP AT ls_reported-purchasingsourcelistitem INTO ls_listitem.
              lv_msgty = ls_listitem-%msg->if_t100_dyn_msg~msgty.
              IF lv_msgty = 'A'
              OR lv_msgty = 'E'.
                lv_text = ls_listitem-%msg->if_message~get_text( ).
                lv_message = zzcl_common_utils=>merge_message(
                               iv_message1 = lv_message
                               iv_message2 = lv_text
                               iv_symbol = '\' ).
              ENDIF.
            ENDLOOP.
          ENDIF.
        ELSE.
          lv_status = 'S'.
          lv_message = 'No Change'.
        ENDIF.

        LOOP AT ct_data ASSIGNING <ls_data>.
          <ls_data>-status = lv_status.
          <ls_data>-message = lv_message.
        ENDLOOP.
      WHEN 'C'.     "Delete
        LOOP AT ct_data ASSIGNING <ls_data>.
          ls_item_delete-%key-material = zzcl_common_utils=>conversion_matn1(
                                   EXPORTING iv_alpha = 'IN'
                                             iv_input = <ls_data>-material ).
          ls_item_delete-%key-plant = <ls_data>-plant.
          ls_item_delete-%key-sourcelistrecord = <ls_data>-sourcelistrecord.

          APPEND ls_item_delete TO lt_item_delete.
          CLEAR: ls_item_delete.
        ENDLOOP.
        MODIFY ENTITIES OF i_purchasingsourcelisttp PRIVILEGED ##EML_IN_LOOP_OK
                  ENTITY purchasingsourcelistitem  DELETE FROM lt_item_delete
                  FAILED ls_failed
                  REPORTED ls_reported
                  MAPPED ls_mapped.

        IF sy-subrc = 0
       AND ls_failed IS INITIAL.
          lv_status = 'S'.
          MESSAGE s015(zmm_001) INTO lv_message.
        ELSE.
          lv_status = 'E'.
          LOOP AT ls_reported-purchasingsourcelistitem INTO ls_listitem.
            lv_msgty = ls_listitem-%msg->if_t100_dyn_msg~msgty.
            IF lv_msgty = 'A'
            OR lv_msgty = 'E'.
              lv_text = ls_listitem-%msg->if_message~get_text( ).
              lv_message = zzcl_common_utils=>merge_message(
                             iv_message1 = lv_message
                             iv_message2 = lv_text
                             iv_symbol = '\' ).
            ENDIF.
          ENDLOOP.
        ENDIF.

        LOOP AT ct_data ASSIGNING <ls_data>.
          <ls_data>-status = lv_status.
          <ls_data>-message = lv_message.
        ENDLOOP.
      WHEN OTHERS.

    ENDCASE.


  ENDMETHOD.


ENDCLASS.
