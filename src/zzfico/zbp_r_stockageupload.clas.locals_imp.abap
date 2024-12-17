CLASS lhc_stageupload DEFINITION INHERITING FROM cl_abap_behavior_handler.
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
      IMPORTING REQUEST requested_authorizations FOR stageupload RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION stageupload~processlogic RESULT result.

    METHODS check  IMPORTING ct_data1 TYPE lty_request_t1
                   CHANGING  ct_data  TYPE lty_request_t
                             cs_error TYPE c.
    METHODS excute CHANGING ct_data TYPE lty_request_t.
    METHODS export IMPORTING it_data              TYPE lty_request_t
                   RETURNING VALUE(rv_recorduuid) TYPE sysuuid_c36.

ENDCLASS.

CLASS lhc_stageupload IMPLEMENTATION.

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
    TYPES:BEGIN OF ty_matnr.
    TYPES: material TYPE matnr,
           plant    TYPE werks_d,
           END OF ty_matnr.
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.
    DATA: lv_matnr(18) TYPE c.
    DATA: ls_matnr TYPE ty_matnr.
    DATA: lt_matnr TYPE STANDARD TABLE OF ty_matnr.
    DATA: lv_temp     TYPE string.
    DATA: lv_temp_qty TYPE p LENGTH 16 DECIMALS 2.
    TYPES:BEGIN OF lty_collect.
            INCLUDE TYPE zr_stockageupload.
    TYPES:  age_s TYPE string.
    TYPES: counts TYPE i,
           END OF lty_collect.

    DATA:ls_collect TYPE lty_collect.
    DATA:lt_collect TYPE STANDARD TABLE OF lty_collect.

    LOOP AT ct_data INTO DATA(ls_data_t).
      IF ls_data_t-material IS NOT INITIAL.
        lv_matnr = ls_data_t-material.
        ls_matnr-material = zzcl_common_utils=>conversion_matn1( iv_alpha = lc_mode_in iv_input =  |{ lv_matnr ALPHA = IN }| ).
        ls_matnr-plant = ls_data_t-plant.
        APPEND ls_matnr TO lt_matnr.
      ENDIF.
      ls_data_t-material = ls_matnr-material.
      MOVE-CORRESPONDING ls_data_t TO ls_collect.
      CLEAR ls_collect-age.
      ls_collect-age_s = ls_data_t-age.
      ls_collect-counts = 1.
      COLLECT ls_collect INTO lt_collect.
      MODIFY ct_data FROM ls_data_t TRANSPORTING material.
    ENDLOOP.

    SELECT product AS material                "#EC CI_FAE_LINES_ENSURED
    FROM i_product WITH PRIVILEGED ACCESS
    FOR ALL ENTRIES IN @lt_matnr
    WHERE product = @lt_matnr-material
    INTO TABLE @DATA(lt_productbasic).
    SORT lt_productbasic BY material.

    SELECT plant, product AS material         "#EC CI_FAE_LINES_ENSURED
    FROM i_productplantbasic WITH PRIVILEGED ACCESS
    FOR ALL ENTRIES IN @lt_matnr
    WHERE product = @lt_matnr-material
    AND plant = @lt_matnr-plant
    INTO TABLE @DATA(lt_productplantbasic).
    SORT lt_productplantbasic BY plant material.

    SELECT plant,valuationarea FROM i_plant
    INTO TABLE @DATA(lt_plant).                         "#EC CI_NOWHERE
    SORT lt_plant BY plant.

    SELECT companycode FROM i_companycode
    INTO TABLE @DATA(lt_companycode).                   "#EC CI_NOWHERE
    SORT lt_companycode BY companycode.

    SELECT * FROM ztfi_1004 FOR ALL ENTRIES IN @ct_data
    WHERE  plant =   @ct_data-plant
    AND material = @ct_data-material
   " AND age = @ct_data-age
    AND calendaryear   = @ct_data-calendaryear
    AND calendarmonth  = @ct_data-calendarmonth
    INTO TABLE @DATA(lt_ztfi_1004) .
    SORT lt_ztfi_1004 BY plant material calendaryear calendarmonth .

    SELECT a~ledger,a~companycode,b~valuationarea FROM i_ledgercompanycodecrcyroles WITH PRIVILEGED ACCESS AS a
    JOIN i_productvaluationareavh WITH PRIVILEGED ACCESS AS b
    ON a~companycode = b~companycode
    INTO TABLE @DATA(lt_ledgercompanycodecrcyrole).
    SORT lt_ledgercompanycodecrcyrole BY ledger companycode.

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CLEAR lv_message.
      READ TABLE lt_collect TRANSPORTING NO FIELDS  WITH KEY companycode = <lfs_data>-companycode plant = <lfs_data>-plant  material =  <lfs_data>-material age_s = <lfs_data>-age
