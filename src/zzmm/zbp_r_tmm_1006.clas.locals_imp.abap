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
    METHODS handlefile FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~handlefile RESULT result.
    METHODS deletepr FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~deletepr RESULT result.
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
                      orderid
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
*                                ( companycode = lv_company1 field = 'MatId' field_name = TEXT-009 )
                                ( companycode = lv_company1 field = 'Quantity' field_name = TEXT-010 )
                                ( companycode = lv_company1 field = 'Price' field_name = TEXT-011 )
                                ( companycode = lv_company1 field = 'Kyoten' field_name = TEXT-015 )
                                ( companycode = lv_company1 field = 'BuyPurpoose' field_name = TEXT-014 )
                                ( companycode = lv_company1 field = 'PolinkBy' field_name = TEXT-018 )
                                ( companycode = lv_company1 field = 'PrBy' field_name = TEXT-019 )
                                ( companycode = lv_company1 field = 'UnitPrice' field_name = TEXT-025 ) ). " ADD BY XINLEI XU 2025/05/15

    required_fields = VALUE #( BASE required_fields
                                ( companycode = lv_company2 field = 'ApplyDepart' field_name = TEXT-016 )
                                ( companycode = lv_company2 field = 'OrderType' field_name = TEXT-003 )
                                ( companycode = lv_company2 field = 'IsLink' field_name = TEXT-004 )
                                ( companycode = lv_company2 field = 'IsApprove' field_name = TEXT-017 )
                                ( companycode = lv_company2 field = 'Supplier' field_name = TEXT-005 )
                                ( companycode = lv_company2 field = 'CompanyCode' field_name = TEXT-006 )
                                ( companycode = lv_company2 field = 'PurchaseOrg' field_name = TEXT-007 )
                                ( companycode = lv_company2 field = 'PurchaseGrp' field_name = TEXT-008 )
*                                ( companycode = lv_company2 field = 'MatId' field_name = TEXT-009 )
                                ( companycode = lv_company2 field = 'Quantity' field_name = TEXT-010 )
                                ( companycode = lv_company2 field = 'Price' field_name = TEXT-011 )
                                ( companycode = lv_company2 field = 'PolinkBy' field_name = TEXT-018 )
                                ( companycode = lv_company2 field = 'PrBy' field_name = TEXT-019 )
                                ( companycode = lv_company2 field = 'UnitPrice' field_name = TEXT-025 ) ). " ADD BY XINLEI XU 2025/05/15
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
        " 单字段必输校验
        LOOP AT required_fields INTO DATA(required) WHERE companycode = <record>-('CompanyCode') .
*&--ADD BEGIN BY XINLEI XU 2025/02/24
          IF required-field = 'BuyPurpoose' AND <record>-('PrType') <> '1'.
            CONTINUE.
          ENDIF.
*&--ADD END BY XINLEI XU 2025/02/24

*&--ADD BEGIN BY XINLEI XU 2025/04/22 CR#4359 当购买申请类型=4时，依頼部署，拠点，購買依頼者、購入目的，四个字段不需要做必输性检查
          IF <record>-('PrType') = '4' AND ( required-field = 'ApplyDepart' OR
                                             required-field = 'Kyoten' OR
                                             required-field = 'PrBy' OR
                                             required-field = 'BuyPurpoose' ).
            CONTINUE.
          ENDIF.
*&--ADD END BY XINLEI XU 2025/04/22 CR#4359

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
        "组合字段必输校验
        IF <record>-('CompanyCode') = '1400' OR <record>-('CompanyCode') = '1100'.
          IF <record>-('AccountType') IS INITIAL AND <record>-('MatId') IS INITIAL AND <record>-('SupplierMat') IS INITIAL.
            is_error = abap_true.
            " 明细界面单条值处理时会用到此消息
            add_reported(
              EXPORTING
                record    = <record>
                target    = required-field
                id        = 'ZMM_001'
                number    = '035'
                severity  = cl_abap_behv=>ms-error
              CHANGING
                reported  = repo ).
            " excel批量导入时，通过action调用会用到此消息
            MESSAGE e035(zmm_001) INTO lv_msg.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
          ELSEIF <record>-('AccountType') IS NOT INITIAL AND
            <record>-('MatId') IS INITIAL AND <record>-('SupplierMat') IS INITIAL AND <record>-('MatDesc') IS INITIAL.
            is_error = abap_true.
            " 明细界面单条值处理时会用到此消息
            add_reported(
              EXPORTING
                record    = <record>
                target    = required-field
                id        = 'ZMM_001'
                number    = '036'
                severity  = cl_abap_behv=>ms-error
              CHANGING
                reported  = repo ).
            " excel批量导入时，通过action调用会用到此消息
            MESSAGE e036(zmm_001) INTO lv_msg.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
            " 根据客户物料和供应商查找SAP物料
          ELSEIF <record>-('MatId') IS INITIAL AND <record>-('SupplierMat') IS NOT INITIAL.
            DATA lv_suppliermat TYPE i_purchasinginforecordapi01-suppliermaterialnumber.
            DATA lv_supplier TYPE lifnr.

            lv_supplier = <record>-('Supplier').
            lv_supplier = |{ lv_supplier ALPHA = IN }|.
            lv_suppliermat = <record>-('SupplierMat').
            SELECT
              material,
              supplier,
              suppliermaterialnumber
            FROM i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS _purhcasinginforecord
            WHERE suppliermaterialnumber = @lv_suppliermat
              AND supplier = @lv_supplier
              AND isdeleted = ''
            INTO TABLE @DATA(lt_material).
            IF lines( lt_material ) <> 1.
              is_error = abap_true.
              " 明细界面单条值处理时会用到此消息
              add_reported(
                EXPORTING
                  record    = <record>
                  target    = required-field
                  id        = 'ZMM_001'
                  number    = '034'
                  severity  = cl_abap_behv=>ms-error
                  v1        = <record>-('SupplierMat')
                  v2        = <record>-('Supplier')
                CHANGING
                  reported  = repo ).
              " excel批量导入时，通过action调用会用到此消息
              MESSAGE e034(zmm_001) WITH <record>-('SupplierMat') <record>-('Supplier') INTO lv_msg.
              lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
            ELSE.
              READ TABLE lt_material INTO DATA(ls_material) INDEX 1.
              IF sy-subrc = 0.
                <record>-('MatId') = ls_material-material.
              ENDIF.
            ENDIF.
          ENDIF.

