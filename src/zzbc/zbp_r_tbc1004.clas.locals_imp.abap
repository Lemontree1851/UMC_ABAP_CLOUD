CLASS lhc_user DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR user RESULT result.
    METHODS validationemail FOR VALIDATE ON SAVE
      IMPORTING keys FOR user~validationemail.
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE user.
    METHODS validationuserid FOR VALIDATE ON SAVE
      IMPORTING keys FOR user~validationuserid.

ENDCLASS.

CLASS lhc_user IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD validationuserid.
    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY user
    FIELDS ( userid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      IF <lfs_result>-userid IS INITIAL.
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-user.
        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %element-userid = if_abap_behv=>mk-on
                        %msg = new_message( id       = 'ZBC_001'
                                            number   = 006
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = TEXT-001 ) ) TO reported-user.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validationemail.
    DATA: lv_regular_expression TYPE string VALUE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'.

    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY user
    FIELDS ( mail ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    " Example for a POSIX regular expression engine (More configuration options are available
    " as optional parameters of the method POSIX).
    DATA(lo_posix_engine) = xco_cp_regular_expression=>engine->posix(
      iv_ignore_case = abap_true
    ).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      DATA(lv_match) = xco_cp=>string( <lfs_result>-mail )->matches( iv_regular_expression = lv_regular_expression
                                                                     io_engine             = lo_posix_engine ).
      IF lv_match IS INITIAL.
        MESSAGE e008(zbc_001) WITH TEXT-002 <lfs_result>-mail INTO DATA(lv_message).

        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-user.

        APPEND VALUE #( %tky          = <lfs_result>-%tky
                        %state_area   = 'VALIDATE_EMAIL'
                        %element-mail = if_abap_behv=>mk-on
                        %msg          = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                               text     = lv_message ) ) TO reported-user.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    DATA: lv_has_assign TYPE abap_boolean.

    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY user
    FIELDS ( mail userid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_user).

    IF lt_user IS NOT INITIAL.
      SELECT uuid,
             mail
        FROM zr_tbc1006
         FOR ALL ENTRIES IN @lt_user
       WHERE mail = @lt_user-mail
        INTO TABLE @DATA(lt_assign_plant).
      SORT lt_assign_plant BY mail.

      SELECT uuid,
             mail
        FROM zr_tbc1007
         FOR ALL ENTRIES IN @lt_user
       WHERE mail = @lt_user-mail
        INTO TABLE @DATA(lt_assign_role).
      SORT lt_assign_role BY mail.

      SELECT uuid,
             mail
        FROM zr_tbc1012
         FOR ALL ENTRIES IN @lt_user
       WHERE mail = @lt_user-mail
        INTO TABLE @DATA(lt_assign_company).
      SORT lt_assign_company BY mail.

      SELECT uuid,
             mail
        FROM zr_tbc1013
         FOR ALL ENTRIES IN @lt_user
       WHERE mail = @lt_user-mail
        INTO TABLE @DATA(lt_assign_salesorg).
      SORT lt_assign_salesorg BY mail.

      SELECT uuid,
             mail
        FROM zr_tbc1017
         FOR ALL ENTRIES IN @lt_user
       WHERE mail = @lt_user-mail
        INTO TABLE @DATA(lt_assign_purchorg).
      SORT lt_assign_purchorg BY mail.

      SELECT uuid,
             mail
        FROM zr_tbc1018
         FOR ALL ENTRIES IN @lt_user
       WHERE mail = @lt_user-mail
        INTO TABLE @DATA(lt_assign_shippingpoint).
      SORT lt_assign_shippingpoint BY mail.
    ENDIF.

    LOOP AT lt_user ASSIGNING FIELD-SYMBOL(<lfs_user>).
      CLEAR lv_has_assign.

      READ TABLE lt_assign_plant TRANSPORTING NO FIELDS WITH KEY mail = <lfs_user>-mail BINARY SEARCH.
      IF sy-subrc = 0.
        lv_has_assign = abap_true.
      ENDIF.

      READ TABLE lt_assign_company TRANSPORTING NO FIELDS WITH KEY mail = <lfs_user>-mail BINARY SEARCH.
      IF sy-subrc = 0.
        lv_has_assign = abap_true.
      ENDIF.

      READ TABLE lt_assign_salesorg TRANSPORTING NO FIELDS WITH KEY mail = <lfs_user>-mail BINARY SEARCH.
      IF sy-subrc = 0.
        lv_has_assign = abap_true.
      ENDIF.

      READ TABLE lt_assign_purchorg TRANSPORTING NO FIELDS WITH KEY mail = <lfs_user>-mail BINARY SEARCH.
      IF sy-subrc = 0.
        lv_has_assign = abap_true.
      ENDIF.

      READ TABLE lt_assign_shippingpoint TRANSPORTING NO FIELDS WITH KEY mail = <lfs_user>-mail BINARY SEARCH.
      IF sy-subrc = 0.
        lv_has_assign = abap_true.
      ENDIF.

      READ TABLE lt_assign_role TRANSPORTING NO FIELDS WITH KEY mail = <lfs_user>-mail BINARY SEARCH.
      IF sy-subrc = 0.
        lv_has_assign = abap_true.
      ENDIF.

      IF lv_has_assign = abap_true.
        APPEND VALUE #( %tky = <lfs_user>-%tky ) TO failed-user.
        APPEND VALUE #( %tky = <lfs_user>-%tky
                        %msg = new_message( id       = 'ZBC_001'
                                            number   = 026
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = <lfs_user>-userid ) ) TO reported-user.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_assignplant DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateplant FOR VALIDATE ON SAVE
      IMPORTING keys FOR assignplant~validateplant.

