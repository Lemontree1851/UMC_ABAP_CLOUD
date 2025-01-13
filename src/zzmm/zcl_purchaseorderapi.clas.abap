CLASS zcl_purchaseorderapi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_purchaseorderapi IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.
    TYPES: BEGIN OF ts_workflow_overview,
             sapbusinessobjectnodekey1 TYPE string,
             workflowinternalid        TYPE string,
             workflowexternalstatus    TYPE string,
           END OF ts_workflow_overview,
           BEGIN OF ts_workflow_overview_d,
             results TYPE STANDARD TABLE OF ts_workflow_overview WITH DEFAULT KEY,
           END OF ts_workflow_overview_d,
           BEGIN OF ts_workflow_overview_api,
             d TYPE ts_workflow_overview_d,
           END OF ts_workflow_overview_api,

           BEGIN OF ts_workflow_detail,
             workflowinternalid     TYPE string,
             workflowtaskinternalid TYPE string,
             workflowtaskresult     TYPE string,
           END OF ts_workflow_detail,
           BEGIN OF ts_workflow_detail_d,
             results TYPE STANDARD TABLE OF ts_workflow_detail WITH DEFAULT KEY,
           END OF ts_workflow_detail_d,
           BEGIN OF ts_workflow_detail_api,
             d TYPE ts_workflow_detail_d,
           END OF ts_workflow_detail_api.

    DATA: lt_original_data TYPE STANDARD TABLE OF zc_purchaseorderapi WITH DEFAULT KEY.

    DATA: ls_workflow_overview TYPE ts_workflow_overview_api,
          ls_workflow_detail   TYPE ts_workflow_detail_api.

    DATA: lv_path        TYPE string,
          lv_status_code TYPE if_web_http_response=>http_status-code,
          lv_response    TYPE string.

    lt_original_data = CORRESPONDING #( it_original_data ).

    " Get WorkflowStatusOverview
    CLEAR: lv_path, lv_status_code, lv_response.
    lv_path = |/YY1_WORKFLOWSTATUSOVERVIEW_CDS/YY1_WorkflowStatusOverview|.
    DATA(lv_filter) = |SAPObjectNodeRepresentation eq 'PurchaseOrder'|.
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_filter      = lv_filter
        iv_method      = if_web_http_client=>get
      IMPORTING
        ev_status_code = lv_status_code
        ev_response    = lv_response ).
    IF lv_status_code = 200.
      /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                 CHANGING  data = ls_workflow_overview ).

      DATA(lt_workflow_overview) = ls_workflow_overview-d-results.
      SORT lt_workflow_overview BY sapbusinessobjectnodekey1 workflowinternalid.
    ENDIF.

    " Get WorkflowStatusDetails
    CLEAR: lv_path, lv_status_code, lv_response.
    lv_path = |/YY1_WORKFLOWSTATUSDETAILS_CDS/YY1_WorkflowStatusDetails|.
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>get
      IMPORTING
        ev_status_code = lv_status_code
        ev_response    = lv_response ).
    IF lv_status_code = 200.
      /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                 CHANGING  data = ls_workflow_detail ).

      DATA(lt_workflow_detail) = ls_workflow_detail-d-results.
      SORT lt_workflow_detail BY workflowinternalid workflowtaskinternalid DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_workflow_detail COMPARING workflowinternalid.
    ENDIF.

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<lfs_original_data>).
      READ TABLE lt_workflow_overview INTO DATA(ls_overview)
                                      WITH KEY sapbusinessobjectnodekey1 = <lfs_original_data>-purchaseorder
                                               BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_workflow_detail INTO DATA(ls_detail)
                                      WITH KEY workflowinternalid = ls_overview-workflowinternalid
                                               BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_original_data>-workflowtaskresult = ls_detail-workflowtaskresult.
        ELSE.
          <lfs_original_data>-workflowtaskresult = ls_overview-workflowexternalstatus.
        ENDIF.
      ENDIF.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.

ENDCLASS.
