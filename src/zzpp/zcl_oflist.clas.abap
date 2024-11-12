CLASS zcl_oflist DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_oflist IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    CASE io_request->get_entity_id( ).
      WHEN 'ZCE_OFLIST'.
        DATA: lt_oflist TYPE TABLE OF zce_oflist,
              ls_oflist LIKE LINE OF lt_oflist.
        TRY.
            DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range INTO DATA(cx_erro).
            DATA ls_msg TYPE scx_t100key.
            DATA(lv_msg) = cx_erro->get_text( ).
*          ls_msg = VALUE #( msgid = 'GENERIC_CDE' msgno = '000' attr1 = cx_erro->get_text( ) ).
*          RAISE EXCEPTION TYPE cx_rap_query_provider
*            EXPORTING
*             textid = ls_msg.

        ENDTRY.
        LOOP AT lt_ranges INTO DATA(ls_ranges).
          CASE ls_ranges-name.
            WHEN 'PLANT'.
              DATA(r_plant) = ls_ranges-range.
            WHEN 'REQUIREMENTPLAN'.
              DATA(r_requirementplan) = ls_ranges-range.
            WHEN 'PRODUCT'.
              DATA(r_product) = ls_ranges-range.
            WHEN 'PLNDINDEPRQMTVERSION'.
              DATA(r_plndindeprqmtversion) = ls_ranges-range.
            WHEN 'MATERIALBYCUSTOMER'.
              DATA(r_materialbycustomer) = ls_ranges-range.
            WHEN 'INTERVALDAYS'.
              DATA(r_intervaldays) = ls_ranges-range.
            WHEN 'PLNDINDEPRQMTISACTIVE'.
              DATA(r_plndindeprqmtisactive) = ls_ranges-range.
            WHEN 'REQUIREMENTDATE'.
              DATA(r_requirementdate) = ls_ranges-range.
          ENDCASE.
        ENDLOOP.

        SELECT
          root~product,
          root~plant,
          root~mrparea,
          root~plndindeprqmttype,
          root~plndindeprqmtversion,
          root~requirementplan,
          root~requirementsegment,
          root~plndindeprqmtperiod,
          root~periodtype,
          cust_mat2~materialbycustomer,
          root~workingdaydate AS requirementdate,
          pir_bik~plndindeprqmtisactive,
          root~plannedquantity,
          root~unitofmeasure,
          root~lastchangedbyuser,
          root~lastchangedate,
          product_text~productdescription,
          product_plant~profitcenter
        FROM i_plndindeprqmtitemtp WITH PRIVILEGED ACCESS AS root
        LEFT OUTER JOIN i_plndindeprqmtbyintkey WITH PRIVILEGED ACCESS AS pir_bik
          ON root~plndindeprqmtinternalid = pir_bik~plndindeprqmtinternalid
        LEFT OUTER JOIN i_customermaterial_2 WITH PRIVILEGED ACCESS  AS cust_mat2
          ON root~product = cust_mat2~product
        LEFT OUTER JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS product_plant
          ON root~product = product_plant~product
          AND root~plant = product_plant~plant
        LEFT OUTER JOIN i_productdescription WITH PRIVILEGED ACCESS AS product_text
          ON root~product = product_text~product
          AND product_text~language = @sy-langu
        WHERE root~plant IN @r_plant
          AND root~requirementplan IN @r_requirementplan
          AND root~product IN @r_product
          AND root~plndindeprqmtversion IN @r_plndindeprqmtversion
          AND root~workingdaydate IN @r_requirementdate
          AND cust_mat2~materialbycustomer IN @r_materialbycustomer
          AND pir_bik~plndindeprqmtisactive IN @r_plndindeprqmtisactive
        INTO TABLE @DATA(lt_pir_item).

        DATA(lt_pir_key) = lt_pir_item.
        LOOP AT lt_pir_key ASSIGNING FIELD-SYMBOL(<fs_pir_key>).
          <fs_pir_key>-requirementplan = |{ <fs_pir_key>-requirementplan ALPHA = IN }|.
        ENDLOOP.

        "获取备注
        IF lt_pir_item IS NOT INITIAL.
          SELECT
            material,
            plant,
            customer,
            requirement_date,
            remark,
            created_at
          FROM ztpp_1012 WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_pir_key
          WHERE material = @lt_pir_key-product
            AND plant = @lt_pir_key-plant
            AND customer = @lt_pir_key-requirementplan
            AND requirement_date = @lt_pir_key-requirementdate
          INTO TABLE @DATA(lt_pp1012).
          SORT lt_pp1012 BY material plant customer requirement_date created_at DESCENDING.
          DELETE ADJACENT DUPLICATES FROM lt_pp1012 COMPARING material plant customer requirement_date.
        ENDIF.

        SELECT
