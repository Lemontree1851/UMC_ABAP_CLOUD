CLASS zcl_get_mm1006_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GET_MM1006_DATA IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_original_data TYPE STANDARD TABLE OF zc_tmm_1006 WITH DEFAULT KEY.

    DATA: lv_costcenter TYPE i_costcentertext-costcenter,
          lv_glaccount  TYPE i_glaccounttextincompanycode-glaccount.

    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      CLEAR: lv_costcenter,
             lv_glaccount.

      lv_costcenter = |{ <fs_original_data>-costcenter ALPHA = IN }|.
      SELECT SINGLE costcentername
        FROM i_costcentertext WITH PRIVILEGED ACCESS
       WHERE costcenter = @lv_costcenter
         AND language = @sy-langu
        INTO @<fs_original_data>-costcentername.

      lv_glaccount = |{ <fs_original_data>-glaccount ALPHA = IN }|.
      SELECT SINGLE glaccountname
        FROM i_glaccounttextincompanycode WITH PRIVILEGED ACCESS
       WHERE glaccount = @lv_glaccount
         AND companycode = @<fs_original_data>-companycode
         AND language = @sy-langu
        INTO @<fs_original_data>-glaccountname.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
