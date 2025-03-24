CLASS zcl_podataanalysis DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_podataanalysis IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    TYPES:

      BEGIN OF ts_workflow,

        sapbusinessobjectnodekey1   TYPE  string,
        workflowinternalid          TYPE  string,
        workflowexternalstatus      TYPE  string,
        sapobjectnoderepresentation TYPE string,

      END OF ts_workflow,

      tt_workflow TYPE STANDARD TABLE OF ts_workflow WITH DEFAULT KEY,

      BEGIN OF ts_workflow_d,
        results TYPE tt_workflow,
      END OF ts_workflow_d,

      BEGIN OF ts_workflow_api,
        d TYPE ts_workflow_d,
      END OF ts_workflow_api,
*---------------------------------------------------------------------------
      BEGIN OF ts_workflowdetail,

        workflowinternalid     TYPE  string,
        workflowtaskinternalid TYPE  string,
        workflowtaskresult     TYPE  string,

      END OF ts_workflowdetail,

      tt_workflowdetail TYPE STANDARD TABLE OF ts_workflowdetail WITH DEFAULT KEY,

      BEGIN OF ts_workflowdetail_d,
        results TYPE tt_workflowdetail,
      END OF ts_workflowdetail_d,

      BEGIN OF ts_workflowdetail_api,
        d TYPE ts_workflowdetail_d,
      END OF ts_workflowdetail_api,




      BEGIN OF ty_tline,
        tdformat TYPE c LENGTH 2,
        tdline   TYPE c LENGTH 132,
      END OF ty_tline,

      BEGIN OF ty_d,
        material                   TYPE string,
        mrparea                    TYPE string,
        mrpplant                   TYPE string,
        mrpelement                 TYPE string,
        mrpelementitem             TYPE string,
        mrpelementreschedulingdate TYPE string,
        exceptionmessagenumber     TYPE string,
        mrpelementavailyorrqmtdate TYPE string,

      END OF ty_d,

      BEGIN OF ty_message,
        lang  TYPE string,
        value TYPE string,
      END OF ty_message,

      BEGIN OF ty_error,
        code    TYPE string,
        message TYPE ty_message,
      END OF ty_error,

      BEGIN OF ty_res_api,
        d     TYPE ty_d,
        error TYPE ty_error,
      END OF ty_res_api,

      tt_tline TYPE STANDARD TABLE OF ty_tline.

    TYPES:
      BEGIN OF ty_response_s,
        material TYPE string,
        mrparea  TYPE string,
      END OF ty_response_s,


      BEGIN OF ty_response_ss,
        d TYPE ty_response_s,
      END OF ty_response_ss.

    DATA:ls_response_ss TYPE ty_response_ss,
         lt_response_ss TYPE STANDARD TABLE OF ty_response_ss.

**********************************************************************
    TYPES:

      BEGIN OF ts_mrp_api,  "api structue

        material                   TYPE matnr,
        mrpplant                   TYPE werks_d,
        mrpelementopenquantity     TYPE c LENGTH 16,
        mrpavailablequantity       TYPE c LENGTH 16,
        mrpelement                 TYPE c LENGTH 12,
        mrpelementitem             TYPE c LENGTH 5,
        mrpelementavailyorrqmtdate TYPE datum,
        mrpelementcategory         TYPE c LENGTH 2,
        mrpelementdocumenttype     TYPE c LENGTH 4,
        productionversion          TYPE c LENGTH 4,
        sourcemrpelement           TYPE c LENGTH 12,
        mrpelementreschedulingdate TYPE datum,
        exceptionmessagenumber     TYPE string,
        mrpelementscheduleline     TYPE n LENGTH 4,
        exceptionmessagetext       TYPE string,


      END OF ts_mrp_api,

      tt_mrp_api TYPE STANDARD TABLE OF ts_mrp_api WITH DEFAULT KEY,

      BEGIN OF ts_mrp_d,
        __count TYPE string,
        results TYPE tt_mrp_api,
      END OF ts_mrp_d,

      BEGIN OF ts_message,
        lang  TYPE string,
        value TYPE string,
      END OF ts_message,

      BEGIN OF ts_error,
        code    TYPE string,
        message TYPE ts_message,
      END OF ts_error,

      BEGIN OF ts_res_mrp_api,
        d     TYPE ts_mrp_d,
        error TYPE ts_error,
      END OF ts_res_mrp_api,

      BEGIN OF ts_mrp_api_boi,  "api structue
        material                   TYPE matnr,
        mrpplant                   TYPE werks_d,
        mrpelementopenquantity(9)  TYPE p DECIMALS 3,
        mrpavailablequantity(9)    TYPE p DECIMALS 3,
        mrpelement                 TYPE c LENGTH 12,
        mrpelementavailyorrqmtdate TYPE string,
        mrpelementcategory         TYPE c LENGTH 2,
        mrpelementdocumenttype     TYPE c LENGTH 4,
        productionversion          TYPE c LENGTH 4,
        sourcemrpelement           TYPE c LENGTH 12,
        mrpelementitem             TYPE c LENGTH 6,
        mrpelementscheduleline     TYPE c LENGTH 4,
        exceptionmessagenumber     TYPE c LENGTH 2,
      END OF ts_mrp_api_boi,
      tt_mrp_api_boi TYPE STANDARD TABLE OF ts_mrp_api_boi WITH DEFAULT KEY,

*----------------------------------------------uweb调用参考 pickinglist。
      BEGIN OF ty_response_res,
        po_no       TYPE c LENGTH 10,
        d_no        TYPE c LENGTH 5,
        print_times TYPE i,

      END OF ty_response_res,

      BEGIN OF ty_response_d,
        results TYPE TABLE OF ty_response_res WITH DEFAULT KEY,
      END OF ty_response_d,

      BEGIN OF ty_response,
        d TYPE ty_response_d,
      END OF ty_response.

