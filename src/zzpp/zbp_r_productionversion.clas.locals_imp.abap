CLASS lhc_productionversion DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_productionversion.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING REQUEST requested_authorizations FOR productionversion RESULT result,
      processlogic FOR MODIFY
        IMPORTING keys FOR ACTION productionversion~processlogic RESULT result.

    METHODS check  CHANGING ct_data TYPE lty_request_t.
    METHODS excute CHANGING ct_data TYPE lty_request_t.
    METHODS export IMPORTING it_data              TYPE lty_request_t
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.
ENDCLASS.

CLASS lhc_productionversion IMPLEMENTATION.

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

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CLEAR: <lfs_data>-status,<lfs_data>-message.
      CLEAR: lv_message.

      IF <lfs_data>-material IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-001 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-plant IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-002 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-productionversion IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-003 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-productionversiontext IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-004 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-validitystartdate IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-005 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-validityenddate IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-006 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-billofmaterialvariantusage IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-007 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-billofmaterialvariant IS INITIAL.
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
*&--Request Body
      BEGIN OF lty_request,
        material                       TYPE i_productionversiontp-material,
        plant                          TYPE i_productionversiontp-plant,
        production_version             TYPE i_productionversiontp-productionversion,
        production_version_text        TYPE i_productionversiontp-productionversiontext,
        validity_start_date            TYPE i_productionversiontp-validitystartdate,
        validity_end_date              TYPE i_productionversiontp-validityenddate,
        bill_of_operations_type        TYPE i_productionversiontp-billofoperationstype,
        bill_of_operations_group       TYPE i_productionversiontp-billofoperationsgroup,
        bill_of_operations_variant     TYPE i_productionversiontp-billofoperationsvariant,
        bill_of_material_variant_usage TYPE i_productionversiontp-billofmaterialvariantusage,
        bill_of_material_variant       TYPE i_productionversiontp-billofmaterialvariant,
        production_line                TYPE i_productionversiontp-productionline,
        issuing_storage_location       TYPE i_productionversiontp-issuingstoragelocation,
        receiving_storage_location     TYPE i_productionversiontp-receivingstoragelocation,
      END OF lty_request.

    DATA: ls_request      TYPE lty_request,
          lt_update_table TYPE TABLE OF ztpp_1007.

    DATA: lv_message   TYPE string,
          lv_timestamp TYPE tzntstmpl,
          ls_error     TYPE zzcl_odata_utils=>gty_error.

    check( CHANGING ct_data = ct_data ).
    IF line_exists( ct_data[ status = 'E' ] ).
      RETURN.
    ENDIF.

    " Sub contract request, the internal table usually has only one entry
    LOOP AT ct_data INTO DATA(ls_data).
      CLEAR ls_request.
      DATA(lv_startdatetime) = |{ ls_data-validitystartdate+0(4) }-{ ls_data-validitystartdate+4(2) }-{ ls_data-validitystartdate+6(2) }T00:00:00|.
      DATA(lv_enddatetime) = |{ ls_data-validityenddate+0(4) }-{ ls_data-validityenddate+4(2) }-{ ls_data-validityenddate+6(2) }T00:00:00|.
      ls_request = VALUE #( material                       = ls_data-material
                            plant                          = ls_data-plant
                            production_version             = ls_data-productionversion
                            production_version_text        = ls_data-productionversiontext
                            validity_start_date            = ls_data-validitystartdate
                            validity_end_date              = ls_data-validityenddate
                            bill_of_operations_type        = ls_data-billofoperationstype
                            bill_of_operations_group       = ls_data-billofoperationsgroup
                            bill_of_operations_variant     = ls_data-billofoperationsvariant
                            bill_of_material_variant_usage = ls_data-billofmaterialvariantusage
                            bill_of_material_variant       = ls_data-billofmaterialvariant
                            production_line                = ls_data-productionline
                            issuing_storage_location       = ls_data-issuingstoragelocation
                            receiving_storage_location     = ls_data-receivingstoragelocation ).

      DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).

      DATA(lv_path) = |/api_production_version/srvd_a2x/sap/productionversion/0001/ProductionVersion?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

      zzcl_common_utils=>request_api_v4( EXPORTING iv_path        = lv_path
                                                   iv_method      = if_web_http_client=>post
                                                   iv_body        = lv_requestbody
                                         IMPORTING ev_status_code = DATA(lv_status_code)
                                                   ev_response    = DATA(lv_response) ).
      IF lv_status_code = 201.
        " 製造バージョン登録成功しました。
        MESSAGE s080(zpp_001) WITH |{ TEXT-003 } { ls_request-production_version }| INTO lv_message.
        ls_data-status = 'S'.
        ls_data-message = lv_message.
        MODIFY ct_data FROM ls_data TRANSPORTING status message WHERE row IS NOT INITIAL.

        " consistency check
        MODIFY ENTITIES OF i_productionversiontp PRIVILEGED
        ENTITY productionversion
        EXECUTE checkprodnversconstcy
        FROM VALUE #( ( %key-material = ls_request-material
                        %key-plant    = ls_request-plant
                        %key-productionversion = ls_request-production_version ) )
        FAILED DATA(failed)
        MAPPED DATA(mapped)
        REPORTED DATA(reported).
        IF failed IS INITIAL AND reported IS INITIAL
        OR ( ( reported IS NOT INITIAL AND reported-productionversion[ 1 ]-%msg->if_t100_message~t100key-msgid = 'PP ODATA API PRV' )
                                        OR reported-productionversion[ 1 ]-%msg->if_t100_message~t100key-msgno = '041'
                                        OR reported-productionversion[ 1 ]-%msg->if_t100_message~t100key-msgno = '042' ).
          " update check status
          MODIFY ENTITIES OF i_productionversiontp PRIVILEGED
          ENTITY productionversion
          UPDATE SET FIELDS WITH VALUE #( ( material = ls_request-material
                                            plant = ls_request-plant
                                            productionversion = ls_request-production_version
                                            productionversionstatus = COND #( WHEN ls_request-bill_of_operations_group IS NOT INITIAL
                                                                              THEN '1' )
                                            bomcheckstatus          = COND #( WHEN ls_request-bill_of_material_variant IS NOT INITIAL
                                                                              THEN '1' )
                                            productionversionlastcheckdate = cl_abap_context_info=>get_system_date( )
                                            %control = VALUE #( productionversionstatus = if_abap_behv=>mk-on
                                                                bomcheckstatus = if_abap_behv=>mk-on
                                                                productionversionlastcheckdate = if_abap_behv=>mk-on ) ) )
          MAPPED DATA(mapped2)
          FAILED DATA(failed2)
          REPORTED DATA(reported2).
        ENDIF.
      ELSE.
        /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                   CHANGING  data = ls_error ).
        ls_data-status = 'E'.
        IF ls_error-error-message-value IS NOT INITIAL.
          ls_data-message = ls_error-error-message-value.
        ELSEIF ls_error-error-code IS NOT INITIAL.
          SPLIT ls_error-error-code AT '/' INTO TABLE DATA(lt_msg).
          IF lines( lt_msg ) = 2.
            DATA(lv_msg_class) = lt_msg[ 1 ].
            DATA(lv_msg_number) = lt_msg[ 2 ].
            MESSAGE ID lv_msg_class TYPE 'S' NUMBER lv_msg_number INTO ls_data-message.
          ENDIF.
        ENDIF.
        MODIFY ct_data FROM ls_data TRANSPORTING status message WHERE row IS NOT INITIAL.
      ENDIF.
    ENDLOOP.

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
    MODIFY ztpp_1007 FROM TABLE @lt_update_table.
  ENDMETHOD.

  METHOD export.
    TYPES:BEGIN OF lty_export,
            status                     TYPE bapi_mtype,
            message                    TYPE zze_zzkey,
            material                   TYPE zr_productionversion-material,
            plant                      TYPE zr_productionversion-plant,
            productionversion          TYPE zr_productionversion-productionversion,
            productionversiontext      TYPE zr_productionversion-productionversiontext,
            validitystartdate          TYPE string,
            validityenddate            TYPE string,
            billofoperationstype       TYPE zr_productionversion-billofoperationstype,
            billofoperationsgroup      TYPE zr_productionversion-billofoperationsgroup,
            billofoperationsvariant    TYPE zr_productionversion-billofoperationsvariant,
            billofmaterialvariantusage TYPE zr_productionversion-billofmaterialvariantusage,
            billofmaterialvariant      TYPE zr_productionversion-billofmaterialvariant,
            productionline             TYPE zr_productionversion-productionline,
            issuingstoragelocation     TYPE zr_productionversion-issuingstoragelocation,
            receivingstoragelocation   TYPE zr_productionversion-receivingstoragelocation,
          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.

    LOOP AT it_data INTO DATA(ls_data).
      APPEND INITIAL LINE TO lt_export ASSIGNING FIELD-SYMBOL(<lfs_export>).
      <lfs_export> = CORRESPONDING #( ls_data ).
      <lfs_export>-validitystartdate = |{ <lfs_export>-validitystartdate+0(4) }/{ <lfs_export>-validitystartdate+4(2) }/{ <lfs_export>-validitystartdate+6(2) }|.
      <lfs_export>-validityenddate   = |{ <lfs_export>-validityenddate+0(4) }/{ <lfs_export>-validityenddate+4(2) }/{ <lfs_export>-validityenddate+6(2) }|.
    ENDLOOP.

    SELECT SINGLE *
      FROM zzc_dtimp_conf
     WHERE object = 'ZDOWNLOAD_PRODVERSION'
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
                                                    provided_keys   = |製造バージョンの一括登録_エクセル出力|
                                                    pdf_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    pdf_file_name   = |Production Version_Export_{ lv_timestamp }.xlsx|
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
