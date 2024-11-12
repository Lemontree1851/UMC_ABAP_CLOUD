class ZCL_HTTP_STORAGELOCATION_001 definition
  public
  create public .

public section.

*   export parameters
    TYPES:
          BEGIN OF ty_response,
            Plant                                     TYPE c  LENGTH 4	 ,       "プラント			
            StorageLocation                           TYPE c  LENGTH 4	 ,       "保管場所	
            StorageLocationName                       TYPE c  LENGTH 16	 ,       "保管場所名			
            SalesOrganization                         TYPE c  LENGTH 4	 ,       "販売組織			
            DistributionChannel                       TYPE c  LENGTH 2	 ,       "流通チャネル			
            Division                                  TYPE c  LENGTH 2	 ,       "製品部門			
            IsStorLocAuthznCheckActive                TYPE c  LENGTH 1	 ,       "権限チェック			
            HandlingUnitIsRequired                    TYPE c  LENGTH 1	 ,       "HU 必須			
            ConfigDeprecationCode                     TYPE c  LENGTH 1	 ,       "有効性			

          END OF ty_response.

*   input parameters
    TYPES:
      BEGIN OF ty_inputs,
        Plant(4) TYPE c,
      END OF ty_inputs,

      BEGIN OF ty_output,
        items TYPE STANDARD TABLE OF ty_response WITH EMPTY KEY,
      END OF ty_output.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.
        DATA:
          LT_INPUT TYPE STANDARD TABLE OF ty_inputs,
          lv_error(1)       TYPE c,
          lv_text           TYPE string,
          ls_response       TYPE ty_response,
          es_response       TYPE ty_output,
          lc_header_content TYPE string VALUE 'content-type',
          lc_content_type   TYPE string VALUE 'text/json'.
        DATA:
          lv_temp(14)   TYPE c,
          lv_PurchaseOrder   TYPE c LENGTH 10.
ENDCLASS.



CLASS ZCL_HTTP_STORAGELOCATION_001 IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

    DATA(lv_req_body) = request->get_text( ).
    DATA(lv_header) = request->get_header_field( i_name = 'form' ).

    if lv_header = 'XML'.

    else.
    "处理JSON请求体
    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_pascal_case )
    ) )->write_to( REF #( lt_INPUT ) ).
    ENDIF.

    SELECT *
    FROM I_StorageLocation WITH PRIVILEGED ACCESS
    FOR ALL ENTRIES IN @lt_input
    WHERE plant = @lt_input-PLANT
    INTO TABLE @DATA(lt_storage).

    IF LT_STORAGE IS NOT INITIAL.
      LOOP AT LT_STORAGE INTO DATA(LW_STORAGE).
        ls_response-Plant                      =   LW_STORAGE-Plant                                .
        ls_response-StorageLocation            =   LW_STORAGE-StorageLocation                      .
        ls_response-StorageLocationName        =   LW_STORAGE-StorageLocationName                  .
        ls_response-SalesOrganization          =   LW_STORAGE-SalesOrganization                    .
        ls_response-DistributionChannel        =   LW_STORAGE-DistributionChannel                  .
        ls_response-Division                   =   LW_STORAGE-Division                             .
        ls_response-IsStorLocAuthznCheckActive =   LW_STORAGE-IsStorLocAuthznCheckActive           .
        ls_response-HandlingUnitIsRequired     =   LW_STORAGE-HandlingUnitIsRequired               .
        ls_response-ConfigDeprecationCode      =   LW_STORAGE-ConfigDeprecationCode                .

        CONDENSE ls_response-Plant                                                                 .
        CONDENSE ls_response-StorageLocation                                                       .
        CONDENSE ls_response-StorageLocationName                                                   .
        CONDENSE ls_response-SalesOrganization                                                     .
        CONDENSE ls_response-DistributionChannel                                                   .
        CONDENSE ls_response-Division                                                              .
        CONDENSE ls_response-IsStorLocAuthznCheckActive                                            .
        CONDENSE ls_response-HandlingUnitIsRequired                                                .
        CONDENSE ls_response-ConfigDeprecationCode                                                 .

        APPEND ls_response TO es_response-items.
        CLEAR ls_response.
      ENDLOOP.

    ELSE.
        lv_error = 'X'.
        lv_text = 'storagelocation not found'.
    ENDIF.

    IF lv_error IS NOT INITIAL.
      "propagate any errors raised
      response->set_status( '500' )."500
      response->set_text( lv_text ).
    ELSE.


      "respond with success payload
      response->set_status( '200' ).

      DATA(lv_json_string) = xco_cp_json=>data->from_abap( es_response )->apply( VALUE #(
      ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->to_string( ).
      response->set_text( lv_json_string ).
      response->set_header_field( i_name  = lc_header_content
                                  i_value = lc_content_type ).

    ENDIF.
  endmethod.
ENDCLASS.