*          mfg_confirm~MfgOrderConfirmationGroup,
*          mfg_confirm~MfgOrderConfirmation,
          mfg~material,
          mfg~productionplant,
          MAX( mfg_confirm~mfgorderconfirmationentrydate ) AS mfgorderconfirmationentrydate
        FROM i_mfgorderconfirmation WITH PRIVILEGED ACCESS AS mfg_confirm
        LEFT OUTER JOIN i_manufacturingorder WITH PRIVILEGED ACCESS AS mfg
        ON mfg_confirm~manufacturingorder = mfg~manufacturingorder
        GROUP BY material, productionplant
        INTO TABLE @DATA(lt_mfg_confirm).

        "获取要求的间隔天数
        DATA lv_intervaldays TYPE i.
        DATA is_process TYPE abap_boolean.
        READ TABLE r_intervaldays INTO DATA(rs_intervaldays) INDEX 1.
        IF sy-subrc = 0.
          is_process = abap_true.
          lv_intervaldays = rs_intervaldays-low.
        ELSE.
          is_process = abap_false.
        ENDIF.

        SORT lt_mfg_confirm BY material productionplant.
        CLEAR: ls_oflist,lt_oflist.
        LOOP AT lt_pir_item INTO DATA(ls_pir_item).
          MOVE-CORRESPONDING ls_pir_item TO ls_oflist.
          CLEAR ls_oflist-mfgorderconfirmationentrydate.
          "符合要求的才填充【最終生産実績登録日】
          IF ls_pir_item-plndindeprqmtversion = '01' AND is_process = abap_true.
            READ TABLE lt_mfg_confirm INTO DATA(ls_mfg_confirm) WITH KEY material = ls_pir_item-product
              productionplant = ls_pir_item-plant BINARY SEARCH.
            IF sy-subrc = 0.
              "intervaldays 不参与筛选，只是当intervaldays大于0时mfgorderconfirmationentrydate有值
              ls_oflist-intervaldays = ls_pir_item-requirementdate - ls_mfg_confirm-mfgorderconfirmationentrydate.
              IF ls_oflist-intervaldays > lv_intervaldays.
                ls_oflist-mfgorderconfirmationentrydate = ls_mfg_confirm-mfgorderconfirmationentrydate.
              ENDIF.
            ENDIF.
          ENDIF.

          "备注
          DATA(lv_customer) = ls_pir_item-requirementplan.
          lv_customer = |{ lv_customer ALPHA = IN }|.
          READ TABLE lt_pp1012 INTO DATA(ls_pp1012) WITH KEY material = ls_pir_item-product plant = ls_pir_item-plant
            customer = lv_customer requirement_date = ls_pir_item-requirementdate BINARY SEARCH.
          IF sy-subrc = 0.
            ls_oflist-remark = ls_pp1012-remark.
          ENDIF.
          APPEND ls_oflist TO lt_oflist.
          CLEAR ls_oflist.
        ENDLOOP.

        SORT lt_oflist BY product plant mrparea plndindeprqmttype plndindeprqmtversion requirementplan
          requirementsegment plndindeprqmtperiod periodtype requirementdate.

        "过滤
        zzcl_odata_utils=>filtering(
                            EXPORTING
                              io_filter = io_request->get_filter( )
                              it_excluded = VALUE #( ( fieldname = 'INTERVALDAYS' ) )
                            CHANGING
                              ct_data = lt_oflist ).
        "排序
        zzcl_odata_utils=>orderby(
                            EXPORTING
                              it_order = io_request->get_sort_elements( )
                            CHANGING
                              ct_data = lt_oflist ).

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lines( lt_oflist ) ).
        ENDIF.
        IF io_request->is_data_requested( ).
          zzcl_odata_utils=>paging(
            EXPORTING
              io_paging = io_request->get_paging( )
            CHANGING
              ct_data = lt_oflist
          ).
          io_response->set_data( lt_oflist ).
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.