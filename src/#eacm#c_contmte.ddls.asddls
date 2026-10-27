@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Posted Commission Accrual'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity /EACM/C_CONTMTE
  provider contract transactional_query
  as projection on /EACM/I_CONTMTE
  association [1..1] to /EACM/I_CONTMTE as _BaseEntity on $projection.CompanyCode = _BaseEntity.CompanyCode and $projection.SalesOrganization = _BaseEntity.SalesOrganization and $projection.DistributionChannel = _BaseEntity.DistributionChannel and $projection.CommissionClass = _BaseEntity.CommissionClass and $projection.BillingDocument = _BaseEntity.BillingDocument and $projection.BillingDocumentItem = _BaseEntity.BillingDocumentItem and $projection.Agent = _BaseEntity.Agent and $projection.AgentProgressive = _BaseEntity.AgentProgressive and $projection.FacsimileProgressive = _BaseEntity.FacsimileProgressive and $projection.FacsimilePeriod = _BaseEntity.FacsimilePeriod
{
  @EndUserText: {
    label: 'Company Code', 
    quickInfo: 'Company Code'
  }
  key CompanyCode,
  @EndUserText: {
    label: 'Sales Organization', 
    quickInfo: 'Sales Organization'
  }
  key SalesOrganization,
  @EndUserText: {
    label: 'Distribution Channel', 
    quickInfo: 'Distribution Channel'
  }
  key DistributionChannel,
  @EndUserText: {
    label: 'Cod.class.comm.', 
    quickInfo: 'Code classification commissions'
  }
  key CommissionClass,
  @EndUserText: {
    label: 'SD Document', 
    quickInfo: 'Sales and Distribution Document Number'
  }
  key BillingDocument,
  @EndUserText: {
    label: 'Item (SD)', 
    quickInfo: 'Item number of the SD document'
  }
  key BillingDocumentItem,
  @EndUserText: {
    label: 'Agent Code', 
    quickInfo: 'Agent Code'
  }
  key Agent,
  @EndUserText: {
    label: 'Prog.n.agent', 
    quickInfo: 'Progressive number agent'
  }
  key AgentProgressive,
  @EndUserText: {
    label: 'Facsimile number', 
    quickInfo: 'Facsimile number'
  }
  key FacsimileProgressive,
  @EndUserText: {
    label: 'YYYYMM competence', 
    quickInfo: 'YYYYMM competence facsimile'
  }
  key FacsimilePeriod,
  @EndUserText: {
    label: 'Record state', 
    quickInfo: 'Record state'
  }
  ProcessingStatus,
  @EndUserText: {
    label: 'Dt fac-sim print', 
    quickInfo: 'Date of fac-simile print'
  }
  FacsimileSettlementDate,
  @EndUserText: {
    label: 'Posting Date', 
    quickInfo: 'Posting Date in the Document'
  }
  PostingDate,
  @EndUserText: {
    label: 'Document Date', 
    quickInfo: 'Document Date in Document'
  }
  MteDocumentDate,
  @EndUserText: {
    label: 'Document Date', 
    quickInfo: 'Document Date in Document'
  }
  BillingDocumentDate,
  @EndUserText: {
    label: 'Agent type code', 
    quickInfo: 'Agent type code'
  }
  AgentPaymentType,
  @EndUserText: {
    label: 'SD document categ.', 
    quickInfo: 'SD document category'
  }
  SalesDocumentCategory,
  @EndUserText: {
    label: 'Exchange Rate Factor', 
    quickInfo: 'Exchange Rate Factor'
  }
  ExchangeRate,
  @EndUserText: {
    label: 'Currency', 
    quickInfo: 'Currency Key'
  }
  TransactionCurrency,
  @EndUserText: {
    label: 'Currency', 
    quickInfo: 'Currency Key'
  }
  CompanyCurrency,
  @EndUserText: {
    label: 'Amount document (£)', 
    quickInfo: 'Amount document in £'
  }
  @Semantics: {
    amount.currencyCode: 'TransactionCurrency'
  }
  BillingNetAmount,
  @EndUserText: {
    label: 'Max date', 
    quickInfo: 'Date time limit maximum'
  }
  PaymentDueDate,
  @EndUserText: {
    label: 'Tax.comm.', 
    quickInfo: 'Taxable commission'
  }
  @Semantics: {
    amount.currencyCode: 'TransactionCurrency'
  }
  PayableCommissionAmount,
  @EndUserText: {
    label: 'Perc. commiss.', 
    quickInfo: 'Percentage commission'
  }
  CommissionPercentage,
  @EndUserText: {
    label: 'Cod.class.comm.', 
    quickInfo: 'Code classification commissions'
  }
  SourceCommissionClass,
  @EndUserText: {
    label: 'Comm.amount', 
    quickInfo: 'Commission amount'
  }
  @Semantics: {
    amount.currencyCode: 'TransactionCurrency'
  }
  AccruedCommissionAmount,
  @EndUserText: {
    label: 'Date agent invoice', 
    quickInfo: 'Date of agent invoice'
  }
  AgentInvoiceDate,
  @EndUserText: {
    label: 'N.invoice ag.', 
    quickInfo: 'Number invoice agent'
  }
  AgentInvoiceNumber,
  @EndUserText: {
    label: 'Ex.invoice ag.', 
    quickInfo: 'Exercise invoice agent'
  }
  AgentInvoiceFiscalYear,
  @EndUserText: {
    label: 'dt acc ref ag inv', 
    quickInfo: 'date of accounting reference agent invoice'
  }
  AgentInvoiceRegistrationDate,
  @EndUserText: {
    label: 'Sign document', 
    quickInfo: 'Sign of the document'
  }
  DocumentSign,
  @Semantics: {
    amount.currencyCode: 'TransactionCurrency'
  }
  AccruedCommissionSigned,
  @EndUserText: {
    label: 'Posted Today', 
    quickInfo: 'Contabilizzato oggi - boolean'
  }
  IsToday,
  _BaseEntity
}
