CLASS zcl_purinfomasterlist DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_purinfomasterlist IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TYPES: BEGIN OF ty_record,
             conditionrecord              TYPE i_purgprcgconditionrecord-conditionrecord,
             conditionvalidityenddate     TYPE string,
             conditionvaliditystartdate   TYPE string,
             purchasinginforecord         TYPE i_purginforecdorgplntdataapi01-purchasinginforecord,
             material                     TYPE i_purchasinginforecordapi01-material,
             supplier                     TYPE i_purchasinginforecordapi01-supplier,
             plant                        TYPE i_purginforecdorgplntdataapi01-plant,
             purchasingorganization       TYPE i_purginforecdorgplntdataapi01-purchasingorganization,
             purchasinginforecordcategory TYPE i_purginforecdorgplntdataapi01-purchasinginforecordcategory,
             validitystartdate            TYPE datum,
             validityenddate              TYPE datum,
             creationdate                 TYPE datum,
             creationtime                 TYPE uzeit,
           END OF ty_record,
           BEGIN OF ty_result,
             results TYPE TABLE OF ty_record WITH DEFAULT KEY,
           END OF ty_result,
           BEGIN OF ty_response,
             d TYPE ty_result,
           END OF ty_response.

    DATA: lt_data TYPE STANDARD TABLE OF zr_purinfomasterlist,
          ls_data LIKE LINE OF lt_data.

    DATA: ls_response     TYPE ty_response,
          lt_recdvalidity TYPE STANDARD TABLE OF ty_record.

    DATA: lv_filter                 TYPE string,
          lv_unitprice_standard(16) TYPE p DECIMALS 3,
          lv_unitprice_plnt(16)     TYPE p DECIMALS 3,
          lv_price(16)              TYPE p DECIMALS 6,
          lv_count                  TYPE i,
          lv_dec                    TYPE i,
          lv_rate(16)               TYPE p DECIMALS 6,
          lv_rate_display           TYPE p DECIMALS 2.

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          CASE ls_filter_cond-name.
            WHEN 'PURCHASINGINFORECORD'.
              DATA(lr_purchasinginforecord) = ls_filter_cond-range.
            WHEN 'PLANT'.
              DATA(lr_plant) = ls_filter_cond-range.
            WHEN 'PURCHASINGORGANIZATION'.
              DATA(lr_purchasingorganization) = ls_filter_cond-range.
            WHEN 'MATERIAL'.
              DATA(lr_material) = ls_filter_cond-range.
              LOOP AT lr_material ASSIGNING FIELD-SYMBOL(<lr_material>).
                <lr_material>-low  = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lr_material>-low ).
                <lr_material>-high = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lr_material>-high ).
              ENDLOOP.
            WHEN 'SUPPLIER'.
              DATA(lr_supplier) = ls_filter_cond-range.
            WHEN 'SUPPLIERMATERIALNUMBER'.
              DATA(lr_suppliermaterialnumber) = ls_filter_cond-range.
            WHEN 'PURCHASINGGROUP'.
              DATA(lr_purchasinggroup) = ls_filter_cond-range.
            WHEN 'CREATIONDATE_1'.
              DATA(lr_creationdate_1) = ls_filter_cond-range.
            WHEN 'CREATIONDATE_2'.
              DATA(lr_creationdate_2) = ls_filter_cond-range.
            WHEN 'MANUFACTURERNUMBER'.
              DATA(lr_manufacturernumber) = ls_filter_cond-range.
            WHEN 'PRODUCTMANUFACTURERNUMBER'.
              DATA(lr_productmanufacturernumber) = ls_filter_cond-range.
            WHEN 'LATESTOFFER'.
              DATA(lr_latestoffer) = ls_filter_cond-range.
            WHEN 'SUPPLIERISFIXED'.
              DATA(lr_supplierisfixed) = ls_filter_cond-range.
            WHEN 'INCOTERMSCLASSIFICATION'.
              DATA(lr_incotermsclassification) = ls_filter_cond-range.
            WHEN 'PLUSDAY'.
              IF ls_filter_cond-range IS NOT INITIAL.
                DATA(lv_plusday) = ls_filter_cond-range[ 1 ]-low.
              ENDIF.
            WHEN 'ZTYPE1'.
              IF ls_filter_cond-range IS NOT INITIAL.
                DATA(lv_ztype1) = ls_filter_cond-range[ 1 ]-low.
              ENDIF.
            WHEN 'ZTYPE2'.
              IF ls_filter_cond-range IS NOT INITIAL.
                DATA(lv_ztype2) = ls_filter_cond-range[ 1 ]-low.
              ENDIF.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
        IF sy-subrc = 0.
        ENDIF.
    ENDTRY.

    " 获取系统当前日期
    DATA(lv_current_date) = cl_abap_context_info=>get_system_date( ).

    SELECT a~purchasinginforecord,
           a~material,
           a~supplier,
           a~suppliermaterialnumber,
           a~suppliermaterialgroup,
           a~suppliercertorigincountry,
           a~suppliercertoriginregion,
           a~purgdocorderquantityunit,
           a~baseunit,
           a~creationdate AS creationdate_1,
           a~suppliersubrange,
           a~isdeleted,

           b~productgroup,
           b~productoid,
           b~owninventorymanagedproduct,
           b~manufacturernumber,
           b~industrystandardname,
           b~productmanufacturernumber,

