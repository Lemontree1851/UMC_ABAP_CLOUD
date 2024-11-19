CLASS zcl_mfgorder_003 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MFGORDER_003 IMPLEMENTATION.


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
        companycode                 TYPE string,
        plant                       TYPE string,
        postingdate                 TYPE string,
        product                     TYPE string,
        glaccount                   TYPE string,
        amountincompanycodecurrency TYPE string,
        companycodecurrency         TYPE string,
        profitcenter                TYPE string,
        costcenter                  TYPE string,
      END OF ty_results,
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
      lr_plant        TYPE RANGE OF zc_mfgorder_003-plant,
      lrs_plant       LIKE LINE OF lr_plant,
      lr_companycode  TYPE RANGE OF zc_mfgorder_003-companycode,
      lrs_companycode LIKE LINE OF lr_companycode.
    DATA:
      lv_calendaryear  TYPE calendaryear,
      lv_calendarmonth TYPE calendarmonth.
    DATA:lv_calendarmonth_s TYPE string.

    DATA:lv_glaccount1(10) TYPE c,
         lv_glaccount2(10) TYPE c.
    DATA:
      lt_mfgorder_003     TYPE STANDARD TABLE OF zc_mfgorder_003,
      lt_mfgorder_003_out TYPE STANDARD TABLE OF zc_mfgorder_003,
      ls_mfgorder_003     TYPE zc_mfgorder_003.
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
        ENDIF.
      ENDIF.

      lv_glaccount1 = '0050301000'.
      lv_glaccount2 = '0050302000'.

      "从会计科目表明细中提取主要材料和辅助材料的帐户和金额合计
      lv_path = |/API_OPLACCTGDOCITEMCUBE_SRV/A_OperationalAcctgDocItemCube?$filter=FiscalYear%20eq%20'{ lv_calendaryear }'%20and%20(%20GLAccount%20eq%20'{ lv_glaccount1 }'%20or%20GLAccount%20eq%20'{ lv_glaccount2 }'%20)|.
      "Call API
      "      zzcl_common_utils=>request_api_v2(
      "        EXPORTING
      "         iv_path        = lv_path
      "          iv_method      = if_web_http_client=>get
      "        IMPORTING
      "          ev_status_code = DATA(lv_stat_code)
      "          ev_response    = DATA(lv_resbody_api) ).
      "      TRY.
      "          "JSON->ABAP
      "          xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
      "             ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api ) ).
      "        CATCH cx_root INTO DATA(lx_root1).
      "      ENDTRY.
*      SELECT
*      companycode                 ,
*      plant                       ,
*      postingdate                 ,
*      product                     ,
*      glaccount                   ,
*      amountincompanycodecurrency ,
*      companycodecurrency         ,
*      profitcenter                ,
*      costcenter                  ,
*      quantity
*      FROM  i_operationalacctgdocitem
*      WITH PRIVILEGED ACCESS
*      WHERE companycode IN @lr_companycode
*      AND plant IN @lr_plant
*      AND fiscalyear = @lv_calendaryear
*      AND fiscalperiod = @lv_calendarmonth
*      AND ( glaccount = @lv_glaccount1  OR glaccount = @lv_glaccount2 )
*      INTO TABLE @DATA(lt_operationalacctgdocitem).


      SELECT
      a~companycode                 ,
      a~plant                       ,
      a~postingdate                 ,
      a~product                     ,
      a~glaccount                   ,
      a~amountincompanycodecurrency ,
      a~companycodecurrency         ,
      a~profitcenter                ,
      a~costcenter                  ,
      a~quantity,

      a~accountingdocument,
      a~ledgergllineitem,
      b~AccountingDocumentType
      FROM  i_journalentryitem WITH PRIVILEGED ACCESS as a
      JOIN i_journalentry WITH PRIVILEGED ACCESS as b
      on a~companycode = b~companycode
      and a~accountingdocument = b~accountingdocument
      and a~fiscalyear = b~fiscalyear
      WHERE a~companycode IN @lr_companycode
      AND a~plant IN @lr_plant
      AND a~fiscalyear = @lv_calendaryear
      AND a~fiscalperiod = @lv_calendarmonth
      AND ( a~glaccount = @lv_glaccount1  OR a~glaccount = @lv_glaccount2 )
      AND a~sourceledger = '0L'
      AND a~ledger = '0L'
      INTO TABLE @DATA(lt_operationalacctgdocitem).

      IF lt_operationalacctgdocitem IS NOT INITIAL.

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

        "品目マスタから品目テキストを抽出
        SELECT
        product,
        productdescription
        FROM
        i_productdescription
        WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_operationalacctgdocitem
        WHERE product = @lt_operationalacctgdocitem-product
        AND language  = 'J'
        INTO TABLE @DATA(lt_productdescription).
        SORT lt_productdescription BY product.

        "品目マスタからMRP管理者を抽出
