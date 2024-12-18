CLASS zcl_http_podata_003 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:

      BEGIN OF ts_workflow,

        SAPBusinessObjectNodeKey1     TYPE  string,
        WorkflowInternalID            TYPE  string,
        WorkflowExternalStatus        TYPE  string,

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

        WorkflowInternalID         TYPE  string,
        WorkflowTaskInternalID     TYPE  string,
        WorkflowTaskResult         TYPE  string,

      END OF ts_workflowdetail,

      tt_workflowdetail TYPE STANDARD TABLE OF ts_workflowdetail WITH DEFAULT KEY,

      BEGIN OF ts_workflowdetail_d,
        results TYPE tt_workflowdetail,
      END OF ts_workflowdetail_d,

      BEGIN OF ts_workflowdetail_api,
        d TYPE ts_workflowdetail_d,
      END OF ts_workflowdetail_api,
*---------------------------------------------------------------------------
      Begin of ty_confirmation,

                 PurchaseOrder                       type string,
                 PurchaseOrderItem                   type string,
                 SequentialNmbrOfSuplrConf           type string,
                 DeliveryDate                        type string,
                 ConfirmedQuantity                   type string,
                 MRPRelevantQuantity                 type string,
                 SupplierConfirmationExtNumber       type string,

      END OF TY_confirmation,

      tt_confimation TYPE STANDARD TABLE OF ty_confirmation WITH EMPTY KEY,

      BEGIN OF ty_response,
        purchaseorder                  TYPE c LENGTH  10,
        purchaseorderitem              TYPE c LENGTH  5,
        supplier                       TYPE c LENGTH  10,
        companycode                    type c length  4,
        purchasingdocumentdeletioncode TYPE c LENGTH  1,
        purchaseorderdate              TYPE c LENGTH  8,
        creationdate                   TYPE c LENGTH  8,
        createdbyuser                  TYPE c LENGTH  12,
        lastchangedatetime             TYPE c LENGTH  21,
        documentcurrency               TYPE c LENGTH  5,
        material                       TYPE c LENGTH  18,
        TaxCode                        TYPE c Length  12,
        plant                          type c LENGTH  4 ,
        purchaseorderitemtext          TYPE c LENGTH  40,
        orderquantity                  TYPE c LENGTH  13,
        purchaseorderquantityunit      TYPE c LENGTH  3,
        netpricequantity               TYPE c LENGTH  5,
        netpriceamount                 TYPE c length  16,
        netamount                      TYPE c LENGTH  16,
        taxamount                      type c LENGTH  16,
        storagelocation                TYPE c LENGTH  4,
        storagelocationname            TYPE c LENGTH  20,
        textobjecttype                 TYPE c LENGTH  4,
        plainlongtext                  TYPE string,
        schedulelinedeliverydate       TYPE c LENGTH  8,
        SupplierMaterialNumber         type c LENGTH 18,
        InternationalArticleNumber     type c length 12,
        RequisitionerName              type c length 12,
        CorrespncInternalReference     type c length 12,


        _confirmation type STANDARD TABLE OF  ty_confirmation WITH EMPTY KEY,

      END OF ty_response,

      BEGIN OF ty_output,

        items TYPE STANDARD TABLE OF ty_response WITH EMPTY KEY,

      END OF ty_output.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:



      lt_workflow_api TYPE STANDARD TABLE OF ts_workflow,
      lt_workflowdetail_api TYPE STANDARD TABLE OF ts_workflowdetail,
      ls_res_workflow type ts_workflow_api,
      ls_res_workflowdetail TYPE ts_workflowdetail_api,

      lv_error(1)       TYPE c,
      lv_text           TYPE string,
      ls_response       TYPE ty_response,
      lw_confirmation    type ty_confirmation,
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
           b~netpriceamount,
           b~netamount,
           b~storagelocation,
           b~SupplierMaterialNumber,
           b~TaxCode,

           b~InternationalArticleNumber,
           b~RequisitionerName,

           c~storagelocationname,
           b~purchasingdocumentdeletioncode,
           a~supplier,
           a~purchaseorderdate,
           a~CompanyCode,
           a~creationdate,
           a~createdbyuser,
           a~lastchangedatetime,
           a~CorrespncInternalReference,
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
     WHERE a~LastChangeDateTime >= @lv_timestampl

      INTO TABLE @data(lt_poitem).

