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

      BEGIN OF ts_message,
        message TYPE string,
      END OF ts_message,

      BEGIN OF ts_error,
        code    TYPE string,
        message TYPE string,
      END OF ts_error,

      BEGIN OF ts_plan,
        plannedorder              TYPE i_plannedorder-plannedorder,
        plannedordertype          TYPE i_plannedorder-plannedordertype,
        material                  TYPE matnr,
        mrpplant                  TYPE werks_d,
        productionversion         TYPE verid,
        plndorderplannedstartdate TYPE i_plannedorder-plndorderplannedstartdate,
        plannedtotalqtyinbaseunit TYPE i_plannedorder-plannedtotalqtyinbaseunit,
        plndordercommittedqty     TYPE i_plannedorder-plndordercommittedqty,
        startdate                 TYPE d,
        baseunit                  TYPE meins,
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
        _total_quantity                TYPE menge_d,
        _plnd_order_planned_start_date TYPE string,
        _plnd_order_planned_end_date   TYPE string,
        _planned_order_is_firm         TYPE abap_bool,
      END OF ts_planorder_i,

      BEGIN OF ts_planorder_u,
        _base_unit             TYPE c LENGTH 3,
        _total_quantity        TYPE menge_d,
        _planned_order_is_firm TYPE abap_bool,
      END OF ts_planorder_u,

      BEGIN OF ts_planorder_d,
        plannedorder TYPE string,
      END OF ts_planorder_d,

      BEGIN OF ts_res_plan_api,
        plannedorder TYPE string,
        "d         TYPE ts_planorder_d,
        error        TYPE ts_error,
      END OF ts_res_plan_api,

      BEGIN OF ts_pir_item,
        _product                 TYPE i_plndindeprqmtitemtp-product,
        _plant                   TYPE i_plndindeprqmtitemtp-plant,
        _plnd_indep_rqmt_version TYPE i_plndindeprqmtitemtp-plndindeprqmtversion,
        _plnd_indep_rqmt_period  TYPE i_plndindeprqmtitemtp-plndindeprqmtperiod,
        _period_type             TYPE i_plndindeprqmtitemtp-periodtype,
        _planned_quantity        TYPE string,
        _working_day_date        TYPE string,
      END OF ts_pir_item,

      BEGIN OF ts_pir_header,
        _product                   TYPE i_plndindeprqmttp-product,
        _plant                     TYPE i_plndindeprqmttp-plant,
        _plnd_indep_rqmt_version   TYPE i_plndindeprqmttp-plndindeprqmtversion,
        _plnd_indep_rqmt_is_active TYPE i_plndindeprqmttp-plndindeprqmtisactive,
        to_plnd_indep_rqmt_item    TYPE TABLE OF ts_pir_item WITH DEFAULT KEY,
      END OF ts_pir_header,

      BEGIN OF ts_plnd,
        product              TYPE matnr,
        plant                TYPE werks_d,
        mrparea              TYPE i_plndindeprqmtitemtp-mrparea,
        plndindeprqmttype    TYPE i_plndindeprqmtitemtp-plndindeprqmttype,
        plndindeprqmtversion TYPE i_plndindeprqmtitemtp-plndindeprqmtversion,
        requirementplan      TYPE i_plndindeprqmtitemtp-requirementplan,
        requirementsegment   TYPE i_plndindeprqmtitemtp-requirementsegment,
        plndindeprqmtperiod  TYPE i_plndindeprqmtitemtp-plndindeprqmtperiod,
        periodtype           TYPE i_plndindeprqmtitemtp-periodtype,
        workingdaydate       TYPE i_plndindeprqmtitemtp-workingdaydate,
        plannedquantity      TYPE i_plndindeprqmtitemtp-plannedquantity,
      END OF ts_plnd,

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

    METHODS post CHANGING ct_data TYPE lt_request_t
                          cv_day  TYPE cs_zday.

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

    METHODS update_pir CHANGING cs_data TYPE lts_request_t
                                cs_plnd TYPE ts_plnd
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
                         cv_day = lv_zday ).

          DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

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
      lt_para          TYPE TABLE FOR FUNCTION IMPORT i_supplydemanditemtp~getitem,
      ls_para          TYPE STRUCTURE FOR FUNCTION IMPORT i_supplydemanditemtp~getitem,
      lt_mrp_api       TYPE STANDARD TABLE OF ts_mrp_api,
      ls_mrp_api       TYPE ts_mrp_api,
      lt_confirmedplan TYPE STANDARD TABLE OF ts_plan,
      lt_unconfirmplan TYPE STANDARD TABLE OF ts_plan,
      lt_confirm       TYPE STANDARD TABLE OF ts_plan,
      ls_confirm       TYPE ts_plan,
      lt_unconfirm     TYPE STANDARD TABLE OF ts_plan,
      ls_unconfirm     TYPE ts_plan,
      lr_plnum         TYPE RANGE OF i_plannedorder-plannedorder,
      lrs_plnum        LIKE LINE OF lr_plnum,
      dy_line          TYPE REF TO data.

    DATA:

      lv_dayc  TYPE c LENGTH 30,
      lv_dayi  TYPE c LENGTH 30,
      lv_day   TYPE d,
      lv_vdate TYPE d,
      lv_index TYPE n LENGTH 3,
      lv_first TYPE c LENGTH 1,
      lv_diff  TYPE menge_d,
      lv_qty   TYPE menge_d,
      lv_left  TYPE menge_d,
      lv_field TYPE string,
      lv_tabix TYPE i.

    FIELD-SYMBOLS:
      <l_field>   TYPE any,
      <l_field2>  TYPE any,
      <l_field3>  TYPE any,
      <ls_data_w> TYPE zr_productionplan.
    CREATE DATA dy_line LIKE LINE OF ct_data.
    ASSIGN dy_line->* TO <ls_data_w>.

    LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data>).
      DATA(lv_datum) = cl_abap_context_info=>get_system_date( ).
      lv_day = lv_datum - 1.
      lv_vdate = lv_day + cv_day.
      CLEAR: <ls_data>-status, <ls_data>-message.
      CASE <ls_data>-plantype.
        WHEN 'P'.   "計画手配(同时修改W行)
