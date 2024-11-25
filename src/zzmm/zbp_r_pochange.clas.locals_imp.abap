CLASS lhc_pochange DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:BEGIN OF lty_request.
            INCLUDE TYPE zr_pochange.
    TYPES:  row TYPE i,
          END OF lty_request,
          lty_request_t TYPE TABLE OF lty_request.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR pochange RESULT result.

    METHODS processlogic FOR MODIFY
      IMPORTING keys FOR ACTION pochange~processlogic RESULT result.

    METHODS excute CHANGING ct_data TYPE lty_request_t.


ENDCLASS.

CLASS lhc_pochange IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD processlogic.
    DATA lt_request TYPE TABLE OF lty_request.

    CHECK keys IS NOT INITIAL.
    DATA(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO DATA(key).
      CLEAR lt_request.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_request ).

      CASE lv_event.

        WHEN 'EXCUTE'.
          excute( CHANGING ct_data = lt_request ).
        WHEN OTHERS.
      ENDCASE.

      DATA(lv_json) = /ui2/cl_json=>serialize( data = lt_request ).

      APPEND VALUE #( %cid   = key-%cid
                      %param = VALUE #( event = lv_event
                                        zzkey = lv_json ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD excute.
    DATA:
      lt_itemnote_create          TYPE TABLE FOR CREATE i_purchaseorderitemtp_2\_purchaseorderitemnote,
      ls_itemnote_create          TYPE STRUCTURE FOR CREATE i_purchaseorderitemtp_2\_purchaseorderitemnote,
      lt_purchaseorder_update     TYPE TABLE FOR UPDATE i_purchaseordertp_2,
      ls_purchaseorder_update     TYPE STRUCTURE FOR UPDATE i_purchaseordertp_2,
      lt_purchaseorderitem_update TYPE TABLE FOR UPDATE i_purchaseorderitemtp_2,
      ls_purchaseorderitem_update TYPE STRUCTURE FOR UPDATE i_purchaseorderitemtp_2,
      lt_acctassignment_update    TYPE TABLE FOR UPDATE i_purordaccountassignmenttp_2,
      ls_acctassignment_update    TYPE STRUCTURE FOR UPDATE i_purordaccountassignmenttp_2,
      lt_scheduleline_update      TYPE TABLE FOR UPDATE i_purchaseordschedulelinetp_2,
      ls_scheduleline_update      TYPE STRUCTURE FOR UPDATE i_purchaseordschedulelinetp_2,
      lt_item_delete              TYPE TABLE FOR DELETE i_purchaseorderitemtp_2,
      ls_item_delete              TYPE STRUCTURE FOR DELETE i_purchaseorderitemtp_2.


    DATA:
      lv_bukrs   TYPE bukrs,
      lv_ekorg   TYPE ekorg,
      lv_ekgrp   TYPE ekgrp,
      lv_waers   TYPE waers,
      lv_status  TYPE c LENGTH 1,
      lv_msg     TYPE string,
      lv_message TYPE string,
      lc_null    TYPE c VALUE '-'.

