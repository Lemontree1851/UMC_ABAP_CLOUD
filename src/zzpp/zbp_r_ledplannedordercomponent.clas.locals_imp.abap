CLASS lhc_zr_ledplannedordercomponen DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_messageitem,
            type        TYPE string,
            title       TYPE string,
            description TYPE string,
            subtitle    TYPE string,
          END OF lty_messageitem.

    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_ledplannedordercomponent.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    CONSTANTS: lc_event_accept TYPE string VALUE 'ACCEPT',
               lc_msgty_e(1)   TYPE c      VALUE 'E'.

    METHODS        get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_ledplannedordercomponent RESULT result.

*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE zr_ledplannedordercomponent.
*
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zr_ledplannedordercomponent.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE zr_ledplannedordercomponent.

    METHODS read FOR READ
      IMPORTING keys FOR READ zr_ledplannedordercomponent RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zr_ledplannedordercomponent.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION zr_ledplannedordercomponent~processlogic RESULT result.

    METHODS accept CHANGING ct_data TYPE lty_request_t.

ENDCLASS.

CLASS lhc_zr_ledplannedordercomponen IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD create.
*  ENDMETHOD.
*
  METHOD update.
  ENDMETHOD.
*
*  METHOD delete.
*  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD processlogic.
    DATA: lt_request TYPE TABLE OF lty_request.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).

      CASE lv_event.
        WHEN lc_event_accept.
          "accept
          accept( CHANGING ct_data = lt_request ).
        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD accept.

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<fs_l_data>).
      IF <fs_l_data>-message IS INITIAL
      AND <fs_l_data>-requiredquantity IS INITIAL.
        MODIFY ENTITIES OF i_plannedordertp PRIVILEGED
             ENTITY plannedordercomponent
             UPDATE FIELDS ( goodsmovemententryqty )
             WITH VALUE #( (
                plannedorder              = <fs_l_data>-plannedorder
                reservation               = <fs_l_data>-reservation
                reservationitem           = <fs_l_data>-reservationitem
                goodsmovemententryqty     = <fs_l_data>-requiredquantity
                %control = VALUE #( goodsmovemententryqty = cl_abap_behv=>flag_changed
                ) ) )
             FAILED DATA(ls_failed)
             REPORTED DATA(ls_reported).
        IF ls_failed IS INITIAL AND ls_reported IS INITIAL.
          CLEAR:
            ls_failed,
            ls_reported.
          MODIFY ENTITIES OF i_plannedordertp PRIVILEGED
               ENTITY plannedorder
               UPDATE FIELDS ( plannedorderisfirm plannedorderbomisfixed )
               WITH VALUE #( (
                  plannedorder              = <fs_l_data>-plannedorder
                  plannedorderisfirm        = abap_on
                  plannedorderbomisfixed    = abap_on
                  %control = VALUE #( plannedorderisfirm = cl_abap_behv=>flag_changed
                                      plannedorderbomisfixed = cl_abap_behv=>flag_changed
                  ) ) )
               FAILED ls_failed
               REPORTED ls_reported.
          IF ls_failed IS INITIAL AND ls_reported IS INITIAL.
            <fs_l_data>-status = '3'.
            <fs_l_data>-statustext = 'Success'.
*           提案が受入できました。
            MESSAGE s102(zpp_001) INTO <fs_l_data>-message.
          ENDIF.
        ELSE.
          DATA(lv_msgid) = ls_reported-plannedordercomponent[ 1 ]-%msg->if_t100_message~t100key-msgid.
          DATA(lv_msgno) = ls_reported-plannedordercomponent[ 1 ]-%msg->if_t100_message~t100key-msgno.
          DATA(lv_msgty) = ls_reported-plannedordercomponent[ 1 ]-%msg->if_t100_dyn_msg~msgty.
          DATA(lv_msgv1) = ls_reported-plannedordercomponent[ 1 ]-%msg->if_t100_dyn_msg~msgv1.
          DATA(lv_msgv2) = ls_reported-plannedordercomponent[ 1 ]-%msg->if_t100_dyn_msg~msgv2.
          DATA(lv_msgv3) = ls_reported-plannedordercomponent[ 1 ]-%msg->if_t100_dyn_msg~msgv3.
          DATA(lv_msgv4) = ls_reported-plannedordercomponent[ 1 ]-%msg->if_t100_dyn_msg~msgv4.
          MESSAGE ID lv_msgid TYPE lv_msgty NUMBER lv_msgno WITH lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4 INTO <fs_l_data>-message.
          if lv_msgty = 'W'.
            <fs_l_data>-status = '3'.
            <fs_l_data>-statustext = 'Success'.
*           提案が受入できました。
            MESSAGE s102(zpp_001) INTO <fs_l_data>-message.
          ENDIF.
        ENDIF.
      ELSEIF <fs_l_data>-message IS NOT INITIAL.
        <fs_l_data>-status = '1'.
        <fs_l_data>-statustext = 'Error'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_zr_ledplannedordercomponen DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_ledplannedordercomponen IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