*&--ADD BEGIN BY XINLEI XU 2025/04/07 CR#4358
          CASE <record>-('AccountType').
            WHEN 'A'.
              " 勘定設定カテゴリはAですので、G/L勘定と資産番号を入力してください。
              IF <record>-('GlAccount') IS INITIAL OR <record>-('AssetNo') IS INITIAL.
                is_error = abap_true.
                MESSAGE e037(zmm_001) WITH <record>-('AccountType') TEXT-020 INTO lv_msg.
                lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
              ENDIF.

            WHEN 'F'.
              " 勘定設定カテゴリはFですので、G/L勘定と指図番号を入力してください。
              IF <record>-('GlAccount') IS INITIAL OR <record>-('OrderId') IS INITIAL.
                is_error = abap_true.
                MESSAGE e037(zmm_001) WITH <record>-('AccountType') TEXT-021 INTO lv_msg.
                lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
              ENDIF.

            WHEN 'K' OR 'X'.
              " 勘定設定カテゴリはK、Xですので、G/L勘定と原価センタを入力してください。
              IF <record>-('GlAccount') IS INITIAL OR <record>-('CostCenter') IS INITIAL.
                is_error = abap_true.
                MESSAGE e037(zmm_001) WITH <record>-('AccountType') TEXT-022 INTO lv_msg.
                lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
              ENDIF.

            WHEN 'P'.
              " 勘定設定カテゴリはPですので、G/L勘定とWBS要素を入力してください。
              IF <record>-('GlAccount') IS INITIAL OR <record>-('WbsElemnt') IS INITIAL.
                is_error = abap_true.
                MESSAGE e037(zmm_001) WITH <record>-('AccountType') TEXT-023 INTO lv_msg.
                lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
              ENDIF.

            WHEN OTHERS.
          ENDCASE.

          IF <record>-('CompanyCode') = '1100' AND <record>-('OrderType') = 'ZB90' AND <record>-('ReturnItem') IS INITIAL.
            is_error = abap_true.
            MESSAGE e038(zmm_001) INTO lv_msg.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
          ENDIF.

          IF <record>-('CompanyCode') = '1400' AND <record>-('OrderType') = 'ZH90' AND <record>-('ReturnItem') IS INITIAL.
            is_error = abap_true.
            MESSAGE e038(zmm_001) INTO lv_msg.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
          ENDIF.
*&--ADD END BY XINLEI XU 2025/04/07 CR#4358

*&--ADD BEGIN BY XINLEI XU 2025/04/23 CR#4359 当购买申请类型=4、承認要否≠2时报错
          IF <record>-('PrType') = '4' AND <record>-('IsApprove') <> '2'.
            is_error = abap_true.
            MESSAGE e039(zmm_001) INTO lv_msg.
            lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
          ENDIF.
*&--ADD END BY XINLEI XU 2025/04/23 CR#4359
        ENDIF.

*&--ADD BEGIN BY XINLEI XU 2025/05/15
        IF <record>-('IsApprove') = '1' AND <record>-('Currency') IS INITIAL. " 承認要 通貨コード 必输
          is_error = abap_true.
          MESSAGE e009(zmm_001) WITH TEXT-024 INTO lv_msg.
          lv_message = zzcl_common_utils=>merge_message( iv_message1 = lv_message iv_message2 = lv_msg iv_symbol = ';' ).
        ENDIF.
