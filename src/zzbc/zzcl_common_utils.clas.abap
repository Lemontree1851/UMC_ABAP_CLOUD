CLASS zzcl_common_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    CONSTANTS: lc_range_option_eq(2) TYPE c VALUE `EQ`,
               lc_range_option_ge(2) TYPE c VALUE `GE`,
               lc_range_option_le(2) TYPE c VALUE `LE`.

    CONSTANTS: lc_alpha_in  TYPE string VALUE `IN`,
               lc_alpha_out TYPE string VALUE `OUT`.

    TYPES: BEGIN OF ty_attachment,
             content      TYPE xstring,
             content_type TYPE cl_bcs_mail_bodypart=>ty_content_type,
             filename     TYPE string,
           END OF ty_attachment,
           tt_attachment TYPE STANDARD TABLE OF ty_attachment.

    TYPES: BEGIN OF ty_token_response,
             access_token TYPE string,
             token_type   TYPE string,
           END OF ty_token_response.

    TYPES:BEGIN OF ts_add_column,
            name  TYPE string,
            types TYPE string,
          END OF ts_add_column,
          tt_add_coll TYPE STANDARD TABLE OF ts_add_column WITH EMPTY KEY,
          BEGIN OF ts_dyn_name,
            name TYPE string,
          END OF ts_dyn_name,
          tt_dyn_name TYPE STANDARD TABLE OF ts_dyn_name WITH EMPTY KEY.

    TYPES: BEGIN OF ty_etag,
             etag TYPE string,
           END OF   ty_etag,
           BEGIN OF ty_metadata,
             metadata TYPE ty_etag,
           END OF   ty_metadata,
           BEGIN OF ty_odata_res,
             results  TYPE TABLE OF ty_metadata WITH DEFAULT KEY,
             metadata TYPE ty_etag,
           END OF   ty_odata_res,
           BEGIN OF ty_odata_res_d,
             d TYPE ty_odata_res,
           END OF   ty_odata_res_d.

    TYPES:
      "odata v2 api message structure
      BEGIN OF ty_message,
        lang  TYPE string,
        value TYPE string,
      END OF ty_message,
      BEGIN OF ty_odata_error,
        code    TYPE string,
        message TYPE ty_message,
      END OF ty_odata_error,
      BEGIN OF ty_errordetails,
        code    TYPE string,
        message TYPE string,
      END OF ty_errordetails,
      BEGIN OF ty_innererror,
        errordetails TYPE TABLE OF ty_errordetails WITH DEFAULT KEY,
      END OF ty_innererror,
      BEGIN OF ty_message_v2,
        code       TYPE string,
        message    TYPE ty_message,
        innererror TYPE ty_innererror,
      END OF ty_message_v2,
      BEGIN OF ty_error_v2,
        error TYPE ty_message_v2,
      END OF ty_error_v2,
      "odata v4 api message structure
      BEGIN OF ty_message_v4,
        code    TYPE string,
        message TYPE string,
        details TYPE TABLE OF ty_errordetails WITH DEFAULT KEY,
      END OF ty_message_v4,
      BEGIN OF ty_error_v4,
        error TYPE ty_message_v4,
      END OF ty_error_v4.

    CLASS-DATA: BEGIN OF date,
                  j(4),
                  m(2),
                  t(2),
                END OF date,
                januar(2)   VALUE '01',
                december(2) VALUE '12',
                lowdate(4)  VALUE '1800',
                frist(2)    VALUE '01',
                BEGIN OF highdate,
                  j(4) VALUE '9999',
                  m(2) VALUE '12',
                  t(2) VALUE '31',
                END OF highdate.

    CLASS-METHODS:
      "! Merge Messages
      merge_message IMPORTING iv_message1      TYPE string
                              iv_message2      TYPE string
                              iv_symbol        TYPE string OPTIONAL
                    RETURNING VALUE(rv_result) TYPE string,

      "! Request API for OData V2
      request_api_v2 IMPORTING iv_path               TYPE string
                               iv_method             TYPE if_web_http_client=>method
                               iv_body               TYPE string OPTIONAL
                               iv_format             TYPE string OPTIONAL
                               iv_select             TYPE string OPTIONAL
                               iv_filter             TYPE string OPTIONAL
                               iv_etag               TYPE string OPTIONAL
                               iv_contenttype_value  TYPE string OPTIONAL
                     EXPORTING VALUE(ev_status_code) TYPE if_web_http_response=>http_status-code
                               VALUE(ev_response)    TYPE string
                               VALUE(ev_etag)        TYPE string,

      "! Request API for OData V4
      request_api_v4 IMPORTING iv_path               TYPE string
                               iv_method             TYPE if_web_http_client=>method
                               iv_body               TYPE string OPTIONAL
                               iv_format             TYPE string OPTIONAL
                               iv_select             TYPE string OPTIONAL
                               iv_filter             TYPE string OPTIONAL
                               iv_etag               TYPE string OPTIONAL
                               iv_contenttype_value  TYPE string OPTIONAL
                     EXPORTING VALUE(ev_status_code) TYPE if_web_http_response=>http_status-code
                               VALUE(ev_response)    TYPE string
                               VALUE(ev_etag)        TYPE string,

      "! Conversion exit for Material INPUT/OUTPUT
      "! @parameter iv_alpha | (IN or OUT)
      conversion_matn1 IMPORTING iv_alpha         TYPE string
                                 iv_input         TYPE any
                       RETURNING VALUE(rv_output) TYPE i_product-product,

      "! Conversion exit for commercial (3-char) measurement unit INPUT/OUTPUT
      "! @parameter iv_alpha | (IN or OUT)
      conversion_cunit IMPORTING iv_alpha         TYPE string
                                 iv_input         TYPE any
                       RETURNING VALUE(rv_output) TYPE i_unitofmeasure-unitofmeasure
                       RAISING   zzcx_custom_exception,

      "! Conversion exit for Amount INPUT/OUTPUT
      "! @parameter iv_alpha | (IN or OUT)
      conversion_amount IMPORTING iv_alpha         TYPE string
                                  iv_currency      TYPE i_currency-currency
                                  iv_input         TYPE any
                        RETURNING VALUE(rv_output) TYPE bapicurr-bapicurr,

      "! Method get number next
      "! @parameter iv_object | number range object
      "! @parameter iv_datum  | datum
      "! @parameter iv_nrlen  | number range length
      "! @parameter rv_nrnum  | return number
      get_number_next IMPORTING iv_object       TYPE ztbc_1002-object
                                iv_datum        TYPE datum OPTIONAL
                                iv_nrlen        TYPE i OPTIONAL
                      RETURNING VALUE(rv_nrnum) TYPE string
                      RAISING   zzcx_custom_exception,

      "! Method generate attachment
      "! @parameter iv_templateid   | Template ID
      "! @parameter iv_providedkeys | Provided keys
      "! @parameter ev_has_error    | Error flag
      "! @parameter ev_message      | Error message
      "! @parameter ev_content      | File content
      generate_attachment IMPORTING iv_templateid   TYPE zzr_prt_template-templateid
                                    iv_providedkeys TYPE zzt_prt_record-provided_keys
                          EXPORTING ev_has_error    TYPE abap_boolean
                                    ev_message      TYPE string
                                    ev_content      TYPE xstring,

      "! Method send email
      "! @parameter iv_subject      | Subject
      "! @parameter iv_main_content | Content string containing the text body part
      "! @parameter it_recipient    | Recipients addresses
      "! @parameter it_attachment   | Attachments
      "! @parameter et_status       | Status table with send status for each recipient
      "! @raising   cx_bcs_mail     | Mail exception
      send_email IMPORTING iv_subject      TYPE cl_bcs_mail_message=>ty_subject OPTIONAL
                           iv_main_content TYPE string OPTIONAL
                           it_recipient    TYPE cl_bcs_mail_message=>tyt_recipient
                           it_attachment   TYPE tt_attachment OPTIONAL
                 EXPORTING et_status       TYPE cl_bcs_mail_message=>tyt_status
                 RAISING   cx_bcs_mail,

      "! Method get current language
      "! @parameter rv_language | language(EN/JA..)
      get_current_language RETURNING VALUE(rv_language) TYPE laiso,

      "! Method get working day
      "! @parameter iv_date       | Date
      "! @parameter iv_next       | Next/Current working day
      "! @parameter iv_plant      | Plant
      "! @parameter rv_workingday | Working day
      get_workingday IMPORTING iv_date              TYPE datum
                               iv_next              TYPE abap_boolean DEFAULT abap_false
                               iv_plant             TYPE werks_d
                     RETURNING VALUE(rv_workingday) TYPE datum,

      "! Method Check if the date is valid
      "! @parameter iv_date  | Date
      "! @parameter rv_valid | Date is valid
      is_valid_date IMPORTING iv_date         TYPE datum
                    RETURNING VALUE(rv_valid) TYPE abap_boolean,

      "! Method get month begin date
      "! @parameter iv_date             | Date
      "! @parameter rv_month_begin_date | Month begin date
      get_begindate_of_month IMPORTING iv_date                    TYPE datum
                             RETURNING VALUE(rv_month_begin_date) TYPE datum,

      "! Method get month end date
      "! @parameter iv_date             | Date
      "! @parameter rv_month_end_date   | Month end date
      get_enddate_of_month IMPORTING iv_date                  TYPE datum
                           RETURNING VALUE(rv_month_end_date) TYPE datum,

      calc_date_add IMPORTING date             TYPE datum
                              year             TYPE i DEFAULT 0
                              month            TYPE i DEFAULT 0
                              day              TYPE i DEFAULT 0
                    RETURNING VALUE(calc_date) TYPE datum,

      calc_date_subtract IMPORTING date             TYPE datum
                                   year             TYPE i DEFAULT 0
                                   month            TYPE i DEFAULT 0
                                   day              TYPE i DEFAULT 0
                         RETURNING VALUE(calc_date) TYPE datum,

      get_access_token IMPORTING iv_token_url          TYPE string
                                 iv_client_id          TYPE string
                                 iv_client_secret      TYPE string
                       EXPORTING VALUE(ev_status_code) TYPE if_web_http_response=>http_status-code
                                 VALUE(ev_response)    TYPE string
                                 VALUE(es_response)    TYPE ty_token_response,

      get_externalsystems_cdata IMPORTING iv_odata_url          TYPE string
                                          iv_odata_filter       TYPE string OPTIONAL
                                          iv_token_url          TYPE string OPTIONAL
                                          iv_client_id          TYPE string OPTIONAL
                                          iv_client_secret      TYPE string OPTIONAL
                                          iv_authtype           TYPE string
                                EXPORTING VALUE(ev_status_code) TYPE if_web_http_response=>http_status-code
                                          VALUE(ev_response)    TYPE string,

      get_api_etag IMPORTING iv_odata_version      TYPE string
                             iv_path               TYPE string
                   EXPORTING VALUE(ev_status_code) TYPE if_web_http_response=>http_status-code
                             VALUE(ev_response)    TYPE string
                             VALUE(ev_etag)        TYPE string,

      get_fiscal_year_period IMPORTING iv_date          TYPE datum
                             EXPORTING VALUE(ev_year)   TYPE gjahr
                                       VALUE(ev_period) TYPE poper,

      unit_conversion_simple IMPORTING !input               TYPE any
                                       VALUE(no_type_check) TYPE any DEFAULT 'X'
                                       VALUE(round_sign)    TYPE any OPTIONAL
                                       VALUE(unit_in)       TYPE msehi OPTIONAL
                                       VALUE(unit_out)      TYPE msehi OPTIONAL
                             EXPORTING VALUE(add_const)     TYPE any
                                       VALUE(decimals)      TYPE any
                                       VALUE(denominator)   TYPE any
                                       VALUE(numerator)     TYPE any
                                       VALUE(output)        TYPE any,

