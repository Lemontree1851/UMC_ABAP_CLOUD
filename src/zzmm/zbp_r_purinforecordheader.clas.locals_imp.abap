CLASS lhc_purinforecordheader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: BEGIN OF ts_item,
             supplier                     TYPE c LENGTH 10,
             material                     TYPE c LENGTH 40,
             purchasingorganization       TYPE c LENGTH 4,
             plant                        TYPE c LENGTH 4,
             purchasinginforecordcategory TYPE c LENGTH 1,
             conditionvaliditystartdate   TYPE budat,
             conditionvalidityenddate     TYPE budat,
             conditionscalequantity(8)    TYPE p DECIMALS 3,
             conditionscaleamount(8)      TYPE p DECIMALS 2,
           END OF ts_item.
    TYPES: tt_item TYPE STANDARD TABLE OF ts_item WITH NON-UNIQUE DEFAULT KEY.

    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_purinforecordheader.
    TYPES:  to_item TYPE tt_item.
    TYPES: row TYPE i,
           END OF lty_request,
           lty_request_t TYPE TABLE OF lty_request.


    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR purinforecordheader RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION purinforecordheader~processlogic RESULT result.

    METHODS excute CHANGING ct_data TYPE lty_request_t.

ENDCLASS.

CLASS lhc_purinforecordheader IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD processlogic.
    DATA lt_request TYPE TABLE OF lty_request.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).

      CASE lv_event.

        WHEN 'EXCUTE'.
          excute( CHANGING ct_data = lt_request ).

        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.

    ENDLOOP.
  ENDMETHOD.

  METHOD excute.
