CLASS zcl_ledplannedordercomponent DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_LEDPLANNEDORDERCOMPONENT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA:
      lt_data                    TYPE STANDARD TABLE OF zr_ledplannedordercomponent,
      ls_data                    TYPE zr_ledplannedordercomponent,
      lr_material                TYPE RANGE OF matnr,
      lr_mrpcontroller           TYPE RANGE OF dispo,
      lr_productionsupervisor    TYPE RANGE OF zr_ledplannedordercomponent-productionsupervisor,
      lr_matlcomprequirementdate TYPE RANGE OF zr_ledplannedordercomponent-matlcomprequirementdate,
      lr_plannedorder            TYPE RANGE OF zr_ledplannedordercomponent-plannedorder,
      lr_plant                   TYPE RANGE OF werks_d,
      ls_material                LIKE LINE OF lr_material,
      ls_mrpcontroller           LIKE LINE OF lr_mrpcontroller,
      ls_productionsupervisor    LIKE LINE OF lr_productionsupervisor,
      ls_matlcomprequirementdate LIKE LINE OF lr_matlcomprequirementdate,
      ls_plannedorder            LIKE LINE OF lr_plannedorder,
      ls_plant                   LIKE LINE OF lr_plant.

    CONSTANTS:
      lc_zid(6)        TYPE c VALUE 'ZPP014',
      lc_strategy_2(1) TYPE c VALUE '2',
      lc_msgid         TYPE string VALUE 'ZPP_001',
      lc_msgty         TYPE string VALUE 'E',
      lc_alpha_in      TYPE string VALUE 'IN'.

    IF io_request->is_data_requested( ).
      TRY.
          "Get and add filter
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
      ENDTRY.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
          CASE ls_filter_cond-name.
*           プラント
            WHEN 'PLANT'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_plant.
              APPEND ls_plant TO lr_plant.
              CLEAR ls_plant.
*           MRP 管理者
            WHEN 'MRPCONTROLLER'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_mrpcontroller.
              APPEND ls_mrpcontroller TO lr_mrpcontroller.
              CLEAR ls_mrpcontroller.
*           製造責任者
            WHEN 'PRODUCTIONSUPERVISOR'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_productionsupervisor.
              APPEND ls_productionsupervisor TO lr_productionsupervisor.
              CLEAR ls_productionsupervisor.
*           品目コード
            WHEN 'MATERIAL'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_material.
*              lv_material = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = str_rec_l_range-low ).
              ls_material-low  = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_material-low ).
              ls_material-high = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_material-high ).
              APPEND ls_material TO lr_material.
              CLEAR ls_material.
*           所要日付
            WHEN 'MATLCOMPREQUIREMENTDATE'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_matlcomprequirementdate.
              APPEND ls_matlcomprequirementdate TO lr_matlcomprequirementdate.
              CLEAR ls_matlcomprequirementdate.
*           計画手配
            WHEN 'PLANNEDORDER'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_plannedorder.
              APPEND ls_plannedorder TO lr_plannedorder.
              CLEAR ls_plannedorder.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      ENDLOOP.

*     計画手配取得
      SELECT b~plannedorder,                                            "計画手配
             b~plant,                                                   "プラント
             b~assembly,                                                "組立品目
             a~plannedtotalqtyinbaseunit,                               "計画数量
             b~matlcomprequirementdate,                                 "所要日付
             b~billofmaterialitemnumber_2 AS billofmaterialitemnumber,  "BOM明細番号
             b~material,                                                "構成品目
             b~usageprobabilitypercent,                                 "使用頻度
             b~alternativeitemgroup,                                    "代替明細グループ
             b~alternativeitemstrategy,                                 "方針
             b~alternativeitempriority,                                 "優先度
             b~requiredquantity,                                        "所要量
             b~confirmedavailablequantity,                              "利用可能数量
             b~mrpcontroller,                                           "MRP管理者
             b~productionsupervisor,                                    "製造責任者
             b~reservation,
             b~reservationitem,
             b~materialcomponentismissing,
             ' ' AS commitfail,
             ' ' AS status,
             CAST( ' ' AS CHAR( 50 ) ) AS message
        FROM i_plannedorder WITH PRIVILEGED ACCESS AS a
       INNER JOIN i_plannedordercomponent WITH PRIVILEGED ACCESS AS b
          ON b~plannedorder = a~plannedorder
         AND b~materialcompisalternativeitem = 'X'
