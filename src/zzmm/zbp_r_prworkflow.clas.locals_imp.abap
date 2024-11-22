CLASS lhc_purchasereq DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF ty_batchupload.
            INCLUDE TYPE zc_prworkflow.
    TYPES:  remark TYPE ztbc_1011-remark.
    TYPES:  useremail TYPE string.
    TYPES:  userfullname TYPE string.
    TYPES:  timezone TYPE string.
    TYPES: row TYPE i,
           END OF ty_batchupload.
    TYPES:tt_batchupload TYPE TABLE OF ty_batchupload.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR purchasereq RESULT result.

    METHODS batchprocess FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~batchprocess RESULT result.

    METHODS createpurchaseorder FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~createpurchaseorder RESULT result.

    METHODS acceptprwf FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~acceptprwf RESULT result.
    METHODS rejectprwf FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~rejectprwf RESULT result.
    METHODS checkrecords FOR VALIDATE ON SAVE
      IMPORTING keys FOR purchasereq~checkrecords.
    METHODS application FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~application RESULT result.
    METHODS revoke FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~revoke RESULT result.
    METHODS check   CHANGING ct_data TYPE tt_batchupload.
    METHODS accept  CHANGING ct_data TYPE tt_batchupload.
    METHODS reject  CHANGING ct_data TYPE tt_batchupload.
ENDCLASS.

CLASS lhc_purchasereq IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD batchprocess.
  ENDMETHOD.

  METHOD createpurchaseorder.
  ENDMETHOD.

  METHOD acceptprwf.
    DATA:
      records TYPE TABLE OF ty_batchupload,
      record  LIKE LINE OF records,
      lv_msg  TYPE string.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).

      accept( CHANGING ct_data = records ).

      DATA(lv_json) = /ui2/cl_json=>serialize( records ).
      APPEND VALUE #( %cid    = key-%cid
                      %param  = VALUE #( zzkey = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.
  METHOD rejectprwf.
    DATA:
      records TYPE TABLE OF ty_batchupload,
      record  LIKE LINE OF records,
      lv_msg  TYPE string.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).

      reject( CHANGING ct_data = records ).

      DATA(lv_json) = /ui2/cl_json=>serialize( records ).
      APPEND VALUE #( %cid    = key-%cid
                      %param  = VALUE #( zzkey = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.
  METHOD check.

  ENDMETHOD.
  METHOD accept.

    DATA:lv_current_node TYPE ztbc_1011-current_node.
    DATA:lv_next_node    TYPE ztbc_1011-current_node.
    DATA:lv_approvalend  TYPE abap_boolean.
    DATA:lv_operator TYPE  ztbc_1011-operator.
    DATA:lv_ev_error TYPE abap_boolean.
    DATA:lv_error_text TYPE string.
    DATA:lv_users TYPE STANDARD TABLE OF zc_wf_approvaluser.
    DATA:lv_users_prby TYPE STANDARD TABLE OF zc_wf_approvaluser.
    DATA:lv_users_polink TYPE STANDARD TABLE OF zc_wf_approvaluser.
    DATA:lv_auto TYPE STANDARD TABLE OF zc_wf_approvalhistory.
    LOOP AT ct_data INTO DATA(cs_data).

      CLEAR:lv_current_node,lv_next_node,lv_approvalend, lv_operator,lv_ev_error,lv_error_text,lv_users.
      CLEAR:lv_users_prby,lv_users_polink.
      CLEAR:lv_auto.

      lv_operator = cs_data-userfullname && '(' && cs_data-useremail && ')' .

*&--获取当前节点
      zzcl_wf_utils=>get_current_node( EXPORTING iv_workflowid     = cs_data-workflowid
                                                 iv_applicationid  = cs_data-applicationid
                                                 iv_instanceid     = cs_data-instanceid
                                       IMPORTING ev_currentnode    = lv_current_node ).
