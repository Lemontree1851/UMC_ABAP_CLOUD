CLASS lhc_purchasereq DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF ty_batchupload.
            INCLUDE TYPE zc_tmm_1006.
    TYPES:  row TYPE i,
          END OF ty_batchupload.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR purchasereq RESULT result.
    METHODS checkrecords FOR VALIDATE ON SAVE
      IMPORTING keys FOR purchasereq~checkrecords.
    METHODS batchprocess FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~batchprocess RESULT result.
    METHODS createpurchaseorder FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~createpurchaseorder RESULT result.
    METHODS mandotarycheck
      CHANGING
        records   TYPE data
        !failed   TYPE data OPTIONAL
        !reported TYPE data OPTIONAL.
    METHODS add_reported
      IMPORTING
        record    TYPE data
        !target   TYPE simple
        !id       TYPE symsgid
        !number   TYPE symsgno
        !severity TYPE if_abap_behv_message=>t_severity
        !v1       TYPE simple OPTIONAL
        !v2       TYPE simple OPTIONAL
        !v3       TYPE simple OPTIONAL
        !v4       TYPE simple OPTIONAL
      CHANGING
        reported  TYPE data.
    METHODS get_prno
      IMPORTING
                prtype      TYPE ztmm_1006-pr_type
                kyoten      TYPE ztmm_1006-kyoten
      RETURNING VALUE(prno) TYPE string
      RAISING   zzcx_custom_exception .

ENDCLASS.

