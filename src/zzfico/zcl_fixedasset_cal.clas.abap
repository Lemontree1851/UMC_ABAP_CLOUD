CLASS zcl_fixedasset_cal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fixedasset_cal IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.





    TYPES:
      BEGIN OF ty_results,
        companycode      TYPE i_fixedassetassgmt-companycode,
        masterfixedasset TYPE i_fixedassetassgmt-masterfixedasset,
        fixedasset       TYPE i_fixedassetassgmt-fixedasset,
        spc(3)           TYPE c,
      END OF ty_results,
      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,
      BEGIN OF ty_d,
        results TYPE tt_results,
      END OF ty_d,
      BEGIN OF ty_res_api,
        d TYPE ty_d,
      END OF ty_res_api,
      BEGIN OF ty_results1,
        chartofdepreciation     TYPE i_fixedassetassgmt-companycode,
        depreciationkey         TYPE i_fixedassetassgmt-companycode,
        "language(1)             TYPE c,
        depreciationkeyname(50) TYPE c,
      END OF ty_results1,
      BEGIN OF ty_sum,
        companycode             TYPE  i_glaccountlineitem-companycode,
        masterfixedasset        TYPE  i_glaccountlineitem-masterfixedasset,
        fixedasset              TYPE  i_glaccountlineitem-fixedasset,
        debitamountincocodecrcy TYPE  i_glaccountlineitem-debitamountincocodecrcy,
        companycodecurrency     TYPE  i_glaccountlineitem-companycodecurrency,
        quantity                TYPE  i_glaccountlineitem-quantity,
      END OF ty_sum,
      tt_results1 TYPE STANDARD TABLE OF ty_results1 WITH DEFAULT KEY,
      BEGIN OF ty_d1,
        results TYPE tt_results1,
      END OF ty_d1,
      BEGIN OF ty_res_api1,
        d TYPE ty_d1,
      END OF ty_res_api1.
    DATA:lv_path     TYPE string.
    DATA:ls_res_api  TYPE ty_res_api.
    DATA:ls_res_api1 TYPE ty_res_api1.
    DATA:ls_sum TYPE ty_sum.
    DATA:lt_sum TYPE STANDARD TABLE OF ty_sum.
    DATA:lt_original_data TYPE STANDARD TABLE OF zc_fixedassetprint WITH DEFAULT KEY.

    DATA:lv_masterfixedasset        TYPE i_fixedassetassgmt-masterfixedasset.
    DATA:lv_fixedasset              TYPE i_fixedassetassgmt-fixedasset.

    DATA:lv_from TYPE bldat.
    DATA:lv_to TYPE bldat.
    lt_original_data = CORRESPONDING #( it_original_data ).
    IF lt_original_data IS NOT INITIAL.

      SELECT companycode,masterfixedasset,fixedasset, debitamountincocodecrcy ,companycodecurrency ,
      subledgeracctlineitemtype,fiscalyear,accountingdocument,ledgergllineitem,businesstransactiontype,
      quantity,baseunit
      FROM
      i_glaccountlineitem
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_original_data
      WHERE masterfixedasset = @lt_original_data-masterfixedasset
      AND fixedasset = @lt_original_data-fixedasset
      AND sourceledger = '0L'
      AND ledger = '0L'
      AND (   subledgeracctlineitemtype = '7000' OR subledgeracctlineitemtype = '7040' )
      AND masterfixedasset IS NOT INITIAL
      AND businesstransactiontype NE 'RFBC'
      AND debitamountincocodecrcy IS NOT INITIAL
      INTO TABLE @DATA(lt_glaccountlineitem).
      SORT lt_glaccountlineitem BY companycode masterfixedasset fixedasset quantity DESCENDING.

      LOOP AT lt_glaccountlineitem INTO DATA(lt_glaccountlineitem1).
        CLEAR ls_sum.
        MOVE-CORRESPONDING lt_glaccountlineitem1 TO ls_sum.
        COLLECT ls_sum INTO lt_sum.
      ENDLOOP.
      SORT lt_sum BY companycode masterfixedasset fixedasset.

    ENDIF.

    lv_path = |/YY1_FIXEDASSETCOUNTRYDATA_CDS/YY1_FixedAssetCountryData|.
    "Call API
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>get
        iv_format      = 'json'
      IMPORTING
        ev_status_code = DATA(lv_stat_code)
        ev_response    = DATA(lv_resbody_api) ).
    "JSON->ABAP
    xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api ) ).

    lv_path = |/YY1_DEPRECIATIONKEY_CDS/YY1_DepreciationKey|.
    "Call API
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>get
        iv_format      = 'json'
      IMPORTING
        ev_status_code = DATA(lv_stat_code1)
        ev_response    = DATA(lv_resbody_api1) ).

    "JSON->ABAP
    xco_cp_json=>data->from_string( lv_resbody_api1 )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api1 ) ).

    IF ls_res_api-d-results IS NOT INITIAL OR ls_res_api1-d-results IS NOT INITIAL.

      SORT ls_res_api-d-results BY companycode masterfixedasset fixedasset.
      SORT ls_res_api1-d-results BY chartofdepreciation depreciationkey .


