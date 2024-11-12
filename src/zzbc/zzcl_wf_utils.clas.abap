CLASS zzcl_wf_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    CLASS-METHODS:
      get_next_node IMPORTING iv_workflowid    TYPE ztbc_1011-workflow_id
                              iv_applicationid TYPE ztbc_1011-application_id
                              iv_currentnode   TYPE ztbc_1011-current_node OPTIONAL
                    EXPORTING ev_nextnode      TYPE ztbc_1011-next_node
                              ev_approvalend   TYPE abap_boolean,

      add_approval_history IMPORTING iv_workflowid     TYPE ztbc_1011-workflow_id
                                     iv_instanceid     TYPE ztbc_1011-instance_id
                                     iv_applicationid  TYPE ztbc_1011-application_id
                                     iv_currentnode    TYPE ztbc_1011-current_node OPTIONAL
                                     iv_nextnode       TYPE ztbc_1011-next_node
                                     iv_operator       TYPE ztbc_1011-operator
                                     iv_approvalstatus TYPE ztbc_1011-approval_status OPTIONAL
                                     iv_remark         TYPE ztbc_1011-remark.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zzcl_wf_utils IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

**********************************************************************
* DEMO
**********************************************************************
*    TRY.
*        DATA(lv_instanceid) = cl_system_uuid=>create_uuid_x16_static(  ).
*        ##NO_HANDLER
*      CATCH cx_uuid_error.
*        "handle exception
*    ENDTRY.
*
**&--发起人提交
*    get_next_node( EXPORTING iv_workflowid    = 'purchaserequisition'
*                             iv_applicationid = 1001
*                   IMPORTING ev_nextnode      = DATA(lv_next_node)
*                             ev_approvalend   = DATA(lv_approvalend) ).
*
*    add_approval_history(
*      iv_workflowid     = 'purchaserequisition'
*      iv_instanceid     = lv_instanceid
*      iv_applicationid  = 1001
*      iv_nextnode       = lv_next_node
*      iv_operator       = 'XINLEI.XU(xinlei.xu@sh.shin-china.com)'
*      iv_remark         = '提交审批'
*    ).
*
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

  METHOD get_next_node.
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
  ENDMETHOD.

ENDCLASS.
