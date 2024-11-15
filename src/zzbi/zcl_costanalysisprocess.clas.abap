CLASS zcl_costanalysisprocess DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_costanalysisprocess IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA:
      lt_data TYPE STANDARD TABLE OF zr_costanalysisprocess,
      ls_data TYPE zr_costanalysisprocess.

    DATA:
      lr_companycode TYPE RANGE OF zr_costanalysisprocess-companycode,
      lv_zyear       TYPE zr_costanalysisprocess-zyear,
      lv_zmonth      TYPE zr_costanalysisprocess-zmonth,
      lr_product     TYPE RANGE OF zr_costanalysisprocess-product,
      lr_customer    TYPE RANGE OF zr_costanalysisprocess-customer,
      ls_companycode LIKE LINE OF lr_companycode,
      ls_product     LIKE LINE OF lr_product,
      ls_customer    LIKE LINE OF lr_customer,
      lv_kunnr       TYPE kunnr.

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
            CASE ls_filter_cond-name.
              WHEN 'COMPANYCODE'.
                CLEAR ls_companycode.
                ls_companycode-sign   = 'I'.
                ls_companycode-option = 'EQ'.
                ls_companycode-low    = str_rec_l_range-low.
                APPEND ls_companycode TO lr_companycode.
              WHEN 'ZYEAR'.
                lv_zyear = str_rec_l_range-low.
              WHEN 'ZMONTH'.
                lv_zmonth = str_rec_l_range-low.
              WHEN 'PRODUCT'.
                CLEAR ls_product.
                ls_product-sign   = 'I'.
                ls_product-option = 'EQ'.
                ls_product-low    = str_rec_l_range-low.
                APPEND ls_product TO lr_product.
              WHEN 'CUSTOMER'.
                CLEAR ls_customer.
                ls_customer-sign   = 'I'.
                ls_customer-option = 'EQ'.

                lv_kunnr = str_rec_l_range-low.
                lv_kunnr = |{ lv_kunnr ALPHA = IN }|.
                ls_customer-low    = lv_kunnr.

                APPEND ls_customer TO lr_customer.

              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.
        ENDLOOP.

      CATCH cx_rap_query_filter_no_range.
        "handle exception
        io_response->set_data( lt_data ).
    ENDTRY.

    SELECT zyear,
           zmonth,
           yearmonth,
           companycode,
           plant,
           product,
           customer,
           customername,
           companycodetext,
           planttext,
           productdescription,
           estimatedprice_smt,
           estimatedprice_ai,
           estimatedprice_fat,
           actualprice_smt,
           actualprice_ai,
           actualprice_fat,
           currency,
           billingquantity,
           billingquantityunit
      FROM ztbi_1002
     WHERE COMPANYCODE in @lr_companycode
       and zyear       = @lv_zyear
       and zmonth      = @lv_zmonth
       and product     in @lr_product
       and CUSTOMER    in @lr_customer
      into TABLE @lt_data.

    io_response->set_total_number_of_records( lines( lt_data ) ).

    "Sort
    IF io_request->get_sort_elements( ) IS NOT INITIAL.
      zzcl_odata_utils=>orderby(
        EXPORTING
          it_order = io_request->get_sort_elements( )
        CHANGING
          ct_data  = lt_data ).
    ENDIF.

    "Page
    zzcl_odata_utils=>paging(
      EXPORTING
        io_paging = io_request->get_paging( )
      CHANGING
        ct_data   = lt_data ).

    io_response->set_data( lt_data ).
  ENDMETHOD.

ENDCLASS.
