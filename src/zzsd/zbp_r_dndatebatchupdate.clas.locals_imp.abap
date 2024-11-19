CLASS lhc_deliverydocumentlist DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zc_dndatebatchupdate.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    "DN修改
    TYPES:
      BEGIN OF ty_update_header,
        _bill_of_lading TYPE string,
*        _actual_goods_movement_date TYPE string,
*        _Delivery_Document_By_Supplier          TYPE string,
      END OF ty_update_header,

      BEGIN OF ty_update_request,
        header_data TYPE ty_update_header,
      END OF ty_update_request.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR deliverydocumentlist RESULT result.

    METHODS batchprocess FOR MODIFY
      IMPORTING keys FOR ACTION deliverydocumentlist~batchprocess RESULT result.

    METHODS export IMPORTING it_data              TYPE lty_request_t
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.

    METHODS check CHANGING it_data              TYPE lty_request_t.

ENDCLASS.

CLASS lhc_deliverydocumentlist IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD batchprocess.

    DATA: ls_update_request TYPE ty_update_request.

    DATA:
      lt_records TYPE TABLE OF lty_request.

    DATA:
*      lt_records     TYPE TABLE OF zr_dndatebatchupdate,
      ls_record_temp LIKE LINE OF lt_records,
      ls_error_v2    TYPE zzcl_odata_utils=>gty_error,
      lv_extdate     TYPE c LENGTH 10,
      lv_intdate     TYPE c LENGTH 10,
      lv_timestampl  TYPE timestampl,
      lv_message     TYPE string.

    GET TIME STAMP FIELD lv_timestampl.

    DATA: i TYPE i.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = lt_records ).
    ENDLOOP.

    DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_records ).

    LOOP AT lt_records ASSIGNING FIELD-SYMBOL(<fs_record>).
      <fs_record>-deliverydocument = |{ <fs_record>-deliverydocument ALPHA = IN }|.
    ENDLOOP.

    CASE lv_event.
      WHEN 'export'.
        DATA(lv_recorduuid) = export( EXPORTING it_data = lt_records ).
        APPEND VALUE #( %cid   = key-%cid
                        %param = VALUE #( event = lv_event
                                          zzkey = lv_json
                                          recorduuid = lv_recorduuid ) ) TO result.
        RETURN.
      WHEN 'check'.

        check( CHANGING it_data = lt_records ).

        lv_json = /ui2/cl_json=>serialize( lt_records ).
        APPEND VALUE #( %cid    = key-%cid
                        %param  = VALUE #( zzkey = lv_json ) ) TO result.
      WHEN OTHERS.

        IF lt_records IS NOT INITIAL.
          SELECT deliverydocument,
                 billoflading,
                 actualgoodsmovementdate
            FROM i_deliverydocument WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_records
           WHERE deliverydocument = @lt_records-deliverydocument
            INTO TABLE @DATA(lt_deliverydocument).

          SORT lt_deliverydocument BY deliverydocument ASCENDING.

          SELECT a~deliverydocument,
                 a~goodsmovementtype,
                 materialdocument,
                 materialdocumentitem,
                 reversedmaterialdocument,
                 reversedmaterialdocumentitem,
                 goodsmovementiscancelled
            FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS a
            INNER JOIN i_deliverydocumentitem WITH PRIVILEGED ACCESS AS b ON a~deliverydocument = b~deliverydocument
             FOR ALL ENTRIES IN @lt_records
           WHERE a~deliverydocument = @lt_records-deliverydocument
             AND reversedmaterialdocument IS INITIAL
             AND goodsmovementiscancelled IS INITIAL
             AND a~goodsmovementtype = '101'
             AND b~goodsmovementtype = '687'
             AND debitcreditcode = 'S'
            INTO TABLE @DATA(lt_materialdocument).

          SORT lt_materialdocument BY deliverydocument ASCENDING.
        ENDIF.

        LOOP AT lt_records ASSIGNING <fs_record>.

          IF <fs_record>-intcoextactltransfofctrldtetme IS NOT INITIAL.
            lv_extdate = <fs_record>-intcoextactltransfofctrldtetme.
            CONDENSE lv_extdate NO-GAPS.
          ELSE.
            CLEAR lv_extdate.
          ENDIF.

          IF <fs_record>-intcointactltransfofctrldtetme IS NOT INITIAL.
            lv_intdate = <fs_record>-intcointactltransfofctrldtetme.
            CONDENSE lv_intdate NO-GAPS.
          ELSE.
            CLEAR lv_intdate.
          ENDIF.

          CONDENSE lv_intdate NO-GAPS.

