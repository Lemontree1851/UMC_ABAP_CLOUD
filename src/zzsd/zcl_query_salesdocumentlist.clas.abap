CLASS zcl_query_salesdocumentlist DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_QUERY_SALESDOCUMENTLIST IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TYPES:
      BEGIN OF ty_finalproductinfo,
        highlevelmaterial            TYPE matnr,
        plant                        TYPE werks_d,
        billofmaterialcomponent      TYPE matnr,
        material                     TYPE matnr,
        validitystartdate            TYPE matnr,
        billofmaterialitemnumber     TYPE n LENGTH 4,
        billofmaterialitemquantity   TYPE i_billofmaterialitemdex_3-billofmaterialitemquantity,
        billofmaterialitemunit       TYPE meins,
        billofmaterialvariant        TYPE i_materialbomlink-billofmaterialvariant,
        billofmaterial               TYPE i_materialbomlink-billofmaterial,
        billofmaterialitemnodenumber TYPE i_billofmaterialitemdex_3-billofmaterialitemnodenumber,
        billofmaterialcategory       TYPE i_materialbomlink-billofmaterialcategory,
      END OF ty_finalproductinfo.

    DATA:
      lt_data                    TYPE STANDARD TABLE OF zc_salesdocumentlist,
      lr_user_salesorg           TYPE RANGE OF zc_salesdocumentlist-salesorganization,
*      lr_salesorganization       TYPE RANGE OF zc_salesdocumentlist-salesorganization,
*      lr_salesdocument           TYPE RANGE OF zc_salesdocumentlist-salesdocument,
*      lr_soldtoparty             TYPE RANGE OF zc_salesdocumentlist-soldtoparty,
*      lr_salesdocumenttype       TYPE RANGE OF zc_salesdocumentlist-salesdocumenttype,
*      lr_salesdocapprovalstatus  TYPE RANGE OF zc_salesdocumentlist-salesdocapprovalstatus,
*      lr_yy1_salesdoctype_sdh    TYPE RANGE OF zc_salesdocumentlist-yy1_salesdoctype_sdh,
*      lr_purchaseorderbycustomer TYPE RANGE OF zc_salesdocumentlist-purchaseorderbycustomer,
*      lr_product                 TYPE RANGE OF zc_salesdocumentlist-product,
*      lr_plant                   TYPE RANGE OF zc_salesdocumentlist-plant,
*      lr_requesteddeliverydate   TYPE RANGE OF zc_salesdocumentlist-requesteddeliverydate,
*      lr_salesdocumentdate       TYPE RANGE OF zc_salesdocumentlist-salesdocumentdate,
*      lr_confirmeddeliverydate   TYPE RANGE OF zc_salesdocumentlist-confirmeddeliverydate,
*      lr_creationdateitem        TYPE RANGE OF zc_salesdocumentlist-creationdateitem,
      lr_salesdocumentrjcnreason TYPE RANGE OF zc_salesdocumentlist-salesdocumentrjcnreason,
      lr_deliverystatus          TYPE RANGE OF i_salesdocumentitem-deliverystatus,
      lr_relatedbillingstatus    TYPE RANGE OF i_deliverydocumentitem-deliveryrelatedbillingstatus,
      lr_conditiontype           TYPE RANGE OF i_salesdocitempricingelement-conditiontype,
*      ls_salesorganization       LIKE LINE OF lr_salesorganization,
*      ls_salesdocument           LIKE LINE OF lr_salesdocument,
*      ls_soldtoparty             LIKE LINE OF lr_soldtoparty,
*      ls_salesdocumenttype       LIKE LINE OF lr_salesdocumenttype,
*      ls_salesdocapprovalstatus  LIKE LINE OF lr_salesdocapprovalstatus,
*      ls_yy1_salesdoctype_sdh    LIKE LINE OF lr_yy1_salesdoctype_sdh,
*      ls_purchaseorderbycustomer LIKE LINE OF lr_purchaseorderbycustomer,
*      ls_product                 LIKE LINE OF lr_product,
*      ls_plant                   LIKE LINE OF lr_plant,
*      ls_requesteddeliverydate   LIKE LINE OF lr_requesteddeliverydate,
*      ls_salesdocumentdate       LIKE LINE OF lr_salesdocumentdate,
*      ls_confirmeddeliverydate   LIKE LINE OF lr_confirmeddeliverydate,
*      ls_creationdateitem        LIKE LINE OF lr_creationdateitem,
      ls_deliverystatus          LIKE LINE OF lr_deliverystatus,
      ls_conditiontype           LIKE LINE OF lr_conditiontype,
      ls_data                    TYPE zc_salesdocumentlist,
      lv_user_email              TYPE i_workplaceaddress-defaultemailaddress,
      lv_actualdelqtyinbaseunit  TYPE i_deliverydocumentitem-actualdeliveredqtyinbaseunit,
      lv_billingqtyinbaseunit    TYPE i_billingdocumentitem-billingquantityinbaseunit,
      lv_indicator1              TYPE abap_boolean,
      lv_indicator2              TYPE abap_boolean,
      lv_indicator3              TYPE abap_boolean,
      lv_indicator4              TYPE abap_boolean,
      lv_indicator5              TYPE abap_boolean,
      lv_indicator6              TYPE abap_boolean,
      lv_value                   TYPE string.

    CONSTANTS:
      BEGIN OF lsc_conditiontype,
        ppr0 TYPE kscha VALUE 'PPR0',
        ttx1 TYPE kscha VALUE 'TTX1',
        zpfc TYPE kschl VALUE 'ZPFC',
        zpst TYPE kschl VALUE 'ZPST',
        zpin TYPE kschl VALUE 'ZPIN',
        zpsb TYPE kschl VALUE 'ZPSB',
        zpss TYPE kschl VALUE 'ZPSS',
        zpcm TYPE kschl VALUE 'ZPCM',
        zpgp TYPE kschl VALUE 'ZPGP',
      END OF lsc_conditiontype,

      BEGIN OF lsc_status,
        a    TYPE string VALUE 'A',
        b    TYPE string VALUE 'B',
        c    TYPE string VALUE 'C',
        hash TYPE string VALUE '#',
      END OF lsc_status,

      BEGIN OF lsc_partner,
        soldtoparty TYPE string VALUE 'AG', "'SP'
        billtoparty TYPE string VALUE 'RE', "'BP'
        shiptoparty TYPE string VALUE 'WE', "'SH'
      END OF lsc_partner,

      BEGIN OF lsc_gmtype,
        b101 TYPE bwart VALUE '101',
        b601 TYPE bwart VALUE '601',
        b687 TYPE bwart VALUE '687',
      END OF lsc_gmtype,

      BEGIN OF lsc_debitcreditcode,
        s TYPE shkzg VALUE 'S',
        h TYPE bwart VALUE 'H',
      END OF lsc_debitcreditcode,

      lc_sign_i         TYPE string VALUE 'I',
      lc_option_eq      TYPE string VALUE 'EQ',
      lc_gmstatus_c     TYPE string VALUE 'C',
      lc_profilecode_z5 TYPE string VALUE 'Z5',
      lc_alpha_out      TYPE string VALUE 'OUT',
      lc_symbol_hyphen  TYPE string VALUE '-'.

    TRY.
        "Get and add filter
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option) ##NO_HANDLER.
    ENDTRY.

