CLASS zcl_accountdoc_prt_h DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ACCOUNTDOC_PRT_H IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA:lt_zr_accountingdoc_prt_h TYPE STANDARD TABLE OF zr_accountingdoc_prt_h.
    DATA:ls_zr_accountingdoc_prt_h TYPE zr_accountingdoc_prt_h.
    DATA:
      lv_orderby_string TYPE string,
      lv_select_string  TYPE string.
    DATA:
      lv_fiscalyear         TYPE  zc_accountingdoc-fiscalyear,
      lv_accountingdocument TYPE  zc_accountingdoc-accountingdocument,
      lv_companycode        TYPE  zc_accountingdoc-companycode.
    "select options
    DATA:
      lr_companycode         TYPE RANGE OF zc_accountingdoc-companycode,
      lrs_companycode        LIKE LINE OF lr_companycode,
      lr_accountingdocument  TYPE RANGE OF zc_accountingdoc-accountingdocument,
      lrs_accountingdocument LIKE LINE OF lr_accountingdocument,
      lr_fiscalyear          TYPE RANGE OF zc_accountingdoc-fiscalyear,
      lrs_fiscalyear         LIKE LINE OF lr_fiscalyear.
    TYPES:
      BEGIN OF ty_sum,
        companycode                 TYPE i_operationalacctgdocitem-companycode,
        fiscalyear                  TYPE i_operationalacctgdocitem-fiscalyear,
        accountingdocument          TYPE i_operationalacctgdocitem-accountingdocument,
        "accountingdocumentitem TYPE i_operationalacctgdocitem-,

        transactioncurrency         TYPE i_operationalacctgdocitem-transactioncurrency,
        debitcreditcode             TYPE i_operationalacctgdocitem-debitcreditcode,
        amountintransactioncurrency TYPE i_operationalacctgdocitem-amountintransactioncurrency,
      END OF ty_sum.
    DATA:ls_sum TYPE ty_sum.
    DATA:lt_sum1 TYPE STANDARD TABLE OF ty_sum.
    DATA:lt_sum2 TYPE STANDARD TABLE OF ty_sum.
    TYPES:
      BEGIN OF ty_results,
        companycode                    TYPE string,
        accountingdocument             TYPE string,
        fiscalyear                     TYPE string,
        accountingdocumentitem         TYPE string,

        parkedbyusername               TYPE string,
        workitem                       TYPE string,
        accountingdocumentcategory     TYPE string,
        createdbyusername              TYPE string,
        accountingdocumentcreationdate TYPE string,
        accountingdocumentstatusname   TYPE string,

      END OF ty_results,
      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,
      BEGIN OF ty_d,
        results TYPE tt_results,
      END OF ty_d,
      BEGIN OF ty_res_api,
        d TYPE ty_d,
      END OF ty_res_api,
      BEGIN OF ty_results1,
        workflowinternalid           TYPE string,

        wrkflwtskcreationutcdatetime TYPE string,
      END OF ty_results1,
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
    DATA:
      lv_calendaryear  TYPE calendaryear,
      lv_calendarmonth TYPE calendarmonth.

    IF io_request->is_data_requested( ).

      TRY.
          "get and add filter
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option) ##NO_HANDLER.

      ENDTRY.
      DATA(lv_top)     = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).
      DATA(lt_fields)  = io_request->get_requested_elements( ).
      DATA(lt_sort)    = io_request->get_sort_elements( ).
