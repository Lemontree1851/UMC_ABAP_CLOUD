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

        sapbusinessobjectnodekey1 TYPE  string,
        workflowinternalid        TYPE  string,
        workflowexternalstatus    TYPE  string,

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
        mrpelementavailyorrqmtdate TYPE sy-datum,
        mrpelementcategory         TYPE c LENGTH 2,
        mrpelementdocumenttype     TYPE c LENGTH 4,
        productionversion          TYPE c LENGTH 4,
        sourcemrpelement           TYPE c LENGTH 12,
        mrpelementreschedulingdate TYPE sy-datum,
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
      lr_mrpctname       TYPE RANGE OF zr_podataanalysis-mrpcontrollername      ,       "MRP管理者
      lr_createdbyuser   TYPE RANGE OF zr_podataanalysis-createdbyuser       ,       "登録者
      ls_purchaseorder   LIKE LINE OF  lr_purchaseorder,
      ls_poitem          LIKE LINE OF  lr_poitem,
      ls_supplier        LIKE LINE OF  lr_supplier,
      ls_purchasinggroup LIKE LINE OF  lr_purchasinggroup,
      ls_material        LIKE LINE OF  lr_material,
      ls_plant           LIKE LINE OF  lr_plant,
      ls_mrpctname       LIKE LINE OF  lr_mrpctname,
      ls_createdbyuser   LIKE LINE OF  lr_createdbyuser,
      ls_res_api         TYPE ty_res_api.


    DATA:
      lr_correspncinternalreference TYPE RANGE OF  i_purchaseorderapi01-correspncinternalreference,
      lr_suppliermaterialnumber     TYPE RANGE OF  i_purchaseorderitemapi01-suppliermaterialnumber,
      lr_purchaseorderdate          TYPE RANGE OF  i_purchaseorderapi01-purchaseorderdate,
      lr_schedulelinedeliverydate   TYPE RANGE OF  i_purordschedulelineapi01-schedulelinedeliverydate,
      lr_deliverydate               TYPE RANGE OF  i_posupplierconfirmationapi01-deliverydate,
      lr_storagelocation            TYPE RANGE OF  i_purchaseorderitemapi01-storagelocation,
      lr_incotermsclassification    TYPE RANGE OF  i_purchaseorderitemapi01-incotermsclassification,
      lr_workflowtaskresult         TYPE RANGE OF  char12,
      ls_correspncinternalreference LIKE LINE OF lr_correspncinternalreference,
      ls_suppliermaterialnumber     LIKE LINE OF lr_suppliermaterialnumber,
      ls_purchaseorderdate          LIKE LINE OF lr_purchaseorderdate,
      ls_schedulelinedeliverydate   LIKE LINE OF lr_schedulelinedeliverydate,
      ls_deliverydate               LIKE LINE OF lr_deliverydate,
      ls_storagelocation            LIKE LINE OF lr_storagelocation,
      ls_incotermsclassification    LIKE LINE OF lr_incotermsclassification,
      ls_workflowtaskresult         LIKE LINE OF lr_workflowtaskresult.

    DATA: lr_new_range TYPE RANGE OF zr_podataanalysis-purchasinggroup, " 新的 range 表
          ls_new_range LIKE LINE OF lr_new_range,                     " 新的 range 表的条目
          ls_old_range LIKE LINE OF lr_purchasinggroup.               " 原来的 range 表的条目

    DATA:
         lt_tlines TYPE tt_tline.

    DATA:
        lv_dur TYPE i .

    DATA:
        lv_mrpdate TYPE d.

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
      lv_matnr TYPE matnr,
      lv_sup   TYPE i_purchaseorderapi01-supplier,
      lv_sup_h TYPE i_purchaseorderapi01-supplier.

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

    DATA:lv_conf TYPE n LENGTH 4.

    DATA: lt_uweb_api TYPE STANDARD TABLE OF ty_response_res,
          ls_response TYPE ty_response.

    IF io_request->is_data_requested( ).
      TRY.
          "Get and add filter
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
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
              MOVE-CORRESPONDING str_rec_l_range TO ls_mrpctname.
              APPEND ls_mrpctname TO lr_mrpctname.
              CLEAR ls_mrpctname.
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

              MOVE-CORRESPONDING str_rec_l_range TO ls_workflowtaskresult.
              APPEND ls_workflowtaskresult TO lr_workflowtaskresult.
              CLEAR ls_workflowtaskresult.

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

      SELECT

             b~purchaseorder                      ,
             b~purchaseorderitem                  ,
             concat( b~purchaseorder, CAST( b~purchaseorderitem AS CHAR ) ) AS popoitem,

             l~deliverydate                       , "回答納期
             l~sequentialnmbrofsuplrconf          ,
             l~supplierconfirmationextnumber      ,
             l~confirmedquantity                  ,

             a~purchaseordertype                  ,
             a~supplier                           ,
             a~purchasinggroup                    ,
             a~purchaseorderdate                  ,             "伝票日付
             a~documentcurrency                   ,
             a~purchasingorganization             ,
             a~createdbyuser                      ,
             a~correspncinternalreference         ,  "1117 追加PO連携担当者



             b~material                           ,
             b~purchaseorderitemtext              ,
             b~manufacturermaterial               ,
             b~manufacturerpartnmbr               ,
             b~manufacturer                       ,
             b~planneddeliverydurationindays      ,
             b~goodsreceiptdurationindays         ,
             b~orderquantity                      ,
             b~purchaseorderquantityunit          ,
             b~purchaserequisition                ,
             b~purchaserequisitionitem            ,
             b~requirementtracking                ,
             b~requisitionername                  ,
             b~internationalarticlenumber         ,
             b~materialgroup                      ,
             b~netamount                          ,
             b~plant                              ,
             b~storagelocation                    ,"保管場所
             b~iscompletelydelivered              ,
             b~taxcode                            ,
             b~pricingdatecontrol                 ,
             b~incotermsclassification            ,"基軸通貨

             b~netpricequantity                   ,
             b~netpriceamount                     ,
             b~purchaseorderitemcategory          ,
             b~suppliermaterialnumber             ,                               "1117 追加仕入先品目コード

             c~suppliername   AS     suppliername1,                               "仕入先名称
             "c~suppliername   AS     suppliername2,

             d~mrparea                            ,                               "2.3　MRPエリア

             e~mrpresponsible                     ,                               "2.4　MRPコントロール

             f~mrpcontrollername                  ,                               "2.5　コントロール名称

             g~suppliercertorigincountry          ,                               "2.7　原産国

             g~purchasinginforecord               ,
             g~suppliersubrange                   ,                               "供給者部門

             h~storagelocationname                ,                               "2.8　保管場所テキスト

             i~productionmemopageformat           ,                               "基板取り数
             i~productionorinspectionmemotxt      ,                               "2.9　基板取数(製造/検査メモ)

             j~supplierrespsalespersonname        ,                               "2.10　下請対象 販売担当者

             k~lotsizeroundingquantity            ,                               "2.11　丸め数量

             m~schedulelinedeliverydate           ,                               "納入日付
             m~roughgoodsreceiptqty


        FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS AS b
        LEFT OUTER JOIN i_posupplierconfirmationapi01 WITH PRIVILEGED ACCESS AS l
          ON l~purchaseorder = b~purchaseorder
         AND l~purchaseorderitem = b~purchaseorderitem
        LEFT JOIN i_purchaseorderapi01  WITH PRIVILEGED ACCESS AS a
          ON b~purchaseorder = a~purchaseorder
        LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS c
          ON a~supplier = c~supplier
        LEFT JOIN i_productmrparea WITH PRIVILEGED ACCESS AS d
          ON d~product = b~material
         AND d~mrpplant = b~plant
        LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS e
          ON e~product = b~material
         AND e~plant = b~plant
        LEFT JOIN i_mrpcontroller WITH PRIVILEGED ACCESS AS f
          ON f~mrpcontroller = e~mrpresponsible
         AND f~plant = b~plant
        LEFT JOIN i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS g
          ON g~purchasinginforecord = b~purchasinginforecord
        LEFT JOIN i_storagelocation WITH PRIVILEGED ACCESS AS h
          ON h~plant = b~plant
         AND h~storagelocation = b~storagelocation
        LEFT JOIN i_product WITH PRIVILEGED ACCESS AS i
          ON i~product = b~material
        LEFT JOIN i_supplierpurchasingorg WITH PRIVILEGED ACCESS AS j
          ON j~supplier = a~supplier
         AND j~purchasingorganization = a~purchasingorganization
        LEFT JOIN  i_productsupplyplanning WITH PRIVILEGED ACCESS AS k
          ON k~product = b~material
         AND k~plant = b~plant
        LEFT JOIN i_purordschedulelineapi01 WITH PRIVILEGED ACCESS AS m
          ON m~purchaseorder = b~purchaseorder
         AND m~purchaseorderitem = b~purchaseorderitem
