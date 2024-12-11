CLASS lhc_user DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR user RESULT result.
    METHODS validationemail FOR VALIDATE ON SAVE
      IMPORTING keys FOR user~validationemail.

ENDCLASS.

CLASS lhc_user IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD validationemail.
    DATA: lv_regular_expression TYPE string VALUE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'.

    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY user
    FIELDS ( mail ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    " Example for a POSIX regular expression engine (More configuration options are available
    " as optional parameters of the method POSIX).
    DATA(lo_posix_engine) = xco_cp_regular_expression=>engine->posix(
      iv_ignore_case = abap_true
    ).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      DATA(lv_match) = xco_cp=>string( <lfs_result>-mail )->matches( iv_regular_expression = lv_regular_expression
                                                                     io_engine             = lo_posix_engine ).
      IF lv_match IS INITIAL.
        MESSAGE e008(zbc_001) WITH TEXT-002 <lfs_result>-mail INTO DATA(lv_message).

        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-user.

        APPEND VALUE #( %tky          = <lfs_result>-%tky
                        %state_area   = 'VALIDATE_EMAIL'
                        %element-mail = if_abap_behv=>mk-on
                        %msg          = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                               text     = lv_message ) ) TO reported-user.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_assignplant DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateplant FOR VALIDATE ON SAVE
      IMPORTING keys FOR assignplant~validateplant.

ENDCLASS.

CLASS lhc_assignplant IMPLEMENTATION.

  METHOD validateplant.
    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY assignplant
    FIELDS ( plant ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    IF lt_result IS NOT INITIAL.
      SELECT plant
        FROM i_plant WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_result
       WHERE plant = @lt_result-plant
        INTO TABLE @DATA(lt_plant).
      SORT lt_plant BY plant.

      LOOP AT lt_result INTO DATA(ls_result).
        IF ls_result-plant IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-003 INTO DATA(lv_message).
        ELSE.
          READ TABLE lt_plant TRANSPORTING NO FIELDS WITH KEY plant = ls_result-plant BINARY SEARCH.
          IF sy-subrc <> 0.
            MESSAGE e008(zbc_001) WITH TEXT-003 ls_result-plant INTO lv_message.
          ENDIF.
        ENDIF.

        IF lv_message IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-assignplant.
          APPEND VALUE #( %tky           = ls_result-%tky
                          %state_area    = 'VALIDATE_PLANT'
                          %element-plant = if_abap_behv=>mk-on
                          %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                  text     = lv_message )
                          %path          = VALUE #( user-%key-userid = ls_result-userid ) ) TO reported-assignplant.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_assigncompany DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validatecompanycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR assigncompany~validatecompanycode.

ENDCLASS.

CLASS lhc_assigncompany IMPLEMENTATION.

  METHOD validatecompanycode.
    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY assigncompany
    FIELDS ( companycode ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    IF lt_result IS NOT INITIAL.
      SELECT companycode
        FROM i_companycode WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_result
       WHERE companycode = @lt_result-companycode
        INTO TABLE @DATA(lt_companycode).
      SORT lt_companycode BY companycode.

      LOOP AT lt_result INTO DATA(ls_result).
        IF ls_result-companycode IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-005 INTO DATA(lv_message).
        ELSE.
          READ TABLE lt_companycode TRANSPORTING NO FIELDS WITH KEY companycode = ls_result-companycode BINARY SEARCH.
          IF sy-subrc <> 0.
            MESSAGE e008(zbc_001) WITH TEXT-005 ls_result-companycode INTO lv_message.
          ENDIF.
        ENDIF.

        IF lv_message IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-assigncompany.
          APPEND VALUE #( %tky           = ls_result-%tky
                          %state_area    = 'VALIDATE_COMPANY'
                          %element-companycode = if_abap_behv=>mk-on
                          %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                  text     = lv_message )
                          %path          = VALUE #( user-%key-userid = ls_result-userid ) ) TO reported-assigncompany.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_assignsalesorg DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validatesalesorg FOR VALIDATE ON SAVE
      IMPORTING keys FOR assignsalesorg~validatesalesorg.

ENDCLASS.

CLASS lhc_assignsalesorg IMPLEMENTATION.

  METHOD validatesalesorg.
    READ ENTITIES OF zr_tbc1004 IN LOCAL MODE
    ENTITY assignsalesorg
    FIELDS ( salesorganization ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    IF lt_result IS NOT INITIAL.
      SELECT salesorganization
        FROM i_salesorganization WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_result
       WHERE salesorganization = @lt_result-salesorganization
        INTO TABLE @DATA(lt_salesorganization).
      SORT lt_salesorganization BY salesorganization.

      LOOP AT lt_result INTO DATA(ls_result).
        IF ls_result-salesorganization IS INITIAL.
          MESSAGE e006(zbc_001) WITH TEXT-006 INTO DATA(lv_message).
        ELSE.
          READ TABLE lt_salesorganization TRANSPORTING NO FIELDS WITH KEY salesorganization = ls_result-salesorganization BINARY SEARCH.
          IF sy-subrc <> 0.
            MESSAGE e008(zbc_001) WITH TEXT-006 ls_result-salesorganization INTO lv_message.
          ENDIF.
        ENDIF.

        IF lv_message IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_result-%tky ) TO failed-assignsalesorg.
          APPEND VALUE #( %tky           = ls_result-%tky
                          %state_area    = 'VALIDATE_SALESORG'
                          %element-salesorganization = if_abap_behv=>mk-on
                          %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                  text     = lv_message )
                          %path          = VALUE #( user-%key-userid = ls_result-userid ) ) TO reported-assignsalesorg.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
