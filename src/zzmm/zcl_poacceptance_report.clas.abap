CLASS zcl_poacceptance_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_POACCEPTANCE_REPORT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TYPES:
      BEGIN OF ts_dimension,
        purchaseorder               TYPE ebeln,
        purchaseorderitem           TYPE ebelp,
        materialdocumentyear        TYPE mjahr,
        materialdocument            TYPE mblnr,
        materialdocumentitem        TYPE mblpo,
        fiscalyear                  TYPE mjahr,
        supplierinvoice             TYPE re_belnr,
        supplierinvoiceitem         TYPE rblgp,
        referencedocumentfiscalyear TYPE lfgja,
        referencedocument           TYPE lfbnr,
        referencedocumentitem       TYPE lfpos,
        del                         TYPE c LENGTH 1,
      END OF ts_dimension,

      BEGIN OF ts_ekes,
        purchaseorder             TYPE ebeln,
        purchaseorderitem         TYPE ebelp,
        sequentialnmbrofsuplrconf TYPE n LENGTH 4,
        deliverydate              TYPE eindt,
        confirmedquantity         TYPE menge_d,
      END OF ts_ekes.

    "select options
    DATA:
      lr_awkey  TYPE RANGE OF awkey,
      lrs_awkey LIKE LINE OF lr_awkey.

    DATA:
      lt_ekes   TYPE STANDARD TABLE OF ts_ekes,
      ls_ekes   TYPE ts_ekes,
      lt_mat    TYPE STANDARD TABLE OF ts_dimension,
      ls_mat    TYPE ts_dimension,
      lt_inv    TYPE STANDARD TABLE OF ts_dimension,
      ls_inv    TYPE ts_dimension,
      lt_pur    TYPE STANDARD TABLE OF ts_dimension,
      ls_pur    TYPE ts_dimension,
      lt_output TYPE STANDARD TABLE OF zr_poacceptance,
      ls_output TYPE zr_poacceptance.

    DATA:
      lv_netpr_jp(12) TYPE p DECIMALS 3,
      lv_netpr(12)    TYPE p DECIMALS 5,
      lv_ebeln        TYPE ebeln,
      lv_ebelp        TYPE ebelp,
      lv_tabix        TYPE i,
      lv_flg          TYPE c LENGTH 1,
      lv_count        TYPE i,
      lv_rate         TYPE i,
      lv_diff1        TYPE i,
      lv_diff2        TYPE i.

    CONSTANTS:
      lc_zid(6)   TYPE c VALUE 'ZMM001',
      lc_zkey1(7) TYPE c VALUE 'TAXCODE'.


    IF io_request->is_data_requested( ).
* Get filter range
      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).

          LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
            CASE ls_filter_cond-name.
              WHEN 'PURCHASEORDER'.
                DATA(lr_ebeln) = ls_filter_cond-range.
              WHEN 'SUPPLIER'.
                DATA(lr_lifnr) = ls_filter_cond-range.
              WHEN 'PURCHASINGGROUP'.
                DATA(lr_ekgrp) = ls_filter_cond-range.
              WHEN 'MATERIAL'.
                DATA(lr_matnr) = ls_filter_cond-range.
              WHEN 'PLANT'.
                DATA(lr_werks) = ls_filter_cond-range.
              WHEN 'PURCHASEORDERITEMUNIQUEID'.
                DATA(lr_poitem) = ls_filter_cond-range.
              WHEN 'PURCHASINGORGANIZATION'.
                DATA(lr_ekorg) = ls_filter_cond-range.
              WHEN 'MATERIALGROUP'.
                DATA(lr_matkl) = ls_filter_cond-range.
              WHEN 'DOCUMENTDATE'.
                DATA(lr_date1) = ls_filter_cond-range.
              WHEN 'POSTINGDATE'.
                DATA(lr_date2) = ls_filter_cond-range.
              WHEN 'INVOICEDOCUMENTDATE'.
                DATA(lr_date3) = ls_filter_cond-range.
              WHEN 'INVOICEDOCUMENTPOSTINGDATE'.
                DATA(lr_date4) = ls_filter_cond-range.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.
        CATCH cx_rap_query_filter_no_range.
          "handle exception
          io_response->set_data( lt_output ).
      ENDTRY.
* Get Tax
      SELECT zvalue1,
             zvalue2
        FROM ztbc_1001
       WHERE zid = @lc_zid
         AND zkey1 = @lc_zkey1
        INTO TABLE @DATA(lt_ztbc_1001).

