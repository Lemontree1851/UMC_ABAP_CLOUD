CLASS zcl_http_podata_003 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_response,
        purchaseorder                  TYPE c LENGTH  10,
        supplier                       TYPE c LENGTH  10,
        companycode                    type c length  4,
        purchasingdocumentdeletioncode TYPE c LENGTH  1,
        purchaseorderdate              TYPE c LENGTH  8,
        creationdate                   TYPE c LENGTH  8,
        createdbyuser                  TYPE c LENGTH  12,
        lastchangedatetime             TYPE c LENGTH  21,
        purchaseorderitem              TYPE c LENGTH  5,
        documentcurrency               TYPE c LENGTH  5,
        material                       TYPE c LENGTH  18,
        plant                          type c LENGTH  4 ,
        purchaseorderitemtext          TYPE c LENGTH  40,
        orderquantity                  TYPE c LENGTH  13,
        purchaseorderquantityunit      TYPE c LENGTH  3,
        netpricequantity               TYPE c LENGTH  5,
        netamount                      TYPE c LENGTH  16,
        grossamount                    TYPE c LENGTH  16,
        storagelocation                TYPE c LENGTH  4,
        storagelocationname            TYPE c LENGTH  20,
        textobjecttype                 TYPE c LENGTH  4,
        plainlongtext                  TYPE c LENGTH  10,
        schedulelinedeliverydate       TYPE c LENGTH  8,
        SupplierMaterialNumber         type c LENGTH 18,


      END OF ty_response,

      BEGIN OF ty_output,
        items TYPE STANDARD TABLE OF ty_response WITH EMPTY KEY,
      END OF ty_output.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
*          ls_req            TYPE ty_request,
      lv_error(1)       TYPE c,
      lv_text           TYPE string,
      ls_response       TYPE ty_response,
      es_response       TYPE ty_output,
      lc_header_content TYPE string VALUE 'content-type',
      lc_content_type   TYPE string VALUE 'text/json'.

ENDCLASS.



CLASS zcl_http_podata_003 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA:
      lt_polog type TABLE of ztmm_1002,
      lw_polog TYPE ztmm_1002.

    DATA:
      lv_ebeln    TYPE ebeln,
      lr_where    TYPE RANGE OF ebeln,
      lv_dec(11)  TYPE p DECIMALS 7,
      lr_lastdate LIKE RANGE OF lv_dec.

      DATA(lv_sy_datum) = cl_abap_context_info=>get_system_date( ).



      data(lv_predate) = zzcl_common_utils=>calc_date_subtract(
                  EXPORTING
                    date      = lv_sy_datum

                    day       = '1'

                ).

DATA: lv_date       TYPE D,
      lv_time       TYPE T,
      lv_timestampl TYPE TIMESTAMPL.

       lv_date = lv_predate.
       lv_time = '000000'.

       CONVERT DATE lv_date TIME lv_time INTO TIME STAMP lv_timestampl TIME ZONE SY-ZONLO.

        SELECT

           b~purchaseorder,
           b~purchaseorderitem,
           b~documentcurrency,
           b~material,
           b~plant,
           b~purchaseorderitemtext,
           b~orderquantity,
           b~purchaseorderquantityunit,
           b~netpricequantity,
           b~netamount,
           b~grossamount,
           b~storagelocation,
           b~SupplierMaterialNumber,
           c~storagelocationname,
           b~purchasingdocumentdeletioncode,
           a~supplier,
           a~purchaseorderdate,
           a~CompanyCode,
           a~creationdate,
           a~createdbyuser,
           a~lastchangedatetime,
           d~textobjecttype,
           d~plainlongtext,
           e~schedulelinedeliverydate

      FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS AS b
     INNER JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS a
        ON b~purchaseorder = a~purchaseorder
      LEFT JOIN i_storagelocation WITH PRIVILEGED ACCESS AS c
        ON b~storagelocation = c~storagelocation
      LEFT JOIN  i_purchaseorderitemnotetp_2 WITH PRIVILEGED ACCESS AS d
        ON b~purchaseorder = d~purchaseorder
       AND b~purchaseorderitem = d~purchaseorderitem
      LEFT JOIN i_purordschedulelineapi01 WITH PRIVILEGED ACCESS AS e
        ON b~purchaseorder = e~purchaseorder
       AND b~purchaseorderitem = e~purchaseorderitem
     WHERE a~purgreleasesequencestatus <> 'X'
