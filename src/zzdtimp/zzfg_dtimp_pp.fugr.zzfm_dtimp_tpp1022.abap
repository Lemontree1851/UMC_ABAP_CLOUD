FUNCTION zzfm_dtimp_tpp1022.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA:
    ls_data     TYPE zzs_dtimp_tpp1022,
    lt_data     TYPE TABLE OF zzs_dtimp_tpp1022,
    lo_root_exc TYPE REF TO cx_root.

  CONSTANTS:
    lc_alpha_in  TYPE string        VALUE 'IN'.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).

    CLEAR ls_data.

    IF <line>-('order_number') IS INITIAL.
      CONTINUE.
    ENDIF.

    ls_data-order_number     = <line>-('order_number').
    ls_data-material         = <line>-('material').
    ls_data-unloading_point  = <line>-('unloading_point').

    TRY.
        ls_data-order_number  = |{ ls_data-order_number ALPHA = IN }|.
        ls_data-material      = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_data-material ).
        ##NO_HANDLER
      CATCH zzcx_custom_exception INTO lo_root_exc.
    ENDTRY.

    MODIFY ENTITY i_productionordertp
    UPDATE FIELDS (
                    unloadingpointname
                  )
    WITH VALUE #(
                  (
                    %key-productionorder     = ls_data-order_number
                    %data-unloadingpointname = ls_data-unloading_point
                  )
                 )
    FAILED DATA(failed)
    REPORTED DATA(reported)
    MAPPED DATA(mapped).

    IF failed IS INITIAL.
      COMMIT ENTITIES
        RESPONSES
          FAILED   DATA(failed_c)
          REPORTED DATA(reported_c).
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      <line>-('Type') = 'S'.
    ELSE.
      ROLLBACK ENTITIES.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      <line>-('Type') = 'E'.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