*           c~firstsalesspecproductgroup,
           c~productsalesorg,

           d~plant,
           d~purchasingorganization,
           d~ismarkedfordeletion,
           d~purchasinginforecordcategory,
           d~materialplanneddeliverydurn,
           d~purchasinggroup,
           d~minimumpurchaseorderquantity,
           d~maximumorderquantity,
           d~supplierconfirmationcontrolkey,
           d~taxcode,
           d~currency AS currency_plnt,
           d~netpriceamount,
           d~materialpriceunitqty,
           d~pricingdatecontrol,
           d~incotermsclassification,
           d~createdbyuser,

           e~additionalmaterialgroup1name AS firstsalesspecproductgroup,
           f~productname,
           g~organizationbpname1 AS organizationbpname1_ja,
           h~zvalue2,
           i~purchasinggroupname,
           j~shippingconditionname,
           k~organizationbpname1 AS organizationbpname1_en,
           o~supplierisfixed

      FROM i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS AS d
             ON d~purchasinginforecord = a~purchasinginforecord
      LEFT JOIN i_product WITH PRIVILEGED ACCESS AS b
             ON b~product = a~material
      LEFT JOIN i_producttext WITH PRIVILEGED ACCESS AS f
             ON f~product = a~material
            AND f~language = @sy-langu
      LEFT JOIN i_businesspartner WITH PRIVILEGED ACCESS AS g
             ON g~businesspartner = a~supplier
      LEFT JOIN i_productsalesdelivery WITH PRIVILEGED ACCESS AS c
             ON c~product = a~material
            AND c~productsalesorg = d~purchasingorganization
            AND c~productdistributionchnl = '10'
      LEFT JOIN i_additionalmaterialgroup1text WITH PRIVILEGED ACCESS AS e
             ON e~additionalmaterialgroup1 = c~firstsalesspecproductgroup
            AND e~language = @sy-langu
      LEFT JOIN i_mppurchasingsourceitem WITH PRIVILEGED ACCESS AS o
             ON o~material = a~material
            AND o~plant    = d~plant
            AND o~supplier = a~supplier
      LEFT JOIN i_purchasinggroup WITH PRIVILEGED ACCESS AS i
             ON i~purchasinggroup = d~purchasinggroup
      LEFT JOIN i_shippingconditiontext WITH PRIVILEGED ACCESS AS j
             ON j~shippingcondition = d~shippinginstruction
            AND j~language = @sy-langu
      LEFT JOIN i_businesspartner WITH PRIVILEGED ACCESS AS k
             ON k~businesspartner = b~manufacturernumber
      LEFT JOIN ztbc_1001 AS h ON zid = 'ZMM001' AND zvalue1 = d~taxcode
      WHERE a~purchasinginforecord IN @lr_purchasinginforecord
        AND a~supplier IN @lr_supplier
        AND a~material IN @lr_material
        AND a~suppliermaterialnumber IN @lr_suppliermaterialnumber
        AND a~creationdate IN @lr_creationdate_1
        AND b~manufacturernumber IN @lr_manufacturernumber
        AND b~productmanufacturernumber IN @lr_productmanufacturernumber
        AND d~plant IN @lr_plant
        AND d~purchasingorganization IN @lr_purchasingorganization
        AND d~incotermsclassification IN @lr_incotermsclassification
        AND d~purchasinggroup IN @lr_purchasinggroup
        AND o~supplierisfixed IN @lr_supplierisfixed
      INTO TABLE @DATA(lt_purinfoitem).