*&--MOD BEGIN BY XINLEI XU 2025/03/06 BUG Fix
*    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
*      LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
*        CASE ls_filter_cond-name.
*          WHEN 'USEREMAIL'.
*            lv_user_email = str_rec_l_range-low.
*          WHEN 'SALESORGANIZATION'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_salesorganization.
*            APPEND ls_salesorganization TO lr_salesorganization.
*            CLEAR ls_salesorganization.
*          WHEN 'SALESDOCUMENT'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_salesdocument.
*            APPEND ls_salesdocument TO lr_salesdocument.
*            CLEAR ls_salesdocument.
*          WHEN 'SOLDTOPARTY'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_soldtoparty.
*            APPEND ls_soldtoparty TO lr_soldtoparty.
*            CLEAR ls_soldtoparty.
*          WHEN 'SALESDOCUMENTTYPE'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_salesdocumenttype.
*            APPEND ls_salesdocumenttype TO lr_salesdocumenttype.
*            CLEAR ls_salesdocumenttype.
*          WHEN 'SALESDOCAPPROVALSTATUS'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_salesdocapprovalstatus.
*            APPEND ls_salesdocapprovalstatus TO lr_salesdocapprovalstatus.
*            CLEAR ls_salesdocapprovalstatus.
*          WHEN 'YY1_SALESDOCTYPE_SDH'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_yy1_salesdoctype_sdh.
*            APPEND ls_yy1_salesdoctype_sdh TO lr_yy1_salesdoctype_sdh.
*            CLEAR ls_yy1_salesdoctype_sdh.
*          WHEN 'PURCHASEORDERBYCUSTOMER'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_purchaseorderbycustomer.
*            APPEND ls_purchaseorderbycustomer TO lr_purchaseorderbycustomer.
*            CLEAR ls_purchaseorderbycustomer.
*          WHEN 'PRODUCT'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_product.
*            APPEND ls_product TO lr_product.
*            CLEAR ls_product.
*          WHEN 'PLANT'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_plant.
*            APPEND ls_plant TO lr_plant.
*            CLEAR ls_plant.
*          WHEN 'REQUESTEDDELIVERYDATE'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_requesteddeliverydate.
*            APPEND ls_requesteddeliverydate TO lr_requesteddeliverydate.
*            CLEAR ls_requesteddeliverydate.
*          WHEN 'SALESDOCUMENTDATE'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_salesdocumentdate.
*            APPEND ls_salesdocumentdate TO lr_salesdocumentdate.
*            CLEAR ls_salesdocumentdate.
*          WHEN 'CONFIRMEDDELIVERYDATE'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_confirmeddeliverydate.
*            APPEND ls_confirmeddeliverydate TO lr_confirmeddeliverydate.
*            CLEAR ls_confirmeddeliverydate.
*          WHEN 'CREATIONDATEITEM'.
*            MOVE-CORRESPONDING str_rec_l_range TO ls_creationdateitem.
*            APPEND ls_creationdateitem TO lr_creationdateitem.
*            CLEAR ls_creationdateitem.
*          WHEN 'INDICATOR1'.
*            lv_indicator1 = str_rec_l_range-low.
*          WHEN 'INDICATOR2'.
*            lv_indicator2 = str_rec_l_range-low.
*          WHEN 'INDICATOR3'.
*            lv_indicator3 = str_rec_l_range-low.
*          WHEN 'INDICATOR4'.
*            lv_indicator4 = str_rec_l_range-low.
*          WHEN 'INDICATOR5'.
*            lv_indicator5 = str_rec_l_range-low.
*          WHEN 'INDICATOR6'.
*            lv_indicator6 = str_rec_l_range-low.
*          WHEN OTHERS.
*        ENDCASE.
*      ENDLOOP.
*    ENDLOOP.
    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
      CASE ls_filter_cond-name.
        WHEN 'SALESORGANIZATION'.
          DATA(lr_salesorganization) = ls_filter_cond-range.
        WHEN 'SALESDOCUMENT'.
          DATA(lr_salesdocument) = ls_filter_cond-range.
        WHEN 'SOLDTOPARTY'.
          DATA(lr_soldtoparty) = ls_filter_cond-range.
        WHEN 'SALESDOCUMENTTYPE'.
          DATA(lr_salesdocumenttype) = ls_filter_cond-range.
        WHEN 'SALESDOCAPPROVALSTATUS'.
          DATA(lr_salesdocapprovalstatus) = ls_filter_cond-range.
        WHEN 'YY1_SALESDOCTYPE_SDH'.
          DATA(lr_yy1_salesdoctype_sdh) = ls_filter_cond-range.
        WHEN 'PURCHASEORDERBYCUSTOMER'.
          DATA(lr_purchaseorderbycustomer) = ls_filter_cond-range.
        WHEN 'PRODUCT'.
          DATA(lr_product) = ls_filter_cond-range.
        WHEN 'PLANT'.
          DATA(lr_plant) = ls_filter_cond-range.
        WHEN 'REQUESTEDDELIVERYDATE'.
          DATA(lr_requesteddeliverydate) = ls_filter_cond-range.
        WHEN 'SALESDOCUMENTDATE'.
          DATA(lr_salesdocumentdate) = ls_filter_cond-range.
        WHEN 'CONFIRMEDDELIVERYDATE'.
          DATA(lr_confirmeddeliverydate) = ls_filter_cond-range.
        WHEN 'CREATIONDATEITEM'.
          DATA(lr_creationdateitem) = ls_filter_cond-range.
        WHEN 'USEREMAIL'.
          lv_user_email = ls_filter_cond-range[ 1 ]-low.
        WHEN 'INDICATOR1'.
          lv_indicator1 = ls_filter_cond-range[ 1 ]-low.
        WHEN 'INDICATOR2'.
          lv_indicator2 = ls_filter_cond-range[ 1 ]-low.
        WHEN 'INDICATOR3'.
          lv_indicator3 = ls_filter_cond-range[ 1 ]-low.
        WHEN 'INDICATOR4'.
          lv_indicator4 = ls_filter_cond-range[ 1 ]-low.
        WHEN 'INDICATOR5'.
          lv_indicator5 = ls_filter_cond-range[ 1 ]-low.
        WHEN 'INDICATOR6'.
          lv_indicator6 = ls_filter_cond-range[ 1 ]-low.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
