CLASS lsc_zzr_prt_record DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zzr_prt_record IMPLEMENTATION.

  METHOD save_modified.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_record DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR record
        RESULT result,
      createprintfile FOR DETERMINE ON SAVE
        IMPORTING keys FOR record~createprintfile,
      createprintrecord FOR MODIFY
        IMPORTING keys FOR ACTION record~createprintrecord,
      sendemail FOR MODIFY
        IMPORTING keys FOR ACTION record~sendemail RESULT result,
      mergerpdf FOR MODIFY
        IMPORTING keys FOR ACTION record~mergerpdf RESULT result.
ENDCLASS.

CLASS lhc_record IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD createprintfile.
    DATA: lo_data               TYPE REF TO data,
          lv_service_definition TYPE if_fp_fdp_api=>ty_service_definition,
          lv_xml                TYPE xstring,
          lv_has_error          TYPE abap_boolean,
          lv_message            TYPE string.

    FIELD-SYMBOLS: <lfo_data> TYPE any.

    READ ENTITIES OF zzr_prt_record IN LOCAL MODE
    ENTITY record ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_records).

    IF lt_records IS NOT INITIAL.
      ##SELECT_FAE_WITH_LOB[XDPCONTENT]
      SELECT templateuuid,
             servicedefinitionname,
             xdpcontent
        FROM zzr_prt_template
        FOR ALL ENTRIES IN @lt_records
       WHERE templateuuid = @lt_records-templateuuid
        INTO TABLE @DATA(lt_template).
      SORT lt_template BY templateuuid.

      LOOP AT lt_records ASSIGNING FIELD-SYMBOL(<lfs_record>).

        READ TABLE lt_template INTO DATA(ls_template) WITH KEY templateuuid = <lfs_record>-templateuuid
                                                               BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_record>-pdfmimetype = 'application/pdf'.

          IF <lfs_record>-pdffilename IS INITIAL.
            TRY.
                DATA(lv_uuid) = cl_system_uuid=>create_uuid_c36_static(  ).
                ##NO_HANDLER
              CATCH cx_uuid_error.
                " handle exception
            ENDTRY.
            <lfs_record>-pdffilename = |{ lv_uuid }.pdf |.
          ENDIF.

          <lfs_record>-datamimetype = 'application/xml'.
          <lfs_record>-datafilename = 'data.xml'.

          " get xml data
          IF <lfs_record>-isexternalprovideddata = abap_false.
            TRY.
                lv_service_definition = ls_template-servicedefinitionname.

                DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( lv_service_definition ).

                DATA(lt_keys) = lo_fdp_util->get_keys( ).

                " get key values
                /ui2/cl_json=>deserialize( EXPORTING json = <lfs_record>-providedkeys
                                           CHANGING  data = lo_data ).

                ASSIGN lo_data->* TO <lfo_data>.
                IF sy-subrc = 0.
                  DATA(lt_key_l) = lt_keys.
                  lt_keys = VALUE #( FOR key IN lt_key_l ( name      = key-name
                                                           value     = <lfo_data>-(key-name)->*
                                                           data_type = key-data_type ) ).
                ENDIF.

                lv_xml = lo_fdp_util->read_to_xml( lt_keys ).

                <lfs_record>-externalprovideddata = lv_xml.

                UNASSIGN <lfo_data>.
                FREE lo_data.
              CATCH cx_fp_fdp_error INTO DATA(lo_fdp_error).
                lv_has_error = abap_true.
                lv_message = lo_fdp_error->get_longtext(  ).
              CATCH cx_fp_ads_util INTO DATA(lo_ads_error).
                lv_has_error = abap_true.
                lv_message = lo_ads_error->get_longtext(  ).
            ENDTRY.
          ELSE.
            lv_xml = <lfs_record>-externalprovideddata.
          ENDIF.

          " render pdf
          TRY.
              cl_fp_ads_util=>render_pdf(
                EXPORTING
                  iv_locale       = 'en_us'
                  iv_xdp_layout   = ls_template-xdpcontent
                  iv_xml_data     = lv_xml
                IMPORTING
                  ev_pdf          = <lfs_record>-pdfcontent ).
            CATCH cx_fp_ads_util INTO lo_ads_error.
              lv_has_error = abap_true.
              lv_message = lo_ads_error->get_longtext(  ).
          ENDTRY.
        ELSE.
          lv_has_error = abap_true.
          ##NO_TEXT
          lv_message   = |Print Template not found|.
        ENDIF.

        IF lv_has_error = abap_true.
          APPEND VALUE #( recorduuid = <lfs_record>-recorduuid
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = lv_message ) )
          TO reported-record.
        ENDIF.
      ENDLOOP.

      IF lv_has_error = abap_false.
        MODIFY ENTITIES OF zzr_prt_record IN LOCAL MODE
        ENTITY record UPDATE FIELDS ( pdfmimetype
                                      pdffilename
                                      pdfcontent
                                      datamimetype
                                      datafilename
                                      externalprovideddata )
        WITH VALUE #( FOR record IN lt_records ( %tky         = record-%tky
                                                 pdfmimetype  = record-pdfmimetype
                                                 pdffilename  = record-pdffilename
                                                 pdfcontent   = record-pdfcontent
                                                 datamimetype = record-datamimetype
                                                 datafilename = record-datafilename
                                                 externalprovideddata = record-externalprovideddata ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD createprintrecord.
    DATA: lt_create_printing TYPE TABLE FOR CREATE zzr_prt_record,
          ls_create_printing LIKE LINE OF lt_create_printing.

    IF keys IS NOT INITIAL.
      SELECT templateuuid,
             templateid
        FROM zzr_prt_template
         FOR ALL ENTRIES IN @keys
       WHERE templateid = @keys-%param-templateid
        INTO TABLE @DATA(lt_template).
      SORT lt_template BY templateid.

      IF lt_template IS NOT INITIAL.
        LOOP AT keys INTO DATA(key).
          READ TABLE lt_template INTO DATA(ls_template) WITH KEY templateid = key-%param-templateid
                                                                 BINARY SEARCH.
          IF sy-subrc = 0.
            ls_create_printing = VALUE #( %cid = key-%cid
                                          templateuuid = ls_template-templateuuid
                                          isexternalprovideddata = key-%param-isexternalprovideddata
                                          externalprovideddata = key-%param-externalprovideddata
                                          providedkeys = key-%param-providedkeys
                                          pdffilename = key-%param-filename ).
            APPEND ls_create_printing TO lt_create_printing.
          ENDIF.
        ENDLOOP.

        MODIFY ENTITIES OF zzr_prt_record IN LOCAL MODE
        ENTITY record
        CREATE FIELDS ( templateuuid
                        isexternalprovideddata
                        externalprovideddata
                        providedkeys
                        pdffilename )
        WITH lt_create_printing
        MAPPED mapped
        REPORTED reported
        FAILED failed.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD sendemail.
    DATA: BEGIN OF ls_data,
            emailaddress TYPE i_addressemailaddress_2-emailaddress,
          END OF ls_data,
          lt_data LIKE TABLE OF ls_data.

    DATA: BEGIN OF ls_response,
            type        TYPE string,
            title       TYPE string,
            description TYPE string,
          END OF ls_response.

    READ ENTITIES OF zzr_prt_record IN LOCAL MODE
    ENTITY record ALL FIELDS WITH VALUE #( FOR key IN keys ( recorduuid = key-%param-recorduuid ) )
    RESULT DATA(lt_results).

    LOOP AT lt_results INTO DATA(ls_results).
      READ TABLE keys INTO DATA(ls_key) WITH KEY %param-recorduuid = ls_results-recorduuid BINARY SEARCH.
      IF sy-subrc = 0.
        " Get Key values
        /ui2/cl_json=>deserialize(
          EXPORTING
            json = ls_key-%param-zzkey
          CHANGING
            data = lt_data ).
      ENDIF.

      TRY.
          DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).

          LOOP AT lt_data INTO ls_data.
            lo_mail->add_recipient( CONV #( ls_data-emailaddress ) ).
          ENDLOOP.

          lo_mail->set_subject( |Email Test| ).

          DATA(lv_content) = |<p>Dear Customer:</p>| &&
                             |<p>Please do not reply to this message. |.

          lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
              iv_content      = lv_content
              iv_content_type = 'text/html' ) ).

          DATA(lo_attachment) = cl_bcs_mail_binarypart=>create_instance(
                                   iv_content      = ls_results-pdfcontent
                                   iv_content_type = ls_results-pdfmimetype
                                   iv_filename     = |attachment.pdf| ).

          lo_mail->add_attachment( lo_attachment ).

          lo_mail->send( IMPORTING et_status = DATA(lt_status) ).

          IF line_exists( lt_status[ status = 'S' ] ).
            ls_response = VALUE #( type = 'Success' title = 'Sent successfully' ).
          ENDIF.
        CATCH cx_bcs_mail INTO DATA(lo_err).
          ls_response = VALUE #( type = 'Error' title = 'Sent Failed ' description = lo_err->get_text(  ) ).
      ENDTRY.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_response ).

      APPEND VALUE #( %cid   = ls_key-%cid
                      %param = VALUE #( recorduuid = ls_results-recorduuid
                                        zzkey      = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD mergerpdf.
    TYPES:BEGIN OF ty_document,
            uuid TYPE sysuuid_x16,
          END OF ty_document.

    DATA lt_document TYPE TABLE OF ty_document.

    IF keys IS NOT INITIAL.
      SELECT templateuuid,
             templateid
        FROM zzr_prt_template
         FOR ALL ENTRIES IN @keys
       WHERE templateid = @keys-%param-templateid
        INTO TABLE @DATA(lt_template).
      SORT lt_template BY templateid.

      LOOP AT keys INTO DATA(ls_key).
        /ui2/cl_json=>deserialize(
          EXPORTING
            json = ls_key-%param-zzkey
          CHANGING
            data = lt_document ).

        READ ENTITIES OF zzr_prt_record IN LOCAL MODE
        ENTITY record ALL FIELDS WITH VALUE #( FOR document IN lt_document ( recorduuid = document-uuid ) )
        RESULT DATA(lt_results).

        " Create an instance of the PDF merger class
        DATA(l_merger) = cl_rspo_pdf_merger=>create_instance( ).

        LOOP AT lt_results INTO DATA(ls_results).
          " Add the data of the PDF document to the list of files which shall be merged
          l_merger->add_document( ls_results-pdfcontent ).
        ENDLOOP.

        TRY.
            " Merge both documents and receive the result
            DATA(l_merged_pdf) = l_merger->merge_documents( ).
            ##NO_HANDLER
          CATCH cx_rspo_pdf_merger INTO DATA(l_exception).
            " Add a useful error handling here
        ENDTRY.

        TRY.
            DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
            cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = lv_uuid
                                                     IMPORTING uuid_c36 = DATA(lv_recorduuid)  ).
            ##NO_HANDLER
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.

        GET TIME STAMP FIELD DATA(lv_timestamp).
        READ TABLE lt_template INTO DATA(ls_template) WITH KEY templateid = ls_key-%param-templateid BINARY SEARCH.
        INSERT INTO zzt_prt_record VALUES @( VALUE #( record_uuid     = lv_uuid
                                                      template_uuid   = ls_template-templateuuid
                                                      provided_keys   = ls_key-%param-zzkey
                                                      pdf_mime_type   = |application/pdf|
                                                      pdf_file_name   = |{ lv_recorduuid }.pdf |
                                                      pdf_content     = l_merged_pdf
                                                      created_by      = sy-uname
                                                      created_at      = lv_timestamp
                                                      last_changed_by = sy-uname
                                                      last_changed_at = lv_timestamp
                                                      local_last_changed_at = lv_timestamp ) ).

        APPEND VALUE #( %cid   = ls_key-%cid
                        %param = VALUE #( templateid = ls_key-%param-templateid
                                          zzkey      = ls_key-%param-zzkey
                                          recorduuid = lv_recorduuid ) ) TO result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
