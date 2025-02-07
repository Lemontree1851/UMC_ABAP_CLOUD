CLASS zcl_ofsocomparison DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_OFSOCOMPARISON IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA:
      lt_data               TYPE STANDARD TABLE OF zr_ofsocomparison,
      ls_data               TYPE zr_ofsocomparison,
      lr_plant              TYPE RANGE OF zr_ofsocomparison-plant,
      lr_customer           TYPE RANGE OF zr_ofsocomparison-customer,
      lr_material           TYPE RANGE OF zr_ofsocomparison-material,
      lr_materialbycustomer TYPE RANGE OF zr_ofsocomparison-materialbycustomer,
      lv_durf               TYPE zr_ofsocomparison-duration,
      lv_created_atf        TYPE zr_ofsocomparison-created_at,
      lv_durt               TYPE zr_ofsocomparison-duration,
      lv_created_att        TYPE zr_ofsocomparison-created_at,
      lr_duration           TYPE RANGE OF ztpp_1012-requirement_date,
      lr_created_at         TYPE RANGE OF zr_ofsocomparison-created_at,
      lv_latestof           TYPE zr_ofsocomparison-latestof,
      lv_contents           TYPE zr_ofsocomparison-contents,
      ls_plant              LIKE LINE OF lr_plant,
      ls_customer           LIKE LINE OF lr_customer,
      ls_material           LIKE LINE OF lr_material,
      ls_materialbycustomer LIKE LINE OF lr_materialbycustomer,
      ls_duration           LIKE LINE OF lr_duration,
      ls_created_at         LIKE LINE OF lr_created_at.

    DATA:
      lv_kunnr     TYPE kunnr,
      lv_ldate     TYPE ztpp_1012-requirement_date,
      lv_hdate     TYPE ztpp_1012-requirement_date,
      lv_begindate TYPE ztpp_1012-requirement_date,
      lv_enddate   TYPE ztpp_1012-requirement_date,
      lv_num       TYPE i,
      lv_string1   TYPE string,
      lv_string2   TYPE string,
      lv_rowno     TYPE zr_ofsocomparison-rowno,
      lv_durationf TYPE n LENGTH 6,
      lv_durationt TYPE n LENGTH 6.

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
          LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
            CASE ls_filter_cond-name.
              WHEN 'PLANT'.
                CLEAR ls_plant.
                ls_plant-sign   = 'I'.
                ls_plant-option = 'EQ'.
                ls_plant-low    = str_rec_l_range-low.
                APPEND ls_plant TO lr_plant.
              WHEN 'CUSTOMER'.
                CLEAR ls_customer.
                ls_customer-sign   = 'I'.
                ls_customer-option = 'EQ'.

                lv_kunnr = str_rec_l_range-low.
                lv_kunnr = |{ lv_kunnr ALPHA = IN }|.
                ls_customer-low    = lv_kunnr.

                APPEND ls_customer TO lr_customer.
              WHEN 'MATERIAL'.
                CLEAR ls_material.
                ls_material-sign   = 'I'.
                ls_material-option = 'EQ'.
                ls_material-low    = str_rec_l_range-low.
                SHIFT ls_materialbycustomer-low LEFT DELETING LEADING '0'.
                APPEND ls_material TO lr_material.
              WHEN 'MATERIALBYCUSTOMER'.
                CLEAR ls_materialbycustomer.
                ls_materialbycustomer-sign   = 'I'.
                ls_materialbycustomer-option = 'EQ'.
                ls_materialbycustomer-low    = str_rec_l_range-low.
                SHIFT ls_materialbycustomer-low LEFT DELETING LEADING '0'.
                APPEND ls_materialbycustomer TO lr_materialbycustomer.
              WHEN 'DURATION'.
                lv_durf            = str_rec_l_range-low.
                lv_durt            = str_rec_l_range-high.

                lv_ldate = lv_durf && '01'.
                lv_hdate = lv_durt && '01'.

                lv_begindate = zzcl_common_utils=>get_begindate_of_month(
                  EXPORTING
                    iv_date        = lv_ldate ).

                lv_enddate = zzcl_common_utils=>get_enddate_of_month(
                  EXPORTING
                    iv_date        = lv_hdate ).

                CLEAR ls_duration.
                ls_duration-sign   = 'I'.
                ls_duration-option = 'BT'.
                ls_duration-low    = lv_begindate.
                ls_duration-high   = lv_enddate.
                APPEND ls_duration TO lr_duration.
              WHEN 'CREATED_AT'.
                lv_created_atf     = str_rec_l_range-low.
                lv_created_att     = str_rec_l_range-high.
                CLEAR ls_created_at.
                ls_created_at-sign   = 'I'.
                ls_created_at-option = 'BT'.
                ls_created_at-low    = str_rec_l_range-low.
                ls_created_at-high   = str_rec_l_range-high.
                APPEND ls_created_at TO lr_created_at.
              WHEN 'LATESTOF'.
                lv_latestof     = str_rec_l_range-low.
              WHEN 'CONTENTS'.
                lv_contents    = str_rec_l_range-low.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.
        ENDLOOP.

      CATCH cx_rap_query_filter_no_range.

        "handle exception
        io_response->set_data( lt_data ).
    ENDTRY.

