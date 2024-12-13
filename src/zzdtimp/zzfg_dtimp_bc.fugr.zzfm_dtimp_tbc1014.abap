FUNCTION zzfm_dtimp_tbc1014.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA: ls_data      TYPE zzs_dtimp_tbc1014,
        lt_data      TYPE TABLE OF zzs_dtimp_tbc1014,
        ls_ztbc_1014 TYPE ztbc_1014,            "function information
        ls_ztbc_1015 TYPE ztbc_1015.            "function access information

  CONSTANTS:
    lc_updateflag_insert TYPE string VALUE 'I',
    lc_updateflag_update TYPE string VALUE 'U',
    lc_updateflag_delete TYPE string VALUE 'D'.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).

    CLEAR ls_data.
    ls_data-updateflag     = <line>-('updateflag').
    ls_data-function_id    = <line>-('function_id').
    ls_data-design_file_id = <line>-('design_file_id').
    ls_data-function_name  = <line>-('function_name').
    ls_data-access_id      = <line>-('access_id').
    ls_data-access_name    = <line>-('access_name').
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

    "Check function id
    IF ls_data-function_id IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-006 INTO <line>-('Message').
      <line>-('Type')    = 'E'.
      CONTINUE.
    ENDIF.

    "Check access id
    IF ls_data-access_id IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-007 INTO <line>-('Message').
      <line>-('Type')    = 'E'.
      CONTINUE.
    ENDIF.

    "Obtain data of function information
    CLEAR ls_ztbc_1014.
    SELECT SINGLE * FROM ztbc_1014 WHERE function_id = @ls_data-function_id INTO @ls_ztbc_1014. "#EC CI_ALL_FIELDS_NEEDED
    CLEAR ls_ztbc_1015.
    SELECT SINGLE * FROM ztbc_1015 WHERE function_id = @ls_data-function_id AND access_id = @ls_data-access_id INTO @ls_ztbc_1015. "#EC CI_ALL_FIELDS_NEEDED

*   Insert data
    IF ls_data-updateflag = lc_updateflag_insert.

      IF ls_data-access_name IS INITIAL.
        MESSAGE e006(zbc_001) WITH TEXT-008 INTO <line>-('Message').
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      IF ls_ztbc_1015 IS NOT INITIAL.       "&1 &2 already exists.
        MESSAGE e009(zbc_001) WITH ls_data-function_id ls_data-access_id INTO <line>-('Message').
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

*     Insert function data
      IF ls_ztbc_1014 IS INITIAL.

        IF ls_data-design_file_id IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-014 INTO <line>-('Message').
          <line>-('Type')    = 'E'.
          CONTINUE.
        ENDIF.

        IF ls_data-function_name IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-015 INTO <line>-('Message').
          <line>-('Type')    = 'E'.
          CONTINUE.
        ENDIF.

        ls_ztbc_1014-function_id    = ls_data-function_id.
        ls_ztbc_1014-design_file_id = ls_data-design_file_id.
        ls_ztbc_1014-function_name  = ls_data-function_name.

        ls_ztbc_1014-created_by = sy-uname.
        GET TIME STAMP FIELD ls_ztbc_1014-created_at.
        ls_ztbc_1014-last_changed_by = sy-uname.
        GET TIME STAMP FIELD ls_ztbc_1014-last_changed_at.
        GET TIME STAMP FIELD ls_ztbc_1014-local_last_changed_at.

        MODIFY ztbc_1014 FROM @ls_ztbc_1014.
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

*     Insert function access data
      TRY.
        ls_ztbc_1015-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
        ##NO_HANDLER
      CATCH cx_uuid_error.
        " handle exception
      ENDTRY.

      ls_ztbc_1015-function_id = ls_data-function_id.
      ls_ztbc_1015-access_id   = ls_data-access_id.
      ls_ztbc_1015-access_name = ls_data-access_name.
      ls_ztbc_1015-created_by  = sy-uname.
      GET TIME STAMP FIELD ls_ztbc_1015-created_at.
      ls_ztbc_1015-last_changed_by = sy-uname.
      GET TIME STAMP FIELD ls_ztbc_1015-last_changed_at.
      GET TIME STAMP FIELD ls_ztbc_1015-local_last_changed_at.

      MODIFY ztbc_1015 FROM @ls_ztbc_1015.
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

      IF ls_ztbc_1014 IS INITIAL.
        MESSAGE e007(zbc_001) WITH TEXT-006 ls_data-function_id INTO <line>-('Message').
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      IF ls_ztbc_1015 IS INITIAL.
        MESSAGE e007(zbc_001) WITH ls_data-function_id ls_data-access_id INTO <line>-('Message').
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

*     Update function data
      IF ls_data-design_file_id IS NOT INITIAL.
        ls_ztbc_1014-design_file_id = ls_data-design_file_id.
      ENDIF.
      IF ls_data-function_name IS NOT INITIAL.
        ls_ztbc_1014-function_name  = ls_data-function_name.
      ENDIF.

      ls_ztbc_1014-last_changed_by = sy-uname.
      GET TIME STAMP FIELD ls_ztbc_1014-last_changed_at.
      GET TIME STAMP FIELD ls_ztbc_1014-local_last_changed_at.

      MODIFY ztbc_1014 FROM @ls_ztbc_1014.
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

*     Update function access data
      ls_ztbc_1015-access_name = ls_data-access_name.
      ls_ztbc_1015-last_changed_by = sy-uname.
      GET TIME STAMP FIELD ls_ztbc_1015-last_changed_at.
      GET TIME STAMP FIELD ls_ztbc_1015-local_last_changed_at.

      MODIFY ztbc_1015 FROM @ls_ztbc_1015.
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

      IF ls_ztbc_1014 IS INITIAL.
        MESSAGE e007(zbc_001) WITH TEXT-006 ls_data-function_id INTO <line>-('Message').
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      IF ls_ztbc_1015 IS INITIAL.
        MESSAGE e007(zbc_001) WITH ls_data-function_id ls_data-access_id INTO <line>-('Message').
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      "Delete function access data
      DELETE FROM ztbc_1015 WHERE function_id = @ls_data-function_id AND access_id = @ls_data-access_id.
      COMMIT WORK AND WAIT.

      "明细全部删除时，再清空头表
      SELECT COUNT(*) FROM ztbc_1015 WHERE function_id = @ls_data-function_id.
      IF sy-subrc <> 0.
        DELETE FROM ztbc_1014 WHERE function_id = @ls_data-function_id.
        COMMIT WORK AND WAIT.
      ENDIF.

      <line>-('Type') = 'S'.
      <line>-('Message') = 'Success'.

    ENDIF.

  ENDLOOP.

ENDFUNCTION.
