CLASS zcl_agencypurchasing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AGENCYPURCHASING IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA:
      lt_data TYPE STANDARD TABLE OF zc_agencypurchasing,
      ls_data TYPE zc_agencypurchasing.

    DATA:
      lr_companycode   TYPE RANGE OF zc_agencypurchasing-companycode,
      lr_companycode2  TYPE RANGE OF zc_agencypurchasing-companycode2,
      ls_companycode   LIKE LINE OF lr_companycode,
      ls_companycode2  LIKE LINE OF lr_companycode2,
      lv_zpostingdatef TYPE c LENGTH 6,
      lv_zpostingdatet TYPE c LENGTH 6,
      lr_zpostingdate  TYPE RANGE OF zc_agencypurchasing-zpostingdate.

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
            CASE ls_filter_cond-name.
              WHEN 'ZPOSTINGDATE'.
                lv_zpostingdatef = str_rec_l_range-low+0(6).
                if str_rec_l_range-high is NOT INITIAL.
                  lv_zpostingdatet = str_rec_l_range-high+0(6).
                ELSE.
                  lv_zpostingdatet = lv_zpostingdatef.
                endif.

              WHEN 'COMPANYCODE'.
                CLEAR ls_companycode.
                ls_companycode-sign   = 'I'.
                ls_companycode-option = 'EQ'.
                ls_companycode-low    = str_rec_l_range-low.
                APPEND ls_companycode TO lr_companycode.
              WHEN 'COMPANYCODE2'.
                CLEAR ls_companycode2.
                ls_companycode2-sign   = 'I'.
                ls_companycode2-option = 'EQ'.
                ls_companycode2-low    = str_rec_l_range-low.
                APPEND ls_companycode2 TO lr_companycode2.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.
        ENDLOOP.

      CATCH cx_rap_query_filter_no_range.

        "handle exception
        io_response->set_data( lt_data ).
    ENDTRY.

    SELECT item1~postingdate,
           item1~companycode,
           item1~companycodecurrency,
           item1~taxcode,
           item2~companycode                                                            AS companycode2,
           item1~glaccount,
           SUM( item1~amountincompanycodecurrency )                                     AS currency1,
           SUM( item3~amountincompanycodecurrency )                                     AS currency2,
*           sum( item3~AmountInCompanyCodeCurrency * -1 )                                     as Currency2,
*           sum( item3~AmountInCompanyCodeCurrency * -1 - Item1~AmountInCompanyCodeCurrency ) as Currency3,
           CASE WHEN jour1~accountingdocument = ztfi_1014~accountingdocument1 THEN ' '
           ELSE ztfi_1014~accountingdocument1 END AS accountingdocument1,
           CASE WHEN jour2~accountingdocument = ztfi_1014~accountingdocument2 THEN ' '
           ELSE ztfi_1014~accountingdocument2 END AS accountingdocument2,
           ztfi_1014~message,
           ztfi_1014~uuid1,
           ztfi_1014~uuid2
      FROM zr_journalentryitem WITH PRIVILEGED ACCESS  AS item1
    INNER JOIN      ztbc_1001                   ON  ztbc_1001~zid     = 'ZFI001'
                                                AND ztbc_1001~zvalue1 = item1~glaccount
    LEFT OUTER JOIN i_journalentryitem AS item2 ON  item1~referencedocumentcontext =  item2~referencedocumentcontext
                                                AND item1~referencedocument        =  item2~referencedocument
                                                AND item1~companycode              <> item2~companycode
                                                AND item2~ledger                   =  '0L'
                                                AND item2~taxcode              IS NOT INITIAL
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
                                              AND jour2~fiscalyear = item1~fiscalyear AND jour2~isreversed = 'X'
WHERE item1~taxcode              IS NOT INITIAL
  AND item3~financialaccounttype   = 'K'
  AND item1~ledger                 = '0L'
  AND item1~accountingdocumenttype = 'RE'
  AND item1~postingdate >= @lv_zpostingdatef
  AND item1~postingdate <= @lv_zpostingdatet
  AND item1~companycode IN @lr_companycode
  AND item2~companycode IN @lr_companycode2
GROUP BY
  item1~postingdate,
  jour1~accountingdocument,
  jour2~accountingdocument,
  ztfi_1014~accountingdocument1,
  ztfi_1014~accountingdocument2,
  ztfi_1014~message,
  item1~companycode,
  item2~companycode,
  item1~companycodecurrency,
  item1~taxcode,
  item1~glaccount,
  ztfi_1014~uuid1,
  ztfi_1014~uuid2
  INTO TABLE @DATA(lt_data_l).

    LOOP AT lt_data_l ASSIGNING FIELD-SYMBOL(<lfs_data_l>).
      CLEAR ls_data.
*      ls_data-zpostingdate = '20240101'.
      ls_data-postingdate = <lfs_data_l>-postingdate.
      ls_data-companycode = <lfs_data_l>-companycode.
      ls_data-companycodecurrency = <lfs_data_l>-companycodecurrency.
      ls_data-taxcode = <lfs_data_l>-taxcode.
      ls_data-companycode2 = <lfs_data_l>-companycode2.
      ls_data-glaccount = <lfs_data_l>-glaccount.
      ls_data-currency1 = <lfs_data_l>-currency1.
      ls_data-currency2 = <lfs_data_l>-currency2 * -1.
      ls_data-currency3 = ls_data-currency2 - ls_data-currency1.
      ls_data-accountingdocument1 = <lfs_data_l>-accountingdocument1.
      ls_data-accountingdocument2 = <lfs_data_l>-accountingdocument2.
      ls_data-message = <lfs_data_l>-message.
*      ls_data-uuid1   = '1001'.
*      ls_data-uuid2   = '1002'.
      APPEND ls_data TO lt_data.
    ENDLOOP.

    SORT lt_data by postingdate companycode companycode2 companycodecurrency taxcode.
    io_response->set_total_number_of_records( lines( lt_data ) ).

    "Sort
    IF io_request->get_sort_elements( ) IS NOT INITIAL.
      zzcl_odata_utils=>orderby(
        EXPORTING
          it_order = io_request->get_sort_elements( )
        CHANGING
          ct_data  = lt_data ).
    ENDIF.

    "Page
    zzcl_odata_utils=>paging(
      EXPORTING
        io_paging = io_request->get_paging( )
      CHANGING
        ct_data   = lt_data ).

    io_response->set_data( lt_data ).

  ENDMETHOD.
ENDCLASS.
