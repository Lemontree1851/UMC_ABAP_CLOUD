CLASS zcl_purchasereq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PURCHASEREQ IMPLEMENTATION.


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
        "manufacturingorder        TYPE i_manufacturingorder-manufacturingorder,
        product                   TYPE i_mfgorderactlplantgtldgrcost-producedproduct,
        mfgorderconfirmedyieldqty TYPE i_manufacturingorder-mfgorderconfirmedyieldqty,
        productionsupervisor      TYPE i_manufacturingorder-productionsupervisor,
      END OF ty_data2.
    TYPES:
      BEGIN OF ty_results,
        accountingcostrateuuid     TYPE string,
        companycode                TYPE string,
        costcenter                 TYPE string,
        activitytype               TYPE string,
        currency                   TYPE string,
        controllingarea            TYPE string,
        validitystartfiscalyear    TYPE string,
        validitystartfiscalperiod  TYPE string,
        validityendfiscalyear      TYPE string,
        validityendfiscalperiod    TYPE string,
        costratefixedamount        TYPE string,
        costratevarblamount        TYPE string,
        costratescalefactor        TYPE string,
        costctractivitytypeqtyunit TYPE string,
        ledger                     TYPE string,
        costrateisoverwritemode    TYPE string,
      END OF ty_results,
      tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,
      BEGIN OF ty_res_api,
        value TYPE tt_results,
      END OF ty_res_api,

      BEGIN OF ty_results1,
        accountingcostrateuuid     TYPE string,
        companycode                TYPE string,
        costcenter                 TYPE string,
        activitytype               TYPE string,
        currency                   TYPE string,
        controllingarea            TYPE string,
        validitystartfiscalyear    TYPE string,
        validitystartfiscalperiod  TYPE string,
        validityendfiscalyear      TYPE string,
        validityendfiscalperiod    TYPE string,
        costratefixedamount        TYPE string,
        costratevarblamount        TYPE string,
        costratescalefactor        TYPE string,
        costctractivitytypeqtyunit TYPE string,
        ledger                     TYPE string,
        costrateisoverwritemode    TYPE string,
        depreciationkeyname(50)    TYPE c,
      END OF ty_results1,
      tt_results1 TYPE STANDARD TABLE OF ty_results1 WITH DEFAULT KEY,

      BEGIN OF ty_res_api1,
        value TYPE tt_results1,
      END OF ty_res_api1.
    TYPES:
      BEGIN OF ty_results3,
        isassembly              TYPE string,
        "companycode             TYPE string,
        plant                   TYPE string,
        "manufacturingorder         TYPE string,
        billofmaterialcomponent TYPE string,
        material                TYPE string,
      END OF ty_results3,

      tt_results3 TYPE STANDARD TABLE OF ty_results3 WITH DEFAULT KEY,
      BEGIN OF ty_d,
        results TYPE tt_results3,
      END OF ty_d,
      BEGIN OF ty_res_api3,
        d TYPE ty_d,
      END OF ty_res_api3.
    DATA:ls_res_api3  TYPE ty_res_api3.
    DATA:
      lv_orderby_string TYPE string,
      lv_select_string  TYPE string.
    "select options
    DATA:
      lr_plant        TYPE RANGE OF zc_mfgorder_001-plant,
      lrs_plant       LIKE LINE OF lr_plant,
      lr_companycode  TYPE RANGE OF zc_mfgorder_001-companycode,
      lrs_companycode LIKE LINE OF lr_companycode.
    DATA:
      lv_calendaryear  TYPE calendaryear,
      lv_calendarmonth TYPE calendarmonth.
    DATA:lv_date_f TYPE aedat.
    DATA:lv_date_t TYPE aedat.
    DATA:lv_date_s TYPE aedat.
    DATA:lv_date_e TYPE aedat.
    DATA:lv_calendarmonth_s TYPE string.
    DATA:
      lt_mfgorder_001     TYPE STANDARD TABLE OF zc_mfgorder_001,
      lt_mfgorder_001_out TYPE STANDARD TABLE OF zc_mfgorder_001,
      ls_mfgorder_001     TYPE zc_mfgorder_001.
    DATA:lv_path     TYPE string.
    DATA:ls_res_api  TYPE ty_res_api.
    DATA:ls_res_api1 TYPE ty_res_api1.
    DATA:lc_alpha_out     TYPE string        VALUE 'OUT'.

    DATA:lv_zero TYPE i_manufacturingorder-mfgorderconfirmedyieldqty.
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

*****************************************************************
*       Filter
*****************************************************************
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
*****************************************************************
*       Check Data
*****************************************************************
*****************************************************************
*       Get Data
*****************************************************************

    DATA:
      lt_PRWORKFLOW_dup     TYPE STANDARD TABLE OF ZR_PRWORKFLOW_dup,
      lt_PRWORKFLOW_dup_out TYPE STANDARD TABLE OF ZR_PRWORKFLOW_dup,
      ls_PRWORKFLOW_dup     TYPE ZR_PRWORKFLOW_dup.

      SELECT
         apply_depart                           as ApplyDepart_dup,
        pr_no                                  as PrNo_dup,
         uuid                                   as UUID_dup

      FROM ztmm_1006 INTO CORRESPONDING FIELDS OF TABLE @lt_PRWORKFLOW_dup.

      " Filtering
      "zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
      "                              CHANGING  ct_data   = lt_mfgorder_001 ).
      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( lines( lt_PRWORKFLOW_dup ) ).
      ENDIF.

      "Sort
      zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                 CHANGING  ct_data  = lt_PRWORKFLOW_dup ).

      " Paging
      zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                               CHANGING  ct_data   = lt_PRWORKFLOW_dup ).



      io_response->set_data( lt_PRWORKFLOW_dup ).
    ELSE.

      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( 1 ).
      ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
