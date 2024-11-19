CLASS zcl_ecn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_ecn IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    TYPES:
      BEGIN OF ty_changemaster_ent,
        objmgmtrecdobject    TYPE aeusobj,
        sapobjecttechnicalid TYPE aeobjekt,
      END OF ty_changemaster_ent.

    DATA:

      lt_data           TYPE STANDARD TABLE OF zr_ecn,
      ls_data           TYPE zr_ecn,
      lr_material       TYPE RANGE OF zr_ecn-material,
      ls_material       LIKE LINE OF lr_material,
      lr_mrpresponsible TYPE RANGE OF zr_ecn-mrpresponsible,
      ls_mrpresponsible LIKE LINE OF lr_mrpresponsible,
      lr_bofmvu         TYPE RANGE OF zr_ecn-billofmaterialvariantusage,
      ls_bofmvu         LIKE LINE OF lr_bofmvu,
      lr_variant        TYPE RANGE OF zr_ecn-billofmaterialvariant,
      ls_variant        LIKE LINE OF lr_variant,
      lv_plant          TYPE zr_ecn-plant,

      lr_changedoc      TYPE RANGE OF zr_ecn-ecnno,
      ls_changedoc      LIKE LINE OF lr_changedoc,

      lr_begdat         TYPE RANGE OF zr_ecn-ecnvalidfrom,
      ls_begdat         LIKE LINE OF lr_begdat,

      lr_credat         TYPE RANGE OF zr_ecn-ecncreateat,
      ls_credat         LIKE LINE OF  lr_credat,

      lr_bomcom         TYPE RANGE OF zr_ecn-component,
      ls_bomcom         LIKE LINE OF lr_bomcom,
      lv_subitem        TYPE  abap_boolean,

      lv_minimumgroup   TYPE abap_boolean.

    TYPES:

      BEGIN OF ts_bom_api,  "api structue

        billofmaterial                TYPE string,
        billofmaterialcategory        TYPE string,
        billofmaterialvariant         TYPE string,
        billofmaterialversion         TYPE string,
        billofmaterialitemnodenumber  TYPE string,
        material                      TYPE string,
        plant                         TYPE string,
        bomiteminternalchangecount    TYPE string,
        validitystartdate             TYPE c LENGTH 8,
        validityenddate               TYPE c LENGTH 8,
        engineeringchangedocument     TYPE string,
        chgtoengineeringchgdocument   TYPE string,
        inheritednodenumberforbomitem TYPE string,
        bomitemrecordcreationdate     TYPE c LENGTH 8,
        bomitemlastchangedate         TYPE c LENGTH 8,
        billofmaterialcomponent       TYPE string,
        billofmaterialitemnumber      TYPE string,
        billofmaterialitemunit        TYPE zr_ecn-unit,
        billofmaterialitemquantity    TYPE zr_ecn-qty,
        bomitemsorter                 TYPE string,
        isassembly                    TYPE string,
        alternativeitemgroup          TYPE string,
        followupgroup                 TYPE string,
        discontinuationgroup          TYPE string,
        issubitem                     TYPE c LENGTH 1,
        headerchangedocument          TYPE string,

      END OF ts_bom_api,

      tt_bom_api TYPE STANDARD TABLE OF ts_bom_api WITH DEFAULT KEY,

      BEGIN OF ts_bom_apisub,  "api structue

        billofmaterial               TYPE string,
        billofmaterialcategory       TYPE string,
        billofmaterialvariant        TYPE string,
        billofmaterialversion        TYPE string,
        billofmaterialitemnodenumber TYPE string,
        headerchangedocument         TYPE string,
        material                     TYPE string,
        plant                        TYPE string,
        bomsubiteminstallationpoint  TYPE string,

      END OF ts_bom_apisub,

      tt_bom_apisub TYPE STANDARD TABLE OF ts_bom_apisub WITH DEFAULT KEY,


      BEGIN OF ts_bom_d,
        __count TYPE string,
        results TYPE tt_bom_api,
      END OF ts_bom_d,

      BEGIN OF ts_bom_dsub,
        __count TYPE string,
        results TYPE tt_bom_apisub,
      END OF ts_bom_dsub,


      BEGIN OF ts_message,
        lang  TYPE string,
        value TYPE string,
      END OF ts_message,

      BEGIN OF ts_error,
        code    TYPE string,
        message TYPE ts_message,
      END OF ts_error,

      BEGIN OF ts_res_bom_api,
        d     TYPE ts_bom_d,
        error TYPE ts_error,
      END OF ts_res_bom_api,

      BEGIN OF ts_res_bom_apisub,
        d     TYPE ts_bom_dsub,
        error TYPE ts_error,
      END OF ts_res_bom_apisub,

      BEGIN OF ts_ecn,
        changenumber                TYPE  aennr,
        changenumbercreationdate    TYPE  cc_andat,
        changenumbervalidfromdate   TYPE  cc_andat,
        changenumberdescription     TYPE  cc_aetxt,
        reasonforchangetext         TYPE  cc_aegru,
        objmgmtrecdobjrevisionlevel TYPE c LENGTH 2,

      END OF ts_ecn,

      tt_ecn TYPE STANDARD TABLE OF ts_ecn WITH DEFAULT KEY,

      BEGIN OF ts_basic,
        serialnumber                  TYPE i,
        changediff                    TYPE c LENGTH 10,
        changenumbercreationdate      TYPE c LENGTH 8,   "1
        engineeringchangedocument     TYPE string,   "2
        changenumbervalidfromdate     TYPE c LENGTH 8,   "3
        changenumberdescription       TYPE string,   "4
        reasonforchangetext           TYPE cc_aegru,   "5
        objmgmtrecdobjrevisionlevel   TYPE string,   "6
        billofmaterial                TYPE string,   "17
        billofmaterialcategory        TYPE string,   "18
        billofmaterialvariant         TYPE string,   "9
        billofmaterialversion         TYPE string,   "19
        billofmaterialitemnodenumber  TYPE string,   "20
        material                      TYPE string,   "7
        plant                         TYPE string,   "8
        bomiteminternalchangecount    TYPE string,   "21
        validitystartdate             TYPE c LENGTH 8,   "22
        validityenddate               TYPE c LENGTH 8,   "23
        chgtoengineeringchgdocument   TYPE string,   "24
        inheritednodenumberforbomitem TYPE string,   "25
        bomitemrecordcreationdate     TYPE c LENGTH 8,   "26
        bomitemlastchangedate         TYPE c LENGTH 8,   "27
        billofmaterialcomponent       TYPE string,   "11
        billofmaterialitemnumber      TYPE string,   "10
        billofmaterialitemunit        TYPE zr_ecn-unit,   "13
        billofmaterialitemquantity    TYPE zr_ecn-qty,   "12
        bomitemsorter                 TYPE string,   "28
        isassembly                    TYPE string,   "29
        alternativeitemgroup          TYPE string,   "14
        followupgroup                 TYPE string,   "16
        discontinuationgroup          TYPE string,   "15
        issubitem                     TYPE c LENGTH 1,   "30
        headerchangedocument          TYPE string,   "31
        netweight                     TYPE ntgew,   "32
        weightunit                    TYPE gewei,   "33
        bomsubiteminstallationpoint   TYPE string,   "34
        mrpresponsible                TYPE dispo,   "mpr

      END OF ts_basic,

      tt_baisc TYPE STANDARD TABLE OF ts_basic WITH DEFAULT KEY,

      BEGIN OF ts_ecn_d,
        results TYPE tt_ecn,
      END OF ts_ecn_d,

      BEGIN OF ts_ecn_api,
        d TYPE ts_ecn_d,
      END OF ts_ecn_api.

    DATA:
      lt_bom_api        TYPE STANDARD TABLE OF ts_bom_api,
      lt_bom_apisub     TYPE STANDARD TABLE OF ts_bom_apisub,
      ls_bom_api        TYPE ts_bom_api,
      ls_res_bom_api    TYPE ts_res_bom_api,
      ls_res_bom_apisub TYPE ts_res_bom_apisub,
      lv_path           TYPE string,
      lv_path1          TYPE string,
      lv_path2          TYPE string,
      lv_path3          TYPE string,
      lt_bomlist_tmp    TYPE STANDARD TABLE OF zcl_explodebom=>ty_bomlist,
      lt_bomlist        TYPE STANDARD TABLE OF zcl_explodebom=>ty_bomlist,
      lv_point          TYPE string.


    DATA:
      lt_ecn_api TYPE STANDARD TABLE OF ts_ecn,
      ls_ecn_api TYPE ts_ecn,
      ls_res_ecn TYPE ts_ecn_api.

    DATA:
      lt_basic    TYPE STANDARD TABLE OF ts_basic,
      lt_basicdis TYPE STANDARD TABLE OF ts_basic,
      lt_basicobj TYPE STANDARD TABLE OF ts_basic,
      lw_basicdis TYPE ts_basic,
      lw_basicobj TYPE ts_basic,
      lw_basic    TYPE ts_basic,
      lt_basicall TYPE STANDARD TABLE OF ts_basic,
      lw_basicall TYPE ts_basic.

    CONSTANTS:
      lc_msgid                  TYPE string VALUE 'ZPP_008',
      lc_msgty                  TYPE string VALUE 'E',
      lc_alpha_in               TYPE string VALUE 'IN',
      lc_alpha_out              TYPE string VALUE 'OUT',
      lc_separator              TYPE string VALUE '、',
      lc_itemgroup_main         TYPE string VALUE 'Main',
      lc_itemgroup_sub          TYPE string VALUE 'Sub',
      lc_discfollowupgroup_stop TYPE string VALUE 'Stop',
      lc_discfollowupgroup_new  TYPE string VALUE 'New',
      lc_localposition_h        TYPE string VALUE 'H',
      lc_localposition_v        TYPE string VALUE 'V',
      lc_profilecode_z0         TYPE string VALUE 'Z0',
      lc_profilecode_z2         TYPE string VALUE 'Z2',
      lc_profilecode_z3         TYPE string VALUE 'Z3',
      lc_profilecode_lock       TYPE string VALUE 'Purcahse Lock',
      lc_changenumberobjecttype TYPE aetyp  VALUE '41',
      lc_priority_01            TYPE n LENGTH 2  VALUE '01',
