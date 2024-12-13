FUNCTION zzfm_dtimp_tbc1011.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  TYPES:
    BEGIN OF ty_plant,
      plant TYPE werks_d,
    END OF ty_plant,
    BEGIN OF ty_company,
      company TYPE bukrs,
    END OF ty_company,
    BEGIN OF ty_salesorg,
      salesorg TYPE vkorg,
    END OF ty_salesorg.

  DATA:
    ls_data      TYPE zzs_dtimp_tbc1011,
    lt_data      TYPE TABLE OF zzs_dtimp_tbc1011,
    ls_ztbc_1004 TYPE ztbc_1004,            "User information
    ls_ztbc_1006 TYPE ztbc_1006,            "User Plant information
    lt_ztbc_1006 TYPE TABLE OF ztbc_1006,   "User Plant information
    ls_ztbc_1012 TYPE ztbc_1012,            "User Company information
    lt_ztbc_1012 TYPE TABLE OF ztbc_1012,   "User Company information
    ls_ztbc_1013 TYPE ztbc_1013,            "User Sales Organization information
    lt_ztbc_1013 TYPE TABLE OF ztbc_1013,   "User Sales Organization information
    lt_plant     TYPE TABLE OF ty_plant,
    lt_company   TYPE TABLE OF ty_company,
    lt_salesorg  TYPE TABLE OF ty_salesorg,
    lv_regular_expression TYPE string VALUE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    lv_flag      TYPE STRING.

    " Example for a POSIX regular expression engine (More configuration options are available
    " as optional parameters of the method POSIX).
    DATA(lo_posix_engine) = xco_cp_regular_expression=>engine->posix(
      iv_ignore_case = abap_true
    ).

  CONSTANTS:
    lc_updateflag_insert TYPE string VALUE 'I',
    lc_updateflag_update TYPE string VALUE 'U',
    lc_updateflag_delete TYPE string VALUE 'D',
    lc_splitflag         TYPE string VALUE '、'.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).

    CLEAR ls_data.
    ls_data-updateflag         = <line>-('updateflag').
    ls_data-user_id            = <line>-('user_id').
    ls_data-mail               = <line>-('mail').
    ls_data-department         = <line>-('department').
    ls_data-plant              = <line>-('plant').
    ls_data-company_code       = <line>-('company_code').
    ls_data-sales_organization = <line>-('sales_organization').
    CLEAR: <line>-('Message'), <line>-('Type').
    CONDENSE ls_data-mail NO-GAPS.

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

    "Check mail
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
    SELECT SINGLE * FROM ztbc_1004 WHERE mail = @ls_data-mail INTO @ls_ztbc_1004.

*   Insert data
    IF ls_data-updateflag = lc_updateflag_insert.

*     Insert user data
      IF ls_ztbc_1004 IS INITIAL.

        "Check user id
        IF ls_data-user_id IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-002 INTO <line>-('Message').
          <line>-('Type')    = 'E'.
          CONTINUE.
        ENDIF.

        ls_ztbc_1004-user_id    = ls_data-user_id.
        ls_ztbc_1004-mail       = ls_data-mail.
        ls_ztbc_1004-department = ls_data-department .
        ls_ztbc_1004-user_name  = ls_data-user_id.

        ls_ztbc_1004-created_by = sy-uname.
        GET TIME STAMP FIELD ls_ztbc_1004-created_at.
        ls_ztbc_1004-last_changed_by = sy-uname.
        GET TIME STAMP FIELD ls_ztbc_1004-last_changed_at.
        GET TIME STAMP FIELD ls_ztbc_1004-local_last_changed_at.

        MODIFY ztbc_1004 FROM @ls_ztbc_1004.
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