**********************************************************************
    DATA:
      lt_mrp_api     TYPE STANDARD TABLE OF ts_mrp_api,
      ls_mrp_api     TYPE ts_mrp_api,
      ls_res_mrp_api TYPE ts_res_mrp_api.

    DATA:
      "lt_result          type STANDARD TABLE OF zr_podataanalysis,
      lt_data            TYPE STANDARD TABLE OF zr_podataanalysis,
      lw_data            LIKE LINE OF lt_data,
      lt_output          TYPE STANDARD TABLE OF zr_podataanalysis,
      lr_purchaseorder   TYPE RANGE OF zr_podataanalysis-purchaseorder       ,       "購買発注番号
      lr_poitem          TYPE RANGE OF zr_podataanalysis-purchaseorderitem     ,       "Item
      lr_supplier        TYPE RANGE OF i_purchaseorderapi01-supplier            ,       "仕入先
      lr_purchasinggroup TYPE RANGE OF zr_podataanalysis-purchasinggroup     ,       "購買グループ
      lr_material        TYPE RANGE OF zr_podataanalysis-material            ,       "品目
      lr_plant           TYPE RANGE OF zr_podataanalysis-plant               ,       "プラント
      lr_mrpresponsible  TYPE RANGE OF zr_podataanalysis-mrpresponsible      ,       "MRPコントロール
      lr_createdbyuser   TYPE RANGE OF zr_podataanalysis-createdbyuser       ,       "登録者
      lr_category        TYPE RANGE OF zr_podataanalysis-accountassignmentcategory   ,       "勘定設定 Categ.
      lr_intartinum      TYPE RANGE OF zr_podataanalysis-internationalarticlenumber,         "海外PO番号/回収管理番号
      lr_extref          TYPE RANGE OF zr_podataanalysis-correspncexternalreference ,  "旧購買発注番号明細
      ls_purchaseorder   LIKE LINE OF  lr_purchaseorder,
      ls_poitem          LIKE LINE OF  lr_poitem,
      ls_supplier        LIKE LINE OF  lr_supplier,
      ls_purchasinggroup LIKE LINE OF  lr_purchasinggroup,
      ls_material        LIKE LINE OF  lr_material,
      ls_plant           LIKE LINE OF  lr_plant,
      ls_mrpresponsible  LIKE LINE OF  lr_mrpresponsible,
      ls_intartinum      LIKE LINE OF  lr_intartinum,
      ls_extref          LIKE LINE OF  lr_extref,
      ls_createdbyuser   LIKE LINE OF  lr_createdbyuser,
      ls_category        LIKE LINE OF  lr_category,
      ls_res_api         TYPE ty_res_api.

    DATA:
      lr_correspncinternalreference TYPE RANGE OF  i_purchaseorderapi01-correspncinternalreference,
      lr_suppliermaterialnumber     TYPE RANGE OF  i_purchaseorderitemapi01-suppliermaterialnumber,
      lr_purchaseorderdate          TYPE RANGE OF  i_purchaseorderapi01-purchaseorderdate,
      lr_schedulelinedeliverydate   TYPE RANGE OF  i_purordschedulelineapi01-schedulelinedeliverydate,
      lr_deliverydate               TYPE RANGE OF  i_posupplierconfirmationapi01-deliverydate,
      lr_storagelocation            TYPE RANGE OF  i_purchaseorderitemapi01-storagelocation,
      lr_incotermsclassification    TYPE RANGE OF  i_purchaseorderitemapi01-incotermsclassification,
      ls_correspncinternalreference LIKE LINE OF lr_correspncinternalreference,
      ls_suppliermaterialnumber     LIKE LINE OF lr_suppliermaterialnumber,
      ls_purchaseorderdate          LIKE LINE OF lr_purchaseorderdate,
      ls_schedulelinedeliverydate   LIKE LINE OF lr_schedulelinedeliverydate,
      ls_deliverydate               LIKE LINE OF lr_deliverydate,
      ls_storagelocation            LIKE LINE OF lr_storagelocation,
      ls_incotermsclassification    LIKE LINE OF lr_incotermsclassification,
      lr_purchasingorganization     TYPE RANGE OF i_purchaseorderapi01-purchasingorganization.

    DATA:
      lr_new_range TYPE RANGE OF zr_podataanalysis-purchasinggroup, " 新的 range 表
      ls_new_range LIKE LINE OF lr_new_range,                     " 新的 range 表的条目
      ls_old_range LIKE LINE OF lr_purchasinggroup.               " 原来的 range 表的条目

    DATA:
         lt_tlines       TYPE tt_tline.

    DATA:
      lv_dur     TYPE i,
      lv_days    TYPE i,
      lv_befdays TYPE d.

    DATA:
        lv_mrpdate       TYPE d.

    DATA:
      lo_root_exc TYPE REF TO cx_root,
      lv_path     TYPE string,
      i           TYPE i,
      lv_status   TYPE c LENGTH 1,
      lv_message  TYPE string,
      lv_valid    TYPE budat.

    CONSTANTS:
      lc_msgid     TYPE string VALUE 'ZMM_001',
      lc_msgty     TYPE string VALUE 'E',
      lc_alpha_in  TYPE string VALUE 'IN',
      lc_alpha_out TYPE string VALUE 'OUT'.

    DATA :
      lv_matnr           TYPE matnr,
      lv_sup             TYPE i_purchaseorderapi01-supplier,
      lv_sup_h           TYPE i_purchaseorderapi01-supplier,
      lv_purchaseorder   TYPE i_purchaseorderapi01-purchaseorder,
      lv_purchaseorder_h TYPE i_purchaseorderapi01-purchaseorder.

    DATA:
      lr_sup TYPE RANGE OF i_purchaseorderapi01-supplier,
      ls_sup LIKE LINE OF lr_sup.

    DATA:
      lt_workflow_api       TYPE STANDARD TABLE OF ts_workflow,
      lt_workflowdetail_api TYPE STANDARD TABLE OF ts_workflowdetail,
      ls_res_workflow       TYPE ts_workflow_api,
      ls_res_workflowdetail TYPE ts_workflowdetail_api.

    DATA:
      lt_mrp_api_boi TYPE STANDARD TABLE OF ts_mrp_api_boi,
      ls_mrp_api_boi TYPE ts_mrp_api_boi.

    DATA:
      lv_conf            TYPE n LENGTH 4.

    DATA:
      lv_pathoverview TYPE string,
      lv_pathdetails  TYPE string.

    DATA:
      lt_uweb_api TYPE STANDARD TABLE OF ty_response_res,
      ls_response TYPE ty_response.

    DATA:
      lv_filter TYPE string,
      lv_count  TYPE sy-index.

    IF io_request->is_data_requested( ).
      TRY.
          "Get and add filter
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
          ##NO_HANDLER
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
      ENDTRY.

