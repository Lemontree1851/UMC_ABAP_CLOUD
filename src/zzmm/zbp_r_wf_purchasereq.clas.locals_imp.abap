CLASS lhc_zr_wf_purchasereq DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zr_wf_purchasereq RESULT result.

    METHODS batchprocess FOR MODIFY
      IMPORTING keys FOR ACTION zr_wf_purchasereq~batchprocess RESULT result.

    METHODS createpurchaseorder FOR MODIFY
      IMPORTING keys FOR ACTION zr_wf_purchasereq~createpurchaseorder RESULT result.

ENDCLASS.

CLASS lhc_zr_wf_purchasereq IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD batchprocess.
  ENDMETHOD.

  METHOD createpurchaseorder.
  ENDMETHOD.

ENDCLASS.
