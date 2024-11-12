CLASS lsc_zr_tbc1005 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zr_tbc1005 IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_role DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR role RESULT result.
    METHODS validationroleid FOR VALIDATE ON SAVE
      IMPORTING keys FOR role~validationroleid.

ENDCLASS.

CLASS lhc_role IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD validationroleid.
*    READ ENTITIES OF zr_tbc1005 IN LOCAL MODE
*    ENTITY role
*    FIELDS ( roleid ) WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_result).
*
*    IF lt_result IS NOT INITIAL.
*      SELECT roleid
*        FROM zc_tbc1005
*         FOR ALL ENTRIES IN @lt_result
*       WHERE roleid = @lt_result-roleid
*        INTO TABLE @DATA(lt_role).
*      SORT lt_role BY roleid.
*
*      LOOP AT lt_result INTO DATA(ls_result).
*        IF ls_result-roleid IS INITIAL.
*          MESSAGE e006(zbc_001) WITH TEXT-001 INTO DATA(lv_message).
*        ELSE.
*          READ TABLE lt_role TRANSPORTING NO FIELDS WITH KEY roleid = ls_result-roleid BINARY SEARCH.
*          IF sy-subrc = 0.
*            MESSAGE e009(zbc_001) WITH TEXT-001 ls_result-roleid INTO lv_message.
*          ENDIF.
*        ENDIF.
*        IF lv_message IS NOT INITIAL.
*          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-role.
*          APPEND VALUE #( %tky            = ls_result-%tky
*                          %state_area     = 'VALIDATE_ROLEID'
*                          %element-roleid = if_abap_behv=>mk-on
*                          %msg            = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                                   text     = lv_message ) ) TO reported-role.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
  ENDMETHOD.

ENDCLASS.