*      DATA(lv_top)    = io_request->get_paging( )->get_page_size( ).
*      DATA(lv_skip)   = io_request->get_paging( )->get_offset( ).
*      DATA(lt_fields) = io_request->get_requested_elements( ).
*      DATA(lt_sort)   = io_request->get_sort_elements( ).

      DATA(lv_poalldis) = '1'. "1全部显示，2po=残 3 po不等于残

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
          CASE ls_filter_cond-name.
            WHEN 'PURCHASEORDER'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_purchaseorder.

              lv_purchaseorder = |{ str_rec_l_range-low ALPHA = IN }|.
              lv_purchaseorder_h = |{ str_rec_l_range-high ALPHA = IN }|.

              ls_purchaseorder-sign = str_rec_l_range-sign.
              ls_purchaseorder-option = str_rec_l_range-option.
              ls_purchaseorder-low = lv_purchaseorder.
              ls_purchaseorder-high = lv_purchaseorder_h.

              APPEND ls_purchaseorder TO lr_purchaseorder.
              CLEAR ls_purchaseorder.

            WHEN 'POPOITEM'.
              ls_purchaseorder-sign = str_rec_l_range-sign.
              ls_purchaseorder-option = str_rec_l_range-option.
              ls_purchaseorder-low = str_rec_l_range-low(10).   " 前10位作为PURCHASEORDER

              ls_poitem-sign = str_rec_l_range-sign.
              ls_poitem-option = str_rec_l_range-option.
              ls_poitem-low = str_rec_l_range-low+10(5).        " 后5位作为POITEM

              " 将对应的值加入到各自的range表
              APPEND ls_purchaseorder TO lr_purchaseorder.
              APPEND ls_poitem TO lr_poitem.

              " 清空临时变量
              CLEAR: ls_purchaseorder, ls_poitem.

            WHEN 'SUPPLIER'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_supplier.

              lv_sup = |{ str_rec_l_range-low ALPHA = IN }|.
              lv_sup_h = |{ str_rec_l_range-high ALPHA = IN }|.

              ls_sup-sign = str_rec_l_range-sign.
              ls_sup-option = str_rec_l_range-option.
              ls_sup-low = lv_sup.
              ls_sup-high = lv_sup_h.

              APPEND ls_sup TO lr_sup.
              CLEAR ls_supplier.

            WHEN 'PURCHASINGGROUP'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_purchasinggroup.
              APPEND ls_purchasinggroup TO lr_purchasinggroup.
              CLEAR ls_purchasinggroup.

            WHEN 'MATERIAL'.
              str_rec_l_range-low = zzcl_common_utils=>conversion_matn1( iv_alpha = lc_alpha_in  iv_input = str_rec_l_range-low ).
              str_rec_l_range-high = zzcl_common_utils=>conversion_matn1( iv_alpha = lc_alpha_in  iv_input = str_rec_l_range-high ).
              MOVE-CORRESPONDING str_rec_l_range TO ls_material.
              APPEND ls_material TO lr_material.
              CLEAR ls_material.

            WHEN 'PLANT'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_plant.
              APPEND ls_plant TO lr_plant.
              CLEAR ls_plant.

            WHEN 'MRPCONTROLLERNAME'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_mrpresponsible.
              APPEND ls_mrpresponsible TO lr_mrpresponsible.
              CLEAR ls_mrpresponsible.

            WHEN 'CREATEDBYUSER'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_createdbyuser.
              APPEND ls_createdbyuser TO lr_createdbyuser.
              CLEAR ls_createdbyuser.

            WHEN 'CORRESPNCINTERNALREFERENCE'.  "PO連携担当者
              MOVE-CORRESPONDING str_rec_l_range TO ls_correspncinternalreference.
              APPEND ls_correspncinternalreference TO lr_correspncinternalreference.
              CLEAR ls_correspncinternalreference.

            WHEN 'SUPPLIERMATERIALNUMBER'."仕入先品目コード
              MOVE-CORRESPONDING str_rec_l_range TO ls_suppliermaterialnumber.
              APPEND ls_suppliermaterialnumber TO lr_suppliermaterialnumber.
              CLEAR ls_suppliermaterialnumber.

            WHEN 'PURCHASEORDERDATE'."伝票日付
              MOVE-CORRESPONDING str_rec_l_range TO ls_purchaseorderdate.
              APPEND ls_purchaseorderdate TO lr_purchaseorderdate.
              CLEAR ls_purchaseorderdate.

            WHEN 'SCHEDULELINEDELIVERYDATE'."納入日付
              MOVE-CORRESPONDING str_rec_l_range TO ls_schedulelinedeliverydate.
              APPEND ls_schedulelinedeliverydate TO lr_schedulelinedeliverydate.
              CLEAR ls_schedulelinedeliverydate.

              "add by wz 20241227
            WHEN 'ACCOUNTASSIGNMENTCATEGORY'."勘定設定 Categ.
              MOVE-CORRESPONDING str_rec_l_range TO ls_category.
              APPEND ls_category TO lr_category.
              CLEAR ls_category.

            WHEN 'INTERNATIONALARTICLENUMBER'."海外PO番号/回収管理番号
              MOVE-CORRESPONDING str_rec_l_range TO ls_intartinum.
              APPEND ls_intartinum TO lr_intartinum.
              CLEAR ls_intartinum.

            WHEN 'CORRESPNCEXTERNALREFERENCE'."旧購買発注番号明細
              MOVE-CORRESPONDING str_rec_l_range TO ls_extref.
              APPEND ls_extref TO lr_extref.
              CLEAR ls_extref.

              "end add by wz 20241227

            WHEN 'DELIVERYDATE'."回答納期
              MOVE-CORRESPONDING str_rec_l_range TO ls_deliverydate.
              APPEND ls_deliverydate TO lr_deliverydate.
              CLEAR ls_deliverydate.

            WHEN 'STORAGELOCATION'."保管場所
              MOVE-CORRESPONDING str_rec_l_range TO ls_storagelocation.
              APPEND ls_storagelocation TO lr_storagelocation.
              CLEAR ls_storagelocation.

            WHEN 'INCOTERMSCLASSIFICATION'."基軸通貨
              MOVE-CORRESPONDING str_rec_l_range TO ls_incotermsclassification.
              APPEND ls_incotermsclassification TO lr_incotermsclassification.
              CLEAR ls_incotermsclassification.

            WHEN 'WORKFLOWTASKRESULT'."承認区分
              DATA(lr_workflowtaskresult) = ls_filter_cond-range.

            WHEN 'PONOKODIS'.
              IF str_rec_l_range-low = '2'.
                lv_poalldis = '2'.
              ELSEIF str_rec_l_range-low = '3'.
                lv_poalldis = '3'.
              ENDIF.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      ENDLOOP.

