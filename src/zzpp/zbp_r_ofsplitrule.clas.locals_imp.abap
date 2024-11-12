CLASS lhc_splitrule DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_ofsplitrule.
    TYPES:  row     TYPE i,
            status  TYPE bapi_mtype,
            message TYPE zze_zzkey,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR splitrule RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION splitrule~processlogic RESULT result.

    METHODS check  CHANGING ct_data TYPE lty_request_t.
    METHODS excute CHANGING ct_data TYPE lty_request_t.
    METHODS export IMPORTING it_data              TYPE lty_request_t
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.
ENDCLASS.

CLASS lhc_splitrule IMPLEMENTATION.

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
    DATA: lv_customer TYPE kunnr,
          lv_message  TYPE string,
          lv_msg      TYPE string.

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CLEAR: <lfs_data>-status,<lfs_data>-message.
      CLEAR: lv_message.

      DATA(lv_product) = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_data>-splitmaterial ).
      lv_customer = |{ <lfs_data>-customer ALPHA = IN }|.

      IF <lfs_data>-customer IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-005 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ELSE.
        SELECT SINGLE *
          FROM i_customer WITH PRIVILEGED ACCESS
         WHERE customer = @lv_customer
          INTO @DATA(ls_customer).            "#EC CI_ALL_FIELDS_NEEDED
        IF sy-subrc <> 0.
          MESSAGE e084(zpp_001) WITH TEXT-005 <lfs_data>-customer INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        ENDIF.
      ENDIF.

      IF <lfs_data>-splitmaterial IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-001 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-plant IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-002 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF lv_message IS INITIAL.
        SELECT SINGLE product,
                     plant
         FROM i_productplantbasic
         WITH PRIVILEGED ACCESS
        WHERE product = @lv_product
          AND plant   = @<lfs_data>-plant
         INTO @DATA(ls_productplantbasic).
        IF sy-subrc <> 0.
          MESSAGE e030(zpp_001) WITH <lfs_data>-splitmaterial <lfs_data>-plant INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        ENDIF.
      ENDIF.

      IF <lfs_data>-splitunit IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-003 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ELSEIF <lfs_data>-splitunit <> 'M' AND <lfs_data>-splitunit <> 'J' AND
             <lfs_data>-splitunit <> 'W' AND <lfs_data>-splitunit <> 'D' .
        MESSAGE e029(zpp_001) WITH TEXT-003 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-shipunit IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-004 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ENDIF.

      IF <lfs_data>-validend IS INITIAL.
        MESSAGE e010(zpp_001) WITH TEXT-006 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
      ELSE.
        SELECT SINGLE *
          FROM zc_ofsplitrule
         WHERE customer      =  @lv_customer
           AND splitmaterial =  @lv_product
           AND plant         =  @<lfs_data>-plant
           AND splitunit     <> @<lfs_data>-splitunit
           AND validend      =  @<lfs_data>-validend
           AND deleteflag    <> @abap_true
          INTO @DATA(ls_ofsplitrule).         "#EC CI_ALL_FIELDS_NEEDED
        IF sy-subrc = 0.
          MESSAGE e083(zpp_001) INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '/' ).
        ENDIF.
      ENDIF.

      IF lv_message IS NOT INITIAL.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = lv_message.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD excute.
    DATA ls_pp1008 TYPE ztpp_1008.
    DATA lv_timestamp TYPE tzntstmpl.

    check( CHANGING ct_data = ct_data ).
    IF line_exists( ct_data[ status = 'E' ] ).
      RETURN.
    ENDIF.

    GET TIME STAMP FIELD lv_timestamp.

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CLEAR ls_pp1008.

      READ ENTITIES OF zr_ofsplitrule IN LOCAL MODE
      ENTITY splitrule
      ALL FIELDS WITH VALUE #( ( %key-customer      = |{ <lfs_data>-customer ALPHA = IN }|
                                 %key-splitmaterial = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_data>-splitmaterial )
                                 %key-plant         = <lfs_data>-plant
                                 %key-splitunit     = <lfs_data>-splitunit ) )
      RESULT FINAL(lt_result).

      ls_pp1008 = VALUE #( customer        = |{ <lfs_data>-customer ALPHA = IN }|
                           split_material  = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_data>-splitmaterial )
                           plant           = <lfs_data>-plant
                           split_unit      = <lfs_data>-splitunit
                           ship_unit       = <lfs_data>-shipunit
                           valid_end       = <lfs_data>-validend
                           delete_flag     = <lfs_data>-deleteflag
                           created_by      = sy-uname
                           created_at      = lv_timestamp
                           last_changed_by = sy-uname
                           last_changed_at = lv_timestamp
                           local_last_changed_at = lv_timestamp ).
      " for update
      IF lt_result IS NOT INITIAL.
        ls_pp1008-created_by = lt_result[ 1 ]-createdby.
        ls_pp1008-created_at = lt_result[ 1 ]-createdat.
      ENDIF.

      MODIFY ztpp_1008 FROM @ls_pp1008.
      IF sy-subrc = 0.
        <lfs_data>-status  = 'S'.
        MESSAGE s080(zpp_001) WITH space INTO <lfs_data>-message.
      ELSE.
        <lfs_data>-status = 'E'.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <lfs_data>-message WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD export.
    TYPES:BEGIN OF lty_export,
            status        TYPE bapi_mtype,
            message       TYPE zze_zzkey,
            customer      TYPE zr_ofsplitrule-customer,
            splitmaterial TYPE zr_ofsplitrule-splitmaterial,
            plant         TYPE zr_ofsplitrule-plant,
            shipunit      TYPE zr_ofsplitrule-shipunit,
            splitunit     TYPE zr_ofsplitrule-splitunit,
            validend      TYPE zr_ofsplitrule-validend,
            deleteflag    TYPE zr_ofsplitrule-deleteflag,
          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.

    lt_export = CORRESPONDING #( it_data ).

    SELECT SINGLE *
      FROM zzc_dtimp_conf
     WHERE object = 'ZDOWNLOAD_OFSPLITRULE'
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
                                                    provided_keys   = |OF分割ルールの一括登録_エクセル出力|
                                                    pdf_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    pdf_file_name   = |OF Split Rule_Export_{ lv_timestamp }.xlsx|
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
