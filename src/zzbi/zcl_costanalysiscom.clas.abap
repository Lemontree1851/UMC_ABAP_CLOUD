CLASS zcl_costanalysiscom DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_COSTANALYSISCOM IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA:
      lt_data TYPE STANDARD TABLE OF zr_costanalysiscom,
      ls_data TYPE zr_costanalysiscom.

    DATA:
      lr_companycode TYPE RANGE OF zr_costanalysiscom-companycode,
      lv_zyear       TYPE zr_costanalysiscom-zyear,
      lv_zmonth      TYPE n LENGTH 2,
      lr_product     TYPE RANGE OF zr_costanalysiscom-product,
      lr_material    TYPE RANGE OF zr_costanalysiscom-material,
      lr_customer    TYPE RANGE OF zr_costanalysiscom-customer,
      ls_companycode LIKE LINE OF lr_companycode,
      ls_product     LIKE LINE OF lr_product,
      ls_material    LIKE LINE OF lr_material,
      ls_customer    LIKE LINE OF lr_customer,
      lr_zyear       TYPE RANGE OF zr_costanalysiscom-zyear,
      ls_zyear       LIKE LINE OF lr_zyear,
      lr_zmonth      TYPE RANGE OF zr_costanalysiscom-zmonth,
      ls_zmonth      LIKE LINE OF lr_zmonth,
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
                CLEAR ls_material.
                ls_material-sign   = 'I'.
                ls_material-option = 'EQ'.
                ls_material-low    = str_rec_l_range-low.
                APPEND ls_material TO lr_material.
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
           profitcentername,
*&--ADD BEGIN BY XINLEI XU 2025/04/10
           finalsuppliername,
           finalpurchaseorder,
           fixedsuppliername
*&--ADD END BY XINLEI XU 2025/04/10
      FROM ztbi_1001
     WHERE companycode IN @lr_companycode
       AND zyear       IN @lr_zyear
       AND zmonth      IN @lr_zmonth
       AND product     IN @lr_product
       AND material    IN @lr_material
       AND customer    IN @lr_customer
      INTO TABLE @DATA(lt_bi1001).

*&--Authorization Check
    DATA(lv_user_prefix) = sy-uname+0(2).
    IF lv_user_prefix = 'CB'.
      DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
      DATA(lv_companycode) = zzcl_common_utils=>get_company_by_user( lv_user_email ).
      IF lv_companycode IS INITIAL.
        CLEAR lt_bi1001.
      ELSE.
        SPLIT lv_companycode AT '&' INTO TABLE DATA(lt_company_check).
        CLEAR lr_companycode.
        lr_companycode = VALUE #( FOR companycode IN lt_company_check ( sign = 'I' option = 'EQ' low = companycode ) ).
        DELETE lt_bi1001 WHERE companycode NOT IN lr_companycode.
      ENDIF.
    ENDIF.
*&--Authorization Check

    LOOP AT lt_bi1001 ASSIGNING FIELD-SYMBOL(<lfs_bi1001>).
      APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      <lfs_data> = CORRESPONDING #( <lfs_bi1001> ).
      <lfs_data>-estimatedprice = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                        iv_currency = <lfs_bi1001>-currency
                                                                        iv_input = <lfs_bi1001>-estimatedprice ).

      <lfs_data>-finalprice = zzcl_common_utils=>conversion_amount( iv_alpha = zzcl_common_utils=>lc_alpha_out
                                                                    iv_currency = <lfs_bi1001>-currency
                                                                    iv_input = <lfs_bi1001>-finalprice ).

      <lfs_data>-finalsupplier = |{ <lfs_bi1001>-finalsupplier ALPHA = OUT }|.
      <lfs_data>-finalpurchaseorder = |{ <lfs_bi1001>-finalpurchaseorder ALPHA = OUT }|.
    ENDLOOP.

    " Filtering
    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
                                 CHANGING  ct_data   = lt_data ).

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