*       LEFT JOIN I_SupplierSubrange WITH PRIVILEGED ACCESS AS N
*         ON N~SupplierSubrange = B~SupplierSubrange
*        AND N~Supplier = A~Supplier
       WHERE b~purchaseorder IN @lr_purchaseorder
         AND b~purchaseorderitem IN @lr_poitem
         AND c~supplier IN @lr_sup
         AND a~purchasinggroup IN @lr_purchasinggroup
         AND b~material IN @lr_material
         AND b~suppliermaterialnumber IN @lr_suppliermaterialnumber
         AND b~plant IN @lr_plant
         AND b~storagelocation IN @lr_storagelocation
         AND b~incotermsclassification IN @lr_incotermsclassification
         AND a~createdbyuser IN @lr_createdbyuser
         AND a~correspncinternalreference IN @lr_correspncinternalreference
         AND a~purchaseorderdate IN @lr_purchaseorderdate
         AND m~schedulelinedeliverydate IN @lr_schedulelinedeliverydate
         AND l~deliverydate IN @lr_deliverydate
*        AND N~Language =
        INTO TABLE @DATA(lt_result) .

*     购买组取值
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

      "2.6　メーカー名
      SELECT suppliername ,
             supplier
        FROM i_supplier WITH PRIVILEGED ACCESS
        INTO  TABLE @DATA(lt_maker).

      SORT lt_maker BY  supplier .

      SELECT customer ,
             addresssearchterm2
        FROM i_customer WITH PRIVILEGED ACCESS
       WHERE addresssearchterm1 IN @lr_new_range
        INTO TABLE @DATA(lt_customer).

      SORT lt_customer BY addresssearchterm2.

      "-----2.17　NCNR、CANCELルール-------------
      "購買情報の組織プラントデータ
      SELECT *
        FROM i_purginforecdorgplntdataapi01
        WITH PRIVILEGED ACCESS
       WHERE ismarkedfordeletion IS INITIAL   "ブランク
        INTO TABLE @DATA(lt_purginfo).

      SORT lt_purginfo BY purchasinginforecord  purchasingorganization plant purchasinginforecordcategory .

      "出荷指示 - テキスト
      SELECT *
        FROM i_shippinginstructiontext
        WITH PRIVILEGED ACCESS
       WHERE language = @sy-langu
        INTO TABLE @DATA(lt_shipping).

      SORT lt_shipping BY shippinginstruction.

      "-----2.17　NCNR、CANCELルール-------------

      SELECT *
        FROM i_purchaseorderitemnotetp_2
        WITH PRIVILEGED ACCESS
       WHERE language = @sy-langu
        INTO TABLE @DATA(lt_longtext).

      SORT lt_longtext BY purchaseorder  purchaseorderitem.

      SELECT *
        FROM i_purchaseordernotetp_2
        WITH PRIVILEGED ACCESS
       WHERE language = @sy-langu
        INTO TABLE @DATA(lt_longtext_1).
      SORT lt_longtext_1 BY purchaseorder .

      "mrp管理者 控制
      DELETE lt_result WHERE mrpresponsible NOT IN lr_mrpctname.

      "承認区分

      DATA:
        lv_pathoverview TYPE string,
        lv_pathdetails  TYPE string.

      IF lt_result IS NOT INITIAL.

        DATA(lt_result_1) = lt_result.

        DELETE lt_result_1 WHERE deliverydate IS INITIAL.


        SORT lt_result_1 BY plant.

        DELETE ADJACENT DUPLICATES FROM lt_result_1 COMPARING plant.

      ENDIF.

      " api 接口 mrp 数据取得。
      IF lt_result_1 IS  NOT INITIAL.

        LOOP AT lt_result_1 INTO DATA(lw_result_1).

          lv_path = |/API_MRP_MATERIALS_SRV_01/SupplyDemandItems?$filter=MRPPlant eq '{ lw_result_1-plant }' and MRPArea eq '{ lw_result_1-plant }'|.

          zzcl_common_utils=>request_api_v2(
                EXPORTING
                  iv_path        = lv_path
                  iv_method      = if_web_http_client=>get
                IMPORTING
                  ev_status_code = DATA(lv_stat_code)
                  ev_response    = DATA(lv_resbody_api) ).

          /ui2/cl_json=>deserialize(
                          EXPORTING json = lv_resbody_api
                          CHANGING data = ls_res_mrp_api ).

          IF lv_stat_code = '200' AND ls_res_mrp_api-d-results IS NOT INITIAL.
            APPEND LINES OF ls_res_mrp_api-d-results TO lt_mrp_api.
          ENDIF.

          CLEAR ls_res_mrp_api.

        ENDLOOP.

        IF  lt_mrp_api IS NOT INITIAL.

          LOOP AT lt_mrp_api ASSIGNING FIELD-SYMBOL(<fs_mrp>) .

            <fs_mrp>-mrpelementitem = |{ <fs_mrp>-mrpelementitem ALPHA = IN }|.

