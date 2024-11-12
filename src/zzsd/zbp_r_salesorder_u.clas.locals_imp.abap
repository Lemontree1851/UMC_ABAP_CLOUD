CLASS lhc_salesorderfordn DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR salesorderfordn RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE salesorderfordn.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE salesorderfordn.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE salesorderfordn.

    METHODS read FOR READ
      IMPORTING keys FOR READ salesorderfordn RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK salesorderfordn.

    METHODS createdeliveryorder FOR MODIFY
      IMPORTING keys FOR ACTION salesorderfordn~createdeliveryorder RESULT result.


ENDCLASS.

CLASS lhc_salesorderfordn IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD createdeliveryorder.
    READ ENTITIES OF zr_salesorder_u IN LOCAL MODE
        ENTITY salesorderfordn
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_read)
        FAILED failed.
    LOOP AT keys INTO DATA(ls_keys).
*        ls_keys-%param-DeliveryType "获取参数
    ENDLOOP.
    LOOP AT lt_read INTO DATA(ls_read).

    ENDLOOP.
    DATA: lt_order_header        TYPE TABLE FOR CREATE i_salesordertp,
          lt_order_item          TYPE TABLE FOR CREATE i_salesordertp\_item,
          lt_order_item_schedule TYPE TABLE FOR CREATE i_salesorderitemtp\_scheduleline.

    MODIFY ENTITIES OF i_outbounddeliverytp
        ENTITY outbounddelivery
        EXECUTE createdlvfromsalesdocument
            FROM VALUE #(
            ( %cid = 'DLV001'
            %param = VALUE #(
            %control = VALUE #(
            shippingpoint = if_abap_behv=>mk-on
            deliveryselectiondate = if_abap_behv=>mk-on
            deliverydocumenttype = if_abap_behv=>mk-on )
            shippingpoint = '1010'
            deliveryselectiondate = '20230201'
            deliverydocumenttype = 'LF'
            _referencesddocumentitem = VALUE #(
            ( %control = VALUE #(
            referencesddocument = if_abap_behv=>mk-on
            referencesddocumentitem = if_abap_behv=>mk-on )
            referencesddocument = '0000004711'
            referencesddocumentitem = '000010' ) ) ) ) )
    MAPPED DATA(ls_mapped)
    REPORTED DATA(ls_reported_modify)
    FAILED DATA(ls_failed_modify).

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_salesorderfordn_u DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_salesorderfordn_u IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
