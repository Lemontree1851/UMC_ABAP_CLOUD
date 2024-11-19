CLASS zzcl_wf_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:tt_wf_approvaluser TYPE TABLE OF zc_wf_approvaluser.
    TYPES:tt_wf_approvalhistory TYPE TABLE OF zc_wf_approvalhistory.
    CONSTANTS: lc_zkey1        TYPE string VALUE `COMPANY_CODE`,
               lc_zkey2        TYPE string VALUE `PR_TYPE`,
               lc_zkey3        TYPE string VALUE `PR_BY`,
               lc_zkey4        TYPE string VALUE `POLINK_BY`,
               lc_zkey5        TYPE string VALUE `MAIL`,
               lc_prby_zid     TYPE string VALUE `ZMM005`,
               lc_polinkby_zid TYPE string VALUE `ZMM006`.

    INTERFACES if_oo_adt_classrun.

    CLASS-METHODS:
      check_current_node_email IMPORTING iv_workflowid    TYPE ztbc_1011-workflow_id
                                         iv_applicationid TYPE ztbc_1011-application_id
                                         iv_currentnode   TYPE ztbc_1011-current_node
                                         iv_email         TYPE string
                               EXPORTING ev_error         TYPE abap_boolean
                                         ev_errortext     TYPE string,
      get_current_node IMPORTING iv_workflowid    TYPE ztbc_1011-workflow_id
                                 iv_applicationid TYPE ztbc_1011-application_id
                                 iv_instanceid    TYPE ztbc_1011-instance_id
                       EXPORTING ev_currentnode   TYPE ztbc_1011-next_node,

      get_next_node_user IMPORTING iv_workflowid    TYPE ztbc_1011-workflow_id
                                   iv_applicationid TYPE ztbc_1011-application_id
                                   iv_nextnode      TYPE ztbc_1011-next_node
                         EXPORTING ev_error         TYPE abap_boolean
                                   ev_errortext     TYPE string
                                   ev_users         TYPE tt_wf_approvaluser,
      get_approved_user IMPORTING iv_workflowid    TYPE ztbc_1011-workflow_id
                                  iv_applicationid TYPE ztbc_1011-application_id
                                  iv_instanceid    TYPE ztbc_1011-instance_id
                        EXPORTING ev_users         TYPE tt_wf_approvaluser,
      get_application_id IMPORTING iv_workflowid    TYPE ztbc_1011-workflow_id
                                   iv_uuid          TYPE sysuuid_x16
                         EXPORTING ev_applicationid TYPE ztbc_1011-application_id
                                   ev_error         TYPE abap_boolean
                                   ev_errortext     TYPE string,
      get_next_node IMPORTING iv_workflowid    TYPE ztbc_1011-workflow_id
                              iv_applicationid TYPE ztbc_1011-application_id
                              iv_instanceid    TYPE ztbc_1011-instance_id
                              iv_currentnode   TYPE ztbc_1011-current_node OPTIONAL
                    EXPORTING ev_nextnode      TYPE ztbc_1011-next_node
                              ev_approvalend   TYPE abap_boolean
                              ev_auto          TYPE tt_wf_approvalhistory,

      add_approval_history IMPORTING iv_workflowid     TYPE ztbc_1011-workflow_id
                                     iv_instanceid     TYPE ztbc_1011-instance_id
                                     iv_applicationid  TYPE ztbc_1011-application_id
                                     iv_currentnode    TYPE ztbc_1011-current_node OPTIONAL
                                     iv_nextnode       TYPE ztbc_1011-next_node
                                     iv_operator       TYPE ztbc_1011-operator
                                     iv_email          TYPE ztbc_1011-email_address
                                     iv_approvalstatus TYPE ztbc_1011-approval_status OPTIONAL
                                     iv_remark         TYPE ztbc_1011-remark
                                     iv_reject         TYPE  abap_boolean OPTIONAL,
      get_pr_by  IMPORTING iv_workflowid    TYPE ztbc_1011-workflow_id
                           iv_applicationid TYPE ztbc_1011-application_id
                           iv_instanceid    TYPE ztbc_1011-instance_id
                 EXPORTING ev_error         TYPE abap_boolean
                           ev_errortext     TYPE string
                           ev_users         TYPE tt_wf_approvaluser,
      get_polink_by  IMPORTING iv_workflowid    TYPE ztbc_1011-workflow_id
                               iv_applicationid TYPE ztbc_1011-application_id
                               iv_instanceid    TYPE ztbc_1011-instance_id
                     EXPORTING ev_error         TYPE abap_boolean
                               ev_errortext     TYPE string
                               ev_users         TYPE tt_wf_approvaluser,
      send_emails IMPORTING iv_workflowid    TYPE ztbc_1011-workflow_id
                            iv_applicationid TYPE ztbc_1011-application_id
                            iv_instanceid    TYPE ztbc_1011-instance_id
                            iv_users         TYPE tt_wf_approvaluser
                            iv_zid           TYPE ztbc_1001-zid
                  EXPORTING ev_error         TYPE abap_boolean
                            ev_errortext     TYPE string.
  PROTECTED SECTION.
    CLASS-METHODS:
      get_nextnode IMPORTING iv_workflowid    TYPE ztbc_1011-workflow_id
                             iv_applicationid TYPE ztbc_1011-application_id
                             iv_currentnode   TYPE ztbc_1011-current_node OPTIONAL
                   EXPORTING ev_nextnode      TYPE ztbc_1011-next_node
                             ev_approvalend   TYPE abap_boolean.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_wf_utils IMPLEMENTATION.

  METHOD get_application_id.


    CASE iv_workflowid.

      WHEN 'purchaserequisition'.

        SELECT SINGLE *
        FROM ztmm_1006
        WHERE uuid = @iv_uuid
        INTO @DATA(ls_ztmm_1006).

        DATA:ls_wf_approvalpath TYPE zc_wf_approvalpath.
        ls_wf_approvalpath-prtype      = ls_ztmm_1006-pr_type.
        ls_wf_approvalpath-applydepart = ls_ztmm_1006-apply_depart.
        ls_wf_approvalpath-ordertype   = ls_ztmm_1006-order_type.
        ls_wf_approvalpath-buypurpose  = ls_ztmm_1006-buy_purpoose.
        ls_wf_approvalpath-kyoten      = ls_ztmm_1006-kyoten.
        CONDENSE:ls_wf_approvalpath-prtype,
        ls_wf_approvalpath-applydepart,
        ls_wf_approvalpath-ordertype,
        ls_wf_approvalpath-buypurpose,
        ls_wf_approvalpath-kyoten .

        SELECT SINGLE applicationid
        FROM zc_wf_approvalpath
       WHERE  prtype      = @ls_wf_approvalpath-prtype
         AND  applydepart = @ls_wf_approvalpath-applydepart
         AND  ordertype   = @ls_wf_approvalpath-ordertype
         AND  buypurpose  = @ls_wf_approvalpath-BuyPurpose
         AND  kyoten      = @ls_wf_approvalpath-kyoten
        INTO @DATA(lv_applicationid).

        ev_applicationid = lv_applicationid.
      WHEN OTHERS.

    ENDCASE.

    IF ev_applicationid IS INITIAL.
      ev_error = 'X'.
      MESSAGE s018(zbc_001) WITH ls_ztmm_1006-pr_no INTO ev_errortext.
    ENDIF.

  ENDMETHOD.

  METHOD add_approval_history.
    SELECT MAX( zseq )
      FROM zc_wf_approvalhistory
     WHERE workflowid = @iv_workflowid
       AND instanceid = @iv_instanceid
      INTO @DATA(lv_zseq).

    lv_zseq += 1.
    GET TIME STAMP FIELD DATA(lv_timestamp).
    INSERT INTO ztbc_1011 VALUES @( VALUE #( workflow_id     = iv_workflowid
                                             instance_id     = iv_instanceid
                                             zseq            = lv_zseq
                                             application_id  = iv_applicationid
                                             current_node    = iv_currentnode
                                             next_node       = iv_nextnode
                                             operator        = iv_operator
                                             approval_status = iv_approvalstatus
                                             remark          = iv_remark
                                             created_by      = sy-uname
                                             created_at      = lv_timestamp
                                             last_changed_by = sy-uname
                                             last_changed_at = lv_timestamp
                                             local_last_changed_at = lv_timestamp ) ).
    "修改订单状态
    IF iv_approvalstatus IS NOT INITIAL.
      UPDATE ztmm_1006
       SET approve_status = @iv_approvalstatus
      WHERE workflow_id = @iv_workflowid
      AND application_id = @iv_applicationid
      AND instance_id = @iv_instanceid.
    ENDIF.
    "承认撤回 标记删除过往审批历史
    IF iv_reject = abap_true.

      UPDATE ztbc_1011
       SET del = @abap_true
      WHERE workflow_id = @iv_workflowid
      AND application_id = @iv_applicationid
      AND instance_id = @iv_instanceid.

    ENDIF.
  ENDMETHOD.
  METHOD check_current_node_email.
    SELECT *
      FROM zc_wf_approvaluser
     WHERE workflowid    = @iv_workflowid
       AND applicationid = @iv_applicationid
       AND node        = @iv_currentnode
       AND emailaddress = @iv_email
      INTO TABLE @DATA(lt_approvaluser).

    IF lt_approvaluser IS INITIAL.
      SELECT SINGLE nodename
    FROM zc_wf_approvalnode
   WHERE workflowid    = @iv_workflowid
     AND applicationid = @iv_applicationid
     AND node          = @iv_currentnode
    INTO @DATA(lv_nodename).
      ev_error = 'X'.
      MESSAGE s012(zbc_001) WITH iv_currentnode lv_nodename INTO ev_errortext.
    ENDIF.
  ENDMETHOD.

  METHOD get_approved_user.
    SELECT *
      FROM zc_wf_approvalhistory
     WHERE workflowid    = @iv_workflowid
       AND applicationid = @iv_applicationid
       AND instanceid    = @iv_instanceid
       AND del NE 'X'
      INTO TABLE @DATA(lt_approvaluser).

    IF lt_approvaluser IS INITIAL.
      LOOP AT lt_approvaluser INTO DATA(ls_approvaluser).
        DATA:ls_wf_approvaluser TYPE zc_wf_approvaluser.
        CLEAR ls_wf_approvaluser.
        ls_wf_approvaluser-emailaddress = ls_approvaluser-emailaddress.
        ls_wf_approvaluser-username     = ls_approvaluser-operator.
        APPEND ls_wf_approvaluser TO ev_users.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD get_current_node.
    SELECT *
       FROM zc_wf_approvalhistory
    WHERE  workflowid    = @iv_workflowid
       AND applicationid = @iv_applicationid
       AND instanceid    = @iv_instanceid
        AND del NE 'X'
    INTO TABLE @DATA(lt_approvalhistory).

    IF lt_approvalhistory IS NOT INITIAL.
      SORT lt_approvalhistory BY createdat DESCENDING.
      READ TABLE lt_approvalhistory INTO DATA(ls_approvalhistory) INDEX 1.
      IF sy-subrc = 0.
        ev_currentnode = ls_approvalhistory-nextnode.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_nextnode.
    SELECT *
      FROM zc_wf_approvalnode
     WHERE workflowid    = @iv_workflowid
       AND applicationid = @iv_applicationid
       AND active        = @abap_true
      INTO TABLE @DATA(lt_approvalnode).

    SORT lt_approvalnode BY node.

    IF lt_approvalnode IS NOT INITIAL.
      IF iv_currentnode IS INITIAL.
        ev_nextnode = lt_approvalnode[ 1 ]-node.
      ELSE.
        DELETE lt_approvalnode WHERE node <= iv_currentnode.
        READ TABLE lt_approvalnode INTO DATA(ls_approvalnode) INDEX 1.
        IF sy-subrc = 0.
          ev_nextnode = ls_approvalnode-node.
        ELSE.
          ev_approvalend = abap_true.
        ENDIF.
      ENDIF.
    ELSE.
      ev_approvalend = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_next_node.
    SELECT *
      FROM zc_wf_approvalnode
     WHERE workflowid    = @iv_workflowid
       AND applicationid = @iv_applicationid
       AND active        = @abap_true
      INTO TABLE @DATA(lt_approvalnode).

    SORT lt_approvalnode BY node.

    IF lt_approvalnode IS NOT INITIAL.

      LOOP AT lt_approvalnode INTO DATA(ls_approvalnode) WHERE node > iv_currentnode.
        IF ls_approvalnode-autoconver IS INITIAL.
          ev_nextnode = ls_approvalnode-node.
          EXIT.
        ELSE.
          get_nextnode( EXPORTING iv_workflowid    = iv_workflowid
                                  iv_applicationid = iv_applicationid
                                  iv_currentnode   = ls_approvalnode-node
                        IMPORTING ev_nextnode      = DATA(lv_next_node)
                                  ev_approvalend   = DATA(lv_approvalend) ).
          " Automatic approval
          DATA:ls_zc_wf_approvalhistory  TYPE zc_wf_approvalhistory.
          CLEAR ls_zc_wf_approvalhistory.

          ls_zc_wf_approvalhistory-currentnode    = ls_approvalnode-node.
          ls_zc_wf_approvalhistory-nextnode       = lv_next_node.
          ls_zc_wf_approvalhistory-emailaddress   = TEXT-001.
          ls_zc_wf_approvalhistory-operator       = TEXT-001.
          ls_zc_wf_approvalhistory-remark         = TEXT-002.
          ls_zc_wf_approvalhistory-approvalstatus = '2'.
          IF lv_next_node IS INITIAL.
            ls_zc_wf_approvalhistory-approvalstatus = '3'.
          ENDIF.
          APPEND ls_zc_wf_approvalhistory TO ev_auto.

        ENDIF.
      ENDLOOP.
      IF ev_nextnode IS INITIAL.
        ev_approvalend = abap_true.
      ENDIF.

    ELSE.
      ev_approvalend = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD get_next_node_user.
    SELECT *
       FROM zc_wf_approvaluser
    WHERE  workflowid    = @iv_workflowid
       AND applicationid = @iv_applicationid
       AND node    = @iv_nextnode
       AND emailaddress IS NOT INITIAL
    INTO TABLE @ev_users.

    IF ev_users IS INITIAL.
      SELECT SINGLE nodename
        FROM zc_wf_approvalnode
       WHERE workflowid    = @iv_workflowid
         AND applicationid = @iv_applicationid
         AND node          = @iv_nextnode
        INTO @DATA(lv_nodename).
      ev_error = 'X'.
      MESSAGE s011(zbc_001) WITH iv_nextnode lv_nodename INTO ev_errortext.
    ENDIF.
  ENDMETHOD.

  METHOD get_pr_by.

    "get info
    SELECT SINGLE *
      FROM ztmm_1006
    WHERE  workflow_id    = @iv_workflowid
      AND application_id = @iv_applicationid
      AND instance_id    = @iv_instanceid
    INTO @DATA(ls_ztmm_1006).
    IF ls_ztmm_1006-pr_by IS INITIAL.
      ev_error = 'X'.
      MESSAGE s013(zbc_001) WITH ls_ztmm_1006-pr_no INTO ev_errortext.
      RETURN.
    ENDIF.
    CONDENSE ls_ztmm_1006-pr_by.

    "get PR_BY setting
    SELECT SINGLE *
      FROM ztbc_1001
    WHERE  zid   = @lc_prby_zid
      AND zkey1  = @lc_zkey3
      AND zkey2  = @lc_zkey5
      AND zvalue1 = @ls_ztmm_1006-pr_by
    INTO @DATA(ls_ztbc_1001).

    IF ls_ztbc_1001-zvalue2 IS NOT INITIAL.

      DATA:ls_wf_approvaluser TYPE zc_wf_approvaluser.
      ls_wf_approvaluser-emailaddress = ls_ztbc_1001-zvalue2.
      ls_wf_approvaluser-username     = ls_ztmm_1006-pr_by.
      APPEND ls_wf_approvaluser TO ev_users.
    ELSE.
      ev_error = 'X'.
      MESSAGE s014(zbc_001) WITH ls_ztmm_1006-pr_no ls_ztmm_1006-pr_by INTO ev_errortext.
    ENDIF.

  ENDMETHOD.

  METHOD get_polink_by.

    "get info
    SELECT SINGLE *
      FROM ztmm_1006
    WHERE  workflow_id    = @iv_workflowid
      AND application_id = @iv_applicationid
      AND instance_id    = @iv_instanceid
    INTO @DATA(ls_ztmm_1006).
    IF ls_ztmm_1006-polink_by IS INITIAL.
      ev_error = 'X'.
      MESSAGE s015(zbc_001) WITH ls_ztmm_1006-pr_no INTO ev_errortext.
      RETURN.
    ENDIF.

    CONDENSE ls_ztmm_1006-polink_by.

    "get PR_BY setting
    SELECT SINGLE *
      FROM ztbc_1001
    WHERE  zid   = @lc_polinkby_zid
      AND zkey1  = @lc_zkey4
      AND zkey2  = @lc_zkey5
      AND zvalue1 = @ls_ztmm_1006-polink_by
    INTO @DATA(ls_ztbc_1001).

    IF ls_ztbc_1001-zvalue2 IS NOT INITIAL.

      DATA:ls_wf_approvaluser TYPE zc_wf_approvaluser.
      ls_wf_approvaluser-emailaddress = ls_ztbc_1001-zvalue2.
      ls_wf_approvaluser-username     = ls_ztmm_1006-polink_by.
      APPEND ls_wf_approvaluser TO ev_users.
    ELSE.
      ev_error = 'X'.
      MESSAGE s016(zbc_001) WITH ls_ztmm_1006-pr_no ls_ztmm_1006-polink_by INTO ev_errortext.
    ENDIF.

  ENDMETHOD.

  METHOD send_emails.
    DATA: lt_recipient    TYPE cl_bcs_mail_message=>tyt_recipient,
          lt_attachment   TYPE zzcl_common_utils=>tt_attachment,
          lv_subject      TYPE cl_bcs_mail_message=>ty_subject,
          lv_main_content TYPE string,
          lv_filename     TYPE string,
          lv_timestamp    TYPE timestamp,
          lv_timezone     TYPE tznzone.

    "get companycode / PR_TYPE
    SELECT SINGLE *
      FROM ztmm_1006
    WHERE  workflow_id    = @iv_workflowid
      AND application_id = @iv_applicationid
      AND instance_id    = @iv_instanceid
    INTO @DATA(ls_ztmm_1006).

    "get email setting
    SELECT SINGLE *
      FROM ztbc_1001
    WHERE  zid   = @iv_zid
      AND zkey1  = @lc_zkey1
      AND zkey2  = @lc_zkey2
    INTO @DATA(ls_ztbc_1001).
    IF sy-subrc <> 0.
      ev_error = 'X'.
      MESSAGE s017(zbc_001) WITH iv_zid INTO ev_errortext.
    ENDIF.

    lt_recipient = VALUE #( FOR item IN iv_users ( address = item-emailaddress ) ).
    SORT lt_recipient BY address.
    DELETE ADJACENT DUPLICATES FROM lt_recipient COMPARING address.

    lv_subject = ls_ztbc_1001-zvalue3.
    REPLACE ALL OCCURRENCES OF '&1' IN lv_subject  WITH ls_ztmm_1006-pr_by .
    REPLACE ALL OCCURRENCES OF '&2' IN lv_subject  WITH ls_ztmm_1006-pr_no .
    IF ls_ztbc_1001-zkey4 IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '&1' IN ls_ztbc_1001-zvalue4  WITH ls_ztmm_1006-pr_by .
      REPLACE ALL OCCURRENCES OF '&2' IN ls_ztbc_1001-zvalue4  WITH ls_ztmm_1006-pr_no .
      lv_main_content = lv_main_content && |<p style="line-height: 0.5">{ ls_ztbc_1001-zvalue4 }</p><div style="height: 5px;"></div>|.
    ENDIF.
    IF ls_ztbc_1001-zkey5 IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '&1' IN ls_ztbc_1001-zvalue5  WITH ls_ztmm_1006-pr_by .
      REPLACE ALL OCCURRENCES OF '&2' IN ls_ztbc_1001-zvalue5  WITH ls_ztmm_1006-pr_no .
      lv_main_content = lv_main_content && |<p style="line-height: 0.5">{ ls_ztbc_1001-zvalue5 }</p>|.
    ENDIF.
    IF ls_ztbc_1001-zkey6 IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '&1' IN ls_ztbc_1001-zvalue6  WITH ls_ztmm_1006-pr_by .
      REPLACE ALL OCCURRENCES OF '&2' IN ls_ztbc_1001-zvalue6  WITH ls_ztmm_1006-pr_no .
      lv_main_content = lv_main_content && |<p style="line-height: 0.5">{ ls_ztbc_1001-zvalue6 }</p>|.
    ENDIF.


    TRY.
        zzcl_common_utils=>send_email( EXPORTING iv_subject      = lv_subject
                                                 iv_main_content = lv_main_content
                                                 it_recipient    = lt_recipient
                                       IMPORTING et_status       = DATA(lt_status) ).
      CATCH cx_bcs_mail INTO DATA(lx_bcs_mail).
        " handle exception
        DATA(rv_error_text) = lx_bcs_mail->get_longtext(  ).
        ev_error = 'X'.
        ev_errortext = rv_error_text.
    ENDTRY.

  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
