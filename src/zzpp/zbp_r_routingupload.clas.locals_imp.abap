CLASS lhc_routingupload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_routingupload.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING REQUEST requested_authorizations FOR routingupload RESULT result,
      processlogic FOR MODIFY
        IMPORTING keys FOR ACTION routingupload~processlogic RESULT result.

    METHODS check  CHANGING ct_data TYPE lty_request_t.
    METHODS excute CHANGING ct_data TYPE lty_request_t.
    METHODS export IMPORTING it_data              TYPE lty_request_t
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.
ENDCLASS.

CLASS lhc_routingupload IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD processlogic.

    DATA: lt_request TYPE TABLE OF lty_request,
          lt_export  TYPE TABLE OF lty_request.

    DATA: i TYPE i.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_request.
      i += 1.

      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).

      CASE lv_event.
        WHEN 'CHECK'.
          check( CHANGING ct_data = lt_request ).
        WHEN 'EXCUTE'.
          excute( CHANGING ct_data = lt_request ).
        WHEN 'EXPORT'.
          APPEND LINES OF lt_request TO lt_export.
        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

      IF lv_event = 'EXPORT' AND i = lines( keys ).
        DATA(lv_recorduuid) = export( EXPORTING it_data = lt_export ).

        APPEND VALUE #( %cid   = key-%cid
                        %param = VALUE #( event = lv_event
                                          zzkey = lv_json
                                          recorduuid = lv_recorduuid ) ) TO result.
      ELSE.
        APPEND VALUE #( %cid   = key-%cid
                        %param = VALUE #( event = lv_event
                                          zzkey = lv_json ) ) TO result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD check.
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.

    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
    DATA(lv_plant) = zzcl_common_utils=>get_plant_by_user( lv_user_email ).

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CLEAR: <lfs_data>-status,<lfs_data>-message.
      CLEAR: lv_message.

      IF <lfs_data>-product IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-001 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-plant IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-002 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ELSEIF NOT lv_plant CS <lfs_data>-plant.
        MESSAGE e027(zbc_001) WITH <lfs_data>-plant INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-validitystartdate IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-003 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-billofoperationsusage IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-004 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-billofoperationsstatus IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-005 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-operation IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-006 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-workcenter IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-007 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-operationcontrolprofile IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-008 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF lv_message IS NOT INITIAL.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = lv_message.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD excute.
    TYPES:
*&--Material Assignment
      BEGIN OF lty_matlassgmt_line,
        product             TYPE i_prodnroutingmatlassgmttp_2-product,
        plant               TYPE i_prodnroutingmatlassgmttp_2-plant,
        validity_start_date TYPE string,
      END OF lty_matlassgmt_line,
      ltty_matlassgmt TYPE TABLE OF lty_matlassgmt_line WITH DEFAULT KEY,
*&--Operation
      BEGIN OF lty_operation,
        operation                     TYPE i_prodnroutingoperationtp_2-operation,
        work_center_internal_i_d      TYPE i_prodnroutingoperationtp_2-workcenterinternalid,
        operation_control_profile     TYPE i_prodnroutingoperationtp_2-operationcontrolprofile,
        operation_text                TYPE i_prodnroutingoperationtp_2-operationtext,
        operation_reference_quantity  TYPE string,
        operation_unit                TYPE i_prodnroutingoperationtp_2-operationunit,
        op_qty_to_base_qty_nmrtr      TYPE string,
        op_qty_to_base_qty_dnmntr     TYPE string,
        standard_work_quantity1       TYPE string,
        standard_work_quantity_unit1  TYPE i_prodnroutingoperationtp_2-standardworkquantityunit1,
        standard_work_quantity2       TYPE string,
        standard_work_quantity_unit2  TYPE i_prodnroutingoperationtp_2-standardworkquantityunit2,
        standard_work_quantity3       TYPE string,
        standard_work_quantity_unit3  TYPE i_prodnroutingoperationtp_2-standardworkquantityunit3,
        standard_work_quantity4       TYPE string,
        standard_work_quantity_unit4  TYPE i_prodnroutingoperationtp_2-standardworkquantityunit4,
        standard_work_quantity5       TYPE string,
        standard_work_quantity_unit5  TYPE i_prodnroutingoperationtp_2-standardworkquantityunit5,
        standard_work_quantity6       TYPE string,
        standard_work_quantity_unit6  TYPE i_prodnroutingoperationtp_2-standardworkquantityunit6,
        number_of_time_tickets        TYPE string,
        validity_start_date           TYPE string,
        operationcostingrelevancytype TYPE i_prodnroutingoperationtp_2-operationcostingrelevancytype,
      END OF lty_operation,
      ltty_operation TYPE TABLE OF lty_operation WITH DEFAULT KEY,
