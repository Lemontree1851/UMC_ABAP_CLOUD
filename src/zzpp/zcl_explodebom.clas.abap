CLASS zcl_explodebom DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_bomlist,
        material                     TYPE matnr,
        plant                        TYPE werks_d,
        billofmaterialvariantroot    TYPE i_materialbomlink-billofmaterialvariant,
        headermaterial               TYPE matnr,
        explodebomlevelvalue         TYPE i,
        billofmaterialitemnumber     TYPE c LENGTH 4,
        billofmaterialitemcategory   TYPE c LENGTH 1,
        billofmaterialcomponent      TYPE matnr,
        componentdescription         TYPE maktx,
        billofmaterialvariant        TYPE i_materialbomlink-billofmaterialvariant,
        alternativeitemgroup         TYPE c LENGTH 2,
        alternativeitempriority      TYPE n LENGTH 2,
        alternativeitemstrategy      TYPE c LENGTH 1,
        usageprobabilitypercent      TYPE p LENGTH 3 DECIMALS 0,
        bomitemisdiscontinued        TYPE kzaus,
        discontinuationgroup         TYPE c LENGTH 2,
        followupgroup                TYPE c LENGTH 2,
        billofmaterialitemunit       TYPE meins,
        componentquantityincompuom   TYPE i_billofmaterialitemdex_3-billofmaterialitemquantity,
        bomitemsorter                TYPE c LENGTH 10,
        ismaterialprovision          TYPE c LENGTH 1,
