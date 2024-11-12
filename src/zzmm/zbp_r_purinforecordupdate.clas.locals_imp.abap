CLASS lhc_purinforecordupdate DEFINITION INHERITING FROM cl_abap_behavior_handler.
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

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR purinforecordupdate RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION purinforecordupdate~processlogic RESULT result.

    METHODS excute CHANGING ct_data TYPE lty_request_t.

ENDCLASS.

CLASS lhc_purinforecordupdate IMPLEMENTATION.

  METHOD get_instance_authorizations.
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
    TYPES:
      BEGIN OF ts_purinforecord,
        _purchasing_info_record       TYPE string,
        _supplier                     TYPE string,
        _material                     TYPE string,
        _purg_doc_order_quantity_unit TYPE string,
        orderitemqtytobaseqtynmrtr    TYPE string,
        orderitemqtytobaseqtydnmntr   TYPE string,
        _supplier_material_number     TYPE string,
        _supplier_material_group      TYPE string,
        _supplier_subrange            TYPE string,
        _supplier_cert_origin_country TYPE string,
      END OF ts_purinforecord,

      BEGIN OF ts_plantdata,
        _purchasing_info_record        TYPE string,
        purchasinginforecordcategory   TYPE string,
        _purchasing_organization       TYPE string,
        _plant                         TYPE string,
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
      END OF ts_plantdata,

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
        _condition_type                TYPE string,
        _plant                         TYPE string,
        _purchasing_organization       TYPE string,
        _supplier                      TYPE string,
        _material                      TYPE string,
        _purg_doc_order_quantity_unit  TYPE string,
        to_pur_info_recd_prcg_cndn     TYPE ts_pricingcondition,
        _purchasing_info_record        TYPE string,
        purchasinginforecordcategory   TYPE string,
      END OF ts_validity,

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

      BEGIN OF ty_message,
        lang  TYPE string,
        value TYPE string,
      END OF ty_message,

      BEGIN OF ty_error,
        code    TYPE string,
        message TYPE ty_message,
      END OF ty_error,

      BEGIN OF ty_res_api,
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
      lc_null              TYPE c LENGTH 1 VALUE '^',
      lo_root_exc          TYPE REF TO cx_root,
      lv_path              TYPE string,
      i                    TYPE i,
      lv_status            TYPE c LENGTH 1,
      lv_message           TYPE string,
      lv_valid             TYPE budat,
      lv_purinforecordx    TYPE c LENGTH 1,
      lv_plantdatax        TYPE c LENGTH 1,
      lv_pricingconditionx TYPE c LENGTH 1.

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

    READ TABLE ct_data INTO DATA(ls_data) INDEX 1.
    lv_valid = ls_1001-zvalue3.
    DATA(lv_validfrom) = xco_cp_time=>moment( iv_year   = lv_valid+0(4)
                                              iv_month  = lv_valid+4(2)
                                              iv_day    = lv_valid+6(2)
                                              iv_hour   = lc_hour_08
                                              iv_minute = lc_minute_00
                                              iv_second = lc_second_00
                                           )->get_unix_timestamp( )->value * lc_second_in_ms.
    IF ls_data-pricevalidityenddate IS NOT INITIAL.
      DATA(lv_enddate) = xco_cp_time=>moment( iv_year   = ls_data-pricevalidityenddate+0(4)
                                              iv_month  = ls_data-pricevalidityenddate+4(2)
                                              iv_day    = ls_data-pricevalidityenddate+6(2)
                                              iv_hour   = lc_hour_08
                                              iv_minute = lc_minute_00
                                              iv_second = lc_second_00
                                          )->get_unix_timestamp( )->value * lc_second_in_ms.

    ENDIF.

    IF ls_data-conditionvaliditystartdate IS NOT INITIAL.
      DATA(lv_startdate) = xco_cp_time=>moment( iv_year   = ls_data-conditionvaliditystartdate+0(4)
                                                iv_month  = ls_data-conditionvaliditystartdate+4(2)
                                                iv_day    = ls_data-conditionvaliditystartdate+6(2)
                                                iv_hour   = lc_hour_08
                                                iv_minute = lc_minute_00
                                                iv_second = lc_second_00
                                            )->get_unix_timestamp( )->value * lc_second_in_ms.

    ENDIF.

    DATA(lv_inforecord) = |{ ls_data-purchasinginforecord ALPHA = IN }|.
