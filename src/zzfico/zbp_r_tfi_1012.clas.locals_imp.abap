CLASS lhc_zr_tfi_1012 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF lty_request,
            companycode        TYPE bukrs,
            fiscalyear         TYPE gjahr,
            accountingdocument TYPE belnr_d,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.
    TYPES:BEGIN OF lty_prt_i,
            companycode                 TYPE bukrs,
            fiscalyear                  TYPE belnr_d,
            accountingdocument          TYPE belnr_d,
            ledgergllineitem            TYPE      char3,
            yy1_f_fins1z01_cob          TYPE      char10,
            yy1_f_fins1z02_cob(60)      TYPE      c,
            yy1_f_fins2z01_cob          TYPE      char10,
            yy1_f_fins2z02_cob(60)      TYPE      c,
            glaccount                   TYPE      hkont,
            glaccountname(60)           TYPE      c,
            documentitemtext(60)        TYPE      c,
            taxcode                     TYPE      char5,
            profitcenter                TYPE      char10,
            costcenter                  TYPE      kostl,
            exchangerate                TYPE      prctr,
            financialaccounttype        TYPE      char1,
            customer                    TYPE      kunnr,
            customername(60)            TYPE      c,
            supplier                    TYPE      kunnr,
            suppliername(60)            TYPE      c,
            bp                          TYPE      kunnr,
            bpname(60)                  TYPE      c,
            transactioncurrency         TYPE      waers,
            debitcreditcode             TYPE      shkzg,
            amountintransactioncurrency TYPE      wrbtr,

            debitamountintranscrcy      TYPE      string,
            creditamountintranscrcy     TYPE      string,

            masterfixedasset            TYPE      anln1,
            fixedasset                  TYPE      anln2,
            fixedassetdescription(70)   TYPE      c,
            companycodecurrency         TYPE      waers,
            amountincompanycodecurrency TYPE      wrbtr,

            debitamountincocodecrcy     TYPE      string,
            creditamountincocodecrcy    TYPE      string,

          END OF lty_prt_i.
    TYPES:BEGIN OF lty_prt_h,
            companycode                      TYPE bukrs,
            fiscalyear                       TYPE belnr_d,
            accountingdocument               TYPE belnr_d,
            documentdate                     TYPE    bldat,
            postingdate                      TYPE    bldat,
            accountingdocumentheadertext     TYPE    butxt,
            accountingdoccreatedbyuser       TYPE    string,
            creationtime                     TYPE    uzeit,
            accountingdocumentcreationdate   TYPE    bldat,
            lastchangedate                   TYPE    bldat,
            ledgergroup                      TYPE    char4,
            fiscalperiod                     TYPE    monat,
            accountingdocumenttype           TYPE    blart,
            accountingdocumenttypename       TYPE    char40,
            accountingdocumentcategory       TYPE    char1,
            companycodetext                  TYPE    char25,
            transactioncurrency              TYPE    waers,

            debitamountintranscrcy           TYPE    string,
            creditamountintranscrcy          TYPE    string,

            parkedbyusername                 TYPE    string,
            workitem                         TYPE    p LENGTH 12 DECIMALS 0,
            createdbyusername                TYPE    char80,
            accountingdoccreationdate_w      TYPE    string,
            accountingdoccategory_w          TYPE    char1,
            accountingdocumentstatusname(60) TYPE    c,
            wrkflwtskcreationutcdatetime     TYPE   string,
            reversedocumentfiscalyear        TYPE string,
            reversedocument                  TYPE belnr_d,
            accountingdocumentitem           TYPE char3,
            assignmentreference(18)          TYPE      c,
            billofexchangeissuedate          TYPE      string,
            billofexchangedomiciletext(60)   TYPE      c,
            duecalculationbasedate           TYPE      string,
            page_num                         TYPE i,
            total_page_num                   TYPE i,
            print_user(30)                   TYPE c,
          END OF lty_prt_h.
    TYPES:tt_prt_i TYPE STANDARD TABLE OF lty_prt_i WITH DEFAULT KEY.
    TYPES:BEGIN OF lty_prts,
            companycode        TYPE bukrs,
            fiscalyear         TYPE belnr_d,
            accountingdocument TYPE belnr_d,

            _header            TYPE lty_prt_h,
            _item              TYPE tt_prt_i,
          END OF lty_prts.
    TYPES:tt_prts TYPE STANDARD TABLE OF lty_prts WITH DEFAULT KEY.
    TYPES:BEGIN OF ty_select,
            "HEADER
            companycode                      TYPE    bukrs,
            fiscalyear                       TYPE    gjahr,
            accountingdocument               TYPE    belnr_d,
            documentdate                     TYPE    bldat,
            postingdate                      TYPE    bldat,
            accountingdocumentheadertext     TYPE    butxt,
            accountingdoccreatedbyuser       TYPE    string,
            creationtime                     TYPE    uzeit,
            accountingdocumentcreationdate   TYPE    bldat,
            lastchangedate                   TYPE    bldat,
            ledgergroup                      TYPE    char4,
            fiscalperiod                     TYPE    monat,
            accountingdocumenttype           TYPE    blart,
            accountingdocumenttypename       TYPE    char20,
            accountingdocumentcategory       TYPE    char1,
            companycodetext                  TYPE    char25,
            transactioncurrency              TYPE    waers,
            debitamountintranscrcy           TYPE    wrbtr,
            creditamountintranscrcy          TYPE    wrbtr,
            parkedbyusername                 TYPE    string,
            workitem                         TYPE    p LENGTH 12 DECIMALS 0,
            createdbyusername                TYPE    char80,
            accountingdoccreationdate_w      TYPE    bldat,
            accountingdoccategory_w          TYPE    char1,
            accountingdocumentstatusname(60) TYPE    c,
            wrkflwtskcreationutcdatetime     TYPE    tzntstmpl,
            reversedocumentfiscalyear        TYPE gjahr,
            reversedocument                  TYPE belnr_d,
            "ITEM
            ledgergllineitem                 TYPE      char6,
            yy1_f_fins1z01_cob               TYPE      char10,
            yy1_f_fins1z02_cob(50)           TYPE      c,
            yy1_f_fins2z01_cob               TYPE      char10,
            yy1_f_fins2z02_cob(50)           TYPE      c,
            glaccount                        TYPE      hkont,
            glaccountname(50)                TYPE      c,
            documentitemtext(50)             TYPE      c,
            taxcode                          TYPE      char5,
            profitcenter                     TYPE      char10,
            costcenter                       TYPE      kostl,
            exchangerate                     TYPE      prctr,
            financialaccounttype             TYPE      char1,
            customer                         TYPE      kunnr,
            customername(50)                 TYPE      c,
            supplier                         TYPE      kunnr,
            suppliername(50)                 TYPE      c,
            bp                               TYPE      kunnr,
            bpname(50)                       TYPE      c,
            transactioncurrency_i            TYPE      waers,
            debitcreditcode                  TYPE      shkzg,
            amountintransactioncurrency      TYPE      wrbtr,
            debitamountintranscrcy_i         TYPE      wrbtr,
            creditamountintranscrcy_i        TYPE      wrbtr,
            masterfixedasset                 TYPE      anln1,
            fixedasset                       TYPE      anln2,
            fixedassetdescription(50)        TYPE      c,
            companycodecurrency              TYPE      waers,
            amountincompanycodecurrency      TYPE      wrbtr,
            debitamountincocodecrcy          TYPE      wrbtr,
            creditamountincocodecrcy         TYPE      wrbtr,
            accountingdocumentitem           TYPE      char6,
            assignmentreference(18)          TYPE      c,
            billofexchangeissuedate          TYPE      datum,
            billofexchangedomiciletext(60)   TYPE      c,
            duecalculationbasedate           TYPE      datum,
            print_user                       TYPE string,
          END OF ty_select.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zrtfi1012
        RESULT result,

      get_prts  IMPORTING ct_request TYPE lty_request_t
                CHANGING  ct_print   TYPE tt_prts,
      createprintfile FOR MODIFY
        IMPORTING keys FOR ACTION zrtfi1012~createprintfile RESULT result.
