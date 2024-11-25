CLASS zcl_http_cancelmfgordconf_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_CANCELMFGORDCONF_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        u_m_e_s_i_d                  TYPE string,
        plant                        TYPE string,
        mfg_order_confirmation_group TYPE string,
        mfg_order_confirmation       TYPE string,
        creator                      TYPE string,
      END OF ty_req,

      BEGIN OF ty_data,
        _u_m_e_s_i_d TYPE string,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res,

      BEGIN OF ty_d,
        order_i_d       TYPE string,
        order_operation TYPE string,
        posting_date    TYPE string,
      END OF ty_d,

      BEGIN OF ty_message,
        value TYPE string,
      END OF ty_message,

      BEGIN OF ty_error,
        message TYPE ty_message,
      END OF ty_error,

      BEGIN OF ty_res_api,
        d     TYPE ty_d,
        error TYPE ty_error,
      END OF ty_res_api.

    DATA:
      lo_root_exc       TYPE REF TO cx_root,
      lt_ztpp_1004      TYPE STANDARD TABLE OF ztpp_1004,
      lt_ztpp_1005      TYPE STANDARD TABLE OF ztpp_1005,
      ls_ztpp_1004      TYPE ztpp_1004,
      ls_ztpp_1005      TYPE ztpp_1005,
      ls_req            TYPE ty_req,
      ls_res            TYPE ty_res,
      ls_res_api        TYPE ty_res_api,
      lv_umesid         TYPE sysuuid_c32,
      lv_plant          TYPE i_mfgorderconfirmation-plant,
      lv_group          TYPE i_mfgorderconfirmation-mfgorderconfirmationgroup,
      lv_count          TYPE i_mfgorderconfirmation-mfgorderconfirmation,
      lv_creator        TYPE c LENGTH 40,
      lv_path           TYPE string,
      lv_string         TYPE string,
      lv_unix_timestamp TYPE int8,
      lv_previous_processed TYPE ztpp_1004-messagetype,
      ls_error          TYPE zzcl_odata_utils=>gty_error.

    CONSTANTS:
      lc_msgid         TYPE string VALUE 'ZPP_001',
      lc_msgty         TYPE string VALUE 'E',
      lc_msgty_s       TYPE string VALUE 'S',
      lc_msgty_w       TYPE string VALUE 'W',
      lc_stat_code_200 TYPE string VALUE '200',
      lc_stat_code_500 TYPE string VALUE '500',
      lc_updateflag_i  TYPE string VALUE 'I',
      lc_updateflag_c  TYPE string VALUE 'C',
      lc_count_10      TYPE i      VALUE '10',
      lc_date_19000101 TYPE d      VALUE '19000101',
      lc_pgmid         TYPE string VALUE 'ZCL_HTTP_CANCELMFGORDCONF_001'.

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).

    lv_umesid = ls_req-u_m_e_s_i_d.
    lv_plant = ls_req-plant.
    lv_group = ls_req-mfg_order_confirmation_group.
    lv_count = ls_req-mfg_order_confirmation.
    lv_creator = ls_req-creator.

    TRY.
        "Check UMESID of input parameter must be valuable
        IF lv_umesid IS INITIAL.
          "UMESIDを送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 026 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Check plant of input parameter must be valuable
        IF lv_plant IS INITIAL.
          "プラントを送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 001 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Check confirmation number of input parameter must be valuable
        IF lv_group IS INITIAL.
          "作業確認番号を送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 019 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Check confirmation counter of input parameter must be valuable
        IF lv_count IS INITIAL.
          "確認カウンタを送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 020 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        "Check plant of input parameter must be existent
        SELECT COUNT(*)
          FROM i_plant
         WHERE plant = @lv_plant.
        IF sy-subrc <> 0.
          "プラント&1存在しません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 002 WITH lv_plant INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

       "Check previous processed
        SELECT umesid,
               plant,
               pgmid,
               creationdate,
               mfgorderconfirmationgroup,
               mfgorderconfirmation,
               updateflag
          FROM ztpp_1004
         WHERE umesid      = @lv_umesid
           AND updateflag  = @lc_updateflag_i      "登録
           AND messagetype = @lc_msgty_s
         ORDER BY creationdate DESCENDING
          INTO TABLE @DATA(lt_ztpp_1004_i).

        SELECT umesid,
               plant,
               pgmid,
               creationdate,
               mfgorderconfirmationgroup,
               mfgorderconfirmation,
               updateflag
          FROM ztpp_1004
         WHERE umesid      = @lv_umesid
           AND updateflag  = @lc_updateflag_c      "取り消し
           AND messagetype = @lc_msgty_s
         ORDER BY creationdate DESCENDING
          INTO TABLE @DATA(lt_ztpp_1004_c).

        IF lines( lt_ztpp_1004_i ) - lines( lt_ztpp_1004_c ) <> 1.
          lv_previous_processed = lc_msgty_w.
        ELSE.
          CLEAR lv_previous_processed.
        ENDIF.

        IF lv_previous_processed = lc_msgty_w.
          "該当データは前回処理済みです！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 110 INTO ls_res-_msg.
          ls_res-_msgty = lv_previous_processed.
        ELSE.

        "Obtain data of manufacturing order confirmation
        SELECT SINGLE
               manufacturingorder,
               isreversed,
               isreversal,
               milestoneconfirmationtype
          FROM i_mfgorderconfirmation WITH PRIVILEGED ACCESS
         WHERE mfgorderconfirmationgroup = @lv_group
           AND mfgorderconfirmation = @lv_count
           AND plant = @lv_plant
          INTO @DATA(ls_mfgorderconfirmation).
        IF sy-subrc = 0.
          IF ls_mfgorderconfirmation-isreversed = 'X' OR ls_mfgorderconfirmation-isreversal = 'X'.
            "作業実績は既に取消しました！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 022 INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.

          "/API_PROD_ORDER_CONFIRMATION_2_SRV/CancelProdnOrdConf?ConfirmationGroup='{ConfirmationGroup}'&ConfirmationCount='{ConfirmationCount}'
          lv_path = |/API_PROD_ORDER_CONFIRMATION_2_SRV/CancelProdnOrdConf?ConfirmationGroup='{ lv_group }'&ConfirmationCount='{ lv_count }'|.

          "Call API of canceling manufacturing order confirmation
          zzcl_common_utils=>request_api_v2(
            EXPORTING
              iv_path        = lv_path
              iv_method      = if_web_http_client=>post
            IMPORTING
              ev_status_code = DATA(lv_stat_code)
              ev_response    = DATA(lv_resbody_api) ).

          "Could not fetch SCRF token
          IF lv_stat_code = lc_stat_code_500.
            ls_res-_msg = lv_resbody_api.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.

          IF lv_stat_code = lc_stat_code_200.
            "JSON->ABAP
            xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
                ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_res_api ) ).

            "作業実績取消は成功しました！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 028 INTO ls_res-_msg.
            ls_res-_msgty = 'S'.

            ls_ztpp_1004-manufacturingorder = |{ ls_res_api-d-order_i_d ALPHA = IN }|.
            ls_ztpp_1004-manufacturingorderoperation_2 = ls_res_api-d-order_operation.

            lv_string = ls_res_api-d-posting_date.
            SHIFT lv_string BY 6 PLACES LEFT.
            REPLACE ALL OCCURRENCES OF ')/' IN lv_string WITH ''.
            lv_unix_timestamp = lv_string / 1000.

            IF lv_unix_timestamp > 0.
              DATA(lv_date) = xco_cp_time=>unix_timestamp( iv_unix_timestamp = lv_unix_timestamp )->get_moment(
                                                                                                 )->as( xco_cp_time=>format->abap
                                                         )->value+0(8).
              ls_ztpp_1004-postingdate = lv_date.
            ELSE.
              ls_ztpp_1004-postingdate = lc_date_19000101.
            ENDIF.
          ELSE.
            "作業実績取消は失敗しました：
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 027 INTO ls_res-_msg.
            /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api
                                       CHANGING  data = ls_error ).
            "ls_res-_msg = ls_res-_msg && ls_res_api-error-message-value.
            ls_res-_msg = ls_res-_msg && ls_error-error-message-value.
            RAISE EXCEPTION TYPE cx_abap_api_state.
          ENDIF.
        ELSE.
          "作業確認番号&1確認カウンタ&2存在しません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 021 WITH lv_group lv_count INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_api_state.
        ENDIF.

        ENDIF.

      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    ls_res-_data-_u_m_e_s_i_d = lv_umesid.

    "ABAP->JSON
    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    IF lv_umesid IS NOT INITIAL.
      ls_ztpp_1004-umesid                    = lv_umesid.
      ls_ztpp_1004-plant                     = lv_plant.
      ls_ztpp_1004-pgmid                     = lc_pgmid.
      ls_ztpp_1004-mfgorderconfirmationgroup = lv_group.
      ls_ztpp_1004-mfgorderconfirmation      = lv_count.
      ls_ztpp_1004-updateflag                = lc_updateflag_c.
      ls_ztpp_1004-messagetype               = ls_res-_msgty.
      ls_ztpp_1004-creator                   = lv_creator.
      IF lv_previous_processed = lc_msgty_w.
        CLEAR: ls_ztpp_1004-mfgorderconfirmationgroup,
               ls_ztpp_1004-mfgorderconfirmation.
      ENDIF.
      GET TIME STAMP FIELD ls_ztpp_1004-creationdate.
      APPEND ls_ztpp_1004 TO lt_ztpp_1004.

      ls_ztpp_1005-umesid       = lv_umesid.
      ls_ztpp_1005-plant        = lv_plant.
      ls_ztpp_1005-pgmid        = lc_pgmid.
      ls_ztpp_1005-msgitemno    = lc_count_10.
      ls_ztpp_1005-messagetype  = ls_res-_msgty.
      ls_ztpp_1005-message      = ls_res-_msg.
      ls_ztpp_1005-creator      = lv_creator.
      GET TIME STAMP FIELD ls_ztpp_1005-creationdate.
      APPEND ls_ztpp_1005 TO lt_ztpp_1005.

      "Modify database of log
      MODIFY ztpp_1004 FROM TABLE @lt_ztpp_1004.
      MODIFY ztpp_1005 FROM TABLE @lt_ztpp_1005.
    ENDIF.

    "Set request data
    response->set_text( lv_res_body ).

  ENDMETHOD.
ENDCLASS.