* Check if condition_record exist
    SELECT SINGLE conditionrecord
      FROM i_purginforecdprcgcndnvaldtytp
     WHERE purchasinginforecord = @lv_inforecord
       AND purchasinginforecordcategory = @ls_data-purchasinginforecordcategory
       AND purchasingorganization = @ls_data-purchasingorganization
       AND plant = @ls_data-plant
       AND conditionvalidityenddate = @ls_data-pricevalidityenddate
      INTO @DATA(lv_conditionrecord).
    IF sy-subrc = 0.
      lv_conditionrecord = |{ lv_conditionrecord ALPHA = IN }|.
    ENDIF.

* Purchasing Info Record - General Data
    IF ls_data-purgdocorderquantityunit IS NOT INITIAL.
      ls_purinforecord-_purg_doc_order_quantity_unit = ls_data-purgdocorderquantityunit.
    ENDIF.
    IF ls_data-orderitemqtytobaseqtynmrtr IS NOT INITIAL.
      ls_purinforecord-orderitemqtytobaseqtynmrtr = ls_data-orderitemqtytobaseqtynmrtr.
    ENDIF.
    IF ls_data-orderitemqtytobaseqtydnmntr IS NOT INITIAL.
      ls_purinforecord-orderitemqtytobaseqtydnmntr = ls_data-orderitemqtytobaseqtydnmntr.
    ENDIF.
    IF ls_data-suppliermaterialnumber IS NOT INITIAL.
      ls_purinforecord-_supplier_material_number = |{ ls_data-suppliermaterialnumber ALPHA = IN }|.
    ELSEIF ls_data-suppliermaterialnumber = lc_null.
      ls_purinforecord-_supplier_material_number = ' '.
      lv_purinforecordx = 'X'.
    ENDIF.
    IF ls_data-suppliermaterialgroup IS NOT INITIAL.
      ls_purinforecord-_supplier_material_group = ls_data-suppliermaterialgroup.
    ELSEIF ls_data-suppliermaterialgroup = lc_null.
      ls_purinforecord-_supplier_material_group = ' '.
      lv_purinforecordx = 'X'.
    ENDIF.
    IF ls_data-suppliersubrange IS NOT INITIAL.
      ls_purinforecord-_supplier_subrange = ls_data-suppliersubrange.
    ELSEIF ls_data-suppliersubrange = lc_null.
      ls_purinforecord-_supplier_subrange = ' '.
      lv_purinforecordx = 'X'.
    ENDIF.
    IF ls_data-suppliercertorigincountry IS NOT INITIAL.
      ls_purinforecord-_supplier_cert_origin_country = ls_data-suppliercertorigincountry.
    ELSEIF ls_data-suppliercertorigincountry = lc_null.
      ls_purinforecord-_supplier_cert_origin_country = ' '.
      lv_purinforecordx = 'X'.
    ENDIF.

