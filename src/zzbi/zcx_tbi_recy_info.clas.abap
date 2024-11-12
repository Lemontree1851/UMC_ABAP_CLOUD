CLASS zcx_tbi_recy_info DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

    METHODS constructor
      IMPORTING
        !textid           LIKE if_t100_message=>t100key OPTIONAL
        !previous         LIKE previous OPTIONAL
        !iv_severity      TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        !iv_company_code  TYPE bukrs OPTIONAL
        !iv_recovery_type TYPE ze_recycle_type OPTIONAL
        !iv_customer      TYPE kunnr OPTIONAL
        !iv_recovery_year TYPE gjahr OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mv_company_code  TYPE bukrs,
          mv_recovery_type TYPE ze_recycle_type,
          mv_customer      TYPE kunnr,
          mv_recovery_year TYPE gjahr.
ENDCLASS.



CLASS ZCX_TBI_RECY_INFO IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->mv_company_code = iv_company_code.
    me->mv_recovery_type = iv_recovery_type.
    me->mv_customer = iv_customer.
    me->mv_recovery_year = iv_recovery_year.
    me->if_abap_behv_message~m_severity = iv_severity.
  ENDMETHOD.
ENDCLASS.