ENDCLASS.

CLASS lhc_zr_tfi_1012 IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD createprintfile.
    DATA: lt_request TYPE TABLE OF lty_request,
          lt_export  TYPE TABLE OF lty_request.
    DATA:ls_record TYPE zzr_prt_record.
    DATA:lv_xml_s    TYPE string.
    DATA:lv_xml    TYPE xstring.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA:lv_xml_xstring TYPE xstring.
    DATA:lt_print TYPE tt_prts.

    GET TIME STAMP FIELD lv_timestamp.

    SELECT SINGLE templateuuid,
           servicedefinitionname,
           xdpcontent
      FROM zzr_prt_template
     WHERE templateid = 'YY1_TEST1'
      INTO @DATA(ls_template).

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc = 0.

      CLEAR lt_request.

      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).


      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
          cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = lv_uuid
                                                   IMPORTING uuid_c36 = DATA(lv_recorduuid)  ).
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.
      ls_record-pdfmimetype = 'application/pdf'.
      ls_record-pdffilename = |{ lv_recorduuid }.pdf |.

      ls_record-datamimetype = 'application/xml'.
      ls_record-datafilename = 'data.xml'.

      get_prts( EXPORTING ct_request = lt_request
 CHANGING ct_print = lt_print ).


      CALL TRANSFORMATION ztrans_accountdoc
         SOURCE zr_accountingdoc_prts = lt_print
         RESULT XML lv_xml_xstring.

      lv_xml = lv_xml_xstring.
      " render pdf
      TRY.
          cl_fp_ads_util=>render_pdf(
            EXPORTING
              iv_locale       = 'en_us'
              iv_xdp_layout   = ls_template-xdpcontent
              iv_xml_data     = lv_xml
            IMPORTING
              ev_pdf          = ls_record-pdfcontent ).
        CATCH cx_fp_ads_util INTO DATA(lo_ads_error).
          "lv_has_error = abap_true.
          "lv_message = lo_ads_error->get_longtext(  ).
      ENDTRY.
      INSERT INTO zzt_prt_record  VALUES @( VALUE #(
                                            record_uuid                = lv_uuid
                                            template_uuid              = ls_template-templateuuid
                                            is_external_provided_data  = abap_true
                                            data_mime_type             =  ls_record-datamimetype
                                            data_file_name             =  ls_record-datafilename
                                            external_provided_data     =  lv_xml
                                            "provided_keys             : zze_zzkey;
                                            pdf_mime_type              =   ls_record-pdfmimetype
                                            pdf_file_name              =  ls_record-pdffilename
                                            pdf_content                =   ls_record-pdfcontent
                                            created_by      = sy-uname
                                            created_at      = lv_timestamp
                                            last_changed_by = sy-uname
                                            last_changed_at = lv_timestamp
                                            local_last_changed_at = lv_timestamp ) ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( zzkey      = key-%param-zzkey
                                        recorduuid = lv_recorduuid ) ) TO result.


    ENDIF.

  ENDMETHOD.
  METHOD get_prts .
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
    TYPES:
      BEGIN OF ty_results2,
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
      END OF ty_results2,
      tt_results2 TYPE STANDARD TABLE OF ty_results2 WITH DEFAULT KEY,
      BEGIN OF ty_d2,
        results TYPE tt_results2,
      END OF ty_d2,
      BEGIN OF ty_res_api2,
        d TYPE ty_d2,
      END OF ty_res_api2.
    DATA:ls_res_api2 TYPE ty_res_api2.
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
    DATA:lt_sum3 TYPE STANDARD TABLE OF ty_sum.
    DATA:ls_select TYPE ty_select.
    DATA:lt_select TYPE STANDARD TABLE OF ty_select.