**********************************************************************
* MOD BEGIN BY XINLEI XU
**********************************************************************
*      SELECT
*             b~purchaseorder                      ,
*             b~purchaseorderitem                  ,
*             concat( b~purchaseorder, CAST( b~purchaseorderitem AS CHAR ) ) AS popoitem,
*
*             l~deliverydate                       , "回答納期
*             l~sequentialnmbrofsuplrconf          ,
*             l~supplierconfirmationextnumber      ,
*             l~confirmedquantity                  ,
*
*             a~purchaseordertype                  ,
*             a~supplier                           ,
*             a~purchasinggroup                    ,
*             a~purchaseorderdate                  ,             "伝票日付
*             a~documentcurrency                   ,
*             a~purchasingorganization             ,
*             a~createdbyuser                      ,
*             a~correspncinternalreference         ,  "1117 追加PO連携担当者
*
*
*
*             b~material                           ,
*             b~purchaseorderitemtext              ,
*             b~manufacturermaterial               ,
*             b~manufacturerpartnmbr               ,
*             b~manufacturer                       ,
*             b~planneddeliverydurationindays      ,
*             b~goodsreceiptdurationindays         ,
*             b~orderquantity                      ,
*             b~purchaseorderquantityunit          ,
*             b~purchaserequisition                ,
*             b~purchaserequisitionitem            ,
*             b~requirementtracking                ,
*             b~requisitionername                  ,
*             b~internationalarticlenumber         ,
*             b~materialgroup                      ,
*             b~netamount                          ,
*             b~plant                              ,
*             b~storagelocation                    ,"保管場所
*             b~iscompletelydelivered              ,
*             b~taxcode                            ,
*             b~pricingdatecontrol                 ,
*             b~incotermsclassification            ,"基軸通貨
*
*             b~netpricequantity                   ,
*             b~netpriceamount                     ,
*             b~purchaseorderitemcategory          ,
*             b~suppliermaterialnumber             ,                               "1117 追加仕入先品目コード
*
*             c~suppliername   AS     suppliername1,                               "仕入先名称
*             "c~suppliername   AS     suppliername2,
*
*             d~mrparea                            ,                               "2.3　MRPエリア
*
*             e~mrpresponsible                     ,                               "2.4　MRPコントロール
*
*             f~mrpcontrollername                  ,                               "2.5　コントロール名称
*
*             g~suppliercertorigincountry          ,                               "2.7　原産国
*
*             g~purchasinginforecord               ,
*             g~suppliersubrange                   ,                               "供給者部門
*
*             h~storagelocationname                ,                               "2.8　保管場所テキスト
*
*             i~productionmemopageformat           ,                               "基板取り数
*             i~productionorinspectionmemotxt      ,                               "2.9　基板取数(製造/検査メモ)
*
*             j~supplierrespsalespersonname        ,                               "2.10　下請対象 販売担当者
*
*             k~lotsizeroundingquantity            ,                               "2.11　丸め数量
*
*             m~schedulelinedeliverydate           ,                               "納入日付
*             m~roughgoodsreceiptqty
*
*
*        FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS AS b
*        LEFT OUTER JOIN i_posupplierconfirmationapi01 WITH PRIVILEGED ACCESS AS l
*          ON l~purchaseorder = b~purchaseorder
*         AND l~purchaseorderitem = b~purchaseorderitem
*        LEFT JOIN i_purchaseorderapi01  WITH PRIVILEGED ACCESS AS a
*          ON b~purchaseorder = a~purchaseorder
*        LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS c
*          ON a~supplier = c~supplier
*        LEFT JOIN i_productmrparea WITH PRIVILEGED ACCESS AS d
*          ON d~product = b~material
*         AND d~mrpplant = b~plant
*        LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS e
*          ON e~product = b~material
*         AND e~plant = b~plant
*        LEFT JOIN i_mrpcontroller WITH PRIVILEGED ACCESS AS f
*          ON f~mrpcontroller = e~mrpresponsible
*         AND f~plant = b~plant
*        LEFT JOIN i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS g
*          ON g~purchasinginforecord = b~purchasinginforecord
*        LEFT JOIN i_storagelocation WITH PRIVILEGED ACCESS AS h
*          ON h~plant = b~plant
*         AND h~storagelocation = b~storagelocation
*        LEFT JOIN i_product WITH PRIVILEGED ACCESS AS i
*          ON i~product = b~material
*        LEFT JOIN i_supplierpurchasingorg WITH PRIVILEGED ACCESS AS j
*          ON j~supplier = a~supplier
*         AND j~purchasingorganization = a~purchasingorganization
*        LEFT JOIN  i_productsupplyplanning WITH PRIVILEGED ACCESS AS k
*          ON k~product = b~material
*         AND k~plant = b~plant
*        LEFT JOIN i_purordschedulelineapi01 WITH PRIVILEGED ACCESS AS m
*          ON m~purchaseorder = b~purchaseorder
*         AND m~purchaseorderitem = b~purchaseorderitem
**       LEFT JOIN I_SupplierSubrange WITH PRIVILEGED ACCESS AS N
**         ON N~SupplierSubrange = B~SupplierSubrange
**        AND N~Supplier = A~Supplier
*       WHERE b~purchaseorder IN @lr_purchaseorder
*         AND b~purchaseorderitem IN @lr_poitem
*         AND c~supplier IN @lr_sup
*         AND a~purchasinggroup IN @lr_purchasinggroup
*         AND b~material IN @lr_material
*         AND b~suppliermaterialnumber IN @lr_suppliermaterialnumber
*         AND b~plant IN @lr_plant
*         AND b~storagelocation IN @lr_storagelocation
*         AND b~incotermsclassification IN @lr_incotermsclassification
*         AND a~createdbyuser IN @lr_createdbyuser
*         AND a~correspncinternalreference IN @lr_correspncinternalreference
*         AND a~purchaseorderdate IN @lr_purchaseorderdate
*         AND m~schedulelinedeliverydate IN @lr_schedulelinedeliverydate
*         AND l~deliverydate IN @lr_deliverydate
**        AND N~Language =
*        INTO TABLE @DATA(lt_result) .
      SELECT *
        FROM zc_podataanalysis WITH PRIVILEGED ACCESS
       WHERE purchaseorder IN @lr_purchaseorder
         AND purchaseorderitem IN @lr_poitem
         AND supplier IN @lr_sup
         AND purchasinggroup IN @lr_purchasinggroup
         AND material IN @lr_material
         AND suppliermaterialnumber IN @lr_suppliermaterialnumber
         AND plant IN @lr_plant
         AND storagelocation IN @lr_storagelocation
       " AND incotermsclassification IN @lr_incotermsclassification DEL BY XINLEI XU 2025/03/18
         AND createdbyuser IN @lr_createdbyuser
         AND correspncinternalreference IN @lr_correspncinternalreference
         AND purchaseorderdate IN @lr_purchaseorderdate
         AND schedulelinedeliverydate IN @lr_schedulelinedeliverydate
         AND deliverydate IN @lr_deliverydate
         AND mrpresponsible IN @lr_mrpresponsible
         AND accountassignmentcategory IN @lr_category
         AND internationalarticlenumber IN @lr_intartinum
         AND correspncexternalreference IN @lr_extref
        INTO TABLE @DATA(lt_result).
**********************************************************************
* MOD END BY XINLEI XU
**********************************************************************

* Authorization Check
      DATA(lv_user_prefix) = sy-uname+0(2).
      IF lv_user_prefix = 'CB'.
        DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
        DATA(lv_plant) = zzcl_common_utils=>get_plant_by_user( lv_user_email ).
        DATA(lv_ekorg) = zzcl_common_utils=>get_purchorg_by_user( lv_user_email ).

        IF lv_plant IS INITIAL.
          CLEAR lt_result.
        ELSE.
          SPLIT lv_plant AT '&' INTO TABLE DATA(lt_plant_check).
          CLEAR lr_plant.
          lr_plant = VALUE #( FOR plant IN lt_plant_check ( sign = 'I' option = 'EQ' low = plant ) ).
          DELETE lt_result WHERE plant NOT IN lr_plant.
        ENDIF.

        IF lv_ekorg IS INITIAL.
          CLEAR lt_result.
        ELSE.
          SPLIT lv_ekorg AT '&' INTO TABLE DATA(lt_purchorg_check).
          CLEAR lr_purchasingorganization.
          lr_purchasingorganization = VALUE #( FOR purchorg IN lt_purchorg_check ( sign = 'I' option = 'EQ' low = purchorg ) ).
          DELETE lt_result WHERE purchasingorganization NOT IN lr_purchasingorganization.
        ENDIF.
      ENDIF.
