CLASS zcl_http_podata_003 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:

      BEGIN OF ts_workflow,
        sapbusinessobjectnodekey1      TYPE  string,
        workflowinternalid             TYPE  string,
        workflowexternalstatus         TYPE  string,
        wrkflwtskcompletionutcdatetime TYPE string,
        sapobjectnoderepresentation    TYPE string,

      END OF ts_workflow,

      tt_workflow TYPE STANDARD TABLE OF ts_workflow WITH DEFAULT KEY,

      BEGIN OF ts_workflow_d,
        results TYPE tt_workflow,
      END OF ts_workflow_d,

      BEGIN OF ts_workflow_api,
        d TYPE ts_workflow_d,
      END OF ts_workflow_api,
*---------------------------------------------------------------------------
      BEGIN OF ts_workflowdetail,

        workflowinternalid     TYPE  string,
        workflowtaskinternalid TYPE  string,
        workflowtaskresult     TYPE  string,
        WorkflowTaskExternalStatus TYPE string,

      END OF ts_workflowdetail,

      tt_workflowdetail TYPE STANDARD TABLE OF ts_workflowdetail WITH DEFAULT KEY,

      BEGIN OF ts_workflowdetail_d,
        results TYPE tt_workflowdetail,
      END OF ts_workflowdetail_d,

      BEGIN OF ts_workflowdetail_api,
        d TYPE ts_workflowdetail_d,
      END OF ts_workflowdetail_api,
*---------------------------------------------------------------------------
      BEGIN OF ty_confirmation,

        purchaseorder                 TYPE string,
        purchaseorderitem             TYPE string,
        sequentialnmbrofsuplrconf     TYPE string,
        deliverydate                  TYPE string,
        confirmedquantity             TYPE string,
        mrprelevantquantity           TYPE string,
        supplierconfirmationextnumber TYPE string,

      END OF ty_confirmation,

      tt_confimation TYPE STANDARD TABLE OF ty_confirmation WITH EMPTY KEY,

      BEGIN OF ty_response,
        purchaseorder                  TYPE c LENGTH  10,
        purchaseorderitem              TYPE c LENGTH  5,
        supplier                       TYPE c LENGTH  10,
        companycode                    TYPE c LENGTH  4,
        purchasingdocumentdeletioncode TYPE c LENGTH  1,
        purchaseorderdate              TYPE c LENGTH  8,
        creationdate                   TYPE c LENGTH  8,
        createdbyuser                  TYPE c LENGTH  12,
        lastchangedatetime             TYPE i_purchaseorderapi01-lastchangedatetime,
        documentcurrency               TYPE c LENGTH  5,
        material                       TYPE c LENGTH  40,
        taxcode                        TYPE c LENGTH  12,
        plant                          TYPE c LENGTH  4,
        purchaseorderitemtext          TYPE c LENGTH  40,
        orderquantity                  TYPE c LENGTH  13,
        purchaseorderquantityunit      TYPE c LENGTH  3,
        netpricequantity               TYPE c LENGTH  5,
        netpriceamount                 TYPE c LENGTH  16,
        netamount                      TYPE c LENGTH  16,
        taxamount                      TYPE c LENGTH  16,
        storagelocation                TYPE c LENGTH  4,
        storagelocationname            TYPE c LENGTH  20,
        textobjecttype                 TYPE c LENGTH  4,
        plainlongtext                  TYPE string,
        schedulelinedeliverydate       TYPE c LENGTH  8,
        suppliermaterialnumber         TYPE I_PurchaseOrderItemAPI01-suppliermaterialnumber,
        internationalarticlenumber     TYPE string,
        requisitionername              TYPE c LENGTH 12,
        correspncinternalreference     TYPE c LENGTH 12,
        approvedate                    TYPE string,
        purchasingorganization         TYPE c LENGTH 4,
        sap_cd_by_text                 TYPE c LENGTH 50,
        _confirmation                  TYPE STANDARD TABLE OF  ty_confirmation WITH EMPTY KEY,

      END OF ty_response,

      BEGIN OF ty_output,

        items TYPE STANDARD TABLE OF ty_response WITH EMPTY KEY,

      END OF ty_output,

      BEGIN OF ty_req,
        plant      TYPE string,
        time_stamp TYPE string,
      END OF ty_req.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:

      lt_workflow_api       TYPE STANDARD TABLE OF ts_workflow,
      lt_workflowdetail_api TYPE STANDARD TABLE OF ts_workflowdetail,
      ls_res_workflow       TYPE ts_workflow_api,
      ls_res_workflowdetail TYPE ts_workflowdetail_api,

      lv_error(1)           TYPE c,
      lv_text               TYPE string,
      ls_response           TYPE ty_response,
      lw_confirmation       TYPE ty_confirmation,
      es_response           TYPE ty_output,
      lc_header_content     TYPE string VALUE 'content-type',
      lc_content_type       TYPE string VALUE 'text/json',

      ls_req                TYPE ty_req,
      lv_plant              TYPE werks_d,
      lv_timestamp          TYPE timestamp.