*****************************************************************
*       Filter
*****************************************************************
    "select options
    DATA:
      lr_companycode         TYPE RANGE OF zc_accountingdoc-companycode,
      lrs_companycode        LIKE LINE OF lr_companycode,
      lr_accountingdocument  TYPE RANGE OF zc_accountingdoc-accountingdocument,
      lrs_accountingdocument LIKE LINE OF lr_accountingdocument,
      lr_fiscalyear          TYPE RANGE OF zc_accountingdoc-fiscalyear,
      lrs_fiscalyear         LIKE LINE OF lr_fiscalyear.

    CLEAR :lr_companycode,   lr_accountingdocument   ,lr_fiscalyear  .
    LOOP AT ct_request INTO DATA(ls_request).
      lrs_companycode-low    = ls_request-companycode.
      lrs_companycode-sign   = 'I'.
      lrs_companycode-option = 'EQ'.
      INSERT lrs_companycode INTO TABLE lr_companycode.

      lrs_fiscalyear-low    = ls_request-fiscalyear.
      lrs_fiscalyear-sign   = 'I'.
      lrs_fiscalyear-option = 'EQ'.
      INSERT lrs_fiscalyear INTO TABLE lr_fiscalyear.

      lrs_accountingdocument-low    = |{ ls_request-accountingdocument ALPHA = IN }| .
      lrs_accountingdocument-sign   = 'I'.
      lrs_accountingdocument-option = 'EQ'.
      INSERT lrs_accountingdocument INTO TABLE lr_accountingdocument.

    ENDLOOP.
*****************************************************************
*       Get Data
*****************************************************************
*****************************************************************
*      HEAD Data
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
        accountingdocumentcategory,
        reversedocument,
        reversedocumentfiscalyear
    FROM i_journalentry
    WITH PRIVILEGED ACCESS
   WHERE companycode IN @lr_companycode
    AND accountingdocument IN @lr_accountingdocument
    AND fiscalyear IN @lr_fiscalyear
    INTO TABLE @DATA(lt_journalentry).
    SORT lt_journalentry BY companycode fiscalyear accountingdocument.

    IF lt_journalentry IS NOT INITIAL.

      lv_path = |/YY1_C_GLJRNLENTRYTOBEVERIF_CDS/YY1_C_GLJrnlEntryToBeVerif|.
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
        TRY.
            "JSON->ABAP
            xco_cp_json=>data->from_string( lv_resbody_api1 )->apply( VALUE #(
               ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api1 ) ).
          CATCH cx_root INTO DATA(lx_root1).
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
      SORT lt_operationalacctgdocitem BY companycode fiscalyear accountingdocument accountingdocumentitem.

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

      SELECT
          companycode,
          fiscalyear,
          accountingdocument,
          ledgergllineitem,

         companycodecurrency,
         amountincompanycodecurrency,
         transactioncurrency ,
        debitcreditcode ,
        amountintransactioncurrency
        FROM
        i_glaccountlineitem
        WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_journalentry
        WHERE companycode = @lt_journalentry-companycode
        AND fiscalyear = @lt_journalentry-fiscalyear
        AND accountingdocument = @lt_journalentry-accountingdocument
        INTO TABLE @DATA(lt_glaccountlineitem_h).
      LOOP AT lt_glaccountlineitem_h INTO DATA(ls_glaccountlineitem_h).
        CLEAR ls_sum .
        MOVE-CORRESPONDING ls_glaccountlineitem_h TO ls_sum .
        COLLECT ls_sum INTO lt_sum3 .
      ENDLOOP.
*****************************************************************
*      ITEM Data
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

      SORT lt_journalentryitem BY companycode fiscalyear accountingdocument ledgergllineitem.
      DELETE ADJACENT DUPLICATES FROM lt_journalentryitem COMPARING companycode fiscalyear accountingdocument ledgergllineitem.

      IF lt_journalentryitem IS NOT INITIAL.

