FUNCTION zzfg_dtimp_sd_1001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA: ls_data TYPE ztsd_1001,
        lt_data TYPE TABLE OF ztsd_1001.
  CREATE DATA eo_data TYPE TABLE OF (iv_struc).
  eo_data->* = io_data->*.

  lt_data = VALUE #( FOR <fs_line> IN eo_data->*
                     ( customer                     = <fs_line>-('customer')
                       billing_to_party             = <fs_line>-('billing_to_party')
                       plant                        = <fs_line>-('plant')
                       issue_storage_location       = <fs_line>-('issue_storage_location')
                       finished_storage_location    = <fs_line>-('finished_storage_location')
                       return_storage_location      = <fs_line>-('return_storage_location')
                       repair_storage_location      = <fs_line>-('repair_storage_location')
                       vim_storage_location         = <fs_line>-('vim_storage_location')
                     ) ).
  SELECT
    *
  FROM ztsd_1001
  FOR ALL ENTRIES IN @lt_data
  WHERE customer = @lt_data-customer
    AND billing_to_party = @lt_data-billing_to_party
    AND plant = @lt_data-plant
  INTO TABLE @DATA(lt_old_data).
  SORT lt_old_data BY customer billing_to_party plant.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<fs_record>).
    MOVE-CORRESPONDING <fs_record> TO ls_data.
    READ TABLE lt_old_data INTO DATA(ls_old_data) WITH KEY customer = ls_data-customer
        billing_to_party = ls_data-billing_to_party plant = ls_data-plant BINARY SEARCH.
    IF sy-subrc = 0.
      ls_data-local_created_by = ls_old_data-local_created_by.
      ls_data-local_created_at = ls_old_data-local_created_at.
    ELSE.
      ls_data-local_created_by = sy-uname.
      GET TIME STAMP FIELD ls_data-local_created_at.
    ENDIF.
    ls_data-local_last_changed_by = sy-uname.
    GET TIME STAMP FIELD ls_data-local_last_changed_at.
    GET TIME STAMP FIELD ls_data-lat_cahanged_at.

    MODIFY ztsd_1001 FROM @ls_data.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <fs_record>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      <fs_record>-('Type') = 'E'.
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