*---------------------------------------------------------------------------

      IF lt_result IS NOT INITIAL.
        " 购买组取值
        IF lr_purchasinggroup IS NOT INITIAL.
          LOOP AT lr_purchasinggroup INTO ls_old_range.
            " 从第二位开始截取后两位数
            ls_new_range-sign = ls_old_range-sign.
            ls_new_range-option = ls_old_range-option.
            ls_new_range-low = ls_old_range-low+1(2). " 从第2位截取两位
            ls_new_range-high = ls_old_range-high+1(2). " 适用于有 high 的情况
            " 将新的条目添加到新的 range 表
            APPEND ls_new_range TO lr_new_range.
            CLEAR: ls_new_range.
          ENDLOOP.
        ENDIF.

        SELECT customer,
               addresssearchterm2
          FROM i_customer WITH PRIVILEGED ACCESS
         WHERE addresssearchterm1 IN @lr_new_range
          INTO TABLE @DATA(lt_customer).
        SORT lt_customer BY addresssearchterm2.

        " 購買情報の組織プラントデータ
        SELECT a~purchasinginforecord,
               a~purchasingorganization,
               a~purchasinginforecordcategory,
               a~plant,
               a~shippinginstruction,
               a~incotermsclassification, " ADD BY XINLEI XU 2025/03/18
               b~shippinginstructionname
          FROM i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS AS a
          LEFT JOIN i_shippinginstructiontext WITH PRIVILEGED ACCESS AS b
                 ON b~shippinginstruction = a~shippinginstruction
                AND b~language = @sy-langu
           FOR ALL ENTRIES IN @lt_result
         WHERE a~purchasinginforecord = @lt_result-purchasinginforecord
           AND a~purchasingorganization = @lt_result-purchasingorganization
           AND a~plant = @lt_result-plant
           AND a~purchasinginforecordcategory = @lt_result-purchaseorderitemcategory " ADD BY XINLEI XU 2025/03/18
           AND a~ismarkedfordeletion IS INITIAL
          INTO TABLE @DATA(lt_purginfo).
        SORT lt_purginfo BY purchasinginforecord purchasingorganization plant purchasinginforecordcategory.

        SELECT purchaseorder,
               textobjecttype,
               plainlongtext
          FROM i_purchaseordernotetp_2 WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_result
         WHERE purchaseorder = @lt_result-purchaseorder
           AND textobjecttype = 'F01'
           AND language = @sy-langu
          INTO TABLE @DATA(lt_longtext).
        SORT lt_longtext BY purchaseorder.

        SELECT purchaseorder,
               purchaseorderitem,
               textobjecttype,
               plainlongtext
          FROM i_purchaseorderitemnotetp_2 WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_result
         WHERE purchaseorder = @lt_result-purchaseorder
           AND purchaseorderitem = @lt_result-purchaseorderitem
           AND textobjecttype = 'F01'
           AND language = @sy-langu
          INTO TABLE @DATA(lt_longtext_1).
        SORT lt_longtext_1 BY purchaseorder purchaseorderitem.

        SELECT *
          FROM ztmm_1009
          INTO TABLE @DATA(lt_1009).                    "#EC CI_NOWHERE
        SORT lt_1009 BY pono dno deliverydate quantity.

        DATA(lt_plant) = lt_result.
        SORT lt_plant BY plant.
        DELETE ADJACENT DUPLICATES FROM lt_plant COMPARING plant.

        DATA(lt_material) = lt_result.
        SORT lt_material BY material.
        DELETE ADJACENT DUPLICATES FROM lt_material COMPARING material.
      ENDIF.


      SELECT  plant,
              factorycalendarid,
              factorycalendarvalidityenddate
      FROM i_factorycalendarbasic WITH PRIVILEGED ACCESS AS a
      JOIN i_plant AS b ON b~factorycalendar = a~factorycalendarlegacyid
      INTO TABLE @DATA(lt_factorycalendar).
      SORT lt_factorycalendar BY plant.


*&--MOD BEGIN BY XINLEI XU 2025/03/04 BUG Fix
*      CLEAR lv_count.
*      LOOP AT lt_plant INTO DATA(ls_plant_v).
*        lv_count += 1.
*        IF lv_count = 1.
*          lv_filter = |(MRPPlant eq '{ ls_plant_v-plant }' and MRPArea eq '{ ls_plant_v-plant }')|.
*        ELSE.
*          lv_filter = |{ lv_filter } or (MRPPlant eq '{ ls_plant_v-plant }' and MRPArea eq '{ ls_plant_v-plant }')|.
*        ENDIF.
*      ENDLOOP.
*
*      IF lines( lt_material ) < 30.
*        CLEAR lv_count.
*        LOOP AT lt_material INTO DATA(ls_material_v).
*          lv_count += 1.
*          IF lv_count = 1.
*            lv_filter = |{ lv_filter } and (Material eq '{ ls_material_v-material }'|.
*          ELSE.
*            lv_filter = |{ lv_filter } or Material eq '{ ls_material_v-material }'|.
*          ENDIF.
*        ENDLOOP.
*        lv_filter = |{ lv_filter })|.
*      ENDIF.

      DATA(lv_select) = |Material,MRPArea,MRPPlant,MRPElementOpenQuantity,MRPElementAvailyOrRqmtDate,| &&
                        |MRPElement,MRPElementItem,SourceMRPElement,MRPElementCategory,MRPElementDocumentType,| &&
                        |ProductionVersion,MRPElementScheduleLine,MRPElementReschedulingDate,ExceptionMessageNumber,ExceptionMessageText|.
      lv_path = |/API_MRP_MATERIALS_SRV_01/SupplyDemandItems?sap-language={ zzcl_common_utils=>get_current_language( ) }|.

      CLEAR lv_filter.

      IF lines( lt_material ) < 30.
        CLEAR lv_count.
        LOOP AT lt_material INTO DATA(ls_material_v).
          lv_count += 1.
          IF lv_count = 1.
            lv_filter = |(Material eq '{ ls_material_v-material }'|.
          ELSE.
            lv_filter = |{ lv_filter } or Material eq '{ ls_material_v-material }'|.
          ENDIF.
        ENDLOOP.
        lv_filter = |{ lv_filter })|.
      ENDIF.

      LOOP AT lt_plant INTO DATA(ls_plant_v).
        IF lv_filter IS NOT INITIAL.
          DATA(lv_new_filter) = |{ lv_filter } and (MRPPlant eq '{ ls_plant_v-plant }' and MRPArea eq '{ ls_plant_v-plant }')|.
        ELSE.
          lv_new_filter = |(MRPPlant eq '{ ls_plant_v-plant }' and MRPArea eq '{ ls_plant_v-plant }')|.
        ENDIF.

        " MRP数据取得
        zzcl_common_utils=>request_api_v2(
              EXPORTING
                iv_path        = lv_path
                iv_method      = if_web_http_client=>get
                iv_filter      = lv_new_filter
                iv_select      = lv_select
              IMPORTING
                ev_status_code = DATA(lv_stat_code)
                ev_response    = DATA(lv_resbody_api) ).

        IF lv_stat_code = '200'.
          CLEAR ls_res_mrp_api.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api
                                     CHANGING  data = ls_res_mrp_api ).

          APPEND LINES OF ls_res_mrp_api-d-results TO lt_mrp_api.
        ENDIF.
        CLEAR lv_new_filter.
      ENDLOOP.
      SORT lt_mrp_api BY mrpelement mrpelementitem mrpelementscheduleline mrpelementcategory.
*&--MOD END BY XINLEI XU 2025/03/04

*&--MOD BEGIN BY XINLEI XU 2025/02/21
      TRY.
          DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
          " Get UWEB Access configuration
          SELECT *
            FROM zc_tbc1001
           WHERE zid = 'ZBC005'
             AND zvalue1 = @lv_system_url     "ADD BY XINLEI XU 2025/02/21
            INTO TABLE @DATA(lt_config).      "#EC CI_ALL_FIELDS_NEEDED
          ##NO_HANDLER
        CATCH cx_abap_context_info_error.
          "handle exception
      ENDTRY.

      SORT lt_config BY zvalue2.
      DELETE ADJACENT DUPLICATES FROM lt_config COMPARING zvalue2.

      LOOP AT lt_config INTO DATA(ls_config).
        CONDENSE ls_config-zvalue2 NO-GAPS. " ODATA_URL
        CONDENSE ls_config-zvalue3 NO-GAPS. " TOKEN_URL
        CONDENSE ls_config-zvalue4 NO-GAPS. " CLIENT_ID
        CONDENSE ls_config-zvalue5 NO-GAPS. " CLIENT_SECRET

        DATA(lv_top)  = 1000.
        DATA(lv_skip) = -1000.
        DO.
          lv_skip += 1000.
          zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |{ ls_config-zvalue2 }/odata/v2/TableService/T02_PO_D?$top={ lv_top }&$skip={ lv_skip }|
                                                                  iv_token_url     = CONV #( ls_config-zvalue3 )
                                                                  iv_client_id     = CONV #( ls_config-zvalue4 )
                                                                  iv_client_secret = CONV #( ls_config-zvalue5 )
                                                                  iv_authtype      = 'OAuth2.0'
                                                        IMPORTING ev_status_code   = DATA(lv_status_code_uweb)
                                                                  ev_response      = DATA(lv_response_uweb) ).

          IF lv_status_code_uweb = 200.
            CLEAR ls_response.