*        SELECT
*        product,
*        plant,
*        mrpresponsible
*        FROM i_productplantmrp
*        WITH PRIVILEGED ACCESS
*        FOR ALL ENTRIES IN @lt_operationalacctgdocitem
*        WHERE product = @lt_operationalacctgdocitem-product
*        "and MRPArea = ???
*        INTO TABLE @DATA(lt_productplantmrp).
*        SORT lt_productplantmrp BY product plant.

        SELECT
        product,
        plant,
        mrpresponsible
        FROM i_productplantbasic
        WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_operationalacctgdocitem
        WHERE product = @lt_operationalacctgdocitem-product
        "and MRPArea = ???
        INTO TABLE @DATA(lt_productplantmrp).
        SORT lt_productplantmrp BY product plant.

        "BPマスタから得意先のBPコードとBPテキストを抽出
        SELECT
        businesspartner,
        businesspartnername,
        searchterm2
        FROM i_businesspartner
        WITH PRIVILEGED ACCESS
        WHERE searchterm2 IS NOT INITIAL
        INTO TABLE @DATA(lt_businesspartner).
        SORT lt_businesspartner BY searchterm2.

        "品目マスタから製品が属される利益センタを抽出
        SELECT
        profitcenter,
        profitcentername AS profitcenterlongname
        FROM i_profitcentertext
        WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_operationalacctgdocitem
        WHERE profitcenter = @lt_operationalacctgdocitem-profitcenter
        AND language = 'J'
        "AND ControllingArea  = ????
        "AND ValidityEndDate  = ????
        INTO TABLE @DATA(lt_profitcentertext).
        SORT lt_profitcentertext BY profitcenter.

        DATA:lv_zamount1 TYPE i_operationalacctgdocitem-amountincompanycodecurrency.
        DATA:lv_zamount2 TYPE i_operationalacctgdocitem-amountincompanycodecurrency.

        LOOP AT lt_operationalacctgdocitem INTO DATA(ls_data).

          CLEAR ls_mfgorder_003.

          ls_mfgorder_003-calendaryear = |{ lv_calendaryear ALPHA = IN }|."'年月'
          ls_mfgorder_003-calendarmonth = |{ lv_calendarmonth ALPHA = IN }|."'年月'
          ls_mfgorder_003-yearmonth = lv_calendaryear && '0' && lv_calendarmonth."'年月'
          ls_mfgorder_003-companycode = ls_data-companycode."'会社コード'
          ls_mfgorder_003-plant = ls_data-plant."'プラント'
          ls_mfgorder_003-profitcenter = ls_data-profitcenter."'利益センタ'
          ls_mfgorder_003-displaycurrency = ls_data-companycodecurrency."'照会通貨'
          ls_mfgorder_003-product = ls_data-product.
          ls_mfgorder_003-AccountingDocumentType = ls_data-AccountingDocumentType.

          ls_mfgorder_003-accountingdocument = ls_data-accountingdocument.
          ls_mfgorder_003-ledgergllineitem = ls_data-ledgergllineitem.



          "IF ls_data-quantity IS NOT INITIAL AND ls_data-glaccount = lv_glaccount1.
          "  ls_mfgorder_003-zamount1 = ls_data-amountincompanycodecurrency / ls_data-quantity.
          "ENDIF.
          "IF ls_data-quantity IS NOT INITIAL AND ls_data-glaccount = lv_glaccount2.
          "  ls_mfgorder_003-zamount2 = ls_data-amountincompanycodecurrency / ls_data-quantity.
          "ENDIF.
          IF ls_data-glaccount = lv_glaccount1.
            ls_mfgorder_003-zamount1 = ls_data-amountincompanycodecurrency .
          ENDIF.
          IF  ls_data-glaccount = lv_glaccount2.
            ls_mfgorder_003-zamount2 = ls_data-amountincompanycodecurrency .
          ENDIF.
          "'得意先' "'得意先テキスト'
          READ TABLE lt_productplantmrp INTO DATA(ls_productplantmrp) WITH KEY product = ls_mfgorder_003-product plant = ls_data-plant BINARY SEARCH.
          IF sy-subrc = 0.
            DATA:lv_str2(2) TYPE c.
            DATA:lv_i TYPE i.
            CLEAR lv_str2.
            lv_i = strlen( ls_productplantmrp-mrpresponsible ).
            lv_i = lv_i - 2.
            IF lv_i >= 0.
              lv_str2 = ls_productplantmrp-mrpresponsible+lv_i(2).
              READ TABLE lt_businesspartner INTO DATA(ls_businesspartner) WITH KEY searchterm2 = lv_str2 BINARY SEARCH.
              IF sy-subrc = 0.
                "'得意先'
                ls_mfgorder_003-soldtoparty = ls_businesspartner-businesspartner.
                "'得意先テキスト'
                ls_mfgorder_003-businesspartnername = ls_businesspartner-businesspartnername.
              ENDIF.
            ENDIF.
          ENDIF.

          "'利益センタテキスト'
          READ TABLE lt_profitcentertext INTO DATA(ls_profitcentertext) WITH KEY profitcenter = ls_data-profitcenter BINARY SEARCH.
          IF sy-subrc = 0.
            ls_mfgorder_003-profitcenterlongname = ls_profitcentertext-profitcenterlongname."'利益センタテキスト'
          ENDIF.

          "'会社コードテキスト'
          READ TABLE lt_companycode INTO DATA(ls_companycode) WITH KEY companycode = ls_data-companycode BINARY SEARCH.
          IF sy-subrc = 0.
            ls_mfgorder_003-companycodetext = ls_companycode-companycodename."'会社コードテキスト'
          ENDIF.
          "'プラントテキスト'
          READ TABLE lt_plant INTO DATA(ls_plant) WITH KEY plant = ls_data-plant BINARY SEARCH.
          IF sy-subrc = 0.
            ls_mfgorder_003-planttext = ls_plant-plantname."'プラントテキスト'
          ENDIF.
          "'製品テキスト'
          READ TABLE lt_productdescription INTO DATA(ls_productdescription) WITH KEY product = ls_mfgorder_003-product BINARY SEARCH.
          IF sy-subrc = 0.
            ls_mfgorder_003-productdescription = ls_productdescription-productdescription."'製品テキスト'
          ENDIF.

          ls_mfgorder_003-profitcenter = |{ ls_mfgorder_003-profitcenter ALPHA = OUT }|.
          ls_mfgorder_003-soldtoparty = |{ ls_mfgorder_003-soldtoparty ALPHA = OUT }|.

          "ls_mfgorder_003-zamount1 = zzcl_common_utils=>conversion_amount(
          "                            iv_alpha = 'OUT'
          "                            iv_currency =  ls_data-companycodecurrency
          "                            iv_input = ls_mfgorder_003-zamount1 ).
          "ls_mfgorder_003-zamount2 = zzcl_common_utils=>conversion_amount(
          "                             iv_alpha = 'OUT'
          "                             iv_currency = ls_data-companycodecurrency
           "                            iv_input = ls_mfgorder_003-zamount2 ).

