FUNCTION zzfm_dtimp_demo.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA: ls_data TYPE zzt_dtimp_demo,
        lt_data TYPE TABLE OF zzt_dtimp_demo.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).

    CLEAR ls_data.
    ls_data-purchase_order      = <line>-('purchase_order').
    ls_data-purchase_order_item = <line>-('purchase_order_item').
    ls_data-loading_quantity    = <line>-('loading_quantity').

    IF ls_data-purchase_order IS INITIAL.
      <line>-('Message') = 'The value of purchase order cannot be empty.'.
      <line>-('Type') = 'E'.
      CONTINUE.
    ELSE.
      IF strlen( <line>-('purchase_order') ) GT 10.
        <line>-('Message') = |Purchase order { <line>-('purchase_order') } exceeded 10 digits.|.
        <line>-('Type') = 'E'.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF ls_data-purchase_order_item IS INITIAL.
      <line>-('Message') = 'The value of purchase order item cannot be empty.'.
      <line>-('Type') = 'E'.
      CONTINUE.
    ENDIF.

*    SELECT COUNT(*)
*      FROM i_purchaseorderapi01
*     WHERE purchaseorder = @ls_data-purchase_order.
*    IF sy-subrc <> 0.
*      <line>-('Message') = |{ 'Purchase order' } { ls_data-purchase_order } { 'does not exist.' }|.
*      <line>-('Type') = 'E'.
*      CONTINUE.
*    ENDIF.

*    SELECT COUNT(*)
*      FROM i_purchaseorderitemapi01
*     WHERE purchaseorder     = @ls_data-purchase_order
*       AND purchaseorderitem = @ls_data-purchase_order_item.
*    IF sy-subrc <> 0.
*      <line>-('Message') = |{ 'Purchase order' } { ls_data-purchase_order } { ls_data-purchase_order_item } { 'does not exist.' }|.
*      <line>-('Type') = 'E'.
*      CONTINUE.
*    ENDIF.

    ls_data-created_by = sy-uname.
    GET TIME STAMP FIELD ls_data-created_at.

    ls_data-last_changed_by = sy-uname.
    GET TIME STAMP FIELD ls_data-last_changed_at.
    GET TIME STAMP FIELD ls_data-local_last_changed_at.

    MODIFY zzt_dtimp_demo FROM @ls_data.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      APPEND ls_data TO lt_data.
    ELSE.
      ROLLBACK WORK.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      <line>-('Type') = 'E'.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
