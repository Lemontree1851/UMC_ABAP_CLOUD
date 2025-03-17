CLASS zcl_materialrequisition_prt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MATERIALREQUISITION_PRT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA lt_data TYPE TABLE OF zr_materialrequisition_prt_i.

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          CASE ls_filter_cond-name.
            WHEN 'MATERIALREQUISITIONNO'.
              DATA(lr_materialrequisitionno) = ls_filter_cond-range.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
        ##NO_HANDLER
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    SELECT *
      FROM zc_materialrequisition
     WHERE materialrequisitionno IN @lr_materialrequisitionno
      INTO TABLE @DATA(lt_master).

    LOOP AT lt_master ASSIGNING FIELD-SYMBOL(<lfs_master>).

      APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      <lfs_data> = CORRESPONDING #( <lfs_master> ).
      IF <lfs_master>-remark IS INITIAL.
        <lfs_data>-remark = |{ <lfs_master>-reason }-{ <lfs_master>-reasontext }|.
      ELSE.
        <lfs_data>-remark = |{ <lfs_master>-reason }-{ <lfs_master>-reasontext } { <lfs_master>-remark }|.
      ENDIF.

*&--ADD BEGIN BY XINLEI XU 2025/03/04
      SPLIT <lfs_data>-material AT ':' INTO <lfs_data>-material DATA(lv_other).
*&--ADD END BY XINLEI XU 2025/03/04
    ENDLOOP.

    " Filtering
    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
                                 CHANGING  ct_data   = lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    SORT lt_data BY itemno.

    io_response->set_data( lt_data ).
  ENDMETHOD.
ENDCLASS.