*   対象OFデータ取得
    SELECT ztpp_1012~plant,          "プラント
           ztpp_1012~customer,       "受注先
           ztpp_1012~material,       "品目
           materialt~productdescription AS materialname,
           cust~materialbycustomer,  "得意先品目
           ztpp_1012~created_at,     "登録日付
           ztpp_1012~requirement_date,"所要期間
           ztpp_1012~unit_of_measure,
           requirement_qty
      FROM ztpp_1012
     LEFT JOIN i_customermaterial_2 WITH PRIVILEGED ACCESS AS cust
        ON ztpp_1012~customer = cust~customer
       AND ztpp_1012~material = cust~product
     LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS materialt
        ON materialt~product  = ztpp_1012~material
       AND materialt~language = 'J'
     WHERE ztpp_1012~customer         IN @lr_customer
       AND ztpp_1012~material         IN @lr_material
       AND ztpp_1012~plant            IN @lr_plant
       AND cust~materialbycustomer    IN @lr_materialbycustomer
       AND ztpp_1012~requirement_date IN @lr_duration
*       AND ztpp_1012~created_at       IN @lr_created_at
      INTO TABLE @DATA(lt_of).

*&--Authorization Check
    DATA(lv_user_email) = zzcl_common_utils=>get_email_by_uname( ).
    DATA(lv_plant) = zzcl_common_utils=>get_plant_by_user( lv_user_email ).
    IF lv_plant IS INITIAL.
      CLEAR lt_of.
    ELSE.
      SPLIT lv_plant AT '&' INTO TABLE DATA(lt_plant_check).
      CLEAR lr_plant.
      lr_plant = VALUE #( FOR plant IN lt_plant_check ( sign = 'I' option = 'EQ' low = plant ) ).
      DELETE lt_of WHERE plant NOT IN lr_plant.
    ENDIF.
*&--Authorization Check