*      lc_priority_02            TYPE n LENGTH 2  VALUE '02',
*      lc_itemcategory_l         TYPE c LENGTH 1  VALUE 'L',
      lc_ispurcondrec_yes       TYPE c LENGTH 10 VALUE 'YES',
      lc_ispurcondrec_no        TYPE c LENGTH 10 VALUE 'NO',
      lc_sign_i                 TYPE c LENGTH 1 VALUE 'I',
      lc_opt_eq                 TYPE c LENGTH 2 VALUE 'EQ',
      lc_opt_le                 TYPE c LENGTH 2 VALUE 'LE'.

    IF io_request->is_data_requested( ).
      TRY.
          "Get and add filter
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
      ENDTRY.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        LOOP AT ls_filter_cond-range INTO DATA(str_rec_l_range).
          CASE ls_filter_cond-name.
            WHEN 'PLANT'.
              lv_plant = str_rec_l_range-low.

            WHEN 'MATERIAL'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_material.
              ls_material-low  = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_material-low ).
              ls_material-high = zzcl_common_utils=>conversion_matn1( EXPORTING iv_alpha = lc_alpha_in iv_input = ls_material-high ).
              APPEND ls_material TO lr_material.
              CLEAR ls_material.

            WHEN 'MRPRESPONSIBLE'.
              MOVE-CORRESPONDING str_rec_l_range TO ls_mrpresponsible.
              APPEND ls_mrpresponsible TO lr_mrpresponsible.
              CLEAR ls_mrpresponsible.

            WHEN 'BILLOFMATERIALVARIANTUSAGE'.