*     出荷伝票チェック
          READ TABLE lt_deliverydocument INTO DATA(ls_dn)
            WITH KEY deliverydocument = <fs_record>-deliverydocument BINARY SEARCH.

          IF sy-subrc NE 0.
            <fs_record>-status = 'E'.
*       {出荷伝票}は存在しません。
            MESSAGE e016(zsd_001) WITH |{ <fs_record>-deliverydocument ALPHA = OUT }| INTO lv_message.
            <fs_record>-message = zzcl_common_utils=>merge_message(  iv_message1 = <fs_record>-message
                                                                          iv_message2 = lv_message
                                                                          iv_symbol = ';' ).
          ENDIF.

*     外部実績日付は実出庫移動日付より早い場合
          IF CONV datum( CONV string( <fs_record>-intcoextactltransfofctrldtetme ) ) < <fs_record>-actualgoodsmovementdate
          AND <fs_record>-intcoextactltransfofctrldtetme IS NOT INITIAL
          AND <fs_record>-intcoextactltransfofctrldtetme <> 1.  "1 => "NULL"
            <fs_record>-status = 'E'.
*       外部実績日付&1は実出庫移動日付より早い。ご確認ください。
            MESSAGE e017(zsd_001) WITH lv_extdate INTO lv_message.
            <fs_record>-message = zzcl_common_utils=>merge_message(  iv_message1 = <fs_record>-message
                                                                          iv_message2 = lv_message
                                                                          iv_symbol = ';' ).
          ENDIF.

*     内部実績日付は実出庫移動日付より早い場合
          IF CONV datum( CONV string( <fs_record>-intcointactltransfofctrldtetme ) ) < <fs_record>-actualgoodsmovementdate
          AND <fs_record>-intcointactltransfofctrldtetme IS NOT INITIAL
          AND <fs_record>-intcointactltransfofctrldtetme <> 1.  "1 => "NULL"
            <fs_record>-status = 'E'.
*       内部実績日付&1は実出庫移動日付より早い。ご確認ください。
            MESSAGE e018(zsd_001) WITH lv_intdate INTO lv_message.
            <fs_record>-message = zzcl_common_utils=>merge_message(  iv_message1 = <fs_record>-message
                                                                          iv_message2 = lv_message
                                                                          iv_symbol = ';' ).
          ENDIF.

*     内部実績日付は外部実績日付より早い場合、
          IF CONV datum( CONV string( <fs_record>-intcointactltransfofctrldtetme ) ) < CONV datum( CONV string( <fs_record>-intcoextactltransfofctrldtetme ) )
          AND <fs_record>-intcointactltransfofctrldtetme IS NOT INITIAL
          AND <fs_record>-intcointactltransfofctrldtetme <> 1.  "1 => "NULL"
            <fs_record>-status = 'E'.
*       内部実績日付&1は実出庫移動日付より早い。ご確認ください。
            MESSAGE e019(zsd_001) WITH lv_intdate INTO lv_message.
            <fs_record>-message = zzcl_common_utils=>merge_message(  iv_message1 = <fs_record>-message
                                                                          iv_message2 = lv_message
                                                                          iv_symbol = ';' ).
          ENDIF.

*         内部移転による在庫移動の会計伝票はすでに生成された場合、内部実績日付(IntcoIntActlTransfOfCtrlDteTme)　は更新できないように制御
          IF <fs_record>-intcointactltransfofctrldtetme IS NOT INITIAL.
            READ TABLE lt_materialdocument TRANSPORTING NO FIELDS
              WITH KEY deliverydocument = <fs_record>-deliverydocument BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_record>-status = 'E'.