*                if <fs_mrp>-MRPElementScheduleLine is not INITIAL.
*                <fs_mrp>-MRPElementScheduleLine = |{ <fs_mrp>-MRPElementScheduleLine ALPHA = IN }|.
*                ENDIF.

          ENDLOOP.

        ENDIF.

      ENDIF.

      SORT lt_mrp_api BY mrpelement  mrpelementitem mrpelementscheduleline mrpelementcategory.

      "uweb 接口，打印次数
      zzcl_common_utils=>get_externalsystems_cdata( EXPORTING iv_odata_url     = |http://220.248.121.53:11380/srv/odata/v2/TableService/T02_PO_D|
                                                              iv_client_id     = CONV #( 'Tom' )
                                                              iv_client_secret = CONV #( '1' )
                                                             iv_authtype      = 'Basic'
                                                    IMPORTING ev_status_code   = DATA(lv_status_code_uweb)
                                                              ev_response      = DATA(lv_response_uweb) ).
      IF lv_status_code_uweb = 200.
        xco_cp_json=>data->from_string( lv_response_uweb )->apply( VALUE #(
*            ( xco_cp_json=>transformation->pascal_case_to_underscore )
          ( xco_cp_json=>transformation->boolean_to_abap_bool )
        ) )->write_to( REF #( ls_response ) ).

        IF ls_response-d-results IS NOT INITIAL.

          APPEND LINES OF ls_response-d-results TO lt_uweb_api.

        ENDIF.

      ENDIF.

      SORT lt_uweb_api BY po_no d_no.




*     审批状态取得取得
      lv_pathoverview = |/YY1_WORKFLOWSTATUSOVERVIEW_CDS/YY1_WorkflowStatusOverview|.
      "Call API
      zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_pathoverview
          iv_method      = if_web_http_client=>get
          iv_format      = 'json'
        IMPORTING
          ev_status_code = DATA(lv_stat_codeo)
          ev_response    = DATA(lv_resbody_apio) ).
      /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_apio
                               CHANGING data = ls_res_workflow ).

      IF lv_stat_codeo = '200' AND ls_res_workflow-d-results IS NOT INITIAL.

        APPEND LINES OF ls_res_workflow-d-results TO lt_workflow_api.

      ENDIF.

      SORT lt_workflow_api BY sapbusinessobjectnodekey1.