*   対象SOデータ取得
    IF lt_of IS NOT INITIAL.
      DATA(lt_of_copy) = lt_of.
      SORT lt_of_copy BY customer material plant.
      DELETE ADJACENT DUPLICATES FROM lt_of_copy
                            COMPARING customer material plant.
      SELECT salesorder~soldtoparty AS customer,
             rderitem~product AS material,
             materialt~productdescription AS materialname,
             rderitem~plant,
             leline~productavailabilitydate AS requirement_date,   "所要期間
             cust~materialbycustomer,          "得意先品目
             leline~schedulelineorderquantity, "受注の数量
             leline~orderquantityunit,
             rderitem~salesorder,
             rderitem~salesorderitem
        FROM i_salesorder WITH PRIVILEGED ACCESS AS salesorder
   INNER JOIN i_salesorderitem WITH PRIVILEGED ACCESS AS rderitem
          ON salesorder~salesorder = rderitem~salesorder
         AND rderitem~salesdocumentrjcnreason = @space
   INNER JOIN @lt_of_copy AS copy
          ON rderitem~product                 = copy~material
         AND rderitem~plant                   = copy~plant
         AND salesorder~soldtoparty           = copy~customer
   INNER JOIN i_salesorderscheduleline WITH PRIVILEGED ACCESS AS leline
          ON rderitem~salesorder      = leline~salesorder
         AND rderitem~salesorderitem  = leline~salesorderitem
   LEFT JOIN i_customermaterial_2 WITH PRIVILEGED ACCESS AS cust
          ON salesorder~soldtoparty = cust~customer
         AND rderitem~product = cust~product
   LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS materialt
          ON materialt~product  = rderitem~product
         AND materialt~language = 'J'
       WHERE leline~productavailabilitydate IN @lr_duration
        INTO TABLE @DATA(lt_so).
    ENDIF.

    SORT lt_of BY plant customer material materialname materialbycustomer created_at.

    lv_durationf = lv_durf.
    lv_durationt = lv_durt.

    CLEAR lv_rowno.
    LOOP AT lt_of ASSIGNING FIELD-SYMBOL(<lfs_of>)
      GROUP BY ( customer = <lfs_of>-customer
                 material = <lfs_of>-material
                 plant    = <lfs_of>-plant
                 materialbycustomer = <lfs_of>-materialbycustomer
                 created_at         = <lfs_of>-created_at ).

      CLEAR ls_data.
      ls_data-plant                = <lfs_of>-plant.
      ls_data-customer             = <lfs_of>-customer.
      ls_data-material             = <lfs_of>-material.
      ls_data-materialname         = <lfs_of>-materialname.
      ls_data-materialbycustomer   = <lfs_of>-materialbycustomer.

      CONVERT TIME STAMP <lfs_of>-created_at TIME ZONE sy-zonlo
      INTO DATE DATA(lv_date)
         TIME DATA(lv_time).

      IF lv_date NOT IN lr_created_at.
        CONTINUE.
      ENDIF.

      ls_data-created_at           = lv_date.
      ls_data-created_ats          = <lfs_of>-created_at.
      ls_data-unit_of_measure      = <lfs_of>-unit_of_measure.

      CLEAR lv_num.
      lv_durationf = lv_durf.
      lv_durationt = lv_durt.
      DO.

        lv_num    = lv_num + 1.
        lv_string1 = 'Period'  && lv_num.
        lv_string2 = 'PeriodT' && lv_num.
        ASSIGN COMPONENT lv_string1 OF STRUCTURE ls_data TO FIELD-SYMBOL(<lfs_data1>).
        ASSIGN COMPONENT lv_string2 OF STRUCTURE ls_data TO FIELD-SYMBOL(<lfs_data2>).
        <lfs_data2> = lv_durationf.

        LOOP AT GROUP <lfs_of> ASSIGNING FIELD-SYMBOL(<lfs_ofg>)
                                     WHERE requirement_date+0(6) = lv_durationf.

          <lfs_data1> = <lfs_data1> + <lfs_ofg>-requirement_qty.

        ENDLOOP.

        IF lv_durationf = lv_durationt OR lv_num = 36.
          EXIT.
        ENDIF.
        IF lv_durationf+4(2) = 12.

          lv_durationf = lv_durationf+0(4) + 1.
          lv_durationf = lv_durationf && '01'.

        ELSE.

          lv_durationf = lv_durationf + 1.

        ENDIF.
      ENDDO.

      lv_rowno = lv_rowno + 1.
      ls_data-rowno = lv_rowno.
      APPEND ls_data TO lt_data.
    ENDLOOP.

    IF lv_latestof = '02'.