*       {出荷伝票}は内部転記済みのため、実績日は更新できない。
              MESSAGE e021(zsd_001) WITH |{ <fs_record>-deliverydocument ALPHA = OUT }| INTO lv_message.
              <fs_record>-message = zzcl_common_utils=>merge_message(  iv_message1 = <fs_record>-message
                                                                            iv_message2 = lv_message
                                                                            iv_symbol = ';' ).
            ENDIF.
          ENDIF.

          IF <fs_record>-status IS NOT INITIAL.
            CONTINUE.
          ENDIF.

          "修改DN

          "保存一些无法通过API或者BOI修改的字段信息到自建表，后续通过再次调用修改API 通过增强实现
          "有些字段在创建时无法赋值，需要通过修改来实现，
          "其中【外部実績日付】【内部実績日付】无法直接需改，需要通过增强逻辑实现（和AcceptDate保持一致）
          DATA ls_sd1010 TYPE ztsd_1010.
          ls_sd1010-client = sy-mandt.
          ls_sd1010-deliverydocument = |{ <fs_record>-deliverydocument ALPHA = IN }|.
          ls_sd1010-shippingpoint = <fs_record>-shippingpoint.
          ls_sd1010-salesorganization = <fs_record>-salesorganization.
          ls_sd1010-salesoffice = <fs_record>-salesoffice.
          ls_sd1010-soldtoparty = <fs_record>-soldtoparty.
          ls_sd1010-shiptoparty = <fs_record>-shiptoparty.
          ls_sd1010-documentdate = <fs_record>-documentdate.
          ls_sd1010-deliverydate = <fs_record>-deliverydate.
          ls_sd1010-actualgoodsmovementdate = <fs_record>-actualgoodsmovementdate.
          ls_sd1010-overallgoodsmovementstatus = <fs_record>-overallgoodsmovementstatus.
          IF <fs_record>-intcoextplndtransfofctrldtetme IS NOT INITIAL.
            ls_sd1010-intcoextplndtransfofctrldtetme = <fs_record>-intcoextplndtransfofctrldtetme.
            CONDENSE ls_sd1010-intcoextplndtransfofctrldtetme NO-GAPS.
          ENDIF.
          IF <fs_record>-intcoextactltransfofctrldtetme IS NOT INITIAL.
            ls_sd1010-intcoextactltransfofctrldtetme = <fs_record>-intcoextactltransfofctrldtetme.
            CONDENSE ls_sd1010-intcoextactltransfofctrldtetme NO-GAPS.
          ENDIF.
          IF <fs_record>-intcointplndtransfofctrldtetme IS NOT INITIAL.
            ls_sd1010-intcointplndtransfofctrldtetme = <fs_record>-intcointplndtransfofctrldtetme.
            CONDENSE ls_sd1010-intcointplndtransfofctrldtetme NO-GAPS.
          ENDIF.
          IF <fs_record>-intcointactltransfofctrldtetme IS NOT INITIAL.
            ls_sd1010-intcointactltransfofctrldtetme = <fs_record>-intcointactltransfofctrldtetme.
            CONDENSE ls_sd1010-intcointactltransfofctrldtetme NO-GAPS.
          ENDIF.

          CLEAR ls_update_request.
          IF ls_dn-billoflading IS INITIAL.
            ls_update_request-header_data-_bill_of_lading = 'test'.
            ls_sd1010-billoflading = ls_dn-billoflading.
          ELSE.
            ls_update_request-header_data-_bill_of_lading = ' '.
            ls_sd1010-billoflading = ls_dn-billoflading.
          ENDIF.

          ls_sd1010-is_extension_used = abap_false.
          ls_sd1010-created_by = cl_abap_context_info=>get_user_technical_name( ).
          ls_sd1010-created_at = lv_timestampl.
          MODIFY ztsd_1010 FROM @ls_sd1010.
          CLEAR ls_sd1010.


*      ls_update_request-header_data-_Bill_Of_Lading = ls_dn-BillOfLading.
*      ls_update_request-header_data-_actual_goods_movement_date = |{ ls_dn-actualgoodsmovementdate+0(4) }-{ ls_dn-actualgoodsmovementdate+4(2) }-{ ls_dn-actualgoodsmovementdate+6(2) }T00:00:01|.

*      if lv_extdate is NOT INITIAL.
*        lv_extdate = |{ lv_extdate+0(4) }-{ lv_extdate+4(2) }-{ lv_extdate+6(2) }|.
*        ls_update_request-header_data-intcoextactltransfofctrldtetme = |{ lv_extdate }T00:00:00|.
*      ENDIF.
*
*      if lv_intdate is NOT INITIAL.
*        lv_intdate = |{ lv_intdate+0(4) }-{ lv_intdate+4(2) }-{ lv_intdate+6(2) }|.
*        ls_update_request-header_data-intcointactltransfofctrldtetme = |{ lv_intdate }T00:00:00|.
*      ENDIF.

          "将数据转换成json格式
