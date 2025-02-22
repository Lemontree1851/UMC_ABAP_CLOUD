CLASS zcl_http_usap_002 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
* input data type
    TYPES:
      BEGIN OF ts_input_item1,
        delivery     TYPE c LENGTH 10,
        actualdate   TYPE budat,
      END OF ts_input_item1,
      tt_item1 TYPE STANDARD TABLE OF ts_input_item1 WITH DEFAULT KEY,

      BEGIN OF ts_post,
        BEGIN OF to_post,
          items TYPE tt_item1,
        END OF to_post,
      END OF ts_post,

      BEGIN OF ts_result,
        systemmessageidentification TYPE c LENGTH 20,
        systemmessagenumber         TYPE c LENGTH 3,
        systemmessagetype           TYPE c LENGTH 1,
        systemmessagevariable1      TYPE c LENGTH 50,
        systemmessagevariable2      TYPE c LENGTH 50,
        systemmessagevariable3      TYPE c LENGTH 50,
        systemmessagevariable4      TYPE c LENGTH 50,
      END OF ts_result,
      tt_result TYPE STANDARD TABLE OF ts_result WITH DEFAULT KEY,

      BEGIN OF ts_d,
        __count TYPE string,
        results TYPE tt_result,
      END OF ts_d,

      BEGIN OF ts_message,
        lang  TYPE string,
        value TYPE string,
      END OF ts_message,

      BEGIN OF ts_error,
        code    TYPE string,
        message TYPE ts_message,
      END OF ts_error,

      BEGIN OF ts_res_api,
        d     TYPE ts_d,
        error TYPE ts_error,
      END OF ts_res_api,

      BEGIN OF ts_response,
        _message TYPE c LENGTH 220,
        _status  TYPE c LENGTH 1,
      END OF ts_response,

      BEGIN OF ts_output,
        items TYPE STANDARD TABLE OF ts_response WITH EMPTY KEY,
      END OF ts_output,

      BEGIN OF ts_input_item2,
        delivery TYPE c LENGTH 10,
        gidate   TYPE budat,
      END OF ts_input_item2,
      tt_item2 TYPE STANDARD TABLE OF ts_input_item2 WITH DEFAULT KEY,

      BEGIN OF ts_reserve,
        BEGIN OF to_reserve,
          items TYPE tt_item2,
        END OF to_reserve,
      END OF ts_reserve,

      BEGIN OF ts_outbound,
        _actual_goods_movement_date TYPE string,
        _bill_of_lading             TYPE string,
      END OF ts_outbound.

    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      ls_post_in        TYPE ts_post,
      ls_reserve_in     TYPE ts_reserve,
      lv_msg(220)       TYPE c,
      lv_text           TYPE string,
      lv_success        TYPE c,
      lv_count          TYPE i,
      ls_response       TYPE ts_response,
      es_response       TYPE ts_output,
      lc_header_content TYPE string VALUE 'content-type',
      lc_content_type   TYPE string VALUE 'text/json',
      lo_root_exc       TYPE REF TO cx_root.
ENDCLASS.



CLASS ZCL_HTTP_USAP_002 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA:
      ls_outbound TYPE ts_outbound,
      lt_result   TYPE STANDARD TABLE OF ts_result,
      ls_res_api  TYPE ts_res_api.

    DATA:
      lv_datetime TYPE string,
      lv_etag     TYPE string.

    DATA(lv_req_body) = request->get_text( ).
    IF sy-subrc <> 0.
      ls_response-_message = 'Connect fail'.
      ls_response-_status = 'E'.
      APPEND ls_response TO es_response-items.
      RETURN.
    ENDIF.

    DATA(lv_header) = request->get_header_field( i_name = 'action' ).
    DATA(lv_langu) = request->get_header_field( i_name = 'sap-language' ).
    IF lv_header = 'POST'.
      /ui2/cl_json=>deserialize(
         EXPORTING
           json             = lv_req_body
           pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
         CHANGING
           data             = ls_post_in ).
    ELSE.
      /ui2/cl_json=>deserialize(
         EXPORTING
           json             = lv_req_body
           pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
         CHANGING
           data             = ls_reserve_in ).
    ENDIF.

* POST Process
    IF lv_header = 'POST'.

      DATA(lt_post) = ls_post_in-to_post-items.

      LOOP AT lt_post INTO DATA(ls_post).
        CLEAR: lv_etag.
        ls_post-delivery = |{ ls_post-delivery ALPHA = IN }|.
        DATA(lv_parameter) = '''' && ls_post-delivery && ''''.
