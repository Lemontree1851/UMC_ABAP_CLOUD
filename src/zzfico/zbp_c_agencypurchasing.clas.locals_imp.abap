CLASS lhc_zc_agencypurchasing DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES: BEGIN OF lty_item,
             postingdate         TYPE c LENGTH 6,
             companycode         TYPE i_journalentryitem-companycode,
             companycode2        TYPE i_journalentryitem-companycode,
             glaccount           TYPE i_journalentryitem-glaccount,
             companycodecurrency TYPE i_journalentryitem-companycodecurrency,
             taxcode             TYPE i_journalentryitem-taxcode,
             currency1           TYPE i_journalentryitem-amountincompanycodecurrency,
             currency2           TYPE i_journalentryitem-amountincompanycodecurrency,
             currency3           TYPE i_journalentryitem-amountincompanycodecurrency,
             accountingdocument1 TYPE c LENGTH 10,
             accountingdocument2 TYPE c LENGTH 10,
             message             TYPE string.
    TYPES: END OF lty_item.
    TYPES:BEGIN OF lty_request,
            items    TYPE TABLE OF lty_item WITH DEFAULT KEY,
            user     TYPE string,
            username TYPE string,
            datetime TYPE string,
          END OF lty_request.

    CONSTANTS: lc_event_posting TYPE string VALUE `POSTING`.

    CONSTANTS: lc_config_id TYPE ztbc_1001-zid VALUE `ZFI002`.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_agencypurchasing RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION zc_agencypurchasing~processlogic RESULT result.

*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE zc_agencypurchasing.
*
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE zc_agencypurchasing.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_agencypurchasing RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_agencypurchasing.

    METHODS posting IMPORTING iv_model TYPE string
                    CHANGING  cs_data  TYPE lty_request.

    TYPES: BEGIN OF ts_response,
             _accountingdocument TYPE c LENGTH 20,
             _companycode        TYPE bukrs,
             _fiscalyear         TYPE c LENGTH 4,
           END OF ts_response.

    DATA: ls_response TYPE ts_response.

ENDCLASS.

CLASS lhc_zc_agencypurchasing IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD processlogic.
    DATA: ls_request TYPE lty_request.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR ls_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      CHANGING data = ls_request ).

      CASE lv_event.
        WHEN lc_event_posting.
          posting( EXPORTING iv_model = lc_event_posting CHANGING cs_data = ls_request ).
        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD posting.
    DATA: ls_ztfi_1014 TYPE ztfi_1014.

    DATA: lv_lastday     TYPE datum,
          lv_postingdate TYPE datum,
          lv_username    TYPE string,
          lv_password    TYPE string,
          lv_request     TYPE string,
          lv_string1     TYPE string,
          lv_string2     TYPE string.

    CHECK cs_data IS NOT INITIAL.

    SELECT *
     FROM zc_tbc1001
    WHERE zid = @lc_config_id
     INTO TABLE @DATA(lt_config).             "#EC CI_ALL_FIELDS_NEEDED
    SORT lt_config BY zvalue1 zvalue2.

    DATA(lt_items) = cs_data-items.
    SORT lt_items BY companycode companycode2.
    DELETE ADJACENT DUPLICATES FROM lt_items COMPARING companycode companycode2.

    SELECT *
      FROM i_suppliercompany
       FOR ALL ENTRIES IN @lt_items
     WHERE companycode = @lt_items-companycode
        OR companycode = @lt_items-companycode2
      INTO TABLE @DATA(lt_suppliercompany).   "#EC CI_ALL_FIELDS_NEEDED
    SORT lt_suppliercompany BY supplier companycode.

    SELECT SINGLE zvalue2,zvalue3
      FROM zc_tbc1001
     WHERE zid = 'ZBC001'
       AND zvalue1 = 'SELF'
      INTO ( @lv_username, @lv_password ).

    LOOP AT cs_data-items ASSIGNING FIELD-SYMBOL(<lfs_item>).

      IF <lfs_item>-accountingdocument1 IS NOT INITIAL
      OR <lfs_item>-accountingdocument2 IS NOT INITIAL.
        <lfs_item>-message = '仕訳が既に生成されましたので、ご確認ください。'.
        CONTINUE.
      ENDIF.

      lv_postingdate = <lfs_item>-postingdate && '01'.
      lv_lastday = zzcl_common_utils=>get_enddate_of_month( lv_postingdate ).
      DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
      DATA(lv_time) = cl_abap_context_info=>get_system_time( ).
      DATA(lv_timestamp) = |{ lv_date+0(4) }-{ lv_date+4(2) }-{ lv_date+6(2) }T{ lv_time+0(2) }:{ lv_time+2(2) }:{ lv_time+4(2) }Z|.
      DATA(lv_lastday_d) = |{ lv_lastday+0(4) }-{ lv_lastday+4(2) }-{ lv_lastday+6(2) }|.

      READ TABLE lt_config INTO DATA(ls_config) WITH KEY zvalue1 = <lfs_item>-companycode
                                                         zvalue2 = <lfs_item>-companycode2
                                                         BINARY SEARCH.

      READ TABLE lt_suppliercompany INTO DATA(ls_suppliercompany) WITH KEY supplier = ls_config-zvalue3
                                                                           companycode = <lfs_item>-companycode
                                                                           BINARY SEARCH.

      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_c32_static( ).
          DATA(lv_formatted_uuid) = |{ lv_uuid+0(8) }-{ lv_uuid+8(4) }-{ lv_uuid+12(4) }-{ lv_uuid+16(4) }-{ lv_uuid+20(12) }|.
        CATCH cx_uuid_error INTO DATA(lx_uuid_error).
          <lfs_item>-message = 'UUID 作成に失敗しました: ' && lx_uuid_error->get_text( ).
          CONTINUE.
      ENDTRY.

