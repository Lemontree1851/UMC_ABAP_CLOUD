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
    ls_data      TYPE zzs_dtimp_tbc1013,
    lt_data      TYPE TABLE OF zzs_dtimp_tbc1013,
    ls_ztbc_1004 TYPE ztbc_1004,            "User information
    ls_ztbc_1005 TYPE ztbc_1005,            "Role information
    ls_ztbc_1007 TYPE ztbc_1007,            "User role information
    lv_regular_expression TYPE string VALUE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'.

    " Example for a POSIX regular expression engine (More configuration options are available
    " as optional parameters of the method POSIX).
    DATA(lo_posix_engine) = xco_cp_regular_expression=>engine->posix(
      iv_ignore_case = abap_true
    ).

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
    CONDENSE ls_data-mail NO-GAPS.

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

*-----Check mail-----
    IF ls_data-mail IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-003 INTO <line>-('Message').
      <line>-('Type')    = 'E'.
      CONTINUE.
    ENDIF.

    DATA(lv_match) = xco_cp=>string( ls_data-mail )->matches( iv_regular_expression = lv_regular_expression
                                                              io_engine             = lo_posix_engine ).
    IF lv_match IS INITIAL.
      MESSAGE e008(zbc_001) WITH TEXT-003 ls_data-mail INTO <line>-('Message').
      <line>-('Type')    = 'E'.
      CONTINUE.
    ENDIF.

    "Obtain data of user information
    CLEAR ls_ztbc_1004.
    SELECT SINGLE * FROM ztbc_1004 WHERE mail = @ls_data-mail INTO @ls_ztbc_1004.  "#EC CI_ALL_FIELDS_NEEDED

    IF ls_ztbc_1004 IS INITIAL. "&1 &2 not found.
      MESSAGE e007(zbc_001) WITH TEXT-002 ls_data-mail INTO <line>-('Message').
      <line>-('Type') = 'E'.
      CONTINUE.
    ENDIF.

    "Check role id
    IF ls_data-role_id IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-004 INTO <line>-('Message').
      <line>-('Type') = 'E'.
      CONTINUE.
    ENDIF.

    SELECT SINGLE * FROM ztbc_1005 WHERE role_id = @ls_data-role_id INTO @ls_ztbc_1005. "#EC CI_ALL_FIELDS_NEEDED
    IF sy-subrc <> 0.
      MESSAGE e007(zbc_001) WITH TEXT-004 ls_data-role_id INTO <line>-('Message').
      <line>-('Type') = 'E'.
      CONTINUE.
    ENDIF.

*   Insert data
    IF ls_data-updateflag = lc_updateflag_insert.

      SELECT COUNT( * ) FROM ztbc_1007 WHERE mail    = @ls_ztbc_1004-mail
                                         AND role_id = @ls_ztbc_1005-role_id.
      IF sy-subrc = 0.
        MESSAGE e009(zbc_001) WITH TEXT-002 TEXT-013 INTO <line>-('Message').    "User role data already exist
        <line>-('Type') = 'E'.
        CONTINUE.
      ENDIF.

      CLEAR: ls_ztbc_1007.

      TRY.
          ls_ztbc_1007-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
          ##NO_HANDLER
        CATCH cx_uuid_error.
          " handle exception
      ENDTRY.

      ls_ztbc_1007-mail     = ls_ztbc_1004-mail.
      ls_ztbc_1007-role_id  = ls_ztbc_1005-role_id.

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
      DELETE FROM ztbc_1007 WHERE mail    = @ls_ztbc_1004-mail
                              AND role_id = @ls_ztbc_1005-role_id.
      COMMIT WORK AND WAIT.
      <line>-('Type') = 'S'.
      <line>-('Message') = 'Success'.
    ENDIF.
  ENDLOOP.


*  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>)
*                               GROUP BY ( user_id = <lfs_data>-user_id ).

*    DELETE FROM ztbc_1007 WHERE mail = @<lfs_data>-mail.

*    LOOP AT GROUP <lfs_data> INTO ls_data.
*      CLEAR: ls_ztbc_1007.

*      TRY.
*          ls_ztbc_1007-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
*          ##NO_HANDLER
*        CATCH cx_uuid_error.
          " handle exception
*      ENDTRY.

*      ls_ztbc_1007-mail    = ls_data-mail.
*      ls_ztbc_1007-role_id = ls_data-role_id.

*      ls_ztbc_1007-created_by = sy-uname.
*      GET TIME STAMP FIELD ls_ztbc_1007-created_at.
*      ls_ztbc_1007-last_changed_by = sy-uname.
*      GET TIME STAMP FIELD ls_ztbc_1007-last_changed_at.
*      GET TIME STAMP FIELD ls_ztbc_1007-local_last_changed_at.

*      MODIFY ztbc_1007 FROM @ls_ztbc_1007.
*      IF sy-subrc = 0.
*        COMMIT WORK AND WAIT.
*      ELSE.
*        ROLLBACK WORK.
*        READ TABLE eo_data->* ASSIGNING <line> WITH KEY ('updateflag') = ls_data-updateflag
*                                                        ('user_id')    = ls_data-user_id
*                                                        ('mail')       = ls_data-mail
*                                                        ('role_id')    = ls_data-role_id. "#EC CI_ANYSEQ
*        IF <line> IS ASSIGNED.
*          MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*          <line>-('Type') = 'E'.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*  ENDLOOP.

ENDFUNCTION.