*                lv_BOfMVU = str_rec_l_range-low.
              MOVE-CORRESPONDING str_rec_l_range TO ls_bofmvu.
              APPEND ls_bofmvu TO lr_bofmvu.
              CLEAR ls_bofmvu.

            WHEN 'BILLOFMATERIALVARIANT'.
*                lv_variant = |{ str_rec_l_range-low ALPHA = IN }|.

              MOVE-CORRESPONDING str_rec_l_range TO ls_variant.
              APPEND ls_variant TO lr_variant.
              CLEAR ls_variant.

            WHEN 'ECNNO'.

              MOVE-CORRESPONDING str_rec_l_range TO ls_changedoc.
              APPEND ls_changedoc TO lr_changedoc.
              CLEAR ls_changedoc.


            WHEN 'ECNVALIDFROM'.

              MOVE-CORRESPONDING str_rec_l_range TO ls_begdat.
              APPEND ls_begdat TO lr_begdat.
              CLEAR ls_begdat.

            WHEN 'ECNCREATEAT'.

              MOVE-CORRESPONDING str_rec_l_range TO ls_credat.
              APPEND ls_credat TO lr_credat.
              CLEAR ls_credat.

            WHEN 'COMPONENT'.

              MOVE-CORRESPONDING str_rec_l_range TO ls_bomcom.
              APPEND ls_bomcom TO lr_bomcom.
              CLEAR ls_bomcom.

            WHEN 'SUBITEM'.

              lv_subitem = str_rec_l_range-low .

            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      ENDLOOP.

      IF lr_changedoc IS NOT INITIAL.

        LOOP  AT lr_changedoc ASSIGNING FIELD-SYMBOL(<fs_changedoc>).

          <fs_changedoc>-low  = |{ <fs_changedoc>-low ALPHA = OUT }|.

        ENDLOOP.

      ENDIF.

