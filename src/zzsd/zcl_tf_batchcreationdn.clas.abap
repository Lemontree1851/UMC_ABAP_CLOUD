CLASS zcl_tf_batchcreationdn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb .

    CLASS-METHODS:
      get_storloc
        FOR TABLE FUNCTION ztf_salesorderstorloc .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_tf_batchcreationdn IMPLEMENTATION.


  METHOD get_storloc
    BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY
    USING zr_tsd_1001 zr_salesorderbasic zr_tbc1001.
    lt_table =
      select
        Customer,
        billingtoparty,
        plant,
        partsstoragelocation,
        finishedstoragelocation,
        returnstoragelocation,
        repairstoragelocation,
        vmistoragelocation,
        ROW_NUMBER ( ) OVER (PARTITION BY Customer,plant) as rownumber
      FROM zr_tsd_1001
      WHERE zr_tsd_1001.mandt = :clnt;

      lt_table_without_billto =
        SELECT
          customer,
          plant,
          partsstoragelocation,
          finishedstoragelocation,
          returnstoragelocation,
          repairstoragelocation,
          vmistoragelocation
        FROM :lt_table
        WHERE rownumber = 1;

    RETURN
      select
        basic.mandt as client,
        basic.salesdocument,
        basic.salesdocumentitem,
        case when basic.storagelocation <> ''
          then basic.storagelocation
          else
          -- Determine whether the three conditions have taken values(sd1001a) customer billingtoparty plant
            CASE when sd1001a.customer is not null
              then
                case
                  when ( select count( * ) from zr_tbc1001 where zid = 'ZSD016' and zvalue1 = basic.salesdocumenttype ) > 1
                    then sd1001a.returnstoragelocation
                  when basic.yy1_salesdoctype_sdh = ''
                    then sd1001a.finishedstoragelocation
                  when ( select count( * ) from zr_tbc1001 where zid = 'ZSD013' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then sd1001a.finishedstoragelocation
                  when ( select count( * ) from zr_tbc1001 where zid = 'ZSD014' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then case when sd1001a.vmistoragelocation = '' THEN sd1001a.partsstoragelocation else sd1001a.vmistoragelocation end
                  when ( select count( * ) from zr_tbc1001 where zid = 'ZSD015' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then sd1001a.repairstoragelocation
                end
             -- if the three conditions do not take a value, fix billingtoparty as empty(sd1001b)
              else
                case
                  when ( select count( * ) from zr_tbc1001 where zid = 'ZSD016' and zvalue1 = basic.salesdocumenttype ) > 1
                    then sd1001b.returnstoragelocation
                  when basic.yy1_salesdoctype_sdh = ''
                    then sd1001b.finishedstoragelocation
                  when ( select count( * ) from zr_tbc1001 where zid = 'ZSD013' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then sd1001b.finishedstoragelocation
                  when ( select count( * ) from zr_tbc1001 where zid = 'ZSD014' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then case when sd1001b.vmistoragelocation = '' THEN sd1001b.partsstoragelocation else sd1001b.vmistoragelocation end
                  when ( select count( * ) from zr_tbc1001 where zid = 'ZSD015' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then sd1001b.repairstoragelocation
                end
            end
          end as storagelocation
      from zr_salesorderbasic as basic
      left outer join zr_tsd_1001              as sd1001a  on  sd1001a.customer       = basic.soldtoparty
                                                           and sd1001a.billingtoparty = basic.billingtoparty
                                                           and sd1001a.plant          = basic.plant
                                                           and sd1001a.mandt = :clnt
      left outer join zr_tsd_1001              as sd1001b  ON  sd1001b.customer = basic.soldtoparty
                                                           and sd1001b.billingtoparty = ''
                                                           and sd1001b.plant    = basic.plant
                                                           and sd1001b.mandt = :clnt
      where basic.mandt = :clnt;

  ENDMETHOD.
ENDCLASS.
