@EndUserText.label: 'MDE action result'
define abstract entity /eacm/a_mde_action_result
{
  Preview       : abap_boolean;
  MessageType   : abap.char(1);
  MessageText   : abap.char(255);
  PostedRows    : abap.int4;
  ErrorCount    : abap.int4;
  WarningCount  : abap.int4;
}