CLASS lhc_purchasereq IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD checkrecords.
    DATA:
      is_error   TYPE abap_boolean,
      lv_msg     TYPE string,
      lv_message TYPE string,
      lo_data    TYPE REF TO data.

    READ ENTITIES OF zr_tmm_1006 IN LOCAL MODE
      ENTITY purchasereq
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(records).
    " 必输检查
    mandotarycheck(
      CHANGING
        records   = records
        failed    = failed
        reported  = reported ).


  ENDMETHOD.

  METHOD batchprocess.
    DATA:
      records TYPE TABLE OF ty_batchupload,
      record  LIKE LINE OF records,
      lv_msg  TYPE string.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).
      " 必输检查 这里手动执行了检查，实际上由于validate checkrecords的存在，在eml语句保存数据后，还会再执行一次检查
      mandotarycheck( CHANGING records = records ).

      LOOP AT records INTO record.
        record-supplier = |{ record-supplier ALPHA = IN }|.
        record-matid = |{ record-matid ALPHA = IN }|.
        MODIFY records FROM record.
      ENDLOOP.

      IF key-%param-event = 'check'.
        "价格检查
        DATA(lv_current_date) = cl_abap_context_info=>get_system_date( ).
        IF records IS NOT INITIAL.
          SELECT
            purc_info~supplier,
            purc_info~material,
            purc_info_org_plant~plant,
            purc_info_org_plant~purchasingorganization,
            purc_info_org_plant~pricevalidityenddate,
            purc_info_org_plant~materialpriceunitqty,
            purc_info_org_plant~netpriceamount,
            purc_info_org_plant~currency
          FROM i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS purc_info
          LEFT JOIN i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS AS purc_info_org_plant
            ON purc_info~purchasinginforecord = purc_info_org_plant~purchasinginforecord
          FOR ALL ENTRIES IN @records
          WHERE supplier = @records-supplier
            AND material = @records-matid
            AND plant = @records-plant
            AND purchasingorganization = @records-purchaseorg
            AND purchasinginforecordcategory = '0'
            AND pricevalidityenddate >= @lv_current_date
          INTO TABLE @DATA(lt_purginforecd).

          DATA lv_upload_price(11) TYPE p DECIMALS 5.
          DATA lv_main_price(11) TYPE p DECIMALS 5.
          DATA lv_price1_str TYPE string.
          DATA lv_price2_str TYPE string.
          SORT lt_purginforecd BY supplier material plant purchasingorganization pricevalidityenddate DESCENDING.
          LOOP AT records INTO record WHERE type <> 'E' AND unitprice <> 0.
            READ TABLE lt_purginforecd INTO DATA(ls_purginforecd) WITH KEY supplier = record-supplier
              material = record-matid plant = record-plant purchasingorganization = record-purchaseorg BINARY SEARCH.
            IF sy-subrc = 0.
              ls_purginforecd-netpriceamount = zzcl_common_utils=>conversion_amount(
                                                                    iv_alpha = 'OUT'
                                                                    iv_currency = ls_purginforecd-currency
                                                                    iv_input = ls_purginforecd-netpriceamount ).
              IF ls_purginforecd-materialpriceunitqty <> 0.
                lv_upload_price = record-price / record-unitprice.
                lv_main_price = ls_purginforecd-netpriceamount / ls_purginforecd-materialpriceunitqty.

                IF lv_upload_price = 0 AND lv_main_price <> 0.
                  record-price = ls_purginforecd-netpriceamount.
                  record-unitprice = ls_purginforecd-materialpriceunitqty.
                ELSEIF lv_upload_price <> lv_main_price AND lv_main_price <> 0.
                  "TODO 没有往failed 中填充错误消息，在明细修改时会没有校验
                  record-type = 'W'.
                  lv_price1_str = lv_upload_price.
                  lv_price2_str = lv_main_price.
                  SHIFT lv_price1_str RIGHT DELETING TRAILING ''.
                  SHIFT lv_price1_str RIGHT DELETING TRAILING '0'.
                  SHIFT lv_price1_str RIGHT DELETING TRAILING '.'.
                  SHIFT lv_price1_str LEFT DELETING LEADING ''.
                  SHIFT lv_price2_str RIGHT DELETING TRAILING ''.
                  SHIFT lv_price2_str RIGHT DELETING TRAILING '0'.
                  SHIFT lv_price2_str RIGHT DELETING TRAILING '.'.
                  SHIFT lv_price2_str LEFT DELETING LEADING ''.
                  MESSAGE e025(zmm_001) WITH lv_price1_str lv_price2_str INTO lv_msg.
                  record-message = zzcl_common_utils=>merge_message( iv_message1 = record-message iv_message2 = lv_msg iv_symbol = ';' ).
                ENDIF.
              ENDIF.
            ENDIF.
            lv_upload_price = 0.
            IF record-unitprice <> 0.
              lv_upload_price = record-price / record-unitprice.
            ENDIF.
            IF lv_upload_price = 0.
              "TODO 没有往failed 中填充错误消息，在明细修改时会没有校验
              record-type = 'E'.
              MESSAGE e026(zmm_001) INTO lv_msg.
              record-message = zzcl_common_utils=>merge_message( iv_message1 = record-message iv_message2 = lv_msg iv_symbol = ';' ).
            ENDIF.
            MODIFY records FROM record.
          ENDLOOP.
        ENDIF.

        LOOP AT records INTO record WHERE type = ''.
          record-type = 'S'.
          record-message = TEXT-012.
          MODIFY records FROM record.
        ENDLOOP.
      ELSEIF key-%param-event = 'save'.
        READ TABLE records TRANSPORTING NO FIELDS WITH KEY type = 'E'.
        IF sy-subrc <> 0.
          DATA lt_purchasereq TYPE TABLE FOR CREATE zr_tmm_1006.
          DATA ls_purchasereq LIKE LINE OF lt_purchasereq.
          DATA lv_prno TYPE ztmm_1006-pr_no.
          CLEAR lv_prno.
          LOOP AT records INTO record.
            "一起上传的数据都是一个番号
            IF sy-tabix = 1.
              " 1400使用不同的编号方式；默认所有数据公司代码一致
              IF record-companycode = '1400'.
                TRY.
                    cl_numberrange_runtime=>number_get(
                                              EXPORTING
                                                nr_range_nr = '1'
                                                object = 'ZMM_1001'
                                              IMPORTING
                                                number = DATA(lv_number)
                                                returncode = DATA(lv_returncode) ).
                    IF lv_returncode = space.
                      lv_prno = lv_number+13(7).
                    ENDIF.
                  CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(exc_nr).
                    record-type = 'E'.
                    record-message = exc_nr->get_text( ).
                ENDTRY.
              ELSE.
                TRY.
                    lv_prno = get_prno(
                                    EXPORTING
                                      prtype = record-prtype
                                      kyoten = record-kyoten ).
                  CATCH zzcx_custom_exception  INTO DATA(exc).
                    record-type = 'E'.
                    record-message = exc->get_text( ).
                ENDTRY.
              ENDIF.
            ENDIF.
            IF lv_prno IS NOT INITIAL.
              record-prno = lv_prno.
              record-createdat = cl_abap_context_info=>get_system_date( ).
              "到这就认为成功，后续出错程序会抛出异常或终止
              record-type = 'S'.
              MESSAGE s012(zmm_001) WITH record-prno record-pritem INTO record-message.
              "需要审批时，审批状态默认为1登録済
              "不需要审批，状态直接为3承認済
              IF record-isapprove = '1'.
                record-approvestatus = '1'.
              ELSE.
                record-approvestatus = '3'.
              ENDIF.
              MOVE-CORRESPONDING record TO ls_purchasereq.
              APPEND ls_purchasereq TO lt_purchasereq.
            ENDIF.
            MODIFY records FROM record.
            CLEAR ls_purchasereq.
          ENDLOOP.
        ENDIF.
        READ TABLE records TRANSPORTING NO FIELDS WITH KEY type = 'E'.
        IF sy-subrc <> 0.
          MODIFY ENTITIES OF zr_tmm_1006 IN LOCAL MODE
            ENTITY purchasereq
            CREATE AUTO FILL CID
            FIELDS (  applydepart
                      prno
                      pritem
                      prtype
                      ordertype
                      supplier
                      companycode
                      purchaseorg
                      purchasegrp
                      plant
                      currency
                      itemcategory
                      accounttype
                      matid
                      matdesc
                      materialgroup
                      quantity
                      unit
                      price
                      unitprice
                      deliverydate
                      location
                      returnitem
                      free
                      glaccount
                      costcenter
                      wbselemnt
                      assetno
                      tax
                      itemtext
                      prby
                      trackno
                      ean
                      customerrec
                      assetori
                      memotext
                      buypurpoose
                      islink
                      suppliermat
                      polinkby
                      purchaseorder
                      purchaseorderitem
                      kyoten
                      isapprove
                      approvestatus
                      createdat )
            WITH lt_purchasereq
            MAPPED mapped
            REPORTED reported
            FAILED failed.
        ENDIF.
      ENDIF.
      LOOP AT records INTO record.
        record-supplier = |{ record-supplier ALPHA = OUT }|.
        record-matid = |{ record-matid ALPHA = OUT }|.
        MODIFY records FROM record.
      ENDLOOP.
      DATA(lv_json) = /ui2/cl_json=>serialize( records ).
      APPEND VALUE #( %cid    = key-%cid
                      %param  = VALUE #( zzkey = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD mandotarycheck.
    DATA fail TYPE RESPONSE FOR FAILED LATE zr_tmm_1006.
    DATA repo TYPE RESPONSE FOR REPORTED LATE zr_tmm_1006.
    DATA:
      is_error   TYPE abap_boolean,
      lv_msg     TYPE string,
      lv_message TYPE string.
    " 读取传入的值，在传入的值的基础上新增值
    IF failed IS SUPPLIED.
      ASSIGN failed TO FIELD-SYMBOL(<failed>).
      fail-purchasereq = <failed>-('purchasereq').
    ENDIF.
    IF reported IS SUPPLIED.
      ASSIGN reported TO FIELD-SYMBOL(<reported>).
      repo-purchasereq = <reported>-('purchasereq').
    ENDIF.

    TYPES: BEGIN OF ty_required_field,
             companycode     TYPE bukrs,
             field           TYPE string,
             field_name(220) TYPE c,
           END OF ty_required_field.
    DATA required_fields TYPE TABLE OF ty_required_field.
    CONSTANTS: lv_company1 TYPE bukrs VALUE '1100',
               lv_company2 TYPE bukrs VALUE '1400'.
    required_fields = VALUE #(  ( companycode = lv_company1 field = 'ApplyDepart' field_name = TEXT-016 )
                                ( companycode = lv_company1 field = 'OrderType' field_name = TEXT-003 )
                                ( companycode = lv_company1 field = 'IsLink' field_name = TEXT-004 )
                                ( companycode = lv_company1 field = 'IsApprove' field_name = TEXT-017 )
                                ( companycode = lv_company1 field = 'Supplier' field_name = TEXT-005 )
                                ( companycode = lv_company1 field = 'CompanyCode' field_name = TEXT-006 )
                                ( companycode = lv_company1 field = 'PurchaseOrg' field_name = TEXT-007 )
                                ( companycode = lv_company1 field = 'PurchaseGrp' field_name = TEXT-008 )
                                ( companycode = lv_company1 field = 'MatId' field_name = TEXT-009 )
                                ( companycode = lv_company1 field = 'Quantity' field_name = TEXT-010 )
                                ( companycode = lv_company1 field = 'Price' field_name = TEXT-011 )
                                ( companycode = lv_company1 field = 'Kyoten' field_name = TEXT-015 )
                                ( companycode = lv_company1 field = 'BuyPurpoose' field_name = TEXT-014 )
                                ( companycode = lv_company1 field = 'PolinkBy' field_name = TEXT-018 )
                                ( companycode = lv_company1 field = 'PrBy' field_name = TEXT-019 ) ).

    required_fields = VALUE #( BASE required_fields
                                ( companycode = lv_company2 field = 'ApplyDepart' field_name = TEXT-016 )
                                ( companycode = lv_company2 field = 'OrderType' field_name = TEXT-003 )
                                ( companycode = lv_company2 field = 'IsLink' field_name = TEXT-004 )
                                ( companycode = lv_company2 field = 'IsApprove' field_name = TEXT-017 )
                                ( companycode = lv_company2 field = 'Supplier' field_name = TEXT-005 )
                                ( companycode = lv_company2 field = 'CompanyCode' field_name = TEXT-006 )
                                ( companycode = lv_company2 field = 'PurchaseOrg' field_name = TEXT-007 )
                                ( companycode = lv_company2 field = 'PurchaseGrp' field_name = TEXT-008 )
                                ( companycode = lv_company2 field = 'MatId' field_name = TEXT-009 )
                                ( companycode = lv_company2 field = 'Quantity' field_name = TEXT-010 )
                                ( companycode = lv_company2 field = 'Price' field_name = TEXT-011 )
                                ( companycode = lv_company2 field = 'PolinkBy' field_name = TEXT-018 )
                                ( companycode = lv_company2 field = 'PrBy' field_name = TEXT-019 ) ).
    LOOP AT records ASSIGNING FIELD-SYMBOL(<record>).
      " 没起作用，不知为何前端状态消息不会自动清除，添加清除状态消息的代码也不起作用