*&--Sequence
      BEGIN OF lty_sequence,
        sequence_category   TYPE i_prodnroutingsequencetp_2-sequencecategory,
        validity_start_date TYPE string,
        to_operation        TYPE ltty_operation,
      END OF lty_sequence,
      ltty_sequence TYPE TABLE OF lty_sequence WITH DEFAULT KEY,
*&--Header
      BEGIN OF lty_header,
        plant                     TYPE i_productionroutingheadertp_2-plant,
        bill_of_operations_desc   TYPE i_productionroutingheadertp_2-billofoperationsdesc,
        production_routing        TYPE i_productionroutingheadertp_2-productionrouting,
        bill_of_operations_usage  TYPE i_productionroutingheadertp_2-billofoperationsusage,
        bill_of_operations_status TYPE i_productionroutingheadertp_2-billofoperationsstatus,
        responsible_planner_group TYPE i_productionroutingheadertp_2-responsibleplannergroup,
        bill_of_operations_unit   TYPE i_productionroutingheadertp_2-billofoperationsunit,
        maximum_lot_size_quantity TYPE string,
        validity_start_date       TYPE string,
        to_matlassgmt             TYPE ltty_matlassgmt,
        to_sequence               TYPE ltty_sequence,
      END OF lty_header,
      ltty_header TYPE TABLE OF lty_header WITH DEFAULT KEY,
*&--Request Body
      BEGIN OF lty_request,
        production_routing_group TYPE i_productionroutingheadertp_2-productionroutinggroup,
        production_routing       TYPE i_productionroutingheadertp_2-productionrouting,
        to_header                TYPE ltty_header,
      END OF lty_request,
