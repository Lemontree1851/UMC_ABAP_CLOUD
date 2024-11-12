CLASS lhc_zi_bi003_report_001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_bi003_report_001 RESULT result.

    METHODS determine_detail FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_bi003_report_001~determine_detail.

    METHODS validate_input FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_bi003_report_001~validate_input.

ENDCLASS.

CLASS lhc_zi_bi003_report_001 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD determine_detail.
    READ ENTITIES OF zi_bi003_report_001 IN LOCAL MODE ENTITY zi_bi003_report_001
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

    CHECK lt_data IS NOT INITIAL.

    SELECT comp~companycode,
           comp~companycodename,
           comp~currency
      FROM i_companycode AS comp
      INNER JOIN @lt_data AS dat
      ON comp~companycode = dat~companycode
      INTO TABLE @DATA(lt_company).

    SELECT cust~customer,
           cust~customername
    FROM i_customer WITH PRIVILEGED ACCESS AS cust
    INNER JOIN @lt_data AS dat
    ON cust~customer = dat~customer
    INTO TABLE @DATA(lt_customer).

    LOOP AT lt_data INTO DATA(ls_data).
      READ TABLE lt_company INTO DATA(ls_company) WITH KEY companycode = ls_data-companycode.
      IF sy-subrc = 0.
        ls_data-companyname = ls_company-companycodename.
        ls_data-currency = ls_company-currency.
      ENDIF.

      READ TABLE lt_customer INTO DATA(ls_customer) WITH KEY customer = ls_data-customer.
      IF sy-subrc = 0.
        ls_data-customername = ls_customer-customername.
      ENDIF.

      IF ls_data-recoverynum IS INITIAL OR ls_data-recoverymanagementnumber IS INITIAL.
        ls_data-createddate = cl_abap_context_info=>get_system_date(  ).

        SELECT MAX( recovery_num ) FROM ztbi_recy_info
           WHERE recovery_type = @ls_data-recoverytype
           AND recovery_year = @ls_data-recoveryyear
           INTO @DATA(lv_max_no).

        IF lv_max_no IS INITIAL.
          lv_max_no = 1.
        ELSE.
          lv_max_no = lv_max_no + 1.
        ENDIF.

        ls_data-recoverynum = lv_max_no.
        ls_data-recoverynecessaryamount = 0.
        ls_data-recoveryalready = 0.
        ls_data-recoverypercentage = 0.
        ls_data-recoverystatus = '1'.
        ls_data-recoverymanagementnumber = |{ ls_data-recoverytype }{ ls_data-recoveryyear }{ ls_data-recoverynum }|.


        "SELECT SINGLE userdescription FROM i_user WITH PRIVILEGED ACCESS WHERE userid = @sy-uname INTO @ls_data-createdname.

        TRY.
            ls_data-createdname = cl_abap_context_info=>get_user_description(  ).
          CATCH cx_abap_context_info_error.
            SELECT SINGLE userdescription FROM i_user WITH PRIVILEGED ACCESS WHERE userid = @sy-uname INTO @ls_data-createdname.
        ENDTRY.
      ENDIF.

      MODIFY lt_data FROM ls_data.
    ENDLOOP.

    MODIFY ENTITIES OF zi_bi003_report_001 IN LOCAL MODE ENTITY zi_bi003_report_001
     UPDATE FIELDS ( companyname currency customername createddate recoverymanagementnumber recoverynecessaryamount recoverynum recoverypercentage
     recoverystatus createdname ) WITH CORRESPONDING #( lt_data ).

  ENDMETHOD.

  METHOD validate_input.
    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    IF sy-subrc <> 0.
      APPEND VALUE #( %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                    textid = VALUE #( msgid = 'ZBI003' msgno = '000' )
                                                  )
                      %state_area = 'VALIDATE_CREATE'
                     ) TO reported-zi_bi003_report_001.
      RETURN.
    ENDIF.

    READ ENTITIES OF zi_bi003_report_001 IN LOCAL MODE ENTITY zi_bi003_report_001
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

    LOOP AT lt_data INTO DATA(ls_data).

      IF ls_data-companycode IS INITIAL.
        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                     textid = VALUE #( msgid = 'ZBI003' msgno = '001' )
                                                   )

                       %state_area = 'VALIDATE_CREATE'
                      ) TO reported-zi_bi003_report_001.


        CONTINUE.
      ENDIF.

      IF ls_data-recoverytype IS INITIAL.
        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                     textid = VALUE #( msgid = 'ZBI003' msgno = '002' )
                                                   )
                       %state_area = 'VALIDATE_CREATE'
                      ) TO reported-zi_bi003_report_001.
        RETURN.
      ENDIF.

      IF ls_data-customer IS INITIAL.
        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                     textid = VALUE #( msgid = 'ZBI003' msgno = '003' )
                                                   )
                       %state_area = 'VALIDATE_CREATE'
                      ) TO reported-zi_bi003_report_001.
        RETURN.
      ENDIF.

      IF ls_data-recoveryyear IS INITIAL.
        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                     textid = VALUE #( msgid = 'ZBI003' msgno = '004' )
                                                   )
                       %state_area = 'VALIDATE_CREATE'
                      ) TO reported-zi_bi003_report_001.

        RETURN.
      ENDIF.

      SELECT SINGLE companycode FROM i_companycode WHERE companycode = @ls_data-companycode INTO @DATA(lv_companycode).
      IF lv_companycode IS INITIAL.
        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                     textid = VALUE #( msgid = 'ZBI003' msgno = '008' )
                                                   )
                       %state_area = 'VALIDATE_CREATE'
                      ) TO reported-zi_bi003_report_001.

        RETURN.
      ENDIF.

      SELECT SINGLE customer FROM i_customer WITH PRIVILEGED ACCESS WHERE customer = @ls_data-customer INTO @DATA(lv_customer).
      IF lv_customer IS INITIAL.
        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = NEW zcx_tbi_recy_info( iv_severity = if_abap_behv_message=>severity-error
                                                     textid = VALUE #( msgid = 'ZBI003' msgno = '009' )
                                                   )
                       %state_area = 'VALIDATE_CREATE'
                      ) TO reported-zi_bi003_report_001.

        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
