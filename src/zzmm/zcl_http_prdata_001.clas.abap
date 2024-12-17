class ZCL_HTTP_PRDATA_001 definition
  public
  create public .

public section.
"参数
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

        PR_NUMBER            TYPE  C  LENGTH  10   ,      "購買依頼番号
        D_NO                 TYPE  C  LENGTH  5    ,      "購買依頼明細
        PUR_GROUP            TYPE  C  LENGTH  3    ,      "購買グループ
        SUPPLIER             TYPE  C  LENGTH  10   ,      "固定仕入先
        MATERIAL             TYPE  C  LENGTH  40   ,      "品目
        MATERIAL_TEXT        TYPE  C  LENGTH  40   ,
        DELIVARY_DAYS        TYPE  C  LENGTH  3    ,
        ARRANGE_START_DATE   TYPE  C  LENGTH  8    ,
        ARRANGE_END_DATE     TYPE  C  LENGTH  8    ,
        PLANT                TYPE  C  LENGTH  4    ,
        ARRANGE_QTY          TYPE  C  LENGTH  13   ,
        NAME1                TYPE  C  LENGTH  40   ,
        MIN_DELIVERY_QTY     TYPE  C  LENGTH  13   ,
        MANUF_CODE           TYPE  C  LENGTH  40   ,
        PUR_GROUP_NAME       TYPE  C  LENGTH  18   ,
        SupplierPhoneNumber  type c LENGTH 16,
        SupplierMaterialNumber type c LENGTH 35 ,

      END OF ty_response,

      BEGIN OF ty_output,
        items TYPE STANDARD TABLE OF ty_response WITH EMPTY KEY,
      END OF ty_output.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.
"变量
  DATA:
    ls_response       TYPE ty_response,
    es_response       TYPE ty_output,
    lv_previous_month type datum,
    lv_text type string,
    lv_error type     c,
    lc_header_content TYPE string VALUE 'content-type',
    lc_content_type   TYPE string VALUE 'text/json',
    lv_dur type i ,

    lc_month_1        TYPE i VALUE '1'.

ENDCLASS.