ENDCLASS.

CLASS lhc_assignplant IMPLEMENTATION.

  METHOD validateplant.
    DATA: lv_message TYPE string.

    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY assignplant
    FIELDS ( mail plant ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    IF lt_result IS NOT INITIAL.
      ##ITAB_DB_SELECT
      SELECT plant,
             COUNT(*) AS count
        FROM @lt_result AS a
       GROUP BY plant
        INTO TABLE @DATA(lt_plant_count).
      SORT lt_plant_count BY plant.

      SELECT uuid,
             mail,
             plant
        FROM zr_tbc1006
         FOR ALL ENTRIES IN @lt_result
       WHERE mail = @lt_result-mail
        INTO TABLE @DATA(lt_db_data).
      SORT lt_db_data BY plant.

      SELECT plant
        FROM i_plant WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_result
       WHERE plant = @lt_result-plant
        INTO TABLE @DATA(lt_plant).
      SORT lt_plant BY plant.

      LOOP AT lt_result INTO DATA(ls_result).
        CLEAR lv_message.

        IF ls_result-plant IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-003 INTO lv_message.
        ELSE.
          READ TABLE lt_plant TRANSPORTING NO FIELDS WITH KEY plant = ls_result-plant BINARY SEARCH.
          IF sy-subrc <> 0.
            MESSAGE e008(zbc_001) WITH TEXT-003 ls_result-plant INTO lv_message.
          ENDIF.

          READ TABLE lt_plant_count INTO DATA(ls_plant_count) WITH KEY plant = ls_result-plant BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_plant_count-count > 1.
              MESSAGE e009(zbc_001) WITH TEXT-003 ls_result-plant INTO lv_message.
            ELSE.
              READ TABLE lt_db_data TRANSPORTING NO FIELDS WITH KEY mail  = ls_result-mail
                                                                    plant = ls_result-plant BINARY SEARCH.
              IF sy-subrc = 0.
                MESSAGE e009(zbc_001) WITH TEXT-003 ls_result-plant INTO lv_message.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF lv_message IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-assignplant.
          APPEND VALUE #( %tky           = ls_result-%tky
                          %state_area    = 'VALIDATE_PLANT'
                          %element-plant = if_abap_behv=>mk-on
                          %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                  text     = lv_message )
                          %path          = VALUE #( user-%key-mail = ls_result-mail ) ) TO reported-assignplant.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_assigncompany DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validatecompanycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR assigncompany~validatecompanycode.

ENDCLASS.

