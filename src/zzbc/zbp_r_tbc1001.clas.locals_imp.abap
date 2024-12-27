CLASS lhc_commonconfig DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING REQUEST requested_authorizations FOR commonconfig RESULT result,
      get_instance_authorizations FOR INSTANCE AUTHORIZATION
            IMPORTING keys REQUEST requested_authorizations FOR commonconfig RESULT result,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE commonconfig,
      precheck_delete FOR PRECHECK
        IMPORTING keys FOR DELETE commonconfig.
ENDCLASS.

CLASS lhc_commonconfig IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    READ ENTITIES OF zr_tbc1001 IN LOCAL MODE
    ENTITY commonconfig
    FIELDS ( unmodifiable ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

    LOOP AT lt_data INTO DATA(ls_data).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      <lfs_result>-%tky = ls_data-%tky.

      IF ls_data-unmodifiable = abap_true.
        <lfs_result>-%delete = if_abap_behv=>auth-unauthorized.
        <lfs_result>-%action-edit = if_abap_behv=>auth-unauthorized.
      ELSE.
        <lfs_result>-%delete = if_abap_behv=>auth-allowed.
        <lfs_result>-%action-edit = if_abap_behv=>auth-allowed.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    LOOP AT entities INTO DATA(entity).
      IF entity-%control-zprogram = if_abap_behv=>mk-on AND entity-zprogram IS INITIAL.
        INSERT VALUE #( %tky = entity-%tky ) INTO TABLE failed-commonconfig.

        MESSAGE e006(zbc_001) WITH TEXT-001 INTO DATA(lv_message).

        INSERT VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text( text = lv_message ) ) INTO TABLE reported-commonconfig.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITIES OF zr_tbc1001 IN LOCAL MODE
    ENTITY commonconfig
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    FAILED DATA(ls_failed)
    REPORTED DATA(ls_reported).

    DATA(lv_text1) = |！！！临时检查，防止错删！！！|.
    DATA(lv_text2) = |1、修改<Remark>字段值为：DEL2024，再次点击删除|.
    DATA(lv_text3) = |2、请联系技术人员：许鑫磊|.

*    LOOP AT lt_result INTO DATA(ls_result).
*      IF ls_result-zremark <> 'DEL2024'.
*        INSERT VALUE #( %tky = ls_result-%tky ) INTO TABLE failed-commonconfig.
*        INSERT VALUE #( %tky = ls_result-%tky
*                        %msg = new_message_with_text( text = lv_text3 ) ) INTO TABLE reported-commonconfig.
*        INSERT VALUE #( %tky = ls_result-%tky
*                        %msg = new_message_with_text( text = lv_text2 ) ) INTO TABLE reported-commonconfig.
*        INSERT VALUE #( %tky = ls_result-%tky
*                        %msg = new_message_with_text( text = lv_text1 ) ) INTO TABLE reported-commonconfig.
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
