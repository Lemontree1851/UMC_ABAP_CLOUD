CLASS zcl_accountdoc_prt_i DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ACCOUNTDOC_PRT_I IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA:lt_zr_accountingdoc_prt_i TYPE STANDARD TABLE OF zr_accountingdoc_prt_i.
    DATA:ls_zr_accountingdoc_prt_i TYPE zr_accountingdoc_prt_i.
    DATA:
      lv_orderby_string TYPE string,
      lv_select_string  TYPE string.
    "select options
    DATA:
      lr_companycode         TYPE RANGE OF zc_accountingdoc-companycode,
      lrs_companycode        LIKE LINE OF lr_companycode,
      lr_accountingdocument  TYPE RANGE OF zc_accountingdoc-accountingdocument,
      lrs_accountingdocument LIKE LINE OF lr_accountingdocument,
      lr_fiscalyear          TYPE RANGE OF zc_accountingdoc-fiscalyear,
      lrs_fiscalyear         LIKE LINE OF lr_fiscalyear.
    DATA:
      lv_fiscalyear         TYPE  zc_accountingdoc-fiscalyear,
      lv_accountingdocument TYPE  zc_accountingdoc-accountingdocument,
      lv_companycode        TYPE  zc_accountingdoc-companycode.
    TYPES:
      BEGIN OF ty_results,
        companycode                  TYPE string,
        accountingdocument           TYPE string,
        fiscalyear                   TYPE string,
        accountingdocumentitem       TYPE string,

        companycodename              TYPE string,
        accountingdocumenttype       TYPE string,
        accountingdocumenttypename   TYPE string,
        documentdate                 TYPE string,
        postingdate                  TYPE string,
        accountingdocumentheadertext TYPE string,
        reversedocumentfiscalyear    TYPE string,
        reversedocument              TYPE string,
        glaccount                    TYPE string,
        glaccountname                TYPE string,
        customer                     TYPE string,
        customername                 TYPE string,
        supplier                     TYPE string,
        suppliername                 TYPE string,
        documentitemtext             TYPE string,
        taxcode                      TYPE string,
        profitcenter                 TYPE string,
        costcenter                   TYPE string,
        duecalculationbasedate       TYPE string,
        exchangerate                 TYPE string,
        financialaccounttype         TYPE string,

      END OF ty_results,
      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,
      BEGIN OF ty_d,
        results TYPE tt_results,
      END OF ty_d,
      BEGIN OF ty_res_api,
        d TYPE ty_d,
      END OF ty_res_api,
      BEGIN OF ty_results1,
        companycode                  TYPE bukrs,
        accountingdocument           TYPE belnr_d,
        fiscalyear                   TYPE gjahr,
        accountingdocumentitem       TYPE buzei,

        companycodename              TYPE string,
        accountingdocumenttype       TYPE string,
        accountingdocumenttypename   TYPE string,
        documentdate                 TYPE string,
        postingdate                  TYPE string,
        accountingdocumentheadertext TYPE string,
        reversedocumentfiscalyear    TYPE string,
        reversedocument              TYPE string,
        glaccount                    TYPE hkont,
        glaccountname                TYPE string,
        customer                     TYPE kunnr,
        customername                 TYPE string,
        supplier                     TYPE kunnr,
        suppliername                 TYPE string,
        documentitemtext             TYPE string,
        taxcode                      TYPE string,
        profitcenter                 TYPE string,
        costcenter                   TYPE string,
        duecalculationbasedate       TYPE string,
        exchangerate                 TYPE string,
        financialaccounttype         TYPE string,
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
    IF io_request->is_data_requested( ).

      TRY.
          "get and add filter
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).

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
          lv_companycode = ls_sel_opt_companycode-low.
          INSERT lrs_companycode INTO TABLE lr_companycode.
        ENDLOOP.
      ENDIF.

      READ TABLE lt_filter_cond INTO DATA(ls_accountingdocument_cond) WITH KEY name = 'ACCOUNTINGDOCUMENT' .
      IF sy-subrc EQ 0.
        LOOP AT ls_accountingdocument_cond-range INTO DATA(ls_sel_opt_accountingdocument).
          MOVE-CORRESPONDING ls_sel_opt_accountingdocument TO lrs_accountingdocument.
          lv_accountingdocument = ls_sel_opt_accountingdocument-low.
          INSERT lrs_accountingdocument INTO TABLE lr_accountingdocument.
        ENDLOOP.
      ENDIF.
      READ TABLE lt_filter_cond INTO DATA(ls_fiscalyear_cond) WITH KEY name = 'FISCALYEAR' .
      IF sy-subrc EQ 0.
        LOOP AT ls_fiscalyear_cond-range INTO DATA(ls_sel_opt_fiscalyear).
          MOVE-CORRESPONDING ls_sel_opt_fiscalyear TO lrs_fiscalyear.
          lv_fiscalyear = ls_sel_opt_fiscalyear-low.
          INSERT lrs_fiscalyear INTO TABLE lr_fiscalyear.
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
 "         financialaccounttype,
          ledgergllineitem,
          yy1_f_fins1z01_cob,
          yy1_f_fins1z02_cob,
          yy1_f_fins2z01_cob,
          yy1_f_fins2z02_cob
      FROM i_journalentryitem
      WITH PRIVILEGED ACCESS
      WHERE companycode IN @lr_companycode
      AND accountingdocument IN @lr_accountingdocument
      AND fiscalyear IN @lr_fiscalyear
      AND sourceledger = '0L'
      AND ledger = '0L'
      INTO TABLE @DATA(lt_journalentryitem).

      SELECT
         sourcecompanycode AS companycode,
         sourcefiscalyear AS fiscalyear,
         sourceaccountingdocument AS accountingdocument,
