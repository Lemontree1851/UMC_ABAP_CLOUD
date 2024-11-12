CLASS zzcl_show_application_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SHOW_APPLICATION_LOG IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA lt_data TYPE TABLE OF zzc_dtimp_logs.

    IF io_request->is_data_requested( ).
      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).

          LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
            CASE ls_filter_cond-name.
              WHEN 'LOGHANDLE'.
                DATA(lv_loghandle) = ls_filter_cond-range[ 1 ]-low.
            ENDCASE.
          ENDLOOP.
        CATCH cx_rap_query_filter_no_range.
          "handle exception
          io_response->set_data( lt_data ).
      ENDTRY.

      TRY.
          DATA(l_log) = cl_bali_log_db=>get_instance( )->load_log( handle = CONV #( lv_loghandle ) ).
          DATA(l_item_table) = l_log->get_all_items( ).

          LOOP AT l_item_table INTO DATA(l_item_entry).
            APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).

            <lfs_data>-loghandle     = lv_loghandle.
            <lfs_data>-logitemnumber = l_item_entry-log_item_number.
            <lfs_data>-severity      = l_item_entry-item->severity.
            <lfs_data>-category      = l_item_entry-item->category.

            CASE <lfs_data>-severity.
              WHEN 'S'. "Success
                <lfs_data>-criticality = 3.
                <lfs_data>-severitytext = 'Success'.
              WHEN 'E'. "Error
                <lfs_data>-criticality = 1.
                <lfs_data>-severitytext = 'Error'.
              WHEN 'W'. "Warning
                <lfs_data>-criticality = 2.
                <lfs_data>-severitytext = 'Warning'.
              WHEN OTHERS.
                <lfs_data>-criticality = 0.
                <lfs_data>-severitytext = 'Info'.
            ENDCASE.

            <lfs_data>-detaillevel   = l_item_entry-item->detail_level.
            <lfs_data>-timestamp     = l_item_entry-item->timestamp.
            <lfs_data>-messagetext   = l_item_entry-item->get_message_text( ).
          ENDLOOP.
        CATCH cx_bali_runtime INTO DATA(l_exception).
          " handle exception
      ENDTRY.

      " Filtering
      zzcl_odata_utils=>filtering( EXPORTING io_filter   = io_request->get_filter(  )
                                   CHANGING  ct_data     = lt_data ).

      "Sort
      zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                 CHANGING  ct_data  = lt_data ).

      " Paging
      zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                CHANGING  ct_data   = lt_data ).


      IF io_request->is_total_numb_of_rec_requested(  ) .
        io_response->set_total_number_of_records( lines( lt_data ) ).
      ENDIF.

      io_response->set_data( lt_data ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
