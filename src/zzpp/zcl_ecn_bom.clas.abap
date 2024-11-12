CLASS zcl_ecn_bom DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ecn_bom IMPLEMENTATION.



  METHOD if_oo_adt_classrun~main.
*  "BOM展开
   READ ENTITIES OF i_billofmaterialtp_2
      ENTITY billofmaterial
      EXECUTE explodebom
      FROM VALUE #(
      (
       billofmaterial = '00000073'

      plant = '1100' "'1400'"'1510'
      material = '4841A1-10200-SMTB' "'S_2119932-A-SMTB'"'FG1_CP'
      billofmaterialcategory = 'M'
      BillOfMaterialVariant = '01'

     %param-bomexplosionapplication = 'PP01'
      %param-requiredquantity = 1
      %param-explodebomlevelvalue = 0
*      %param-bomexplosionismultilevel = 'X'
      %param-BOMExplosionIsAlternatePrio = 'X'
*      %param-BOMExplosionDate = lv_date
   )
   )
   RESULT DATA(lt_result)
   FAILED DATA(ls_failed)
   REPORTED DATA(ls_reported).

   out->write( lt_result ).


  ENDMETHOD.

ENDCLASS.