*      DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_update_request )->apply( VALUE #(
*          ( xco_cp_json=>transformation->underscore_to_pascal_case )
*        ) )->to_string( ).

          DATA(lv_requestbody) = /ui2/cl_json=>serialize( data = ls_update_request
                                                          pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                                           ).

          REPLACE ALL OCCURRENCES OF 'headerData' IN lv_requestbody WITH 'd'.

          DATA(lv_path) = |/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader('{ <fs_record>-deliverydocument }')?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
          zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                       iv_method      = if_web_http_client=>patch
                                                       iv_body        = lv_requestbody
                                             IMPORTING ev_status_code = DATA(lv_status_code)
                                                       ev_response    = DATA(lv_response) ).
          IF lv_status_code = 204.
            UPDATE ztsd_1010 SET is_extension_used = @abap_true
              WHERE deliverydocument = @<fs_record>-deliverydocument.

            "DN更新成功しました。
            MESSAGE s020(zsd_001) WITH |{ <fs_record>-deliverydocument ALPHA = OUT }| INTO lv_message.
            <fs_record>-status = 'S'.
            <fs_record>-message = lv_message.
          ELSE.
            xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
              ( xco_cp_json=>transformation->pascal_case_to_underscore )
            ) )->write_to( REF #( ls_error_v2 ) ).

            <fs_record>-status = 'E'.
            <fs_record>-message = zzcl_common_utils=>merge_message( iv_message1 = <fs_record>-message
                                                                         iv_message2 = ls_error_v2-error-message-value
                                                                         iv_symbol   = ';' ).
          ENDIF.
        ENDLOOP.

        lv_json = /ui2/cl_json=>serialize( lt_records ).
        APPEND VALUE #( %cid    = key-%cid
                        %param  = VALUE #( zzkey = lv_json ) ) TO result.
    ENDCASE.
  ENDMETHOD.

  METHOD check.

    IF it_data IS NOT INITIAL.
      SELECT deliverydocument,
             intcoextplndtransfofctrldtetme,    "外部转记计划日
             intcoextactltransfofctrldtetme,    "外部转记实际日
             intcointplndtransfofctrldtetme,    "内部转记计划日
             intcointactltransfofctrldtetme     "内部转记实际日
        FROM i_deliverydocument WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @it_data
       WHERE deliverydocument = @it_data-deliverydocument
        INTO TABLE @DATA(lt_deliverydocument).

      SORT lt_deliverydocument BY deliverydocument ASCENDING.
    ENDIF.

    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<fs_l_data>).
      READ TABLE lt_deliverydocument INTO DATA(ls_deliverydocument) WITH KEY deliverydocument = <fs_l_data>-deliverydocument BINARY SEARCH.
      IF sy-subrc = 0.
*       外部转记实际日のチェック
        IF ls_deliverydocument-intcoextplndtransfofctrldtetme IS INITIAL
        AND <fs_l_data>-intcoextactltransfofctrldtetme <> 1.    "1 =>"NULL"
          CLEAR <fs_l_data>-intcoextactltransfofctrldtetme.
        ENDIF.
*       内部转记实际日のチェック
        IF ls_deliverydocument-intcointplndtransfofctrldtetme IS INITIAL
        AND <fs_l_data>-intcointactltransfofctrldtetme <> 1.    "1 =>"NULL"
          CLEAR <fs_l_data>-intcointactltransfofctrldtetme.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD export.
    TYPES:BEGIN OF lty_export,
            deliverydocument               TYPE char10,
            shippingpoint                  TYPE char4,
            salesorganization              TYPE char4,
            salesoffice                    TYPE char4,
            soldtoparty                    TYPE char10,
            shiptoparty                    TYPE char10,
            documentdate                   TYPE char8,
            deliverydate                   TYPE char8,
            actualgoodsmovementdate        TYPE char8,
            overallgoodsmovementstatus     TYPE char1,
            intcoextplndtransfofctrldtetme TYPE char24,
            intcoextactltransfofctrldtetme TYPE char24,
            intcointplndtransfofctrldtetme TYPE char24,
            intcointactltransfofctrldtetme TYPE char24,
            yy1_salesdoctype_dlh           TYPE char8,
          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.

    LOOP AT it_data INTO DATA(ls_data).
      APPEND INITIAL LINE TO lt_export ASSIGNING FIELD-SYMBOL(<fs_l_export>).
      <fs_l_export> = CORRESPONDING #( ls_data ).
      CONDENSE:
        <fs_l_export>-documentdate,
        <fs_l_export>-deliverydate,
        <fs_l_export>-actualgoodsmovementdate,
        <fs_l_export>-intcoextplndtransfofctrldtetme,
        <fs_l_export>-intcoextactltransfofctrldtetme,
        <fs_l_export>-intcointplndtransfofctrldtetme,
        <fs_l_export>-intcointactltransfofctrldtetme.

