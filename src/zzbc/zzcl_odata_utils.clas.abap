CLASS zzcl_odata_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF gty_odata_error_msg,
             lang  TYPE string,
             value TYPE string,
           END OF gty_odata_error_msg,
           BEGIN OF gty_odata_error,
             code    TYPE string,
             message TYPE gty_odata_error_msg,
           END OF gty_odata_error,
           BEGIN OF gty_error,
             error TYPE gty_odata_error,
           END OF gty_error,
           BEGIN OF gty_fieldname,
             fieldname TYPE string,
           END OF gty_fieldname,
           gtty_fieldname TYPE TABLE OF gty_fieldname.

    CLASS-METHODS:
      filtering
        IMPORTING
          !io_filter   TYPE REF TO if_rap_query_filter
          !it_excluded TYPE gtty_fieldname OPTIONAL
        CHANGING
          !ct_data     TYPE STANDARD TABLE,
      orderby
        IMPORTING
          !it_order TYPE if_rap_query_request=>tt_sort_elements
        CHANGING
          !ct_data  TYPE STANDARD TABLE,
      paging
        IMPORTING
          !io_paging TYPE REF TO if_rap_query_paging
        CHANGING
          !ct_data   TYPE STANDARD TABLE.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_odata_utils IMPLEMENTATION.


  METHOD filtering.
    FIELD-SYMBOLS: <fs_data> TYPE any,
                   <fs_fval> TYPE any.
    DATA: lv_index          TYPE sy-tabix,
          lv_external_value TYPE string.

    TRY.
        DATA(lt_select_options) = io_filter->get_as_ranges(  ).
        ##NO_HANDLER
      CATCH cx_rap_query_filter_no_range.
        " handle exception
    ENDTRY.

    LOOP AT lt_select_options INTO DATA(ls_select_options).
      TRANSLATE ls_select_options-name TO UPPER CASE.    "#EC TRANSLANG

      READ TABLE it_excluded TRANSPORTING NO FIELDS WITH KEY fieldname = ls_select_options-name.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      LOOP AT ct_data ASSIGNING <fs_data>.
        lv_index = sy-tabix.
        ASSIGN COMPONENT ls_select_options-name OF STRUCTURE <fs_data> TO <fs_fval>.
        IF sy-subrc = 0.
          IF <fs_fval> NOT IN ls_select_options-range.
            " Convert to external format if field output conversion exist
            lv_external_value = |{ <fs_fval> ALPHA = OUT }|.
            CONDENSE lv_external_value.
            IF lv_external_value NOT IN ls_select_options-range.
              DELETE ct_data INDEX lv_index.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD orderby.
    DATA: lt_otab  TYPE abap_sortorder_tab,
          ls_oline TYPE abap_sortorder.
    DATA: ls_order LIKE LINE OF it_order.

    LOOP AT it_order INTO ls_order.
      ls_oline-name = ls_order-element_name.
      TRANSLATE ls_oline-name TO UPPER CASE.             "#EC TRANSLANG
      ls_oline-descending = ls_order-descending.
      APPEND ls_oline TO lt_otab.
      CLEAR ls_oline.
    ENDLOOP.

    SORT ct_data BY (lt_otab).
  ENDMETHOD.


  METHOD paging.
    DATA: lv_from TYPE i,
          lv_to   TYPE i.

    DATA: lo_data TYPE REF TO data.

    FIELD-SYMBOLS: <fs_result> TYPE STANDARD TABLE,
                   <fs_rec>    TYPE any.

    CREATE DATA lo_data LIKE ct_data.
    ASSIGN lo_data->* TO <fs_result>.

    IF io_paging->get_offset(  ) IS NOT INITIAL.
      lv_from = io_paging->get_offset(  ) + 1.
    ELSE.
      lv_from = 1.
    ENDIF.

    IF io_paging->get_page_size(  ) IS NOT INITIAL.
      lv_to = lv_from + io_paging->get_page_size(  ) - 1.
    ELSE.
      lv_to = lines( ct_data ).
    ENDIF.

    LOOP AT ct_data ASSIGNING <fs_rec> FROM lv_from TO lv_to.
      APPEND <fs_rec> TO <fs_result>.
    ENDLOOP.

    ct_data = <fs_result>.
  ENDMETHOD.


ENDCLASS.
