@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: 'Maturate Contabilizzate'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity /EACM/C_CONTMTE
  provider contract TRANSACTIONAL_QUERY
  as projection on /EACM/I_CONTMTE
  association [1..1] to /EACM/I_CONTMTE as _BaseEntity on $projection.COMPANYCODE = _BaseEntity.COMPANYCODE and $projection.SALESORGANIZATION = _BaseEntity.SALESORGANIZATION and $projection.DISTRIBUTIONCHANNEL = _BaseEntity.DISTRIBUTIONCHANNEL and $projection.COMMISSIONCLASS = _BaseEntity.COMMISSIONCLASS and $projection.BILLINGDOCUMENT = _BaseEntity.BILLINGDOCUMENT and $projection.BILLINGDOCUMENTITEM = _BaseEntity.BILLINGDOCUMENTITEM and $projection.AGENT = _BaseEntity.AGENT and $projection.AGENTPROGRESSIVE = _BaseEntity.AGENTPROGRESSIVE and $projection.FACSIMILEPROGRESSIVE = _BaseEntity.FACSIMILEPROGRESSIVE and $projection.FACSIMILEPERIOD = _BaseEntity.FACSIMILEPERIOD
{
  @Endusertext: {
    Label: 'Company Code', 
    Quickinfo: 'Company Code'
  }
  key CompanyCode,
  @Endusertext: {
    Label: 'Sales Organization', 
    Quickinfo: 'Sales Organization'
  }
  key SalesOrganization,
  @Endusertext: {
    Label: 'Distribution Channel', 
    Quickinfo: 'Distribution Channel'
  }
  key DistributionChannel,
  @Endusertext: {
    Label: 'Cod.class.comm.', 
    Quickinfo: 'Code classification commissions'
  }
  key CommissionClass,
  @Endusertext: {
    Label: 'SD Document', 
    Quickinfo: 'Sales and Distribution Document Number'
  }
  key BillingDocument,
  @Endusertext: {
    Label: 'Item (SD)', 
    Quickinfo: 'Item number of the SD document'
  }
  key BillingDocumentItem,
  @Endusertext: {
    Label: 'Agent Code', 
    Quickinfo: 'Agent Code'
  }
  key Agent,
  @Endusertext: {
    Label: 'Prog.n.agent', 
    Quickinfo: 'Progressive number agent'
  }
  key AgentProgressive,
  @Endusertext: {
    Label: 'Facsimile number', 
    Quickinfo: 'Facsimile number'
  }
  key FacsimileProgressive,
  @Endusertext: {
    Label: 'YYYYMM competence', 
    Quickinfo: 'YYYYMM competence facsimile'
  }
  key FacsimilePeriod,
  @Endusertext: {
    Label: 'Record state', 
    Quickinfo: 'Record state'
  }
  ProcessingStatus,
  @Endusertext: {
    Label: 'Dt fac-sim print', 
    Quickinfo: 'Date of fac-simile print'
  }
  FacsimileSettlementDate,
  @Endusertext: {
    Label: 'Posting Date', 
    Quickinfo: 'Posting Date in the Document'
  }
  PostingDate,
  @Endusertext: {
    Label: 'Document Date', 
    Quickinfo: 'Document Date in Document'
  }
  MteDocumentDate,
  @Endusertext: {
    Label: 'Document Date', 
    Quickinfo: 'Document Date in Document'
  }
  BillingDocumentDate,
  @Endusertext: {
    Label: 'Agent type code', 
    Quickinfo: 'Agent type code'
  }
  AgentPaymentType,
  @Endusertext: {
    Label: 'SD document categ.', 
    Quickinfo: 'SD document category'
  }
  SalesDocumentCategory,
  @Endusertext: {
    Label: 'Exchange Rate Factor', 
    Quickinfo: 'Exchange Rate Factor'
  }
  ExchangeRate,
  @Endusertext: {
    Label: 'Currency', 
    Quickinfo: 'Currency Key'
  }
  TransactionCurrency,
  @Endusertext: {
    Label: 'Currency', 
    Quickinfo: 'Currency Key'
  }
  CompanyCurrency,
  @Endusertext: {
    Label: 'Amount document (£)', 
    Quickinfo: 'Amount document in £'
  }
  @Semantics: {
    Amount.Currencycode: 'TransactionCurrency'
  }
  BillingNetAmount,
  @Endusertext: {
    Label: 'Max date', 
    Quickinfo: 'Date time limit maximum'
  }
  PaymentDueDate,
  @Endusertext: {
    Label: 'Tax.comm.', 
    Quickinfo: 'Taxable commission'
  }
  @Semantics: {
    Amount.Currencycode: 'TransactionCurrency'
  }
  PayableCommissionAmount,
  @Endusertext: {
    Label: 'Perc. commiss.', 
    Quickinfo: 'Percentage commission'
  }
  CommissionPercentage,
  @Endusertext: {
    Label: 'Cod.class.comm.', 
    Quickinfo: 'Code classification commissions'
  }
  SourceCommissionClass,
  @Endusertext: {
    Label: 'Comm.amount', 
    Quickinfo: 'Commission amount'
  }
  @Semantics: {
    Amount.Currencycode: 'TransactionCurrency'
  }
  AccruedCommissionAmount,
  @Endusertext: {
    Label: 'Date agent invoice', 
    Quickinfo: 'Date of agent invoice'
  }
  AgentInvoiceDate,
  @Endusertext: {
    Label: 'N.invoice ag.', 
    Quickinfo: 'Number invoice agent'
  }
  AgentInvoiceNumber,
  @Endusertext: {
    Label: 'Ex.invoice ag.', 
    Quickinfo: 'Exercise invoice agent'
  }
  AgentInvoiceFiscalYear,
  @Endusertext: {
    Label: 'dt acc ref ag inv', 
    Quickinfo: 'date of accounting reference agent invoice'
  }
  AgentInvoiceRegistrationDate,
  @Endusertext: {
    Label: 'Sign document', 
    Quickinfo: 'Sign of the document'
  }
  DocumentSign,
  @Semantics: {
    Amount.Currencycode: 'TransactionCurrency'
  }
  AccruedCommissionSigned,
  @Endusertext: {
    Label: 'Posted Today', 
    Quickinfo: 'Contabilizzato oggi - boolean'
  }
  IsToday,
  _BaseEntity
}
