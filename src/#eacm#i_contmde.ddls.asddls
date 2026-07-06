@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stanziamenti provvigioni agenti'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /EACM/I_CONTMDE 
  as select from /eacm/prdo as Prdo
    inner join /eacm/zpr02 as PayType
      on PayType.ztpag = Prdo.ztpag
    left outer to one join /eacm/zpr48 as DocSign
      on DocSign.vbtyp = Prdo.vbtyp
{
  key Prdo.bukrs as CompanyCode,
  key Prdo.vkorg as SalesOrganization,
  key Prdo.vtweg as DistributionChannel,
  key Prdo.zclpr as CommissionClass,
  key Prdo.vbeln as BillingDocument,
  key Prdo.posnr as BillingDocumentItem,
  key Prdo.zcdaz as Agent,
  key Prdo.zidag as AgentProgressive,

      Prdo.bldat as BillingDocumentDate,
      Prdo.budat as PostingDate,
      Prdo.ztpag as AgentPaymentType,
      Prdo.vbtyp as SalesDocumentCategory,
      Prdo.kurrf as ExchangeRate,

//      @Semantics.currencyCode: true
      Prdo.waerk as CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      Prdo.zimst as AccrualAmountOriginal,

      case
        when DocSign.zsegn is null or DocSign.zsegn = ''
          then '1'
        else DocSign.zsegn
      end as DocumentSign,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      case
        when DocSign.zsegn = '-1'
          then Prdo.zimst * -1
        else Prdo.zimst
      end as AccrualAmountSigned,
      

      cast(
          case
            when Prdo.budat = $session.system_date
            then 'X'
            else ''
          end
          as /eacm/istoday
        ) as IsToday
 
}
where
      Prdo.zimst <> 0
  and Prdo.zstre <> 'D'
  and PayType.zstpm = 'X'
//  già contabilizzate
  and Prdo.budat <> '00000000'
  and Prdo.zimst <> 0;