*      APPEND VALUE #( %key     = <record>-('%key')
*                      %state_area = 'required' ) TO repo-purchasereq.

      CLEAR lv_message.
      is_error = abap_false.
      "不同公司检查逻辑不通，所以先要检查公司代码
      IF <record>-('CompanyCode') IS INITIAL.
        is_error = abap_true.
        " 明细界面单条值处理时会用到此消息
        add_reported(
          EXPORTING
            record    = <record>
            target    = 'CompanyCode'
            id        = 'ZMM_001'
            number    = '009'
            severity  = cl_abap_behv=>ms-error
            v1        = TEXT-006
          CHANGING
            reported  = repo ).
        " excel批量导入时，通过action调用会用到此消息
        MESSAGE e009(zmm_001) WITH TEXT-006 INTO lv_msg.
        lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
      ELSE.
        LOOP AT required_fields INTO DATA(required) WHERE companycode = <record>-('CompanyCode') .
          IF <record>-(required-field) IS INITIAL.
            is_error = abap_true.
            " 明细界面单条值处理时会用到此消息
            add_reported(
              EXPORTING
                record    = <record>
                target    = required-field
                id        = 'ZMM_001'
                number    = '009'
                severity  = cl_abap_behv=>ms-error
                v1        = required-field_name
              CHANGING
                reported  = repo ).
            " excel批量导入时，通过action调用会用到此消息
            MESSAGE e009(zmm_001) WITH required-field_name INTO lv_msg.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
          ENDIF.
        ENDLOOP.
      ENDIF.

      " 标识当前行有错误
      IF is_error = abap_true.
        <record>-('type')     = 'E'.
        <record>-('message')  = lv_message.
      ENDIF.
      IF reported IS SUPPLIED.
        <reported>-('purchasereq') = repo-purchasereq.
      ENDIF.
      IF failed IS SUPPLIED.
        IF is_error = abap_true.
          APPEND VALUE #( %tky = <record>-('%key') ) TO fail-purchasereq.
        ENDIF.
        <failed>-('purchasereq') = fail-purchasereq.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  "批导数据和单条处理共用一个数据校验。批导数据时record中没有%key，此方法通过trycatch防止程序中断
  "为什么不在外层添加消息时判断？因为要添加消息的地方很多，那么每个消息都需要判断
  METHOD add_reported.
    DATA repo TYPE RESPONSE FOR REPORTED LATE zr_tmm_1006.
    ASSIGN reported TO FIELD-SYMBOL(<reported>).
    repo-purchasereq = <reported>-('purchasereq').
    " 新增一个空行，通过往空行中添加达到使用FIELD-SYMBOL新增行的目的
    APPEND INITIAL LINE TO repo-purchasereq ASSIGNING FIELD-SYMBOL(<repo_line>).
    TRY.
        ASSIGN record TO  FIELD-SYMBOL(<fs_record>).
        <repo_line>-('%key') = <fs_record>-('%key').

        ASSIGN <repo_line>-('%element') TO FIELD-SYMBOL(<element>).
        DATA(ref_element) = REF #( <element> ).
        ASSIGN ref_element->(target)  TO FIELD-SYMBOL(<target>).
        <target> = if_abap_behv=>mk-on.
        <repo_line>-('%msg') = new_message(
                                  id        = id
                                  number    = number
                                  severity  = severity
                                  v1        = v1
                                  v2        = v2
                                  v3        = v3
                                  v4        = v4 ).
      CATCH cx_root INTO DATA(e).

    ENDTRY.
    <reported>-('purchasereq') = repo-purchasereq.
  ENDMETHOD.

  METHOD get_prno.
    DATA utils TYPE REF TO zzcl_common_utils.
    DATA lv_datum TYPE datum.
    DATA prefix(3) TYPE c.
    utils = NEW #( ).

    "确认前缀
    CLEAR prefix.
    CASE prtype.
      WHEN '1'."購入依頼書
        prefix = 'EKO'.
      WHEN '2'."物品請求書
        CASE kyoten.
          WHEN '1'."本社
            prefix = 'EHO'.
          WHEN '2'."埼玉工場
            prefix = 'ESA'.
          WHEN '3'."九州工場
            prefix = 'EKY'.
          WHEN '4'."宮崎工場
            prefix = 'EMI'.
          WHEN '5'."佐賀工場
            prefix = 'ESG'.
        ENDCASE.
      WHEN '3'."製作指示書
        prefix = 'ESE'.
    ENDCASE.
    CHECK prefix IS NOT INITIAL.
    "get_number_next获得的流水号是根据每天流水的，但我们需要每月的流水所以每次只传当月1号
    lv_datum = cl_abap_context_info=>get_system_date( ).
    lv_datum = lv_datum(6) && '01'.
    TRY.
        DATA(lv_prno) = utils->get_number_next(
                      iv_object = CONV ztbc_1002-object( prefix )
                      iv_datum  = lv_datum
                      iv_nrlen  = 3 ).
      CATCH zzcx_custom_exception INTO DATA(exc).
        RAISE EXCEPTION exc.
    ENDTRY.
    prno = prefix && lv_prno+2(4) && lv_prno+8(3).
  ENDMETHOD.

  METHOD createpurchaseorder.
    DATA records TYPE TABLE OF zc_tmm_1006.
    DATA lt_mm1006 TYPE TABLE OF zr_tmm_1006.
    DATA record_temp LIKE LINE OF records.
    DATA lv_json TYPE /ui2/cl_json=>json.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).
    ENDLOOP.

    READ ENTITIES OF zr_tmm_1006 IN LOCAL MODE
      ENTITY purchasereq
      ALL FIELDS
      WITH CORRESPONDING  #( records )
      RESULT DATA(lt_result).

    "数据校验
    DATA lv_msg TYPE string.
    DATA is_error TYPE abap_boolean.
    is_error = abap_false.
    LOOP AT lt_result INTO DATA(ls_result).
      IF ls_result-islink <> '1'.
        is_error = abap_true.
        ls_result-type = 'E'.
        MESSAGE e019(zmm_001) WITH ls_result-prno ls_result-pritem INTO lv_msg.
        ls_result-message = zzcl_common_utils=>merge_message( iv_message1 = ls_result-message
                                                              iv_message2 = lv_msg
                                                              iv_symbol   = ';' ).
      ENDIF.
      " 只有审批完成的才可以生成PO
      IF ls_result-approvestatus <> '3'."承認済
        is_error = abap_true.
        ls_result-type = 'E'.
        MESSAGE e028(zmm_001) INTO lv_msg.
        ls_result-message = zzcl_common_utils=>merge_message( iv_message1 = ls_result-message
                                                              iv_message2 = lv_msg
                                                              iv_symbol   = ';' ).
      ENDIF.
      IF ls_result-purchaseorder IS NOT INITIAL.
        is_error = abap_true.
        ls_result-type = 'E'.
        MESSAGE e020(zmm_001) INTO lv_msg.
        ls_result-message = zzcl_common_utils=>merge_message( iv_message1 = ls_result-message
                                                              iv_message2 = lv_msg
                                                              iv_symbol   = ';' ).
      ENDIF.

      MODIFY lt_result FROM ls_result.
    ENDLOOP.
    IF is_error = abap_true.
      "返回结果
      lv_json = /ui2/cl_json=>serialize( lt_result ).
      APPEND VALUE #( %cid    = keys[ 1 ]-%cid
                      %param  = VALUE #( zzkey = lv_json ) ) TO result.
      EXIT.
    ENDIF.
    TYPES:
      "PO行项目计划行
      BEGIN OF ty_schedule_line,
        purchase_order_item          TYPE i_purchaseordschedulelinetp_2-purchaseorderitem,
        schedule_line                TYPE i_purchaseordschedulelinetp_2-scheduleline,
        schedule_line_delivery_date  TYPE i_purchaseordschedulelinetp_2-schedulelinedeliverydate,
        schedule_line_order_quantity TYPE i_purchaseordschedulelinetp_2-schedulelineorderquantity,
        purchase_order_quantity_unit TYPE i_purchaseordschedulelinetp_2-purchaseorderquantityunit,
      END OF ty_schedule_line,
      "PO行项目科目分配
      BEGIN OF ty_account_assignment,
        purchase_order_item        TYPE i_purordaccountassignmenttp_2-purchaseorderitem,
        account_assignment_number  TYPE i_purordaccountassignmenttp_2-accountassignmentnumber,
        cost_center                TYPE i_purordaccountassignmenttp_2-costcenter,
        g_l_account                TYPE i_purordaccountassignmenttp_2-glaccount,
        w_b_s_element_internal_i_d TYPE i_purordaccountassignmenttp_2-wbselementinternalid,
        master_fixed_asset         TYPE i_purordaccountassignmenttp_2-masterfixedasset,
        tax_code                   TYPE i_purordaccountassignmenttp_2-taxcode,
      END OF ty_account_assignment,
      "PO行项目长文本
      BEGIN OF ty_item_note,
        purchase_order_item TYPE i_purchaseorderitemnotetp_2-purchaseorderitem,
        text_object_type    TYPE i_purchaseorderitemnotetp_2-textobjecttype,
        language            TYPE i_purchaseorderitemnotetp_2-language,
        plain_long_text     TYPE i_purchaseorderitemnotetp_2-plainlongtext,
      END OF ty_item_note,
      "PO行项目结构
      BEGIN OF ty_purchase_order_item,
        purchase_order_item          TYPE i_purchaseorderitemtp_2-purchaseorderitem,
        material                     TYPE i_purchaseorderitemtp_2-material,
        purchase_order_item_text     TYPE i_purchaseorderitemtp_2-purchaseorderitemtext,
        account_assignment_category  TYPE i_purchaseorderitemtp_2-accountassignmentcategory,
        purchase_order_item_category TYPE i_purchaseorderitemtp_2-purchaseorderitemcategory,
        order_quantity               TYPE i_purchaseorderitemtp_2-orderquantity,
        plant                        TYPE i_purchaseorderitemtp_2-plant,
        storage_location             TYPE i_purchaseorderitemtp_2-storagelocation,
        material_group               TYPE i_purchaseorderitemtp_2-materialgroup,
        purchase_order_quantity_unit TYPE i_purchaseorderitemtp_2-purchaseorderquantityunit,
        net_price_amount             TYPE i_purchaseorderitemtp_2-netpriceamount,
        document_currency            TYPE i_purchaseorderitemtp_2-documentcurrency,
        net_price_quantity           TYPE i_purchaseorderitemtp_2-netpricequantity,
        order_price_unit             TYPE i_purchaseorderitemtp_2-orderpriceunit,
        is_returns_item(5)           TYPE c,
        is_free_of_charge(5)         TYPE c,
        requisitioner_name           TYPE i_purchaseorderitemtp_2-requisitionername,
        requirement_tracking         TYPE i_purchaseorderitemtp_2-requirementtracking,
        international_article_number TYPE i_purchaseorderitemtp_2-internationalarticlenumber,
        to_schedule_line             TYPE TABLE OF ty_schedule_line WITH DEFAULT KEY,
        to_account_assignment        TYPE TABLE OF ty_account_assignment WITH DEFAULT KEY,
        to_item_note                 TYPE TABLE OF ty_item_note WITH DEFAULT KEY,
      END OF ty_purchase_order_item,
      "PO抬头结构
      BEGIN OF ty_purchase_order,
        purchase_order               TYPE i_purchaseordertp_2-purchaseorder,
        purchase_order_type          TYPE i_purchaseordertp_2-purchaseordertype,
        purchase_order_date          TYPE i_purchaseordertp_2-purchaseorderdate,
        company_code                 TYPE i_purchaseordertp_2-companycode,
        purchasing_organization      TYPE i_purchaseordertp_2-purchasingorganization,
        purchasing_group             TYPE i_purchaseordertp_2-purchasinggroup,
        supplier                     TYPE i_purchaseordertp_2-supplier,
        document_currency            TYPE i_purchaseordertp_2-documentcurrency,
        correspnc_internal_reference TYPE i_purchaseordertp_2-correspncinternalreference,
        to_purchase_order_item       TYPE TABLE OF ty_purchase_order_item WITH DEFAULT KEY,
      END OF ty_purchase_order,
      " 这种格式的可能只适用于odata v2的api
