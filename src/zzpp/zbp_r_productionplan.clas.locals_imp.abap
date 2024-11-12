CLASS lhc_zr_productionplan DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:
      lt_request_t  TYPE TABLE OF zr_productionplan,
      lts_request_t TYPE zr_productionplan,

      BEGIN OF ts_mrp_api,  "api structue
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
        baseunit                   TYPE c LENGTH 3,
      END OF ts_mrp_api,
*      tt_mrp_api TYPE STANDARD TABLE OF ts_mrp_api WITH DEFAULT KEY,
*
*      BEGIN OF ts_mrp_d,
*        __count TYPE string,
*        results TYPE tt_mrp_api,
*      END OF ts_mrp_d,
*
      BEGIN OF ts_message,
        message TYPE string,
      END OF ts_message,

      BEGIN OF ts_error,
        code    TYPE string,
        message TYPE string,
      END OF ts_error,
*
*      BEGIN OF ts_res_mrp_api,
*        d     TYPE ts_mrp_d,
*        error TYPE ts_error,
*      END OF ts_res_mrp_api,

      BEGIN OF ts_plan,
        plannedorder              TYPE i_plannedorder-plannedorder,
        plannedordertype          TYPE i_plannedorder-plannedordertype,
        material                  TYPE matnr,
        mrpplant                  TYPE werks_d,
        productionversion         TYPE verid,
        plndorderplannedstartdate TYPE i_plannedorder-plndorderplannedstartdate,
        plannedtotalqtyinbaseunit TYPE i_plannedorder-plannedtotalqtyinbaseunit,
        plndordercommittedqty     TYPE i_plannedorder-plndordercommittedqty,
      END OF ts_plan,

      BEGIN OF ts_planorder_i,
        _planned_order                 TYPE c LENGTH 10,
        _planned_order_profile         TYPE c LENGTH 4,
        _material                      TYPE c LENGTH 18,
        _production_plant              TYPE c LENGTH 4,
        _m_r_p_area                    TYPE c LENGTH 10,
        _production_version            TYPE c LENGTH 4,
        _material_procurement_category TYPE c LENGTH 1,
        _base_unit                     TYPE c LENGTH 3,
        _total_quantity                TYPE c LENGTH 16,
        _plnd_order_planned_start_date TYPE string,
        _plnd_order_planned_end_date   TYPE string,
        _planned_order_is_firm         TYPE abap_bool,
      END OF ts_planorder_i,

      BEGIN OF ts_planorder_d,
        planorder TYPE string,
      END OF ts_planorder_d,

      BEGIN OF ts_res_plan_api,
        d     TYPE ts_planorder_d,
        error TYPE ts_error,
      END OF ts_res_plan_api,

      BEGIN OF ts_pir_item,
        product                 TYPE i_plndindeprqmtitemtp-product,
        plant                   TYPE i_plndindeprqmtitemtp-plant,
        plnd_indep_rqmt_version TYPE i_plndindeprqmtitemtp-plndindeprqmtversion,
        requirement_plan        TYPE i_plndindeprqmtitemtp-requirementplan,
        plnd_indep_rqmt_period  TYPE i_plndindeprqmtitemtp-plndindeprqmtperiod,
        period_type             TYPE i_plndindeprqmtitemtp-periodtype,
        working_day_date        TYPE string,
        planned_quantity        TYPE string,
      END OF ts_pir_item,

      BEGIN OF ts_pir_header,
        product                   TYPE i_plndindeprqmttp-product,
        plant                     TYPE i_plndindeprqmttp-plant,
        plnd_indep_rqmt_version   TYPE i_plndindeprqmttp-plndindeprqmtversion,
        requirement_plan          TYPE i_plndindeprqmttp-requirementplan,
        plnd_indep_rqmt_is_active TYPE i_plndindeprqmttp-plndindeprqmtisactive,
        to_plnd_indep_rqmt_item   TYPE TABLE OF ts_pir_item WITH DEFAULT KEY,
      END OF ts_pir_header,

      BEGIN OF ts_authcheck,
        check TYPE string,
      END OF ts_authcheck,

      cs_zday TYPE c LENGTH 20.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_productionplan RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zr_productionplan.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zr_productionplan.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zr_productionplan.

    METHODS read FOR READ
      IMPORTING keys FOR READ zr_productionplan RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zr_productionplan.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION zr_productionplan~processlogic RESULT result.

    METHODS post CHANGING ct_data        TYPE lt_request_t
                          ct_data_return TYPE lt_request_t
                          cv_day         TYPE cs_zday.

    METHODS update_planorder CHANGING cs_planorder TYPE ts_plan
                                      cs_data      TYPE lts_request_t
                                      cv_qty       TYPE menge_d.
    METHODS delete_planorder CHANGING cs_planorder TYPE ts_plan
                                      cs_data      TYPE lts_request_t.

    METHODS create_planorder CHANGING cs_planorder TYPE ts_plan
                                      cs_data      TYPE lts_request_t
                                      cv_qty       TYPE menge_d
                                      cv_day       TYPE d.

    METHODS create_pir CHANGING cs_data TYPE lts_request_t
                                cv_qty  TYPE menge_d
                                cv_day  TYPE d.