*&--MOD END BY XINLEI XU 2025/03/06 BUG Fix

    DATA(lv_user_salesorg) = zzcl_common_utils=>get_salesorg_by_user( lv_user_email ).
    SPLIT lv_user_salesorg AT '&' INTO TABLE DATA(lt_user_salesorg).
    lr_user_salesorg = VALUE #( FOR salesorg IN lt_user_salesorg ( sign = 'I' option = 'EQ' low = salesorg ) ).

    IF lr_user_salesorg IS NOT INITIAL.
      IF lr_salesorganization IS INITIAL.
        lr_salesorganization = CORRESPONDING #( lr_user_salesorg ).
      ELSE.
        LOOP AT lr_salesorganization ASSIGNING FIELD-SYMBOL(<fs_salesorganization>).
          IF <fs_salesorganization>-low NOT IN lr_user_salesorg.
            CLEAR <fs_salesorganization>-low.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSE.
      lr_salesorganization = VALUE #( sign = 'I' option = 'EQ' ( low = '' ) ).
    ENDIF.

    IF lv_indicator1 = abap_true.
      IF lv_indicator2 = abap_true.
        lr_deliverystatus = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lsc_status-b ) ).
      ELSE.
        lr_deliverystatus = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lsc_status-a )
                                   ( low = lsc_status-b ) ( low = lsc_status-hash ) ).
      ENDIF.
    ELSE.
      IF lv_indicator2 = abap_true.
        lr_deliverystatus = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lsc_status-b )
                                   ( low = lsc_status-c ) ).
      ENDIF.
    ENDIF.

    IF lv_indicator4 = abap_true.
      lr_relatedbillingstatus = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lsc_status-a )
                                       ( low = lsc_status-b ) ( low = lsc_status-hash ) ).
    ENDIF.

    IF lv_indicator6 = abap_false.
      lr_salesdocumentrjcnreason = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = space ) ).
    ENDIF.

    "Obtain data of sales document item
    SELECT a~salesdocument,
           a~salesorganization,
           a~salesdocumenttype,
           d~salesdocumenttypename,
           a~salesdocapprovalstatus,
           e~salesdocapprovalstatusdesc,
           a~purchaseorderbycustomer,
           a~incotermsclassification,
           a~incotermslocation1,
           a~soldtoparty,
           i~businesspartnerfullname AS soldtopartyname,
           i~searchterm1 AS soldtopartysearchterm1,
           i~searchterm2 AS soldtopartysearchterm2,
           g~customer AS billtoparty,
           j~businesspartnerfullname AS billtopartyname,
           j~searchterm1 AS billtopartysearchterm1,
           j~searchterm2 AS billtopartysearchterm2,
           h~customer AS shiptoparty,
           k~businesspartnerfullname AS shiptopartyname,
           k~searchterm1 AS shiptopartysearchterm1,
           k~searchterm2 AS shiptopartysearchterm2,
           b~salesdocumentitem,
           b~product,
           b~salesdocumentitemtext,
           b~materialbycustomer,
           b~purchaseorderbycustomer AS purchaseorderbycustomeritem,
           b~underlyingpurchaseorderitem,
           CASE WHEN b~orderquantity <> 0 THEN b~orderquantity ELSE b~targetquantity END AS orderquantity,
           b~orderquantityunit,
           b~baseunit,
           b~plant,
           b~yy1_customerlotno_sdi,
           b~purchaseorderbyshiptoparty,
           b~profitcenter,
           b~controllingarea,
           a~customerpaymentterms,
           l~paymenttermsname,
           a~transactioncurrency,
           b~pricedetnexchangerate,
           b~exchangeratedate,
           b~yy1_itemremarks_1_sdi,
           a~creationdate,
           b~creationdate AS creationdateitem,
           b~lastchangedate,
           b~createdbyuser,
           b~salesdocumentrjcnreason,
           n~salesdocumentrjcnreasonname,
           a~yy1_salesdoctype_sdh,
           b~yy1_managementno_sdi,
           b~yy1_managementno_1_sdi,
           b~yy1_managementno_2_sdi,
           b~yy1_managementno_3_sdi,

           b~orderrelatedbillingstatus,
           b~requestedquantityinbaseunit,
           b~transitplant
      FROM i_salesdocument WITH PRIVILEGED ACCESS AS a
     INNER JOIN i_salesdocumentitem WITH PRIVILEGED ACCESS AS b
        ON b~salesdocument = a~salesdocument
      LEFT OUTER JOIN i_salesdocumenttypetext WITH PRIVILEGED ACCESS AS d
        ON d~salesdocumenttype = a~salesdocumenttype
       AND d~language = @sy-langu
      LEFT OUTER JOIN i_salesdocapprovalstatust WITH PRIVILEGED ACCESS AS e
        ON e~salesdocapprovalstatus = a~salesdocapprovalstatus
       AND e~language = @sy-langu
      LEFT OUTER JOIN i_salesdocumentpartner WITH PRIVILEGED ACCESS AS f
        ON f~salesdocument = a~salesdocument
       AND f~partnerfunction = @lsc_partner-soldtoparty
      LEFT OUTER JOIN i_salesdocumentpartner WITH PRIVILEGED ACCESS AS g
        ON g~salesdocument = a~salesdocument
       AND g~partnerfunction = @lsc_partner-billtoparty
      LEFT OUTER JOIN i_salesdocumentpartner WITH PRIVILEGED ACCESS AS h
        ON h~salesdocument = a~salesdocument
       AND h~partnerfunction = @lsc_partner-shiptoparty
      LEFT OUTER JOIN i_businesspartner WITH PRIVILEGED ACCESS AS i
        ON i~businesspartner = f~customer
      LEFT OUTER JOIN i_businesspartner WITH PRIVILEGED ACCESS AS j
        ON j~businesspartner = g~customer
      LEFT OUTER JOIN i_businesspartner WITH PRIVILEGED ACCESS AS k
        ON k~businesspartner = h~customer
      LEFT OUTER JOIN i_paymenttermstext WITH PRIVILEGED ACCESS AS l
        ON l~paymentterms = a~customerpaymentterms
       AND l~language = @sy-langu
      LEFT OUTER JOIN i_salesdocumentrjcnreasontext WITH PRIVILEGED ACCESS AS n
        ON n~salesdocumentrjcnreason = b~salesdocumentrjcnreason
       AND n~language = @sy-langu
     WHERE a~salesdocument IN @lr_salesdocument
       AND a~salesorganization IN @lr_salesorganization
       AND a~soldtoparty IN @lr_soldtoparty
       AND a~salesdocumenttype IN @lr_salesdocumenttype
       AND a~salesdocapprovalstatus IN @lr_salesdocapprovalstatus
       AND a~yy1_salesdoctype_sdh IN @lr_yy1_salesdoctype_sdh
       AND a~purchaseorderbycustomer IN @lr_purchaseorderbycustomer
       AND a~salesdocumentdate IN @lr_salesdocumentdate
       AND b~requesteddeliverydate IN @lr_requesteddeliverydate
       AND b~product IN @lr_product
       AND b~plant IN @lr_plant
       AND b~creationdate IN @lr_creationdateitem
       AND b~salesdocumentrjcnreason IN @lr_salesdocumentrjcnreason
       AND b~deliverystatus IN @lr_deliverystatus
      INTO TABLE @DATA(lt_salesdocumentitem).
    IF sy-subrc = 0.
      "Obtain data of sales document schedule line
      SELECT a~salesdocument,
             a~salesdocumentitem,
             a~scheduleline,
             a~isconfirmeddelivschedline,
             a~schedulelinecategory,
             a~deliverydate,
             a~confirmeddeliverydate,
             a~deliveredqtyinorderqtyunit,
             a~openconfddelivqtyinordqtyunit,
             b~schedulelinecategoryname
        FROM i_salesdocumentscheduleline WITH PRIVILEGED ACCESS AS a
        LEFT OUTER JOIN i_schedulelinecategorytext WITH PRIVILEGED ACCESS AS b
          ON b~schedulelinecategory = a~schedulelinecategory
         AND b~language = @sy-langu
         FOR ALL ENTRIES IN @lt_salesdocumentitem
       WHERE a~salesdocument = @lt_salesdocumentitem-salesdocument
         AND a~salesdocumentitem = @lt_salesdocumentitem-salesdocumentitem
         AND a~isconfirmeddelivschedline = @abap_true
        INTO TABLE @DATA(lt_salesdocumentscheduleline). "#EC CI_NO_TRANSFORM

      DATA(lt_salesdocumentitem_tmp) = lt_salesdocumentitem.
      SORT lt_salesdocumentitem_tmp BY controllingarea profitcenter.
      DELETE ADJACENT DUPLICATES FROM lt_salesdocumentitem_tmp
                            COMPARING controllingarea profitcenter.

      "Obtain data of profit center text
      SELECT controllingarea,
             profitcenter,
             profitcenterlongname
        FROM i_profitcentertext WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_salesdocumentitem_tmp
       WHERE controllingarea = @lt_salesdocumentitem_tmp-controllingarea
         AND profitcenter = @lt_salesdocumentitem_tmp-profitcenter
         AND language = @sy-langu
        INTO TABLE @DATA(lt_profitcentertext).

      lr_conditiontype = VALUE #( sign = lc_sign_i option = lc_option_eq
                              ( low = lsc_conditiontype-ppr0 ) ( low = lsc_conditiontype-ttx1 ) ( low = lsc_conditiontype-zpfc )
                              ( low = lsc_conditiontype-zpst ) ( low = lsc_conditiontype-zpin ) ( low = lsc_conditiontype-zpsb )
                              ( low = lsc_conditiontype-zpss ) ( low = lsc_conditiontype-zpcm ) ( low = lsc_conditiontype-zpgp ) ).

      "Obtain data of pricing element
      SELECT salesdocument,
             salesdocumentitem,
             conditiontype,
             conditionratevalue,
             conditionamount,
             conditionquantity,
             conditioncurrency
        FROM i_salesdocitempricingelement WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_salesdocumentitem
       WHERE salesdocument = @lt_salesdocumentitem-salesdocument
         AND salesdocumentitem = @lt_salesdocumentitem-salesdocumentitem
         AND conditioninactivereason = @space
         AND conditiontype IN @lr_conditiontype
        INTO TABLE @DATA(lt_salesdocitempricingelement). "#EC CI_NO_TRANSFORM

      "Obtain data of delivery document item
      SELECT a~deliverydocument,
             a~deliverydocumentitem,
             a~referencesddocument,
             a~referencesddocumentitem,
             a~goodsmovementstatus,
             a~goodsmovementtype,
             a~actualdeliveredqtyinbaseunit,
             a~deliveryrelatedbillingstatus,
             b~intcoextplndtransfofctrldtetme
        FROM i_deliverydocumentitem WITH PRIVILEGED ACCESS AS a
       INNER JOIN i_deliverydocument WITH PRIVILEGED ACCESS AS b
          ON b~deliverydocument = a~deliverydocument
         FOR ALL ENTRIES IN @lt_salesdocumentitem
       WHERE a~referencesddocument = @lt_salesdocumentitem-salesdocument
         AND a~referencesddocumentitem = @lt_salesdocumentitem-salesdocumentitem
        INTO TABLE @DATA(lt_deliverydocumentitem). "#EC CI_NO_TRANSFORM
      IF sy-subrc = 0.
        "Obtain data of billing document item(DN billing)
        SELECT a~billingdocument,
               a~billingdocumentitem,
               a~referencesddocument,
               a~referencesddocumentitem,
               a~billingquantityinbaseunit
          FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS a
         INNER JOIN i_billingdocument WITH PRIVILEGED ACCESS AS b
            ON b~billingdocument = a~billingdocument
           FOR ALL ENTRIES IN @lt_deliverydocumentitem
         WHERE a~referencesddocument = @lt_deliverydocumentitem-deliverydocument
           AND a~referencesddocumentitem = @lt_deliverydocumentitem-deliverydocumentitem
           AND b~billingdocumentiscancelled = @abap_false
           AND b~cancelledbillingdocument = @abap_false
          INTO TABLE @DATA(lt_billingdocumentitem_dn). "#EC CI_NO_TRANSFORM

        "Obtain data of material document item
        SELECT a~materialdocumentyear,
               a~materialdocument,
               a~materialdocumentitem,
               a~goodsmovementtype,
               a~debitcreditcode,
               a~deliverydocument,
               a~deliverydocumentitem
          FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS a
           FOR ALL ENTRIES IN @lt_deliverydocumentitem
         WHERE a~deliverydocument = @lt_deliverydocumentitem-deliverydocument
           AND a~deliverydocumentitem = @lt_deliverydocumentitem-deliverydocumentitem
           AND ( ( a~goodsmovementtype = @lsc_gmtype-b101 AND a~debitcreditcode = @lsc_debitcreditcode-s )
              OR ( a~goodsmovementtype IN (@lsc_gmtype-b601,@lsc_gmtype-b687) AND a~debitcreditcode = @lsc_debitcreditcode-h ) )
           AND NOT EXISTS ( SELECT materialdocument FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
                             WHERE reversedmaterialdocumentyear = a~materialdocumentyear
                               AND reversedmaterialdocument = a~materialdocument
                               AND reversedmaterialdocumentitem = a~materialdocumentitem )
          INTO TABLE @DATA(lt_materialdocumentitem). "#EC CI_NO_TRANSFORM
      ENDIF.

      "Obtain data of billing document item(SO billing)
      SELECT a~billingdocument,
             a~billingdocumentitem,
             a~salesdocument,
             a~salesdocumentitem,
             a~billingquantityinbaseunit
        FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS a
       INNER JOIN i_billingdocument WITH PRIVILEGED ACCESS AS b
          ON b~billingdocument = a~billingdocument
         FOR ALL ENTRIES IN @lt_salesdocumentitem
       WHERE a~salesdocument = @lt_salesdocumentitem-salesdocument
         AND a~salesdocumentitem = @lt_salesdocumentitem-salesdocumentitem
         AND b~billingdocumentiscancelled = @abap_false
         AND b~cancelledbillingdocument = @abap_false
        INTO TABLE @DATA(lt_billingdocumentitem_so). "#EC CI_NO_TRANSFORM
    ENDIF.

    DATA(lt_deliverydocumentitem_bs) = lt_deliverydocumentitem.

    SORT lt_salesdocumentitem BY salesdocument salesdocumentitem.
    SORT lt_salesdocumentscheduleline BY salesdocument salesdocumentitem deliverydate.
    SORT lt_profitcentertext BY controllingarea profitcenter.
    SORT lt_salesdocitempricingelement BY salesdocument salesdocumentitem conditiontype.
    SORT lt_deliverydocumentitem BY referencesddocument referencesddocumentitem goodsmovementstatus goodsmovementtype.
    SORT lt_deliverydocumentitem_bs BY referencesddocument referencesddocumentitem deliveryrelatedbillingstatus.
    SORT lt_billingdocumentitem_dn BY referencesddocument referencesddocumentitem.
    SORT lt_billingdocumentitem_so BY salesdocument salesdocumentitem.
    SORT lt_materialdocumentitem BY deliverydocument deliverydocumentitem goodsmovementtype debitcreditcode.

    LOOP AT lt_salesdocumentitem INTO DATA(ls_salesdocumentitem).
      CLEAR ls_data.

      "DN未出庫
      IF lv_indicator2 = abap_true.
        "Read data of delivery document item
        READ TABLE lt_deliverydocumentitem TRANSPORTING NO FIELDS WITH KEY referencesddocument = ls_salesdocumentitem-salesdocument
                                                                           referencesddocumentitem = ls_salesdocumentitem-salesdocumentitem
                                                                           goodsmovementstatus = lsc_status-a
                                                                  BINARY SEARCH.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
      ENDIF.

      "外部移転未記載
      IF lv_indicator3 = abap_true.
        "Read data of delivery document item
        READ TABLE lt_deliverydocumentitem TRANSPORTING NO FIELDS WITH KEY referencesddocument = ls_salesdocumentitem-salesdocument
                                                                           referencesddocumentitem = ls_salesdocumentitem-salesdocumentitem
                                                                           goodsmovementstatus = lsc_status-c
                                                                           goodsmovementtype = lsc_gmtype-b687
                                                                  BINARY SEARCH.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
      ENDIF.

      "未請求
      IF lv_indicator4 = abap_true.
        IF ls_salesdocumentitem-orderrelatedbillingstatus NOT IN lr_relatedbillingstatus.
          "Read data of delivery document item
          READ TABLE lt_deliverydocumentitem INTO DATA(ls_deliverydocumentitem) WITH KEY referencesddocument = ls_salesdocumentitem-salesdocument
                                                                                         referencesddocumentitem = ls_salesdocumentitem-salesdocumentitem
                                                                                         goodsmovementstatus = lsc_status-c
                                                                                         goodsmovementtype = lsc_gmtype-b601
                                                                                BINARY SEARCH.
          IF sy-subrc = 0.
            IF ls_deliverydocumentitem-deliveryrelatedbillingstatus NOT IN lr_relatedbillingstatus.
              CONTINUE.
            ENDIF.
          ELSE.
            "Read data of delivery document item
            READ TABLE lt_deliverydocumentitem INTO ls_deliverydocumentitem WITH KEY referencesddocument = ls_salesdocumentitem-salesdocument
                                                                                     referencesddocumentitem = ls_salesdocumentitem-salesdocumentitem
                                                                                     goodsmovementstatus = lsc_status-c
                                                                                     goodsmovementtype = lsc_gmtype-b687
                                                                            BINARY SEARCH.
            IF sy-subrc = 0.
              IF ls_deliverydocumentitem-deliveryrelatedbillingstatus NOT IN lr_relatedbillingstatus.
                CONTINUE.
              ENDIF.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      "請求済
      IF lv_indicator5 = abap_true AND ls_salesdocumentitem-orderrelatedbillingstatus <> lsc_status-c.
        "Read data of delivery document item
        READ TABLE lt_deliverydocumentitem_bs TRANSPORTING NO FIELDS WITH KEY referencesddocument = ls_salesdocumentitem-salesdocument
                                                                              referencesddocumentitem = ls_salesdocumentitem-salesdocumentitem
                                                                              deliveryrelatedbillingstatus = lsc_status-c
                                                                     BINARY SEARCH.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING ls_salesdocumentitem TO ls_data.

      IF ls_salesdocumentitem-transitplant IS INITIAL.
        ls_data-internaltansferqtyinbaseunit   = lc_symbol_hyphen.
        ls_data-nointernaltansferqtyinbaseunit = lc_symbol_hyphen.
      ENDIF.

      "Read data of sales document schedule line
      READ TABLE lt_salesdocumentscheduleline INTO DATA(ls_salesdocumentscheduleline) WITH KEY salesdocument = ls_salesdocumentitem-salesdocument
                                                                                               salesdocumentitem = ls_salesdocumentitem-salesdocumentitem
                                                                                      BINARY SEARCH.
      IF sy-subrc = 0.
        "Minimum delivery date schedule line
        ls_data-scheduleline               = |{ ls_salesdocumentscheduleline-scheduleline ALPHA = OUT }|.
        ls_data-isconfirmeddelivschedline  = ls_salesdocumentscheduleline-isconfirmeddelivschedline.
        ls_data-schedulelinecategory       = ls_salesdocumentscheduleline-schedulelinecategory.
        ls_data-deliverydate               = ls_salesdocumentscheduleline-deliverydate.
        ls_data-confirmeddeliverydate      = ls_salesdocumentscheduleline-confirmeddeliverydate.
        ls_data-deliveredqtyinorderqtyunit = ls_salesdocumentscheduleline-deliveredqtyinorderqtyunit.
        ls_data-schedulelinecategoryname   = ls_salesdocumentscheduleline-schedulelinecategoryname.
        CONDENSE ls_data-scheduleline.

        LOOP AT lt_salesdocumentscheduleline INTO ls_salesdocumentscheduleline FROM sy-tabix.
          IF ls_salesdocumentscheduleline-salesdocument <> ls_salesdocumentitem-salesdocument
          OR ls_salesdocumentscheduleline-salesdocumentitem <> ls_salesdocumentitem-salesdocumentitem.
            EXIT.
          ENDIF.

          ls_data-openconfddelivqtyinordqtyunit = ls_data-openconfddelivqtyinordqtyunit + ls_salesdocumentscheduleline-openconfddelivqtyinordqtyunit.
        ENDLOOP.
      ENDIF.

      "Read data of profit center text
      READ TABLE lt_profitcentertext INTO DATA(ls_profitcentertext) WITH KEY controllingarea = ls_salesdocumentitem-controllingarea
                                                                             profitcenter = ls_salesdocumentitem-profitcenter
                                                                    BINARY SEARCH.
      IF sy-subrc = 0.
        ls_data-profitcenterlongname = ls_profitcentertext-profitcenterlongname.
      ENDIF.

      "Read data of profit center text
      READ TABLE lt_salesdocitempricingelement TRANSPORTING NO FIELDS WITH KEY salesdocument = ls_salesdocumentitem-salesdocument
                                                                               salesdocumentitem = ls_salesdocumentitem-salesdocumentitem
                                                                      BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_salesdocitempricingelement INTO DATA(ls_salesdocitempricingelement) FROM sy-tabix.
          IF ls_salesdocitempricingelement-salesdocument <> ls_salesdocumentitem-salesdocument
          OR ls_salesdocitempricingelement-salesdocumentitem <> ls_salesdocumentitem-salesdocumentitem.
            EXIT.
          ENDIF.

          CASE ls_salesdocitempricingelement-conditiontype.
            WHEN lsc_conditiontype-ppr0.
              IF ls_salesdocitempricingelement-conditionquantity <> 0.
                ls_data-conditionratevalueppr0 = ls_salesdocitempricingelement-conditionratevalue
                                               / ls_salesdocitempricingelement-conditionquantity.
              ELSE.
                ls_data-conditionratevalueppr0 = ls_salesdocitempricingelement-conditionratevalue.
              ENDIF.

              ls_data-conditioncurrencyppr0 = ls_salesdocitempricingelement-conditioncurrency.
              ls_data-conditionamountppr0   = ls_salesdocitempricingelement-conditionamount.
            WHEN lsc_conditiontype-ttx1.
              ls_data-conditionratevaluettx1 = ls_salesdocitempricingelement-conditionratevalue.
              ls_data-conditionamountttx1    = ls_salesdocitempricingelement-conditionamount.
            WHEN lsc_conditiontype-zpfc.
              IF ls_salesdocitempricingelement-conditionquantity <> 0.
                ls_data-conditionratevaluezpfc = ls_salesdocitempricingelement-conditionratevalue
                                               / ls_salesdocitempricingelement-conditionquantity.
              ELSE.
                ls_data-conditionratevaluezpfc = ls_salesdocitempricingelement-conditionratevalue.
              ENDIF.

              ls_data-conditioncurrencyzpfc = ls_salesdocitempricingelement-conditioncurrency.
              ls_data-conditionamountzpfc   = ls_salesdocitempricingelement-conditionamount.
            WHEN lsc_conditiontype-zpst.
              IF ls_salesdocitempricingelement-conditionquantity <> 0.
                ls_data-conditionratevaluezpst = ls_salesdocitempricingelement-conditionratevalue
                                               / ls_salesdocitempricingelement-conditionquantity.
              ELSE.
                ls_data-conditionratevaluezpst = ls_salesdocitempricingelement-conditionratevalue.
              ENDIF.

              ls_data-conditioncurrencyzpst = ls_salesdocitempricingelement-conditioncurrency.
              ls_data-conditionamountzpst   = ls_salesdocitempricingelement-conditionamount.
            WHEN lsc_conditiontype-zpin.
              IF ls_salesdocitempricingelement-conditionquantity <> 0.
                ls_data-conditionratevaluezpin = ls_salesdocitempricingelement-conditionratevalue
                                               / ls_salesdocitempricingelement-conditionquantity.
              ELSE.
                ls_data-conditionratevaluezpin = ls_salesdocitempricingelement-conditionratevalue.
              ENDIF.

              ls_data-conditioncurrencyzpin = ls_salesdocitempricingelement-conditioncurrency.
              ls_data-conditionamountzpin   = ls_salesdocitempricingelement-conditionamount.
            WHEN lsc_conditiontype-zpsb.
              IF ls_salesdocitempricingelement-conditionquantity <> 0.
                ls_data-conditionratevaluezpsb = ls_salesdocitempricingelement-conditionratevalue
                                               / ls_salesdocitempricingelement-conditionquantity.
              ELSE.
                ls_data-conditionratevaluezpsb = ls_salesdocitempricingelement-conditionratevalue.
              ENDIF.

              ls_data-conditioncurrencyzpsb = ls_salesdocitempricingelement-conditioncurrency.
              ls_data-conditionamountzpsb   = ls_salesdocitempricingelement-conditionamount.
            WHEN lsc_conditiontype-zpss.
              IF ls_salesdocitempricingelement-conditionquantity <> 0.
                ls_data-conditionratevaluezpss = ls_salesdocitempricingelement-conditionratevalue
                                               / ls_salesdocitempricingelement-conditionquantity.
              ELSE.
                ls_data-conditionratevaluezpss = ls_salesdocitempricingelement-conditionratevalue.
              ENDIF.

              ls_data-conditioncurrencyzpss = ls_salesdocitempricingelement-conditioncurrency.
              ls_data-conditionamountzpss   = ls_salesdocitempricingelement-conditionamount.
            WHEN lsc_conditiontype-zpcm.
              IF ls_salesdocitempricingelement-conditionquantity <> 0.
                ls_data-conditionratevaluezpcm = ls_salesdocitempricingelement-conditionratevalue
                                               / ls_salesdocitempricingelement-conditionquantity.
              ELSE.
                ls_data-conditionratevaluezpcm = ls_salesdocitempricingelement-conditionratevalue.
              ENDIF.

              ls_data-conditioncurrencyzpcm = ls_salesdocitempricingelement-conditioncurrency.
              ls_data-conditionamountzpcm   = ls_salesdocitempricingelement-conditionamount.
            WHEN lsc_conditiontype-zpgp.
              IF ls_salesdocitempricingelement-conditionquantity <> 0.
                ls_data-conditionratevaluezpgp = ls_salesdocitempricingelement-conditionratevalue
                                               / ls_salesdocitempricingelement-conditionquantity.
              ELSE.
                ls_data-conditionratevaluezpgp = ls_salesdocitempricingelement-conditionratevalue.
              ENDIF.

              ls_data-conditioncurrencyzpgp = ls_salesdocitempricingelement-conditioncurrency.
              ls_data-conditionamountzpgp   = ls_salesdocitempricingelement-conditionamount.
          ENDCASE.
        ENDLOOP.
      ENDIF.

