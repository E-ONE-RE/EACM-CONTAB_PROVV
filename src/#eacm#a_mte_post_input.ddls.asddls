@EndUserText.label: 'MDE posting action input'
define abstract entity /EACM/A_MTE_POST_INPUT
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
  AgentFrom              : /eacm/zcdaz;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPRAA', element: 'Zcdaz' }}]
  AgentTo                : /eacm/zcdaz;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPR02', element: 'Ztpag' }}]
  PaymentTypeFrom        : abap.char(4);
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPR02', element: 'Ztpag' }}]
  PaymentTypeTo          : abap.char(4);
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_TVKO', element: 'Vkorg' }}]
  SalesOrgFrom           : vkorg;
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_TVKO', element: 'Vkorg' }}]
  SalesOrgTo             : vkorg;
  CommissionClassFrom    : abap.char(10);
  CommissionClassTo      : abap.char(10);
  BillingDocumentFrom    : abap.char(10);
  BillingDocumentTo      : abap.char(10);
  DocumentDateFrom       : abap.dats;
  DocumentDateTo         : abap.dats;
  FacsimilePeriodFrom    : abap.char(6);
  FacsimilePeriodTo      : abap.char(6);
  @Consumption.valueHelpDefinition: [{
    entity: {name: '/EACM/I_ZPR43', element: 'Zfratt' }}]
  AssignmentRule         : abap.char(10);
  AssignmentReference    : abap.char(18);
  TextRule               : abap.char(10);
  ItemText               : abap.char(50);
  
}