ENDCLASS.

CLASS lhc_zr_productionplan IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD processlogic.
    DATA:
      lt_request        TYPE TABLE OF zr_productionplan,
      lt_request_return TYPE TABLE OF zr_productionplan,
      ls_request        TYPE zr_productionplan,
      lt_authcheck      TYPE TABLE OF ts_authcheck,
      ls_authcheck      TYPE ts_authcheck.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.
    DATA(lv_zday) = keys[ 1 ]-%param-zdays.

    LOOP AT keys INTO DATA(key).
      CLEAR ls_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                           pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                 CHANGING  data = lt_request ).
      CASE lv_event.
        WHEN 'POST'.
          post( CHANGING ct_data = lt_request
                         ct_data_return = lt_request_return
                         cv_day = lv_zday ).

          DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request_return ).

          APPEND VALUE #( %cid   = key-%cid
                          %param = VALUE #( event = lv_event
                                            zzkey = lv_json ) ) TO result.
        WHEN 'EDIT'.

          ls_authcheck-check = 'X'.
          APPEND ls_authcheck TO lt_authcheck.
          lv_json = /ui2/cl_json=>serialize( data = ls_authcheck-check ).

          APPEND VALUE #( %cid   = key-%cid
                          %param = VALUE #( event = lv_event
                                            zzkey = lv_json ) ) TO result.
        WHEN OTHERS.

      ENDCASE.


    ENDLOOP.
  ENDMETHOD.

  METHOD post.
    DATA:
      lt_para      TYPE TABLE FOR FUNCTION IMPORT i_supplydemanditemtp~getitem,
      ls_para      TYPE STRUCTURE FOR FUNCTION IMPORT i_supplydemanditemtp~getitem,
      lt_mrp_api   TYPE STANDARD TABLE OF ts_mrp_api,
      ls_mrp_api   TYPE ts_mrp_api,
      lt_confirm   TYPE STANDARD TABLE OF ts_plan,
      ls_confirm   TYPE ts_plan,
      lt_unconfirm TYPE STANDARD TABLE OF ts_plan,
      ls_unconfirm TYPE ts_plan,
      lr_plnum     TYPE RANGE OF i_plannedorder-plannedorder,
      lrs_plnum    LIKE LINE OF lr_plnum,
      dy_line      TYPE REF TO data.

    DATA:

      lv_dayc  TYPE c LENGTH 30,
      lv_dayi  TYPE c LENGTH 30,
      lv_day   TYPE d,
      lv_vdate TYPE d,
      lv_index TYPE n LENGTH 3,
      lv_first TYPE c LENGTH 1,
      lv_diff  TYPE menge_d,
      lv_qty   TYPE menge_d.

    FIELD-SYMBOLS:
      <l_field>   TYPE any,
      <l_field2>  TYPE any,
      <l_field3>  TYPE any,
      <ls_data_w> TYPE zr_productionplan.
    CREATE DATA dy_line LIKE LINE OF ct_data.
    ASSIGN dy_line->* TO <ls_data_w>.
    DATA(lv_datum) = cl_abap_context_info=>get_system_date( ).
    lv_day = lv_datum - 1.
    lv_vdate = lv_day + cv_day.
    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data>).
      CASE <ls_data>-project.
        WHEN '計画手配'.   "計画手配(同时修改W行)
          READ ENTITIES OF i_supplydemanditemtp PRIVILEGED
            ENTITY supplydemanditem
            EXECUTE getitem
            FROM VALUE #( ( %param-material = <ls_data>-idnrk
                            %param-mrparea = <ls_data>-plant
                            %param-mrpplant = <ls_data>-plant ) )
            RESULT DATA(lt_sdi_result)
            FAILED DATA(lt_sdi_failed)
            REPORTED DATA(lt_sdi_reported).

          LOOP AT lt_sdi_result INTO DATA(ls_item).
            IF ls_item-%param-mrpelementcategory = 'PA'
           AND ls_item-%param-mrpelementdocumenttype = 'LA'.
              ls_mrp_api-material = ls_item-%param-material.
              ls_mrp_api-mrpplant = ls_item-%param-mrpplant.
              ls_mrp_api-mrpelementopenquantity = ls_item-%param-mrpelementopenquantity.
              ls_mrp_api-mrpavailablequantity = ls_item-%param-mrpavailablequantity.
              ls_mrp_api-mrpelement = ls_item-%param-mrpelement.
              ls_mrp_api-mrpelementavailyorrqmtdate = ls_item-%param-mrpelementavailyorrqmtdate.
              ls_mrp_api-mrpelementcategory = ls_item-%param-mrpelementcategory.
              ls_mrp_api-mrpelementdocumenttype = ls_item-%param-mrpelementdocumenttype.
              ls_mrp_api-productionversion = ls_item-%param-productionversion.
              ls_mrp_api-sourcemrpelement = ls_item-%param-sourcemrpelement_2.
              ls_mrp_api-baseunit = ls_item-%param-MaterialBaseUnit.
              APPEND ls_mrp_api TO lt_mrp_api.
              CLEAR: ls_mrp_api.
            ENDIF.
          ENDLOOP.