*     DN billing
      IF ls_salesdocumentitem-orderrelatedbillingstatus IS INITIAL.
        "Read data of delivery document item
        READ TABLE lt_deliverydocumentitem TRANSPORTING NO FIELDS WITH KEY referencesddocument = ls_salesdocumentitem-salesdocument
                                                                           referencesddocumentitem = ls_salesdocumentitem-salesdocumentitem
                                                                  BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_deliverydocumentitem INTO ls_deliverydocumentitem FROM sy-tabix.
            IF ls_deliverydocumentitem-referencesddocument <> ls_salesdocumentitem-salesdocument
            OR ls_deliverydocumentitem-referencesddocumentitem <> ls_salesdocumentitem-salesdocumentitem.
              EXIT.
            ENDIF.

            IF ls_deliverydocumentitem-goodsmovementstatus = lc_gmstatus_c.
              ls_data-compldeliveredqtyinbaseunit = ls_data-compldeliveredqtyinbaseunit + ls_deliverydocumentitem-actualdeliveredqtyinbaseunit.
            ELSE.
              ls_data-nocompldeliveredqtyinbaseunit = ls_data-nocompldeliveredqtyinbaseunit + ls_deliverydocumentitem-actualdeliveredqtyinbaseunit.
            ENDIF.

            "Read data of billing document item(DN billing)
            READ TABLE lt_billingdocumentitem_dn TRANSPORTING NO FIELDS WITH KEY referencesddocument = ls_deliverydocumentitem-deliverydocument
                                                                                 referencesddocumentitem = ls_deliverydocumentitem-deliverydocumentitem
                                                                        BINARY SEARCH.
            IF sy-subrc = 0.
              LOOP AT lt_billingdocumentitem_dn INTO DATA(ls_billingdocumentitem_dn) FROM sy-tabix.
                IF ls_billingdocumentitem_dn-referencesddocument <> ls_deliverydocumentitem-deliverydocument
                OR ls_billingdocumentitem_dn-referencesddocumentitem <> ls_deliverydocumentitem-deliverydocumentitem.
                  EXIT.
                ENDIF.

                ls_data-billingquantityinbaseunit = ls_data-billingquantityinbaseunit + ls_billingdocumentitem_dn-billingquantityinbaseunit.
                lv_billingqtyinbaseunit = lv_billingqtyinbaseunit + ls_billingdocumentitem_dn-billingquantityinbaseunit.
              ENDLOOP.
            ENDIF.

            IF ls_deliverydocumentitem-goodsmovementtype = lsc_gmtype-b687.
              IF ls_salesdocumentitem-transitplant IS NOT INITIAL.
                TRY.
                    DATA(lv_baseunit) = zzcl_common_utils=>conversion_cunit( iv_alpha = lc_alpha_out
                                                                             iv_input = ls_salesdocumentitem-baseunit ).
                  CATCH zzcx_custom_exception INTO DATA(lo_exc).
                    lv_baseunit = ls_salesdocumentitem-baseunit.
                ENDTRY.

                "Read data of material document item(GoodsMovementType 101)
                READ TABLE lt_materialdocumentitem TRANSPORTING NO FIELDS WITH KEY deliverydocument = ls_deliverydocumentitem-deliverydocument
                                                                                   deliverydocumentitem = ls_deliverydocumentitem-deliverydocumentitem
                                                                                   goodsmovementtype = lsc_gmtype-b101
                                                                                   debitcreditcode = lsc_debitcreditcode-s
                                                                          BINARY SEARCH.
                IF sy-subrc = 0.
                  lv_value = ls_deliverydocumentitem-actualdeliveredqtyinbaseunit.
                  CONDENSE lv_value NO-GAPS.
                  SHIFT lv_value RIGHT DELETING TRAILING '0'.
                  SHIFT lv_value RIGHT DELETING TRAILING '.'. "小数点是.
                  SHIFT lv_value LEFT DELETING LEADING space.

                  CONCATENATE lv_value lv_baseunit INTO ls_data-internaltansferqtyinbaseunit SEPARATED BY space.
                  CONCATENATE '0' lv_baseunit INTO ls_data-nointernaltansferqtyinbaseunit SEPARATED BY space.
                ELSE.
                  lv_value = ls_deliverydocumentitem-actualdeliveredqtyinbaseunit.
                  CONDENSE lv_value NO-GAPS.
                  SHIFT lv_value RIGHT DELETING TRAILING '0'.
                  SHIFT lv_value RIGHT DELETING TRAILING '.'. "小数点是.
                  SHIFT lv_value LEFT DELETING LEADING space.

                  CONCATENATE lv_value lv_baseunit INTO ls_data-nointernaltansferqtyinbaseunit SEPARATED BY space.
                  CONCATENATE '0' lv_baseunit INTO ls_data-internaltansferqtyinbaseunit SEPARATED BY space.
                ENDIF.
              ENDIF.

              IF ls_deliverydocumentitem-intcoextplndtransfofctrldtetme <> 0.
                "Read data of material document item(GoodsMovementType 601)
                READ TABLE lt_materialdocumentitem TRANSPORTING NO FIELDS WITH KEY deliverydocument = ls_deliverydocumentitem-deliverydocument
                                                                                   deliverydocumentitem = ls_deliverydocumentitem-deliverydocumentitem
                                                                                   goodsmovementtype = lsc_gmtype-b601
                                                                                   debitcreditcode = lsc_debitcreditcode-h
                                                                          BINARY SEARCH.
                IF sy-subrc = 0.
                  DATA(lv_flag_b601) = abap_true.
                ENDIF.

                "Read data of material document item(GoodsMovementType 687)
                READ TABLE lt_materialdocumentitem TRANSPORTING NO FIELDS WITH KEY deliverydocument = ls_deliverydocumentitem-deliverydocument
                                                                                   deliverydocumentitem = ls_deliverydocumentitem-deliverydocumentitem
                                                                                   goodsmovementtype = lsc_gmtype-b687
                                                                                   debitcreditcode = lsc_debitcreditcode-h
                                                                          BINARY SEARCH.
                IF sy-subrc = 0.
                  DATA(lv_flag_b687) = abap_true.
                ENDIF.

                IF lv_flag_b601 = abap_true AND lv_flag_b687 = abap_true.
                  lv_value = ls_deliverydocumentitem-actualdeliveredqtyinbaseunit.
                  CONDENSE lv_value NO-GAPS.
                  SHIFT lv_value RIGHT DELETING TRAILING '0'.
                  SHIFT lv_value RIGHT DELETING TRAILING '.'. "小数点是.
                  SHIFT lv_value LEFT DELETING LEADING space.

                  CONCATENATE lv_value lv_baseunit INTO ls_data-externaltansferqtyinbaseunit SEPARATED BY space.
                ENDIF.

                IF ( lv_flag_b601 = abap_false AND lv_flag_b687 = abap_true )
                OR ( lv_flag_b601 = abap_false AND lv_flag_b687 = abap_false ).
                  lv_value = ls_deliverydocumentitem-actualdeliveredqtyinbaseunit.
                  CONDENSE lv_value NO-GAPS.
                  SHIFT lv_value RIGHT DELETING TRAILING '0'.
                  SHIFT lv_value RIGHT DELETING TRAILING '.'. "小数点是.
                  SHIFT lv_value LEFT DELETING LEADING space.

                  CONCATENATE lv_value lv_baseunit INTO ls_data-noexternaltansferqtyinbaseunit SEPARATED BY space.

                  "外部移転未記載
                  IF lv_indicator3 = abap_true.
                    IF lv_flag_b601 = abap_false AND lv_flag_b687 = abap_true.
                      DATA(lv_indicator3_ok) = abap_true.
                    ENDIF.
                  ENDIF.
                ENDIF.

                IF ls_data-externaltansferqtyinbaseunit IS INITIAL.
                  CONCATENATE '0' lv_baseunit INTO ls_data-externaltansferqtyinbaseunit SEPARATED BY space.
                ENDIF.

                IF ls_data-noexternaltansferqtyinbaseunit IS INITIAL.
                  CONCATENATE '0' lv_baseunit INTO ls_data-noexternaltansferqtyinbaseunit SEPARATED BY space.
                ENDIF.

                CLEAR:
                  lv_flag_b601,
                  lv_flag_b687.
              ELSE.
                ls_data-externaltansferqtyinbaseunit   = lc_symbol_hyphen.
                ls_data-noexternaltansferqtyinbaseunit = lc_symbol_hyphen.
              ENDIF.
            ENDIF.

            lv_actualdelqtyinbaseunit = lv_actualdelqtyinbaseunit + ls_deliverydocumentitem-actualdeliveredqtyinbaseunit.
          ENDLOOP.

          "外部移転未記載
          IF lv_indicator3 = abap_true.
            IF lv_indicator3_ok = abap_false.
              CONTINUE.
            ELSE.
              CLEAR lv_indicator3_ok.
            ENDIF.
          ENDIF.

          IF ls_salesdocumentitem-orderrelatedbillingstatus = lsc_status-c.
            ls_data-nobillingquantityinbaseunit = lv_actualdelqtyinbaseunit - lv_billingqtyinbaseunit.
          ELSE.
            ls_data-nobillingquantityinbaseunit = ls_data-openconfddelivqtyinordqtyunit + lv_actualdelqtyinbaseunit - lv_billingqtyinbaseunit.
          ENDIF.

          CLEAR:
            lv_actualdelqtyinbaseunit,
            lv_billingqtyinbaseunit.
        ENDIF.