* API(Because BOI cannot create scales price):
    TYPES:
      BEGIN OF ts_scale,
        _condition_record            TYPE string,
        _condition_sequential_number TYPE string,
        _condition_scale_line        TYPE string,
        _condition_scale_quantity    TYPE string,
        conditionscalequantityunit   TYPE string,
        _condition_scale_amount      TYPE string,
        conditionscaleamountcurrency TYPE string,
        _condition_rate_value        TYPE string,
        _condition_rate_value_unit   TYPE string,
      END OF ts_scale,

      BEGIN OF ts_pricingcondition,
        _condition_record              TYPE string,
        _condition_sequential_number   TYPE string,
        _condition_type                TYPE string,
        _condition_validity_end_date   TYPE string,
        _condition_validity_start_date TYPE string,
        _condition_rate_value          TYPE string,
        _condition_rate_value_unit     TYPE string,
        _condition_currency            TYPE string,
        _condition_quantity            TYPE string,
        _condition_quantity_unit       TYPE string,
        _condition_to_base_qty_nmrtr   TYPE string,
        _condition_to_base_qty_dnmntr  TYPE string,
        _base_unit                     TYPE string,
      END OF ts_pricingcondition,
      tt_pricingcondition TYPE STANDARD TABLE OF ts_pricingcondition WITH DEFAULT KEY,


      BEGIN OF ts_validity,
        _condition_record              TYPE string,
        _condition_validity_end_date   TYPE string,
        _condition_validity_start_date TYPE string,
        _plant                         TYPE string,
        _purchasing_organization       TYPE string,
        _supplier                      TYPE string,
        _material                      TYPE string,
        _purg_doc_order_quantity_unit  TYPE string,
        _condition_type                TYPE string,
        to_pur_info_recd_prcg_cndn     TYPE ts_pricingcondition,
        _purchasing_info_record        TYPE string,
        purchasinginforecordcategory   TYPE string,
      END OF ts_validity,
      tt_validity TYPE STANDARD TABLE OF ts_validity WITH DEFAULT KEY,

      BEGIN OF ts_plantdata,
        _purchasing_info_record        TYPE string,
        purchasinginforecordcategory   TYPE string,
        _purchasing_organization       TYPE string,
        _plant                         TYPE string,
        _purchasing_group              TYPE string,
        _currency                      TYPE string,
        minimumpurchaseorderquantity   TYPE string,
        standardpurchaseorderquantity  TYPE string,
        materialplanneddeliverydurn    TYPE string,
        unlimitedoverdeliveryisallowed TYPE string,
        _purg_doc_order_quantity_unit  TYPE string,
        _net_price_amount              TYPE string,
        _material_price_unit_qty       TYPE string,
        _purchase_order_price_unit     TYPE string,
        _price_validity_end_date       TYPE string,
        _shipping_instruction          TYPE string,
        _tax_code                      TYPE string,
        _incoterms_classification      TYPE string,
        _incoterms_location1           TYPE string,
        _pricing_date_control          TYPE string,
        timedependenttaxvalidfromdate  TYPE string,
        to_purinforecdprcgcndnvalidity TYPE tt_validity,
      END OF ts_plantdata,
      tt_plantdata TYPE STANDARD TABLE OF ts_plantdata WITH DEFAULT KEY,

      BEGIN OF ts_purinforecord,
        _purchasing_info_record       TYPE string,
        _supplier                     TYPE string,
        _material                     TYPE string,
        _material_group               TYPE string,
        _purg_doc_order_quantity_unit TYPE string,
        orderitemqtytobaseqtynmrtr    TYPE string,
        orderitemqtytobaseqtydnmntr   TYPE string,
        _supplier_material_number     TYPE string,
        _base_unit                    TYPE string,
        _supplier_material_group      TYPE string,
        _supplier_subrange            TYPE string,
        _supplier_cert_origin_country TYPE string,
        to_purginforecdorgplantdata   TYPE tt_plantdata,
      END OF ts_purinforecord,

      BEGIN OF ty_d,
        purchasing_info_record TYPE string,
      END OF ty_d,

      BEGIN OF ty_message,
        lang  TYPE string,
        value TYPE string,
      END OF ty_message,

      BEGIN OF ty_error,
        code    TYPE string,
        message TYPE ty_message,
      END OF ty_error,
      BEGIN OF ty_res_api,
        d     TYPE ty_d,
        error TYPE ty_error,
      END OF ty_res_api.

    DATA:
      lt_scale            TYPE STANDARD TABLE OF ts_scale,
      ls_scale            TYPE ts_scale,
      lt_purinforecord    TYPE STANDARD TABLE OF ts_purinforecord,
      ls_purinforecord    TYPE ts_purinforecord,
      lt_plantdata        TYPE STANDARD TABLE OF ts_plantdata,
      ls_plantdata        TYPE ts_plantdata,
      lt_validity         TYPE STANDARD TABLE OF ts_validity,
      ls_validity         TYPE ts_validity,
      lt_pricingcondition TYPE STANDARD TABLE OF ts_pricingcondition,
      ls_pricingcondition TYPE ts_pricingcondition,
      lt_item             TYPE STANDARD TABLE OF ts_item,
      ls_res_api          TYPE ty_res_api.

    DATA:
      lo_root_exc TYPE REF TO cx_root,
      lv_path     TYPE string,
      i           TYPE i,
      lv_status   TYPE c LENGTH 1,
      lv_message  TYPE string,
      lv_valid    TYPE budat.

    CONSTANTS:
      lc_hour_08      TYPE n LENGTH 2 VALUE '08',
      lc_minute_00    TYPE n LENGTH 2 VALUE '00',
      lc_second_00    TYPE n LENGTH 2 VALUE '00',
      lc_second_in_ms TYPE i          VALUE '1000',
      lc_zid          TYPE zze_configid VALUE 'MM0001',
      lc_zkey1        TYPE c LENGTH 7 VALUE 'TAXCODE',
      lc_zkey3        TYPE c LENGTH 5 VALUE 'Valid'.

* Get taxcode value
    SELECT zvalue1,
           zvalue3
      FROM ztbc_1001
     WHERE zid = @lc_zid
       AND zkey1 = @lc_zkey1
       AND zkey3 = @lc_zkey3
      INTO TABLE @DATA(lt_1001).
    SORT lt_1001 BY zvalue1.

* Check taxcode valid
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      READ TABLE lt_1001 INTO DATA(ls_1001)
           WITH KEY zvalue1 = <lfs_data>-taxcode BINARY SEARCH.
      IF sy-subrc <> 0.
        <lfs_data>-status = 'E'.
        MESSAGE s014(zmm_001) WITH <lfs_data>-taxcode INTO <lfs_data>-message.
      ENDIF.
    ENDLOOP.
    IF <lfs_data>-status = 'E'.
      RETURN.
    ENDIF.

