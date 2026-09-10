CLASS /eacm/cl_mte_posting_apj DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_rt_run.
    INTERFACES if_apj_dt_defaults.
    DATA p_max TYPE i VALUE 20.
protected section.
private section.
ENDCLASS.



CLASS /EACM/CL_MTE_POSTING_APJ IMPLEMENTATION.


  METHOD if_apj_dt_defaults~fill_attribute_defaults.
    p_max = 20.
  ENDMETHOD.


  METHOD if_apj_rt_run~execute.
    NEW /eacm/cl_mte_posting_worker( )->run_pending(
      iv_max_requests = p_max ).

    SELECT SINGLE @abap_true
      FROM /eacm/job_mte
      WHERE status = 'I'
         OR status = 'W'
      INTO @DATA(lv_more_requests).

    IF lv_more_requests = abap_true.
      TRY.
          /eacm/cl_mte_posting_request=>schedule_processing_job(
            iv_delay_seconds = 30 ).
        CATCH /eacm/cx_eacm_posting INTO DATA(lx_schedule).
          RAISE EXCEPTION TYPE cx_apj_rt_content
            USING MESSAGE
            EXPORTING previous = lx_schedule.
      ENDTRY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