*        lv_path = |/API_OPLACCTGDOCITEMCUBE_SRV/A_OperationalAcctgDocItemCube|.
*        "Call API
*        zzcl_common_utils=>request_api_v2(
*          EXPORTING
*           iv_path        = lv_path
*            iv_method      = if_web_http_client=>get
*          IMPORTING
*            ev_status_code = DATA(lv_stat_code2)
*            ev_response    = DATA(lv_resbody_api2) ).
*        TRY.
*            "JSON->ABAP
*            xco_cp_json=>data->from_string( lv_resbody_api2 )->apply( VALUE #(
*               ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api2 ) ).
*          CATCH cx_root INTO DATA(lx_root2).
*        ENDTRY.

        SELECT
        companycode,
        fiscalyear,
        accountingdocument,
        accountingdocumentitem,
        "companycodename             ,
        accountingdocumenttype      ,
        "accountingdocumenttypename  ,
        documentdate                ,
        postingdate                 ,
        "accountingdocumentheadertext,
        "reversedocumentfiscalyear   ,
        "reversedocument             ,
        glaccount                   ,
        "glaccountname               ,
        customer                    ,
        "customername                ,
        supplier                    ,
        "suppliername                ,
        documentitemtext            ,
        taxcode                     ,
        profitcenter                ,
        costcenter                  ,
        duecalculationbasedate      ,
        "exchangerate                ,
        financialaccounttype

        FROM  i_operationalacctgdocitem
        WITH PRIVILEGED ACCESS
        WHERE companycode IN @lr_companycode
        AND accountingdocument IN @lr_accountingdocument
        AND fiscalyear IN @lr_fiscalyear
        INTO TABLE @DATA(lt_operationalacctgdocitem_i).
        SORT lt_operationalacctgdocitem_i BY companycode fiscalyear accountingdocument accountingdocumentitem.

        IF lt_operationalacctgdocitem_i IS NOT INITIAL.
          SELECT glaccount,glaccountlongname
          FROM i_glaccounttext WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_operationalacctgdocitem_i
          WHERE glaccount = @lt_operationalacctgdocitem_i-glaccount
          AND language = 'J'
          INTO TABLE @DATA(lt_glaccounttext).
          SORT lt_glaccounttext BY glaccount  glaccountlongname.

          SELECT customer ,customername
          FROM i_customer WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_operationalacctgdocitem_i
          WHERE customer = @lt_operationalacctgdocitem_i-customer
          AND language = 'J'
          INTO TABLE @DATA(lt_customer).
          SORT lt_customer BY customer customername.

          SELECT supplier ,suppliername
          FROM i_supplier_vh WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_operationalacctgdocitem_i
          WHERE supplier = @lt_operationalacctgdocitem_i-supplier
          INTO TABLE @DATA(lt_supplier).
          SORT lt_supplier BY supplier suppliername.

        ENDIF.

        SELECT
          companycode,
          fiscalyear,
          accountingdocument,
          ledgergllineitem,

            glaccount,

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

          SELECT glaccount,glaccountlongname
            FROM i_glaccounttext WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_glaccountlineitem
            WHERE glaccount = @lt_glaccountlineitem-glaccount
            AND language = 'J'
            APPENDING CORRESPONDING FIELDS OF TABLE @lt_glaccounttext.
          SORT lt_glaccounttext BY glaccount  glaccountlongname.

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
          INTO TABLE @DATA(lt_parkedoplacctgdocitem_i).

        SORT lt_parkedoplacctgdocitem_i BY sourcecompanycode sourceaccountingdocument sourcefiscalyear sourceaccountingdocument .

        IF lt_parkedoplacctgdocitem_i IS NOT INITIAL.
          SELECT glaccount,glaccountlongname
          FROM i_glaccounttext WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_parkedoplacctgdocitem_i
          WHERE glaccount = @lt_parkedoplacctgdocitem_i-glaccount
          AND language = 'J'
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_glaccounttext.
          SORT lt_glaccounttext BY glaccount  glaccountlongname.

          SELECT customer ,customername
          FROM i_customer WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_parkedoplacctgdocitem_i
          WHERE customer = @lt_parkedoplacctgdocitem_i-customer
          AND language = 'J'
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_customer.
          SORT lt_customer BY customer customername.

          SELECT supplier ,suppliername
          FROM i_supplier_vh WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_parkedoplacctgdocitem_i
          WHERE supplier = @lt_parkedoplacctgdocitem_i-supplier
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_supplier.
          SORT lt_supplier BY supplier suppliername.

          SELECT
            companycode,
            masterfixedasset,
            fixedasset,
            fixedassetdescription
          FROM i_fixedasset
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_parkedoplacctgdocitem_i
          WHERE companycode = @lt_parkedoplacctgdocitem_i-sourcecompanycode
          AND masterfixedasset = @lt_parkedoplacctgdocitem_i-masterfixedasset
          AND fixedasset = @lt_parkedoplacctgdocitem_i-fixedasset
          APPENDING CORRESPONDING FIELDS OF TABLE @lt_fixedasset.
          SORT lt_fixedasset BY fixedasset.

        ENDIF.


        SELECT
        *
        FROM i_user
        WITH PRIVILEGED ACCESS
        INTO TABLE @DATA(lt_user).
        SORT lt_user BY userid.

        LOOP AT lt_journalentryitem INTO DATA(ls_journalentryitem).
          CLEAR ls_select.
          ls_select-companycode = ls_journalentryitem-companycode.
          ls_select-fiscalyear = ls_journalentryitem-fiscalyear.
          ls_select-accountingdocument = ls_journalentryitem-accountingdocument.
          ls_select-ledgergllineitem = ls_journalentryitem-ledgergllineitem.
*****************************************************************
*       HEAD MAPPING
*****************************************************************
          READ TABLE lt_journalentry INTO DATA(ls_journalentry) WITH KEY companycode = ls_select-companycode
                   fiscalyear = ls_select-fiscalyear
                   accountingdocument = ls_select-accountingdocument BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-documentdate                          =      ls_journalentry-documentdate                         .
            ls_select-postingdate                           =      ls_journalentry-postingdate                          .
            ls_select-accountingdocumentheadertext          =      ls_journalentry-accountingdocumentheadertext         .
            ls_select-accountingdoccreatedbyuser            =      ls_journalentry-accountingdoccreatedbyuser           .
            ls_select-creationtime                          =      ls_journalentry-creationtime                         .
            ls_select-accountingdocumentcreationdate        =      ls_journalentry-accountingdocumentcreationdate       .
            ls_select-lastchangedate                        =      ls_journalentry-lastchangedate                       .
            ls_select-ledgergroup                           =      ls_journalentry-ledgergroup                          .
            ls_select-fiscalperiod                          =      ls_journalentry-fiscalperiod                         .
            ls_select-accountingdocumenttype                =      ls_journalentry-accountingdocumenttype               .
            ls_select-accountingdocumentcategory            =      ls_journalentry-accountingdocumentcategory           .
            ls_select-reversedocumentfiscalyear            = ls_journalentry-reversedocumentfiscalyear.
            ls_select-reversedocument            = ls_journalentry-reversedocument.

          ENDIF.

          READ TABLE ls_res_api-d-results INTO DATA(ls_result1)
          WITH KEY companycode = ls_select-companycode
                   fiscalyear = ls_select-fiscalyear
                   accountingdocument = ls_select-accountingdocument.
          IF sy-subrc = 0.
            ls_select-parkedbyusername = ls_result1-parkedbyusername .
            ls_select-workitem = ls_result1-workitem .
            ls_select-accountingdoccategory_w  = ls_result1-accountingdocumentcategory  .
            ls_select-createdbyusername = ls_result1-createdbyusername .
            ls_select-accountingdoccreationdate_w = ls_result1-accountingdocumentcreationdate .
            ls_select-accountingdocumentstatusname = ls_result1-accountingdocumentstatusname .
            READ TABLE ls_res_api1-d-results INTO DATA(ls_result11)
            WITH KEY workflowinternalid = ls_select-workitem .
            IF sy-subrc = 0.
              ls_select-wrkflwtskcreationutcdatetime = ls_result11-wrkflwtskcreationutcdatetime.
            ENDIF.
          ENDIF.
          READ TABLE lt_sum1 INTO ls_sum
          WITH KEY companycode = ls_select-companycode
                   fiscalyear = ls_select-fiscalyear
                   accountingdocument = ls_select-accountingdocument
                   debitcreditcode = 'S'.
          IF sy-subrc = 0.
            ls_select-debitamountintranscrcy = ls_sum-amountintransactioncurrency.
            ls_select-transactioncurrency = ls_sum-transactioncurrency.
          ELSE.
            READ TABLE lt_sum2 INTO ls_sum
            WITH KEY companycode = ls_select-companycode
               fiscalyear = ls_select-fiscalyear
               accountingdocument = ls_select-accountingdocument
               debitcreditcode = 'S'.
            IF sy-subrc = 0.
              ls_select-debitamountintranscrcy = ls_sum-amountintransactioncurrency.
              ls_select-transactioncurrency = ls_sum-transactioncurrency.
            ELSE.
              READ TABLE lt_sum3 INTO ls_sum
