CLASS zcl_http_storagelocation_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

*   export parameters
    TYPES:
      BEGIN OF ty_response,
        plant                      TYPE c  LENGTH 4	 ,       "プラント			
        storagelocation            TYPE c  LENGTH 4	 ,       "保管場所	
        storagelocationname        TYPE c  LENGTH 16	 ,       "保管場所名			
        salesorganization          TYPE c  LENGTH 4	 ,       "販売組織			
        distributionchannel        TYPE c  LENGTH 2	 ,       "流通チャネル			
        division                   TYPE c  LENGTH 2	 ,       "製品部門			
        isstorlocauthzncheckactive TYPE c  LENGTH 1	 ,       "権限チェック			
        handlingunitisrequired     TYPE c  LENGTH 1	 ,       "HU 必須			
        configdeprecationcode      TYPE c  LENGTH 1	 ,       "有効性			

      END OF ty_response.

*   input parameters
    TYPES:
      BEGIN OF ty_inputs,
        plant(4) TYPE c,
      END OF ty_inputs,

      BEGIN OF ty_output,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_response WITH EMPTY KEY,
      END OF ty_output.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      lt_input          TYPE STANDARD TABLE OF ty_inputs,
      lv_error(1)       TYPE c,
      lv_text           TYPE string,
      ls_response       TYPE ty_response,
      es_response       TYPE ty_output,
      lc_header_content TYPE string VALUE 'content-type',
      lc_content_type   TYPE string VALUE 'text/json'.
    DATA:
      lv_temp(14)      TYPE c,
      lv_purchaseorder TYPE c LENGTH 10.
ENDCLASS.



CLASS ZCL_HTTP_STORAGELOCATION_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    GET TIME STAMP FIELD DATA(lv_timestamp_start).

    DATA(lv_req_body) = request->get_text( ).
    DATA(lv_header) = request->get_header_field( i_name = 'form' ).

    IF lv_header = 'XML'.

    ELSE.
      "处理JSON请求体
      IF lv_req_body IS NOT INITIAL.
        xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
            ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->write_to( REF #( lt_input ) ).
      ENDIF.
    ENDIF.

    SELECT *
    FROM i_storagelocation WITH PRIVILEGED ACCESS
    FOR ALL ENTRIES IN @lt_input
    WHERE plant = @lt_input-plant
    INTO TABLE @DATA(lt_storage).

    DATA: lv_count TYPE i.

    IF lt_storage IS NOT INITIAL.
      DATA(lt_storage1) = lt_storage.
      SORT lt_storage1 BY plant storagelocation.
      DELETE ADJACENT DUPLICATES FROM lt_storage1 COMPARING plant storagelocation.

      LOOP AT lt_storage1  INTO DATA(lw_data).
        lv_count = lv_count + 1.
      ENDLOOP.

      LOOP AT lt_storage INTO DATA(lw_storage).
        ls_response-plant                      =   lw_storage-plant                                .
        ls_response-storagelocation            =   lw_storage-storagelocation                      .
        ls_response-storagelocationname        =   lw_storage-storagelocationname                  .
        ls_response-salesorganization          =   lw_storage-salesorganization                    .
        ls_response-distributionchannel        =   lw_storage-distributionchannel                  .
        ls_response-division                   =   lw_storage-division                             .
        ls_response-isstorlocauthzncheckactive =   lw_storage-isstorlocauthzncheckactive           .
        ls_response-handlingunitisrequired     =   lw_storage-handlingunitisrequired               .
        ls_response-configdeprecationcode      =   lw_storage-configdeprecationcode                .

        CONDENSE ls_response-plant                                                                 .
        CONDENSE ls_response-storagelocation                                                       .
        CONDENSE ls_response-storagelocationname                                                   .
        CONDENSE ls_response-salesorganization                                                     .
        CONDENSE ls_response-distributionchannel                                                   .
        CONDENSE ls_response-division                                                              .
        CONDENSE ls_response-isstorlocauthzncheckactive                                            .
        CONDENSE ls_response-handlingunitisrequired                                                .
        CONDENSE ls_response-configdeprecationcode                                                 .
        APPEND ls_response TO es_response-items.
        CLEAR ls_response.
      ENDLOOP.

      es_response-message = |保管場所{ lv_count }件は送信されました。|.
    ELSE.
      lv_error = 'X'.
      lv_text = 'storagelocation not found'.
    ENDIF.

    IF lv_error IS NOT INITIAL.
      "propagate any errors raised
      response->set_status( '500' )."500
      response->set_text( lv_text ).
    ELSE.
      "respond with success payload
      response->set_status( '200' ).

      DATA(lv_json_string) = xco_cp_json=>data->from_abap( es_response )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).
      response->set_text( lv_json_string ).
      response->set_header_field( i_name  = lc_header_content
                                  i_value = lc_content_type ).
    ENDIF.

*&--ADD BEGIN BY XINLEI XU 2025/02/08
    GET TIME STAMP FIELD DATA(lv_timestamp_end).
    TRY.
        DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
        DATA(lv_request_url) = |https://{ lv_system_url }/sap/bc/http/sap/z_http_storagelocation_001|.
        ##NO_HANDLER
      CATCH cx_abap_context_info_error.
        "handle exception
    ENDTRY.

    DATA(lv_request_body) = xco_cp_json=>data->from_abap( lt_input )->apply( VALUE #(
    ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    zzcl_common_utils=>add_interface_log( EXPORTING iv_interface_id   = |IF022|
                                                    iv_interface_desc = |保管場所連携|
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
