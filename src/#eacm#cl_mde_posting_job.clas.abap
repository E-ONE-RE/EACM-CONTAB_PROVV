CLASS /eacm/cl_mde_posting_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.
ENDCLASS.


CLASS /eacm/cl_mde_posting_job IMPLEMENTATION.

  METHOD if_apj_dt_exec_object~get_parameters.
    CLEAR et_parameter_def.
    CLEAR et_parameter_val.
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    SELECT *
      FROM /eacm/job_mde
      WHERE status = 'I'
         OR status = 'W'
      ORDER BY created_at
      INTO TABLE @DATA(lt_status).

    LOOP AT lt_status INTO DATA(ls_status).
      NEW /eacm/cl_mde_posting( )->process_status( ls_status ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

