CLASS zcl_podataanalysis DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PODATAANALYSIS IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    TYPES:
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
        mrpelementavailyorrqmtdate TYPE string,
        mrpelementcategory         TYPE c LENGTH 2,
        mrpelementdocumenttype     TYPE c LENGTH 4,
        productionversion          TYPE c LENGTH 4,
        sourcemrpelement           TYPE c LENGTH 12,
        mrpelementreschedulingdate TYPE string,
        exceptionmessagenumber     TYPE string,

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
      END OF ts_res_mrp_api.

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
      lr_mrpctname  TYPE RANGE OF zr_podataanalysis-MRPControllerName      ,       "MRP管理者
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


    DATA: lr_new_range TYPE RANGE OF zr_podataanalysis-purchasinggroup, " 新的 range 表
          ls_new_range LIKE LINE OF lr_new_range,                     " 新的 range 表的条目
          ls_old_range LIKE LINE OF lr_purchasinggroup.               " 原来的 range 表的条目

    DATA:
         lt_tlines TYPE tt_tline.

    DATA:
        lv_dur TYPE i .

    DATA:
        LV_MRPDate TYPE D.

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

    IF io_request->is_data_requested( ).
      TRY.
          "Get and add filter
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
      ENDTRY.

      DATA(lv_top)    = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)   = io_request->get_paging( )->get_offset( ).
      DATA(lt_fields) = io_request->get_requested_elements( ).
      DATA(lt_sort)   = io_request->get_sort_elements( ).

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
            WHEN OTHERS.

          ENDCASE.

        ENDLOOP.

      ENDLOOP.

      SELECT a~purchaseordertype                  ,
             a~supplier                           ,
             a~purchasinggroup                    ,
             a~purchaseorderdate                  ,
             a~documentcurrency                   ,
             a~purchasingorganization             ,
             a~createdbyuser                      ,


             l~purchaseorderitem                  ,
             l~purchaseorder                      ,
             l~deliverydate                       ,
             l~sequentialnmbrofsuplrconf          ,
             l~supplierconfirmationextnumber      ,
             l~confirmedquantity                  ,

             concat( b~purchaseorder, CAST( b~purchaseorderitem AS CHAR ) ) AS popoitem,
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
             b~storagelocation                    ,
             b~iscompletelydelivered              ,
             b~taxcode                            ,
             b~pricingdatecontrol                 ,

             b~netpricequantity                   ,
             b~NetPriceAmount                     ,
             b~PurchaseOrderItemCategory          ,

             c~suppliername   AS     suppliername1,                               "仕入先名称
             "c~suppliername   AS     suppliername2,

             d~mrparea                            ,                               "2.3　MRPエリア

             e~mrpresponsible                     ,                               "2.4　MRPコントロール

             f~mrpcontrollername                  ,                               "2.5　コントロール名称

             g~suppliercertorigincountry          ,                               "2.7　原産国
             g~suplrcertoriginclassfctnnumber     ,                               "2.16　基軸通貨(製造業者)
             g~purchasinginforecord               ,
             g~suppliersubrange                   ,                               "供給者部門

             h~storagelocationname                ,                               "2.8　保管場所テキスト

             i~productionmemopageformat           ,                               "基板取り数
             i~ProductionOrInspectionMemoTxt      ,                               "2.9　基板取数(製造/検査メモ)

             j~supplierrespsalespersonname        ,                               "2.10　下請対象 販売担当者

             k~lotsizeroundingquantity            ,                               "2.11　丸め数量

             m~schedulelinedeliverydate           ,
             m~roughgoodsreceiptqty

        FROM i_posupplierconfirmationapi01 WITH PRIVILEGED ACCESS AS l
        LEFT JOIN i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS AS b
          ON l~purchaseorder = b~purchaseorder
         AND l~purchaseorderitem = b~purchaseorderitem
        LEFT JOIN i_purchaseorderapi01  WITH PRIVILEGED ACCESS AS a
          ON l~purchaseorder = a~purchaseorder
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
         AND b~plant IN @lr_plant
         AND a~createdbyuser IN @lr_createdbyuser
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
      SELECT SupplierName ,
             Supplier
        FROM I_Supplier WITH PRIVILEGED ACCESS
        into  table @DATA(lt_maker).

      SELECT customer ,
             addresssearchterm2
        FROM i_customer WITH PRIVILEGED ACCESS
       WHERE addresssearchterm1 IN @lr_new_range
        INTO TABLE @DATA(lt_customer).

      "-----2.17　NCNR、CANCELルール-------------
      "購買情報の組織プラントデータ
      SELECT *
        FROM i_purginforecdorgplntdataapi01
        WITH PRIVILEGED ACCESS
       WHERE ismarkedfordeletion IS INITIAL   "ブランク
        INTO TABLE @DATA(lt_purginfo).

      "出荷指示 - テキスト
      SELECT *
        FROM i_shippinginstructiontext
        WITH PRIVILEGED ACCESS
       WHERE language = @sy-langu
        INTO TABLE @DATA(lt_shipping).

      "-----2.17　NCNR、CANCELルール-------------

      SELECT *
        FROM i_purchaseorderitemnotetp_2
        WITH PRIVILEGED ACCESS
       WHERE language = @sy-langu
        INTO TABLE @DATA(lt_longtext).

      SELECT *
        FROM i_purchaseordernotetp_2
        WITH PRIVILEGED ACCESS
       WHERE language = @sy-langu
        INTO TABLE @DATA(lt_longtext_1).

      "mrp管理者 控制
      DELETE lt_result WHERE MRPResponsible not IN lr_mrpctname.

      LOOP  AT lt_result INTO DATA(lw_result).

        MOVE-CORRESPONDING lw_result TO lw_data.

        "2.2　得意先名称通过 ea0 后两位检索 customer
        READ TABLE lt_customer INTO DATA(lw_customer) WITH KEY addresssearchterm2 = lw_result-purchasinggroup+1(2).
        IF sy-subrc = 0.
          lw_data-customer = lw_customer-customer.
          clear lw_customer.
        else.
            lw_data-customer = ''.
        ENDIF.
        clear lw_customer.

        "2.12　生産可能日付   生産可能日付=回答納期＋入庫処理時間（稼働日）
        CLEAR lv_dur.
        lv_dur = lw_result-goodsreceiptdurationindays.  "入庫処理時間（稼働日）

        IF lv_dur <> 0 AND lw_result-deliverydate IS NOT INITIAL.
          lw_data-possibleproductiondate = zzcl_common_utils=>calc_date_add(
            EXPORTING
              date  = lw_result-deliverydate  "回答納期
              day   = lv_dur                  "入庫処理時間（稼働日）
            ).


        ELSE.

          lw_data-possibleproductiondate = lw_result-deliverydate.

        ENDIF.
        case lw_data-PurchaseOrderItemCategory.

        when '0'.
        data(lv_PurCate) = '0'.

        WHEN '3'.

            lv_PurCate = '3'.
        when '2'.

            lv_PurCate = '2'.

        when OTHERS.

        ENDCASE.


        "2.17　NCNR、CANCELルール
        READ TABLE lt_purginfo INTO DATA(lw_purginfo) WITH KEY purchasinginforecord   = lw_result-purchasinginforecord
                                                               purchasingorganization = lw_result-purchasingorganization
                                                               plant                  = lw_result-plant
                                                               PurchasingInfoRecordCategory = lv_PurCate .

        IF sy-subrc = 0.

        if lw_purginfo-shippinginstruction is INITIAL.
            data(lv_error1q) = 'x'.
        endif.

          READ TABLE lt_shipping INTO DATA(lw_shipping) WITH KEY shippinginstruction = lw_purginfo-shippinginstruction.  "出荷指示

          IF sy-subrc = 0.
            "NCNR、CANCELルール
            lw_data-shippinginstructionname  =  lw_shipping-shippinginstructionname.
            clear:lw_shipping.

          else.
            lw_data-shippinginstructionname = ''.

          ENDIF.
          clear:lw_shipping.


        else.

            lw_data-shippinginstructionname = ''.

        ENDIF.

        clear:lw_shipping.
        CLEAR lw_purginfo.

        DATA(lv_a) = lw_result-material.
        DATA(lv_b) = lw_result-plant.
        DATA(lv_c) = lw_result-purchaseorder.
        DATA(lv_d) = lw_result-purchaseorderitem.
        IF lw_result-sequentialnmbrofsuplrconf IS INITIAL.

          DATA(lv_e) = | & MRPElementScheduleLine eq '{ lw_result-sequentialnmbrofsuplrconf }'|.
        ELSE.
          lv_e = | & MRPElementCategory eq 'BE' |.
        ENDIF.

        lv_path = |/API_MRP_MATERIALS_SRV_01/SupplyDemandItems?$filter=Material eq '{ lv_a }' & MRPPlant eq '{ lv_b }' & MRPArea eq '{ lv_b }' & MRPElement eq '{ lv_c }' & MRPElementItem eq '{ lv_d }' { lv_e }|.

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

        CLEAR: lt_mrp_api,ls_res_mrp_api.
        IF lv_stat_code = '200' AND ls_res_mrp_api-d-results IS NOT INITIAL.
          APPEND LINES OF ls_res_mrp_api-d-results TO lt_mrp_api.
        ENDIF.

        CLEAR: lv_path ,lv_stat_code .

        LOOP AT lt_mrp_api ASSIGNING FIELD-SYMBOL(<fs_mrp>).

          <fs_mrp>-mrpelementitem = |{ <fs_mrp>-mrpelementitem ALPHA = IN }|.

        ENDLOOP.

