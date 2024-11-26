CLASS lhc_zce_createpir DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES tt_ofpartition TYPE TABLE for HIERARCHY zd_orderforecastitem.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zce_createpir RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zce_createpir.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zce_createpir.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zce_createpir.

    METHODS read FOR READ
      IMPORTING keys FOR READ zce_createpir RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zce_createpir.

    METHODS processofpartition FOR MODIFY
      IMPORTING keys FOR ACTION zce_createpir~processofpartition RESULT result.
    METHODS checkrecords FOR MODIFY
      IMPORTING keys FOR ACTION zce_createpir~checkrecords RESULT result.

    METHODS get_shipping_data
      IMPORTING iv_customer             TYPE kunnr
                iv_plant                TYPE werks_d
                iv_material             TYPE matnr
                iv_startdate            TYPE datum
                iv_enddate              TYPE datum
      RETURNING VALUE(rt_shipping_data) TYPE zttpp_1001.
    METHODS get_supply_demand_items
      IMPORTING iv_material                   TYPE matnr
                iv_plant                      TYPE werks_d
      RETURNING VALUE(rt_supply_demand_items) TYPE zttpp_1002.
    METHODS createpir
      IMPORTING iv_type          TYPE string DEFAULT 'OF'
      CHANGING  ct_plndindeprqmt TYPE tt_ofpartition
                !failed          TYPE DATA optional
                !reported        TYPE data OPTIONAL.
    METHODS processpir
      IMPORTING iv_request     TYPE data
      CHANGING  ct_ofpartition TYPE STANDARD TABLE.
ENDCLASS.

CLASS lhc_zce_createpir IMPLEMENTATION.

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

  METHOD processofpartition.
    DATA: lt_splitof_pir TYPE TABLE OF i_plndindeprqmttp,
          ls_splitof_pir LIKE LINE OF lt_splitof_pir.
    DATA key LIKE LINE OF keys.
    LOOP AT keys INTO key.
      "默认只有一条值,默认一次只处理一个维度的数据
      DATA(ls_request) = key-%param.
      DATA(lt_ofpartition) = ls_request-_item.
      DATA ls_ofpartition LIKE LINE OF lt_ofpartition.



      "分割后数据直接登录PIR
      createpir(
        EXPORTING
          iv_type = 'OF'
        CHANGING
          ct_plndindeprqmt = lt_ofpartition
          failed    = failed
          reported  = reported ).

      " 拼接BO返回的消息
      DATA lv_msg TYPE string.
      DATA lv_type TYPE c.
      " 如果有返回消息则视为失败
      IF reported-zce_createpir IS NOT INITIAL.
        lv_type = 'E'.
      ENDIF.
      IF lv_type <> 'E'.
        " 将分割后的OF数据和受注残出荷残一起处理
        processpir(
          EXPORTING
            iv_request = ls_request
          CHANGING
            ct_ofpartition = lt_ofpartition ).

        "经过受注残出荷残处理的PIR创建
        createpir(
          EXPORTING
            iv_type = 'PIR'
          CHANGING
            ct_plndindeprqmt = lt_ofpartition
            failed    = failed
            reported  = reported ).
      ENDIF.
      " 如果没有返回消息则视为成功
      IF reported-zce_createpir IS INITIAL.
        lv_type = 'S'.
        MESSAGE s090(zpp_001) INTO lv_msg.
      ELSE.
        lv_type = 'E'.
        " 将所有错误消息拼接在一起
        LOOP AT reported-zce_createpir INTO DATA(ls_message).
          lv_msg = zzcl_common_utils=>merge_message(
                                        iv_message1 = lv_msg
                                        iv_message2 = cl_message_helper=>get_text_for_message( ls_message-%msg )
                                        iv_symbol = ';' ).
        ENDLOOP.
      ENDIF.
      "返回处理过数据
      DATA: lt_item TYPE TABLE FOR HIERARCHY zd_orderforecastitem,
            ls_item LIKE LINE OF lt_item.
      SORT lt_ofpartition BY customer plant material requirementdate.
      CLEAR: ls_item, lt_item.
      LOOP AT lt_ofpartition INTO ls_ofpartition.
        MOVE-CORRESPONDING ls_ofpartition TO ls_item.
        APPEND ls_item TO lt_item.
      ENDLOOP.


      APPEND VALUE #( %cid    = key-%cid
                        %param  =
                        VALUE #(  customer  = ls_request-customer
                                  plant     = ls_request-plant
                                  material  = ls_request-material
                                  type      = lv_type
                                  message   = lv_msg
                                  _item     = lt_item ) ) TO result.
    ENDLOOP.
  ENDMETHOD.
  METHOD get_shipping_data.
    SELECT
