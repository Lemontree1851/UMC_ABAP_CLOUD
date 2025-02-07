CLASS lhc_invoicereport DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR invoicereport RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE invoicereport.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE invoicereport.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE invoicereport.

    METHODS read FOR READ
      IMPORTING keys FOR READ invoicereport RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK invoicereport.

    METHODS printinvoice FOR MODIFY
      IMPORTING keys FOR ACTION invoicereport~printinvoice RESULT result.
    METHODS reprintinvoice FOR MODIFY
      IMPORTING keys FOR ACTION invoicereport~reprintinvoice RESULT result.
    METHODS deleteinovice FOR MODIFY
      IMPORTING keys FOR ACTION invoicereport~deleteinovice RESULT result.
    METHODS get_invoice_number
      RETURNING VALUE(invoice_no) TYPE string.
    METHODS get_longtext
      IMPORTING iv_billing_document  TYPE i_billingdocument-billingdocument
                iv_textid            TYPE string
      RETURNING VALUE(longtext_tx05) TYPE string.

ENDCLASS.

CLASS lhc_invoicereport IMPLEMENTATION.

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

  METHOD printinvoice.
    DATA print_records TYPE TABLE OF zc_invoicereport.
    DATA records TYPE TABLE OF zc_invoicereport.
    DATA record_temp LIKE LINE OF records.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).
    ENDLOOP.

    LOOP AT records ASSIGNING FIELD-SYMBOL(<fs_record>).
      <fs_record>-billingdocument = |{ <fs_record>-billingdocument ALPHA = IN }|.
      <fs_record>-billingdocumentitem = |{ <fs_record>-billingdocumentitem ALPHA = IN }|.
    ENDLOOP.
    CHECK records IS NOT INITIAL.
    "校验是否为同一次印刷
    SELECT
      billing_document,
      billing_document_item,
      invoice_no
    FROM ztsd_1008
    FOR ALL ENTRIES IN @records
    WHERE billing_document = @records-billingdocument
      AND billing_document_item = @records-billingdocumentitem
    INTO TABLE @DATA(old_records).

    DATA(old_records_temp) = old_records.
    SORT old_records_temp BY billing_document billing_document_item.

    SORT old_records BY invoice_no.
    DELETE ADJACENT DUPLICATES FROM old_records COMPARING invoice_no.

    IF lines( old_records ) > 1.
      APPEND VALUE #( %cid = keys[ 1 ]-%cid ) TO failed-invoicereport.
      reported-invoicereport = VALUE #( FOR record IN records ( "%key = record-%key
                                                                  %msg = new_message(
                                                                            id        = 'ZSD_001'
                                                                            number    = '005'
                                                                            severity  = cl_abap_behv=>ms-error )
                                                                   ) ).
      "表示是选择的数据是同一个请求书编号的，直接输入之前的数据即可
    ELSEIF lines( old_records ) = 1.
      " 需要进一步判断，有可能选择了一条已经打印的，一条没打印过的，这种情况取到的数据也是1条,但需要报错
      LOOP AT records INTO record_temp.
        READ TABLE old_records_temp TRANSPORTING NO FIELDS WITH KEY billing_document = record_temp-billingdocument
          billing_document_item = record_temp-billingdocumentitem BINARY SEARCH.
        IF sy-subrc <> 0.
          APPEND VALUE #( %cid = keys[ 1 ]-%cid ) TO failed-invoicereport.
          APPEND VALUE #( %cid = keys[ 1 ]-%cid
                          %msg = new_message(
                                    id        = 'ZSD_001'
                                    number    = '005'
                                    severity  = cl_abap_behv=>ms-error ) ) TO reported-invoicereport.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF failed IS NOT INITIAL.
        EXIT.
      ENDIF.
      "按照 納品書受領書No. 获取所有要打印的条目
      DATA print_keys TYPE TABLE FOR READ IMPORT zr_invoicereport.
      READ TABLE old_records INTO DATA(old_record) INDEX 1.
      SELECT
        billing_document,
        billing_document_item,
        invoice_no
      FROM ztsd_1008
      WHERE invoice_no = @old_record-invoice_no
      INTO TABLE @DATA(lt_print).

      IF lt_print IS NOT INITIAL.
        SELECT                                     "#EC CI_NO_TRANSFORM
          *
        FROM zc_invoicereport
        FOR ALL ENTRIES IN @lt_print
        WHERE billingdocument = @lt_print-billing_document
          AND billingdocumentitem = @lt_print-billing_document_item
        INTO TABLE @print_records.
      ENDIF.
      "第一次打印，创建納品書受領書No
    ELSE.
      "因为只传入了key值，这一步获取完整数据
      IF records IS NOT INITIAL.
        SELECT
          *
        FROM zc_invoicereport
        FOR ALL ENTRIES IN @records
        WHERE billingdocument = @records-billingdocument
          AND billingdocumentitem = @records-billingdocumentitem
        INTO TABLE @print_records.
      ENDIF.

      "获取新的请求书编号
      DATA invoice_no(11) TYPE c.
      invoice_no = get_invoice_number( ).

      "将新的编号记录在自建表中
      DATA lt_ztsd_1008 TYPE TABLE OF ztsd_1008.
      lt_ztsd_1008 = VALUE #( FOR record IN records
                                INDEX INTO lv_index ( billing_document = record-billingdocument
                                                      billing_document_item = record-billingdocumentitem
                                                      invoice_no = invoice_no
                                                      invoice_item_no = lv_index ) ).
      MODIFY ztsd_1008 FROM TABLE @lt_ztsd_1008.
    ENDIF.

    IF failed-invoicereport IS NOT INITIAL.
      EXIT.
    ENDIF.

    "返回结果
    DATA ls_result LIKE LINE OF result.
    SORT print_records BY invoiceno invoiceitemno.
    LOOP AT print_records INTO DATA(print_record).
      ls_result-%cid =  keys[ 1 ]-%cid.
      "本想在此处添加长文本，但对于返回类型是 $self的action 值来源是cds无法覆盖，
      "所以想要优化需要打印时单独从前端获取长文本值（把get_longtext改成action）
