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

*&--ADD BEGIN BY XINLEI XU 2025/02/28
    ls_data-quantity         = <line>-('quantity').
    ls_data-quantity_uom     = <line>-('quantity_uom').
    ls_data-basic_start_date = <line>-('basic_start_date').
    ls_data-basic_end_date   = <line>-('basic_end_date').

    SELECT SINGLE *
      FROM i_manufacturingorder WITH PRIVILEGED ACCESS
     WHERE manufacturingorder = @ls_data-order_number
      INTO @DATA(ls_order).
*&--ADD END BY XINLEI XU 2025/02/28

    TRY.
        ls_data-order_number = |{ ls_data-order_number ALPHA = IN }|.
        ls_data-material = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_data-material ).

*&--ADD BEGIN BY XINLEI XU 2025/02/28
        ls_data-quantity = COND #( WHEN ls_data-quantity IS INITIAL
                                   THEN ls_order-mfgorderplannedtotalqty
                                   ELSE ls_data-quantity ).

        IF ls_data-quantity_uom IS NOT INITIAL.
          ls_data-quantity_uom = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_in
                                                                      iv_input = ls_data-quantity_uom ).
        ELSE.
          ls_data-quantity_uom = ls_order-productionunit.
        ENDIF.

        ls_data-basic_start_date = COND #( WHEN ls_data-basic_start_date IS INITIAL
                                           THEN ls_order-mfgorderplannedstartdate
                                           ELSE ls_data-basic_start_date ).

        ls_data-basic_end_date = COND #( WHEN ls_data-basic_end_date IS INITIAL
                                         THEN ls_order-mfgorderplannedenddate
                                         ELSE ls_data-basic_end_date ).
*&--ADD END BY XINLEI XU 2025/02/28
        ##NO_HANDLER
      CATCH zzcx_custom_exception INTO lo_root_exc.
    ENDTRY.

    MODIFY ENTITY i_productionordertp
    UPDATE FIELDS (
                    unloadingpointname
*&--ADD BEGIN BY XINLEI XU 2025/02/28
                    orderplannedtotalqty
                    productionunit
                    orderplannedstartdate
                    orderplannedenddate
*&--ADD END BY XINLEI XU 2025/02/28
                  )
    WITH VALUE #( (
                    %key-productionorder     = ls_data-order_number
                    %data-unloadingpointname = ls_data-unloading_point
*&--ADD BEGIN BY XINLEI XU 2025/02/28
                    %data-orderplannedtotalqty = ls_data-quantity
                    %data-productionunit = ls_data-quantity_uom
                    %data-orderplannedstartdate = ls_data-basic_start_date
                    %data-orderplannedenddate = ls_data-basic_end_date
*&--ADD END BY XINLEI XU 2025/02/28
                ) )
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
