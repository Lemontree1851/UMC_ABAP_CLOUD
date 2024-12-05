CLASS lhc_inageupload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_inageupload.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.
    TYPES:BEGIN OF lty_request1.
    TYPES:  age      TYPE string.
    TYPES:  qty      TYPE string.
    TYPES:  calendaryear         TYPE string.
    TYPES:  calendarmonth         TYPE string.
    TYPES: row TYPE i,
           END OF lty_request1,
           lty_request_t1 TYPE TABLE OF lty_request1.
    CONSTANTS: lc_mode_insert TYPE string VALUE `I`,
               lc_mode_update TYPE string VALUE `U`,
               lc_mode_in     TYPE string VALUE `IN`,
               lc_mode_out    TYPE string VALUE `OUT`.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR inageupload RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION inageupload~processlogic RESULT result.

    METHODS check  IMPORTING ct_data1 TYPE lty_request_t1
                   CHANGING  ct_data  TYPE lty_request_t
                             cs_error TYPE c.
    METHODS excute CHANGING ct_data TYPE lty_request_t.
    METHODS export IMPORTING it_data              TYPE lty_request_t
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.

ENDCLASS.

CLASS lhc_inageupload IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD processlogic.
    DATA: lt_request TYPE TABLE OF lty_request,
          lt_export  TYPE TABLE OF lty_request.
    DATA: lt_request1 TYPE TABLE OF lty_request1.
    DATA: lv_error TYPE c.
    DATA: lv_execute TYPE c.


    DATA: i TYPE i.

    CLEAR: lv_error,lv_execute.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_request.
      i += 1.

      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request1 ).
      CASE lv_event.
        WHEN 'CHECK'.
          check( EXPORTING ct_data1 = lt_request1 CHANGING ct_data = lt_request cs_error = lv_error ).
        WHEN 'EXCUTE'.
          check( EXPORTING ct_data1 = lt_request1 CHANGING ct_data = lt_request cs_error = lv_error ).
          lv_execute = 'X'.
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
      ELSEIF lv_event = 'EXCUTE'.
      ELSE.
        APPEND VALUE #( %cid   = key-%cid
                        %param = VALUE #( event = lv_event
                                          zzkey = lv_json ) ) TO result.
      ENDIF.

    ENDLOOP.
    IF lv_execute = 'X' .
      LOOP AT keys INTO key.
        CLEAR lt_request.
        i += 1.

        /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                   CHANGING  data = lt_request ).
        /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                   CHANGING  data = lt_request1 ).
        CASE lv_event.
          WHEN 'EXCUTE'.
            check( EXPORTING ct_data1 = lt_request1 CHANGING ct_data = lt_request cs_error = lv_error ).
            IF lv_error = ''.
              excute( CHANGING ct_data = lt_request ).
            ENDIF.
          WHEN OTHERS.
        ENDCASE.

        DATA(lv_json1) = /ui2/cl_json=>serialize( data = lt_request ).

        IF lv_event = 'EXCUTE' .
          APPEND VALUE #( %cid   = key-%cid
                          %param = VALUE #( event = lv_event
                                            zzkey = lv_json1 ) ) TO result.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD check.
    TYPES:BEGIN OF ty_matnr.
    TYPES: material TYPE matnr,
           plant    TYPE werks_d,
           END OF ty_matnr.
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.
    DATA: lv_matnr TYPE matnr.
    DATA: ls_matnr TYPE ty_matnr.
    DATA: lt_matnr TYPE STANDARD TABLE OF ty_matnr.
    DATA: lv_temp     TYPE string.
    DATA: lv_temp_qty TYPE p LENGTH 16 DECIMALS 2.
    LOOP AT ct_data INTO DATA(ls_data_t).
      IF ls_data_t-material IS NOT INITIAL.
        ls_matnr-material = zzcl_common_utils=>conversion_matn1( iv_alpha = lc_mode_out iv_input = ls_data_t-material ).
        ls_matnr-plant = ls_data_t-plant.
        APPEND ls_matnr TO lt_matnr.
      ENDIF.
    ENDLOOP.

    SELECT plant, product AS material         "#EC CI_FAE_LINES_ENSURED
    FROM i_productplantbasic WITH PRIVILEGED ACCESS
    FOR ALL ENTRIES IN @lt_matnr
    WHERE product = @lt_matnr-material
    AND plant = @lt_matnr-plant
    INTO TABLE @DATA(lt_productplantbasic).
    SORT lt_productplantbasic BY plant material.

    SELECT plant FROM i_plant
    INTO TABLE @DATA(lt_plant).                         "#EC CI_NOWHERE
    SORT lt_plant BY plant.

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CLEAR lv_message.
      READ TABLE ct_data1 INTO DATA(cs_data1) WITH KEY row = <lfs_data>-row.
      IF sy-subrc <> 0.
        CLEAR cs_data1.
      ELSE.
        CONDENSE cs_data1-age.
        CONDENSE cs_data1-qty.
        CONDENSE cs_data1-calendaryear.
        CONDENSE cs_data1-calendarmonth.
      ENDIF.
      IF <lfs_data>-plant IS INITIAL.
        MESSAGE s011(zfico_001) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.
      IF <lfs_data>-material IS INITIAL.
        MESSAGE s012(zfico_001) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.
      IF <lfs_data>-age IS INITIAL.
        IF cs_data1-age IS NOT INITIAL.
          MESSAGE s009(zfico_001) INTO lv_msg WITH cs_data1-age.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ELSE.
          MESSAGE s013(zfico_001) INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ELSE.
        lv_temp = <lfs_data>-age.
        CONDENSE lv_temp.
        IF  lv_temp NE cs_data1-age.
          MESSAGE s009(zfico_001) INTO lv_msg WITH cs_data1-age.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ENDIF.
      IF <lfs_data>-qty IS INITIAL.
        IF cs_data1-qty IS NOT INITIAL.
          MESSAGE s010(zfico_001) INTO lv_msg WITH cs_data1-qty.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ELSE.
          MESSAGE s014(zfico_001) INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ELSE.

      ENDIF.
      IF <lfs_data>-calendaryear IS INITIAL.
        IF cs_data1-calendaryear IS NOT INITIAL.
          MESSAGE s017(zfico_001) INTO lv_msg WITH cs_data1-calendaryear.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ELSE.
          MESSAGE s015(zfico_001) INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ELSE.

      ENDIF.

      IF <lfs_data>-calendarmonth IS INITIAL.
        IF cs_data1-calendarmonth IS NOT INITIAL .
          MESSAGE s018(zfico_001) INTO lv_msg WITH cs_data1-calendarmonth.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ELSE.
          MESSAGE s016(zfico_001) INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ELSE.

      ENDIF.


      IF lv_message IS INITIAL.
        READ TABLE lt_plant TRANSPORTING NO FIELDS WITH KEY plant = <lfs_data>-plant BINARY SEARCH.
        IF sy-subrc <> 0.
          MESSAGE s007(zfico_001) INTO lv_msg WITH <lfs_data>-plant.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ENDIF.
      IF lv_message IS INITIAL.
        lv_matnr = zzcl_common_utils=>conversion_matn1( iv_alpha = lc_mode_out iv_input = <lfs_data>-material ).
        READ TABLE lt_productplantbasic TRANSPORTING NO FIELDS WITH KEY plant = <lfs_data>-plant material = lv_matnr BINARY SEARCH.
        IF sy-subrc <> 0.
          MESSAGE s008(zfico_001) INTO lv_msg WITH <lfs_data>-material <lfs_data>-plant.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ENDIF.
      IF lv_message IS NOT INITIAL.
        cs_error = 'X'.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = lv_message.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD excute.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.
    DATA: lv_matnr TYPE matnr.
    TRY.
        DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
      CATCH cx_uuid_error INTO DATA(e) ##NO_HANDLER.
        "handle exception
    ENDTRY.

    GET TIME STAMP FIELD lv_timestamp.
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>) WHERE status NE 'E' .
      CLEAR lv_message.

      lv_matnr = zzcl_common_utils=>conversion_matn1( iv_alpha = lc_mode_in iv_input = <lfs_data>-material ).

      MODIFY ztfi_1004 FROM @( VALUE #(
                                                  plant              = <lfs_data>-plant
                                                  material           =  lv_matnr
                                                  age                = <lfs_data>-age
                                                  qty                = <lfs_data>-qty
                                                  calendaryear       = <lfs_data>-calendaryear
                                                  calendarmonth      = <lfs_data>-calendarmonth

                                                  created_by         = sy-uname
                                                  created_at         = lv_timestamp
                                                  last_changed_by    = sy-uname
                                                  last_changed_at    = lv_timestamp
                                                  local_last_changed_at = lv_timestamp ) ).
      IF sy-subrc = 0.
        INSERT INTO ztfi_1003 VALUES @( VALUE #(
                                            uuid                = lv_uuid
                                                  plant              = <lfs_data>-plant
                                                  material           =  lv_matnr
                                                  age                = <lfs_data>-age
                                                  qty                = <lfs_data>-qty
                                                  calendaryear       = <lfs_data>-calendaryear
                                                  calendarmonth      = <lfs_data>-calendarmonth
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

    ENDLOOP.

  ENDMETHOD.

  METHOD export.

    TYPES:BEGIN OF lty_export,

            plant         TYPE zr_inageupload-plant,
            material      TYPE zr_inageupload-material,
            age           TYPE zr_inageupload-age,
            qty           TYPE zr_inageupload-qty,
            calendaryear  TYPE zr_inageupload-calendaryear,
            calendarmonth TYPE zr_inageupload-calendarmonth,

            status        TYPE zr_inageupload-status,
            message       TYPE zr_inageupload-message,
          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.
    DATA lv_timestamp TYPE tzntstmpl.

    lt_export = CORRESPONDING #( it_data ).

    SELECT SINGLE *                           "#EC CI_ALL_FIELDS_NEEDED
      FROM zzc_dtimp_conf
     WHERE object = 'ZDOWNLOAD_INAGE'
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
        CATCH cx_uuid_error INTO DATA(e) ##NO_HANDLER.
          "handle exception
      ENDTRY.

      GET TIME STAMP FIELD lv_timestamp.

      INSERT INTO zzt_prt_record VALUES @( VALUE #( record_uuid     = lv_uuid
                                                    provided_keys   = |継続年齢アップデート出力|
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

ENDCLASS.
