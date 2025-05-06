FUNCTION zzfm_dtimp_tpp1024.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA: ls_data TYPE zzs_dtimp_tpp1024,
        lt_data TYPE TABLE OF zzs_dtimp_tpp1024.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).
    CLEAR ls_data.

    IF <line>-('order_number') IS INITIAL
    OR <line>-('order_item') IS INITIAL
    OR <line>-('component') IS INITIAL.
      <line>-('Type') = 'E'.
      CONTINUE.
    ENDIF.

    ls_data-order_number = <line>-('order_number').
    ls_data-order_item = <line>-('order_item').
    ls_data-component = <line>-('component').
    ls_data-quantity = <line>-('quantity').

    ls_data-order_number = |{ ls_data-order_number ALPHA = IN }|.
    ls_data-order_item = |{ ls_data-order_item ALPHA = IN }|.
    ls_data-component = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in
                                                                       iv_input = ls_data-component ).
    SELECT SINGLE reservation,
                  reservationitem,
                  reservationrecordtype
      FROM i_productionorderopcomponenttp WITH PRIVILEGED ACCESS
     WHERE productionorder = @ls_data-order_number
       AND billofmaterialitemnumber = @ls_data-order_item
       AND material = @ls_data-component
      INTO @DATA(ls_component).
    IF sy-subrc = 0.
      MODIFY ENTITIES OF i_productionordertp
        ENTITY productionordercomponent
        UPDATE FIELDS ( requiredquantity )
        WITH VALUE #( (
                        %key-reservation           = ls_component-reservation
                        %key-reservationitem       = ls_component-reservationitem
                        %key-reservationrecordtype = ls_component-reservationrecordtype
                        %data-requiredquantity     = ls_data-quantity
                      ) )
        FAILED DATA(failed)
        REPORTED DATA(reported)
        MAPPED DATA(mapped).

      IF failed IS INITIAL.
        " No errors occurred
        COMMIT ENTITIES
          RESPONSES
            FAILED   DATA(failed_commit)
            REPORTED DATA(reported_commit).
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        <line>-('Type') = 'S'.
      ELSE.
        ROLLBACK ENTITIES.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        <line>-('Type') = 'E'.
      ENDIF.
    ELSE.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      <line>-('Type') = 'E'.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
