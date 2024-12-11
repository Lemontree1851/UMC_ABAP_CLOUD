FUNCTION zzfm_dtimp_tbc1012.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA:
    ls_data      TYPE zzs_dtimp_tbc1012,
    lt_data      TYPE TABLE OF zzs_dtimp_tbc1012,
    ls_ztbc_1005 TYPE ztbc_1005.            "Role information

  CONSTANTS:
    lc_updateflag_insert TYPE string VALUE 'I',
    lc_updateflag_update TYPE string VALUE 'U',
    lc_updateflag_delete TYPE string VALUE 'D'.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).

    CLEAR ls_data.
    ls_data-updateflag = <line>-('updateflag').
    ls_data-role_id    = <line>-('role_id').
    ls_data-role_name  = <line>-('role_name').
    CLEAR: <line>-('Message'), <line>-('Type').

    "Check update flag
    IF ls_data-updateflag IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-001 INTO <line>-('Message').
      <line>-('Type') = 'E'.
      CONTINUE.
    ELSEIF ls_data-updateflag <> lc_updateflag_insert AND
           ls_data-updateflag <> lc_updateflag_update AND
           ls_data-updateflag <> lc_updateflag_delete.
      MESSAGE e008(zbc_001) WITH TEXT-001 ls_data-updateflag INTO <line>-('Message').
      <line>-('Type') = 'E'.
      CONTINUE.
    ENDIF.

    IF ls_data-role_id IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-004 INTO <line>-('Message').
      <line>-('Type') = 'E'.
      CONTINUE.
    ENDIF.
*
*    IF ls_data-function_id IS INITIAL.
*      MESSAGE e006(zbc_001) WITH TEXT-006 INTO <line>-('Message').
*      <line>-('Type') = 'E'.
*      CONTINUE.
*    ENDIF.
*
*    IF ls_data-access_id IS INITIAL.
*      MESSAGE e006(zbc_001) WITH TEXT-007 INTO <line>-('Message').
*      <line>-('Type') = 'E'.
*      CONTINUE.
*    ENDIF.
*
*    IF ls_data-access_name IS INITIAL.
*      MESSAGE e006(zbc_001) WITH TEXT-008 INTO <line>-('Message').
*      <line>-('Type') = 'E'.
*      CONTINUE.
*    ENDIF.

*   Insert data
    IF ls_data-updateflag = lc_updateflag_insert.

      SELECT COUNT( * ) FROM ztbc_1005 WHERE role_id = @ls_data-role_id.
      IF sy-subrc = 0.
        MESSAGE e009(zbc_001) WITH TEXT-013 space INTO <line>-('Message').
        <line>-('Type') = 'E'.
        CONTINUE.
      ENDIF.

      CLEAR: ls_ztbc_1005.
      ls_ztbc_1005-role_id   = ls_data-role_id.
      ls_ztbc_1005-role_name = ls_data-role_name.

      ls_ztbc_1005-created_by  = sy-uname.
      GET TIME STAMP FIELD ls_ztbc_1005-created_at.
      ls_ztbc_1005-last_changed_by = sy-uname.
      GET TIME STAMP FIELD ls_ztbc_1005-last_changed_at.
      GET TIME STAMP FIELD ls_ztbc_1005-local_last_changed_at.

      MODIFY ztbc_1005 FROM @ls_ztbc_1005.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
        <line>-('Type') = 'S'.
        <line>-('Message') = 'Success'.
      ELSE.
        ROLLBACK WORK.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        <line>-('Type') = 'E'.
        CONTINUE.
      ENDIF.

    ENDIF.

*   Update data
    IF ls_data-updateflag = lc_updateflag_update.

      SELECT SINGLE * FROM ztbc_1005 WHERE role_id = @ls_data-role_id INTO @ls_ztbc_1005.
      IF sy-subrc <> 0.
        MESSAGE e007(zbc_001) WITH TEXT-004 ls_data-role_id INTO <line>-('Message').
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      ls_ztbc_1005-role_id   = ls_data-role_id.
      ls_ztbc_1005-role_name = ls_data-role_name.

      ls_ztbc_1005-last_changed_by = sy-uname.
      GET TIME STAMP FIELD ls_ztbc_1005-last_changed_at.
      GET TIME STAMP FIELD ls_ztbc_1005-local_last_changed_at.

      MODIFY ztbc_1005 FROM @ls_ztbc_1005.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
        <line>-('Type') = 'S'.
        <line>-('Message') = 'Success'.
      ELSE.
        ROLLBACK WORK.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        <line>-('Type') = 'E'.
        CONTINUE.
      ENDIF.

    ENDIF.

*   Delete data
    IF ls_data-updateflag = lc_updateflag_delete.
      DELETE FROM ztbc_1007 WHERE role_id = @ls_data-role_id.
      DELETE FROM ztbc_1005 WHERE role_id = @ls_data-role_id.

      COMMIT WORK AND WAIT.
      <line>-('Type') = 'S'.
      <line>-('Message') = 'Success'.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
