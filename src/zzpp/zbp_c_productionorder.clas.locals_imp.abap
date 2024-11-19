CLASS lhc_zc_productionorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF lty_messageitem,
        type        TYPE string,
        title       TYPE string,
        description TYPE string,
        subtitle    TYPE string,
      END OF lty_messageitem,

      BEGIN OF lty_request,
        items        TYPE TABLE OF zc_productionorder WITH DEFAULT KEY,
        user         TYPE string,
        username     TYPE string,
        datetime     TYPE string,
        messageitems TYPE TABLE OF lty_messageitem WITH DEFAULT KEY,
      END OF lty_request.

    CONSTANTS:
      lc_msgid_zpp_001    TYPE string VALUE 'ZPP_001',
      lc_msgty_e          TYPE string VALUE 'E',
      lc_type_e           TYPE string VALUE `Error`,
      lc_type_s           TYPE string VALUE `Success`,
      lc_producttype_zfrt TYPE string VALUE 'ZFRT',
      lc_strategygroup_40 TYPE string VALUE '40',
      lc_criticality_1    TYPE string VALUE '1',
      lc_criticality_3    TYPE string VALUE '3',
      lc_event_release    TYPE string VALUE 'RELEASE',
      lc_seprator_virgule TYPE string VALUE '/'.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR productionorder RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION productionorder~processlogic RESULT result.

    METHODS release CHANGING cs_data TYPE lty_request.

    METHODS check CHANGING cs_data TYPE lty_request.

*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE ProductionOrder.
*
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE productionorder.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE ProductionOrder.
*
*    METHODS read FOR READ
*      IMPORTING keys FOR READ productionorder RESULT result.
*
*    METHODS lock FOR LOCK
*      IMPORTING keys FOR LOCK productionorder.

ENDCLASS.

CLASS lhc_zc_productionorder IMPLEMENTATION.

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
        WHEN lc_event_release.
          release( CHANGING cs_data = ls_request ).
        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

