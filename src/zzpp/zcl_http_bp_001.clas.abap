CLASS zcl_http_bp_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_http_bp_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        company_code     TYPE string,
        business_partner TYPE string,
        time_stamp       TYPE string,
      END OF ty_req,

      BEGIN OF ty_partner,
        _business_partner      TYPE i_businesspartner-businesspartner,
        _business_partner_name TYPE i_businesspartner-organizationbpname1,
        _search_term1          TYPE i_businesspartner-searchterm1,
        _company_code          TYPE i_customercompany-companycode,
        _partner_type          TYPE i,
      END OF ty_partner,
      tt_partner TYPE STANDARD TABLE OF ty_partner WITH DEFAULT KEY,

      BEGIN OF ty_data,
        _partner TYPE tt_partner,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res.

    DATA:
      lo_root_exc  TYPE REF TO cx_root,
      ls_req       TYPE ty_req,
      ls_res       TYPE ty_res,
      ls_partner   TYPE ty_partner,
      lv_company   TYPE i_customercompany-companycode,
      lv_partner   TYPE i_businesspartner-businesspartner,
      lv_timestamp TYPE timestamp,
      lv_date      TYPE d,
      lv_time      TYPE t.

    CONSTANTS:
      lc_zid_zms001    TYPE string VALUE 'ZMS001',
      lc_msgid         TYPE string VALUE 'ZPP_001',
      lc_msgty         TYPE string VALUE 'E',
      lc_alpha_out     TYPE string VALUE 'OUT',
      lc_partnertype_1 TYPE i      VALUE '1',
      lc_partnertype_2 TYPE i      VALUE '2',
      lc_partnertype_3 TYPE i      VALUE '3'.

    GET TIME STAMP FIELD DATA(lv_timestamp_start).

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).

    lv_company = ls_req-company_code.
    lv_partner = |{ ls_req-business_partner ALPHA = IN }|.
    lv_timestamp = ls_req-time_stamp.

    TRY.
        "Check company code of input parameter must be valuable
        IF lv_company IS INITIAL.
          "会社コードを送信してください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 053 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check business partner or time stamp of input parameter must be valuable
        IF lv_partner IS INITIAL AND lv_timestamp IS INITIAL.
          "BP或いは前回送信時間を送信してください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 054 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check business partner and time stamp of input parameter must be not valuable at the same time
        IF lv_partner IS NOT INITIAL AND lv_timestamp IS NOT INITIAL.
          "BPと前回送信時間を一つしか送信できません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 055 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check company code of input parameter must be existent
        SELECT COUNT(*)
          FROM i_companycode
         WHERE companycode = @lv_company.
        IF sy-subrc <> 0.
          "会社コード&1は存在しません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 056 WITH lv_company INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        IF lv_partner IS NOT INITIAL.
          "Check business partner of company code of input parameter must be existent
          SELECT COUNT(*)
            FROM i_customercompany WITH PRIVILEGED ACCESS
           WHERE customer = @lv_partner
             AND companycode = @lv_company.
          IF sy-subrc <> 0.
            SELECT COUNT(*)
               FROM i_suppliercompany WITH PRIVILEGED ACCESS
              WHERE supplier = @lv_partner
                AND companycode = @lv_company.
            IF sy-subrc <> 0.
              "会社コード&1に対し、BP &2は存在しません！
              MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 108 WITH lv_company lv_partner INTO ls_res-_msg.
              RAISE EXCEPTION TYPE cx_abap_invalid_value.
            ENDIF.
          ENDIF.
        ENDIF.

        "Obtain language and time zone of plant
        SELECT SINGLE
               zvalue3 AS zonlo_in,
               zvalue4 AS zonlo_out
          FROM ztbc_1001
         WHERE zid = @lc_zid_zms001
           AND zvalue1 = @lv_company
          INTO @DATA(ls_ztbc_1001).

        "Convert date and time from time zone of plant to zero zone
        CONVERT TIME STAMP lv_timestamp
                TIME ZONE ls_ztbc_1001-zonlo_in
                INTO DATE lv_date
                     TIME lv_time.

        lv_timestamp = lv_date && lv_time.

        IF lv_partner IS NOT INITIAL.
          "Obtain data of business partner
          SELECT a~businesspartner,
                 a~organizationbpname1,
                 a~searchterm1,
                 b~customer,
                 c~supplier,
                 CASE WHEN b~customer IS NOT NULL AND c~supplier IS NULL THEN @lc_partnertype_1
                      WHEN b~customer IS NULL AND c~supplier IS NOT NULL THEN @lc_partnertype_2
                      WHEN b~customer IS NOT NULL AND c~supplier IS NOT NULL THEN @lc_partnertype_3
                      END AS partnertype,
                 CASE WHEN d~companycode IS NOT NULL THEN d~companycode
                      WHEN e~companycode IS NOT NULL THEN e~companycode
                      END AS companycode
            FROM i_businesspartner WITH PRIVILEGED ACCESS AS a
            LEFT OUTER JOIN i_businesspartnercustomer WITH PRIVILEGED ACCESS AS b
              ON b~businesspartner = a~businesspartner
            LEFT OUTER JOIN i_businesspartnersupplier WITH PRIVILEGED ACCESS AS c
              ON c~businesspartner = a~businesspartner
            LEFT OUTER JOIN i_customercompany WITH PRIVILEGED ACCESS AS d
              ON d~customer = b~customer
             AND d~companycode = @lv_company
            LEFT OUTER JOIN i_suppliercompany WITH PRIVILEGED ACCESS AS e
              ON e~supplier = c~supplier
             AND e~companycode = @lv_company
           WHERE a~businesspartner = @lv_partner
            INTO TABLE @DATA(lt_businesspartner).
        ELSE.
          "Obtain data of business partner
          SELECT a~businesspartner,
                 a~organizationbpname1,
                 a~searchterm1,
                 b~customer,
                 c~supplier,
                 CASE WHEN b~customer IS NOT NULL AND c~supplier IS NULL THEN @lc_partnertype_1
                      WHEN b~customer IS NULL AND c~supplier IS NOT NULL THEN @lc_partnertype_2
                      WHEN b~customer IS NOT NULL AND c~supplier IS NOT NULL THEN @lc_partnertype_3
                      END AS partnertype,
                 CASE WHEN d~companycode IS NOT NULL THEN d~companycode
                      WHEN e~companycode IS NOT NULL THEN e~companycode
                      END AS companycode
            FROM i_businesspartner WITH PRIVILEGED ACCESS AS a
            LEFT OUTER JOIN i_businesspartnercustomer WITH PRIVILEGED ACCESS AS b
              ON b~businesspartner = a~businesspartner
            LEFT OUTER JOIN i_businesspartnersupplier WITH PRIVILEGED ACCESS AS c
              ON c~businesspartner = a~businesspartner
            LEFT OUTER JOIN i_customercompany WITH PRIVILEGED ACCESS AS d
              ON d~customer = b~customer
             AND d~companycode = @lv_company
            LEFT OUTER JOIN i_suppliercompany WITH PRIVILEGED ACCESS AS e
              ON e~supplier = c~supplier
             AND e~companycode = @lv_company
           WHERE ( concat( a~creationdate,a~creationtime ) >= @lv_timestamp
                OR concat( a~lastchangedate,a~lastchangetime ) >= @lv_timestamp )
            INTO TABLE @lt_businesspartner.

          DELETE lt_businesspartner WHERE companycode <> lv_company.

          "Delete duplicates data
          SORT lt_businesspartner BY businesspartner.
          DELETE ADJACENT DUPLICATES FROM lt_businesspartner
                                COMPARING businesspartner.
        ENDIF.

        DATA(lv_lines) = lines( lt_businesspartner ).
        ls_res-_msgty = 'S'.

        "会社コード&1 BPマスタ連携成功 &2 件！
        MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 057 WITH lv_company lv_lines INTO ls_res-_msg.

      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    LOOP AT lt_businesspartner INTO DATA(ls_businesspartner).
      ls_partner-_business_partner      = |{ ls_businesspartner-businesspartner ALPHA = OUT }|.
      ls_partner-_business_partner_name = ls_businesspartner-organizationbpname1.
      ls_partner-_search_term1          = ls_businesspartner-searchterm1.
      ls_partner-_company_code          = ls_businesspartner-companycode.
      ls_partner-_partner_type          = ls_businesspartner-partnertype.
      APPEND ls_partner TO ls_res-_data-_partner.
      CLEAR ls_partner.
    ENDLOOP.

    "ABAP->JSON
    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    "Set request data
    response->set_text( lv_res_body ).

*&--ADD BEGIN BY XINLEI XU 2025/02/08
    GET TIME STAMP FIELD DATA(lv_timestamp_end).
    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        DATA(lv_request_url) = |https://{ lv_system_url }/sap/bc/http/sap/z_http_bp_001|.
        ##NO_HANDLER
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    DATA(lv_request_body) = xco_cp_json=>data->from_abap( ls_req )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    DATA(lv_count) = lines( ls_res-_data-_partner ).

    zzcl_common_utils=>add_interface_log( EXPORTING iv_interface_id   = |IF062|
                                                    iv_interface_desc = |BPマスタ連携|
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
