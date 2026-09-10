@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: '/EACM/JOB_MDE'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity /EACM/R_JOB_MDE
  as select from /EACM/JOB_MDE
{
  key job_uuid as JobUUID,
  status as Status,
  bukrs as Bukrs,
  vkorg as Vkorg,
  vtweg as Vtweg,
  zclpr as Zclpr,
  zcdaz as Zcdaz,
  ztpag as Ztpag,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  waers as Waers,
  lifnr as Lifnr,
  bldat as Bldat,
  budat as Budat,
  blart as Blart,
  use_doc_rate as UseDocRate,
  assignment_rule as AssignmentRule,
  assignment_reference as AssignmentReference,
  text_rule as TextRule,
  item_text as ItemText,
  business_area as BusinessArea,
  cost_center as CostCenter,
  order_number as OrderNumber,
  profit_center as ProfitCenter,
  cost_account as CostAccount,
  provision_account as ProvisionAccount,
  provision_special_gl as ProvisionSpecialGl,
  tax_code as TaxCode,
  amount as Amount,
  source_count as SourceCount,
  xblnr as Xblnr,
  xblnr_gjahr as XblnrGjahr,
  belnr as Belnr,
  belnr_gjahr as BelnrGjahr,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  changed_by as ChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  changed_at as ChangedAt,
  last_message as LastMessage
}