*&--Begin use for create dynamic table
      get_all_fields     IMPORTING VALUE(is_table) TYPE any
                                   VALUE(it_type)  TYPE tt_add_coll
                         RETURNING VALUE(rv_value) TYPE REF TO data,

      set_datadescr      IMPORTING VALUE(iv_types) TYPE string
                         RETURNING VALUE(rv_descr) TYPE REF TO cl_abap_datadescr,
*&--End use for create dynamic table

      is_workingday IMPORTING iv_plant             TYPE werks_d
                              iv_date              TYPE datum
                    RETURNING VALUE(rv_workingday) TYPE abap_bool,

      parse_error_v4 IMPORTING iv_response       TYPE string
                     RETURNING VALUE(rv_message) TYPE string,

      parse_error_v2 IMPORTING iv_response       TYPE string
                     RETURNING VALUE(rv_message) TYPE string,

      get_email_by_uname IMPORTING iv_user         TYPE sy-uname OPTIONAL
                         RETURNING VALUE(rv_email) TYPE i_workplaceaddress-defaultemailaddress,

      get_access_by_user IMPORTING iv_email         TYPE i_workplaceaddress-defaultemailaddress
                         RETURNING VALUE(rv_access) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zzcl_common_utils IMPLEMENTATION.


  METHOD calc_date_add.
    DATA(lv_date_xco) = xco_cp_time=>date(
                          iv_year   = date(4)
                          iv_month  = date+4(2)
                          iv_day    = date+6(2) ).
    calc_date = lv_date_xco->add( iv_year   = year
                                  iv_month  = month
                                  iv_day    = day
                                  io_calculation = xco_cp_time=>date_calculation->ultimo )->as( xco_cp_time=>format->abap )->value.
  ENDMETHOD.


  METHOD calc_date_subtract.
    DATA(lv_date_xco) = xco_cp_time=>date(
                          iv_year   = date(4)
                          iv_month  = date+4(2)
                          iv_day    = date+6(2) ).
    calc_date = lv_date_xco->subtract(  iv_year   = year
                                        iv_month  = month
                                        iv_day    = day
                                        io_calculation = xco_cp_time=>date_calculation->ultimo )->as( xco_cp_time=>format->abap )->value.
  ENDMETHOD.


  METHOD conversion_amount.
    DATA: int_shift      TYPE i,
          dec_amount_int TYPE bapicurr-bapicurr,
          struct_tcurx   TYPE i_currency.

    SELECT SINGLE * FROM i_currency WHERE currency = @iv_currency INTO @struct_tcurx. "#EC CI_ALL_FIELDS_NEEDED

    IF sy-subrc = 0. "Currency has a number of decimals not equal two
      int_shift = 2 - struct_tcurx-decimals.
    ELSE. "Currency is no exceptional currency. It has two decimals
      int_shift = 0.
    ENDIF.

    " Fill AMOUNT_EXTERNAL and shift decimal point depending on CURRENCY
    dec_amount_int = iv_input.
    CASE iv_alpha.
      WHEN 'IN'.
        DO int_shift TIMES.
          dec_amount_int = dec_amount_int / 10.
        ENDDO.
        rv_output = dec_amount_int.
      WHEN 'OUT'.
        rv_output = 10 ** int_shift.
        rv_output = rv_output * dec_amount_int.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD conversion_cunit.
    DATA lv_input TYPE i_unitofmeasure-unitofmeasure.

    IF iv_input EQ space.
      rv_output = iv_input.
      EXIT.
    ENDIF.

    lv_input = iv_input.

    CASE iv_alpha.
      WHEN 'IN'.
        SELECT SINGLE unitofmeasure FROM i_unitofmeasure WHERE unitofmeasure_e = @lv_input INTO @rv_output.
      WHEN 'OUT'.
        SELECT SINGLE unitofmeasure_e FROM i_unitofmeasure WHERE unitofmeasure = @lv_input INTO @rv_output.
      WHEN OTHERS.
        EXIT.
    ENDCASE.
    IF sy-subrc <> 0.
      TRANSLATE lv_input TO UPPER CASE.
      IF iv_alpha = 'IN'.
        SELECT SINGLE unitofmeasure FROM i_unitofmeasure WHERE unitofmeasure_e = @lv_input INTO @rv_output.
      ELSE.
        SELECT SINGLE unitofmeasure_e FROM i_unitofmeasure WHERE unitofmeasure = @lv_input INTO @rv_output.
      ENDIF.
      IF sy-subrc <> 0.
        TRY.
            DATA(lv_language) = cl_abap_context_info=>get_user_language_abap_format(  ).
            ##NO_HANDLER
          CATCH cx_abap_context_info_error.
            " handle exception
        ENDTRY.
        RAISE EXCEPTION NEW zzcx_custom_exception( textid = VALUE #( msgid = 'ZBC_001'
                                                                     msgno = '001'
                                                                     attr1 = iv_input
                                                                     attr2 = lv_language ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD conversion_matn1.
    CLEAR rv_output.

    IF strlen( iv_input ) EQ 0.
      EXIT.
    ENDIF.

    CASE iv_alpha.
      WHEN 'IN'.
        SELECT SINGLE product FROM i_product WITH PRIVILEGED ACCESS WHERE productexternalid = @iv_input INTO @rv_output.
      WHEN 'OUT'.
        SELECT SINGLE productexternalid FROM i_product WITH PRIVILEGED ACCESS WHERE product = @iv_input INTO @rv_output.
      WHEN OTHERS.
        EXIT.
    ENDCASE.
    IF sy-subrc <> 0.
      rv_output = iv_input.
    ENDIF.
  ENDMETHOD.


  METHOD generate_attachment.
    DATA: lo_data               TYPE REF TO data,
          lv_service_definition TYPE if_fp_fdp_api=>ty_service_definition,
          lv_xml                TYPE xstring.
    FIELD-SYMBOLS: <lfo_data> TYPE any.

    ##SELECT_FAE_WITH_LOB[XDPCONTENT]
    SELECT SINGLE
           templateuuid,
           servicedefinitionname,
           xdpcontent
      FROM zzr_prt_template
     WHERE templateid = @iv_templateid
      INTO @DATA(ls_template).
    IF sy-subrc = 0.
      TRY.
          lv_service_definition = ls_template-servicedefinitionname.
          DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( lv_service_definition ).
          DATA(lt_keys) = lo_fdp_util->get_keys( ).
          " get key values
          /ui2/cl_json=>deserialize( EXPORTING json = iv_providedkeys
                                     CHANGING  data = lo_data ).
          ASSIGN lo_data->* TO <lfo_data>.
          IF sy-subrc = 0.
            DATA(lt_key_l) = lt_keys.
            lt_keys = VALUE #( FOR key IN lt_key_l ( name      = key-name
                                                     value     = <lfo_data>-(key-name)->*
                                                     data_type = key-data_type ) ).
          ENDIF.
          lv_xml = lo_fdp_util->read_to_xml( lt_keys ).
          UNASSIGN <lfo_data>.
          FREE lo_data.
        CATCH cx_fp_fdp_error INTO DATA(lo_fdp_error).
          ev_has_error = abap_true.
          ev_message = lo_fdp_error->get_longtext(  ).
        CATCH cx_fp_ads_util INTO DATA(lo_ads_error).
          ev_has_error = abap_true.
          ev_message = lo_ads_error->get_longtext(  ).
      ENDTRY.

      TRY.
          cl_fp_ads_util=>render_pdf(
            EXPORTING
              iv_locale       = 'en_us'
              iv_xdp_layout   = ls_template-xdpcontent
              iv_xml_data     = lv_xml
            IMPORTING
              ev_pdf          = ev_content ).
        CATCH cx_fp_ads_util INTO lo_ads_error.
          ev_has_error = abap_true.
          ev_message = lo_ads_error->get_longtext(  ).
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD get_access_token.
    TRY.
        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( iv_token_url ).
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
        DATA(lo_request) = lo_http_client->get_http_request( ).

        DATA(lv_post_data) = |grant_type=client_credentials&client_id={ iv_client_id }&client_secret={ iv_client_secret }|.

        lo_request->set_header_field( i_name = 'Content-type' i_value = 'application/x-www-form-urlencoded' ).

        lo_request->set_text( lv_post_data ).

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).

        ev_status_code = lo_response->get_status( )-code.
        ev_response = lo_response->get_text(  ).

        /ui2/cl_json=>deserialize( EXPORTING json = ev_response
                                             pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                   CHANGING  data = es_response ).

      CATCH cx_web_http_client_error cx_http_dest_provider_error INTO DATA(lx_http_exception).
        ev_status_code = 500.
        ev_response = lx_http_exception->get_text( ).
    ENDTRY.
  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD get_all_fields.
    DATA: ref_table_des TYPE REF TO cl_abap_structdescr,
          lt_comp       TYPE cl_abap_structdescr=>component_table.

    ref_table_des ?= cl_abap_typedescr=>describe_by_name( is_table ).
    lt_comp  = ref_table_des->get_components( ).

    APPEND LINES OF VALUE cl_abap_structdescr=>component_table(
           FOR is_type IN it_type ( name = is_type-name
                                    type = set_datadescr( is_type-types ) ) ) TO lt_comp.

    DATA(lo_new_type) = cl_abap_structdescr=>create( lt_comp ).
    DATA(lo_new_tab) = cl_abap_tabledescr=>create(
                        p_line_type  = lo_new_type
                        p_table_kind = cl_abap_tabledescr=>tablekind_std
                        p_unique     = abap_false ).

    CREATE DATA rv_value TYPE HANDLE lo_new_tab.
  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD get_api_etag.
    DATA: ls_odata_result TYPE ty_odata_res_d.

    DATA(lv_path) = iv_path.

    " Find CA by Scenario ID
    cl_com_arrangement_factory=>create_instance( )->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_CS_API' ) ) )
      IMPORTING
        et_com_arrangement = DATA(lt_ca) ).
    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.

    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.

    " get destination based on Communication Arrangement and the service ID
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
            comm_scenario  = 'YY1_CS_API'
            service_id     = |YY1_ODATA{ iv_odata_version }_REST|
            comm_system_id = lo_ca->get_comm_system_id( ) ).
      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
        EXIT.
    ENDTRY.

    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        REPLACE ALL OCCURRENCES OF ` ` IN lv_path  WITH '%20'.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).

        lo_http_client->set_csrf_token(  ).

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

        ev_status_code = lo_response->get_status( )-code.
        ev_response = lo_response->get_text(  ).

        IF ev_status_code = 200.
          REPLACE ALL OCCURRENCES OF `__metadata` IN ev_response WITH 'metadata'.
          /ui2/cl_json=>deserialize( EXPORTING json = ev_response
                                               pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                     CHANGING  data = ls_odata_result ).
          IF ls_odata_result-d-results IS NOT INITIAL.
            ev_etag = ls_odata_result-d-results[ 1 ]-metadata-etag.
          ELSE.
            ev_etag = ls_odata_result-d-metadata-etag.
          ENDIF.
        ENDIF.

        lo_http_client->close(  ).

      CATCH cx_web_message_error INTO DATA(lx_web_message_error).
        ev_status_code = 500.
        ev_response = lx_web_message_error->get_text(  ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        ev_status_code = 500.
        ev_response = lx_web_http_client_error->get_text(  ).
      CATCH cx_root INTO DATA(lx_root).
        ev_status_code = 500.
        ev_response = lx_root->get_text(  ).
    ENDTRY.
  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD get_begindate_of_month.
    IF is_valid_date( iv_date ).
      rv_month_begin_date(6) = iv_date(6).
      rv_month_begin_date+6(2) = frist.
    ENDIF.
  ENDMETHOD.


  METHOD get_current_language.
    SELECT SINGLE languageisocode
      FROM i_language
     WHERE language = @sy-langu
      INTO @rv_language.
  ENDMETHOD.


  METHOD get_enddate_of_month.
    IF is_valid_date( iv_date ).
      IF iv_date+4(2) = december.
        rv_month_end_date(6) = iv_date(6).
        rv_month_end_date+6(2) = highdate-t.
      ELSE.
        rv_month_end_date = get_begindate_of_month( iv_date ).
        rv_month_end_date+4(2) = rv_month_end_date+4(2) + 1.
        rv_month_end_date = rv_month_end_date - 1.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_externalsystems_cdata.

    IF iv_authtype = 'OAuth2.0'.
      get_access_token( EXPORTING iv_token_url     = iv_token_url
                                  iv_client_id     = iv_client_id
                                  iv_client_secret = iv_client_secret
                        IMPORTING ev_status_code   = ev_status_code
                                  ev_response      = ev_response
                                  es_response      = DATA(ls_response) ).
      IF ls_response IS INITIAL.
        RETURN.
      ENDIF.
    ENDIF.

    TRY.
        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( iv_odata_url ).
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).
        DATA(lo_request) = lo_http_client->get_http_request( ).

        CASE iv_authtype.
          WHEN 'OAuth2.0'.
            lo_request->set_header_field( i_name = 'Authorization' i_value = |{ ls_response-token_type } { ls_response-access_token }| ).
          WHEN 'Basic'.
            lo_request->set_authorization_basic( i_username = iv_client_id i_password = iv_client_secret ).
        ENDCASE.

        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).

        IF iv_odata_filter IS NOT INITIAL.
          lo_request->set_form_field( i_name = '$filter' i_value = iv_odata_filter ).
        ENDIF.

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

        ev_status_code = lo_response->get_status( )-code.
        ev_response = lo_response->get_text(  ).

      CATCH cx_web_http_client_error cx_http_dest_provider_error INTO DATA(lx_http_exception).
        ev_status_code = 500.
        ev_response = lx_http_exception->get_text( ).
    ENDTRY.
  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD get_fiscal_year_period.
    IF iv_date IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE
           fiscalyear,
           fiscalperiod
      FROM i_fiscalyearperiodforvariant WITH PRIVILEGED ACCESS
     WHERE fiscalyearvariant = 'V3'
       AND isspecialperiod   = ''
       AND fiscalperiodstartdate <= @iv_date
       AND fiscalperiodenddate >= @iv_date
      INTO ( @ev_year, @ev_period ).
  ENDMETHOD.


  METHOD get_number_next.
    DATA: ls_data  TYPE ztbc_1002,
          lt_data  TYPE TABLE OF ztbc_1002,
          lv_datum TYPE datum,
          lv_daywm TYPE c LENGTH 8,
          lo_srnum TYPE REF TO data.
    DATA: lv_date   TYPE datum,
          lv_client TYPE sy-mandt,
          lv_subrc  TYPE sy-subrc.
    DATA: lt_lock_parameter TYPE if_abap_lock_object=>tt_parameter.
    FIELD-SYMBOLS <lv_srnum> TYPE n.

    lv_date   = iv_datum.
    lv_client = sy-mandt.

    IF iv_nrlen IS INITIAL.
      RAISE EXCEPTION NEW zzcx_custom_exception( textid = VALUE #( msgid = 'ZBC_001'
                                                                   msgno = '002'
                                                                   attr1 = 'iv_nrlen' ) ).
    ENDIF.

    IF lv_date IS INITIAL OR lv_date = ''.
      TRY.
          lv_date = cl_abap_context_info=>get_system_date(  ).
          ##NO_HANDLER
        CATCH cx_abap_context_info_error.
          " handle exception
      ENDTRY.
    ENDIF.
    lv_datum = lv_date.
    lv_daywm = lv_date.

    CREATE DATA lo_srnum TYPE n LENGTH iv_nrlen.
    ASSIGN lo_srnum->* TO <lv_srnum>.

    TRY.
        DATA(lr_lock) = cl_abap_lock_object_factory=>get_instance( 'EZ_ZTBC_1002' ).
      CATCH cx_abap_lock_failure INTO DATA(lx_abap_lock_failure).
        RAISE EXCEPTION NEW zzcx_custom_exception( textid = VALUE #( msgid = 'ZBC_001'
                                                                     msgno = '000'
                                                                     attr1 = lx_abap_lock_failure->get_text( ) ) ).
    ENDTRY.

    SELECT SINGLE * FROM ztbc_1002 WHERE object = @iv_object AND datum = @lv_datum INTO @ls_data.
    lv_subrc = sy-subrc.
    IF lv_subrc = 0.
      lt_lock_parameter = VALUE #( ( name = 'CLIENT' value = REF #( lv_client ) )
                                   ( name = 'OBJCET' value = REF #( iv_object ) )
                                   ( name = 'DATUM'  value = REF #( lv_datum ) ) ).
    ELSE.
      lt_lock_parameter = VALUE #( ( name = 'CLIENT' value = REF #( lv_client ) )
                                   ( name = 'OBJCET' value = REF #( iv_object ) )  ).
    ENDIF.

    TRY.
        lr_lock->enqueue( it_parameter = lt_lock_parameter ).
      CATCH cx_abap_foreign_lock INTO DATA(lx_abap_foreign_lock).
        RAISE EXCEPTION NEW zzcx_custom_exception( textid = VALUE #( msgid = 'ZBC_001'
                                                                     msgno = '000'
                                                                     attr1 = lx_abap_foreign_lock->get_text( ) ) ).
      CATCH cx_abap_lock_failure INTO lx_abap_lock_failure.
        RAISE EXCEPTION NEW zzcx_custom_exception( textid = VALUE #( msgid = 'ZBC_001'
                                                                     msgno = '000'
                                                                     attr1 = lx_abap_lock_failure->get_text( ) ) ).
    ENDTRY.
    IF lv_subrc <> 0.
      IF sy-subrc = 0.
        ls_data-object = iv_object.
        ls_data-datum  = lv_datum.
        ls_data-srnum  = 0.
        DO 365 TIMES.
          APPEND ls_data TO lt_data.
          ls_data-datum = ls_data-datum + 1.
        ENDDO.
        INSERT ztbc_1002 FROM TABLE @lt_data ACCEPTING DUPLICATE KEYS.
        IF sy-subrc = 0.
*          COMMIT WORK.
        ELSE.
          " Serial number initialization, please call again.
          RAISE EXCEPTION NEW zzcx_custom_exception( textid = VALUE #( msgid = 'ZBC_001'
                                                                       msgno = '003' ) ).
        ENDIF.
        ls_data-datum = lv_datum.
      ELSE.
        " Serial number initialization, please call again.
        RAISE EXCEPTION NEW zzcx_custom_exception( textid = VALUE #( msgid = 'ZBC_001'
                                                                     msgno = '003' ) ).
      ENDIF.
    ENDIF.

    <lv_srnum> = ls_data-srnum = ls_data-srnum + 1.
    IF <lv_srnum> < ls_data-srnum.
      " Serial number overflow.
      RAISE EXCEPTION NEW zzcx_custom_exception( textid = VALUE #( msgid = 'ZBC_001'
                                                                   msgno = '004' ) ).
    ENDIF.

    UPDATE ztbc_1002 FROM @ls_data.
    IF sy-subrc = 0.
