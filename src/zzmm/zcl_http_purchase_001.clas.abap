CLASS zcl_http_purchase_001 DEFINITION

  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    "入参
    TYPES:
      BEGIN OF ty_inputs,
        material_number TYPE c    LENGTH 40,            "SAP品目コード"
        bp_number       TYPE c    LENGTH 10,            "仕入先"
        plant_id        TYPE c    LENGTH 10,            "プラント"
      END OF ty_inputs.

    "传参
    TYPES:
      BEGIN OF ty_output,
        baseunit                     TYPE c    LENGTH 3,            "基本数量単位
        suppliercertorigincountry    TYPE c    LENGTH 3,            "原産国
        purchasinginforecord         TYPE c    LENGTH 10,           "購買情報
        suppliermaterialnumber       TYPE c    LENGTH 35,           "仕入先品目コード
        pricingdatecontrol           TYPE c    LENGTH 20,            "価格設定日制御　
        minimumpurchaseorderquantity TYPE c    LENGTH 13,           "最小購買発注数量
        incotermsclassification      TYPE c    LENGTH 3,            "インコタームズ
        incotermslocation1           TYPE c    LENGTH 70,           "インコタームズ場所１
        materialpriceunitqty         TYPE c    LENGTH 5,            "価格単位
        netpriceamount               TYPE c    LENGTH 11,           "正味価格
        pricevalidityenddate         TYPE c    LENGTH 8,            "有効終了日
        materialplanneddeliverydurn  TYPE c    LENGTH 5,            "納入予定日
        currency                     TYPE c    LENGTH 3,            "通貨
      END OF ty_output,

      BEGIN OF ty_response,
        baseunit                     TYPE c    LENGTH 3,            "基本数量単位
        suppliercertorigincountry    TYPE c    LENGTH 3,            "原産国
        purchasinginforecord         TYPE c    LENGTH 10,           "購買情報
        suppliermaterialnumber       TYPE c    LENGTH 35,           "仕入先品目コード
        pricingdatecontrol           TYPE c    LENGTH 20,            "価格設定日制御　
        minimumpurchaseorderquantity TYPE c    LENGTH 13,           "最小購買発注数量
        incotermsclassification      TYPE c    LENGTH 3,            "インコタームズ
        incotermslocation1           TYPE c    LENGTH 70,           "インコタームズ場所１
        materialpriceunitqty         TYPE c    LENGTH 5,            "価格単位
        netpriceamount               TYPE c    LENGTH 11,           "正味価格
        pricevalidityenddate         TYPE c    LENGTH 8,            "有効終了日
        materialplanneddeliverydurn  TYPE c    LENGTH 5,            "納入予定日
        currency                     TYPE c    LENGTH 3,            "通貨
      END OF ty_response,

      BEGIN OF ty_output1,
        items TYPE STANDARD TABLE OF ty_output WITH EMPTY KEY,
      END OF ty_output1,

      ty_output_table TYPE STANDARD TABLE OF ty_output WITH EMPTY KEY.


*    TYPES: tt_items TYPE STANDARD TABLE OF ty_inputs WITH EMPTY KEY.
*
*    TYPES:
*      BEGIN OF ty_items,
*        items  TYPE tt_items,
*      END OF ty_items.
*
*    TYPES: lt_items TYPE STANDARD TABLE OF ty_items WITH EMPTY KEY.
*
*    DATA: lt_req TYPE STANDARD TABLE OF lt_items.

    INTERFACES if_http_service_extension .
PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      lt_req            TYPE STANDARD TABLE OF ty_inputs,
      ls_req1           TYPE ty_inputs,
      lt_req1           TYPE STANDARD TABLE OF ty_inputs,
      ls_output         TYPE ty_output,
      lv_error(1)       TYPE c,
      lv_text           TYPE string,
      es_outputs        TYPE ty_output1,
      es_response       TYPE ty_output,
      lc_header_content TYPE string VALUE 'content-type',
      lc_content_type   TYPE string VALUE 'text/json'.

    DATA:
      lt_inputs TYPE STANDARD TABLE OF ty_inputs,
      ls_inputs TYPE ty_inputs.

    DATA:
      lv_request  TYPE string,
      ls_response TYPE ty_response.

*    DATA:
*      lv_token_json TYPE string,
*      lv_token      TYPE string,
*      lv_status     TYPE i.

ENDCLASS.


CLASS zcl_http_purchase_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(lv_req_body) = request->get_text( ).

    DATA(lv_header) = request->get_header_field( i_name = 'form' ).

    DATA(lv_tst) = request->get_form_fields_cs( ).

    IF lv_header = 'XML'.

    ELSE.
      "first deserialize the request