* 仕訳1：転記先会社仕訳
      lv_request = |<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sfin="http://sap.com/xi/SAPSCORE/SFIN">| &&
      |<soapenv:Header/>| &&
      |<soapenv:Body>| &&
      |<sfin:JournalEntryBulkCreateRequest>| &&
      |<MessageHeader>| &&
      |<ID>{ lv_uuid }</ID>| && " 添加唯一消息 ID
      |<CreationDateTime>{ lv_timestamp }</CreationDateTime>| && " 使用动态时间戳
      |</MessageHeader>| &&
      |<JournalEntryCreateRequest>| &&
      |<MessageHeader>| &&
      |<ID>{ lv_uuid }</ID>| && " 添加唯一消息 ID
      |<CreationDateTime>{ lv_timestamp }</CreationDateTime>| && " 使用动态时间戳
      |</MessageHeader>| &&
      |<JournalEntry>| &&
      |<OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>| &&
      |<CompanyCode>{ <lfs_item>-companycode }</CompanyCode>| &&
      |<BusinessTransactionType>RFBU</BusinessTransactionType>| &&
      |<PostingDate>{ lv_lastday_d }</PostingDate>| &&
      |<DocumentDate>{ lv_lastday_d }</DocumentDate>| &&
      |<AccountingDocumentType>KR</AccountingDocumentType>| &&
      |<DocumentHeaderText>{ <lfs_item>-postingdate && '代行購買決済対象会社' && <lfs_item>-companycode2 }</DocumentHeaderText>| &&
      |<CreatedByUser>XXL_TEST</CreatedByUser>| &&
      |<TaxDeterminationDate>{ lv_lastday_d }</TaxDeterminationDate>| &&
      |<Item>| &&
      |<ReferenceDocumentItem>1</ReferenceDocumentItem>| &&
      |<GLAccount>{ <lfs_item>-glaccount }</GLAccount>| &&
      |<DocumentItemText>{ <lfs_item>-postingdate && '代行購買決済対象会社' && <lfs_item>-companycode2 }</DocumentItemText>| &&
      |<AmountInTransactionCurrency currencyCode="JPY">{ <lfs_item>-currency1 * -1 }</AmountInTransactionCurrency>| &&
      |<Tax>| &&
      |<TaxCode>{ <lfs_item>-taxcode }</TaxCode>| &&
      |</Tax>| &&
      |</Item>| &&
      |<CreditorItem>| &&
      |<ReferenceDocumentItem>2</ReferenceDocumentItem>| &&
      |<Creditor>{ ls_config-zvalue3 }</Creditor>| &&
      |<AltvRecnclnAccts listID="2">0021100010</AltvRecnclnAccts>| &&
      |<DocumentItemText>{ <lfs_item>-postingdate && '代行購買決済対象会社' && <lfs_item>-companycode2 }</DocumentItemText>| &&
      |<AmountInTransactionCurrency currencyCode="JPY">{ <lfs_item>-currency2 }</AmountInTransactionCurrency>| &&
      |</CreditorItem>| &&
      |<ProductTaxItem>| &&
      |<TaxCode>{ <lfs_item>-taxcode }</TaxCode>| &&
      |<TaxItemClassification>VST</TaxItemClassification>| &&
      |<AmountInTransactionCurrency currencyCode="JPY">{ <lfs_item>-currency3 * -1 }</AmountInTransactionCurrency>| &&
      |<TaxBaseAmountInTransCrcy currencyCode="JPY">{ <lfs_item>-currency1 * -1 }</TaxBaseAmountInTransCrcy>| &&
      |</ProductTaxItem>| &&
      |</JournalEntry>| &&
      |</JournalEntryCreateRequest>| &&
      |</sfin:JournalEntryBulkCreateRequest>| &&
      |</soapenv:Body>| &&
      |</soapenv:Envelope>|.

      TRY.
          DATA(lv_base_url) = |https://| && cl_abap_context_info=>get_system_url( ) && '/sap/bc/srt/scs_ext/sap/journalentrycreaterequestconfi'.
          DATA(lo_destination) = cl_http_destination_provider=>create_by_url( i_url = lv_base_url ).
          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
          DATA(lo_http_request) = lo_http_client->get_http_request( ).

          lo_http_request->set_authorization_basic( i_username = lv_username
                                                    i_password = lv_password ).
          lo_http_request->set_text( lv_request ).

          lo_http_request->set_header_field( i_name = 'Content-Type' i_value = 'text/xml' ).

          DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
          DATA(ls_http_status) = lo_response->get_status( ).

        CATCH cx_abap_context_info_error INTO DATA(lx_context_error).
          <lfs_item>-message = 'システムURLの取得に失敗しました: ' && lx_context_error->get_text( ).
          CONTINUE.
        CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
          <lfs_item>-message = 'HTTP宛先の作成に失敗しました: ' && lx_http_dest_provider_error->get_text( ).
          CONTINUE.
        CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
          <lfs_item>-message = lx_web_http_client_error->get_text( ).
          CONTINUE.
      ENDTRY.

      IF ls_http_status-code = 200.
        DATA(lv_string) = lo_response->get_text( ).
        DATA(lv_xstr) = cl_abap_conv_codepage=>create_out( )->convert( source = lv_string ).
        DATA(lo_xml_reader) = cl_sxml_string_reader=>create( lv_xstr ).
        CLEAR: lv_string1, lv_string2.
        DO.
          DATA(lo_xml_node) = lo_xml_reader->read_next_node( ).
          IF lo_xml_node IS INITIAL.
            EXIT.
          ENDIF.

          IF lo_xml_node->type = if_sxml_node=>co_nt_element_open.
            DATA(lo_xml_open_element) = CAST if_sxml_open_element( lo_xml_node ).
            DATA(lv_name) = lo_xml_open_element->qname-name.
            lv_string1 = |{ lv_string1 },{ lv_name }|.
          ENDIF.

          IF lv_name = 'AccountingDocument' AND lo_xml_node->type = if_sxml_node=>co_nt_value.
            lv_string1 = lo_xml_reader->value.
          ENDIF.

          IF lv_name = 'Note' AND lo_xml_node->type = if_sxml_node=>co_nt_value.
            IF lv_string2 IS INITIAL.
              lv_string2 = lo_xml_reader->value.
            ELSE.
              lv_string2 = lv_string2 && ' ' && lo_xml_reader->value.
            ENDIF.
          ENDIF.
        ENDDO.

        <lfs_item>-accountingdocument1 = lv_string1.

        IF <lfs_item>-accountingdocument1 <> '0000000000'.
          <lfs_item>-message = '処理が成功しました。'.
          " 仕訳が転記された後、アドオンテーブルに保存する
          CLEAR ls_ztfi_1014.
          ls_ztfi_1014-postingdate         = <lfs_item>-postingdate.
          ls_ztfi_1014-companycode         = <lfs_item>-companycode.
          ls_ztfi_1014-companycode2        = <lfs_item>-companycode2.
          ls_ztfi_1014-companycodecurrency = <lfs_item>-companycodecurrency.
          ls_ztfi_1014-taxcode             = <lfs_item>-taxcode.
          ls_ztfi_1014-fiscalyear1         = <lfs_item>-postingdate+0(4).
          ls_ztfi_1014-accountingdocument1 = <lfs_item>-accountingdocument1.
          MODIFY ztfi_1014 FROM @ls_ztfi_1014.
        ELSE.
          CLEAR <lfs_item>-accountingdocument1.
          <lfs_item>-message = lv_string2.
        ENDIF.
      ELSE.
        <lfs_item>-message = |{ ls_http_status-code } { ls_http_status-reason }|.
      ENDIF.