* Purch. Organization Data 1
    IF ls_data-minimumpurchaseorderquantity IS NOT INITIAL.
      ls_plantdata-minimumpurchaseorderquantity = ls_data-minimumpurchaseorderquantity.
    ELSEIF ls_data-minimumpurchaseorderquantity = lc_null.
      ls_data-minimumpurchaseorderquantity = 0.
    ENDIF.

    IF ls_data-standardpurchaseorderquantity IS NOT INITIAL.
      ls_plantdata-standardpurchaseorderquantity = ls_data-standardpurchaseorderquantity.
    ELSEIF ls_data-standardpurchaseorderquantity = lc_null.
      ls_plantdata-standardpurchaseorderquantity = 0.
      lv_plantdatax = 'X'.
    ENDIF.

    IF ls_data-materialplanneddeliverydurn IS NOT INITIAL.
      ls_plantdata-materialplanneddeliverydurn = ls_data-materialplanneddeliverydurn.
    ELSEIF ls_data-materialplanneddeliverydurn = lc_null.
      ls_plantdata-materialplanneddeliverydurn = 0.
      lv_plantdatax = 'X'.
    ENDIF.
    IF ls_data-unlimitedoverdeliveryisallowed IS NOT INITIAL.
      ls_plantdata-unlimitedoverdeliveryisallowed = ls_data-unlimitedoverdeliveryisallowed.
    ELSEIF ls_data-unlimitedoverdeliveryisallowed = lc_null.
      ls_plantdata-unlimitedoverdeliveryisallowed = ' '.
      lv_plantdatax = 'X'.
    ENDIF.
    IF ls_data-shippinginstruction IS NOT INITIAL.
      ls_plantdata-_shipping_instruction = ls_data-shippinginstruction.
    ELSEIF ls_data-shippinginstruction = lc_null.
      ls_plantdata-_shipping_instruction = ' '.
      lv_plantdatax = 'X'.
    ENDIF.
    IF ls_data-taxcode IS NOT INITIAL.
      ls_plantdata-_tax_code = ls_data-taxcode.
    ELSEIF ls_data-taxcode = lc_null.
      ls_plantdata-_tax_code = ' '.
      lv_plantdatax = 'X'.
    ENDIF.
    IF ls_data-incotermsclassification IS NOT INITIAL.
      ls_plantdata-_incoterms_classification = ls_data-incotermsclassification.
    ELSEIF ls_data-incotermsclassification = lc_null.
      ls_plantdata-_incoterms_classification = ' '.
      lv_plantdatax = 'X'.
    ENDIF.
    IF ls_data-incotermslocation1 IS NOT INITIAL.
      ls_plantdata-_incoterms_location1 = ls_data-incotermslocation1.
    ELSEIF ls_data-incotermslocation1 = lc_null.
      ls_plantdata-_incoterms_location1 = ' '.
      lv_plantdatax = 'X'.
    ENDIF.
    IF ls_data-pricingdatecontrol IS NOT INITIAL.
      ls_plantdata-_pricing_date_control = ls_data-pricingdatecontrol.
    ELSEIF ls_data-pricingdatecontrol = lc_null.
      ls_plantdata-_pricing_date_control = ' '.
      lv_plantdatax = 'X'.
    ENDIF.
    IF ls_data-taxcode = lc_null.
      ls_plantdata-timedependenttaxvalidfromdate = ' '.
      lv_plantdatax = 'X'.
    ELSE.
      ls_plantdata-timedependenttaxvalidfromdate = lv_validfrom.
    ENDIF.

* Condition

    IF lv_enddate IS NOT INITIAL.
      ls_pricingcondition-_condition_validity_end_date = |/Date({ lv_enddate })/|.
    ENDIF.
    IF lv_startdate IS NOT INITIAL.
      ls_pricingcondition-_condition_validity_start_date = |/Date({ lv_startdate })/|.
    ENDIF.
    IF ls_data-netpriceamount IS NOT INITIAL.
      ls_pricingcondition-_condition_rate_value = ls_data-netpriceamount.
    ELSEIF ls_data-netpriceamount = lc_null.
      ls_pricingcondition-_condition_rate_value = 0.
    ENDIF.
    IF ls_data-currency IS NOT INITIAL.
      ls_pricingcondition-_condition_rate_value_unit = ls_data-currency.
      ls_pricingcondition-_condition_currency = ls_data-currency.
    ENDIF.
    IF ls_data-materialpriceunitqty IS NOT INITIAL.
      ls_pricingcondition-_condition_quantity = ls_data-materialpriceunitqty.
    ELSEIF ls_data-materialpriceunitqty = lc_null.
      ls_pricingcondition-_condition_quantity = 0.
    ENDIF.

    IF ls_data-purchaseorderpriceunit IS NOT INITIAL.
      ls_pricingcondition-_condition_quantity_unit = ls_data-purchaseorderpriceunit.
    ELSEIF ls_data-purchaseorderpriceunit = lc_null.
      ls_pricingcondition-_condition_quantity_unit = ' '.
      lv_pricingconditionx = 'X'.
    ENDIF.

    IF ls_data-orderpriceunittoorderunitnmrtr IS NOT INITIAL.
      ls_pricingcondition-_condition_to_base_qty_nmrtr = ls_data-orderpriceunittoorderunitnmrtr.
    ELSEIF ls_data-orderpriceunittoorderunitnmrtr = lc_null.
      ls_pricingcondition-_condition_to_base_qty_nmrtr = 0.
    ENDIF.

    IF ls_data-ordpriceunittoorderunitdnmntr IS NOT INITIAL.
      ls_pricingcondition-_condition_to_base_qty_dnmntr = ls_data-ordpriceunittoorderunitdnmntr.
    ELSEIF ls_data-ordpriceunittoorderunitdnmntr = lc_null.
      ls_pricingcondition-_condition_to_base_qty_dnmntr = 0.
    ENDIF.