*      审批详情取得

      lv_pathdetails = |/YY1_WORKFLOWSTATUSDETAILS_CDS/YY1_WorkflowStatusDetails|.
      "Call API
      zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_pathdetails
          iv_method      = if_web_http_client=>get
          iv_format      = 'json'
        IMPORTING
          ev_status_code = DATA(lv_stat_coded)
          ev_response    = DATA(lv_resbody_apid) ).
      /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_apid
                               CHANGING data = ls_res_workflowdetail ).

      IF lv_stat_coded = '200' AND ls_res_workflowdetail-d-results IS NOT INITIAL.

        APPEND LINES OF ls_res_workflowdetail-d-results TO lt_workflowdetail_api.

      ENDIF.

      IF lt_workflowdetail_api IS NOT INITIAL.

        SORT lt_workflowdetail_api BY workflowinternalid workflowtaskinternalid DESCENDING.

        DELETE ADJACENT DUPLICATES FROM lt_workflowdetail_api COMPARING workflowinternalid.

      ENDIF.

      DATA:lv_response TYPE c .

      LOOP  AT lt_result INTO DATA(lw_result).

        MOVE-CORRESPONDING lw_result TO lw_data.

        "2.2　得意先名称通过 ea0 后两位检索 customer
        READ TABLE lt_customer INTO DATA(lw_customer) WITH KEY addresssearchterm2 = lw_result-purchasinggroup+1(2) BINARY SEARCH.
        IF sy-subrc = 0.
          lw_data-customer = lw_customer-customer.
          CLEAR lw_customer.
        ELSE.
          lw_data-customer = ''.
        ENDIF.
        CLEAR lw_customer.

        CASE lw_data-purchaseorderitemcategory.

          WHEN '0'.
            DATA(lv_purcate) = '0'.

          WHEN '3'.

            lv_purcate = '3'.
          WHEN '2'.

            lv_purcate = '2'.

          WHEN OTHERS.

        ENDCASE.


        "2.17　NCNR、CANCELルール
        READ TABLE lt_purginfo INTO DATA(lw_purginfo) WITH KEY purchasinginforecord   = lw_result-purchasinginforecord
                                                               purchasingorganization = lw_result-purchasingorganization
                                                               plant                  = lw_result-plant
                                                               purchasinginforecordcategory = lv_purcate
                                                               BINARY SEARCH.

        IF sy-subrc = 0.

          IF lw_purginfo-shippinginstruction IS INITIAL.
            DATA(lv_error1q) = 'X'.
          ENDIF.

          READ TABLE lt_shipping INTO DATA(lw_shipping) WITH KEY shippinginstruction = lw_purginfo-shippinginstruction BINARY SEARCH.  "出荷指示

          IF sy-subrc = 0.
            "NCNR、CANCELルール
            lw_data-shippinginstructionname  =  lw_shipping-shippinginstructionname.
            CLEAR:lw_shipping.

          ELSE.
            lw_data-shippinginstructionname = ''.

          ENDIF.
          CLEAR:lw_shipping.


        ELSE.

          lw_data-shippinginstructionname = ''.

        ENDIF.

        CLEAR:lw_shipping.
        CLEAR lw_purginfo.

