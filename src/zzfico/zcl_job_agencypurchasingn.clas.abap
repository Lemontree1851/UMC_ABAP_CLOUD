CLASS zcl_job_agencypurchasingn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS init_application_log.

    CLASS-DATA:
      mo_application_log TYPE REF TO if_bali_log.

    TYPES:
      BEGIN OF ts_response,
        _company_code TYPE bukrs,
        _customer     TYPE kunnr,
        _supplier     TYPE lifnr,
        _fiscal_year1 TYPE c LENGTH 4,
        _document1    TYPE c LENGTH 10,
        _fiscal_year2 TYPE c LENGTH 4,
        _document2    TYPE c LENGTH 10,
        _fiscal_year3 TYPE c LENGTH 4,
        _document3    TYPE c LENGTH 10,
        _fiscal_year4 TYPE c LENGTH 4,
        _document4    TYPE c LENGTH 10,
        _message      TYPE c LENGTH 500,
        _status       TYPE c LENGTH 1,
      END OF ts_response.
    TYPES:
      lt_deep_t     TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
      ls_response_t TYPE ts_response.

    "!
    "! @parameter ct_deep |
    "! @parameter cs_response |
    "! @parameter cv_fail |
    "! @parameter cv_i |
    METHODS boi  CHANGING ct_deep     TYPE lt_deep_t
                          cs_response TYPE ls_response_t
                          cv_fail     TYPE c
                          cv_i        TYPE i.
ENDCLASS.



CLASS zcl_job_agencypurchasingn IMPLEMENTATION.
  METHOD if_apj_rt_exec_object~execute.

  ENDMETHOD.

  METHOD if_apj_dt_exec_object~get_parameters.

    " 获取日志对象
    init_application_log( ).

    SELECT SUBSTRING( item1~postingdate,1,6 ) as postingdate,
           item1~companycode,
           item2~companycode                                                            AS companycode2,
           item1~companycodecurrency,
           item1~taxcode,
          item1~ledger,
          item1~glaccount,
          item1~accountingdocument,
          item1~fiscalyear,
          item1~fiscalyearperiod,
          item1~referencedocumentcontext,
          item1~referencedocument,
          SUM( item1~amountincompanycodecurrency )                                     AS currency1,
          SUM( item3~amountincompanycodecurrency )                                      AS currency2,
          SUM(  item3~amountincompanycodecurrency - item1~amountincompanycodecurrency ) AS currency3,
      CASE WHEN jour1~accountingdocument = ztfi_1014~accountingdocument1 THEN ' '
      ELSE ztfi_1014~accountingdocument1 END AS accountingdocument1,
      CASE WHEN jour2~accountingdocument = ztfi_1014~accountingdocument2 THEN ' '
      ELSE ztfi_1014~accountingdocument2 END AS accountingdocument2,
          ztfi_1014~message AS message
    FROM    i_journalentryitem AS item1
        INNER JOIN      ztbc_1001                   ON  ztbc_1001~zid     = 'ZFI001'
                                                    AND ztbc_1001~zvalue1 = item1~glaccount
        INNER JOIN      ztbc_1001 AS ztbc_1001c     ON  ztbc_1001c~zid     = 'ZFI002'
                                                    AND ztbc_1001c~zvalue1 = item1~companycode
        LEFT OUTER JOIN i_journalentryitem AS item2 ON  item1~referencedocumentcontext =  item2~referencedocumentcontext
                                                    AND item1~referencedocument        =  item2~referencedocument
                                                    AND item1~companycode              <> item2~companycode
                                                    AND item2~ledger                   =  '0L'
        LEFT OUTER JOIN i_journalentryitem AS item3 ON  item1~companycode          = item3~companycode
                                                    AND item1~accountingdocument   = item3~accountingdocument
                                                    AND item1~fiscalyear           = item3~fiscalyear
                                                    AND item3~financialaccounttype = 'K'
                                                    AND item3~ledger               = '0L'
        LEFT OUTER JOIN ztfi_1014 ON  ztfi_1014~postingdate            = item1~postingdate
                                  AND ztfi_1014~companycode            = item1~companycode
                                  AND ztfi_1014~companycode2           = item2~companycode
                                  AND ztfi_1014~companycodecurrency    = item1~companycodecurrency
                                  AND ztfi_1014~taxcode                = item1~taxcode
    LEFT OUTER JOIN i_journalentryitem AS jour1 ON jour1~companycode = item1~companycode
                                              AND jour1~accountingdocument = ztfi_1014~accountingdocument1
                                              AND jour1~fiscalyear = item1~fiscalyear
                                              AND jour1~isreversed = 'X'
    LEFT OUTER JOIN i_journalentryitem AS jour2 ON jour2~companycode = item2~companycode
                                              AND jour2~accountingdocument = ztfi_1014~accountingdocument2
                                              AND jour2~fiscalyear = item1~fiscalyear
                                              AND jour2~isreversed = 'X'
    WHERE item1~taxcode              IS NOT INITIAL
      AND item3~financialaccounttype = 'K'
      AND item1~ledger               = '0L'
      AND item1~accountingdocumenttype = 'RE'
    GROUP BY
      jour1~accountingdocument,
      jour2~accountingdocument,
      ztfi_1014~accountingdocument1,
      ztfi_1014~accountingdocument2,
      ztfi_1014~message,
      item1~postingdate,
      item1~companycode,
      item2~companycode,
      item1~companycodecurrency,
      item1~taxcode,
      item1~glaccount,
      item1~accountingdocument,
      item1~ledger,
      item2~ledger,
      item3~ledger,
      item1~fiscalyearperiod,
      item1~referencedocumentcontext,
      item1~referencedocument,
      item1~fiscalyear
      INTO TABLE @DATA(lt_item).

    DATA:
      lt_deep     TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
      ls_deep     TYPE STRUCTURE FOR ACTION IMPORT i_journalentrytp~post,
      lt_deep_rev TYPE TABLE FOR ACTION IMPORT i_journalentrytp~reverse,
      ls_deep_rev TYPE STRUCTURE FOR ACTION IMPORT i_journalentrytp~reverse.

    DATA:
      ls_ztfi_1014 TYPE ztfi_1014.

    DATA:
      i          TYPE i,
      lv_lastday TYPE sy-datum,
      lv_postingdate TYPE sy-datum,
      lv_cr(9)   TYPE p DECIMALS 2,
      lv_cr1(9)  TYPE p DECIMALS 2,
      lv_cr2(9)  TYPE p DECIMALS 2,
      lv_dr(9)   TYPE p DECIMALS 2,
      lv_msg     TYPE string,
      lv_message TYPE string,
      lv_fail    TYPE c LENGTH 1.

    CONSTANTS: lc_config_id           TYPE ztbc_1001-zid VALUE `ZFI002`.

    DATA:
      ls_response       TYPE ts_response.