*        changenumber                 TYPE aennr,
        bomitemtext2                 TYPE c LENGTH 40,
        bomitemdescription           TYPE potx1,
        isbulkmaterial               TYPE schgt,
        bomitemiscostingrelevant     TYPE c LENGTH 1,
        revisionlevel                TYPE c LENGTH 2,
        materialgroup                TYPE matkl,
        billofmaterialitembaseunit   TYPE meins,
        componentquantityinbaseuom   TYPE i_billofmaterialitemdex_3-billofmaterialitemquantity,
        prodorderissuelocation       TYPE c LENGTH 4,
        billofmaterial               TYPE i_materialbomlink-billofmaterial,
        billofmaterialitemnodenumber TYPE i_billofmaterialitemdex_3-billofmaterialitemnodenumber,
        billofmaterialcategory       TYPE i_materialbomlink-billofmaterialcategory,
        billofmaterialvariantusage   TYPE i_materialbomlink-billofmaterialvariantusage,

        bomhdrrootmatlhiernode       TYPE matnr,
        bomhdrmatlhiernode           TYPE matnr,
        billofmaterialversion        TYPE c LENGTH 4,
        billofmaterialitemquantity   TYPE i_billofmaterialitemdex_3-billofmaterialitemquantity,
        materialiscoproduct          TYPE c LENGTH 1,
        billofmaterialroot           TYPE c LENGTH 8,
        billofmaterialitemindex      TYPE i,
      END OF ty_bomlist,
      tt_bomlist TYPE STANDARD TABLE OF ty_bomlist.

    CLASS-METHODS:
      "! Get data of BOM
      "! iv_quantityinheritance: abap_true->explode component BOM with component quantity
      "!                         abap_false->explode component BOM with iv_requiredquantity
      get_data IMPORTING iv_explosiontype               TYPE ze_explodetype OPTIONAL
                         iv_plant                       TYPE werks_d
                         iv_material                    TYPE matnr
                         iv_billofmaterialcategory      TYPE i_materialbomlink-billofmaterialcategory
                         iv_billofmaterialvariant       TYPE i_materialbomlink-billofmaterialvariant OPTIONAL
                         iv_bomexplosionapplication     TYPE i_billofmaterialwithkeydate-bomexplosionapplication
                         iv_bomexplosiondate            TYPE datuv
                         iv_headermaterial              TYPE matnr
                         iv_headerbillofmaterialvariant TYPE i_materialbomlink-billofmaterialvariant
                         iv_requiredquantity            TYPE basmn
                         iv_explodebomlevelvalue        TYPE i OPTIONAL
                         iv_quantityinheritance         TYPE abap_boolean DEFAULT abap_false
               CHANGING  ct_bomlist                     TYPE tt_bomlist.

  PROTECTED SECTION.
    CONSTANTS:
      lc_billofmaterialvariant_01 TYPE i_materialbomlink-billofmaterialvariant VALUE '01',
      lc_explodetype_1            TYPE ze_explodetype                          VALUE '1',
      lc_explodetype_2            TYPE ze_explodetype                          VALUE '2',
      lc_explodetype_3            TYPE ze_explodetype                          VALUE '3',
      lc_explodetype_4            TYPE ze_explodetype                          VALUE '4'.

  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EXPLODEBOM IMPLEMENTATION.


  METHOD get_data.
    DATA:
      lt_bomlist                  TYPE STANDARD TABLE OF ty_bomlist,
      ls_bomlist                  TYPE ty_bomlist,
      lv_bomexplosionismultilevel TYPE abap_boolean,
      lv_bomexplosionisnextlevel  TYPE abap_boolean,
      lv_requiredquantity         TYPE basmn,
      lv_explodebomlevelvalue     TYPE i.

    "最上层=可选BOM输入值
    IF iv_explosiontype = lc_explodetype_2 AND iv_quantityinheritance = abap_true.
      lv_bomexplosionismultilevel = abap_true.
    ENDIF.

    "Explode BOM
    READ ENTITIES OF i_billofmaterialtp_2 PRIVILEGED ENTITY billofmaterial
         EXECUTE explodebom
         FROM VALUE #(
         ( plant = iv_plant
           material = iv_headermaterial
           billofmaterialcategory = iv_billofmaterialcategory
           billofmaterialvariant = iv_headerbillofmaterialvariant

           %param-bomexplosionapplication = iv_bomexplosionapplication
           %param-requiredquantity = iv_requiredquantity
           %param-explodebomlevelvalue = 0
           %param-bomexplosionismultilevel = lv_bomexplosionismultilevel
           %param-bomexplosiondate = iv_bomexplosiondate
         )
         )
         RESULT DATA(lt_result)
         FAILED DATA(ls_failed)
         REPORTED DATA(ls_reported).

    IF lt_result IS NOT INITIAL.
      CASE iv_explosiontype.
        WHEN lc_explodetype_1.
          LOOP AT lt_result INTO DATA(ls_result).
            ls_bomlist-material                     = iv_material.
            ls_bomlist-plant                        = iv_plant.
            ls_bomlist-billofmaterialvariantroot    = iv_billofmaterialvariant.
            ls_bomlist-headermaterial               = ls_result-%param-bomhdrmatlhiernode.
            ls_bomlist-explodebomlevelvalue         = ls_result-%param-explodebomlevelvalue.
            ls_bomlist-billofmaterialitemnumber     = ls_result-%param-billofmaterialitemnumber.
            ls_bomlist-billofmaterialitemcategory   = ls_result-%param-billofmaterialitemcategory.
            ls_bomlist-billofmaterialcomponent      = ls_result-%param-billofmaterialcomponent.
            ls_bomlist-componentdescription         = ls_result-%param-componentdescription.
            ls_bomlist-billofmaterialvariant        = ls_result-%param-billofmaterialvariant.
            ls_bomlist-alternativeitemgroup         = ls_result-%param-alternativeitemgroup.
            ls_bomlist-alternativeitempriority      = ls_result-%param-alternativeitempriority.
            ls_bomlist-alternativeitemstrategy      = ls_result-%param-alternativeitemstrategy.
            ls_bomlist-usageprobabilitypercent      = ls_result-%param-usageprobabilitypercent.
            ls_bomlist-bomitemisdiscontinued        = ls_result-%param-bomitemisdiscontinued.
            ls_bomlist-discontinuationgroup         = ls_result-%param-discontinuationgroup.
            ls_bomlist-followupgroup                = ls_result-%param-followupgroup.
            ls_bomlist-billofmaterialitemunit       = ls_result-%param-billofmaterialitemunit.
            ls_bomlist-componentquantityincompuom   = ls_result-%param-componentquantityincompuom.
            ls_bomlist-bomitemsorter                = ls_result-%param-bomitemsorter.
            ls_bomlist-ismaterialprovision          = ls_result-%param-ismaterialprovision.
