@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: '/EACM/JOB_MTE'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity /EACM/C_JOB_MTE
  provider contract transactional_query
  as projection on /EACM/R_JOB_MTE
  association [1..1] to /EACM/R_JOB_MTE as _BaseEntity on $projection.JobUUID = _BaseEntity.JobUUID
{
key JobUUID,

  Status,

  @Consumption.valueHelpDefinition: [{
    entity: {
      name: '/EACM/R_T001',
      element: 'Bukrs'
    }
  }]
  Bukrs,

  @Consumption.valueHelpDefinition: [{
    entity: {
      name: '/EACM/I_TVKO',
      element: 'Vkorg'
    }
  }]
  Vkorg,

  Vtweg,

  Zclpr,

  @Consumption.valueHelpDefinition: [{
    entity: {
      name: '/EACM/I_ZPRAA',
      element: 'Zcdaz'
    }
  }]
  Zcdaz,

  @Consumption.valueHelpDefinition: [{
    entity: {
      name: '/EACM/I_ZPR02',
      element: 'Ztpag'
    }
  }]
  Ztpag,

  @Consumption.valueHelpDefinition: [{
    entity: {
      name: 'I_CurrencyStdVH',
      element: 'Currency'
    },
    useForValidation: true
  }]
  Waers,

  Lifnr,
  Zamcf,
  Zidfs,
  Bldat,
  Budat,
  Blart,
  UseDocRate,
  AssignmentRule,
  AssignmentReference,
  TextRule,
  ItemText,
  BusinessArea,
  CostCenter,
  OrderNumber,
  ProfitCenter,
  AccrualAccount,
  MaturityAccount,
  tax_code,
  Amount,
  SourceCount,
  Xblnr,
  XblnrGjahr,
  Belnr,
  BelnrGjahr,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.lastChangedBy: true
  }
  ChangedBy,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  ChangedAt,
  LastMessage,
  _BaseEntity
}