* 仕訳2：決済対象会社仕訳
      IF <lfs_item>-message IS INITIAL.
        TRY.
            lv_uuid = cl_system_uuid=>create_uuid_c32_static( ).
            lv_formatted_uuid = |{ lv_uuid+0(8) }-{ lv_uuid+8(4) }-{ lv_uuid+12(4) }-{ lv_uuid+16(4) }-{ lv_uuid+20(12) }|.
          CATCH cx_uuid_error INTO lx_uuid_error.
            <lfs_item>-message = 'UUID 作成に失敗しました: ' && lx_uuid_error->get_text( ).
            CONTINUE.
        ENDTRY.

        lv_date = cl_abap_context_info=>get_system_date( ).
        lv_time = cl_abap_context_info=>get_system_time( ).
        lv_timestamp = |{ lv_date+0(4) }-{ lv_date+4(2) }-{ lv_date+6(2) }T{ lv_time+0(2) }:{ lv_time+2(2) }:{ lv_time+4(2) }Z|.
        lv_lastday_d = |{ lv_lastday+0(4) }-{ lv_lastday+4(2) }-{ lv_lastday+6(2) }|.

        READ TABLE lt_config INTO DATA(ls_config2) WITH KEY zvalue1 = <lfs_item>-companycode2
                                                            zvalue2 = <lfs_item>-companycode
                                                            BINARY SEARCH.

        lv_request = |<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sfin="http://sap.com/xi/SAPSCORE/SFIN">| &&
        |<soapenv:Header/>| &&
        |<soapenv:Body>| &&
        |<sfin:JournalEntryBulkCreateRequest>| &&
        |<MessageHeader>| &&
        |<ID>{ lv_uuid }</ID>| && " 添加唯一消息 ID
        |<CreationDateTime>{ lv_timestamp }</CreationDateTime>| && " 使用动态时间戳
        |</MessageHeader>| &&
        |<JournalEntryCreateRequest>| &&
        |<MessageHeader>| &&
        |<ID>{ lv_uuid }</ID>| && " 添加唯一消息 ID
        |<CreationDateTime>{ lv_timestamp }</CreationDateTime>| && " 使用动态时间戳
        |</MessageHeader>| &&
        |<JournalEntry>| &&
        |<OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>| &&
        |<CompanyCode>{ <lfs_item>-companycode2 }</CompanyCode>| &&
        |<BusinessTransactionType>RFBU</BusinessTransactionType>| &&
        |<PostingDate>{ lv_lastday_d }</PostingDate>| &&
        |<DocumentDate>{ lv_lastday_d }</DocumentDate>| &&
        |<AccountingDocumentType>KR</AccountingDocumentType>| &&
        |<DocumentHeaderText>{ <lfs_item>-postingdate && '代行購買転記先会社' && <lfs_item>-companycode }</DocumentHeaderText>| &&
        |<CreatedByUser>XXL_TEST</CreatedByUser>| &&
        |<TaxDeterminationDate>{ lv_lastday_d }</TaxDeterminationDate>| &&
        |<Item>| &&
        |<ReferenceDocumentItem>1</ReferenceDocumentItem>| &&
        |<GLAccount>{ <lfs_item>-glaccount }</GLAccount>| &&
        |<DocumentItemText>{ <lfs_item>-postingdate && '代行購買転記先会社' && <lfs_item>-companycode }</DocumentItemText>| &&
        |<AmountInTransactionCurrency currencyCode="JPY">{ <lfs_item>-currency1 }</AmountInTransactionCurrency>| &&
        |<Tax>| &&
        |<TaxCode>{ <lfs_item>-taxcode }</TaxCode>| &&
        |</Tax>| &&
        |</Item>| &&
        |<CreditorItem>| &&
        |<ReferenceDocumentItem>2</ReferenceDocumentItem>| &&
        |<Creditor>{ ls_config2-zvalue3 }</Creditor>| &&
        |<AltvRecnclnAccts listID="2">0021100010</AltvRecnclnAccts>| &&
        |<DocumentItemText>{ <lfs_item>-postingdate && '代行購買転記先会社' && <lfs_item>-companycode }</DocumentItemText>| &&
        |<AmountInTransactionCurrency currencyCode="JPY">{ <lfs_item>-currency2 * -1 }</AmountInTransactionCurrency>| &&
        |</CreditorItem>| &&
        |<ProductTaxItem>| &&
        |<TaxCode>{ <lfs_item>-taxcode }</TaxCode>| &&
        |<TaxItemClassification>VST</TaxItemClassification>| &&
        |<AmountInTransactionCurrency currencyCode="JPY">{ <lfs_item>-currency3 }</AmountInTransactionCurrency>| &&
        |<TaxBaseAmountInTransCrcy currencyCode="JPY">{ <lfs_item>-currency1 }</TaxBaseAmountInTransCrcy>| &&
        |</ProductTaxItem>| &&
        |</JournalEntry>| &&
        |</JournalEntryCreateRequest>| &&
        |</sfin:JournalEntryBulkCreateRequest>| &&
        |</soapenv:Body>| &&
        |</soapenv:Envelope>|.

        TRY.
            lv_base_url = |https://| && cl_abap_context_info=>get_system_url( ) && '/sap/bc/srt/scs_ext/sap/journalentrycreaterequestconfi'.
            lo_destination = cl_http_destination_provider=>create_by_url( i_url = lv_base_url ).
            lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
            lo_http_request = lo_http_client->get_http_request( ).

            lo_http_request->set_authorization_basic( i_username = lv_username
                                                      i_password = lv_password ).
            lo_http_request->set_text( lv_request ).

            lo_http_request->set_header_field( i_name = 'Content-Type' i_value = 'text/xml' ).

            lo_response = lo_http_client->execute( i_method = if_web_http_client=>post ).
            ls_http_status = lo_response->get_status( ).
            lv_string = lo_response->get_text( ).

          CATCH cx_abap_context_info_error INTO lx_context_error.
            <lfs_item>-message = 'システムURLの取得に失敗しました: ' && lx_context_error->get_text( ).
            CONTINUE.
          CATCH cx_http_dest_provider_error INTO lx_http_dest_provider_error.
            <lfs_item>-message = 'HTTP宛先の作成に失敗しました: ' && lx_http_dest_provider_error->get_text( ).
            CONTINUE.
          CATCH cx_web_http_client_error INTO lx_web_http_client_error.
            <lfs_item>-message = lx_web_http_client_error->get_text( ).
            CONTINUE.
        ENDTRY.

        IF ls_http_status-code = 200.
          lv_xstr = cl_abap_conv_codepage=>create_out( )->convert( source = lv_string ).
          lo_xml_reader = cl_sxml_string_reader=>create( lv_xstr ).
          CLEAR: lv_string1, lv_string2.
          DO.
            lo_xml_node = lo_xml_reader->read_next_node( ).
            IF lo_xml_node IS INITIAL.
              EXIT.
            ENDIF.

            IF lo_xml_node->type = if_sxml_node=>co_nt_element_open.
              lo_xml_open_element = CAST if_sxml_open_element( lo_xml_node ).
              lv_name = lo_xml_open_element->qname-name.
              lv_string1 = |{ lv_string1 },{ lv_name }|.
            ENDIF.

            IF lv_name = 'AccountingDocument' AND lo_xml_node->type = if_sxml_node=>co_nt_value.
              lv_string1 = lo_xml_reader->value.
            ENDIF.

            IF lv_name = 'Note' AND lo_xml_node->type = if_sxml_node=>co_nt_value.
              IF lv_string2 IS INITIAL.
                lv_string2 = lo_xml_reader->value.
              ELSE.
                lv_string2 = lv_string2 && ' ' && lo_xml_reader->value.
              ENDIF.
            ENDIF.
          ENDDO.

          <lfs_item>-accountingdocument2 = lv_string1.

          IF <lfs_item>-accountingdocument2 <> '0000000000'.
            <lfs_item>-message = '処理が成功しました。'.

            " 仕訳が転記された後、アドオンテーブルに保存する
            CLEAR ls_ztfi_1014.
            ls_ztfi_1014-postingdate         = <lfs_item>-postingdate.
            ls_ztfi_1014-companycode         = <lfs_item>-companycode.
            ls_ztfi_1014-companycode2        = <lfs_item>-companycode2.
            ls_ztfi_1014-companycodecurrency = <lfs_item>-companycodecurrency.
            ls_ztfi_1014-taxcode             = <lfs_item>-taxcode.
            ls_ztfi_1014-fiscalyear1         = <lfs_item>-postingdate+0(4).
            ls_ztfi_1014-accountingdocument1 = <lfs_item>-accountingdocument1.
            ls_ztfi_1014-fiscalyear2         = <lfs_item>-postingdate+0(4).
            ls_ztfi_1014-accountingdocument2 = <lfs_item>-accountingdocument2.
            ls_ztfi_1014-amount              = <lfs_item>-currency2.
            MODIFY ztfi_1014 FROM @ls_ztfi_1014.
          ELSE.
            CLEAR <lfs_item>-accountingdocument2.
            <lfs_item>-message = lv_string2.
          ENDIF.
        ELSE.
          <lfs_item>-message = |{ ls_http_status-code } { ls_http_status-reason }|.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

*  METHOD create.
*  ENDMETHOD.
*
*  METHOD update.
*  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_agencypurchasing DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_agencypurchasing IMPLEMENTATION.

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