*            ls_bomlist-changenumber                 = ls_result-%param-changenumber.
            ls_bomlist-bomitemtext2                 = ls_result-%param-bomitemtext2.
            ls_bomlist-bomitemdescription           = ls_result-%param-bomitemdescription.
            ls_bomlist-isbulkmaterial               = ls_result-%param-isbulkmaterial.
            ls_bomlist-bomitemiscostingrelevant     = ls_result-%param-bomitemiscostingrelevant.
            ls_bomlist-revisionlevel                = ls_result-%param-revisionlevel.
            ls_bomlist-materialgroup                = ls_result-%param-materialgroup.
            ls_bomlist-billofmaterialitembaseunit   = ls_result-%param-baseunit.
            ls_bomlist-componentquantityinbaseuom   = ls_result-%param-componentquantityinbaseuom.
            ls_bomlist-prodorderissuelocation       = ls_result-%param-prodorderissuelocation.
            ls_bomlist-billofmaterial               = ls_result-%param-billofmaterial.
            ls_bomlist-billofmaterialitemnodenumber = ls_result-%param-billofmaterialitemnodenumber.
            ls_bomlist-billofmaterialcategory       = iv_billofmaterialcategory.
            ls_bomlist-billofmaterialvariantusage   = ls_result-%param-billofmaterialvariantusage.
            APPEND ls_bomlist TO ct_bomlist.
            CLEAR ls_bomlist.
          ENDLOOP.
        WHEN lc_explodetype_2.
          IF iv_quantityinheritance = abap_true.
            LOOP AT lt_result INTO ls_result.
              ls_bomlist-material                     = iv_material.
              ls_bomlist-plant                        = iv_plant.
              ls_bomlist-billofmaterialvariantroot    = iv_billofmaterialvariant.
              ls_bomlist-headermaterial               = ls_result-%param-bomhdrmatlhiernode.
              ls_bomlist-explodebomlevelvalue         = ls_result-%param-explodebomlevelvalue.
              ls_bomlist-billofmaterialitemnumber     = ls_result-%param-billofmaterialitemnumber.
              ls_bomlist-billofmaterialitemcategory   = ls_result-%param-billofmaterialitemcategory.
              ls_bomlist-billofmaterialcomponent      = ls_result-%param-billofmaterialcomponent.
              ls_bomlist-componentdescription         = ls_result-%param-componentdescription.
              ls_bomlist-billofmaterialvariant        = ls_result-%param-billofmaterialvariant.
              ls_bomlist-alternativeitemgroup         = ls_result-%param-alternativeitemgroup.
              ls_bomlist-alternativeitempriority      = ls_result-%param-alternativeitempriority.
              ls_bomlist-alternativeitemstrategy      = ls_result-%param-alternativeitemstrategy.
              ls_bomlist-usageprobabilitypercent      = ls_result-%param-usageprobabilitypercent.
              ls_bomlist-bomitemisdiscontinued        = ls_result-%param-bomitemisdiscontinued.
              ls_bomlist-discontinuationgroup         = ls_result-%param-discontinuationgroup.
              ls_bomlist-followupgroup                = ls_result-%param-followupgroup.
              ls_bomlist-billofmaterialitemunit       = ls_result-%param-billofmaterialitemunit.
              ls_bomlist-componentquantityincompuom   = ls_result-%param-componentquantityincompuom.
              ls_bomlist-bomitemsorter                = ls_result-%param-bomitemsorter.
              ls_bomlist-ismaterialprovision          = ls_result-%param-ismaterialprovision.
