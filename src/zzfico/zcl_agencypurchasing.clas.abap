CLASS zcl_agencypurchasing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_agencypurchasing IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    DATA: lt_data    TYPE STANDARD TABLE OF zc_agencypurchasing,
          lt_sumdata TYPE STANDARD TABLE OF zc_agencypurchasing.

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          CASE ls_filter_cond-name.
            WHEN 'ZPOSTINGDATE'.
              READ TABLE ls_filter_cond-range INTO DATA(str_rec_l_range) INDEX 1.
              IF sy-subrc = 0.
                DATA(lv_postingdatefrom) = zzcl_common_utils=>get_begindate_of_month( CONV #( str_rec_l_range-low ) ).
                IF str_rec_l_range-high IS NOT INITIAL.
                  DATA(lv_postingdateto) = zzcl_common_utils=>get_enddate_of_month( CONV #( str_rec_l_range-high ) ).
                ELSE.
                  lv_postingdateto = lv_postingdatefrom.
                ENDIF.
              ENDIF.
            WHEN 'COMPANYCODE'.
              DATA(lr_companycode) = ls_filter_cond-range.
            WHEN 'COMPANYCODE2'.
              DATA(lr_companycode2) = ls_filter_cond-range.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      CATCH cx_rap_query_filter_no_range.
        "handle exception
        io_response->set_total_number_of_records( lines( lt_sumdata ) ).

        "Sort
        IF io_request->get_sort_elements( ) IS NOT INITIAL.
          zzcl_odata_utils=>orderby(
            EXPORTING
              it_order = io_request->get_sort_elements( )
            CHANGING
              ct_data  = lt_sumdata ).
        ENDIF.

        "Page
        zzcl_odata_utils=>paging(
          EXPORTING
            io_paging = io_request->get_paging( )
          CHANGING
            ct_data   = lt_sumdata ).

        io_response->set_data( lt_sumdata ).
        RETURN.
    ENDTRY.

**********************************************************************
* DEL BEGIN BY XINLEI XU
**********************************************************************
*      SELECT item1~postingdate,
*             item1~companycode,
*             item1~companycodecurrency,
*             item1~taxcode,
*             item2~companycode                                                            AS companycode2,
*             item1~glaccount,
*             SUM( item1~amountincompanycodecurrency )                                     AS currency1,
*             SUM( item3~amountincompanycodecurrency )                                     AS currency2,
**           sum( item3~AmountInCompanyCodeCurrency * -1 )                                     as Currency2,
**           sum( item3~AmountInCompanyCodeCurrency * -1 - Item1~AmountInCompanyCodeCurrency ) as Currency3,
*             CASE WHEN jour1~accountingdocument = ztfi_1014~accountingdocument1 THEN ' '
*             ELSE ztfi_1014~accountingdocument1 END AS accountingdocument1,
*             CASE WHEN jour2~accountingdocument = ztfi_1014~accountingdocument2 THEN ' '
*             ELSE ztfi_1014~accountingdocument2 END AS accountingdocument2
*        FROM zr_journalentryitem WITH PRIVILEGED ACCESS  AS item1
*      INNER JOIN      ztbc_1001                   ON  ztbc_1001~zid     = 'ZFI001'
*                                                  AND ztbc_1001~zvalue1 = item1~glaccount
*      LEFT OUTER JOIN i_journalentryitem AS item2 ON  item1~referencedocumentcontext =  item2~referencedocumentcontext
*                                                  AND item1~referencedocument        =  item2~referencedocument
*                                                  AND item1~companycode              <> item2~companycode
*                                                  AND item2~ledger                   =  '0L'
*                                                  AND item2~taxcode              IS NOT INITIAL
*      LEFT OUTER JOIN i_journalentryitem AS item3 ON  item1~companycode          = item3~companycode
*                                                  AND item1~accountingdocument   = item3~accountingdocument
*                                                  AND item1~fiscalyear           = item3~fiscalyear
*                                                  AND item3~financialaccounttype = 'K'
*                                                  AND item3~ledger               = '0L'
*      LEFT OUTER JOIN ztfi_1014 ON  ztfi_1014~postingdate            = item1~postingdate
*                                AND ztfi_1014~companycode            = item1~companycode
*                                AND ztfi_1014~companycode2           = item2~companycode
*                                AND ztfi_1014~companycodecurrency    = item1~companycodecurrency
*                                AND ztfi_1014~taxcode                = item1~taxcode
*      LEFT OUTER JOIN i_journalentryitem AS jour1 ON jour1~companycode = item1~companycode
*                                                AND jour1~accountingdocument = ztfi_1014~accountingdocument1
*                                                AND jour1~fiscalyear = item1~fiscalyear
*                                                AND jour1~isreversed = 'X'
*      LEFT OUTER JOIN i_journalentryitem AS jour2 ON jour2~companycode = item2~companycode
*                                                AND jour2~accountingdocument = ztfi_1014~accountingdocument2
*                                                AND jour2~fiscalyear = item1~fiscalyear AND jour2~isreversed = 'X'
*  WHERE item1~taxcode              IS NOT INITIAL
*    AND item3~financialaccounttype   = 'K'
*    AND item1~ledger                 = '0L'
*    AND item1~accountingdocumenttype = 'RE'
*    AND item1~postingdate >= @lv_zpostingdatef
*    AND item1~postingdate <= @lv_zpostingdatet
*    AND item1~companycode IN @lr_companycode
*    AND item2~companycode IN @lr_companycode2
*  GROUP BY
*    item1~postingdate,
*    jour1~accountingdocument,
*    jour2~accountingdocument,
*    ztfi_1014~accountingdocument1,
*    ztfi_1014~accountingdocument2,
*    item1~companycode,
*    item2~companycode,
*    item1~companycodecurrency,
*    item1~taxcode,
*    item1~glaccount
*    INTO TABLE @DATA(lt_data_l).
*
*      LOOP AT lt_data_l ASSIGNING FIELD-SYMBOL(<lfs_data_l>).
*        CLEAR ls_data.
**      ls_data-zpostingdate = '20240101'.
*        ls_data-postingdate = <lfs_data_l>-postingdate.
*        ls_data-companycode = <lfs_data_l>-companycode.
*        ls_data-companycodecurrency = <lfs_data_l>-companycodecurrency.
*        ls_data-taxcode = <lfs_data_l>-taxcode.
*        ls_data-companycode2 = <lfs_data_l>-companycode2.
*        ls_data-glaccount = <lfs_data_l>-glaccount.
*        ls_data-currency1 = <lfs_data_l>-currency1.
*        ls_data-currency2 = <lfs_data_l>-currency2 * -1.
*        ls_data-currency3 = ls_data-currency2 - ls_data-currency1.
*        ls_data-accountingdocument1 = <lfs_data_l>-accountingdocument1.
*        ls_data-accountingdocument2 = <lfs_data_l>-accountingdocument2.
*        APPEND ls_data TO lt_data.
*      ENDLOOP.
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
           accountingdocument1,
           accountingdocument2,
           message,
           SUM( currency1 ) AS currency1,
           SUM( currency2 ) AS currency2,
           SUM( currency3 ) AS currency3
      FROM @lt_data AS a
     GROUP BY a~postingdate,
           a~companycode,
           a~companycode2,
           a~companycodecurrency,
           a~taxcode,
           a~glaccount,
           a~accountingdocument1,
           a~accountingdocument2,
           a~message
      INTO CORRESPONDING FIELDS OF TABLE @lt_sumdata.

    IF lt_sumdata IS NOT INITIAL.
      SORT lt_sumdata BY postingdate companycode companycode2 companycodecurrency taxcode.

      SELECT *
        FROM ztfi_1014
         FOR ALL ENTRIES IN @lt_sumdata
       WHERE ztfi_1014~postingdate = @lt_sumdata-postingdate
         AND ztfi_1014~companycode = @lt_sumdata-companycode
         AND ztfi_1014~companycode2 = @lt_sumdata-companycode2
         AND ztfi_1014~companycodecurrency = @lt_sumdata-companycodecurrency
         AND ztfi_1014~taxcode = @lt_sumdata-taxcode
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

      LOOP AT lt_sumdata ASSIGNING FIELD-SYMBOL(<lfs_sumdata>).
        READ TABLE lt_fi1014 INTO DATA(ls_fi1014) WITH KEY postingdate = <lfs_sumdata>-postingdate
                                                           companycode = <lfs_sumdata>-companycode
                                                           companycode2 = <lfs_sumdata>-companycode2
                                                           companycodecurrency = <lfs_sumdata>-companycodecurrency
                                                           taxcode = <lfs_sumdata>-taxcode
                                                           BINARY SEARCH.
        IF sy-subrc = 0.
          READ TABLE lt_document1 TRANSPORTING NO FIELDS WITH KEY fiscalyear = <lfs_sumdata>-postingdate+0(4)
                                                                  companycode = <lfs_sumdata>-companycode
                                                                  accountingdocument = ls_fi1014-accountingdocument1
                                                                  BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_sumdata>-accountingdocument1 = ls_fi1014-accountingdocument1.
          ENDIF.

          READ TABLE lt_document2 TRANSPORTING NO FIELDS WITH KEY fiscalyear = <lfs_sumdata>-postingdate+0(4)
                                                                  companycode = <lfs_sumdata>-companycode2
                                                                  accountingdocument = ls_fi1014-accountingdocument2
                                                                  BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_sumdata>-accountingdocument2 = ls_fi1014-accountingdocument2.
          ENDIF.

          IF <lfs_sumdata>-accountingdocument2 IS NOT INITIAL AND
             <lfs_sumdata>-accountingdocument2 IS NOT INITIAL.
            <lfs_sumdata>-message = ls_fi1014-message.
            <lfs_sumdata>-currency4 = ls_fi1014-amount. " 確定会社間取引税込額
          ENDIF.
        ENDIF.

        " ステータス
        IF <lfs_sumdata>-accountingdocument1 IS NOT INITIAL AND <lfs_sumdata>-accountingdocument2 IS NOT INITIAL AND
         ( <lfs_sumdata>-currency2 = <lfs_sumdata>-currency4 ).
          <lfs_sumdata>-status = '処理済'.
        ELSEIF <lfs_sumdata>-accountingdocument1 IS INITIAL AND
               <lfs_sumdata>-accountingdocument2 IS INITIAL AND
               <lfs_sumdata>-currency4 IS INITIAL.
          <lfs_sumdata>-status = '未処理'.
        ELSE.
          <lfs_sumdata>-status = '確認要'.
        ENDIF.

        <lfs_sumdata>-glaccount = |{ <lfs_sumdata>-glaccount ALPHA = OUT }|.
      ENDLOOP.
    ENDIF.
**********************************************************************
* ADD END BY XINLEI XU
**********************************************************************

    io_response->set_total_number_of_records( lines( lt_sumdata ) ).

    "Sort
    IF io_request->get_sort_elements( ) IS NOT INITIAL.
      zzcl_odata_utils=>orderby(
        EXPORTING
          it_order = io_request->get_sort_elements( )
        CHANGING
          ct_data  = lt_sumdata ).
    ENDIF.

    "Page
    zzcl_odata_utils=>paging(
      EXPORTING
        io_paging = io_request->get_paging( )
      CHANGING
        ct_data   = lt_sumdata ).

    io_response->set_data( lt_sumdata ).

  ENDMETHOD.

ENDCLASS.