*      SORT lt_data BY plant                ASCENDING
*                      customer             ASCENDING
*                      material             ASCENDING
*                      materialname         ASCENDING
*                      materialbycustomer   ASCENDING
*                      created_at           DESCENDING.
*      DELETE ADJACENT DUPLICATES FROM lt_data COMPARING plant
*                                                        customer
*                                                        material
*                                                        materialname
*                                                        materialbycustomer.

      SORT lt_data BY plant              ASCENDING
                      customer           ASCENDING
                      material           ASCENDING
                      materialname       ASCENDING
                      materialbycustomer ASCENDING
                      created_ats         DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_data COMPARING plant customer material materialname materialbycustomer.

    ENDIF.

    IF lv_contents = '03'.

      CLEAR lt_data.

    ENDIF.

    IF lv_contents = '01' OR lv_contents = '03'.
      SORT lt_so BY plant customer material materialname materialbycustomer.

      lv_durationf = lv_durf.
      lv_durationt = lv_durt.

      LOOP AT lt_so ASSIGNING FIELD-SYMBOL(<lfs_so>)
        GROUP BY ( customer = <lfs_so>-customer
                   material = <lfs_so>-material
                   plant    = <lfs_so>-plant
                   materialbycustomer = <lfs_so>-materialbycustomer ).

        CLEAR ls_data.
        ls_data-plant                = <lfs_so>-plant.
        ls_data-customer             = <lfs_so>-customer.
        ls_data-material             = <lfs_so>-material.
        ls_data-materialname         = <lfs_so>-materialname.
        ls_data-materialbycustomer   = <lfs_so>-materialbycustomer.
        ls_data-created_at           = 'SO'.
        ls_data-unit_of_measure      = <lfs_so>-orderquantityunit.

        CLEAR lv_num.
        lv_durationf = lv_durf.
        lv_durationt = lv_durt.
        DO.

          lv_num    = lv_num + 1.
          lv_string1 = 'Period'  && lv_num.
          lv_string2 = 'PeriodT' && lv_num.
          ASSIGN COMPONENT lv_string1 OF STRUCTURE ls_data TO <lfs_data1>.
          ASSIGN COMPONENT lv_string2 OF STRUCTURE ls_data TO <lfs_data2>.
          <lfs_data2> = lv_durationf.

          LOOP AT GROUP <lfs_so> ASSIGNING FIELD-SYMBOL(<lfs_sog>)
                                     WHERE requirement_date+0(6) = lv_durationf.

            <lfs_data1> = <lfs_data1> + <lfs_sog>-schedulelineorderquantity.

          ENDLOOP.

          IF lv_durationf = lv_durationt OR lv_num = 36.
            EXIT.
          ENDIF.

          IF lv_durationf+4(2) = 12.

            lv_durationf = lv_durationf+0(4) + 1.
            lv_durationf = lv_durationf && '01'.

          ELSE.

            lv_durationf = lv_durationf + 1.

          ENDIF.
        ENDDO.

        lv_rowno = lv_rowno + 1.
        ls_data-rowno = lv_rowno.
        APPEND ls_data TO lt_data.
      ENDLOOP.
    ENDIF.

    SORT lt_data BY plant customer material materialname materialbycustomer created_at.

    io_response->set_total_number_of_records( lines( lt_data ) ).

    "Sort
    IF io_request->get_sort_elements( ) IS NOT INITIAL.
      zzcl_odata_utils=>orderby(
        EXPORTING
          it_order = io_request->get_sort_elements( )
        CHANGING
          ct_data  = lt_data ).
    ENDIF.

    DATA(ls_re) = io_request->get_paging( ).

    "Page
    zzcl_odata_utils=>paging(
      EXPORTING
        io_paging = io_request->get_paging( )
      CHANGING
        ct_data   = lt_data ).

    io_response->set_data( lt_data ).

  ENDMETHOD.
ENDCLASS.