*            ls_bomlist-changenumber                 = ls_result-%param-changenumber.
              ls_bomlist-bomitemtext2                 = ls_result-%param-bomitemtext2.
              ls_bomlist-bomitemdescription           = ls_result-%param-bomitemdescription.
              ls_bomlist-isbulkmaterial               = ls_result-%param-isbulkmaterial.
              ls_bomlist-bomitemiscostingrelevant     = ls_result-%param-bomitemiscostingrelevant.
              ls_bomlist-revisionlevel                = ls_result-%param-revisionlevel.
              ls_bomlist-materialgroup                = ls_result-%param-materialgroup.
              ls_bomlist-billofmaterialitembaseunit   = ls_result-%param-baseunit.
              ls_bomlist-componentquantityinbaseuom   = ls_result-%param-componentquantityinbaseuom.
              ls_bomlist-prodorderissuelocation       = ls_result-%param-prodorderissuelocation.
              ls_bomlist-billofmaterial               = ls_result-%param-billofmaterial.
              ls_bomlist-billofmaterialitemnodenumber = ls_result-%param-billofmaterialitemnodenumber.
              ls_bomlist-billofmaterialcategory       = iv_billofmaterialcategory.
              ls_bomlist-billofmaterialvariantusage   = ls_result-%param-billofmaterialvariantusage.
              APPEND ls_bomlist TO ct_bomlist.
              CLEAR ls_bomlist.
            ENDLOOP.
          ELSE.
            "Set level value of exploding BOM
            lv_explodebomlevelvalue = iv_explodebomlevelvalue + 1.

            LOOP AT lt_result INTO ls_result.
              ls_bomlist-material                     = iv_material.
              ls_bomlist-plant                        = iv_plant.
              ls_bomlist-billofmaterialvariantroot    = iv_billofmaterialvariant.
              ls_bomlist-headermaterial               = ls_result-%param-bomhdrmatlhiernode.
              ls_bomlist-explodebomlevelvalue         = lv_explodebomlevelvalue.
              ls_bomlist-billofmaterialitemnumber     = ls_result-%param-billofmaterialitemnumber.
              ls_bomlist-billofmaterialitemcategory   = ls_result-%param-billofmaterialitemcategory.
              ls_bomlist-billofmaterialcomponent      = ls_result-%param-billofmaterialcomponent.
              ls_bomlist-componentdescription         = ls_result-%param-componentdescription.
              ls_bomlist-billofmaterialvariant        = ls_result-%param-billofmaterialvariant.
              ls_bomlist-alternativeitemgroup         = ls_result-%param-alternativeitemgroup.
              ls_bomlist-alternativeitempriority      = ls_result-%param-alternativeitempriority.
              ls_bomlist-alternativeitemstrategy      = ls_result-%param-alternativeitemstrategy.
              ls_bomlist-usageprobabilitypercent      = ls_result-%param-usageprobabilitypercent.
              ls_bomlist-bomitemisdiscontinued        = ls_result-%param-bomitemisdiscontinued.
              ls_bomlist-discontinuationgroup         = ls_result-%param-discontinuationgroup.
              ls_bomlist-followupgroup                = ls_result-%param-followupgroup.
              ls_bomlist-billofmaterialitemunit       = ls_result-%param-billofmaterialitemunit.
              ls_bomlist-componentquantityincompuom   = ls_result-%param-componentquantityincompuom.
              ls_bomlist-bomitemsorter                = ls_result-%param-bomitemsorter.
              ls_bomlist-ismaterialprovision          = ls_result-%param-ismaterialprovision.