*&--check下一节点的email是否匹配当前用户
      zzcl_wf_utils=>check_current_node_email( EXPORTING iv_workflowid     = cs_data-workflowid
                                        iv_applicationid  = cs_data-applicationid
                                        iv_currentnode      = lv_current_node
                                         iv_email        = cs_data-useremail
                              IMPORTING ev_errortext     = lv_error_text
                                        ev_error         = lv_ev_error ).
*&--有错 停止
      IF lv_ev_error IS NOT INITIAL.
        cs_data-message = lv_error_text.
        cs_data-type = 'E'.
        MODIFY ct_data FROM cs_data TRANSPORTING message type.
        CONTINUE.
      ENDIF.
*&--获取下一节点
      zzcl_wf_utils=>get_next_node( EXPORTING iv_workflowid     = cs_data-workflowid
                                              iv_applicationid  = cs_data-applicationid
                                              iv_instanceid     = cs_data-instanceid
                                              iv_currentnode    = lv_current_node
                                    IMPORTING ev_nextnode       = lv_next_node
                                              ev_approvalend    = lv_approvalend
                                              ev_auto           = lv_auto ).
*&--获取邮件发送人
      IF lv_approvalend NE abap_true.
*&--获取再下一节点的user
        zzcl_wf_utils=>get_next_node_user( EXPORTING iv_workflowid    = cs_data-workflowid
                                                     iv_applicationid = cs_data-applicationid
                                                     iv_nextnode      = lv_next_node
                                           IMPORTING ev_error         = lv_ev_error
                                                     ev_errortext     = lv_error_text
                                                     ev_users         = lv_users ).
      ELSE.
*&--获取pr_by polink
        zzcl_wf_utils=>get_pr_by( EXPORTING iv_workflowid    = cs_data-workflowid
                                         iv_applicationid = cs_data-applicationid
                                          iv_instanceid     = cs_data-instanceid
                               IMPORTING ev_error         = lv_ev_error
                                         ev_errortext     = lv_error_text
                                         ev_users         = lv_users_prby ).

        zzcl_wf_utils=>get_polink_by( EXPORTING iv_workflowid    = cs_data-workflowid
                                               iv_applicationid = cs_data-applicationid
                                                iv_instanceid     = cs_data-instanceid
                                     IMPORTING ev_error         = lv_ev_error
                                               ev_errortext     = lv_error_text
                                               ev_users         = lv_users_polink ).
      ENDIF.

*&--有错 停止
      IF lv_ev_error IS NOT INITIAL.
        cs_data-message = lv_error_text.
        cs_data-type = 'E'.
        MODIFY ct_data FROM cs_data TRANSPORTING message type.
        CONTINUE.
      ENDIF.

*&--下一节点不存在 当前就是最终节点 终点邮件和节点变更
      IF lv_approvalend = abap_true.
        "邮件通知 POLINK_BY & PR_BY
        zzcl_wf_utils=>send_emails( EXPORTING iv_workflowid    = cs_data-workflowid
                                              iv_applicationid = cs_data-applicationid
                                              iv_instanceid    = cs_data-instanceid
                                              iv_users         =  lv_users_prby
                                              iv_zid           = 'ZMM015'
                                     IMPORTING ev_error         = lv_ev_error
                                               ev_errortext     = lv_error_text ).
        IF lv_ev_error IS NOT INITIAL.
          cs_data-message = lv_error_text.
          cs_data-type = 'E'.
          MODIFY ct_data FROM cs_data TRANSPORTING message type.
          CONTINUE.
        ENDIF.
        zzcl_wf_utils=>send_emails( EXPORTING iv_workflowid    = cs_data-workflowid
                                      iv_applicationid = cs_data-applicationid
                                      iv_instanceid    = cs_data-instanceid
                                      iv_users         = lv_users_polink
                                      iv_zid           = 'ZMM016'
                             IMPORTING ev_error         = lv_ev_error
                                       ev_errortext     = lv_error_text ).
        IF lv_ev_error IS NOT INITIAL.
          cs_data-message = lv_error_text.
          cs_data-type = 'E'.
          MODIFY ct_data FROM cs_data TRANSPORTING message type.
          CONTINUE.
        ENDIF.
        zzcl_wf_utils=>add_approval_history(
         iv_workflowid     = cs_data-workflowid
         iv_instanceid     = cs_data-instanceid
         iv_applicationid  = cs_data-applicationid
         iv_currentnode    = lv_current_node
         iv_nextnode       = lv_next_node
         iv_operator       = lv_operator
         iv_email          = cs_data-emailaddress
         iv_remark         = cs_data-remark
         iv_approvalstatus = '3'
       ).
        cs_data-message = '成功'.
        cs_data-type = 'S'.
        MODIFY ct_data FROM cs_data TRANSPORTING message type.
      ENDIF.

