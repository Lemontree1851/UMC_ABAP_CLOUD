CLASS lhc_accessbtn DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE accessbtn.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE accessbtn.

ENDCLASS.

CLASS lhc_accessbtn IMPLEMENTATION.

  METHOD precheck_update.
    READ ENTITIES OF zr_tbc1014 IN LOCAL MODE
    ENTITY accessbtn
    FIELDS ( accessid ) WITH CORRESPONDING #( entities )
    RESULT DATA(lt_dbdata).
    SORT lt_dbdata BY uuid.

    IF lt_dbdata IS NOT INITIAL.
      SELECT uuid,
             roleid,
             functionid,
             accessid
        FROM zr_tbc1016
         FOR ALL ENTRIES IN @lt_dbdata
       WHERE accessid = @lt_dbdata-accessid
        INTO TABLE @DATA(lt_assign).
      SORT lt_assign BY accessid.
    ENDIF.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entity>).
      READ TABLE lt_dbdata INTO DATA(ls_dbdata) WITH KEY uuid = <lfs_entity>-uuid BINARY SEARCH.
      IF sy-subrc = 0 AND ls_dbdata-accessid <> <lfs_entity>-accessid.
        READ TABLE lt_assign INTO DATA(ls_assign) WITH KEY accessid = ls_dbdata-accessid BINARY SEARCH.
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
    FIELDS ( accessid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_accessid).

    IF lt_accessid IS NOT INITIAL.
      SELECT uuid,
             roleid,
             functionid,
             accessid
        FROM zr_tbc1016
         FOR ALL ENTRIES IN @lt_accessid
       WHERE accessid = @lt_accessid-accessid
        INTO TABLE @DATA(lt_assign).
      SORT lt_assign BY accessid.
    ENDIF.

    LOOP AT lt_accessid ASSIGNING FIELD-SYMBOL(<lfs_accessid>).
      READ TABLE lt_assign INTO DATA(ls_assign) WITH KEY accessid = <lfs_accessid>-accessid BINARY SEARCH.
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = <lfs_accessid>-%tky ) TO failed-accessbtn.
        APPEND VALUE #( %tky = <lfs_accessid>-%tky
                        %msg = new_message( id       = 'ZBC_001'
                                            number   = 024
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = <lfs_accessid>-accessid
                                            v2       = ls_assign-roleid ) ) TO reported-accessbtn.
      ENDIF.
    ENDLOOP.
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
