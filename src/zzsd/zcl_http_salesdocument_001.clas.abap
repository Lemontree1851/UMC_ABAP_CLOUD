CLASS zcl_http_salesdocument_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_SALESDOCUMENT_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    TYPES:
      BEGIN OF ty_req,
        sales_organization   TYPE string,
        distribution_channel TYPE string,
        sales_document       TYPE string,
        sales_document_item  TYPE string,
        sold_to_party        TYPE string,
        product              TYPE string,
        time_stamp           TYPE string,
      END OF ty_req,

      BEGIN OF ty_salesdocument,
        _sales_organization            TYPE i_salesdocumentitem-salesorganization,
        _distribution_channel          TYPE i_salesdocumentitem-distributionchannel,
        _sales_document                TYPE string,
        _sales_document_item           TYPE string,
        _product                       TYPE i_salesdocumentitem-product,
        _sold_to_party                 TYPE string,
        _sales_document_item_text      TYPE i_salesdocumentitem-salesdocumentitemtext,
        _purchase_order_by_customer    TYPE i_salesdocumentitem-purchaseorderbycustomer,
        _plant                         TYPE i_salesdocumentitem-plant,
        _order_quantity                TYPE i_salesdocumentitem-orderquantity,
        _order_quantity_unit           TYPE i_salesdocumentitem-orderquantityunit,
        _committed_delivery_date       TYPE string,
        _net_amount                    TYPE i_salesdocumentitem-netamount,
        _transaction_currency          TYPE i_salesdocumentitem-transactioncurrency,
        _last_change_date_time         TYPE timestampl,
        _material_by_customer          TYPE i_salesdocumentitem-materialbycustomer,
        _yy1_customerlotno_sdi         TYPE i_salesdocumentitem-yy1_customerlotno_sdi,
        _s_d_document_rejection_status TYPE i_salesdocumentitem-sddocumentrejectionstatus,
        _sales_document_rjcn_reason    TYPE i_salesdocumentitem-salesdocumentrjcnreason,
        _openconfddelivqtyinordqtyunit TYPE i_salesdocumentscheduleline-openconfddelivqtyinordqtyunit,
      END OF ty_salesdocument,
      tt_salesdocument TYPE STANDARD TABLE OF ty_salesdocument WITH DEFAULT KEY,

      BEGIN OF ty_data,
        _sales_document TYPE tt_salesdocument,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res.

    DATA:
      lo_root_exc            TYPE REF TO cx_root,
      lr_salesorganization   TYPE RANGE OF i_salesdocumentitem-salesorganization,
      lr_distributionchannel TYPE RANGE OF i_salesdocumentitem-distributionchannel,
      lr_salesdocument       TYPE RANGE OF i_salesdocumentitem-salesdocument,
      lr_salesdocumentitem   TYPE RANGE OF i_salesdocumentitem-salesdocumentitem,
      lr_soldtoparty         TYPE RANGE OF i_salesdocumentitem-soldtoparty,
      lr_product             TYPE RANGE OF i_salesdocumentitem-product,
      lr_salesdocumenttype   TYPE RANGE OF i_salesdocument-salesdocumenttype,
      ls_req                 TYPE ty_req,
      ls_res                 TYPE ty_res,
      ls_salesdocument       TYPE ty_salesdocument,
      lv_salesorganization   TYPE i_salesdocumentitem-salesorganization,
      lv_distributionchannel TYPE i_salesdocumentitem-distributionchannel,
      lv_salesdocument       TYPE i_salesdocumentitem-salesdocument,
      lv_salesdocumentitem   TYPE i_salesdocumentitem-salesdocumentitem,
      lv_soldtoparty         TYPE i_salesdocumentitem-soldtoparty,
      lv_product             TYPE i_salesdocumentitem-product,
      lv_timestamp           TYPE timestamp,
      lv_date                TYPE d,
      lv_time                TYPE t.

    CONSTANTS:
      lc_sign_i        TYPE c LENGTH 1 VALUE 'I',
      lc_option_eq     TYPE c LENGTH 2 VALUE 'EQ',
      lc_zid_zsd011    TYPE string VALUE 'ZSD011',
      lc_zid_zsd012    TYPE string VALUE 'ZSD012',
      lc_msgid_zsd_001 TYPE string VALUE 'ZSD_001',
      lc_alpha_in      TYPE string VALUE 'IN',
      lc_alpha_out     TYPE string VALUE 'OUT',
      lc_time_000000   TYPE t      VALUE '000000'.

    GET TIME STAMP FIELD DATA(lv_timestamp_start).

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    IF lv_req_body IS NOT INITIAL.
      xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).
    ENDIF.

    lv_salesorganization   = ls_req-sales_organization.
    lv_distributionchannel = ls_req-distribution_channel.
    lv_salesdocument       = |{ ls_req-sales_document ALPHA = IN }|.
    lv_salesdocumentitem   = |{ ls_req-sales_document_item ALPHA = IN }|.
    lv_soldtoparty         = |{ ls_req-sold_to_party ALPHA = IN }|.
    lv_timestamp           = ls_req-time_stamp.
    lv_product = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_req-product ).

    TRY.
        "Check sales organization of input parameter must be valuable
        IF lv_salesorganization IS INITIAL.
          "販売組織を送信していください！
          MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 007 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        IF lv_salesorganization IS NOT INITIAL.
          "Check sales organization of input parameter must be existent
          SELECT COUNT(*)
            FROM i_salesorganization WITH PRIVILEGED ACCESS
           WHERE salesorganization = @lv_salesorganization.
          IF sy-subrc <> 0.
            "販売組織&1存在しません！
            MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 008 WITH lv_salesorganization INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ELSE.
            lr_salesorganization = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lv_salesorganization ) ).
          ENDIF.
        ENDIF.

        IF lv_distributionchannel IS NOT INITIAL.
          "Check distribution channel of input parameter must be existent
          SELECT COUNT(*)
            FROM i_distributionchannel WITH PRIVILEGED ACCESS
           WHERE distributionchannel = @lv_distributionchannel.
          IF sy-subrc <> 0.
            "流通チャネル&1存在しません！
            MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 009 WITH lv_distributionchannel INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ELSE.
            lr_distributionchannel = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lv_distributionchannel ) ).
          ENDIF.
        ENDIF.

        IF lv_soldtoparty IS NOT INITIAL.
          "Check sold to party of input parameter must be existent
          SELECT COUNT(*)
            FROM i_businesspartner WITH PRIVILEGED ACCESS
           WHERE businesspartner = @lv_soldtoparty.
          IF sy-subrc <> 0.
            "得意先&1存在しません！
            MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 010 WITH lv_soldtoparty INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ELSE.
            lr_soldtoparty = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lv_soldtoparty ) ).
          ENDIF.
        ENDIF.

        IF lv_product IS NOT INITIAL.
          "Check product of input parameter must be existent
          SELECT COUNT(*)
            FROM i_product WITH PRIVILEGED ACCESS
           WHERE product = @lv_product.
          IF sy-subrc <> 0.
            "製品&1存在しません！
            MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 011 WITH lv_product INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ELSE.
            lr_product = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lv_product ) ).
          ENDIF.
        ENDIF.

        IF lv_salesdocument IS NOT INITIAL.
          "Check sales document of input parameter must be existent
          SELECT COUNT(*)
            FROM i_salesdocument WITH PRIVILEGED ACCESS
           WHERE salesdocument = @lv_salesdocument.
          IF sy-subrc <> 0.
            "販売伝票&1存在しません！
            MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 013 WITH lv_salesdocument INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ELSE.
            lr_salesdocument = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lv_salesdocument ) ).
          ENDIF.
        ENDIF.

        IF lv_salesdocumentitem IS NOT INITIAL.
          lr_salesdocumentitem = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lv_salesdocumentitem ) ).
        ENDIF.

        "Obtain time zone of sales organization
        SELECT SINGLE
               zvalue2 AS zonlo_in,
               zvalue3 AS zonlo_out
          FROM ztbc_1001
         WHERE zid = @lc_zid_zsd011
           AND zvalue1 = @lv_salesorganization
          INTO @DATA(ls_ztbc_1001).

        IF lv_timestamp IS NOT INITIAL.
          "Convert date and time from time zone of sales organization to zero zone
          CONVERT TIME STAMP lv_timestamp
                  TIME ZONE ls_ztbc_1001-zonlo_in
                  INTO DATE lv_date
                       TIME lv_time.

          lv_timestamp = lv_date && lv_time.
        ENDIF.

        "Obtain sales document type
        SELECT @lc_sign_i AS sign,
               @lc_option_eq AS option,
               zvalue1 AS low
          FROM ztbc_1001
         WHERE zid = @lc_zid_zsd012
          INTO TABLE @lr_salesdocumenttype.
        IF sy-subrc = 0.
          "Obtain data of customer product
          SELECT salesorganization,
                 distributionchannel,
                 salesdocument,
                 salesdocumentitem,
                 product,
                 soldtoparty,
                 salesdocumentitemtext,
                 purchaseorderbycustomer,
                 plant,
                 orderquantity,
                 orderquantityunit,
                 committeddeliverydate,
                 netamount,
                 transactioncurrency,
                 materialbycustomer,
                 yy1_customerlotno_sdi,
                 sddocumentrejectionstatus,
                 salesdocumentrjcnreason,
                 creationdate,
                 creationtime,
                 lastchangedate
            FROM i_salesdocumentitem WITH PRIVILEGED ACCESS
           WHERE salesorganization IN @lr_salesorganization
             AND distributionchannel IN @lr_distributionchannel
             AND salesdocument IN @lr_salesdocument
             AND salesdocumentitem IN @lr_salesdocumentitem
             AND soldtoparty IN @lr_soldtoparty
             AND product IN @lr_product
             AND salesdocumenttype IN @lr_salesdocumenttype
             AND ( ( concat( creationdate,creationtime ) >= @lv_timestamp )
                OR ( concat( lastchangedate,@lc_time_000000 ) >= @lv_timestamp ) )
            INTO TABLE @DATA(lt_salesdocumentitem).

          SORT lt_salesdocumentitem BY salesdocument salesdocumentitem.
          DELETE ADJACENT DUPLICATES FROM lt_salesdocumentitem COMPARING salesdocument salesdocumentitem.

          IF lt_salesdocumentitem IS NOT INITIAL.
            "Obtain data of sales document schedule line
            SELECT salesdocument,
                   salesdocumentitem,
                   scheduleline,
                   openconfddelivqtyinordqtyunit
              FROM i_salesdocumentscheduleline WITH PRIVILEGED ACCESS
               FOR ALL ENTRIES IN @lt_salesdocumentitem
             WHERE salesdocument = @lt_salesdocumentitem-salesdocument
               AND salesdocumentitem = @lt_salesdocumentitem-salesdocumentitem
               AND isconfirmeddelivschedline = @abap_true
              INTO TABLE @DATA(lt_salesdocumentscheduleline).
          ENDIF.
        ENDIF.

        DATA(lv_lines) = lines( lt_salesdocumentitem ).
        ls_res-_msgty = 'S'.

        "受注伝票連携成功 &1 件！
        MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 014 WITH lv_lines INTO ls_res-_msg.
      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    SORT lt_salesdocumentitem BY salesdocument salesdocumentitem.
    SORT lt_salesdocumentscheduleline BY salesdocument salesdocumentitem.

    LOOP AT lt_salesdocumentitem INTO DATA(ls_salesdocumentitem).
      ls_salesdocument-_sales_organization            = ls_salesdocumentitem-salesorganization.
      ls_salesdocument-_distribution_channel          = ls_salesdocumentitem-distributionchannel.
      ls_salesdocument-_sales_document                = |{ ls_salesdocumentitem-salesdocument ALPHA = OUT }|.
      ls_salesdocument-_sales_document_item           = |{ ls_salesdocumentitem-salesdocumentitem ALPHA = OUT }|.
      ls_salesdocument-_sold_to_party                 = |{ ls_salesdocumentitem-soldtoparty ALPHA = OUT }|.
      ls_salesdocument-_sales_document_item_text      = ls_salesdocumentitem-salesdocumentitemtext.
      ls_salesdocument-_purchase_order_by_customer    = ls_salesdocumentitem-purchaseorderbycustomer.
      ls_salesdocument-_plant                         = ls_salesdocumentitem-plant.
      ls_salesdocument-_order_quantity                = ls_salesdocumentitem-orderquantity.
      ls_salesdocument-_committed_delivery_date       = ls_salesdocumentitem-committeddeliverydate.
      ls_salesdocument-_net_amount                    = ls_salesdocumentitem-netamount.
      ls_salesdocument-_transaction_currency          = ls_salesdocumentitem-transactioncurrency.
      ls_salesdocument-_material_by_customer          = ls_salesdocumentitem-materialbycustomer.
      ls_salesdocument-_yy1_customerlotno_sdi         = ls_salesdocumentitem-yy1_customerlotno_sdi.
      ls_salesdocument-_s_d_document_rejection_status = ls_salesdocumentitem-sddocumentrejectionstatus.
      ls_salesdocument-_sales_document_rjcn_reason    = ls_salesdocumentitem-salesdocumentrjcnreason.
      CONDENSE ls_salesdocument-_sales_document.
      CONDENSE ls_salesdocument-_sales_document_item.
      CONDENSE ls_salesdocument-_sold_to_party.

      ls_salesdocument-_product = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_out iv_input = ls_salesdocumentitem-product ).

      TRY.
          ls_salesdocument-_order_quantity_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                                  iv_input = ls_salesdocumentitem-orderquantityunit ).
        CATCH zzcx_custom_exception INTO lo_root_exc.
          ls_salesdocument-_order_quantity_unit = ls_salesdocumentitem-orderquantityunit.
      ENDTRY.

      "Read data of sales document schedule line
      READ TABLE lt_salesdocumentscheduleline TRANSPORTING NO FIELDS WITH KEY salesdocument = ls_salesdocumentitem-salesdocument
                                                                              salesdocumentitem = ls_salesdocumentitem-salesdocumentitem
                                                                     BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_salesdocumentscheduleline INTO DATA(ls_salesdocumentscheduleline)  FROM sy-tabix.
          IF ls_salesdocumentscheduleline-salesdocument <> ls_salesdocumentitem-salesdocument
          OR ls_salesdocumentscheduleline-salesdocumentitem <> ls_salesdocumentitem-salesdocumentitem.
            EXIT.
          ENDIF.

          ls_salesdocument-_openconfddelivqtyinordqtyunit = ls_salesdocument-_openconfddelivqtyinordqtyunit + ls_salesdocumentscheduleline-openconfddelivqtyinordqtyunit.
        ENDLOOP.
      ENDIF.

      IF ls_salesdocumentitem-lastchangedate IS INITIAL.
        lv_timestamp = ls_salesdocumentitem-creationdate && ls_salesdocumentitem-creationtime.
      ELSE.
        lv_timestamp = ls_salesdocumentitem-lastchangedate && lc_time_000000.
      ENDIF.

      "Convert date and time from zero zone to time zone of sales organization
      CONVERT TIME STAMP lv_timestamp
              TIME ZONE ls_ztbc_1001-zonlo_out
              INTO DATE lv_date
                   TIME lv_time.

      ls_salesdocument-_last_change_date_time = lv_date && lv_time.
      APPEND ls_salesdocument TO ls_res-_data-_sales_document.
      CLEAR ls_salesdocument.
    ENDLOOP.

    "ABAP->JSON