* data:lv_uuid TYPE SYSUUID_X16.
    DATA:
      lv_request  TYPE string,
      lv_error(1) TYPE c,
      lv_text     TYPE string.

    SELECT *
    FROM zc_tbc1001
    WHERE zid = @lc_config_id
    INTO TABLE @DATA(lt_config).              "#EC CI_ALL_FIELDS_NEEDED
    SORT lt_config BY zvalue1 zvalue2.

    DATA(lt_items) = lt_item.
    SORT lt_items BY companycode companycode2.
    DELETE ADJACENT DUPLICATES FROM lt_items COMPARING companycode companycode2.

    IF lt_items IS NOT INITIAL.
      SELECT *
      FROM i_suppliercompany
      FOR ALL ENTRIES IN @lt_items
      WHERE companycode = @lt_items-companycode
      OR companycode = @lt_items-companycode2
      INTO TABLE @DATA(lt_suppliercompany).   "#EC CI_ALL_FIELDS_NEEDED
      SORT lt_suppliercompany BY supplier companycode.
    ENDIF.

    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<lfs_item>).
      <lfs_item>-Currency2 = <lfs_item>-Currency2 * -1.
      <lfs_item>-Currency3 = <lfs_item>-Currency2 * -1 - <lfs_item>-Currency1.

      IF <lfs_item>-accountingdocument1 IS NOT INITIAL
      OR <lfs_item>-accountingdocument2 IS NOT INITIAL.
        <lfs_item>-message = '仕訳が既に生成されましたので、ご確認ください。'.
        CONTINUE.
      ENDIF.

      CLEAR lv_error.

