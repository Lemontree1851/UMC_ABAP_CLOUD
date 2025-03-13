FUNCTION zzfm_dtimp_tbc1008.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA: ls_data TYPE ztbc_1008,
        lt_data TYPE TABLE OF ztbc_1008.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).
    CLEAR ls_data.
    ls_data-workflow_id    = 'purchaserequisition'.
    ls_data-application_id = <line>-('APPLICATION_ID').
    ls_data-pr_type        = <line>-('PR_TYPE').
    ls_data-apply_depart   = <line>-('APPLY_DEPART').
    ls_data-order_type     = <line>-('ORDER_TYPE').
    ls_data-buy_purpose    = <line>-('BUY_PURPOSE').
    ls_data-kyoten         = <line>-('KYOTEN').
    ls_data-knttp          = <line>-('KNTTP').
    ls_data-cost_center    = <line>-('COST_CENTER').
    ls_data-purchase_group = <line>-('PURCHASE_GROUP').
    ls_data-amount_from    = <line>-('AMOUNT_FROM').
    ls_data-amount_to      = <line>-('AMOUNT_TO').

    ls_data-created_by = sy-uname.
    GET TIME STAMP FIELD ls_data-created_at.
    ls_data-last_changed_by = sy-uname.
    GET TIME STAMP FIELD ls_data-last_changed_at.
    GET TIME STAMP FIELD ls_data-local_last_changed_at.

    MODIFY ztbc_1008 FROM @ls_data.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      <line>-('Type') = 'S'.
      <line>-('Message') = |データが保存されました。|.
    ELSE.
      ROLLBACK WORK.
      <line>-('Type') = 'E'.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