* 未修改前的数据
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
              ls_mrp_api-baseunit = ls_item-%param-materialbaseunit.
              APPEND ls_mrp_api TO lt_mrp_api.
              CLEAR: ls_mrp_api.
            ENDIF.
          ENDLOOP.

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
                   plndordercommittedqty,
                   baseunit
              FROM i_plannedorder WITH PRIVILEGED ACCESS
             WHERE plannedorder IN @lr_plnum
               AND plannedorderisfirm = 'X'
              INTO CORRESPONDING FIELDS OF TABLE @lt_confirmedplan.

            SELECT plannedorder,
                   plannedordertype,
                   material,
                   mrpplant,
                   productionversion,
                   plndorderplannedstartdate,
                   plannedtotalqtyinbaseunit,
                   plndordercommittedqty,
                   baseunit
              FROM i_plannedorder WITH PRIVILEGED ACCESS
             WHERE plannedorder IN @lr_plnum
               AND plannedorderisfirm = @space
              INTO CORRESPONDING FIELDS OF TABLE @lt_unconfirmplan.
          ENDIF.
          " 将开始日<当天的都修改为当天，否则比较第一天的数据会错乱
          LOOP AT lt_confirmedplan ASSIGNING FIELD-SYMBOL(<lfs_tmp>).
            IF <lfs_tmp>-plndorderplannedstartdate < lv_datum.
              <lfs_tmp>-startdate = lv_datum.
            ELSE.
              <lfs_tmp>-startdate = <lfs_tmp>-plndorderplannedstartdate.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_confirmedplan INTO DATA(ls_tmp)
                                   GROUP BY ( productionversion = ls_tmp-productionversion
                                              startdate = ls_tmp-startdate )
                                   REFERENCE INTO DATA(confirm_member).
            LOOP AT GROUP confirm_member ASSIGNING FIELD-SYMBOL(<lfs_member>).
              ls_confirm-plannedtotalqtyinbaseunit = ls_confirm-plannedtotalqtyinbaseunit
                                                   + <lfs_member>-plannedtotalqtyinbaseunit.

            ENDLOOP.
            ls_confirm-material = <lfs_member>-material.
            ls_confirm-mrpplant = <lfs_member>-mrpplant.
            ls_confirm-productionversion = <lfs_member>-productionversion.
            ls_confirm-plndorderplannedstartdate = <lfs_member>-plndorderplannedstartdate.
            ls_confirm-startdate = <lfs_member>-startdate.
            ls_confirm-baseunit = <lfs_member>-baseunit.
            APPEND ls_confirm TO lt_confirm.
            CLEAR: ls_confirm.
          ENDLOOP.

          LOOP AT lt_unconfirmplan ASSIGNING <lfs_tmp>.
            IF <lfs_tmp>-plndorderplannedstartdate < lv_datum.
              <lfs_tmp>-startdate = lv_datum.
            ELSE.
              <lfs_tmp>-startdate = <lfs_tmp>-plndorderplannedstartdate.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_unconfirmplan INTO ls_tmp
                                   GROUP BY ( startdate = ls_tmp-startdate )
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
            ls_unconfirm-startdate = <lfs_unmember>-startdate.
            ls_unconfirm-baseunit = <lfs_unmember>-baseunit.
            APPEND ls_unconfirm TO lt_unconfirm.
            CLEAR: ls_unconfirm.
          ENDLOOP.

          SORT lt_confirmedplan BY plndorderplannedstartdate plannedorder.
          SORT lt_unconfirmplan BY plndorderplannedstartdate plannedorder.
