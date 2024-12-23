CLASS lhc_zr_orderforecast DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_orderforecast.
    TYPES:  row               TYPE i,
            status            TYPE bapi_mtype,
            message           TYPE zze_zzkey,
            requirementqtystr TYPE string,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    CONSTANTS: lc_config_id TYPE ztbc_1001-zid VALUE `ZPP013`.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_orderforecast RESULT result.
    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION zr_orderforecast~processlogic RESULT result.

    METHODS check  CHANGING ct_data TYPE lty_request_t.
    METHODS excute CHANGING ct_data TYPE lty_request_t.
    METHODS export IMPORTING it_data              TYPE lty_request_t
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.

ENDCLASS.

CLASS lhc_zr_orderforecast IMPLEMENTATION.

  METHOD get_instance_authorizations.
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
    DATA: lv_customer TYPE kunnr,
          lv_salesorg TYPE i_customermaterial_2-salesorganization,
          lv_message  TYPE string,
          lv_msg      TYPE string,
          n           TYPE i.

    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
    DATA(lv_plant) = zzcl_common_utils=>get_plant_by_user( lv_user_email ).

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      n += 1.
      CLEAR: <lfs_data>-status,<lfs_data>-message.
      CLEAR: lv_message.

      IF NOT lv_plant CS <lfs_data>-plant.
        MESSAGE e027(zbc_001) WITH <lfs_data>-plant INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF n = 1.
        SELECT SINGLE zvalue2
          FROM zc_tbc1001
         WHERE zid     = @lc_config_id
           AND zvalue1 = @<lfs_data>-plant
          INTO @lv_salesorg.

        lv_customer = |{ <lfs_data>-customer ALPHA = IN }|.
        SELECT SINGLE *
          FROM i_customer WITH PRIVILEGED ACCESS
         WHERE customer = @lv_customer
          INTO @DATA(ls_customer).

        SELECT SINGLE *
          FROM i_plant WITH PRIVILEGED ACCESS
         WHERE plant = @<lfs_data>-plant
          INTO @DATA(ls_plant).
      ENDIF.

      IF <lfs_data>-customer IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-001 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ELSE.
        IF ls_customer IS INITIAL.
          MESSAGE e084(zpp_001) WITH TEXT-001 <lfs_data>-customer INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        ENDIF.
      ENDIF.

      IF <lfs_data>-materialbycustomer IS INITIAL AND <lfs_data>-material IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-007 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ELSEIF <lfs_data>-materialbycustomer IS NOT INITIAL.
        SELECT SINGLE product
          FROM i_customermaterial_2 WITH PRIVILEGED ACCESS
         WHERE customer = @lv_customer
           AND materialbycustomer = @<lfs_data>-materialbycustomer
          INTO @DATA(lv_product).
        IF sy-subrc <> 0.
          IF <lfs_data>-material IS INITIAL.
            MESSAGE e085(zpp_001) WITH TEXT-002 INTO lv_msg.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ELSE.
            lv_product = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_data>-material ).
          ENDIF.
        ENDIF.
        IF lv_product IS NOT INITIAL.
          SELECT SINGLE product,
                        plant,
                        baseunit
            FROM i_productplantbasic WITH PRIVILEGED ACCESS
           WHERE product = @lv_product
             AND plant   = @<lfs_data>-plant
            INTO @DATA(ls_productplantbasic).
          IF sy-subrc <> 0.
            MESSAGE e085(zpp_001) WITH TEXT-002 INTO lv_msg.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
          ELSE.
            <lfs_data>-material = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = lv_product ).
            <lfs_data>-unitofmeasure = ls_productplantbasic-baseunit.
          ENDIF.
        ENDIF.
      ELSEIF <lfs_data>-material IS NOT INITIAL.
        lv_product = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_data>-material ).
        SELECT SINGLE product,
                      plant,
                      baseunit
          FROM i_productplantbasic WITH PRIVILEGED ACCESS
         WHERE product = @lv_product
           AND plant   = @<lfs_data>-plant
          INTO @ls_productplantbasic.
        IF sy-subrc <> 0.
          MESSAGE e085(zpp_001) WITH TEXT-003 INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        ELSE.
          <lfs_data>-unitofmeasure = ls_productplantbasic-baseunit.
        ENDIF.
      ENDIF.

      IF <lfs_data>-plant IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-004 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ELSE.
        IF ls_plant IS INITIAL.
          MESSAGE e084(zpp_001) WITH TEXT-004 <lfs_data>-plant INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        ENDIF.
      ENDIF.

      IF <lfs_data>-requirementdate IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-005 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ELSE.
        DATA(lv_workingday) = zzcl_common_utils=>get_workingday( iv_date  = <lfs_data>-requirementdate
                                                                 iv_next  = abap_false
                                                                 iv_plant = <lfs_data>-plant ).
        IF lv_workingday = '12340506'. " 用于标识，超过工厂日历范围
          MESSAGE e112(zpp_001) INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        ELSE.
          <lfs_data>-requirementdate = lv_workingday.
        ENDIF.
      ENDIF.

      IF <lfs_data>-requirementqtystr IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-006 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF lv_message IS NOT INITIAL.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = lv_message.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD excute.
    TYPES:BEGIN OF lty_pir_item,
            product                 TYPE i_plndindeprqmtitemtp-product,
            plant                   TYPE i_plndindeprqmtitemtp-plant,
            plnd_indep_rqmt_version TYPE i_plndindeprqmtitemtp-plndindeprqmtversion,
            requirement_plan        TYPE i_plndindeprqmtitemtp-requirementplan,
            plnd_indep_rqmt_period  TYPE i_plndindeprqmtitemtp-plndindeprqmtperiod,
            period_type             TYPE i_plndindeprqmtitemtp-periodtype,
            working_day_date        TYPE string,
            planned_quantity        TYPE string,
          END OF lty_pir_item,
          BEGIN OF lty_pir_header,
            product                   TYPE i_plndindeprqmttp-product,
            plant                     TYPE i_plndindeprqmttp-plant,
            plnd_indep_rqmt_version   TYPE i_plndindeprqmttp-plndindeprqmtversion,
            requirement_plan          TYPE i_plndindeprqmttp-requirementplan,
            plnd_indep_rqmt_is_active TYPE i_plndindeprqmttp-plndindeprqmtisactive,
            to_plnd_indep_rqmt_item   TYPE TABLE OF lty_pir_item WITH DEFAULT KEY,
          END OF lty_pir_header.

    DATA: ls_pir_item TYPE lty_pir_item,
          ls_request  TYPE lty_pir_header,
          ls_error    TYPE zzcl_odata_utils=>gty_error,
          ls_pp1012   TYPE ztpp_1012.

    DATA: lv_timestamp    TYPE tzntstmpl,
          lv_sum_quantity TYPE ztpp_1012-requirement_qty,
          lv_remark       TYPE ztpp_1012-remark.

    check( CHANGING ct_data = ct_data ).
    IF line_exists( ct_data[ status = 'E' ] ).
      RETURN.
    ENDIF.

    CLEAR ls_request.
    LOOP AT ct_data INTO DATA(ls_data).
      CLEAR ls_pir_item.

      IF sy-tabix = 1.
        ls_request = VALUE #( product                   = ls_data-material
                              plant                     = ls_data-plant
                              plnd_indep_rqmt_version   = '01'
                              requirement_plan          = ls_data-customer
                              plnd_indep_rqmt_is_active = '' ).
      ENDIF.

      DATA(lv_datetime) = |{ ls_data-requirementdate+0(4) }-{ ls_data-requirementdate+4(2) }-{ ls_data-requirementdate+6(2) }T00:00:00|.
      READ TABLE ls_request-to_plnd_indep_rqmt_item ASSIGNING FIELD-SYMBOL(<lfs_item>)
                                                    WITH KEY working_day_date = lv_datetime.
      IF sy-subrc = 0.
        <lfs_item>-planned_quantity += ls_data-requirementqty.
        CONDENSE <lfs_item>-planned_quantity NO-GAPS.
      ELSE.
        ls_pir_item = VALUE #( product                 = ls_data-material
                               plant                   = ls_data-plant
                               plnd_indep_rqmt_version = '01'
                               requirement_plan        = ls_data-customer
                               plnd_indep_rqmt_period  = ls_data-requirementdate
                               period_type             = 'D'
                               working_day_date        = lv_datetime
                               planned_quantity        = ls_data-requirementqty ).
        CONDENSE ls_pir_item-planned_quantity NO-GAPS.
        APPEND ls_pir_item TO ls_request-to_plnd_indep_rqmt_item.
      ENDIF.
    ENDLOOP.

    SELECT *
      FROM i_plndindeprqmtitemtp WITH PRIVILEGED ACCESS
     WHERE product = @ls_data-material
       AND plant = @ls_data-plant
       AND plndindeprqmtversion = '01'
       AND requirementplan = @ls_data-customer
      INTO TABLE @DATA(lt_exists_data).
    IF sy-subrc = 0.
      LOOP AT lt_exists_data INTO DATA(ls_exists_data).
        READ TABLE ls_request-to_plnd_indep_rqmt_item TRANSPORTING NO FIELDS
                                                      WITH KEY plnd_indep_rqmt_period = ls_exists_data-plndindeprqmtperiod.
        IF sy-subrc <> 0.
          CLEAR ls_pir_item.
          lv_datetime = |{ ls_exists_data-workingdaydate+0(4) }-{ ls_exists_data-workingdaydate+4(2) }-{ ls_exists_data-workingdaydate+6(2) }T00:00:00|.
          ls_pir_item = VALUE #( product                 = ls_exists_data-product
                                 plant                   = ls_exists_data-plant
                                 plnd_indep_rqmt_version = ls_exists_data-plndindeprqmtversion
                                 requirement_plan        = ls_exists_data-requirementplan
                                 plnd_indep_rqmt_period  = ls_exists_data-plndindeprqmtperiod
                                 period_type             = ls_exists_data-periodtype
                                 working_day_date        = lv_datetime
                                 planned_quantity        = '0' ).
          CONDENSE ls_pir_item-planned_quantity NO-GAPS.
          APPEND ls_pir_item TO ls_request-to_plnd_indep_rqmt_item.
        ENDIF.
      ENDLOOP.
    ENDIF.

    DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    REPLACE ALL OCCURRENCES OF `ToPlndIndepRqmtItem` IN lv_requestbody  WITH `to_PlndIndepRqmtItem`.

    DATA(lv_path) = |/API_PLND_INDEP_RQMT_SRV/PlannedIndepRqmt?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

    zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                 iv_method      = if_web_http_client=>post
                                                 iv_body        = lv_requestbody
                                       IMPORTING ev_status_code = DATA(lv_status_code)
                                                 ev_response    = DATA(lv_response) ).
    IF lv_status_code = 201.
      " OF登録成功しました。
      MESSAGE s080(zpp_001) WITH TEXT-008 INTO DATA(lv_message).
      ls_data-status = 'S'.
      ls_data-message = lv_message.
      MODIFY ct_data FROM ls_data TRANSPORTING status message WHERE row IS NOT INITIAL.
    ELSE.
      /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                 CHANGING  data = ls_error ).
      ls_data-status = 'E'.
      ls_data-message = ls_error-error-message-value.
      REPLACE ALL OCCURRENCES OF `&` IN ls_data-message WITH ``.
      MODIFY ct_data FROM ls_data TRANSPORTING status message WHERE row IS NOT INITIAL.
    ENDIF.

    IF line_exists( ct_data[ status = 'E' ] ).
      RETURN.
    ENDIF.

    GET TIME STAMP FIELD lv_timestamp.