* Get PO data

      SELECT a~purchaseorder,
           a~purchaseordertype,
           a~purchaseorderdate,
           a~companycode,
           a~purchasingorganization,
           a~purchasinggroup,
           a~supplier,
           a~documentcurrency,
           a~exchangerate,
           b~purchaseorderitem,
           b~purchaseorderitemuniqueid,
           b~materialgroup,
           b~material,
           b~suppliermaterialnumber,
           b~purchaseorderitemtext,
           b~plant,
           b~purchaseorderquantityunit,
           b~netpricequantity,
           b~requirementtracking,
           b~requisitionername,
           b~orderpriceunit,
           b~pricingdatecontrol,
           b~purchasinginforecord,
           b~accountassignmentcategory,
           b~netamount,
           b~orderquantity,
           b~netpriceamount,
           b~taxcode,
           b~purgdocpricedate
      FROM i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS a
        INNER JOIN i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS AS b
        ON ( a~purchaseorder = b~purchaseorder )
     WHERE a~purchaseorder IN @lr_ebeln
       AND a~purchasinggroup IN @lr_ekgrp
       AND a~supplier IN @lr_lifnr
       AND a~purchasingorganization IN @lr_ekorg
       AND b~purchaseorderitemuniqueid IN @lr_poitem
       AND b~purchasingdocumentdeletioncode = @space
       AND b~material IN @lr_matnr
       AND b~materialgroup IN @lr_matkl
       AND b~plant IN @lr_werks
      INTO TABLE @DATA(lt_po).


      IF lt_po IS NOT INITIAL.
* Get Product
        SELECT product,
               productmanufacturernumber,
               yy1_customermaterial_prd
          FROM i_product
          FOR ALL ENTRIES IN @lt_po
         WHERE product = @lt_po-material
          INTO TABLE @DATA(lt_product).

* Get Purchasing Group
        SELECT purchasinggroup,
               purchasinggroupname
          FROM i_purchasinggroup
          FOR ALL ENTRIES IN @lt_po
         WHERE purchasinggroup = @lt_po-purchasinggroup
          INTO TABLE @DATA(lt_purchasinggroup).

* Get Business Partner Name
        SELECT businesspartner,
               organizationbpname1
          FROM i_businesspartner
          FOR ALL ENTRIES IN @lt_po
         WHERE businesspartner = @lt_po-supplier
          INTO TABLE @DATA(lt_bp).

* Get EKES
        SELECT purchaseorder,
               purchaseorderitem,
               sequentialnmbrofsuplrconf,
               deliverydate,
               confirmedquantity
          FROM i_posupplierconfirmationapi01
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_po
         WHERE purchaseorder = @lt_po-purchaseorder
           AND purchaseorderitem = @lt_po-purchaseorderitem
           AND supplierconfirmationcategory = 'AB'
           AND isdeleted = @space
          INTO TABLE @DATA(lt_ekes_tmp).

* Get Schedule
        SELECT purchaseorder,
               purchaseorderitem,
               schedulelinedeliverydate
          FROM i_purordschedulelineapi01
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_po
         WHERE purchaseorder = @lt_po-purchaseorder
           AND purchaseorderitem = @lt_po-purchaseorderitem
           AND purchaseorderscheduleline = 1
          INTO TABLE @DATA(lt_eket).

* Get Accounting Assignment
        SELECT purchaseorder,
               purchaseorderitem,
               accountassignmentnumber,
               costcenter,
               glaccount,
               profitcenter
          FROM i_purordaccountassignmentapi01
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_po
         WHERE purchaseorder = @lt_po-purchaseorder
           AND purchaseorderitem = @lt_po-purchaseorderitem
          INTO TABLE @DATA(lt_ekkn).

* Get ekbe
        SELECT purchaseorder,
               purchaseorderitem,
               accountassignmentnumber,
               purchasinghistorydocumenttype,
               purchasinghistorydocumentyear,
               purchasinghistorydocument,
               purchasinghistorydocumentitem,
               postingdate,
               debitcreditcode,
               referencedocumentfiscalyear,
               referencedocument,
               referencedocumentitem,
               taxcode,
               documentdate,
               accountingdocumentcreationdate,
               purghistdocumentcreationtime,
               quantity,
               purchaseorderamount,
               invoiceamtinpurordtransaccrcy
          FROM i_purchaseorderhistoryapi01
          WITH PRIVILEGED ACCESS
          FOR ALL ENTRIES IN @lt_po
         WHERE purchaseorder = @lt_po-purchaseorder
           AND purchaseorderitem = @lt_po-purchaseorderitem
           AND ( ( purchasinghistorydocumenttype = '1'  "入出庫伝票
               AND documentdate IN @lr_date1
               AND postingdate IN @lr_date2 )
              OR ( purchasinghistorydocumenttype = '2'  "請求書
               AND documentdate IN @lr_date3
               AND postingdate IN @lr_date4 ) )
          INTO TABLE @DATA(lt_ekbe).

        IF lt_ekbe IS NOT INITIAL.