**********************************************************************
* DEMO
**********************************************************************
    TRY.
        DATA(lv_instanceid) = cl_system_uuid=>create_uuid_x16_static(  ).
        ##NO_HANDLER
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.

*&--发起人提交
    get_next_node( EXPORTING iv_workflowid    = 'purchaserequisition'
                             iv_applicationid = 1001
                             iv_instanceid    = lv_instanceid
                   IMPORTING ev_nextnode      = DATA(lv_next_node)
                             ev_approvalend   = DATA(lv_approvalend) ).

    add_approval_history(
      iv_workflowid     = 'purchaserequisition'
      iv_instanceid     = lv_instanceid
      iv_applicationid  = 1001
      iv_nextnode       = lv_next_node
      iv_operator       = 'XINLEI.XU(xinlei.xu@sh.shin-china.com)'
      iv_email          = 'xinlei.xu@sh.shin-china.com'
      iv_approvalstatus = '2'
      iv_remark         = '提交审批'
    ).

    DATA:lv_1006 TYPE ztmm_1006.
    lv_1006-workflow_id    = 'purchaserequisition'.
    lv_1006-application_id = 1001.
    lv_1006-instance_id    = lv_instanceid.

    UPDATE ztmm_1006
       SET workflow_id = @lv_1006-workflow_id
         , application_id = @lv_1006-application_id
         , instance_id = @lv_1006-instance_id
    WHERE pr_no = '1000005'.

**&--审批中
*    get_next_node( EXPORTING iv_workflowid    = 'purchaserequisition'
*                             iv_applicationid = 1001
*                             iv_currentnode   = 10
*                   IMPORTING ev_nextnode      = lv_next_node
*                             ev_approvalend   = lv_approvalend ).
*
*    add_approval_history(
*      iv_workflowid     = 'purchaserequisition'
*      iv_instanceid     = lv_instanceid
*      iv_applicationid  = 1001
*      iv_currentnode    = 10
*      iv_nextnode       = lv_next_node
*      iv_operator       = 'XINLEI.XU(xinlei.xu@sh.shin-china.com)'
*      iv_remark         = '审批通过，无意见'
*    ).
**********************************************************************
  ENDMETHOD.

ENDCLASS.
