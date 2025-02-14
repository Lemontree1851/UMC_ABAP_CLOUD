FUNCTION zzfm_dtimp_tbc1009.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IO_DATA) TYPE REF TO  DATA OPTIONAL
*"     VALUE(IV_STRUC) TYPE  ZZE_STRUCTURENAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(EO_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
**********************************************************************

  DATA: ls_data TYPE zzs_dtimp_tbc1009,
        lt_data TYPE TABLE OF zzs_dtimp_tbc1009,
        ls_node TYPE ztbc_1009,
        lt_node TYPE TABLE OF ztbc_1009,
        ls_user TYPE ztbc_1010,
        lt_user TYPE TABLE OF ztbc_1010.

  CREATE DATA eo_data TYPE TABLE OF (iv_struc).

  eo_data->* = io_data->*.

*  SELECT * FROM ztbc_1009 WHERE workflow_id = 'purchaserequisition' INTO TABLE @DATA(lt_db_node). "#EC CI_ALL_FIELDS_NEEDED
*  SELECT * FROM ztbc_1010 WHERE workflow_id = 'purchaserequisition' INTO TABLE @DATA(lt_db_user). "#EC CI_ALL_FIELDS_NEEDED
*  SORT lt_db_node BY application_id node.
*  SORT lt_db_user BY application_id node zseq.

  LOOP AT eo_data->* ASSIGNING FIELD-SYMBOL(<line>).
    CLEAR ls_data.
    ls_data-application_id = <line>-('APPLICATION_ID').
    ls_data-node           = <line>-('NODE').
    ls_data-node_name      = <line>-('NODE_NAME').
    ls_data-auto_conver    = <line>-('AUTO_CONVER').
    ls_data-active         = <line>-('ACTIVE').
    ls_data-zseq           = <line>-('ZSEQ').
    ls_data-user_name      = <line>-('USER_NAME').
    ls_data-email_address  = <line>-('EMAIL_ADDRESS').

*    READ TABLE lt_db_node TRANSPORTING NO FIELDS WITH KEY application_id = ls_data-application_id
*                                                          node = ls_data-node BINARY SEARCH.
*    IF sy-subrc = 0.
*      <line>-('Type') = 'E'.
*      <line>-('Message') = |アプリケーションID { ls_data-application_id } ノード { ls_data-node } はすでに存在します。|.
*      CONTINUE.
*    ENDIF.
*
*    READ TABLE lt_db_user TRANSPORTING NO FIELDS WITH KEY application_id = ls_data-application_id
*                                                          node = ls_data-node
*                                                          zseq = ls_data-zseq BINARY SEARCH.
*    IF sy-subrc = 0.
*      <line>-('Type') = 'E'.
*      <line>-('Message') = |アプリケーションID { ls_data-application_id } ノード { ls_data-node } シーケンス番号 { ls_data-zseq } はすでに存在します。|.
*      CONTINUE.
*    ENDIF.

    APPEND ls_data TO lt_data.
  ENDLOOP.

  DATA(lt_node_temp) = lt_data.
  SORT lt_node_temp BY application_id node.
  DELETE ADJACENT DUPLICATES FROM lt_node_temp COMPARING application_id node.

  LOOP AT lt_node_temp INTO DATA(ls_node_temp).
    CLEAR ls_node.
    ls_node = CORRESPONDING #( ls_node_temp ).
    ls_node-workflow_id = 'purchaserequisition'.
    ls_node-created_by = sy-uname.
    GET TIME STAMP FIELD ls_node-created_at.
    ls_node-last_changed_by = sy-uname.
    GET TIME STAMP FIELD ls_node-last_changed_at.
    GET TIME STAMP FIELD ls_node-local_last_changed_at.

    MODIFY ztbc_1009 FROM @ls_node.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      READ TABLE eo_data->* ASSIGNING <line> WITH KEY ('APPLICATION_ID') = ls_data-application_id
                                                      ('NODE') = ls_data-node. "#EC CI_ANYSEQ
      IF <line> IS ASSIGNED.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        <line>-('Type') = 'E'.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_data INTO ls_data.
    CLEAR ls_user.
    ls_user = CORRESPONDING #( ls_data ).
    ls_user-workflow_id = 'purchaserequisition'.
    ls_user-created_by = sy-uname.
    GET TIME STAMP FIELD ls_user-created_at.
    ls_user-last_changed_by = sy-uname.
    GET TIME STAMP FIELD ls_user-last_changed_at.
    GET TIME STAMP FIELD ls_user-local_last_changed_at.

    READ TABLE eo_data->* ASSIGNING <line> WITH KEY ('APPLICATION_ID') = ls_data-application_id
                                                    ('NODE') = ls_data-node
                                                    ('ZSEQ') = ls_data-zseq. "#EC CI_ANYSEQ

    MODIFY ztbc_1010 FROM @ls_user.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      IF <line> IS ASSIGNED.
        <line>-('Type') = 'S'.
        <line>-('Message') = |データが保存されました。|.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
      IF <line> IS ASSIGNED.
        <line>-('Type') = 'E'.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno INTO <line>-('Message') WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