* Get Material Doc. data
          SELECT materialdocumentyear,
                 materialdocument,
                 materialdocumentheadertext
            FROM i_materialdocumentheader_2
            WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_ekbe
           WHERE materialdocumentyear = @lt_ekbe-purchasinghistorydocumentyear
             AND materialdocument = @lt_ekbe-purchasinghistorydocument
            INTO TABLE @DATA(lt_matdoc).

          SELECT supplierinvoice,
                 fiscalyear,
                 supplierinvoicewthnfiscalyear,
                 companycode,
                 invoicingparty,
                 exchangerate,
                 duecalculationbasedate
            FROM i_supplierinvoiceapi01
            WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_ekbe
           WHERE supplierinvoice = @lt_ekbe-purchasinghistorydocument
             AND fiscalyear = @lt_ekbe-purchasinghistorydocumentyear
            INTO TABLE @DATA(lt_invoice).
        ENDIF.

        LOOP AT lt_invoice INTO DATA(ls_invoice).
          lrs_awkey-sign = 'I'.
          lrs_awkey-option = 'EQ'.
          lrs_awkey-low = ls_invoice-supplierinvoicewthnfiscalyear.
          APPEND lrs_awkey TO lr_awkey.
          CLEAR: lrs_awkey.
        ENDLOOP.

        IF lt_invoice IS NOT INITIAL.
          SELECT companycode,
                 fiscalyear,
                 accountingdocument,
                 originalreferencedocument
            FROM i_journalentry
            WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_invoice
           WHERE companycode = @lt_invoice-companycode
             AND fiscalyear = @lt_invoice-fiscalyear
             AND originalreferencedocument IN @lr_awkey
            INTO TABLE @DATA(lt_bkpf).
        ENDIF.

      ENDIF.

* Check ekes count
      LOOP AT lt_ekes_tmp ASSIGNING FIELD-SYMBOL(<lfs_ekes>)
                GROUP BY ( purchaseorder = <lfs_ekes>-purchaseorder )
                REFERENCE INTO DATA(member).
        LOOP AT GROUP member ASSIGNING FIELD-SYMBOL(<lfs_member>).
          lv_count = lv_count + 1.
        ENDLOOP.
        IF lv_count = 1.
          ls_ekes-purchaseorder = <lfs_member>-purchaseorder.
          ls_ekes-purchaseorderitem = <lfs_member>-purchaseorderitem.
          ls_ekes-deliverydate = <lfs_member>-deliverydate.
          ls_ekes-confirmedquantity = <lfs_member>-confirmedquantity.
          APPEND ls_ekes TO lt_ekes.
          CLEAR: ls_ekes, lv_count.
        ENDIF.
      ENDLOOP.

