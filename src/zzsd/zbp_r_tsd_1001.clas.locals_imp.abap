CLASS lhc_zr_tsd_1001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zr_tsd_1001
        RESULT result,
      get_instance_authorizations FOR INSTANCE AUTHORIZATION
        IMPORTING keys REQUEST requested_authorizations FOR zr_tsd_1001
        RESULT    result.
ENDCLASS.

CLASS lhc_zr_tsd_1001 IMPLEMENTATION.
  METHOD get_global_authorizations.
    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
    DATA(lv_access) = zzcl_common_utils=>get_access_by_user( lv_user_email ).

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      IF lv_access CS 'shipmentstorageloc-Create'.
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg    = new_message( id       = 'ZBC_001'
                                               number   = 031
                                               severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-zr_tsd_1001.
      ENDIF.
    ENDIF.

    IF requested_authorizations-%action-edit = if_abap_behv=>mk-on.
      IF lv_access CS 'shipmentstorageloc-Edit'.
        result-%action-edit = if_abap_behv=>auth-allowed.
      ELSE.
        result-%action-edit = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      IF lv_access CS 'shipmentstorageloc-Delete'.
        result-%delete = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.
  ENDMETHOD.
  METHOD get_instance_authorizations.
    READ ENTITIES OF zr_tsd_1001 IN LOCAL MODE
    ENTITY zr_tsd_1001
    FIELDS ( plant ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
    DATA(lv_plant) = zzcl_common_utils=>get_plant_by_user( lv_user_email ).

    LOOP AT lt_data INTO DATA(ls_data).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      <lfs_result>-%tky = ls_data-%tky.

      IF lv_plant CS ls_data-plant.
        <lfs_result>-%delete = if_abap_behv=>auth-allowed.
        <lfs_result>-%action-edit = if_abap_behv=>auth-allowed.
      ELSE.
        <lfs_result>-%delete = if_abap_behv=>auth-unauthorized.
        <lfs_result>-%action-edit = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg    = new_message( id       = 'ZBC_001'
                                               number   = 027
                                               severity = if_abap_behv_message=>severity-error
                                               v1       = ls_data-plant )
                        %global = if_abap_behv=>mk-on ) TO reported-zr_tsd_1001.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
