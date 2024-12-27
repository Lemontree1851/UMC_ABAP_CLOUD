FUNCTION zzfm_dtimp_tbc1001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA: ls_data TYPE ztbc_1001,
        lt_data TYPE TABLE OF ztbc_1001.

  DATA lv_message TYPE string.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).

    CLEAR ls_data.
    ls_data-zid      = <line>-('ZID').
    ls_data-zkey1    = <line>-('Zkey1').
    ls_data-zkey2    = <line>-('Zkey2').
    ls_data-zkey3    = <line>-('Zkey3').
    ls_data-zkey4    = <line>-('Zkey4').
    ls_data-zkey5    = <line>-('Zkey5').
    ls_data-zkey6    = <line>-('Zkey6').
    ls_data-zkey7    = <line>-('Zkey7').
    ls_data-zkey8    = <line>-('Zkey8').
    ls_data-zkey9    = <line>-('Zkey9').
    ls_data-zseq     = <line>-('Zseq').
    ls_data-zvalue1  = <line>-('Zvalue1').
    ls_data-zvalue2  = <line>-('Zvalue2').
    ls_data-zvalue3  = <line>-('Zvalue3').
    ls_data-zvalue4  = <line>-('Zvalue4').
    ls_data-zvalue5  = <line>-('Zvalue5').
    ls_data-zvalue6  = <line>-('Zvalue6').
    ls_data-zvalue7  = <line>-('Zvalue7').
    ls_data-zvalue8  = <line>-('Zvalue8').
    ls_data-zvalue9  = <line>-('Zvalue9').
    ls_data-zremark  = <line>-('Zremark').
    ls_data-zprogram = <line>-('Zprogram').
    ls_data-unmodifiable = <line>-('Unmodifiable').

    IF ls_data-zid IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-001 INTO <line>-('Message').
    ENDIF.

    IF ls_data-zseq IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-002 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF ls_data-zprogram IS INITIAL.
      MESSAGE s006(zbc_001) WITH TEXT-003 INTO lv_message.
      <line>-('Message') = zzcl_common_utils=>merge_message( iv_message1 = <line>-('Message') iv_message2 = lv_message iv_symbol = '/' ).
    ENDIF.

    IF <line>-('Message') IS NOT INITIAL.
      <line>-('Type') = 'E'.
    ELSE.
      ls_data-created_by = sy-uname.
      GET TIME STAMP FIELD ls_data-created_at.

      ls_data-last_changed_by = sy-uname.
      GET TIME STAMP FIELD ls_data-last_changed_at.
      GET TIME STAMP FIELD ls_data-local_last_changed_at.

      MODIFY ztbc_1001 FROM @ls_data.
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
