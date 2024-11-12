CLASS lhc_zzr_prt_template DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Template
        RESULT result,
      createXSDFile FOR DETERMINE ON SAVE
        IMPORTING keys FOR Template~createXSDFile.
ENDCLASS.

CLASS lhc_zzr_prt_template IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD createXSDFile.
    DATA: lv_service_definition TYPE if_fp_fdp_api=>ty_service_definition,
          lv_has_error          TYPE abap_boolean,
          lv_message            TYPE string.

    READ ENTITIES OF zzr_prt_template IN LOCAL MODE
    ENTITY Template ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(results).

    LOOP AT results ASSIGNING FIELD-SYMBOL(<lfs_result>).
      lv_has_error = abap_false.
      lv_service_definition = <lfs_result>-ServiceDefinitionName.

      TRY.
          DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( lv_service_definition ).

          <lfs_result>-XSDContent  = lo_fdp_util->get_xsd(  ).

          <lfs_result>-XSDFileName = |{ <lfs_result>-ServiceDefinitionName }.xsd |.

          <lfs_result>-XSDMimeType = 'application/xml'.

        CATCH cx_fp_fdp_error INTO DATA(lo_fdp_error).
          lv_has_error = abap_true.
          lv_message   = lo_fdp_error->get_longtext(  ).
      ENDTRY.

      IF lv_has_error = abap_true.
        APPEND VALUE #( TemplateUUID = <lfs_result>-TemplateUUID
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_message ) )
        TO reported-template.
      ENDIF.
    ENDLOOP.

    IF lv_has_error = abap_false.
      MODIFY ENTITIES OF zzr_prt_template IN LOCAL MODE
      ENTITY Template
      UPDATE FIELDS ( XSDMimeType XSDFileName XSDContent )
      WITH VALUE #( FOR file IN results ( %tky        = file-%tky
                                          XSDMimeType = file-XSDMimeType
                                          XSDFileName = file-XSDFileName
                                          XSDContent  = file-XSDContent ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