calendaryear = <lfs_data>-calendaryear calendarmonth = <lfs_data>-calendarmonth counts = 1.
      IF sy-subrc NE 0.
        MESSAGE s029(zfico_001) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.


      READ TABLE ct_data1 INTO DATA(cs_data1) WITH KEY row = <lfs_data>-row.
      IF sy-subrc <> 0.
        CLEAR cs_data1.
      ELSE.
        CONDENSE cs_data1-age.
        CONDENSE cs_data1-qty.
        CONDENSE cs_data1-calendaryear.
        CONDENSE cs_data1-calendarmonth.
      ENDIF.
      IF <lfs_data>-inventorytype NE 'A' AND <lfs_data>-inventorytype NE 'B' .
        MESSAGE s042(zfico_001) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.
      IF <lfs_data>-ledger IS INITIAL.
        MESSAGE s036(zfico_001) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
      ENDIF.
      IF <lfs_data>-companycode IS INITIAL.
        MESSAGE s038(zfico_001) INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
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

      IF <lfs_data>-companycode IS NOT INITIAL.
        READ TABLE lt_companycode INTO DATA(ls_companycode) WITH KEY companycode = <lfs_data>-companycode BINARY SEARCH.
        IF sy-subrc <> 0.
          MESSAGE s039(zfico_001) INTO lv_msg WITH <lfs_data>-companycode.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
        READ TABLE lt_ledgercompanycodecrcyrole INTO DATA(ls_ledgercompanycodecrcyrole1) WITH KEY valuationarea = <lfs_data>-companycode
         ledger = <lfs_data>-ledger.
        IF sy-subrc <> 0.
          MESSAGE s037(zfico_001) INTO lv_msg WITH <lfs_data>-ledger.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ENDIF.

      IF <lfs_data>-plant IS NOT INITIAL AND <lfs_data>-inventorytype NE 'B'.
        READ TABLE lt_plant INTO DATA(ls_plant) WITH KEY plant = <lfs_data>-plant BINARY SEARCH.
        IF sy-subrc <> 0.
          MESSAGE s007(zfico_001) INTO lv_msg WITH <lfs_data>-plant.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ELSE.

*          READ TABLE lt_ledgercompanycodecrcyrole INTO DATA(ls_ledgercompanycodecrcyrole) WITH KEY valuationarea = ls_plant-valuationarea
*          ledger = <lfs_data>-ledger.
*          IF sy-subrc <> 0.
*            MESSAGE s037(zfico_001) INTO lv_msg WITH <lfs_data>-ledger.
*            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
*          ENDIF.
        ENDIF.
      ENDIF.
      IF <lfs_data>-inventorytype NE 'B'.
        READ TABLE lt_productplantbasic TRANSPORTING NO FIELDS WITH KEY plant = <lfs_data>-plant material = <lfs_data>-material BINARY SEARCH.
        IF sy-subrc <> 0.
          MESSAGE s008(zfico_001) INTO lv_msg WITH |{ <lfs_data>-material ALPHA = OUT }| <lfs_data>-plant.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ELSE.
        READ TABLE lt_productbasic TRANSPORTING NO FIELDS WITH KEY material = <lfs_data>-material BINARY SEARCH.
        IF sy-subrc <> 0.
          MESSAGE s044(zfico_001) INTO lv_msg WITH |{ <lfs_data>-material ALPHA = OUT }|.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = '\' ).
        ENDIF.
      ENDIF.


      IF lv_message IS NOT INITIAL.
        cs_error = 'X'.
        <lfs_data>-status = 'E'.
        <lfs_data>-message = lv_message.
      ELSE.
        " READ TABLE lt_ztfi_1004 INTO DATA(ls_ztfi_1004) WITH KEY plant = <lfs_data>-plant  material =  <lfs_data>-material age = <lfs_data>-age
        "calendaryear = <lfs_data>-calendaryear calendarmonth = <lfs_data>-calendarmonth.
        "  IF sy-subrc = 0.
        "    <lfs_data>-status = ''.
        "    MESSAGE s028(zfico_001) INTO <lfs_data>-message.
        "  ELSE.
        <lfs_data>-status = ''.
        MESSAGE s022(zfico_001) INTO <lfs_data>-message.
        "   ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD excute.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA: lv_message TYPE string,
          lv_msg     TYPE string.
    DATA: lv_matnr(18) TYPE c.
    DATA:lv_check_succ TYPE string.
    DATA:lv_check_warn TYPE string.

    TRY.
        DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
      CATCH cx_uuid_error INTO DATA(e) ##NO_HANDLER.
        "handle exception
    ENDTRY.



    MESSAGE s022(zfico_001) INTO lv_check_succ .
    MESSAGE s028(zfico_001) INTO lv_check_warn .
    LOOP AT ct_data INTO DATA(cs_data1).
      IF cs_data1-status = 'E' .
        MESSAGE s024(zfico_001) INTO lv_message .
        cs_data1-status  = 'E'.
        cs_data1-message = lv_message.
      ENDIF.
      IF cs_data1-message NE lv_check_succ AND cs_data1-message NE lv_check_warn AND cs_data1-status = ''.
        MESSAGE s023(zfico_001) INTO lv_message .
        cs_data1-status  = 'E'.
        cs_data1-message = lv_message.
      ENDIF.

      MODIFY ct_data FROM cs_data1 TRANSPORTING status message.
    ENDLOOP.

    LOOP AT ct_data INTO DATA(ls_data_t).
      IF ls_data_t-material IS NOT INITIAL.
        lv_matnr = ls_data_t-material.
        ls_data_t-material = zzcl_common_utils=>conversion_matn1( iv_alpha = lc_mode_in iv_input =  |{ lv_matnr ALPHA = IN }| ).
      ENDIF.
      MODIFY ct_data FROM ls_data_t TRANSPORTING material.
    ENDLOOP.

