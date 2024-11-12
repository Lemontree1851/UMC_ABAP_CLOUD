CLASS zcl_query_routinglist DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_query_routinglist IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA: lt_data     TYPE TABLE OF zc_routinglist,
          ls_response TYPE zc_routinglist,
          lt_response TYPE TABLE OF zc_routinglist,
          lr_product  TYPE RANGE OF zc_routinglist-product.

    IF io_request->is_data_requested( ).
      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).

          LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
            CASE ls_filter_cond-name.
              WHEN 'PLANT'.
                DATA(lr_plant) = ls_filter_cond-range.
              WHEN 'PRODUCT'.
                lr_product = VALUE #( FOR range IN ls_filter_cond-range (
                       sign   = range-sign
                       option = range-option
                       low    = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = range-low  )
                       high   = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = zzcl_common_utils=>lc_alpha_in iv_input = range-high )
                ) ) .
              WHEN 'MRPRESPONSIBLE'.
                DATA(lr_mrpresponsible) = ls_filter_cond-range.
              WHEN 'PRODUCTIONSUPERVISOR'.
                DATA(lr_productionsupervisor) = ls_filter_cond-range.
              WHEN 'ISMARKEDFORDELETION'.
                DATA(lr_delete) = ls_filter_cond-range.
              WHEN 'VALIDITYSTARTDATE'.
                DATA(lr_validitystartdate) = ls_filter_cond-range.
                lr_validitystartdate[ 1 ]-option = zzcl_common_utils=>lc_range_option_ge.
              WHEN 'VALIDITYENDDATE'.
                DATA(lr_validityenddate) = ls_filter_cond-range.
                lr_validityenddate[ 1 ]-option = zzcl_common_utils=>lc_range_option_le.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.
        CATCH cx_rap_query_filter_no_range.
          "handle exception
          io_response->set_data( lt_data ).
      ENDTRY.

      SELECT a~product,
             a~plant,
             a~mrpresponsible,
             a~procurementtype,
             a~specialprocurementtype,
             a~productionsupervisor,
             a~productioninvtrymanagedloc,
             b~costinglotsize,
             c~billofoperationstype,
             c~billofoperationsgroup,
             c~billofoperationsvariant,
             c~bootomaterialinternalid,
             CASE WHEN d~ismarkedfordeletion IS NOT INITIAL
                  THEN d~ismarkedfordeletion
                  WHEN d~isdeleted IS NOT INITIAL
                  THEN d~isdeleted
                  WHEN d~isimplicitlydeleted IS NOT INITIAL
                  THEN d~isimplicitlydeleted
                  ELSE @abap_false END AS ismarkedfordeletion
        FROM i_productplantbasic WITH PRIVILEGED ACCESS AS a
        LEFT OUTER JOIN i_productplantcosting WITH PRIVILEGED ACCESS
                     AS b ON b~product = a~product AND b~plant = a~plant
        LEFT OUTER JOIN i_mfgboomaterialassignment WITH PRIVILEGED ACCESS
                     AS c ON c~product = a~product AND c~plant = a~plant
        LEFT OUTER JOIN i_mfgbillofoperationschgst WITH PRIVILEGED ACCESS
                     AS d ON  d~billofoperationstype    = c~billofoperationstype
                          AND d~billofoperationsgroup   = c~billofoperationsgroup
                          AND d~billofoperationsvariant = c~billofoperationsvariant
       WHERE a~plant IN @lr_plant
         AND a~product IN @lr_product
         AND a~mrpresponsible IN @lr_mrpresponsible
         AND a~productionsupervisor IN @lr_productionsupervisor
        INTO TABLE @DATA(lt_header).

      IF lr_delete IS NOT INITIAL.
        DELETE lt_header WHERE ismarkedfordeletion NOT IN lr_delete.
      ENDIF.

      IF lt_header IS NOT INITIAL.
        SELECT *
          FROM zr_productionroutingoperation WITH PRIVILEGED ACCESS AS operation
         INNER JOIN @lt_header AS header ON  header~billofoperationstype    = operation~billofoperationstype
                                         AND header~billofoperationsgroup   = operation~billofoperationsgroup
                                         AND header~billofoperationsvariant = operation~billofoperationsvariant
         WHERE validitystartdate IN @lr_validitystartdate
           AND validityenddate   IN @lr_validityenddate
          INTO CORRESPONDING FIELDS OF TABLE @lt_data.

        IF lt_data IS NOT INITIAL.
          SELECT workcenterinternalid,
                 workcentertypecode,
                 workcenter
            FROM i_workcenter WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_data
           WHERE workcenterinternalid = @lt_data-workcenterinternalid
            INTO TABLE @DATA(lt_workcenter).
          SORT lt_workcenter BY workcenterinternalid.

          LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
            READ TABLE lt_workcenter INTO DATA(ls_workcenter) WITH KEY workcenterinternalid = <lfs_data>-workcenterinternalid BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_data>-workcenter = ls_workcenter-workcenter.
            ENDIF.

            TRY.
                <lfs_data>-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
              CATCH cx_uuid_error.
                " handle exception
            ENDTRY.
          ENDLOOP.
        ENDIF.
      ENDIF.

      " Filtering
      zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
                                             it_excluded = VALUE #( ( fieldname = 'VALIDITYSTARTDATE' )
                                                                    ( fieldname = 'VALIDITYENDDATE' )
                                                                    ( fieldname = 'ISMARKEDFORDELETION' ) )
                                   CHANGING  ct_data     = lt_data ).

      SORT lt_data BY plant product billofoperationsgroup billofoperationsvariant operation.

      LOOP AT lt_data INTO DATA(ls_data) GROUP BY ( plant = ls_data-plant )
                                         ASSIGNING FIELD-SYMBOL(<lfs_group>).

        CLEAR ls_response.
        LOOP AT GROUP <lfs_group> ASSIGNING FIELD-SYMBOL(<lfs_group_item>).
          APPEND <lfs_group_item> TO lt_response.

          IF  <lfs_group_item>-standardworkquantityunit1 IS NOT INITIAL
          AND <lfs_group_item>-standardworkquantityunit1 <> 'S'.
            zzcl_common_utils=>unit_conversion_simple( EXPORTING input      = <lfs_group_item>-standardworkquantity1
                                                                 round_sign = 'X'
                                                                 unit_in    = <lfs_group_item>-standardworkquantityunit1
                                                                 unit_out   = 'S'
                                                       IMPORTING output     = <lfs_group_item>-standardworkquantity1 ).
          ENDIF.
          IF  <lfs_group_item>-standardworkquantityunit2 IS NOT INITIAL
          AND <lfs_group_item>-standardworkquantityunit2 <> 'S'.
            zzcl_common_utils=>unit_conversion_simple( EXPORTING input      = <lfs_group_item>-standardworkquantity2
                                                                 round_sign = 'X'
                                                                 unit_in    = <lfs_group_item>-standardworkquantityunit2
                                                                 unit_out   = 'S'
                                                       IMPORTING output     = <lfs_group_item>-standardworkquantity2 ).
          ENDIF.
          IF  <lfs_group_item>-standardworkquantityunit3 IS NOT INITIAL
          AND <lfs_group_item>-standardworkquantityunit3 <> 'S'.
            zzcl_common_utils=>unit_conversion_simple( EXPORTING input      = <lfs_group_item>-standardworkquantity3
                                                                 round_sign = 'X'
                                                                 unit_in    = <lfs_group_item>-standardworkquantityunit3
                                                                 unit_out   = 'S'
                                                       IMPORTING output     = <lfs_group_item>-standardworkquantity3 ).
          ENDIF.
          IF  <lfs_group_item>-standardworkquantityunit4 IS NOT INITIAL
          AND <lfs_group_item>-standardworkquantityunit4 <> 'M2'.
            zzcl_common_utils=>unit_conversion_simple( EXPORTING input      = <lfs_group_item>-standardworkquantity4
                                                                 round_sign = 'X'
                                                                 unit_in    = <lfs_group_item>-standardworkquantityunit4
                                                                 unit_out   = 'M2'
                                                       IMPORTING output     = <lfs_group_item>-standardworkquantity4 ).
          ENDIF.
          IF  <lfs_group_item>-standardworkquantityunit5 IS NOT INITIAL
          AND <lfs_group_item>-standardworkquantityunit5 <> 'KWH'.
            zzcl_common_utils=>unit_conversion_simple( EXPORTING input      = <lfs_group_item>-standardworkquantity5
                                                                 round_sign = 'X'
                                                                 unit_in    = <lfs_group_item>-standardworkquantityunit5
                                                                 unit_out   = 'KWH'
                                                       IMPORTING output     = <lfs_group_item>-standardworkquantity5 ).
          ENDIF.
          IF  <lfs_group_item>-standardworkquantityunit6 IS NOT INITIAL
          AND <lfs_group_item>-standardworkquantityunit6 <> 'LE'. " 外部显示为AU
            zzcl_common_utils=>unit_conversion_simple( EXPORTING input      = <lfs_group_item>-standardworkquantity6
                                                                 round_sign = 'X'
                                                                 unit_in    = <lfs_group_item>-standardworkquantityunit6
                                                                 unit_out   = 'LE'
                                                       IMPORTING output     = <lfs_group_item>-standardworkquantity6 ).
          ENDIF.

          " Sum Line
          ls_response-standardworkquantity1 += <lfs_group_item>-standardworkquantity1.
          ls_response-standardworkquantity2 += <lfs_group_item>-standardworkquantity2.
          ls_response-standardworkquantity3 += <lfs_group_item>-standardworkquantity3.
          ls_response-standardworkquantity4 += <lfs_group_item>-standardworkquantity4.
          ls_response-standardworkquantity5 += <lfs_group_item>-standardworkquantity5.
          ls_response-standardworkquantity6 += <lfs_group_item>-standardworkquantity6.
        ENDLOOP.

        TRY.
            ls_response-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error.
            " handle exception
        ENDTRY.

        " Sum Line
        ls_response-standardworkquantityunit1 = 'S'.
        ls_response-standardworkquantityunit2 = 'S'.
        ls_response-standardworkquantityunit3 = 'S'.
        ls_response-standardworkquantityunit4 = 'M2'.
        ls_response-standardworkquantityunit5 = 'KWH'.
        ls_response-standardworkquantityunit6 = 'LE'.   " 外部显示为AU
        APPEND ls_response TO lt_response.
      ENDLOOP.

      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( lines( lt_response ) ).
      ENDIF.

      "Sort
      zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                 CHANGING  ct_data  = lt_response ).

      " Paging
      zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                CHANGING  ct_data   = lt_response ).

      io_response->set_data( lt_response ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
