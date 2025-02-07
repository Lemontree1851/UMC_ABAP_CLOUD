CLASS lhc_bi003upload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_request_data,
            recoverymanagementnumber TYPE ze_recycle_no, " 回収管理番号
          END OF lty_request_data,
          BEGIN OF lty_request,
            uploadtype TYPE ze_recycle_type,
            jsondata   TYPE TABLE OF lty_request_data WITH DEFAULT KEY,
          END OF lty_request,
          BEGIN OF lty_check_table,
            recoverymanagementnumber TYPE ze_recycle_no, " 回収管理番号
            companycode              TYPE bukrs,
            companyname              TYPE bktxt,
            customer                 TYPE kunnr,
            customername             TYPE string,
          END OF lty_check_table,
          lty_check_table_t TYPE TABLE OF lty_check_table.

    TYPES:BEGIN OF lty_upload_type_sb,
            row                      TYPE i,
            status                   TYPE bapi_mtype,
            message                  TYPE string,
            yearmonth                TYPE string,        " 会計期間
            recoverymanagementnumber TYPE ze_recycle_no, " 回収管理番号
            purchaseorder            TYPE string,        " 発注伝票
            purchaseorderitem        TYPE string,        " 発注伝票明細
            spotbuymaterial          TYPE string,        " スポットバイ品目
            spotbuymaterialtext      TYPE string,        " スポットバイ品目テキスト
            spotbuymaterialprice     TYPE string,        " スポットバイ品目単価
            generalmaterial          TYPE string,        " 通常品目
            generalmaterialtext      TYPE string,        " 通常品目テキスト
            generalmaterialprice     TYPE string,        " 通常品目最新発注単価
            materialquantity         TYPE string,        " スポットバイ品目入庫数量
          END OF lty_upload_type_sb,
          BEGIN OF lty_upload_type_in,
            row                      TYPE i,
            status                   TYPE bapi_mtype,
            message                  TYPE string,
            yearmonth                TYPE string,        " 会計期間
            recoverymanagementnumber TYPE ze_recycle_no, " 回収管理番号
            purchaseorder            TYPE string,        " 発注伝票
            purchaseorderitem        TYPE string,        " 発注伝票明細
            initialmaterial          TYPE string,        " イニシャル品目
            initialmaterialtext      TYPE string,        " イニシャル品目テキスト
            materiagroup             TYPE string,        " 品目グループ
            accountingdocument       TYPE string,        " 会計伝票
            accountingdocumentitem   TYPE string,        " 会計伝票明細
            glaccount                TYPE string,        " 勘定科目
            glaccounttext            TYPE string,        " 勘定科目テキスト
            fixedasset               TYPE string,        " 固定資産番号
            fixedassettext           TYPE string,        " 固定資産テキスト
            poquantity               TYPE string,        " 発注伝票数量
            netamount                TYPE string,        " 発注伝票単価
            recoverynecessaryamount  TYPE string,        " 回収必要金額
          END OF lty_upload_type_in,
          BEGIN OF lty_upload_type_st,
            row                          TYPE i,
            status                       TYPE bapi_mtype,
            message                      TYPE string,
            yearmonth                    TYPE string,        " 会計期間
            recoverymanagementnumber     TYPE ze_recycle_no, " 回収管理番号
            purchaseorder                TYPE string,        " 発注伝票
            purchaseorderitem            TYPE string,        " 発注伝票明細
            transportexpensematerial     TYPE string,        " 特別輸送費品目
            transportexpensematerialtext TYPE string,        " 特別輸送費品目テキスト
            poquantity                   TYPE string,        " 発注伝票数量
            netamount                    TYPE string,        " 発注伝票単価
            recoverynecessaryamount      TYPE string,        " 回収必要金額
          END OF lty_upload_type_st,
          BEGIN OF lty_upload_type_ss,
            row                      TYPE i,
            status                   TYPE bapi_mtype,
            message                  TYPE string,
            yearmonth                TYPE string,        " 会計期間
            recoverymanagementnumber TYPE ze_recycle_no, " 回収管理番号
            materialdocument         TYPE string,        " 品目入出庫伝票
            materialdocumentitem     TYPE string,        " 品目入出庫伝票明細
            ssmaterial               TYPE string,        " 在庫廃棄ロス品目
            ssmaterialtext           TYPE string,        " 在庫廃棄ロス品目テキスト
            glaccount                TYPE string,        " 勘定科目
            glaccounttext            TYPE string,        " 勘定科目テキスト
            quantity                 TYPE string,        " 品目入出庫伝票数量
            recoverynecessaryamount  TYPE string,        " 回収必要金額
          END OF lty_upload_type_ss.

    TYPES: BEGIN OF lty_upload_sb,
             uploadtype TYPE string,
             jsondata   TYPE TABLE OF lty_upload_type_sb WITH DEFAULT KEY,
           END OF lty_upload_sb,
           BEGIN OF lty_upload_in,
             uploadtype TYPE string,
             jsondata   TYPE TABLE OF lty_upload_type_in WITH DEFAULT KEY,
           END OF lty_upload_in,
           BEGIN OF lty_upload_st,
             uploadtype TYPE string,
             jsondata   TYPE TABLE OF lty_upload_type_st WITH DEFAULT KEY,
           END OF lty_upload_st,
           BEGIN OF lty_upload_ss,
             uploadtype TYPE string,
             jsondata   TYPE TABLE OF lty_upload_type_ss WITH DEFAULT KEY,
           END OF lty_upload_ss.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR bi003upload RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION bi003upload~processlogic RESULT result.

    METHODS get_check_table IMPORTING is_request     TYPE lty_request
                            CHANGING  ct_check_table TYPE lty_check_table_t.

    METHODS save IMPORTING iv_upload_type TYPE ze_recycle_type
                           it_check_table TYPE lty_check_table_t
                 CHANGING  cs_data        TYPE string.

    METHODS delete IMPORTING iv_upload_type TYPE ze_recycle_type
                   CHANGING  cs_data        TYPE string.

    METHODS export IMPORTING iv_upload_type       TYPE ze_recycle_type
                             is_data              TYPE string
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.
ENDCLASS.