WITH KEY companycode = ls_select-companycode
   fiscalyear = ls_select-fiscalyear
   accountingdocument = ls_select-accountingdocument
   debitcreditcode = 'S'.
              IF sy-subrc = 0.
                ls_select-debitamountintranscrcy = ls_sum-amountintransactioncurrency.
                ls_select-transactioncurrency = ls_sum-transactioncurrency.
              ENDIF.
            ENDIF.
          ENDIF.

          READ TABLE lt_sum1 INTO ls_sum
          WITH KEY companycode = ls_select-companycode
                   fiscalyear = ls_select-fiscalyear
                   accountingdocument = ls_select-accountingdocument
                   debitcreditcode = 'H'.
          IF sy-subrc = 0.
            ls_select-creditamountintranscrcy = ls_sum-amountintransactioncurrency.
          ELSE.
            READ TABLE lt_sum2 INTO ls_sum
            WITH KEY companycode = ls_select-companycode
               fiscalyear = ls_select-fiscalyear
               accountingdocument = ls_select-accountingdocument
               debitcreditcode = 'H'.
            IF sy-subrc = 0.
              ls_select-creditamountintranscrcy = ls_sum-amountintransactioncurrency.
            ELSE.
              READ TABLE lt_sum3 INTO ls_sum
WITH KEY companycode = ls_select-companycode
   fiscalyear = ls_select-fiscalyear
   accountingdocument = ls_select-accountingdocument
   debitcreditcode = 'H'.
              IF sy-subrc = 0.
                ls_select-creditamountintranscrcy = ls_sum-amountintransactioncurrency.
              ENDIF.
            ENDIF.
          ENDIF.
          ls_select-debitamountintranscrcy = zzcl_common_utils=>conversion_amount(
                                     iv_alpha = 'OUT'
                                     iv_currency = ls_select-transactioncurrency
                                     iv_input = ls_select-debitamountintranscrcy ).
          ls_select-creditamountintranscrcy = zzcl_common_utils=>conversion_amount(
                                     iv_alpha = 'OUT'
                                     iv_currency = ls_select-transactioncurrency
                                     iv_input = ls_select-creditamountintranscrcy ).
          "'会社コードテキスト'
          READ TABLE lt_companycode INTO DATA(ls_companycode) WITH KEY companycode = ls_select-companycode BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-companycodetext = ls_companycode-companycodename."'会社コードテキスト'
          ENDIF.
          READ TABLE lt_accountingdocumenttypetext INTO DATA(ls_accountingdocumenttypetext) WITH KEY accountingdocumenttype = ls_select-accountingdocumenttype BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-accountingdocumenttypename = ls_accountingdocumenttypetext-accountingdocumenttypename."'会社コードテキスト'
          ENDIF.
