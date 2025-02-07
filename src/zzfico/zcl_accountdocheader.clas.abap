CLASS zcl_accountdocheader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ACCOUNTDOCHEADER IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA:lt_zc_accountingdoc TYPE STANDARD TABLE OF zc_accountingdoc.
    DATA:ls_zc_accountingdoc TYPE zc_accountingdoc.
    DATA:
      lv_orderby_string TYPE string,
      lv_select_string  TYPE string.
    "select options
    DATA:
      lr_companycode                 TYPE RANGE OF zc_accountingdoc-companycode,
      lr_companycode_auth            TYPE RANGE OF zc_accountingdoc-companycode,
      lrs_companycode                LIKE LINE OF lr_companycode,
      lr_ledgergroup                 TYPE RANGE OF zc_accountingdoc-ledgergroup,
      lrs_ledgergroup                LIKE LINE OF lr_ledgergroup,
      lr_fiscalperiod                TYPE RANGE OF zc_accountingdoc-fiscalperiod,
      lrs_fiscalperiod               LIKE LINE OF lr_fiscalperiod,
      lr_accountingdocumenttype      TYPE RANGE OF zc_accountingdoc-accountingdocumenttype,
      lrs_accountingdocumenttype     LIKE LINE OF lr_accountingdocumenttype,
      lr_accountingdocumentcategory  TYPE RANGE OF zc_accountingdoc-accountingdocumentcategory,
      lrs_accountingdocumentcategory LIKE LINE OF lr_accountingdocumentcategory,
      lr_accountingdocument          TYPE RANGE OF zc_accountingdoc-accountingdocument,
      lrs_accountingdocument         LIKE LINE OF lr_accountingdocument,
      lr_fiscalyear                  TYPE RANGE OF zc_accountingdoc-fiscalyear,
      lrs_fiscalyear                 LIKE LINE OF lr_fiscalyear,
      lr_documentdate                TYPE RANGE OF zc_accountingdoc-documentdate,
      lrs_documentdate               LIKE LINE OF lr_documentdate,
      lr_postingdate                 TYPE RANGE OF zc_accountingdoc-postingdate,
      lrs_postingdate                LIKE LINE OF lr_postingdate,
      lr_accountingdoccreatedbyuser  TYPE RANGE OF zc_accountingdoc-accountingdoccreatedbyuser,
      lrs_accountingdoccreatedbyuser LIKE LINE OF lr_accountingdoccreatedbyuser.

    DATA:
      lv_calendaryear  TYPE calendaryear,
      lv_calendarmonth TYPE calendarmonth.
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
      IF lt_sort IS NOT INITIAL.
        CLEAR lv_orderby_string.
        LOOP AT lt_sort INTO DATA(ls_sort).
          IF ls_sort-descending = abap_true.
            CONCATENATE lv_orderby_string ls_sort-element_name 'DESCENDING' INTO lv_orderby_string SEPARATED BY space.
          ELSE.
            CONCATENATE lv_orderby_string ls_sort-element_name 'ASCENDING' INTO lv_orderby_string SEPARATED BY space.
          ENDIF.
        ENDLOOP.
      ELSE.
        "lv_orderby_string = 'PRODUCT'.
      ENDIF.

