CLASS lhc_bdglupload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_bdglupload.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR bdglupload RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION bdglupload~processlogic RESULT result.
    METHODS validationfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR bdglupload~validationfields.
    METHODS check  CHANGING ct_data TYPE lty_request_t.
    METHODS excute CHANGING ct_data TYPE lty_request_t.
    METHODS export IMPORTING it_data              TYPE lty_request_t
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.

ENDCLASS.

CLASS lhc_bdglupload IMPLEMENTATION.

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
    TYPES:BEGIN OF ty_gl.
    TYPES: glaccount TYPE hkont,
           END OF ty_gl.
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.
    DATA: ls_gl TYPE ty_gl.
    DATA: lt_gl TYPE STANDARD TABLE OF ty_gl.

    LOOP AT ct_data INTO DATA(ls_data_t).
      IF ls_data_t-glaccount IS NOT INITIAL.
        ls_gl-glaccount = |{ ls_data_t-glaccount ALPHA = IN }|.
        APPEND ls_gl TO lt_gl.
      ENDIF.
    ENDLOOP.

    SELECT a~glaccount,a~companycode,b~glaccountlongname "#EC CI_FAE_LINES_ENSURED
    FROM i_glaccount WITH PRIVILEGED ACCESS AS a
    JOIN i_glaccounttext WITH PRIVILEGED ACCESS AS b
    ON a~chartofaccounts = b~chartofaccounts
    AND a~glaccount = b~glaccount
    AND b~language = 'J'
    FOR ALL ENTRIES IN @lt_gl
    WHERE a~glaccount = @lt_gl-glaccount
    AND a~chartofaccounts = 'YCOA'
    INTO TABLE @DATA(lt_glaccount).
    SORT lt_glaccount BY glaccount companycode glaccountlongname.

    SELECT * FROM ztfi_1002 FOR ALL ENTRIES IN @lt_gl "#EC CI_FAE_LINES_ENSURED
    WHERE glaccount = @lt_gl-glaccount INTO TABLE @DATA(lt_ztfi_1002) . "#EC CI_ALL_FIELDS_NEEDED
    SORT lt_ztfi_1002 BY glaccount.

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CLEAR lv_message.

      IF <lfs_data>-glaccount IS INITIAL.
        MESSAGE s002(zfico_001) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.
      IF <lfs_data>-financialstatementitem IS INITIAL.
        MESSAGE s003(zfico_001) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.
      DATA(lv_gl) = |{ <lfs_data>-glaccount  ALPHA = IN }|.
      READ TABLE lt_glaccount INTO DATA(ls_glaccount) WITH KEY glaccount = lv_gl BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_data>-glaccountname = ls_glaccount-glaccountlongname.
        <lfs_data>-chartofaccounts = 'YCOA'.
      ELSE.
        MESSAGE s004(zfico_001) WITH <lfs_data>-glaccount INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.

      READ TABLE lt_ztfi_1002 TRANSPORTING NO FIELDS WITH KEY glaccount = lv_gl BINARY SEARCH.
      IF sy-subrc = 0.
        MESSAGE s034(zfico_001) WITH <lfs_data>-glaccount INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.


      IF lv_message IS NOT INITIAL.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = lv_message.
      ELSE.
        <lfs_data>-status = ''.
        <lfs_data>-message = lv_message.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD excute.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.
    TRY.
        DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
      CATCH cx_uuid_error INTO DATA(e) ##NO_HANDLER.
        "handle exception
    ENDTRY.
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_datas>) WHERE status = 'S'.
      MESSAGE s034(zfico_001) WITH <lfs_datas>-glaccount INTO lv_msg.
      lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      <lfs_datas>-status = 'E'.
      <lfs_datas>-message = lv_message.
    ENDLOOP.

    GET TIME STAMP FIELD lv_timestamp.
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>) WHERE status NE 'E' AND status NE 'S' AND chartofaccounts IS NOT INITIAL.

      MODIFY ztfi_1002 FROM @( VALUE #(
                                                  chartofaccounts      = <lfs_data>-chartofaccounts
                                                  glaccount            = |{ <lfs_data>-glaccount ALPHA = IN }|
                                                  financialstatement   = <lfs_data>-financialstatementitem
                                                  financialstatementitemtext   = <lfs_data>-financialstatementitemtext
                                                  created_by      = sy-uname
                                                  created_at      = lv_timestamp
                                                  last_changed_by = sy-uname
                                                  last_changed_at = lv_timestamp
                                                  local_last_changed_at = lv_timestamp ) ).
      IF sy-subrc = 0.
        INSERT INTO ztfi_1001 VALUES @( VALUE #(
                                            uuid                = lv_uuid
                                            chartofaccounts     = <lfs_data>-chartofaccounts
                                            glaccount           = |{ <lfs_data>-glaccount ALPHA = IN }|
                                            glaccountname        = <lfs_data>-glaccountname
                                            financialstatement   = <lfs_data>-financialstatementitem
                                            financialstatementitemtext   = <lfs_data>-financialstatementitemtext
                                            created_by      = sy-uname
                                            created_at      = lv_timestamp
                                            last_changed_by = sy-uname
                                            last_changed_at = lv_timestamp
                                            local_last_changed_at = lv_timestamp ) ).
        MESSAGE s006(zfico_001) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        <lfs_data>-status = 'S'.
        <lfs_data>-message = lv_message.
      ELSE.
        MESSAGE s005(zfico_001) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        <lfs_data>-status = 'E'.
        <lfs_data>-message = lv_message.
      ENDIF.
      CLEAR lv_message.
    ENDLOOP.

  ENDMETHOD.

  METHOD export.
    TYPES:BEGIN OF lty_export,
            glaccount                  TYPE zr_bdglupload-glaccount,
            financialstatementitem     TYPE zr_bdglupload-financialstatementitem,
            financialstatementitemtext TYPE zr_bdglupload-financialstatementitemtext,
            status                     TYPE zr_bdglupload-status,
            message                    TYPE zr_bdglupload-message,
          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.
    DATA lv_timestamp TYPE tzntstmpl.

    lt_export = CORRESPONDING #( it_data ).

    SELECT SINGLE *
      FROM zzc_dtimp_conf
     WHERE object = 'ZDOWNLOAD_BDGL'
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
        CATCH cx_uuid_error INTO DATA(e) ##NO_HANDLER.
          "handle exception
      ENDTRY.

      GET TIME STAMP FIELD lv_timestamp.

      INSERT INTO zzt_prt_record VALUES @( VALUE #( record_uuid     = lv_uuid
                                                    provided_keys   = |連結勘定とG/L勘定マッピング関係出力|
                                                    pdf_mime_type   = |application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                                                    pdf_file_name   = |Export.xlsx|
                                                    pdf_content     = lv_file
                                                    created_by      = sy-uname
                                                    created_at      = lv_timestamp
                                                    last_changed_by = sy-uname
                                                    last_changed_at = lv_timestamp
                                                    local_last_changed_at = lv_timestamp ) ).

      TRY.
          cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = lv_uuid
                                                   IMPORTING uuid_c36 = rv_recorduuid  ).
        CATCH cx_uuid_error INTO DATA(e1) ##NO_HANDLER.
          " handle exception
      ENDTRY.
    ENDIF.
  ENDMETHOD.
  METHOD validationfields.
    DATA: lv_message TYPE string.
    DATA: lv_regular_expression TYPE string VALUE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'.

    READ ENTITIES OF zr_bindglupload IN LOCAL MODE
    ENTITY bdglupload
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    " Example for a POSIX regular expression engine (More configuration options are available
    " as optional parameters of the method POSIX).
    DATA(lo_posix_engine) = xco_cp_regular_expression=>engine->posix(
      iv_ignore_case = abap_true
    ).
    SELECT glaccount                          "#EC CI_FAE_LINES_ENSURED
    FROM i_glaccount WITH PRIVILEGED ACCESS AS a
    FOR ALL ENTRIES IN @lt_result
    WHERE glaccount = @lt_result-glaccount
    AND chartofaccounts = 'YCOA'
    INTO TABLE @DATA(lt_glaccount).
    SORT lt_glaccount BY glaccount  .

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      IF <lfs_result>-chartofaccounts NE 'YCOA'.
        MESSAGE s035(zfico_001) INTO lv_message.
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-bdglupload.
        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %element-chartofaccounts = if_abap_behv=>mk-on
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_message ) )
                     TO reported-bdglupload.
      ENDIF.
      IF <lfs_result>-glaccount IS INITIAL.
        MESSAGE s002(zfico_001) INTO lv_message.
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-bdglupload.
        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %element-glaccount = if_abap_behv=>mk-on
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_message ) )
                     TO reported-bdglupload.
      ENDIF.
      IF <lfs_result>-financialstatement IS INITIAL.
        MESSAGE s003(zfico_001) INTO lv_message.
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-bdglupload.
        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %element-financialstatement = if_abap_behv=>mk-on
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_message ) )
                     TO reported-bdglupload.
      ENDIF.
      DATA(lv_gl) = |{ <lfs_result>-glaccount  ALPHA = IN }|.
      READ TABLE lt_glaccount INTO DATA(ls_glaccount) WITH KEY glaccount = lv_gl BINARY SEARCH.
      IF sy-subrc = 0.

      ELSE.
        MESSAGE s004(zfico_001) WITH <lfs_result>-glaccount INTO lv_message.
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-bdglupload.
        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %element-glaccount = if_abap_behv=>mk-on
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_message ) )
                     TO reported-bdglupload.
      ENDIF.


    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