CLASS ZCL_HTTP_PRDATA_001 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA:
        lv_date type d,
        lv_pre_month type d.

    lv_date = cl_abap_context_info=>get_system_date( ).

    zzcl_common_utils=>calc_date_subtract(
          EXPORTING
            date      = lv_date
            month     = lc_month_1
          RECEIVING
            calc_date = lv_pre_month ).



    SELECT
                a~PurchaseRequisition                    ,
                a~PurchaseRequisitionItem              ,
                a~PurchasingGroup                      ,
                a~FixedSupplier                        ,
                a~Material                             ,
                a~PurchaseRequisitionItemText          ,
                a~MaterialPlannedDeliveryDurn          ,
                a~MaterialGoodsReceiptDuration         ,
                a~DeliveryDate                         ,
                a~Plant                                ,
                a~RequestedQuantity                    ,
                b~BusinessPartnerName1                 ,
                d~MinimumPurchaseOrderQuantity         ,
                e~ProductManufacturerNumber            ,
                f~PurchasingGroupName

    FROM i_purchaserequisitionitemapi01 WITH PRIVILEGED ACCESS as a
    LEFT JOIN i_supplier WITH PRIVILEGED ACCESS as b
    on b~supplier = a~FixedSupplier
    LEFT JOIN I_PurchasingInfoRecordApi01 WITH PRIVILEGED ACCESS as c
    on c~Material = a~Material
    and c~Supplier = a~FixedSupplier
    LEFT JOIN I_PurgInfoRecdOrgPlntDataApi01 WITH PRIVILEGED ACCESS AS d
    on d~PurchasingOrganization = a~Plant
    and d~Plant = a~plant
    AND D~PurchasingInfoRecord = C~PurchasingInfoRecord
    LEFT JOIN I_Product  WITH PRIVILEGED ACCESS AS E
    ON E~Product = A~Material
    LEFT JOIN I_PurchasingGroup WITH PRIVILEGED ACCESS as f
    on f~PurchasingGroup = a~PurchasingGroup

    INTO TABLE @DATA(lt_pr).

    SELECT supplier,
           Material,
           SupplierPhoneNumber,
           SupplierMaterialNumber
     FROM i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS
        WHERE isdeleted <> 'X'
        into TABLE @data(lt_phno) .

    if lt_phno is NOT INITIAL.
        sort lt_phno by supplier material.
    ENDIF.


    if lt_pr is not INITIAL.

        LOOP AT LT_PR INTO DATA(LW_PR).

            READ TABLE lt_phno into data(lw_phno) with key supplier = lw_pr-FixedSupplier Material = lw_pr-Material BINARY SEARCH.


                if sy-subrc = 0.
                    ls_response-SupplierPhoneNumber = lw_phno-SupplierPhoneNumber.
                    ls_response-suppliermaterialnumber = lw_phno-SupplierMaterialNumber.
                ENDIF.



            ls_response-PR_NUMBER           =   LW_PR-PurchaseRequisition           .
            ls_response-D_NO                =   LW_PR-PurchaseRequisitionItem       .
            ls_response-PUR_GROUP           =   LW_PR-PurchasingGroup               .
            ls_response-SUPPLIER            =   LW_PR-FixedSupplier                 .
            ls_response-MATERIAL            =   LW_PR-Material                      .
            ls_response-MATERIAL_TEXT       =   LW_PR-PurchaseRequisitionItemText   .
            ls_response-DELIVARY_DAYS       =   LW_PR-MaterialPlannedDeliveryDurn   .

            lv_dur = LW_PR-MaterialPlannedDeliveryDurn + LW_PR-MaterialGoodsReceiptDuration.

            ls_response-ARRANGE_START_DATE = zzcl_common_utils=>calc_date_subtract(
                    EXPORTING
                      date  = LW_PR-DeliveryDate
                      DAY = lv_dur
                  ).

            "ls_response-ARRANGE_START_DATE  =   LW_PR-DeliveryDate.
            ls_response-ARRANGE_END_DATE    =   LW_PR-DeliveryDate.
            ls_response-PLANT               =   LW_PR-Plant.
            ls_response-ARRANGE_QTY         =   LW_PR-RequestedQuantity.

            ls_response-NAME1               =   LW_PR-BusinessPartnerName1.



            ls_response-MIN_DELIVERY_QTY    =   LW_PR-MinimumPurchaseOrderQuantity.
            ls_response-MANUF_CODE          =   LW_PR-ProductManufacturerNumber.
            ls_response-PUR_GROUP_NAME      =   LW_PR-PurchasingGroupName.

            CONDENSE ls_response-PR_NUMBER                                                 .
            CONDENSE ls_response-D_NO                                                      .
            CONDENSE ls_response-PUR_GROUP                                                 .
            CONDENSE ls_response-SUPPLIER                                                  .
            CONDENSE ls_response-MATERIAL                                                  .
            CONDENSE ls_response-MATERIAL_TEXT                                             .
            CONDENSE ls_response-DELIVARY_DAYS                                             .
            CONDENSE ls_response-ARRANGE_START_DATE                                             .
            CONDENSE ls_response-ARRANGE_END_DATE                                               .
            CONDENSE ls_response-PLANT                                                          .
            CONDENSE ls_response-ARRANGE_QTY                                                    .
            CONDENSE ls_response-NAME1                                                          .
            CONDENSE ls_response-MIN_DELIVERY_QTY                                               .
            CONDENSE ls_response-MANUF_CODE                                                     .
            CONDENSE ls_response-PUR_GROUP_NAME .

            APPEND ls_response TO es_response-items.
            CLEAR ls_response.

        ENDLOOP.
    else.
        lv_error = 'X'.
        lv_text = 'there is no data'.

    ENDIF.

    IF lv_error IS NOT INITIAL.
      "propagate any errors raised
      response->set_status( '500' )."500
      response->set_text( lv_text ).
    ELSE.


      "respond with success payload
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