*&--ADD END BY XINLEI XU 2025/05/15
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
      CATCH cx_root INTO DATA(e) ##NO_HANDLER.

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
*&--ADD BEGIN BY XINLEI XU 2025/04/22 CR#4359
      WHEN '4'."調達G専用
        prefix = 'PUR'.
*&--ADD END BY XINLEI XU 2025/04/22 CR#4359
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
      IF ls_result-approvestatus <> '3' AND ls_result-approvestatus <> '4'."承認済,送信済
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
*&--MOD BEGIN BY XINLEI XU 2025/01/17 WBSElementInternalID Obsolete
*        w_b_s_element_internal_i_d TYPE i_purordaccountassignmenttp_2-wbselementinternalid,
        w_b_s_element_external_i_d TYPE i_purordaccountassignmenttp_2-wbselementexternalid,
*&--MOD END BY XINLEI XU 2025/01/17
        master_fixed_asset         TYPE i_purordaccountassignmenttp_2-masterfixedasset,
        tax_code                   TYPE i_purordaccountassignmenttp_2-taxcode,
        order_i_d                  TYPE i_purordaccountassignmenttp_2-orderid,
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
        tax_code                     TYPE i_purchaseorderitemtp_2-taxcode,
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

    DATA: ls_request     TYPE ty_purchase_order,
          lt_request     TYPE TABLE OF ty_purchase_order,
          ls_item        TYPE ty_purchase_order_item,
          ls_response    TYPE ty_response,
          lv_requestbody TYPE string.

    "去重数据，得到抬头数据
    DATA(records_key) = records.
    SORT records_key BY ordertype supplier companycode purchaseorg purchasegrp currency.
    DELETE ADJACENT DUPLICATES FROM records_key COMPARING ordertype supplier companycode purchaseorg purchasegrp currency.

*&--ADD BEGIN BY XINLEI XU 2025/02/13
    IF records IS NOT INITIAL.
      DATA(lt_records_temp) = records.
      LOOP AT lt_records_temp ASSIGNING FIELD-SYMBOL(<lfs_records_temp>).
        <lfs_records_temp>-matid = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = <lfs_records_temp>-matid ).
        <lfs_records_temp>-supplier = |{ <lfs_records_temp>-supplier ALPHA = IN }|.
      ENDLOOP.
      SELECT i_product~product,
             i_product~productgroup,
             i_product~baseunit,
             i_producttext~productname
        FROM i_product WITH PRIVILEGED ACCESS
        LEFT OUTER JOIN i_producttext WITH PRIVILEGED ACCESS ON i_producttext~product  = i_product~product
                                                            AND i_producttext~language = @sy-langu
         FOR ALL ENTRIES IN @lt_records_temp
       WHERE i_product~product = @lt_records_temp-matid
        INTO TABLE @DATA(lt_product).
      SORT lt_product BY product.

      SELECT product,
             plant,
             dfltstoragelocationextprocmt AS storagelocation " 外部調達の保管場所
        FROM i_productsupplyplanning WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_records_temp
       WHERE product = @lt_records_temp-matid
         AND plant = @lt_records_temp-plant
        INTO TABLE @DATA(lt_product_location).
      SORT lt_product_location BY product plant.

      SELECT a~purchasinginforecord,
             a~material,
             a~supplier,
             b~plant,
             b~purchasingorganization,
             b~taxcode,
             b~currency
        FROM i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS a
        LEFT OUTER JOIN i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS AS b
                     ON b~purchasinginforecord = a~purchasinginforecord
         FOR ALL ENTRIES IN @lt_records_temp
       WHERE a~material = @lt_records_temp-matid
         AND a~supplier = @lt_records_temp-supplier
         AND a~isdeleted IS INITIAL
         AND b~plant = @lt_records_temp-plant
         AND b~purchasingorganization = @lt_records_temp-purchaseorg
         AND b~ismarkedfordeletion IS INITIAL
        INTO TABLE @DATA(lt_purinfo_record).
      SORT lt_purinfo_record BY material supplier plant purchasingorganization.
    ENDIF.
*&--ADD END BY XINLEI XU 2025/02/13

    DATA is_returns_item(5) TYPE c.
    DATA is_free_of_charge(5) TYPE c.
    DATA lv_message TYPE string.
    DATA lv_order_item TYPE i.
    DATA lv_item TYPE i.
    "填充request数据