* Validity
    IF lv_enddate IS NOT INITIAL.
      ls_validity-_condition_validity_end_date = |/Date({ lv_enddate })/|.
    ENDIF.
    IF lv_startdate IS NOT INITIAL.
      ls_validity-_condition_validity_start_date = |/Date({ lv_startdate })/|.
    ENDIF.
    ls_validity-_purg_doc_order_quantity_unit = ls_data-purgdocorderquantityunit.
    ls_validity-_purchasing_organization = ls_data-purchasingorganization.
    ls_validity-purchasinginforecordcategory = ls_data-purchasinginforecordcategory.
    ls_validity-_purchasing_info_record  = lv_inforecord.
    ls_validity-_supplier = |{ ls_data-supplier ALPHA = IN }|.
    ls_validity-_material = zzcl_common_utils=>conversion_matn1(
                                EXPORTING iv_alpha = 'IN'
                                          iv_input = ls_validity-_material ).
    ls_validity-to_pur_info_recd_prcg_cndn = ls_pricingcondition.
    APPEND ls_validity TO lt_validity.

* Scales
    lt_item = ls_data-to_item[].


* Call API1-General data
    IF ls_purinforecord IS NOT INITIAL
    OR lv_purinforecordx = 'X'.
      ls_purinforecord-_purchasing_info_record = lv_inforecord.
      lv_path = '/API_INFORECORD_PROCESS_SRV/A_PurchasingInfoRecord'
                && '(' && '''' && lv_inforecord && '''' && ')'.
      DATA(lv_reqbody_api) = /ui2/cl_json=>serialize( data = ls_purinforecord
                                                      compress = 'X'
                                                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
      REPLACE ALL OCCURRENCES OF 'orderitemqtytobaseqtynmrtr' IN lv_reqbody_api WITH 'OrderItemQtyToBaseQtyNmrtr'.
      REPLACE ALL OCCURRENCES OF 'orderitemqtytobaseqtydnmntr' IN lv_reqbody_api WITH 'OrderItemQtyToBaseQtyDnmntr'.
      zzcl_common_utils=>request_api_v2(
          EXPORTING
            iv_path        = lv_path
            iv_method      = if_web_http_client=>patch
            iv_body        = lv_reqbody_api
          IMPORTING
            ev_status_code = DATA(lv_stat_code)
            ev_response    = DATA(lv_resbody_api) ).

      xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
            ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_res_api ) ).

      IF lv_stat_code = '204'.
        lv_status = 'S'.
      ELSE.
        lv_status = 'E'.
        lv_message = ls_res_api-error-message-value.
      ENDIF.
    ENDIF.