*       and d~TextObjectType = 'F01'
        and a~LastChangeDateTime >= @lv_timestampl

      INTO TABLE @data(lt_poitem).

      SELECT * FROM i_purchaseorderitemnotetp_2 WITH PRIVILEGED ACCESS
      where TextObjectType = 'F01'
      into TABLE @data(lt_note).

*   ①購買伝票ヘッダ
*    SELECT
*        PurchaseOrder,
*        Supplier,
*        PurchasingDocumentDeletionCode,
*        PurchaseOrderDate,
*        CreationDate,
*        CreatedByUser,
*        LastChangeDateTime
*     FROM I_PurchaseOrderAPI01 WITH PRIVILEGED ACCESS
*     where PurchaseOrder IN @lr_where
*     into table @data(lt_po).

*     DATA:
*       LV_LASTCHANGEDATETIME TYPE STRING.
*
**    ①LastChangeDateTime ＞ 前回取得データに最も新しいLastChangeDateTime
*     LOOP AT LT_PO INTO DATA(LW_PO).
*       IF LW_PO-LastChangeDateTime < lv_lastdate.
*       DELETE LT_PO.
*       ENDIF.
*     ENDLOOP.

*     data(lt_po1) = lt_po[].
*     if lt_po1 is not INITIAL.
*        sort lt_po1 by purchaseorder DESCENDING.
*        DELETE ADJACENT DUPLICATES FROM lt_po1 COMPARING purchaseorder.
*
*     ENDIF.

**    ②購買伝票明細
*     select
*       PurchaseOrder,
*       PurchaseOrderItem,
*       DocumentCurrency,
*       Material,
*       PurchaseOrderItemText,
*       OrderQuantity,
*       PurchaseOrderQuantityUnit,
*       NetPriceQuantity,
*       NetAmount,
*       GrossAmount,
*       A~StorageLocation,
*       B~StorageLocationName,
*       PurchasingDocumentDeletionCode
*     from I_PurchaseOrderItemAPI01 WITH PRIVILEGED ACCESS as A
*     LEFT JOIN I_StorageLocation WITH PRIVILEGED ACCESS as B
*     on A~StorageLocation = B~StorageLocation
*     FOR ALL ENTRIES IN @lt_po1
*     where purchaseorder = @lt_po1-PurchaseOrder
*     into table @data(lt_poitem).

*      SELECT
*       PurchaseOrder,
*       PurchaseOrderItem,
*       TextObjectType,
*       PlainLongText
*     from I_PurchaseOrderItemNoteTP_2 WITH PRIVILEGED ACCESS
*     FOR ALL ENTRIES IN @lt_po1
*     where purchaseorder = @lt_po1-PurchaseOrder
*     INTO TABLE @DATA(LT_ITEMNOTE).

*    SELECT
*       purchaseorder,
*       purchaseorderitem,
*       schedulelinedeliverydate
*    FROM i_purordschedulelineapi01 WITH PRIVILEGED ACCESS
*    FOR ALL ENTRIES IN @lt_po1
*    WHERE purchaseorder = @lt_po1-purchaseorder
*    INTO TABLE @DATA(lt_poscl).