*&--下一节点存在 正常流程邮件和节点变更
      IF lv_approvalend = abap_false.
        zzcl_wf_utils=>send_emails( EXPORTING iv_workflowid    = cs_data-workflowid
                                iv_applicationid = cs_data-applicationid
                                iv_instanceid    = cs_data-instanceid
                                iv_users         = lv_users
                                iv_zid           = 'ZMM013'
                       IMPORTING ev_error         = lv_ev_error
                                 ev_errortext     = lv_error_text ).
        IF lv_ev_error IS NOT INITIAL.
          cs_data-message = lv_error_text.
          cs_data-type = 'E'.
          MODIFY ct_data FROM cs_data TRANSPORTING message type.
          CONTINUE.
        ENDIF.
        zzcl_wf_utils=>add_approval_history(
          iv_workflowid     = cs_data-workflowid
          iv_instanceid     = cs_data-instanceid
          iv_applicationid  = cs_data-applicationid
          iv_currentnode    = lv_current_node
          iv_nextnode       = lv_next_node
          iv_operator       = lv_operator
          iv_email          = cs_data-emailaddress
          iv_remark         = cs_data-remark
          iv_approvalstatus = '2'
        ).
        cs_data-message = '成功'.
        cs_data-type = 'S'.
        MODIFY ct_data FROM cs_data TRANSPORTING message type.
        "邮件通知下一层的users
      ENDIF.

      IF lv_auto IS NOT INITIAL.

        LOOP AT lv_auto INTO DATA(ls_auto).

          WAIT UP TO  1 SECONDS.
          "for timeline
          zzcl_wf_utils=>add_approval_history(
        iv_workflowid     = cs_data-workflowid
        iv_instanceid     = cs_data-instanceid
        iv_applicationid  = cs_data-applicationid
        iv_currentnode    = ls_auto-currentnode
        iv_nextnode       = ls_auto-nextnode
        iv_operator       = ls_auto-operator
        iv_email          = ls_auto-emailaddress
        iv_remark         = ls_auto-remark
        iv_approvalstatus = ls_auto-approvalstatus
      ).
          cs_data-message = '成功'.
          cs_data-type = 'S'.
          MODIFY ct_data FROM cs_data TRANSPORTING message type.
        ENDLOOP.


      ENDIF.

    ENDLOOP.
  ENDMETHOD.
  METHOD reject.

    DATA:lv_current_node TYPE ztbc_1011-current_node.
    DATA:lv_next_node    TYPE ztbc_1011-current_node.
    DATA:lv_approvalend  TYPE abap_boolean.
    DATA:lv_operator TYPE  ztbc_1011-operator.
    DATA:lv_ev_error TYPE abap_boolean.
    DATA:lv_error_text TYPE string.
    DATA:lv_users TYPE STANDARD TABLE OF zc_wf_approvaluser.
    DATA:lv_users_prby TYPE STANDARD TABLE OF zc_wf_approvaluser.
    DATA:lv_users_polink TYPE STANDARD TABLE OF zc_wf_approvaluser.
    LOOP AT ct_data INTO DATA(cs_data).

      CLEAR:lv_current_node,lv_next_node,lv_approvalend, lv_operator,lv_ev_error,lv_error_text,lv_users.
      CLEAR:lv_users_prby,lv_users_polink.

      lv_operator = cs_data-userfullname && '(' && cs_data-useremail && ')' .