"          financialaccounttype,
         sourceaccountingdocumentitem AS ledgergllineitem
     FROM i_parkedoplacctgdocitem
     WITH PRIVILEGED ACCESS
     WHERE sourcecompanycode IN @lr_companycode
     AND sourceaccountingdocument IN @lr_accountingdocument
     AND sourcefiscalyear IN @lr_fiscalyear
     AND accountingdocumentcategory = 'V'
     APPENDING CORRESPONDING FIELDS OF TABLE @lt_journalentryitem.

      SORT lt_journalentryitem BY companycode fiscalyear accountingdocument.
      DELETE ADJACENT DUPLICATES FROM lt_journalentryitem COMPARING companycode fiscalyear accountingdocument.


      IF lt_journalentryitem IS NOT INITIAL.

*        lv_path = |/YY1_FIXEDASSETCOUNTRYDATA_CDS/YY1_C_GLJrnlEntryToBeVerified|.
*        "Call API
*        zzcl_common_utils=>request_api_v2(
*          EXPORTING
*            iv_path        = lv_path
*            iv_method      = if_web_http_client=>get
*            iv_format      = 'json'
*          IMPORTING
*            ev_status_code = DATA(lv_stat_code)
*            ev_response    = DATA(lv_resbody_api) ).
*        "JSON->ABAP
*        xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
*            ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api ) ).

        lv_path = |/API_OPLACCTGDOCITEMCUBE_SRV/A_OperationalAcctgDocItemCube?$filter=FiscalYear%20eq%20'{ lv_fiscalyear }'%20and%20(%20CompanyCode%20eq%20'{ lv_companycode }'%20and%20AccountingDocument%20eq%20'{ lv_accountingdocument }'%20)|.
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
          CATCH cx_root INTO DATA(lx_root1).
        ENDTRY.
        IF ls_res_api1-d-results IS NOT INITIAL.
          SELECT glaccount,glaccountlongname
          FROM i_glaccounttext WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @ls_res_api1-d-results
          WHERE glaccount = @ls_res_api1-d-results-glaccount
          AND language = 'J'
          INTO TABLE @DATA(lt_glaccounttext).
          SORT lt_glaccounttext BY glaccount  glaccountlongname.

          SELECT customer ,customername
          FROM i_customer WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @ls_res_api1-d-results
          WHERE customer = @ls_res_api1-d-results-customer
          AND language = 'J'
          INTO TABLE @DATA(lt_customer).
          SORT lt_customer BY customer customername.

          SELECT supplier ,suppliername
          FROM i_supplier_vh WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @ls_res_api1-d-results
          WHERE supplier = @ls_res_api1-d-results-supplier
          INTO TABLE @DATA(lt_supplier).
          SORT lt_supplier BY supplier suppliername.




        ENDIF.
        SELECT
          companycode,
          fiscalyear,
          accountingdocument,
          ledgergllineitem,

            transactioncurrency,
            debitamountintranscrcy,
            creditamountintranscrcy,
            masterfixedasset,
            fixedasset,
            companycodecurrency,
            debitamountincocodecrcy,
            creditamountincocodecrcy,
            assignmentreference
        FROM
        i_glaccountlineitem
        WITH PRIVILEGED ACCESS
      WHERE companycode IN @lr_companycode
      AND accountingdocument IN @lr_accountingdocument
      AND fiscalyear IN @lr_fiscalyear
      AND sourceledger = '0L'
      AND ledger = '0L'
        INTO TABLE @DATA(lt_glaccountlineitem).
        SORT lt_glaccountlineitem BY companycode fiscalyear accountingdocument ledgergllineitem.

        IF lt_glaccountlineitem IS NOT INITIAL.

          SELECT
          companycode,
          masterfixedasset,
          fixedasset,
          fixedassetdescription
          FROM i_fixedasset
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_glaccountlineitem
        WHERE companycode = @lt_glaccountlineitem-companycode
        AND masterfixedasset = @lt_glaccountlineitem-masterfixedasset
        AND fixedasset = @lt_glaccountlineitem-fixedasset
          INTO TABLE @DATA(lt_fixedasset).
          SORT lt_fixedasset BY fixedasset.


        ENDIF.

        SELECT
          companycode,
          fiscalyear,
          accountingdocument,
          accountingdocumentitem,
          billofexchangeissuedate,
          billofexchangedomiciletext
        FROM
        i_billofexchange
       WITH PRIVILEGED ACCESS
          WHERE companycode IN @lr_companycode
          AND accountingdocument IN @lr_accountingdocument
          AND fiscalyear IN @lr_fiscalyear
          INTO TABLE @DATA(lt_billofexchange).
        SORT lt_billofexchange BY companycode fiscalyear accountingdocument accountingdocumentitem.



        SELECT
        accountingdocumentcategory,
        sourceaccountingdocument    ,
        sourcecompanycode   ,
        "AccountingDocumentStatusName,
        sourcefiscalyear    ,
        accountingdocumenttype,
        documentdate    ,
        postingdate ,
        "AccountingDocumentHeaderText,
        sourceaccountingdocumentitem ,
        glaccount   ,
        customer    ,
        supplier    ,
        transactioncurrency ,
        debitcreditcode ,
        amountintransactioncurrency ,
        "DebitAmountInTransCrcy ,
        "CreditAmountInTransCrcy ,
        masterfixedasset    ,
        fixedasset  ,
        companycodecurrency ,
        amountincompanycodecurrency,
        "DebitAmountInCoCodeCrcy ,
        "CreditAmountInCoCodeCrcy ,
        documentitemtext ,
        taxcode ,
        profitcenter  ,
        costcenter  ,
        financialaccounttype

        FROM i_parkedoplacctgdocitem
         WITH PRIVILEGED ACCESS
          WHERE sourcecompanycode IN @lr_companycode
          AND sourceaccountingdocument IN @lr_accountingdocument
          AND sourcefiscalyear IN @lr_fiscalyear
          AND accountingdocumentcategory = 'V'
          INTO TABLE @DATA(lt_parkedoplacctgdocitem).

        SORT lt_parkedoplacctgdocitem BY sourcecompanycode sourceaccountingdocument sourcefiscalyear sourceaccountingdocument .

        IF lt_parkedoplacctgdocitem IS NOT INITIAL.
          SELECT glaccount,glaccountlongname
          FROM i_glaccounttext WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_parkedoplacctgdocitem
          WHERE glaccount = @lt_parkedoplacctgdocitem-glaccount
          AND language = 'J'
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_glaccounttext.
          SORT lt_glaccounttext BY glaccount  glaccountlongname.

          SELECT customer ,customername
          FROM i_customer WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_parkedoplacctgdocitem
          WHERE customer = @lt_parkedoplacctgdocitem-customer
          AND language = 'J'
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_customer.
          SORT lt_customer BY customer customername.

          SELECT supplier ,suppliername
          FROM i_supplier_vh WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_parkedoplacctgdocitem
          WHERE supplier = @lt_parkedoplacctgdocitem-supplier
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_supplier.
          SORT lt_supplier BY supplier suppliername.

          SELECT
            companycode,
            masterfixedasset,
            fixedasset,
            fixedassetdescription
          FROM i_fixedasset
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_parkedoplacctgdocitem
          WHERE companycode = @lt_parkedoplacctgdocitem-sourcecompanycode
          AND masterfixedasset = @lt_parkedoplacctgdocitem-masterfixedasset
          AND fixedasset = @lt_parkedoplacctgdocitem-fixedasset
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_fixedasset.
          SORT lt_fixedasset BY fixedasset.
        ENDIF.




        LOOP AT lt_journalentryitem INTO DATA(ls_journalentryitem).

          CLEAR ls_zr_accountingdoc_prt_i.
          ls_zr_accountingdoc_prt_i-companycode = ls_journalentryitem-companycode.
          ls_zr_accountingdoc_prt_i-fiscalyear = ls_journalentryitem-fiscalyear.
          ls_zr_accountingdoc_prt_i-accountingdocument = ls_journalentryitem-accountingdocument.
          ls_zr_accountingdoc_prt_i-ledgergllineitem = ls_journalentryitem-ledgergllineitem.
          ls_zr_accountingdoc_prt_i-yy1_f_fins1z01_cob = ls_journalentryitem-yy1_f_fins1z01_cob.
          ls_zr_accountingdoc_prt_i-yy1_f_fins1z02_cob = ls_journalentryitem-yy1_f_fins1z02_cob.
          ls_zr_accountingdoc_prt_i-yy1_f_fins2z01_cob = ls_journalentryitem-yy1_f_fins2z01_cob.
          ls_zr_accountingdoc_prt_i-yy1_f_fins2z02_cob = ls_journalentryitem-yy1_f_fins2z02_cob.

          READ TABLE ls_res_api1-d-results INTO DATA(ls_result) WITH KEY
          companycode = ls_zr_accountingdoc_prt_i-companycode
          fiscalyear  = ls_zr_accountingdoc_prt_i-fiscalyear
          accountingdocument = ls_zr_accountingdoc_prt_i-accountingdocument
          accountingdocumentitem  = ls_zr_accountingdoc_prt_i-ledgergllineitem.

          IF sy-subrc = 0.               .
            "ls_zr_accountingdoc_prt_i-companycodename                 = ls_result-companycodename                 .
            ls_zr_accountingdoc_prt_i-fiscalyear                      = ls_result-fiscalyear                      .
            "ls_zr_accountingdoc_prt_i-accountingdocumenttype          = ls_result-accountingdocumenttype          .
            "ls_zr_accountingdoc_prt_i-accountingdocumenttypename      = ls_result-accountingdocumenttypename      .
            "ls_zr_accountingdoc_prt_i-documentdate                    = ls_result-documentdate                    .
            "ls_zr_accountingdoc_prt_i-postingdate                     = ls_result-postingdate                     .
            "ls_zr_accountingdoc_prt_i-accountingdocumentheadertext    = ls_result-accountingdocumentheadertext    .
            "ls_zr_accountingdoc_prt_i-reversedocumentfiscalyear       = ls_result-reversedocumentfiscalyear       .
            "ls_zr_accountingdoc_prt_i-reversedocument                 = ls_result-reversedocument                 .
            "ls_zr_accountingdoc_prt_i-accountingdocumentitem          = ls_result-accountingdocumentitem
            .
            ls_zr_accountingdoc_prt_i-glaccount                       = ls_result-glaccount                       .
            ls_zr_accountingdoc_prt_i-glaccountname                   = ls_result-glaccountname                   .
            ls_zr_accountingdoc_prt_i-documentitemtext                = ls_result-documentitemtext                .
            ls_zr_accountingdoc_prt_i-taxcode                         = ls_result-taxcode                         .
            ls_zr_accountingdoc_prt_i-profitcenter                    = ls_result-profitcenter                    .
            ls_zr_accountingdoc_prt_i-costcenter                      = ls_result-costcenter                      .
            ls_zr_accountingdoc_prt_i-exchangerate                    = ls_result-exchangerate                    .
            ls_zr_accountingdoc_prt_i-financialaccounttype            = ls_result-financialaccounttype  .


          ELSE.
            READ TABLE lt_parkedoplacctgdocitem INTO DATA(ls_parkedoplacctgdocument) WITH KEY
            sourcecompanycode = ls_zr_accountingdoc_prt_i-companycode
            sourcefiscalyear  = ls_zr_accountingdoc_prt_i-fiscalyear
            sourceaccountingdocument = ls_zr_accountingdoc_prt_i-accountingdocument
            sourceaccountingdocumentitem  = ls_zr_accountingdoc_prt_i-ledgergllineitem BINARY SEARCH.
            IF sy-subrc = 0.
              "ls_zr_accountingdoc_prt_i-accountingdocumenttype                = ls_parkedoplacctgdocument-accountingdocumenttype              .
              "ls_zr_accountingdoc_prt_i-documentdate                          = ls_parkedoplacctgdocument-documentdate                        .
              "ls_zr_accountingdoc_prt_i-postingdate                           = ls_parkedoplacctgdocument-postingdate                         .
              "ls_zr_accountingdoc_prt_i-accountingdocumentheadertext          = ls_parkedoplacctgdocument-accountingdocumentheadertext        .
              "ls_zr_accountingdoc_prt_i-sourceaccountingdocumentitem          = ls_parkedoplacctgdocument-sourceaccountingdocumentitem        .
              ls_zr_accountingdoc_prt_i-glaccount                             = ls_parkedoplacctgdocument-glaccount                           .
              ls_zr_accountingdoc_prt_i-customer                              = ls_parkedoplacctgdocument-customer                            .
              ls_zr_accountingdoc_prt_i-supplier                              = ls_parkedoplacctgdocument-supplier
                                  .
              ls_zr_accountingdoc_prt_i-transactioncurrency                   = ls_parkedoplacctgdocument-transactioncurrency                 .
              ls_zr_accountingdoc_prt_i-debitcreditcode                       = ls_parkedoplacctgdocument-debitcreditcode                     .
              ls_zr_accountingdoc_prt_i-amountintransactioncurrency           = ls_parkedoplacctgdocument-amountintransactioncurrency         .
              ls_zr_accountingdoc_prt_i-masterfixedasset                      = ls_parkedoplacctgdocument-masterfixedasset                    .
              ls_zr_accountingdoc_prt_i-fixedasset                            = ls_parkedoplacctgdocument-fixedasset                          .
              ls_zr_accountingdoc_prt_i-companycodecurrency                   = ls_parkedoplacctgdocument-companycodecurrency                 .
              ls_zr_accountingdoc_prt_i-amountincompanycodecurrency           = ls_parkedoplacctgdocument-amountincompanycodecurrency         .
              ls_zr_accountingdoc_prt_i-documentitemtext                      = ls_parkedoplacctgdocument-documentitemtext                    .
              ls_zr_accountingdoc_prt_i-taxcode                               = ls_parkedoplacctgdocument-taxcode                             .
              ls_zr_accountingdoc_prt_i-profitcenter                          = ls_parkedoplacctgdocument-profitcenter                        .
              ls_zr_accountingdoc_prt_i-costcenter                            = ls_parkedoplacctgdocument-costcenter                          .
              "ls_zr_accountingdoc_prt_i-absoluteexchangerate                  = ls_parkedoplacctgdocument-absoluteexchangerate                .
              ls_zr_accountingdoc_prt_i-financialaccounttype                  = ls_parkedoplacctgdocument-financialaccounttype                .
              IF  ls_parkedoplacctgdocument-debitcreditcode = 'S'.
                ls_zr_accountingdoc_prt_i-debitamountintranscrcy = ls_parkedoplacctgdocument-amountintransactioncurrency.
              ELSE.
                ls_zr_accountingdoc_prt_i-creditamountintranscrcy = ls_parkedoplacctgdocument-amountintransactioncurrency.
              ENDIF.

              IF ls_zr_accountingdoc_prt_i-transactioncurrency NE ls_zr_accountingdoc_prt_i-companycodecurrency .
                IF  ls_parkedoplacctgdocument-debitcreditcode = 'S'.
                  ls_zr_accountingdoc_prt_i-debitamountincocodecrcy = ls_parkedoplacctgdocument-amountintransactioncurrency.
                ELSE.
                  ls_zr_accountingdoc_prt_i-creditamountincocodecrcy = ls_parkedoplacctgdocument-amountintransactioncurrency.
                ENDIF.

              ELSE.
                CLEAR:
                ls_zr_accountingdoc_prt_i-companycodecurrency,
                ls_zr_accountingdoc_prt_i-debitamountincocodecrcy,
                ls_zr_accountingdoc_prt_i-creditamountincocodecrcy.

              ENDIF.

            ENDIF.
          ENDIF.

          READ TABLE lt_glaccountlineitem INTO DATA(ls_glaccountlineitem) WITH KEY
                    companycode = ls_zr_accountingdoc_prt_i-companycode
          fiscalyear  = ls_zr_accountingdoc_prt_i-fiscalyear
          accountingdocument = ls_zr_accountingdoc_prt_i-accountingdocument
          ledgergllineitem  = ls_zr_accountingdoc_prt_i-ledgergllineitem BINARY SEARCH.
          IF sy-subrc = 0.
            ls_zr_accountingdoc_prt_i-transactioncurrency = ls_glaccountlineitem-transactioncurrency .
            ls_zr_accountingdoc_prt_i-debitamountintranscrcy = ls_glaccountlineitem-debitamountintranscrcy .
            ls_zr_accountingdoc_prt_i-creditamountintranscrcy = ls_glaccountlineitem-creditamountintranscrcy .
            ls_zr_accountingdoc_prt_i-masterfixedasset = ls_glaccountlineitem-masterfixedasset .
            ls_zr_accountingdoc_prt_i-fixedasset = ls_glaccountlineitem-fixedasset .
            ls_zr_accountingdoc_prt_i-companycodecurrency = ls_glaccountlineitem-companycodecurrency.
            ls_zr_accountingdoc_prt_i-debitamountincocodecrcy = ls_glaccountlineitem-debitamountincocodecrcy.
            ls_zr_accountingdoc_prt_i-creditamountincocodecrcy = ls_glaccountlineitem-creditamountincocodecrcy.


            IF ls_glaccountlineitem-transactioncurrency = ls_glaccountlineitem-companycodecurrency.
              CLEAR:
              ls_zr_accountingdoc_prt_i-companycodecurrency,
              ls_zr_accountingdoc_prt_i-debitamountincocodecrcy,
              ls_zr_accountingdoc_prt_i-creditamountincocodecrcy.

            ELSE.
              READ TABLE ls_res_api1-d-results INTO DATA(ls_result2) WITH KEY
                companycode = ls_zr_accountingdoc_prt_i-companycode
                fiscalyear  = ls_zr_accountingdoc_prt_i-fiscalyear
                accountingdocument = ls_zr_accountingdoc_prt_i-accountingdocument
                accountingdocumentitem  = ls_zr_accountingdoc_prt_i-ledgergllineitem.

              IF sy-subrc = 0.
                ls_zr_accountingdoc_prt_i-exchangerate = ls_result2-exchangerate.
              ENDIF.
            ENDIF.

          ENDIF.

          READ TABLE lt_billofexchange INTO DATA(ls_billofexchange) WITH KEY
          companycode = ls_zr_accountingdoc_prt_i-companycode
          fiscalyear  = ls_zr_accountingdoc_prt_i-fiscalyear
          accountingdocument = ls_zr_accountingdoc_prt_i-accountingdocument
          accountingdocumentitem  = ls_zr_accountingdoc_prt_i-ledgergllineitem
          BINARY SEARCH.
          IF sy-subrc = 0.
            ls_zr_accountingdoc_prt_i-billofexchangeissuedate = ls_billofexchange-billofexchangeissuedate .
            ls_zr_accountingdoc_prt_i-billofexchangedomiciletext = ls_billofexchange-billofexchangedomiciletext .
            READ TABLE lt_glaccountlineitem INTO DATA(ls_glaccountlineitem1) WITH KEY
            companycode = ls_zr_accountingdoc_prt_i-companycode
           fiscalyear  = ls_zr_accountingdoc_prt_i-fiscalyear
           accountingdocument = ls_zr_accountingdoc_prt_i-accountingdocument
           ledgergllineitem  = ls_zr_accountingdoc_prt_i-ledgergllineitem BINARY SEARCH.
            IF sy-subrc = 0.
              ls_zr_accountingdoc_prt_i-assignmentreference = ls_glaccountlineitem1-assignmentreference.
            ENDIF.
            READ TABLE ls_res_api1-d-results INTO DATA(ls_result1) WITH KEY
            companycode = ls_zr_accountingdoc_prt_i-companycode
            fiscalyear  = ls_zr_accountingdoc_prt_i-fiscalyear
            accountingdocument = ls_zr_accountingdoc_prt_i-accountingdocument
            accountingdocumentitem  = ls_zr_accountingdoc_prt_i-ledgergllineitem.

            IF sy-subrc = 0.
              ls_zr_accountingdoc_prt_i-duecalculationbasedate = ls_result1-duecalculationbasedate.

            ENDIF.
          ENDIF.
