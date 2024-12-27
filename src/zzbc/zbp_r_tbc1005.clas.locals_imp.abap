CLASS lhc_accessbtn DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setfunctionid FOR DETERMINE ON SAVE
      IMPORTING keys FOR accessbtn~setfunctionid.
    METHODS validateaccessid FOR VALIDATE ON SAVE
      IMPORTING keys FOR accessbtn~validateaccessid.

ENDCLASS.

CLASS lhc_accessbtn IMPLEMENTATION.

  METHOD setfunctionid.
    READ ENTITIES OF zr_tbc1005 IN LOCAL MODE
    ENTITY accessbtn
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    IF lt_result IS NOT INITIAL.
      SELECT *
        FROM zc_tbc1015
         FOR ALL ENTRIES IN @lt_result
       WHERE accessid = @lt_result-accessid
        INTO TABLE @DATA(lt_function).        "#EC CI_ALL_FIELDS_NEEDED
      SORT lt_function BY accessid.

      LOOP AT lt_result INTO DATA(ls_result).
        READ TABLE lt_function INTO DATA(ls_function) WITH KEY accessid = ls_result-accessid BINARY SEARCH.
        IF sy-subrc = 0.
          MODIFY ENTITIES OF zr_tbc1005 IN LOCAL MODE
          ENTITY accessbtn
          UPDATE FIELDS ( functionid ) WITH VALUE #( ( %tky       = ls_result-%tky
                                                       functionid = ls_function-functionid ) )
          REPORTED DATA(modifyreported).

          reported = CORRESPONDING #( DEEP modifyreported ).
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD validateaccessid.
    DATA: lv_message TYPE string.

    READ ENTITIES OF zr_tbc1005 IN LOCAL MODE
    ENTITY accessbtn
    FIELDS ( roleid accessid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    IF lt_result IS NOT INITIAL.
      ##ITAB_DB_SELECT
      SELECT accessid,
             COUNT(*) AS count
        FROM @lt_result AS a
       GROUP BY accessid
        INTO TABLE @DATA(lt_accessid_count).
      SORT lt_accessid_count BY accessid.

      SELECT uuid,
             roleid,
             accessid
        FROM zr_tbc1016
         FOR ALL ENTRIES IN @lt_result
       WHERE roleid = @lt_result-roleid
        INTO TABLE @DATA(lt_db_data).
      SORT lt_db_data BY roleid accessid.

      LOOP AT lt_result INTO DATA(ls_result).
        CLEAR lv_message.

        IF ls_result-accessid IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-002 INTO lv_message.
        ELSE.
          READ TABLE lt_accessid_count INTO DATA(ls_accessid_count) WITH KEY accessid = ls_result-accessid BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_accessid_count-count > 1.
              MESSAGE e009(zbc_001) WITH TEXT-002 ls_result-accessid INTO lv_message.
            ELSE.
              READ TABLE lt_db_data TRANSPORTING NO FIELDS WITH KEY roleid = ls_result-roleid
                                                                    accessid = ls_result-accessid
                                                                    BINARY SEARCH.
              IF sy-subrc = 0.
                MESSAGE e009(zbc_001) WITH TEXT-002 ls_result-accessid INTO lv_message.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF lv_message IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-accessbtn.
          APPEND VALUE #( %tky           = ls_result-%tky
                          %state_area    = 'VALIDATE_ACCESSID'
                          %element-accessid = if_abap_behv=>mk-on
                          %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                  text     = lv_message )
                          %path          = VALUE #( role-%key-roleid = ls_result-roleid ) ) TO reported-accessbtn.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

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
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE role.

ENDCLASS.

CLASS lhc_role IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITIES OF zr_tbc1005 IN LOCAL MODE
    ENTITY role
    FIELDS ( roleid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_role).

    IF lt_role IS NOT INITIAL.
      SELECT uuid,
             userid,
             roleid
        FROM zr_tbc1007
        JOIN zr_tbc1004 ON zr_tbc1004~mail = zr_tbc1007~mail
         FOR ALL ENTRIES IN @lt_role
       WHERE roleid = @lt_role-roleid
        INTO TABLE @DATA(lt_assign).
      SORT lt_assign BY roleid.

      SELECT uuid,
             roleid
        FROM zr_tbc1016
         FOR ALL ENTRIES IN @lt_role
       WHERE roleid = @lt_role-roleid
        INTO TABLE @DATA(lt_assign_access).
      SORT lt_assign_access BY roleid.
    ENDIF.

    LOOP AT lt_role ASSIGNING FIELD-SYMBOL(<lfs_role>).
      READ TABLE lt_assign INTO DATA(ls_assign) WITH KEY roleid = <lfs_role>-roleid BINARY SEARCH.
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = <lfs_role>-%tky ) TO failed-role.
        APPEND VALUE #( %tky = <lfs_role>-%tky
                        %msg = new_message( id       = 'ZBC_001'
                                            number   = 023
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = <lfs_role>-roleid
                                            v2       = ls_assign-userid ) ) TO reported-role.
      ENDIF.

      READ TABLE lt_assign_access TRANSPORTING NO FIELDS WITH KEY roleid = <lfs_role>-roleid BINARY SEARCH.
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = <lfs_role>-%tky ) TO failed-role.
        APPEND VALUE #( %tky = <lfs_role>-%tky
                        %msg = new_message( id       = 'ZBC_001'
                                            number   = 032
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = <lfs_role>-roleid ) ) TO reported-role.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