*      BEGIN OF ty_response,
*        d TYPE ty_purchase_order,
*      END OF ty_response.
      BEGIN OF ty_response,
        purchaseorder TYPE ebeln,
      END OF ty_response.

    TYPES:
      BEGIN OF ty_details,
        code    TYPE string,
        message TYPE string,
      END OF ty_details,
      BEGIN OF ty_message,
        code    TYPE string,
        message TYPE string,
        details TYPE TABLE OF ty_details WITH DEFAULT KEY,
      END OF ty_message,
      BEGIN OF ty_error_v4,
        error TYPE ty_message,
      END OF ty_error_v4.
    DATA: ls_request  TYPE ty_purchase_order,
          lt_request  TYPE TABLE OF ty_purchase_order,
          ls_item     TYPE ty_purchase_order_item,
          ls_response TYPE ty_response,
          ls_error    TYPE ty_error_v4.

    "去重数据，得到抬头数据
    DATA(records_key) = records.
    SORT records_key BY prno.
    DELETE ADJACENT DUPLICATES FROM records_key COMPARING prno.


    DATA is_returns_item(5) TYPE c.
    DATA is_free_of_charge(5) TYPE c.
    DATA lv_message TYPE string.
    "填充request数据
    LOOP AT records_key INTO DATA(record_key).
      "抬头数据
      ls_request-purchase_order_type = record_key-ordertype.
      ls_request-purchase_order_date = cl_abap_context_info=>get_system_date( ).
      ls_request-company_code = record_key-companycode.
      ls_request-purchasing_organization = record_key-purchaseorg.
      ls_request-purchasing_group = record_key-purchasegrp.
      ls_request-supplier = record_key-supplier.
      ls_request-document_currency = record_key-currency.
      ls_request-correspnc_internal_reference = record_key-polinkby.
      "行项目数据
      CLEAR ls_request-to_purchase_order_item.
      CLEAR lt_mm1006.
      LOOP AT records INTO record_temp WHERE prno = record_key-prno.
        IF record_temp-returnitem IS NOT INITIAL.
          is_returns_item = 'true'.
        ELSE.
          is_returns_item = 'false'.
        ENDIF.
        IF record_temp-free IS NOT INITIAL.
          is_free_of_charge = 'true'.
        ELSE.
          is_free_of_charge = 'false'.
        ENDIF.
        "行项目数据
        APPEND VALUE #( purchase_order_item           = sy-tabix
                        material                      = record_temp-matid
                        purchase_order_item_text      = record_temp-matdesc
                        account_assignment_category   = record_temp-accounttype
                        purchase_order_item_category  = record_temp-itemcategory
                        order_quantity                = record_temp-quantity
                        plant                         = record_temp-plant
                        storage_location              = record_temp-location
                        material_group                = record_temp-materialgroup
                        purchase_order_quantity_unit  = record_temp-unit
                        net_price_amount              = record_temp-price
                        document_currency             = record_temp-currency
                        net_price_quantity            = record_temp-unitprice
                        order_price_unit              = record_temp-unit
                        is_returns_item               = is_returns_item
                        is_free_of_charge             = is_free_of_charge
                        requisitioner_name            = record_temp-prby
                        requirement_tracking          = record_temp-prno
                        international_article_number  = record_temp-ean
                        "计划行
                        to_schedule_line = VALUE #( ( purchase_order_item = sy-tabix
                                                      schedule_line = 1
                                                      schedule_line_delivery_date = record_temp-deliverydate
                                                      schedule_line_order_quantity = record_temp-quantity
                                                      purchase_order_quantity_unit = record_temp-unit ) )
                        "科目分配
                        to_account_assignment = VALUE #( (  purchase_order_item = sy-tabix
                                                            account_assignment_number = 1
                                                            cost_center = record_temp-costcenter
                                                            g_l_account = record_temp-glaccount
                                                            w_b_s_element_internal_i_d = record_temp-wbselemnt
                                                            master_fixed_asset = record_temp-assetno
                                                            tax_code = record_temp-tax ) )
                        "行项目长文本
                        to_item_note = VALUE #( ( purchase_order_item = sy-tabix
                                                  text_object_type = 'F01'
                                                  language = sy-langu
                                                  plain_long_text = record_temp-itemtext ) )
                         ) TO ls_request-to_purchase_order_item.
        record_temp-purchaseorderitem = sy-tabix.
        MODIFY records FROM record_temp.
        APPEND VALUE #( uuid = record_temp-uuid purchaseorderitem = record_temp-purchaseorderitem ) TO lt_mm1006.
      ENDLOOP.
