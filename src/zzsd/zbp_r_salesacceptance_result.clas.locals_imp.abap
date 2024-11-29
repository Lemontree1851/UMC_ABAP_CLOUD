CLASS lhc_zr_salesacceptance_result DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_salesacceptance_result.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_salesacceptance_result RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zr_salesacceptance_result.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zr_salesacceptance_result.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zr_salesacceptance_result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zr_salesacceptance_result RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zr_salesacceptance_result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION zr_salesacceptance_result~processlogic RESULT result.

ENDCLASS.

CLASS lhc_zr_salesacceptance_result IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD processlogic.
    DATA: lt_request TYPE TABLE OF lty_request.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).





      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_salesacceptance_result DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_salesacceptance_result IMPLEMENTATION.

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