CLASS lhc_assigncompany IMPLEMENTATION.

  METHOD validatecompanycode.
    DATA: lv_message TYPE string.

    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY assigncompany
    FIELDS ( mail companycode ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    IF lt_result IS NOT INITIAL.
      ##ITAB_DB_SELECT
      SELECT companycode,
             COUNT(*) AS count
        FROM @lt_result AS a
       GROUP BY companycode
        INTO TABLE @DATA(lt_companycode_count).
      SORT lt_companycode_count BY companycode.

      SELECT uuid,
             mail,
             companycode
        FROM zr_tbc1012
         FOR ALL ENTRIES IN @lt_result
       WHERE mail = @lt_result-mail
        INTO TABLE @DATA(lt_db_data).
      SORT lt_db_data BY companycode.

      SELECT companycode
        FROM i_companycode WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_result
       WHERE companycode = @lt_result-companycode
        INTO TABLE @DATA(lt_companycode).
      SORT lt_companycode BY companycode.

      LOOP AT lt_result INTO DATA(ls_result).
        CLEAR lv_message.

        IF ls_result-companycode IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-005 INTO lv_message.
        ELSE.
          READ TABLE lt_companycode TRANSPORTING NO FIELDS WITH KEY companycode = ls_result-companycode BINARY SEARCH.
          IF sy-subrc <> 0.
            MESSAGE e008(zbc_001) WITH TEXT-005 ls_result-companycode INTO lv_message.
          ENDIF.

          READ TABLE lt_companycode_count INTO DATA(ls_companycode_count) WITH KEY companycode = ls_result-companycode BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_companycode_count-count > 1.
              MESSAGE e009(zbc_001) WITH TEXT-005 ls_result-companycode INTO lv_message.
            ELSE.
              READ TABLE lt_db_data TRANSPORTING NO FIELDS WITH KEY mail = ls_result-mail
                                                                    companycode = ls_result-companycode BINARY SEARCH.
              IF sy-subrc = 0.
                MESSAGE e009(zbc_001) WITH TEXT-005 ls_result-companycode INTO lv_message.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF lv_message IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-assigncompany.
          APPEND VALUE #( %tky           = ls_result-%tky
                          %state_area    = 'VALIDATE_COMPANY'
                          %element-companycode = if_abap_behv=>mk-on
                          %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                  text     = lv_message )
                          %path          = VALUE #( user-%key-mail = ls_result-mail ) ) TO reported-assigncompany.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_assignsalesorg DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validatesalesorg FOR VALIDATE ON SAVE
      IMPORTING keys FOR assignsalesorg~validatesalesorg.

ENDCLASS.

CLASS lhc_assignsalesorg IMPLEMENTATION.

  METHOD validatesalesorg.
    DATA: lv_message TYPE string.

    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY assignsalesorg
    FIELDS ( mail salesorganization ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    IF lt_result IS NOT INITIAL.
      ##ITAB_DB_SELECT
      SELECT salesorganization,
             COUNT(*) AS count
        FROM @lt_result AS a
       GROUP BY salesorganization
        INTO TABLE @DATA(lt_salesorg_count).
      SORT lt_salesorg_count BY salesorganization.

      SELECT uuid,
             mail,
             salesorganization
        FROM zr_tbc1013
         FOR ALL ENTRIES IN @lt_result
       WHERE mail = @lt_result-mail
        INTO TABLE @DATA(lt_db_data).
      SORT lt_db_data BY salesorganization.

      SELECT salesorganization
        FROM i_salesorganization WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_result
       WHERE salesorganization = @lt_result-salesorganization
        INTO TABLE @DATA(lt_salesorganization).
      SORT lt_salesorganization BY salesorganization.

      LOOP AT lt_result INTO DATA(ls_result).
        CLEAR lv_message.

        IF ls_result-salesorganization IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-006 INTO lv_message.
        ELSE.
          READ TABLE lt_salesorganization TRANSPORTING NO FIELDS WITH KEY salesorganization = ls_result-salesorganization BINARY SEARCH.
          IF sy-subrc <> 0.
            MESSAGE e008(zbc_001) WITH TEXT-006 ls_result-salesorganization INTO lv_message.
          ENDIF.

          READ TABLE lt_salesorg_count INTO DATA(ls_salesorg_count) WITH KEY salesorganization = ls_result-salesorganization BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_salesorg_count-count > 1.
              MESSAGE e009(zbc_001) WITH TEXT-006 ls_result-salesorganization INTO lv_message.
            ELSE.
              READ TABLE lt_db_data TRANSPORTING NO FIELDS WITH KEY mail = ls_result-mail
                                                                    salesorganization = ls_result-salesorganization BINARY SEARCH.
              IF sy-subrc = 0.
                MESSAGE e009(zbc_001) WITH TEXT-006 ls_result-salesorganization INTO lv_message.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF lv_message IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-assignsalesorg.
          APPEND VALUE #( %tky           = ls_result-%tky
                          %state_area    = 'VALIDATE_SALESORG'
                          %element-salesorganization = if_abap_behv=>mk-on
                          %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                  text     = lv_message )
                          %path          = VALUE #( user-%key-mail = ls_result-mail ) ) TO reported-assignsalesorg.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_assignpurchorg DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validatepurchorg FOR VALIDATE ON SAVE
      IMPORTING keys FOR assignpurchorg~validatepurchorg.

