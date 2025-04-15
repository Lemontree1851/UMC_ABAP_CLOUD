CLASS zzcl_job_mrp_supplydemand DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mo_application_log TYPE REF TO if_bali_log.

    METHODS:
      init_application_log,

      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime.
ENDCLASS.



CLASS ZZCL_JOB_MRP_SUPPLYDEMAND IMPLEMENTATION.


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
    et_parameter_def = VALUE #( ( selname        = 'P_ID'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'X'
                                  length         = 16
                                  param_text     = 'Schedule UUID'
                                  changeable_ind = abap_true ) ).

    " Return the default parameters values here
    " et_parameter_val
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    TYPES: BEGIN OF ts_mrp_result,
             results TYPE TABLE OF ztbc_1020 WITH DEFAULT KEY,
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

    DATA: lt_data         TYPE TABLE OF ztbc_1020,
          ls_mrp_response TYPE ts_mrp_response.

    DATA: lr_plant  TYPE RANGE OF i_plant-plant,
          lv_filter TYPE string,
          lv_count  TYPE sy-tabix.

    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_ID'.
          DATA(lv_uuid) = ls_parameter-low.
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

    SELECT plant FROM i_plant WITH PRIVILEGED ACCESS INTO TABLE @DATA(lt_plant). "#EC CI_NOWHERE
    SORT lt_plant BY plant.

    LOOP AT lt_plant INTO DATA(ls_plant).
      CLEAR: lv_filter,
             lt_data.

      lv_filter = |MRPPlant eq '{ ls_plant-plant }' and MRPArea eq '{ ls_plant-plant }'|.
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
        IMPORTING
          ev_status_code = DATA(ev_status_code)
          ev_response    = DATA(ev_response) ).

      IF ev_status_code = 200.
        CLEAR ls_mrp_response.
        /ui2/cl_json=>deserialize( EXPORTING json = ev_response
                                   CHANGING  data = ls_mrp_response ).

        APPEND LINES OF ls_mrp_response-d-results TO lt_data.

        LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
          TRY.
              <lfs_data>-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
              ##NO_HANDLER
            CATCH cx_uuid_error.
              " handle exception
          ENDTRY.

          <lfs_data>-material = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_data>-material ).

          <lfs_data>-created_by = sy-uname.
          GET TIME STAMP FIELD <lfs_data>-created_at.
          <lfs_data>-last_changed_by = sy-uname.
          GET TIME STAMP FIELD <lfs_data>-last_changed_at.
          GET TIME STAMP FIELD <lfs_data>-local_last_changed_at.
        ENDLOOP.

        DELETE FROM ztbc_1020 WHERE mrpplant = @ls_plant-plant
                                AND mrparea  = @ls_plant-plant.

        MODIFY ztbc_1020 FROM TABLE @lt_data.
        IF sy-subrc = 0.
          IF lv_uuid IS NOT INITIAL.
            GET TIME STAMP FIELD DATA(lv_timestamp).
            UPDATE ztbc_1021 SET schedule_end = @lv_timestamp WHERE uuid = @lv_uuid.
          ENDIF.
          TRY.
              add_message_to_log( |テーブル ZTBC_1020 データ { lines( lt_data ) } 件更新| ).
              ##NO_HANDLER
            CATCH cx_bali_runtime.
              " handle exception
          ENDTRY.
        ELSE.
          TRY.
              add_message_to_log( i_text = |データ更新に失敗しました。|
                                  i_type = if_bali_constants=>c_severity_error ).
              ##NO_HANDLER
            CATCH cx_bali_runtime.
              " handle exception
          ENDTRY.
        ENDIF.
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
      ENDIF.
      CLEAR: ev_status_code, ev_response.
    ENDLOOP.

    TRY.
        add_message_to_log( |Processing completed| ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.


  METHOD init_application_log.
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object    = 'ZZ_LOG_SUPPLYDEMAND'
                                                                       subobject = 'ZZ_LOG_SUPPLYDEMAND' ) ).
        ##NO_HANDLER
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