*     Insert plant data
      IF ls_data-plant IS NOT INITIAL.

        SELECT COUNT( * ) FROM ztbc_1006 WHERE mail = @ls_ztbc_1004-mail .
        IF sy-subrc = 0.
          MESSAGE e009(zbc_001) WITH TEXT-002 TEXT-009 INTO <line>-('Message').    "User plant data already exist
          <line>-('Type')    = 'E'.
          CONTINUE.
        ENDIF.

        CLEAR:
          ls_ztbc_1006,
          lt_ztbc_1006.

        ls_ztbc_1006-mail       = ls_ztbc_1004-mail.
        ls_ztbc_1006-created_by = sy-uname.
        GET TIME STAMP FIELD ls_ztbc_1006-created_at.
        ls_ztbc_1006-last_changed_by = sy-uname.
        GET TIME STAMP FIELD ls_ztbc_1006-last_changed_at.
        GET TIME STAMP FIELD ls_ztbc_1006-local_last_changed_at.

        CLEAR lt_plant.
        SPLIT ls_data-plant AT lc_splitflag INTO TABLE lt_plant.

        CLEAR lv_flag.
        LOOP AT lt_plant INTO DATA(ls_plant).

          SELECT COUNT( * ) FROM i_Plant WHERE Plant = @ls_plant-plant.
          IF sy-subrc <> 0.  "&1 &2 is invalid.
            MESSAGE e008(zbc_001) WITH TEXT-016 ls_plant-plant INTO <line>-('Message').
            <line>-('Type')    = 'E'.
            lv_flag = 'X'.
            EXIT.
          ENDIF.

          TRY.
              ls_ztbc_1006-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
              ##NO_HANDLER
            CATCH cx_uuid_error.
              " handle exception
          ENDTRY.
          ls_ztbc_1006-plant = ls_plant-plant.
          APPEND ls_ztbc_1006 TO lt_ztbc_1006.
        ENDLOOP.
        IF lv_flag = 'X'.
          CONTINUE.
        ENDIF.

        MODIFY ztbc_1006 FROM TABLE @lt_ztbc_1006.
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

*     Insert company data
      IF ls_data-company_code IS NOT INITIAL.

        SELECT COUNT( * ) FROM ztbc_1012 WHERE mail = @ls_ztbc_1004-mail.
        IF sy-subrc = 0.
          MESSAGE e009(zbc_001) WITH TEXT-002 TEXT-010 INTO <line>-('Message').    "User company data already exist
          <line>-('Type')    = 'E'.
          CONTINUE.
        ENDIF.

        CLEAR:
          ls_ztbc_1012,
          lt_ztbc_1012.

        ls_ztbc_1012-mail = ls_ztbc_1004-mail.
        ls_ztbc_1012-created_by = sy-uname.
        GET TIME STAMP FIELD ls_ztbc_1012-created_at.
        ls_ztbc_1012-last_changed_by = sy-uname.
        GET TIME STAMP FIELD ls_ztbc_1012-last_changed_at.
        GET TIME STAMP FIELD ls_ztbc_1012-local_last_changed_at.

        CLEAR lt_company.
        SPLIT ls_data-company_code AT lc_splitflag INTO TABLE lt_company.

        CLEAR lv_flag.
        LOOP AT lt_company INTO DATA(ls_company).

          SELECT COUNT( * ) FROM i_CompanyCode WHERE CompanyCode = @ls_company-company.
          IF sy-subrc <> 0.  "&1 &2 is invalid.
            MESSAGE e008(zbc_001) WITH TEXT-017 ls_company-company INTO <line>-('Message').
            <line>-('Type')    = 'E'.
            lv_flag = 'X'.
            EXIT.
          ENDIF.

          TRY.
              ls_ztbc_1012-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
              ##NO_HANDLER
            CATCH cx_uuid_error.
              " handle exception
          ENDTRY.
          ls_ztbc_1012-company_code = ls_company-company.
          APPEND ls_ztbc_1012 TO lt_ztbc_1012.
        ENDLOOP.
        IF lv_flag = 'X'.
          CONTINUE.
        ENDIF.

        MODIFY ztbc_1012 FROM TABLE @lt_ztbc_1012.
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

*     Insert sales organization data
      IF ls_data-sales_organization IS NOT INITIAL.

        SELECT COUNT( * ) FROM ztbc_1013 WHERE mail = @ls_ztbc_1004-mail.
        IF sy-subrc = 0.
          MESSAGE e009(zbc_001) WITH TEXT-002 TEXT-011 INTO <line>-('Message').    "User sales organization data already exist
          <line>-('Type')    = 'E'.
          CONTINUE.
        ENDIF.

        CLEAR:
          ls_ztbc_1013,
          lt_ztbc_1013.

        ls_ztbc_1013-mail = ls_ztbc_1004-mail.
        ls_ztbc_1013-created_by = sy-uname.
        GET TIME STAMP FIELD ls_ztbc_1013-created_at.
        ls_ztbc_1013-last_changed_by = sy-uname.
        GET TIME STAMP FIELD ls_ztbc_1013-last_changed_at.
        GET TIME STAMP FIELD ls_ztbc_1013-local_last_changed_at.

        CLEAR lt_salesorg.
        SPLIT ls_data-sales_organization AT lc_splitflag INTO TABLE lt_salesorg.

        CLEAR lv_flag.
        LOOP AT lt_salesorg INTO DATA(ls_salesorg).

          SELECT COUNT( * ) FROM i_SalesOrganization WHERE SalesOrganization = @ls_salesorg-salesorg.
          IF sy-subrc <> 0.  "&1 &2 is invalid.
            MESSAGE e008(zbc_001) WITH TEXT-018 ls_salesorg-salesorg INTO <line>-('Message').
            <line>-('Type')    = 'E'.
            lv_flag = 'X'.
            EXIT.
          ENDIF.

          TRY.
              ls_ztbc_1013-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
              ##NO_HANDLER
            CATCH cx_uuid_error.
              " handle exception
          ENDTRY.
          ls_ztbc_1013-sales_organization = ls_salesorg-salesorg.
          APPEND ls_ztbc_1013 TO lt_ztbc_1013.
        ENDLOOP.
        IF lv_flag = 'X'.
          CONTINUE.
        ENDIF.

        MODIFY ztbc_1013 FROM TABLE @lt_ztbc_1013.
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

      IF <line>-('Type') IS INITIAL.
        MESSAGE e009(zbc_001) WITH TEXT-002 TEXT-012 INTO <line>-('Message').    "User data already exist
        <line>-('Type') = 'E'.
        CONTINUE.
      ENDIF.

    ENDIF.