*&--获取当前节点
      zzcl_wf_utils=>get_current_node( EXPORTING iv_workflowid     = cs_data-workflowid
                                                 iv_applicationid  = cs_data-applicationid
                                                 iv_instanceid     = cs_data-instanceid
                                       IMPORTING ev_currentnode    = lv_current_node ).
*&--check下一节点的email是否匹配当前用户
      zzcl_wf_utils=>check_current_node_email( EXPORTING iv_workflowid     = cs_data-workflowid
                                        iv_applicationid  = cs_data-applicationid
                                        iv_currentnode      = lv_current_node
                                         iv_email        = cs_data-useremail
                              IMPORTING ev_errortext     = lv_error_text
                                        ev_error         = lv_ev_error ).
*&--有错 停止
      IF lv_ev_error IS NOT INITIAL.
        cs_data-message = lv_error_text.
        cs_data-type = 'E'.
        MODIFY ct_data FROM cs_data TRANSPORTING message type.
        CONTINUE.
      ENDIF.

*&--获取邮件发送人

*&--获取已经审批的人
*      zzcl_wf_utils=>get_approved_user( EXPORTING iv_workflowid    = cs_data-workflowid
*                                        iv_applicationid = cs_data-applicationid
*                                        iv_instanceid    = cs_data-instanceid
*                             IMPORTING  ev_users         = lv_users ).
*&--获取pr_by polink
      zzcl_wf_utils=>get_pr_by( EXPORTING iv_workflowid    = cs_data-workflowid
                                       iv_applicationid = cs_data-applicationid
                                        iv_instanceid     = cs_data-instanceid
                             IMPORTING ev_error         = lv_ev_error
                                       ev_errortext     = lv_error_text
                                       ev_users         = lv_users_prby ).

      zzcl_wf_utils=>get_polink_by( EXPORTING iv_workflowid    = cs_data-workflowid
                                             iv_applicationid = cs_data-applicationid
                                              iv_instanceid     = cs_data-instanceid
                                   IMPORTING ev_error         = lv_ev_error
                                             ev_errortext     = lv_error_text
                                             ev_users         = lv_users_polink ).
*&--有错 停止
      IF lv_ev_error IS NOT INITIAL.
        cs_data-message = lv_error_text.
        cs_data-type = 'E'.
        MODIFY ct_data FROM cs_data TRANSPORTING message type.
        CONTINUE.
      ENDIF.

