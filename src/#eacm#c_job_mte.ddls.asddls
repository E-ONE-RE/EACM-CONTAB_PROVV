@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: '/EACM/JOB_MTE'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity /EACM/C_JOB_MTE
  provider contract TRANSACTIONAL_QUERY
  as projection on /EACM/R_JOB_MTE
  association [1..1] to /EACM/R_JOB_MTE as _BaseEntity on $projection.JOBUUID = _BaseEntity.JOBUUID
{
  key JobUUID,
  Status,
  Bukrs,
  Vkorg,
  Vtweg,
  Zclpr,
  Zcdaz,
  Ztpag,
  @Consumption: {
    Valuehelpdefinition: [ {
      Entity.Element: 'Currency', 
      Entity.Name: 'I_CurrencyStdVH', 
      Useforvalidation: true
    } ]
  }
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
  Amount,
  SourceCount,
  Xblnr,
  XblnrGjahr,
  Belnr,
  BelnrGjahr,
  @Semantics: {
    User.Createdby: true
  }
  CreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  CreatedAt,
  @Semantics: {
    User.Lastchangedby: true
  }
  ChangedBy,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  ChangedAt,
  LastMessage,
  _BaseEntity
}
