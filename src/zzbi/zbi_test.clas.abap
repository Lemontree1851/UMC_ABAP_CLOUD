CLASS zbi_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZBI_TEST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    update ztbi_recy_info set recovery_management_number = 'IN2024002' where recovery_management_number = 'IN2024015'.

    SELECT * FROM ztbi_recy_info INTO TABLE @DATA(lt_data).
    CHECK lt_data IS NOT INITIAL.

        SELECT userid,
               UserDescription as personfullname
           FROM I_User
           WITH PRIVILEGED ACCESS
           FOR ALL ENTRIES IN @lt_data
           WHERE userid = @lt_data-created_by
           into TABLE @data(lt_user).

    LOOP AT lt_data INTO DATA(ls_data).
      READ TABLE lt_user INTO DATA(ls_user) WITH KEY userid = ls_data-created_by.
      IF sy-subrc = 0.
        ls_data-created_name = ls_user-personfullname.
      ENDIF.

      MODIFY lt_data FROM ls_data.
    ENDLOOP.

    MODIFY ztbi_recy_info FROM TABLE @lt_data.
  ENDMETHOD.
ENDCLASS.