*     伝票日付
      IF ls_data-documentdate IS INITIAL.
        CLEAR <fs_l_export>-documentdate.
      ELSE.
        <fs_l_export>-documentdate = <fs_l_export>-documentdate+0(8).
      ENDIF.

*     納入日付
      IF ls_data-deliverydate IS INITIAL.
        CLEAR <fs_l_export>-deliverydate.
      ELSE.
        <fs_l_export>-deliverydate = <fs_l_export>-deliverydate+0(8).
      ENDIF.

*     実出庫移動日付
      IF ls_data-actualgoodsmovementdate IS INITIAL.
        CLEAR <fs_l_export>-actualgoodsmovementdate.
      ELSE.
        <fs_l_export>-actualgoodsmovementdate = <fs_l_export>-actualgoodsmovementdate+0(8).
      ENDIF.

*     外部計画日付
      IF ls_data-intcoextplndtransfofctrldtetme IS INITIAL.
        CLEAR <fs_l_export>-intcoextplndtransfofctrldtetme.
      ELSE.
        <fs_l_export>-intcoextplndtransfofctrldtetme = <fs_l_export>-intcoextplndtransfofctrldtetme+0(8).
      ENDIF.

*     外部実績日付
      IF ls_data-intcoextactltransfofctrldtetme IS INITIAL.
        CLEAR <fs_l_export>-intcoextactltransfofctrldtetme.
      ELSE.
        <fs_l_export>-intcoextactltransfofctrldtetme = <fs_l_export>-intcoextactltransfofctrldtetme+0(8).
      ENDIF.

*     内部計画日付
      IF ls_data-intcointplndtransfofctrldtetme IS INITIAL.
        CLEAR <fs_l_export>-intcointplndtransfofctrldtetme.
      ELSE.
        <fs_l_export>-intcointplndtransfofctrldtetme = <fs_l_export>-intcointplndtransfofctrldtetme+0(8).
      ENDIF.

*     内部実績日付
      IF ls_data-intcointactltransfofctrldtetme IS INITIAL.
        CLEAR <fs_l_export>-intcointactltransfofctrldtetme.
      ELSE.
        <fs_l_export>-intcointactltransfofctrldtetme = <fs_l_export>-intcointactltransfofctrldtetme+0(8).
      ENDIF.

*      <fs_l_export>-documentdate = |{ <fs_l_export>-documentdate+0(4) }/{ <fs_l_export>-documentdate+4(2) }/{ <fs_l_export>-documentdate+6(2) }|.
*      <fs_l_export>-postingdate   = |{ <fs_l_export>-postingdate+0(4) }/{ <fs_l_export>-postingdate+4(2) }/{ <fs_l_export>-postingdate+6(2) }|.
    ENDLOOP.

    SELECT SINGLE *
      FROM zzc_dtimp_conf WITH PRIVILEGED ACCESS
     WHERE object = 'ZDOWNLOAD_DNDATEUPDATE'
      INTO @DATA(ls_file_conf).
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
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

      GET TIME STAMP FIELD DATA(lv_timestamp).



      INSERT INTO zzt_prt_record VALUES @( VALUE #( record_uuid     = lv_uuid
                                                    provided_keys   = |出荷伝票外部移転の日付一括更新_エクセル出力|
                                                    pdf_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    pdf_file_name   = |出荷伝票外部移転の日付一括更新_{ lv_timestamp }.xlsx|
                                                    pdf_content     = lv_file
                                                    created_by      = sy-uname
                                                    created_at      = lv_timestamp
                                                    last_changed_by = sy-uname
                                                    last_changed_at = lv_timestamp
                                                    local_last_changed_at = lv_timestamp ) ).

      TRY.
          cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = lv_uuid
                                                   IMPORTING uuid_c36 = rv_recorduuid  ).
        CATCH cx_uuid_error.
          " handle exception
      ENDTRY.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_dndatebatchupdate DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_dndatebatchupdate IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
