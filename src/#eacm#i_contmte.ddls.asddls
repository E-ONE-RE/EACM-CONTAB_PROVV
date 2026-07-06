@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maturate Contabilizzate'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /EACM/I_CONTMTE
  as select from /eacm/zprdp as Mte
    left outer to one join /eacm/prdo as Prdo
      on  Prdo.vkorg = Mte.vkorg
      and Prdo.vtweg = Mte.vtweg
      and Prdo.zclpr = Mte.zclpr
      and Prdo.vbeln = Mte.vbeln
      and Prdo.posnr = Mte.posnr
      and Prdo.zcdaz = Mte.zcdaz
      and Prdo.zidag = Mte.zidag
    left outer to one join /eacm/zpr48 as DocSign
      on DocSign.vbtyp = Prdo.vbtyp
{
  key Mte.bukrs as CompanyCode,
  key Mte.vkorg as SalesOrganization,
  key Mte.vtweg as DistributionChannel,
  key Mte.zclpr as CommissionClass,
  key Mte.vbeln as BillingDocument,
  key Mte.posnr as BillingDocumentItem,
  key Mte.zcdaz as Agent,
  key Mte.zidag as AgentProgressive,
  key Mte.zidfs as FacsimileProgressive,
  key Mte.zamcf as FacsimilePeriod,

      Mte.zstre as ProcessingStatus,
      Mte.zdtsf as FacsimileSettlementDate,
      Mte.budat as PostingDate,
      Mte.bldat as MteDocumentDate,
      Prdo.bldat as BillingDocumentDate,
      Prdo.ztpag as AgentPaymentType,
      Prdo.vbtyp as SalesDocumentCategory,
      Prdo.kurrf as ExchangeRate,

      Mte.zwaer as TransactionCurrency,
      Mte.waerk as CompanyCurrency,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Prdo.zimlr as BillingNetAmount,

      Prdo.zutmx as PaymentDueDate,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Prdo.zimpp as PayableCommissionAmount,

      Prdo.zpcpr as CommissionPercentage,
      Prdo.zclpr as SourceCommissionClass,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Mte.ziprv as AccruedCommissionAmount,

      Mte.zdtfa as AgentInvoiceDate,
      Mte.znrfa as AgentInvoiceNumber,
      Mte.zesfa as AgentInvoiceFiscalYear,
      Mte.zdrfa as AgentInvoiceRegistrationDate,

      case
        when DocSign.zsegn is null or DocSign.zsegn = ''
          then '1'
        else DocSign.zsegn
      end as DocumentSign,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case
        when DocSign.zsegn = '-1'
          then Mte.ziprv * -1
        else Mte.ziprv
      end as AccruedCommissionSigned,

      cast(
        case
          when Mte.budat = $session.system_date
          then 'X'
          else ''
        end
        as /eacm/istoday
      ) as IsToday
}
where
      Mte.zdtsf <> '00000000'
  and Mte.zstre = 'C';