ENDCLASS.



CLASS ZCL_HTTP_PODATA_003 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA:
      lt_polog TYPE TABLE OF ztmm_1002,
      lw_polog TYPE ztmm_1002.

    DATA:
      lv_ebeln    TYPE ebeln,
      lr_where    TYPE RANGE OF ebeln,
      lv_dec(11)  TYPE p DECIMALS 7,
      lr_lastdate LIKE RANGE OF lv_dec.

    DATA(lv_sy_datum) = cl_abap_context_info=>get_system_date( ).

    DATA(lv_predate) = zzcl_common_utils=>calc_date_subtract(
                EXPORTING
                  date      = lv_sy_datum

                  day       = '1'

              ).

    DATA: lv_date       TYPE d,
          lv_time       TYPE t,
          lv_timestampl TYPE timestampl.

    lv_date = lv_predate.
    lv_time = '000000'.

    CONVERT DATE lv_date TIME lv_time INTO TIME STAMP lv_timestampl TIME ZONE sy-zonlo.

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).

    lv_plant     = ls_req-plant.
    lv_timestamp = ls_req-time_stamp.

    data:lv_where type String.

    if lv_plant is NOT INITIAL.

        lv_where = |b~plant = @lv_plant and a~lastchangedatetime >= @lv_timestamp|.

    else.

        lv_where = |a~lastchangedatetime >= @lv_timestamp|.

    ENDIF.

    SELECT b~purchaseorder,
           b~purchaseorderitem,
           b~documentcurrency,
           b~material,
           b~plant,
           b~purchaseorderitemtext,
           b~orderquantity,
           b~purchaseorderquantityunit,
           b~netpricequantity,
           b~netpriceamount,
           b~netamount,
           b~storagelocation,
           b~suppliermaterialnumber,
           b~taxcode,
           b~internationalarticlenumber,
           b~requisitionername,
           c~storagelocationname,
           b~purchasingdocumentdeletioncode,
           a~supplier,
           a~purchaseorderdate,
           a~companycode,
           a~creationdate,
           a~createdbyuser,
           a~lastchangedatetime,
           a~correspncinternalreference,
           a~purchasingorganization,
           d~textobjecttype,
           d~plainlongtext,
           e~schedulelinedeliverydate,
           a~PurchaseOrderType "add by stanley 20250307
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
      LEFT JOIN i_businessuserbasic WITH PRIVILEGED ACCESS AS f
        ON a~CreatedByUser = f~BusinessPartner
     WHERE (lv_where)
      INTO TABLE @DATA(lt_poitem).

      SELECT BusinessPartner,
             LASTNAME,
             FIRSTNAME
          FROM i_businessuserbasic
          INTO TABLE @DATA(LT_USERNAME)."#EC CI_NOWHERE
*--------------------------------------------------------------just for test

*DELETE lt_poitem WHERE purchaseorder <> '3100000000'.

*--------------------------------------------------------------just for test

    SELECT
    zvalue1,
    zvalue2
    FROM ztbc_1001 WITH PRIVILEGED ACCESS
    WHERE zid = 'ZMM001'
    INTO TABLE @DATA(lt_1001).

    IF  lt_poitem IS NOT INITIAL.

      DATA(lt_poitem_copy) = lt_poitem.

      SORT lt_poitem_copy BY purchaseorder purchaseorderitem.

      DELETE ADJACENT DUPLICATES FROM lt_poitem_copy COMPARING purchaseorder purchaseorderitem.

      SELECT  purchaseorder,
              purchaseorderitem,
              sequentialnmbrofsuplrconf,
              deliverydate,
              confirmedquantity,
              mrprelevantquantity,
              supplierconfirmationextnumber

         FROM i_posupplierconfirmationapi01 WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_poitem_copy
        WHERE purchaseorder = @lt_poitem_copy-purchaseorder
          AND purchaseorderitem = @lt_poitem_copy-purchaseorderitem
         INTO TABLE @DATA(lt_confirmation).

    ENDIF.

    SELECT * FROM i_purchaseorderitemnotetp_2 WITH PRIVILEGED ACCESS
    WHERE textobjecttype = 'F01'
    INTO TABLE @DATA(lt_note).

    IF    lt_note IS NOT INITIAL.
      SORT lt_note BY purchaseorder purchaseorderitem.
    ENDIF.

    DATA:
      lt_result TYPE STANDARD TABLE OF ty_response,
      lw_result TYPE ty_response.


    DATA:
      lv_path  TYPE string,
      lv_path1 TYPE string.