* Call API2-Pur. Org.
    IF ls_plantdata IS NOT INITIAL
    OR lv_plantdatax = 'X'.
      ls_plantdata-_purchasing_info_record = lv_inforecord.
      lv_path = '/API_INFORECORD_PROCESS_SRV/A_PurgInfoRecdOrgPlantData('
              && 'PurchasingInfoRecord=' && '''' && lv_inforecord && '''' && ','
              && 'PurchasingInfoRecordCategory=' && '''' && ls_data-purchasinginforecordcategory && '''' && ','
              && 'PurchasingOrganization=' && '''' && ls_data-purchasingorganization && '''' && ','
              && 'Plant=' && '''' && ls_data-plant && '''' && ')'.
      lv_reqbody_api = /ui2/cl_json=>serialize( data = ls_plantdata
                                                compress = 'X'
                                                pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
      REPLACE ALL OCCURRENCES OF 'purchasinginforecordcategory' IN lv_reqbody_api WITH 'PurchasingInfoRecordCategory'.
      REPLACE ALL OCCURRENCES OF 'minimumpurchaseorderquantity' IN lv_reqbody_api WITH 'MinimumPurchaseOrderQuantity'.
      REPLACE ALL OCCURRENCES OF 'standardpurchaseorderquantity' IN lv_reqbody_api WITH 'StandardPurchaseOrderQuantity'.
      REPLACE ALL OCCURRENCES OF 'materialplanneddeliverydurn' IN lv_reqbody_api WITH 'MaterialPlannedDeliveryDurn'.
      REPLACE ALL OCCURRENCES OF 'unlimitedoverdeliveryisallowed' IN lv_reqbody_api WITH 'UnlimitedOverdeliveryIsAllowed'.
      REPLACE ALL OCCURRENCES OF 'timedependenttaxvalidfromdate' IN lv_reqbody_api  WITH 'TimeDependentTaxValidFromDate'.
      zzcl_common_utils=>request_api_v2(
          EXPORTING
            iv_path        = lv_path
            iv_method      = if_web_http_client=>patch
            iv_body        = lv_reqbody_api
          IMPORTING
            ev_status_code = lv_stat_code
            ev_response    = lv_resbody_api ).

      xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
            ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_res_api ) ).

      IF lv_stat_code = '204'.
        lv_status = 'S'.
      ELSE.
        lv_status = 'E'.
        lv_message = zzcl_common_utils=>merge_message(
                             iv_message1 = lv_message
                             iv_message2 = ls_res_api-error-message-value
                             iv_symbol = '\' ).

      ENDIF.
    ENDIF.

* Call API3-conditions
    IF lv_conditionrecord IS NOT INITIAL.
      DATA(lv_method) = 'PATCH'.
    ELSE.
      lv_method = 'POST'.
    ENDIF.
    IF lv_method = 'PATCH'.
      ls_pricingcondition-_condition_record = lv_conditionrecord.
      lv_path = '/API_INFORECORD_PROCESS_SRV/A_PurInfoRecdPrcgCndn('
                    && '''' && lv_conditionrecord && '''' && ')'.
      lv_reqbody_api = /ui2/cl_json=>serialize( data = ls_pricingcondition
                                                compress = 'X'
                                                pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

      zzcl_common_utils=>request_api_v2(
          EXPORTING
            iv_path        = lv_path
            iv_method      = if_web_http_client=>patch
            iv_body        = lv_reqbody_api
          IMPORTING
            ev_status_code = lv_stat_code
            ev_response    = lv_resbody_api ).
    ELSE.
* add new validity
      lv_path = '/API_INFORECORD_PROCESS_SRV/A_PurgInfoRecdOrgPlantData('
              && 'PurchasingInfoRecord=' && '''' && lv_inforecord && '''' && ','
              && 'PurchasingInfoRecordCategory=' && '''' && ls_data-purchasinginforecordcategory && '''' && ','
              && 'PurchasingOrganization=' && '''' && ls_data-purchasingorganization && '''' && ','
              && 'Plant=' && '''' && ls_data-plant && '''' && ')'
              && '/to_PurInfoRecdPrcgCndnValidity'.
      lv_reqbody_api = /ui2/cl_json=>serialize( data = ls_validity
                                                compress = 'X'
                                                pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
      REPLACE ALL OCCURRENCES OF 'purchasinginforecordcategory' IN lv_reqbody_api WITH 'PurchasingInfoRecordCategory'.
      zzcl_common_utils=>request_api_v2(
         EXPORTING
           iv_path        = lv_path
           iv_method      = if_web_http_client=>post
           iv_body        = lv_reqbody_api
         IMPORTING
           ev_status_code = lv_stat_code
           ev_response    = lv_resbody_api ).
    ENDIF.
    xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_res_api ) ).

    IF lv_stat_code = '204'.
      lv_status = 'S'.
* Call API4- Scales
      SELECT SINGLE conditionrecord,
                    conditionsequentialnumber
          FROM i_purginforecdcndnrecordtp
         WHERE purchasinginforecord = @lv_inforecord
           AND purchasinginforecordcategory = @ls_data-purchasinginforecordcategory
           AND purchasingorganization = @ls_data-purchasingorganization
           AND plant = @ls_data-plant
           AND conditionvalidityenddate = @ls_data-pricevalidityenddate
          INTO ( @DATA(lv_newconditionrecord),
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
    ELSE.
      lv_status = 'E'.
      lv_message = zzcl_common_utils=>merge_message(
                           iv_message1 = lv_message
                           iv_message2 = ls_res_api-error-message-value
                           iv_symbol = '\' ).

    ENDIF.

* output
    LOOP AT ct_data ASSIGNING <lfs_data>.
      <lfs_data>-status = lv_status.
      <lfs_data>-message = lv_message.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