*          "2.19 例外
*          "2.20 注意

        IF lw_result-sequentialnmbrofsuplrconf IS NOT INITIAL .

          READ TABLE lt_mrp_api INTO DATA(lw_mrp) WITH KEY mrpelement = lw_result-purchaseorder
                                                           mrpelementitem = lw_result-purchaseorderitem
                                                           mrpelementscheduleline = lw_result-sequentialnmbrofsuplrconf
                                                            BINARY SEARCH.

          IF sy-subrc = 0.
            DATA(lv_getnop) = 'X'.
          ELSE.
            lv_getnop = ''.
          ENDIF.

        ELSE.

          READ TABLE lt_mrp_api INTO lw_mrp WITH KEY mrpelement = lw_result-purchaseorder
                                                     mrpelementitem = lw_result-purchaseorderitem
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

          IF lw_mrp-mrpelementreschedulingdate IS NOT INITIAL.
            lw_data-mrpelementreschedulingdate = lw_mrp-mrpelementreschedulingdate.
          ENDIF.

          IF lw_mrp-mrpelementavailyorrqmtdate IS NOT INITIAL.
*
*          data(lv_possi) = CONV string( lw_mrp-MRPElementAvailyOrRqmtDate DIV 1000000 ) .

            lw_data-possibleproductiondate =  lw_mrp-mrpelementavailyorrqmtdate.

            IF lw_mrp-exceptionmessagetext IS NOT INITIAL.

              DATA(lv_length) = strlen( lw_mrp-exceptionmessagetext ).

              IF lv_length = 33.
                "

                DATA(lv_yy) = lw_mrp-exceptionmessagetext+30(2).
                DATA(lv_dd) = lw_mrp-exceptionmessagetext+27(2).
                DATA(lv_mm) = lw_mrp-exceptionmessagetext+24(2).
                DATA(lv_date) = |20{ lv_yy }{ lv_mm }{ lv_dd } |.
                lw_data-mrpdiliverydate = lv_date.
              ENDIF.
              CLEAR:lv_yy,lv_dd,lv_mm,lv_date,lv_length.

            ENDIF.
          ENDIF.