*     审批状态取得取得
    lv_path = |/YY1_WORKFLOWSTATUSOVERVIEW_CDS/YY1_WorkflowStatusOverview|.
    "Call API
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>get
        iv_format      = 'json'
      IMPORTING
        ev_status_code = DATA(lv_stat_code1)
        ev_response    = DATA(lv_resbody_api1) ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api1
                             CHANGING data = ls_res_workflow ).

    IF lv_stat_code1 = '200' AND ls_res_workflow-d-results IS NOT INITIAL.

      APPEND LINES OF ls_res_workflow-d-results TO lt_workflow_api.

    ENDIF.

    IF lt_workflow_api IS NOT INITIAL.

      SORT lt_workflow_api BY sapbusinessobjectnodekey1 sapobjectnoderepresentation WorkflowInternalID DESCENDING.

    ENDIF.

*      审批详情取得

    lv_path1 = |/YY1_WORKFLOWSTATUSDETAILS_CDS/YY1_WorkflowStatusDetails|.
    "Call API
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path1
        iv_method      = if_web_http_client=>get
        iv_format      = 'json'
      IMPORTING
        ev_status_code = DATA(lv_stat_code2)
        ev_response    = DATA(lv_resbody_api2) ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api2
                             CHANGING data = ls_res_workflowdetail ).

    IF lv_stat_code1 = '200' AND ls_res_workflowdetail-d-results IS NOT INITIAL.

      APPEND LINES OF ls_res_workflowdetail-d-results TO lt_workflowdetail_api.

    ENDIF.

    IF lt_workflowdetail_api IS NOT INITIAL.

      SORT lt_workflowdetail_api BY workflowinternalid workflowtaskinternalid DESCENDING.
      "ADD BY STANLEY 20250217
      DELETE lt_workflowdetail_api WHERE WorkflowTaskExternalStatus = 'CANCELLED'.
      "END ADD

      DELETE ADJACENT DUPLICATES FROM lt_workflowdetail_api COMPARING workflowinternalid.



    ENDIF.

    DATA:lv_response TYPE c .

    LOOP AT lt_poitem INTO DATA(lw_poitems).

      READ TABLE lt_workflow_api INTO DATA(lw_workflow) WITH KEY sapbusinessobjectnodekey1 = lw_poitems-purchaseorder sapobjectnoderepresentation = 'PurchaseOrder'.

      IF sy-subrc = 0.
        lw_result-approvedate = lw_workflow-wrkflwtskcompletionutcdatetime.

        READ TABLE lt_workflowdetail_api INTO DATA(lw_workflow_d) WITH KEY workflowinternalid = lw_workflow-workflowinternalid BINARY SEARCH.

        "如果能在detail中取到WorkflowTaskInternalID
        IF sy-subrc = 0.

          IF lw_workflow_d-workflowtaskresult = 'RELEASED'.

            lv_response = 'X'.

          ELSE.

            lv_response = ''.

          ENDIF.

          "当取不到internalid 的时候
        ELSE.
          "直接判断WorkflowTaskExternalStatus是不是COMPLETED
          IF lw_workflow-workflowexternalstatus = 'COMPLETED'.
            "如果是，则是传出对象。
            lv_response = 'X'.

          ELSE.
            "如果不是completed 则不是传出对象。
             lv_response = ''.
          ENDIF.

        ENDIF.

      ELSE.
       if lw_poitems-PurchaseOrderType =  'ZB21'."add by stanley 20250307 for advanced purchase pass ZB21
             lv_response = 'X'.
       else.
             lv_response = ''.
       endif.

      ENDIF.

      "只有是传出对象的时候才会去传出
      IF  lv_response = 'X'.

        MOVE-CORRESPONDING lw_poitems TO lw_result.

        "ADD BY STANLEY 20250207
        READ TABLE LT_USERNAME INTO DATA(LS_USERNAME) WITH KEY BusinessPartner = LW_POITEMS-CreatedByUser+2.
        IF SY-SUBRC EQ 0.
            lw_result-sap_cd_by_text = |{ LS_USERNAME-LastName } { LS_USERNAME-FirstName }|.
        ENDIF.


        READ TABLE lt_note INTO DATA(lw_note) WITH KEY purchaseorder = lw_poitems-purchaseorder purchaseorderitem = lw_poitems-purchaseorderitem BINARY SEARCH.
        IF  sy-subrc = 0.
          lw_result-plainlongtext = lw_note-plainlongtext .
        ENDIF.

        TRY.
            DATA(lv_unit1) = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input =  lw_result-purchaseorderquantityunit ).
            ##NO_HANDLER
          CATCH zzcx_custom_exception.
            " handle exception
        ENDTRY.

        lw_result-purchaseorderquantityunit = lv_unit1.

        APPEND lw_result TO lt_result.

        CLEAR lw_result.

      ENDIF.

      CLEAR:lv_response,lw_result,lw_note,lw_workflow,lw_workflow_d.

    ENDLOOP.

    DATA lv_taxamount1        TYPE p LENGTH 10 DECIMALS 2."两位小数

    DATA lv_taxamount        TYPE p LENGTH 10  ."两位小数

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
      ls_response-plant                              = lw_result-plant                       .
      ls_response-purchaseorderitemtext              = lw_result-purchaseorderitemtext          .
      ls_response-orderquantity                      = lw_result-orderquantity                  .
      ls_response-purchaseorderquantityunit          = lw_result-purchaseorderquantityunit      .
      ls_response-netpricequantity                   = lw_result-netpricequantity               .
      ls_response-purchasingorganization             = lw_result-purchasingorganization         .
      ls_response-sap_cd_by_text                     = lw_result-sap_cd_by_text.
      ls_response-netamount = zzcl_common_utils=>conversion_amount(
        EXPORTING
          iv_alpha    = 'OUT'
          iv_currency = lw_result-documentcurrency
          iv_input    = lw_result-netamount
*        RECEIVING
*          rv_output   =
      ).

      ls_response-netpriceamount = zzcl_common_utils=>conversion_amount(
        EXPORTING
          iv_alpha    = 'OUT'
          iv_currency = lw_result-documentcurrency
          iv_input    = lw_result-netpriceamount
*        RECEIVING
*          rv_output   =
      ).