*          "2.19 例外
*          "2.20 注意

        READ TABLE lt_mrp_api INTO DATA(lw_mrp) WITH KEY mrpelement = lw_result-purchaseorder mrpelementitem = lw_result-purchaseorderitem.

        IF sy-subrc = 0.

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

          if lw_mrp-mrpelementreschedulingdate is NOT INITIAL.
            lw_data-mrpelementreschedulingdate = lw_mrp-mrpelementreschedulingdate.
          ENDIF.

          if LW_MRP-MRPElementAvailyOrRqmtDate is NOT INITIAL and lw_data-mrpelementreschedulingdate is not INITIAL .

                lv_dur = LW_MRP-MRPElementAvailyOrRqmtDate.   "入庫処理時間
                "購買納入日付

                LW_DATA-MRPDILIVERYDATE = zzcl_common_utils=>calc_date_subtract(
                  EXPORTING
                    date      = lw_data-mrpelementreschedulingdate

                    day       = lv_dur

                ).

                LW_DATA-MRPDILIVERYDATE = zzcl_common_utils=>get_workingday( iv_date = LW_DATA-MRPDILIVERYDATE
                                                                        iv_next = abap_false ).

            ELSE.
                if lw_mrp-mrpelementreschedulingdate is NOT INITIAL.
                       LW_DATA-MRPDILIVERYDATE =  lw_mrp-mrpelementreschedulingdate.


                ENDIF.

            ENDIF.

         ENDIF.
         clear  lw_mrp.

          "LW_DATA-MRPDILIVERYDATE  = LW_MRP-MRPElementAvailyOrRqmtDate - 1.  calc_date_subtract


