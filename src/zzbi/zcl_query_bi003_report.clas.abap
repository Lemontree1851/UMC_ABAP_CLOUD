CLASS zcl_query_bi003_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_QUERY_BI003_REPORT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    CONSTANTS: lc_createdby_upload TYPE ernam VALUE 'UPLOAD'.
    DATA: lt_data TYPE TABLE OF zc_bi003_report_upload.

    IF io_request->is_data_requested( ).
      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
          LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
            CASE ls_filter_cond-name.
              WHEN 'UPLOADTYPE'.
                DATA(lv_uploadtype) = ls_filter_cond-range[ 1 ]-low.
              WHEN 'COMPANYCODE'.
                DATA(lr_companycode) = ls_filter_cond-range.
              WHEN 'YEARMONTH'.
                DATA(lr_yearmonth) = ls_filter_cond-range.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.
        CATCH cx_rap_query_filter_no_range.
          "handle exception
          IF io_request->is_total_numb_of_rec_requested(  ) .
            io_response->set_total_number_of_records( lines( lt_data ) ).
          ENDIF.
          "Sort
          zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                     CHANGING  ct_data  = lt_data ).
          " Paging
          zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                    CHANGING  ct_data   = lt_data ).

          io_response->set_data( lt_data ).
          RETURN.
      ENDTRY.

      CASE lv_uploadtype.
        WHEN 'SB'. " スポットバイ
          SELECT fiscal_year_period AS yearmonth,
                 company_code AS companycode,
                 company_code_name AS companycodetext,
                 customer AS customer,
                 customer_name AS customername,
                 company_currency AS companycurrency,
                 base_unit AS baseunit,
                 recovery_management_number AS recoverymanagementnumber,
                 purchase_order AS purchaseorder,
                 purchase_order_item AS purchaseorderitem,
                 spotbuy_material AS spotbuymaterial,
                 spotbuy_material_text AS spotbuymaterialtext,
                 net_price_amount AS spotbuymaterialprice,
                 product_old_id AS generalmaterial,
                 product_old_text AS generalmaterialtext,
                 old_material_price AS generalmaterialprice,
                 order_quantity AS materialquantity,
                 net_price_diff AS netpricediff,
                 recovery_necessary_amount AS recoverynecessaryamount
            FROM ztbi_bi003_j02
           WHERE company_code IN @lr_companycode
             AND fiscal_year_period IN @lr_yearmonth
             AND job_run_by = @lc_createdby_upload
            INTO CORRESPONDING FIELDS OF TABLE @lt_data.
        WHEN 'IN'. " イニシャル
          SELECT fiscal_year_period AS yearmonth,
                 company_code AS companycode,
                 company_code_name AS companycodetext,
                 customer AS customer,
                 customer_name AS customername,
                 company_currency AS companycurrency,
                 base_unit AS baseunit,
                 recovery_management_number AS recoverymanagementnumber,
                 purchase_order AS purchaseorder,
                 purchase_order_item AS purchaseorderitem,
                 material AS initialmaterial,
                 material_text AS initialmaterialtext,
                 product_group AS materiagroup,
                 accounting_document AS accountingdocument,
                 ledger_gl_line_item AS accountingdocumentitem,
                 gl_account AS glaccount,
                 gl_account_name AS glaccounttext,
                 fixed_asset AS fixedasset,
                 fixed_asset_description AS fixedassettext,
                 order_quantity AS poquantity,
                 net_price_amount AS netamount,
                 recovery_necessary_amount AS recoverynecessaryamount
            FROM ztbi_bi003_j03
           WHERE company_code IN @lr_companycode
             AND fiscal_year_period IN @lr_yearmonth
             AND job_run_by = @lc_createdby_upload
            INTO CORRESPONDING FIELDS OF TABLE @lt_data.
        WHEN 'ST'. " 特別輸送費
          SELECT fiscal_year_period AS yearmonth,
                 company_code AS companycode,
                 company_code_name AS companycodetext,
                 customer AS customer,
                 customer_name AS customername,
                 company_currency AS companycurrency,
                 base_unit AS baseunit,
                 recovery_management_number AS recoverymanagementnumber,
                 purchase_order AS purchaseorder,
                 purchase_order_item AS purchaseorderitem,
                 material AS transportexpensematerial,
                 material_text AS transportexpensematerialtext,
                 gl_account AS glaccount,
                 gl_account_name AS glaccounttext,
                 order_quantity AS poquantity,
                 net_price_amount AS netamount,
                 recovery_necessary_amount AS recoverynecessaryamount
            FROM ztbi_bi003_j04
           WHERE company_code IN @lr_companycode
             AND fiscal_year_period IN @lr_yearmonth
             AND job_run_by = @lc_createdby_upload
            INTO CORRESPONDING FIELDS OF TABLE @lt_data.
        WHEN 'SS'. " 在庫廃棄ロス
          SELECT fiscal_year_period AS yearmonth,
                 company_code AS companycode,
                 company_code_name AS companycodetext,
                 customer AS customer,
                 customer_name AS customername,
                 company_currency AS companycurrency,
                 entry_unit AS baseunit,
                 recovery_management_number AS recoverymanagementnumber,
                 material_document AS materialdocument,
                 material_document_item AS materialdocumentitem,
                 material AS ssmaterial,
                 product_name AS ssmaterialtext,
                 gl_account AS glaccount,
                 gl_account_name AS glaccounttext,
                 quantity_in_entry_unit AS quantity,
                 recovery_necessary_amount AS recoverynecessaryamount
            FROM ztbi_bi003_j05
           WHERE company_code IN @lr_companycode
             AND fiscal_year_period IN @lr_yearmonth
             AND job_run_by = @lc_createdby_upload
            INTO CORRESPONDING FIELDS OF TABLE @lt_data.
        WHEN OTHERS.
      ENDCASE.

*&--Authorization Check
      DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
      DATA(lv_company) = zzcl_common_utils=>get_company_by_user( lv_user_email ).
      IF lv_company IS INITIAL.
        CLEAR lt_data.
      ELSE.
        SPLIT lv_company AT '&' INTO TABLE DATA(lt_company_check).
        CLEAR lr_companycode.
        lr_companycode = VALUE #( FOR company IN lt_company_check ( sign = 'I' option = 'EQ' low = company ) ).
        DELETE lt_data WHERE companycode NOT IN lr_companycode.
      ENDIF.
*&--Authorization Check

      " Filtering
      zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
                                             it_excluded = VALUE #( ( fieldname = 'UPLOADTYPE' ) )
                                   CHANGING  ct_data     = lt_data ).

      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
        TRY.
            <lfs_data>-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
            ##NO_HANDLER
          CATCH cx_uuid_error.
            " handle exception
        ENDTRY.
      ENDLOOP.

      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( lines( lt_data ) ).
      ENDIF.

      "Sort
      zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                 CHANGING  ct_data  = lt_data ).

      " Paging
      zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                CHANGING  ct_data   = lt_data ).

      io_response->set_data( lt_data ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
