CLASS zcl_purchasepricevariance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PURCHASEPRICEVARIANCE IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    TYPES: BEGIN OF ty_record,
             condition_record              TYPE i_purgprcgconditionrecord-conditionrecord,
             condition_validity_end_date   TYPE string,
             condition_validity_start_date TYPE string,
             supplier                      TYPE zc_purchasepricevariance-supplier,
             material                      TYPE zc_purchasepricevariance-material,
             purchasing_organization       TYPE zc_purchasepricevariance-purchasingorganization,
             plant                         TYPE zc_purchasepricevariance-plant,
             purchasinginforecordcategory  TYPE i_purginforecdorgplntdataapi01-purchasinginforecordcategory,
             validity_start_date           TYPE datum,
             validity_end_date             TYPE datum,
           END OF ty_record,
           BEGIN OF ty_result,
             results TYPE TABLE OF ty_record WITH DEFAULT KEY,
           END OF ty_result,
           BEGIN OF ty_response,
             d TYPE ty_result,
           END OF ty_response.

    DATA: lt_original_data TYPE STANDARD TABLE OF zc_purchasepricevariance WITH DEFAULT KEY.
    DATA: ls_response TYPE ty_response,
          lv_count    TYPE i,
          lv_filter   TYPE string.

    lt_original_data = CORRESPONDING #( it_original_data ).

    IF lt_original_data IS NOT INITIAL.
      SELECT purchaseorder,
             purchaseorderitem,
             sequentialnmbrofsuplrconf,
             deliverydate
        FROM i_posupplierconfirmationapi01 WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_original_data
       WHERE purchaseorder = @lt_original_data-purchaseorder
         AND purchaseorderitem = @lt_original_data-purchaseorderitem
        INTO TABLE @DATA(lt_posupplierconf).
      SORT lt_posupplierconf BY purchaseorder purchaseorderitem.

      SELECT purchaseorder,
             purchaseorderitem,
             accountassignmentnumber,
             purchasinghistorydocumenttype,
             purchasinghistorydocumentyear,
             purchasinghistorydocument,
             purchasinghistorydocumentitem,
             postingdate
        FROM i_purchaseorderhistoryapi01 WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_original_data
       WHERE purchaseorder = @lt_original_data-purchaseorder
         AND purchaseorderitem = @lt_original_data-purchaseorderitem
         AND purchasinghistorydocumenttype = '1'
        INTO TABLE @DATA(lt_pohistory).
      SORT lt_pohistory BY purchaseorder purchaseorderitem.

      DATA(lt_supplier) = lt_original_data.
      SORT lt_supplier BY supplier.
      DELETE ADJACENT DUPLICATES FROM lt_supplier COMPARING supplier.

      DATA(lt_material) = lt_original_data.
      SORT lt_material BY material.
      DELETE ADJACENT DUPLICATES FROM lt_material COMPARING material.

      DATA(lt_plant) = lt_original_data.
      SORT lt_plant BY plant.
      DELETE ADJACENT DUPLICATES FROM lt_plant COMPARING plant.

      DATA(lt_itemcategory) = lt_original_data.
      SORT lt_itemcategory BY purchaseorderitemcategory.
      DELETE ADJACENT DUPLICATES FROM lt_itemcategory COMPARING purchaseorderitemcategory.

      DATA(lv_path) = |/API_PURGPRCGCONDITIONRECORD_SRV/A_PurgPrcgCndnRecdValidity?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
      DATA(lv_select) = |ConditionRecord,ConditionValidityStartDate,ConditionValidityEndDate,Supplier,Material| &&
                        |,PurchasingOrganization,Plant,PurchasingInfoRecordCategory|.
      lv_filter = |ConditionType eq 'PPR0'|.

      CLEAR lv_count.
      LOOP AT lt_supplier INTO DATA(ls_supplier).
        lv_count += 1.
        IF lv_count = 1.
          lv_filter = |{ lv_filter } and (Supplier eq '{ ls_supplier-supplier }'|.
        ELSE.
          lv_filter = |{ lv_filter } or Supplier eq '{ ls_supplier-supplier }'|.
        ENDIF.
      ENDLOOP.
      lv_filter = |{ lv_filter })|.

      CLEAR lv_count.
      LOOP AT lt_material INTO DATA(ls_material).
        lv_count += 1.
        IF lv_count = 1.
          lv_filter = |{ lv_filter } and (Material eq '{ ls_material-material }'|.
        ELSE.
          lv_filter = |{ lv_filter } or Material eq '{ ls_material-material }'|.
        ENDIF.
      ENDLOOP.
      lv_filter = |{ lv_filter })|.

      CLEAR lv_count.
      LOOP AT lt_plant INTO DATA(ls_plant).
        lv_count += 1.
        IF lv_count = 1.
          lv_filter = |{ lv_filter } and (Plant eq '{ ls_plant-plant }'|.
        ELSE.
          lv_filter = |{ lv_filter } or Plant eq '{ ls_plant-plant }'|.
        ENDIF.
      ENDLOOP.
      lv_filter = |{ lv_filter })|.

      CLEAR lv_count.
      LOOP AT lt_itemcategory INTO DATA(ls_itemcategory).
        lv_count += 1.
        IF lv_count = 1.
          lv_filter = |{ lv_filter } and (PurchasingInfoRecordCategory eq '{ ls_itemcategory-purchaseorderitemcategory }'|.
        ELSE.
          lv_filter = |{ lv_filter } or PurchasingInfoRecordCategory eq '{ ls_itemcategory-purchaseorderitemcategory }'|.
        ENDIF.
      ENDLOOP.
      lv_filter = |{ lv_filter })|.

      zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                   iv_method      = if_web_http_client=>get
                                                   iv_select      = lv_select
                                                   iv_filter      = lv_filter
                                         IMPORTING ev_status_code = DATA(lv_status_code)
                                                   ev_response    = DATA(lv_response) ).
      IF lv_status_code = 200.
        REPLACE ALL OCCURRENCES OF `PurchasingInfoRecordCategory` IN lv_response  WITH `Purchasinginforecordcategory`.
        "ConditionValidityEndDate":"\/Date(253402214400000)\/"
        "ConditionValidityStartDate":"\/Date(1722297600000)\/"
        REPLACE ALL OCCURRENCES OF `\/Date(` IN lv_response  WITH ``.
        REPLACE ALL OCCURRENCES OF `)\/` IN lv_response  WITH ``.

        xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore )
          ( xco_cp_json=>transformation->boolean_to_abap_bool )
        ) )->write_to( REF #( ls_response ) ).

        DATA(lt_recdvalidity) = ls_response-d-results.
        LOOP AT lt_recdvalidity ASSIGNING FIELD-SYMBOL(<lfs_recdvalidity>).
          IF <lfs_recdvalidity>-condition_validity_start_date < 0.
            <lfs_recdvalidity>-validity_start_date = '19000101'.
          ELSEIF <lfs_recdvalidity>-condition_validity_start_date = '253402214400000'.
            <lfs_recdvalidity>-validity_start_date = '99991231'.
          ELSE.
            <lfs_recdvalidity>-validity_start_date = xco_cp_time=>unix_timestamp(
                        iv_unix_timestamp = <lfs_recdvalidity>-condition_validity_start_date / 1000
                     )->get_moment( )->as( xco_cp_time=>format->abap )->value+0(8).
          ENDIF.
          IF <lfs_recdvalidity>-condition_validity_end_date < 0.
            <lfs_recdvalidity>-validity_end_date = '19000101'.
          ELSEIF <lfs_recdvalidity>-condition_validity_end_date = '253402214400000'.
            <lfs_recdvalidity>-validity_end_date = '99991231'.
          ELSE.
            <lfs_recdvalidity>-validity_end_date = xco_cp_time=>unix_timestamp(
                        iv_unix_timestamp = <lfs_recdvalidity>-condition_validity_end_date / 1000
                     )->get_moment( )->as( xco_cp_time=>format->abap )->value+0(8).
          ENDIF.
          <lfs_recdvalidity>-supplier = |{ <lfs_recdvalidity>-supplier ALPHA = IN }|.
          <lfs_recdvalidity>-material = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_recdvalidity>-material ).
        ENDLOOP.
        SORT lt_recdvalidity BY supplier
                                material
                                purchasing_organization
                                plant
                                purchasinginforecordcategory
                                validity_start_date.

        IF lt_recdvalidity IS NOT INITIAL.
          SELECT conditionrecord,
                 conditionratevalue,
                 conditionquantity,
                 conditionquantityunit,
                 pricingscalebasis
            FROM i_purgprcgconditionrecord WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_recdvalidity
           WHERE conditionrecord = @lt_recdvalidity-condition_record
             AND conditionsequentialnumber = '1'
             AND conditionisdeleted = ''
            INTO TABLE @DATA(lt_conditionrecord).
          SORT lt_conditionrecord BY conditionrecord.

          SELECT conditionrecord,
                 conditionsequentialnumber,
                 conditionscaleline,
                 conditionratevalue,
                 conditionscalequantity
            FROM i_purgprcgcndnrecordscale WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_recdvalidity
           WHERE conditionrecord = @lt_recdvalidity-condition_record
             AND conditionsequentialnumber = '1'
            INTO TABLE @DATA(lt_recordscale).
          SORT lt_recordscale BY conditionrecord conditionscalequantity DESCENDING.
        ENDIF.
      ENDIF.

      ##ITAB_DB_SELECT
      ##ITAB_KEY_IN_SELECT
      SELECT a~purchaseorder,
             a~material,
             SUM( a~orderquantity ) AS orderquantity
        FROM @lt_original_data AS a
        GROUP BY a~purchaseorder,
                 a~material
        INTO TABLE @DATA(lt_group).
      SORT lt_group BY purchaseorder material.

      LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<lfs_original_data>).

        " 回答納期( 複数値を取得される場合、ブランクで表示される )
        CLEAR lv_count.
        LOOP AT lt_posupplierconf INTO DATA(ls_posupplierconf) WHERE purchaseorder = <lfs_original_data>-purchaseorder
                                                                 AND purchaseorderitem = <lfs_original_data>-purchaseorderitem.
          lv_count += 1.
          <lfs_original_data>-deliverydate = ls_posupplierconf-deliverydate.
          IF lv_count = 2.
            CLEAR <lfs_original_data>-deliverydate.
            EXIT.
          ENDIF.
        ENDLOOP.

        " 受入日( 複数値を取得される場合、ブランクで表示される )
        CLEAR lv_count.
        LOOP AT lt_pohistory INTO DATA(ls_pohistory) WHERE purchaseorder = <lfs_original_data>-purchaseorder
                                                       AND purchaseorderitem = <lfs_original_data>-purchaseorderitem.
          lv_count += 1.
          <lfs_original_data>-postingdate = ls_pohistory-postingdate.
          IF lv_count = 2.
            CLEAR <lfs_original_data>-postingdate.
            EXIT.
          ENDIF.
        ENDLOOP.

        LOOP AT lt_recdvalidity INTO DATA(ls_recdvalidity)
                                    WHERE supplier = <lfs_original_data>-supplier
                                      AND material = <lfs_original_data>-material
                                      AND plant = <lfs_original_data>-plant
                                      AND purchasing_organization = <lfs_original_data>-purchasingorganization
                                      AND purchasinginforecordcategory = <lfs_original_data>-purchaseorderitemcategory
                                      AND validity_start_date <= <lfs_original_data>-pricedate
                                      AND validity_end_date >= <lfs_original_data>-pricedate.

          <lfs_original_data>-conditionvaliditystartdate = ls_recdvalidity-validity_start_date.
          <lfs_original_data>-conditionvalidityenddate = ls_recdvalidity-validity_end_date.

          READ TABLE lt_conditionrecord INTO DATA(ls_conditionrecord)
                                        WITH KEY conditionrecord = ls_recdvalidity-condition_record
                                        BINARY SEARCH.
          IF sy-subrc = 0 AND ls_conditionrecord-conditionquantity IS NOT INITIAL.
            <lfs_original_data>-conditionquantity = ls_conditionrecord-conditionquantity.
            <lfs_original_data>-conditionquantityunit = ls_conditionrecord-conditionquantityunit.

            IF ls_conditionrecord-pricingscalebasis IS INITIAL.
              " 新PO単価
              <lfs_original_data>-newprice = ls_conditionrecord-conditionratevalue / ls_conditionrecord-conditionquantity.
            ELSEIF ls_conditionrecord-pricingscalebasis = 'C'.
              READ TABLE lt_group INTO DATA(ls_group) WITH KEY purchaseorder = <lfs_original_data>-purchaseorder
                                                               material = <lfs_original_data>-material
                                                               BINARY SEARCH.
              IF sy-subrc = 0.
                " 阶梯价格
                LOOP AT lt_recordscale INTO DATA(ls_recordscale) WHERE conditionrecord = ls_recdvalidity-condition_record.
                  IF ls_group-orderquantity >= ls_recordscale-conditionscalequantity.
                    " 新PO単価
                    <lfs_original_data>-newprice = ls_recordscale-conditionratevalue / ls_conditionrecord-conditionquantity.
                    EXIT.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF <lfs_original_data>-netpricequantity IS NOT INITIAL.
          <lfs_original_data>-currentprice = <lfs_original_data>-netpriceamount / <lfs_original_data>-netpricequantity.
        ENDIF.

        " 外部変換
        IF <lfs_original_data>-currentprice IS NOT INITIAL.
          <lfs_original_data>-currentprice = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                                   iv_currency = <lfs_original_data>-documentcurrency
                                                                                   iv_input = <lfs_original_data>-currentprice ).
        ENDIF.
        IF <lfs_original_data>-newprice IS NOT INITIAL.
          <lfs_original_data>-newprice = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                               iv_currency = <lfs_original_data>-currency
                                                                               iv_input = <lfs_original_data>-newprice ).
        ENDIF.

        " 単価差異
        <lfs_original_data>-difference = <lfs_original_data>-newprice - <lfs_original_data>-currentprice.
      ENDLOOP.
    ENDIF.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