*&--发送撤回邮件
      "邮件通知   PR_BY
      zzcl_wf_utils=>send_emails( EXPORTING iv_workflowid    = cs_data-workflowid
                                            iv_applicationid = cs_data-applicationid
                                            iv_instanceid    = cs_data-instanceid
                                            iv_users         =  lv_users_prby
                                            iv_zid           = 'ZMM016'
                                   IMPORTING ev_error         = lv_ev_error
                                             ev_errortext     = lv_error_text ).
      IF lv_ev_error IS NOT INITIAL.
        cs_data-message = lv_error_text.
        cs_data-type = 'E'.
        MODIFY ct_data FROM cs_data TRANSPORTING message type.
        CONTINUE.
      ENDIF.
      "邮件通知   polink
      zzcl_wf_utils=>send_emails( EXPORTING iv_workflowid    = cs_data-workflowid
                                            iv_applicationid = cs_data-applicationid
                                            iv_instanceid    = cs_data-instanceid
                                            iv_users         = lv_users_polink
                                            iv_zid           = 'ZMM016'
                                   IMPORTING ev_error         = lv_ev_error
                                             ev_errortext     = lv_error_text ).
      IF lv_ev_error IS NOT INITIAL.
        cs_data-message = lv_error_text.
        cs_data-type = 'E'.
        MODIFY ct_data FROM cs_data TRANSPORTING message type.
        CONTINUE.
      ENDIF.
      zzcl_wf_utils=>add_approval_history(
       iv_workflowid     = cs_data-workflowid
       iv_instanceid     = cs_data-instanceid
       iv_applicationid  = cs_data-applicationid
       iv_currentnode    = lv_current_node
       iv_nextnode       = lv_next_node
       iv_operator       = lv_operator
       iv_email          = cs_data-emailaddress
       iv_remark         = cs_data-remark
       iv_approvalstatus = '1'
     ).

      cs_data-message = '成功'.
      cs_data-type = 'S'.

      MODIFY ct_data FROM cs_data TRANSPORTING message type.
      "邮件通知下一层的users


    ENDLOOP.
  ENDMETHOD.
  METHOD checkrecords.
  ENDMETHOD.

  METHOD application.
    DATA:
      records       TYPE TABLE OF ty_batchupload,
      record        LIKE LINE OF records,
      lv_msg        TYPE string,
      lv_instanceid TYPE sysuuid_x16,
      lv_new        TYPE c.
    DATA:lv_operator TYPE  ztbc_1011-operator.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).
      IF records IS NOT INITIAL.
        SELECT
          *
        FROM ztmm_1006
        FOR ALL ENTRIES IN @records
        WHERE uuid = @records-uuid
        INTO TABLE @DATA(lt_mm1006).
        SORT lt_mm1006 BY pr_no.
      ENDIF.
      LOOP AT records INTO record.

        CLEAR lv_operator.
        lv_operator = record-userfullname && '(' && record-useremail && ')' .

*&--只能申请本公司的PR
        zzcl_wf_utils=>check_plant_access(
                  EXPORTING iv_email    = record-useremail
                            iv_uuid     = record-uuid
                  IMPORTING ev_error         = DATA(lv_ev_error)
                            ev_errortext     = DATA(lv_error_text) ).
        IF lv_ev_error IS NOT INITIAL.
          record-message = lv_error_text.
          record-type = 'E'.
          MODIFY records FROM record TRANSPORTING message type.
          CONTINUE.
        ENDIF.

*&--提交申请时数据状态只能为1（登録済）
        READ TABLE lt_mm1006 INTO DATA(ls_mm1006) WITH KEY pr_no = record-prno BINARY SEARCH.
        IF sy-subrc = 0.
          IF ls_mm1006-approve_status <> '1'.
            record-type = 'E'.
            MESSAGE e027(zmm_001) WITH record-prno record-pritem INTO record-message.
            MODIFY records FROM record.
            CONTINUE.
          ENDIF.
        ELSE.
          " TODO 找不到数据应该报错，刷新界面，但概率较小
        ENDIF.
        record-workflowid = 'purchaserequisition'.
        CLEAR lv_new.
*&-- 获取审批流的uuid
        IF record-instanceid IS INITIAL.
          TRY.
              lv_instanceid = cl_system_uuid=>create_uuid_x16_static(  ).
              lv_new = 'X'.
              ##NO_HANDLER
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ELSE.
          lv_instanceid = record-instanceid.
        ENDIF.
*&-- 获取审批流的applicationid
        zzcl_wf_utils=>get_application_id(
                  EXPORTING iv_workflowid    = record-workflowid
                            iv_uuid          = record-uuid
                  IMPORTING ev_error         = lv_ev_error
                            ev_errortext     = lv_error_text
                            ev_applicationid = record-applicationid ).

        IF lv_ev_error IS NOT INITIAL.
          record-message = lv_error_text.
          record-type = 'E'.
          MODIFY records FROM record TRANSPORTING message type.
          CONTINUE.
        ENDIF.

*&-- 获取下一审批节点
        zzcl_wf_utils=>get_next_node(
                          EXPORTING iv_workflowid    = record-workflowid
                                    iv_applicationid = record-applicationid
                                    iv_instanceid    = lv_instanceid
                          IMPORTING ev_nextnode      = DATA(lv_next_node)
                                    ev_approvalend   = DATA(lv_approvalend) ).
