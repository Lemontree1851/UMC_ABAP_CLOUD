CLASS zcl_http_prdata_001 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_response,
*        PurchaseRequisition             TYPE  C  LENGTH  10   ,      "購買依頼番号
*        PurchaseRequisitionItem         TYPE  C  LENGTH  5    ,      "購買依頼明細
*        PurchasingGroup                 TYPE  C  LENGTH  3    ,      "購買グループ
*        FixedSupplier                   TYPE  C  LENGTH  10   ,      "固定仕入先
*        Material                        TYPE  C  LENGTH  40   ,      "品目
*        PurchaseRequisitionItemText     TYPE  C  LENGTH  40   ,      "テキスト(短)
*        MaterialPlannedDeliveryDurn     TYPE  C  LENGTH  3    ,      "納入予定日数
*        MaterialGoodsReceiptDuration    TYPE  C  LENGTH  3    ,      "入庫処理日数
*        DeliveryDate                    TYPE  C  LENGTH  8    ,      "納入日付
*        Plant                           TYPE  C  LENGTH  4    ,      "プラント
*        RequestedQuantity               TYPE  C  LENGTH  13   ,      "購買依頼数量
*        BusinessPartnerName1            TYPE  C  LENGTH  40   ,      "名称									
*        MinimumPurchaseOrderQuantity    TYPE  C  LENGTH  13   ,      "最低発注数量
*        ProductManufacturerNumber       TYPE  C  LENGTH  40   ,      "製造者製品コード
*        PurchasingGroupName             TYPE  C  LENGTH  18   ,      "購買グループ名
*        ARRANGE_START_DATE              type  c  length  8    ,
        pr_number              TYPE c LENGTH 10,     "購買依頼番号
        d_no                   TYPE c LENGTH 5,      "購買依頼明細
        pur_group              TYPE c LENGTH 3,      "購買グループ
        supplier               TYPE c LENGTH 10,     "固定仕入先
        material               TYPE c LENGTH 40,     "品目
        material_text          TYPE c LENGTH 40,
        delivary_days          TYPE c LENGTH 3,
        arrange_start_date     TYPE c LENGTH 8,
        arrange_end_date       TYPE c LENGTH 8,
        plant                  TYPE c LENGTH 4,
        arrange_qty            TYPE c LENGTH 13,
        name1                  TYPE c LENGTH 40,
        min_delivery_qty       TYPE c LENGTH 13,
        manuf_code             TYPE c LENGTH 40,
        pur_group_name         TYPE c LENGTH 18,
        supplierphonenumber    TYPE c LENGTH 16,
        suppliermaterialnumber TYPE c LENGTH 35,
        m_r_p_controller       TYPE c LENGTH 3,  " ADD BY XINLEI XU 2025/03/25 CR#4293
      END OF ty_response,
      BEGIN OF ty_output,
        items TYPE STANDARD TABLE OF ty_response WITH EMPTY KEY,
      END OF ty_output.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: ls_response       TYPE ty_response,
          es_response       TYPE ty_output,
          lv_previous_month TYPE datum,
          lv_text           TYPE string,
          lv_error          TYPE c,
          lc_header_content TYPE string VALUE 'content-type',
          lc_content_type   TYPE string VALUE 'text/json',
          lv_dur            TYPE i,
          lc_month_1        TYPE i VALUE '1'.
ENDCLASS.


CLASS zcl_http_prdata_001 IMPLEMENTATION.

  METHOD if_http_service_extension~handle_request.
    TYPES: BEGIN OF ty_mrp_record,
             material                   TYPE i_supplydemanditemtp-material,
             mrparea                    TYPE i_supplydemanditemtp-mrparea,
             mrpplant                   TYPE i_supplydemanditemtp-mrpplant,
             mrpelement                 TYPE i_supplydemanditemtp-mrpelement,
             mrpelementitem             TYPE i_supplydemanditemtp-mrpelementitem,
             mrpelementreschedulingdate TYPE datum,
           END OF ty_mrp_record,
           BEGIN OF ty_mrp_result,
             results TYPE TABLE OF ty_mrp_record WITH DEFAULT KEY,
           END OF ty_mrp_result,
           BEGIN OF ty_mrp_response,
             d TYPE ty_mrp_result,
           END OF ty_mrp_response.

    DATA: lt_mrp_data     TYPE TABLE OF ty_mrp_record,
          ls_mrp_response TYPE ty_mrp_response,
          lv_filter       TYPE string,
          lv_workingday   TYPE datum.