*    SELECT
*      purchaseorder ,
*      purchaseorderitem  ,
*      changetimes  ,
*      orderquantity  ,
*      schedulelinedeliverydate    ,
*      netamount    ,
*      purchasingdocumentdeletioncode ,
*      createdbyuser   ,
*      creationdate   ,
*      lastchangedate
*     FROM ztmm_1002 WITH PRIVILEGED ACCESS              "#EC CI_NOWHERE
*     INTO TABLE @DATA(lt_polog_all)
*     .
*
*    SELECT
*        purchaseorder ,
*        purchaseorderitem  ,
*        MAX( changetimes ) AS changetimes
*    FROM ztmm_1002  WITH PRIVILEGED ACCESS              "#EC CI_NOWHERE
*    GROUP BY purchaseorder, purchaseorderitem
*    INTO TABLE @DATA(lt_pologmax)
*    .
*
*    SELECT
*          purchaseorder ,
*          purchaseorderitem  ,
*          changetimes  ,
*          orderquantity  ,
*          schedulelinedeliverydate    ,
*          netamount    ,
*          purchasingdocumentdeletioncode ,
*          createdbyuser   ,
*          creationdate   ,
*          lastchangedate
*    FROM ztmm_1002  WITH PRIVILEGED ACCESS              "#EC CI_NOWHERE
*    INTO TABLE @DATA(lt_polog).
*
*    "只留下changetimes 最大的一条。
*    LOOP AT lt_polog INTO DATA(lw_polog1).
*
*      READ TABLE lt_pologmax INTO DATA(lw_pologmax) WITH KEY purchaseorder = lw_polog1-purchaseorder
*                 purchaseorderitem = lw_polog1-purchaseorderitem.
*      IF lw_polog1-changetimes <> lw_pologmax-changetimes.
*        DELETE lt_polog.
*
*      ENDIF.
*
*    ENDLOOP.
*
    DATA:
      lt_result TYPE STANDARD TABLE OF ty_response,
      lw_result TYPE ty_response.
