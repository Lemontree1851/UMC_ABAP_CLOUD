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



CLASS ZCL_TF_BATCHCREATIONDN IMPLEMENTATION.


  METHOD get_storloc
    BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY
    USING zr_tsd_1001 zr_salesorderbasic.
    lt_table =
      select
        mandt,
        Customer,
        billingtoparty,
        plant,
        issuestoragelocation,
        finishedstoragelocation,
        returnstoragelocation,
        repairstoragelocation,
        vimstoragelocation,
        ROW_NUMBER ( ) OVER (PARTITION BY Customer,plant) as rownumber
      FROM zr_tsd_1001
      WHERE zr_tsd_1001.mandt = :clnt;

      lt_table_without_billto =
        SELECT
          mandt AS client,
          customer,
          plant,
          issuestoragelocation,
          finishedstoragelocation,
          returnstoragelocation,
          repairstoragelocation,
          vimstoragelocation
        FROM :lt_table
        WHERE rownumber = 1;

    RETURN
      select
        basic.mandt as client,
        basic.salesorder,
        basic.salesorderitem,
        -- 判定三个条件是否取到值
        case when sd1001a.customer is not null
          then
            case when basic.deliverytype = 'DN-2'
              then
                CASE when sd1001a.vimstoragelocation <> ''
                  then sd1001a.vimstoragelocation
                  else sd1001a.finishedstoragelocation
                end
              else
                case
                  when basic.salesordertype = 'SO-2' and sd1001a.issuestoragelocation <> ''
                    then sd1001a.issuestoragelocation
                  -- 发货国内、发货国外、转厂交货 为 成品仓
                  when basic.deliverytype = 'DN-1' and sd1001a.finishedstoragelocation <> ''
                    then sd1001a.finishedstoragelocation
                  -- 国内退货、国外退货 为 返品仓
                  when ( basic.deliverytype = 'DN-4' or basic.deliverytype = 'DN-8' ) and sd1001a.returnstoragelocation <> ''
                    then sd1001a.returnstoragelocation
                  -- 返修品发货 为 返修品发货仓
                  when ( basic.deliverytype = 'DN-7' or basic.deliverytype = 'DN-F' ) and sd1001a.repairstoragelocation <> ''
                    then sd1001a.repairstoragelocation
                  else ''
                end
            end
         -- 如果三个条件没有取到值就用两个条件取值
          else
            case when basic.deliverytype = 'DN-2'
              then
                CASE when sd1001b.vimstoragelocation <> ''
                  then sd1001b.vimstoragelocation
                  else sd1001b.finishedstoragelocation
                end
              else
                case
                  when basic.salesordertype = 'SO-2' and sd1001b.issuestoragelocation <> ''
                    then sd1001b.issuestoragelocation
                  -- 发货国内、发货国外、转厂交货 为 成品仓
                  when basic.deliverytype = 'DN-1' and sd1001b.finishedstoragelocation <> ''
                    then sd1001b.finishedstoragelocation
                  -- 国内退货、国外退货 为 返品仓
                  when ( basic.deliverytype = 'DN-4' or basic.deliverytype = 'DN-8' ) and sd1001b.returnstoragelocation <> ''
                    then sd1001b.returnstoragelocation
                  -- 返修品发货 为 返修品发货仓
                  when ( basic.deliverytype = 'DN-7' or basic.deliverytype = 'DN-F' ) and sd1001b.repairstoragelocation <> ''
                    then sd1001b.repairstoragelocation
                  else ''
                end
            end
        end as storagelocation
      from zr_salesorderbasic as basic
      left outer join zr_tsd_1001              as sd1001a  on  sd1001a.customer       = basic.soldtoparty
                                                           and sd1001a.billingtoparty = basic.billingtoparty
                                                           and sd1001a.plant          = basic.plant
      left outer join :lt_table_without_billto as sd1001b  on  sd1001b.customer = basic.soldtoparty
                                                           and sd1001b.plant    = basic.plant;

  endmethod.
ENDCLASS.