*****************************************************************
*       Description
*****************************************************************
          READ TABLE lt_glaccounttext INTO DATA(ls_glaccounttext) WITH KEY glaccount = ls_zr_accountingdoc_prt_i-glaccount BINARY SEARCH.
          IF sy-subrc = 0.
            ls_zr_accountingdoc_prt_i-glaccountname = ls_glaccounttext-glaccountlongname .
          ENDIF.
          READ TABLE lt_customer INTO DATA(ls_customer) WITH KEY customer = ls_zr_accountingdoc_prt_i-customer BINARY SEARCH.
          IF sy-subrc = 0.
            ls_zr_accountingdoc_prt_i-customername = ls_customer-customername .
          ENDIF.
          READ TABLE lt_supplier INTO DATA(ls_supplier) WITH KEY supplier = ls_zr_accountingdoc_prt_i-supplier BINARY SEARCH.
          IF sy-subrc = 0.
            ls_zr_accountingdoc_prt_i-suppliername = ls_supplier-suppliername .
          ENDIF.
          READ TABLE lt_fixedasset INTO DATA(ls_fixedasset) WITH KEY
          companycode = ls_zr_accountingdoc_prt_i-companycode
          masterfixedasset  = ls_zr_accountingdoc_prt_i-masterfixedasset
          fixedasset = ls_zr_accountingdoc_prt_i-fixedasset.
          IF sy-subrc = 0.
            ls_zr_accountingdoc_prt_i-fixedassetdescription = ls_fixedasset-fixedassetdescription.
          ENDIF.

          IF ls_zr_accountingdoc_prt_i-financialaccounttype = 'D'.
            ls_zr_accountingdoc_prt_i-bp = ls_result-customer .
            ls_zr_accountingdoc_prt_i-bpname = ls_result-customername .
          ELSEIF ls_zr_accountingdoc_prt_i-financialaccounttype = 'K'.
            ls_zr_accountingdoc_prt_i-bp = ls_result-supplier .
            ls_zr_accountingdoc_prt_i-bpname = ls_result-suppliername .
          ENDIF.
          APPEND ls_zr_accountingdoc_prt_i TO lt_zr_accountingdoc_prt_i.

        ENDLOOP.



      ENDIF.
      " Filtering
      "zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
      "                              CHANGING  ct_data   = lt_ZR_ACCOUNTINGDOC_PRT_I ).
      "IF io_request->is_total_numb_of_rec_requested(  ) .
      "  io_response->set_total_number_of_records( lines( lt_ZR_ACCOUNTINGDOC_PRT_I ) ).
      "ENDIF.

      "Sort
      "zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
      "                           CHANGING  ct_data  = lt_ZR_ACCOUNTINGDOC_PRT_I ).

      " Paging
      "zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
      "                          CHANGING  ct_data   = lt_ZR_ACCOUNTINGDOC_PRT_I ).



      io_response->set_data( lt_zr_accountingdoc_prt_i ).





    ELSE.

      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( 1 ).
      ENDIF.

    ENDIF.






  ENDMETHOD.
ENDCLASS.
