CLASS zcl_mfgorder_002 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MFGORDER_002 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA:
      lv_orderby_string TYPE string,
      lv_select_string  TYPE string.
    "select options
    DATA:
      lr_plant        TYPE RANGE OF zc_mfgorder_002-plant,
      lrs_plant       LIKE LINE OF lr_plant,
      lr_companycode  TYPE RANGE OF zc_mfgorder_002-companycode,
      lrs_companycode LIKE LINE OF lr_companycode.
    DATA:
      lv_calendaryear  TYPE calendaryear,
      lv_calendarmonth TYPE calendarmonth.
    DATA:lv_date_f TYPE aedat.
    DATA:lv_date_t TYPE aedat.
    DATA:lv_calendarmonth_s TYPE string.
    DATA:
      lt_mfgorder_002     TYPE STANDARD TABLE OF zc_mfgorder_002,
      lt_mfgorder_002_out TYPE STANDARD TABLE OF zc_mfgorder_002,
      ls_mfgorder_002     TYPE zc_mfgorder_002.
    TYPES:
      BEGIN OF ty_results,
        currencypair                TYPE string,
        calendardate                TYPE timestamp,
        calendardate_d              TYPE sy-datum,
        exchangeratetype            TYPE string,

        sourcecurrency              TYPE string,

        targetcurrency              TYPE string,
        exchangerate                TYPE string,
        numberofsourcecurrencyunits TYPE string,
        numberoftargetcurrencyunits TYPE string,

      END OF ty_results,
      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,
      BEGIN OF ty_d,
        results TYPE tt_results,
      END OF ty_d,
      BEGIN OF ty_res_api,
        d TYPE ty_d,
      END OF ty_res_api.

    DATA:lv_path     TYPE string.
    DATA:ls_res_api  TYPE ty_res_api.