*            ls_bomlist-changenumber                 = ls_result-%param-changenumber.
              ls_bomlist-bomitemtext2                 = ls_result-%param-bomitemtext2.
              ls_bomlist-bomitemdescription           = ls_result-%param-bomitemdescription.
              ls_bomlist-isbulkmaterial               = ls_result-%param-isbulkmaterial.
              ls_bomlist-bomitemiscostingrelevant     = ls_result-%param-bomitemiscostingrelevant.
              ls_bomlist-revisionlevel                = ls_result-%param-revisionlevel.
              ls_bomlist-materialgroup                = ls_result-%param-materialgroup.
              ls_bomlist-billofmaterialitembaseunit   = ls_result-%param-baseunit.
              ls_bomlist-componentquantityinbaseuom   = ls_result-%param-componentquantityinbaseuom.
              ls_bomlist-prodorderissuelocation       = ls_result-%param-prodorderissuelocation.
              ls_bomlist-billofmaterial               = ls_result-%param-billofmaterial.
              ls_bomlist-billofmaterialitemnodenumber = ls_result-%param-billofmaterialitemnodenumber.
              ls_bomlist-billofmaterialcategory       = iv_billofmaterialcategory.
              ls_bomlist-billofmaterialvariantusage   = ls_result-%param-billofmaterialvariantusage.
              APPEND ls_bomlist TO ct_bomlist.
              CLEAR ls_bomlist.

              zcl_explodebom=>get_data(
                EXPORTING
                  iv_explosiontype               = iv_explosiontype
                  iv_plant                       = iv_plant
                  iv_material                    = iv_material
                  iv_billofmaterialcategory      = iv_billofmaterialcategory
                  iv_billofmaterialvariant       = iv_billofmaterialvariant
                  iv_bomexplosionapplication     = iv_bomexplosionapplication
                  iv_bomexplosiondate            = iv_bomexplosiondate
                  iv_headermaterial              = ls_result-%param-billofmaterialcomponent
                  iv_headerbillofmaterialvariant = lc_billofmaterialvariant_01
                  iv_requiredquantity            = iv_requiredquantity
                  iv_explodebomlevelvalue        = lv_explodebomlevelvalue
                CHANGING
                  ct_bomlist                     = ct_bomlist ).
            ENDLOOP.
          ENDIF.
        WHEN lc_explodetype_3.
          "Set level value of exploding BOM
          lv_explodebomlevelvalue = iv_explodebomlevelvalue + 1.

          LOOP AT lt_result INTO ls_result.
            ls_bomlist-material                     = iv_material.
            ls_bomlist-plant                        = iv_plant.
            ls_bomlist-billofmaterialvariantroot    = iv_billofmaterialvariant.
            ls_bomlist-headermaterial               = ls_result-%param-bomhdrmatlhiernode.
            ls_bomlist-explodebomlevelvalue         = lv_explodebomlevelvalue.
            ls_bomlist-billofmaterialitemnumber     = ls_result-%param-billofmaterialitemnumber.
            ls_bomlist-billofmaterialitemcategory   = ls_result-%param-billofmaterialitemcategory.
            ls_bomlist-billofmaterialcomponent      = ls_result-%param-billofmaterialcomponent.
            ls_bomlist-componentdescription         = ls_result-%param-componentdescription.
            ls_bomlist-billofmaterialvariant        = ls_result-%param-billofmaterialvariant.
            ls_bomlist-alternativeitemgroup         = ls_result-%param-alternativeitemgroup.
            ls_bomlist-alternativeitempriority      = ls_result-%param-alternativeitempriority.
            ls_bomlist-alternativeitemstrategy      = ls_result-%param-alternativeitemstrategy.
            ls_bomlist-usageprobabilitypercent      = ls_result-%param-usageprobabilitypercent.
            ls_bomlist-bomitemisdiscontinued        = ls_result-%param-bomitemisdiscontinued.
            ls_bomlist-discontinuationgroup         = ls_result-%param-discontinuationgroup.
            ls_bomlist-followupgroup                = ls_result-%param-followupgroup.
            ls_bomlist-billofmaterialitemunit       = ls_result-%param-billofmaterialitemunit.
            ls_bomlist-componentquantityincompuom   = ls_result-%param-componentquantityincompuom.
            ls_bomlist-bomitemsorter                = ls_result-%param-bomitemsorter.
            ls_bomlist-ismaterialprovision          = ls_result-%param-ismaterialprovision.
            ls_bomlist-bomitemtext2                 = ls_result-%param-bomitemtext2.
            ls_bomlist-bomitemdescription           = ls_result-%param-bomitemdescription.
            ls_bomlist-isbulkmaterial               = ls_result-%param-isbulkmaterial.
            ls_bomlist-bomitemiscostingrelevant     = ls_result-%param-bomitemiscostingrelevant.
            ls_bomlist-revisionlevel                = ls_result-%param-revisionlevel.
            ls_bomlist-materialgroup                = ls_result-%param-materialgroup.
            ls_bomlist-billofmaterialitembaseunit   = ls_result-%param-baseunit.
            ls_bomlist-componentquantityinbaseuom   = ls_result-%param-componentquantityinbaseuom.
            ls_bomlist-prodorderissuelocation       = ls_result-%param-prodorderissuelocation.
            ls_bomlist-billofmaterial               = ls_result-%param-billofmaterial.
            ls_bomlist-billofmaterialitemnodenumber = ls_result-%param-billofmaterialitemnodenumber.
            ls_bomlist-billofmaterialcategory       = iv_billofmaterialcategory.
            ls_bomlist-billofmaterialvariantusage   = ls_result-%param-billofmaterialvariantusage.

            ls_bomlist-bomhdrrootmatlhiernode     = ls_result-%param-bomhdrrootmatlhiernode.
            ls_bomlist-bomhdrmatlhiernode         = ls_result-%param-bomhdrmatlhiernode.
            ls_bomlist-billofmaterialversion      = ls_result-%param-billofmaterialversion.
            ls_bomlist-billofmaterialitemquantity = ls_result-%param-billofmaterialitemquantity.
            ls_bomlist-materialiscoproduct        = ls_result-%param-materialiscoproduct.
            ls_bomlist-billofmaterialroot         = ls_result-%param-billofmaterialroot.
            ls_bomlist-billofmaterialitemindex    = ls_result-%param-billofmaterialitemindex.
            APPEND ls_bomlist TO ct_bomlist.
            CLEAR ls_bomlist.

            "Component can be explode
            IF ls_result-%param-nextlevelbillofmaterial IS NOT INITIAL.
              "Obtain max variant of BOM
              SELECT MAX( a~billofmaterialvariant ) AS billofmaterialvariant
                FROM i_materialbomlink WITH PRIVILEGED ACCESS AS a
               INNER JOIN i_billofmaterialwithkeydate WITH PRIVILEGED ACCESS AS b
                  ON b~billofmaterialcategory = a~billofmaterialcategory
                 AND b~billofmaterialvariantusage = a~billofmaterialvariantusage
                 AND b~billofmaterial = a~billofmaterial
                 AND b~billofmaterialvariant = a~billofmaterialvariant
               WHERE a~billofmaterialcategory = @iv_billofmaterialcategory
                 AND a~material = @ls_result-%param-billofmaterialcomponent
                 AND a~plant = @iv_plant
                 AND a~billofmaterialvariant <= @iv_billofmaterialvariant
                 AND b~headervaliditystartdate <= @iv_bomexplosiondate
                 AND b~headervalidityenddate >= @iv_bomexplosiondate
                 INTO @DATA(lv_billofmaterialvariant).
              IF sy-subrc = 0.
                IF iv_quantityinheritance = abap_true.
                  lv_requiredquantity = ls_result-%param-componentquantityincompuom.
                ELSE.
                  lv_requiredquantity = iv_requiredquantity.
                ENDIF.

                zcl_explodebom=>get_data(
                  EXPORTING
                    iv_explosiontype               = iv_explosiontype
                    iv_plant                       = iv_plant
                    iv_material                    = iv_material
                    iv_billofmaterialcategory      = iv_billofmaterialcategory
                    iv_billofmaterialvariant       = iv_billofmaterialvariant
                    iv_bomexplosionapplication     = iv_bomexplosionapplication
                    iv_bomexplosiondate            = iv_bomexplosiondate
                    iv_headermaterial              = ls_result-%param-billofmaterialcomponent
                    iv_headerbillofmaterialvariant = lv_billofmaterialvariant
                    iv_requiredquantity            = lv_requiredquantity "ls_result-%param-componentquantityincompuom
                    iv_explodebomlevelvalue        = lv_explodebomlevelvalue
*                    iv_bomexplosionismultilevel    = iv_bomexplosionismultilevel
*                    iv_bomexplosionisalternateprio = iv_bomexplosionisalternateprio
                  CHANGING
                    ct_bomlist                     = ct_bomlist ).
              ENDIF.
            ENDIF.
          ENDLOOP.
        WHEN lc_explodetype_4.
          "Set level value of exploding BOM
          lv_explodebomlevelvalue = iv_explodebomlevelvalue + 1.

          LOOP AT lt_result INTO ls_result.
            ls_bomlist-material                     = iv_material.
            ls_bomlist-plant                        = iv_plant.
            ls_bomlist-billofmaterialvariantroot    = iv_billofmaterialvariant.
            ls_bomlist-headermaterial               = ls_result-%param-bomhdrmatlhiernode.
            ls_bomlist-explodebomlevelvalue         = lv_explodebomlevelvalue.
            ls_bomlist-billofmaterialitemnumber     = ls_result-%param-billofmaterialitemnumber.
            ls_bomlist-billofmaterialitemcategory   = ls_result-%param-billofmaterialitemcategory.
            ls_bomlist-billofmaterialcomponent      = ls_result-%param-billofmaterialcomponent.
            ls_bomlist-componentdescription         = ls_result-%param-componentdescription.
            ls_bomlist-billofmaterialvariant        = ls_result-billofmaterialvariant.
            ls_bomlist-alternativeitemgroup         = ls_result-%param-alternativeitemgroup.
            ls_bomlist-alternativeitempriority      = ls_result-%param-alternativeitempriority.
            ls_bomlist-alternativeitemstrategy      = ls_result-%param-alternativeitemstrategy.
            ls_bomlist-usageprobabilitypercent      = ls_result-%param-usageprobabilitypercent.
            ls_bomlist-bomitemisdiscontinued        = ls_result-%param-bomitemisdiscontinued.
            ls_bomlist-discontinuationgroup         = ls_result-%param-discontinuationgroup.
            ls_bomlist-followupgroup                = ls_result-%param-followupgroup.
            ls_bomlist-billofmaterialitemunit       = ls_result-%param-billofmaterialitemunit.
            ls_bomlist-componentquantityincompuom   = ls_result-%param-componentquantityincompuom.
            ls_bomlist-bomitemsorter                = ls_result-%param-bomitemsorter.
            ls_bomlist-ismaterialprovision          = ls_result-%param-ismaterialprovision.
            ls_bomlist-bomitemtext2                 = ls_result-%param-bomitemtext2.
            ls_bomlist-bomitemdescription           = ls_result-%param-bomitemdescription.
            ls_bomlist-isbulkmaterial               = ls_result-%param-isbulkmaterial.
            ls_bomlist-bomitemiscostingrelevant     = ls_result-%param-bomitemiscostingrelevant.
            ls_bomlist-revisionlevel                = ls_result-%param-revisionlevel.
            ls_bomlist-materialgroup                = ls_result-%param-materialgroup.
            ls_bomlist-billofmaterialitembaseunit   = ls_result-%param-baseunit.
            ls_bomlist-componentquantityinbaseuom   = ls_result-%param-componentquantityinbaseuom.
            ls_bomlist-prodorderissuelocation       = ls_result-%param-prodorderissuelocation.
            ls_bomlist-billofmaterial               = ls_result-%param-billofmaterial.
            ls_bomlist-billofmaterialitemnodenumber = ls_result-%param-billofmaterialitemnodenumber.
            ls_bomlist-billofmaterialcategory       = iv_billofmaterialcategory.
            ls_bomlist-billofmaterialvariantusage   = ls_result-%param-billofmaterialvariantusage.
            APPEND ls_bomlist TO ct_bomlist.
            CLEAR ls_bomlist.

            "Component can be explode
            IF ls_result-%param-nextlevelbillofmaterial IS NOT INITIAL.
              "Obtain max variant of BOM
              SELECT a~billofmaterialvariant
                FROM i_materialbomlink WITH PRIVILEGED ACCESS AS a
               INNER JOIN i_billofmaterialwithkeydate WITH PRIVILEGED ACCESS AS b
                  ON b~billofmaterialcategory = a~billofmaterialcategory
                 AND b~billofmaterialvariantusage = a~billofmaterialvariantusage
                 AND b~billofmaterial = a~billofmaterial
                 AND b~billofmaterialvariant = a~billofmaterialvariant
               WHERE a~billofmaterialcategory = @iv_billofmaterialcategory
                 AND a~material = @ls_result-%param-billofmaterialcomponent
                 AND a~plant = @iv_plant
                 AND b~headervaliditystartdate <= @iv_bomexplosiondate
                 AND b~headervalidityenddate >= @iv_bomexplosiondate
                 INTO TABLE @DATA(lt_materialbomlink).
              IF sy-subrc = 0.
                LOOP AT lt_materialbomlink INTO DATA(ls_materialbomlink).
                  zcl_explodebom=>get_data(
                    EXPORTING
                      iv_explosiontype               = iv_explosiontype
                      iv_plant                       = iv_plant
                      iv_material                    = ls_result-%param-billofmaterialcomponent "iv_material
                      iv_billofmaterialcategory      = iv_billofmaterialcategory
*                      iv_billofmaterialvariant       = iv_billofmaterialvariant
                      iv_bomexplosionapplication     = iv_bomexplosionapplication
                      iv_bomexplosiondate            = iv_bomexplosiondate
                      iv_headermaterial              = ls_result-%param-billofmaterialcomponent
                      iv_headerbillofmaterialvariant = ls_materialbomlink-billofmaterialvariant
                      iv_requiredquantity            = iv_requiredquantity
                      iv_explodebomlevelvalue        = lv_explodebomlevelvalue
                    CHANGING
                      ct_bomlist                     = lt_bomlist ).
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDLOOP.

*          APPEND LINES OF lt_bomlist TO ct_bomlist.
          LOOP AT lt_bomlist INTO ls_bomlist.
            ls_bomlist-material = iv_material.
            APPEND ls_bomlist TO ct_bomlist.
          ENDLOOP.
      ENDCASE.
    ENDIF.

    CLEAR lt_result.
  ENDMETHOD.
ENDCLASS.
