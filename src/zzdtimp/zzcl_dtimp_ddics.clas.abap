CLASS zzcl_dtimp_ddics DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      get_function_modules IMPORTING io_request  TYPE REF TO if_rap_query_request
                                     io_response TYPE REF TO if_rap_query_response
                           RAISING   cx_rap_query_prov_not_impl
                                     cx_rap_query_provider,

      get_structures IMPORTING io_request  TYPE REF TO if_rap_query_request
                               io_response TYPE REF TO if_rap_query_response
                     RAISING   cx_rap_query_prov_not_impl
                               cx_rap_query_provider.
ENDCLASS.



CLASS zzcl_dtimp_ddics IMPLEMENTATION.


  METHOD get_function_modules.

    DATA lt_data TYPE TABLE OF zzr_dtimp_func.

    DATA(lo_package) = xco_cp_abap_repository=>package->for( 'ZZDTIMP' ).
    DATA(lt_function_groups) = xco_cp_abap_repository=>objects->fugr->all->in( lo_package )->get(  ).

    " Get function modules under every function group
    lt_data = VALUE #( FOR group IN lt_function_groups
                         FOR function IN group->function_modules->all->get(  )
                           ( functionmodulename = function->name
                             functionmoduledesc = function->content(  )->get_short_text(  ) ) ).

    " Filtering
    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
                                 CHANGING  ct_data   = lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    "Sort
    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                               CHANGING  ct_data  = lt_data ).

    " Paging
    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                              CHANGING  ct_data   = lt_data ).

    io_response->set_data( lt_data ).

  ENDMETHOD.


  METHOD get_structures.

    DATA lt_data TYPE TABLE OF zzr_dtimp_struc.

    DATA(lo_package) = xco_cp_abap_repository=>package->for( 'ZZDTIMP' ).
    DATA(lt_structures) = xco_cp_abap_repository=>objects->tabl->structures->all->in( lo_package )->get(  ).

    " Get function modules under every function group
    lt_data = VALUE #( FOR structure IN lt_structures
                         ( structurename = structure->name
                           structuredesc = structure->content(  )->get_short_description(  ) ) ).

    " Filtering
    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
                                 CHANGING  ct_data   = lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    "Sort
    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                               CHANGING  ct_data  = lt_data ).

    " Paging
    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                              CHANGING  ct_data   = lt_data ).

    io_response->set_data( lt_data ).

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.
        CASE io_request->get_entity_id( ).
          WHEN 'ZZR_DTIMP_FUNC'.
            get_function_modules( io_request = io_request io_response = io_response ).
          WHEN 'ZZR_DTIMP_STRUC'.
            get_structures( io_request = io_request io_response = io_response ).
        ENDCASE.
        ##NO_HANDLER
      CATCH cx_rap_query_provider.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