*
*    TYPES:
*      BEGIN OF ty_results,
*        companycode                    TYPE string,
*        accountingdocument             TYPE string,
*        fiscalyear                     TYPE string,
*        accountingdocumentitem         TYPE string,
*
*        parkedbyusername               TYPE string,
*        workitem                       TYPE string,
*        accountingdocumentcategory     TYPE string,
*        createdbyusername              TYPE string,
*        accountingdocumentcreationdate TYPE string,
*        accountingdocumentstatusname   TYPE string,
*
*      END OF ty_results,
*      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,
*      BEGIN OF ty_d,
*        results TYPE tt_results,
*      END OF ty_d,
*      BEGIN OF ty_res_api,
*        d TYPE ty_d,
*      END OF ty_res_api,
*      BEGIN OF ty_results1,
*        workflowinternalid           TYPE string,
*
*        wrkflwtskcreationutcdatetime TYPE string,
*      END OF ty_results1,
*      tt_results1 TYPE STANDARD TABLE OF ty_results1 WITH DEFAULT KEY,
*      BEGIN OF ty_d1,
*        results TYPE tt_results1,
*      END OF ty_d1,
*      BEGIN OF ty_res_api1,
*        d TYPE ty_d1,
*      END OF ty_res_api1.
    "DATA:lv_path     TYPE string.
    "DATA:ls_res_api  TYPE ty_res_api.
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
          INSERT lrs_companycode INTO TABLE lr_companycode.
        ENDLOOP.
      ENDIF.

      READ TABLE lt_filter_cond INTO DATA(ls_plant_cond) WITH KEY name = 'PLANT' .
      IF sy-subrc EQ 0.
        LOOP AT ls_plant_cond-range INTO DATA(ls_sel_opt_plant).
          MOVE-CORRESPONDING ls_sel_opt_plant TO lrs_plant.
          INSERT lrs_plant INTO TABLE lr_plant.
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
          lv_date_t = lv_date_f+0(6) && '31'.
        ENDIF.
      ENDIF.

      SELECT
      billingdocument,
      billingdocumentitem,
      product ,
      companycode ,
      plant   ,
      soldtoparty ,
      billingquantity ,
      billingquantityunit ,
      netamount   ,
      transactioncurrency,
      billingdocumentdate
      FROM i_billingdocumentitem
      WITH PRIVILEGED ACCESS
      WHERE companycode IN @lr_companycode
            AND plant IN @lr_plant
            AND billingdocumentdate >= @lv_date_f
            AND billingdocumentdate <= @lv_date_t
     INTO TABLE @DATA(lt_billingdocumentitem).

      IF lt_billingdocumentitem IS NOT INITIAL.
        SELECT companycode, companycodename
        FROM i_companycode
        WITH PRIVILEGED ACCESS
        WHERE language = 'J'
        INTO TABLE @DATA(lt_companycode).
        SORT lt_companycode BY companycode.

        SELECT plant, plantname
         FROM i_plant
         WITH PRIVILEGED ACCESS
         WHERE language = 'J'
         INTO TABLE @DATA(lt_plant).
        SORT lt_plant BY plant.
        "BPマスタから得意先のBPコードとBPテキストを抽出
        SELECT
        businesspartner,
        businesspartnername
        FROM i_businesspartner
        WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_billingdocumentitem
        WHERE businesspartner = @lt_billingdocumentitem-soldtoparty
        INTO TABLE @DATA(lt_businesspartner).
        SORT lt_businesspartner BY businesspartner.

        "品目マスタから品目テキストを抽出
        SELECT
        product,
        productdescription
        FROM
        i_productdescription
        WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_billingdocumentitem
        WHERE product = @lt_billingdocumentitem-product
        AND language  = 'J'
        INTO TABLE @DATA(lt_productdescription).
        SORT lt_productdescription BY product.
      ENDIF.

      "  SELECT * FROM i_mktdatafxratecube WHERE targetcurrency = 'JPY' AND exchangeratetype = 'M' AND calendardate >= @lv_date_f
      "  INTO TABLE @DATA(lt_mktdatafxratecube).

      lv_path = |/YY1_MktDataFXRateCube_CDS/YY1_MktDataFXRateCube|.
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
      "  xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
      "      ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api ) ).
      /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api
                   CHANGING  data = ls_res_api ).

      LOOP AT ls_res_api-d-results INTO DATA(ls_result_p).
        "时间戳格式转换成日期格式
        ls_result_p-calendardate_d = CONV string( ls_result_p-calendardate DIV 1000000 ).
        MODIFY ls_res_api-d-results  FROM ls_result_p TRANSPORTING calendardate_d .
      ENDLOOP.

      SORT ls_res_api-d-results BY sourcecurrency targetcurrency calendardate_d DESCENDING.

      LOOP AT lt_billingdocumentitem INTO DATA(ls_data).
        CLEAR ls_mfgorder_002.

        ls_mfgorder_002-calendaryear = |{ lv_calendaryear ALPHA = IN }|."'年月'
        ls_mfgorder_002-calendarmonth = |{ lv_calendarmonth ALPHA = IN }|."'年月'
        ls_mfgorder_002-yearmonth = lv_calendaryear && '0' && lv_calendarmonth."'年月'
        ls_mfgorder_002-companycode = ls_data-companycode."'会社コード'
        ls_mfgorder_002-plant = ls_data-plant."'プラント'
        ls_mfgorder_002-salesperformanceactualquantity = ls_data-billingquantity.
        ls_mfgorder_002-salesperfactualquantityunit = ls_data-billingquantityunit.
        ls_mfgorder_002-salesperfactlamtindspcurrency = ls_data-netamount.
        ls_mfgorder_002-displaycurrency = ls_data-transactioncurrency.
        IF ls_data-transactioncurrency NE 'JPY'.

          LOOP AT ls_res_api-d-results INTO DATA(ls_result) WHERE sourcecurrency = ls_data-transactioncurrency AND targetcurrency = 'JPY'.

            IF ls_result-calendardate_d <= ls_data-billingdocumentdate.
            ls_data-transactioncurrency = 'JPY'.
            ls_mfgorder_002-displaycurrency = 'JPY'.
            ls_mfgorder_002-salesperfactlamtindspcurrency = ls_mfgorder_002-salesperfactlamtindspcurrency * ls_result-exchangerate.
            exit.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDLOOP.


*          READ TABLE ls_res_api-d-results INTO DATA(ls_result) WITH KEY sourcecurrency = ls_data-transactioncurrency  targetcurrency = 'JPY'.
*          IF sy-subrc = 0.
*            ls_data-transactioncurrency = 'JPY'.
*            ls_data-transactioncurrency = ls_data-transactioncurrency * ls_result-exchangerate.
*          ELSE.
*            READ TABLE ls_res_api-d-results INTO DATA(ls_result1) WITH KEY sourcecurrency = 'JPY' targetcurrency = ls_data-transactioncurrency .
*            IF sy-subrc = 0.
*              ls_data-transactioncurrency = 'JPY'.
*              ls_data-transactioncurrency = ls_data-transactioncurrency / ls_result1-exchangerate.
*            ENDIF..
*          ENDIF.



        ENDIF.
        "ls_mfgorder_002-salesperfactlamtindspcurrency = zzcl_common_utils=>conversion_amount(
        "                            iv_alpha = 'OUT'
         "                           iv_currency = ls_data-transactioncurrency
        "                            iv_input = ls_mfgorder_002-salesperfactlamtindspcurrency ).

