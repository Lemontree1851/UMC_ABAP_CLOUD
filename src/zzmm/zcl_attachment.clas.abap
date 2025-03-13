 CLASS zcl_attachment DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

   PUBLIC SECTION.
     INTERFACES if_sadl_exit_calc_element_read.
   PROTECTED SECTION.
   PRIVATE SECTION.
 ENDCLASS.



 CLASS zcl_attachment IMPLEMENTATION.


   METHOD if_sadl_exit_calc_element_read~calculate.





     TYPES:
       BEGIN OF ty_results,
         archivedocumentid TYPE string,
       END OF ty_results,
       tt_results TYPE STANDARD TABLE OF ty_results WITH DEFAULT KEY,
       BEGIN OF ty_d,
         results TYPE tt_results,
       END OF ty_d,
       BEGIN OF ty_res_api,
         d TYPE ty_d,
       END OF ty_res_api.

     DATA:lv_path     TYPE string.
     DATA:ls_res_api  TYPE ty_res_api.

     DATA:lt_original_data TYPE STANDARD TABLE OF zr_prworkflowitem WITH DEFAULT KEY.
     lt_original_data = CORRESPONDING #( it_original_data ).
     LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).

*&--MOD BEGIN BY XINLEI XU 2025/03/07
*       DATA:lv_no TYPE string.
*       lv_no =  <fs_original_data>-prno &&  <fs_original_data>-pritem &&  <fs_original_data>-uuid+11(5).
*
*       lv_path = |/API_CV_ATTACHMENT_SRV/A_DocumentInfoRecordAttch(DocumentInfoRecordDocType='SAT',DocumentInfoRecordDocNumber='{ lv_no }',DocumentInfoRecordDocVersion='00',DocumentInfoRecordDocPart='000')/DocumentInfoRecordToAttachmentNavigation|.
*       "Call API
*       zzcl_common_utils=>request_api_v2(
*         EXPORTING
*           iv_path        = lv_path
*           iv_method      = if_web_http_client=>get
*           iv_format      = 'json'
*         IMPORTING
*           ev_status_code = DATA(lv_stat_code)
*           ev_response    = DATA(lv_resbody_api) ).
*
*
*       "JSON->ABAP
*       xco_cp_json=>data->from_string( lv_resbody_api )->apply( VALUE #(
*           ( xco_cp_json=>transformation->underscore_to_camel_case ) ) )->write_to( REF #( ls_res_api ) ).
*
*       IF ls_res_api-d-results IS NOT INITIAL.
*         <fs_original_data>-zattachment = 'あり'.
*       ELSE.
*         <fs_original_data>-zattachment = 'なし'.
*       ENDIF.
*
*       CLEAR ls_res_api.

       SELECT SINGLE pr_uuid, file_uuid
         FROM ztmm_1012
        WHERE pr_uuid = @<fs_original_data>-uuid
         INTO @DATA(ls_attachment).
       IF sy-subrc = 0.
         <fs_original_data>-zattachment = 'あり'.
       ELSE.
         <fs_original_data>-zattachment = 'なし'.
       ENDIF.
*&--MOD END BY XINLEI XU 2025/03/07
     ENDLOOP.

     ct_calculated_data = CORRESPONDING #(  lt_original_data ).
   ENDMETHOD.


   METHOD if_sadl_exit_calc_element_read~get_calculation_info.
     LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
       CASE <fs_calc_element>.
         WHEN 'ZATTACHMENT'.
           INSERT `PRNO` INTO TABLE et_requested_orig_elements.
           INSERT `PRITEM` INTO TABLE et_requested_orig_elements.
           INSERT `UUID` INTO TABLE et_requested_orig_elements.

       ENDCASE.
     ENDLOOP.
   ENDMETHOD.
 ENDCLASS.