*****************************************************************
*       Filter
*****************************************************************

      READ TABLE lt_filter_cond INTO DATA(ls_ledgergroup_cond) WITH KEY name = 'LEDGERGROUP' .
      IF sy-subrc EQ 0.
        LOOP AT ls_ledgergroup_cond-range INTO DATA(ls_sel_opt_ledgergroup).
          MOVE-CORRESPONDING ls_sel_opt_ledgergroup TO lrs_ledgergroup.
          INSERT lrs_ledgergroup INTO TABLE lr_ledgergroup.
        ENDLOOP.
      ENDIF.

      DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
      DATA(lv_user_company) = zzcl_common_utils=>get_company_by_user( lv_user_email ).
      SPLIT lv_user_company AT '&' INTO TABLE DATA(lt_company).
      lr_companycode_auth = VALUE #( FOR companycode IN lt_company ( sign = 'I' option = 'EQ' low = companycode ) ).

      READ TABLE lt_filter_cond INTO DATA(ls_companycode_cond) WITH KEY name = 'COMPANYCODE' .
      IF sy-subrc EQ 0.
        LOOP AT ls_companycode_cond-range INTO DATA(ls_sel_opt_companycode).
          MOVE-CORRESPONDING ls_sel_opt_companycode TO lrs_companycode.
          IF lrs_companycode-low IN lr_companycode_auth AND lr_companycode_auth IS not INITIAL.
            INSERT lrs_companycode INTO TABLE lr_companycode.
          ENDIF.
        ENDLOOP.
      ELSE.
        lr_companycode = lr_companycode_auth.
      ENDIF.
      "不存在为空的情况
      IF lr_companycode IS INITIAL .
        CLEAR lr_companycode.
        lrs_companycode-sign = 'I'.
        lrs_companycode-option = 'EQ' .
        lrs_companycode-low = '' .
        INSERT lrs_companycode INTO TABLE lr_companycode.
      ENDIF.

      READ TABLE lt_filter_cond INTO DATA(ls_fiscalperiod_cond) WITH KEY name = 'FISCALPERIOD' .
      IF sy-subrc EQ 0.
        LOOP AT ls_fiscalperiod_cond-range INTO DATA(ls_sel_opt_fiscalperiod).
          MOVE-CORRESPONDING ls_sel_opt_fiscalperiod TO lrs_fiscalperiod.
          INSERT lrs_fiscalperiod INTO TABLE lr_fiscalperiod.
        ENDLOOP.
      ENDIF.
      READ TABLE lt_filter_cond INTO DATA(ls_accountingdocumenttype_cond) WITH KEY name = 'ACCOUNTINGDOCUMENTTYPE' .
      IF sy-subrc EQ 0.
        LOOP AT ls_accountingdocumenttype_cond-range INTO DATA(ls_sel_opt_accountdocumenttype).
          MOVE-CORRESPONDING ls_sel_opt_accountdocumenttype TO lrs_accountingdocumenttype.
          INSERT lrs_accountingdocumenttype INTO TABLE lr_accountingdocumenttype.
        ENDLOOP.
      ENDIF.
      READ TABLE lt_filter_cond INTO DATA(ls_acccategory_cond) WITH KEY name = 'ACCOUNTINGDOCUMENTCATEGORY' .
      IF sy-subrc EQ 0.
        LOOP AT ls_acccategory_cond-range INTO DATA(ls_sel_opt_acccategory).
          MOVE-CORRESPONDING ls_sel_opt_acccategory TO lrs_accountingdocumentcategory.
          INSERT lrs_accountingdocumentcategory INTO TABLE lr_accountingdocumentcategory.
        ENDLOOP.
      ENDIF.
      READ TABLE lt_filter_cond INTO DATA(ls_accountingdocument_cond) WITH KEY name = 'ACCOUNTINGDOCUMENT' .
      IF sy-subrc EQ 0.
        LOOP AT ls_accountingdocument_cond-range INTO DATA(ls_sel_opt_accountingdocument).
          MOVE-CORRESPONDING ls_sel_opt_accountingdocument TO lrs_accountingdocument.
          INSERT lrs_accountingdocument INTO TABLE lr_accountingdocument.
        ENDLOOP.
      ENDIF.
      READ TABLE lt_filter_cond INTO DATA(ls_fiscalyear_cond) WITH KEY name = 'FISCALYEAR' .
      IF sy-subrc EQ 0.
        LOOP AT ls_fiscalyear_cond-range INTO DATA(ls_sel_opt_fiscalyear).
          MOVE-CORRESPONDING ls_sel_opt_fiscalyear TO lrs_fiscalyear.
          INSERT lrs_fiscalyear INTO TABLE lr_fiscalyear.
        ENDLOOP.
      ENDIF.
      READ TABLE lt_filter_cond INTO DATA(ls_documentdate_cond) WITH KEY name = 'DOCUMENTDATE' .
      IF sy-subrc EQ 0.
        LOOP AT ls_documentdate_cond-range INTO DATA(ls_sel_opt_documentdate).
          MOVE-CORRESPONDING ls_sel_opt_documentdate TO lrs_documentdate.
          INSERT lrs_documentdate INTO TABLE lr_documentdate.
        ENDLOOP.
      ENDIF.
      READ TABLE lt_filter_cond INTO DATA(ls_postingdate_cond) WITH KEY name = 'POSTINGDATE' .
      IF sy-subrc EQ 0.
        LOOP AT ls_postingdate_cond-range INTO DATA(ls_sel_opt_postingdate).
          MOVE-CORRESPONDING ls_sel_opt_postingdate TO lrs_postingdate.
          INSERT lrs_postingdate INTO TABLE lr_postingdate.
        ENDLOOP.
      ENDIF.
      READ TABLE lt_filter_cond INTO DATA(ls_user_cond) WITH KEY name = 'ACCOUNTINGDOCCREATEDBYUSER' .
      IF sy-subrc EQ 0.
        LOOP AT ls_user_cond-range INTO DATA(ls_sel_opt_user).
          MOVE-CORRESPONDING ls_sel_opt_user TO lrs_accountingdoccreatedbyuser.
          INSERT lrs_accountingdoccreatedbyuser INTO TABLE lr_accountingdoccreatedbyuser.
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
      AND ledgergroup IN @lr_ledgergroup
      AND fiscalperiod IN @lr_fiscalperiod
      AND accountingdocumenttype IN @lr_accountingdocumenttype
      AND accountingdocumentcategory IN @lr_accountingdocumentcategory
      AND accountingdocument IN @lr_accountingdocument
      AND fiscalyear IN @lr_fiscalyear
      AND documentdate IN @lr_documentdate
      AND postingdate IN @lr_postingdate
      AND accountingdoccreatedbyuser IN @lr_accountingdoccreatedbyuser
      INTO TABLE @DATA(lt_journalentry).

      IF lt_journalentry IS NOT INITIAL.

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
        INTO TABLE @DATA(lt_glaccountlineitem).

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
        LOOP AT lt_glaccountlineitem INTO DATA(ls_glaccountlineitem).

          CLEAR ls_sum .
          MOVE-CORRESPONDING ls_glaccountlineitem TO ls_sum .
          COLLECT ls_sum INTO lt_sum3 .

        ENDLOOP.

        SORT lt_sum1 BY companycode fiscalyear accountingdocument debitcreditcode .
        SORT lt_sum2 BY companycode fiscalyear accountingdocument debitcreditcode .
        SORT lt_sum3 BY companycode fiscalyear accountingdocument debitcreditcode .

        SORT lt_glaccountlineitem BY companycode fiscalyear accountingdocument amountincompanycodecurrency DESCENDING.

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
        *
        FROM i_user
        WITH PRIVILEGED ACCESS
        INTO TABLE @DATA(lt_user).                      "#EC CI_NOWHERE
        SORT lt_user BY userid.

        LOOP AT lt_journalentry INTO DATA(ls_journalentry).
          CLEAR ls_zc_accountingdoc.
          MOVE-CORRESPONDING ls_journalentry TO ls_zc_accountingdoc.