* 1.Check if header values are same with multiple items in one PO
    READ TABLE ct_data INTO DATA(ls_data) INDEX 1.

    DATA(lv_po) = |{ ls_data-purchaseorder ALPHA = IN }|.
    SELECT SINGLE documentcurrency
      FROM i_purchaseorderapi01
     WHERE purchaseorder = @lv_po
      INTO @lv_waers.

    lv_bukrs = ls_data-companycode.
    lv_ekorg = ls_data-purchasingorganization.
    lv_ekgrp = ls_data-purchasinggroup.

    LOOP AT ct_data INTO ls_data.
      IF ls_data-purchasingorganization <> lv_ekorg.
        lv_status = 'E'.
        lv_msg = TEXT-001.
        lv_message = zzcl_common_utils=>merge_message(
                             iv_message1 = lv_message
                             iv_message2 = lv_msg
                             iv_symbol = '\' ).
      ENDIF.
      IF ls_data-purchasinggroup <> lv_ekgrp.
        lv_status = 'E'.
        lv_msg = TEXT-002.
        lv_message = zzcl_common_utils=>merge_message(
                             iv_message1 = lv_message
                             iv_message2 = lv_msg
                             iv_symbol = '\' ).
      ENDIF.
      IF ls_data-companycode <> lv_bukrs.
        lv_status = 'E'.
        lv_message = TEXT-003.
        lv_message = zzcl_common_utils=>merge_message(
                             iv_message1 = lv_message
                             iv_message2 = lv_msg
                             iv_symbol = '\' ).
      ENDIF.
    ENDLOOP.
    "Check if po item is exist
    SELECT purchaseorder,
           purchaseorderitem
      FROM i_purchaseorderitemapi01
     WHERE purchaseorder = @lv_po
      INTO TABLE @DATA(lt_poitem).
    SORT lt_poitem BY purchaseorder purchaseorderitem.
    LOOP AT ct_data INTO ls_data.
      READ TABLE lt_poitem INTO DATA(ls_poitem)
           WITH KEY purchaseorder = ls_data-purchaseorder
                    purchaseorderitem = ls_data-purchaseorderitem.
      IF sy-subrc <> 0.
        lv_status = 'E'.
        lv_message = ls_data-purchaseorderitem && 'not exist'.
        lv_message = zzcl_common_utils=>merge_message(
                             iv_message1 = lv_message
                             iv_message2 = lv_msg
                             iv_symbol = '\' ).
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_status = 'E'.
      LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
        <lfs_data>-status = lv_status.
        <lfs_data>-message = lv_message.
      ENDLOOP.
      RETURN.
    ENDIF.


* Change Process
    LOOP AT ct_data INTO ls_data.
* Check if delete firstly
      "Deletion indicator
      IF ls_data-purchasingdocumentdeletioncode IS NOT INITIAL.
        ls_item_delete-%key-purchaseorder = lv_po.
        ls_item_delete-%key-purchaseorderitem = ls_data-purchaseorderitem.
        ls_item_delete-purchaseorder = lv_po.
        ls_item_delete-purchaseorderitem = ls_data-purchaseorderitem.
        APPEND ls_item_delete TO lt_item_delete.

        MODIFY ENTITIES OF i_purchaseordertp_2 PRIVILEGED
        ENTITY purchaseorderitem DELETE FROM lt_item_delete
        FAILED DATA(ls_del_failed)
        REPORTED DATA(ls_del_reported)
        MAPPED DATA(ls_del_mapped).
        IF sy-subrc = 0
       AND ls_del_failed IS INITIAL.
          lv_status = 'S'.
        ELSE.
          lv_status = 'E'.
          LOOP AT ls_del_reported-purchaseorder INTO DATA(ls_del).
            DATA(lv_msgty) = ls_del-%msg->if_t100_dyn_msg~msgty.
            IF lv_msgty = 'A'
            OR lv_msgty = 'E'.
              lv_message = ls_del-%msg->if_message~get_text( ).
            ENDIF.
          ENDLOOP.
        ENDIF.
        CONTINUE.
      ENDIF.
* Header value
      IF ls_data-companycode IS NOT INITIAL.
        ls_purchaseorder_update-companycode = ls_data-companycode.
        ls_purchaseorder_update-%control-companycode = if_abap_behv=>mk-on.
      ENDIF.

      IF ls_data-purchasingorganization IS NOT INITIAL.
        ls_purchaseorder_update-purchasingorganization = ls_data-purchasingorganization.
        ls_purchaseorder_update-%control-purchasingorganization = if_abap_behv=>mk-on.
      ENDIF.

      IF ls_data-purchasinggroup IS NOT INITIAL.
        ls_purchaseorder_update-purchasinggroup = ls_data-purchasinggroup.
        ls_purchaseorder_update-%control-purchasinggroup = if_abap_behv=>mk-on.
      ENDIF.

* --PO Item

      "AccountAssignment
      IF ls_data-accountassignmentcategory IS NOT INITIAL.
        ls_purchaseorderitem_update-accountassignmentcategory = ls_data-accountassignmentcategory.
        ls_purchaseorderitem_update-%control-accountassignmentcategory = if_abap_behv=>mk-on.
        IF ls_data-accountassignmentcategory = lc_null.
          CLEAR ls_purchaseorderitem_update-accountassignmentcategory.
          ls_purchaseorderitem_update-%control-accountassignmentcategory = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Item Category
      IF ls_data-purchaseorderitemcategory IS NOT INITIAL.
        ls_purchaseorderitem_update-purchaseorderitemcategory = ls_data-purchaseorderitemcategory.
        ls_purchaseorderitem_update-%control-purchaseorderitemcategory = if_abap_behv=>mk-on.
        IF ls_data-purchaseorderitemcategory = lc_null.
          CLEAR ls_purchaseorderitem_update-purchaseorderitemcategory.
          ls_purchaseorderitem_update-%control-accountassignmentcategory = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Material
      IF ls_data-material IS NOT INITIAL.
        ls_purchaseorderitem_update-material = zzcl_common_utils=>conversion_matn1(
                                                  EXPORTING iv_alpha = 'IN'
                                                            iv_input = ls_data-material ).
        ls_purchaseorderitem_update-%control-material = if_abap_behv=>mk-on.
        IF ls_data-material = lc_null.
          CLEAR: ls_purchaseorderitem_update-material.
          ls_purchaseorderitem_update-%control-material = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Short text
      IF ls_data-purchaseorderitemtext IS NOT INITIAL.
        ls_purchaseorderitem_update-purchaseorderitemtext = ls_data-purchaseorderitemtext.
        ls_purchaseorderitem_update-%control-purchaseorderitemtext = if_abap_behv=>mk-on.
        IF ls_data-purchaseorderitemtext = lc_null.
          CLEAR: ls_purchaseorderitem_update-purchaseorderitemtext.
          ls_purchaseorderitem_update-%control-purchaseorderitemtext = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Material Group
      IF ls_data-materialgroup IS NOT INITIAL.
        ls_purchaseorderitem_update-materialgroup = ls_data-materialgroup.
        ls_purchaseorderitem_update-%control-materialgroup = if_abap_behv=>mk-on.
        IF ls_data-materialgroup = lc_null.
          CLEAR ls_purchaseorderitem_update-materialgroup.
          ls_purchaseorderitem_update-%control-materialgroup = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Order Qty
      IF ls_data-orderquantity IS NOT INITIAL.
        ls_purchaseorderitem_update-orderquantity = ls_data-orderquantity.
        ls_purchaseorderitem_update-%control-orderquantity = if_abap_behv=>mk-on.
      ENDIF.
      "Net price amount-->internal
      IF ls_data-netpriceamount IS NOT INITIAL.
        ls_purchaseorderitem_update-netpriceamount = zzcl_common_utils=>conversion_amount(
                                          iv_alpha = 'IN'
                                          iv_currency = lv_waers
                                          iv_input = ls_data-netpriceamount ).
        "ls_purchaseorderitem_update-netpriceamount = ls_data-netpriceamount.
        ls_purchaseorderitem_update-%control-netpriceamount = if_abap_behv=>mk-on.
      ENDIF.
      "Price Unit
      IF ls_data-orderpriceunit IS NOT INITIAL.
        ls_purchaseorderitem_update-netpricequantity = ls_data-orderpriceunit.
        ls_purchaseorderitem_update-%control-netpricequantity = if_abap_behv=>mk-on.
      ENDIF.

      "Plant
      IF ls_data-plant IS NOT INITIAL.
        ls_purchaseorderitem_update-plant = ls_data-plant.
        ls_purchaseorderitem_update-%control-plant = if_abap_behv=>mk-on.
      ENDIF.
      "Storage Location
      IF ls_data-storagelocation IS NOT INITIAL.
        ls_purchaseorderitem_update-storagelocation = ls_data-storagelocation .
        ls_purchaseorderitem_update-%control-storagelocation  = if_abap_behv=>mk-on.
      ENDIF.
      "Requisitioner Name
      IF ls_data-requisitionername IS NOT INITIAL.
        ls_purchaseorderitem_update-requisitionername = ls_data-requisitionername.
        ls_purchaseorderitem_update-%control-requisitionername  = if_abap_behv=>mk-on.
        IF ls_data-requisitionername = lc_null.
          CLEAR ls_purchaseorderitem_update-requisitionername.
          ls_purchaseorderitem_update-%control-requisitionername  = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Requirement Tracking
      IF ls_data-requirementtracking IS NOT INITIAL.
        ls_purchaseorderitem_update-requirementtracking = ls_data-requirementtracking.
        ls_purchaseorderitem_update-%control-requirementtracking  = if_abap_behv=>mk-on.
        IF ls_data-requirementtracking = lc_null.
          CLEAR ls_purchaseorderitem_update-requirementtracking.
          ls_purchaseorderitem_update-%control-requirementtracking  = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "IS Return Item
      IF ls_data-isreturnitem IS NOT INITIAL.
        ls_purchaseorderitem_update-isreturnsitem = ls_data-isreturnitem.
        ls_purchaseorderitem_update-%control-isreturnsitem  = if_abap_behv=>mk-on.
        IF ls_data-isreturnitem = lc_null.
          CLEAR ls_purchaseorderitem_update-isreturnsitem.
          ls_purchaseorderitem_update-%control-isreturnsitem = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "EAN
      IF ls_data-internationalarticlenumber IS NOT INITIAL.
        ls_purchaseorderitem_update-internationalarticlenumber = ls_data-internationalarticlenumber.
        ls_purchaseorderitem_update-%control-internationalarticlenumber = if_abap_behv=>mk-on.
        IF ls_data-internationalarticlenumber = lc_null.
          CLEAR ls_purchaseorderitem_update-internationalarticlenumber.
          ls_purchaseorderitem_update-%control-internationalarticlenumber = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "DiscountInKindEligibility
      IF ls_data-discountinkindeligibility IS NOT INITIAL.
        ls_purchaseorderitem_update-discountinkindeligibility = ls_data-discountinkindeligibility.
        ls_purchaseorderitem_update-%control-discountinkindeligibility = if_abap_behv=>mk-on.
        IF ls_data-discountinkindeligibility = lc_null.
          CLEAR ls_purchaseorderitem_update-discountinkindeligibility.
          ls_purchaseorderitem_update-%control-discountinkindeligibility = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Tax Code
      IF ls_data-taxcode IS NOT INITIAL.
        ls_purchaseorderitem_update-taxcode = ls_data-taxcode.
        ls_purchaseorderitem_update-%control-taxcode = if_abap_behv=>mk-on.
        IF ls_data-taxcode = lc_null.
          CLEAR ls_purchaseorderitem_update-taxcode.
          ls_purchaseorderitem_update-%control-taxcode = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Is Completely Delivered
      IF ls_data-iscompletelydelivered IS NOT INITIAL.
        ls_purchaseorderitem_update-iscompletelydelivered = ls_data-iscompletelydelivered.
        ls_purchaseorderitem_update-%control-iscompletelydelivered = if_abap_behv=>mk-on.
        IF ls_data-iscompletelydelivered = lc_null.
          CLEAR ls_purchaseorderitem_update-iscompletelydelivered.
          ls_purchaseorderitem_update-%control-iscompletelydelivered = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Pricing Date Control
      IF ls_data-pricingdatecontrol IS NOT INITIAL.
        ls_purchaseorderitem_update-pricingdatecontrol = ls_data-pricingdatecontrol.
        ls_purchaseorderitem_update-%control-pricingdatecontrol = if_abap_behv=>mk-on.
        IF ls_data-pricingdatecontrol = lc_null.
          CLEAR ls_purchaseorderitem_update-pricingdatecontrol.
          ls_purchaseorderitem_update-%control-pricingdatecontrol = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "PurgDocPriceDate
      IF ls_data-purgdocpricedate IS NOT INITIAL.
        ls_purchaseorderitem_update-purgdocpricedate = ls_data-purgdocpricedate.
        ls_purchaseorderitem_update-%control-purgdocpricedate = if_abap_behv=>mk-on.
        IF ls_data-purgdocpricedate = lc_null.
          CLEAR ls_purchaseorderitem_update-purgdocpricedate.
          ls_purchaseorderitem_update-%control-purgdocpricedate = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.

* --PO Item Account Assignment
      "GL Account
      IF ls_data-glaccount IS NOT INITIAL.
        ls_acctassignment_update-glaccount =  |{ ls_data-glaccount ALPHA = IN }|.
        ls_acctassignment_update-%control-glaccount = if_abap_behv=>mk-on.
        IF ls_data-glaccount = lc_null.
          CLEAR ls_acctassignment_update-glaccount.
          ls_acctassignment_update-%control-glaccount = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Cost Center
      IF ls_data-costcenter IS NOT INITIAL.
        ls_acctassignment_update-costcenter = ls_data-costcenter.
        ls_acctassignment_update-%control-costcenter = if_abap_behv=>mk-on.
        IF ls_data-costcenter = lc_null.
          CLEAR ls_acctassignment_update-costcenter.
          ls_acctassignment_update-%control-costcenter = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Master Fixed Asset
      IF ls_data-masterfixedasset IS NOT INITIAL.
        ls_acctassignment_update-masterfixedasset = |{ ls_data-masterfixedasset ALPHA = IN }|.
        ls_acctassignment_update-%control-masterfixedasset = if_abap_behv=>mk-on.
        IF ls_data-masterfixedasset = lc_null.
          CLEAR ls_acctassignment_update-masterfixedasset.
          ls_acctassignment_update-%control-masterfixedasset = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Fixed Asset
      IF ls_data-fixedasset IS NOT INITIAL.
        ls_acctassignment_update-fixedasset = |{ ls_data-fixedasset ALPHA = IN }|.
        ls_acctassignment_update-%control-fixedasset = if_abap_behv=>mk-on.
        IF ls_data-fixedasset = lc_null.
          CLEAR ls_acctassignment_update-fixedasset.
          ls_acctassignment_update-%control-fixedasset = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "Order ID
      IF ls_data-orderid IS NOT INITIAL.
        ls_acctassignment_update-orderid = |{ ls_data-orderid ALPHA = IN }|.
        ls_acctassignment_update-%control-orderid = if_abap_behv=>mk-on.
        IF ls_data-orderid = lc_null.
          CLEAR ls_acctassignment_update-orderid.
          ls_acctassignment_update-%control-orderid = if_abap_behv=>mk-on.
        ENDIF.
      ENDIF.
      "WBS Element ExternalID
      IF ls_data-wbselementinternalid_2 IS NOT INITIAL.
        ls_acctassignment_update-wbselementexternalid = ls_data-wbselementinternalid_2.
        ls_acctassignment_update-%control-wbselementexternalid = if_abap_behv=>mk-on.
      ENDIF.
* --PO Item schedule line
      IF ls_data-schedulelinedeliverydate IS NOT INITIAL.
        ls_scheduleline_update-schedulelinedeliverydate = ls_data-schedulelinedeliverydate.
        ls_scheduleline_update-%control-schedulelinedeliverydate = if_abap_behv=>mk-on.
      ENDIF.

      IF ls_purchaseorder_update IS NOT INITIAL.
        ls_purchaseorder_update-%key-purchaseorder = lv_po.
        APPEND ls_purchaseorder_update TO lt_purchaseorder_update.
      ENDIF.

      IF ls_purchaseorderitem_update IS NOT INITIAL.
        ls_purchaseorderitem_update-%key-purchaseorder = lv_po.
        ls_purchaseorderitem_update-%key-purchaseorderitem = ls_data-purchaseorderitem.
        APPEND ls_purchaseorderitem_update TO lt_purchaseorderitem_update.
      ENDIF.

      IF ls_acctassignment_update IS NOT INITIAL.
        ls_acctassignment_update-%key-purchaseorder = lv_po.
        ls_acctassignment_update-%key-purchaseorderitem = ls_data-purchaseorderitem.
        ls_acctassignment_update-%key-accountassignmentnumber = '01'.
        APPEND ls_acctassignment_update TO lt_acctassignment_update.
      ENDIF.

      IF ls_scheduleline_update IS NOT INITIAL.
        ls_scheduleline_update-%key-purchaseorder = lv_po.
        ls_scheduleline_update-%key-purchaseorderitem = ls_data-purchaseorderitem.
        ls_scheduleline_update-%key-scheduleline = '0001'.
        APPEND ls_scheduleline_update TO lt_scheduleline_update.
      ENDIF.
* --PO Item long text
      IF ls_data-longtext IS NOT INITIAL.
        SELECT COUNT(*)
          FROM i_purchaseorderitemnotetp_2
         WHERE purchaseorder = @lv_po
           AND purchaseorderitem = @ls_data-purchaseorderitem
           AND textobjecttype = 'F01'
           AND language = @sy-langu.
        IF sy-subrc <> 0.
          ls_itemnote_create-%key-purchaseorder = lv_po.
          ls_itemnote_create-%key-purchaseorderitem = ls_data-purchaseorderitem.
          ls_itemnote_create-%target = VALUE #( ( %cid = 'I001'
                                                  purchaseorder = lv_po
                                                  purchaseorderitem = ls_data-purchaseorderitem
                                                  textobjecttype = 'F01'
                                                  language = sy-langu
                                                  plainlongtext = ls_data-longtext ) ).
          APPEND ls_itemnote_create TO lt_itemnote_create.
        ELSE.
          IF ls_data-longtext IS NOT INITIAL.
            ls_itemnote_create-%key-purchaseorder = lv_po.
            ls_itemnote_create-%key-purchaseorderitem = ls_data-purchaseorderitem.

            ls_itemnote_create-%target = VALUE #( ( %cid = 'I001'
                                                    purchaseorder = lv_po
                                                    purchaseorderitem = ls_data-purchaseorderitem
                                                    textobjecttype = 'F01'
                                                    language = sy-langu
                                                    plainlongtext = '#' ) ).
            APPEND ls_itemnote_create TO lt_itemnote_create.
            ls_itemnote_create-%target = VALUE #( ( %cid = 'I002'
                                                    purchaseorder = lv_po
                                                    purchaseorderitem = ls_data-purchaseorderitem
                                                    textobjecttype = 'F01'
                                                    language = sy-langu
                                                    plainlongtext = ls_data-longtext ) ).
            APPEND ls_itemnote_create TO lt_itemnote_create.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: ls_purchaseorder_update, ls_purchaseorderitem_update,
             ls_acctassignment_update, ls_scheduleline_update,
             ls_itemnote_create.
    ENDLOOP.