*&--Authorization Check
    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
    DATA(lv_plant) = zzcl_common_utils=>get_plant_by_user( lv_user_email ).
    DATA(lv_purchorg) = zzcl_common_utils=>get_purchorg_by_user( lv_user_email ).
    IF lv_plant IS INITIAL.
      CLEAR lt_purinfoitem.
    ELSE.
      SPLIT lv_plant AT '&' INTO TABLE DATA(lt_plant_check).
      CLEAR lr_plant.
      lr_plant = VALUE #( FOR plant IN lt_plant_check ( sign = 'I' option = 'EQ' low = plant ) ).
      DELETE lt_purinfoitem WHERE plant NOT IN lr_plant.
    ENDIF.
    IF lv_purchorg IS INITIAL.
      CLEAR lt_purinfoitem.
    ELSE.
      SPLIT lv_purchorg AT '&' INTO TABLE DATA(lt_purchorg_check).
      CLEAR lr_purchasingorganization.
      lr_purchasingorganization = VALUE #( FOR purchorg IN lt_purchorg_check ( sign = 'I' option = 'EQ' low = purchorg ) ).
      DELETE lt_purinfoitem WHERE purchasingorganization NOT IN lr_purchasingorganization.
    ENDIF.
*&--Authorization Check

    IF lt_purinfoitem IS NOT INITIAL.
      SORT lt_purinfoitem ASCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_purinfoitem COMPARING ALL FIELDS.

      SELECT product,
             valuationarea,
             standardprice,
             valuationclass,
             priceunitqty,
             currency,
             movingaverageprice
        FROM i_productvaluationbasic WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_purinfoitem
       WHERE product = @lt_purinfoitem-material
         AND valuationarea = @lt_purinfoitem-plant
        INTO TABLE @DATA(lt_productvaluation).
      SORT lt_productvaluation BY product valuationarea.

      DATA(lt_plant) = lt_purinfoitem.
      SORT lt_plant BY plant.
      DELETE ADJACENT DUPLICATES FROM lt_plant COMPARING plant.

      DATA(lt_supplier) = lt_purinfoitem.
      SORT lt_supplier BY supplier.
      DELETE ADJACENT DUPLICATES FROM lt_supplier COMPARING supplier.

      DATA(lt_material) = lt_purinfoitem.
      SORT lt_material BY material.
      DELETE ADJACENT DUPLICATES FROM lt_material COMPARING material.

      DATA(lt_organization) = lt_purinfoitem.
      SORT lt_organization BY purchasingorganization.
      DELETE ADJACENT DUPLICATES FROM lt_organization COMPARING purchasingorganization.

      DATA(lt_itemcategory) = lt_purinfoitem.
      SORT lt_itemcategory BY purchasinginforecordcategory.
      DELETE ADJACENT DUPLICATES FROM lt_itemcategory COMPARING purchasinginforecordcategory.

      DATA(lv_path) = |/API_PURGPRCGCONDITIONRECORD_SRV/A_PurgPrcgCndnRecdValidity?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
      DATA(lv_select) = |ConditionRecord,ConditionValidityStartDate,ConditionValidityEndDate,PurchasingInfoRecord| &&
                        |,Supplier,Material,Plant,PurchasingOrganization,PurchasingInfoRecordCategory|.

      lv_filter = |ConditionType eq 'PPR0'|.

      CLEAR lv_count.
      LOOP AT lt_plant INTO DATA(ls_plant1).
        lv_count += 1.
        IF lv_count = 1.
          lv_filter = |{ lv_filter } and (Plant eq '{ ls_plant1-plant }'|.
        ELSE.
          lv_filter = |{ lv_filter } or Plant eq '{ ls_plant1-plant }'|.
        ENDIF.
      ENDLOOP.
      lv_filter = |{ lv_filter })|.

      IF lines( lt_supplier ) < 20.
        CLEAR lv_count.
        LOOP AT lt_supplier INTO DATA(ls_supplier1).
          lv_count += 1.
          IF lv_count = 1.
            lv_filter = |{ lv_filter } and (Supplier eq '{ ls_supplier1-supplier }'|.
          ELSE.
            lv_filter = |{ lv_filter } or Supplier eq '{ ls_supplier1-supplier }'|.
          ENDIF.
        ENDLOOP.
        lv_filter = |{ lv_filter })|.
      ENDIF.

      IF lines( lt_material ) < 20.
        CLEAR lv_count.
        LOOP AT lt_material INTO DATA(ls_material1).
          lv_count += 1.
          IF lv_count = 1.
            lv_filter = |{ lv_filter } and (Material eq '{ ls_material1-material }'|.
          ELSE.
            lv_filter = |{ lv_filter } or Material eq '{ ls_material1-material }'|.
          ENDIF.
        ENDLOOP.
        lv_filter = |{ lv_filter })|.
      ENDIF.

      CLEAR lv_count.
      LOOP AT lt_organization INTO DATA(ls_organization).
        lv_count += 1.
        IF lv_count = 1.
          lv_filter = |{ lv_filter } and (PurchasingOrganization eq '{ ls_organization-purchasingorganization }'|.
        ELSE.
          lv_filter = |{ lv_filter } or PurchasingOrganization eq '{ ls_organization-purchasingorganization }'|.
        ENDIF.
      ENDLOOP.
      lv_filter = |{ lv_filter })|.

      CLEAR lv_count.
      LOOP AT lt_itemcategory INTO DATA(ls_itemcategory).
        lv_count += 1.
        IF lv_count = 1.
          lv_filter = |{ lv_filter } and (PurchasingInfoRecordCategory eq '{ ls_itemcategory-purchasinginforecordcategory }'|.
        ELSE.
          lv_filter = |{ lv_filter } or PurchasingInfoRecordCategory eq '{ ls_itemcategory-purchasinginforecordcategory }'|.
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
        REPLACE ALL OCCURRENCES OF `\/Date(` IN lv_response  WITH ``.
        REPLACE ALL OCCURRENCES OF `)\/` IN lv_response  WITH ``.

        /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                   CHANGING  data = ls_response ).

        APPEND LINES OF ls_response-d-results TO lt_recdvalidity.

        SORT lt_recdvalidity BY material ASCENDING
                                supplier ASCENDING
                                plant    ASCENDING
                                purchasingorganization ASCENDING
                                purchasinginforecordcategory ASCENDING
                                conditionvaliditystartdate DESCENDING.
      ENDIF.

      IF lt_recdvalidity IS NOT INITIAL.
        SELECT conditionrecord,
               conditionscalequantity,
               conditionquantity,
               conditionratevalue,
               creationdate AS creationdate_2,
               pricingscalebasis
        FROM i_purgprcgconditionrecord WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_recdvalidity
       WHERE conditionrecord = @lt_recdvalidity-conditionrecord
         AND creationdate IN @lr_creationdate_2
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
         WHERE conditionrecord = @lt_recdvalidity-conditionrecord
           AND conditionsequentialnumber = '1'
          INTO TABLE @DATA(lt_recordscale).
        SORT lt_recordscale BY conditionrecord conditionscalequantity.
      ENDIF.
    ENDIF.

    LOOP AT lt_purinfoitem INTO DATA(ls_data2).
      CLEAR ls_data.
      MOVE-CORRESPONDING ls_data2 TO ls_data.

      IF ls_data-material IS NOT INITIAL AND
         ls_data-plant    IS NOT INITIAL AND
         ls_data-supplier IS NOT INITIAL.
        ls_data-loginflag = 'X'.
      ELSE.
        ls_data-loginflag = ''.
      ENDIF.

      ls_data-deliverylt = ls_data2-materialplanneddeliverydurn + lv_plusday.

      " 查找对应的单价信息
      READ TABLE lt_productvaluation INTO DATA(ls_productvaluation) WITH KEY product = ls_data-material
                                                                             valuationarea = ls_data-plant
                                                                             BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-unitprice_plnt = zzcl_common_utils=>conversion_amount( iv_alpha    = zzcl_common_utils=>lc_alpha_in
                                                                       iv_currency = ls_productvaluation-currency
                                                                       iv_input    = ls_productvaluation-standardprice ).

        ls_data-valuationclass    = ls_productvaluation-valuationclass.
        ls_data-priceunitqty      = ls_productvaluation-priceunitqty.
        ls_data-currency_standard = ls_productvaluation-currency.

        IF ls_productvaluation-priceunitqty  IS NOT INITIAL AND
           ls_productvaluation-standardprice IS NOT INITIAL.

          lv_unitprice_standard = ls_productvaluation-standardprice / ls_productvaluation-priceunitqty.

          IF ls_productvaluation-currency = 'JPY'.
            lv_dec = 3.
          ELSE.
            lv_dec = 5.
          ENDIF.

          ls_data-unitprice_standard = round( val  = lv_unitprice_standard
                                              dec  = lv_dec
                                              mode = cl_abap_math=>round_half_up ).
        ENDIF.
      ENDIF.

      ls_data-supplier = |{ ls_data-supplier ALPHA = OUT }|.

      READ TABLE lt_recdvalidity TRANSPORTING NO FIELDS WITH KEY material = ls_data-material
                                                                 supplier = ls_data-supplier
                                                                 plant = ls_data-plant
                                                                 purchasingorganization = ls_data-purchasingorganization
                                                                 purchasinginforecordcategory = ls_data-purchasinginforecordcategory
                                                                 BINARY SEARCH.
      IF sy-subrc = 0.
        DATA(lv_lastflg) = abap_on.
        LOOP AT lt_recdvalidity INTO DATA(ls_recdvalidity) FROM sy-tabix
          WHERE material = ls_data-material
            AND supplier = ls_data-supplier
            AND plant = ls_data-plant
            AND purchasingorganization = ls_data-purchasingorganization
            AND purchasinginforecordcategory = ls_data-purchasinginforecordcategory.

          IF ls_recdvalidity-conditionvaliditystartdate < 0.
            ls_recdvalidity-validitystartdate = '19000101'.
          ELSEIF ls_recdvalidity-validitystartdate = '253402214400000'.
            ls_recdvalidity-validitystartdate = '99991231'.
          ELSE.
            ls_recdvalidity-validitystartdate = xco_cp_time=>unix_timestamp(
                        iv_unix_timestamp = ls_recdvalidity-conditionvaliditystartdate / 1000
                     )->get_moment( )->as( xco_cp_time=>format->abap )->value+0(8).
          ENDIF.
          IF ls_recdvalidity-conditionvalidityenddate < 0.
            ls_recdvalidity-validityenddate = '19000101'.
          ELSEIF ls_recdvalidity-conditionvalidityenddate = '253402214400000'.
            ls_recdvalidity-validityenddate = '99991231'.
          ELSE.
            ls_recdvalidity-validityenddate = xco_cp_time=>unix_timestamp(
                        iv_unix_timestamp = ls_recdvalidity-conditionvalidityenddate / 1000
                     )->get_moment( )->as( xco_cp_time=>format->abap )->value+0(8).
          ENDIF.

          ls_data-condition_validity_start_date = ls_recdvalidity-validitystartdate.
          ls_data-condition_validity_end_date   = ls_recdvalidity-validityenddate.

          IF ls_recdvalidity-conditionvaliditystartdate >= 0 AND lv_lastflg IS NOT INITIAL.
            ls_data-latestoffer = abap_on.
            CLEAR lv_lastflg.
          ELSE.
            CLEAR ls_data-latestoffer.
          ENDIF.

          TRY.
              ls_data-purgdocorderquantityunit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = ls_data-purgdocorderquantityunit ).
              ls_data-baseunit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = ls_data-baseunit ).
              ##NO_HANDLER
            CATCH zzcx_custom_exception.
              " handle exception
          ENDTRY.

          READ TABLE lt_conditionrecord INTO DATA(ls_conditionrecord) WITH KEY conditionrecord = ls_recdvalidity-conditionrecord BINARY SEARCH.
          IF sy-subrc = 0.
            ls_data-creationdate_2 = ls_conditionrecord-creationdate_2.
            ls_data-materialpriceunitqty = ls_conditionrecord-conditionquantity.

            IF ls_conditionrecord-pricingscalebasis IS INITIAL.
              ls_data-conditionratevalue = ls_conditionrecord-conditionratevalue.

              IF ls_data-materialpriceunitqty <> 0.
                lv_unitprice_plnt = zzcl_common_utils=>conversion_amount( iv_alpha    = zzcl_common_utils=>lc_alpha_out
                                                                          iv_currency = ls_data-currency_plnt
                                                                          iv_input    = ls_data-conditionratevalue ).
                lv_unitprice_plnt = lv_unitprice_plnt / ls_data-materialpriceunitqty.

                IF ls_data-currency_plnt = 'JPY'.
                  lv_dec = 3.
                ELSE.
                  lv_dec = 5.
                ENDIF.

                ls_data-standardpurchaseorderquantity = round( val  = lv_unitprice_plnt
                                                               dec  = lv_dec
                                                               mode = cl_abap_math=>round_half_up ).
              ENDIF.

              IF lv_unitprice_plnt IS NOT INITIAL AND ls_data-zvalue2 IS NOT INITIAL AND ls_data-zvalue2 <> 0.
                ls_data-taxprice = lv_unitprice_plnt * ls_data-zvalue2 / 100.
              ELSE.
                ls_data-taxprice = 0.
              ENDIF.

              lv_price = abs( ls_data-unitprice_standard - ls_data-standardpurchaseorderquantity ).

              IF lv_price IS NOT INITIAL AND ls_data-unitprice_standard IS NOT INITIAL.
                lv_rate = lv_price / ls_data-unitprice_standard.

                " 转换为百分比形式
                lv_rate = lv_rate * 100.
                " 四舍五入至2位小数
                lv_rate = round( val  = lv_rate
                                 dec  = 2
                                 mode = cl_abap_math=>round_half_up ).
                lv_rate_display = lv_rate.
                ls_data-rate = |{ lv_rate_display }%|.
              ELSE.
                ls_data-rate = '0.00%'.
              ENDIF.

              TRY.
                  ls_data-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
                  ##NO_HANDLER
                CATCH cx_uuid_error.
                  "handle exception
              ENDTRY.
              APPEND ls_data TO lt_data.
            ELSEIF ls_conditionrecord-pricingscalebasis = 'C'.
              " 阶梯价格
              LOOP AT lt_recordscale INTO DATA(ls_recordscale) WHERE conditionrecord = ls_recdvalidity-conditionrecord.
                ls_data-conditionscalequantity = ls_recordscale-conditionscalequantity.
                ls_data-conditionratevalue = ls_recordscale-conditionratevalue.

                IF ls_data-materialpriceunitqty <> 0.
                  lv_unitprice_plnt = zzcl_common_utils=>conversion_amount( iv_alpha    = zzcl_common_utils=>lc_alpha_out
                                                                            iv_currency = ls_data-currency_plnt
                                                                            iv_input    = ls_data-conditionratevalue ).
                  lv_unitprice_plnt = lv_unitprice_plnt / ls_data-materialpriceunitqty.

                  IF ls_data-currency_plnt = 'JPY'.
                    lv_dec = 3.
                  ELSE.
                    lv_dec = 5.
                  ENDIF.

                  ls_data-standardpurchaseorderquantity = round( val  = lv_unitprice_plnt
                                                                 dec  = lv_dec
                                                                 mode = cl_abap_math=>round_half_up ).
                ENDIF.

                IF lv_unitprice_plnt IS NOT INITIAL AND ls_data-zvalue2 IS NOT INITIAL AND ls_data-zvalue2 <> 0.
                  ls_data-taxprice = lv_unitprice_plnt * ls_data-zvalue2 / 100.
                ELSE.
                  ls_data-taxprice = 0.
                ENDIF.

                lv_price = abs( ls_data-unitprice_standard - ls_data-standardpurchaseorderquantity ).

                IF lv_price IS NOT INITIAL AND ls_data-unitprice_standard IS NOT INITIAL.
                  lv_rate = lv_price / ls_data-unitprice_standard.

                  " 转换为百分比形式
                  lv_rate = lv_rate * 100.
                  " 四舍五入至2位小数
                  lv_rate = round( val  = lv_rate
                                   dec  = 2
                                   mode = cl_abap_math=>round_half_up ).
                  lv_rate_display = lv_rate.
                  ls_data-rate = |{ lv_rate_display }%|.
                ELSE.
                  ls_data-rate = '0.00%'.
                ENDIF.

                TRY.
                    ls_data-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
                    ##NO_HANDLER
                  CATCH cx_uuid_error.
                    "handle exception
                ENDTRY.
                APPEND ls_data TO lt_data.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF lv_ztype1 <> 'X'.
      DELETE lt_data WHERE isdeleted IS NOT INITIAL
                        OR ismarkedfordeletion IS NOT INITIAL.
    ENDIF.

    IF lv_ztype2 = 'X'.
      DELETE lt_data WHERE condition_validity_end_date <= lv_current_date
                        OR condition_validity_start_date >= lv_current_date.
    ENDIF.

    DELETE lt_data WHERE latestoffer NOT IN lr_latestoffer.

    SORT lt_data BY purchasinginforecord
                    purchasinginforecordcategory
                    condition_validity_start_date
                    conditionscalequantity.

    " Filtering
    zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
                                           it_excluded = VALUE #( ( fieldname = 'MATERIAL' )
                                                                  ( fieldname = 'SUPPLIER' )
                                                                  ( fieldname = 'CREATIONDATE_1' )
                                                                  ( fieldname = 'CREATIONDATE_2' )
                                                                  ( fieldname = 'PLUSDAY' )
                                                                  ( fieldname = 'ZTYPE1' )
                                                                  ( fieldname = 'ZTYPE2' ) )
                                 CHANGING  ct_data     = lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    "Sort
    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                               CHANGING  ct_data  = lt_data ).

    " Paging
    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                              CHANGING  ct_data   = lt_data ).

    io_response->set_data( lt_data ).

  ENDMETHOD.
ENDCLASS.