*****************************************************************
*       ITEM MAPPING
*****************************************************************

          ls_select-yy1_f_fins1z01_cob = ls_journalentryitem-yy1_f_fins1z01_cob.
          ls_select-yy1_f_fins1z02_cob = ls_journalentryitem-yy1_f_fins1z02_cob.
          ls_select-yy1_f_fins2z01_cob = ls_journalentryitem-yy1_f_fins2z01_cob.
          ls_select-yy1_f_fins2z02_cob = ls_journalentryitem-yy1_f_fins2z02_cob.

          READ TABLE lt_operationalacctgdocitem_i INTO DATA(ls_result2) WITH KEY
          companycode = ls_select-companycode
          fiscalyear  = ls_select-fiscalyear
          accountingdocument = ls_select-accountingdocument
          accountingdocumentitem  = ls_select-ledgergllineitem.

          IF sy-subrc = 0.               .
            ls_select-fiscalyear                      = ls_result2-fiscalyear                      .
            ls_select-glaccount                       = ls_result2-glaccount                       .
            "ls_select-glaccountname                   = ls_result2-glaccountname                   .
            ls_select-documentitemtext                = ls_result2-documentitemtext                .
            ls_select-taxcode                         = ls_result2-taxcode                         .
            ls_select-profitcenter                    = ls_result2-profitcenter                    .
            ls_select-costcenter                      = ls_result2-costcenter                      .
            "ls_select-exchangerate                    = ls_result2-exchangerate                    .
            ls_select-financialaccounttype            = ls_result2-financialaccounttype  .

          ELSE.
            READ TABLE lt_parkedoplacctgdocitem_i INTO DATA(ls_parkedoplacctgdocument_i) WITH KEY
            sourcecompanycode = ls_select-companycode
            sourcefiscalyear  = ls_select-fiscalyear
            sourceaccountingdocument = ls_select-accountingdocument
            sourceaccountingdocumentitem  = ls_select-ledgergllineitem BINARY SEARCH.
            IF sy-subrc = 0.
              ls_select-glaccount                             = ls_parkedoplacctgdocument_i-glaccount                           .
              ls_select-customer                              = ls_parkedoplacctgdocument_i-customer                            .
              ls_select-supplier                              = ls_parkedoplacctgdocument_i-supplier
                                  .
              ls_select-transactioncurrency_i                   = ls_parkedoplacctgdocument_i-transactioncurrency                 .
              ls_select-debitcreditcode                       = ls_parkedoplacctgdocument_i-debitcreditcode                     .
              ls_select-amountintransactioncurrency           = ls_parkedoplacctgdocument_i-amountintransactioncurrency         .
              ls_select-masterfixedasset                      = ls_parkedoplacctgdocument_i-masterfixedasset                    .
              ls_select-fixedasset                            = ls_parkedoplacctgdocument_i-fixedasset                          .
              ls_select-companycodecurrency                   = ls_parkedoplacctgdocument_i-companycodecurrency                 .
              ls_select-amountincompanycodecurrency           = ls_parkedoplacctgdocument_i-amountincompanycodecurrency         .
              ls_select-documentitemtext                      = ls_parkedoplacctgdocument_i-documentitemtext                    .
              ls_select-taxcode                               = ls_parkedoplacctgdocument_i-taxcode                             .
              ls_select-profitcenter                          = ls_parkedoplacctgdocument_i-profitcenter                        .
              ls_select-costcenter                            = ls_parkedoplacctgdocument_i-costcenter                          .
              "ls_select-absoluteexchangerate                  = ls_parkedoplacctgdocument-absoluteexchangerate                .
              ls_select-financialaccounttype                  = ls_parkedoplacctgdocument_i-financialaccounttype                .
              IF  ls_parkedoplacctgdocument_i-debitcreditcode = 'S'.
                ls_select-debitamountintranscrcy_i = ls_parkedoplacctgdocument_i-amountintransactioncurrency.
              ELSE.
                ls_select-creditamountintranscrcy_i = ls_parkedoplacctgdocument_i-amountintransactioncurrency.
              ENDIF.

              IF ls_select-transactioncurrency NE ls_select-companycodecurrency .
                IF  ls_parkedoplacctgdocument_i-debitcreditcode = 'S'.
                  ls_select-debitamountincocodecrcy = ls_parkedoplacctgdocument_i-amountintransactioncurrency.
                ELSE.
                  ls_select-creditamountincocodecrcy = ls_parkedoplacctgdocument_i-amountintransactioncurrency.
                ENDIF.

              ELSE.
                CLEAR:
                ls_select-companycodecurrency,
                ls_select-debitamountincocodecrcy,
                ls_select-creditamountincocodecrcy.

              ENDIF.

            ENDIF.
          ENDIF.

          READ TABLE lt_glaccountlineitem INTO DATA(ls_glaccountlineitem) WITH KEY
                    companycode = ls_select-companycode
          fiscalyear  = ls_select-fiscalyear
          accountingdocument = ls_select-accountingdocument
          ledgergllineitem  = ls_select-ledgergllineitem BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-transactioncurrency_i = ls_glaccountlineitem-transactioncurrency .
            ls_select-debitamountintranscrcy_i = ls_glaccountlineitem-debitamountintranscrcy .
            ls_select-creditamountintranscrcy_i = ls_glaccountlineitem-creditamountintranscrcy .
            ls_select-masterfixedasset = ls_glaccountlineitem-masterfixedasset .
            ls_select-fixedasset = ls_glaccountlineitem-fixedasset .
            ls_select-companycodecurrency = ls_glaccountlineitem-companycodecurrency.
            ls_select-debitamountincocodecrcy = ls_glaccountlineitem-debitamountincocodecrcy.
            ls_select-creditamountincocodecrcy = ls_glaccountlineitem-creditamountincocodecrcy.

            IF ls_select-glaccount IS INITIAL.
              ls_select-glaccount = ls_glaccountlineitem-glaccount.
            ENDIF.

            IF ls_glaccountlineitem-transactioncurrency = ls_glaccountlineitem-companycodecurrency.
              CLEAR:
              ls_select-companycodecurrency,
              ls_select-debitamountincocodecrcy,
              ls_select-creditamountincocodecrcy.

            ELSE.
              READ TABLE lt_operationalacctgdocitem_i INTO ls_result2 WITH KEY
                companycode = ls_select-companycode
                fiscalyear  = ls_select-fiscalyear
                accountingdocument = ls_select-accountingdocument
                accountingdocumentitem  = ls_select-ledgergllineitem.

              IF sy-subrc = 0.
                "ls_select-exchangerate = ls_result2-exchangerate.
              ENDIF.
            ENDIF.

          ENDIF.

          READ TABLE lt_billofexchange INTO DATA(ls_billofexchange) WITH KEY
          companycode = ls_select-companycode
          fiscalyear  = ls_select-fiscalyear
          accountingdocument = ls_select-accountingdocument
          BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-accountingdocumentitem = ls_billofexchange-accountingdocumentitem .
            ls_select-billofexchangeissuedate = ls_billofexchange-billofexchangeissuedate .
            ls_select-billofexchangedomiciletext = ls_billofexchange-billofexchangedomiciletext .
            READ TABLE lt_glaccountlineitem INTO DATA(ls_glaccountlineitem1) WITH KEY
            companycode = ls_select-companycode
           fiscalyear  = ls_select-fiscalyear
           accountingdocument = ls_select-accountingdocument
           ledgergllineitem  = ls_select-ledgergllineitem BINARY SEARCH.
            IF sy-subrc = 0.
              ls_select-assignmentreference = ls_glaccountlineitem1-assignmentreference.
            ENDIF.
            READ TABLE lt_operationalacctgdocitem_i INTO ls_result2 WITH KEY
            companycode = ls_select-companycode
            fiscalyear  = ls_select-fiscalyear
            accountingdocument = ls_select-accountingdocument
            accountingdocumentitem  = ls_select-ledgergllineitem.

            IF sy-subrc = 0.
              ls_select-duecalculationbasedate = ls_result2-duecalculationbasedate.

            ENDIF.
          ENDIF.
          ls_select-debitamountintranscrcy_i = zzcl_common_utils=>conversion_amount(
                           iv_alpha = 'OUT'
                           iv_currency = ls_select-transactioncurrency_i
                           iv_input = ls_select-debitamountintranscrcy_i ).
          ls_select-creditamountintranscrcy_i = zzcl_common_utils=>conversion_amount(
                                     iv_alpha = 'OUT'
                                     iv_currency = ls_select-transactioncurrency_i
                                     iv_input = ls_select-creditamountintranscrcy_i ).