ls_mfgorder_002-salesperfactualquantityunit = ls_data-billingquantityunit .
        "TRY.
        "    ls_mfgorder_002-salesperfactualquantityunit             = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = 'OUT'
         "                                                                                                   iv_input = ls_data-billingquantityunit ).
        "  CATCH zzcx_custom_exception INTO DATA(lo_root_exc).
        "ENDTRY.

        ls_mfgorder_002-product = ls_data-product.
        ls_mfgorder_002-soldtoparty = ls_data-soldtoparty.
        "'会社コードテキスト'
        READ TABLE lt_companycode INTO DATA(ls_companycode) WITH KEY companycode = ls_data-companycode BINARY SEARCH.
        IF sy-subrc = 0.
          ls_mfgorder_002-companycodetext = ls_companycode-companycodename."'会社コードテキスト'
        ENDIF.
        "'プラントテキスト'
        READ TABLE lt_plant INTO DATA(ls_plant) WITH KEY plant = ls_data-plant BINARY SEARCH.
        IF sy-subrc = 0.
          ls_mfgorder_002-planttext = ls_plant-plantname."'プラントテキスト'
        ENDIF.
        "'製品テキスト'
        READ TABLE lt_productdescription INTO DATA(ls_productdescription) WITH KEY product = ls_mfgorder_002-product BINARY SEARCH.
        IF sy-subrc = 0.
          ls_mfgorder_002-productdescription = ls_productdescription-productdescription."'製品テキスト'
        ENDIF.
        READ TABLE lt_businesspartner INTO DATA(ls_businesspartner) WITH KEY businesspartner = ls_mfgorder_002-soldtoparty BINARY SEARCH.
        IF sy-subrc = 0.
          ls_mfgorder_002-soldtoparty = |{ ls_mfgorder_002-soldtoparty ALPHA = OUT }|."'年月'
          "'得意先テキスト'
          ls_mfgorder_002-businesspartnername = ls_businesspartner-businesspartnername.
        ENDIF.

        ls_mfgorder_002-product = zzcl_common_utils=>conversion_matn1(
                                     EXPORTING iv_alpha = 'OUT'
                                               iv_input = ls_mfgorder_002-product ).
        ls_mfgorder_002-orderid = ls_data-billingdocument.
        ls_mfgorder_002-orderitem = ls_data-billingdocumentitem.
        APPEND ls_mfgorder_002 TO lt_mfgorder_002.
      ENDLOOP.

      " Filtering
      "zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
      "                             CHANGING  ct_data   = lt_mfgorder_002 ).
      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( lines( lt_mfgorder_002 ) ).
      ENDIF.

      "Sort
      zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                 CHANGING  ct_data  = lt_mfgorder_002 ).

      " Paging
      zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                CHANGING  ct_data   = lt_mfgorder_002 ).



      io_response->set_data( lt_mfgorder_002 ).

    ELSE.
      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( 2 ).
      ENDIF.
*          READ TABLE lt_filter_cond INTO DATA(ls_companycode_cond2) WITH KEY name = 'COMPANYCODE' .
*      IF sy-subrc EQ 0.
*        LOOP AT ls_companycode_cond2-range INTO DATA(ls_sel_opt_companycode2).
*          MOVE-CORRESPONDING ls_sel_opt_companycode2 TO lrs_companycode.
*          INSERT lrs_companycode INTO TABLE lr_companycode.
*        ENDLOOP.
*      ENDIF.
*
*      READ TABLE lt_filter_cond INTO DATA(ls_plant_cond2) WITH KEY name = 'PLANT' .
*      IF sy-subrc EQ 0.
*        LOOP AT ls_plant_cond2-range INTO DATA(ls_sel_opt_plant2).
*          MOVE-CORRESPONDING ls_sel_opt_plant2 TO lrs_plant.
*          INSERT lrs_plant INTO TABLE lr_plant.
*        ENDLOOP.
*      ENDIF.
*
*      READ TABLE lt_filter_cond INTO DATA(ls_year_cond2) WITH KEY name = 'CALENDARYEAR' .
*      IF sy-subrc EQ 0.
*        READ TABLE ls_year_cond2-range INTO DATA(ls_sel_opt_year2) INDEX 1.
*        IF sy-subrc EQ 0 .
*          lv_calendaryear = ls_sel_opt_year2-low.
*        ENDIF.
*      ENDIF.
*
*      READ TABLE lt_filter_cond INTO DATA(ls_month_cond2) WITH KEY name = 'CALENDARMONTH' .
*      IF sy-subrc EQ 0.
*        READ TABLE ls_month_cond2-range INTO DATA(ls_sel_opt_month2) INDEX 1.
*        IF sy-subrc EQ 0 .
*          lv_calendarmonth = ls_sel_opt_month2-low.
*        ENDIF.
*      ENDIF.
*      IF io_request->is_total_numb_of_rec_requested(  ) .
*        io_response->set_total_number_of_records( lines( lt_mfgorder_002 ) ).
*      ENDIF.



    ENDIF.
  ENDMETHOD.
ENDCLASS.
