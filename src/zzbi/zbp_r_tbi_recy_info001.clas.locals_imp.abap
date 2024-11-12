CLASS lhc_zr_tbi_recy_info001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zrtbirecyinfo001
        RESULT result,

      add_prefix IMPORTING iv_number        TYPE i
                 RETURNING VALUE(rv_number) TYPE ze_recycle_num,

      create_recycle FOR MODIFY
        IMPORTING keys FOR ACTION zrtbirecyinfo001~create_recycle RESULT result,
      validate_input FOR VALIDATE ON SAVE
        IMPORTING keys FOR zrtbirecyinfo001~validate_input,
      determine_detail FOR DETERMINE ON SAVE
            IMPORTING keys FOR zrtbirecyinfo001~determine_detail.
ENDCLASS.

CLASS lhc_zr_tbi_recy_info001 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create_recycle.

    DATA: lt_recy_info TYPE TABLE FOR CREATE zr_tbi_recy_info001,
          ls_recy_info LIKE LINE OF lt_recy_info.

    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    IF sy-subrc <> 0.
      APPEND VALUE #( %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                    textid = VALUE #( msgid = 'ZBI003' msgno = '000' )
                                                  )
                      %state_area = 'VALIDATE_CREATE'
                     ) TO reported-zrtbirecyinfo001.
      RETURN.
    ENDIF.

    IF ls_key-%param-companycode IS INITIAL.
      APPEND VALUE #( %cid = ls_key-%cid
                      %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                   textid = VALUE #( msgid = 'ZBI003' msgno = '001' )
                                                 )
                     %action-create_recycle = if_abap_behv=>mk-on

                     %state_area = 'VALIDATE_CREATE'
                    ) TO reported-zrtbirecyinfo001.


      RETURN.
    ENDIF.

    IF ls_key-%param-recoverytype IS INITIAL.
      APPEND VALUE #( %cid = ls_key-%cid
                      %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                   textid = VALUE #( msgid = 'ZBI003' msgno = '002' )
                                                 )
                     %state_area = 'VALIDATE_CREATE'
                    ) TO reported-zrtbirecyinfo001.
      RETURN.
    ENDIF.

    IF ls_key-%param-customer IS INITIAL.
      APPEND VALUE #( %cid = ls_key-%cid
                      %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                   textid = VALUE #( msgid = 'ZBI003' msgno = '003' )
                                                 )
                     %state_area = 'VALIDATE_CREATE'
                    ) TO reported-zrtbirecyinfo001.
      RETURN.
    ENDIF.

    IF ls_key-%param-recoveryyear IS INITIAL.
      APPEND VALUE #( %cid = ls_key-%cid
                      %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                   textid = VALUE #( msgid = 'ZBI003' msgno = '004' )
                                                 )
                     %state_area = 'VALIDATE_CREATE'
                    ) TO reported-zrtbirecyinfo001.
      RETURN.
    ENDIF.

    SELECT MAX( recovery_num ) FROM ztbi_recy_info
     WHERE recovery_type = @ls_key-%param-recoverytype
     AND recovery_year = @ls_key-%param-recoveryyear
     INTO @DATA(lv_max_no).

    IF lv_max_no IS INITIAL.
      lv_max_no = 1.
    ELSE.
      lv_max_no = lv_max_no + 1.
    ENDIF.

    TRY.
        ls_recy_info-uuid = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        APPEND VALUE #( %cid = ls_key-%cid
                       %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                    textid = VALUE #( msgid = 'ZBI003' msgno = '007' )
                                                  )
                      %state_area = 'VALIDATE_CREATE'
                     ) TO reported-zrtbirecyinfo001.
        RETURN.
    ENDTRY.

    ls_recy_info-companycode = ls_key-%param-companycode.
    ls_recy_info-createddate = cl_abap_context_info=>get_system_date( ).
    ls_recy_info-currency = 'JPY'.
    ls_recy_info-customer = |{ ls_key-%param-customer ALPHA = IN }|.

    SELECT SINGLE companycodename
    FROM i_companycode WHERE companycode = @ls_key-%param-companycode
    INTO @ls_recy_info-companyname.

    IF ls_recy_info-companyname IS INITIAL.
      APPEND VALUE #( %cid = ls_key-%cid
                     %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                   textid = VALUE #( msgid = 'ZBI003' msgno = '008' attr1 = ls_key-%param-companycode )
                                                )
                    %state_area = 'VALIDATE_CREATE'
                   ) TO reported-zrtbirecyinfo001.
      RETURN.
    ENDIF.


    SELECT SINGLE customername
    FROM i_customer WHERE customer = @ls_key-%param-customer
    INTO @ls_recy_info-customername.

    IF ls_recy_info-customername IS INITIAL.
      APPEND VALUE #( %cid = ls_key-%cid
                     %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                   textid = VALUE #( msgid = 'ZBI003' msgno = '009' attr1 = ls_key-%param-customer )
                                                )
                    %state_area = 'VALIDATE_CREATE'
                   ) TO reported-zrtbirecyinfo001.
      RETURN.
    ENDIF.

    ls_recy_info-%cid = ls_key-%cid.
    ls_recy_info-recoverytype = ls_key-%param-recoverytype.
    ls_recy_info-recoveryyear = ls_key-%param-recoveryyear.
    ls_recy_info-recoverynum = lv_max_no.
    ls_recy_info-recoverytype = ls_key-%param-recoverytype.
    ls_recy_info-recoverystatus = '1'.
    ls_recy_info-recoverymanagementnumber = |{ ls_recy_info-recoverytype }{ ls_recy_info-recoveryyear }{ ls_recy_info-recoverynum }|.
    APPEND ls_recy_info TO lt_recy_info.


    MODIFY ENTITIES OF zr_tbi_recy_info001 IN LOCAL MODE ENTITY zrtbirecyinfo001
    CREATE FIELDS ( uuid companycode companyname customer customername currency createddate machine recoveryalready recoverymanagementnumber
        recoverynecessaryamount recoverynum recoverypercentage recoverystatus recoverytype recoveryyear
     )
    WITH  lt_recy_info
    MAPPED mapped
    REPORTED reported
    FAILED failed.

    result = VALUE #( FOR ls_create IN lt_recy_info ( %cid = ls_create-%cid
                                                     %param = CORRESPONDING #( ls_create )
                                                    ) ).

  ENDMETHOD.



  METHOD add_prefix.
    DATA: lv_number TYPE n LENGTH 4.

    IF iv_number IS INITIAL.
      RETURN.
    ENDIF.

    lv_number = iv_number.
    rv_number = lv_number.


  ENDMETHOD.

  METHOD validate_input.
    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    IF sy-subrc <> 0.
      APPEND VALUE #( %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                    textid = VALUE #( msgid = 'ZBI003' msgno = '000' )
                                                  )
                      %state_area = 'VALIDATE_CREATE'
                     ) TO reported-zrtbirecyinfo001.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_tbi_recy_info001 IN LOCAL MODE ENTITY zrtbirecyinfo001
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

    LOOP AT lt_data INTO DATA(ls_data).

      IF ls_data-companycode IS INITIAL.
        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                     textid = VALUE #( msgid = 'ZBI003' msgno = '001' )
                                                   )
                       %action-create_recycle = if_abap_behv=>mk-on

                       %state_area = 'VALIDATE_CREATE'
                      ) TO reported-zrtbirecyinfo001.


        CONTINUE.
      ENDIF.

      IF ls_data-recoverytype IS INITIAL.
        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                     textid = VALUE #( msgid = 'ZBI003' msgno = '002' )
                                                   )
                       %state_area = 'VALIDATE_CREATE'
                      ) TO reported-zrtbirecyinfo001.
        RETURN.
      ENDIF.

      IF ls_data-customer IS INITIAL.
        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                     textid = VALUE #( msgid = 'ZBI003' msgno = '003' )
                                                   )
                       %state_area = 'VALIDATE_CREATE'
                      ) TO reported-zrtbirecyinfo001.
        RETURN.
      ENDIF.

      IF ls_data-recoveryyear IS INITIAL.
        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                     textid = VALUE #( msgid = 'ZBI003' msgno = '004' )
                                                   )
                       %state_area = 'VALIDATE_CREATE'
                      ) TO reported-zrtbirecyinfo001.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD determine_detail.
  ENDMETHOD.

ENDCLASS.
