@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: '/EACM/JOB_MTE'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity /EACM/R_JOB_MTE
  as select from /EACM/JOB_MTE
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
  zamcf as Zamcf,
  zidfs as Zidfs,
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
  accrual_account as AccrualAccount,
  maturity_account as MaturityAccount,
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