*    SELECT * FROM ztfi_1004 FOR ALL ENTRIES IN @ct_data
*    WHERE  plant =   @ct_data-plant
*    AND material = @ct_data-material
*   " AND age = @ct_data-age
*    AND calendaryear   = @ct_data-calendaryear
*    AND calendarmonth  = @ct_data-calendarmonth
*    INTO TABLE @DATA(lt_ztfi_1004) .
*    SORT lt_ztfi_1004 BY plant material calendaryear calendarmonth .
    DATA(lt_data_temp) = ct_data .
    SORT lt_data_temp BY inventorytype ledger companycode plant calendaryear calendarmonth.

    DELETE ADJACENT DUPLICATES FROM lt_data_temp COMPARING inventorytype ledger companycode plant calendaryear calendarmonth.
    LOOP AT lt_data_temp ASSIGNING FIELD-SYMBOL(<lfs_data_temp>) WHERE status = ''.

      DELETE FROM ztfi_1004 WHERE inventorytype = @<lfs_data_temp>-inventorytype
      AND  ledger = @<lfs_data_temp>-ledger
      AND  companycode = @<lfs_data_temp>-companycode
      AND  plant = @<lfs_data_temp>-plant
      AND  calendaryear = @<lfs_data_temp>-calendaryear
      AND  calendarmonth = @<lfs_data_temp>-calendarmonth.

    ENDLOOP.
    GET TIME STAMP FIELD lv_timestamp.
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>) WHERE status = ''.
      CLEAR lv_message.
      "READ TABLE lt_ztfi_1004 INTO DATA(ls_ztfi_1004) WITH KEY plant = <lfs_data>-plant  material =  <lfs_data>-material age = <lfs_data>-age
      "calendaryear   = <lfs_data>-calendaryear calendarmonth  = <lfs_data>-calendarmonth.
      "IF sy-subrc = 0.
      " <lfs_data>-qty += ls_ztfi_1004-qty.
      "ENDIF.

      MODIFY ztfi_1004 FROM @( VALUE #(
                                                  inventorytype = <lfs_data>-inventorytype
                                                  ledger = <lfs_data>-ledger
                                                  companycode =  <lfs_data>-companycode
                                                  plant              = <lfs_data>-plant
                                                  material           = <lfs_data>-material
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
                                            inventorytype = <lfs_data>-inventorytype
                                            ledger = <lfs_data>-ledger
                                            companycode =  <lfs_data>-companycode
                                                  plant              = <lfs_data>-plant
                                                  material           = <lfs_data>-material
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
            inventorytype TYPE ztfi_1003-inventorytype,
            ledger        TYPE ztfi_1003-ledger,
            companycode   TYPE ztfi_1003-companycode,
            calendaryear  TYPE ztfi_1003-calendaryear,
            calendarmonth TYPE ztfi_1003-calendarmonth,
            plant         TYPE ztfi_1003-plant,
            material      TYPE ztfi_1003-material,
            age           TYPE ztfi_1003-age,
            qty           TYPE ztfi_1003-qty,


            status        TYPE ztfi_1003-status,
            message       TYPE ztfi_1003-message,
          END OF lty_export,
          lty_export_t TYPE TABLE OF lty_export.

    DATA lt_export TYPE lty_export_t.
    DATA lv_timestamp TYPE tzntstmpl.

    lt_export = CORRESPONDING #( it_data ).

    SELECT SINGLE *
      FROM zzc_dtimp_conf
     WHERE object = 'ZDOWNLOAD_INAGE'
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