*      IF lt_original_data IS NOT INITIAL.
*        SELECT companycode, masterfixedasset, fixedasset ,yy1_fixedasset1_faa AS yy1_fixedasset1_faa
*        FROM i_fixedasset WITH PRIVILEGED ACCESS
*        FOR ALL ENTRIES IN @lt_original_data
*        WHERE companycode = @lt_original_data-companycode
*        AND masterfixedasset = @lt_original_data-masterfixedasset
*        AND fixedasset = @lt_original_data-fixedasset
*        INTO TABLE @DATA(lt_fixedasset).
*      ENDIF.
      "SORT lt_fixedasset BY companycode  masterfixedasset  fixedasset.

      LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
        lv_masterfixedasset =  |{ <fs_original_data>-masterfixedasset ALPHA = OUT }|.
        lv_fixedasset       =  |{ <fs_original_data>-fixedasset ALPHA = OUT }|.
        READ TABLE ls_res_api-d-results INTO DATA(ls_result) WITH KEY companycode = <fs_original_data>-companycode
        masterfixedasset = lv_masterfixedasset fixedasset = lv_fixedasset BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_original_data>-jp_prptytxrptspcldepr =  ls_result-spc.
        ENDIF.
        IF <fs_original_data>-jp_prptytxrptspcldepr = 'JP0'.
          <fs_original_data>-jp_prptytxrptspcldepr = '非课税'.
        ENDIF.
        READ TABLE ls_res_api1-d-results INTO DATA(ls_result1) WITH KEY chartofdepreciation = '1510'
        depreciationkey = <fs_original_data>-depreciationkey BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_original_data>-depreciationkeyname =  ls_result1-depreciationkeyname.
        ENDIF.
*        READ TABLE lt_fixedasset INTO DATA(ls_fixedasset) WITH KEY companycode = <fs_original_data>-companycode
*        masterfixedasset = <fs_original_data>-masterfixedasset fixedasset = <fs_original_data>-fixedasset BINARY SEARCH.
*        IF sy-subrc = 0.
*          IF ls_fixedasset-yy1_fixedasset1_faa = '01'.
*            <fs_original_data>-yy1_fixedasset1_faa = '所有'.
*          ELSEIF ls_fixedasset-yy1_fixedasset1_faa = '02'.
*            <fs_original_data>-yy1_fixedasset1_faa = '借家'.
*          ENDIF.
*        ENDIF.
        READ TABLE lt_sum INTO DATA(ls_glaccountlineitem) WITH KEY companycode = <fs_original_data>-companycode
  masterfixedasset = <fs_original_data>-masterfixedasset fixedasset = <fs_original_data>-fixedasset BINARY SEARCH.
        IF sy-subrc = 0.

          <fs_original_data>-originalacquisitionamount = ls_glaccountlineitem-debitamountincocodecrcy.
          <fs_original_data>-originalacquisitioncurrency = ls_glaccountlineitem-companycodecurrency.
          <fs_original_data>-quantity = ls_glaccountlineitem-quantity.
        ENDIF.
