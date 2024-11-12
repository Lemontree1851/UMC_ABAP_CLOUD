CLASS zcl_http_customermaterial_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_http_customermaterial_001 IMPLEMENTATION.
  METHOD if_http_service_extension~handle_request.

    TYPES:
      BEGIN OF ty_req,
        sales_organization   TYPE string,
        distribution_channel TYPE string,
        customer             TYPE string,
        product              TYPE string,
        time_stamp           TYPE string,
      END OF ty_req,

      BEGIN OF ty_customermaterial,
        _sales_organization            TYPE i_customermaterial_2-salesorganization,
        _distribution_channel          TYPE i_customermaterial_2-distributionchannel,
        _customer                      TYPE string,
        _product                       TYPE i_customermaterial_2-product,
        _material_by_customer          TYPE i_customermaterial_2-materialbycustomer,
        _materialdescriptionbycustomer TYPE i_customermaterial_2-materialdescriptionbycustomer,
        _last_change_date_time         TYPE i_customermaterial_2-lastchangedatetime,
        _delete_indicator              TYPE string,
      END OF ty_customermaterial,
      tt_customermaterial TYPE STANDARD TABLE OF ty_customermaterial WITH DEFAULT KEY,

      BEGIN OF ty_data,
        _customer_material TYPE tt_customermaterial,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res.

    DATA:
      lo_root_exc            TYPE REF TO cx_root,
      lr_salesorganization   TYPE RANGE OF i_customermaterial_2-salesorganization,
      lr_distributionchannel TYPE RANGE OF i_customermaterial_2-distributionchannel,
      lr_customer            TYPE RANGE OF i_customermaterial_2-customer,
      lr_product             TYPE RANGE OF i_customermaterial_2-product,
      lt_ztsd_1011           TYPE STANDARD TABLE OF ztsd_1011,
      lt_customermaterial    TYPE STANDARD TABLE OF ty_customermaterial,
      ls_customermaterial    TYPE ty_customermaterial,
      ls_req                 TYPE ty_req,
      ls_res                 TYPE ty_res,
      ls_ztsd_1011           TYPE ztsd_1011,
      lv_salesorganization   TYPE i_customermaterial_2-salesorganization,
      lv_distributionchannel TYPE i_customermaterial_2-distributionchannel,
      lv_customer            TYPE i_customermaterial_2-customer,
      lv_product             TYPE i_customermaterial_2-product,
      lv_timestamp           TYPE timestamp,
      lv_timestampl          TYPE timestampl,
      lv_timestampl_tmp      TYPE timestampl,
      lv_date                TYPE d,
      lv_time                TYPE t.

    CONSTANTS:
      lc_zid_zsd011    TYPE string VALUE 'ZSD011',
      lc_msgid_zsd_001 TYPE string VALUE 'ZSD_001',
      lc_sign_i        TYPE string VALUE 'I',
      lc_option_eq     TYPE string VALUE 'EQ',
      lc_alpha_in      TYPE string VALUE 'IN',
      lc_alpha_out     TYPE string VALUE 'OUT'.

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).

    lv_salesorganization   = ls_req-sales_organization.
    lv_distributionchannel = ls_req-distribution_channel.
    lv_customer            = |{ ls_req-customer ALPHA = IN }|.
    lv_timestampl          = ls_req-time_stamp.
    lv_product = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_req-product ).

    TRY.
        "Check sales organization of input parameter must be valuable
        IF lv_salesorganization IS INITIAL.
          "販売組織を送信していください！
          MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 007 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        IF lv_salesorganization IS NOT INITIAL.
          "Check sales organization of input parameter must be existent
          SELECT COUNT(*)
            FROM i_salesorganization WITH PRIVILEGED ACCESS
           WHERE salesorganization = @lv_salesorganization.
          IF sy-subrc <> 0.
            "販売組織&1存在しません！
            MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 008 WITH lv_salesorganization INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ELSE.
            lr_salesorganization = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lv_salesorganization ) ).
          ENDIF.
        ENDIF.

        IF lv_distributionchannel IS NOT INITIAL.
          "Check distribution channel of input parameter must be existent
          SELECT COUNT(*)
            FROM i_distributionchannel WITH PRIVILEGED ACCESS
           WHERE distributionchannel = @lv_distributionchannel.
          IF sy-subrc <> 0.
            "流通チャネル&1存在しません！
            MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 009 WITH lv_distributionchannel INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ELSE.
            lr_distributionchannel = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lv_distributionchannel ) ).
          ENDIF.
        ENDIF.

        IF lv_customer IS NOT INITIAL.
          "Check customer of input parameter must be existent
          SELECT COUNT(*)
            FROM i_customer WITH PRIVILEGED ACCESS
           WHERE customer = @lv_customer.
          IF sy-subrc <> 0.
            "得意先&1存在しません！
            MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 010 WITH lv_customer INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ELSE.
            lr_customer = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lv_customer ) ).
          ENDIF.
        ENDIF.

        IF lv_product IS NOT INITIAL.
          "Check product of input parameter must be existent
          SELECT COUNT(*)
            FROM i_product WITH PRIVILEGED ACCESS
           WHERE product = @lv_product.
          IF sy-subrc <> 0.
            "製品&1存在しません！
            MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 011 WITH lv_product INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ELSE.
            lr_product = VALUE #( sign = lc_sign_i option = lc_option_eq ( low = lv_product ) ).
          ENDIF.
        ENDIF.

        "Obtain time zone of sales organization
        SELECT SINGLE
               zvalue2 AS zonlo_in,
               zvalue3 AS zonlo_out
          FROM ztbc_1001
         WHERE zid = @lc_zid_zsd011
           AND zvalue1 = @lv_salesorganization
          INTO @DATA(ls_ztbc_1001).

        IF lv_timestampl IS NOT INITIAL.
          "Convert date and time from time zone of sales organization to zero zone
          CONVERT TIME STAMP lv_timestampl
                  TIME ZONE ls_ztbc_1001-zonlo_in
                  INTO DATE lv_date
                       TIME lv_time.

          lv_timestampl = lv_date && lv_time.
        ENDIF.

        "Obtain data of customer product
        SELECT salesorganization AS _sales_organization,
               distributionchannel AS _distribution_channel,
               customer AS _customer,
               product AS _product,
               materialbycustomer AS _material_by_customer,
               materialdescriptionbycustomer AS _materialdescriptionbycustomer,
               lastchangedatetime AS _last_change_date_time
          FROM i_customermaterial_2 WITH PRIVILEGED ACCESS
         WHERE salesorganization IN @lr_salesorganization
           AND distributionchannel IN @lr_distributionchannel
           AND customer IN @lr_customer
           AND product IN @lr_product
           AND lastchangedatetime >= @lv_timestampl
          INTO TABLE @ls_res-_data-_customer_material.

        LOOP AT ls_res-_data-_customer_material ASSIGNING FIELD-SYMBOL(<fs_customermaterial>).
          GET TIME STAMP FIELD lv_timestampl_tmp.

          ls_ztsd_1011-salesorganization     = <fs_customermaterial>-_sales_organization.
          ls_ztsd_1011-distributionchannel   = <fs_customermaterial>-_distribution_channel.
          ls_ztsd_1011-customer              = <fs_customermaterial>-_customer.
          ls_ztsd_1011-product               = <fs_customermaterial>-_product.
          ls_ztsd_1011-last_changed_by       = sy-uname.
          ls_ztsd_1011-last_changed_at       = lv_timestampl_tmp.
          ls_ztsd_1011-local_last_changed_at = lv_timestampl_tmp.
          APPEND ls_ztsd_1011 TO lt_ztsd_1011.
          CLEAR ls_ztsd_1011.

          <fs_customermaterial>-_customer = |{ <fs_customermaterial>-_customer ALPHA = OUT }|.
          <fs_customermaterial>-_product = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_out iv_input = <fs_customermaterial>-_product ).
          CONDENSE <fs_customermaterial>-_customer.

          lv_timestamp = trunc( <fs_customermaterial>-_last_change_date_time ).

          "Convert date and time from zero zone to time zone of sales organization
          CONVERT TIME STAMP lv_timestamp
                  TIME ZONE ls_ztbc_1001-zonlo_out
                  INTO DATE lv_date
                       TIME lv_time.

          lv_timestamp = lv_date && lv_time.
          <fs_customermaterial>-_last_change_date_time = lv_timestamp + frac( <fs_customermaterial>-_last_change_date_time ).
        ENDLOOP.

        "Obtain data of customer product of deletion
        SELECT salesorganization AS _sales_organization,
               distributionchannel AS _distribution_channel,
               customer AS _customer,
               product AS _product,
               last_changed_at AS _last_change_date_time,
               deleteindicator AS _delete_indicator
          FROM ztsd_1011
         WHERE salesorganization IN @lr_salesorganization
           AND distributionchannel IN @lr_distributionchannel
           AND customer IN @lr_customer
           AND product IN @lr_product
           AND last_changed_at >= @lv_timestampl
           AND deleteindicator = @abap_true
          INTO TABLE @DATA(lt_ztsd_1011_del).

        SORT ls_res-_data-_customer_material BY _sales_organization _distribution_channel _customer _product.

        LOOP AT lt_ztsd_1011_del INTO DATA(ls_ztsd_1011_del).
          ls_ztsd_1011_del-_customer = |{ ls_ztsd_1011_del-_customer ALPHA = OUT }|.
          ls_ztsd_1011_del-_product = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_out iv_input = ls_ztsd_1011_del-_product ).
          CONDENSE ls_ztsd_1011_del-_customer.

          READ TABLE ls_res-_data-_customer_material TRANSPORTING NO FIELDS WITH KEY _sales_organization = ls_ztsd_1011_del-_sales_organization
                                                                                     _distribution_channel = ls_ztsd_1011_del-_distribution_channel
                                                                                     _customer = ls_ztsd_1011_del-_customer
                                                                                     _product = ls_ztsd_1011_del-_product
                                                                            BINARY SEARCH.
          IF sy-subrc <> 0.
            MOVE-CORRESPONDING ls_ztsd_1011_del TO ls_customermaterial.

            lv_timestamp = trunc( ls_customermaterial-_last_change_date_time ).

            "Convert date and time from zero zone to time zone of sales organization
            CONVERT TIME STAMP lv_timestamp
                    TIME ZONE ls_ztbc_1001-zonlo_out
                    INTO DATE lv_date
                         TIME lv_time.

            lv_timestamp = lv_date && lv_time.
            ls_customermaterial-_last_change_date_time = lv_timestamp + frac( ls_customermaterial-_last_change_date_time ).

            APPEND ls_customermaterial TO lt_customermaterial.
            CLEAR ls_customermaterial.
          ENDIF.
        ENDLOOP.

        APPEND LINES OF lt_customermaterial TO ls_res-_data-_customer_material.

        DATA(lv_lines) = lines( ls_res-_data-_customer_material ).
        ls_res-_msgty = 'S'.

        "得意先品目マスタ連携成功 &1 件！
        MESSAGE ID lc_msgid_zsd_001 TYPE 'E' NUMBER 012 WITH lv_lines INTO ls_res-_msg.

        "Obtain data of customer product sending log
        SELECT salesorganization,
               distributionchannel,
               customer,
               product,
               deleteindicator
          FROM ztsd_1011
         WHERE salesorganization IN @lr_salesorganization
           AND deleteindicator = @abap_false
          INTO TABLE @DATA(lt_log).
        IF sy-subrc = 0.
          "Obtain data of customer product
          SELECT salesorganization,
                 distributionchannel,
                 customer,
                 product
            FROM i_customermaterial_2 WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_log
           WHERE salesorganization = @lt_log-salesorganization
             AND distributionchannel = @lt_log-distributionchannel
             AND customer = @lt_log-customer
             AND product = @lt_log-product
            INTO TABLE @DATA(lt_customermaterial_2).
        ENDIF.
      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    SORT ls_res-_data-_customer_material BY _sales_organization _distribution_channel _customer _product.
    SORT lt_log BY salesorganization distributionchannel customer product.
    SORT lt_customermaterial_2 BY salesorganization distributionchannel customer product.

    LOOP AT lt_log INTO DATA(ls_log).
      GET TIME STAMP FIELD lv_timestampl_tmp.

      "Read data of customer product
      READ TABLE lt_customermaterial_2 INTO DATA(ls_customermaterial_2) WITH KEY salesorganization = ls_log-salesorganization
                                                                                 distributionchannel = ls_log-distributionchannel
                                                                                 customer = ls_log-customer
                                                                                 product = ls_log-product
                                                                        BINARY SEARCH.
      IF sy-subrc <> 0.
        ls_ztsd_1011-salesorganization     = ls_log-salesorganization.
        ls_ztsd_1011-distributionchannel   = ls_log-distributionchannel.
        ls_ztsd_1011-customer              = ls_log-customer.
        ls_ztsd_1011-product               = ls_log-product.
        ls_ztsd_1011-deleteindicator       = abap_true.
        ls_ztsd_1011-last_changed_by       = sy-uname.
        ls_ztsd_1011-last_changed_at       = lv_timestampl.
        ls_ztsd_1011-local_last_changed_at = lv_timestampl.
        APPEND ls_ztsd_1011 TO lt_ztsd_1011.
        CLEAR ls_ztsd_1011.
      ENDIF.
    ENDLOOP.

    IF lt_ztsd_1011 IS NOT INITIAL.
      MODIFY ztsd_1011 FROM TABLE @lt_ztsd_1011.
      COMMIT WORK AND WAIT.
    ENDIF.

    "ABAP->JSON
*    DATA(lv_res_body) = xco_cp_json=>data->from_abap( ls_res )->apply( VALUE #(
*                          ( xco_cp_json=>transformation->underscore_to_pascal_case ) ) )->to_string( ).

    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF 'Materialdescriptionbycustomer' IN lv_res_body WITH 'MaterialDescriptionByCustomer'.


    "Set request data
    response->set_text( lv_res_body ).

  ENDMETHOD.
ENDCLASS.
