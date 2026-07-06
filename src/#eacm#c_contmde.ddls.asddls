@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Stanziamenti provvigioni agenti'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity /EACM/C_CONTMDE
  provider contract transactional_query
  as projection on /EACM/I_CONTMDE
  association [1..1] to /EACM/I_CONTMDE as _BaseEntity on $projection.CompanyCode = _BaseEntity.CompanyCode and $projection.SalesOrganization = _BaseEntity.SalesOrganization and $projection.DistributionChannel = _BaseEntity.DistributionChannel and $projection.CommissionClass = _BaseEntity.CommissionClass and $projection.BillingDocument = _BaseEntity.BillingDocument and $projection.BillingDocumentItem = _BaseEntity.BillingDocumentItem and $projection.Agent = _BaseEntity.Agent and $projection.AgentProgressive = _BaseEntity.AgentProgressive
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
    label: 'Document Date', 
    quickInfo: 'Document Date in Document'
  }
  BillingDocumentDate,
  @EndUserText: {
    label: 'Date record alloc.', 
    quickInfo: 'Date of record allocation'
  }
  PostingDate,
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
    label: 'Document Currency', 
    quickInfo: 'SD Document Currency'
  }
  CompanyCurrency,
  @EndUserText: {
    label: 'Amm.allocate', 
    quickInfo: 'Amount allocate'
  }
  @Semantics: {
    amount.currencyCode: 'CompanyCurrency'
  }
  AccrualAmountOriginal,
  @EndUserText: {
    label: 'Sign document', 
    quickInfo: 'Sign of the document'
  }
  DocumentSign,
  @Semantics: {
    amount.currencyCode: 'CompanyCurrency'
  }
  AccrualAmountSigned,
  
  IsToday,
  
  _BaseEntity
}
