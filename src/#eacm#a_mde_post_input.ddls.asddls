@EndUserText.label: 'MDE posting action input'
define abstract entity /eacm/a_mde_post_input
{
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/R_T001', element: 'Bukrs' }}]
  CompanyCode            : bukrs;
  @EndUserText.label: 'Test'
  TestRun                : abap_boolean;
  DocumentDate           : abap.dats;
  PostingDate            : abap.dats;
  AccountingDocumentType : blart;
  @EndUserText.label: 'Valuta alla data documento'
  UseDocumentDateRate    : abap_boolean;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPRAA', element: 'Zcdaz' }}]
  Agent                  : /eacm/zcdaz;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPR02', element: 'Ztpag' }}]
  @EndUserText.label: 'Tipo agente'
  AgentType              : abap.char(4);
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_TVKO', element: 'Vkorg' }}]
  SalesOrganization      : vkorg;
  CommissionClass        : abap.char(10);
  BillingDocument        : abap.char(10);
  BillingDocumentDateFrom : abap.dats;
  BillingDocumentDateTo   : abap.dats;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPR43', element: 'Zfratt' }}]
  AssignmentRule         : abap.char(10);
  AssignmentReference    : abap.char(18);
  TextRule               : abap.char(10);
  ItemText               : abap.char(50);
  
}