*--------------------------------------------------------------just for test

*DELETE lt_poitem WHERE purchaseorder <> '2100001939'.

*--------------------------------------------------------------just for test

      SELECT
      zvalue1,
      zvalue2
      FROM ztbc_1001 WITH PRIVILEGED ACCESS
      WHERE ZID = 'ZMM001'
      into TABLE @data(lt_1001).

      if  lt_poitem is NOT INITIAL.

         data(lt_poitem_copy) = lt_poitem.

         SORT lt_poitem_copy by purchaseorder purchaseorderitem.

         DELETE ADJACENT DUPLICATES FROM lt_poitem_copy COMPARING purchaseorder purchaseorderitem.

         SELECT  purchaseorder,
                 purchaseorderItem,
                 SequentialNmbrOfSuplrConf,
                 DeliveryDate,
                 ConfirmedQuantity,
                 MRPRelevantQuantity,
                 SupplierConfirmationExtNumber

            FROM I_POSupplierConfirmationAPI01 WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_poitem_copy
           WHERE Purchaseorder = @lt_poitem_copy-purchaseorder
             and purchaseorderitem = @lt_poitem_copy-purchaseorderItem
            INto  TABLE @DATA(lt_confirmation).

      ENDIF.

      SELECT * FROM i_purchaseorderitemnotetp_2 WITH PRIVILEGED ACCESS
      where TextObjectType = 'F01'
      into TABLE @data(lt_note).

      if    lt_note is NOT INITIAL.
        SORT lt_note by purchaseorder purchaseorderitem.
      ENDIF.

    DATA:
      lt_result TYPE STANDARD TABLE OF ty_response,
      lw_result TYPE ty_response.


  data:
         lv_path           TYPE string,
         lv_path1          TYPE String.


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

      if lt_workflow_api is NOT INITIAL.

        SORT lt_workflow_api by SAPBusinessObjectNodeKey1.

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

      if lt_workflowdetail_api is NOT INITIAL.

          SORT lt_workflowdetail_api by WorkflowInternalID WorkflowTaskInternalID DESCENDING.

          DELETE ADJACENT DUPLICATES FROM lt_workflowdetail_api COMPARING WorkflowInternalID.

      ENDIF.

    data:lv_response type c .



    LOOP AT lt_poitem INTO DATA(lw_poitems).

        READ TABLE lt_workflow_api into data(lw_workflow) WITH KEY SAPBusinessObjectNodeKey1 = lw_poitems-purchaseorder BINARY SEARCH.

            if sy-subrc = 0.
               READ TABLE lt_workflowdetail_api into data(lw_workflow_d) WITH key WorkflowInternalID = lw_workflow-WorkflowInternalID BINARY SEARCH.

               "如果能在detail中取到WorkflowTaskInternalID
               if sy-subrc = 0.

                 if lw_workflow_d-workflowtaskresult = 'RELEASED'.

                    lv_response = 'X'.

                 ELSE.

                    lv_response = ''.

                 ENDIF.

               "当取不到internalid 的时候
               else.
                 "直接判断WorkflowTaskExternalStatus是不是COMPLETED
                 if lw_workflow-workflowexternalstatus = 'COMPLETED'.
                 "如果是，则是传出对象。
                    lv_response = 'X'.

                 else.
                 "如果不是completed 则不是传出对象。
                    lv_response = ''.
                 endif.

               ENDIF.

            else.

                lv_response = ''.

            ENDIF.

            "只有是传出对象的时候才会去传出
            if  lv_response = 'X'.

              MOVE-CORRESPONDING lw_poitems to lw_result.

              READ TABLE lt_note into data(lw_note) WITH KEY purchaseorder = lw_poitems-purchaseorder purchaseorderitem = lw_poitems-purchaseorderitem BINARY SEARCH.
              if  sy-subrc = 0.
              lw_result-plainlongtext = lw_note-PlainLongText .
              ENDIF.

                TRY.
                  DATA(lv_unit1) = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input =  lw_result-purchaseorderquantityunit ).
                    ##NO_HANDLER
                  CATCH zzcx_custom_exception.
                    " handle exception
                ENDTRY.

                 lw_result-purchaseorderquantityunit = lv_unit1.

              append lw_result to lt_result.

              clear lw_result.

            ENDIF.

            clear:lv_response,lw_result,lw_note,lw_workflow,lw_workflow_d.

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



       READ TABLE lt_1001 into data(lw_1001) WITH KEY Zvalue1 = lw_result-TaxCode.