*      dnitem~deliverydocument,
*      dnitem~deliverydocumentitem,
      i_salesorder~soldtoparty AS customer,
      dnitem~plant,
      dnitem~product AS material,
      dnitem~productavailabilitydate,
      CAST( substring( dnitem~productavailabilitydate, 1, 6 ) AS NUMC( 6 ) )  AS month,
*      dnitem~goodsmovementtype,
      SUM( CASE WHEN dnitem~goodsmovementtype = '688' OR dnitem~goodsmovementtype = '602'
        THEN matdoc2~quantityinbaseunit * -1
        ELSE matdoc2~quantityinbaseunit
      END ) AS quantityinbaseunit
*      matdoc2~QUANTITYINBASEUNIT
    FROM i_deliverydocumentitem AS dnitem
    LEFT JOIN i_salesorder
      ON dnitem~referencesddocument = i_salesorder~salesorder
    LEFT JOIN i_materialdocumentitem_2 AS matdoc2
      ON matdoc2~deliverydocument = dnitem~deliverydocument
      AND matdoc2~deliverydocumentitem = dnitem~deliverydocumentitem
      AND matdoc2~isautomaticallycreated <> 'X'
      AND matdoc2~goodsmovementtype IN ( '687', '688', '601', '602' )
    WHERE i_salesorder~soldtoparty = @iv_customer
    AND dnitem~plant = @iv_plant
    AND dnitem~product = @iv_material
    AND dnitem~productavailabilitydate >= @iv_startdate
    AND dnitem~productavailabilitydate <= @iv_enddate
    GROUP BY  i_salesorder~soldtoparty,
              dnitem~plant,
              dnitem~product,
              dnitem~productavailabilitydate
    INTO TABLE @DATA(lt_shipping).

    MOVE-CORRESPONDING lt_shipping TO rt_shipping_data.
*    "获取内表结构
*    data(lo_table_type) = cast cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( lt_shipping ) ).
*
*    CREATE DATA rt_shipping_data TYPE HANDLE lo_table_type.
*
*    FIELD-SYMBOLS: <lt_shipping> TYPE STANDARD TABLE.
*    ASSIGN rt_shipping_data->* TO <lt_shipping>.
*    <lt_shipping> = lt_shipping.
  ENDMETHOD.

  METHOD get_supply_demand_items.
    TYPES: tt_results TYPE STANDARD TABLE OF zspp_1002 WITH DEFAULT KEY,
           BEGIN OF ty_d,
             results TYPE tt_results,
           END OF ty_d,
           BEGIN OF ty_response_api,
             d TYPE ty_d,
           END OF ty_response_api.
    DATA: ls_response_api      TYPE ty_response_api,
          ls_supplydemanditems TYPE zspp_1002,
          lt_supplydemanditems TYPE TABLE OF zspp_1002.
    DATA(lv_param1) = |(%20MRPElementCategory%20eq%20'VC'%20or%20MRPElementCategory%20eq%20'VJ'%20)|.
    DATA(lv_path) = |/API_MRP_MATERIALS_SRV_01/SupplyDemandItems?$filter=Material%20eq%20'{ iv_material }'%20and%20MRPPlant%20eq%20'{ iv_plant }'%20and%20{ lv_param1 }|.