*          "2.21 MC要求
 if lw_data-schedulelinedeliverydate is NOT INITIAL and ls_res_api-d-mrpelementreschedulingdate is NOT INITIAL.
        IF lw_data-attention <> ''.

          IF lw_data-attention = 'CANCEL'.
            lw_data-mcrequire = 'CANCEL'.

          ELSE.



                IF lw_data-schedulelinedeliverydate < ls_res_api-d-mrpelementreschedulingdate.
                  lw_data-mcrequire = 'PUSH OUT'.
                ELSEIF lw_data-schedulelinedeliverydate > ls_res_api-d-mrpelementreschedulingdate.
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

        APPEND lw_data TO lt_data.

      ENDLOOP.

      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

        READ TABLE lt_maker into data(lw_maker) with KEY Supplier = <fs_data>-Manufacturer.
            if  sy-subrc = 0.
                <fs_data>-SupplierName2 = lw_maker-SupplierName.

            ENDIF.

            CLEar lw_maker.


        "输出时的内外部转换
        <fs_data>-supplier = |{ <fs_data>-supplier ALPHA = OUT }|. "供应商
        <fs_data>-material = |{ <fs_data>-material ALPHA = OUT }|. "品目
        <fs_data>-manufacturermaterial = |{ <fs_data>-manufacturermaterial ALPHA = OUT }|. "内部品目
        <fs_data>-purchaseorderquantityunit =  |{ <fs_data>-purchaseorderquantityunit ALPHA = OUT }|.
        <fs_data>-Customer = |{ <fs_data>-Customer ALPHA = OUT }|.  "得意先名称

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
            <fs_data>-netprice = <fs_data>-NetPriceAmount * 100 / <fs_data>-netpricequantity.
            <fs_data>-netamount = <fs_data>-NetPrice * <fs_data>-ConfirmedQuantity.

            <fs_data>-netamount  = round( val = <fs_data>-netamount dec = 0 mode = cl_abap_math=>ROUND_HALF_UP ).


          WHEN OTHERS.
            <fs_data>-netprice =  <fs_data>-NetPriceAmount / <fs_data>-netpricequantity.
            <fs_data>-netamount = <fs_data>-NetPrice * <fs_data>-ConfirmedQuantity.
            <fs_data>-netamount  = round( val = <fs_data>-netamount dec = 2 mode = cl_abap_math=>ROUND_HALF_UP ).

        ENDCASE.

        "ヘッダテキスト
        READ TABLE lt_longtext INTO DATA(ls_longtext) WITH KEY purchaseorder = <fs_data>-purchaseorder purchaseorderitem = <fs_data>-purchaseorderitem .
        IF sy-subrc = 0.
          <fs_data>-plainlongtext1 =  ls_longtext-plainlongtext.
        ENDIF.
        clear ls_longtext.

        "項目テキスト
        READ TABLE lt_longtext_1 INTO DATA(ls_longtext1) WITH KEY purchaseorder = <fs_data>-purchaseorder.

        IF sy-subrc = 0 .
          <fs_data>-plainlongtext = ls_longtext1-plainlongtext.
        ENDIF.
        clear ls_longtext1.

      ENDLOOP.

      "Page
      DATA(lv_start) = lv_skip + 1.
      DATA(lv_end) = lv_skip + lv_top.

      APPEND LINES OF lt_data FROM lv_start TO lv_end TO lt_output.
      io_response->set_total_number_of_records( lines( lt_data ) ).
      io_response->set_data( lt_output ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