*      "approve date 获取
*      READ TABLE lt_workflow_api into data(lw_approvedate)  WITH KEY SAPBusinessObjectNodeKey1 = lw_result-purchaseorder BINARY SEARCH.
*
*      if sy-subrc = 0.
*
*        lw_result-approvedate = lw_approvedate-WrkflwTskCompletionUTCDateTime.
*
*      ENDIF.
*      clear lw_approvedate.

      READ TABLE lt_1001 INTO DATA(lw_1001) WITH KEY zvalue1 = lw_result-taxcode.
*
      IF sy-subrc = 0.

        DATA(lv_value) = lw_1001-zvalue2.

      ENDIF.
      CLEAR lw_1001.

      CASE lw_result-documentcurrency.
        WHEN 'JPY'.

          ls_response-taxamount = lv_value / 100 * ls_response-netamount.

*            lv_taxamount2 = floor( lw_result-taxamount * 100 ) / 100.
*            ls_response-taxamount = lv_taxamount2.

          " 舍弃小数部分，取整
          CONDENSE ls_response-taxamount.

          lv_taxamount = floor( ls_response-taxamount ).
          ls_response-taxamount = lv_taxamount.

        WHEN 'USD'.

          ls_response-taxamount = lv_value / 100 * ls_response-netamount.

          " 舍弃小数部分，取整
          CONDENSE ls_response-taxamount.

          lv_taxamount1 = floor( ls_response-taxamount * 100 ) / 100.
          ls_response-taxamount = lv_taxamount1.

        WHEN 'EUR'.

          ls_response-taxamount = lv_value / 100 * ls_response-netamount.

          CONDENSE ls_response-taxamount.
          lv_taxamount1 = floor( ls_response-taxamount * 100 ) / 100.
          ls_response-taxamount = lv_taxamount1.

        WHEN OTHERS.

      ENDCASE.

      CLEAR :  lv_value, lv_taxamount1.

      ls_response-storagelocation                    = lw_result-storagelocation                .
      ls_response-storagelocationname                = lw_result-storagelocationname            .
      ls_response-textobjecttype                     = lw_result-textobjecttype                 .
      ls_response-plainlongtext                      = lw_result-plainlongtext                  .
      ls_response-schedulelinedeliverydate           = lw_result-schedulelinedeliverydate       .
      ls_response-suppliermaterialnumber             = lw_result-suppliermaterialnumber         .
      ls_response-taxcode                            = lw_result-taxcode.

      ls_response-internationalarticlenumber         = lw_result-internationalarticlenumber.
      ls_response-requisitionername                  = lw_result-requisitionername.
      ls_response-correspncinternalreference = lw_result-correspncinternalreference.
      ls_response-approvedate                        = lw_result-approvedate.

      "change by wz 20241218 顾问教育归来 要求 去除po的前导零
      ls_response-purchaseorder  = |{ ls_response-purchaseorder  ALPHA = OUT }|.

      CONDENSE ls_response-purchaseorder                  .
      CONDENSE ls_response-supplier                       .
      CONDENSE ls_response-companycode                    .
      CONDENSE ls_response-purchasingdocumentdeletioncode .
      CONDENSE ls_response-purchaseorderdate              .
      CONDENSE ls_response-creationdate                   .
      CONDENSE ls_response-createdbyuser                  .