*&-- 获取再下一节点的user
        zzcl_wf_utils=>get_next_node_user( EXPORTING iv_workflowid    = record-workflowid
                                                     iv_applicationid = record-applicationid
                                                     iv_nextnode      = lv_next_node
                                           IMPORTING ev_error         = lv_ev_error
                                                     ev_errortext     = lv_error_text
                                                     ev_users         = DATA(lv_users) ).
        IF lv_ev_error IS NOT INITIAL.
          record-message = lv_error_text.
          record-type = 'E'.
          MODIFY records FROM record TRANSPORTING message type.
          CONTINUE.
        ENDIF.
*&-- node 10 发邮件
        zzcl_wf_utils=>send_emails( EXPORTING iv_workflowid    = record-workflowid
                                              iv_applicationid = record-applicationid
                                              iv_instanceid    = lv_instanceid
                                              iv_users         = lv_users
                                              iv_zid           = 'ZMM013'
                                              iv_uuid          = record-uuid
                                     IMPORTING ev_error         = lv_ev_error
                                               ev_errortext     = lv_error_text ).
        IF lv_ev_error IS NOT INITIAL.
          record-message = lv_error_text.
          record-type = 'E'.
          MODIFY records FROM record TRANSPORTING message type.
          CONTINUE.
        ENDIF.
*&-- 将工作流id写入ztmm_1006
        DATA(current_date) = cl_abap_context_info=>get_system_date( ).
        DATA(current_time) = cl_abap_context_info=>get_system_time( ).
        DATA lv_frontend_datetime_str TYPE timestamp.
        lv_frontend_datetime_str = current_date && current_time.
        CONVERT TIME STAMP lv_frontend_datetime_str TIME ZONE record-timezone INTO DATE current_date TIME current_time.
        IF lv_new IS NOT INITIAL.
          UPDATE ztmm_1006
             SET workflow_id   = @record-workflowid,
                application_id = @record-applicationid,
                instance_id    = @lv_instanceid,
                apply_date = @current_date,
                apply_time = @current_time
         WHERE pr_no = @record-prno.
        ENDIF.