* 仕訳1：転記先会社仕訳
      lv_postingdate = <lfs_item>-postingdate && '01'.
      lv_lastday = zzcl_common_utils=>get_enddate_of_month(
      EXPORTING
      iv_date = lv_postingdate ).

      READ TABLE lt_config INTO DATA(ls_config)
      WITH KEY zvalue1 = <lfs_item>-companycode
      zvalue2 = <lfs_item>-companycode2
      BINARY SEARCH.

      READ TABLE lt_suppliercompany INTO DATA(ls_suppliercompany)
      WITH KEY supplier = ls_config-zvalue3
      companycode = <lfs_item>-companycode
      BINARY SEARCH.

      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_c32_static( ).
        CATCH cx_uuid_error INTO DATA(lx_uuid_error).
          " 处理 UUID 错误
          lv_error = 'X'.
          lv_text = 'UUID 作成に失敗しました: ' && lx_uuid_error->get_text( ).
          " 处理错误或记录日志
*          <lfs_item>-uuid1 = lv_uuid.
          <lfs_item>-message = lv_text.
          EXIT.
      ENDTRY.

      " 格式化 UUID 添加分隔符
      DATA lv_formatted_uuid TYPE string.
      lv_formatted_uuid = |{ lv_uuid+0(8) }-{ lv_uuid+8(4) }-{ lv_uuid+12(4) }-{ lv_uuid+16(4) }-{ lv_uuid+20(12) }|.

      TRY.
          DATA(lv_base_url) = |https://| && cl_abap_context_info=>get_system_url( ) && '/sap/bc/srt/scs_ext/sap/journalentrycreaterequestconfi'.
          DATA(lo_destination) = cl_http_destination_provider=>create_by_url( i_url = lv_base_url ).
        CATCH cx_abap_context_info_error INTO DATA(lx_context_error).
          " 处理上下文信息错误
          lv_error = 'X'.
          lv_text = 'システムURLの取得に失敗しました: ' && lx_context_error->get_text( ).
*          <lfs_item>-uuid1 = lv_uuid.
          <lfs_item>-message = lv_text.
          EXIT.
        CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
          " 处理 HTTP 目的地提供者错误
          lv_error = 'X'.
          lv_text = 'HTTP宛先の作成に失敗しました: ' && lx_http_dest_provider_error->get_text( ).
*          <lfs_item>-uuid1 = lv_uuid.
          <lfs_item>-message = lv_text.
          EXIT.
      ENDTRY.

      TRY.
          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

          DATA: lv_username TYPE string, " 存储用户名
                lv_password TYPE string. " 存储密码

          " 从表 ZC_TBC1001 中读取用户名和密码
          SELECT SINGLE zvalue2,zvalue3
          FROM zc_tbc1001
          WHERE zid = 'ZBC001'
          AND zvalue1 = 'SELF'
          INTO (@lv_username,@lv_password).

          IF sy-subrc <> 0.
            " 处理密码读取失败的情况
            lv_error = 'X'.
            lv_text = 'ZC_TBC1001テーブルからユーザー名またはパスワードを読み込めませんでした'.

*            <lfs_item>-uuid1 = lv_uuid.
            <lfs_item>-message = lv_text.
            EXIT.
          ENDIF.

          " 使用读取的用户名和密码进行 HTTP 请求的授权
          lo_http_client->get_http_request( )->set_authorization_basic(
          i_username = lv_username
          i_password = lv_password ).


          "DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
        CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
          lv_error = 'X'.
          lv_text = 'HTTP 要求失敗: ' && lx_web_http_client_error->get_text( ).

*          <lfs_item>-uuid1 = lv_uuid.
          <lfs_item>-message = lv_text.
          EXIT.
      ENDTRY.

      DATA(lo_http_request) = lo_http_client->get_http_request( ).

      DATA(lv_date) = sy-datum. " 获取当前日期
      DATA(lv_time) = sy-uzeit. " 获取当前时间

      DATA(lv_timestamp) = |{ lv_date+0(4) }-{ lv_date+4(2) }-{ lv_date+6(2) }T{ lv_time+0(2) }:{ lv_time+2(2) }:{ lv_time+4(2) }Z|.
      DATA(lv_lastday_d) = |{ lv_lastday+0(4) }-{ lv_lastday+4(2) }-{ lv_lastday+6(2) }|.
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


      " 设置请求数据
      lo_http_request->set_text( lv_request ).

      " 设置请求头
      lo_http_request->set_header_field( i_name = 'Content-Type' i_value = 'text/xml' ).


* DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
      TRY.
          DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
        CATCH cx_web_http_client_error INTO DATA(lx_http_error).
          " 在这里处理异常，例如记录错误日志或返回自定义错误消息
          lv_text = 'HTTP リクエストに失敗しました。接続や設定を確認してください。'.
          lv_error = 'X'.
*          <lfs_item>-uuid1 = lv_uuid.
          <lfs_item>-message = lv_text.
          EXIT.
      ENDTRY.

      lo_response->get_status( RECEIVING r_value = DATA(ls_http_status) ).
*      IF ls_http_status-code = 200.
      DATA(lv_string) = lo_response->get_text( ).

*        /ui2/cl_json=>deserialize(
*        EXPORTING json = lv_string
*        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
*        CHANGING data = ls_response ).


      DATA(lv_xstr) = cl_abap_conv_codepage=>create_out( )->convert( source = lv_string ).
      DATA(lo_xml_reader) = cl_sxml_string_reader=>create( lv_xstr ).
      DATA:lv_string1 TYPE string,
           lv_string2 TYPE string.
      CLEAR lv_string2.
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
        IF  lv_name = 'AccountingDocument'
        AND lo_xml_node->type = if_sxml_node=>co_nt_value.
          lv_string1 = lo_xml_reader->value.
        ENDIF.

        IF  lv_name = 'Note'
        AND lo_xml_node->type = if_sxml_node=>co_nt_value.
          IF lv_string2 IS INITIAL.
            lv_string2 = lo_xml_reader->value.
          ELSE.
            lv_string2 = lv_string2 && ' ' && lo_xml_reader->value.
          ENDIF.
        ENDIF.
      ENDDO.

      <lfs_item>-accountingdocument1 = lv_string1.

      IF <lfs_item>-accountingdocument1 <> '0000000000'.

        " 成功消息
        lv_text = '処理が成功しました。'.
        lv_error = ''.


        <lfs_item>-message = lv_text.

*       仕訳が転記された後、アドオンテーブルに保存する
        CLEAR ls_ztfi_1014.
        ls_ztfi_1014-postingdate         = <lfs_item>-postingdate.
        ls_ztfi_1014-companycode         = <lfs_item>-companycode.
        ls_ztfi_1014-companycode2        = <lfs_item>-companycode2.
        ls_ztfi_1014-companycodecurrency = <lfs_item>-companycodecurrency.
        ls_ztfi_1014-taxcode             = <lfs_item>-taxcode.
        ls_ztfi_1014-accountingdocument1 = <lfs_item>-accountingdocument1.
        ls_ztfi_1014-accountingdocument2 = ''.
*        ls_ztfi_1014-message             = <lfs_item>-message.
        MODIFY ztfi_1014 FROM @ls_ztfi_1014.
      ELSE.
        CLEAR <lfs_item>-accountingdocument1.
        lv_string = lo_response->get_text( ).
        lv_text = lv_string2.

        lv_error = 'X'.
*        <lfs_item>-uuid1 = lv_uuid.
        <lfs_item>-message = lv_text.

*       仕訳が転記された後、アドオンテーブルに保存する
        CLEAR ls_ztfi_1014.
        ls_ztfi_1014-postingdate         = <lfs_item>-postingdate.
        ls_ztfi_1014-companycode         = <lfs_item>-companycode.
        ls_ztfi_1014-companycode2        = <lfs_item>-companycode2.
        ls_ztfi_1014-companycodecurrency = <lfs_item>-companycodecurrency.
        ls_ztfi_1014-taxcode             = <lfs_item>-taxcode.
        ls_ztfi_1014-accountingdocument1 = ''.
        ls_ztfi_1014-accountingdocument2 = ''.
        ls_ztfi_1014-message             = ''.
        MODIFY ztfi_1014 FROM @ls_ztfi_1014.
        EXIT.
      ENDIF.

