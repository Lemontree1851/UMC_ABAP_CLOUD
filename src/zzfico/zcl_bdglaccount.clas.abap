CLASS zcl_bdglaccount DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
    "   CLASS-METHODS:
    "! Merge Messages
    "     apply_group_aggregation         IMPORTING
    "                                       !it_select TYPE /iwbep/t_mgw_tech_field_names
    "                                     CHANGING
    "                                      !ct_data   TYPE STANDARD TABLE,
    "      zzdefine_aggr_annotation
    "       IMPORTING
    "         io_odata_model TYPE REF TO /iwbep/if_mgw_odata_model.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_bdglaccount IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TYPES:
      BEGIN OF ty_data,
        orderid                       TYPE i_mfgorderactlplantgtldgrcost-orderid,                       "key
        partnercostcenter             TYPE i_mfgorderactlplantgtldgrcost-partnercostcenter,             "key
        partnercostctractivitytype    TYPE i_mfgorderactlplantgtldgrcost-partnercostctractivitytype,    "key
        unitofmeasure                 TYPE i_mfgorderactlplantgtldgrcost-unitofmeasure,                 "key
        plant                         TYPE i_mfgorderactlplantgtldgrcost-plant,                         "key
        orderitem                     TYPE i_mfgorderactlplantgtldgrcost-orderitem,                     "key
        workcenterinternalid          TYPE i_mfgorderactlplantgtldgrcost-workcenterinternalid,          "key
        orderoperation                TYPE i_mfgorderactlplantgtldgrcost-orderoperation,                "key
        glaccount                     TYPE i_mfgorderactlplantgtldgrcost-glaccount,                     "key
        curplanprojslsordvalnstrategy TYPE i_mfgorderactlplantgtldgrcost-curplanprojslsordvalnstrategy, "key
        companycode                   TYPE i_mfgorderactlplantgtldgrcost-companycode,
        producedproduct               TYPE i_mfgorderactlplantgtldgrcost-producedproduct,
        planqtyincostsourceunit       TYPE i_mfgorderactlplantgtldgrcost-planqtyincostsourceunit,
        actualqtyincostsourceunit     TYPE i_mfgorderactlplantgtldgrcost-actualqtyincostsourceunit,
        yearperiod                    TYPE fins_fyearperiod,                                            "new key
      END OF ty_data,
      BEGIN OF ty_data1,

        assembly    TYPE i_mfgorderactlplantgtldgrcost-producedproduct, "
        material    TYPE i_mfgorderactlplantgtldgrcost-producedproduct,
        zfrtproduct TYPE i_mfgorderactlplantgtldgrcost-producedproduct,
      END OF ty_data1,
      BEGIN OF ty_data2,
        manufacturingorder        TYPE i_manufacturingorder-manufacturingorder,
        mfgorderconfirmedyieldqty TYPE i_manufacturingorder-mfgorderconfirmedyieldqty,
      END OF ty_data2.
    TYPES:
      BEGIN OF ty_results,
        ledger                         TYPE string,
        companycode                    TYPE string,
        glaccount                      TYPE ztfi_1002-glaccount,
        startingbalanceamtincocodecrcy TYPE dmbtr,
        startingbalanceamtincocode     TYPE string,
        debitamountincocodecrcy        TYPE dmbtr,
        debitamountincocode            TYPE string,
        creditamountincocodecrcy       TYPE dmbtr,
        creditamountincocode           TYPE string,
        endingbalanceamtincocodecrcy   TYPE dmbtr,
        endingbalanceamtincocode       TYPE string,

      END OF ty_results,
      BEGIN OF ty_collect,
        ledger                         TYPE string,
        companycode                    TYPE string,
        financialstatement             TYPE ztfi_1002-financialstatement,
        glaccount                      TYPE ztfi_1002-glaccount,
        startingbalanceamtincocodecrcy TYPE dmbtr,
        startingbalanceamtincocode     TYPE string,
        debitamountincocodecrcy        TYPE dmbtr,
        debitamountincocode            TYPE string,
        creditamountincocodecrcy       TYPE dmbtr,
        creditamountincocode           TYPE string,
        endingbalanceamtincocodecrcy   TYPE dmbtr,
        endingbalanceamtincocode       TYPE string,

      END OF ty_collect,
      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,
      BEGIN OF ty_d,
        results TYPE tt_results,
      END OF ty_d,
      BEGIN OF ty_res_api,
        d TYPE ty_d,
      END OF ty_res_api.
    DATA:
      lv_orderby_string TYPE string,
      lv_select_string  TYPE string.
    "select options
    DATA:
      lr_ledger       TYPE RANGE OF zc_bdglaccount-ledger,
      lrs_ledger      LIKE LINE OF lr_ledger,
      lr_companycode  TYPE RANGE OF zc_bdglaccount-companycode,
      lrs_companycode LIKE LINE OF lr_companycode.
    DATA:
      lv_calendaryear  TYPE calendaryear,
      lv_calendarmonth TYPE calendarmonth.
    DATA:lv_companycode TYPE zc_bdglaccount-companycode.
    DATA:lv_ledger TYPE zc_bdglaccount-ledger.
    DATA:lv_calendarmonth_s TYPE string.
    DATA:lv_date_f TYPE aedat.
    DATA:lv_date_t TYPE aedat.
    DATA:lv_date_s TYPE aedat.
    DATA:lv_date_e TYPE aedat.
    DATA:lv_from TYPE string.
    DATA:lv_to TYPE string.
    DATA:lv_glaccount1(10) TYPE c,
         lv_glaccount2(10) TYPE c.
    DATA:ls_collect TYPE ty_collect.
    DATA:lt_collect TYPE STANDARD TABLE OF ty_collect.
    DATA:lt_collect1 TYPE STANDARD TABLE OF ty_collect.
    DATA:
      lt_bdglaccount     TYPE STANDARD TABLE OF zc_bdglaccount,
      lt_bdglaccount_out TYPE STANDARD TABLE OF zc_bdglaccount,
      ls_bdglaccount     TYPE zc_bdglaccount.
    DATA:lv_path     TYPE string.
    DATA:ls_res_api  TYPE ty_res_api.
    DATA:ls_res_api1  TYPE ty_res_api.
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
        lv_orderby_string = 'PRODUCT'.
      ENDIF.
      "filter
      READ TABLE lt_filter_cond INTO DATA(ls_companycode_cond) WITH KEY name = 'COMPANYCODE' .
      IF sy-subrc EQ 0.
        LOOP AT ls_companycode_cond-range INTO DATA(ls_sel_opt_companycode).
          MOVE-CORRESPONDING ls_sel_opt_companycode TO lrs_companycode.
          lv_companycode = lrs_companycode-low.


          INSERT lrs_companycode INTO TABLE lr_companycode.
        ENDLOOP.
      ENDIF.

      READ TABLE lt_filter_cond INTO DATA(ls_plant_cond) WITH KEY name = 'LEDGER' .
      IF sy-subrc EQ 0.
        LOOP AT ls_plant_cond-range INTO DATA(ls_sel_opt_ledger).
          MOVE-CORRESPONDING ls_sel_opt_ledger TO lrs_ledger.
          lv_ledger = lrs_ledger-low.




          INSERT lrs_ledger INTO TABLE lr_ledger.
        ENDLOOP.
      ENDIF.
      READ TABLE lt_filter_cond INTO DATA(ls_year_cond) WITH KEY name = 'CALENDARYEAR' .
      IF sy-subrc EQ 0.
        READ TABLE ls_year_cond-range INTO DATA(ls_sel_opt_year) INDEX 1.
        IF sy-subrc EQ 0 .
          lv_calendaryear = ls_sel_opt_year-low.

        ENDIF.
      ENDIF.

      READ TABLE lt_filter_cond INTO DATA(ls_month_cond) WITH KEY name = 'CALENDARMONTH' .
      IF sy-subrc EQ 0.
        READ TABLE ls_month_cond-range INTO DATA(ls_sel_opt_month) INDEX 1.
        IF sy-subrc EQ 0 .
          lv_calendarmonth = ls_sel_opt_month-low.





          lv_calendarmonth_s =  |{ lv_calendarmonth ALPHA = OUT }|.
          CONDENSE lv_calendarmonth_s.
          IF lv_calendarmonth_s < 10.
            lv_calendarmonth_s = '0' && lv_calendarmonth_s.
          ENDIF.
          lv_date_f = lv_calendaryear && lv_calendarmonth_s && '01'.
          lv_date_f = zzcl_common_utils=>calc_date_add( date = lv_date_f month = 3 ).
          lv_date_f = lv_date_f+0(6) && '01'.
          "lv_date_t = lv_date_f+0(6) && '31'.
          lv_date_t = zzcl_common_utils=>get_enddate_of_month( EXPORTING iv_date = lv_date_f ).
          lv_from =  lv_date_f+0(4) && '-' && lv_date_f+4(2) && '-' && lv_date_f+6(2) && 'T00%3A00'.
          lv_to =  lv_date_t+0(4) && '-' && lv_date_t+4(2) && '-' && lv_date_t+6(2) && 'T00%3A00'.
        ENDIF.
      ENDIF.