*      CONDENSE ls_response-lastchangedatetime             .
      CONDENSE ls_response-purchaseorderitem              .
      CONDENSE ls_response-documentcurrency               .
      CONDENSE ls_response-material                       .
      CONDENSE ls_response-plant                       .
      CONDENSE ls_response-purchaseorderitemtext          .
      CONDENSE ls_response-orderquantity                  .
      CONDENSE ls_response-purchaseorderquantityunit      .
      CONDENSE ls_response-netpricequantity               .
      CONDENSE ls_response-netamount                      .
      CONDENSE ls_response-taxamount                      .
      CONDENSE ls_response-netpriceamount                 .
      CONDENSE ls_response-storagelocation                .
      CONDENSE ls_response-storagelocationname            .
      CONDENSE ls_response-textobjecttype                 .
      CONDENSE ls_response-plainlongtext                  .
      CONDENSE ls_response-schedulelinedeliverydate       .
      CONDENSE ls_response-suppliermaterialnumber       .
      CONDENSE ls_response-taxcode.
      CONDENSE ls_response-internationalarticlenumber     .
      CONDENSE ls_response-requisitionername     .
      CONDENSE ls_response-correspncinternalreference .
      CONDENSE ls_response-approvedate.
      CONDENSE ls_response-purchasingorganization.

      LOOP AT lt_confirmation INTO DATA(lw_confadd) WHERE purchaseorder = lw_result-purchaseorder AND purchaseorderitem = lw_result-purchaseorderitem .

        lw_confirmation-purchaseorder                               =  lw_confadd-purchaseorder                  .
        lw_confirmation-purchaseorderitem                           =  lw_confadd-purchaseorderitem              .
        lw_confirmation-sequentialnmbrofsuplrconf                   =  lw_confadd-sequentialnmbrofsuplrconf      .
        lw_confirmation-deliverydate                                =  lw_confadd-deliverydate                   .
        lw_confirmation-confirmedquantity                           =  lw_confadd-confirmedquantity              .
        lw_confirmation-mrprelevantquantity                         =  lw_confadd-mrprelevantquantity            .
        lw_confirmation-supplierconfirmationextnumber               =  lw_confadd-supplierconfirmationextnumber  .

        lw_confirmation-purchaseorder = |{ lw_confirmation-purchaseorder ALPHA = OUT }|.

        CONDENSE  lw_confirmation-purchaseorder                 .
        CONDENSE  lw_confirmation-purchaseorderitem             .
        CONDENSE  lw_confirmation-sequentialnmbrofsuplrconf     .
        CONDENSE  lw_confirmation-deliverydate                  .
        CONDENSE  lw_confirmation-confirmedquantity             .
        CONDENSE  lw_confirmation-mrprelevantquantity           .
        CONDENSE  lw_confirmation-supplierconfirmationextnumber .

        APPEND lw_confirmation TO ls_response-_confirmation.
        CLEAR lw_confirmation.
      ENDLOOP.

      SORT ls_response-_confirmation BY purchaseorder purchaseorderitem.

      APPEND ls_response TO es_response-items.
      CLEAR ls_response.

    ENDLOOP.

    SORT es_response-items BY purchaseorder purchaseorderitem.

    IF lt_result IS INITIAL.
      lv_text = 'there is no data to send'.
      "propagate any errors raised
      response->set_status( '204' )."204

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
