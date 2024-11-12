CLASS lhc_zr_emailmasterupload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zremailmasterupload
        RESULT result,
      validationfields FOR VALIDATE ON SAVE
        IMPORTING keys FOR zremailmasterupload~validationfields.
ENDCLASS.

CLASS lhc_zr_emailmasterupload IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validationfields.
    DATA: lv_message TYPE string.
    DATA: lv_regular_expression TYPE string VALUE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'.

    READ ENTITIES OF zr_emailmasterupload IN LOCAL MODE
    ENTITY zremailmasterupload
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    " Example for a POSIX regular expression engine (More configuration options are available
    " as optional parameters of the method POSIX).
    DATA(lo_posix_engine) = xco_cp_regular_expression=>engine->posix(
      iv_ignore_case = abap_true
    ).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).

      IF <lfs_result>-plant IS INITIAL.
        MESSAGE e006(zbc_001) WITH TEXT-001 INTO lv_message.
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-zremailmasterupload.
        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %element-plant = if_abap_behv=>mk-on
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_message ) )
                     TO reported-zremailmasterupload.
      ENDIF.

      IF <lfs_result>-customer IS INITIAL.
        MESSAGE e006(zbc_001) WITH TEXT-002 INTO lv_message.
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-zremailmasterupload.
        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %element-customer = if_abap_behv=>mk-on
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_message ) )
                     TO reported-zremailmasterupload.
      ELSE.
        DATA(lv_customer) = |{ <lfs_result>-customer ALPHA = IN }|.
        CONDENSE lv_customer NO-GAPS.

        SELECT SINGLE plant,
                      customer
          FROM i_customercompanybyplant
          WITH PRIVILEGED ACCESS
         WHERE plant = @<lfs_result>-plant
           AND customer = @lv_customer
          INTO @DATA(ls_customer).
        IF sy-subrc <> 0.
          MESSAGE e010(zbc_001) WITH <lfs_result>-customer <lfs_result>-plant INTO lv_message.
          APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-zremailmasterupload.
          APPEND VALUE #( %tky = <lfs_result>-%tky
                          %element-customer = if_abap_behv=>mk-on
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = lv_message ) )
                       TO reported-zremailmasterupload.
        ENDIF.
      ENDIF.

      IF <lfs_result>-receiver IS INITIAL.
        MESSAGE e006(zbc_001) WITH TEXT-003 INTO lv_message.
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-zremailmasterupload.
        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %element-receiver = if_abap_behv=>mk-on
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_message ) )
                     TO reported-zremailmasterupload.
      ENDIF.

      IF <lfs_result>-mailaddress IS INITIAL.
        MESSAGE e006(zbc_001) WITH TEXT-004 INTO lv_message.
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-zremailmasterupload.
        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %element-mailaddress = if_abap_behv=>mk-on
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_message ) )
                     TO reported-zremailmasterupload.
      ELSE.
        DATA(lv_match) = xco_cp=>string( <lfs_result>-mailaddress )->matches( iv_regular_expression = lv_regular_expression
                                                                              io_engine             = lo_posix_engine ).
        IF lv_match IS INITIAL.
          APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-zremailmasterupload.

          MESSAGE e008(zbc_001) WITH TEXT-004 <lfs_result>-mailaddress INTO lv_message.
          APPEND VALUE #( %tky = <lfs_result>-%tky
                          %element-mailaddress = if_abap_behv=>mk-on
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = lv_message ) )
                       TO reported-zremailmasterupload.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