* step1 - create info record.
* If there are more conditions items with same keys, create info record by the 1st item.
* Then get the created info record to post other conditons
    READ TABLE ct_data INTO DATA(ls_data) INDEX 1.
    IF ls_data-xflag = 'X'.
      lt_item = ls_data-to_item[].
    ENDIF.
* Get reference data
    DATA(lv_material) = zzcl_common_utils=>conversion_matn1(
                                      EXPORTING iv_alpha = 'IN'
                                                iv_input = ls_data-material ).
    SELECT SINGLE productgroup,
                  baseunit
      FROM i_product
    WHERE product = @lv_material
      INTO ( @DATA(lv_matkl),
             @DATA(lv_meins) ).   "Material group, Base unit

    SELECT SINGLE purchasinggroup
      FROM i_productplantbasic
     WHERE product = @lv_material
       AND plant = @ls_data-plant
      INTO @DATA(lv_ekgrp).

    TRY.
        DATA(lv_baseunit) = zzcl_common_utils=>conversion_cunit(
                          EXPORTING iv_alpha = 'OUT'
                                    iv_input = lv_meins ).
      CATCH zzcx_custom_exception INTO lo_root_exc.
    ENDTRY.

    DATA(lv_startdate) = xco_cp_time=>moment( iv_year   = ls_data-conditionvaliditystartdate+0(4)
                                              iv_month  = ls_data-conditionvaliditystartdate+4(2)
                                              iv_day    = ls_data-conditionvaliditystartdate+6(2)
                                              iv_hour   = lc_hour_08
                                              iv_minute = lc_minute_00
                                              iv_second = lc_second_00
                                            )->get_unix_timestamp( )->value * lc_second_in_ms.
    DATA(lv_enddate) = xco_cp_time=>moment( iv_year   = ls_data-pricevalidityenddate+0(4)
                                            iv_month  = ls_data-pricevalidityenddate+4(2)
                                            iv_day    = ls_data-pricevalidityenddate+6(2)
                                            iv_hour   = lc_hour_08
                                            iv_minute = lc_minute_00
                                            iv_second = lc_second_00
                                           )->get_unix_timestamp( )->value * lc_second_in_ms.
    lv_valid = ls_1001-zvalue3.
    DATA(lv_validfrom) = xco_cp_time=>moment( iv_year   = lv_valid+0(4)
                                              iv_month  = lv_valid+4(2)
                                              iv_day    = lv_valid+6(2)
                                              iv_hour   = lc_hour_08
                                              iv_minute = lc_minute_00
                                              iv_second = lc_second_00
                                           )->get_unix_timestamp( )->value * lc_second_in_ms.

    ls_pricingcondition-_condition_validity_end_date = |/Date({ lv_enddate })/|.
    ls_pricingcondition-_condition_validity_start_date = |/Date({ lv_startdate })/|.
    ls_pricingcondition-_condition_rate_value = zzcl_common_utils=>conversion_amount(
                                                  iv_alpha = 'IN'
                                                  iv_currency = ls_data-currency
                                                  iv_input = ls_data-netpriceamount ).
    ls_pricingcondition-_condition_rate_value_unit = ls_data-currency.
    ls_pricingcondition-_condition_currency = ls_data-currency.
    ls_pricingcondition-_condition_quantity = ls_data-materialpriceunitqty.
    ls_pricingcondition-_condition_quantity_unit = ls_data-purchaseorderpriceunit.
    ls_pricingcondition-_condition_to_base_qty_nmrtr = ls_data-orderpriceunittoorderunitnmrtr.
    ls_pricingcondition-_condition_to_base_qty_dnmntr = ls_data-ordpriceunittoorderunitdnmntr.
    ls_pricingcondition-_base_unit = lv_baseunit.
    APPEND ls_pricingcondition TO lt_pricingcondition.


    ls_validity-to_pur_info_recd_prcg_cndn = ls_pricingcondition.
    APPEND ls_validity TO lt_validity.


    ls_plantdata-purchasinginforecordcategory = ls_data-purchasinginforecordcategory.
    ls_plantdata-_purchasing_organization = ls_data-purchasingorganization.
    ls_plantdata-_plant = ls_data-plant.
    ls_plantdata-_purchasing_group = lv_ekgrp.
    ls_plantdata-_currency = ls_data-currency.
    ls_plantdata-minimumpurchaseorderquantity = ls_data-minimumpurchaseorderquantity.
    ls_plantdata-standardpurchaseorderquantity = ls_data-standardpurchaseorderquantity.
    ls_plantdata-materialplanneddeliverydurn = ls_data-materialplanneddeliverydurn.
    ls_plantdata-unlimitedoverdeliveryisallowed = ls_data-unlimitedoverdeliveryisallowed.
    ls_plantdata-_purg_doc_order_quantity_unit = ls_data-purgdocorderquantityunit.
    ls_plantdata-_net_price_amount = zzcl_common_utils=>conversion_amount(
                                           iv_alpha = 'IN'
                                           iv_currency = ls_data-currency
                                           iv_input = ls_data-netpriceamount ).
    ls_plantdata-_material_price_unit_qty = ls_data-materialpriceunitqty.
    ls_plantdata-_purchase_order_price_unit = ls_data-purchaseorderpriceunit.
    ls_plantdata-_price_validity_end_date = |/Date({ lv_enddate })/|.
    ls_plantdata-_shipping_instruction = ls_data-shippinginstruction.
    ls_plantdata-_tax_code = ls_data-taxcode.
    ls_plantdata-_incoterms_classification = ls_data-incotermsclassification.
    ls_plantdata-_incoterms_location1 = ls_data-incotermslocation1.
    ls_plantdata-_pricing_date_control = ls_data-pricingdatecontrol.
    ls_plantdata-timedependenttaxvalidfromdate = lv_validfrom.
    ls_plantdata-to_purinforecdprcgcndnvalidity = lt_validity[].
    APPEND ls_plantdata TO lt_plantdata.

    ls_purinforecord-_supplier = ls_data-supplier.
    ls_purinforecord-_material = ls_data-material.
    ls_purinforecord-_material_group = lv_matkl.
    ls_purinforecord-_purg_doc_order_quantity_unit = ls_data-purgdocorderquantityunit.
    ls_purinforecord-orderitemqtytobaseqtynmrtr = ls_data-orderitemqtytobaseqtynmrtr.
    ls_purinforecord-orderitemqtytobaseqtydnmntr = ls_data-orderitemqtytobaseqtydnmntr.
    ls_purinforecord-_supplier_material_number = ls_data-suppliermaterialnumber.
    ls_purinforecord-_base_unit = lv_baseunit.
    ls_purinforecord-_supplier_material_group = ls_data-suppliermaterialgroup.
    ls_purinforecord-_supplier_subrange = ls_data-suppliersubrange.
    ls_purinforecord-_supplier_cert_origin_country = ls_data-suppliercertorigincountry.
    ls_purinforecord-to_purginforecdorgplantdata = lt_plantdata[].