*   Update data
    IF ls_data-updateflag = lc_updateflag_update.

*     Update user data
      IF ls_ztbc_1004 IS INITIAL.
        MESSAGE e007(zbc_001) WITH TEXT-002 ls_data-user_id INTO <line>-('Message').
        <line>-('Type')    = 'E'.
        CONTINUE.
      ENDIF.

      IF ls_data-user_id IS NOT INITIAL OR ls_data-department IS NOT INITIAL.

        IF ls_data-user_id IS NOT INITIAL.
          ls_ztbc_1004-user_id = ls_data-user_id.
        ENDIF.

        IF ls_data-department IS NOT INITIAL.
          ls_ztbc_1004-department = ls_data-department.
        ENDIF.

        ls_ztbc_1004-last_changed_by = sy-uname.
        GET TIME STAMP FIELD ls_ztbc_1004-last_changed_at.
        GET TIME STAMP FIELD ls_ztbc_1004-local_last_changed_at.

        MODIFY ztbc_1004 FROM @ls_ztbc_1004.
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

*     Update plant data
      IF ls_data-plant IS NOT INITIAL.

        DELETE FROM ztbc_1006 WHERE mail = @ls_ztbc_1004-mail.

        IF ls_data-plant <> 'D'.

          CLEAR:
            ls_ztbc_1006,
            lt_ztbc_1006.

          ls_ztbc_1006-mail = ls_ztbc_1004-mail.
          ls_ztbc_1006-created_by = sy-uname.
          GET TIME STAMP FIELD ls_ztbc_1006-created_at.
          ls_ztbc_1006-last_changed_by = sy-uname.
          GET TIME STAMP FIELD ls_ztbc_1006-last_changed_at.
          GET TIME STAMP FIELD ls_ztbc_1006-local_last_changed_at.

          CLEAR lt_plant.
          SPLIT ls_data-plant AT lc_splitflag INTO TABLE lt_plant.

          CLEAR lv_flag.
          LOOP AT lt_plant INTO ls_plant.

            SELECT COUNT( * ) FROM i_Plant WHERE Plant = @ls_plant-plant.
            IF sy-subrc <> 0.  "&1 &2 is invalid.
              MESSAGE e008(zbc_001) WITH TEXT-016 ls_plant-plant INTO <line>-('Message').
              <line>-('Type')    = 'E'.
              lv_flag = 'X'.
              EXIT.
            ENDIF.

            TRY.
                ls_ztbc_1006-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
                ##NO_HANDLER
              CATCH cx_uuid_error.
                " handle exception
            ENDTRY.
            ls_ztbc_1006-plant = ls_plant-plant.
            APPEND ls_ztbc_1006 TO lt_ztbc_1006.
          ENDLOOP.
          IF lv_flag = 'X'.
            CONTINUE.
          ENDIF.

          MODIFY ztbc_1006 FROM TABLE @lt_ztbc_1006.
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

        ELSE.
          COMMIT WORK AND WAIT.
          <line>-('Type') = 'S'.
          <line>-('Message') = 'Success'.
        ENDIF.

      ENDIF.

