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
    CLASS-METHODS:
      init_application_log,

      add_message_to_log IMPORTING i_text TYPE cl_bali_free_text_setter=>ty_text
                                   i_type TYPE cl_bali_free_text_setter=>ty_severity OPTIONAL
                         RAISING   cx_bali_runtime.

    CLASS-DATA:
      mo_application_log TYPE REF TO if_bali_log.

ENDCLASS.



CLASS zcl_job_agencypurchasingn IMPLEMENTATION.


  METHOD add_message_to_log.
    TRY.
        IF sy-batch = abap_true.
          DATA(lo_free_text) = cl_bali_free_text_setter=>create(
                                 severity = COND #( WHEN i_type IS NOT INITIAL
                                                    THEN i_type
                                                    ELSE if_bali_constants=>c_severity_status )
                                 text     = i_text ).

          lo_free_text->set_detail_level( detail_level = '1' ).

          mo_application_log->add_item( item = lo_free_text ).

          cl_bali_log_db=>get_instance( )->save_log( log = mo_application_log
                                                     assign_to_current_appl_job = abap_true ).

        ELSE.
*          mo_out->write( i_text ).
        ENDIF.
      CATCH cx_bali_runtime INTO DATA(cx_erro).
        DATA ls_msg TYPE scx_t100key.
        DATA(lv_msge) = cx_erro->get_text( ).
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.

    et_parameter_def = VALUE #( ( selname        = 'P_ZPOSTI'
                                  kind           = if_apj_dt_exec_object=>select_option
                                  datatype       = 'char'
                                  length         = 6
                                  param_text     = '年度期間'
                                  changeable_ind = abap_true )
                                  ( selname        = 'P_COM'
                                  kind           = if_apj_dt_exec_object=>select_option
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = '転記先会社コード'
                                  changeable_ind = abap_true )
                                  ( selname        = 'P_COM2'
                                  kind           = if_apj_dt_exec_object=>select_option
                                  datatype       = 'char'
                                  length         = 4
                                  param_text     = '決済対象会社コード'
                                  changeable_ind = abap_true ) ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA: lr_companycode  TYPE RANGE OF zc_agencypurchasing-companycode,
          lr_companycode2 TYPE RANGE OF zc_agencypurchasing-companycode2,
          ls_companycode  LIKE LINE OF lr_companycode,
          ls_companycode2 LIKE LINE OF lr_companycode2.

    DATA: lt_data TYPE STANDARD TABLE OF zc_agencypurchasing,
          lt_item TYPE STANDARD TABLE OF zc_agencypurchasing.

    DATA: ls_ztfi_1014 TYPE ztfi_1014.

    DATA: lv_datum       TYPE datum,
          lv_lastday     TYPE datum,
          lv_postingdate TYPE datum,
          lv_username    TYPE string,
          lv_password    TYPE string,
          lv_request     TYPE string,
          lv_string1     TYPE string,
          lv_string2     TYPE string,
          lv_has_error   TYPE abap_boolean.

    " 获取日志对象
    init_application_log( ).

    LOOP AT it_parameters INTO DATA(ls_parameters).
      IF ls_parameters-selname = 'P_ZPOSTI'.
        CLEAR lv_datum.
        lv_datum = ls_parameters-low && '01'.
        IF NOT zzcl_common_utils=>is_valid_date( lv_datum ).
          TRY.
              add_message_to_log( i_text = |パラメータ年度期間 { ls_parameters-low } 無効。| i_type = 'E' ).
            CATCH cx_bali_runtime INTO DATA(cx_erro).
              DATA ls_msg TYPE scx_t100key.
              DATA(lv_msge) = cx_erro->get_text( ).
          ENDTRY.
          RETURN.
        ENDIF.
        DATA(lv_postingdatefrom) = zzcl_common_utils=>get_begindate_of_month( lv_datum )..
        DATA(lv_postingdateto) = zzcl_common_utils=>get_enddate_of_month( lv_datum ).
      ENDIF.

      IF ls_parameters-selname = 'P_COM'.
        MOVE-CORRESPONDING ls_parameters TO ls_companycode.
        APPEND ls_companycode TO lr_companycode.
      ENDIF.

      IF ls_parameters-selname = 'P_COM2'.
        MOVE-CORRESPONDING ls_parameters TO ls_companycode2.
        APPEND ls_companycode2 TO lr_companycode2.
      ENDIF.
    ENDLOOP.

    IF lv_postingdatefrom IS INITIAL.
      " Parameterの実行日付
      CLEAR lv_datum.
      DATA(lv_system_date) = cl_abap_context_info=>get_system_date( ).
      lv_datum = lv_system_date+0(6) && '01'.
      lv_datum = lv_datum - 1.
      lv_postingdatefrom = zzcl_common_utils=>get_begindate_of_month( lv_datum ).
      lv_postingdateto = zzcl_common_utils=>get_enddate_of_month( lv_datum ).
    ENDIF.

