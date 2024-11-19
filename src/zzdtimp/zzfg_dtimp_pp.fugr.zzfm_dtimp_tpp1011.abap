FUNCTION zzfm_dtimp_tpp1011.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA: ls_data TYPE ztpp_1011,
        lt_data TYPE TABLE OF ztpp_1011.

  DATA: lv_regular_expression TYPE string VALUE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        lv_message            TYPE string,
        lv_all_msg            TYPE string.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  " Example for a POSIX regular expression engine (More configuration options are available
  " as optional parameters of the method POSIX).
  DATA(lo_posix_engine) = xco_cp_regular_expression=>engine->posix(
    iv_ignore_case = abap_true
  ).

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).

    CLEAR ls_data.
    ls_data-plant         = <line>-('Plant').
    ls_data-customer      = <line>-('Customer').
    ls_data-receiver      = <line>-('Receiver').
    ls_data-receiver_type = <line>-('ReceiverType').
    ls_data-mail_address  = <line>-('MailAddress').

    CLEAR lv_all_msg.
    IF ls_data-plant IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-001 INTO lv_all_msg.
    ELSE.
      SELECT SINGLE * FROM i_plant WHERE plant = @ls_data-plant INTO @DATA(ls_plant).
      IF sy-subrc <> 0.
        MESSAGE e007(zbc_001) WITH TEXT-001 ls_data-plant INTO lv_all_msg.
      ENDIF.
    ENDIF.

    IF ls_data-customer IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-002 INTO lv_message.
      lv_all_msg = zzcl_common_utils=>merge_message( iv_message1 = lv_all_msg iv_message2 = lv_message iv_symbol = '/' ).
    ELSE.
      DATA(lv_customer) = |{ ls_data-customer ALPHA = IN }|.
      CONDENSE lv_customer NO-GAPS.
      SELECT SINGLE * FROM i_customer WHERE customer = @lv_customer INTO @DATA(ls_customer).
      IF sy-subrc <> 0.
        MESSAGE e007(zbc_001) WITH TEXT-002 ls_data-customer INTO lv_message.
        lv_all_msg = zzcl_common_utils=>merge_message( iv_message1 = lv_all_msg iv_message2 = lv_message iv_symbol = '/' ).
      ELSE.
        ls_data-customer = lv_customer.
      ENDIF.
    ENDIF.

    IF ls_data-receiver_type IS NOT INITIAL AND ls_data-receiver_type <> 'C'.
      MESSAGE e008(zbc_001) WITH TEXT-003 ls_data-receiver_type INTO lv_message.
      lv_all_msg = zzcl_common_utils=>merge_message( iv_message1 = lv_all_msg iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF ls_data-mail_address IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-004 INTO lv_message.
      lv_all_msg = zzcl_common_utils=>merge_message( iv_message1 = lv_all_msg iv_message2 = lv_message iv_symbol = '/' ).
    ELSE.
      DATA(lv_match) = xco_cp=>string( ls_data-mail_address )->matches( iv_regular_expression = lv_regular_expression
                                                                        io_engine             = lo_posix_engine ).
      IF lv_match IS INITIAL.
        MESSAGE e008(zbc_001) WITH TEXT-004 ls_data-mail_address INTO lv_message.
        lv_all_msg = zzcl_common_utils=>merge_message( iv_message1 = lv_all_msg iv_message2 = lv_message iv_symbol = '/' ).
      ENDIF.
    ENDIF.

    IF ls_data-receiver IS INITIAL.
      MESSAGE e006(zbc_001) WITH TEXT-005 INTO lv_message.
      lv_all_msg = zzcl_common_utils=>merge_message( iv_message1 = lv_all_msg iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF..

    IF lv_all_msg IS NOT INITIAL.
      <line>-('Type') = 'E'.
      <line>-('Message') = lv_all_msg.
    ELSE.
      TRY.
          ls_data-uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          " handle exception
      ENDTRY.

      ls_data-created_by = sy-uname.
      GET TIME STAMP FIELD ls_data-created_at.

      ls_data-last_changed_by = sy-uname.
      GET TIME STAMP FIELD ls_data-last_changed_at.
      GET TIME STAMP FIELD ls_data-local_last_changed_at.

      MODIFY ztpp_1011 FROM @ls_data.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
        <line>-('Type') = 'S'.
        <line>-('Message') = 'Success'.
      ELSE.
        ROLLBACK WORK.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        <line>-('Type') = 'E'.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