*    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
*      CLEAR ls_pp1012.
*      TRY.
*          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
*          ##NO_HANDLER
*        CATCH cx_uuid_error.
*          "handle exception
*      ENDTRY.
*      ls_pp1012 = VALUE #( uuid                  = lv_uuid
*                           customer              = |{ <lfs_data>-customer ALPHA = IN }|
*                           material              = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_data>-material )
*                           plant                 = <lfs_data>-plant
*                           material_by_customer  = <lfs_data>-materialbycustomer
*                           requirement_date      = <lfs_data>-requirementdate
*                           requirement_qty       = <lfs_data>-requirementqty
*                           unit_of_measure       = <lfs_data>-unitofmeasure
*                           remark                = <lfs_data>-remark
*                           created_by            = sy-uname
*                           created_at            = lv_timestamp
*                           last_changed_by       = sy-uname
*                           last_changed_at       = lv_timestamp
*                           local_last_changed_at = lv_timestamp ).
*
*      MODIFY ztpp_1012 FROM @ls_pp1012.
*      IF sy-subrc <> 0.
*        <lfs_data>-status = 'E'.
*        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <lfs_data>-message WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*    ENDLOOP.
    LOOP AT ct_data INTO DATA(ls_group) GROUP BY ( customer           = ls_group-customer
                                                   material           = ls_group-material
                                                   plant              = ls_group-plant
                                                   materialbycustomer = ls_group-materialbycustomer
                                                   requirementdate    = ls_group-requirementdate
                                                   unitofmeasure      = ls_group-unitofmeasure )
                                        ASSIGNING FIELD-SYMBOL(<lfs_group>).
      CLEAR: lv_sum_quantity, lv_remark.

      LOOP AT GROUP <lfs_group> ASSIGNING FIELD-SYMBOL(<lfs_group_item>).
        lv_sum_quantity += <lfs_group_item>-requirementqty.
        lv_remark = <lfs_group_item>-remark.
      ENDLOOP.

      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
          ##NO_HANDLER
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

      CLEAR ls_pp1012.
      ls_pp1012 = VALUE #( uuid                  = lv_uuid
                           customer              = |{ <lfs_group>-customer ALPHA = IN }|
                           material              = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_group>-material )
                           plant                 = <lfs_group>-plant
                           material_by_customer  = <lfs_group>-materialbycustomer
                           requirement_date      = <lfs_group>-requirementdate
                           requirement_qty       = lv_sum_quantity
                           unit_of_measure       = <lfs_group>-unitofmeasure
                           remark                = lv_remark
                           created_by            = sy-uname
                           created_at            = lv_timestamp
                           last_changed_by       = sy-uname
                           last_changed_at       = lv_timestamp
                           local_last_changed_at = lv_timestamp ).
      MODIFY ztpp_1012 FROM @ls_pp1012.
      IF sy-subrc <> 0.
        LOOP AT GROUP <lfs_group> ASSIGNING <lfs_group_item>.
          <lfs_group_item>-status = 'E'.
          MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <lfs_group_item>-message WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD export.
    TYPES:BEGIN OF lty_export,
            status             TYPE bapi_mtype,
            message            TYPE zze_zzkey,
            customer           TYPE zr_orderforecast-customer,
            materialbycustomer TYPE zr_orderforecast-materialbycustomer,
            material           TYPE zr_orderforecast-material,
            plant              TYPE zr_orderforecast-plant,
            requirementdate    TYPE zr_orderforecast-requirementdate,
            requirementqty     TYPE zr_orderforecast-requirementqty,
            remark             TYPE zr_orderforecast-remark,
          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.

    lt_export = CORRESPONDING #( it_data ).

    SELECT SINGLE *
      FROM zzc_dtimp_conf
     WHERE object = 'ZDOWNLOAD_OF'
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
                                                    provided_keys   = |OFデータの一括登録_エクセル出力|
                                                    pdf_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    pdf_file_name   = |Order Forecast_Export_{ lv_timestamp }.xlsx|
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