*           "2.12　生産可能日付   生産可能日付=回答納期＋入庫処理時間（稼働日） 然后需要使用工厂日期
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
*
*        ELSE.
*
*          "采用
*          lw_data-possibleproductiondate = zzcl_common_utils=>get_workingday( iv_date = lw_result-deliverydate
*                                                        iv_next = abap_false
*                                                        iv_plant = lw_data-plant ).
*
*        ENDIF.



          IF lw_mrp-mrpelementavailyorrqmtdate IS NOT INITIAL AND lw_data-mrpelementreschedulingdate IS NOT INITIAL .

*            lv_dur = lw_mrp-mrpelementavailyorrqmtdate.   "入庫処理時間
            "購買納入日付

*            lw_data-mrpdiliverydate = zzcl_common_utils=>calc_date_subtract(
*              EXPORTING
*                date      = lw_data-mrpelementreschedulingdate
*
*                day       = lv_dur
*
*            ).
*
*            lw_data-mrpdiliverydate = zzcl_common_utils=>get_workingday( iv_date = lw_data-mrpdiliverydate
*                                                                    iv_next = abap_false
*                                                                    iv_plant = lw_data-plant ).

          ELSE.
            IF lw_mrp-mrpelementreschedulingdate IS NOT INITIAL.
              lw_data-mrpdiliverydate =  lw_mrp-mrpelementreschedulingdate.


            ENDIF.

          ENDIF.

        ENDIF.

        CLEAR:  lw_mrp ,lv_getnop.

        "LW_DATA-MRPDILIVERYDATE  = LW_MRP-MRPElementAvailyOrRqmtDate - 1.  calc_date_subtract