*            xco_cp_json=>data->from_string( lv_response_uweb )->apply( VALUE #(
*              ( xco_cp_json=>transformation->boolean_to_abap_bool )
*            ) )->write_to( REF #( ls_response ) ).
            /ui2/cl_json=>deserialize( EXPORTING json = lv_response_uweb
                                       CHANGING  data = ls_response ).

            IF ls_response-d-results IS NOT INITIAL.
              APPEND LINES OF ls_response-d-results TO lt_uweb_api.
            ELSE.
              EXIT.
            ENDIF.

            CLEAR: lv_status_code_uweb, lv_response_uweb.
          ELSE.
            EXIT.
          ENDIF.
        ENDDO.
      ENDLOOP.
      SORT lt_uweb_api BY po_no d_no.
*&--MOD END BY XINLEI XU 2025/02/21

*      " UWEB接口，打印次数
*      zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |http://220.248.121.53:11380/srv/odata/v2/TableService/T02_PO_D|
*                                                              iv_client_id     = CONV #( ls_bc005-zvalue4 )
*                                                              iv_client_secret = CONV #( ls_bc005-zvalue5 )
*                                                              iv_authtype      = 'Basic'
*                                                    IMPORTING ev_status_code   = DATA(lv_status_code_uweb)
*                                                              ev_response      = DATA(lv_response_uweb) ).


      " 审批状态取得取得
      lv_pathoverview = |/YY1_WORKFLOWSTATUSOVERVIEW_CDS/YY1_WorkflowStatusOverview|.
      zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_pathoverview
          iv_method      = if_web_http_client=>get
          iv_format      = 'json'
        IMPORTING
          ev_status_code = DATA(lv_stat_codeo)
          ev_response    = DATA(lv_resbody_apio) ).
      IF lv_stat_codeo = '200'.
        /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_apio
                                   CHANGING data = ls_res_workflow ).

        APPEND LINES OF ls_res_workflow-d-results TO lt_workflow_api.
        SORT lt_workflow_api BY sapbusinessobjectnodekey1 sapobjectnoderepresentation.
      ENDIF.

      " 审批详情取得
      lv_pathdetails = |/YY1_WORKFLOWSTATUSDETAILS_CDS/YY1_WorkflowStatusDetails|.
      zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_pathdetails
          iv_method      = if_web_http_client=>get
          iv_format      = 'json'
        IMPORTING
          ev_status_code = DATA(lv_stat_coded)
          ev_response    = DATA(lv_resbody_apid) ).
      IF lv_stat_coded = '200'.
        /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_apid
                                   CHANGING data = ls_res_workflowdetail ).

        APPEND LINES OF ls_res_workflowdetail-d-results TO lt_workflowdetail_api.
        SORT lt_workflowdetail_api BY workflowinternalid workflowtaskinternalid DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_workflowdetail_api COMPARING workflowinternalid.
      ENDIF.

      DATA:
        lv_netprice3 TYPE p LENGTH 13 DECIMALS 3,         " 日元三位小数
        lv_netprice5 TYPE p LENGTH 13 DECIMALS 5.         " 五位小数

      LOOP AT lt_result INTO DATA(lw_result).
        CLEAR lw_data.

        MOVE-CORRESPONDING lw_result TO lw_data.

        "2.2　得意先名称通过 ea0 后两位检索 customer
        READ TABLE lt_customer INTO DATA(lw_customer) WITH KEY addresssearchterm2 = lw_result-purchasinggroup+1(2) BINARY SEARCH.
        IF sy-subrc = 0.
          lw_data-customer = lw_customer-customer.
        ENDIF.

        " NCNR、CANCELルール
        READ TABLE lt_purginfo INTO DATA(lw_purginfo) WITH KEY purchasinginforecord         = lw_result-purchasinginforecord
                                                               purchasingorganization       = lw_result-purchasingorganization
                                                               plant                        = lw_result-plant
                                                               purchasinginforecordcategory = lw_result-purchaseorderitemcategory
                                                               BINARY SEARCH.
        IF sy-subrc = 0.
          lw_data-shippinginstructionname = lw_purginfo-shippinginstructionname.
          lw_data-incotermsclassification = lw_purginfo-incotermsclassification. " ADD BY XINLEI XU 2025/03/18
        ENDIF.

*&--ADD BEGIN BY XINLEI XU 2025/03/18
        IF lw_data-incotermsclassification NOT IN lr_incotermsclassification.
          CONTINUE.
        ENDIF.
*&--ADD END BY XINLEI XU 2025/03/18

        "2.19 例外
        "2.20 注意
        IF lw_result-sequentialnmbrofsuplrconf IS NOT INITIAL .
          READ TABLE lt_mrp_api INTO DATA(lw_mrp) WITH KEY mrpelement = |{ lw_result-purchaseorder ALPHA = OUT }|
                                                           mrpelementitem = |{ lw_result-purchaseorderitem ALPHA = OUT }|
                                                           mrpelementscheduleline = lw_result-sequentialnmbrofsuplrconf
                                                           BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(lv_getnop) = 'X'.
          ELSE.
            lv_getnop = ''.
          ENDIF.
        ELSE.
          READ TABLE lt_mrp_api INTO lw_mrp WITH KEY mrpelement = |{ lw_result-purchaseorder ALPHA = OUT }|
                                                     mrpelementitem = |{ lw_result-purchaseorderitem ALPHA = OUT }|
                                                     mrpelementcategory = 'BE' BINARY SEARCH.
          IF sy-subrc = 0.
            lv_getnop = 'X'.
          ELSE.
            lv_getnop = ''.
          ENDIF.
        ENDIF.

        IF lv_getnop = 'X'.
          CASE lw_mrp-exceptionmessagenumber.
            WHEN '10'.
              lw_data-exception1 = 'U1'.
              lw_data-attention  = 'PULL IN'.
            WHEN '15'.
              lw_data-exception1 = 'U2'.
              lw_data-attention  = 'PUSH OUT'.
            WHEN '20'.
              lw_data-exception1 = 'U3'.
              lw_data-attention  = 'CANCEL'.
            WHEN '07'.
              lw_data-exception1 = 'T4'.
              lw_data-attention  = 'RESCHEDULE'.
            WHEN OTHERS.
              lw_data-exception1 = ''.
              lw_data-attention  = ''.
          ENDCASE.

          "2.22 生産計画日付
          IF lw_mrp-mrpelementreschedulingdate IS NOT INITIAL.
            lw_data-mrpelementreschedulingdate = lw_mrp-mrpelementreschedulingdate.
          ENDIF.


          CLEAR lv_dur.
          "2.12　生産可能日付 PossibleProductionDate
          "回答納期  GoodsReceiptDurationInDays（入庫処理時間）稼働日
          IF lw_result-deliverydate IS NOT INITIAL .