*  METHOD create.
*  ENDMETHOD.
*
*  METHOD update.
*  ENDMETHOD.
*
*  METHOD delete.
*  ENDMETHOD.
*
*  METHOD read.
*  ENDMETHOD.
*
*  METHOD lock.
*  ENDMETHOD.

  METHOD release.
    DATA:
      lv_manufacturingorder TYPE zc_productionorder-manufacturingorder,
      lv_message            TYPE zc_productionorder-message.

    check( CHANGING cs_data = cs_data ).

    CHECK cs_data-messageitems IS INITIAL.

    LOOP AT cs_data-items ASSIGNING FIELD-SYMBOL(<fs_item>).
      lv_manufacturingorder = |{ <fs_item>-manufacturingorder ALPHA = IN }|.

      MODIFY ENTITY PRIVILEGED i_productionordertp
      EXECUTE release
      FROM VALUE #( ( %key-productionorder = lv_manufacturingorder %param-ordrelispmtddsptmisgparts = abap_true ) )
      REQUEST VALUE #( )
      RESULT DATA(result_rel)
      FAILED DATA(failed_rel)
      REPORTED DATA(reported_rel).

      IF failed_rel IS NOT INITIAL.
        LOOP AT reported_rel-productionorder INTO DATA(ls_productionorder).
          IF ls_productionorder-%msg->if_t100_dyn_msg~msgty CA 'EAX'.
            DATA(lv_msgid) = ls_productionorder-%msg->if_t100_message~t100key-msgid.
            DATA(lv_msgno) = ls_productionorder-%msg->if_t100_message~t100key-msgno.
            DATA(lv_msgty) = ls_productionorder-%msg->if_t100_dyn_msg~msgty.
            DATA(lv_msgv1) = ls_productionorder-%msg->if_t100_dyn_msg~msgv1.
            DATA(lv_msgv2) = ls_productionorder-%msg->if_t100_dyn_msg~msgv2.
            DATA(lv_msgv3) = ls_productionorder-%msg->if_t100_dyn_msg~msgv3.
            DATA(lv_msgv4) = ls_productionorder-%msg->if_t100_dyn_msg~msgv4.
            MESSAGE ID lv_msgid TYPE lv_msgty NUMBER lv_msgno WITH lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4 INTO lv_message.

            IF <fs_item>-message IS INITIAL.
              <fs_item>-message = lv_message.
            ELSE.
              CONCATENATE <fs_item>-message
                          lv_message
                     INTO <fs_item>-message
                SEPARATED BY lc_seprator_virgule.
            ENDIF.
          ENDIF.
        ENDLOOP.

        <fs_item>-criticality = lc_criticality_1.
        lv_message = <fs_item>-message.

        "製造指図 &1: &2
        MESSAGE ID lc_msgid_zpp_001 TYPE lc_msgty_e NUMBER 099 WITH lv_manufacturingorder lv_message INTO lv_message.

        APPEND VALUE #( type        = lc_type_e
                        title       = lc_type_e
                        subtitle    = lv_message
                        description = lv_message ) TO cs_data-messageitems.
      ELSE.
        <fs_item>-criticality = lc_criticality_3.

        "Production Order &1 was released successfully.
        "製造指図 &1 発行できました。
        MESSAGE ID lc_msgid_zpp_001 TYPE lc_msgty_e NUMBER 100 WITH lv_manufacturingorder INTO lv_message.

        <fs_item>-message = lv_message.

        APPEND VALUE #( type        = lc_type_s
                        title       = lc_type_s
                        subtitle    = lv_message
                        description = lv_message ) TO cs_data-messageitems.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check.
    DATA:
      lv_message            TYPE zc_productionorder-message,
      lv_assign_qty         TYPE ztpp_1014-assign_qty,
      lv_manufacturingorder TYPE aufnr.

    CHECK cs_data-items IS NOT INITIAL.

    DATA(lt_items) = cs_data-items.

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<fs_item>).
      <fs_item>-manufacturingorder = |{ <fs_item>-manufacturingorder ALPHA = IN }|.
    ENDLOOP.


    "Obtain data of product plant supply planning
    SELECT product,
           plant,
           planningstrategygroup
      FROM i_productplantsupplyplanning
       FOR ALL ENTRIES IN @lt_items
     WHERE plant = @lt_items-plant
       AND product = @lt_items-material
      INTO TABLE @DATA(lt_planning).

    "Obtain data of allocation relationship between production order and so
    SELECT plant,
           manufacturing_order,
           sales_order,
           sales_order_item,
           sequence,
           assign_qty
      FROM ztpp_1014
       FOR ALL ENTRIES IN @lt_items
     WHERE plant = @lt_items-plant
       AND manufacturing_order = @lt_items-manufacturingorder
       AND assign_qty <> 0
      INTO TABLE @DATA(lt_ztpp_1014).

    SORT lt_planning BY product plant.
    SORT lt_ztpp_1014 BY plant manufacturing_order.

    LOOP AT cs_data-items ASSIGNING <fs_item>.
      lv_manufacturingorder = |{ <fs_item>-manufacturingorder ALPHA = IN }|.

      "Read data of product plant supply planning
      READ TABLE lt_planning INTO DATA(ls_planning) WITH KEY product = <fs_item>-material
                                                             plant = <fs_item>-plant
                                                     BINARY SEARCH.

      "Read data of allocation relationship between production order and so
      READ TABLE lt_ztpp_1014 TRANSPORTING NO FIELDS WITH KEY plant = <fs_item>-plant
                                                              manufacturing_order = lv_manufacturingorder
                                                     BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_ztpp_1014 INTO DATA(ls_ztpp_1014) FROM sy-tabix.
          IF ls_ztpp_1014-plant <> <fs_item>-plant
          OR ls_ztpp_1014-manufacturing_order <> lv_manufacturingorder.
            EXIT.
          ENDIF.

          lv_assign_qty = lv_assign_qty + ls_ztpp_1014-assign_qty.
        ENDLOOP.

        IF <fs_item>-mfgorderplannedtotalqty > lv_assign_qty.
          "製造指図の生産計画数が割当合計数より多くなる。
          MESSAGE ID lc_msgid_zpp_001 TYPE lc_msgty_e NUMBER 086 INTO lv_message .

          <fs_item>-criticality = lc_criticality_1.
          <fs_item>-message = lv_message.

          "製造指図 &1: &2
          MESSAGE ID lc_msgid_zpp_001 TYPE lc_msgty_e NUMBER 099 WITH <fs_item>-manufacturingorder lv_message INTO lv_message.

          APPEND VALUE #( type        = lc_type_e
                          title       = lc_type_e
                          subtitle    = lv_message
                          description = lv_message ) TO cs_data-messageitems.
        ENDIF.
      ELSE.
        IF <fs_item>-producttype = lc_producttype_zfrt AND ls_planning-planningstrategygroup = lc_strategygroup_40.
          "当該製造指図に受注を割当してください。
          MESSAGE ID lc_msgid_zpp_001 TYPE lc_msgty_e NUMBER 087 INTO lv_message.

          <fs_item>-criticality = lc_criticality_1.
          <fs_item>-message = lv_message.

          "製造指図 &1: &2
          MESSAGE ID lc_msgid_zpp_001 TYPE lc_msgty_e NUMBER 099 WITH <fs_item>-manufacturingorder lv_message INTO lv_message.

          APPEND VALUE #( type        = lc_type_e
                          title       = lc_type_e
                          subtitle    = lv_message
                          description = lv_message ) TO cs_data-messageitems.
        ENDIF.
      ENDIF.

      CLEAR:
        ls_planning,
        lv_assign_qty.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_zc_productionorder DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zc_productionorder IMPLEMENTATION.
  METHOD save_modified.
  ENDMETHOD.
ENDCLASS.
