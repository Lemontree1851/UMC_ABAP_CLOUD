CLASS lhc_accessbtn DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE accessbtn.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE accessbtn.
    METHODS validateaccessid FOR VALIDATE ON SAVE
      IMPORTING keys FOR accessbtn~validateaccessid.

ENDCLASS.

CLASS lhc_accessbtn IMPLEMENTATION.

  METHOD precheck_update.
    READ ENTITIES OF zr_tbc1014 IN LOCAL MODE
    ENTITY accessbtn
    FIELDS ( functionid accessid ) WITH CORRESPONDING #( entities )
    RESULT DATA(lt_dbdata).
    SORT lt_dbdata BY uuid.

    IF lt_dbdata IS NOT INITIAL.
      SELECT uuid,
             roleid,
             functionid,
             accessid
        FROM zr_tbc1016
         FOR ALL ENTRIES IN @lt_dbdata
       WHERE functionid = @lt_dbdata-functionid
         AND accessid = @lt_dbdata-accessid
        INTO TABLE @DATA(lt_assign).
      SORT lt_assign BY functionid accessid.
    ENDIF.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entity>) WHERE accessid IS NOT INITIAL.
      READ TABLE lt_dbdata INTO DATA(ls_dbdata) WITH KEY uuid = <lfs_entity>-uuid BINARY SEARCH.
      IF sy-subrc = 0 AND ls_dbdata-accessid <> <lfs_entity>-accessid.
        READ TABLE lt_assign INTO DATA(ls_assign) WITH KEY functionid = ls_dbdata-functionid
                                                           accessid = ls_dbdata-accessid BINARY SEARCH.
        IF sy-subrc = 0.
          MESSAGE e024(zbc_001) WITH ls_dbdata-accessid INTO DATA(lv_message).
          APPEND VALUE #( %tky = <lfs_entity>-%tky ) TO failed-accessbtn.
          APPEND VALUE #( %tky = <lfs_entity>-%tky
                          %msg = new_message( id       = 'ZBC_001'
                                              number   = 024
                                              severity = if_abap_behv_message=>severity-error
                                              v1       = ls_dbdata-accessid
                                              v2       = ls_assign-roleid ) ) TO reported-accessbtn.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITIES OF zr_tbc1014 IN LOCAL MODE
    ENTITY accessbtn
    FIELDS ( functionid accessid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_accessid).

    IF lt_accessid IS NOT INITIAL.
      SELECT uuid,
             functionid,
             accessid
        FROM zr_tbc1015
         FOR ALL ENTRIES IN @lt_accessid
       WHERE functionid = @lt_accessid-functionid
         AND accessid = @lt_accessid-accessid
        INTO TABLE @DATA(lt_db_data).
      SORT lt_db_data BY functionid accessid.

      SELECT uuid,
             roleid,
             functionid,
             accessid
        FROM zr_tbc1016
         FOR ALL ENTRIES IN @lt_accessid
       WHERE functionid = @lt_accessid-functionid
         AND accessid = @lt_accessid-accessid
        INTO TABLE @DATA(lt_assign).
      SORT lt_assign BY functionid accessid.
    ENDIF.

    LOOP AT lt_accessid ASSIGNING FIELD-SYMBOL(<lfs_accessid>).
      READ TABLE lt_assign INTO DATA(ls_assign) WITH KEY functionid = <lfs_accessid>-functionid
                                                         accessid = <lfs_accessid>-accessid BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_db_data INTO DATA(ls_db_data) WITH KEY functionid = <lfs_accessid>-functionid
                                                             accessid = <lfs_accessid>-accessid BINARY SEARCH.
        IF ls_db_data-uuid = <lfs_accessid>-uuid.
          APPEND VALUE #( %tky = <lfs_accessid>-%tky ) TO failed-accessbtn.
          APPEND VALUE #( %tky = <lfs_accessid>-%tky
                          %msg = new_message( id       = 'ZBC_001'
                                              number   = 024
                                              severity = if_abap_behv_message=>severity-error
                                              v1       = <lfs_accessid>-accessid
                                              v2       = ls_assign-roleid ) ) TO reported-accessbtn.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateaccessid.
    DATA: lv_message TYPE string.

    READ ENTITIES OF zr_tbc1014 IN LOCAL MODE
    ENTITY accessbtn
    FIELDS ( accessid ) WITH CORRESPONDING #( keys )
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
             functionid,
             accessid
        FROM zr_tbc1015
         FOR ALL ENTRIES IN @lt_result
       WHERE accessid = @lt_result-accessid
        INTO TABLE @DATA(lt_db_data).
      SORT lt_db_data BY accessid.

      LOOP AT lt_result INTO DATA(ls_result).
        CLEAR lv_message.

        IF ls_result-accessid IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-001 INTO lv_message.
        ELSE.
          READ TABLE lt_accessid_count INTO DATA(ls_accessid_count) WITH KEY accessid = ls_result-accessid BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_accessid_count-count > 1.
              MESSAGE e009(zbc_001) WITH TEXT-001 ls_result-accessid INTO lv_message.
            ELSE.
              READ TABLE lt_db_data TRANSPORTING NO FIELDS WITH KEY accessid = ls_result-accessid
                                                                    BINARY SEARCH.
              IF sy-subrc = 0.
                MESSAGE e009(zbc_001) WITH TEXT-001 ls_result-accessid INTO lv_message.
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
                          %path          = VALUE #( function-%key-functionid = ls_result-functionid ) ) TO reported-accessbtn.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_function DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR function RESULT result.
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE function.

ENDCLASS.

CLASS lhc_function IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITIES OF zr_tbc1014 IN LOCAL MODE
    ENTITY function
    FIELDS ( functionid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_function).

    IF lt_function IS NOT INITIAL.
      SELECT uuid,
             roleid,
             functionid,
             accessid
        FROM zr_tbc1016
         FOR ALL ENTRIES IN @lt_function
       WHERE functionid = @lt_function-functionid
        INTO TABLE @DATA(lt_assign).
      SORT lt_assign BY functionid.
    ENDIF.

    LOOP AT lt_function ASSIGNING FIELD-SYMBOL(<lfs_function>).
      READ TABLE lt_assign INTO DATA(ls_assign) WITH KEY functionid = <lfs_function>-functionid BINARY SEARCH.
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = <lfs_function>-%tky ) TO failed-function.
        APPEND VALUE #( %tky = <lfs_function>-%tky
                        %msg = new_message( id       = 'ZBC_001'
                                            number   = 025
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = <lfs_function>-functionid
                                            v2       = ls_assign-roleid ) ) TO reported-function.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