ENDCLASS.

CLASS lhc_assignpurchorg IMPLEMENTATION.

  METHOD validatepurchorg.
    DATA: lv_message TYPE string.

    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY assignpurchorg
    FIELDS ( mail purchasingorganization ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    IF lt_result IS NOT INITIAL.
      ##ITAB_DB_SELECT
      SELECT purchasingorganization,
             COUNT(*) AS count
        FROM @lt_result AS a
       GROUP BY purchasingorganization
        INTO TABLE @DATA(lt_purchorg_count).
      SORT lt_purchorg_count BY purchasingorganization.

      SELECT uuid,
             mail,
             purchasingorganization
        FROM zr_tbc1017
         FOR ALL ENTRIES IN @lt_result
       WHERE mail = @lt_result-mail
        INTO TABLE @DATA(lt_db_data).
      SORT lt_db_data BY purchasingorganization.

      SELECT purchasingorganization
        FROM i_purchasingorganization WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_result
       WHERE purchasingorganization = @lt_result-purchasingorganization
        INTO TABLE @DATA(lt_purchasingorganization).
      SORT lt_purchasingorganization BY purchasingorganization.

      LOOP AT lt_result INTO DATA(ls_result).
        CLEAR lv_message.

        IF ls_result-purchasingorganization IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-007 INTO lv_message.
        ELSE.
          READ TABLE lt_purchasingorganization TRANSPORTING NO FIELDS WITH KEY purchasingorganization = ls_result-purchasingorganization BINARY SEARCH.
          IF sy-subrc <> 0.
            MESSAGE e008(zbc_001) WITH TEXT-007 ls_result-purchasingorganization INTO lv_message.
          ENDIF.

          READ TABLE lt_purchorg_count INTO DATA(ls_purchorg_count) WITH KEY purchasingorganization = ls_result-purchasingorganization BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_purchorg_count-count > 1.
              MESSAGE e009(zbc_001) WITH TEXT-007 ls_result-purchasingorganization INTO lv_message.
            ELSE.
              READ TABLE lt_db_data TRANSPORTING NO FIELDS WITH KEY mail = ls_result-mail
                                                                    purchasingorganization = ls_result-purchasingorganization BINARY SEARCH.
              IF sy-subrc = 0.
                MESSAGE e009(zbc_001) WITH TEXT-007 ls_result-purchasingorganization INTO lv_message.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF lv_message IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-assignpurchorg.
          APPEND VALUE #( %tky           = ls_result-%tky
                          %state_area    = 'VALIDATE_PURCHORG'
                          %element-purchasingorganization = if_abap_behv=>mk-on
                          %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                  text     = lv_message )
                          %path          = VALUE #( user-%key-mail = ls_result-mail ) ) TO reported-assignpurchorg.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_assignshippingpoint DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateshippingpoint FOR VALIDATE ON SAVE
      IMPORTING keys FOR assignshippingpoint~validateshippingpoint.

ENDCLASS.

