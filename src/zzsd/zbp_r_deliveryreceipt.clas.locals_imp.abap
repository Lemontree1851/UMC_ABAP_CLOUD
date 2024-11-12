CLASS lhc_deliveryreceipt DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR deliveryreceipt RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE deliveryreceipt.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE deliveryreceipt.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE deliveryreceipt.

    METHODS read FOR READ
      IMPORTING keys FOR READ deliveryreceipt RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK deliveryreceipt.

    METHODS printdeliveryreceiptno FOR MODIFY
      IMPORTING keys FOR ACTION deliveryreceipt~printdeliveryreceiptno RESULT result.

    METHODS reprintdeliveryreceiptno FOR MODIFY
      IMPORTING keys FOR ACTION deliveryreceipt~reprintdeliveryreceiptno RESULT result.

    METHODS deletedeliveryreceiptno FOR MODIFY
      IMPORTING keys FOR ACTION deliveryreceipt~deletedeliveryreceiptno RESULT result.

    METHODS get_delivery_receipt_number
      RETURNING VALUE(delivery_receipt_no) TYPE string.
ENDCLASS.

CLASS lhc_deliveryreceipt IMPLEMENTATION.

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

  METHOD printdeliveryreceiptno.
    DATA print_records TYPE TABLE OF zc_deliveryreceipt.
    DATA records TYPE TABLE OF zc_deliveryreceipt.
    DATA record_temp LIKE LINE OF records.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).
    ENDLOOP.

    LOOP AT records ASSIGNING FIELD-SYMBOL(<fs_record>).
      <fs_record>-deliverydocument = |{ <fs_record>-deliverydocument ALPHA = IN }|.
      <fs_record>-deliverydocumentitem = |{ <fs_record>-deliverydocumentitem ALPHA = IN }|.
    ENDLOOP.
