CLASS zcl_bi006_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      TYPES:
      ty_t_companycode  TYPE RANGE OF ztfi_1019-companycode,
      ty_t_product      TYPE RANGE OF ztfi_1019-product,
      ty_t_customer     TYPE RANGE OF kunnr,
      ty_t_fiscalyear   TYPE RANGE OF ztfi_1019-fiscalyear,
      ty_t_fiscalperiod TYPE RANGE OF ztfi_1019-fiscalperiod,
      ty_t_plant        TYPE RANGE OF ztfi_1019-plant,
      ty_t_data TYPE STANDARD TABLE OF zi_bi006_report.

  METHODS: get_data IMPORTING ir_companycode TYPE ty_t_companycode
                              ir_fiscalyear type ty_t_fiscalyear
                              ir_fiscalperiod TYPE ty_t_fiscalperiod
                              ir_plant TYPE ty_t_plant
                              ir_product TYPE ty_t_product
                              ir_customer TYPE ty_t_customer
                    EXPORTING et_data TYPE ty_t_data.
  PROTECTED SECTION.

  PRIVATE SECTION.


ENDCLASS.



CLASS zcl_bi006_data IMPLEMENTATION.

  METHOD get_data.

  ENDMETHOD.

ENDCLASS.