*          "2.21 MC要求
        IF lw_data-schedulelinedeliverydate IS NOT INITIAL AND lw_data-mrpelementreschedulingdate IS NOT INITIAL.
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
            ELSEIF lw_data-schedulelinedeliverydate =  lw_data-deliverydate.
              lw_data-mcrequire = ''.
            ENDIF.

            IF lw_data-deliverydate <> ''.
              IF lw_data-schedulelinedeliverydate >  lw_data-deliverydate.
                lw_data-mcrequire = 'PULL IN'.

              ELSE.
                IF lw_data-schedulelinedeliverydate >  lw_data-deliverydate.
                  lw_data-mcrequire = ''.

                ENDIF.
              ENDIF.

            ENDIF.

          ENDIF.
        ENDIF.




        "2.26 承認サイト
        "lw_data-WorkflowTaskResut

        READ TABLE lt_workflow_api INTO DATA(lw_workflow) WITH KEY sapbusinessobjectnodekey1 = lw_data-purchaseorder BINARY SEARCH.

        IF sy-subrc = 0.
          READ TABLE lt_workflowdetail_api INTO DATA(lw_workflow_d) WITH KEY workflowinternalid = lw_workflow-workflowinternalid BINARY SEARCH.

          "如果能在detail中取到WorkflowTaskInternalID
          IF sy-subrc = 0.

            IF lw_workflow_d-workflowtaskresult = 'RELEASED'.

              lw_data-workflowtaskresult = '2'.
              lw_data-taskresulttext = '承認済'.

            ELSEIF lw_workflow_d-workflowtaskresult = 'REJECTED' OR lw_workflow_d-workflowtaskresult = ''.

              lw_data-workflowtaskresult = 'D'.
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

        ELSE.

        ENDIF.

        CLEAR:  lw_workflow      ,lw_workflow_d.

        APPEND lw_data TO lt_data.
        CLEAR lw_data.

      ENDLOOP.

      DELETE lt_data WHERE workflowtaskresult NOT IN lr_workflowtaskresult.

      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

        DATA(lv_dn) =  |{ <fs_data>-purchaseorderitem ALPHA = OUT }| .
        DATA(lv_po) = |{ <fs_data>-purchaseorder ALPHA = OUT }| .
        READ TABLE lt_uweb_api INTO DATA(lw_uweb) WITH KEY po_no = lv_po
                                                            d_no = lv_dn BINARY SEARCH.
        IF sy-subrc = 0.

          IF lw_uweb-print_times > 0.
            <fs_data>-porelease = '発行済'.

          ELSEIF lw_uweb-print_times = 0.
            <fs_data>-porelease = '未発行'.
          ENDIF.

        ENDIF.



        CLEAR : lw_uweb , lv_dn ,lv_po.

        READ TABLE lt_maker INTO DATA(lw_maker) WITH KEY supplier = <fs_data>-manufacturer BINARY SEARCH.
        IF  sy-subrc = 0.
          <fs_data>-suppliername2 = lw_maker-suppliername.

        ENDIF.

        CLEAR lw_maker.


        "输出时的内外部转换
        <fs_data>-supplier = |{ <fs_data>-supplier ALPHA = OUT }|. "供应商
        <fs_data>-material = |{ <fs_data>-material ALPHA = OUT }|. "品目
        <fs_data>-manufacturermaterial = |{ <fs_data>-manufacturermaterial ALPHA = OUT }|. "内部品目
        <fs_data>-purchaseorderquantityunit =  |{ <fs_data>-purchaseorderquantityunit ALPHA = OUT }|.
        <fs_data>-customer = |{ <fs_data>-customer ALPHA = OUT }|.  "得意先名称

        "unit in and out transfer
        TRY.
            <fs_data>-purchaseorderquantityunit = zzcl_common_utils=>conversion_cunit(
                                                   EXPORTING iv_alpha = lc_alpha_out
                                                             iv_input = <fs_data>-purchaseorderquantityunit ).

          CATCH zzcx_custom_exception INTO DATA(lo_exc).

            <fs_data>-purchaseorderquantityunit     = <fs_data>-purchaseorderquantityunit.

        ENDTRY.

        "PO残＝PO明細の発注数-入庫済数量
        <fs_data>-ponokoru = <fs_data>-orderquantity - <fs_data>-roughgoodsreceiptqty .

        "2.24 PO単価
        "2.25 金額
        CASE <fs_data>-documentcurrency.

          WHEN 'JPY'.
            <fs_data>-netprice = <fs_data>-netpriceamount * 100 / <fs_data>-netpricequantity.
            <fs_data>-netamount = <fs_data>-netprice * <fs_data>-confirmedquantity.

            <fs_data>-netamount  = round( val = <fs_data>-netamount dec = 0 mode = cl_abap_math=>round_half_up ).


          WHEN OTHERS.
            <fs_data>-netprice =  <fs_data>-netpriceamount / <fs_data>-netpricequantity.
            <fs_data>-netamount = <fs_data>-netprice * <fs_data>-confirmedquantity.
            <fs_data>-netamount  = round( val = <fs_data>-netamount dec = 2 mode = cl_abap_math=>round_half_up ).

        ENDCASE.

        "ヘッダテキスト
        READ TABLE lt_longtext INTO DATA(ls_longtext) WITH KEY purchaseorder = <fs_data>-purchaseorder purchaseorderitem = <fs_data>-purchaseorderitem  BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_data>-plainlongtext1 =  ls_longtext-plainlongtext.
        ENDIF.
        CLEAR ls_longtext.

        "項目テキスト
        READ TABLE lt_longtext_1 INTO DATA(ls_longtext1) WITH KEY purchaseorder = <fs_data>-purchaseorder BINARY SEARCH.

        IF sy-subrc = 0 .
          <fs_data>-plainlongtext = ls_longtext1-plainlongtext.
        ENDIF.
        CLEAR ls_longtext1.

      ENDLOOP.

      IF lv_poalldis = '2'.  "hai

        DELETE lt_data WHERE ponokoru <> 0.

      ELSEIF lv_poalldis = '3'."iie

        DELETE lt_data WHERE ponokoru = 0.

      ELSE.


      ENDIF.

      "Page
*      DATA(lv_start) = lv_skip + 1.
*      DATA(lv_end) = lv_skip + lv_top.
*      APPEND LINES OF lt_data FROM lv_start TO lv_end TO lt_output.
*      io_response->set_total_number_of_records( lines( lt_data ) ).

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