* 比较数量
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
                 WITH KEY material = <ls_data>-idnrk
                          mrpplant = <ls_data>-plant
                          productionversion = <ls_data>-verid
                          startdate = lv_day.
            IF sy-subrc = 0.
              "確定計画手配の処理:比较
              lv_qty = <l_field>.
              IF lv_qty <> ls_confirm-plannedtotalqtyinbaseunit.  "原始数据
                "把数量修改到第一张planorder，同时删除当天其他planorder
                lv_first = 'X'.
                LOOP AT lt_confirmedplan INTO DATA(ls_confirmedplan)
                        WHERE material = <ls_data>-idnrk
                          AND mrpplant = <ls_data>-plant
                          AND productionversion = <ls_data>-verid
                          AND startdate = lv_day.
                  IF lv_first = 'X'.
                    IF lv_qty = 0.  "如果=0，直接删除，后续不用处理
                      delete_planorder( CHANGING cs_planorder = ls_confirmedplan
                                               cs_data = <ls_data> ).
                    ELSE.
                      update_planorder( CHANGING cs_planorder = ls_confirmedplan
                                                 cs_data = <ls_data>
                                                 cv_qty = lv_qty ).
                    ENDIF.
                    CLEAR: lv_first.
                  ELSE.
                    delete_planorder( CHANGING cs_planorder = ls_confirmedplan
                                               cs_data = <ls_data> ).
                  ENDIF.
                ENDLOOP.

                "P处理完，同时未処分計画手配Wの処理
                READ TABLE ct_data INTO <ls_data_w>
                     WITH KEY product = <ls_data>-product
                              idnrk = <ls_data>-idnrk
                              plantype = 'W'.
                lv_tabix = sy-tabix.
                CLEAR: <ls_data_w>-status, <ls_data_w>-message.
                lv_diff = lv_qty - ls_confirm-plannedtotalqtyinbaseunit.
                IF lv_diff > 0.  "数量从小改大
                  LOOP AT lt_unconfirmplan INTO DATA(ls_unconfirmplan).
                    IF ls_unconfirmplan-plannedtotalqtyinbaseunit <= lv_qty.
                      delete_planorder( CHANGING cs_planorder = ls_unconfirmplan
                                                     cs_data = <ls_data_w> ).
                      lv_qty = lv_qty - ls_unconfirmplan-plannedtotalqtyinbaseunit.
                      IF <ls_data_w>-status = 'S'.
                        DELETE TABLE lt_unconfirmplan FROM ls_unconfirmplan.
                      ENDIF.
                      IF lv_qty = 0.  "如果最后为0，跳出不处理后续
                        EXIT.
                      ENDIF.
                    ELSE.
                      lv_qty = ls_unconfirmplan-plannedtotalqtyinbaseunit - lv_qty.
                      update_planorder( CHANGING cs_planorder = ls_unconfirmplan
                                                   cs_data = <ls_data_w>
                                                   cv_qty = lv_qty ).

                      IF <ls_data_w>-status = 'S'.
                        ls_unconfirmplan-plannedtotalqtyinbaseunit = lv_qty.
                        MODIFY lt_unconfirmplan FROM ls_unconfirmplan TRANSPORTING plannedtotalqtyinbaseunit.
                      ENDIF.
                      EXIT.   "修改后跳出不处理后续
                    ENDIF.
                  ENDLOOP.
                ELSEIF lv_diff < 0.  "数量从大改小
                  LOOP AT lt_unconfirmplan INTO ls_unconfirmplan.
                    lv_qty = ls_unconfirmplan-plannedtotalqtyinbaseunit - lv_diff.

                    update_planorder( CHANGING cs_planorder = ls_unconfirmplan
                                                 cs_data = <ls_data_w>
                                                 cv_qty = lv_qty ).
                    IF <ls_data_w>-status = 'S'.
                      ls_unconfirmplan-plannedtotalqtyinbaseunit = lv_qty.
                      MODIFY lt_unconfirmplan FROM ls_unconfirmplan TRANSPORTING plannedtotalqtyinbaseunit.
                    ENDIF.
                    EXIT.
                  ENDLOOP.
                  IF sy-subrc <> 0.
                    lv_qty = -1 * lv_diff.
                    ls_unconfirmplan-material = <ls_data_w>-idnrk.
                    ls_unconfirmplan-mrpplant = <ls_data_w>-plant.
                    ls_unconfirmplan-productionversion = <ls_data_w>-verid.
                    create_planorder( CHANGING cs_planorder = ls_unconfirmplan
                                             cs_data = <ls_data_w>
                                             cv_qty = lv_qty
                                             cv_day = lv_day ).
                  ENDIF.

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
                "W行处理
                READ TABLE ct_data INTO <ls_data_w>
                     WITH KEY product = <ls_data>-product
                              idnrk = <ls_data>-idnrk
                              plantype = 'W'.
                lv_tabix = sy-tabix.
                CLEAR: <ls_data_w>-status, <ls_data_w>-message.

                LOOP AT lt_unconfirmplan INTO ls_unconfirmplan.
                  IF ls_unconfirmplan-plannedtotalqtyinbaseunit <= lv_qty.
                    delete_planorder( CHANGING cs_planorder = ls_unconfirmplan
                                                   cs_data = <ls_data_w> ).
                    lv_qty = lv_qty - ls_unconfirmplan-plannedtotalqtyinbaseunit.
                    IF <ls_data_w>-status = 'S'.
                      DELETE TABLE lt_unconfirmplan FROM ls_unconfirmplan.
                    ENDIF.
                    IF lv_qty = 0.
                      EXIT.
                    ENDIF.
                  ELSE.
                    lv_qty = ls_unconfirmplan-plannedtotalqtyinbaseunit - lv_qty.
                    IF lv_qty = 0.
                      delete_planorder( CHANGING cs_planorder = ls_unconfirmplan
                                                     cs_data = <ls_data_w> ).
                      IF <ls_data_w>-status = 'S'.
                        DELETE TABLE lt_unconfirmplan FROM ls_unconfirmplan.
                      ENDIF.
                    ELSE.
                      update_planorder( CHANGING cs_planorder = ls_unconfirmplan
                                                   cs_data = <ls_data_w>
                                                   cv_qty = lv_qty ).
                      IF <ls_data_w>-status = 'S'.
                        ls_unconfirmplan-plannedtotalqtyinbaseunit = lv_qty.
                        MODIFY lt_unconfirmplan FROM ls_unconfirmplan TRANSPORTING plannedtotalqtyinbaseunit.
                      ENDIF.
                    ENDIF.
                    EXIT.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDDO.
          "更新W行的消息
          IF <ls_data_w>-status IS NOT INITIAL
         AND <ls_data_w>-message IS NOT INITIAL.
            MODIFY ct_data FROM <ls_data_w> INDEX lv_tabix TRANSPORTING status message.
          ENDIF.
        WHEN 'I'.
          SELECT product,
                 plant,
                 mrparea,
                 plndindeprqmttype,
                 plndindeprqmtversion,
                 requirementplan,
                 requirementsegment,
                 plndindeprqmtperiod,
                 periodtype,
                 workingdaydate,
                 plannedquantity
            FROM i_plndindeprqmtitemtp WITH PRIVILEGED ACCESS
           WHERE product = @<ls_data>-idnrk
             AND plant = @<ls_data>-plant
             AND plndindeprqmtversion = '03'
            INTO TABLE @DATA(lt_plnd).

          DO cv_day TIMES.
            lv_day = lv_day + 1.
            lv_dayc = lv_day.
            CONCATENATE 'D' lv_dayc INTO lv_dayc.
            CONDENSE lv_dayc.

            lv_index = lv_index + 1.
            CONCATENATE 'D' lv_index INTO lv_dayi.
            CONDENSE lv_dayi.
            ASSIGN COMPONENT lv_dayi OF STRUCTURE <ls_data> TO <l_field>.
            lv_qty = <l_field>.

            READ TABLE lt_plnd INTO DATA(ls_plnd)
                 WITH KEY workingdaydate = lv_day.
            IF sy-subrc <> 0.
              IF lv_qty <> 0.
                create_pir( CHANGING cs_data = <ls_data>
                                     cv_qty = lv_qty
                                     cv_day = lv_day ).
              ENDIF.
            ELSE.
              IF lv_qty <> ls_plnd-plannedquantity.
                update_pir( CHANGING cs_data = <ls_data>
                                     cs_plnd = ls_plnd
                                     cv_qty  = lv_qty
                                     cv_day  = lv_day ).
              ENDIF.
            ENDIF.
          ENDDO.

      ENDCASE.

    ENDLOOP.
  ENDMETHOD.



  METHOD update_planorder.
    DATA:
      lo_root_exc      TYPE REF TO cx_root,
      ls_planorder_u   TYPE ts_planorder_u,
      ls_res_planorder TYPE ts_res_plan_api.
    DATA:
      lv_msg     TYPE string,
      lv_message TYPE string,
      lv_firm    TYPE abap_bool,
      lv_etag    TYPE string.

    IF cs_data-plantype = 'P'.
      lv_firm = abap_true.
    ELSE.
      lv_firm = abap_false.
    ENDIF.


    ls_planorder_u-_total_quantity = cv_qty.
    ls_planorder_u-_planned_order_is_firm = lv_firm.
    TRY.
        ls_planorder_u-_base_unit =  zzcl_common_utils=>conversion_cunit(
                                      EXPORTING iv_alpha = 'OUT'
                                                iv_input = cs_planorder-baseunit ).
      CATCH zzcx_custom_exception INTO lo_root_exc.
    ENDTRY.
    zzcl_common_utils=>request_api_v4( EXPORTING iv_path = |/api_plannedorder/srvd_a2x/sap/plannedorder/0001/PlannedOrderHeader/{ cs_planorder-plannedorder }|
                                                 iv_method      = if_web_http_client=>get
                                                 "iv_etag        = lv_etag
                                       IMPORTING ev_status_code = DATA(lv_status_code)
                                                 ev_response    = DATA(lv_response)
                                                 ev_etag        = lv_etag ).
    IF lv_etag IS NOT INITIAL.
      DATA(lv_reqbody_api) = /ui2/cl_json=>serialize( data = ls_planorder_u
                                                      compress = 'X'
                                                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
      zzcl_common_utils=>request_api_v4( EXPORTING iv_path = |/api_plannedorder/srvd_a2x/sap/plannedorder/0001/PlannedOrderHeader/{ cs_planorder-plannedorder }|
                                                 iv_method      = if_web_http_client=>patch
                                                 iv_body        = lv_reqbody_api
                                                 iv_etag        = lv_etag
                                         IMPORTING ev_status_code = lv_status_code
                                                  ev_response    = lv_response ).
      /ui2/cl_json=>deserialize(
                           EXPORTING json = lv_response
                           CHANGING data = ls_res_planorder ).
      IF lv_status_code = 201
      OR lv_status_code = 200. " update
        IF cs_data-message IS INITIAL.
          cs_data-status = 'S'.
          cs_data-message = cs_planorder-plannedorder && ` update`.
        ELSE.
          cs_data-message = cs_data-message && ';' && cs_planorder-plannedorder && ` update`.
        ENDIF.
      ELSE.
        cs_data-status = 'E'.
        IF cs_data-message IS INITIAL.
          cs_data-message = ls_res_planorder-error-message.
        ELSE.
          cs_data-message = cs_data-message && ';' && ls_res_planorder-error-message.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD delete_planorder.
    DATA:
      lo_root_exc      TYPE REF TO cx_root,
      ls_planorder_u   TYPE ts_planorder_u,
      ls_res_planorder TYPE ts_res_plan_api.
    DATA:
      lv_msg     TYPE string,
      lv_message TYPE string,
      lv_etag    TYPE string.

    zzcl_common_utils=>request_api_v4( EXPORTING iv_path = |/api_plannedorder/srvd_a2x/sap/plannedorder/0001/PlannedOrderHeader/{ cs_planorder-plannedorder }|
                                                 iv_method      = if_web_http_client=>get
                                                 "iv_etag        = lv_etag
                                       IMPORTING ev_status_code = DATA(lv_status_code)
                                                 ev_response    = DATA(lv_response)
                                                 ev_etag        = lv_etag ).
    IF lv_etag IS NOT INITIAL.
      zzcl_common_utils=>request_api_v4( EXPORTING iv_path = |/api_plannedorder/srvd_a2x/sap/plannedorder/0001/PlannedOrderHeader/{ cs_planorder-plannedorder }|
                                                 iv_method      = if_web_http_client=>delete
                                                 iv_etag = lv_etag
                                         IMPORTING ev_status_code = lv_status_code
                                                  ev_response    = lv_response ).
      /ui2/cl_json=>deserialize(
                           EXPORTING json = lv_response
                           CHANGING data = ls_res_planorder ).
      IF lv_status_code = 204. " success
        IF cs_data-message IS INITIAL.
          cs_data-status = 'S'.
          cs_data-message = cs_planorder-plannedorder && ` update`.
        ELSE.
          cs_data-message = cs_data-message && ';' && cs_planorder-plannedorder && ` update`.
        ENDIF.
      ELSE.
        cs_data-status = 'E'.
        IF cs_data-message IS INITIAL.
          cs_data-message = ls_res_planorder-error-message.
        ELSE.
          cs_data-message = cs_data-message && ';' && ls_res_planorder-error-message.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD create_planorder.
    DATA:
      lo_root_exc      TYPE REF TO cx_root,
      ls_planorder_i   TYPE ts_planorder_i,
      ls_res_planorder TYPE ts_res_plan_api.


    ls_planorder_i-_material = cs_planorder-material.
    ls_planorder_i-_planned_order_profile = 'LA'.
    ls_planorder_i-_m_r_p_area = cs_planorder-mrpplant.
    ls_planorder_i-_production_plant = cs_planorder-mrpplant.

    SELECT SINGLE baseunit
      FROM i_product
     WHERE product = @cs_planorder-material
      INTO @DATA(lv_unit).
    TRY.
        ls_planorder_i-_base_unit =  zzcl_common_utils=>conversion_cunit(
                                      EXPORTING iv_alpha = 'OUT'
                                                iv_input = lv_unit ).
      CATCH zzcx_custom_exception INTO lo_root_exc.
    ENDTRY.
    ls_planorder_i-_total_quantity = cv_qty.
    ls_planorder_i-_plnd_order_planned_start_date = |{ cv_day+0(4) }-{ cv_day+4(2) }-{ cv_day+6(2) }|.
    ls_planorder_i-_plnd_order_planned_end_date = |{ cv_day+0(4) }-{ cv_day+4(2) }-{ cv_day+6(2) }|.
    IF cs_data-plantype = 'P'.
      ls_planorder_i-_production_version = cs_planorder-productionversion.
      ls_planorder_i-_planned_order_is_firm = abap_true.
    ELSE.
      ls_planorder_i-_planned_order_is_firm = abap_false.
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
      DATA(lv_planorder) = ls_res_planorder-plannedorder.
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

    ls_request = VALUE #( _product                   = cs_data-idnrk
                          _plant                     = cs_data-plant
                          _plnd_indep_rqmt_version   = '03'
                          _plnd_indep_rqmt_is_active = '' ).
    DATA(lv_datetime) = |{ cv_day+0(4) }-{ cv_day+4(2) }-{ cv_day+6(2) }T00:00:00|.
    ls_pir_item = VALUE #( _product                 = cs_data-idnrk
                           _plant                   = cs_data-plant
                           _plnd_indep_rqmt_version = '03'
                           _plnd_indep_rqmt_period  = cv_day
                           _period_type             = 'D'
                           _planned_quantity        = cv_qty
                           _working_day_date        = lv_datetime ).
    CONDENSE ls_pir_item-_planned_quantity NO-GAPS.
    APPEND ls_pir_item TO ls_request-to_plnd_indep_rqmt_item.

    DATA(lv_requestbody) = /ui2/cl_json=>serialize( data = ls_request
                                                    compress = 'X'
                                                    pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
    REPLACE ALL OCCURRENCES OF 'toPlndIndepRqmtItem' IN lv_requestbody  WITH `to_PlndIndepRqmtItem`.

    DATA(lv_path) = |/API_PLND_INDEP_RQMT_SRV/PlannedIndepRqmt?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

    zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                 iv_method      = if_web_http_client=>post
                                                 iv_body        = lv_requestbody
                                       IMPORTING ev_status_code = DATA(lv_status_code)
                                                 ev_response    = DATA(lv_response) ).
    IF lv_status_code = 201.
      cs_data-status = 'S'.
      cs_data-message = 'Create Successful'.
    ELSE.
      /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                 CHANGING  data = ls_error ).
      cs_data-status = 'E'.
      IF cs_data-message IS INITIAL.
        cs_data-message = ls_error-error-message-value.
      ELSE.
        cs_data-message = cs_data-message && ';' && ls_error-error-message-value.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD update_pir.
    DATA:
      lv_msg     TYPE string,
      lv_message TYPE string.

    MODIFY ENTITIES OF i_plndindeprqmttp PRIVILEGED
      ENTITY plannedindependentrqmtitem
      UPDATE FROM VALUE #( (   product              = cs_plnd-product
                               plant                = cs_plnd-plant
                               mrparea              = cs_plnd-mrparea
                               plndindeprqmtversion = cs_plnd-plndindeprqmtversion
                               plndindeprqmttype    = cs_plnd-plndindeprqmttype
                               requirementplan      = cs_plnd-requirementplan
                               requirementsegment   = cs_plnd-requirementsegment
                               plndindeprqmtperiod  = cs_plnd-plndindeprqmtperiod
                               periodtype           = cs_plnd-periodtype
                               plannedquantity      = cv_qty
                               %control-plannedquantity = 1
                          ) )
     MAPPED   DATA(ls_mapped)
     FAILED   DATA(ls_failed)
     REPORTED DATA(ls_reported).

    IF sy-subrc = 0
   AND ls_failed IS INITIAL.
      cs_data-status = 'S'.
      IF cs_data-message IS INITIAL.
        cs_data-message = 'Update Successful'.
      ENDIF.

    ELSE.
      LOOP AT ls_reported-plannedindependentrequirement INTO DATA(ls_order).
        DATA(lv_msgobj) = cl_message_helper=>get_t100_for_object( ls_order-%msg ).
        IF ls_order-%msg->m_severity = cl_abap_behv=>ms-error.
          lv_msg = ls_order-%msg->if_message~get_text( ).
*          lv_message = zzcl_common_utils=>merge_message(
*                             iv_message1 = lv_message
*                             iv_message2 = lv_msg
*                             iv_symbol = ';' ).
        ENDIF.
      ENDLOOP.
      cs_data-status = 'E'.
      IF cs_data-message IS INITIAL.
        cs_data-message = lv_msg.
      ELSE.
        cs_data-message = cs_data-message && ';' && lv_msg.
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