* Call API
    lv_path = '/API_INFORECORD_PROCESS_SRV/A_PurchasingInfoRecord'.
    DATA(lv_reqbody_api) = /ui2/cl_json=>serialize( data = ls_purinforecord
                                                    compress = 'X'
                                                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
    REPLACE ALL OCCURRENCES OF 'conditionvalidityenddate'  IN lv_reqbody_api WITH 'ConditionValidityEndDate'.
    REPLACE ALL OCCURRENCES OF 'conditionvaliditystartdate' IN lv_reqbody_api WITH 'ConditionValidityStartDate'.
    REPLACE ALL OCCURRENCES OF 'toPurInfoRecdPrcgCndn' IN lv_reqbody_api WITH 'to_PurInfoRecdPrcgCndn'.
    REPLACE ALL OCCURRENCES OF 'conditionscaleamountcurrency' IN lv_reqbody_api WITH 'ConditionScaleAmountCurrency'.
    REPLACE ALL OCCURRENCES OF 'purchasinginforecordcategory' IN lv_reqbody_api WITH 'PurchasingInfoRecordCategory'.
    REPLACE ALL OCCURRENCES OF 'minimumpurchaseorderquantity' IN lv_reqbody_api WITH 'MinimumPurchaseOrderQuantity'.
    REPLACE ALL OCCURRENCES OF 'standardpurchaseorderquantity' IN lv_reqbody_api WITH 'StandardPurchaseOrderQuantity'.
    REPLACE ALL OCCURRENCES OF 'materialplanneddeliverydurn' IN lv_reqbody_api WITH 'MaterialPlannedDeliveryDurn'.
    REPLACE ALL OCCURRENCES OF 'unlimitedoverdeliveryisallowed' IN lv_reqbody_api WITH 'UnlimitedOverdeliveryIsAllowed'.
    REPLACE ALL OCCURRENCES OF 'timedependenttaxvalidfromdate' IN lv_reqbody_api  WITH 'TimeDependentTaxValidFromDate'.
    REPLACE ALL OCCURRENCES OF 'toPurinforecdprcgcndnvalidity' IN lv_reqbody_api WITH 'to_PurInfoRecdPrcgCndnValidity'.
    REPLACE ALL OCCURRENCES OF 'orderitemqtytobaseqtynmrtr' IN lv_reqbody_api WITH 'OrderItemQtyToBaseQtyNmrtr'.
    REPLACE ALL OCCURRENCES OF 'orderitemqtytobaseqtydnmntr' IN lv_reqbody_api WITH 'OrderItemQtyToBaseQtyDnmntr'.
    REPLACE ALL OCCURRENCES OF 'toPurginforecdorgplantdata' IN lv_reqbody_api WITH 'to_PurgInfoRecdOrgPlantData'.
    zzcl_common_utils=>request_api_v2(
          EXPORTING
            iv_path        = lv_path
            iv_method      = if_web_http_client=>post
            iv_body        = lv_reqbody_api
          IMPORTING
            ev_status_code = DATA(lv_stat_code)
            ev_response    = DATA(lv_resbody_api) ).

    xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
            ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_res_api ) ).

    IF lv_stat_code = '201'.
      lv_status = 'S'.
      DATA(lv_inforecord) = ls_res_api-d-purchasing_info_record.
      IF lt_item IS NOT INITIAL.