* edit dimension
* -split ekbe into matdoc and invoice
      LOOP AT lt_ekbe INTO DATA(ls_ekbe).
        IF ls_ekbe-purchasinghistorydocumenttype = '1'.
          ls_mat-purchaseorder = ls_ekbe-purchaseorder.
          ls_mat-purchaseorderitem = ls_ekbe-purchaseorderitem.
          ls_mat-materialdocumentyear = ls_ekbe-purchasinghistorydocumentyear.
          ls_mat-materialdocument = ls_ekbe-purchasinghistorydocument.
          ls_mat-materialdocumentitem = ls_ekbe-purchasinghistorydocumentitem.
          ls_mat-referencedocumentfiscalyear = ls_ekbe-referencedocumentfiscalyear.
          ls_mat-referencedocument = ls_ekbe-referencedocument.
          ls_mat-referencedocumentitem = ls_ekbe-referencedocumentitem.
          APPEND ls_mat TO lt_mat.
          CLEAR: ls_mat.
        ELSE.
          ls_inv-purchaseorder = ls_ekbe-purchaseorder.
          ls_inv-purchaseorderitem = ls_ekbe-purchaseorderitem.
          ls_inv-fiscalyear = ls_ekbe-purchasinghistorydocumentyear.
          ls_inv-supplierinvoice = ls_ekbe-purchasinghistorydocument.
          ls_inv-supplierinvoiceitem = ls_ekbe-purchasinghistorydocumentitem.
          ls_inv-referencedocumentfiscalyear = ls_ekbe-referencedocumentfiscalyear.
          ls_inv-referencedocument = ls_ekbe-referencedocument.
          ls_inv-referencedocumentitem = ls_ekbe-referencedocumentitem.
          APPEND ls_inv TO lt_inv.
          CLEAR: ls_inv.
        ENDIF.
      ENDLOOP.

      SORT lt_mat BY purchaseorder purchaseorderitem materialdocumentyear materialdocument materialdocumentitem.
      SORT lt_inv BY purchaseorder purchaseorderitem fiscalyear supplierinvoice supplierinvoiceitem.
      LOOP AT lt_mat INTO ls_mat.
        IF ls_mat-purchaseorder <> lv_ebeln
        OR ls_mat-purchaseorderitem <> lv_ebelp.
          CLEAR: lv_flg, lv_tabix.
          READ TABLE lt_inv INTO ls_inv
               WITH KEY purchaseorder = ls_mat-purchaseorder
                        purchaseorderitem = ls_mat-purchaseorderitem BINARY SEARCH.
          IF sy-subrc = 0.
            lv_tabix = sy-tabix.
          ELSE.
            lv_flg = 'X'.
          ENDIF.
        ENDIF.

        IF lv_flg IS INITIAL.
          READ TABLE lt_inv ASSIGNING FIELD-SYMBOL(<lfs_inv>) INDEX lv_tabix.
          IF <lfs_inv>-purchaseorder = ls_mat-purchaseorder
         AND <lfs_inv>-purchaseorderitem = ls_mat-purchaseorderitem.
            <lfs_inv>-del = 'X'.
            ls_pur-fiscalyear = <lfs_inv>-fiscalyear.
            ls_pur-supplierinvoice = <lfs_inv>-supplierinvoice.
            ls_pur-supplierinvoiceitem = <lfs_inv>-supplierinvoiceitem.
          ENDIF.
        ENDIF.
        ls_pur-purchaseorder = ls_mat-purchaseorder.
        ls_pur-purchaseorderitem = ls_mat-purchaseorderitem.
        ls_pur-materialdocumentyear = ls_mat-materialdocumentyear.
        ls_pur-materialdocument = ls_mat-materialdocument.
        ls_pur-materialdocumentitem = ls_mat-materialdocumentitem.
        APPEND ls_pur TO lt_pur.
        CLEAR: ls_pur.

        lv_tabix = lv_tabix + 1.
        lv_ebeln = ls_mat-purchaseorder.
        lv_ebelp = ls_mat-purchaseorderitem.
      ENDLOOP.
      DELETE lt_inv WHERE del = 'X'.

      LOOP AT lt_inv INTO ls_inv.
        ls_pur-purchaseorder = ls_inv-purchaseorder.
        ls_pur-purchaseorderitem = ls_inv-purchaseorderitem.
        ls_pur-fiscalyear = ls_inv-fiscalyear.
        ls_pur-supplierinvoice = ls_inv-supplierinvoice.
        ls_pur-supplierinvoiceitem = ls_inv-supplierinvoiceitem.
        ls_pur-materialdocumentyear = ls_inv-referencedocumentfiscalyear.
        ls_pur-materialdocument = ls_inv-referencedocument.
        ls_pur-materialdocumentitem = ls_inv-referencedocumentitem.
        APPEND ls_pur TO lt_pur.
        CLEAR: ls_pur.
      ENDLOOP.

* Edit output
      SORT lt_po BY purchaseorder purchaseorderitem.
      SORT lt_product BY product.
      SORT lt_purchasinggroup BY purchasinggroup.
      SORT lt_bp BY businesspartner.
      SORT lt_eket BY purchaseorder purchaseorderitem.
      SORT lt_ekes BY purchaseorder purchaseorderitem.
      SORT lt_ekes_tmp BY purchaseorder purchaseorderitem deliverydate.
      SORT lt_ekkn BY purchaseorder purchaseorderitem.
      SORT lt_ekbe BY purchaseorder purchaseorderitem
                      purchasinghistorydocumentyear purchasinghistorydocument
                      purchasinghistorydocumentitem.
      SORT lt_matdoc BY materialdocumentyear materialdocument.
      SORT lt_invoice BY fiscalyear supplierinvoice.
      SORT lt_bkpf BY companycode fiscalyear originalreferencedocument.