*    "校验传入的key值在结果集中是否存在或有变化（不必须）
*    DATA read_keys TYPE TABLE FOR READ IMPORT zr_deliveryreceipt.
*    read_keys  = VALUE #( FOR ls_input IN lt_input ( %key-deliverydocument = ls_input-deliverydocument
*                                                     %key-deliverydocumentitem = ls_input-deliverydocumentitem ) ).
*    "非托管必须实现read方法才能使用
*    READ ENTITIES OF zr_deliveryreceipt IN LOCAL MODE
*      ENTITY deliveryreceipt
*      FIELDS ( deliverydocument deliverydocumentitem )
*      WITH CORRESPONDING #( read_keys )
*      RESULT DATA(records)
*      FAILED failed.
    CHECK records IS NOT INITIAL.
    "校验是否为同一次印刷
    SELECT
      delivery_document,
      delivery_document_item,
      delivery_receipt_no
    FROM ztsd_1007
    FOR ALL ENTRIES IN @records
    WHERE delivery_document = @records-deliverydocument
      AND delivery_document_item = @records-deliverydocumentitem
    INTO TABLE @DATA(old_records).

    DATA(old_records_temp) = old_records.
    SORT old_records_temp BY delivery_document delivery_document_item.

    SORT old_records BY delivery_receipt_no.
    DELETE ADJACENT DUPLICATES FROM old_records COMPARING delivery_receipt_no.
    "如果选择了不是同一次打印的数据需要报错
    IF lines( old_records ) > 1.
      APPEND VALUE #( %cid = keys[ 1 ]-%cid ) TO failed-deliveryreceipt.
      reported-deliveryreceipt = VALUE #( FOR record IN records ( "%key = record-%key
                                                                  %msg = new_message(
                                                                            id        = 'ZSD_001'
                                                                            number    = '005'
                                                                            severity  = cl_abap_behv=>ms-error )
                                                                   ) ).
      "表示是选择的数据是同一个请求书编号的，直接输入之前的数据即可
    ELSEIF lines( old_records ) = 1.
      " 需要进一步判断，有可能选择了一条已经打印的，一条没打印过的，这种情况取到的数据也是1条,但需要报错
      LOOP AT records INTO record_temp.
        READ TABLE old_records_temp TRANSPORTING NO FIELDS WITH KEY delivery_document = record_temp-deliverydocument
          delivery_document_item = record_temp-deliverydocumentitem BINARY SEARCH.
        IF sy-subrc <> 0.
          APPEND VALUE #( %cid = keys[ 1 ]-%cid ) TO failed-deliveryreceipt.
          APPEND VALUE #( %cid = keys[ 1 ]-%cid
                          %msg = new_message(
                                    id        = 'ZSD_001'
                                    number    = '005'
                                    severity  = cl_abap_behv=>ms-error ) ) TO reported-deliveryreceipt.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF failed IS NOT INITIAL.
        EXIT.
      ENDIF.
      "按照 納品書受領書No. 获取所有要打印的条目
      DATA print_keys TYPE TABLE FOR READ IMPORT zr_deliveryreceipt.
      READ TABLE old_records INTO DATA(old_record) INDEX 1.
      SELECT
        delivery_document,
        delivery_document_item,
        delivery_receipt_no
      FROM ztsd_1007
      WHERE delivery_receipt_no = @old_record-delivery_receipt_no
      INTO TABLE @DATA(lt_print).

      IF lt_print IS NOT INITIAL.
        SELECT
          *
        FROM zc_deliveryreceipt
        FOR ALL ENTRIES IN @lt_print
        WHERE deliverydocument = @lt_print-delivery_document
          AND deliverydocumentitem = @lt_print-delivery_document_item
        INTO TABLE @print_records.
      ENDIF.
      "第一次打印，创建納品書受領書No
    ELSE.
      "因为只传入了key值，这一步获取完整数据
      IF records IS NOT INITIAL.
        SELECT
          *
        FROM zc_deliveryreceipt
        FOR ALL ENTRIES IN @records
        WHERE deliverydocument = @records-deliverydocument
          AND deliverydocumentitem = @records-deliverydocumentitem
        INTO TABLE @print_records.
      ENDIF.

      "获取納品書受領書No
      DATA delivery_receipt_no(11) TYPE c.
      delivery_receipt_no = get_delivery_receipt_number( ).

      LOOP AT records ASSIGNING <fs_record>.
        <fs_record>-deliveryreceiptno = delivery_receipt_no.
      ENDLOOP.

      "将新的编号记录在自建表中
      DATA lt_ztsd_1007 TYPE TABLE OF  ztsd_1007.
      lt_ztsd_1007 = VALUE #( FOR record IN records ( delivery_document = record-deliverydocument
                                                      delivery_document_item = record-deliverydocumentitem
                                                      delivery_receipt_no = record-deliveryreceiptno ) ).
      MODIFY ztsd_1007 FROM TABLE @lt_ztsd_1007.
    ENDIF.

    IF failed IS NOT INITIAL.
      EXIT.
    ENDIF.

    "返回结果
    DATA ls_result LIKE LINE OF result.
    LOOP AT print_records INTO DATA(print_record).
      ls_result-%cid =  keys[ 1 ]-%cid.
      MOVE-CORRESPONDING print_record TO ls_result-%param.
      APPEND  ls_result TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD reprintdeliveryreceiptno.
    DATA print_records TYPE TABLE OF zc_deliveryreceipt.
    DATA records TYPE TABLE OF zc_deliveryreceipt.
    DATA record_temp LIKE LINE OF records.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).
    ENDLOOP.

    LOOP AT records ASSIGNING FIELD-SYMBOL(<fs_record>).
      <fs_record>-deliverydocument = |{ <fs_record>-deliverydocument ALPHA = IN }|.
      <fs_record>-deliverydocumentitem = |{ <fs_record>-deliverydocumentitem ALPHA = IN }|.
    ENDLOOP.

    IF records IS NOT INITIAL.
      SELECT
        delivery_document,
        delivery_document_item,
        delivery_receipt_no
      FROM ztsd_1007
      FOR ALL ENTRIES IN @records
      WHERE delivery_document = @records-deliverydocument
        AND delivery_document_item = @records-deliverydocumentitem
      INTO TABLE @DATA(old_records).

      "如果是订正打印则需要删除之前的数据
      LOOP AT old_records INTO DATA(old_record).
        DELETE FROM ztsd_1007 WHERE delivery_receipt_no = @old_record-delivery_receipt_no.
      ENDLOOP.

      "获取納品書受領書No
      DATA delivery_receipt_no(11) TYPE c.
      delivery_receipt_no = get_delivery_receipt_number( ).

      "将新的编号记录在自建表中
      DATA lt_ztsd_1007 TYPE TABLE OF  ztsd_1007.
      lt_ztsd_1007 = VALUE #( FOR record IN records ( delivery_document = record-deliverydocument
                                                      delivery_document_item = record-deliverydocumentitem
                                                      delivery_receipt_no = delivery_receipt_no ) ).
      MODIFY ztsd_1007 FROM TABLE @lt_ztsd_1007.

      IF records IS NOT INITIAL.
        SELECT
          *
        FROM zc_deliveryreceipt
        FOR ALL ENTRIES IN @records
        WHERE deliverydocument = @records-deliverydocument
          AND deliverydocumentitem = @records-deliverydocumentitem
        INTO TABLE @print_records.
      ENDIF.

      "返回结果
      DATA ls_result LIKE LINE OF result.
      LOOP AT print_records INTO DATA(print_record).
        ls_result-%cid =  keys[ 1 ]-%cid.
        MOVE-CORRESPONDING print_record TO ls_result-%param.
        APPEND  ls_result TO result.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.

  METHOD get_delivery_receipt_number.
    "获取納品書受領書No.
    DATA utils TYPE REF TO zzcl_common_utils.
    DATA lv_datum TYPE datum.
    DATA prefix(3) TYPE c.
    utils = NEW #( ).
    prefix = 'N'.
    TRY.
        DATA(lv_no) = utils->get_number_next(
                      iv_object = CONV ztbc_1002-object( prefix )
                      iv_datum  = cl_abap_context_info=>get_system_date( )
                      iv_nrlen  = 2 ).
      CATCH zzcx_custom_exception INTO DATA(exc).
        RAISE EXCEPTION exc.
    ENDTRY.
    delivery_receipt_no = prefix && lv_no.
  ENDMETHOD.
  "删除当前dn和打印编号的绑定
  METHOD deletedeliveryreceiptno.
    DATA print_records TYPE TABLE OF zc_deliveryreceipt.
    DATA records TYPE TABLE OF zc_deliveryreceipt.
    DATA record_temp LIKE LINE OF records.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).
    ENDLOOP.

    LOOP AT records ASSIGNING FIELD-SYMBOL(<fs_record>).
      <fs_record>-deliverydocument = |{ <fs_record>-deliverydocument ALPHA = IN }|.
      <fs_record>-deliverydocumentitem = |{ <fs_record>-deliverydocumentitem ALPHA = IN }|.
    ENDLOOP.

    IF records IS NOT INITIAL.
      DATA lt_ztsd_1007 TYPE TABLE OF ztsd_1007.
      lt_ztsd_1007 = VALUE #( FOR record IN records ( delivery_document       = record-deliverydocument
                                                      delivery_document_item  = record-deliverydocumentitem ) ).
      DELETE ztsd_1007 FROM TABLE @lt_ztsd_1007.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_deliveryreceipt DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_deliveryreceipt IMPLEMENTATION.

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
