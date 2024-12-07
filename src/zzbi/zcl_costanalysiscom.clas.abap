CLASS zcl_costanalysiscom DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_costanalysiscom IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA:
      lt_data TYPE STANDARD TABLE OF zr_costanalysiscom,
      ls_data TYPE zr_costanalysiscom.

    DATA:
      lr_companycode TYPE RANGE OF zr_costanalysiscom-companycode,
      lv_zyear       TYPE zr_costanalysiscom-zyear,
      lv_zmonth      TYPE N LENGTH 2,
      lr_product     TYPE RANGE OF zr_costanalysiscom-MATERIAL,
      lr_customer    TYPE RANGE OF zr_costanalysiscom-customer,
      ls_companycode LIKE LINE OF lr_companycode,
      ls_product     LIKE LINE OF lr_product,
      ls_customer    LIKE LINE OF lr_customer,
      lr_zyear       TYPE RANGE OF zr_costanalysiscom-zyear,
      ls_zyear       LIKE LINE OF lr_zyear,
      lr_zmonth       TYPE RANGE OF zr_costanalysiscom-zmonth,
      ls_zmonth       LIKE LINE OF lr_zmonth,
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

                CLEAR ls_zyear.
                ls_zyear-sign   = 'I'.
                ls_zyear-option = 'EQ'.
                ls_zyear-low    = lv_zyear.
                APPEND ls_zyear TO lr_zyear.
              WHEN 'ZMONTH'.
                lv_zmonth = str_rec_l_range-low.

                CLEAR ls_zmonth.
                ls_zmonth-sign   = 'I'.
                ls_zmonth-option = 'EQ'.
                ls_zmonth-low    = lv_zmonth.
                APPEND ls_zmonth TO lr_zmonth.
              WHEN 'MATERIAL'.
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
           material,
           companycodetext,
           planttext,
           productdescription,
           materialdescription,
           quantity,
           customer,
           customername,
           estimatedprice,
           finalprice,
           finalpostingdate,
           finalsupplier,
           fixedsupplier,
           standardprice,
           movingaverageprice,
           currency,
           billingquantity,
           billingquantityunit,
           sales_number,
           quo_version,
           sales_d_no,
           profitcenter,
           profitcentername
      FROM ztbi_1001
     WHERE companycode in @lr_companycode
       and zyear       in @lr_zyear
       and zmonth      in @lr_zmonth
       and product     in @lr_product
       and customer    in @lr_customer
      into CORRESPONDING FIELDS OF TABLE @lt_data.

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