* 仕訳2：決済対象会社仕訳
      IF lv_error <> 'X'.
        lv_postingdate = <lfs_item>-postingdate && '01'.
        lv_lastday = zzcl_common_utils=>get_enddate_of_month(
        EXPORTING
        iv_date = lv_postingdate ).
*
*        READ TABLE lt_config INTO DATA(ls_config)
*        WITH KEY zvalue1 = <lfs_item>-companycode
*        zvalue2 = <lfs_item>-companycode2
*        BINARY SEARCH.
*
*        READ TABLE lt_suppliercompany INTO DATA(ls_suppliercompany)
*        WITH KEY supplier = ls_config-zvalue3
*        companycode = <lfs_item>-companycode
*        BINARY SEARCH.

        TRY.
            lv_uuid = cl_system_uuid=>create_uuid_c32_static( ).
          CATCH cx_uuid_error INTO lx_uuid_error.
            " 处理 UUID 错误
            lv_error = 'X'.
            lv_text = 'UUID 作成に失敗しました: ' && lx_uuid_error->get_text( ).
            " 处理错误或记录日志
*            <lfs_item>-uuid1 = lv_uuid.
            <lfs_item>-message = lv_text.
            EXIT.
        ENDTRY.

        " 格式化 UUID 添加分隔符
        lv_formatted_uuid = |{ lv_uuid+0(8) }-{ lv_uuid+8(4) }-{ lv_uuid+12(4) }-{ lv_uuid+16(4) }-{ lv_uuid+20(12) }|.

        TRY.
            lv_base_url = |https://| && cl_abap_context_info=>get_system_url( ) && '/sap/bc/srt/scs_ext/sap/journalentrycreaterequestconfi'.
            lo_destination = cl_http_destination_provider=>create_by_url( i_url = lv_base_url ).
          CATCH cx_abap_context_info_error INTO lx_context_error.
            " 处理上下文信息错误
            lv_error = 'X'.
            lv_text = 'システムURLの取得に失敗しました: ' && lx_context_error->get_text( ).
*            <lfs_item>-uuid1 = lv_uuid.
            <lfs_item>-message = lv_text.
            EXIT.
          CATCH cx_http_dest_provider_error INTO lx_http_dest_provider_error.
            " 处理 HTTP 目的地提供者错误
            lv_error = 'X'.
            lv_text = 'HTTP宛先の作成に失敗しました: ' && lx_http_dest_provider_error->get_text( ).
*            <lfs_item>-uuid1 = lv_uuid.
            <lfs_item>-message = lv_text.
            EXIT.
        ENDTRY.

        TRY.
            lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

            " 从表 ZC_TBC1001 中读取用户名和密码
            SELECT SINGLE zvalue2,zvalue3
            FROM zc_tbc1001
            WHERE zid = 'ZBC001'
            AND zvalue1 = 'SELF'
            INTO (@lv_username,@lv_password).

            IF sy-subrc <> 0.
              " 处理密码读取失败的情况
              lv_error = 'X'.
              lv_text = 'ZC_TBC1001テーブルからユーザー名またはパスワードを読み込めませんでした'.

*              <lfs_item>-uuid1 = lv_uuid.
              <lfs_item>-message = lv_text.
              EXIT.
            ENDIF.

            " 使用读取的用户名和密码进行 HTTP 请求的授权
            lo_http_client->get_http_request( )->set_authorization_basic(
            i_username = lv_username
            i_password = lv_password ).


            "DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
          CATCH cx_web_http_client_error INTO lx_web_http_client_error.
            lv_error = 'X'.
            lv_text = 'HTTP 要求失敗: ' && lx_web_http_client_error->get_text( ).

*            <lfs_item>-uuid1 = lv_uuid.
            <lfs_item>-message = lv_text.
            EXIT.
        ENDTRY.

        lo_http_request = lo_http_client->get_http_request( ).

        lv_date = sy-datum. " 获取当前日期
        lv_time = sy-uzeit. " 获取当前时间

        lv_timestamp = |{ lv_date+0(4) }-{ lv_date+4(2) }-{ lv_date+6(2) }T{ lv_time+0(2) }:{ lv_time+2(2) }:{ lv_time+4(2) }Z|.
        lv_lastday_d = |{ lv_lastday+0(4) }-{ lv_lastday+4(2) }-{ lv_lastday+6(2) }|.
