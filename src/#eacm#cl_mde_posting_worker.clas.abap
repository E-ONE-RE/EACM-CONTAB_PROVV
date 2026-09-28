CLASS /eacm/cl_mde_posting_worker DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS run_pending
      IMPORTING iv_max_requests TYPE i DEFAULT 20.

protected section.
  PRIVATE SECTION.
    METHODS mark_unhandled_error
      IMPORTING
        is_status  TYPE /eacm/job_mde
        iv_message TYPE string.
ENDCLASS.



CLASS /EACM/CL_MDE_POSTING_WORKER IMPLEMENTATION.


  METHOD run_pending.
    DATA lv_processed TYPE i.

    SELECT *
      FROM /eacm/job_mde
      WHERE status = 'I'
         OR status = 'W'
         OR status = 'E'  "togliere?
      ORDER BY changed_at, created_at
      INTO TABLE @DATA(lt_status).

    LOOP AT lt_status INTO DATA(ls_status).
      IF iv_max_requests > 0 AND lv_processed >= iv_max_requests.
        EXIT.
      ENDIF.

      TRY.
          NEW /eacm/cl_mde_posting( )->process_status( ls_status ).
        CATCH cx_root INTO DATA(lx_error).
          mark_unhandled_error(
            is_status  = ls_status
            iv_message = lx_error->get_text( ) ).
      ENDTRY.
      lv_processed += 1.
    ENDLOOP.
  ENDMETHOD.


  METHOD mark_unhandled_error.
    DATA lv_now TYPE /eacm/job_mde-changed_at.
    DATA(lv_message) = iv_message.
    IF strlen( lv_message ) > 500.
      lv_message = substring( val = lv_message off = 0 len = 497 ) && `...`.
    ENDIF.
    GET TIME STAMP FIELD lv_now.

    SELECT SINGLE status
      FROM /eacm/job_mde
      WHERE job_uuid = @is_status-job_uuid
      INTO @DATA(lv_status).

    IF lv_status = 'W'.
      UPDATE /eacm/job_mde
        SET changed_by   = @sy-uname,
            changed_at   = @lv_now,
            last_message = @lv_message
        WHERE job_uuid = @is_status-job_uuid.
    ELSE.
      UPDATE /eacm/job_mde
        SET status       = 'E',
            changed_by   = @sy-uname,
            changed_at   = @lv_now,
            last_message = @lv_message
        WHERE job_uuid = @is_status-job_uuid
          AND status <> 'C'.
    ENDIF.
    COMMIT WORK AND WAIT.
  ENDMETHOD.
ENDCLASS.