*&--ADD BEGIN BY XINLEI XU 2025/04/16 CR#4357
    DATA(lv_path) = |/api_purchaseorder_2/srvd_a2x/sap/purchaseorder/0001/PurchaseOrder?sap-language={ zzcl_common_utils=>get_current_language(  ) }|.

    READ TABLE records INTO DATA(record) INDEX 1.
    IF sy-subrc = 0 AND record-companycode = '1400'.
      LOOP AT records INTO record.
        "抬头数据
        CLEAR ls_request.
        ls_request-purchase_order_type = record-ordertype.
        ls_request-purchase_order_date = cl_abap_context_info=>get_system_date( ).
        ls_request-company_code = record-companycode.
        ls_request-purchasing_organization = record-purchaseorg.
        ls_request-purchasing_group = record-purchasegrp.
        ls_request-supplier = record-supplier.
        ls_request-document_currency = record-currency.
        ls_request-correspnc_internal_reference = record-polinkby.

        "行项目数据
        lv_order_item = 10.

        IF record-returnitem IS NOT INITIAL.
          is_returns_item = 'true'.
        ELSE.
          is_returns_item = 'false'.
        ENDIF.
        IF record-free IS NOT INITIAL.
          is_free_of_charge = 'true'.
        ELSE.
          is_free_of_charge = 'false'.
        ENDIF.

        DATA(lv_matid) = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = record-matid ).
        DATA(lv_supplier) = |{ record-supplier ALPHA = IN }|.

        READ TABLE lt_product INTO DATA(ls_product) WITH KEY product = lv_matid BINARY SEARCH.
        IF sy-subrc = 0.
          record-matdesc = COND #( WHEN record-matdesc IS NOT INITIAL THEN record-matdesc ELSE ls_product-productname ).
          record-materialgroup = COND #( WHEN record-materialgroup IS NOT INITIAL THEN record-materialgroup ELSE ls_product-productgroup ).
          IF record-unit IS INITIAL.
            TRY.
                record-unit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = ls_product-baseunit ).
                ##NO_HANDLER
              CATCH zzcx_custom_exception.
                " handle exception
            ENDTRY.
          ENDIF.
        ENDIF.

        IF record-location IS INITIAL.
          READ TABLE lt_product_location INTO DATA(ls_product_location) WITH KEY product = lv_matid
                                                                                 plant   = record-plant BINARY SEARCH.
          IF sy-subrc = 0.
            record-location = ls_product_location-storagelocation.
          ENDIF.
        ENDIF.

        READ TABLE lt_purinfo_record INTO DATA(ls_purinfo_record) WITH KEY material = lv_matid
                                                                           supplier = lv_supplier
                                                                           plant    = record-plant
                                                                           purchasingorganization = record-purchaseorg BINARY SEARCH.
        IF sy-subrc = 0.
          record-tax = COND #( WHEN record-tax IS NOT INITIAL THEN record-tax ELSE ls_purinfo_record-taxcode ).

          IF record-currency IS INITIAL.
            record-currency = ls_purinfo_record-currency.
            ls_request-document_currency = ls_purinfo_record-currency.
          ENDIF.
        ENDIF.

        APPEND VALUE #( purchase_order_item          = lv_order_item
                        material                     = record-matid
                        purchase_order_item_text     = record-matdesc
                        account_assignment_category  = record-accounttype
                        purchase_order_item_category = record-itemcategory
                        order_quantity               = record-quantity
                        plant                        = record-plant
                        storage_location             = record-location
                        material_group               = record-materialgroup
                        purchase_order_quantity_unit = record-unit
                        net_price_amount             = record-price
                        document_currency            = record-currency
                        net_price_quantity           = record-unitprice
                        order_price_unit             = record-unit
                        is_returns_item              = is_returns_item
                        is_free_of_charge            = is_free_of_charge
                        requisitioner_name           = record-prby
                        " MOD BEGIN BY XINLEI XU 2025/04/22 CR#4359
                        " requirement_tracking       = record_temp-prno
                        requirement_tracking         = COND #( WHEN record-trackno IS INITIAL THEN record-prno ELSE record-trackno )
                        " MOD END BY XINLEI XU 2025/04/22 CR#4359
                        international_article_number = record-ean
                        tax_code                     = record-tax
                        "计划行
                        to_schedule_line = VALUE #( ( purchase_order_item = lv_order_item
                                                      schedule_line = 1
                                                      schedule_line_delivery_date = record-deliverydate
                                                      schedule_line_order_quantity = record-quantity
                                                      purchase_order_quantity_unit = record-unit ) )
                        "科目分配
                        to_account_assignment = VALUE #( (  purchase_order_item = lv_order_item
                                                            account_assignment_number = 1
                                                            cost_center = record-costcenter
                                                            g_l_account = record-glaccount
                                                            w_b_s_element_external_i_d = record-wbselemnt
                                                            order_i_d = record-orderid
                                                            master_fixed_asset = record-assetno
                                                            tax_code = record-tax ) )
                        "行项目长文本
                        to_item_note = VALUE #( ( purchase_order_item = lv_order_item
                                                  text_object_type = 'F01'
                                                  language = sy-langu
                                                  plain_long_text = record-itemtext ) )
                         ) TO ls_request-to_purchase_order_item.

        CLEAR lv_requestbody.
        lv_requestbody = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
          ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).

        REPLACE ALL OCCURRENCES OF `IsFreeOfCharge`      IN lv_requestbody  WITH `PurchasingItemIsFreeOfCharge`.
        REPLACE ALL OCCURRENCES OF `ToPurchaseOrderItem` IN lv_requestbody  WITH `_PurchaseOrderItem`.
        REPLACE ALL OCCURRENCES OF `ToScheduleLine`      IN lv_requestbody  WITH `_PurchaseOrderScheduleLineTP`.
        REPLACE ALL OCCURRENCES OF `ToAccountAssignment` IN lv_requestbody  WITH `_PurOrdAccountAssignment`.
        REPLACE ALL OCCURRENCES OF `ToItemNote`          IN lv_requestbody  WITH `_PurchaseOrderItemNote`.
        REPLACE ALL OCCURRENCES OF `"false"`             IN lv_requestbody  WITH `false`.
        REPLACE ALL OCCURRENCES OF `"true"`              IN lv_requestbody  WITH `true`.

        zzcl_common_utils=>request_api_v4( EXPORTING iv_path        = lv_path
                                                     iv_method      = if_web_http_client=>post
                                                     iv_body        = lv_requestbody
                                           IMPORTING ev_status_code = DATA(lv_status_code)
                                                     ev_response    = DATA(lv_response) ).
        IF lv_status_code = 201.
          /ui2/cl_json=>deserialize(  EXPORTING json = lv_response
                                      CHANGING  data = ls_response ).
          " 購買伝票登録成功しました。
          MESSAGE s018(zmm_001) WITH ls_response-purchaseorder INTO lv_message.
          record-type = 'S'.
          record-message = lv_message.
          record-purchaseorder = ls_response-purchaseorder.
          record-purchaseorderitem = lv_order_item.
          " PO创建成功后需要更改审批状态为4送信済
          record-approvestatus = '4'.
          MODIFY records FROM record TRANSPORTING type message purchaseorder purchaseorderitem approvestatus
           WHERE prno = record-prno AND pritem = record-pritem.

          "将PO号更新到ZTMM_1006
          MODIFY ENTITIES OF zr_tmm_1006 IN LOCAL MODE
          ENTITY purchasereq
          UPDATE FIELDS ( purchaseorder purchaseorderitem approvestatus )
          WITH CORRESPONDING #( records ).
        ELSE.
          record-type = 'E'.
          record-message = zzcl_common_utils=>parse_error_v4( lv_response ).
          MODIFY records FROM record TRANSPORTING type message WHERE prno = record-prno AND pritem = record-pritem.
        ENDIF.
        CLEAR: lv_status_code,lv_response.
      ENDLOOP.
    ELSE.
