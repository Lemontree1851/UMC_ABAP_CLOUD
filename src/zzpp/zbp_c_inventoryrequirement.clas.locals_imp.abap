CLASS lhc_zc_inventoryrequirement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_inventoryrequirement RESULT result.

*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE zc_inventoryrequirement.
*
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE zc_inventoryrequirement.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE zc_inventoryrequirement.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_inventoryrequirement RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_inventoryrequirement.

ENDCLASS.

CLASS lhc_zc_inventoryrequirement IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD create.
*  ENDMETHOD.
*
*  METHOD update.
*  ENDMETHOD.
*
*  METHOD delete.
*  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_inventoryrequirement DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_inventoryrequirement IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
