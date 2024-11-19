CLASS zcl_paidpay_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PAIDPAY_REPORT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA:
      lt_output TYPE STANDARD TABLE OF zr_paidpay_report,
      ls_output TYPE zr_paidpay_report.


* Get filter range
    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          CASE ls_filter_cond-name.
            WHEN 'COMPANYCODE'.
              DATA(lr_bukrs) = ls_filter_cond-range.
              READ TABLE lr_bukrs INTO DATA(lrs_bukrs) INDEX 1.
              DATA(lv_bukrs) = lrs_bukrs-low.
            WHEN 'FISCALYEAR'.
              DATA(lr_gjahr) = ls_filter_cond-range.
              READ TABLE lr_gjahr INTO DATA(lrs_gjahr) INDEX 1.
              DATA(lv_gjahr) = lrs_gjahr-low.
            WHEN 'PERIOD'.
              DATA(lr_monat) = ls_filter_cond-range.
              READ TABLE lr_monat INTO DATA(lrs_monat) INDEX 1.
              DATA(lv_monat) = lrs_monat-low.
            WHEN 'ZTYPE'.
              DATA(lr_ztype) = ls_filter_cond-range.
              READ TABLE lr_ztype INTO DATA(lrs_ztype) INDEX 1.
              DATA(lv_ztype) = lrs_ztype-low.
          ENDCASE.
        ENDLOOP.
      CATCH cx_rap_query_filter_no_range.
        "handle exception
        io_response->set_data( lt_output ).
    ENDTRY.


    CASE lv_ztype.
      WHEN 'A'.    "期首在庫金額
        SELECT *
          FROM ztfi_1008 WITH PRIVILEGED ACCESS
         WHERE companycode IN @lr_bukrs
           AND fiscalyear = @lv_gjahr
           AND period = @lv_monat
          INTO TABLE @DATA(lt_1008).
        IF lt_1008 IS NOT INITIAL.
          SELECT businesspartner,
                 businesspartnername
            FROM i_businesspartner WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_1008
           WHERE businesspartner = @lt_1008-businesspartner
            INTO TABLE @DATA(lt_bp).

          SELECT purchasinggroup,
                 purchasinggroupname
            FROM i_purchasinggroup WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_1008
           WHERE purchasinggroup = @lt_1008-purchasinggroup
            INTO TABLE @DATA(lt_ekgrp).

          SELECT profitcenter,
                 profitcentername
            FROM i_profitcentertext WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_1008
           WHERE profitcenter = @lt_1008-profitcenter
             AND language = @sy-langu
            INTO TABLE @DATA(lt_prctr).
        ENDIF.
        SORT lt_bp BY businesspartner.
        SORT lt_ekgrp BY purchasinggroup.
        SORT lt_prctr BY profitcenter.
        LOOP AT lt_1008 INTO DATA(ls_1008).
          MOVE-CORRESPONDING ls_1008 TO ls_output.
          ls_output-ztype = lv_ztype.

          READ TABLE lt_bp INTO DATA(ls_bp)
               WITH KEY businesspartner = ls_1008-businesspartner BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-businesspartnername = ls_bp-businesspartnername.
          ENDIF.

          READ TABLE lt_ekgrp INTO DATA(ls_ekgrp)
               WITH KEY purchasinggroup = ls_1008-purchasinggroup BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-purchasinggroupname = ls_ekgrp-purchasinggroupname.
          ENDIF.

          READ TABLE lt_prctr INTO DATA(ls_prctr)
               WITH KEY profitcenter = ls_1008-profitcenter BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-profitcentername = ls_prctr-profitcentername.
          ENDIF.
          ls_output-businesspartner = |{ ls_output-businesspartner ALPHA = OUT }|.
          APPEND ls_output TO lt_output.
          CLEAR: ls_output.
        ENDLOOP.

      WHEN 'B'.    "期首仕入金額
        SELECT *
          FROM ztfi_1009 WITH PRIVILEGED ACCESS
         WHERE companycode IN @lr_bukrs
           AND fiscalyear = @lv_gjahr
           AND period = @lv_monat
          INTO TABLE @DATA(lt_1009).

        IF lt_1009 IS NOT INITIAL.
          SELECT businesspartner,
                 businesspartnername
            FROM i_businesspartner
            FOR ALL ENTRIES IN @lt_1009
           WHERE businesspartner = @lt_1009-businesspartner
            INTO TABLE @lt_bp.

          SELECT purchasinggroup,
                 purchasinggroupname
            FROM i_purchasinggroup
            FOR ALL ENTRIES IN @lt_1009
           WHERE purchasinggroup = @lt_1009-purchasinggroup
            INTO TABLE @lt_ekgrp.

          SELECT profitcenter,
                 profitcentername
            FROM i_profitcentertext WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_1009
           WHERE profitcenter = @lt_1009-profitcenter
             AND language = @sy-langu
            INTO TABLE @lt_prctr.
        ENDIF.
        SORT lt_bp BY businesspartner.
        SORT lt_ekgrp BY purchasinggroup.
        SORT lt_prctr BY profitcenter.
        LOOP AT lt_1009 INTO DATA(ls_1009).
          MOVE-CORRESPONDING ls_1009 TO ls_output.
          ls_output-ztype = lv_ztype.
          READ TABLE lt_bp INTO ls_bp
               WITH KEY businesspartner = ls_1009-businesspartner BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-businesspartnername = ls_bp-businesspartnername.
          ENDIF.

          READ TABLE lt_ekgrp INTO ls_ekgrp
               WITH KEY purchasinggroup = ls_1009-purchasinggroup BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-purchasinggroupname = ls_ekgrp-purchasinggroupname.
          ENDIF.

          READ TABLE lt_prctr INTO ls_prctr
               WITH KEY profitcenter = ls_1009-profitcenter BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-profitcentername = ls_prctr-profitcentername.
          ENDIF.
          ls_output-businesspartner = |{ ls_output-businesspartner ALPHA = OUT }|.
          APPEND ls_output TO lt_output.
          CLEAR: ls_output.
        ENDLOOP.
    ENDCASE.


    " Filtering
    zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
                                 CHANGING  ct_data     = lt_output ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_output ) ).
    ENDIF.

    "Sort
    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                               CHANGING  ct_data  = lt_output ).

    " Paging
    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                              CHANGING  ct_data   = lt_output ).

    io_response->set_data( lt_output ).

  ENDMETHOD.
ENDCLASS.