*      if lr_variant is NOT INITIAL.
*
*        LOOP  AT lr_variant ASSIGNING FIELD-SYMBOL(<fs_variant>).
*
*          <fs_variant>-low  = |{ <fs_variant>-low ALPHA = IN }|.
*
*        ENDLOOP.
*
*
*      ENDIF.

      SELECT a~billofmaterial,
             a~material,
             a~plant,
             a~billofmaterialvariantusage,
             a~billofmaterialvariant,
             b~mrpresponsible,
             a~billofmaterialcategory
      FROM i_materialbomlink WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b
      ON   b~product = a~material
      AND  b~plant = a~plant
      WHERE a~material IN @lr_material
        AND a~plant = @lv_plant
        AND a~billofmaterialvariantusage IN @lr_bofmvu

        "AND a~billofmaterialvariant IN @lr_variant

        AND b~mrpresponsible IN @lr_mrpresponsible
       INTO TABLE @DATA(lt_bomlink).


      SELECT
             a~material,
             a~plant,
             a~billofmaterialvariantusage,
             b~mrpresponsible

      FROM i_materialbomlink WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b
      ON   b~product = a~material
      AND  b~plant = a~plant

       INTO TABLE @DATA(lt_bomusemrp).



      LOOP AT lt_bomlink INTO DATA(ls_materialbomlink).
        "Explode BOM
        zcl_explodebom=>get_data(
          EXPORTING
            iv_explosiontype               = '4'
            iv_plant                       = ls_materialbomlink-plant
            iv_material                    = ls_materialbomlink-material
            iv_billofmaterialcategory      = ls_materialbomlink-billofmaterialcategory
*            iv_billofmaterialvariant       = lv_variant
            iv_bomexplosionapplication     = 'PP01'
            iv_bomexplosiondate            = '20241108'
            iv_headermaterial              = ls_materialbomlink-material
            iv_headerbillofmaterialvariant = ls_materialbomlink-billofmaterialvariant
            iv_requiredquantity            = '1'
          CHANGING
            ct_bomlist                     = lt_bomlist_tmp ).

        APPEND LINES OF lt_bomlist_tmp TO lt_bomlist.
        CLEAR lt_bomlist_tmp.
      ENDLOOP.

      IF    lt_bomlist IS NOT INITIAL.

        SORT lt_bomlist BY material plant billofmaterialvariant billofmaterialcategory.

        DELETE ADJACENT DUPLICATES FROM lt_bomlist COMPARING material plant billofmaterialvariant billofmaterialcategory.

      ENDIF.

      LOOP AT  lt_bomlist INTO DATA(lw_bomlist).
        DATA(lv_a) = lw_bomlist-billofmaterial.
        DATA(lv_b) = lw_bomlist-plant.
        DATA(lv_c) = lw_bomlist-material.
        DATA(lv_d) = lw_bomlist-billofmaterialvariant.


        lv_path = |/API_BILL_OF_MATERIAL_SRV;v=0002/MaterialBOMItem?$filter=BillOfMaterial eq '{ lv_a }' & Plant eq '{ lv_b }' & Material eq '{ lv_c }' & BillOfMaterialVariant eq '{ lv_d }'|.

        CLEAR : lv_a ,lv_b ,lv_c, lv_d.
        zzcl_common_utils=>request_api_v2(
               EXPORTING
                 iv_path        = lv_path
                 iv_method      = if_web_http_client=>get
               IMPORTING
                 ev_status_code = DATA(lv_stat_code)
                 ev_response    = DATA(lv_resbody_api) ).

        /ui2/cl_json=>deserialize(
                                    EXPORTING json = lv_resbody_api
                                    CHANGING data = ls_res_bom_api ).

        IF lv_stat_code = '200' AND ls_res_bom_api-d-results IS NOT INITIAL.

          SORT ls_res_bom_api-d-results BY billofmaterialcomponent plant billofmaterialvariant billofmaterialitemnodenumber .

          DELETE ADJACENT DUPLICATES FROM ls_res_bom_api-d-results .

          APPEND LINES OF ls_res_bom_api-d-results TO lt_bom_api.

        ENDIF.

      ENDLOOP.

      SORT lt_bom_api BY billofmaterial billofmaterialcategory billofmaterialvariant billofmaterialversion billofmaterialitemnodenumber.

      DELETE ADJACENT DUPLICATES FROM lt_bom_api.

