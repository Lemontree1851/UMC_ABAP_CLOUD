CLASS zcl_tf_batchcreationdn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb .

    CLASS-METHODS:
      get_storloc
        FOR TABLE FUNCTION ztf_salesorderstorloc.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_tf_batchcreationdn IMPLEMENTATION.


  METHOD get_storloc
    BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY
    USING zr_tsd_1001 zr_salesorderbasic ztbc_1001.
    lt_table =
      select
        mandt,
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
          mandt AS client,
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
          -- 判定三个条件是否取到值(sd1001a) customer billingtoparty plant
            CASE when sd1001a.customer is not null
              then
                case
                  when basic.yy1_salesdoctype_sdh = ''
                    then sd1001a.finishedstoragelocation
                  when ( select count( * ) from ztbc_1001 where zid = 'ZSD013' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then sd1001a.finishedstoragelocation
                  when ( select count( * ) from ztbc_1001 where zid = 'ZSD014' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then case when sd1001a.vmistoragelocation = '' THEN sd1001a.partsstoragelocation else sd1001a.vmistoragelocation end
                  when ( select count( * ) from ztbc_1001 where zid = 'ZSD015' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then sd1001a.repairstoragelocation
                  when ( select count( * ) from ztbc_1001 where zid = 'ZSD016' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then sd1001a.returnstoragelocation
                end
             -- 如果三个条件没有取到值就将billingtoparty固定为空(sd1001b)
              ELSE
                case
                  when basic.yy1_salesdoctype_sdh = ''
                    then sd1001b.finishedstoragelocation
                  when ( select count( * ) from ztbc_1001 where zid = 'ZSD013' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then sd1001b.finishedstoragelocation
                  when ( select count( * ) from ztbc_1001 where zid = 'ZSD014' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then case when sd1001b.vmistoragelocation = '' THEN sd1001b.partsstoragelocation else sd1001b.vmistoragelocation end
                  when ( select count( * ) from ztbc_1001 where zid = 'ZSD015' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then sd1001b.repairstoragelocation
                  when ( select count( * ) from ztbc_1001 where zid = 'ZSD016' and zvalue1 = basic.yy1_salesdoctype_sdh ) > 1
                    then sd1001b.returnstoragelocation
                end
            end
          end as storagelocation
      from zr_salesorderbasic as basic
      left outer join zr_tsd_1001              as sd1001a  on  sd1001a.customer       = basic.soldtoparty
                                                           and sd1001a.billingtoparty = basic.billingtoparty
                                                           and sd1001a.plant          = basic.plant
      left outer join :lt_table_without_billto as sd1001b  on  sd1001b.customer = basic.soldtoparty
                                                           and sd1001a.billingtoparty = ''
                                                           and sd1001b.plant    = basic.plant;

  endmethod.
ENDCLASS.
