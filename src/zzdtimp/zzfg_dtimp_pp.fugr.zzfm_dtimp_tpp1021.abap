FUNCTION zzfm_dtimp_tpp1021.
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
    ls_data     TYPE zzs_dtimp_tpp1021,
    lt_data     TYPE TABLE OF zzs_dtimp_tpp1021,
    lo_root_exc TYPE REF TO cx_root,
    lv_aufnr    TYPE aufnr.

  CONSTANTS:
    lc_alpha_in  TYPE string        VALUE 'IN'.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).

    CLEAR: ls_data, lv_aufnr.

    IF <line>-('order_number') IS INITIAL.
      CONTINUE.
    ENDIF.

    ls_data-order_number     = <line>-('order_number').
    ls_data-material         = <line>-('material').
    ls_data-material_name    = <line>-('material_name').
    ls_data-plant            = <line>-('plant').
    ls_data-order_type       = <line>-('order_type').
    ls_data-quantity         = <line>-('quantity').
    ls_data-quantity_uom     = <line>-('quantity_uom').
    ls_data-basic_start_date = <line>-('basic_start_date').
    ls_data-basic_end_date   = <line>-('basic_end_date').
    ls_data-prod_version     = <line>-('prod_version').
    ls_data-mrp_controller   = <line>-('mrp_controller').
    ls_data-wbs_element      = <line>-('wbs_element').
    ls_data-profit_center    = <line>-('profit_center').
    ls_data-goods_recipient  = <line>-('goods_recipient').
    ls_data-unloading_point  = <line>-('unloading_point').

    TRY.
        ls_data-order_number  = |{ ls_data-order_number ALPHA = IN }|.
        ls_data-material      = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_data-material ).
        ls_data-quantity_uom  = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_data-quantity_uom ).
        ls_data-profit_center = |{ ls_data-profit_center ALPHA = IN }|.
        "ls_data-wbs_element
        ##NO_HANDLER
      CATCH zzcx_custom_exception INTO lo_root_exc.
    ENDTRY.

    MODIFY ENTITY i_productionordertp
    CREATE FIELDS (
                    product
                    productionplant
                    productionordertype
                    orderplannedtotalqty
                    productionunit
                    orderplannedstartdate
                    orderplannedenddate
                    productionversion
                    "mrpcontroller
                    "wbselementinternalid
                    "profitcenter
                    goodsrecipientname
                    unloadingpointname
                  )
    AUTO FILL CID WITH VALUE #(
                  (
                    %data-product                = ls_data-material
                    %data-productionplant        = ls_data-plant
                    %data-productionordertype    = ls_data-order_type
                    %data-orderplannedtotalqty   = ls_data-quantity
                    %data-productionunit         = ls_data-quantity_uom
                    %data-orderplannedstartdate  = ls_data-basic_start_date
                    %data-orderplannedenddate    = ls_data-basic_end_date
                    %data-productionversion      = ls_data-prod_version
                    "%data-mrpcontroller          = ls_data-mrp_controller
                    "%data-wbselementinternalid   = ls_data-wbs_element
                    "%data-profitcenter           = ls_data-profit_center
                    %data-goodsrecipientname     = ls_data-goods_recipient
                    %data-unloadingpointname     = ls_data-unloading_point
                  )
                              )
    FAILED DATA(failed)
    REPORTED DATA(reported)
    MAPPED DATA(mapped).

    IF failed IS INITIAL.
      COMMIT ENTITIES BEGIN
        RESPONSES
          FAILED   DATA(failed_c)
          REPORTED DATA(reported_c).

      IF failed_c IS INITIAL.
        CONVERT KEY OF i_productionordertp
         FROM TEMPORARY VALUE #( %pid = mapped-productionorder[ 1 ]-%pid
                                 %tmp = mapped-productionorder[ 1 ]-%key )
         TO FINAL(ls_finalkey).
      ENDIF.
      COMMIT ENTITIES END.
      lv_aufnr = |{ ls_finalkey-productionorder ALPHA = OUT }|.
      <line>-('Message') = lv_aufnr.
      <line>-('Type')    = 'S'.
    ELSE.
      ROLLBACK ENTITIES.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      <line>-('Type') = 'E'.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