*      DATA(LT_BOM_API1) = lt_bom_api.

      DATA(lt_bom_api1) = lt_bom_api.

      DELETE lt_bom_api WHERE engineeringchangedocument IS INITIAL  AND chgtoengineeringchgdocument IS INITIAL.

*     2.1.2ECN情報取得
      lv_path = |/YY1_CHANGEMASTER_CDS/YY1_ChangeMaster|.
      "Call API
      zzcl_common_utils=>request_api_v2(
        EXPORTING
          iv_path        = lv_path
          iv_method      = if_web_http_client=>get
          iv_format      = 'json'
        IMPORTING
          ev_status_code = DATA(lv_stat_code1)
          ev_response    = DATA(lv_resbody_api1) ).
      /ui2/cl_json=>deserialize( EXPORTING json = lv_resbody_api1
                               CHANGING data = ls_res_ecn ).

      IF lv_stat_code1 = '200' AND ls_res_ecn-d-results IS NOT INITIAL.

        APPEND LINES OF ls_res_ecn-d-results TO lt_ecn_api.

      ENDIF.

* 2.1.3品目基本情報取得

      SELECT
             product,
             netweight,
             weightunit
        FROM i_product WITH PRIVILEGED ACCESS
        INTO TABLE @DATA(lt_product).

      LOOP  AT lt_bom_api ASSIGNING FIELD-SYMBOL(<fs_bomapi>).

        MOVE-CORRESPONDING <fs_bomapi> TO lw_basic.



        READ TABLE lt_ecn_api INTO DATA(lw_ecn) WITH KEY changenumber = <fs_bomapi>-engineeringchangedocument  .

        IF sy-subrc = 0.

          lw_basic-changenumbercreationdate     = lw_ecn-changenumbercreationdate   .
          lw_basic-changenumbervalidfromdate    = lw_ecn-changenumbervalidfromdate  .
          lw_basic-changenumberdescription      = lw_ecn-changenumberdescription    .
          lw_basic-reasonforchangetext          = lw_ecn-reasonforchangetext        .
          lw_basic-objmgmtrecdobjrevisionlevel  = lw_ecn-objmgmtrecdobjrevisionlevel.

        ENDIF.

        CLEAR : lw_ecn.

        APPEND lw_basic TO lt_basic.

        CLEAR :lw_basic.

      ENDLOOP.

      LOOP  AT lt_bom_api1 ASSIGNING FIELD-SYMBOL(<fs_bomapi1>).

        MOVE-CORRESPONDING <fs_bomapi1> TO lw_basic.



        READ TABLE lt_ecn_api INTO lw_ecn WITH KEY changenumber = <fs_bomapi>-engineeringchangedocument  .

        IF sy-subrc = 0.

          lw_basic-changenumbercreationdate     = lw_ecn-changenumbercreationdate   .
          lw_basic-changenumbervalidfromdate    = lw_ecn-changenumbervalidfromdate  .
          lw_basic-changenumberdescription      = lw_ecn-changenumberdescription    .
          lw_basic-reasonforchangetext          = lw_ecn-reasonforchangetext        .
          lw_basic-objmgmtrecdobjrevisionlevel  = lw_ecn-objmgmtrecdobjrevisionlevel.

        ENDIF.

        CLEAR : lw_ecn.

        APPEND lw_basic TO lt_basicall.

        CLEAR :lw_basicall.

      ENDLOOP.



      DATA:
          lv_serialnumber TYPE i.
      "变更后数据
      LOOP AT lt_basic INTO lw_basic.
        IF  lw_basic-engineeringchangedocument IS NOT INITIAL.

          lv_serialnumber = lv_serialnumber + 1.
          lw_basic-changediff = '変更後'.
          lw_basic-serialnumber = lv_serialnumber.

          "操作对象
          APPEND lw_basic TO lt_basicobj.
          "显示
          APPEND lw_basic TO lt_basicdis.
          CLEAR lw_basic.

        ENDIF.

      ENDLOOP.

      LOOP AT lt_basicobj INTO lw_basicobj.

