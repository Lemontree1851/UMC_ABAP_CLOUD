FUNCTION zzfm_dtimp_tbc1013.
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
    ls_data TYPE zzs_dtimp_tbc1013,
    lt_data TYPE TABLE OF zzs_dtimp_tbc1013,
    ls_ztbc_1004 TYPE ztbc_1004,            "User information
    ls_ztbc_1005 TYPE ztbc_1005,            "Role information
    ls_ztbc_1007 TYPE ztbc_1007.            "User role information

  CONSTANTS:
    lc_updateflag_insert TYPE string VALUE 'I',
    lc_updateflag_update TYPE string VALUE 'U',
    lc_updateflag_delete TYPE string VALUE 'D'.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).

    CLEAR ls_data.
    ls_data-updateflag = <line>-('updateflag').
    ls_data-user_id    = <line>-('user_id').
    ls_data-mail       = <line>-('mail').
    ls_data-role_id    = <line>-('role_id').
    CLEAR: <line>-('Message'), <line>-('Type').

    "Check update flag
    IF ls_data-updateflag IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-001 INTO <line>-('Message').
      <line>-('Type')    = 'E'.
      CONTINUE.
    ELSEIF ls_data-updateflag <> lc_updateflag_insert AND
           ls_data-updateflag <> lc_updateflag_update AND
           ls_data-updateflag <> lc_updateflag_delete.
      MESSAGE e008(zbc_001) WITH TEXT-001 ls_data-updateflag INTO <line>-('Message').
      <line>-('Type')    = 'E'.
      CONTINUE.
    ENDIF.

    "Check user id
    IF ls_data-user_id IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-002 INTO <line>-('Message').
      <line>-('Type')    = 'E'.
      CONTINUE.
    ENDIF.

    "Obtain data of user information
    CLEAR ls_ztbc_1004.
    SELECT SINGLE * FROM ztbc_1004 WHERE user_id = @ls_data-user_id INTO @ls_ztbc_1004.

    IF ls_ztbc_1004 IS INITIAL.
      MESSAGE e007(zbc_001) WITH TEXT-002 ls_data-user_id INTO <line>-('Message').
      <line>-('Type')    = 'E'.
      CONTINUE.
    ENDIF.

    "Check role id
    IF ls_data-role_id IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-004 INTO <line>-('Message').
      <line>-('Type')    = 'E'.
      CONTINUE.
    ENDIF.

    SELECT SINGLE * FROM ztbc_1005 WHERE role_id = @ls_data-role_id INTO @ls_ztbc_1005.
    IF sy-subrc <> 0.
      MESSAGE e007(zbc_001) WITH TEXT-004 ls_data-role_id INTO <line>-('Message').
      <line>-('Type')    = 'E'.
      CONTINUE.
    ENDIF.

*   Insert data
    IF ls_data-updateflag = lc_updateflag_insert.

      SELECT count( * ) FROM ztbc_1007 WHERE user_uuid = @ls_ztbc_1004-user_uuid
                                         AND role_uuid = @ls_ztbc_1005-role_uuid.
      IF sy-subrc = 0.
        MESSAGE e009(zbc_001) WITH TEXT-002 TEXT-013 INTO <line>-('Message').    "User role data already exist
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      CLEAR:
        ls_ztbc_1007.

      TRY.
        ls_ztbc_1007-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
      CATCH cx_uuid_error.
        " handle exception
      ENDTRY.

      ls_ztbc_1007-user_uuid  = ls_ztbc_1004-user_uuid.
      ls_ztbc_1007-role_uuid  = ls_ztbc_1005-role_uuid.

      ls_ztbc_1007-created_by = sy-uname.
      GET TIME STAMP FIELD ls_ztbc_1007-created_at.
      ls_ztbc_1007-last_changed_by = sy-uname.
      GET TIME STAMP FIELD ls_ztbc_1007-last_changed_at.
      GET TIME STAMP FIELD ls_ztbc_1007-local_last_changed_at.

      MODIFY ztbc_1007 FROM @ls_ztbc_1007.
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
      <line>-('Type') = 'S'.
      <line>-('Message') = 'Success'.
      APPEND ls_data TO lt_data.
    ENDIF.

*   Delete data
    IF ls_data-updateflag = lc_updateflag_delete.

      DELETE FROM ztbc_1007 WHERE user_uuid = @ls_ztbc_1004-user_uuid
                              AND role_uuid = @ls_ztbc_1005-role_uuid.
      COMMIT WORK AND WAIT.
      <line>-('Type') = 'S'.
      <line>-('Message') = 'Success'.

    ENDIF.

  ENDLOOP.

  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>)
    GROUP BY ( user_id = <lfs_data>-user_id ).

    SELECT SINGLE * FROM ztbc_1004 WHERE user_id = @<lfs_data>-user_id INTO @ls_ztbc_1004.

    DELETE FROM ztbc_1007 WHERE user_uuid = @ls_ztbc_1004-user_uuid.

    LOOP AT GROUP <lfs_data> INTO ls_data.

      CLEAR:
        ls_ztbc_1007.

      TRY.
        ls_ztbc_1007-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
      CATCH cx_uuid_error.
        " handle exception
      ENDTRY.

      ls_ztbc_1007-user_uuid  = ls_ztbc_1004-user_uuid.

      SELECT SINGLE * FROM ztbc_1005 WHERE role_id = @ls_data-role_id INTO @ls_ztbc_1005.
      ls_ztbc_1007-role_uuid  = ls_ztbc_1005-role_uuid.

      ls_ztbc_1007-created_by = sy-uname.
      GET TIME STAMP FIELD ls_ztbc_1007-created_at.
      ls_ztbc_1007-last_changed_by = sy-uname.
      GET TIME STAMP FIELD ls_ztbc_1007-last_changed_at.
      GET TIME STAMP FIELD ls_ztbc_1007-local_last_changed_at.

      MODIFY ztbc_1007 FROM @ls_ztbc_1007.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
        READ TABLE eo_data->* ASSIGNING <line> WITH KEY ('updateflag') = ls_data-updateflag
                                                        ('user_id')    = ls_data-user_id
                                                        ('mail')       = ls_data-mail
                                                        ('role_id')    = ls_data-role_id.
        IF <line> IS ASSIGNED.
          MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          <line>-('Type') = 'E'.
        ENDIF..
      ENDIF.

    ENDLOOP.

  ENDLOOP.

ENDFUNCTION.