*&--Response
      BEGIN OF lty_response,
        d TYPE lty_request,
      END OF lty_response.

    DATA: ls_request        TYPE lty_request,
          ls_response       TYPE lty_response,
          ls_operation_line TYPE lty_operation,
          ls_sequence_line  TYPE lty_sequence,
          lt_update_table   TYPE TABLE OF ztpp_1006.

    DATA: i            TYPE i,
          lv_message   TYPE string,
          lv_timestamp TYPE tzntstmpl,
          ls_error     TYPE zzcl_odata_utils=>gty_error.

    check( CHANGING ct_data = ct_data ).
    IF line_exists( ct_data[ status = 'E' ] ).
      RETURN.
    ENDIF.

    SELECT workcenterinternalid,
           workcentertypecode,
           workcenter
      FROM i_workcenter WITH PRIVILEGED ACCESS
       FOR ALL ENTRIES IN @ct_data
     WHERE workcenter = @ct_data-workcenter
      INTO TABLE @DATA(lt_workcenter).
    SORT lt_workcenter BY workcenter.

    SELECT product,
           baseunit
      FROM i_product WITH PRIVILEGED ACCESS
       FOR ALL ENTRIES IN @ct_data
     WHERE product = @ct_data-product
      INTO TABLE @DATA(lt_product).
    SORT lt_product BY product.

    CLEAR: ls_request.
    LOOP AT ct_data INTO DATA(ls_data).
      i += 1.
      CLEAR ls_operation_line.

      READ TABLE lt_workcenter INTO DATA(ls_workcenter) WITH KEY workcenter = ls_data-workcenter BINARY SEARCH.
      READ TABLE lt_product INTO DATA(ls_product) WITH KEY product = ls_data-product BINARY SEARCH.
      IF sy-subrc = 0.
        TRY.
            DATA(lv_baseunit) = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = ls_product-baseunit ).
            ##NO_HANDLER
          CATCH zzcx_custom_exception.
            " handle exception
        ENDTRY.
      ENDIF.

      DATA(lv_datetime) = |{ ls_data-validitystartdate+0(4) }-{ ls_data-validitystartdate+4(2) }-{ ls_data-validitystartdate+6(2) }T00:00:00|.
      ls_operation_line = VALUE #( operation                     = ls_data-operation
                                   work_center_internal_i_d      = ls_workcenter-workcenterinternalid
                                   operation_control_profile     = ls_data-operationcontrolprofile
                                   operation_text                = ls_data-operationtext
                                   operation_reference_quantity  = '1'
                                   operation_unit                = lv_baseunit
                                   op_qty_to_base_qty_nmrtr      = '1'
                                   op_qty_to_base_qty_dnmntr     = '1'
                                   standard_work_quantity1       = ls_data-standardworkquantity1
                                   standard_work_quantity_unit1  = ls_data-standardworkquantityunit1
                                   standard_work_quantity2       = ls_data-standardworkquantity2
                                   standard_work_quantity_unit2  = ls_data-standardworkquantityunit2
                                   standard_work_quantity3       = ls_data-standardworkquantity3
                                   standard_work_quantity_unit3  = ls_data-standardworkquantityunit3
                                   standard_work_quantity4       = ls_data-standardworkquantity4
                                   standard_work_quantity_unit4  = ls_data-standardworkquantityunit4
                                   standard_work_quantity5       = ls_data-standardworkquantity5
                                   standard_work_quantity_unit5  = ls_data-standardworkquantityunit5
                                   standard_work_quantity6       = ls_data-standardworkquantity6
                                   standard_work_quantity_unit6  = ls_data-standardworkquantityunit6
                                   number_of_time_tickets        = ls_data-numberoftimetickets
                                   validity_start_date           = lv_datetime
                                   operationcostingrelevancytype = 'X' ).

      CONDENSE ls_operation_line-standard_work_quantity1 NO-GAPS.
      CONDENSE ls_operation_line-standard_work_quantity2 NO-GAPS.
      CONDENSE ls_operation_line-standard_work_quantity3 NO-GAPS.
      CONDENSE ls_operation_line-standard_work_quantity4 NO-GAPS.
      CONDENSE ls_operation_line-standard_work_quantity5 NO-GAPS.
      CONDENSE ls_operation_line-standard_work_quantity6 NO-GAPS.
      CONDENSE ls_operation_line-number_of_time_tickets  NO-GAPS.
      APPEND ls_operation_line TO ls_sequence_line-to_operation.

      IF i = lines( ct_data ).
        lv_datetime = |{ ls_data-validitystartdate+0(4) }-{ ls_data-validitystartdate+4(2) }-{ ls_data-validitystartdate+6(2) }T00:00:00|.
        ls_request-production_routing = ls_data-productionrouting.
        ls_request-to_header = VALUE #( ( plant                     = ls_data-plant
                                          bill_of_operations_desc   = ls_data-billofoperationsdesc
                                          production_routing        = ls_data-productionrouting
                                          bill_of_operations_usage  = ls_data-billofoperationsusage
                                          bill_of_operations_status = ls_data-billofoperationsstatus
                                          responsible_planner_group = ls_data-responsibleplannergroup
                                          bill_of_operations_unit   = lv_baseunit
                                          maximum_lot_size_quantity = '99999999'
                                          validity_start_date       = lv_datetime
                                          to_matlassgmt             = VALUE #( ( product             = ls_data-product
                                                                                 plant               = ls_data-plant
                                                                                 validity_start_date = lv_datetime ) )
                                          to_sequence               = VALUE #( ( sequence_category   = '0'
                                                                                 validity_start_date = lv_datetime
                                                                                 to_operation        = ls_sequence_line-to_operation ) ) ) ).
      ENDIF.
      CLEAR: ls_data,ls_workcenter.
    ENDLOOP.

    DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    REPLACE ALL OCCURRENCES OF `ToHeader`     IN lv_requestbody  WITH `to_Header`.
    REPLACE ALL OCCURRENCES OF `ToMatlassgmt` IN lv_requestbody  WITH `to_MatlAssgmt`.
    REPLACE ALL OCCURRENCES OF `ToSequence`   IN lv_requestbody  WITH `to_Sequence`.
    REPLACE ALL OCCURRENCES OF `ToOperation`  IN lv_requestbody  WITH `to_Operation`.
    REPLACE ALL OCCURRENCES OF `Results`      IN lv_requestbody  WITH `results`.
    REPLACE ALL OCCURRENCES OF `Operationcostingrelevancytype` IN lv_requestbody WITH `OperationCostingRelevancyType`.

    DATA(lv_path) = |/API_PRODUCTION_ROUTING;v=0002/ProductionRouting?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

    zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                 iv_method      = if_web_http_client=>post
                                                 iv_body        = lv_requestbody
                                       IMPORTING ev_status_code = DATA(lv_status_code)
                                                 ev_response    = DATA(lv_response) ).
    IF lv_status_code = 201.
      xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore )
        ( xco_cp_json=>transformation->boolean_to_abap_bool )
      ) )->write_to( REF #( ls_response ) ).

      " Routing登録成功しました。
      MESSAGE s080(zpp_001) WITH |{ TEXT-009 } { ls_response-d-production_routing_group }| INTO lv_message.
      ls_data-status = 'S'.
      ls_data-message = lv_message.
      MODIFY ct_data FROM ls_data TRANSPORTING status message WHERE row IS NOT INITIAL.
    ELSE.
      /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                 CHANGING  data = ls_error ).
      ls_data-status = 'E'.
      ls_data-message = ls_error-error-message-value.
      MODIFY ct_data FROM ls_data TRANSPORTING status message WHERE row IS NOT INITIAL.
    ENDIF.

    " set log
    lt_update_table = CORRESPONDING #( ct_data ).
    GET TIME STAMP FIELD lv_timestamp.
    LOOP AT lt_update_table ASSIGNING FIELD-SYMBOL(<lfs_update_table>).
      TRY.
          <lfs_update_table>-uuid = cl_system_uuid=>create_uuid_x16_static( ).
          ##NO_HANDLER
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.
      <lfs_update_table>-created_by = sy-uname.
      <lfs_update_table>-created_at = lv_timestamp.
      <lfs_update_table>-last_changed_by = sy-uname.
      <lfs_update_table>-last_changed_at = lv_timestamp.
      <lfs_update_table>-local_last_changed_at = lv_timestamp.
    ENDLOOP.
    MODIFY ztpp_1006 FROM TABLE @lt_update_table.
  ENDMETHOD.

  METHOD export.
    TYPES:BEGIN OF lty_export,
            status                    TYPE bapi_mtype,
            message                   TYPE zze_zzkey,
            product                   TYPE zr_routingupload-product,
            plant                     TYPE zr_routingupload-plant,
            validitystartdate         TYPE string,
            billofoperationsdesc      TYPE zr_routingupload-billofoperationsdesc,
            productionrouting         TYPE zr_routingupload-productionrouting,
            billofoperationsusage     TYPE zr_routingupload-billofoperationsusage,
            billofoperationsstatus    TYPE zr_routingupload-billofoperationsstatus,
            responsibleplannergroup   TYPE zr_routingupload-responsibleplannergroup,
            operation                 TYPE zr_routingupload-operation,
            workcenter                TYPE zr_routingupload-workcenter,
            operationcontrolprofile   TYPE zr_routingupload-operationcontrolprofile,
            operationtext             TYPE zr_routingupload-operationtext,
            standardworkquantity1     TYPE zr_routingupload-standardworkquantity1,
            standardworkquantityunit1 TYPE zr_routingupload-standardworkquantityunit1,
            standardworkquantity2     TYPE zr_routingupload-standardworkquantity2,
            standardworkquantityunit2 TYPE zr_routingupload-standardworkquantityunit2,
            standardworkquantity3     TYPE zr_routingupload-standardworkquantity3,
            standardworkquantityunit3 TYPE zr_routingupload-standardworkquantityunit3,
            standardworkquantity4     TYPE zr_routingupload-standardworkquantity4,
            standardworkquantityunit4 TYPE zr_routingupload-standardworkquantityunit4,
            standardworkquantity5     TYPE zr_routingupload-standardworkquantity5,
            standardworkquantityunit5 TYPE zr_routingupload-standardworkquantityunit5,
            standardworkquantity6     TYPE zr_routingupload-standardworkquantity6,
            standardworkquantityunit6 TYPE zr_routingupload-standardworkquantityunit6,
            numberoftimetickets       TYPE zr_routingupload-numberoftimetickets,
          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.

    LOOP AT it_data INTO DATA(ls_data).
      APPEND INITIAL LINE TO lt_export ASSIGNING FIELD-SYMBOL(<lfs_export>).
      <lfs_export> = CORRESPONDING #( ls_data ).
      <lfs_export>-validitystartdate = |{ <lfs_export>-validitystartdate+0(4) }/{ <lfs_export>-validitystartdate+4(2) }/{ <lfs_export>-validitystartdate+6(2) }|.
    ENDLOOP.

    SELECT SINGLE *
      FROM zzc_dtimp_conf
     WHERE object = 'ZDOWNLOAD_ROUTING'
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

      lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_export )
        )->execute( ).

      DATA(lv_file) = lo_write_access->get_file_content( ).

      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
          ##NO_HANDLER
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

      GET TIME STAMP FIELD DATA(lv_timestamp).

      INSERT INTO zzt_prt_record VALUES @( VALUE #( record_uuid     = lv_uuid
                                                    provided_keys   = |作業手順の一括登録_エクセル出力|
                                                    pdf_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    pdf_file_name   = |Routing_Export_{ lv_timestamp }.xlsx|
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