*       新规情况。
        IF  lw_basicobj-inheritednodenumberforbomitem = lw_basicobj-billofmaterialitemnodenumber.

*            MOVE-CORRESPONDING lw_basicobj to lw_basicdis.

*            只显示ecn
          lw_basicdis-changediff                       = '変更前'.
          lw_basicdis-serialnumber                     = lw_basicobj-serialnumber.
          lw_basicdis-engineeringchangedocument        = lw_basicobj-engineeringchangedocument.
          lw_basicdis-plant                            = lw_basicobj-plant.
          lw_basicdis-changenumbercreationdate         = lw_basicobj-changenumbercreationdate    .
          lw_basicdis-changenumbervalidfromdate        = lw_basicobj-changenumbervalidfromdate   .
          lw_basicdis-changenumberdescription          = lw_basicobj-changenumberdescription     .
          lw_basicdis-reasonforchangetext              = lw_basicobj-reasonforchangetext         .
          lw_basicdis-objmgmtrecdobjrevisionlevel      = lw_basicobj-objmgmtrecdobjrevisionlevel .

          APPEND lw_basicdis  TO lt_basicdis.
          CLEAR lw_basicdis.

*        查找修改

        ELSE.

          READ TABLE lt_basicall INTO lw_basicall WITH KEY billofmaterial = lw_basicobj-billofmaterial
                                                 billofmaterialcategory = lw_basicobj-billofmaterialcategory
                                                 billofmaterialvariant = lw_basicobj-billofmaterialvariant
                                                 billofmaterialitemnodenumber = lw_basicobj-inheritednodenumberforbomitem  .
          IF sy-subrc =  0 .

            MOVE-CORRESPONDING lw_basicall TO lw_basicdis.

            lw_basicdis-changediff = '変更前'.
            lw_basicdis-serialnumber = lw_basicobj-serialnumber.
            lw_basicdis-engineeringchangedocument        = lw_basicobj-engineeringchangedocument.

            lw_basicdis-changenumbercreationdate         = lw_basicobj-changenumbercreationdate    .
            lw_basicdis-changenumbervalidfromdate        = lw_basicobj-changenumbervalidfromdate   .
            lw_basicdis-changenumberdescription          = lw_basicobj-changenumberdescription     .
            lw_basicdis-reasonforchangetext              = lw_basicobj-reasonforchangetext         .
            lw_basicdis-objmgmtrecdobjrevisionlevel      = lw_basicobj-objmgmtrecdobjrevisionlevel .

            APPEND lw_basicdis TO lt_basicdis.
            CLEAR lw_basicdis.

          ENDIF.

          CLEAR: lw_basicall.

        ENDIF.

      ENDLOOP.

      SORT lt_basicdis BY serialnumber engineeringchangedocument changediff .

      DATA:

        lv_index TYPE i.

      IF lv_subitem IS NOT INITIAL.

        LOOP AT lt_basicdis INTO DATA(lw_basicsub) WHERE issubitem IS NOT INITIAL.

          DATA(lv_e)  =   lw_basicsub-billofmaterial.
          DATA(lv_f)  =   lw_basicsub-billofmaterialcategory.
          DATA(lv_g)  =   lw_basicsub-billofmaterialvariant.
          DATA(lv_h)  =   lw_basicsub-billofmaterialversion.
          DATA(lv_i)  =   lw_basicsub-billofmaterialitemnodenumber.
          DATA(lv_j)  =   lw_basicsub-headerchangedocument.
          DATA(lv_k)  =   lw_basicsub-material.
          DATA(lv_l)  =   lw_basicsub-plant.

          lv_path1 = |/API_BILL_OF_MATERIAL_SRV;v=0002/MaterialBOMSubItem?$filter=BillOfMaterial eq '{ lv_e }' and BillOfMaterialCategory eq '{ lv_f }'and BillOfMaterialVariant eq '{ lv_g }' |.
          lv_path2 = | and BillOfMaterialVersion eq '{ lv_h }' and BillOfMaterialItemNodeNumber eq '{ lv_i }' and HeaderChangeDocument eq '{ lv_j }' and Material eq '{ lv_k }' and Plant eq '{ lv_l }' |.

          lv_path3 = |{ lv_path1 } { lv_path2 }|.

          zzcl_common_utils=>request_api_v2(
                 EXPORTING
                   iv_path        = lv_path3
                   iv_method      = if_web_http_client=>get
                 IMPORTING
                   ev_status_code = DATA(lv_stat_codesub)
                   ev_response    = DATA(lv_resbody_apisub) ).

          /ui2/cl_json=>deserialize(
                                      EXPORTING json = lv_resbody_apisub
                                      CHANGING data = ls_res_bom_apisub ).


          IF lv_stat_code = '200' AND ls_res_bom_api-d-results IS NOT INITIAL.

            APPEND LINES OF ls_res_bom_apisub-d-results TO lt_bom_apisub.

          ENDIF.

        ENDLOOP.

      ENDIF.

      LOOP AT lt_basicdis INTO lw_basicdis.

        lv_index = lv_index + 1.

        ls_data-seq                          = lv_index.
        ls_data-serialnumber                  = lw_basicdis-serialnumber.
        ls_data-changediff                    = lw_basicdis-changediff.
        ls_data-ecncreateat                   = lw_basicdis-changenumbercreationdate.                   "1
        ls_data-ecnno                         = lw_basicdis-engineeringchangedocument.                    "2
        ls_data-ecnvalidfrom                  = lw_basicdis-changenumbervalidfromdate.                 "3
        ls_data-ecntext                       = lw_basicdis-changenumberdescription .                     "4
        ls_data-ecnreason                     = lw_basicdis-reasonforchangetext.                          "5
        ls_data-revison                       = lw_basicdis-objmgmtrecdobjrevisionlevel.                  "6
        ls_data-headmat                       = lw_basicdis-material.                                     "7
        ls_data-plant                         = lw_basicdis-plant.                                        "8
        ls_data-billofmaterialvariant         = lw_basicdis-billofmaterialvariant.                        "9
        ls_data-itemno                        = lw_basicdis-billofmaterialitemnumber.                     "10
        ls_data-component                     = lw_basicdis-billofmaterialcomponent.                      "11
        ls_data-qty                           = lw_basicdis-billofmaterialitemquantity.                   "12
        ls_data-unit                          = lw_basicdis-billofmaterialitemunit.                       "13
        ls_data-altgroup                      = lw_basicdis-alternativeitemgroup.                         "14
        ls_data-discontinuationgroup          = lw_basicdis-discontinuationgroup.                         "15
        ls_data-followupgroup                 = lw_basicdis-followupgroup.                                "16
        ls_data-netweight                     = lw_basicdis-netweight.                                    "32
        ls_data-weightunit                    = lw_basicdis-weightunit.                                   "33
        ls_data-bomsubiteminstallationpoint   = lw_basicdis-bomsubiteminstallationpoint.                  "34

        LOOP AT  lt_bom_apisub INTO DATA(lw_apisub) WHERE billofmaterial                 = lw_basicdis-billofmaterial
                                                      AND billofmaterialcategory         = lw_basicdis-billofmaterialcategory
                                                      AND billofmaterialvariant          = lw_basicdis-billofmaterialvariant
                                                      AND billofmaterialversion          = lw_basicdis-billofmaterialversion
                                                      AND billofmaterialitemnodenumber   = lw_basicdis-billofmaterialitemnodenumber
                                                      AND headerchangedocument           = lw_basicdis-headerchangedocument
                                                      AND material                       = lw_basicdis-material
                                                      AND plant                          = lw_basicdis-plant .

          lv_point = lv_point && ',' && lw_apisub-bomsubiteminstallationpoint.