*          mrp_api( CHANGING cs_data = <ls_data>
*                            ct_mrp_api = lt_mrp_api ).
* 取目前的数据
          LOOP AT lt_mrp_api INTO ls_mrp_api.
            lrs_plnum-sign = 'I'.
            lrs_plnum-option = 'EQ'.
            lrs_plnum-low = ls_mrp_api-mrpelement.
            APPEND lrs_plnum TO lr_plnum.
            CLEAR: lrs_plnum.
          ENDLOOP.

          IF lr_plnum IS NOT INITIAL.
            SELECT plannedorder,
                   plannedordertype,
                   material,
                   mrpplant,
                   productionversion,
                   plndorderplannedstartdate,
                   plannedtotalqtyinbaseunit,
                   plndordercommittedqty
              FROM i_plannedorder WITH PRIVILEGED ACCESS
             WHERE plannedorder IN @lr_plnum
               AND plannedorderisfirm = 'X'
              INTO TABLE @DATA(lt_confirmedplan).

            SELECT plannedorder,
                   plannedordertype,
                   material,
                   mrpplant,
                   productionversion,
                   plndorderplannedstartdate,
                   plannedtotalqtyinbaseunit,
                   plndordercommittedqty
              FROM i_plannedorder WITH PRIVILEGED ACCESS
             WHERE plannedorder IN @lr_plnum
               AND plannedorderisfirm = @space
              INTO TABLE @DATA(lt_unconfirmplan).
          ENDIF.
          " Sum qty by startdate
          LOOP AT lt_confirmedplan INTO DATA(ls_tmp)
                                   GROUP BY ( productionversion = ls_tmp-productionversion
                                              plndorderplannedstartdate = ls_tmp-plndorderplannedstartdate )
                                   REFERENCE INTO DATA(confirm_member).
            LOOP AT GROUP confirm_member ASSIGNING FIELD-SYMBOL(<lfs_member>).
              ls_confirm-plannedtotalqtyinbaseunit = ls_confirm-plannedtotalqtyinbaseunit
                                                   + <lfs_member>-plannedtotalqtyinbaseunit.

            ENDLOOP.
            ls_confirm-material = <lfs_member>-material.
            ls_confirm-mrpplant = <lfs_member>-mrpplant.
            ls_confirm-productionversion = <lfs_member>-productionversion.
            ls_confirm-plndorderplannedstartdate = <lfs_member>-plndorderplannedstartdate.
            APPEND ls_confirm TO lt_confirm.
            CLEAR: ls_confirm.
          ENDLOOP.

          LOOP AT lt_unconfirmplan INTO ls_tmp
                                   GROUP BY ( plndorderplannedstartdate = ls_tmp-plndorderplannedstartdate )
                                   REFERENCE INTO DATA(unconfirm_member).
            LOOP AT GROUP unconfirm_member ASSIGNING FIELD-SYMBOL(<lfs_unmember>).
              ls_unconfirm-plannedtotalqtyinbaseunit = ls_unconfirm-plannedtotalqtyinbaseunit
                                                     + <lfs_unmember>-plannedtotalqtyinbaseunit.
              ls_unconfirm-plndordercommittedqty = ls_unconfirm-plndordercommittedqty
                                                 + <lfs_unmember>-plndordercommittedqty.
            ENDLOOP.
            ls_unconfirm-material = <lfs_unmember>-material.
            ls_unconfirm-mrpplant = <lfs_unmember>-mrpplant.
            ls_unconfirm-plndorderplannedstartdate = <lfs_unmember>-plndorderplannedstartdate.
            APPEND ls_unconfirm TO lt_unconfirm.
            CLEAR: ls_unconfirm.
          ENDLOOP.
          "新编辑一行W，重现画面上的W行

          READ TABLE ct_data INTO <ls_data_w>
               WITH KEY project = '未処分'.