*
*      "从会计科目表明细中提取主要材料和辅助材料的帐户和金额合计
      lv_path = |/C_TRIALBALANCE_CDS/C_TRIALBALANCE(P_FromPostingDate=datetime'{ lv_from }',P_ToPostingDate=datetime'{ lv_to }')/Results?$top=50&$filter=Ledger%20eq%20'{ lv_ledger }'%20%20and%20CompanyCode%20eq%20'{ lv_companycode }'|.

      lv_path = lv_path && '&$select=Ledger,CompanyCode,GLAccount,StartingBalanceAmtInCoCodeCrcy, StartingBalanceAmtInCoCodeCrcy_E, DebitAmountInCoCodeCrcy,'.
      lv_path = lv_path && 'DebitAmountInCoCodeCrcy_E, CreditAmountInCoCodeCrcy, CreditAmountInCoCodeCrcy_E,EndingBalanceAmtInCoCodeCrcy, EndingBalanceAmtInCoCodeCrcy_E'.

      "Call API
      zzcl_common_utils=>request_api_v2(
        EXPORTING
         iv_path        = lv_path
          iv_method      = if_web_http_client=>get
        IMPORTING
          ev_status_code = DATA(lv_stat_code)
          ev_response    = DATA(lv_resbody_api) ).
      TRY.
          REPLACE ALL OCCURRENCES OF 'StartingBalanceAmtInCoCodeCrcy_E' IN lv_resbody_api WITH 'StartingBalanceAmtInCoCode'.
          REPLACE ALL OCCURRENCES OF 'DebitAmountInCoCodeCrcy_E' IN lv_resbody_api WITH 'DebitAmountInCoCode'.
          REPLACE ALL OCCURRENCES OF 'CreditAmountInCoCodeCrcy_E' IN lv_resbody_api WITH 'CreditAmountInCoCode'.
          REPLACE ALL OCCURRENCES OF 'EndingBalanceAmtInCoCodeCrcy_E' IN lv_resbody_api WITH 'EndingBalanceAmtInCoCode'.
          "JSON->ABAP
          xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
             ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api ) ).
        CATCH cx_root INTO DATA(lx_root1).
      ENDTRY.

      SELECT * FROM ztfi_1002 INTO TABLE @DATA(lt_fi1002) .
      SORT lt_fi1002 BY glaccount.


      LOOP AT ls_res_api-d-results INTO DATA(ls_result1).
        ls_result1-glaccount =  |{ ls_result1-glaccount ALPHA = IN }|.
        MODIFY ls_res_api-d-results FROM ls_result1 TRANSPORTING glaccount.
      ENDLOOP.



      LOOP AT ls_res_api-d-results INTO DATA(ls_result).
        READ TABLE lt_fi1002 INTO DATA(ls_fi1002) WITH KEY glaccount = ls_result-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          CLEAR ls_collect.
          MOVE-CORRESPONDING  ls_result TO  ls_collect.
          ls_collect-financialstatement = ls_fi1002-financialstatement.
          COLLECT ls_collect INTO lt_collect.


          CLEAR ls_collect-glaccount ..
          COLLECT ls_collect INTO lt_collect1.
        ELSE.
          CLEAR ls_collect.
          MOVE-CORRESPONDING  ls_result TO  ls_collect.
          ls_collect-financialstatement = '未割当'.
          COLLECT ls_collect INTO lt_collect.


          CLEAR ls_collect-glaccount .
          COLLECT ls_collect INTO lt_collect1.

        ENDIF.
      ENDLOOP.


      SORT lt_collect BY ledger companycode financialstatement glaccount.

      SELECT glaccount,glaccountlongname