*         AND b~materialcompisalternativeitem = @space
       WHERE a~productionplant IN @lr_plant
         AND a~mrpcontroller IN @lr_mrpcontroller
         AND a~productionsupervisor IN @lr_productionsupervisor
         AND a~plannedorderopeningdate IN @lr_matlcomprequirementdate
         AND a~product IN @lr_material
         AND a~plannedorder IN @lr_plannedorder
         AND a~productavailabilitychecktype <> @space
*         AND a~productavailabilitychecktype = @space
        INTO TABLE @DATA(lt_basicinfo).

*     副代替グループ取得
      SELECT zvalue1,
             zvalue2
        FROM ztbc_1001
       WHERE zid = @lc_zid
        INTO TABLE @DATA(lt_ztbc_1001).

      SORT lt_ztbc_1001 BY zvalue1 ASCENDING.

      LOOP AT lt_basicinfo ASSIGNING FIELD-SYMBOL(<fs_l_group>)
        GROUP BY ( plannedorder = <fs_l_group>-plannedorder ).

        LOOP AT GROUP <fs_l_group> ASSIGNING FIELD-SYMBOL(<fs_l_basicinfo>).
*         主代替グループの優先度を取得する
          IF <fs_l_basicinfo>-alternativeitemstrategy = lc_strategy_2.
*            IF <fs_l_basicinfo>-plannedtotalqtyinbaseunit <> <fs_l_basicinfo>-confirmedavailablequantity.
            IF <fs_l_basicinfo>-materialcomponentismissing IS NOT INITIAL.
              <fs_l_basicinfo>-commitfail = abap_true.
              <fs_l_basicinfo>-status = '1'.

              "不足品目がある。
              MESSAGE e101(zpp_001) INTO <fs_l_basicinfo>-message.

              MODIFY lt_basicinfo FROM <fs_l_basicinfo> TRANSPORTING commitfail status WHERE plannedorder = <fs_l_basicinfo>-plannedorder.

            ELSEIF <fs_l_basicinfo>-requiredquantity IS NOT INITIAL.
              DATA(ls_tmp) = <fs_l_basicinfo>.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF <fs_l_group>-commitfail IS INITIAL.
*         副代替グループ取得
          READ TABLE lt_ztbc_1001 INTO DATA(ls_ztbc_1001) WITH KEY zvalue1 = ls_tmp-alternativeitemgroup BINARY SEARCH.
          IF sy-subrc = 0.
*            ls_tmp-usageprobabilitypercent = 0.
            ls_tmp-requiredquantity = 0.
            ls_tmp-usageprobabilitypercent = 0.

            MODIFY lt_basicinfo FROM ls_tmp TRANSPORTING requiredquantity usageprobabilitypercent WHERE plannedorder = ls_tmp-plannedorder
                                                                                                    AND alternativeitemgroup = ls_ztbc_1001-zvalue2
                                                                                                    AND alternativeitempriority <> ls_tmp-alternativeitempriority.
          ENDIF.
        ENDIF.
        CLEAR ls_tmp.
      ENDLOOP.
      SORT lt_basicinfo BY plannedorder    ASCENDING
                           reservation     ASCENDING
                           reservationitem ASCENDING.

      MOVE-CORRESPONDING lt_basicinfo TO lt_data.

      io_response->set_total_number_of_records( lines( lt_data ) ).

      "Sort
      IF io_request->get_sort_elements( ) IS NOT INITIAL.
        zzcl_odata_utils=>orderby(
          EXPORTING
            it_order = io_request->get_sort_elements( )
          CHANGING
            ct_data  = lt_data ).
      ENDIF.

      "Page
      zzcl_odata_utils=>paging(
        EXPORTING
          io_paging = io_request->get_paging( )
        CHANGING
          ct_data   = lt_data ).

      io_response->set_data( lt_data ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