* Call scale api
        SELECT SINGLE conditionrecord,
                      conditionsequentialnumber
          FROM i_purginforecdcndnrecordtp
         WHERE purchasinginforecord = @ls_res_api-d-purchasing_info_record
           AND purchasinginforecordcategory = @ls_data-purchasinginforecordcategory
           AND purchasingorganization = @ls_data-purchasingorganization
           AND plant = @ls_data-plant
           AND conditionvalidityenddate = @ls_data-pricevalidityenddate
          INTO ( @DATA(lv_conditionrecord),
                 @DATA(lv_seq) ).

        LOOP AT lt_item INTO DATA(ls_item).
          i += 1.
          ls_scale-_condition_record = lv_conditionrecord.
          ls_scale-_condition_sequential_number = lv_seq.
          ls_scale-_condition_scale_line = i.
          ls_scale-_condition_scale_quantity = ls_item-conditionscalequantity.
          ls_scale-conditionscalequantityunit = ls_data-purchaseorderpriceunit.
          ls_scale-_condition_scale_amount = zzcl_common_utils=>conversion_amount(
                                               iv_alpha = 'IN'
                                               iv_currency = ls_data-currency
                                               iv_input = ls_item-conditionscaleamount ).
          ls_scale-conditionscaleamountcurrency = ls_data-currency.
          ls_scale-_condition_rate_value = zzcl_common_utils=>conversion_amount(
                                               iv_alpha = 'IN'
                                               iv_currency = ls_data-currency
                                               iv_input = ls_item-conditionscaleamount ).
          ls_scale-_condition_rate_value_unit = ls_data-currency.
          APPEND ls_scale TO lt_scale.
          CLEAR: ls_scale.
        ENDLOOP.

        lv_path = '/API_INFORECORD_PROCESS_SRV/A_PurInfoRecdPrcgCndnScale'.
        lv_reqbody_api = /ui2/cl_json=>serialize( data = lt_scale
                                                      compress = 'X'
                                                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
        REPLACE ALL OCCURRENCES OF 'conditionscalequantityunit' IN lv_reqbody_api WITH 'ConditionScaleQuantityUnit'.
        REPLACE ALL OCCURRENCES OF 'conditionscaleamountcurrency' IN lv_reqbody_api WITH 'ConditionScaleAmountCurrency'.

        zzcl_common_utils=>request_api_v2(
            EXPORTING
              iv_path        = lv_path
              iv_method      = if_web_http_client=>post
              iv_body        = lv_reqbody_api
            IMPORTING
              ev_status_code = lv_stat_code
              ev_response    = lv_resbody_api ).

        xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
                ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_res_api ) ).
        IF lv_stat_code = '201'.
          lv_status = 'S'.
        ELSE.
          lv_status = 'E'.
          lv_message = ls_res_api-error-message-value.
        ENDIF.

        LOOP AT ct_data ASSIGNING <lfs_data>.
          <lfs_data>-status = lv_status.
          <lfs_data>-message = lv_message.
          <lfs_data>-purchasinginforecord = lv_inforecord.
        ENDLOOP.
      ENDIF.
    ELSE.

      LOOP AT ct_data ASSIGNING <lfs_data>.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = ls_res_api-error-message-value.
        EXIT.
      ENDLOOP.
    ENDIF.

