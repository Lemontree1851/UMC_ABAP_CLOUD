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
      <line>-('Message') = 'The value of update flag cannot be empty.'.
      <line>-('Type')    = 'E'.
      CONTINUE.
    ELSEIF ls_data-updateflag <> lc_updateflag_insert AND
           "ls_data-updateflag <> lc_updateflag_update AND
           ls_data-updateflag <> lc_updateflag_delete.
      <line>-('Message') = 'The value of update flag must be I or D.'.
      <line>-('Type')    = 'E'.
      CONTINUE.
    ENDIF.

    "Check user id
    IF ls_data-user_id IS INITIAL.
      <line>-('Message') = 'The value of user cannot be empty.'.
      <line>-('Type')    = 'E'.
      CONTINUE.
    ENDIF.

    "Obtain data of user information
    CLEAR ls_ztbc_1004.
    SELECT SINGLE * FROM ztbc_1004 WHERE user_id = @ls_data-user_id INTO @ls_ztbc_1004.

*   Insert data
    IF ls_data-updateflag = lc_updateflag_insert.

      IF ls_ztbc_1004 IS INITIAL.
        <line>-('Message') = 'The user is not existed, please create the user first'.
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      IF ls_data-role_id IS INITIAL.
        <line>-('Message') = 'The value of role cannot be empty.'.
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      SELECT SINGLE * FROM ztbc_1005 WHERE role_id = @ls_data-role_id INTO @ls_ztbc_1005.
      IF sy-subrc <> 0.
        <line>-('Message') = 'The role information is not existed, please create the role first'.
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      SELECT count( * ) FROM ztbc_1007 WHERE user_uuid = @ls_ztbc_1004-user_uuid
                                         AND role_uuid = @ls_ztbc_1005-role_uuid.
      IF sy-subrc = 0.
        <line>-('Message') = 'User role data is already exist'.
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

      IF ls_ztbc_1004 IS INITIAL.
        <line>-('Message') = 'The user is not existed, please create the user first'.
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      IF ls_data-role_id IS INITIAL.
        <line>-('Message') = 'The value of role cannot be empty.'.
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      SELECT SINGLE * FROM ztbc_1005 WHERE role_id = @ls_data-role_id INTO @ls_ztbc_1005.
      IF sy-subrc <> 0.
        <line>-('Message') = 'The role information is not existed, please create the role first'.
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

    ENDIF.

*   Delete data
    IF ls_data-updateflag = lc_updateflag_delete.

      IF ls_ztbc_1004 IS INITIAL.
        <line>-('Message') = 'The user is not existed, please create the user first'.
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      IF ls_data-role_id IS INITIAL.
        <line>-('Message') = 'The value of role cannot be empty.'.
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      SELECT SINGLE * FROM ztbc_1005 WHERE role_id = @ls_data-role_id INTO @ls_ztbc_1005.
      IF sy-subrc <> 0.
        <line>-('Message') = 'The role information is not existed, please create the role first'.
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      DELETE FROM ztbc_1007 WHERE user_uuid = @ls_ztbc_1004-user_uuid
                              AND role_uuid = @ls_ztbc_1005-role_uuid.
      COMMIT WORK AND WAIT.
      <line>-('Type') = 'S'.
      <line>-('Message') = 'Success'.

    ENDIF.

  ENDLOOP.

ENDFUNCTION.