FROM  i_glaccounttext WITH PRIVILEGED ACCESS
FOR ALL ENTRIES IN @ls_res_api-d-results
WHERE glaccount = @ls_res_api-d-results-glaccount

AND language = 'J'
INTO TABLE @DATA(lt_glaccount).
      SORT lt_glaccount BY glaccount.

      LOOP AT lt_collect INTO ls_collect .


        ls_bdglaccount-ledger = ls_collect-ledger.
        ls_bdglaccount-companycode = ls_collect-companycode.
        ls_bdglaccount-calendaryear = lv_calendaryear.
        ls_bdglaccount-calendarmonth  = lv_calendarmonth .
        ls_bdglaccount-glaccount = ls_collect-glaccount.
        ls_bdglaccount-financialstatementitem = ls_collect-financialstatement.

        ls_bdglaccount-startingbalanceamtincocodecrcy = ls_collect-startingbalanceamtincocodecrcy .
        ls_bdglaccount-startingbalanceamtincocode_e = ls_collect-startingbalanceamtincocode.
        ls_bdglaccount-creditamountincocodecrcy = ls_collect-creditamountincocodecrcy .
        ls_bdglaccount-creditamountincocode_e = ls_collect-creditamountincocode.
        ls_bdglaccount-debitamountincocodecrcy = ls_collect-debitamountincocodecrcy .
        ls_bdglaccount-debitamountincocode_e =  ls_collect-debitamountincocode.
        ls_bdglaccount-endingbalanceamtincocodecrcy = ls_collect-endingbalanceamtincocodecrcy .
        ls_bdglaccount-endingbalanceamtincocode_e = ls_collect-endingbalanceamtincocode.



        READ TABLE lt_glaccount INTO DATA(ls_glaccount) WITH KEY glaccount = ls_bdglaccount-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          ls_bdglaccount-glaccountdesc = ls_glaccount-glaccountlongname.
        ENDIF.
        ls_bdglaccount-glaccount =  |{ ls_bdglaccount-glaccount ALPHA = OUT }|.
        READ TABLE lt_fi1002 INTO DATA(ls_fi10021) WITH KEY glaccount = ls_collect-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          ls_bdglaccount-financialstatementitemdesc = ls_fi10021-financialstatementitemtext.
        ENDIF.
        APPEND ls_bdglaccount TO lt_bdglaccount.
        AT END OF financialstatement.
          ls_bdglaccount-ledger = ls_collect-ledger.
          ls_bdglaccount-companycode = ls_collect-companycode.
          ls_bdglaccount-calendaryear = lv_calendaryear.
          ls_bdglaccount-calendarmonth  = lv_calendarmonth .
          ls_bdglaccount-glaccount = '合計'.
          ls_bdglaccount-financialstatementitem = ''.
          CLEAR ls_bdglaccount-financialstatementitemdesc.
          CLEAR ls_bdglaccount-glaccountdesc.
          READ TABLE lt_collect1 INTO DATA(ls_collect1) WITH KEY financialstatement = ls_collect-financialstatement.
          IF sy-subrc = 0.
            ls_bdglaccount-startingbalanceamtincocodecrcy = ls_collect1-startingbalanceamtincocodecrcy .
            ls_bdglaccount-startingbalanceamtincocode_e = ls_collect1-startingbalanceamtincocode.
            ls_bdglaccount-creditamountincocodecrcy = ls_collect1-creditamountincocodecrcy .
            ls_bdglaccount-creditamountincocode_e = ls_collect1-creditamountincocode.
            ls_bdglaccount-debitamountincocodecrcy = ls_collect1-debitamountincocodecrcy .
            ls_bdglaccount-debitamountincocode_e =  ls_collect1-debitamountincocode.
            ls_bdglaccount-endingbalanceamtincocodecrcy = ls_collect1-endingbalanceamtincocodecrcy .
            ls_bdglaccount-endingbalanceamtincocode_e = ls_collect1-endingbalanceamtincocode.
          ENDIF.
          ls_bdglaccount-lineid = ls_collect-financialstatement && ls_bdglaccount-glaccount.
          APPEND ls_bdglaccount TO lt_bdglaccount.


        ENDAT.

      ENDLOOP.






      " Filtering
      " zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
      "                              CHANGING  ct_data   = lt_bdglaccount ).
      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( lines( lt_bdglaccount ) ).
      ENDIF.

      "Sort
      zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                 CHANGING  ct_data  = lt_bdglaccount ).

      " Paging
      zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                CHANGING  ct_data   = lt_bdglaccount ).



      io_response->set_data( lt_bdglaccount ).

    ELSE.
      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( 3 ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