*     SO billing
      ELSE.
        "Read data of billing document item(SO billing)
        READ TABLE lt_billingdocumentitem_so TRANSPORTING NO FIELDS WITH KEY salesdocument = ls_salesdocumentitem-salesdocument
                                                                             salesdocumentitem = ls_salesdocumentitem-salesdocumentitem
                                                                    BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_billingdocumentitem_so INTO DATA(ls_billingdocumentitem_so) FROM sy-tabix.
            IF ls_billingdocumentitem_so-salesdocument <> ls_salesdocumentitem-salesdocument
            OR ls_billingdocumentitem_so-salesdocumentitem <> ls_salesdocumentitem-salesdocumentitem.
              EXIT.
            ENDIF.

            ls_data-billingquantityinbaseunit = ls_data-billingquantityinbaseunit + ls_billingdocumentitem_so-billingquantityinbaseunit.
            lv_billingqtyinbaseunit = lv_billingqtyinbaseunit + ls_billingdocumentitem_dn-billingquantityinbaseunit.
          ENDLOOP.
        ENDIF.

        IF ls_salesdocumentitem-orderrelatedbillingstatus <> lsc_status-c.
          ls_data-nobillingquantityinbaseunit = ls_salesdocumentitem-requestedquantityinbaseunit - lv_billingqtyinbaseunit.
        ENDIF.

        CLEAR lv_billingqtyinbaseunit.
      ENDIF.

      APPEND ls_data TO lt_data.
    ENDLOOP.

    IF lr_confirmeddeliverydate IS NOT INITIAL.
      DELETE lt_data WHERE confirmeddeliverydate NOT IN lr_confirmeddeliverydate.
    ENDIF.

    "Calculate counts of so and so item
    DATA(lt_data_tmp) = lt_data.
    DELETE ADJACENT DUPLICATES FROM lt_data_tmp COMPARING salesdocument.
    DATA(lv_totalcountso)     = lines( lt_data_tmp ).
    DATA(lv_totalcountsoitem) = lines( lt_data ).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      <fs_data>-totalcountso     = lv_totalcountso.
      <fs_data>-totalcountsoitem = lv_totalcountsoitem.
    ENDLOOP.

    io_response->set_total_number_of_records( lines( lt_data ) ).

    "Sort
    IF io_request->get_sort_elements( ) IS NOT INITIAL.
      zzcl_odata_utils=>orderby(
        EXPORTING
          it_order = io_request->get_sort_elements( )
        CHANGING
          ct_data  = lt_data ).
    ENDIF.

    "Page
    zzcl_odata_utils=>paging(
      EXPORTING
        io_paging = io_request->get_paging( )
      CHANGING
        ct_data   = lt_data ).

    io_response->set_data( lt_data ).
  ENDMETHOD.
ENDCLASS.
