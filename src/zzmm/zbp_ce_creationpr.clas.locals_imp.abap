CLASS lhc_purchasingreq DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES lty_purchasereq TYPE TABLE of zce_creationpr.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR purchasereq RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE purchasereq.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE purchasereq.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE purchasereq.

    METHODS read FOR READ
      IMPORTING keys FOR READ purchasereq RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK purchasereq.

    METHODS createpr FOR MODIFY
      IMPORTING keys FOR ACTION purchasereq~createpr RESULT result.

    METHODS check CHANGING records TYPE lty_purchasereq.
    METHODS excute CHANGING records TYPE lty_purchasereq.

ENDCLASS.

CLASS lhc_purchasingreq IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD createPR.
    data lt_purchasing_req type TABLE of zce_creationpr.
    CHECK keys is not INITIAL.

    data(lv_event) = keys[ 1 ]-%param-event.

    LOOP AT keys INTO data(key).
      clear lt_purchasing_req.
      /ui2/cl_json=>deserialize( EXPORTING json = key-%param-zzkey
                                 CHANGING  data = lt_purchasing_req ).

      CASE lv_event.
        WHEN 'CHECK'.
        WHEN 'EXCUTE'.

        WHEN 'EXPORT'.
          " TODO 如果有导出源文件的需求那么可以在上传数据时将文件保存，并在此处读取源文件 by zoukun
          "SELECT SINGLE templatecontent FROM zzc_dtimp_conf WHERE object = 'ZUPLOAD_BOM' INTO @DATA(lv_file).
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check.
    " TODO 对采购申请数据的检查
  ENDMETHOD.

  METHOD excute.
    data:
      purchaserequisition TYPE TABLE FOR CREATE I_PURCHASEREQUISITIONTP.
    LOOP AT records REFERENCE INTO data(record).

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zce_creationpr DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zce_creationpr IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
