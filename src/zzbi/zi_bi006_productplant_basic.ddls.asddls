@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI006 Product Plant Basic'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI006_PRODUCTPLANT_BASIC 
  as select from    I_ProductPlantBasic

    left outer join I_Plant            as _Plant            on _Plant.Plant = I_ProductPlantBasic.Plant
    left outer join I_ValuationArea    as _ValuationArea    on _Plant.ValuationArea = _ValuationArea.ValuationArea
    left outer join I_CompanyCode      as _CompanyCode      on _CompanyCode.CompanyCode = _ValuationArea.CompanyCode
    left outer join I_ProfitCenterText as _ProfitCenterText on  _ProfitCenterText.ProfitCenter      = I_ProductPlantBasic.ProfitCenter
                                                            and _ProfitCenterText.Language          = $session.system_language
                                                            and _ProfitCenterText.ControllingArea   = _CompanyCode.ControllingArea
                                                            and _ProfitCenterText.ValidityStartDate <= $session.system_date
                                                            and _ProfitCenterText.ValidityEndDate   >= $session.system_date                                                     
   association [0..1] to ZI_BI006_PRODUCT_CUSTOMER as _BusinessPartner on _BusinessPartner.SearchTerm2 = $projection.searchterm  
                                                    
{
  key    I_ProductPlantBasic.Product,
  key    I_ProductPlantBasic.Plant, 
         I_ProductPlantBasic.ProfitCenter,
         _ProfitCenterText.ProfitCenterName,
         _Plant.ValuationArea,
         case when I_ProductPlantBasic.MRPResponsible <> '' and length( I_ProductPlantBasic.MRPResponsible ) >=2
         then substring(I_ProductPlantBasic.MRPResponsible, length( I_ProductPlantBasic.MRPResponsible ) - 1 ,2 )
         else ''
         end as searchterm, 
         
         _CompanyCode.Currency,
         
         _BusinessPartner
}
