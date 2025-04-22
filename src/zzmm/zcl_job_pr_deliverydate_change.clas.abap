CLASS zcl_job_pr_deliverydate_change DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS:
      init_application_log,
      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime.
    CLASS-DATA:
      mo_application_log TYPE REF TO if_bali_log.
ENDCLASS.



CLASS ZCL_JOB_PR_DELIVERYDATE_CHANGE IMPLEMENTATION.


  METHOD add_message_to_log.
    TRY.
        IF sy-batch = abap_true.
          DATA(lo_free_text) = cl_bali_free_text_setter=>create(
                                 severity = COND #( WHEN i_type IS NOT INITIAL
                                                    THEN i_type
                                                    ELSE if_bali_constants=>c_severity_status )
                                 text     = i_text ).

          lo_free_text->set_detail_level( detail_level = '1' ).

          mo_application_log->add_item( item = lo_free_text ).

          cl_bali_log_db=>get_instance( )->save_log( log = mo_application_log
                                                     assign_to_current_appl_job = abap_true ).

        ELSE.
*          mo_out->write( i_text ).
        ENDIF.
        ##NO_HANDLER
      CATCH cx_bali_runtime INTO DATA(lx_bali_runtime).
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #( ( selname        = 'P_PLANT'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'C'
                                  length         = 4
                                  param_text     = 'Plant'
                                  changeable_ind = abap_true
                                  mandatory_ind  = abap_true ) ).
    " Return the default parameters values here
    " et_parameter_val
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES: BEGIN OF ty_mrp_record,
             material                   TYPE i_supplydemanditemtp-material,
             mrparea                    TYPE i_supplydemanditemtp-mrparea,
             mrpplant                   TYPE i_supplydemanditemtp-mrpplant,
             mrpelementcategory         TYPE i_supplydemanditemtp-mrpelementcategory,
             mrpelement                 TYPE i_supplydemanditemtp-mrpelement,
             mrpelementitem             TYPE i_supplydemanditemtp-mrpelementitem,
             mrpelementreschedulingdate TYPE datum,
           END OF ty_mrp_record,
           BEGIN OF ts_mrp_result,
             results TYPE TABLE OF ty_mrp_record WITH DEFAULT KEY,
           END OF ts_mrp_result,
           BEGIN OF ts_message,
             lang  TYPE string,
             value TYPE string,
           END OF ts_message,
           BEGIN OF ts_error,
             code    TYPE string,
             message TYPE ts_message,
           END OF ts_error,
           BEGIN OF ts_mrp_response,
             d     TYPE ts_mrp_result,
             error TYPE ts_error,
           END OF ts_mrp_response.

    DATA: lt_mrp_data     TYPE TABLE OF ty_mrp_record,
          ls_mrp_response TYPE ts_mrp_response,
          ls_error        TYPE zzcl_common_utils=>ty_error_v4.

    DATA: lv_filter              TYPE string,
          lv_purchaserequisition TYPE i_purchaserequisitionitemapi01-purchaserequisition,
          lv_new_delivery_date   TYPE datum,
          lv_workingday          TYPE datum,
          lv_patch_path          TYPE string,
          lv_date_str            TYPE string,
          lv_request_body        TYPE string,
          lv_has_error1          TYPE abap_boolean,
          lv_has_error2          TYPE abap_boolean,
          lv_error_message       TYPE string,
          lv_error_message1      TYPE string,
          lv_error_message2      TYPE string.

    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_PLANT'.
          DATA(lv_plant) = ls_parameter-low.
      ENDCASE.
    ENDLOOP.

    " create log handle
    init_application_log(  ).

    " process logic
    DATA(lv_path) = |/API_MRP_MATERIALS_SRV_01/SupplyDemandItems?sap-language={ zzcl_common_utils=>get_current_language( ) }|.

    TRY.
        add_message_to_log( |Request API Path: { lv_path }| ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.

    lv_filter = |MRPPlant eq '{ lv_plant }' and MRPArea eq '{ lv_plant }' and MRPElementCategory eq 'BA'|.
    TRY.
        add_message_to_log( |Request Object Data: { lv_filter }| ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.

    TRY.
        add_message_to_log( |Processing, please wait| ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.

    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>get
        iv_filter      = lv_filter
        iv_select      = |Material,MRPPlant,MRPArea,MRPElementCategory,MRPElement,MRPElementItem,MRPElementReschedulingDate|
      IMPORTING
        ev_status_code = DATA(ev_status_code)
        ev_response    = DATA(ev_response) ).

    IF ev_status_code = 200.
      CLEAR ls_mrp_response.
      /ui2/cl_json=>deserialize( EXPORTING json = ev_response
                                 CHANGING  data = ls_mrp_response ).

      APPEND LINES OF ls_mrp_response-d-results TO lt_mrp_data.
      DELETE lt_mrp_data WHERE mrpelementreschedulingdate IS INITIAL.
    ELSE.
      /ui2/cl_json=>deserialize( EXPORTING json = ev_response
                                 CHANGING  data = ls_mrp_response ).
      TRY.
          add_message_to_log( i_text = CONV #( ls_mrp_response-error-message-value )
                              i_type = if_bali_constants=>c_severity_error ).
          ##NO_HANDLER
        CATCH cx_bali_runtime.
          " handle exception
      ENDTRY.
      RETURN.
    ENDIF.

    TRY.
        add_message_to_log( |MRP Data Count: { lines( lt_mrp_data ) }| ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.

    LOOP AT lt_mrp_data INTO DATA(ls_mrp_data).
      CLEAR: lv_has_error1, lv_error_message1,
             lv_has_error2, lv_error_message2.

      lv_purchaserequisition = |{ ls_mrp_data-mrpelement ALPHA = IN }|.
      DATA(lv_item) = |{ ls_mrp_data-mrpelementitem ALPHA = OUT }|.
      CONDENSE lv_item NO-GAPS.

      SELECT SINGLE
             purchaserequisition,
             purchaserequisitionitem,
             plant,
             materialgoodsreceiptduration,
             deliverydate
        FROM i_purchaserequisitionitemapi01 WITH PRIVILEGED ACCESS
       WHERE purchaserequisition = @lv_purchaserequisition
         AND purchaserequisitionitem = @ls_mrp_data-mrpelementitem
        INTO @DATA(ls_prdata).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      " 手配終了日 = 再日程計画日付 - 入库处理日数(稼働日)
      CLEAR: lv_workingday,lv_new_delivery_date.
      DATA(lv_duration) = ls_prdata-materialgoodsreceiptduration.
      lv_workingday = ls_mrp_data-mrpelementreschedulingdate.
      IF lv_duration > 0.
        DO.
          lv_workingday -= 1.
          IF zzcl_common_utils=>is_workingday( iv_plant = ls_prdata-plant
                                               iv_date  = lv_workingday ).
            lv_duration -= 1.
          ENDIF.

          IF lv_duration = 0.
            lv_new_delivery_date = lv_workingday.
            EXIT.
          ENDIF.
        ENDDO.
      ELSE.
        lv_new_delivery_date = lv_workingday.
      ENDIF.

      IF lv_new_delivery_date <> ls_prdata-deliverydate.
        " Call API
        CLEAR lv_patch_path.
        lv_patch_path = |/api_purchaserequisition_2/srvd_a2x/sap/purchaserequisition/0001/PurchaseReqnItem| &&
                        |(PurchaseRequisition='{ ls_mrp_data-mrpelement }',PurchaseRequisitionItem='{ lv_item }')?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

        DO 2 TIMES.
          CLEAR: lv_date_str, lv_request_body.
          CASE sy-index.
            WHEN 1.
              lv_date_str = |{ lv_new_delivery_date+0(4) }-{ lv_new_delivery_date+4(2) }-{ lv_new_delivery_date+6(2) }|.
              CONDENSE lv_date_str NO-GAPS.
              lv_request_body = '{' && |"DeliveryDate":"{ lv_date_str }"| && '}'.
            WHEN 2.
              lv_request_body = '{' && |"PurchaseRequisitionIsFixed":false| && '}'.
            WHEN OTHERS.
          ENDCASE.

          zzcl_common_utils=>request_api_v4( EXPORTING iv_path        = lv_patch_path
                                                       iv_method      = if_web_http_client=>patch
                                                       iv_body        = lv_request_body
                                             IMPORTING ev_status_code = DATA(lv_status_code)
                                                       ev_response    = DATA(lv_response) ).
          IF lv_status_code <> 200.
            TRY.
                /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                           CHANGING  data = ls_error ).

                IF ls_error-error-message IS NOT INITIAL.
                  lv_error_message = ls_error-error-message.
                ELSEIF ls_error-error-code IS NOT INITIAL.
                  SPLIT ls_error-error-code AT '/' INTO TABLE DATA(lt_msg).
                  IF lines( lt_msg ) = 2.
                    DATA(lv_msg_class) = lt_msg[ 1 ].
                    DATA(lv_msg_number) = lt_msg[ 2 ].
                    MESSAGE ID lv_msg_class TYPE 'S' NUMBER lv_msg_number INTO lv_error_message.
                  ENDIF.
                ENDIF.
                ##NO_HANDLER
              CATCH cx_root.
            ENDTRY.

            CASE sy-index.
              WHEN 1.
                lv_has_error1 = abap_true.
                lv_error_message1 = lv_error_message.
              WHEN 2.
                lv_has_error2 = abap_true.
                lv_error_message2 = lv_error_message.
              WHEN OTHERS.
            ENDCASE.
          ENDIF.
        ENDDO.
      ENDIF.

      IF lv_has_error1 = abap_false AND lv_has_error2 = abap_false.
        TRY.
            add_message_to_log( i_text = |購買依頼{ ls_mrp_data-mrpelement }-{ lv_item },変更前納期 { ls_prdata-deliverydate },変更後納期 { lv_new_delivery_date }|
                                i_type = if_bali_constants=>c_severity_status ).
            ##NO_HANDLER
          CATCH cx_bali_runtime.
            " handle exception
        ENDTRY.
      ENDIF.

      IF lv_has_error1 = abap_true.
        TRY.
            add_message_to_log( i_text = |購買依頼{ ls_mrp_data-mrpelement }-{ lv_item },Step 1: { lv_error_message1 }|
                                i_type = if_bali_constants=>c_severity_warning ).
            ##NO_HANDLER
          CATCH cx_bali_runtime.
            " handle exception
        ENDTRY.
      ENDIF.

      IF lv_has_error2 = abap_true.
        TRY.
            add_message_to_log( i_text = |購買依頼{ ls_mrp_data-mrpelement }-{ lv_item },Step 2: { lv_error_message2 }|
                                i_type = if_bali_constants=>c_severity_warning ).
            ##NO_HANDLER
          CATCH cx_bali_runtime.
            " handle exception
        ENDTRY.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    " for debugger
    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.

    lt_parameters = VALUE #( ( selname = 'P_PLANT'
                               kind    = if_apj_dt_exec_object=>parameter
                               sign    = 'I'
                               option  = 'EQ'
                               low     = '1400' ) ).

    TRY.
        if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_root INTO DATA(lo_root).
        out->write( |Exception has occured: { lo_root->get_text(  ) }| ).
    ENDTRY.
  ENDMETHOD.


  METHOD init_application_log.
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object    = 'ZZ_LOG_MM044'
                                                                       subobject = 'ZZ_LOG_MM044_SUB' ) ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