*        <fs_original_data>-barcode = <fs_original_data>-companycode && ';' &&  <fs_original_data>-masterfixedasset && ';' && <fs_original_data>-fixedasset && ';' .
*        <fs_original_data>-barcode = <fs_original_data>-barcode && <fs_original_data>-inventorynote && ';' && <fs_original_data>-fixedassetdescription && ';' &&  <fs_original_data>-fixedassetexternalid && ';' && <fs_original_data>-inventory && ';' .
*        <fs_original_data>-barcode = <fs_original_data>-barcode && <fs_original_data>-costcenter && ';' && <fs_original_data>-costcentername && ';' &&  <fs_original_data>-assetcapitalizationdate && ';' && <fs_original_data>-depreciationstartdate && ';' .
*        <fs_original_data>-barcode = <fs_original_data>-barcode && <fs_original_data>-assetaccountdeterminationdesc && ';' && <fs_original_data>-depreciationkeyname && ';' &&  <fs_original_data>-leasedassetnote && ';'.
*        <fs_original_data>-barcode = <fs_original_data>-barcode && <fs_original_data>-plannedusefullifeinyears && ';' && <fs_original_data>-originalacquisitionamount && ';' && <fs_original_data>-investmentreason && ';' .
*        <fs_original_data>-barcode = <fs_original_data>-barcode && <fs_original_data>-assettypename && ';' && <fs_original_data>-yy1_fixedasset1_faa && ';'  && ';' && <fs_original_data>-jp_prptytxrptspcldepr .

        <fs_original_data>-barcode =  <fs_original_data>-fixedassetexternalid  && ';'  && <fs_original_data>-costcenter.
        READ TABLE lt_glaccountlineitem INTO DATA(ls_glaccountlineitem1) WITH KEY companycode = <fs_original_data>-companycode
  masterfixedasset = <fs_original_data>-masterfixedasset fixedasset = <fs_original_data>-fixedasset BINARY SEARCH.
        IF sy-subrc = 0.

          "<fs_original_data>-quantity = ls_glaccountlineitem1-quantity.
          <fs_original_data>-baseunit = ls_glaccountlineitem1-baseunit.
        ENDIF.
      ENDLOOP.
    ENDIF.
    ct_calculated_data = CORRESPONDING #(  lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'JP_PRPTYTXRPTSPCLDEPR'.
          INSERT `COMPANYCODE` INTO TABLE et_requested_orig_elements.
          INSERT `MASTERFIXEDASSET` INTO TABLE et_requested_orig_elements.
          INSERT `FIXEDASSET` INTO TABLE et_requested_orig_elements.
        WHEN 'DEPRECIATIONKEYNAME'.
          INSERT `COMPANYCODE` INTO TABLE et_requested_orig_elements.
          INSERT `MASTERFIXEDASSET` INTO TABLE et_requested_orig_elements.
          INSERT `FIXEDASSET` INTO TABLE et_requested_orig_elements.
          INSERT `DEPRECIATIONKEY` INTO TABLE et_requested_orig_elements.

        WHEN 'ORIGINALACQUISITIONAMOUNT'.
          INSERT `COMPANYCODE` INTO TABLE et_requested_orig_elements.
          INSERT `MASTERFIXEDASSET` INTO TABLE et_requested_orig_elements.
          INSERT `FIXEDASSET` INTO TABLE et_requested_orig_elements.
          INSERT `DEPRECIATIONKEY` INTO TABLE et_requested_orig_elements.
        WHEN 'ORIGINALACQUISITIONCURRENCY'.
          INSERT `COMPANYCODE` INTO TABLE et_requested_orig_elements.
          INSERT `MASTERFIXEDASSET` INTO TABLE et_requested_orig_elements.
          INSERT `FIXEDASSET` INTO TABLE et_requested_orig_elements.
          INSERT `DEPRECIATIONKEY` INTO TABLE et_requested_orig_elements.
        WHEN 'QUANTITY'.
          INSERT `COMPANYCODE` INTO TABLE et_requested_orig_elements.
          INSERT `MASTERFIXEDASSET` INTO TABLE et_requested_orig_elements.
          INSERT `FIXEDASSET` INTO TABLE et_requested_orig_elements.
          INSERT `DEPRECIATIONKEY` INTO TABLE et_requested_orig_elements.
        WHEN 'BASEUNIT'.
          INSERT `COMPANYCODE` INTO TABLE et_requested_orig_elements.
          INSERT `MASTERFIXEDASSET` INTO TABLE et_requested_orig_elements.
          INSERT `FIXEDASSET` INTO TABLE et_requested_orig_elements.
          INSERT `DEPRECIATIONKEY` INTO TABLE et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