*          LOOP AT lt_unconfirm INTO ls_unconfirm WHERE plndorderplannedstartdate < lv_vdate.
*            IF ls_unconfirm-plndorderplannedstartdate < lv_datum.
*              ls_unconfirm-plndorderplannedstartdate = lv_datum.
*            ENDIF.
*            lv_index = ls_unconfirm-plndorderplannedstartdate - lv_day.
*            CONCATENATE 'D' lv_index INTO lv_dayc.
*            ASSIGN COMPONENT lv_dayc OF STRUCTURE <ls_data_w> TO <l_field>.
*            <l_field> = ls_unconfirm-plannedtotalqtyinbaseunit.
*            "Summary
*            <l_field2> = <l_field2> + ls_unconfirm-plannedtotalqtyinbaseunit.
*          ENDLOOP.
*          <ls_data_w>-plant = <ls_data>-plant.
*          <ls_data_w>-mrpresponsible = <ls_data>-mrpresponsible.
*          <ls_data_w>-idnrk = <ls_data>-idnrk.
*          <ls_data_w>-stufe = <ls_data>-stufe.
*          <ls_data_w>-verid = <ls_data>-verid.
*          <ls_data_w>-mdv01 = <ls_data>-mdv01.
*          <ls_data_w>-plantype = 'W'.
*          <ls_data_w>-project = '未処分'.
*          <ls_data_w>-summary = <l_field2>.

          SORT lt_confirmedplan BY plndorderplannedstartdate plannedorder.
          SORT lt_unconfirmplan BY plndorderplannedstartdate plannedorder.

          CLEAR: lv_index.
          DO cv_day TIMES.
            lv_day = lv_day + 1.
            lv_dayc = lv_day.
            CONCATENATE 'D' lv_dayc INTO lv_dayc.
            CONDENSE lv_dayc.

            lv_index = lv_index + 1.
            CONCATENATE 'D' lv_index INTO lv_dayi.
            CONDENSE lv_dayi.
            ASSIGN COMPONENT lv_dayi OF STRUCTURE <ls_data> TO <l_field>.
            READ TABLE lt_confirm INTO ls_confirm
                 WITH KEY plndorderplannedstartdate = lv_day.
            IF sy-subrc = 0.
              "確定計画手配の処理: if field changed
              IF <l_field> IS NOT INITIAL        "修改的数据
             AND <l_field> <> ls_confirm-plannedtotalqtyinbaseunit.  "原始数据
                "把数量修改到第一张planorder，同时删除当天其他planorder
                lv_first = 'X'.
                LOOP AT lt_confirmedplan INTO DATA(ls_confirmedplan)
                        WHERE plndorderplannedstartdate = lv_day.
                  IF lv_first = 'X'.
                    lv_qty = <l_field>.
                    update_planorder( CHANGING cs_planorder = ls_confirmedplan
                                               cs_data = <ls_data>
                                               cv_qty = lv_qty ).
                    CLEAR: lv_first.
                  ELSE.
                    delete_planorder( CHANGING cs_planorder = ls_confirmedplan
                                               cs_data = <ls_data> ).
                  ENDIF.
                ENDLOOP.

                "P处理完，同时未処分計画手配の処理
                READ TABLE lt_unconfirm INTO ls_unconfirm
                     WITH KEY plndorderplannedstartdate = lv_day.
                IF sy-subrc = 0.
                  <l_field2> = <l_field>.
                  lv_diff = <l_field> - ls_confirm-plannedtotalqtyinbaseunit.
                  IF lv_diff >= 0.
                    LOOP AT lt_unconfirmplan INTO DATA(ls_unconfirmplan).
                      IF ls_unconfirmplan-plannedtotalqtyinbaseunit <= <l_field2>.
                        delete_planorder( CHANGING cs_planorder = ls_unconfirmplan
                                                   cs_data = <ls_data_w> ).
                        <l_field2> = <l_field2> - ls_unconfirmplan-plannedtotalqtyinbaseunit.
                      ELSE.
                        <l_field2> = ls_unconfirmplan-plannedtotalqtyinbaseunit - <l_field2>.
                        lv_qty = <l_field2>.
                        update_planorder( CHANGING cs_planorder = ls_unconfirmplan
                                                 cs_data = <ls_data_w>
                                                 cv_qty = lv_qty ).
                      ENDIF.
                      IF <l_field2> = 0.
                        EXIT.
                      ENDIF.
                    ENDLOOP.
                    ASSIGN COMPONENT lv_dayi OF STRUCTURE <ls_data_w> TO <l_field3>.
                    <l_field3> = ls_unconfirm-plannedtotalqtyinbaseunit - lv_diff.
                  ELSE.
                    LOOP AT lt_unconfirmplan INTO ls_unconfirmplan.
                      <l_field2> = ls_unconfirmplan-plannedtotalqtyinbaseunit - lv_diff.
                      lv_qty = <l_field2>.
                      update_planorder( CHANGING cs_planorder = ls_unconfirmplan
                                                 cs_data = <ls_data_w>
                                                 cv_qty = lv_qty ).
                    ENDLOOP.
                    ASSIGN COMPONENT lv_dayi OF STRUCTURE <ls_data_w> TO <l_field3>.
                    <l_field3> = ls_unconfirm-plannedtotalqtyinbaseunit - lv_diff.
                  ENDIF.
                ELSE.
                  <l_field2> = <l_field>.
                  lv_qty = <l_field2>.
                  create_planorder( CHANGING cs_planorder = ls_unconfirmplan
                                         cs_data = <ls_data_w>
                                         cv_qty = lv_qty
                                         cv_day = lv_day ).
                  ASSIGN COMPONENT lv_dayi OF STRUCTURE <ls_data_w> TO <l_field3>.
                  <l_field3> = ls_unconfirm-plannedtotalqtyinbaseunit + <l_field>.
                ENDIF.

              ENDIF.
            ELSE.
              "確定計画手配の処理: if zero before,Create plan order
              IF <l_field> <> 0.
                lv_qty = <l_field>.
                ls_confirmedplan-material = <ls_data>-idnrk.
                ls_confirmedplan-mrpplant = <ls_data>-plant.
                ls_confirmedplan-productionversion = <ls_data>-verid.
                create_planorder( CHANGING cs_planorder = ls_confirmedplan
                                           cs_data = <ls_data>
                                           cv_qty = lv_qty
                                           cv_day = lv_day ).
              ENDIF.
            ENDIF.

          ENDDO.
          APPEND <ls_data> TO ct_data_return.
          APPEND <ls_data_w> TO ct_data_return.

        WHEN 'I'.
          DO cv_day TIMES.
            lv_day = lv_day + 1.
            lv_dayc = lv_day.
            CONCATENATE 'D' lv_dayc INTO lv_dayc.
            CONDENSE lv_dayc.

            lv_index = lv_index + 1.
            CONCATENATE 'D' lv_index INTO lv_dayi.
            CONDENSE lv_dayi.
            ASSIGN COMPONENT lv_dayi OF STRUCTURE <ls_data> TO <l_field>.
            create_pir( CHANGING cs_data = <ls_data>
                                 cv_qty = <l_field>
                                 cv_day = lv_day ).
          ENDDO.
          APPEND <ls_data> TO ct_data_return.
      ENDCASE.

    ENDLOOP.
  ENDMETHOD.



  METHOD update_planorder.
    DATA:
      lv_msg     TYPE string,
      lv_message TYPE string,
      lv_firm    TYPE c.

    IF cs_data-plantype = 'P'.
      lv_firm = 'X'.
    ENDIF.
    MODIFY ENTITIES OF i_plannedordertp PRIVILEGED
      ENTITY plannedorder
      UPDATE FIELDS (  totalquantity plannedorderisfirm )
           WITH VALUE #( (
           plannedorder  = cs_planorder-plannedorder
           totalquantity = cv_qty
           plannedorderisfirm = lv_firm
           %control-totalquantity = cl_abap_behv=>flag_changed
           %control-plannedorderisfirm = cl_abap_behv=>flag_changed ) )
      FAILED DATA(ls_update_failed)
      REPORTED DATA(ls_update_reported).

    IF sy-subrc = 0
   AND ls_update_failed IS INITIAL.
      IF cs_data-message IS INITIAL.
        cs_data-message = cs_planorder-plannedorder && ` update`.
      ELSE.
        cs_data-message = cs_data-message && ';' && cs_planorder-plannedorder && ` update`.
      ENDIF.

    ELSE.
      LOOP AT ls_update_reported-plannedorder INTO DATA(ls_order).
        DATA(lv_msgty) = ls_order-%msg->if_t100_dyn_msg~msgty.
        IF lv_msgty = 'A'
        OR lv_msgty = 'E'.
          lv_msg = ls_order-%msg->if_message~get_text( ).
          lv_message = zzcl_common_utils=>merge_message(
                             iv_message1 = lv_message
                             iv_message2 = lv_msg
                             iv_symbol = ';' ).
        ENDIF.
      ENDLOOP.
      IF cs_data-message IS INITIAL.
        cs_data-message = lv_message.
      ELSE.
        cs_data-message = cs_data-message && ';' && lv_message.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD delete_planorder.
    DATA:
      lv_msg     TYPE string,
      lv_message TYPE string.
    MODIFY ENTITIES OF i_plannedordertp PRIVILEGED
      ENTITY plannedorder
      DELETE FROM VALUE #( ( plannedorder = cs_planorder-plannedorder ) )
          MAPPED DATA(ls_delete_mapped)
          FAILED DATA(ls_delete_failed)
          REPORTED DATA(ls_delete_reported).
    IF sy-subrc = 0
   AND ls_delete_failed IS INITIAL.
      IF cs_data-message IS INITIAL.
        cs_data-message = cs_planorder-plannedorder && ` delete`.
      ELSE.
        cs_data-message = cs_data-message && ';' && cs_planorder-plannedorder && ` delete`.
      ENDIF.

    ELSE.
      LOOP AT ls_delete_reported-plannedorder INTO DATA(ls_order).

        DATA(lv_msgty) = ls_order-%msg->if_t100_dyn_msg~msgty.
        IF lv_msgty = 'A'
        OR lv_msgty = 'E'.
          lv_msg = ls_order-%msg->if_message~get_text( ).
          lv_message = zzcl_common_utils=>merge_message(
                             iv_message1 = lv_message
                             iv_message2 = lv_msg
                             iv_symbol = ';' ).
        ENDIF.
      ENDLOOP.
      IF cs_data-message IS INITIAL.
        cs_data-message = lv_message.
      ELSE.
        cs_data-message = cs_data-message && ';' && lv_message.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD create_planorder.
    DATA:
      ls_planorder_i   TYPE ts_planorder_i,
      ls_res_planorder TYPE ts_res_plan_api.


    ls_planorder_i-_material = cs_planorder-material.
    ls_planorder_i-_planned_order_profile = 'LA'.
    ls_planorder_i-_m_r_p_area = cs_planorder-mrpplant.
    ls_planorder_i-_production_plant = cs_planorder-mrpplant.
    ls_planorder_i-_production_version = cs_planorder-productionversion.
    ls_planorder_i-_material_procurement_category = 'E'.
    ls_planorder_i-_base_unit = 'PC'.
    ls_planorder_i-_total_quantity = cv_qty.
    CONDENSE ls_planorder_i-_total_quantity NO-GAPS.
    ls_planorder_i-_plnd_order_planned_start_date = |{ cv_day+0(4) }-{ cv_day+4(2) }-{ cv_day+6(2) }T00:00:00|.
    IF cs_data-project = '計画手配'.
      ls_planorder_i-_planned_order_is_firm = 'X'.
    ELSE.
      ls_planorder_i-_planned_order_is_firm = space.
    ENDIF.

    DATA(lv_reqbody_api) = /ui2/cl_json=>serialize( data = ls_planorder_i
                                                    compress = 'X'
                                                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
    zzcl_common_utils=>request_api_v4( EXPORTING iv_path = |/api_plannedorder/srvd_a2x/sap/plannedorder/0001/PlannedOrderHeader|
                                                 iv_method      = if_web_http_client=>post
                                                 iv_body        = lv_reqbody_api
                                       IMPORTING ev_status_code = DATA(lv_status_code)
                                                 ev_response    = DATA(lv_response) ).
    /ui2/cl_json=>deserialize(
                          EXPORTING json = lv_response
                          CHANGING data = ls_res_planorder ).
    IF lv_status_code = 201. " created
      DATA(lv_planorder) = ls_res_planorder-d-planorder.
      IF cs_data-message IS INITIAL.
        cs_data-message = lv_planorder && ` create`.
      ELSE.
        cs_data-message = cs_data-message && ';' && lv_planorder && ` create`.
      ENDIF.
    ELSE.

      IF cs_data-message IS INITIAL.
        cs_data-message = ls_res_planorder-error-message.
      ELSE.
        cs_data-message = cs_data-message && ';' && ls_res_planorder-error-message.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD create_pir.
    DATA: ls_pir_item TYPE ts_pir_item,
          ls_request  TYPE ts_pir_header,
          ls_error    TYPE zzcl_odata_utils=>gty_error.

    ls_request = VALUE #( product                   = cs_data-idnrk
                          plant                     = cs_data-plant
                          plnd_indep_rqmt_version   = '03'
                          plnd_indep_rqmt_is_active = '' ).
    DATA(lv_datetime) = |{ cv_day+0(4) }-{ cv_day+4(2) }-{ cv_day+6(2) }T00:00:00|.
    ls_pir_item = VALUE #( product                 = cs_data-idnrk
                           plant                   = cs_data-plant
                           plnd_indep_rqmt_version = '03'
                           period_type             = 'D'
                           working_day_date        = lv_datetime
                           planned_quantity        = cv_qty ).
    CONDENSE ls_pir_item-planned_quantity NO-GAPS.
    APPEND ls_pir_item TO ls_request-to_plnd_indep_rqmt_item.
    DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->to_string( ).

    REPLACE ALL OCCURRENCES OF `ToPlndIndepRqmtItem` IN lv_requestbody  WITH `to_PlndIndepRqmtItem`.

    DATA(lv_path) = |/API_PLND_INDEP_RQMT_SRV/PlannedIndepRqmt?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

    zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                 iv_method      = if_web_http_client=>post
                                                 iv_body        = lv_requestbody
                                       IMPORTING ev_status_code = DATA(lv_status_code)
                                                 ev_response    = DATA(lv_response) ).
    IF lv_status_code = 201.
      cs_data-status = 'S'.
      cs_data-message = 'Successful'.
    ELSE.
      /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                 CHANGING  data = ls_error ).
      IF cs_data-message IS INITIAL.
        cs_data-message = ls_error-error-message-value.
      ELSE.
        cs_data-message = cs_data-message && ';' && ls_error-error-message-value.
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_productionplan DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_productionplan IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