*           |{ lw_apisub-bomsubiteminstallationpoint } , { lv_point }|.

        ENDLOOP.
        IF lv_point IS NOT INITIAL.
          SHIFT lv_point BY 1 PLACES.
          ls_data-bomsubiteminstallationpoint   = lv_point.                  "34
          CLEAR lv_point.

        ENDIF.

        APPEND ls_data TO lt_data.
        CLEAR ls_data.

      ENDLOOP.


      DELETE lt_data WHERE      ecnno NOT IN lr_changedoc.
      DELETE lt_data WHERE      ecnvalidfrom NOT IN lr_begdat.
      DELETE lt_data WHERE      ecncreateat NOT IN lr_credat.
      DELETE lt_data WHERE      component NOT IN lr_bomcom.
      DELETE lt_data Where      billofmaterialvariant not in lr_variant.



      loop at lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

        READ TABLE lt_product INTO data(lw_product) WITH KEY product = <fs_data>-component.

            IF sy-subrc = 0.

              <fs_data>-netweight   = lw_product-netweight .
              <fs_data>-weightunit  = lw_product-weightunit.

            ENDIF.


        READ TABLE lt_bomusemrp INTO DATA(lw_bomusemrp) WITH KEY material = <fs_data>-HeadMat plant = <fs_data>-plant.

        IF sy-subrc = 0.

          <fs_data>-mrpresponsible                = lw_bomusemrp-mrpresponsible.                                "35
          <fs_data>-billofmaterialvariantusage    = lw_bomusemrp-billofmaterialvariantusage.

        ENDIF.

        CLEAR: lw_product, lw_bomusemrp.

      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_data ) ).

      "Sort
      IF io_request->get_sort_elements( ) IS NOT INITIAL.
        zzcl_odata_utils=>orderby(
          EXPORTING
            it_order = io_request->get_sort_elements( )
          CHANGING
            ct_data  = lt_data ).
      ENDIF.

      "Page
      zzcl_odata_utils=>paging(
        EXPORTING
          io_paging = io_request->get_paging( )
        CHANGING
          ct_data   = lt_data ).

      io_response->set_data( lt_data ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