*&--ADD END BY XINLEI XU 2025/04/16
      LOOP AT records_key INTO DATA(record_key).
        "抬头数据
        CLEAR: ls_request.
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
        CLEAR: lt_mm1006,lv_order_item,lv_item.
        LOOP AT records INTO record_temp WHERE ordertype = record_key-ordertype AND supplier = record_key-supplier AND companycode = record_key-companycode
          AND purchaseorg = record_key-purchaseorg AND purchasegrp = record_key-purchasegrp AND currency = record_key-currency.
*&--MOD BEGIN BY XINLEI XU 2025/02/25 按照10,20,30的规则採番
*       lv_order_item = lv_order_item + 1.
          lv_item += 1.
          lv_order_item = lv_item * 10.
*&--MOD END BY XINLEI XU 2025/02/25
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

*&--ADD BEGIN BY XINLEI XU 2025/02/13
          lv_matid = zzcl_common_utils=>conversion_matn1( iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = record_temp-matid ).
          lv_supplier = |{ record_temp-supplier ALPHA = IN }|.

          READ TABLE lt_product INTO ls_product WITH KEY product = lv_matid BINARY SEARCH.
          IF sy-subrc = 0.
            record_temp-matdesc = COND #( WHEN record_temp-matdesc IS NOT INITIAL THEN record_temp-matdesc ELSE ls_product-productname ).
            record_temp-materialgroup = COND #( WHEN record_temp-materialgroup IS NOT INITIAL THEN record_temp-materialgroup ELSE ls_product-productgroup ).
            IF record_temp-unit IS INITIAL.
              TRY.
                  record_temp-unit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = ls_product-baseunit ).
                  ##NO_HANDLER
                CATCH zzcx_custom_exception.
                  " handle exception
              ENDTRY.
            ENDIF.
          ENDIF.

          IF record_temp-location IS INITIAL.
            READ TABLE lt_product_location INTO ls_product_location WITH KEY product = lv_matid
                                                                             plant   = record_temp-plant BINARY SEARCH.
            IF sy-subrc = 0.
              record_temp-location = ls_product_location-storagelocation.
            ENDIF.
          ENDIF.

          READ TABLE lt_purinfo_record INTO ls_purinfo_record WITH KEY material = lv_matid
                                                                       supplier = lv_supplier
                                                                       plant    = record_temp-plant
                                                                       purchasingorganization = record_temp-purchaseorg BINARY SEARCH.
          IF sy-subrc = 0.
            record_temp-tax = COND #( WHEN record_temp-tax IS NOT INITIAL THEN record_temp-tax ELSE ls_purinfo_record-taxcode ).

            IF record_temp-currency IS INITIAL.
              record_temp-currency = ls_purinfo_record-currency.
              record_key-currency = ls_purinfo_record-currency.
              ls_request-document_currency = ls_purinfo_record-currency.
            ENDIF.
          ENDIF.