*
**    添加条目到传出表中。
*    LOOP AT lt_poitem INTO DATA(lw_poitem).
*      MOVE-CORRESPONDING lw_poitem TO lw_result.
*      APPEND lw_result TO lt_result.
*    ENDLOOP.
*
*    LOOP AT lt_result INTO lw_result.
*
*      READ TABLE lt_po INTO DATA(lw_po1) WITH KEY purchaseorder = lw_result-purchaseorder.
*      MOVE-CORRESPONDING lw_po TO lw_result.
*
*      READ TABLE lt_itemnote  INTO DATA(lw_itemnote) WITH KEY purchaseorder = lw_result-purchaseorder
*                                                              purchaseorderitem = lw_result-purchaseorderitem.
*      MOVE-CORRESPONDING lw_itemnote TO lw_result.
*
*      READ TABLE lt_poscl INTO DATA(lw_poscl) WITH KEY  purchaseorder = lw_result-purchaseorder
*                                                        purchaseorderitem = lw_result-purchaseorderitem.
*
*      MODIFY lt_result FROM lw_result.
*      CLEAR lw_result.
*
*    ENDLOOP.
*
*    LOOP AT lt_result INTO lw_result.
*      READ TABLE lt_polog INTO DATA(lw_polog2) WITH KEY purchaseorder = lw_result-purchaseorder
*                                                 purchaseorderitem = lw_result-purchaseorderitem.
*
*      IF lw_result-orderquantity            = lw_polog2-orderquantity
*        AND  lw_result-schedulelinedeliverydate = lw_polog2-schedulelinedeliverydate
*        AND  lw_result-netamount                = lw_polog2-netamount
*        OR   lw_result-purchasingdocumentdeletioncode = 'X'.
*        DELETE lt_result.
*      ENDIF.
*    ENDLOOP.

    LOOP AT lt_poitem INTO DATA(lw_poitems).

      MOVE-CORRESPONDING lw_poitems to lw_result.

      READ TABLE lt_note into data(lw_note) WITH KEY purchaseorder = lw_poitems-purchaseorder purchaseorderitem = lw_poitems-purchaseorderitem.
      if  sy-subrc = 0.
      lw_result-plainlongtext = lw_note-PlainLongText .
      ENDIF.


       DATA(lv_unit1) = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = lw_result-purchaseorderquantityunit ).

         lw_result-purchaseorderquantityunit = lv_unit1.

      append lw_result to lt_result.



    ENDLOOP.

    LOOP AT lt_result INTO lw_result.

      ls_response-purchaseorder                      = lw_result-purchaseorder                  .
      ls_response-supplier                           = lw_result-supplier                       .
      ls_response-companycode                        = lw_result-companycode                    .
      ls_response-purchasingdocumentdeletioncode     = lw_result-purchasingdocumentdeletioncode .
      ls_response-purchaseorderdate                  = lw_result-purchaseorderdate              .
      ls_response-creationdate                       = lw_result-creationdate                   .
      ls_response-createdbyuser                      = lw_result-createdbyuser                  .
      ls_response-lastchangedatetime                 = lw_result-lastchangedatetime             .
      ls_response-purchaseorderitem                  = lw_result-purchaseorderitem              .
      ls_response-documentcurrency                   = lw_result-documentcurrency               .
      ls_response-material                           = lw_result-material                       .
      ls_response-plant                           = lw_result-plant                       .
      ls_response-purchaseorderitemtext              = lw_result-purchaseorderitemtext          .
      ls_response-orderquantity                      = lw_result-orderquantity                  .
      ls_response-purchaseorderquantityunit          = lw_result-purchaseorderquantityunit      .
      ls_response-netpricequantity                   = lw_result-netpricequantity               .
      ls_response-netamount                          = lw_result-netamount                      .
      ls_response-grossamount                        = lw_result-grossamount                    .
      ls_response-storagelocation                    = lw_result-storagelocation                .
      ls_response-storagelocationname                = lw_result-storagelocationname            .
      ls_response-textobjecttype                     = lw_result-textobjecttype                 .
      ls_response-plainlongtext                      = lw_result-plainlongtext                  .
      ls_response-schedulelinedeliverydate           = lw_result-schedulelinedeliverydate       .
      ls_response-SupplierMaterialNumber             = lw_result-SupplierMaterialNumber         .
      CONDENSE ls_response-purchaseorder                  .
      CONDENSE ls_response-supplier                       .
      CONDENSE ls_response-companycode                    .
      CONDENSE ls_response-purchasingdocumentdeletioncode .
      CONDENSE ls_response-purchaseorderdate              .
      CONDENSE ls_response-creationdate                   .
      CONDENSE ls_response-createdbyuser                  .
      CONDENSE ls_response-lastchangedatetime             .
      CONDENSE ls_response-purchaseorderitem              .
      CONDENSE ls_response-documentcurrency               .
      CONDENSE ls_response-material                       .
      CONDENSE ls_response-plant                       .
      CONDENSE ls_response-purchaseorderitemtext          .
      CONDENSE ls_response-orderquantity                  .
      CONDENSE ls_response-purchaseorderquantityunit      .
      CONDENSE ls_response-netpricequantity               .
      CONDENSE ls_response-netamount                      .
      CONDENSE ls_response-grossamount                    .
      CONDENSE ls_response-storagelocation                .
      CONDENSE ls_response-storagelocationname            .
      CONDENSE ls_response-textobjecttype                 .
      CONDENSE ls_response-plainlongtext                  .
      CONDENSE ls_response-schedulelinedeliverydate       .
      CONDENSE ls_response-SupplierMaterialNumber       .

      APPEND ls_response TO es_response-items.
    ENDLOOP.

    IF lt_result IS INITIAL.
      lv_text = 'error'.
      "propagate any errors raised
      response->set_status( '500' )."500
      response->set_text( lv_text ).
    ELSE.

      "respond with success payload
      response->set_status( '200' ).

      DATA(lv_json_string) = xco_cp_json=>data->from_abap( es_response )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
         ) )->to_string( ).
      response->set_text( lv_json_string ).
      response->set_header_field( i_name  = lc_header_content
                                  i_value = lc_content_type ).

    ENDIF.

  ENDMETHOD.
ENDCLASS.
