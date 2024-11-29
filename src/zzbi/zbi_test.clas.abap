CLASS zbi_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zbi_test IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: lv_date TYPE datum VALUE '20240101',
          lv_last_date TYPE datum.

    lv_last_date = lv_date - 1.

  ENDMETHOD.
ENDCLASS.