*****************************************************************
*       Sort
*****************************************************************
*****************************************************************
*       Filter
*****************************************************************
      READ TABLE lt_filter_cond INTO DATA(ls_companycode_cond) WITH KEY name = 'COMPANYCODE' .
      IF sy-subrc EQ 0.
        LOOP AT ls_companycode_cond-range INTO DATA(ls_sel_opt_companycode).
          MOVE-CORRESPONDING ls_sel_opt_companycode TO lrs_companycode.
          INSERT lrs_companycode INTO TABLE lr_companycode.
          lv_companycode = ls_sel_opt_companycode-low.
        ENDLOOP.
      ENDIF.

      READ TABLE lt_filter_cond INTO DATA(ls_accountingdocument_cond) WITH KEY name = 'ACCOUNTINGDOCUMENT' .
      IF sy-subrc EQ 0.
        LOOP AT ls_accountingdocument_cond-range INTO DATA(ls_sel_opt_accountingdocument).
          MOVE-CORRESPONDING ls_sel_opt_accountingdocument TO lrs_accountingdocument.
          INSERT lrs_accountingdocument INTO TABLE lr_accountingdocument.
          lv_accountingdocument = ls_sel_opt_accountingdocument-low.
        ENDLOOP.
      ENDIF.
      READ TABLE lt_filter_cond INTO DATA(ls_fiscalyear_cond) WITH KEY name = 'FISCALYEAR' .
      IF sy-subrc EQ 0.
        LOOP AT ls_fiscalyear_cond-range INTO DATA(ls_sel_opt_fiscalyear).
          MOVE-CORRESPONDING ls_sel_opt_fiscalyear TO lrs_fiscalyear.
          INSERT lrs_fiscalyear INTO TABLE lr_fiscalyear.
          lv_fiscalyear = ls_sel_opt_fiscalyear-low.
        ENDLOOP.
      ENDIF.