*&--ADD BEGIN BY XINLEI XU 2025/02/13

          "行项目数据
          APPEND VALUE #( purchase_order_item          = lv_order_item
                          material                     = record_temp-matid
                          purchase_order_item_text     = record_temp-matdesc
                          account_assignment_category  = record_temp-accounttype
                          purchase_order_item_category = record_temp-itemcategory
                          order_quantity               = record_temp-quantity
                          plant                        = record_temp-plant
                          storage_location             = record_temp-location
                          material_group               = record_temp-materialgroup
                          purchase_order_quantity_unit = record_temp-unit
                          net_price_amount             = record_temp-price
                          document_currency            = record_temp-currency
                          net_price_quantity           = record_temp-unitprice
                          order_price_unit             = record_temp-unit
                          is_returns_item              = is_returns_item
                          is_free_of_charge            = is_free_of_charge
                          requisitioner_name           = record_temp-prby
                          " MOD BEGIN BY XINLEI XU 2025/04/22 CR#4359
                          " requirement_tracking       = record_temp-prno
                          requirement_tracking         = COND #( WHEN record_temp-trackno IS INITIAL THEN record_temp-prno ELSE record_temp-trackno )
                          " MOD END BY XINLEI XU 2025/04/22 CR#4359
                          international_article_number = record_temp-ean
                          tax_code                     = record_temp-tax
                          "计划行
                          to_schedule_line = VALUE #( ( purchase_order_item = lv_order_item
                                                        schedule_line = 1
                                                        schedule_line_delivery_date = record_temp-deliverydate
                                                        schedule_line_order_quantity = record_temp-quantity
                                                        purchase_order_quantity_unit = record_temp-unit ) )
                          "科目分配
                          to_account_assignment = VALUE #( (  purchase_order_item = lv_order_item
                                                              account_assignment_number = 1
                                                              cost_center = record_temp-costcenter
                                                              g_l_account = record_temp-glaccount
                                                              " MOD BEGIN BY XINLEI XU 2025/01/17 WBSElementInternalID Obsolete
                                                              " w_b_s_element_internal_i_d = record_temp-wbselemnt
                                                              w_b_s_element_external_i_d = record_temp-wbselemnt
                                                              " MOD BEGIN BY XINLEI XU 2025/01/17
                                                              order_i_d = record_temp-orderid
                                                              master_fixed_asset = record_temp-assetno
                                                              tax_code = record_temp-tax ) )
                          "行项目长文本
                          to_item_note = VALUE #( ( purchase_order_item = lv_order_item
                                                    text_object_type = 'F01'
                                                    language = sy-langu
                                                    plain_long_text = record_temp-itemtext ) )
                           ) TO ls_request-to_purchase_order_item.
          record_temp-purchaseorderitem = lv_order_item.
          MODIFY records FROM record_temp.
          APPEND VALUE #( uuid = record_temp-uuid purchaseorderitem = record_temp-purchaseorderitem ) TO lt_mm1006.
        ENDLOOP.

        "将abap数据转换成json格式，同时json格式区分大小写,所以通过underscore_to_pascal_case将下划线之后的字符大写
        CLEAR lv_requestbody.
        lv_requestbody = xco_cp_json=>data->from_abap( ls_request )->apply( VALUE #(
          ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).

        REPLACE ALL OCCURRENCES OF `IsFreeOfCharge`           IN lv_requestbody  WITH `PurchasingItemIsFreeOfCharge`.
        REPLACE ALL OCCURRENCES OF `ToPurchaseOrderItem`      IN lv_requestbody  WITH `_PurchaseOrderItem`.
        REPLACE ALL OCCURRENCES OF `ToScheduleLine`           IN lv_requestbody  WITH `_PurchaseOrderScheduleLineTP`.
        REPLACE ALL OCCURRENCES OF `ToAccountAssignment`      IN lv_requestbody  WITH `_PurOrdAccountAssignment`.
        REPLACE ALL OCCURRENCES OF `ToItemNote`               IN lv_requestbody  WITH `_PurchaseOrderItemNote`.
        REPLACE ALL OCCURRENCES OF `"false"`                  IN lv_requestbody  WITH `false`.
        REPLACE ALL OCCURRENCES OF `"true"`                   IN lv_requestbody  WITH `true`.

        CLEAR: lv_status_code,lv_response.
        zzcl_common_utils=>request_api_v4( EXPORTING iv_path        = lv_path
                                                     iv_method      = if_web_http_client=>post
                                                     iv_body        = lv_requestbody
                                           IMPORTING ev_status_code = lv_status_code
                                                     ev_response    = lv_response ).
        IF lv_status_code = 201.
          /ui2/cl_json=>deserialize(  EXPORTING json = lv_response
                                      CHANGING  data = ls_response ).
          " 返回消息文本
          " 購買伝票登録成功しました。
          MESSAGE s018(zmm_001) WITH ls_response-purchaseorder INTO lv_message.
          record_temp-type = 'S'.
          record_temp-message = lv_message.
          record_temp-purchaseorder = ls_response-purchaseorder.
          " PO创建成功后需要更改审批状态为4送信済
          record_temp-approvestatus = '4'.
          MODIFY records FROM record_temp TRANSPORTING type message purchaseorder approvestatus WHERE ordertype = record_key-ordertype
            AND supplier = record_key-supplier AND companycode = record_key-companycode AND purchaseorg = record_key-purchaseorg
            AND purchasegrp = record_key-purchasegrp AND currency = record_key-currency.

          "将PO号更新到ZTMM_1006
          MODIFY ENTITIES OF zr_tmm_1006 IN LOCAL MODE
          ENTITY purchasereq
          UPDATE FIELDS ( purchaseorder purchaseorderitem approvestatus )
          WITH CORRESPONDING #( records ).
        ELSE.
          record_temp-type = 'E'.
          record_temp-message = zzcl_common_utils=>parse_error_v4( lv_response ).
          MODIFY records FROM record_temp TRANSPORTING type message WHERE ordertype = record_key-ordertype
            AND supplier = record_key-supplier AND companycode = record_key-companycode AND purchaseorg = record_key-purchaseorg
            AND purchasegrp = record_key-purchasegrp AND currency = record_key-currency.
        ENDIF.
      ENDLOOP.
    ENDIF.

    "返回结果
    lv_json = /ui2/cl_json=>serialize( records ).
    APPEND VALUE #( %cid    = keys[ 1 ]-%cid
                    %param  = VALUE #( zzkey = lv_json ) ) TO result.

  ENDMETHOD.

  METHOD handlefile.
    TYPES:BEGIN OF lty_upload,
            uuid      TYPE sysuuid_x16,
            seq       TYPE int4,
            file_name TYPE zze_filename,
            mime_type TYPE zze_mimetype,
            file_type TYPE string,
            file_size TYPE int4,
            data      TYPE string,
          END OF lty_upload,
          BEGIN OF lty_file_object,
            object      TYPE string,
            object_type TYPE string,
            file_name   TYPE zze_filename,
            file_type   TYPE string,
            value       TYPE string,
          END OF lty_file_object,
          BEGIN OF lty_s3_request,
            attachmentjson TYPE lty_file_object,
          END OF lty_s3_request,
          BEGIN OF lty_s3_response,
            value TYPE string,
          END OF lty_s3_response.

    DATA: ls_upload      TYPE lty_upload,
          ls_s3_request  TYPE lty_s3_request,
          ls_s3_response TYPE lty_s3_response,
          ls_file_record TYPE ztmm_1012,
          ls_file        TYPE zc_tmm_1012,
          ls_file_object TYPE lty_file_object.

    SELECT SINGLE userdescription
      FROM i_user WITH PRIVILEGED ACCESS
     WHERE userid = @sy-uname
      INTO @DATA(lv_username).

    LOOP AT keys INTO DATA(key).
      CASE key-%param-event.
        WHEN 'UPLOAD'.
          CLEAR: ls_upload, ls_s3_request.
          /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                     CHANGING  data = ls_upload ).
          " POST BODY
          ls_s3_request-attachmentjson = VALUE #( object      = 'MM-011'
                                                  object_type = 'MM-011'
                                                  file_name   = ls_upload-file_name
                                                  file_type   = ls_upload-file_type
                                                  value       = ls_upload-data ).

          DATA(lv_request_body) = /ui2/cl_json=>serialize( data = ls_s3_request
                                                           pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

          REPLACE ALL OCCURRENCES OF `attachmentjson` IN lv_request_body WITH `attachmentJson`.

          zzcl_common_utils=>s3_attachment(
            EXPORTING
              iv_path        = 'if_s3uploadAttachment'
              iv_body        = lv_request_body
            IMPORTING
              ev_status_code = DATA(ev_status_code)
              ev_response    = DATA(ev_response) ).

          IF ev_status_code = 200.
            /ui2/cl_json=>deserialize( EXPORTING json = ev_response
                                       CHANGING  data = ls_s3_response ).
            TRY.
                DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
                ##NO_HANDLER
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.

            GET TIME STAMP FIELD DATA(lv_timestamp).

            CLEAR ls_file_record.
            ls_file_record = VALUE #( pr_uuid     = ls_upload-uuid
                                      file_uuid   = lv_uuid
                                      file_seq    = ls_upload-seq
                                      file_type   = ls_upload-mime_type
                                      file_name   = ls_upload-file_name
                                      file_size   = ls_upload-file_size
                                      s3_filename = ls_s3_response-value
                                      created_by  = sy-uname
                                      created_by_name = lv_username
                                      created_at  = lv_timestamp
                                      last_changed_by = sy-uname
                                      last_changed_by_name = lv_username
                                      last_changed_at = lv_timestamp
                                      local_last_changed_at = lv_timestamp ).
            TRY.
                cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = ls_file_record-pr_uuid
                                                         IMPORTING uuid_c36 = ls_file_record-pr_uuid_c36 ).
                cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid = ls_file_record-file_uuid
                                                         IMPORTING uuid_c36 = ls_file_record-file_uuid_c36 ).
                ##NO_HANDLER
              CATCH cx_uuid_error.
                " handle exception
            ENDTRY.

            INSERT INTO ztmm_1012 VALUES @ls_file_record.
            IF sy-subrc = 0.
              DATA(lv_type) = 'S'.
            ENDIF.
          ENDIF.

          IF lv_type IS INITIAL.
            APPEND VALUE #( %cid   = key-%cid
                            %param = VALUE #( zzkey = 'E' ) ) TO result.
          ELSE.
            DATA(lv_record) = /ui2/cl_json=>serialize( ls_file_record ).
            APPEND VALUE #( %cid   = key-%cid
                            %param = VALUE #( zzkey = lv_record ) ) TO result.
          ENDIF.

        WHEN 'DOWNLOAD'.
          CLEAR: ls_file, ls_s3_request.

          /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                     CHANGING  data = ls_file ).
          " POST BODY
          ls_s3_request-attachmentjson = VALUE #( object = 'download'
                                                  value  = ls_file-s3filename ).

          lv_request_body = /ui2/cl_json=>serialize( data = ls_s3_request
                                                     pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

          REPLACE ALL OCCURRENCES OF `attachmentjson` IN lv_request_body WITH `attachmentJson`.

          zzcl_common_utils=>s3_attachment(
            EXPORTING
              iv_path        = 'if_s3DownloadAttachment'
              iv_body        = lv_request_body
            IMPORTING
              ev_status_code = ev_status_code
              ev_response    = ev_response ).

          IF ev_status_code = 200.
            /ui2/cl_json=>deserialize( EXPORTING json = ev_response
                                       CHANGING  data = ls_s3_response ).

            ls_file_object = VALUE #( file_name = ls_file-filename
                                      file_type = ls_file-filetype
                                      value     = ls_s3_response-value ).

            DATA(lv_download) = /ui2/cl_json=>serialize( ls_file_object ).

            APPEND VALUE #( %cid   = key-%cid
                            %param = VALUE #( zzkey = lv_download ) ) TO result.
          ELSE.
            APPEND VALUE #( %cid   = key-%cid
                            %param = VALUE #( zzkey = 'E' ) ) TO result.
          ENDIF.

        WHEN 'DELETE'.
          CLEAR: ls_file.
          /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                     CHANGING  data = ls_file ).

          DELETE FROM ztmm_1012 WHERE pr_uuid   = @ls_file-pruuid
                                  AND file_uuid = @ls_file-fileuuid.
          IF sy-subrc = 0.
            APPEND VALUE #( %cid   = key-%cid
                            %param = VALUE #( zzkey = 'S' ) ) TO result.
          ELSE.
            APPEND VALUE #( %cid   = key-%cid
                            %param = VALUE #( zzkey = 'E' ) ) TO result.
          ENDIF.

        WHEN OTHERS.

      ENDCASE.

      CLEAR: lv_request_body, ev_status_code, ev_response.
    ENDLOOP.
  ENDMETHOD.

  METHOD deletepr.