CLASS lhc_assignshippingpoint IMPLEMENTATION.

  METHOD validateshippingpoint.
    DATA: lv_message TYPE string.

    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY assignshippingpoint
    FIELDS ( mail shippingpoint ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    IF lt_result IS NOT INITIAL.
      ##ITAB_DB_SELECT
      SELECT shippingpoint,
             COUNT(*) AS count
        FROM @lt_result AS a
       GROUP BY shippingpoint
        INTO TABLE @DATA(lt_shippingpoint_count).
      SORT lt_shippingpoint_count BY shippingpoint.

      SELECT uuid,
             mail,
             shippingpoint
        FROM zr_tbc1018
         FOR ALL ENTRIES IN @lt_result
       WHERE mail = @lt_result-mail
        INTO TABLE @DATA(lt_db_data).
      SORT lt_db_data BY shippingpoint.

      SELECT shippingpoint
        FROM i_shippingpoint WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_result
       WHERE shippingpoint = @lt_result-shippingpoint
        INTO TABLE @DATA(lt_shippingpoint).
      SORT lt_shippingpoint BY shippingpoint.

      LOOP AT lt_result INTO DATA(ls_result).
        CLEAR lv_message.

        IF ls_result-shippingpoint IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-008 INTO lv_message.
        ELSE.
          READ TABLE lt_shippingpoint TRANSPORTING NO FIELDS WITH KEY shippingpoint = ls_result-shippingpoint BINARY SEARCH.
          IF sy-subrc <> 0.
            MESSAGE e008(zbc_001) WITH TEXT-008 ls_result-shippingpoint INTO lv_message.
          ENDIF.

          READ TABLE lt_shippingpoint_count INTO DATA(ls_shippingpoint_count) WITH KEY shippingpoint = ls_result-shippingpoint BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_shippingpoint_count-count > 1.
              MESSAGE e009(zbc_001) WITH TEXT-008 ls_result-shippingpoint INTO lv_message.
            ELSE.
              READ TABLE lt_db_data TRANSPORTING NO FIELDS WITH KEY mail  = ls_result-mail
                                                                    shippingpoint = ls_result-shippingpoint BINARY SEARCH.
              IF sy-subrc = 0.
                MESSAGE e009(zbc_001) WITH TEXT-008 ls_result-shippingpoint INTO lv_message.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF lv_message IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-assignshippingpoint.
          APPEND VALUE #( %tky           = ls_result-%tky
                          %state_area    = 'VALIDATE_SHIPPINGPOINT'
                          %element-shippingpoint = if_abap_behv=>mk-on
                          %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                  text     = lv_message )
                          %path          = VALUE #( user-%key-mail = ls_result-mail ) ) TO reported-assignshippingpoint.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_assignrole DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateroleid FOR VALIDATE ON SAVE
      IMPORTING keys FOR assignrole~validateroleid.

ENDCLASS.

CLASS lhc_assignrole IMPLEMENTATION.

  METHOD validateroleid.
    DATA: lv_message TYPE string.

    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY assignrole
    FIELDS ( mail roleid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    IF lt_result IS NOT INITIAL.
      ##ITAB_DB_SELECT
      SELECT roleid,
             COUNT(*) AS count
        FROM @lt_result AS a
       GROUP BY roleid
        INTO TABLE @DATA(lt_role_count).
      SORT lt_role_count BY roleid.

      SELECT uuid,
             mail,
             roleid
        FROM zr_tbc1007
         FOR ALL ENTRIES IN @lt_result
       WHERE mail = @lt_result-mail
        INTO TABLE @DATA(lt_db_data).
      SORT lt_db_data BY roleid.

      SELECT roleid
        FROM zr_tbc1005
         FOR ALL ENTRIES IN @lt_result
       WHERE roleid = @lt_result-roleid
        INTO TABLE @DATA(lt_role).
      SORT lt_role BY roleid.

      LOOP AT lt_result INTO DATA(ls_result).
        CLEAR lv_message.

        IF ls_result-roleid IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-004 INTO lv_message.
        ELSE.
          READ TABLE lt_role TRANSPORTING NO FIELDS WITH KEY roleid = ls_result-roleid BINARY SEARCH.
          IF sy-subrc <> 0.
            MESSAGE e008(zbc_001) WITH TEXT-004 ls_result-roleid INTO lv_message.
          ENDIF.

          READ TABLE lt_role_count INTO DATA(ls_role_count) WITH KEY roleid = ls_result-roleid BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_role_count-count > 1.
              MESSAGE e009(zbc_001) WITH TEXT-004 ls_result-roleid INTO lv_message.
            ELSE.
              READ TABLE lt_db_data TRANSPORTING NO FIELDS WITH KEY mail   = ls_result-mail
                                                                    roleid = ls_result-roleid BINARY SEARCH.
              IF sy-subrc = 0.
                MESSAGE e009(zbc_001) WITH TEXT-004 ls_result-roleid INTO lv_message.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF lv_message IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-assignrole.
          APPEND VALUE #( %tky            = ls_result-%tky
                          %state_area     = 'VALIDATE_ROLE'
                          %element-roleid = if_abap_behv=>mk-on
                          %msg            = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                   text     = lv_message )
                          %path           = VALUE #( user-%key-mail = ls_result-mail ) ) TO reported-assignrole.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