*    DATA(lv_res_body) = xco_cp_json=>data->from_abap( ls_res )->apply( VALUE #(
*                          ( xco_cp_json=>transformation->underscore_to_pascal_case ) ) )->to_string( ).

    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF 'Yy1CustomerlotnoSdi' IN lv_res_body WITH 'YY1_CustomerLotNo_SDI'.
    REPLACE ALL OCCURRENCES OF 'Openconfddelivqtyinordqtyunit' IN lv_res_body WITH 'OpenConfdDelivQtyInOrdQtyUnit'.

    "Set request data
    response->set_text( lv_res_body ).

*&--ADD BEGIN BY XINLEI XU 2025/02/08
    GET TIME STAMP FIELD DATA(lv_timestamp_end).
    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        DATA(lv_request_url) = |https://{ lv_system_url }/sap/bc/http/sap/z_http_salesdocument_001|.
        ##NO_HANDLER
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    DATA(lv_request_body) = xco_cp_json=>data->from_abap( ls_req )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    DATA(lv_count) = lines( ls_res-_data-_sales_document ).

    zzcl_common_utils=>add_interface_log( EXPORTING iv_interface_id   = |IF061|
                                                    iv_interface_desc = |受注伝票連携|
                                                    iv_request_method = CONV #( if_web_http_client=>get )
                                                    iv_request_url    = lv_request_url
                                                    iv_request_body   = lv_request_body
                                                    iv_status_code    = CONV #( response->get_status( )-code )
                                                    iv_response       = response->get_text( )
                                                    iv_record_count   = lv_count
                                                    iv_run_start_time = CONV #( lv_timestamp_start )
                                                    iv_run_end_time   = CONV #( lv_timestamp_end )
                                          IMPORTING ev_log_uuid       = DATA(lv_log_uuid) ).
*&--ADD END BY XINLEI XU 2025/02/08
  ENDMETHOD.
ENDCLASS.
