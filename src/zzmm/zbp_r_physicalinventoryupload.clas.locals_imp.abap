CLASS lhc_physicalinvupload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_physicalinventoryupload.
    TYPES:  row TYPE i,
          END OF lty_request,

          lty_request_t TYPE TABLE OF lty_request.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR physicalinvupload RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION physicalinvupload~processlogic RESULT result.

    METHODS excute CHANGING ct_data TYPE lty_request_t.
    METHODS get_message IMPORTING io_message    TYPE REF TO if_abap_behv_message
                        RETURNING VALUE(rv_msg) TYPE string.

ENDCLASS.

CLASS lhc_physicalinvupload IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD processlogic.
    DATA lt_request TYPE TABLE OF lty_request.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      "key-%param-zzkey = '[' && key-%param-zzkey && ']'.
      CLEAR lt_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).

      CASE lv_event.

        WHEN 'EXCUTE'.

          excute( CHANGING ct_data = lt_request ) .

        WHEN OTHERS.

      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD excute.
    TYPES:
      BEGIN OF ts_sourcelist,
        _material                    TYPE string,
        _plant                       TYPE string,
        _validity_start_date         TYPE string,
        _validity_end_date           TYPE string,
        _supplier                    TYPE string,
        _supplying_plant             TYPE string,
        _source_of_supply_is_blocked TYPE string,
        _purchasing_organization     TYPE string,
        _m_r_p_sourcing_control      TYPE string,
      END OF ts_sourcelist,

      BEGIN OF ty_message,
        lang  TYPE string,
        value TYPE string,
      END OF ty_message,

      BEGIN OF ty_error,
        code    TYPE string,
        message TYPE ty_message,
      END OF ty_error,

      BEGIN OF ty_res_api,
        error TYPE ty_error,
      END OF ty_res_api,

      BEGIN OF lty_update,
        _material              TYPE i_physinvtrydocitem-material,
        _quantity_in_unit_of_entry TYPE string,
        _unit_of_entry           TYPE i_physinvtrydocitem-unitofentry,
        PhysicalInventoryItemIsZero   type XSDBOOLEAN ,
        _batch type i_physinvtrydocitem-Batch,

      END OF lty_update,

      BEGIN OF lty_create,
        material TYPE i_physinvtrydocitem-material,

      END OF lty_create,


      BEGIN OF lty_create_2,
        _material                      TYPE i_physinvtrydocitem-material,
        _supplier                      TYPE i_physinvtrydocitem-supplier,
        reasonforphysinvtrydifference TYPE i_physinvtrydocitem-reasonforphysinvtrydifference,
      END OF lty_create_2,

      BEGIN OF lty_create_header,
        _plant                     TYPE i_physinvtrydocheader-plant,
        _storage_location           TYPE i_physinvtrydocheader-storagelocation,
        _inventoryspecialstocktype TYPE i_physinvtrydocheader-inventoryspecialstocktype,
        to_phyinvdocitem          TYPE TABLE OF lty_create_2 WITH DEFAULT KEY,
      END OF lty_create_header,

      BEGIN OF lty_response_2,
        d TYPE lty_create_header,
      END OF lty_response_2.

    DATA:
      ls_request       TYPE lty_update,

      ls_header        TYPE lty_create_header,
      ls_item          TYPE lty_create_2,
      ls_request_2     TYPE lty_response_2,

      lt_sourcelist    TYPE STANDARD TABLE OF ts_sourcelist,
      ls_sourcelist    TYPE ts_sourcelist,
      ls_res_api       TYPE ty_res_api,
      lt_header_create TYPE TABLE FOR CREATE i_purchasingsourcelisttp,
      ls_header_create TYPE STRUCTURE FOR CREATE i_purchasingsourcelisttp,
      lt_item_create   TYPE TABLE FOR CREATE i_purchasingsourcelisttp\_purchasingsourceitem,
      ls_item_create   TYPE STRUCTURE FOR CREATE i_purchasingsourcelisttp\_purchasingsourceitem,
      lt_item_update   TYPE TABLE FOR UPDATE i_purchasingsourcelistitemtp,
      ls_item_update   TYPE STRUCTURE FOR UPDATE i_purchasingsourcelistitemtp,
      lt_header_delete TYPE TABLE FOR DELETE i_purchasingsourcelisttp,
      ls_header_delete TYPE STRUCTURE FOR DELETE i_purchasingsourcelisttp,
      lt_item_delete   TYPE TABLE FOR DELETE i_purchasingsourcelistitemtp,
      ls_item_delete   TYPE STRUCTURE FOR DELETE i_purchasingsourcelistitemtp.
    DATA:
      lo_root_exc TYPE REF TO cx_root,
      lv_path     TYPE string,
      lv_path_c   TYPE string,
      lv_usage(1) TYPE c,
      i           TYPE i,
      m           TYPE i,
      n           TYPE i,
      lv_message  TYPE string,
      lv_matnr    TYPE c LENGTH 18,
      ls_error    TYPE zzcl_odata_utils=>gty_error.