**********************************************************************
* DEL BEGIN BY XINLEI XU
**********************************************************************
*    SELECT item1~postingdate,
*           item1~companycode,
*           item1~companycodecurrency,
*           item1~taxcode,
*           item2~companycode                                                            AS companycode2,
*           item1~glaccount,
*           SUM( item1~amountincompanycodecurrency )                                     AS currency1,
*           SUM( item3~amountincompanycodecurrency )                                     AS currency2,
**           sum( item3~AmountInCompanyCodeCurrency * -1 )                                     as Currency2,
**           sum( item3~AmountInCompanyCodeCurrency * -1 - Item1~AmountInCompanyCodeCurrency ) as Currency3,
*           CASE WHEN jour1~accountingdocument = ztfi_1014~accountingdocument1 THEN ' '
*           ELSE ztfi_1014~accountingdocument1 END AS accountingdocument1,
*           CASE WHEN jour2~accountingdocument = ztfi_1014~accountingdocument2 THEN ' '
*           ELSE ztfi_1014~accountingdocument2 END AS accountingdocument2
*      FROM zr_journalentryitem  AS item1
*    INNER JOIN      ztbc_1001                   ON  ztbc_1001~zid     = 'ZFI001'
*                                                AND ztbc_1001~zvalue1 = item1~glaccount
*    LEFT OUTER JOIN i_journalentryitem AS item2 ON  item1~referencedocumentcontext =  item2~referencedocumentcontext
*                                                AND item1~referencedocument        =  item2~referencedocument
*                                                AND item1~companycode              <> item2~companycode
*                                                AND item2~ledger                   =  '0L'
*                                                AND item2~taxcode              IS NOT INITIAL
*    LEFT OUTER JOIN i_journalentryitem AS item3 ON  item1~companycode          = item3~companycode
*                                                AND item1~accountingdocument   = item3~accountingdocument
*                                                AND item1~fiscalyear           = item3~fiscalyear
*                                                AND item3~financialaccounttype = 'K'
*                                                AND item3~ledger               = '0L'
*    LEFT OUTER JOIN ztfi_1014 ON  ztfi_1014~postingdate            = item1~postingdate
*                              AND ztfi_1014~companycode            = item1~companycode
*                              AND ztfi_1014~companycode2           = item2~companycode
*                              AND ztfi_1014~companycodecurrency    = item1~companycodecurrency
*                              AND ztfi_1014~taxcode                = item1~taxcode
*    LEFT OUTER JOIN i_journalentryitem AS jour1 ON jour1~companycode = item1~companycode
*                                              AND jour1~accountingdocument = ztfi_1014~accountingdocument1
*                                              AND jour1~fiscalyear = item1~fiscalyear
*                                              AND jour1~isreversed = 'X'
*    LEFT OUTER JOIN i_journalentryitem AS jour2 ON jour2~companycode = item2~companycode
*                                              AND jour2~accountingdocument = ztfi_1014~accountingdocument2
*                                              AND jour2~fiscalyear = item1~fiscalyear AND jour2~isreversed = 'X'
*WHERE item1~taxcode              IS NOT INITIAL
*  AND item3~financialaccounttype   = 'K'
*  AND item1~ledger                 = '0L'
*  AND item1~accountingdocumenttype = 'RE'
*  AND item1~postingdate >= @lv_zpostingdatef
*  AND item1~postingdate <= @lv_zpostingdatet
*  AND item1~companycode IN @lr_companycode
*  AND item2~companycode IN @lr_companycode2
*GROUP BY
*  item1~postingdate,
*  jour1~accountingdocument,
*  jour2~accountingdocument,
*  ztfi_1014~accountingdocument1,
*  ztfi_1014~accountingdocument2,
*  item1~companycode,
*  item2~companycode,
*  item1~companycodecurrency,
*  item1~taxcode,
*  item1~glaccount
*  INTO TABLE @DATA(lt_data_l).
*
*    LOOP AT lt_data_l ASSIGNING FIELD-SYMBOL(<lfs_data_l>).
*      CLEAR ls_data.
*      ls_data-zpostingdate = '20240101'.
*      ls_data-postingdate = <lfs_data_l>-postingdate.
*      ls_data-companycode = <lfs_data_l>-companycode.
*      ls_data-companycodecurrency = <lfs_data_l>-companycodecurrency.
*      ls_data-taxcode = <lfs_data_l>-taxcode.
*      ls_data-companycode2 = <lfs_data_l>-companycode2.
*      ls_data-glaccount = <lfs_data_l>-glaccount.
*      ls_data-currency1 = <lfs_data_l>-currency1.
*      ls_data-currency2 = <lfs_data_l>-currency2 * -1.
*      ls_data-currency3 = ls_data-currency2 - ls_data-currency1.
*      ls_data-accountingdocument1 = <lfs_data_l>-accountingdocument1.
*      ls_data-accountingdocument2 = <lfs_data_l>-accountingdocument2.
*      APPEND ls_data TO lt_item.
*    ENDLOOP.
**********************************************************************
* DEL END BY XINLEI XU
**********************************************************************