* 仕訳2：決済対象会社仕訳
        READ TABLE lt_config INTO DATA(ls_config2)
        WITH KEY zvalue1 = <lfs_item>-companycode2
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


        " 设置请求数据
        lo_http_request->set_text( lv_request ).

        " 设置请求头
        lo_http_request->set_header_field( i_name = 'Content-Type' i_value = 'text/xml' ).


* DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
        TRY.
            lo_response = lo_http_client->execute( i_method = if_web_http_client=>post ).
          CATCH cx_web_http_client_error INTO lx_http_error.
            " 在这里处理异常，例如记录错误日志或返回自定义错误消息
            lv_text = 'HTTP リクエストに失敗しました。接続や設定を確認してください。'.
            lv_error = 'X'.
*            <lfs_item>-uuid1 = lv_uuid.
            <lfs_item>-message = lv_text.
            EXIT.
        ENDTRY.

        lo_response->get_status( RECEIVING r_value = ls_http_status ).
        lv_string = lo_response->get_text( ).
        lv_xstr = cl_abap_conv_codepage=>create_out( )->convert( source = lv_string ).
        lo_xml_reader = cl_sxml_string_reader=>create( lv_xstr ).
        CLEAR lv_string2.
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
          IF  lv_name = 'AccountingDocument'
          AND lo_xml_node->type = if_sxml_node=>co_nt_value.
            lv_string1 = lo_xml_reader->value.
          ENDIF.

          IF  lv_name = 'Note'
          AND lo_xml_node->type = if_sxml_node=>co_nt_value.
            IF lv_string2 IS INITIAL.
              lv_string2 = lo_xml_reader->value.
            ELSE.
              lv_string2 = lv_string2 && ' ' && lo_xml_reader->value.
            ENDIF.
          ENDIF.
        ENDDO.

        <lfs_item>-accountingdocument2 = lv_string1.
        IF <lfs_item>-accountingdocument2 <> '0000000000'.

          " 成功消息
          lv_text = '処理が成功しました。'.
          lv_error = ''.

          <lfs_item>-message = lv_text.

*       仕訳が転記された後、アドオンテーブルに保存する
          CLEAR ls_ztfi_1014.
          ls_ztfi_1014-postingdate         = <lfs_item>-postingdate.
          ls_ztfi_1014-companycode         = <lfs_item>-companycode.
          ls_ztfi_1014-companycode2        = <lfs_item>-companycode2.
          ls_ztfi_1014-companycodecurrency = <lfs_item>-companycodecurrency.
          ls_ztfi_1014-taxcode             = <lfs_item>-taxcode.
          ls_ztfi_1014-accountingdocument1 = <lfs_item>-accountingdocument1.
          ls_ztfi_1014-accountingdocument2 = <lfs_item>-accountingdocument2.
*          ls_ztfi_1014-message             = <lfs_item>-message.
          MODIFY ztfi_1014 FROM @ls_ztfi_1014.
        ELSE.
          CLEAR <lfs_item>-accountingdocument2.

          lv_text = lv_string2.

          lv_error = 'X'.
*          <lfs_item>-uuid1 = lv_uuid.
          <lfs_item>-message = lv_text.

*       仕訳が転記された後、アドオンテーブルに保存する
          CLEAR ls_ztfi_1014.
          ls_ztfi_1014-postingdate         = <lfs_item>-postingdate.
          ls_ztfi_1014-companycode         = <lfs_item>-companycode.
          ls_ztfi_1014-companycode2        = <lfs_item>-companycode2.
          ls_ztfi_1014-companycodecurrency = <lfs_item>-companycodecurrency.
          ls_ztfi_1014-taxcode             = <lfs_item>-taxcode.
          ls_ztfi_1014-accountingdocument1 = <lfs_item>-accountingdocument1.
          ls_ztfi_1014-accountingdocument2 = ''.
          ls_ztfi_1014-message             = ''.
          MODIFY ztfi_1014 FROM @ls_ztfi_1014.
          EXIT.
        ENDIF.