*****************************************************************
*       Check Data
*****************************************************************
*****************************************************************
*       Get Data
*****************************************************************

      SELECT
          companycode,
          fiscalyear,
          accountingdocument,

          documentdate,
          postingdate,
          accountingdocumentheadertext,
          accountingdoccreatedbyuser,
          creationtime,
          accountingdocumentcreationdate,
          lastchangedate,

          ledgergroup ,
          fiscalperiod,
          accountingdocumenttype,
          accountingdocumentcategory
      FROM i_journalentry
      WITH PRIVILEGED ACCESS
     WHERE companycode IN @lr_companycode
      AND accountingdocument IN @lr_accountingdocument
      AND fiscalyear IN @lr_fiscalyear
      INTO TABLE @DATA(lt_journalentry).

      IF lt_journalentry IS NOT INITIAL.

        lv_path = |/YY1_C_GLJRNLENTRYTOBEVERIF_CDS/YY1_C_GLJrnlEntryToBeVerified?$filter=FiscalYear%20eq%20'{ lv_fiscalyear }'%20and%20(%20CompanyCode%20eq%20'{ lv_companycode }'%20and%20AccountingDocument%20eq%20'{ lv_accountingdocument }'%20)|.
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
        IF ls_res_api-d-results IS NOT INITIAL.

          lv_path = |/YY1_WORKFLOWSTATUSOVERVIEW_CDS/YY1_WorkflowStatusOverview?$filter=WorkflowInternalID%20eq%20'{ ls_res_api-d-results[ 1 ]-workitem }'|.
          "Call API
          zzcl_common_utils=>request_api_v2(
            EXPORTING
             iv_path        = lv_path
              iv_method      = if_web_http_client=>get
            IMPORTING
              ev_status_code = DATA(lv_stat_code1)
              ev_response    = DATA(lv_resbody_api1) ).
          TRY.
              "JSON->ABAP
              xco_cp_json=>data->from_string( lv_resbody_api1 )->apply( VALUE #(
                 ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api1 ) ).
            CATCH cx_root INTO DATA(lx_root1) ##NO_HANDLER.
          ENDTRY.
        ENDIF.
        SELECT
        companycode,
        fiscalyear,
        accountingdocument,
        accountingdocumentitem,

        transactioncurrency,
        debitcreditcode ,
        amountintransactioncurrency
        FROM  i_operationalacctgdocitem
        WITH PRIVILEGED ACCESS
        WHERE companycode IN @lr_companycode
        AND accountingdocument IN @lr_accountingdocument
        AND fiscalyear IN @lr_fiscalyear
        INTO TABLE @DATA(lt_operationalacctgdocitem).

        SELECT
        sourceaccountingdocument  AS  accountingdocument,
        sourcecompanycode  AS companycode,
        sourcefiscalyear   AS fiscalyear,
        sourceaccountingdocumentitem AS accountingdocumentitem,

        transactioncurrency ,
        debitcreditcode ,
        amountintransactioncurrency
        "DebitAmountInTransCrcy ,
        "CreditAmountInTransCrcy ,
        FROM i_parkedoplacctgdocitem
         WITH PRIVILEGED ACCESS
          WHERE sourcecompanycode IN @lr_companycode
          AND sourceaccountingdocument IN @lr_accountingdocument
          AND sourcefiscalyear IN @lr_fiscalyear
          AND accountingdocumentcategory = 'V'
          INTO TABLE @DATA(lt_parkedoplacctgdocitem).

        CLEAR lt_sum1.
        LOOP AT lt_operationalacctgdocitem INTO DATA(ls_operationalacctgdocitem).
          CLEAR ls_sum .
          MOVE-CORRESPONDING ls_operationalacctgdocitem TO ls_sum .
          COLLECT ls_sum INTO lt_sum1 .
        ENDLOOP.

        CLEAR lt_sum2.
        LOOP AT lt_parkedoplacctgdocitem INTO DATA(ls_parkedoplacctgdocitem).
          CLEAR ls_sum .
          MOVE-CORRESPONDING ls_parkedoplacctgdocitem TO ls_sum .
          COLLECT ls_sum INTO lt_sum2 .
        ENDLOOP.

        SELECT companycode, companycodename
        FROM i_companycode
        WITH PRIVILEGED ACCESS
        WHERE language = 'J'
        INTO TABLE @DATA(lt_companycode).
        SORT lt_companycode BY companycode.

        SELECT accountingdocumenttype ,accountingdocumenttypename
        FROM i_accountingdocumenttypetext
        WITH PRIVILEGED ACCESS
        WHERE language = 'J'
        INTO TABLE @DATA(lt_accountingdocumenttypetext).
        SORT lt_accountingdocumenttypetext BY accountingdocumenttype.

        LOOP AT lt_journalentry INTO DATA(ls_journalentry).
          CLEAR ls_zr_accountingdoc_prt_h.
          MOVE-CORRESPONDING ls_journalentry TO ls_zr_accountingdoc_prt_h.
          READ TABLE ls_res_api-d-results INTO DATA(ls_result1)
          WITH KEY companycode = ls_zr_accountingdoc_prt_h-companycode
                   fiscalyear = ls_zr_accountingdoc_prt_h-fiscalyear
                   accountingdocument = ls_zr_accountingdoc_prt_h-accountingdocument.
          IF sy-subrc = 0.
            ls_zr_accountingdoc_prt_h-parkedbyusername = ls_result1-parkedbyusername .
            ls_zr_accountingdoc_prt_h-workitem = ls_result1-workitem .
            ls_zr_accountingdoc_prt_h-accountingdoccategory_w  = ls_result1-accountingdocumentcategory  .
            ls_zr_accountingdoc_prt_h-createdbyusername = ls_result1-createdbyusername .
            ls_zr_accountingdoc_prt_h-accountingdoccreationdate_w = ls_result1-accountingdocumentcreationdate .
            ls_zr_accountingdoc_prt_h-accountingdocumentstatusname = ls_result1-accountingdocumentstatusname .
            READ TABLE ls_res_api1-d-results INTO DATA(ls_result11)
            WITH KEY workflowinternalid = ls_zr_accountingdoc_prt_h-workitem .
            IF sy-subrc = 0.
              ls_zr_accountingdoc_prt_h-wrkflwtskcreationutcdatetime = ls_result11-wrkflwtskcreationutcdatetime.
            ENDIF.
          ENDIF.
          READ TABLE lt_sum1 INTO ls_sum
          WITH KEY companycode = ls_zr_accountingdoc_prt_h-companycode
                   fiscalyear = ls_zr_accountingdoc_prt_h-fiscalyear
                   accountingdocument = ls_zr_accountingdoc_prt_h-accountingdocument
                   debitcreditcode = 'S'.
          IF sy-subrc = 0.
            ls_zr_accountingdoc_prt_h-debitamountintranscrcy = ls_sum-amountintransactioncurrency.
            ls_zr_accountingdoc_prt_h-transactioncurrency = ls_sum-transactioncurrency.
          ELSE.
            READ TABLE lt_sum2 INTO ls_sum
            WITH KEY companycode = ls_zr_accountingdoc_prt_h-companycode
               fiscalyear = ls_zr_accountingdoc_prt_h-fiscalyear
               accountingdocument = ls_zr_accountingdoc_prt_h-accountingdocument
               debitcreditcode = 'S'.
            IF sy-subrc = 0.
              ls_zr_accountingdoc_prt_h-debitamountintranscrcy = ls_sum-amountintransactioncurrency.
              ls_zr_accountingdoc_prt_h-transactioncurrency = ls_sum-transactioncurrency.
            ENDIF.
          ENDIF.

          READ TABLE lt_sum1 INTO ls_sum
          WITH KEY companycode = ls_zr_accountingdoc_prt_h-companycode
                   fiscalyear = ls_zr_accountingdoc_prt_h-fiscalyear
                   accountingdocument = ls_zr_accountingdoc_prt_h-accountingdocument
                   debitcreditcode = 'H'.
          IF sy-subrc = 0.
            ls_zr_accountingdoc_prt_h-creditamountintranscrcy = ls_sum-amountintransactioncurrency.
          ELSE.
            READ TABLE lt_sum2 INTO ls_sum
            WITH KEY companycode = ls_zr_accountingdoc_prt_h-companycode
               fiscalyear = ls_zr_accountingdoc_prt_h-fiscalyear
               accountingdocument = ls_zr_accountingdoc_prt_h-accountingdocument
               debitcreditcode = 'H'.
            IF sy-subrc = 0.
              ls_zr_accountingdoc_prt_h-creditamountintranscrcy = ls_sum-amountintransactioncurrency.
            ENDIF.
          ENDIF.
          ls_zr_accountingdoc_prt_h-debitamountintranscrcy = zzcl_common_utils=>conversion_amount(
                                     iv_alpha = 'OUT'
                                     iv_currency = ls_zr_accountingdoc_prt_h-transactioncurrency
                                     iv_input = ls_zr_accountingdoc_prt_h-debitamountintranscrcy ).
          ls_zr_accountingdoc_prt_h-creditamountintranscrcy = zzcl_common_utils=>conversion_amount(
                                     iv_alpha = 'OUT'
                                     iv_currency = ls_zr_accountingdoc_prt_h-transactioncurrency
                                     iv_input = ls_zr_accountingdoc_prt_h-creditamountintranscrcy ).
          "'会社コードテキスト'
          READ TABLE lt_companycode INTO DATA(ls_companycode) WITH KEY companycode = ls_zr_accountingdoc_prt_h-companycode BINARY SEARCH.
          IF sy-subrc = 0.
            ls_zr_accountingdoc_prt_h-companycodetext = ls_companycode-companycodename."'会社コードテキスト'
          ENDIF.
          READ TABLE lt_accountingdocumenttypetext INTO DATA(ls_accountingdocumenttypetext) WITH KEY accountingdocumenttype = ls_zr_accountingdoc_prt_h-accountingdocumenttype BINARY SEARCH.
          IF sy-subrc = 0.
            ls_zr_accountingdoc_prt_h-accountingdocumenttypename = ls_accountingdocumenttypetext-accountingdocumenttypename."'会社コードテキスト'
          ENDIF.
          APPEND ls_zr_accountingdoc_prt_h TO lt_zr_accountingdoc_prt_h.
        ENDLOOP.

      ENDIF.
      " Filtering
      "zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
      "                             CHANGING  ct_data   = lt_zr_accountingdoc_prt_h ).
      "IF io_request->is_total_numb_of_rec_requested(  ) .
      "  io_response->set_total_number_of_records( lines( lt_ZR_ACCOUNTINGDOC_PRT_H ) ).
      "ENDIF.

      "Sort
      "zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
      "                           CHANGING  ct_data  = lt_ZR_ACCOUNTINGDOC_PRT_H ).

      " Paging
      "zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
      "                          CHANGING  ct_data   = lt_ZR_ACCOUNTINGDOC_PRT_H ).



      io_response->set_data( lt_zr_accountingdoc_prt_h ).


    ENDIF.






  ENDMETHOD.
ENDCLASS.