*****************************************************************
*       Description
*****************************************************************
          READ TABLE lt_glaccounttext INTO DATA(ls_glaccounttext) WITH KEY glaccount = ls_select-glaccount BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-glaccountname = ls_glaccounttext-glaccountlongname .
          ENDIF.
          READ TABLE lt_customer INTO DATA(ls_customer) WITH KEY customer = ls_select-customer BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-customername = ls_customer-customername .
          ENDIF.
          READ TABLE lt_supplier INTO DATA(ls_supplier) WITH KEY supplier = ls_select-supplier BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-suppliername = ls_supplier-suppliername .
          ENDIF.
          READ TABLE lt_fixedasset INTO DATA(ls_fixedasset) WITH KEY
          companycode = ls_select-companycode
          masterfixedasset  = ls_select-masterfixedasset
          fixedasset = ls_select-fixedasset.
          IF sy-subrc = 0.
            ls_select-fixedassetdescription = ls_fixedasset-fixedassetdescription.
          ENDIF.

          IF ls_select-financialaccounttype = 'D'.
            ls_select-bp = ls_result2-customer .
            ls_select-bpname = ls_select-customername .
          ELSEIF ls_select-financialaccounttype = 'K'.
            ls_select-bp = ls_result2-supplier .
            ls_select-bpname = ls_select-suppliername .
          ENDIF.

          READ TABLE lt_user INTO DATA(ls_user) WITH KEY userid = ls_select-createdbyusername BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-createdbyusername = ls_user-userdescription.
          ENDIF.
          READ TABLE lt_user INTO ls_user WITH KEY userid = ls_select-accountingdoccreatedbyuser BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-accountingdoccreatedbyuser = ls_user-userdescription.
          ENDIF.
          READ TABLE lt_user INTO ls_user WITH KEY userid = ls_select-parkedbyusername BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-parkedbyusername = ls_user-userdescription.
          ENDIF.
          READ TABLE lt_user INTO ls_user WITH KEY userid = sy-uname BINARY SEARCH.
          IF sy-subrc = 0.
            ls_select-print_user = sy-uname && ` `  && ls_user-userdescription.
          ENDIF.

          APPEND ls_select TO lt_select.

        ENDLOOP.

        SORT lt_select BY companycode fiscalyear accountingdocument ledgergllineitem  .