* --1. PO with material document or invoice
      LOOP AT lt_pur INTO ls_pur.
        READ TABLE lt_po INTO DATA(ls_po)
             WITH KEY purchaseorder = ls_pur-purchaseorder
                      purchaseorderitem = ls_pur-purchaseorderitem BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-purchaseorder = ls_pur-purchaseorder.
          ls_output-purchaseorderitem = ls_pur-purchaseorderitem.
          ls_output-purchaseorderitemuniqueid = ls_po-purchaseorderitemuniqueid.
          ls_output-companycode = ls_po-companycode.
          ls_output-purchasingorganization = ls_po-purchasingorganization.
          ls_output-purchasinggroup = ls_po-purchasinggroup.
          ls_output-supplier = ls_po-supplier.
          ls_output-documentcurrency = ls_po-documentcurrency.
          ls_output-purchaseorderdate = ls_po-purchaseorderdate.
          ls_output-purchaseordertype = ls_po-purchaseordertype.
          ls_output-exchangerate = ls_po-exchangerate.
          ls_output-material = ls_po-material.
          ls_output-materialgroup = ls_po-materialgroup.
          ls_output-purchaseorderitemtext = ls_po-purchaseorderitemtext.
          ls_output-suppliermaterialnumber = ls_po-suppliermaterialnumber.
          ls_output-plant = ls_po-plant.
          ls_output-purchaseorderquantityunit = ls_po-purchaseorderquantityunit.
          ls_output-netpricequantity = ls_po-netpricequantity.
          ls_output-accountassignmentcategory = ls_po-accountassignmentcategory.
          ls_output-netamount = ls_po-netpriceamount. "正味発注価格
          ls_output-orderquantity = ls_po-orderquantity.
          ls_output-requirementtracking = ls_po-requirementtracking.
          ls_output-requisitionername = ls_po-requisitionername.
          ls_output-taxcode = ls_po-taxcode.

          IF ls_po-documentcurrency = 'JPY'.
            lv_netpr_jp = ls_po-netpriceamount.
            lv_netpr_jp = zzcl_common_utils=>conversion_amount( iv_alpha = 'OUT'
                                                  iv_currency = ls_po-documentcurrency
                                                  iv_input = lv_netpr_jp ).
            lv_netpr_jp = lv_netpr_jp / ls_po-netpricequantity.
            ls_output-netprice1 = lv_netpr_jp.  "発注単価
            ls_output-netprice2 = lv_netpr_jp.  "取引通貨単価
            lv_netpr_jp = lv_netpr_jp * ls_po-exchangerate.
            ls_output-netprice3 = lv_netpr_jp.  "円換算後単価(PO)
          ELSE.
            lv_netpr = ls_po-netpriceamount / ls_po-netpricequantity.
            ls_output-netprice1 = lv_netpr.     "発注単価
            ls_output-netprice2 = lv_netpr.  "取引通貨単価
            lv_netpr = lv_netpr * ls_po-exchangerate.
            ls_output-netprice3 = lv_netpr.     "円換算後単価(PO)
          ENDIF.
          CONDENSE ls_output-netprice1 NO-GAPS.
          CONDENSE ls_output-netprice2 NO-GAPS.
          CONDENSE ls_output-netprice3 NO-GAPS.
        ENDIF.
        READ TABLE lt_product INTO DATA(ls_product)
             WITH KEY product = ls_po-material BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-productmanufacturernumber = ls_product-productmanufacturernumber.
          ls_output-customermaterial = ls_product-yy1_customermaterial_prd.  "顧客品番
        ENDIF.

        READ TABLE lt_purchasinggroup INTO DATA(ls_purchasinggroup)
             WITH KEY purchasinggroup = ls_po-purchasinggroup BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-purchasinggroupname = ls_purchasinggroup-purchasinggroupname.
        ENDIF.

        READ TABLE lt_bp INTO DATA(ls_bp)
             WITH KEY businesspartner = ls_po-supplier BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-suppliername = ls_bp-organizationbpname1.
        ENDIF.

        READ TABLE lt_eket INTO DATA(ls_eket)
             WITH KEY purchaseorder = ls_po-purchaseorder
                      purchaseorderitem = ls_po-purchaseorderitem BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-schedulelinedeliverydate = ls_eket-schedulelinedeliverydate.
        ENDIF.

        READ TABLE lt_ekkn INTO DATA(ls_ekkn)
             WITH KEY purchaseorder = ls_po-purchaseorder
                      purchaseorderitem = ls_po-purchaseorderitem BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-costcenter = ls_ekkn-costcenter.
          ls_output-profitcenter = ls_ekkn-profitcenter.
          ls_output-glaccount = ls_ekkn-glaccount.
        ENDIF.

        READ TABLE lt_ekbe INTO ls_ekbe
             WITH KEY purchaseorder = ls_pur-purchaseorder
                      purchaseorderitem = ls_pur-purchaseorderitem
                      purchasinghistorydocumentyear = ls_pur-materialdocumentyear
                      purchasinghistorydocument = ls_pur-materialdocument
                      purchasinghistorydocumentitem = ls_pur-materialdocumentitem BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-fiscalyear = ls_ekbe-purchasinghistorydocumentyear.
          ls_output-materialdocument = ls_ekbe-purchasinghistorydocument.
          ls_output-materialdocumentitem = ls_ekbe-purchasinghistorydocumentitem.
          IF ls_ekbe-debitcreditcode = 'S'.
            ls_output-quantity1 = ls_ekbe-quantity.   "受入数量
            ls_output-taxexcludedprice = ls_ekbe-purchaseorderamount.  "受入金額（税抜）
          ELSE.
            ls_output-quantity1 = -1 * ls_ekbe-quantity.   "受入数量
            ls_output-taxexcludedprice = -1 * ls_ekbe-purchaseorderamount.  "受入金額（税抜）
          ENDIF.
          "入出庫伝票の登録日付
          ls_output-accountingdocumentcreationdate = ls_ekbe-accountingdocumentcreationdate.
          ls_output-documentdate = ls_ekbe-documentdate.  "入出庫伝票の伝票日付
          ls_output-postingdate = ls_ekbe-postingdate.    "入出庫伝票の転記日付
          ls_output-purghistdocumentcreationtime = ls_ekbe-purghistdocumentcreationtime.  "入出庫伝票の登録時刻
        ENDIF.

        READ TABLE lt_ekes INTO ls_ekes
                     WITH KEY purchaseorder = ls_po-purchaseorder
                              purchaseorderitem = ls_po-purchaseorderitem BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-deliverydate = ls_ekes-deliverydate.
          ls_output-dlvqty = ls_ekes-confirmedquantity.
        ELSE.
          LOOP AT lt_ekes_tmp INTO DATA(ls_ekes_tmp1)
                              WHERE purchaseorder = ls_po-purchaseorder
                                AND purchaseorderitem = ls_po-purchaseorderitem
                                AND deliverydate <= ls_ekbe-documentdate.
            lv_diff1 = ls_ekbe-postingdate - ls_ekes_tmp1-deliverydate.
            EXIT.
          ENDLOOP.

          LOOP AT lt_ekes_tmp INTO DATA(ls_ekes_tmp2)
                              WHERE purchaseorder = ls_po-purchaseorder
                                AND purchaseorderitem = ls_po-purchaseorderitem
                                AND deliverydate >= ls_ekbe-documentdate.
            lv_diff2 = ls_ekes_tmp1-deliverydate - ls_ekbe-postingdate.
            EXIT.
          ENDLOOP.

          IF lv_diff1 <> 0
         AND lv_diff2 <> 0.
            IF lv_diff1 > lv_diff2.
              ls_output-deliverydate = ls_ekes_tmp2-deliverydate.
              ls_output-dlvqty = ls_ekes_tmp2-confirmedquantity.
            ELSEIF lv_diff1 <= lv_diff2.
              ls_output-deliverydate = ls_ekes_tmp1-deliverydate.
              ls_output-dlvqty = ls_ekes_tmp1-confirmedquantity.
            ENDIF.
          ELSEIF lv_diff1 = 0.
            ls_output-deliverydate = ls_ekes_tmp2-deliverydate.
            ls_output-dlvqty = ls_ekes_tmp2-confirmedquantity.
          ELSEIF lv_diff2 = 0.
            ls_output-deliverydate = ls_ekes_tmp1-deliverydate.
            ls_output-dlvqty = ls_ekes_tmp1-confirmedquantity.
          ENDIF.
        ENDIF.

        READ TABLE lt_matdoc INTO DATA(ls_matdoc)
             WITH KEY materialdocumentyear = ls_pur-materialdocumentyear
                      materialdocument = ls_pur-materialdocument BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-materialdocumentheadertext = ls_matdoc-materialdocumentheadertext.
        ENDIF.

        READ TABLE lt_ztbc_1001 INTO DATA(ls_1001)
             WITH KEY zvalue1 = ls_po-taxcode.
        IF sy-subrc = 0.
          lv_rate = ls_1001-zvalue2.   "Tax rate
          IF lv_rate <> 0.
            ls_output-taxrate = lv_rate && '%'.
            CONDENSE ls_output-taxrate NO-GAPS.
          ENDIF.
        ENDIF.

        READ TABLE lt_ekbe INTO ls_ekbe
             WITH KEY purchaseorder = ls_pur-purchaseorder
                      purchaseorderitem = ls_pur-purchaseorderitem
                      purchasinghistorydocumentyear = ls_pur-fiscalyear
                      purchasinghistorydocument = ls_pur-supplierinvoice
                      purchasinghistorydocumentitem = ls_pur-supplierinvoiceitem BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-supplierinvoice = ls_ekbe-purchasinghistorydocument.
          ls_output-supplierinvoiceitem = ls_ekbe-purchasinghistorydocumentitem.
          ls_output-invoicedocumentdate = ls_ekbe-documentdate.
          ls_output-invoicedocumentpostingdate = ls_ekbe-postingdate.

          IF ls_ekbe-debitcreditcode = 'S'.
            ls_output-quantity2 = ls_ekbe-quantity.
            "請求書金額（税込）
            ls_output-invoiceamtinpurordtransaccrcy = ls_ekbe-invoiceamtinpurordtransaccrcy.
            "消費税額
            ls_output-vat1 = ls_ekbe-invoiceamtinpurordtransaccrcy * lv_rate / 100.
          ELSE.
            ls_output-quantity2 = -1 * ls_ekbe-quantity.
            ls_output-invoiceamtinpurordtransaccrcy = -1 * ls_ekbe-invoiceamtinpurordtransaccrcy.
            ls_output-vat1 = -1 * ls_ekbe-invoiceamtinpurordtransaccrcy * lv_rate / 100.
          ENDIF.
          ls_output-invoiceamount = ls_output-invoiceamtinpurordtransaccrcy + ls_output-vat1.
        ENDIF.

        READ TABLE lt_invoice INTO ls_invoice
             WITH KEY fiscalyear = ls_pur-fiscalyear
                      supplierinvoice = ls_pur-supplierinvoice BINARY SEARCH.
        IF sy-subrc = 0.
          ls_output-invoicingparty = ls_invoice-invoicingparty.
          ls_output-duecalculationbasedate = ls_invoice-duecalculationbasedate.
          lv_netpr = ls_output-vat1 * ls_invoice-exchangerate.
          lv_netpr = zzcl_common_utils=>conversion_amount( iv_alpha = 'OUT'
                                                  iv_currency = ls_po-documentcurrency
                                                  iv_input = lv_netpr ).
          IF lv_netpr >= 0.
            ls_output-vat2 = lv_netpr.
          ELSE.
            ls_output-vat2 = |{ lv_netpr SIGN = LEFTPLUS }|.
          ENDIF.

          lv_netpr = ls_output-invoiceamount * ls_invoice-exchangerate.
          lv_netpr = zzcl_common_utils=>conversion_amount( iv_alpha = 'OUT'
                                                  iv_currency = ls_po-documentcurrency
                                                  iv_input = lv_netpr ).
          IF lv_netpr >= 0.
            ls_output-netamount3 = lv_netpr.
          ELSE.
            ls_output-netamount3 = |{ lv_netpr SIGN = LEFTPLUS }|.
          ENDIF.

          READ TABLE lt_bkpf INTO DATA(ls_bkpf)
             WITH KEY companycode = ls_invoice-companycode
                      fiscalyear = ls_invoice-fiscalyear
                      originalreferencedocument = ls_invoice-supplierinvoicewthnfiscalyear BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-accountingdocument = ls_bkpf-accountingdocument.
          ENDIF.
        ENDIF.

        APPEND ls_output TO lt_output.
        CLEAR: ls_output, ls_po, ls_product,
               ls_purchasinggroup, ls_bp, ls_eket,
               ls_ekes, ls_ekkn, ls_ekbe, ls_matdoc,
               ls_invoice, ls_bkpf.
      ENDLOOP.