*      APPEND ls_request TO lt_request.
*      CLEAR ls_request.

      "将abap数据转换成json格式，同时json格式区分大小写,所以通过underscore_to_pascal_case将下划线之后的字符大写
      DATA(lv_requestbody) = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).

      REPLACE ALL OCCURRENCES OF `IsFreeOfCharge`           IN lv_requestbody  WITH `PurchasingItemIsFreeOfCharge`.
      REPLACE ALL OCCURRENCES OF `ToPurchaseOrderItem`      IN lv_requestbody  WITH `_PurchaseOrderItem`.
      REPLACE ALL OCCURRENCES OF `ToScheduleLine`           IN lv_requestbody  WITH `_PurchaseOrderScheduleLineTP`.
      REPLACE ALL OCCURRENCES OF `ToAccountAssignment`      IN lv_requestbody  WITH `_PurOrdAccountAssignment`.
      REPLACE ALL OCCURRENCES OF `ToItemNote`               IN lv_requestbody  WITH `_PurchaseOrderItemNote`.
      REPLACE ALL OCCURRENCES OF `"false"`                  IN lv_requestbody  WITH `false`.
      REPLACE ALL OCCURRENCES OF `"true"`                   IN lv_requestbody  WITH `true`.

      DATA(lv_path) = |/api_purchaseorder_2/srvd_a2x/sap/purchaseorder/0001/PurchaseOrder?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

      zzcl_common_utils=>request_api_v4( EXPORTING iv_path        = lv_path
                                                   iv_method      = if_web_http_client=>post
                                                   iv_body        = lv_requestbody
                                         IMPORTING ev_status_code = DATA(lv_status_code)
                                                   ev_response    = DATA(lv_response) ).
      IF lv_status_code = 201.
