CLASS zcl_accountingdoc DEFINITION
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

      "! Method get month end date
      "! @parameter iv_xml             | header items
      "! @parameter           rv_xml   | lines items for input headers
      get_print_items      IMPORTING iv_xml                  TYPE xstring
                           RETURNING VALUE(rv_xml) TYPE xstring.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ACCOUNTINGDOC IMPLEMENTATION.


  METHOD get_print_items.

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


  METHOD merge_message.
    IF iv_message1 IS INITIAL.
      rv_result = iv_message2.
    ELSE.
      rv_result = |{ iv_message1 }{ iv_symbol }{ iv_message2 }|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