*      COMMIT WORK.
    ELSE.
      RAISE EXCEPTION NEW zzcx_custom_exception( textid = VALUE #( msgid = 'ZBC_001'
                                                                   msgno = '005' ) ).
    ENDIF.

    CONCATENATE lv_daywm <lv_srnum> INTO rv_nrnum.

    TRY.
        lr_lock->dequeue( it_parameter = lt_lock_parameter ).
      CATCH cx_abap_lock_failure INTO lx_abap_lock_failure.
        RAISE EXCEPTION NEW zzcx_custom_exception( textid = VALUE #( msgid = 'ZBC_001'
                                                                     msgno = '000'
                                                                     attr1 = lx_abap_lock_failure->get_text( ) ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_workingday.
    DATA lv_date TYPE datum.

    SELECT SINGLE factorycalendarid,
                  factorycalendarvalidityenddate
      FROM i_factorycalendarbasic WITH PRIVILEGED ACCESS AS a
      JOIN i_plant AS b ON b~factorycalendar = a~factorycalendarlegacyid
     WHERE b~plant = @iv_plant
      INTO @DATA(ls_factorycalendar).
    IF sy-subrc = 0.
      TRY.
          DATA(lo_fcal_run) = cl_fhc_calendar_runtime=>create_factorycalendar_runtime( iv_factorycalendar_id = ls_factorycalendar-factorycalendarid ).
          DATA(lv_flag) = lo_fcal_run->is_date_workingday( iv_date = iv_date ).

          " is a holiday
          IF lv_flag = abap_false.

            IF iv_date > ls_factorycalendar-factorycalendarvalidityenddate.
              rv_workingday = '12340506'. " 用于标识，超过工厂日历范围
              RETURN.
            ENDIF.

            lv_date = iv_date.
            DO.
              lv_date += 1.
              IF iv_date > ls_factorycalendar-factorycalendarvalidityenddate.
                rv_workingday = '12340506'. " 用于标识，超过工厂日历范围
                RETURN.
              ENDIF.
              IF lo_fcal_run->is_date_workingday( iv_date = lv_date ).
                rv_workingday = lv_date.
                EXIT.
              ENDIF.
            ENDDO.

            " not is holiday, get next working day
          ELSEIF iv_next = abap_true.
            lv_date = iv_date + 1.
            rv_workingday = get_workingday( iv_date  = lv_date
                                            iv_next  = abap_false
                                            iv_plant = iv_plant ).

            " not is holiday, get current working day
          ELSE.
            rv_workingday = iv_date.
          ENDIF.
        CATCH cx_fhc_runtime INTO DATA(lx_err).
          "handle exception
          DATA(lv_text) = lx_err->get_text( ).
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
*    DATA lv_path TYPE string.
*
*    lv_path = |/API_PRODUCT_SRV/A_Product('123')/to_ProductBasicText|.
*
*    request_api_v2( EXPORTING iv_path        = lv_path
*                              iv_method      = if_web_http_client=>get
*                    IMPORTING ev_status_code = DATA(lv_status_code)
*                              ev_response    = DATA(lv_ev_response) ).
*
*    IF lv_status_code IS NOT INITIAL.
*    ENDIF.

*    TRY.
*        DATA(lv_nr_number) = get_number_next( iv_object = 'TESTNUM'
*                                              iv_nrlen  = 4 ).
*      CATCH zzcx_custom_exception INTO DATA(lx_custom_exception).
*        "handle exception
*        DATA(lv_error) = lx_custom_exception->get_longtext( ).
*    ENDTRY.
*    out->write( lv_nr_number ).

*    DATA lt_recipient TYPE cl_bcs_mail_message=>tyt_recipient.
*    lt_recipient = VALUE #( ( address = 'xinlei.xu@sh.shin-china.com' ) ).
*    TRY.
*        send_email( EXPORTING iv_subject = 'test'
*                              iv_main_content = 'test_content'
*                              it_recipient = lt_recipient
*                    IMPORTING et_status = DATA(lt_status) ).
*      CATCH cx_bcs_mail INTO DATA(lx_bcs_mail).
*        DATA(lv_text) = lx_bcs_mail->get_longtext(  ).
*        "handle exception
*    ENDTRY.
  ENDMETHOD.


  METHOD is_valid_date.
    rv_valid = abap_true.

    date = iv_date.
    IF date-m LT januar OR date-m GT december.            "#EC PORTABLE
      rv_valid = abap_false.
    ENDIF.
    IF date-j LT lowdate.                                 "#EC PORTABLE
      rv_valid = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD is_workingday.
    rv_workingday = abap_false.
    SELECT SINGLE factorycalendarid
      FROM i_factorycalendarbasic WITH PRIVILEGED ACCESS AS a
      JOIN i_plant AS b ON b~factorycalendar = a~factorycalendarlegacyid
     WHERE b~plant = @iv_plant
      INTO @DATA(lv_factorycalendar_id).
    IF sy-subrc = 0.
      TRY.
          DATA(lo_fcal_run) = cl_fhc_calendar_runtime=>create_factorycalendar_runtime( iv_factorycalendar_id = lv_factorycalendar_id ).
          rv_workingday = lo_fcal_run->is_date_workingday( iv_date = iv_date ).
        CATCH cx_fhc_runtime INTO DATA(lx_err).
          "handle exception
          DATA(lv_text) = lx_err->get_text( ).
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD merge_message.
    IF iv_message1 IS INITIAL.
      rv_result = iv_message2.
    ELSE.
      rv_result = |{ iv_message1 }{ iv_symbol }{ iv_message2 }|.
    ENDIF.
  ENDMETHOD.


  METHOD parse_error_v2.
    DATA ls_error TYPE ty_error_v2.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_response
                               CHANGING  data = ls_error ).
    IF ls_error-error-message-value IS NOT INITIAL.
      IF ls_error-error-innererror-errordetails IS NOT INITIAL.
        LOOP AT ls_error-error-innererror-errordetails INTO DATA(ls_detail).
          "内表中的消息会有多个，可以排除code:/IWCOR/CX_OD_BAD_REQUEST/  CX_SXML_PARSE_ERROR 对用户判断错误起不到作用
          IF ls_detail-code CS '/IWCOR/CX_OD_BAD_REQUEST' OR
            ls_detail-code CS 'CX_SXML_PARSE_ERROR'.
            CONTINUE.
          ENDIF.
          IF ls_detail-message IS NOT INITIAL.
            rv_message = |{ rv_message }{ ls_detail-message };|.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF rv_message IS INITIAL.
        rv_message = ls_error-error-message-value.
      ENDIF.
    ELSEIF ls_error-error-code IS NOT INITIAL.
      SPLIT ls_error-error-code AT '/' INTO TABLE DATA(lt_msg).
      IF lines( lt_msg ) = 2.
        DATA(lv_msg_class) = lt_msg[ 1 ].
        DATA(lv_msg_number) = lt_msg[ 2 ].
        MESSAGE ID lv_msg_class TYPE 'S' NUMBER lv_msg_number INTO rv_message.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD parse_error_v4.
    DATA ls_error TYPE ty_error_v4.
    /ui2/cl_json=>deserialize( EXPORTING json = iv_response
                               CHANGING  data = ls_error ).
    IF ls_error-error-message IS NOT INITIAL.
      IF ls_error-error-details IS NOT INITIAL.
        LOOP AT ls_error-error-details INTO DATA(ls_detail).
          "内表中的消息会有多个，可以排除code:/IWCOR/CX_OD_BAD_REQUEST/  CX_SXML_PARSE_ERROR 对用户判断错误起不到作用
          IF ls_detail-code CS '/IWCOR/CX_OD_BAD_REQUEST' OR
            ls_detail-code CS 'CX_SXML_PARSE_ERROR'.
            CONTINUE.
          ENDIF.
          IF ls_detail-message IS NOT INITIAL.
            rv_message = |{ rv_message }{ ls_detail-message };|.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF rv_message IS INITIAL.
        rv_message = ls_error-error-message.
      ENDIF.
    ELSEIF ls_error-error-code IS NOT INITIAL.
      SPLIT ls_error-error-code AT '/' INTO TABLE DATA(lt_msg).
      IF lines( lt_msg ) = 2.
        DATA(lv_msg_class) = lt_msg[ 1 ].
        DATA(lv_msg_number) = lt_msg[ 2 ].
        MESSAGE ID lv_msg_class TYPE 'S' NUMBER lv_msg_number INTO rv_message.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD request_api_v2.
    DATA(lv_path) = iv_path.

    " Find CA by Scenario ID
    cl_com_arrangement_factory=>create_instance( )->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_CS_API' ) ) )
      IMPORTING
        et_com_arrangement = DATA(lt_ca) ).
    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.

    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.

    " get destination based on Communication Arrangement and the service ID
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
            comm_scenario  = 'YY1_CS_API'
            service_id     = 'YY1_ODATAV2_REST'
            comm_system_id = lo_ca->get_comm_system_id( ) ).

      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
        EXIT.
    ENDTRY.

    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        REPLACE ALL OCCURRENCES OF ` ` IN lv_path  WITH '%20'.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).

        IF iv_format IS NOT INITIAL.
          lo_request->set_form_field( i_name = '$format' i_value = iv_format ).
        ENDIF.
        IF iv_select IS NOT INITIAL.
          lo_request->set_form_field( i_name = '$select' i_value = iv_select ).
        ENDIF.
        IF iv_filter IS NOT INITIAL.
          lo_request->set_form_field( i_name = '$filter' i_value = iv_filter ).
        ENDIF.

        IF iv_method = if_web_http_client=>post
        OR iv_method = if_web_http_client=>put
        OR iv_method = if_web_http_client=>patch.
          IF iv_contenttype_value IS INITIAL.
            lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
          ELSE.
            lo_request->set_header_field( i_name = 'Content-Type' i_value = iv_contenttype_value ).
          ENDIF.
          lo_request->set_text( iv_body ).
        ENDIF.

        IF iv_etag IS NOT INITIAL.
          DATA(lv_etag) = iv_etag.
        ELSEIF iv_method = if_web_http_client=>patch.
          get_api_etag( EXPORTING iv_odata_version = 'V2'
                                  iv_path          = lv_path
                        IMPORTING ev_status_code   = ev_status_code
                                  ev_response      = ev_response
                                  ev_etag          = lv_etag ).
        ENDIF.
        IF lv_etag IS NOT INITIAL.
          lo_request->set_header_field( i_name = 'If-Match' i_value = lv_etag ).
        ENDIF.

        lo_http_client->set_csrf_token(  ).

        DATA(lo_response) = lo_http_client->execute( iv_method ).

        ev_status_code = lo_response->get_status( )-code.
        ev_response = lo_response->get_text(  ).
        IF iv_method = if_web_http_client=>get.
          ev_etag = lo_response->get_header_field( i_name = 'etag' ).
        ENDIF.
        lo_http_client->close(  ).

      CATCH cx_web_message_error INTO DATA(lx_web_message_error).
        ev_status_code = 500.
        ev_response = lx_web_message_error->get_text(  ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        ev_status_code = 500.
        ev_response = lx_web_http_client_error->get_text(  ).
      CATCH cx_root INTO DATA(lx_root).
        ev_status_code = 500.
        ev_response = lx_root->get_text(  ).
    ENDTRY.
  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD request_api_v4.
    DATA(lv_path) = iv_path.

    " Find CA by Scenario ID
    cl_com_arrangement_factory=>create_instance( )->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_CS_API' ) ) )
      IMPORTING
        et_com_arrangement = DATA(lt_ca) ).
    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.

    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.

    " get destination based on Communication Arrangement and the service ID
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
            comm_scenario  = 'YY1_CS_API'
            service_id     = 'YY1_ODATAV4_REST'
            comm_system_id = lo_ca->get_comm_system_id( ) ).

      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
        EXIT.
    ENDTRY.

    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        REPLACE ALL OCCURRENCES OF ` ` IN lv_path  WITH '%20'.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).

        IF iv_format IS NOT INITIAL.
          lo_request->set_form_field( i_name = '$format' i_value = iv_format ).
        ENDIF.
        IF iv_select IS NOT INITIAL.
          lo_request->set_form_field( i_name = '$select' i_value = iv_select ).
        ENDIF.
        IF iv_filter IS NOT INITIAL.
          lo_request->set_form_field( i_name = '$filter' i_value = iv_filter ).
        ENDIF.

        IF iv_method = if_web_http_client=>post
        OR iv_method = if_web_http_client=>put
        OR iv_method = if_web_http_client=>patch.
          IF iv_contenttype_value IS INITIAL.
            lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
          ELSE.
            lo_request->set_header_field( i_name = 'Content-Type' i_value = iv_contenttype_value ).
          ENDIF.
          lo_request->set_text( iv_body ).
        ENDIF.

        IF iv_etag IS NOT INITIAL.
          DATA(lv_etag) = iv_etag.
        ELSEIF iv_method = if_web_http_client=>patch.
          get_api_etag( EXPORTING iv_odata_version = 'V4'
                                  iv_path          = lv_path
                        IMPORTING ev_status_code   = ev_status_code
                                  ev_response      = ev_response
                                  ev_etag          = lv_etag ).
        ENDIF.
        IF lv_etag IS NOT INITIAL.
          lo_request->set_header_field( i_name = 'If-Match' i_value = lv_etag ).
        ENDIF.

        lo_http_client->set_csrf_token(  ).

        DATA(lo_response) = lo_http_client->execute( iv_method ).

        ev_status_code = lo_response->get_status( )-code.
        ev_response = lo_response->get_text(  ).

        IF iv_method = if_web_http_client=>get.
          ev_etag = lo_response->get_header_field( i_name = 'etag' ).
        ENDIF.
        lo_http_client->close(  ).

      CATCH cx_web_message_error INTO DATA(lx_web_message_error).
        ev_status_code = 500.
        ev_response = lx_web_message_error->get_text(  ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        ev_status_code = 500.
        ev_response = lx_web_http_client_error->get_text(  ).
      CATCH cx_root INTO DATA(lx_root).
        ev_status_code = 500.
        ev_response = lx_root->get_text(  ).
    ENDTRY.
  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD send_email.
    TRY.
        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).

        LOOP AT it_recipient INTO DATA(ls_recipient).
          lo_mail->add_recipient( iv_address = ls_recipient-address
                                  iv_copy    = ls_recipient-copy ).
        ENDLOOP.

        lo_mail->set_subject( iv_subject ).
        lo_mail->set_main( cl_bcs_mail_textpart=>create_instance( iv_content      = iv_main_content
                                                                  iv_content_type = 'text/html' ) ).
        LOOP AT it_attachment INTO DATA(ls_attachment).
          lo_mail->add_attachment( cl_bcs_mail_binarypart=>create_instance( iv_content      = ls_attachment-content
                                                                            iv_content_type = ls_attachment-content_type
                                                                            iv_filename     = ls_attachment-filename ) ).
        ENDLOOP.

        lo_mail->send( IMPORTING et_status = et_status ).
      CATCH cx_bcs_mail.
        RAISE EXCEPTION TYPE cx_bcs_mail.
    ENDTRY.
  ENDMETHOD.


  METHOD set_datadescr.
    rv_descr ?= cl_abap_elemdescr=>describe_by_name( iv_types ).
  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD unit_conversion_simple.
    DATA(lo_unit) = cl_uom_conversion=>create( ).
    lo_unit->unit_conversion_simple( EXPORTING  input                = input
                                                round_sign           = round_sign
                                                unit_in              = unit_in
                                                unit_out             = unit_out
                                     IMPORTING  output               = output
                                     EXCEPTIONS conversion_not_found = 01
                                                division_by_zero     = 02
                                                input_invalid        = 03
                                                output_invalid       = 04
                                                overflow             = 05
                                                units_missing        = 06
                                                unit_in_not_found    = 07
                                                unit_out_not_found   = 08 ).
  ENDMETHOD.

  METHOD get_email_by_uname.
    DATA lv_user TYPE sy-uname.

    IF iv_user IS INITIAL.
      lv_user = sy-uname.
    ELSE.
      lv_user = iv_user.
    ENDIF.

    SELECT SINGLE email FROM zc_businessuseremail WHERE userid = @lv_user INTO @rv_email.
  ENDMETHOD.

  METHOD get_access_by_user.
    SELECT access~roleid,
           access~accessid,
           access~accessname
      FROM zc_tbc1007 AS assignrole
      JOIN zc_tbc1016 AS access ON access~roleid = assignrole~roleid
     WHERE assignrole~mail = @iv_email
     INTO TABLE @DATA(lt_access).
    SORT lt_access BY accessid.

    LOOP AT lt_access INTO DATA(ls_access).
      CONDENSE ls_access-accessid NO-GAPS.
      IF rv_access IS INITIAL.
        rv_access = ls_access-accessid.
      ELSE.
        rv_access = rv_access && '|' && ls_access-accessid.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