*          AND lw_result-goodsreceiptdurationindays IS NOT INITIAL.

            IF lw_result-goodsreceiptdurationindays = 0.

              lw_data-possibleproductiondate = lw_result-deliverydate.

            ELSE.

              lv_dur = lw_result-goodsreceiptdurationindays.  "入庫処理時間（稼働日）


              READ TABLE lt_factorycalendar INTO DATA(lw_factory) WITH KEY plant = lw_data-plant BINARY SEARCH .

              IF sy-subrc = 0 .

                TRY.
                    DATA(lo_fcal_run) = cl_fhc_calendar_runtime=>create_factorycalendar_runtime( iv_factorycalendar_id = lw_factory-factorycalendarid ).
                    lw_data-possibleproductiondate = lo_fcal_run->add_workingdays_to_date(  iv_start = lw_result-deliverydate iv_number_of_workingdays = lv_dur  ).

                    ##NO_HANDLER
                  CATCH cx_fhc_runtime.
                    "handle exception
                ENDTRY.

              ENDIF.
              CLEAR lv_days.

*              lw_data-possibleproductiondate = zzcl_common_utils=>calc_date_add(
*                  EXPORTING
*                    date  = lw_result-deliverydate  "回答納期
*                    day   = lv_dur                  "入庫処理時間（稼働日）
*              ).
*
*              lw_data-possibleproductiondate = zzcl_common_utils=>get_workingday( iv_date = lw_data-possibleproductiondate
*                                               iv_next = abap_false
*                                               iv_plant = lw_data-plant ).

            ENDIF.

          ENDIF.

          CLEAR lv_dur.

          "日期型 不能判断initial 还有数字型
*          IF lw_result-goodsreceiptdurationindays IS NOT INITIAL AND lw_mrp-mrpelementreschedulingdate IS NOT INITIAL.

          IF lw_result-goodsreceiptdurationindays = 0.
            lw_data-mrpdiliverydate = lw_mrp-mrpelementreschedulingdate.

          ELSE.

            lv_dur = lw_result-goodsreceiptdurationindays.  "入庫処理時間（稼働日）

            CLEAR lw_factory.
            READ TABLE lt_factorycalendar INTO lw_factory WITH KEY plant = lw_data-plant BINARY SEARCH .

            IF sy-subrc = 0 .

              TRY.
                  CLEAR lo_fcal_run.
                  lo_fcal_run = cl_fhc_calendar_runtime=>create_factorycalendar_runtime( iv_factorycalendar_id = lw_factory-factorycalendarid ).
                  lw_data-mrpdiliverydate = lo_fcal_run->subtract_workingdays_from_date(  iv_start = lw_mrp-mrpelementreschedulingdate iv_number_of_workingdays = lv_dur  ).

                  ##NO_HANDLER
                CATCH cx_fhc_runtime.
                  "handle exception
              ENDTRY.

            ENDIF.
            CLEAR lv_days.
          ENDIF.
*          ENDIF.
          "          comment by wz 20241227 顾问日期变更
*          IF lw_mrp-mrpelementavailyorrqmtdate IS NOT INITIAL.
*            lw_data-possibleproductiondate = lw_mrp-mrpelementavailyorrqmtdate.
*
*            IF lw_mrp-exceptionmessagetext IS NOT INITIAL.
*              DATA(lv_length) = strlen( lw_mrp-exceptionmessagetext ).
*              IF lv_length = 33.
*                DATA(lv_yy) = lw_mrp-exceptionmessagetext+30(2).
*                DATA(lv_dd) = lw_mrp-exceptionmessagetext+27(2).
*                DATA(lv_mm) = lw_mrp-exceptionmessagetext+24(2).
*                DATA(lv_date) = |20{ lv_yy }{ lv_mm }{ lv_dd } |.
*                lw_data-mrpdiliverydate = lv_date.
*              ENDIF.
*              CLEAR:lv_yy,lv_dd,lv_mm,lv_date,lv_length.
*            ENDIF.
*          ENDIF.
          "comment by wz 20241227 顾问日期变更

*        "2.12　生産可能日付   生産可能日付=回答納期＋入庫処理時間（稼働日） 然后需要使用工厂日期
*        CLEAR lv_dur.
*        lv_dur = lw_result-goodsreceiptdurationindays.  "入庫処理時間（稼働日）
*
*        IF lv_dur <> 0 AND lw_result-deliverydate IS NOT INITIAL.
*          lw_data-possibleproductiondate = zzcl_common_utils=>calc_date_add(
*            EXPORTING
*              date  = lw_result-deliverydate  "回答納期
*              day   = lv_dur                  "入庫処理時間（稼働日）
*            ).
*
*          lw_data-possibleproductiondate = zzcl_common_utils=>get_workingday( iv_date = lw_data-possibleproductiondate
*                                                        iv_next = abap_false
*                                                        iv_plant = lw_data-plant ).
*        ELSE.
*          "采用
*          lw_data-possibleproductiondate = zzcl_common_utils=>get_workingday( iv_date = lw_result-deliverydate
*                                                        iv_next = abap_false
*                                                        iv_plant = lw_data-plant ).
*        ENDIF.