*&--生成审批流同时添加审批流日志
        DATA lv_approve_status TYPE ztmm_1006-approve_status.
        lv_approve_status = '2'.
        zzcl_wf_utils=>add_approval_history(
                          iv_workflowid     = record-workflowid
                          iv_instanceid     = lv_instanceid
                          iv_applicationid  = record-applicationid
                          iv_nextnode       = lv_next_node
                          iv_operator       = lv_operator
                          iv_email          = CONV #( record-useremail )
                          iv_approvalstatus = lv_approve_status"审批中
                          iv_remark         = '提交审批' ).

        record-message = '申请成功'.
        record-type = 'S'.
        record-instanceid = lv_instanceid.
        record-approvestatus = lv_approve_status.
        record-applydate = current_date.
        record-applytime = current_time.
        MODIFY records FROM record TRANSPORTING message type instanceid applicationid approvestatus applydate applytime.
        CLEAR:lv_next_node,lv_approvalend,lv_ev_error,lv_error_text,lv_users,lv_instanceid.

      ENDLOOP.

      DATA(lv_json) = /ui2/cl_json=>serialize( records ).
      APPEND VALUE #( %cid    = key-%cid
                      %param  = VALUE #( zzkey = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.
  METHOD revoke.
    DATA:
      records TYPE TABLE OF ty_batchupload,
      record  LIKE LINE OF records,
      lv_msg  TYPE string.
    DATA:lv_operator TYPE  ztbc_1011-operator.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).

      LOOP AT records INTO record.

        CLEAR lv_operator.
        lv_operator = record-userfullname && '(' && record-useremail && ')' .

        "1. 获取 workflowid applicationid instanceid
        SELECT SINGLE *
          FROM ztmm_1006
        WHERE uuid = @record-uuid
        INTO @DATA(ls_ztmm_1006).
        IF ls_ztmm_1006-instance_id IS INITIAL.
          record-type = 'E'.
          MESSAGE s019(zbc_001) WITH ls_ztmm_1006-pr_no INTO record-message.
          MODIFY records FROM record TRANSPORTING message type.
          CONTINUE.
        ENDIF.

        "2. 获取当前节点
        zzcl_wf_utils=>get_current_node( EXPORTING iv_workflowid     = ls_ztmm_1006-workflow_id
                                                   iv_applicationid  = ls_ztmm_1006-application_id
                                                   iv_instanceid     = ls_ztmm_1006-instance_id
                                         IMPORTING ev_currentnode    = DATA(lv_current_node) ).

        "3. 获取下一审批节点
        zzcl_wf_utils=>get_next_node(
                          EXPORTING iv_workflowid    = ls_ztmm_1006-workflow_id
                                    iv_applicationid = ls_ztmm_1006-application_id
                                    iv_instanceid    = ls_ztmm_1006-instance_id
                          IMPORTING ev_nextnode      = DATA(lv_next_node)
                                    ev_approvalend   = DATA(lv_approvalend) ).

        "4. 获取再下一节点的user
        IF lv_approvalend NE abap_true.
          zzcl_wf_utils=>get_next_node_user( EXPORTING iv_workflowid    = ls_ztmm_1006-workflow_id
                                                       iv_applicationid = ls_ztmm_1006-application_id
                                                       iv_nextnode      = lv_next_node
                                             IMPORTING ev_error         = DATA(lv_ev_error)
                                                       ev_errortext     = DATA(lv_error_text)
                                                       ev_users         = DATA(lv_users) ).
          IF lv_ev_error IS NOT INITIAL.
            record-message = lv_error_text.
            record-type = 'E'.
            MODIFY records FROM record TRANSPORTING message type.
            CONTINUE.
          ENDIF.
        ENDIF.
        "5. node 10 发邮件
        IF lv_users IS NOT INITIAL.

          zzcl_wf_utils=>send_emails( EXPORTING iv_workflowid    = ls_ztmm_1006-workflow_id
                                                iv_applicationid = ls_ztmm_1006-application_id
                                                iv_instanceid    = ls_ztmm_1006-instance_id
                                                iv_users         = lv_users
                                                iv_zid           = 'ZMM014'
                                       IMPORTING ev_error         = lv_ev_error
                                                 ev_errortext     = lv_error_text ).
          IF lv_ev_error IS NOT INITIAL.
            record-message = lv_error_text.
            record-type = 'E'.
            MODIFY records FROM record TRANSPORTING message type.
            CONTINUE.
          ENDIF.
        ENDIF.

        "6. 生成审批流同时添加审批流日志
        DATA lv_approve_status TYPE ztmm_1006-approve_status.
        lv_approve_status = '1'.
        zzcl_wf_utils=>add_approval_history(
                          iv_workflowid     = ls_ztmm_1006-workflow_id
                          iv_instanceid     = ls_ztmm_1006-instance_id
                          iv_applicationid  = ls_ztmm_1006-application_id
                          iv_nextnode       = lv_next_node
                          iv_operator       = lv_operator
                          iv_email          = CONV #( record-useremail )
                          iv_approvalstatus = lv_approve_status
                          iv_reject         =  abap_true
                          iv_remark         = '撤回' ).
        record-message = '撤回成功'.
        record-type = 'S'.
        record-approvestatus = lv_approve_status.
        record-applydate = ''.
        record-applytime = ''.
        MODIFY records FROM record TRANSPORTING message type approvestatus applydate applytime.
        CLEAR:lv_next_node,lv_approvalend,lv_ev_error,lv_error_text,lv_users.
      ENDLOOP.

      DATA(lv_json) = /ui2/cl_json=>serialize( records ).
      APPEND VALUE #( %cid    = key-%cid
                      %param  = VALUE #( zzkey = lv_json ) ) TO result.
    ENDLOOP.



  ENDMETHOD.

ENDCLASS.