* update gr date
        IF ls_post-actualdate IS INITIAL.
          DATA(lv_datum) = cl_abap_context_info=>get_system_date( ).
        ELSE.
          lv_datum = ls_post-actualdate.
        ENDIF.
        ls_outbound-_actual_goods_movement_date = |{ lv_datum+0(4) }-{ lv_datum+4(2) }-{ lv_datum+6(2) }T00:00:00|.
        ls_outbound-_bill_of_lading = 'UWMS'.
        data(lv_reqbody_api) = /ui2/cl_json=>serialize( data = ls_outbound
                                                    compress = 'X'
                                                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
        zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = |/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader({ lv_parameter })|
                                                     iv_method      = if_web_http_client=>get
                                                     iv_etag        = lv_etag
                                           IMPORTING ev_status_code = DATA(lv_status_code)
                                                     ev_response    = DATA(lv_response)
                                                     ev_etag        = lv_etag ).
        IF lv_etag IS INITIAL.
          ls_response-_status = 'E'.
          ls_response-_message = 'No Etag for update'.
          APPEND ls_response TO es_response-items.
          CLEAR: ls_response.
          CONTINUE.
        ELSE.
          zzcl_common_utils=>request_api_v2( EXPORTING iv_path = |/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader({ lv_parameter })?sap-language={ lv_langu }|
                                                 iv_method      = if_web_http_client=>patch
                                                 iv_body        = lv_reqbody_api
                                       IMPORTING ev_status_code = lv_status_code
                                                 ev_response    = lv_response ).
          /ui2/cl_json=>deserialize(
                            EXPORTING json = lv_response
                            CHANGING data = ls_res_api ).
          IF lv_status_code = 204. " patch

          ELSE.
            ls_response-_status = 'E'.
            ls_response-_message = ls_res_api-error-message-value.
            "ls_response-_message = 'Update date fail'.
            APPEND ls_response TO es_response-items.
            CLEAR: ls_response.
            CONTINUE.
          ENDIF.
        ENDIF.
* Post
        CLEAR: lv_etag.
        zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = |/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader({ lv_parameter })|
                                                     iv_method      = if_web_http_client=>get
                                                     iv_etag        = lv_etag
                                           IMPORTING ev_status_code = lv_status_code
                                                     ev_response    = lv_response
                                                     ev_etag        = lv_etag ).
        IF lv_etag IS INITIAL.
          ls_response-_status = 'E'.
          ls_response-_message = 'No Etag for post'.
          APPEND ls_response TO es_response-items.
          CLEAR: ls_response.
          CONTINUE.
        ELSE.
          zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = |/API_OUTBOUND_DELIVERY_SRV;v=0002/PostGoodsIssue?DeliveryDocument={ lv_parameter }&sap-language={ lv_langu }|
                                                       iv_method      = if_web_http_client=>post
                                                       iv_etag        = lv_etag
                                             IMPORTING ev_status_code = lv_status_code
                                                       ev_response    = lv_response ).

          /ui2/cl_json=>deserialize(
                            EXPORTING json = lv_response
                            CHANGING data = ls_res_api ).
          IF lv_status_code = 200. " Post
            ls_response-_status = 'S'.
            ls_response-_message = 'Posted successful'.
            APPEND ls_response TO es_response-items.
            CLEAR: ls_response.
          ELSE.
            ls_response-_status = 'E'.
            ls_response-_message = ls_res_api-error-message-value.
            APPEND ls_response TO es_response-items.
            CLEAR: ls_response.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
* Reserve
      DATA(lt_reserve) = ls_reserve_in-to_reserve-items.
      LOOP AT lt_reserve INTO DATA(ls_reserve).
        ls_reserve-delivery = |{ ls_reserve-delivery ALPHA = IN }|.
        lv_parameter = '''' && ls_reserve-delivery && ''''.
        lv_datetime = |{ ls_reserve-gidate+0(4) }-{ ls_reserve-gidate+4(2) }-{ ls_reserve-gidate+6(2) }T00:00:00|.
        lv_datetime = 'datetime' && '''' && lv_datetime && ''''.

        zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = |/API_OUTBOUND_DELIVERY_SRV;v=2/ReverseGoodsIssue?DeliveryDocument={ lv_parameter }&ActualGoodsMovementDate={ lv_datetime }&sap-language={ lv_langu }|
                                                     iv_method      = if_web_http_client=>post
                                                     "iv_etag        = lv_etag
                                           IMPORTING ev_status_code = lv_status_code
                                                     ev_response    = lv_response ).



        /ui2/cl_json=>deserialize(
                            EXPORTING json = lv_response
                            CHANGING data = ls_res_api ).
        IF lv_status_code = 200. "
*          APPEND LINES OF ls_res_api-d-results TO lt_result.
*          LOOP AT lt_result INTO ls_result.
*            lv_text = ls_result-systemmessagevariable1
*                    && ls_result-systemmessagevariable2
*                    && ls_result-systemmessagevariable3
*                    && ls_result-systemmessagevariable4.
*          ENDLOOP.
          ls_response-_status = 'S'.
          ls_response-_message = 'Reserve successful'.
          APPEND ls_response TO es_response-items.
          CLEAR: ls_response.
        ELSE.
          ls_response-_status = 'E'.
          ls_response-_message = ls_res_api-error-message-value.
          APPEND ls_response TO es_response-items.
          CLEAR: ls_response.
        ENDIF.
      ENDLOOP.
    ENDIF.


* Send response to USAP
    response->set_status( '200' ).
    DATA(lv_json_string) = xco_cp_json=>data->from_abap( es_response )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).
    response->set_text( lv_json_string ).
    response->set_header_field( i_name  = lc_header_content
                                i_value = lc_content_type ).

  ENDMETHOD.
ENDCLASS.