** document
*        i += 1.
*        ls_deep-%cid = |My%CID_{ i }|.
*
*        ls_deep-%param-companycode = <lfs_item>-companycode2.
*        ls_deep-%param-businesstransactiontype = 'RFBU'.
*        ls_deep-%param-postingdate = lv_lastday.
*        ls_deep-%param-documentdate = lv_lastday.
*        ls_deep-%param-accountingdocumenttype = 'KR'.
*        ls_deep-%param-accountingdocumentheadertext = <lfs_item>-postingdate
*        && '代行購買転記先会社'
*        && <lfs_item>-companycode.
*        CLEAR ls_config.
*        SELECT SINGLE *
*        FROM zc_tbc1001
*        WHERE zid = @lc_config_id
*        AND zvalue1 = @<lfs_item>-companycode2
*        AND zvalue2 = @<lfs_item>-companycode
*        INTO @ls_config.                      "#EC CI_ALL_FIELDS_NEEDED
*
*        CLEAR ls_suppliercompany.
*        SELECT SINGLE *
*        FROM i_suppliercompany
*        WHERE supplier = @ls_config-zvalue3
*        AND companycode = @<lfs_item>-companycode2
*        INTO @ls_suppliercompany.             "#EC CI_ALL_FIELDS_NEEDED
*
*        ls_deep-%param-_glitems =
*        VALUE #(
*        ( glaccountlineitem = |001|
*        glaccount = <lfs_item>-glaccount
*        documentitemtext = <lfs_item>-postingdate && '代行購買転記先会社' && <lfs_item>-companycode
*        taxcode = <lfs_item>-taxcode
*        _currencyamount =
*        VALUE #( ( currencyrole = '00'
*        journalentryitemamount = <lfs_item>-currency1
*        currency = <lfs_item>-companycodecurrency ) )
*        )
*        ( glaccountlineitem = |002|
*        taxcode = <lfs_item>-taxcode
*        documentitemtext = <lfs_item>-postingdate && '代行購買転記先会社' && <lfs_item>-companycode
*        _currencyamount =
*        VALUE #( ( currencyrole = '00'
*        journalentryitemamount = <lfs_item>-currency3
*        currency = <lfs_item>-companycodecurrency ) )
*        )
*        ( glaccountlineitem = |003|
*        glaccount = '0021100010'
*        documentitemtext = <lfs_item>-postingdate && '代行購買転記先会社' && <lfs_item>-companycode
*        taxcode = <lfs_item>-taxcode
*        _currencyamount =
*        VALUE #( ( currencyrole = '00'
*        journalentryitemamount = <lfs_item>-currency2 * -1
*        currency = <lfs_item>-companycodecurrency ) )
*        )
*
*        ).
*
*        ls_deep-%param-_apitems =
*        VALUE #(
*        ( glaccountlineitem = |003|
*        supplier = ls_config-zvalue3
*        )
*
*        ).
*
*        ls_deep-%param-_aritems =
*        VALUE #(
*        ( glaccountlineitem = |003|
*        paymentterms = ls_suppliercompany-paymentterms
*        )
*
*        ).
*
*        APPEND ls_deep TO lt_deep.

*        boi( CHANGING ct_deep = lt_deep
*        cs_response = ls_response
*        cv_fail = lv_fail
*        cv_i = i ).
*
*        CLEAR: ls_deep, lt_deep.
      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    " for debugger
    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.
*    lt_parameters = VALUE #( ( selname = 'P_ID'
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '8B3CF2B54B611EEFA2D72EB68B20D50C' ) ).
    TRY.
*        if_apj_rt_exec_object~execute( it_parameters = lt_parameters ).
        if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_root INTO DATA(lo_root).
        out->write( |Exception has occured: { lo_root->get_text(  ) }| ).
    ENDTRY.
  ENDMETHOD.


  METHOD init_application_log.
    TRY.
        mo_application_log = cl_bali_log=>create_with_header(
                               header = cl_bali_header_setter=>create( object      = 'ZZ_LOG_FICO028'
                                                                       subobject   = 'ZZ_LOG_FICO028_SUB'
*                                                                       external_id = CONV #( mv_uuid )
                                                                       ) ).
      CATCH cx_bali_runtime.
        " handle exception
    ENDTRY.
  ENDMETHOD.

  METHOD boi.

  ENDMETHOD.

ENDCLASS.