*
      if sy-subrc = 0.

        data(lv_value) = lw_1001-zvalue2.

      endif.
      clear lw_1001.

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

        clear :  lv_value, lv_taxamount1.

      ls_response-storagelocation                    = lw_result-storagelocation                .
      ls_response-storagelocationname                = lw_result-storagelocationname            .
      ls_response-textobjecttype                     = lw_result-textobjecttype                 .
      ls_response-plainlongtext                      = lw_result-plainlongtext                  .
      ls_response-schedulelinedeliverydate           = lw_result-schedulelinedeliverydate       .
      ls_response-SupplierMaterialNumber             = lw_result-SupplierMaterialNumber         .
      ls_response-TaxCode                            = lw_result-TaxCode.

      ls_response-InternationalArticleNumber         = lw_result-InternationalArticleNumber.
      ls_response-RequisitionerName                  = lw_result-RequisitionerName.
      ls_response-CorrespncInternalReference = lw_result-CorrespncInternalReference.

      "change by wz 20241218 顾问教育归来 要求 去除po的前导零
      ls_response-purchaseorder  = |{ ls_response-purchaseorder  ALPHA = OUT }|.

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
      CONDENSE ls_response-taxamount                      .
      CONDENSE ls_response-netpriceamount                 .
      CONDENSE ls_response-storagelocation                .
      CONDENSE ls_response-storagelocationname            .
      CONDENSE ls_response-textobjecttype                 .
      CONDENSE ls_response-plainlongtext                  .
      CONDENSE ls_response-schedulelinedeliverydate       .
      CONDENSE ls_response-SupplierMaterialNumber       .
      CONDENSE ls_response-TaxCode.
      CONDENSE ls_response-InternationalArticleNumber     .
      CONDENSE ls_response-RequisitionerName     .
      condense ls_response-CorrespncInternalReference .


      loop AT lt_confirmation INTO data(lw_confadd) WHERE purchaseorder = lw_result-purchaseorder and purchaseorderitem = lw_result-purchaseorderitem .

        lw_confirmation-PurchaseOrder                               =  lw_confadd-PurchaseOrder                  .
        lw_confirmation-PurchaseOrderItem                           =  lw_confadd-PurchaseOrderItem              .
        lw_confirmation-SequentialNmbrOfSuplrConf                   =  lw_confadd-SequentialNmbrOfSuplrConf      .
        lw_confirmation-DeliveryDate                                =  lw_confadd-DeliveryDate                   .
        lw_confirmation-ConfirmedQuantity                           =  lw_confadd-ConfirmedQuantity              .
        lw_confirmation-MRPRelevantQuantity                         =  lw_confadd-MRPRelevantQuantity            .
        lw_confirmation-SupplierConfirmationExtNumber               =  lw_confadd-SupplierConfirmationExtNumber  .

        lw_confirmation-PurchaseOrder = |{ lw_confirmation-PurchaseOrder ALPHA = OUT }|.

        CONDENSE  lw_confirmation-PurchaseOrder                 .
        CONDENSE  lw_confirmation-PurchaseOrderItem             .
        CONDENSE  lw_confirmation-SequentialNmbrOfSuplrConf     .
        CONDENSE  lw_confirmation-DeliveryDate                  .
        CONDENSE  lw_confirmation-ConfirmedQuantity             .
        CONDENSE  lw_confirmation-MRPRelevantQuantity           .
        CONDENSE  lw_confirmation-SupplierConfirmationExtNumber .

        APPEND lw_confirmation to ls_response-_confirmation.
        clear lw_confirmation.
      ENDLOOP.

      SORT ls_response-_confirmation by purchaseorder purchaseorderitem.

      APPEND ls_response TO es_response-items.
      clear ls_response.

    ENDLOOP.

    sort es_response-items by purchaseorder purchaseorderitem.

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