*    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
*    DATA(lv_pre_month) = zzcl_common_utils=>calc_date_subtract( EXPORTING date  = lv_date
*                                                                          month = lc_month_1 ).
*    lv_pre_month+6(2) = '01'.

    SELECT a~purchaserequisition,
           a~purchaserequisitionitem,
           a~purchasinggroup,
           a~fixedsupplier,
           a~material,
           a~purchaserequisitionitemtext,
           a~materialplanneddeliverydurn,
           a~materialgoodsreceiptduration,
           a~deliverydate,
           a~plant,
           a~requestedquantity,
           b~businesspartnername1,
           d~minimumpurchaseorderquantity,
           e~productmanufacturernumber,
           f~purchasinggroupname,
           a~purchaserequisitionreleasedate,  "add by stanley 20250306
           a~mrpcontroller, " ADD BY XINLEI XU 2025/03/25 CR#4293
           g~goodsreceiptduration " ADD BY XINLEI XU 2025/03/26 CR#4293
      FROM i_purchaserequisitionitemapi01 WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS b ON b~supplier = a~fixedsupplier
      LEFT JOIN i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS c ON c~material = a~material
                                                                       AND c~supplier = a~fixedsupplier
      LEFT JOIN i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS AS d ON d~purchasingorganization = a~plant
                                                                          AND d~plant = a~plant
                                                                          AND d~purchasinginforecord = c~purchasinginforecord
      LEFT JOIN i_product WITH PRIVILEGED ACCESS AS e ON e~product = a~material
      LEFT JOIN i_purchasinggroup WITH PRIVILEGED ACCESS AS f ON f~purchasinggroup = a~purchasinggroup
      LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS g ON g~product = a~material
                                                               AND g~plant = a~plant
*&--MOD BEGIN BY XINLEI XU 2025/03/28 BUG Fixed
*     WHERE purchasereqncreationdate BETWEEN @lv_pre_month AND @lv_date
     WHERE a~processingstatus = 'N'
       AND a~isdeleted IS INITIAL
*&--MOD END BY XINLEI XU 2025/03/28
      INTO TABLE @DATA(lt_pr).

    IF lt_pr IS NOT INITIAL.
      SELECT supplier,
             material,
             supplierphonenumber,
             suppliermaterialnumber
       FROM i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_pr
      WHERE supplier = @lt_pr-fixedsupplier
        AND material = @lt_pr-material
        AND isdeleted <> 'X'
       INTO TABLE @DATA(lt_phno).                  "#EC CI_NO_TRANSFORM
      SORT lt_phno BY supplier material.

*&--ADD BEGIN BY XINLEI XU 2025/03/26 CR#4293
      DATA(lt_plant) = lt_pr.
      SORT lt_plant BY plant.
      DELETE ADJACENT DUPLICATES FROM lt_plant COMPARING plant.
      DATA(lv_path)   = |/API_MRP_MATERIALS_SRV_01/SupplyDemandItems?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.
      DATA(lv_select) = |Material,MRPArea,MRPPlant,MRPElement,MRPElementItem,MRPElementReschedulingDate|.

      LOOP AT lt_plant INTO DATA(ls_plant).
        CLEAR lv_filter.
        lv_filter = |MRPPlant eq '{ ls_plant-plant }' and MRPArea eq '{ ls_plant-plant }'|.

        zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                     iv_method      = if_web_http_client=>get
                                                     iv_select      = lv_select
                                                     iv_filter      = lv_filter
                                           IMPORTING ev_status_code = DATA(lv_status_code)
                                                     ev_response    = DATA(lv_response) ).
        IF lv_status_code = 200.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                     CHANGING  data = ls_mrp_response ).

          APPEND LINES OF ls_mrp_response-d-results TO lt_mrp_data.
        ENDIF.
      ENDLOOP.
      DELETE lt_mrp_data WHERE mrpelement IS INITIAL
                            OR mrpelementitem IS INITIAL
                            OR mrpelementreschedulingdate IS INITIAL.
      SORT lt_mrp_data BY mrpplant material mrpelement mrpelementitem mrpelementreschedulingdate.
*&--ADD END BY XINLEI XU 2025/03/26 CR#4293

      LOOP AT lt_pr INTO DATA(lw_pr).
        CLEAR ls_response.
        READ TABLE lt_phno INTO DATA(lw_phno) WITH KEY supplier = lw_pr-fixedsupplier
                                                       material = lw_pr-material BINARY SEARCH.
        IF sy-subrc = 0.
*&--ADD BEGIN BY XINLEI XU 2025/03/25 CR#4293
          IF lw_phno-supplierphonenumber = 'NOT SEND FC'. " 連携対象外となる
            CONTINUE.
          ENDIF.
*&--ADD END BY XINLEI XU 2025/03/25
          ls_response-supplierphonenumber = lw_phno-supplierphonenumber.
          ls_response-suppliermaterialnumber = lw_phno-suppliermaterialnumber.
        ENDIF.
        ls_response-pr_number          = lw_pr-purchaserequisition.
        ls_response-d_no               = lw_pr-purchaserequisitionitem.
        ls_response-pur_group          = lw_pr-purchasinggroup.
        ls_response-supplier           = lw_pr-fixedsupplier.
        ls_response-material           = lw_pr-material.
        ls_response-material_text      = lw_pr-purchaserequisitionitemtext.
        ls_response-delivary_days      = lw_pr-materialplanneddeliverydurn.