**********************************************************************
* ADD BEGIN BY XINLEI XU
**********************************************************************
    SELECT sourceledger,
           companycode,
           fiscalyear,
           accountingdocument,
           ledgergllineitem,
           ledger,
           postingdate AS zpostingdate,
           substring( postingdate, 1, 6 ) AS postingdate,
           referencedocumentcontext,
           referencedocument,
           companycodecurrency,
           amountincompanycodecurrency AS currency1,
           taxcode,
           glaccount
      FROM i_journalentryitem WITH PRIVILEGED ACCESS
      JOIN ztbc_1001 ON ztbc_1001~zid     = 'ZFI001'
                    AND ztbc_1001~zvalue1 = i_journalentryitem~glaccount
     WHERE ledger = '0L'
       AND accountingdocumenttype = 'RE'
       AND taxcode IS NOT INITIAL
       AND companycode IN @lr_companycode
       AND postingdate >= @lv_postingdatefrom
       AND postingdate <= @lv_postingdateto
      INTO TABLE @DATA(lt_journalentry_re).

    IF lt_journalentry_re IS NOT INITIAL.
      SELECT sourceledger,
             companycode,
             fiscalyear,
             accountingdocument,
             ledgergllineitem,
             ledger,
             referencedocumentcontext,
             referencedocument
        FROM i_journalentryitem WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_journalentry_re
       WHERE ledger = '0L'
         AND referencedocumentcontext = @lt_journalentry_re-referencedocumentcontext
         AND referencedocument = @lt_journalentry_re-referencedocument
         AND companycode <> @lt_journalentry_re-companycode
        INTO TABLE @DATA(lt_journalentry_ref).
      SORT lt_journalentry_ref BY referencedocumentcontext referencedocument.

      SELECT sourceledger,
             companycode,
             fiscalyear,
             accountingdocument,
             ledgergllineitem,
             ledger,
             amountincompanycodecurrency
        FROM i_journalentryitem WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_journalentry_re
       WHERE ledger = '0L'
         AND financialaccounttype = 'K'
         AND companycode = @lt_journalentry_re-companycode
         AND accountingdocument = @lt_journalentry_re-accountingdocument
         AND fiscalyear = @lt_journalentry_re-fiscalyear
        INTO TABLE @DATA(lt_journalentry_k).
      SORT lt_journalentry_k BY companycode fiscalyear accountingdocument.
    ENDIF.

    LOOP AT lt_journalentry_re INTO DATA(ls_journalentry_re).

      APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      <lfs_data> = CORRESPONDING #( ls_journalentry_re ).

      " 決済対象会社コード
      READ TABLE lt_journalentry_ref INTO DATA(ls_journalentry_ref) WITH KEY referencedocumentcontext = ls_journalentry_re-referencedocumentcontext
                                                                             referencedocument = ls_journalentry_re-referencedocument
                                                                             BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_data>-companycode2 = ls_journalentry_ref-companycode.
      ENDIF.

      " 会社間取引税込額
      READ TABLE lt_journalentry_k INTO DATA(ls_journalentry_k) WITH KEY companycode = ls_journalentry_re-companycode
                                                                         fiscalyear = ls_journalentry_re-fiscalyear
                                                                         accountingdocument = ls_journalentry_re-accountingdocument
                                                                         BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_data>-currency2 = ls_journalentry_k-amountincompanycodecurrency * -1.
      ENDIF.

      " 会社間取引税抜き額 = 会社間取引税込額 - 会社間取引税抜き額
      <lfs_data>-currency3 = <lfs_data>-currency2 - <lfs_data>-currency1.
    ENDLOOP.

    ##ITAB_DB_SELECT ##ITAB_KEY_IN_SELECT
    SELECT postingdate,
           companycode,
           companycode2,
           companycodecurrency,
           taxcode,
           glaccount,
           SUM( currency1 ) AS currency1,
           SUM( currency2 ) AS currency2,
           SUM( currency3 ) AS currency3
      FROM @lt_data AS a
     GROUP BY a~postingdate,
           a~companycode,
           a~companycode2,
           a~companycodecurrency,
           a~taxcode,
           a~glaccount
      INTO CORRESPONDING FIELDS OF TABLE @lt_item.

    IF lt_item IS INITIAL.
      TRY.
          add_message_to_log( i_text = 'No Data' ).
        CATCH cx_bali_runtime INTO DATA(cx_erra).
          DATA ls_msga TYPE scx_t100key.
          DATA(lv_msga) = cx_erra->get_text( ).
      ENDTRY.
      RETURN.
    ENDIF.

    SELECT *
      FROM zc_tbc1001
     WHERE zid = 'ZFI002'
      INTO TABLE @DATA(lt_config).            "#EC CI_ALL_FIELDS_NEEDED
    SORT lt_config BY zvalue1 zvalue2.

    SELECT *
      FROM i_suppliercompany
       FOR ALL ENTRIES IN @lt_item
     WHERE companycode = @lt_item-companycode
        OR companycode = @lt_item-companycode2
      INTO TABLE @DATA(lt_suppliercompany).   "#EC CI_ALL_FIELDS_NEEDED
    SORT lt_suppliercompany BY supplier companycode.

    SELECT SINGLE zvalue2, zvalue3
      FROM zc_tbc1001
     WHERE zid = 'ZBC001'
       AND zvalue1 = 'SELF'
      INTO ( @lv_username, @lv_password ).

    SELECT *
      FROM ztfi_1014
       FOR ALL ENTRIES IN @lt_item
     WHERE ztfi_1014~postingdate = @lt_item-postingdate
       AND ztfi_1014~companycode = @lt_item-companycode
       AND ztfi_1014~companycode2 = @lt_item-companycode2
       AND ztfi_1014~companycodecurrency = @lt_item-companycodecurrency
       AND ztfi_1014~taxcode = @lt_item-taxcode
      INTO TABLE @DATA(lt_fi1014).

    IF lt_fi1014 IS NOT INITIAL.
      SORT lt_fi1014 BY postingdate companycode companycode2 companycodecurrency taxcode.

      SELECT companycode,
             fiscalyear,
             accountingdocument
        FROM i_journalentryitem WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_fi1014
       WHERE companycode = @lt_fi1014-companycode
         AND accountingdocument = @lt_fi1014-accountingdocument1
         AND fiscalyear = @lt_fi1014-fiscalyear1
         AND ledger = '0L'
         AND isreversed = ''
        INTO TABLE @DATA(lt_document1).
      SORT lt_document1 BY fiscalyear companycode accountingdocument.

      SELECT companycode,
             fiscalyear,
             accountingdocument
        FROM i_journalentryitem WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_fi1014
       WHERE companycode = @lt_fi1014-companycode2
         AND accountingdocument = @lt_fi1014-accountingdocument2
         AND fiscalyear = @lt_fi1014-fiscalyear2
         AND ledger = '0L'
         AND isreversed = ''
        INTO TABLE @DATA(lt_document2).
      SORT lt_document2 BY fiscalyear companycode accountingdocument.
    ENDIF.

    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<lfs_item>).

      READ TABLE lt_fi1014 INTO DATA(ls_fi1014) WITH KEY postingdate = <lfs_item>-postingdate
                                                         companycode = <lfs_item>-companycode
                                                         companycode2 = <lfs_item>-companycode2
                                                         companycodecurrency = <lfs_item>-companycodecurrency
                                                         taxcode = <lfs_item>-taxcode
                                                         BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_document1 TRANSPORTING NO FIELDS WITH KEY fiscalyear = <lfs_item>-postingdate+0(4)
                                                                companycode = <lfs_item>-companycode
                                                                accountingdocument = ls_fi1014-accountingdocument1
                                                                BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_item>-accountingdocument1 = ls_fi1014-accountingdocument1.
        ENDIF.

        READ TABLE lt_document2 TRANSPORTING NO FIELDS WITH KEY fiscalyear = <lfs_item>-postingdate+0(4)
                                                                companycode = <lfs_item>-companycode2
                                                                accountingdocument = ls_fi1014-accountingdocument2
                                                                BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_item>-accountingdocument2 = ls_fi1014-accountingdocument2.
        ENDIF.
      ENDIF.

      IF <lfs_item>-accountingdocument1 IS NOT INITIAL
      OR <lfs_item>-accountingdocument2 IS NOT INITIAL.
        TRY.
            add_message_to_log( i_text = '仕訳が既に生成されましたので、ご確認ください。' i_type = 'E' ).
          CATCH cx_bali_runtime INTO DATA(cx_errb).
            DATA ls_msgb TYPE scx_t100key.
            DATA(lv_msgb) = cx_errb->get_text( ).
        ENDTRY.
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
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_suppliercompany INTO DATA(ls_suppliercompany) WITH KEY supplier = ls_config-zvalue3
                                                                           companycode = <lfs_item>-companycode
                                                                           BINARY SEARCH.

      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_c32_static( ).
          DATA(lv_formatted_uuid) = |{ lv_uuid+0(8) }-{ lv_uuid+8(4) }-{ lv_uuid+12(4) }-{ lv_uuid+16(4) }-{ lv_uuid+20(12) }|.
        CATCH cx_uuid_error INTO DATA(lx_uuid_error).
          TRY.
              add_message_to_log( i_text = 'UUID 作成に失敗しました: ' && lx_uuid_error->get_text( ) i_type = 'E' ).
            CATCH cx_bali_runtime INTO DATA(cx_errc).
              DATA ls_msgc TYPE scx_t100key.
              DATA(lv_msgc) = cx_errc->get_text( ).
          ENDTRY.
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
      |<CreatedByUser>{ sy-uname }</CreatedByUser>| &&
      |<TaxDeterminationDate>{ lv_lastday_d }</TaxDeterminationDate>| &&
      |<Item>| &&
      |<ReferenceDocumentItem>1</ReferenceDocumentItem>| &&
      |<GLAccount>{ <lfs_item>-glaccount }</GLAccount>| &&
      |<DocumentItemText>{ <lfs_item>-postingdate && '代行購買決済対象会社' && <lfs_item>-companycode2 }</DocumentItemText>| &&
      |<AmountInTransactionCurrency currencyCode="{ <lfs_item>-companycodecurrency }">{ <lfs_item>-currency1 * -1 }</AmountInTransactionCurrency>| &&
      |<Tax>| &&
      |<TaxCode>{ <lfs_item>-taxcode }</TaxCode>| &&
      |</Tax>| &&
      |</Item>| &&
      |<CreditorItem>| &&
      |<ReferenceDocumentItem>2</ReferenceDocumentItem>| &&
      |<Creditor>{ ls_config-zvalue3 }</Creditor>| &&
      |<AltvRecnclnAccts listID="2">0021100010</AltvRecnclnAccts>| &&
      |<DocumentItemText>{ <lfs_item>-postingdate && '代行購買決済対象会社' && <lfs_item>-companycode2 }</DocumentItemText>| &&
      |<AmountInTransactionCurrency currencyCode="{ <lfs_item>-companycodecurrency }">{ <lfs_item>-currency2 }</AmountInTransactionCurrency>| &&
      |</CreditorItem>| &&
      |<ProductTaxItem>| &&
      |<TaxCode>{ <lfs_item>-taxcode }</TaxCode>| &&
      |<TaxItemClassification>VST</TaxItemClassification>| &&
      |<AmountInTransactionCurrency currencyCode="{ <lfs_item>-companycodecurrency }">{ <lfs_item>-currency3 * -1 }</AmountInTransactionCurrency>| &&
      |<TaxBaseAmountInTransCrcy currencyCode="{ <lfs_item>-companycodecurrency }">{ <lfs_item>-currency1 * -1 }</TaxBaseAmountInTransCrcy>| &&
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
          TRY.
              add_message_to_log( i_text = 'システムURLの取得に失敗しました: ' && lx_context_error->get_text( ) i_type = 'E' ).
            CATCH cx_bali_runtime INTO DATA(cx_errd).
              DATA ls_msgd TYPE scx_t100key.
              DATA(lv_msgd) = cx_errd->get_text( ).
          ENDTRY.
          CONTINUE.
        CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
          TRY.
              add_message_to_log( i_text = 'HTTP宛先の作成に失敗しました: ' && lx_http_dest_provider_error->get_text( ) i_type = 'E' ).
            CATCH cx_bali_runtime INTO DATA(cx_erre).
              DATA ls_msge TYPE scx_t100key.
              DATA(lv_msgee) = cx_erre->get_text( ).
          ENDTRY.
          CONTINUE.
        CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
          TRY.
              add_message_to_log( i_text = CONV #( lx_web_http_client_error->get_text( ) ) i_type = 'E' ).
            CATCH cx_bali_runtime INTO DATA(cx_errf).
              DATA ls_msgf TYPE scx_t100key.
              DATA(lv_msgf) = cx_errf->get_text( ).
          ENDTRY.
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

        CLEAR lv_has_error.
        IF <lfs_item>-accountingdocument1 <> '0000000000'.
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
          TRY.
              add_message_to_log( i_text = CONV #( lv_string2 ) i_type = 'E' ).
            CATCH cx_bali_runtime INTO DATA(cx_errg).
              DATA ls_msgg TYPE scx_t100key.
              DATA(lv_msgg) = cx_errg->get_text( ).
          ENDTRY.
          lv_has_error = abap_true.
        ENDIF.
      ELSE.
        TRY.
            add_message_to_log( i_text = |{ ls_http_status-code } { ls_http_status-reason }| i_type = 'E' ).
          CATCH cx_bali_runtime INTO DATA(cx_errh).
            DATA ls_msgh TYPE scx_t100key.
            DATA(lv_msgh) = cx_errh->get_text( ).
        ENDTRY.
        lv_has_error = abap_true.
      ENDIF.

* 仕訳2：決済対象会社仕訳
      IF lv_has_error = abap_false.
        TRY.
            lv_uuid = cl_system_uuid=>create_uuid_c32_static( ).
            lv_formatted_uuid = |{ lv_uuid+0(8) }-{ lv_uuid+8(4) }-{ lv_uuid+12(4) }-{ lv_uuid+16(4) }-{ lv_uuid+20(12) }|.
          CATCH cx_uuid_error INTO lx_uuid_error.
            TRY.
                add_message_to_log( i_text = 'UUID 作成に失敗しました: ' && lx_uuid_error->get_text( ) i_type = 'E' ).
              CATCH cx_bali_runtime INTO DATA(cx_erri).
                DATA ls_msgi TYPE scx_t100key.
                DATA(lv_msgi) = cx_erri->get_text( ).
            ENDTRY.
            CONTINUE.
        ENDTRY.

        lv_date = cl_abap_context_info=>get_system_date( ).
        lv_time = cl_abap_context_info=>get_system_time( ).
        lv_timestamp = |{ lv_date+0(4) }-{ lv_date+4(2) }-{ lv_date+6(2) }T{ lv_time+0(2) }:{ lv_time+2(2) }:{ lv_time+4(2) }Z|.
        lv_lastday_d = |{ lv_lastday+0(4) }-{ lv_lastday+4(2) }-{ lv_lastday+6(2) }|.

        READ TABLE lt_config INTO DATA(ls_config2) WITH KEY zvalue1 = <lfs_item>-companycode2
                                                            zvalue2 = <lfs_item>-companycode
                                                            BINARY SEARCH.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

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
        |<CreatedByUser>{ sy-uname }</CreatedByUser>| &&
        |<TaxDeterminationDate>{ lv_lastday_d }</TaxDeterminationDate>| &&
        |<Item>| &&
        |<ReferenceDocumentItem>1</ReferenceDocumentItem>| &&
        |<GLAccount>{ <lfs_item>-glaccount }</GLAccount>| &&
        |<DocumentItemText>{ <lfs_item>-postingdate && '代行購買転記先会社' && <lfs_item>-companycode }</DocumentItemText>| &&
        |<AmountInTransactionCurrency currencyCode="{ <lfs_item>-companycodecurrency }">{ <lfs_item>-currency1 }</AmountInTransactionCurrency>| &&
        |<Tax>| &&
        |<TaxCode>{ <lfs_item>-taxcode }</TaxCode>| &&
        |</Tax>| &&
        |</Item>| &&
        |<CreditorItem>| &&
        |<ReferenceDocumentItem>2</ReferenceDocumentItem>| &&
        |<Creditor>{ ls_config2-zvalue3 }</Creditor>| &&
        |<AltvRecnclnAccts listID="2">0021100010</AltvRecnclnAccts>| &&
        |<DocumentItemText>{ <lfs_item>-postingdate && '代行購買転記先会社' && <lfs_item>-companycode }</DocumentItemText>| &&
        |<AmountInTransactionCurrency currencyCode="{ <lfs_item>-companycodecurrency }">{ <lfs_item>-currency2 * -1 }</AmountInTransactionCurrency>| &&
        |</CreditorItem>| &&
        |<ProductTaxItem>| &&
        |<TaxCode>{ <lfs_item>-taxcode }</TaxCode>| &&
        |<TaxItemClassification>VST</TaxItemClassification>| &&
        |<AmountInTransactionCurrency currencyCode="{ <lfs_item>-companycodecurrency }">{ <lfs_item>-currency3 }</AmountInTransactionCurrency>| &&
        |<TaxBaseAmountInTransCrcy currencyCode="{ <lfs_item>-companycodecurrency }">{ <lfs_item>-currency1 }</TaxBaseAmountInTransCrcy>| &&
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
            TRY.
                add_message_to_log( i_text = 'システムURLの取得に失敗しました: ' && lx_context_error->get_text( ) i_type = 'E' ).
              CATCH cx_bali_runtime INTO cx_errd.
                lv_msgd = cx_errd->get_text( ).
            ENDTRY.
            CONTINUE.
          CATCH cx_http_dest_provider_error INTO lx_http_dest_provider_error.
            TRY.
                add_message_to_log( i_text = 'HTTP宛先の作成に失敗しました: ' && lx_http_dest_provider_error->get_text( ) i_type = 'E' ).
              CATCH cx_bali_runtime INTO cx_errd.
                lv_msgd = cx_errd->get_text( ).
            ENDTRY.
            CONTINUE.
          CATCH cx_web_http_client_error INTO lx_web_http_client_error.
            TRY.
                add_message_to_log( i_text = CONV #( lx_web_http_client_error->get_text( ) ) i_type = 'E' ).
              CATCH cx_bali_runtime INTO cx_errd.
                lv_msgd = cx_errd->get_text( ).
            ENDTRY.
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
            TRY.
                add_message_to_log( i_text = '処理が成功しました。' ).
              CATCH cx_bali_runtime INTO cx_errd.
                lv_msgd = cx_errd->get_text( ).
            ENDTRY.
          ELSE.
            CLEAR <lfs_item>-accountingdocument2.
            TRY.
                add_message_to_log( i_text = CONV #( lv_string2 ) i_type = 'E' ).
              CATCH cx_bali_runtime INTO cx_errd.
                lv_msgd = cx_errd->get_text( ).
            ENDTRY.
            lv_has_error = abap_true.
          ENDIF.
        ELSE.
          TRY.
              add_message_to_log( i_text = |{ ls_http_status-code } { ls_http_status-reason }| i_type = 'E' ).
            CATCH cx_bali_runtime INTO cx_errd.
              lv_msgd = cx_errd->get_text( ).
          ENDTRY.
          lv_has_error = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.
*    lt_parameters = VALUE #( ( selname = 'P_ZPOSTI'
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '202411' )
*                               ( selname = 'P_COM'
*                               kind    = if_apj_dt_exec_object=>parameter
*                               sign    = 'I'
*                               option  = 'EQ'
*                               low     = '1100' )
**                               ( selname = 'P_COMPANYCODE2'
**                               kind    = if_apj_dt_exec_object=>parameter
**                               sign    = 'I'
**                               option  = 'EQ'
**                               low     = '1100' )
*                               ).
    TRY.
        if_apj_dt_exec_object~get_parameters( IMPORTING et_parameter_val = lt_parameters ).

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
      CATCH cx_bali_runtime INTO DATA(cx_erro).
        DATA ls_msg TYPE scx_t100key.
        DATA(lv_msge) = cx_erro->get_text( ).
        " handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
