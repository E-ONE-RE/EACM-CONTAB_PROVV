CLASS /eacm/cl_mte_posting_request DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_schedule_result,
        jobname  TYPE cl_apj_rt_api=>ty_jobname,
        jobcount TYPE cl_apj_rt_api=>ty_jobcount,
        start_at TYPE timestamp,
      END OF ty_schedule_result.

    TYPES tt_selection TYPE STANDARD TABLE OF /eacm/cl_mte_posting=>ty_selection WITH EMPTY KEY.

    CLASS-METHODS enqueue
      IMPORTING is_selection TYPE /eacm/cl_mte_posting=>ty_selection
      RETURNING VALUE(rv_count) TYPE i
      RAISING /eacm/cx_eacm_posting.

    CLASS-METHODS save_pending.
    CLASS-METHODS clear_pending.

    CLASS-METHODS schedule_processing_job
      IMPORTING iv_delay_seconds TYPE i DEFAULT 30
      RETURNING VALUE(rs_result) TYPE ty_schedule_result
      RAISING /eacm/cx_eacm_posting.

  PRIVATE SECTION.
    CLASS-DATA gt_pending_selection TYPE tt_selection.
ENDCLASS.


CLASS /eacm/cl_mte_posting_request IMPLEMENTATION.

  METHOD enqueue.
    rv_count = NEW /eacm/cl_mte_posting( )->count_status_requests( is_selection ).
    IF rv_count > 0.
      APPEND is_selection TO gt_pending_selection.
    ENDIF.
  ENDMETHOD.


  METHOD save_pending.
    DATA lt_pending_selection TYPE tt_selection.
    DATA lv_enqueued_count TYPE i.
    DATA lv_message TYPE string.

    lt_pending_selection = gt_pending_selection.
    CLEAR gt_pending_selection.
    IF lt_pending_selection IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        LOOP AT lt_pending_selection INTO DATA(ls_selection).
          lv_enqueued_count += NEW /eacm/cl_mte_posting( )->enqueue_status_requests( ls_selection ).
        ENDLOOP.

        IF lv_enqueued_count > 0.
          DATA(ls_schedule) = schedule_processing_job( iv_delay_seconds = 30 ).
          lv_message = |Application Job MTE schedulato: { ls_schedule-jobname }/{ ls_schedule-jobcount }|.

          LOOP AT lt_pending_selection INTO ls_selection.
            NEW /eacm/cl_mte_posting( )->update_status_schedule_message(
              is_selection = ls_selection
              iv_message   = lv_message ).
          ENDLOOP.
        ENDIF.

      CATCH cx_root INTO DATA(lx_error).
        lv_message = lx_error->get_text( ).
        LOOP AT lt_pending_selection INTO ls_selection.
          NEW /eacm/cl_mte_posting( )->update_status_schedule_message(
            is_selection = ls_selection
            iv_message   = lv_message
            iv_status    = 'E' ).
        ENDLOOP.
    ENDTRY.
  ENDMETHOD.


  METHOD clear_pending.
    CLEAR gt_pending_selection.
  ENDMETHOD.


  METHOD schedule_processing_job.
    CONSTANTS lc_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE '/EACM/APJT_MTE_POST'.
    DATA ls_start_info TYPE cl_apj_rt_api=>ty_start_info.
    DATA lv_start_at TYPE timestamp.

    TRY.
        GET TIME STAMP FIELD lv_start_at.
        lv_start_at = cl_abap_tstmp=>add_to_short(
          tstmp = lv_start_at
          secs  = iv_delay_seconds ).
        ls_start_info-timestamp = lv_start_at.

        cl_apj_rt_api=>schedule_job(
          EXPORTING
            iv_job_template_name = lc_template_name
            iv_job_text          = 'Contabilizzazione provvigioni maturate'
            is_start_info        = ls_start_info
          IMPORTING
            ev_jobname           = rs_result-jobname
            ev_jobcount          = rs_result-jobcount ).
        rs_result-start_at = lv_start_at.

      CATCH cx_root INTO DATA(lx_error).
        RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
          EXPORTING
            iv_text = |Errore pianificazione Application Job MTE: { lx_error->get_text( ) }|.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