*--------------------------------just for test
"用于创建成功后的返回值
TYPES: BEGIN OF ty_response_S,
         FiscalYear                       TYPE string,
         PhysicalInventoryDocument        TYPE string,
       END OF ty_response_S,


       BEGIN OF ty_response_ss,
         d TYPE ty_response_S,
       END OF ty_response_Ss.

   data:ls_response_ss type ty_response_Ss.
*-----------------------------------

*-----------------------------------
types: BEGIN OF ty_response_C,

           PhysicalInventoryDocument    type string,
           PhysicalInventoryDocumentItem type string,

       END OF TY_RESPONSE_C,


       BEGIN OF ty_response_cc,
           d type ty_response_c,
       END OF TY_RESPONSE_CC.
   data:ls_response_cc type ty_response_cc.
*-----------------------------------



    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data>).

      SELECT
          b~physicalinventorydocument,
          b~physicalinventorydocumentitem
          FROM i_physinvtrydocitem WITH PRIVILEGED ACCESS AS b
          INNER JOIN i_physinvtrydocheader WITH PRIVILEGED ACCESS AS a
          ON a~physicalinventorydocument = b~physicalinventorydocument
          WHERE a~plant                          = @<ls_data>-plant
            AND a~storagelocation                = @<ls_data>-storagelocation
            AND a~inventoryspecialstocktype      = @<ls_data>-inventoryspecialstocktype
            AND b~material                       = @<ls_data>-material
            AND b~supplier                       = @<ls_data>-supplier
            AND b~batch                          = @<ls_data>-batch
            AND b~physinvtryitemisdeleted        <> 'X'
            AND b~physicalinventoryitemiscounted <> 'X'
          INTO @DATA(ls_phyinv).
      ENDSELECT.

      data:
          lv_unit type I_Product-BaseUnit.


      DATA(LV_MATNRIN) = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in  iv_input = <ls_data>-material ).


      if <ls_data>-unitofentry is INITIAL.
         SELECT  BASEUNIT
         FROM I_Product WITH PRIVILEGED ACCESS
         WHERE Product = @LV_MATNRIN
         into @lv_unit
         UP TO 1 ROWS .
         ENDSELECT.

        TRY.
        DATA(lv_unit1) = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = lv_unit ).
            ##NO_HANDLER
          CATCH zzcx_custom_exception.
            " handle exception
        ENDTRY.
         <ls_data>-UnitOfEntry = lv_unit1.
         clear: lv_unit1, LV_MATNRIN .

       ENDIF.

      "调用api patch
      IF  ls_phyinv-physicalinventorydocument IS NOT INITIAL .

       "因为有头和明细，所以调用patch 更新
        ls_request = VALUE #( _material                       = <ls_data>-material
                              _quantity_in_unit_of_entry      = <ls_data>-quantity
                              _unit_of_entry                  = <ls_data>-unitofentry
                              PhysicalInventoryItemIsZero     = <ls_data>-Physicalinventoryitemiszero
                              _batch                          = <ls_data>-Batch
                              ).


        "将数组转换为json格式
        DATA(lv_requestbody) = /ui2/cl_json=>serialize( data = ls_request
                                                    compress = 'X'
                                                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
        "因为调用api的时候，必须驼峰命名，自动转json 并不是所有的字段都是对的

        REPLACE ALL OCCURRENCES OF `Quantityinunitofentry`   IN lv_requestbody  WITH `QuantityInUnitOfEntry`.
        REPLACE ALL OCCURRENCES OF `Unitofentry`   IN lv_requestbody  WITH `UnitOfEntry`.
        REPLACE ALL OCCURRENCES OF 'physicalinventoryitemiszero' IN lv_requestbody  WITH `PhysicalInventoryItemIsZero`.



        "修改地址中的信息
        DATA(lv_a) = '2024'."顾问说先固定 2024
        data(lv_b) = ls_phyinv-PhysicalInventoryDocument.
        data(lv_c) = ls_phyinv-PhysicalInventoryDocumentItem.

        "使用字符串定义 路径
        lv_path = |/API_PHYSICAL_INVENTORY_DOC_SRV/A_PhysInventoryDocItem(FiscalYear='{ lv_a }',PhysicalInventoryDocument='{ lv_b }',PhysicalInventoryDocumentItem='{ lv_c }')?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

        "调用共通方法
        zzcl_common_utils=>request_api_v2( EXPORTING iv_path  = lv_path
                                           iv_method      = if_web_http_client=>patch
                                           iv_body        = lv_requestbody
                                 IMPORTING ev_status_code = DATA(lv_status_code)
                                           ev_response    = DATA(lv_response) ).
        "成功会返回204
        IF lv_status_code = 204.

          <ls_data>-status = 'S'.
          <ls_data>-message = |実地棚卸伝票 { lv_b } 明細 10 は変更されました。|.

        "如果失败则报错
        ELSE.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                           CHANGING  data = ls_error ).
          "前台返回值
          <ls_data>-status = 'E'.
          <ls_data>-message = ls_error-error-message-value.

        ENDIF.

     "调用api 先使用post创建 再使用patch更新
      ELSE.

        ls_header = VALUE #( _plant                         = <ls_data>-Plant
                             _Storage_Location               = <ls_data>-Storagelocation
                             _inventoryspecialstocktype = <ls_data>-Inventoryspecialstocktype
                              ).

        ls_item   = VALUE #( _Material                      = <ls_data>-Material
                             _supplier                      = <ls_data>-supplier
                             reasonforphysinvtrydifference = <ls_data>-reasonforphysinvtrydifference
                              ).

        APPEND LS_ITEM TO LS_HEADER-to_phyinvdocitem.

        DATA(lv_requestbody_c) = /ui2/cl_json=>serialize( data = LS_HEADER
                                                    compress = 'X'
                                                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

        REPLACE ALL OCCURRENCES OF 'Inventoryspecialstocktype' IN lv_requestbody_c WITH 'InventorySpecialStockType'.
        REPLACE ALL OCCURRENCES OF 'Reasonforphysinvtrydifference' IN lv_requestbody_c WITH 'Reasonforphysinvtrydifference'.
        REPLACE ALL OCCURRENCES OF 'toPhyinvdocitem' IN lv_requestbody_c WITH 'to_PhysicalInventoryDocumentItem'.
        lv_path_c = |/API_PHYSICAL_INVENTORY_DOC_SRV/A_PhysInventoryDocHeader?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

        zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path_c
                                       iv_method      = if_web_http_client=>post
                                       iv_body        = lv_requestbody_c
                             IMPORTING ev_status_code = DATA(lv_status_code_C)
                                       ev_response    = DATA(lv_response_C) ).

        IF lv_status_code_c = 201.



          xco_cp_json=>data->from_string( lv_response_C )->apply( VALUE #(
              ( xco_cp_json=>transformation->underscore_to_pascal_case )
          ) )->write_to( REF #( ls_response_ss ) ).

            <ls_data>-message = |実地棚卸伝票 { ls_response_ss-d-PhysicalInventoryDocument } が登録されました。|.



          ls_request = VALUE #( _material                         = <ls_data>-material
                                _quantity_in_unit_of_entry            = <ls_data>-quantity
                                _unit_of_entry                      = <ls_data>-unitofentry
                                PhysicalInventoryItemIsZero      = <ls_data>-PhysicalInventoryItemIsZero
                                _batch                            = <ls_data>-Batch
                                ).

           lv_requestbody = /ui2/cl_json=>serialize( data = ls_request
                                                    compress = 'X'
                                                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

          REPLACE ALL OCCURRENCES OF `Quantityinunitofentry`   IN lv_requestbody  WITH `QuantityInUnitOfEntry`.
          REPLACE ALL OCCURRENCES OF `Unitofentry`   IN lv_requestbody  WITH `UnitOfEntry`.
          REPLACE ALL OCCURRENCES OF 'physicalinventoryitemiszero' IN lv_requestbody  WITH `PhysicalInventoryItemIsZero`.

          lv_a = ls_response_ss-d-fiscalyear.
          lv_b = ls_response_ss-d-PhysicalInventoryDocument.
          lv_c = '1'.

          lv_path = |/API_PHYSICAL_INVENTORY_DOC_SRV/A_PhysInventoryDocItem(FiscalYear='{ lv_a }',PhysicalInventoryDocument='{ lv_b }',PhysicalInventoryDocumentItem='{ lv_c }')?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

          zzcl_common_utils=>request_api_v2( EXPORTING iv_path  = lv_path
                                             iv_method      = if_web_http_client=>patch
                                             iv_body        = lv_requestbody
                                   IMPORTING ev_status_code = lv_status_code
                                             ev_response    = lv_response ).

          IF lv_status_code = 204.

            /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                           CHANGING  data = ls_response_cc ).

              <ls_data>-status = 'S'.
              <ls_data>-message = |実地棚卸伝票 { lv_b } 明細 10 は登録され、変更されました。|.

          else.

              /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                               CHANGING  data = ls_error ).

              <ls_data>-status = 'E'.
              <ls_data>-message = <ls_data>-message && ' しかし  ' && ls_error-error-message-value.

          ENDIF.

        ELSE.

          /ui2/cl_json=>deserialize( EXPORTING json = lv_response_C
                           CHANGING  data = ls_error ).

          <ls_data>-status = 'E'.
          <ls_data>-message = ls_error-error-message-value.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_message.

    MESSAGE ID io_message->if_t100_message~t100key-msgid
          TYPE io_message->m_severity
        NUMBER io_message->if_t100_message~t100key-msgno
          WITH io_message->if_t100_dyn_msg~msgv1
               io_message->if_t100_dyn_msg~msgv2
               io_message->if_t100_dyn_msg~msgv3
               io_message->if_t100_dyn_msg~msgv4 INTO rv_msg.


  ENDMETHOD.

ENDCLASS.