*    lv_path = CL_WEB_HTTP_UTILITY=>escape_url( lv_path ).
    "Call API
    zzcl_common_utils=>request_api_v2(
      EXPORTING
        iv_path        = lv_path
        iv_method      = if_web_http_client=>get
        iv_format      = 'json'
      IMPORTING
        ev_status_code = DATA(lv_stat_code)
        ev_response    = DATA(lv_resbody_api) ).
    "JSON->ABAP
    /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api
                              CHANGING  data = ls_response_api ).

    "将数量转换成正值并合并数量
    CLEAR lt_supplydemanditems.
    LOOP AT ls_response_api-d-results INTO DATA(ls_results).
      MOVE-CORRESPONDING ls_results TO ls_supplydemanditems.
      " 时间戳格式转换成日期格式
      ls_supplydemanditems-mrprqmtdate = CONV string( ls_supplydemanditems-mrpelementavailyorrqmtdate DIV 1000000 ).
      ls_supplydemanditems-mrpelementopenquantity = abs( ls_supplydemanditems-mrpelementopenquantity ).
      COLLECT ls_supplydemanditems INTO lt_supplydemanditems.
      CLEAR ls_supplydemanditems.
    ENDLOOP.
    MOVE-CORRESPONDING lt_supplydemanditems TO rt_supply_demand_items.
  ENDMETHOD.
  METHOD createpir.
    DATA: lt_plndindeprqmt     TYPE TABLE FOR CREATE i_plndindeprqmttp,
          ls_plndindeprqmt     LIKE LINE OF lt_plndindeprqmt,
          lt_plndindeprqmtitem TYPE TABLE FOR CREATE i_plndindeprqmttp\_plndindeprqmtitem,
          ls_plndindeprqmtitem LIKE LINE OF lt_plndindeprqmtitem,
          cs_plndindeprqmt like LINE OF ct_plndindeprqmt,
          lt_ofpartition TYPE table of zd_orderforecastitem,
          ls_ofpartition like LINE OF lt_ofpartition.
    DATA: lv_customer        TYPE kunnr,
          lv_requirementdate TYPE datum,
          lv_plant           TYPE werks_d,
          lv_tabix           TYPE i,
          lv_date TYPE datum.
    "有些日期不是工作日，sap会自动变成节日的前一个工作日，但业务需求要后一个工作日，所以需要手动更改为后一个工作日
    LOOP AT ct_plndindeprqmt INTO cs_plndindeprqmt.
      lv_requirementdate = cs_plndindeprqmt-requirementdate.
      cs_plndindeprqmt-requirementdate = zzcl_common_utils=>get_workingday( iv_plant = cs_plndindeprqmt-plant iv_date = lv_requirementdate ).
      cs_plndindeprqmt-RequirementMonth = cs_plndindeprqmt-requirementdate(6).
      MOVE-CORRESPONDING cs_plndindeprqmt to ls_ofpartition.
      COLLECT ls_ofpartition INTO lt_ofpartition.
    ENDLOOP.
    MOVE-CORRESPONDING lt_ofpartition to ct_plndindeprqmt.
    "获取要创建pir的日期范围
    DATA(lv_date_range) = zcl_ofpartition=>get_process_date_range( ).
    "为减少数据传输量，前端只会传入数量不等于0的日期
    "但在创建pir时系统只会处理传入日期的数据，但实际是需要用0覆盖之前的数据，
    "所以现在需要填充要处理的日期范围中的每一天(工作日)
    "默认一次只会有一个维度的数据
    IF lines( ct_plndindeprqmt ) > 0.
      cs_plndindeprqmt = ct_plndindeprqmt[ 1 ].
    ENDIF.
    lv_date = lv_date_range-startdate.
    WHILE lv_date <= lv_date_range-enddate.
      "如果不是工作日则不用处理
      IF NOT zzcl_common_utils=>is_workingday( iv_plant = cs_plndindeprqmt-plant iv_date = lv_date ).
        lv_date = lv_date + 1.
        CONTINUE.
      ENDIF.
      "默认一次只会有一个维度的数据
      READ TABLE ct_plndindeprqmt TRANSPORTING NO FIELDS WITH KEY requirementdate = lv_date."因为会插入数据，所以无法使用binary search。除非新增一个内表
      "如果是工作日且内表中没有则需要用0填充
      IF sy-subrc <> 0.
        cs_plndindeprqmt-requirementdate = lv_date.
        cs_plndindeprqmt-requirementmonth = lv_date(6).
        cs_plndindeprqmt-requirementqty = 0.
        APPEND cs_plndindeprqmt TO ct_plndindeprqmt.
      ENDIF.
      lv_date = lv_date + 1.
    ENDWHILE.
    SORT ct_plndindeprqmt BY customer plant material requirementdate.

    LOOP AT ct_plndindeprqmt ASSIGNING FIELD-SYMBOL(<is_plndindeprqmt>).
      lv_tabix = sy-tabix.
      lv_customer = |{ <is_plndindeprqmt>-customer ALPHA = OUT }|.
      IF lv_tabix = 1.
        ls_plndindeprqmt-%cid = sy-tabix.
        ls_plndindeprqmt-product = <is_plndindeprqmt>-material.
        ls_plndindeprqmt-plant = <is_plndindeprqmt>-plant.
        ls_plndindeprqmt-requirementplan = lv_customer.
        IF iv_type = 'OF'.
          DATA(lv_version) = '02'.
          DATA(lv_isactive) = ''.
        ELSE.
          lv_version = '00'.
          lv_isactive = 'X'.
        ENDIF.
        ls_plndindeprqmt-plndindeprqmtversion = lv_version.
        ls_plndindeprqmt-plndindeprqmtisactive = lv_isactive.
        APPEND ls_plndindeprqmt TO lt_plndindeprqmt.
        CLEAR ls_plndindeprqmt.
        ls_plndindeprqmtitem-%cid_ref = sy-tabix.
        ls_plndindeprqmtitem-product = <is_plndindeprqmt>-material.
        ls_plndindeprqmtitem-plant = <is_plndindeprqmt>-plant.
        ls_plndindeprqmtitem-requirementplan = lv_customer.
        ls_plndindeprqmtitem-plndindeprqmtversion = lv_version.
      ENDIF.

      ls_plndindeprqmtitem-%target = VALUE #( BASE ls_plndindeprqmtitem-%target (
                                              %cid = |I{ lv_tabix }|
                                              product = <is_plndindeprqmt>-material
                                              plant = <is_plndindeprqmt>-plant
                                              requirementplan = lv_customer
                                              periodtype      = 'D'
                                              plndindeprqmtperiod = <is_plndindeprqmt>-requirementdate
                                              workingdaydate  = <is_plndindeprqmt>-requirementdate
                                              plannedquantity = <is_plndindeprqmt>-requirementqty ) ).
    ENDLOOP.
    IF sy-subrc = 0.
      APPEND ls_plndindeprqmtitem TO lt_plndindeprqmtitem.
    ENDIF.

    MODIFY ENTITIES OF i_plndindeprqmttp PRIVILEGED
      ENTITY plannedindependentrequirement
      CREATE FROM lt_plndindeprqmt
      CREATE BY \_plndindeprqmtitem
      FROM lt_plndindeprqmtitem
      MAPPED DATA(mapped)
      FAILED DATA(bo_failed)
      REPORTED DATA(bo_reported).


    DATA repo TYPE RESPONSE FOR REPORTED EARLY zce_createpir.
    ASSIGN reported TO FIELD-SYMBOL(<reported>).
    repo-zce_createpir = <reported>-('zce_createpir').

    " 处理抬头消息
    IF bo_failed-plannedindependentrequirement IS NOT INITIAL.
      LOOP AT bo_reported-plannedindependentrequirement INTO DATA(ls_message).
        DATA(lv_msgobj) = cl_message_helper=>get_t100_for_object( ls_message-%msg ).
        " 对于已经存在的PIR创建时抬头会报错，但是行项目可以正常修改，所以会略此消息
        IF lv_msgobj-msgid = 'PPH_FCDM' AND lv_msgobj-msgno = '025'.
          CONTINUE.
        ENDIF.
        IF ls_message-%msg->m_severity = cl_abap_behv=>ms-error.
          " 新增一个空行，通过往空行中添加达到使用FIELD-SYMBOL新增行的目的
          APPEND INITIAL LINE TO repo-zce_createpir ASSIGNING FIELD-SYMBOL(<repo_line>).
          <repo_line>-('%msg') = ls_message-%msg.
        ENDIF.
      ENDLOOP.
    ENDIF.

    " 处理行项目消息
    DATA lt_msg_obj TYPE TABLE OF symsg .
    CLEAR lt_msg_obj.
    IF bo_failed-plannedindependentrqmtitem IS NOT INITIAL.
      LOOP AT bo_reported-plannedindependentrqmtitem INTO DATA(ls_message_item).
        IF ls_message_item-%msg->m_severity = cl_abap_behv=>ms-error.
          DATA(lv_msg) = cl_message_helper=>get_text_for_message( ls_message_item-%msg ).
          DATA(ls_msg_obj) = cl_message_helper=>get_t100_for_object( ls_message_item-%msg ).
          " 重复消息只显示一次
          READ TABLE lt_msg_obj TRANSPORTING NO FIELDS WITH KEY msgid = ls_msg_obj-msgid msgno = ls_msg_obj-msgno.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.
          APPEND ls_msg_obj TO lt_msg_obj.
          CLEAR ls_msg_obj.
          " 新增一个空行，通过往空行中添加达到使用FIELD-SYMBOL新增行的目的
          APPEND INITIAL LINE TO repo-zce_createpir ASSIGNING <repo_line>.
          <repo_line>-('%msg') = ls_message_item-%msg.
        ENDIF.
      ENDLOOP.
    ENDIF.
    <reported>-('zce_createpir') = repo-zce_createpir.
  ENDMETHOD.
  METHOD processpir.
    DATA ls_request TYPE STRUCTURE FOR HIERARCHY zd_orderforecasthead.
    DATA lt_ofpartition TYPE TABLE FOR HIERARCHY zd_orderforecastitem.
    ls_request = iv_request.
    lt_ofpartition = ct_ofpartition.

    DATA: lv_delivered    TYPE menge_d,
          lv_supplydemand TYPE menge_d.

    "1. 获取出荷実績数据
    DATA(lt_shipping) = get_shipping_data(
                          iv_customer   = ls_request-customer
                          iv_plant      = ls_request-plant
                          iv_material   = ls_request-material
                          iv_startdate  = CONV #( ls_request-processstart )
                          iv_enddate    = CONV #( ls_request-processend ) ).
    "2. 对实际发货进行排序，确保按日期从早到晚处理
    SORT lt_shipping BY customer plant material productavailabilitydate.
      "3. 遍历发货数据，依次减少生产计划
    LOOP AT lt_shipping ASSIGNING FIELD-SYMBOL(<ls_shipping>) WHERE quantityinbaseunit > 0.
      lv_delivered = <ls_shipping>-quantityinbaseunit.

      LOOP AT lt_ofpartition INTO DATA(ls_ofpartition) WHERE customer = <ls_shipping>-customer AND plant = <ls_shipping>-plant
        AND material = <ls_shipping>-material AND requirementmonth = <ls_shipping>-month AND requirementqty > 0.
        IF lv_delivered = 0.
          EXIT.
        ENDIF.

        IF ls_ofpartition-requirementqty >= lv_delivered.
          " 如果当前生产计划大于实际发货数量，则生产剩余的数量
          ls_ofpartition-requirementqty = ls_ofpartition-requirementqty - lv_delivered.
          lv_delivered = 0.
        ELSE.
          " 如果实际发货数量已经大于当前生产计划则不生产，数量为0
          lv_delivered = lv_delivered - ls_ofpartition-requirementqty.
          ls_ofpartition-requirementqty = 0.
        ENDIF.

        " 修改生产计划内表中的数量
        MODIFY lt_ofpartition FROM ls_ofpartition.
      ENDLOOP.
    ENDLOOP.
    " 结合受注残出荷残的需求数量 决定生成需求
    "1. 获取受注残出荷残合计的需求数量
    DATA(lt_supplydemanditems) = get_supply_demand_items( iv_material = ls_request-material iv_plant = ls_request-plant ).
    "2. 对需求数据进行排序，确保按日期从早到晚处理
    SORT lt_supplydemanditems BY mrpelementbusinesspartner mrpplant material mrprqmtdate.
    SORT lt_ofpartition BY customer plant material requirementmonth requirementdate requirementqty.
    "3. 遍历供应需求数据，依次在需求日生成生产计划
    LOOP AT lt_supplydemanditems INTO DATA(ls_supplydemanditems) WHERE mrpelementopenquantity > 0.
      DATA(lv_month) = ls_supplydemanditems-mrprqmtdate(6).

      lv_supplydemand = ls_supplydemanditems-mrpelementopenquantity.
      "消耗原生产需求计划
      LOOP AT lt_ofpartition INTO ls_ofpartition WHERE customer = ls_supplydemanditems-mrpelementbusinesspartner AND plant = ls_supplydemanditems-mrpplant
        AND material = ls_supplydemanditems-material AND requirementmonth = lv_month AND requirementqty > 0.
        IF lv_supplydemand = 0.
          EXIT.
        ENDIF.

        IF ls_ofpartition-requirementqty >= lv_supplydemand.
          " 如果当前原生产需求计划可以满足供应需求，则消耗生产需求计划
          ls_ofpartition-requirementqty = ls_ofpartition-requirementqty - lv_supplydemand.
          lv_supplydemand = 0.
        ELSE.
          " 如果供应需求已经大于当前生产需求计划则数量为0
          lv_supplydemand = lv_supplydemand - ls_ofpartition-requirementqty.
          ls_ofpartition-requirementqty = 0.
        ENDIF.
        " 修改原生产需求计划内表中的数量
        MODIFY lt_ofpartition FROM ls_ofpartition.
      ENDLOOP.
    ENDLOOP.
    DATA(lt_ofpartition_tmp) = lt_ofpartition.
    "4. 将供应需求数据和修改后生成需求计划数据结合
    LOOP AT lt_supplydemanditems INTO ls_supplydemanditems WHERE mrpelementopenquantity > 0.
      READ TABLE lt_ofpartition_tmp INTO ls_ofpartition WITH KEY customer = ls_supplydemanditems-mrpelementbusinesspartner plant = ls_supplydemanditems-mrpplant
        material = ls_supplydemanditems-material requirementdate = ls_supplydemanditems-mrprqmtdate BINARY SEARCH.
      IF sy-subrc = 0.
        "如果对应的日期原本有数据，结合原本的数据修改数量即可
        ls_ofpartition-requirementqty = ls_ofpartition-requirementqty + ls_supplydemanditems-mrpelementopenquantity.
        MODIFY lt_ofpartition FROM ls_ofpartition TRANSPORTING requirementqty WHERE customer = ls_ofpartition-customer AND plant = ls_ofpartition-plant
          AND material = ls_ofpartition-material AND requirementdate = ls_ofpartition-requirementdate.
      ELSE.
        "如果没有对应的日期数据则需要新增一条
        ls_ofpartition-customer = ls_supplydemanditems-mrpelementbusinesspartner.
        ls_ofpartition-plant = ls_supplydemanditems-mrpplant.
        ls_ofpartition-material = ls_supplydemanditems-material.
        ls_ofpartition-requirementdate = ls_supplydemanditems-mrprqmtdate.
        ls_ofpartition-requirementqty = ls_supplydemanditems-mrpelementopenquantity.
        APPEND ls_ofpartition TO lt_ofpartition.
      ENDIF.
    ENDLOOP.
    ct_ofpartition = lt_ofpartition.
  ENDMETHOD.
  METHOD checkrecords.
    DATA lv_msg TYPE string.
    DATA lv_msg_single TYPE string.
    DATA lv_type TYPE c.
    LOOP AT keys INTO DATA(key).
      CLEAR lv_msg.
      lv_type = 'S'.
      DATA(ls_ofpartition) = key-%param.

      " 得意先不能为空
      IF ls_ofpartition-customer IS INITIAL.
        lv_type = 'E'.
        MESSAGE e093(zpp_001) INTO lv_msg_single.
        lv_msg = zzcl_common_utils=>merge_message(
                                      iv_message1 = lv_msg
                                      iv_message2 = lv_msg_single
                                      iv_symbol = ';' ).
      ELSE.
        " 得意先不存在
        SELECT
          COUNT(*)
        FROM i_businesspartner
        WHERE businesspartner = @ls_ofpartition-customer.
        IF sy-subrc <> 0.
          lv_type = 'E'.
          MESSAGE e097(zpp_001) INTO lv_msg_single.
          lv_msg = zzcl_common_utils=>merge_message(
                                        iv_message1 = lv_msg
                                        iv_message2 = lv_msg_single
                                        iv_symbol = ';' ).
        ENDIF.
      ENDIF.
      " プラント不能为空
      IF ls_ofpartition-plant IS INITIAL.
        lv_type = 'E'.
        MESSAGE e094(zpp_001) INTO lv_msg_single.
        lv_msg = zzcl_common_utils=>merge_message(
                                      iv_message1 = lv_msg
                                      iv_message2 = lv_msg_single
                                      iv_symbol = ';' ).

      ENDIF.
      " 品目不能为空
      IF ls_ofpartition-material IS INITIAL.
        lv_type = 'E'.
        MESSAGE e095(zpp_001) INTO lv_msg_single.
        lv_msg = zzcl_common_utils=>merge_message(
                                      iv_message1 = lv_msg
                                      iv_message2 = lv_msg_single
                                      iv_symbol = ';' ).
      ENDIF.
      " 物料工厂不存在
      IF ls_ofpartition-plant IS NOT INITIAL AND ls_ofpartition-material IS NOT INITIAL.
        SELECT
          COUNT( * )
        FROM i_productplantbasic
        WHERE product = @ls_ofpartition-material
          AND plant = @ls_ofpartition-plant.
        IF sy-subrc <> 0 .
          lv_type = 'E'.
          MESSAGE e096(zpp_001) WITH ls_ofpartition-material ls_ofpartition-plant INTO lv_msg_single.
          lv_msg = zzcl_common_utils=>merge_message(
                                      iv_message1 = lv_msg
                                      iv_message2 = lv_msg_single
                                      iv_symbol = ';' ).
        ENDIF.
      ENDIF.

      IF lv_type = 'S'.
*        lv_msg =
      ENDIF.

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #(
                        customer  = ls_ofpartition-customer
                        plant     = ls_ofpartition-plant
                        material  = ls_ofpartition-material
                        type      = lv_type
                        message   = lv_msg ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zce_createpir DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zce_createpir IMPLEMENTATION.

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