* --2. PO without material document or invoice
      SORT lt_pur BY purchaseorder purchaseorderitem.
      DELETE ADJACENT DUPLICATES FROM lt_pur COMPARING purchaseorder purchaseorderitem.
      LOOP AT lt_po INTO ls_po.
        READ TABLE lt_pur
             WITH KEY purchaseorder = ls_po-purchaseorder
                      purchaseorderitem = ls_po-purchaseorderitem
             BINARY SEARCH
             TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          ls_output-purchaseorder = ls_po-purchaseorder.
          ls_output-purchaseorderitem = ls_po-purchaseorderitem.
          ls_output-purchaseorderitemuniqueid = ls_po-purchaseorderitemuniqueid.
          ls_output-companycode = ls_po-companycode.
          ls_output-purchasingorganization = ls_po-purchasingorganization.
          ls_output-purchasinggroup = ls_po-purchasinggroup.
          ls_output-supplier = ls_po-supplier.
          ls_output-documentcurrency = ls_po-documentcurrency.
          ls_output-purchaseorderdate = ls_po-purchaseorderdate.
          ls_output-purchaseordertype = ls_po-purchaseordertype.
          ls_output-exchangerate = ls_po-exchangerate.
          ls_output-material = ls_po-material.
          ls_output-materialgroup = ls_po-materialgroup.
          ls_output-purchaseorderitemtext = ls_po-purchaseorderitemtext.
          ls_output-suppliermaterialnumber = ls_po-suppliermaterialnumber.
          ls_output-plant = ls_po-plant.
          ls_output-purchaseorderquantityunit = ls_po-purchaseorderquantityunit.
          ls_output-netpricequantity = ls_po-netpricequantity.
          ls_output-accountassignmentcategory = ls_po-accountassignmentcategory.
          ls_output-netamount = ls_po-netpriceamount. "正味発注価格
          ls_output-orderquantity = ls_po-orderquantity.
          ls_output-requirementtracking = ls_po-requirementtracking.
          ls_output-requisitionername = ls_po-requisitionername.
          ls_output-taxcode = ls_po-taxcode.

          IF ls_po-documentcurrency = 'JPY'.
            lv_netpr_jp = ls_po-netpriceamount.
            lv_netpr_jp = zzcl_common_utils=>conversion_amount( iv_alpha = 'OUT'
                                                  iv_currency = ls_po-documentcurrency
                                                  iv_input = lv_netpr_jp ).

            lv_netpr_jp = lv_netpr_jp / ls_po-netpricequantity.
            ls_output-netprice1 = lv_netpr_jp.  "発注単価
            ls_output-netprice2 = lv_netpr_jp.  "取引通貨単価
            lv_netpr_jp = lv_netpr_jp * ls_po-exchangerate.
            ls_output-netprice3 = lv_netpr_jp.  "円換算後単価(PO)
          ELSE.
            lv_netpr = ls_po-netpriceamount / ls_po-netpricequantity.
            ls_output-netprice1 = lv_netpr.     "発注単価
            ls_output-netprice2 = lv_netpr_jp.  "取引通貨単価
            lv_netpr = lv_netpr * ls_po-exchangerate.
            ls_output-netprice3 = lv_netpr.     "円換算後単価(PO)
          ENDIF.
          CONDENSE ls_output-netprice1 NO-GAPS.
          CONDENSE ls_output-netprice2 NO-GAPS.
          CONDENSE ls_output-netprice3 NO-GAPS.

          READ TABLE lt_product INTO ls_product
               WITH KEY product = ls_po-material BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-productmanufacturernumber = ls_product-productmanufacturernumber.
            ls_output-customermaterial = ls_product-yy1_customermaterial_prd.
          ENDIF.

          READ TABLE lt_purchasinggroup INTO ls_purchasinggroup
               WITH KEY purchasinggroup = ls_po-purchasinggroup BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-purchasinggroupname = ls_purchasinggroup-purchasinggroupname.
          ENDIF.

          READ TABLE lt_bp INTO ls_bp
               WITH KEY businesspartner = ls_po-supplier BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-suppliername = ls_bp-organizationbpname1.
          ENDIF.

          READ TABLE lt_eket INTO ls_eket
               WITH KEY purchaseorder = ls_po-purchaseorder
                        purchaseorderitem = ls_po-purchaseorderitem BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-schedulelinedeliverydate = ls_eket-schedulelinedeliverydate.
          ENDIF.

          READ TABLE lt_ekes INTO ls_ekes
               WITH KEY purchaseorder = ls_po-purchaseorder
                        purchaseorderitem = ls_po-purchaseorderitem BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-deliverydate = ls_ekes-deliverydate.
            ls_output-dlvqty = ls_ekes-confirmedquantity.
          ELSE.
            LOOP AT lt_ekes_tmp INTO ls_ekes_tmp1
                                WHERE purchaseorder = ls_po-purchaseorder
                                  AND purchaseorderitem = ls_po-purchaseorderitem
                                  AND deliverydate <= ls_ekbe-documentdate.
              lv_diff1 = ls_ekbe-postingdate - ls_ekes_tmp1-deliverydate.
              EXIT.
            ENDLOOP.

            LOOP AT lt_ekes_tmp INTO ls_ekes_tmp2
                                WHERE purchaseorder = ls_po-purchaseorder
                                  AND purchaseorderitem = ls_po-purchaseorderitem
                                  AND deliverydate >= ls_ekbe-documentdate.
              lv_diff2 = ls_ekes_tmp1-deliverydate - ls_ekbe-postingdate.
              EXIT.
            ENDLOOP.

            IF lv_diff1 <> 0
           AND lv_diff2 <> 0.
              IF lv_diff1 > lv_diff2.
                ls_output-deliverydate = ls_ekes_tmp2-deliverydate.
                ls_output-dlvqty = ls_ekes_tmp2-confirmedquantity.
              ELSEIF lv_diff1 <= lv_diff2.
                ls_output-deliverydate = ls_ekes_tmp1-deliverydate.
                ls_output-dlvqty = ls_ekes_tmp1-confirmedquantity.
              ENDIF.
            ELSEIF lv_diff1 = 0.
              ls_output-deliverydate = ls_ekes_tmp2-deliverydate.
              ls_output-dlvqty = ls_ekes_tmp2-confirmedquantity.
            ELSEIF lv_diff2 = 0.
              ls_output-deliverydate = ls_ekes_tmp1-deliverydate.
              ls_output-dlvqty = ls_ekes_tmp1-confirmedquantity.
            ENDIF.
          ENDIF.

          READ TABLE lt_ekkn INTO ls_ekkn
               WITH KEY purchaseorder = ls_po-purchaseorder
                        purchaseorderitem = ls_po-purchaseorderitem BINARY SEARCH.
          IF sy-subrc = 0.
            ls_output-costcenter = ls_ekkn-costcenter.
            ls_output-profitcenter = ls_ekkn-profitcenter.
            ls_output-glaccount = ls_ekkn-glaccount.
          ENDIF.

          APPEND ls_output TO lt_output.
          CLEAR: ls_output, ls_po, ls_product,
                 ls_purchasinggroup, ls_bp, ls_eket,
                 ls_ekes, ls_ekkn.
        ENDIF.
      ENDLOOP.

      SORT lt_output BY purchaseorder purchaseorderitem
                        materialdocument materialdocumentitem
                        supplierinvoice supplierinvoiceitem.

      " Filtering
*      zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
*                                   CHANGING  ct_data     = lt_output ).

      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( lines( lt_output ) ).
      ENDIF.

      "Sort
      zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                 CHANGING  ct_data  = lt_output ).

      " Paging
      zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                CHANGING  ct_data   = lt_output ).

      io_response->set_data( lt_output ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
