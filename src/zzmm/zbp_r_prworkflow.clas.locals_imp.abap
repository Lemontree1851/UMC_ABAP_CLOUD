CLASS lhc_purchasereq DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR purchasereq RESULT result.

    METHODS batchprocess FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~batchprocess RESULT result.

    METHODS createpurchaseorder FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~createpurchaseorder RESULT result.

    METHODS checkrecords FOR VALIDATE ON SAVE
      IMPORTING keys FOR purchasereq~checkrecords.

ENDCLASS.

CLASS lhc_purchasereq IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD batchprocess.
  ENDMETHOD.

  METHOD createpurchaseorder.
  ENDMETHOD.

  METHOD checkrecords.
  ENDMETHOD.

ENDCLASS.