*      print_record-RemitAddress = get_longtext(
*                                    iv_billing_document = print_record-BillingDocument
*                                    iv_textid = 'TX05' ).
      MOVE-CORRESPONDING print_record TO ls_result-%param.
      APPEND  ls_result TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD reprintinvoice.
    DATA print_records TYPE TABLE OF zc_invoicereport.
    DATA records TYPE TABLE OF zc_invoicereport.
    DATA record_temp LIKE LINE OF records.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).
    ENDLOOP.

    LOOP AT records ASSIGNING FIELD-SYMBOL(<fs_record>).
      <fs_record>-billingdocument = |{ <fs_record>-billingdocument ALPHA = IN }|.
      <fs_record>-billingdocumentitem = |{ <fs_record>-billingdocumentitem ALPHA = IN }|.
    ENDLOOP.

    IF records IS NOT INITIAL.
      SELECT
        billing_document,
        billing_document_item,
        invoice_no
      FROM ztsd_1008
      FOR ALL ENTRIES IN @records
      WHERE billing_document = @records-billingdocument
        AND billing_document_item = @records-billingdocumentitem
      INTO TABLE @DATA(old_records).

      "如果是订正打印则需要删除之前的数据
      LOOP AT old_records INTO DATA(old_record).
        DELETE FROM ztsd_1008 WHERE invoice_no = @old_record-invoice_no.
      ENDLOOP.

      "获取新的请求书编号
      DATA invoice_no(11) TYPE c.
      invoice_no = get_invoice_number( ).

      "将新的编号记录在自建表中
      DATA lt_ztsd_1008 TYPE TABLE OF ztsd_1008.
      lt_ztsd_1008 = VALUE #( FOR record IN records
                                INDEX INTO lv_index ( billing_document = record-billingdocument
                                                      billing_document_item = record-billingdocumentitem
                                                      invoice_no = invoice_no
                                                      invoice_item_no = lv_index ) ).
      MODIFY ztsd_1008 FROM TABLE @lt_ztsd_1008.

      IF records IS NOT INITIAL.
        SELECT
          *
        FROM zc_invoicereport
        FOR ALL ENTRIES IN @records
        WHERE billingdocument = @records-billingdocument
          AND billingdocumentitem = @records-billingdocumentitem
        INTO TABLE @print_records.
      ENDIF.

      "返回结果
      DATA ls_result LIKE LINE OF result.
      SORT print_records BY invoiceno invoiceitemno.
      LOOP AT print_records INTO DATA(print_record).
        ls_result-%cid =  keys[ 1 ]-%cid.
        MOVE-CORRESPONDING print_record TO ls_result-%param.
        APPEND  ls_result TO result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD get_invoice_number.
    DATA utils TYPE REF TO zzcl_common_utils.
    DATA lv_datum TYPE datum.
    DATA prefix(3) TYPE c.
    utils = NEW #( ).
    prefix = 'S'.
    TRY.
        DATA(lv_no) = utils->get_number_next(
                      iv_object = CONV ztbc_1002-object( prefix )
                      iv_datum  = cl_abap_context_info=>get_system_date( )
                      iv_nrlen  = 2 ).
      CATCH zzcx_custom_exception INTO DATA(exc) ##NO_HANDLER.
    ENDTRY.
    invoice_no = prefix && lv_no.
  ENDMETHOD.

  "删除当前billing和打印编号的绑定
  METHOD deleteinovice.
    DATA print_records TYPE TABLE OF zc_invoicereport.
    DATA records TYPE TABLE OF zc_invoicereport.
    DATA record_temp LIKE LINE OF records.
    LOOP AT keys INTO DATA(key).
      CLEAR records.
      /ui2/cl_json=>deserialize(  EXPORTING json = key-%param-zzkey
                                  CHANGING  data = records ).
    ENDLOOP.

    LOOP AT records ASSIGNING FIELD-SYMBOL(<fs_record>).
      <fs_record>-billingdocument = |{ <fs_record>-billingdocument ALPHA = IN }|.
      <fs_record>-billingdocumentitem = |{ <fs_record>-billingdocumentitem ALPHA = IN }|.
    ENDLOOP.

    IF records IS NOT INITIAL.
      DATA lt_ztsd_1008 TYPE TABLE OF ztsd_1008.
      lt_ztsd_1008 = VALUE #( FOR record IN records ( billing_document       = record-billingdocument
                                                      billing_document_item  = record-billingdocumentitem ) ).
      DELETE ztsd_1008 FROM TABLE @lt_ztsd_1008.
    ENDIF.
  ENDMETHOD.

  METHOD get_longtext.
    TYPES: BEGIN OF ty_longtext,
             billing_document TYPE i_billingdocument-billingdocument,
             language         TYPE string,
             long_text_i_d    TYPE string,
             long_text        TYPE string,
           END OF ty_longtext,
           BEGIN OF ty_result,
             results TYPE TABLE OF ty_longtext WITH DEFAULT KEY,
           END OF ty_result,
           BEGIN OF ty_response,
             d TYPE ty_result,
           END OF ty_response.
    DATA: ls_response TYPE ty_response.

    "效率会很低，可以考虑，在报表中不显示，只在打印时调用此api获取结果
    DATA(lv_path) = |/API_BILLING_DOCUMENT_SRV/A_BillingDocument('{ iv_billing_document }')/to_Text?sap-language={ zzcl_common_utils=>get_current_language( ) }|.
    zzcl_common_utils=>request_api_v2( EXPORTING iv_path        = lv_path
                                                 iv_method      = if_web_http_client=>get
*                                                 iv_body        = lv_requestbody
                                      IMPORTING ev_status_code   = DATA(lv_status_code)
                                                ev_response      = DATA(lv_response) ).
    IF lv_status_code = 200.
      xco_cp_json=>data->from_string( lv_response )->apply( VALUE #(
        ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ) )->write_to( REF #( ls_response ) ).
    ENDIF.
    READ TABLE ls_response-d-results INTO DATA(ls_result) WITH KEY language = zzcl_common_utils=>get_current_language( ) long_text_i_d = iv_textid.
    IF sy-subrc = 0.
      longtext_tx05 = ls_result-long_text.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_invoicereport DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_invoicereport IMPLEMENTATION.

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
