CLASS zcl_http_material_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_MATERIAL_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    TYPES:
      BEGIN OF ty_req,
        plant      TYPE string,
        product    TYPE string,
        time_stamp TYPE string,
      END OF ty_req,

      BEGIN OF ty_material,
        _product                     TYPE i_product-product,
        _product_type                TYPE i_product-producttype,
        _product_group               TYPE i_product-productgroup,
        _base_unit                   TYPE i_product-baseunit,
        _product_old_i_d             TYPE i_product-productoldid,
        _laboratory_or_design_office TYPE i_product-laboratoryordesignoffice,
        _cross_plant_status          TYPE i_product-crossplantstatus,
        _manufacturer_number         TYPE i_product-manufacturernumber,
        _product_manufacturer_number TYPE i_product-productmanufacturernumber,
        _creation_date_time          TYPE i_product-creationdatetime,
        _created_by_user             TYPE i_product-createdbyuser,
        _last_change_date_time       TYPE i_product-lastchangedatetime,
        _last_changed_by_user        TYPE i_product-lastchangedbyuser,
        _product_description         TYPE i_productdescription-productdescription,
        _plant                       TYPE i_productplantbasic-plant,
        _is_marked_for_deletion      TYPE i_productplantbasic-ismarkedfordeletion,
        _valuation_class             TYPE i_productvaluationbasic-valuationclass,
      END OF ty_material,
      tt_material TYPE STANDARD TABLE OF ty_material WITH DEFAULT KEY,

      BEGIN OF ty_data,
        _material TYPE tt_material,
      END OF ty_data,

      BEGIN OF ty_res,
        _msgty TYPE string,
        _msg   TYPE string,
        _data  TYPE ty_data,
      END OF ty_res.

    DATA:
      lo_root_exc   TYPE REF TO cx_root,
      ls_req        TYPE ty_req,
      ls_res        TYPE ty_res,
      ls_material   TYPE ty_material,
      lv_plant      TYPE i_productplantbasic-plant,
      lv_product    TYPE i_product-product,
      lv_timestamp  TYPE timestamp,
      lv_timestampl TYPE timestampl,
      lv_date       TYPE d,
      lv_time       TYPE t.

    CONSTANTS:
      lc_zid_zpp005 TYPE string VALUE 'ZPP005',
      lc_msgid      TYPE string VALUE 'ZPP_001',
      lc_msgty      TYPE string VALUE 'E',
      lc_alpha_in   TYPE string VALUE 'IN',
      lc_alpha_out  TYPE string VALUE 'OUT'.

    "Obtain request data
    DATA(lv_req_body) = request->get_text( ).

    "JSON->ABAP
    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).

    lv_plant = ls_req-plant.
    lv_timestampl = ls_req-time_stamp.
    lv_product = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_req-product ).

    TRY.
        "Check plant of input parameter must be valuable
        IF lv_plant IS INITIAL.
          "プラントを送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 001 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check product or time stamp of input parameter must be valuable
        IF lv_product IS INITIAL AND lv_timestampl IS INITIAL.
          "品目or前回送信時間は送信していください！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 011 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check product and time stamp of input parameter must be not valuable at the same time
        IF lv_product IS NOT INITIAL AND lv_timestampl IS NOT INITIAL.
          "品目と前回送信時間は一つしか送信できません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 012 INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        "Check plant of input parameter must be existent
        SELECT COUNT(*)
          FROM i_plant
         WHERE plant = @lv_plant.
        IF sy-subrc <> 0.
          "プラント&1存在しません！
          MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 002 WITH lv_plant INTO ls_res-_msg.
          RAISE EXCEPTION TYPE cx_abap_invalid_value.
        ENDIF.

        IF lv_product IS NOT INITIAL.
          "Check product and plant of input parameter must be existent
          SELECT COUNT(*)
            FROM i_productplantbasic WITH PRIVILEGED ACCESS
           WHERE product = @lv_product
             AND plant = @lv_plant.
          IF sy-subrc <> 0.
            "プラント&1品目&2存在しません！
            MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 013 WITH lv_plant lv_product INTO ls_res-_msg.
            RAISE EXCEPTION TYPE cx_abap_invalid_value.
          ENDIF.
        ENDIF.

        "Obtain language and time zone of plant
        SELECT SINGLE
               zvalue2 AS language,
               zvalue3 AS zonlo_in,
               zvalue4 AS zonlo_out
          FROM ztbc_1001
         WHERE zid = @lc_zid_zpp005
           AND zvalue1 = @lv_plant
          INTO @DATA(ls_ztbc_1001).

        "Convert date and time from time zone of plant to zero zone
        CONVERT TIME STAMP lv_timestampl
                TIME ZONE ls_ztbc_1001-zonlo_in
                INTO DATE lv_date
                     TIME lv_time.

        lv_timestampl = lv_date && lv_time.

        IF lv_product IS NOT INITIAL.
          "Obtain data of product
          SELECT b~product AS _product,
                 b~producttype AS _product_type,
                 b~productgroup AS _product_group,
                 b~baseunit AS _base_unit,
                 b~productoldid AS _product_old_i_d,
                 b~laboratoryordesignoffice AS _laboratory_or_design_office,
                 b~crossplantstatus AS _cross_plant_status,
                 b~manufacturernumber AS _manufacturer_number,
                 b~productmanufacturernumber AS _product_manufacturer_number,
                 b~creationdatetime AS _creation_date_time,
                 b~createdbyuser AS _created_by_user,
                 b~lastchangedatetime AS _last_change_date_time,
                 b~lastchangedbyuser AS _last_changed_by_user,
                 c~productdescription AS _product_description,
                 a~plant AS _plant,
                 a~ismarkedfordeletion AS _is_marked_for_deletion,
                 d~valuationclass AS _valuation_class
            FROM i_productplantbasic WITH PRIVILEGED ACCESS AS a
           INNER JOIN i_product WITH PRIVILEGED ACCESS AS b
              ON b~product = a~product
            LEFT OUTER JOIN i_productdescription WITH PRIVILEGED ACCESS AS c
              ON c~product = a~product
             AND c~language = @sy-langu"ls_ztbc_1001-language
            LEFT OUTER JOIN i_productvaluationbasic WITH PRIVILEGED ACCESS AS d
              ON d~product = a~product
             AND d~valuationarea = a~plant
           WHERE a~product = @lv_product
             AND a~plant = @lv_plant
            INTO TABLE @DATA(lt_product).
        ELSE.
          "Obtain data of product
          SELECT b~product AS _product,
                 b~producttype AS _product_type,
                 b~productgroup AS _product_group,
                 b~baseunit AS _base_unit,
                 b~productoldid AS _product_old_i_d,
                 b~laboratoryordesignoffice AS _laboratory_or_design_office,
                 b~crossplantstatus AS _cross_plant_status,
                 b~manufacturernumber AS _manufacturer_number,
                 b~productmanufacturernumber AS _product_manufacturer_number,
                 b~creationdatetime AS _creation_date_time,
                 b~createdbyuser AS _created_by_user,
                 b~lastchangedatetime AS _last_change_date_time,
                 b~lastchangedbyuser AS _last_changed_by_user,
                 c~productdescription AS _product_description,
                 a~plant AS _plant,
                 a~ismarkedfordeletion AS _is_marked_for_deletion,
                 d~valuationclass AS _valuation_class
            FROM i_productplantbasic WITH PRIVILEGED ACCESS AS a
           INNER JOIN i_product WITH PRIVILEGED ACCESS AS b
              ON b~product = a~product
            LEFT OUTER JOIN i_productdescription WITH PRIVILEGED ACCESS AS c
              ON c~product = a~product
             AND c~language = @sy-langu"ls_ztbc_1001-language
            LEFT OUTER JOIN i_productvaluationbasic WITH PRIVILEGED ACCESS AS d
              ON d~product = a~product
             AND d~valuationarea = a~plant
           WHERE a~plant = @lv_plant
             AND b~lastchangedatetime >= @lv_timestampl
            INTO TABLE @lt_product.
        ENDIF.

        DATA(lv_lines) = lines( lt_product ).
        ls_res-_msgty = 'S'.

        "プラント&1品目マスタ連携成功 &2 件！
        MESSAGE ID lc_msgid TYPE lc_msgty NUMBER 058 WITH lv_plant lv_lines INTO ls_res-_msg.
      CATCH cx_root INTO lo_root_exc.
        ls_res-_msgty = 'E'.
    ENDTRY.

    SORT lt_product BY _product.

    LOOP AT lt_product INTO DATA(ls_product).
      MOVE-CORRESPONDING ls_product TO ls_material.

      TRY.
          ls_material-_base_unit = zzcl_common_utils=>conversion_cunit( EXPORTING iv_alpha = lc_alpha_out
                                                                                  iv_input = ls_material-_base_unit ).
        CATCH zzcx_custom_exception INTO lo_root_exc.
      ENDTRY.

      lv_timestamp = trunc( ls_material-_last_change_date_time ).

      "Convert date and time from zero zone to time zone of plant
      CONVERT TIME STAMP lv_timestamp
              TIME ZONE ls_ztbc_1001-zonlo_out
              INTO DATE lv_date
                   TIME lv_time.

      lv_timestamp = lv_date && lv_time.
      ls_material-_last_change_date_time = lv_timestamp + frac( ls_material-_last_change_date_time ).

      APPEND ls_material TO ls_res-_data-_material.
      CLEAR ls_material.
    ENDLOOP.

    "ABAP->JSON
*    DATA(lv_res_body) = xco_cp_json=>data->from_abap( ls_res )->apply( VALUE #(
*                          ( xco_cp_json=>transformation->underscore_to_pascal_case ) ) )->to_string( ).

    DATA(lv_res_body) = /ui2/cl_json=>serialize( data = ls_res
*                                                 compress = 'X'
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    "Set request data
    response->set_text( lv_res_body ).
  ENDMETHOD.
ENDCLASS.