*          IF lw_mrp-mrpelementavailyorrqmtdate IS NOT INITIAL AND lw_data-mrpelementreschedulingdate IS NOT INITIAL .
**            lv_dur = lw_mrp-mrpelementavailyorrqmtdate.   "入庫処理時間
*            "購買納入日付
**            lw_data-mrpdiliverydate = zzcl_common_utils=>calc_date_subtract(
**              EXPORTING
**                date      = lw_data-mrpelementreschedulingdate
**                day       = lv_dur
**            ).
**            lw_data-mrpdiliverydate = zzcl_common_utils=>get_workingday( iv_date = lw_data-mrpdiliverydate
**                                                                    iv_next = abap_false
**                                                                    iv_plant = lw_data-plant ).
*          ELSE.
*            IF lw_mrp-mrpelementreschedulingdate IS NOT INITIAL.
*              lw_data-mrpdiliverydate = lw_mrp-mrpelementreschedulingdate.
*            ENDIF.
*          ENDIF.
        ENDIF.

        " 2.21 MC要求
        IF lw_data-schedulelinedeliverydate   IS NOT INITIAL AND
           lw_data-mrpelementreschedulingdate IS NOT INITIAL.
          IF lw_data-attention <> ''.
            IF lw_data-attention = 'CANCEL'.
              lw_data-mcrequire = 'CANCEL'.
            ELSE.
              IF lw_data-schedulelinedeliverydate < lw_data-mrpelementreschedulingdate.
                lw_data-mcrequire = 'PUSH OUT'.
              ELSEIF lw_data-schedulelinedeliverydate > lw_data-mrpelementreschedulingdate.
                lw_data-mcrequire = 'PULL IN'.
              ELSE.
                lw_data-mcrequire = ''.
              ENDIF.
            ENDIF.
          ELSE.
            IF lw_data-schedulelinedeliverydate < lw_data-deliverydate.
              lw_data-mcrequire = 'PUSH OUT'.
            ELSEIF lw_data-schedulelinedeliverydate = lw_data-deliverydate.
              lw_data-mcrequire = ''.
            ENDIF.

            IF lw_data-deliverydate <> ''.
              IF lw_data-schedulelinedeliverydate > lw_data-deliverydate.
                lw_data-mcrequire = 'PULL IN'.
              ELSE.
                IF lw_data-schedulelinedeliverydate > lw_data-deliverydate.
                  lw_data-mcrequire = ''.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        " 2.26 承認サイト
        READ TABLE lt_workflow_api INTO DATA(lw_workflow) WITH KEY sapbusinessobjectnodekey1 = lw_data-purchaseorder sapobjectnoderepresentation = 'PurchaseOrder' BINARY SEARCH.
        IF sy-subrc = 0.
          READ TABLE lt_workflowdetail_api INTO DATA(lw_workflow_d) WITH KEY workflowinternalid = lw_workflow-workflowinternalid BINARY SEARCH.
          " 如果能在detail中取到WorkflowTaskInternalID
          IF sy-subrc = 0.
            IF lw_workflow_d-workflowtaskresult = 'RELEASED'.
              lw_data-workflowtaskresult = '2'.
              lw_data-taskresulttext = '承認済'.
            ELSEIF lw_workflow_d-workflowtaskresult = 'REJECTED' OR lw_workflow_d-workflowtaskresult = ''.
              lw_data-workflowtaskresult = '0'.
              lw_data-taskresulttext = '未承認'.
            ENDIF.
          ELSE.
            "直接判断WorkflowTaskExternalStatus是不是COMPLETED
            IF lw_workflow-workflowexternalstatus = 'COMPLETED'.
              "如果是，则是传出对象。
              lw_data-workflowtaskresult = '2'.
              lw_data-taskresulttext = '承認済'.
            ENDIF.
          ENDIF.
        ENDIF.

        "1202 add by wz
        READ TABLE lt_1009 INTO DATA(lw_1009) WITH KEY pono = lw_data-purchaseorder
                                                       dno  = lw_data-purchaseorderitem
                                                       deliverydate = lw_data-deliverydate
                                                       quantity = lw_data-confirmedquantity BINARY SEARCH.
        IF sy-subrc = 0.
          lw_data-supplierconfirmationextnumber = lw_1009-extnumber.
        ENDIF.

        READ TABLE lt_uweb_api INTO DATA(lw_uweb) WITH KEY po_no = |{ lw_data-purchaseorderitem ALPHA = OUT }|
                                                            d_no = |{ lw_data-purchaseorder ALPHA = OUT }| BINARY SEARCH.
        IF sy-subrc = 0.
          IF lw_uweb-print_times > 0.
            lw_data-porelease = '発行済'.
          ELSEIF lw_uweb-print_times = 0.
            lw_data-porelease = '未発行'.
          ENDIF.
        ENDIF.

        TRY.
            lw_data-purchaseorderquantityunit = zzcl_common_utils=>conversion_cunit(
                                                   EXPORTING iv_alpha = lc_alpha_out
                                                             iv_input = lw_data-purchaseorderquantityunit ).
          CATCH zzcx_custom_exception INTO DATA(lo_exc).
            lw_data-purchaseorderquantityunit = lw_data-purchaseorderquantityunit.
        ENDTRY.

        "2.24 PO単価
        "2.25 金額
        CASE lw_data-documentcurrency.
          WHEN 'JPY'.

            lv_netprice3 = round( val = lw_data-netpriceamount * 100 / lw_data-netpricequantity dec = 3 ).

            lw_data-netprice  = lv_netprice3.
            CLEAR lv_netprice3.

            CONDENSE lw_data-netprice.

            lw_data-netamount = lw_data-netprice * lw_data-confirmedquantity.
            lw_data-netamount = round( val = lw_data-netamount dec = 0 mode = cl_abap_math=>round_half_up ).

          WHEN OTHERS.

            lv_netprice5 = round( val = lw_data-netpriceamount / lw_data-netpricequantity dec = 5 ).

            lw_data-netprice = lv_netprice5.
            CLEAR lv_netprice5.

            lw_data-netamount = lw_data-netprice * lw_data-confirmedquantity.
            lw_data-netamount = round( val = lw_data-netamount dec = 2 mode = cl_abap_math=>round_half_up ).
        ENDCASE.

        " ヘッダテキスト
        READ TABLE lt_longtext INTO DATA(ls_longtext) WITH KEY purchaseorder = lw_data-purchaseorder
                                                               BINARY SEARCH.
        IF sy-subrc = 0.
          lw_data-plainlongtext = ls_longtext-plainlongtext.
        ENDIF.

        " 項目テキスト
        READ TABLE lt_longtext_1 INTO DATA(ls_longtext1) WITH KEY purchaseorder = lw_data-purchaseorder
                                                                  purchaseorderitem = lw_data-purchaseorderitem
                                                                  BINARY SEARCH.
        IF sy-subrc = 0 .

          "change by wz 20241218 只取前后都有空格的  ' # '
          IF ls_longtext1-plainlongtext IS NOT INITIAL.

            FIND ALL OCCURRENCES OF ' # ' IN ls_longtext1-plainlongtext MATCH OFFSET DATA(lv_pos).

            IF lv_pos IS NOT INITIAL.

              lv_pos = lv_pos + 3.

            ENDIF.

            lw_data-plainlongtext1 = ls_longtext1-plainlongtext+lv_pos.

            CLEAR lv_pos.

          ENDIF.

        ENDIF.

        "add by wz 20241227 客户要求追加
        "2.28 PO連携担当者
        IF lw_data-correspncinternalreference IS NOT INITIAL.

          "如果该字段全是数字则不显示。
          IF cl_abap_matcher=>matches(
              pattern = '^(-?[1-9]\d*(\.\d*[1-9])?)|(-?0\.\d*[1-9])$'
              text = lw_data-correspncinternalreference
              ) = abap_true.

            lw_data-correspncinternalreference = ''.

          ENDIF.

        ENDIF.

        "add by wz 20241227 客户要求追加
        "2.30 旧購買発注番号明細 CorrespncExternalReference
        IF lw_data-correspncexternalreference IS NOT INITIAL.

          lw_data-correspncexternalreference = lw_data-correspncexternalreference.

        ENDIF.



        " 输出时的内外部转换
        lw_data-supplier = |{ lw_data-supplier ALPHA = OUT }|. "供应商
        lw_data-material = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = lw_data-material ).
        lw_data-manufacturermaterial = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = lw_data-manufacturermaterial ).
        lw_data-purchaseorderquantityunit = |{ lw_data-purchaseorderquantityunit ALPHA = OUT }|.
        lw_data-customer = |{ lw_data-customer ALPHA = OUT }|.
        lw_data-purchaseorder = |{ lw_data-purchaseorder ALPHA = OUT }|.
        lw_data-purchaseorderitem = |{ lw_data-purchaseorderitem ALPHA = OUT }|.

        " PO残＝PO明細の発注数-入庫済数量
        lw_data-ponokoru = lw_data-orderquantity - lw_data-roughgoodsreceiptqty .

        APPEND lw_data TO lt_data.

        CLEAR: lw_customer, lw_purginfo, lw_mrp, lv_getnop, lw_workflow, lw_workflow_d,lw_1009.
        CLEAR: lw_data.
      ENDLOOP.

      DELETE lt_data WHERE workflowtaskresult NOT IN lr_workflowtaskresult.

      IF lv_poalldis = '2'.
        DELETE lt_data WHERE ponokoru <> 0.
      ELSEIF lv_poalldis = '3'.
        DELETE lt_data WHERE ponokoru = 0.
      ENDIF.

      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( lines( lt_data ) ).
      ENDIF.

      "Sort
      zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                 CHANGING  ct_data  = lt_data ).

      " Paging
      zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                CHANGING  ct_data   = lt_data ).

      io_response->set_data( lt_data ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