*&--ADD BEGIN BY XINLEI XU 2025/04/22 CR#4359
    DATA: records      TYPE TABLE OF ty_batchupload,
          record       LIKE LINE OF records,
          lv_has_error TYPE abap_boolean,
          lv_msg       TYPE string.

    LOOP AT keys INTO DATA(key).
      CLEAR: records, lv_has_error.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).

      LOOP AT records TRANSPORTING NO FIELDS WHERE isapprove = '1' AND approvestatus <> '1'. " 登録済 (1)
      ENDLOOP.
      IF sy-subrc = 0.
        lv_has_error = abap_true.
      ENDIF.

      LOOP AT records TRANSPORTING NO FIELDS WHERE isapprove = '2' AND approvestatus <> '3'. " 承認済 (3)
      ENDLOOP.
      IF sy-subrc = 0.
        lv_has_error = abap_true.
      ENDIF.

      IF lv_has_error = abap_true.
        APPEND VALUE #( %cid   = key-%cid
                        %param = VALUE #( zzkey = 'E' ) ) TO result.
      ELSE.
        MODIFY ENTITIES OF zr_tmm_1006 IN LOCAL MODE
        ENTITY purchasereq
        DELETE FROM CORRESPONDING #( records )
        FAILED DATA(ls_failed).
        IF ls_failed IS INITIAL.
          APPEND VALUE #( %cid   = key-%cid
                          %param = VALUE #( zzkey = 'S' ) ) TO result.
        ENDIF.
      ENDIF.
    ENDLOOP.
*&--ADD END BY XINLEI XU 2025/04/22 CR#4359
  ENDMETHOD.

ENDCLASS.