*      xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
*          ( xco_cp_json=>transformation->underscore_to_pascal_case )
*      ) )->write_to( REF #( lt_req ) ).

      /ui2/cl_json=>deserialize(
                                      EXPORTING json = lv_req_body
                                      CHANGING data = lt_req ).

    ENDIF.

    IF lt_req IS NOT INITIAL.

      LOOP AT lt_req INTO DATA(ls_req).

        ls_req-bp_number = |{ ls_req-bp_number ALPHA = IN }|.

        " 查询第一张表
        SELECT baseunit,suppliercertorigincountry,purchasinginforecord,suppliermaterialnumber,supplier,material,isdeleted
          FROM i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS
          WHERE supplier  = @ls_req-bp_number
            AND material  = @ls_req-material_number
            AND isdeleted = ' '
          INTO @DATA(ls_porecord01).
        ENDSELECT.

        " 查询第二张表
        SELECT  pricingdatecontrol,
                minimumpurchaseorderquantity,
                incotermsclassification,
                incotermslocation1,
                materialpriceunitqty,
                netpriceamount,
                pricevalidityenddate,
                currency,
                materialplanneddeliverydurn,
                purchasinginforecord
          FROM i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS
          WHERE purchasinginforecord   = @ls_porecord01-purchasinginforecord
            AND purchasingorganization = @ls_req-plant_id
            AND ismarkedfordeletion    = ' '
          INTO @DATA(ls_porecord02).
        ENDSELECT.

        CLEAR ls_req.

        " 组装输出数据
        CLEAR ls_response.
        DATA(lv_unit) = ls_porecord01-baseunit.
        DATA(lv_unit1) = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = lv_unit ).
*        ls_porecord01-baseunit = |{ ls_porecord01-baseunit ALPHA = IN }|.
        ls_response-baseunit                       = lv_unit1.
        ls_response-suppliercertorigincountry      = ls_porecord01-suppliercertorigincountry.
        ls_response-purchasinginforecord           = ls_porecord01-purchasinginforecord.
        ls_response-suppliermaterialnumber         = ls_porecord01-suppliermaterialnumber.

        " 价格设置日控制文本处理
        CASE ls_porecord02-pricingdatecontrol.
          WHEN '1'.
            ls_response-pricingdatecontrol = '購買発注日付'.
          WHEN '2'.
            ls_response-pricingdatecontrol = '納入期日'.
          WHEN OTHERS.
            ls_response-pricingdatecontrol = ''. " 可以定义一个默认值
        ENDCASE.

        " 计算单价
        IF ls_porecord02-pricevalidityenddate >= sy-datum.
          ls_response-netpriceamount = ls_porecord02-netpriceamount / ls_porecord02-materialpriceunitqty.
        ELSE.
          ls_response-netpriceamount = ''. " 单价为空
        ENDIF.

        ls_response-minimumpurchaseorderquantity   = ls_porecord02-minimumpurchaseorderquantity.
        ls_response-incotermsclassification        = ls_porecord02-incotermsclassification.
        ls_response-incotermslocation1             = ls_porecord02-incotermslocation1.
        ls_response-materialpriceunitqty           = ls_porecord02-materialpriceunitqty.
        ls_response-pricevalidityenddate           = ls_porecord02-pricevalidityenddate.
        ls_response-materialplanneddeliverydurn    = ls_porecord02-materialplanneddeliverydurn.
        ls_response-currency                       = ls_porecord02-currency.
        CONDENSE ls_response-baseunit.
        CONDENSE ls_response-suppliercertorigincountry.
        CONDENSE ls_response-purchasinginforecord.
        CONDENSE ls_response-suppliermaterialnumber.
        CONDENSE ls_response-pricingdatecontrol.
        CONDENSE ls_response-minimumpurchaseorderquantity.
        CONDENSE ls_response-incotermsclassification.
        CONDENSE ls_response-incotermslocation1.
        CONDENSE ls_response-materialpriceunitqty.
        CONDENSE ls_response-netpriceamount.
        CONDENSE ls_response-pricevalidityenddate.
        CONDENSE ls_response-materialplanneddeliverydurn.
        CONDENSE ls_response-currency.
        APPEND ls_response TO es_outputs-items.

      ENDLOOP.
    ENDIF.

    IF es_outputs-items IS INITIAL.
      lv_text = 'error'.
      "propagate any errors raised
      response->set_status( '500' )."500
      response->set_text( lv_text ).
    ELSE.

      "respond with success payload
      response->set_status( '200' ).

      DATA(lv_json_string) = xco_cp_json=>data->from_abap( es_outputs )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
         ) )->to_string( ).
      response->set_text( lv_json_string ).
      response->set_header_field( i_name  = lc_header_content
                                  i_value = lc_content_type ).

    ENDIF.

  ENDMETHOD.
ENDCLASS.