* BOI-Update
    IF lt_purchaseorder_update IS NOT INITIAL.
      MODIFY ENTITIES OF i_purchaseordertp_2 PRIVILEGED
        ENTITY purchaseorder UPDATE FROM lt_purchaseorder_update
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported)
        MAPPED DATA(ls_mapped).
      IF sy-subrc = 0
     AND ls_failed IS INITIAL.
        lv_status = 'S'.
      ELSE.
        lv_status = 'E'.
        LOOP AT ls_reported-purchaseorder INTO DATA(ls_order).
          lv_msgty = ls_order-%msg->if_t100_dyn_msg~msgty.
          IF lv_msgty = 'A'
          OR lv_msgty = 'E'.
            lv_message = ls_order-%msg->if_message~get_text( ).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
    IF lt_purchaseorderitem_update IS NOT INITIAL.
      MODIFY ENTITIES OF i_purchaseordertp_2 PRIVILEGED
        ENTITY purchaseorderitem UPDATE FROM lt_purchaseorderitem_update
        FAILED ls_failed
        REPORTED ls_reported
        MAPPED ls_mapped.
      IF sy-subrc = 0
     AND ls_failed IS INITIAL.
        lv_status = 'S'.
      ELSE.
        lv_status = 'E'.
        LOOP AT ls_reported-purchaseorderitem INTO DATA(ls_item).
          lv_msgty = ls_item-%msg->if_t100_dyn_msg~msgty.
          IF lv_msgty = 'A'
          OR lv_msgty = 'E'.
            lv_msg = ls_item-%msg->if_message~get_text( ).
            lv_message = zzcl_common_utils=>merge_message(
                         iv_message1 = lv_message
                         iv_message2 = lv_msg
                         iv_symbol = '\' ).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF lt_scheduleline_update IS NOT INITIAL.
      MODIFY ENTITIES OF i_purchaseordertp_2 PRIVILEGED
        ENTITY purchaseorderscheduleline UPDATE FROM lt_scheduleline_update
        FAILED ls_failed
        REPORTED ls_reported
        MAPPED ls_mapped.
      IF sy-subrc = 0
     AND ls_failed IS INITIAL.
        lv_status = 'S'.
      ELSE.
        lv_status = 'E'.
        LOOP AT ls_reported-purchaseorderscheduleline INTO DATA(ls_schedule).
          lv_msgty = ls_schedule-%msg->if_t100_dyn_msg~msgty.
          IF lv_msgty = 'A'
          OR lv_msgty = 'E'.
            lv_msg = ls_schedule-%msg->if_message~get_text( ).
            lv_message = zzcl_common_utils=>merge_message(
                           iv_message1 = lv_message
                           iv_message2 = lv_msg
                           iv_symbol = '\' ).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF lt_acctassignment_update IS NOT INITIAL.
      MODIFY ENTITIES OF i_purchaseordertp_2 PRIVILEGED
        ENTITY purchaseorderaccountassignment UPDATE FROM lt_acctassignment_update
        FAILED ls_failed
        REPORTED ls_reported
        MAPPED ls_mapped.
      IF sy-subrc = 0
     AND ls_failed IS INITIAL.
        lv_status = 'S'.
      ELSE.
        lv_status = 'E'.
        LOOP AT ls_reported-purchaseorderaccountassignment INTO DATA(ls_acct).
          lv_msgty = ls_acct-%msg->if_t100_dyn_msg~msgty.
          IF lv_msgty = 'A'
          OR lv_msgty = 'E'.
            lv_msg = ls_acct-%msg->if_message~get_text( ).
            lv_message = zzcl_common_utils=>merge_message(
                           iv_message1 = lv_message
                           iv_message2 = lv_msg
                           iv_symbol = '\' ).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

* BOI-Item longtext
    CLEAR: ls_failed, ls_reported, ls_mapped.
    IF lt_itemnote_create IS NOT INITIAL.
      MODIFY ENTITIES OF i_purchaseordertp_2 PRIVILEGED
        ENTITY purchaseorderitem
        CREATE BY \_purchaseorderitemnote FROM lt_itemnote_create
        FAILED ls_failed
        REPORTED ls_reported
        MAPPED ls_mapped.
      IF sy-subrc = 0
     AND ls_failed IS INITIAL.
        lv_status = 'S'.
      ELSE.
        lv_status = 'E'.
        LOOP AT ls_reported-purchaseorderitemnote INTO DATA(ls_itemnote).
          lv_msgty = ls_acct-%msg->if_t100_dyn_msg~msgty.
          IF lv_msgty = 'A'
          OR lv_msgty = 'E'.
            lv_msg = ls_acct-%msg->if_message~get_text( ).
            lv_message = zzcl_common_utils=>merge_message(
                           iv_message1 = lv_message
                           iv_message2 = lv_msg
                           iv_symbol = '\' ).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

* Edit output
    LOOP AT ct_data ASSIGNING <lfs_data>.
      <lfs_data>-status = lv_status.
      IF lv_status = 'S'.
        MESSAGE s013(zmm_001) WITH <lfs_data>-purchaseorder INTO <lfs_data>-message.
      ELSE.
        <lfs_data>-message = lv_message.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