*          READ TABLE lt_glaccountlineitem INTO ls_glaccountlineitem
*          WITH KEY companycode = ls_zc_accountingdoc-companycode
*                   fiscalyear = ls_zc_accountingdoc-fiscalyear
*                   accountingdocument = ls_zc_accountingdoc-accountingdocument BINARY SEARCH.
*          IF sy-subrc = 0.
*            ls_zc_accountingdoc-companycodecurrency = ls_glaccountlineitem-companycodecurrency .
*            ls_zc_accountingdoc-amountincompanycodecurrency = ls_glaccountlineitem-amountincompanycodecurrency.
*            "ls_zc_accountingdoc-amountincompanycodecurrency = zzcl_common_utils=>conversion_amount(
*            "                            iv_alpha = 'OUT'
*            "                            iv_currency = ls_zc_accountingdoc-companycodecurrency
*            "                            iv_input = ls_glaccountlineitem-amountincompanycodecurrency ).
*
*          ENDIF.
          READ TABLE lt_sum1 INTO ls_sum
WITH KEY companycode = ls_zc_accountingdoc-companycode
         fiscalyear = ls_zc_accountingdoc-fiscalyear
         accountingdocument = ls_zc_accountingdoc-accountingdocument
         debitcreditcode = 'S' BINARY SEARCH.
          IF sy-subrc = 0.
            ls_zc_accountingdoc-amountincompanycodecurrency = ls_sum-amountintransactioncurrency.
            ls_zc_accountingdoc-companycodecurrency = ls_sum-transactioncurrency.
          ELSE.
            READ TABLE lt_sum2 INTO ls_sum
            WITH KEY companycode = ls_zc_accountingdoc-companycode
               fiscalyear = ls_zc_accountingdoc-fiscalyear
               accountingdocument = ls_zc_accountingdoc-accountingdocument
               debitcreditcode = 'S' BINARY SEARCH.
            IF sy-subrc = 0.
              ls_zc_accountingdoc-amountincompanycodecurrency = ls_sum-amountintransactioncurrency.
              ls_zc_accountingdoc-companycodecurrency = ls_sum-transactioncurrency.
            ELSE.
              READ TABLE lt_sum3 INTO ls_sum
              WITH KEY companycode = ls_zc_accountingdoc-companycode
                 fiscalyear = ls_zc_accountingdoc-fiscalyear
                 accountingdocument = ls_zc_accountingdoc-accountingdocument
                 debitcreditcode = 'S' BINARY SEARCH.
              IF sy-subrc = 0.
                ls_zc_accountingdoc-amountincompanycodecurrency = ls_sum-amountintransactioncurrency.
                ls_zc_accountingdoc-companycodecurrency = ls_sum-transactioncurrency.
              ENDIF.
            ENDIF.
          ENDIF.
          "'会社コードテキスト'
          READ TABLE lt_companycode INTO DATA(ls_companycode) WITH KEY companycode = ls_zc_accountingdoc-companycode BINARY SEARCH.
          IF sy-subrc = 0.
            ls_zc_accountingdoc-companycodetext = ls_companycode-companycodename."'会社コードテキスト'
          ENDIF.
          READ TABLE lt_accountingdocumenttypetext INTO DATA(ls_accountingdocumenttypetext) WITH KEY accountingdocumenttype = ls_zc_accountingdoc-accountingdocumenttype BINARY SEARCH.
          IF sy-subrc = 0.
            ls_zc_accountingdoc-accountingdocumenttypename = ls_accountingdocumenttypetext-accountingdocumenttypename."'会社コードテキスト'
          ENDIF.
          READ TABLE lt_user INTO DATA(ls_user) WITH KEY userid = ls_zc_accountingdoc-accountingdoccreatedbyuser BINARY SEARCH.
          IF sy-subrc = 0.
            ls_zc_accountingdoc-accountingdoccreatedbyusern = ls_user-userdescription.
          ENDIF.
          APPEND ls_zc_accountingdoc TO lt_zc_accountingdoc.
        ENDLOOP.

      ENDIF.
      " Filtering
      " zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
      "                              CHANGING  ct_data   = lt_zc_accountingdoc ).
      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( lines( lt_zc_accountingdoc ) ).
      ENDIF.

      "Sort
      zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                 CHANGING  ct_data  = lt_zc_accountingdoc ).

      " Paging
      zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                CHANGING  ct_data   = lt_zc_accountingdoc ).



      io_response->set_data( lt_zc_accountingdoc ).





    ELSE.

      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( 1 ).
      ENDIF.

    ENDIF.






  ENDMETHOD.
ENDCLASS.
