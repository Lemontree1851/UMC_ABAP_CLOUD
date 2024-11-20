CLASS lhc_zzr_dtimp_conf DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR configuration
        RESULT result,
      fillstartrow FOR DETERMINE ON MODIFY
        IMPORTING keys FOR configuration~fillstartrow,
      validationmandatory FOR VALIDATE ON SAVE
        IMPORTING keys FOR configuration~validationmandatory,
      precheck_delete FOR PRECHECK
        IMPORTING keys FOR DELETE configuration.
ENDCLASS.

CLASS lhc_zzr_dtimp_conf IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD fillstartrow.
    READ ENTITIES OF zzr_dtimp_conf IN LOCAL MODE
    ENTITY configuration
    FIELDS ( startrow )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

    LOOP AT lt_data INTO DATA(ls_data) WHERE startrow IS INITIAL.
      ##EML_IN_LOOP_OK
      MODIFY ENTITIES OF zzr_dtimp_conf IN LOCAL MODE
      ENTITY configuration
      UPDATE FIELDS ( startrow )
      WITH VALUE #( ( %tky = ls_data-%tky
                      startrow = 2
                      %control-startrow = if_abap_behv=>mk-on ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validationmandatory.
    READ ENTITIES OF zzr_dtimp_conf IN LOCAL MODE
    ENTITY configuration
    FIELDS ( object functionname structurename sheetname startcolumn templatecontent )
    WITH CORRESPONDING #( keys )
    RESULT DATA(configurations).

    LOOP AT configurations ASSIGNING FIELD-SYMBOL(<lfs_conf>).
      IF <lfs_conf>-object IS INITIAL.
        APPEND VALUE #( %tky = <lfs_conf>-%tky ) TO failed-configuration.
        APPEND VALUE #( %tky = <lfs_conf>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = 'Import Object is mandatory.' )
                        %element-object = if_abap_behv=>mk-on
                       ) TO reported-configuration.
      ENDIF.
      IF <lfs_conf>-functionname IS INITIAL.
        APPEND VALUE #( %tky = <lfs_conf>-%tky ) TO failed-configuration.
        APPEND VALUE #( %tky = <lfs_conf>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = 'Function Module Name is mandatory.' )
                        %element-functionname = if_abap_behv=>mk-on
                       ) TO reported-configuration.
      ENDIF.
      IF <lfs_conf>-structurename IS INITIAL.
        APPEND VALUE #( %tky = <lfs_conf>-%tky ) TO failed-configuration.
        APPEND VALUE #( %tky = <lfs_conf>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = 'Structure Name is mandatory.' )
                        %element-structurename = if_abap_behv=>mk-on
                       ) TO reported-configuration.
      ENDIF.
      IF <lfs_conf>-sheetname IS INITIAL.
        APPEND VALUE #( %tky = <lfs_conf>-%tky ) TO failed-configuration.
        APPEND VALUE #( %tky = <lfs_conf>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = 'Sheet Name is mandatory.' )
                        %element-sheetname = if_abap_behv=>mk-on
                       ) TO reported-configuration.
      ENDIF.
      IF <lfs_conf>-startcolumn IS INITIAL.
        APPEND VALUE #( %tky = <lfs_conf>-%tky ) TO failed-configuration.
        APPEND VALUE #( %tky = <lfs_conf>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = 'Start Column is mandatory.' )
                        %element-startcolumn = if_abap_behv=>mk-on
                       ) TO reported-configuration.
      ELSEIF <lfs_conf>-startcolumn <> 'A'.
        APPEND VALUE #( %tky = <lfs_conf>-%tky ) TO failed-configuration.
        APPEND VALUE #( %tky = <lfs_conf>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = 'The current version only supports reading from column A.' )
                        %element-startcolumn = if_abap_behv=>mk-on
                       ) TO reported-configuration.
      ENDIF.
      IF <lfs_conf>-templatecontent IS INITIAL.
        APPEND VALUE #( %tky = <lfs_conf>-%tky ) TO failed-configuration.
        APPEND VALUE #( %tky = <lfs_conf>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = 'Template is mandatory.' )
                        %element-templatecontent = if_abap_behv=>mk-on
                       ) TO reported-configuration.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT uuidfile,
           uuidconf,
           object
      FROM zzc_dtimp_files
       FOR ALL ENTRIES IN @keys
     WHERE uuidconf = @keys-uuidconf
      INTO TABLE @DATA(lt_files).
    SORT lt_files BY uuidconf.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      READ TABLE lt_files ASSIGNING FIELD-SYMBOL(<lfs_file>) WITH KEY uuidconf = <lfs_key>-uuidconf BINARY SEARCH.
      IF sy-subrc = 0.
        DATA(lv_text) = |You cannot delete { <lfs_file>-object } because it is used.|.
        APPEND VALUE #( %tky = <lfs_key>-%tky ) TO failed-configuration.
        APPEND VALUE #( %tky = <lfs_key>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_text )
                       ) TO reported-configuration.
      ENDIF.
    ENDLOOP.

    READ ENTITIES OF zzr_dtimp_conf IN LOCAL MODE
    ENTITY configuration
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    FAILED DATA(ls_failed)
    REPORTED DATA(ls_reported).

    DATA(lv_text1) = |！！！临时检查，防止错删！！！|.
    DATA(lv_text2) = |1、修改<ObjectName>字段值为：DEL2024，再次点击删除|.
    DATA(lv_text3) = |2、请联系技术人员：许鑫磊|.

    LOOP AT lt_result INTO DATA(ls_result).
      IF ls_result-objectname <> 'DEL2024'.
        APPEND VALUE #( %tky = <lfs_key>-%tky ) TO failed-configuration.
        INSERT VALUE #( %tky = <lfs_key>-%tky
                        %msg = new_message_with_text( text = lv_text3 ) ) INTO TABLE reported-configuration.
        INSERT VALUE #( %tky = <lfs_key>-%tky
                        %msg = new_message_with_text( text = lv_text2 ) ) INTO TABLE reported-configuration.
        INSERT VALUE #( %tky = <lfs_key>-%tky
                        %msg = new_message_with_text( text = lv_text1 ) ) INTO TABLE reported-configuration.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