*          READ TABLE lt_mfgorder_003 ASSIGNING FIELD-SYMBOL(<ls_old>) WITH KEY
*          yearmonth = ls_mfgorder_003-yearmonth
*          companycode = ls_mfgorder_003-companycode
*          plant = ls_mfgorder_003-plant
*          product = ls_mfgorder_003-product
*          profitcenter = ls_mfgorder_003-profitcenter
*          soldtoparty = ls_mfgorder_003-soldtoparty.
*          IF sy-subrc = 0.
*            <ls_old>-zamount1 += ls_mfgorder_003-zamount1.
*            <ls_old>-zamount2 += ls_mfgorder_003-zamount2.
*          ELSE.
          APPEND ls_mfgorder_003 TO lt_mfgorder_003.
          "          ENDIF.

        ENDLOOP.



      ENDIF.

      " Filtering
      " zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
      "                              CHANGING  ct_data   = lt_mfgorder_003 ).
      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( lines( lt_mfgorder_003 ) ).
      ENDIF.

      "Sort
      zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                 CHANGING  ct_data  = lt_mfgorder_003 ).

      " Paging
      zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                CHANGING  ct_data   = lt_mfgorder_003 ).



      io_response->set_data( lt_mfgorder_003 ).

    ELSE.
      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( 3 ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