* Post conditions from line 2
    CLEAR: i, ls_scale, lt_scale,
           lt_validity, ls_validity,
           lt_pricingcondition, ls_pricingcondition.
    LOOP AT ct_data ASSIGNING <lfs_data> FROM 2.
      lv_startdate = xco_cp_time=>moment( iv_year   = <lfs_data>-conditionvaliditystartdate+0(4)
                                          iv_month  = <lfs_data>-conditionvaliditystartdate+4(2)
                                          iv_day    = <lfs_data>-conditionvaliditystartdate+6(2)
                                          iv_hour   = lc_hour_08
                                          iv_minute = lc_minute_00
                                          iv_second = lc_second_00
                                        )->get_unix_timestamp( )->value * lc_second_in_ms.
      lv_enddate = xco_cp_time=>moment( iv_year   = <lfs_data>-pricevalidityenddate+0(4)
                                        iv_month  = <lfs_data>-pricevalidityenddate+4(2)
                                        iv_day    = <lfs_data>-pricevalidityenddate+6(2)
                                        iv_hour   = lc_hour_08
                                        iv_minute = lc_minute_00
                                        iv_second = lc_second_00
                                      )->get_unix_timestamp( )->value * lc_second_in_ms.

      ls_pricingcondition-_condition_validity_end_date = |/Date({ lv_enddate })/|.
      ls_pricingcondition-_condition_validity_start_date = |/Date({ lv_startdate })/|.
      ls_pricingcondition-_condition_rate_value = zzcl_common_utils=>conversion_amount(
                                                    iv_alpha = 'IN'
                                                    iv_currency = <lfs_data>-currency
                                                    iv_input = <lfs_data>-netpriceamount ).
      ls_pricingcondition-_condition_rate_value_unit = <lfs_data>-currency.
      ls_pricingcondition-_condition_currency = <lfs_data>-currency.
      ls_pricingcondition-_condition_quantity = <lfs_data>-materialpriceunitqty.
      ls_pricingcondition-_condition_quantity_unit = <lfs_data>-purchaseorderpriceunit.
      ls_pricingcondition-_condition_to_base_qty_nmrtr = <lfs_data>-orderpriceunittoorderunitnmrtr.
      ls_pricingcondition-_condition_to_base_qty_dnmntr = <lfs_data>-ordpriceunittoorderunitdnmntr.
      ls_pricingcondition-_base_unit = lv_baseunit.


      ls_validity-_condition_record = lv_conditionrecord.
      ls_validity-_condition_validity_end_date = |/Date({ lv_enddate })/|.
      ls_validity-_condition_validity_start_date = |/Date({ lv_startdate })/|.
      ls_validity-_condition_type = 'PPR0'.
      ls_validity-_plant = <lfs_data>-plant.
      ls_validity-_purchasing_organization = <lfs_data>-purchasingorganization.
      ls_validity-_supplier = <lfs_data>-supplier.
      ls_validity-_material = <lfs_data>-material.
      ls_validity-_purg_doc_order_quantity_unit = <lfs_data>-purgdocorderquantityunit.
      ls_validity-to_pur_info_recd_prcg_cndn = ls_pricingcondition.
      ls_validity-_purchasing_info_record = lv_inforecord.
      ls_validity-purchasinginforecordcategory = <lfs_data>-purchasinginforecordcategory.
      APPEND ls_validity TO lt_validity.

      IF ls_data-xflag = 'X'.
        lt_item = ls_data-to_item.
        LOOP AT lt_item INTO ls_item.

        ENDLOOP.
      ENDIF.