*        xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
*          ( xco_cp_json=>transformation->pascal_case_to_underscore )
*          ( xco_cp_json=>transformation->boolean_to_abap_bool )
*        ) )->write_to( REF #( ls_response ) ).
        /ui2/cl_json=>deserialize(  EXPORTING json = lv_response
                                    CHANGING  data = ls_response ).
        "返回消息文本
        " 購買伝票登録成功しました。
        MESSAGE s018(zmm_001) WITH ls_response-purchaseorder INTO lv_message.
        record_temp-type = 'S'.
        record_temp-message = lv_message.
        record_temp-purchaseorder = ls_response-purchaseorder.
        " PO创建成功后需要更改审批状态为4送信済
        record_temp-approvestatus = '4'.
        MODIFY records FROM record_temp TRANSPORTING type message purchaseorder approvestatus WHERE prno = record_key-prno.

        "将PO号更新到ZTMM_1006
        MODIFY ENTITIES OF zr_tmm_1006 IN LOCAL MODE
        ENTITY purchasereq
        UPDATE FIELDS ( purchaseorder purchaseorderitem )
        WITH CORRESPONDING #( records ).
      ELSE.
        /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                   CHANGING  data = ls_error ).
        record_temp-type = 'E'.
        IF ls_error-error-message IS NOT INITIAL.
          record_temp-message = ls_error-error-message.
        ELSEIF ls_error-error-code IS NOT INITIAL.
          SPLIT ls_error-error-code AT '/' INTO TABLE DATA(lt_msg).
          IF lines( lt_msg ) = 2.
            DATA(lv_msg_class) = lt_msg[ 1 ].
            DATA(lv_msg_number) = lt_msg[ 2 ].
            MESSAGE ID lv_msg_class TYPE 'S' NUMBER lv_msg_number INTO record_temp-message.
          ENDIF.
        ENDIF.
        "/IWCOR/CX_OD_BAD_REQUEST/005056A509B11ED1B9BF94F386DD82E6
        "ls_error-message-details内表中的消息会有多个，可以排除/IWCOR/CX_OD_BAD_REQUEST/  对判断错误起不到作用
        MODIFY records FROM record_temp TRANSPORTING type message WHERE prno = record_key-prno.
      ENDIF.
    ENDLOOP.

    "返回结果
    lv_json = /ui2/cl_json=>serialize( records ).
    APPEND VALUE #( %cid    = keys[ 1 ]-%cid
                    %param  = VALUE #( zzkey = lv_json ) ) TO result.

  ENDMETHOD.

ENDCLASS.