*       lv_dur = lw_pr-materialplanneddeliverydurn + lw_pr-materialgoodsreceiptduration.
*       ls_response-arrange_start_date = zzcl_common_utils=>calc_date_subtract( EXPORTING date = lw_pr-deliverydate day  = lv_dur ).
        ls_response-arrange_start_date = lw_pr-purchaserequisitionreleasedate." Change By Stanley 20250306
        ls_response-arrange_end_date   = lw_pr-deliverydate.

*&--ADD BEGIN BY XINLEI XU 2025/03/26 CR#4293
        READ TABLE lt_mrp_data INTO DATA(ls_mrp_data) WITH KEY mrpplant = lw_pr-plant
                                                               material = lw_pr-material
                                                               mrpelement = lw_pr-purchaserequisition
                                                               mrpelementitem = lw_pr-purchaserequisitionitem BINARY SEARCH.
        IF sy-subrc = 0.
          " 手配終了日 = 再日程計画日付 - 入库处理日数(稼働日)
          DATA(lv_duration) = lw_pr-goodsreceiptduration.
          CLEAR lv_workingday.
          lv_workingday = ls_mrp_data-mrpelementreschedulingdate.
          IF lv_duration > 0.
            DO.
              lv_workingday -= 1.
              IF zzcl_common_utils=>is_workingday( iv_plant = lw_pr-plant
                                                   iv_date  = lv_workingday ).
                lv_duration -= 1.
              ENDIF.

              IF lv_duration = 0.
                ls_response-arrange_end_date = lv_workingday.
                EXIT.
              ENDIF.
            ENDDO.
          ELSE.
            ls_response-arrange_end_date = lv_workingday.
          ENDIF.
        ENDIF.

        " 手配開始日 = 手配終了日 - MaterialPlannedDeliveryDurn
        CLEAR lv_workingday.
        lv_workingday = zzcl_common_utils=>calc_date_subtract( EXPORTING date = CONV #( ls_response-arrange_end_date )
                                                                         day  = CONV #( lw_pr-materialplanneddeliverydurn ) ).
        IF zzcl_common_utils=>is_workingday( iv_plant = lw_pr-plant
                                             iv_date  = lv_workingday ).
          ls_response-arrange_start_date = lv_workingday.
        ELSE.
          " 計算結果は非稼働日なら前倒しの日付になる
          DO.
            lv_workingday -= 1.
            IF zzcl_common_utils=>is_workingday( iv_plant = lw_pr-plant
                                                 iv_date  = lv_workingday ).
              ls_response-arrange_start_date = lv_workingday.
              EXIT.
            ENDIF.
          ENDDO.
        ENDIF.
*&--ADD END BY XINLEI XU 2025/03/26 CR#4293

        ls_response-plant              = lw_pr-plant.
        ls_response-arrange_qty        = lw_pr-requestedquantity.
        ls_response-name1              = lw_pr-businesspartnername1.
        ls_response-min_delivery_qty   = lw_pr-minimumpurchaseorderquantity.
        ls_response-manuf_code         = lw_pr-productmanufacturernumber.
        ls_response-pur_group_name     = lw_pr-purchasinggroupname.
        ls_response-m_r_p_controller   = lw_pr-mrpcontroller. " ADD BY XINLEI XU 2025/03/25 CR#4293
        CONDENSE ls_response-pr_number.
        CONDENSE ls_response-d_no.
        CONDENSE ls_response-pur_group.
        CONDENSE ls_response-supplier.
        CONDENSE ls_response-material.
        CONDENSE ls_response-material_text.
        CONDENSE ls_response-delivary_days.
        CONDENSE ls_response-arrange_start_date.
        CONDENSE ls_response-arrange_end_date.
        CONDENSE ls_response-plant.
        CONDENSE ls_response-arrange_qty.
        CONDENSE ls_response-name1.
        CONDENSE ls_response-min_delivery_qty.
        CONDENSE ls_response-manuf_code.
        CONDENSE ls_response-pur_group_name.

        APPEND ls_response TO es_response-items.
      ENDLOOP.
    ELSE.
      lv_error = 'X'.
      lv_text = 'There is no data'.
    ENDIF.

    IF lv_error IS NOT INITIAL.
      " propagate any errors raised
      response->set_status( '500' ).
      response->set_text( lv_text ).
    ELSE.
      " respond with success payload
      response->set_status( '200' ).
      DATA(lv_json_string) = xco_cp_json=>data->from_abap( es_response )->apply( VALUE #(
                              ( xco_cp_json=>transformation->underscore_to_pascal_case )
                             ) )->to_string( ).
      response->set_text( lv_json_string ).
      response->set_header_field( i_name  = lc_header_content
                                  i_value = lc_content_type ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