* Call API
      lv_path = '/API_INFORECORD_PROCESS_SRV/A_PurInfoRecdPrcgCndn'
              && '(' && '''' && lv_conditionrecord && '''' && ')'
              && '/to_PurInfoRecdPrcgCndnValidity'.
      lv_reqbody_api = /ui2/cl_json=>serialize( data = ls_validity
                                                compress = 'X'
                                                pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
      REPLACE ALL OCCURRENCES OF 'toPurInfoRecdPrcgCndn' IN lv_reqbody_api WITH 'to_PurInfoRecdPrcgCndn'.
      REPLACE ALL OCCURRENCES OF 'purchasinginforecordcategory' IN lv_reqbody_api WITH 'PurchasingInfoRecordCategory'.
      zzcl_common_utils=>request_api_v2(
          EXPORTING
            iv_path        = lv_path
            iv_method      = if_web_http_client=>post
            iv_body        = lv_reqbody_api
          IMPORTING
            ev_status_code = lv_stat_code
            ev_response    = lv_resbody_api ).

      xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
            ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_res_api ) ).
      IF lv_stat_code = '201'.
        lv_status = 'S'.

        IF lt_item IS NOT INITIAL.
* Call scale api


          LOOP AT lt_item INTO ls_item.
            i += 1.
            ls_scale-_condition_record = lv_conditionrecord.
            ls_scale-_condition_sequential_number = lv_seq.
            ls_scale-_condition_scale_line = i.
            ls_scale-_condition_scale_quantity = ls_item-conditionscalequantity.
            ls_scale-conditionscalequantityunit = ls_data-purchaseorderpriceunit.
            ls_scale-_condition_scale_amount = zzcl_common_utils=>conversion_amount(
                                                 iv_alpha = 'IN'
                                                 iv_currency = ls_data-currency
                                                 iv_input = ls_item-conditionscaleamount ).
            ls_scale-conditionscaleamountcurrency = ls_data-currency.
            ls_scale-_condition_rate_value = zzcl_common_utils=>conversion_amount(
                                                 iv_alpha = 'IN'
                                                 iv_currency = ls_data-currency
                                                 iv_input = ls_item-conditionscaleamount ).
            ls_scale-_condition_rate_value_unit = ls_data-currency.
            APPEND ls_scale TO lt_scale.
            CLEAR: ls_scale.
          ENDLOOP.

          lv_path = '/API_INFORECORD_PROCESS_SRV/A_PurInfoRecdPrcgCndnScale'.
          lv_reqbody_api = /ui2/cl_json=>serialize( data = lt_scale
                                                        compress = 'X'
                                                        pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
          REPLACE ALL OCCURRENCES OF 'conditionscalequantityunit' IN lv_reqbody_api WITH 'ConditionScaleQuantityUnit'.
          REPLACE ALL OCCURRENCES OF 'conditionscaleamountcurrency' IN lv_reqbody_api WITH 'ConditionScaleAmountCurrency'.

          zzcl_common_utils=>request_api_v2(
              EXPORTING
                iv_path        = lv_path
                iv_method      = if_web_http_client=>post
                iv_body        = lv_reqbody_api
              IMPORTING
                ev_status_code = lv_stat_code
                ev_response    = lv_resbody_api ).

          xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
                  ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_res_api ) ).
          IF lv_stat_code = '201'.
            lv_status = 'S'.
          ELSE.
            lv_status = 'E'.
            lv_message = ls_res_api-error-message-value.
          ENDIF.
        ENDIF.
      ELSE.
        lv_status = 'E'.
        lv_message = ls_res_api-error-message-value.
      ENDIF.

      <lfs_data>-status = lv_status.
      <lfs_data>-message = lv_message.

      CLEAR: lt_validity, ls_validity.
    ENDLOOP.



  ENDMETHOD.
ENDCLASS.