CLASS lhc_bi003upload IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD processlogic.
    DATA: ls_request TYPE lty_request.
    DATA: lt_check_table TYPE lty_check_table_t.
    DATA: ls_request_data TYPE string.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR: ls_request.
      CLEAR: ls_request_data.

      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = ls_request ).

      ls_request_data = key-%param-zzkey.

      CASE lv_event.
        WHEN 'SAVE'.
          get_check_table( EXPORTING is_request     = ls_request
                           CHANGING  ct_check_table = lt_check_table ).

          save( EXPORTING iv_upload_type = ls_request-uploadtype
                          it_check_table = lt_check_table
                CHANGING  cs_data = ls_request_data ).

          APPEND VALUE #( %cid   = key-%cid
                          %param = VALUE #( event = lv_event
                                            zzkey = ls_request_data ) ) TO result.
        WHEN 'DELETE'.
          delete( EXPORTING iv_upload_type = ls_request-uploadtype
                  CHANGING  cs_data = ls_request_data ).

          APPEND VALUE #( %cid   = key-%cid
                          %param = VALUE #( event = lv_event
                                            zzkey = ls_request_data ) ) TO result.
        WHEN 'EXPORT'.
          DATA(lv_recorduuid) = export( EXPORTING iv_upload_type = ls_request-uploadtype
                                                  is_data = ls_request_data ).
          APPEND VALUE #( %cid   = key-%cid
                          %param = VALUE #( event = lv_event
                                            zzkey = ls_request_data
                                            recorduuid = lv_recorduuid ) ) TO result.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_check_table.
    SELECT recovery_management_number AS recoverymanagementnumber,
           company_code AS companycode,
           company_name AS companyname,
           customer AS customer,
           customer_name AS customername
      FROM ztbi_recy_info
       FOR ALL ENTRIES IN @is_request-jsondata
     WHERE recovery_management_number = @is_request-jsondata-recoverymanagementnumber
      APPENDING TABLE @ct_check_table.

    SORT ct_check_table BY recoverymanagementnumber.
  ENDMETHOD.

  METHOD save.
    DATA: ls_upload_sb TYPE lty_upload_sb,
          ls_upload_in TYPE lty_upload_in,
          ls_upload_st TYPE lty_upload_st,
          ls_upload_ss TYPE lty_upload_ss.

    DATA: ls_update_sb TYPE ztbi_bi003_j02,
          ls_update_in TYPE ztbi_bi003_j03,
          ls_update_st TYPE ztbi_bi003_j04,
          ls_update_ss TYPE ztbi_bi003_j05,
          lt_update_sb TYPE TABLE OF ztbi_bi003_j02,
          lt_update_in TYPE TABLE OF ztbi_bi003_j03,
          lt_update_st TYPE TABLE OF ztbi_bi003_j04,
          lt_update_ss TYPE TABLE OF ztbi_bi003_j05.

    DATA: ls_upload_record TYPE ztbi_bi003_up.
    DATA: lv_message   TYPE string,
          lv_msg       TYPE string,
          lv_timestamp TYPE tzntstmpl.

    CASE iv_upload_type.
      WHEN 'SB'.
        /ui2/cl_json=>deserialize( EXPORTING json = cs_data
                                   CHANGING  data = ls_upload_sb ).

        LOOP AT ls_upload_sb-jsondata ASSIGNING FIELD-SYMBOL(<lfs_upload_sb>).
          CLEAR: lv_message.
          CLEAR: ls_update_sb.

          IF <lfs_upload_sb>-yearmonth IS NOT INITIAL.
            ls_update_sb-fiscal_year_period = |{ <lfs_upload_sb>-yearmonth+0(4) }0{ <lfs_upload_sb>-yearmonth+4(2) }|..
            ls_update_sb-fiscal_year = <lfs_upload_sb>-yearmonth+0(4).
            ls_update_sb-fiscal_month = <lfs_upload_sb>-yearmonth+4(2).
          ELSE.
            lv_msg = |必須項目「会計年月」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_sb>-recoverymanagementnumber IS INITIAL.
            lv_msg = |必須項目「回収管理番号」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ELSE.
            READ TABLE it_check_table INTO DATA(ls_check_data) WITH KEY recoverymanagementnumber = <lfs_upload_sb>-recoverymanagementnumber
                                                                        BINARY SEARCH.
            IF sy-subrc = 0.
              ls_update_sb-company_code = ls_check_data-companycode.
              ls_update_sb-company_code_name = ls_check_data-companyname.
              ls_update_sb-recovery_management_number = <lfs_upload_sb>-recoverymanagementnumber.
              ls_update_sb-customer = ls_check_data-customer.
              ls_update_sb-customer_name = ls_check_data-customername.
            ELSE.
              lv_msg = |回収管理番号は登録されていません。|.
              lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
            ENDIF.
          ENDIF.

          IF <lfs_upload_sb>-purchaseorder IS NOT INITIAL.
            ls_update_sb-purchase_order = |{ <lfs_upload_sb>-purchaseorder ALPHA = IN }|.
          ELSE.
            lv_msg = |必須項目「発注伝票」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_sb>-purchaseorderitem IS NOT INITIAL.
            ls_update_sb-purchase_order_item = <lfs_upload_sb>-purchaseorderitem.
          ELSE.
            lv_msg = |必須項目「発注伝票明細」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_sb>-spotbuymaterial IS NOT INITIAL.
            ls_update_sb-spotbuy_material = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_upload_sb>-spotbuymaterial ).
          ELSE.
            lv_msg = |必須項目「スポットバイ品目」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_sb>-spotbuymaterialtext IS NOT INITIAL.
            ls_update_sb-spotbuy_material_text = <lfs_upload_sb>-spotbuymaterialtext.
          ELSE.
            lv_msg = |必須項目「スポットバイ品目テキスト」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_sb>-spotbuymaterialprice IS NOT INITIAL.
            ls_update_sb-net_price_amount = <lfs_upload_sb>-spotbuymaterialprice.
          ELSE.
            lv_msg = |必須項目「スポットバイ品目単価」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_sb>-materialquantity IS NOT INITIAL.
            ls_update_sb-order_quantity = <lfs_upload_sb>-materialquantity.
          ELSE.
            lv_msg = |必須項目「スポットバイ品目入庫数量」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_sb>-generalmaterial IS NOT INITIAL.
            ls_update_sb-product_old_id = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_upload_sb>-generalmaterial ).
          ELSE.
            lv_msg = |必須項目「通常品目」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_sb>-generalmaterialtext IS NOT INITIAL.
            ls_update_sb-product_old_text = <lfs_upload_sb>-generalmaterialtext.
          ELSE.
            lv_msg = |必須項目「通常品目テキスト」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_sb>-generalmaterialprice IS NOT INITIAL.
            ls_update_sb-old_material_price = <lfs_upload_sb>-generalmaterialprice.
          ELSE.
            lv_msg = |必須項目「通常品目最新発注単価」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF lv_message IS NOT INITIAL.
            <lfs_upload_sb>-status = 'E'.
            <lfs_upload_sb>-message = lv_message.
          ELSE.
            " 単価差額
            ls_update_sb-net_price_diff = ls_update_sb-net_price_amount - ls_update_sb-old_material_price.
            " 差額合計
            ls_update_sb-recovery_necessary_amount = ls_update_sb-net_price_diff * ls_update_sb-order_quantity.
            ls_update_sb-job_run_by = 'UPLOAD'.
            ls_update_sb-job_run_date = cl_abap_context_info=>get_system_date( ).
            ls_update_sb-job_run_time = cl_abap_context_info=>get_system_time( ).

            INSERT INTO ztbi_bi003_j02 VALUES @ls_update_sb.
            IF sy-subrc = 0.
              <lfs_upload_sb>-status = 'S'.
              <lfs_upload_sb>-message = |データが保存されました。|.
            ELSE.
              <lfs_upload_sb>-status = 'E'.
              lv_msg = |データが既に存在しています。|.
              lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
              <lfs_upload_sb>-message = lv_message.
            ENDIF.
          ENDIF.
        ENDLOOP.

        cs_data = /ui2/cl_json=>serialize( data = ls_upload_sb ).

      WHEN 'IN'.
        /ui2/cl_json=>deserialize( EXPORTING json = cs_data
                                   CHANGING  data = ls_upload_in ).

        LOOP AT ls_upload_in-jsondata ASSIGNING FIELD-SYMBOL(<lfs_upload_in>).
          CLEAR: lv_message.
          CLEAR: ls_update_in.

          IF <lfs_upload_in>-yearmonth IS NOT INITIAL.
            ls_update_in-fiscal_year_period = |{ <lfs_upload_in>-yearmonth+0(4) }0{ <lfs_upload_in>-yearmonth+4(2) }|..
            ls_update_in-fiscal_year = <lfs_upload_in>-yearmonth+0(4).
            ls_update_in-fiscal_month = <lfs_upload_in>-yearmonth+4(2).
          ELSE.
            lv_msg = |必須項目「会計年月」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_in>-recoverymanagementnumber IS INITIAL.
            lv_msg = |必須項目「回収管理番号」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ELSE.
            READ TABLE it_check_table INTO ls_check_data WITH KEY recoverymanagementnumber = <lfs_upload_in>-recoverymanagementnumber
                                                                  BINARY SEARCH.
            IF sy-subrc = 0.
              ls_update_in-company_code = ls_check_data-companycode.
              ls_update_in-company_code_name = ls_check_data-companyname.
              ls_update_in-recovery_management_number = <lfs_upload_in>-recoverymanagementnumber.
              ls_update_in-customer = ls_check_data-customer.
              ls_update_in-customer_name = ls_check_data-customername.
            ELSE.
              lv_msg = |回収管理番号は登録されていません。|.
              lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
            ENDIF.
          ENDIF.

          IF <lfs_upload_in>-purchaseorder IS NOT INITIAL.
            ls_update_in-purchase_order = |{ <lfs_upload_in>-purchaseorder ALPHA = IN }|.
          ELSE.
            lv_msg = |必須項目「発注伝票」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_in>-purchaseorderitem IS NOT INITIAL.
            ls_update_in-purchase_order_item = <lfs_upload_in>-purchaseorderitem.
          ELSE.
            lv_msg = |必須項目「発注伝票明細」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_in>-initialmaterial IS NOT INITIAL.
            ls_update_in-material = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_upload_in>-initialmaterial ).
          ELSE.
            lv_msg = |必須項目「イニシャル品目」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_in>-initialmaterialtext IS NOT INITIAL.
            ls_update_in-material_text = <lfs_upload_in>-initialmaterialtext.
          ELSE.
            lv_msg = |必須項目「イニシャル品目テキスト」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_in>-recoverynecessaryamount IS NOT INITIAL.
            ls_update_in-recovery_necessary_amount = <lfs_upload_in>-recoverynecessaryamount.
          ELSE.
            lv_msg = |必須項目「回収必要金額」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF lv_message IS NOT INITIAL.
            <lfs_upload_in>-status = 'E'.
            <lfs_upload_in>-message = lv_message.
          ELSE.
            ls_update_in-product_group = <lfs_upload_in>-materiagroup.
            ls_update_in-accounting_document = |{ <lfs_upload_in>-accountingdocument ALPHA = IN }|.
            ls_update_in-ledger_gl_line_item = |{ <lfs_upload_in>-accountingdocumentitem ALPHA = IN }|.
            ls_update_in-gl_account = |{ <lfs_upload_in>-glaccount ALPHA = IN }|.
            ls_update_in-gl_account_name = <lfs_upload_in>-glaccounttext.
            ls_update_in-fixed_asset = |{ <lfs_upload_in>-fixedasset ALPHA = IN }|.
            ls_update_in-fixed_asset_description = <lfs_upload_in>-fixedassettext.
            ls_update_in-order_quantity = <lfs_upload_in>-poquantity.
            ls_update_in-net_price_amount = <lfs_upload_in>-netamount.
            ls_update_in-job_run_by = 'UPLOAD'.
            ls_update_in-job_run_date = cl_abap_context_info=>get_system_date( ).
            ls_update_in-job_run_time = cl_abap_context_info=>get_system_time( ).

            INSERT INTO ztbi_bi003_j03 VALUES @ls_update_in.
            IF sy-subrc = 0.
              <lfs_upload_in>-status = 'S'.
              <lfs_upload_in>-message = |データが保存されました。|.
            ELSE.
              <lfs_upload_in>-status = 'E'.
              lv_msg = |データが既に存在しています。|.
              lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
              <lfs_upload_in>-message = lv_message.
            ENDIF.
          ENDIF.
        ENDLOOP.

        cs_data = /ui2/cl_json=>serialize( data = ls_upload_in ).

      WHEN 'ST'.
        /ui2/cl_json=>deserialize( EXPORTING json = cs_data
                                   CHANGING  data = ls_upload_st ).

        LOOP AT ls_upload_st-jsondata ASSIGNING FIELD-SYMBOL(<lfs_upload_st>).
          CLEAR: lv_message.
          CLEAR: ls_update_st.

          IF <lfs_upload_st>-yearmonth IS NOT INITIAL.
            ls_update_st-fiscal_year_period = |{ <lfs_upload_st>-yearmonth+0(4) }0{ <lfs_upload_st>-yearmonth+4(2) }|..
            ls_update_st-fiscal_year = <lfs_upload_st>-yearmonth+0(4).
            ls_update_st-fiscal_month = <lfs_upload_st>-yearmonth+4(2).
          ELSE.
            lv_msg = |必須項目「会計年月」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_st>-recoverymanagementnumber IS INITIAL.
            lv_msg = |必須項目「回収管理番号」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ELSE.
            READ TABLE it_check_table INTO ls_check_data WITH KEY recoverymanagementnumber = <lfs_upload_st>-recoverymanagementnumber
                                                                  BINARY SEARCH.
            IF sy-subrc = 0.
              ls_update_st-company_code = ls_check_data-companycode.
              ls_update_st-company_code_name = ls_check_data-companyname.
              ls_update_st-recovery_management_number = <lfs_upload_st>-recoverymanagementnumber.
              ls_update_st-customer = ls_check_data-customer.
              ls_update_st-customer_name = ls_check_data-customername.
            ELSE.
              lv_msg = |回収管理番号は登録されていません。|.
              lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
            ENDIF.
          ENDIF.

          IF <lfs_upload_st>-purchaseorder IS NOT INITIAL.
            ls_update_st-purchase_order = |{ <lfs_upload_st>-purchaseorder ALPHA = IN }|.
          ELSE.
            lv_msg = |必須項目「発注伝票」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_st>-purchaseorderitem IS NOT INITIAL.
            ls_update_st-purchase_order_item = <lfs_upload_st>-purchaseorderitem.
          ELSE.
            lv_msg = |必須項目「発注伝票明細」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_st>-recoverynecessaryamount IS NOT INITIAL.
            ls_update_st-recovery_necessary_amount = <lfs_upload_st>-recoverynecessaryamount.
          ELSE.
            lv_msg = |必須項目「回収必要金額」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF lv_message IS NOT INITIAL.
            <lfs_upload_st>-status = 'E'.
            <lfs_upload_st>-message = lv_message.
          ELSE.
            ls_update_st-material = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_upload_st>-transportexpensematerial ).
            ls_update_st-material_text = <lfs_upload_st>-transportexpensematerialtext.
            ls_update_st-order_quantity = <lfs_upload_st>-poquantity.
            ls_update_st-net_price_amount = <lfs_upload_st>-netamount.
            ls_update_st-job_run_by = 'UPLOAD'.
            ls_update_st-job_run_date = cl_abap_context_info=>get_system_date( ).
            ls_update_st-job_run_time = cl_abap_context_info=>get_system_time( ).

            INSERT INTO ztbi_bi003_j04 VALUES @ls_update_st.
            IF sy-subrc = 0.
              <lfs_upload_st>-status = 'S'.
              <lfs_upload_st>-message = |データが保存されました。|.
            ELSE.
              <lfs_upload_st>-status = 'E'.
              lv_msg = |データが既に存在しています。|.
              lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
              <lfs_upload_st>-message = lv_message.
            ENDIF.
          ENDIF.
        ENDLOOP.

        cs_data = /ui2/cl_json=>serialize( data = ls_upload_st ).

      WHEN 'SS'.
        /ui2/cl_json=>deserialize( EXPORTING json = cs_data
                                   CHANGING  data = ls_upload_ss ).

        LOOP AT ls_upload_ss-jsondata ASSIGNING FIELD-SYMBOL(<lfs_upload_ss>).
          CLEAR: lv_message.
          CLEAR: ls_update_ss.

          IF <lfs_upload_ss>-yearmonth IS NOT INITIAL.
            ls_update_ss-fiscal_year_period = |{ <lfs_upload_ss>-yearmonth+0(4) }0{ <lfs_upload_ss>-yearmonth+4(2) }|.
            ls_update_ss-fiscal_year = <lfs_upload_ss>-yearmonth+0(4).
            ls_update_ss-fiscal_month = <lfs_upload_ss>-yearmonth+4(2).
          ELSE.
            lv_msg = |必須項目「会計年月」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_ss>-recoverymanagementnumber IS INITIAL.
            lv_msg = |必須項目「回収管理番号」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ELSE.
            READ TABLE it_check_table INTO ls_check_data WITH KEY recoverymanagementnumber = <lfs_upload_ss>-recoverymanagementnumber
                                                                  BINARY SEARCH.
            IF sy-subrc = 0.
              ls_update_ss-company_code = ls_check_data-companycode.
              ls_update_ss-company_code_name = ls_check_data-companyname.
              ls_update_ss-recovery_management_number = <lfs_upload_ss>-recoverymanagementnumber.
              ls_update_ss-customer = ls_check_data-customer.
              ls_update_ss-customer_name = ls_check_data-customername.
            ELSE.
              lv_msg = |回収管理番号は登録されていません。|.
              lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
            ENDIF.
          ENDIF.

          IF <lfs_upload_ss>-ssmaterial IS NOT INITIAL.
            ls_update_ss-material = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_upload_ss>-ssmaterial ).
          ELSE.
            lv_msg = |必須項目「在庫廃棄ロス品目」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_ss>-ssmaterialtext IS NOT INITIAL.
            ls_update_ss-product_name = <lfs_upload_ss>-ssmaterialtext.
          ELSE.
            lv_msg = |必須項目「在庫廃棄ロス品目テキスト」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF <lfs_upload_ss>-recoverynecessaryamount IS NOT INITIAL.
            ls_update_ss-recovery_necessary_amount = <lfs_upload_ss>-recoverynecessaryamount.
          ELSE.
            lv_msg = |必須項目「回収必要金額」は入力されていません。|.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ENDIF.

          IF lv_message IS NOT INITIAL.
            <lfs_upload_ss>-status = 'E'.
            <lfs_upload_ss>-message = lv_message.
          ELSE.
            ls_update_ss-material_document = |{ <lfs_upload_ss>-materialdocument ALPHA = IN }|.
            ls_update_ss-material_document_item = |{ <lfs_upload_ss>-materialdocumentitem ALPHA = IN }|.
            ls_update_ss-gl_account = |{ <lfs_upload_ss>-glaccount ALPHA = IN }|.
            ls_update_ss-gl_account_name = <lfs_upload_ss>-glaccounttext.
            ls_update_ss-quantity_in_entry_unit = <lfs_upload_ss>-quantity.
            ls_update_ss-job_run_by = 'UPLOAD'.
            ls_update_ss-job_run_date = cl_abap_context_info=>get_system_date( ).
            ls_update_ss-job_run_time = cl_abap_context_info=>get_system_time( ).

            INSERT INTO ztbi_bi003_j05 VALUES @ls_update_ss.
            IF sy-subrc = 0.
              <lfs_upload_ss>-status = 'S'.
              <lfs_upload_ss>-message = |データが保存されました。|.
            ELSE.
              <lfs_upload_ss>-status = 'E'.
              lv_msg = |データが既に存在しています。|.
              lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
              <lfs_upload_ss>-message = lv_message.
            ENDIF.
          ENDIF.
        ENDLOOP.

        cs_data = /ui2/cl_json=>serialize( data = ls_upload_ss ).

      WHEN OTHERS.
    ENDCASE.

    " set log
    CLEAR ls_upload_record.
    GET TIME STAMP FIELD lv_timestamp.
    TRY.
        ls_upload_record-uuid = cl_system_uuid=>create_uuid_x16_static( ).
        ##NO_HANDLER
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.
    ls_upload_record-upload_type = iv_upload_type.
    ls_upload_record-json_data   = cs_data.
    ls_upload_record-created_by  = sy-uname.
    ls_upload_record-created_at  = lv_timestamp.
    ls_upload_record-last_changed_by = sy-uname.
    ls_upload_record-last_changed_at = lv_timestamp.
    ls_upload_record-local_last_changed_at = lv_timestamp.
    MODIFY ztbi_bi003_up FROM @ls_upload_record.
  ENDMETHOD.

  METHOD delete.
    DATA: ls_upload_sb TYPE lty_upload_sb,
          ls_upload_in TYPE lty_upload_in,
          ls_upload_st TYPE lty_upload_st,
          ls_upload_ss TYPE lty_upload_ss.

    DATA: lv_purchaseorder          TYPE ebeln,
          lv_purchaseorderitem      TYPE ebelp,
          lv_accountingdocument     TYPE belnr_d,
          lv_accountingdocumentitem TYPE ztbi_bi003_j03-ledger_gl_line_item,
          lv_materialdocument       TYPE mblnr,
          lv_materialdocumentitem   TYPE mblpo.

    CASE iv_upload_type.
      WHEN 'SB'.
        /ui2/cl_json=>deserialize( EXPORTING json = cs_data
                                   CHANGING  data = ls_upload_sb ).

        LOOP AT ls_upload_sb-jsondata ASSIGNING FIELD-SYMBOL(<lfs_upload_sb>).
          CLEAR: lv_purchaseorder,lv_purchaseorderitem.
          lv_purchaseorder = |{ <lfs_upload_sb>-purchaseorder ALPHA = IN }|.
          lv_purchaseorderitem = |{ <lfs_upload_sb>-purchaseorderitem ALPHA = IN }|.
          DELETE FROM ztbi_bi003_j02 WHERE purchase_order = @lv_purchaseorder
                                       AND purchase_order_item = @lv_purchaseorderitem
                                       AND recovery_management_number = @<lfs_upload_sb>-recoverymanagementnumber
                                       AND job_run_by = 'UPLOAD'.
        ENDLOOP.

        cs_data = /ui2/cl_json=>serialize( data = ls_upload_sb ).

      WHEN 'IN'.
        /ui2/cl_json=>deserialize( EXPORTING json = cs_data
                                   CHANGING  data = ls_upload_in ).

        LOOP AT ls_upload_in-jsondata ASSIGNING FIELD-SYMBOL(<lfs_upload_in>).
          CLEAR: lv_purchaseorder,lv_purchaseorderitem,lv_accountingdocument,lv_accountingdocumentitem.
          lv_purchaseorder = |{ <lfs_upload_in>-purchaseorder ALPHA = IN }|.
          lv_purchaseorderitem = |{ <lfs_upload_in>-purchaseorderitem ALPHA = IN }|.
          lv_accountingdocument = |{ <lfs_upload_in>-accountingdocument ALPHA = IN }|.
          lv_accountingdocumentitem = |{ <lfs_upload_in>-accountingdocumentitem ALPHA = IN }|.
          DELETE FROM ztbi_bi003_j03 WHERE purchase_order = @lv_purchaseorder
                                       AND purchase_order_item = @lv_purchaseorderitem
                                       AND fiscal_year = @<lfs_upload_in>-yearmonth+0(4)
                                       AND accounting_document = @lv_accountingdocument
                                       AND ledger_gl_line_item = @lv_accountingdocumentitem
                                       AND recovery_management_number = @<lfs_upload_in>-recoverymanagementnumber
                                       AND job_run_by = 'UPLOAD'.
        ENDLOOP.

        cs_data = /ui2/cl_json=>serialize( data = ls_upload_in ).

      WHEN 'ST'.
        /ui2/cl_json=>deserialize( EXPORTING json = cs_data
                                   CHANGING  data = ls_upload_st ).

        LOOP AT ls_upload_st-jsondata ASSIGNING FIELD-SYMBOL(<lfs_upload_st>).
          CLEAR: lv_purchaseorder,lv_purchaseorderitem.
          lv_purchaseorder = |{ <lfs_upload_st>-purchaseorder ALPHA = IN }|.
          lv_purchaseorderitem = |{ <lfs_upload_st>-purchaseorderitem ALPHA = IN }|.
          DELETE FROM ztbi_bi003_j04 WHERE purchase_order = @lv_purchaseorder
                                       AND purchase_order_item = @lv_purchaseorderitem
                                       AND recovery_management_number = @<lfs_upload_st>-recoverymanagementnumber
                                       AND job_run_by = 'UPLOAD'.
        ENDLOOP.

        cs_data = /ui2/cl_json=>serialize( data = ls_upload_st ).

      WHEN 'SS'.
        /ui2/cl_json=>deserialize( EXPORTING json = cs_data
                                   CHANGING  data = ls_upload_ss ).

        LOOP AT ls_upload_ss-jsondata ASSIGNING FIELD-SYMBOL(<lfs_upload_ss>).
          CLEAR: lv_materialdocument,lv_materialdocumentitem.
          lv_materialdocument = |{ <lfs_upload_ss>-materialdocument ALPHA = IN }|.
          lv_materialdocumentitem = |{ <lfs_upload_ss>-materialdocumentitem ALPHA = IN }|.
          DELETE FROM ztbi_bi003_j05 WHERE material_document = @lv_materialdocument
                                       AND material_document_item = @lv_materialdocumentitem
                                       AND recovery_management_number = @<lfs_upload_ss>-recoverymanagementnumber
                                       AND job_run_by = 'UPLOAD'.
        ENDLOOP.

        cs_data = /ui2/cl_json=>serialize( data = ls_upload_ss ).

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

  METHOD export.
    DATA: ls_upload_sb TYPE lty_upload_sb,
          ls_upload_in TYPE lty_upload_in,
          ls_upload_st TYPE lty_upload_st,
          ls_upload_ss TYPE lty_upload_ss.

    DATA(lv_object) = |ZDOWNLOAD_RECOVERY_{ iv_upload_type }|.

    SELECT SINGLE *
      FROM zzc_dtimp_conf
     WHERE object = @lv_object
      INTO @DATA(ls_file_conf).               "#EC CI_ALL_FIELDS_NEEDED
    IF sy-subrc = 0.
      " FILE_CONTENT must be populated with the complete file content of the .XLSX file
      " whose content shall be processed programmatically.
      DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( ls_file_conf-templatecontent ).
      DATA(lo_write_access) = lo_document->write_access(  ).
      DATA(lo_worksheet) = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).

      DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
        )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( ls_file_conf-startcolumn )
        )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( ls_file_conf-startrow )
        )->get_pattern( ).

      CASE iv_upload_type.
        WHEN 'SB'.
          /ui2/cl_json=>deserialize( EXPORTING json = is_data
                                     CHANGING  data = ls_upload_sb ).

          lo_worksheet->select( lo_selection_pattern
            )->row_stream(
            )->operation->write_from( REF #( ls_upload_sb-jsondata )
            )->execute( ).
        WHEN 'IN'.
          /ui2/cl_json=>deserialize( EXPORTING json = is_data
                                     CHANGING  data = ls_upload_in ).

          lo_worksheet->select( lo_selection_pattern
            )->row_stream(
            )->operation->write_from( REF #( ls_upload_in-jsondata )
            )->execute( ).
        WHEN 'ST'.
          /ui2/cl_json=>deserialize( EXPORTING json = is_data
                                     CHANGING  data = ls_upload_st ).

          lo_worksheet->select( lo_selection_pattern
            )->row_stream(
            )->operation->write_from( REF #( ls_upload_st-jsondata )
            )->execute( ).
        WHEN 'SS'.
          /ui2/cl_json=>deserialize( EXPORTING json = is_data
                                     CHANGING  data = ls_upload_ss ).

          lo_worksheet->select( lo_selection_pattern
            )->row_stream(
            )->operation->write_from( REF #( ls_upload_ss-jsondata )
            )->execute( ).
        WHEN OTHERS.
      ENDCASE.

      DATA(lv_file) = lo_write_access->get_file_content( ).

      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
          ##NO_HANDLER
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

      GET TIME STAMP FIELD DATA(lv_timestamp).

      INSERT INTO zzt_prt_record VALUES @( VALUE #( record_uuid     = lv_uuid
                                                    provided_keys   = |回収既存データ_{ iv_upload_type }_エクセル出力|
                                                    pdf_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    pdf_file_name   = |回収既存データ_{ iv_upload_type }_{ lv_timestamp }.xlsx|
                                                    pdf_content     = lv_file
                                                    created_by      = sy-uname
                                                    created_at      = lv_timestamp
                                                    last_changed_by = sy-uname
                                                    last_changed_at = lv_timestamp
                                                    local_last_changed_at = lv_timestamp ) ).
      TRY.
          cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = lv_uuid
                                                   IMPORTING uuid_c36 = rv_recorduuid  ).
          ##NO_HANDLER
        CATCH cx_uuid_error.
          " handle exception
      ENDTRY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