*     Update company data
      IF ls_data-company_code IS NOT INITIAL.

        DELETE FROM ztbc_1012 WHERE mail = @ls_ztbc_1004-mail.

        IF ls_data-company_code <> 'D'.

          CLEAR:
            ls_ztbc_1012,
            lt_ztbc_1012.

          ls_ztbc_1012-mail = ls_ztbc_1004-mail.
          ls_ztbc_1012-created_by = sy-uname.
          GET TIME STAMP FIELD ls_ztbc_1012-created_at.
          ls_ztbc_1012-last_changed_by = sy-uname.
          GET TIME STAMP FIELD ls_ztbc_1012-last_changed_at.
          GET TIME STAMP FIELD ls_ztbc_1012-local_last_changed_at.

          CLEAR lt_company.
          SPLIT ls_data-company_code AT lc_splitflag INTO TABLE lt_company.

          CLEAR lv_flag.
          LOOP AT lt_company INTO ls_company.

            SELECT COUNT( * ) FROM i_CompanyCode WHERE CompanyCode = @ls_company-company.
            IF sy-subrc <> 0.  "&1 &2 is invalid.
              MESSAGE e008(zbc_001) WITH TEXT-017 ls_company-company INTO <line>-('Message').
              <line>-('Type')    = 'E'.
              lv_flag = 'X'.
              EXIT.
            ENDIF.

            TRY.
                ls_ztbc_1012-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
                ##NO_HANDLER
              CATCH cx_uuid_error.
                " handle exception
            ENDTRY.
            ls_ztbc_1012-company_code = ls_company-company.
            APPEND ls_ztbc_1012 TO lt_ztbc_1012.
          ENDLOOP.
          IF lv_flag = 'X'.
            CONTINUE.
          ENDIF.

          MODIFY ztbc_1012 FROM TABLE @lt_ztbc_1012.
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

        ELSE.
          COMMIT WORK AND WAIT.
          <line>-('Type') = 'S'.
          <line>-('Message') = 'Success'.
        ENDIF.

      ENDIF.

*     Update sales organization data
      IF ls_data-sales_organization IS NOT INITIAL.

        DELETE FROM ztbc_1013 WHERE mail = @ls_ztbc_1004-mail.

        IF ls_data-sales_organization <> 'D'.

          CLEAR:
            ls_ztbc_1013,
            lt_ztbc_1013.

          ls_ztbc_1013-mail = ls_ztbc_1004-mail.
          ls_ztbc_1013-created_by = sy-uname.
          GET TIME STAMP FIELD ls_ztbc_1013-created_at.
          ls_ztbc_1013-last_changed_by = sy-uname.
          GET TIME STAMP FIELD ls_ztbc_1013-last_changed_at.
          GET TIME STAMP FIELD ls_ztbc_1013-local_last_changed_at.

          CLEAR lt_salesorg.
          SPLIT ls_data-sales_organization AT lc_splitflag INTO TABLE lt_salesorg.

          CLEAR lv_flag.
          LOOP AT lt_salesorg INTO ls_salesorg.

            SELECT COUNT( * ) FROM i_SalesOrganization WHERE SalesOrganization = @ls_salesorg-salesorg.
            IF sy-subrc <> 0.  "&1 &2 is invalid.
              MESSAGE e008(zbc_001) WITH TEXT-018 ls_salesorg-salesorg INTO <line>-('Message').
              <line>-('Type')    = 'E'.
              lv_flag = 'X'.
              EXIT.
            ENDIF.

            TRY.
                ls_ztbc_1013-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
                ##NO_HANDLER
              CATCH cx_uuid_error.
                " handle exception
            ENDTRY.
            ls_ztbc_1013-sales_organization = ls_salesorg-salesorg.
            APPEND ls_ztbc_1013 TO lt_ztbc_1013.
          ENDLOOP.
          IF lv_flag = 'X'.
            CONTINUE.
          ENDIF.

          MODIFY ztbc_1013 FROM TABLE @lt_ztbc_1013.
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

        ELSE.
          COMMIT WORK AND WAIT.
          <line>-('Type') = 'S'.
          <line>-('Message') = 'Success'.
        ENDIF.

      ENDIF.

      IF <line>-('Type') IS INITIAL.
        <line>-('Message') = 'Success'.
        <line>-('Type')    = 'S'.
        CONTINUE.
      ENDIF.

    ENDIF.

*   Delete data
    IF ls_data-updateflag = lc_updateflag_delete.

      "Delete user data
      DELETE FROM ztbc_1004 WHERE mail = @ls_ztbc_1004-mail.

      "Delete plant data
      DELETE FROM ztbc_1006 WHERE mail = @ls_ztbc_1004-mail.

      "Delete role data
      DELETE FROM ztbc_1007 WHERE mail = @ls_ztbc_1004-mail.

      "Delete company data
      DELETE FROM ztbc_1012 WHERE mail = @ls_ztbc_1004-mail.

      "Delete sales organization data
      DELETE FROM ztbc_1013 WHERE mail = @ls_ztbc_1004-mail.

      COMMIT WORK AND WAIT.
      <line>-('Type') = 'S'.
      <line>-('Message') = 'Success'.

    ENDIF.

  ENDLOOP.

ENDFUNCTION.