*****************************************************************
*       Transform into deep structure
*****************************************************************
        TYPES:BEGIN OF lty_count,
                companycode        TYPE bukrs,
                fiscalyear         TYPE gjahr,
                accountingdocument TYPE belnr_d,
                count              TYPE i,
              END OF lty_count.
        DATA:datakey(100) TYPE c.
        DATA:lt_print TYPE tt_prts.
        DATA:ls_print TYPE lty_prts .
        DATA:ls_header TYPE lty_prt_h.
        DATA:lt_item TYPE tt_prt_i.
        DATA:ls_item TYPE lty_prt_i.
        DATA:lv_page TYPE i .
        DATA:lv_curr_page TYPE i .
        DATA:lt_count TYPE STANDARD TABLE OF lty_count.
        DATA:ls_count TYPE lty_count.
        DATA:lv_total_page TYPE p LENGTH 10 DECIMALS 2 .
        CONSTANTS:c_page TYPE i VALUE 7.
        lv_curr_page = 1.

        LOOP AT lt_select INTO ls_select.
          MOVE-CORRESPONDING  ls_select TO ls_count.
          ls_count-count = 1.
          COLLECT ls_count INTO lt_count.
        ENDLOOP.

        LOOP AT lt_select INTO ls_select.
          "GET TOTAL PAGES FOR EACH HEADER
          READ TABLE lt_count INTO ls_count WITH KEY companycode = ls_select-companycode
        fiscalyear = ls_select-fiscalyear
        accountingdocument = ls_select-accountingdocument BINARY SEARCH.
          "NEW HEADER APPEND
          IF datakey IS NOT INITIAL AND datakey NE ls_select-companycode && ls_select-fiscalyear && ls_select-accountingdocument.
            ls_header-page_num = lv_curr_page.
            "ls_header-total_page_num =  ls_count-count / c_page + 1.
            lv_total_page =  ls_count-count / c_page + 1.
            ls_header-total_page_num = lv_total_page.
            IF ls_header-total_page_num > lv_total_page.
              ls_header-total_page_num  -= 1.
            ENDIF.
            IF ls_select-duecalculationbasedate IS INITIAL.
              CLEAR ls_header-duecalculationbasedate.
            ENDIF.
            IF ls_select-billofexchangeissuedate IS INITIAL.
              CLEAR ls_header-billofexchangeissuedate.
            ENDIF.
            IF ls_select-wrkflwtskcreationutcdatetime IS INITIAL.
              CLEAR ls_header-wrkflwtskcreationutcdatetime.
            ENDIF.
            IF ls_select-reversedocumentfiscalyear IS INITIAL.
              CLEAR ls_header-reversedocumentfiscalyear.
            ENDIF.
            IF ls_select-accountingdoccreationdate_w IS INITIAL.
              CLEAR ls_header-accountingdoccreationdate_w.
            ENDIF.
            ls_print-_header = ls_header.
            IF lv_page < c_page.
              DO c_page - lv_page TIMES.
                CLEAR ls_item.
                APPEND ls_item TO lt_item.
              ENDDO.
            ENDIF.
            ls_print-_item   = lt_item.

            APPEND ls_print TO lt_print.
            lv_curr_page = 1.
            CLEAR lt_item.
            CLEAR ls_print.
            CLEAR lv_page.
          ENDIF.
          "ITEM EDIT
          CLEAR ls_item.
          MOVE-CORRESPONDING ls_select TO ls_item.

          ls_item-companycode = ls_select-companycode .
          ls_item-fiscalyear = ls_select-fiscalyear .
          ls_item-accountingdocument = ls_select-accountingdocument .
          ls_item-transactioncurrency  = ls_select-transactioncurrency_i .
          ls_item-debitamountintranscrcy = ls_select-debitamountintranscrcy_i .
          ls_item-creditamountintranscrcy  = ls_select-creditamountintranscrcy_i.

          CONDENSE :ls_item-glaccountname,ls_item-bpname,ls_item-yy1_f_fins1z02_cob,ls_item-yy1_f_fins2z02_cob,ls_item-fixedassetdescription.
          ls_item-glaccountname = |{ ls_item-glaccount ALPHA = OUT }|  && ls_item-glaccountname.
          ls_item-bpname = |{ ls_item-bp ALPHA = OUT }| && ls_item-bpname.
          ls_item-yy1_f_fins1z02_cob = ls_item-yy1_f_fins1z01_cob && ls_item-yy1_f_fins1z02_cob.
          ls_item-yy1_f_fins2z02_cob = ls_item-yy1_f_fins2z01_cob && ls_item-yy1_f_fins2z02_cob.
          IF ls_item-masterfixedasset IS NOT INITIAL.
            ls_item-fixedassetdescription = |{ ls_item-masterfixedasset ALPHA = OUT }|  && '-' && |{ ls_item-fixedasset ALPHA = OUT }| && ls_item-fixedassetdescription.
          ENDIF.
          ls_item-ledgergllineitem  = ls_select-ledgergllineitem+3(3) .
          APPEND ls_item TO lt_item.
          lv_page += 1.
          "HEAD EDIT
          MOVE-CORRESPONDING ls_select TO ls_header.
          ls_header-accountingdocumenttypename = ls_header-accountingdocumenttype && ls_header-accountingdocumenttypename.
          ls_print-companycode = ls_select-companycode .
          ls_print-fiscalyear = ls_select-fiscalyear .
          ls_print-accountingdocument = ls_select-accountingdocument .
          datakey = ls_select-companycode && ls_select-fiscalyear && ls_select-accountingdocument.
          "OVERFLOW APPEND
          IF lv_page = c_page.
            ls_header-page_num = lv_curr_page.
            lv_total_page =  ls_count-count / c_page + 1.
            ls_header-total_page_num = lv_total_page.
            "ls_header-total_page_num =  ls_count-count / c_page + 1.
            IF ls_header-total_page_num > lv_total_page.
              ls_header-total_page_num  -= 1.
            ENDIF.
            IF ls_select-duecalculationbasedate IS INITIAL.
              CLEAR ls_header-duecalculationbasedate.
            ENDIF.
            IF ls_select-billofexchangeissuedate IS INITIAL.
              CLEAR ls_header-billofexchangeissuedate.
            ENDIF.
            IF ls_select-wrkflwtskcreationutcdatetime IS INITIAL.
              CLEAR ls_header-wrkflwtskcreationutcdatetime.
            ENDIF.
            IF ls_select-reversedocumentfiscalyear IS INITIAL.
              CLEAR ls_header-reversedocumentfiscalyear.
            ENDIF.
            IF ls_select-accountingdoccreationdate_w IS INITIAL.
              CLEAR ls_header-accountingdoccreationdate_w.
            ENDIF.
            ls_print-_header = ls_header.
            ls_print-_item   = lt_item.

            APPEND ls_print TO lt_print.
            lv_curr_page += 1.
            CLEAR lt_item.
            CLEAR ls_print.
            CLEAR lv_page.
          ENDIF.
        ENDLOOP.
        "LAST APPEND
        IF sy-subrc = 0.
          ls_header-page_num = lv_curr_page.
          "ls_header-total_page_num =  ls_count-count / c_page + 1.
          lv_total_page =  ls_count-count / c_page + 1.
          ls_header-total_page_num = lv_total_page.
          IF ls_header-total_page_num > lv_total_page.
            ls_header-total_page_num  -= 1.
          ENDIF.
          IF ls_select-duecalculationbasedate IS INITIAL.
            CLEAR ls_header-duecalculationbasedate.
          ENDIF.
          IF ls_select-billofexchangeissuedate IS INITIAL.
            CLEAR ls_header-billofexchangeissuedate.
          ENDIF.
          IF ls_select-wrkflwtskcreationutcdatetime IS INITIAL.
            CLEAR ls_header-wrkflwtskcreationutcdatetime.
          ENDIF.

          IF ls_select-reversedocumentfiscalyear IS INITIAL.
            CLEAR ls_header-reversedocumentfiscalyear.
          ENDIF.
          IF ls_select-accountingdoccreationdate_w IS INITIAL.
            CLEAR ls_header-accountingdoccreationdate_w.
          ENDIF.



          ls_print-_header = ls_header.
          IF lv_page < c_page.
            DO c_page - lv_page TIMES.
              CLEAR ls_item.
              APPEND ls_item TO lt_item.
            ENDDO.
          ENDIF.
          ls_print-_item   = lt_item.

          APPEND ls_print TO lt_print.
          lv_curr_page = 1.
          CLEAR lt_item.
          CLEAR ls_print.
          CLEAR lv_page.
        ENDIF.

      ENDIF.

    ENDIF.

    ct_print = lt_print.




  ENDMETHOD.
ENDCLASS.
