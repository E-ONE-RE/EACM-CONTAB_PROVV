CLASS /eacm/cl_mte_posting_worker DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS run_pending
      IMPORTING iv_max_requests TYPE i DEFAULT 20.

  PRIVATE SECTION.
    METHODS mark_unhandled_error
      IMPORTING
        is_status  TYPE /eacm/job_mte
        iv_message TYPE string.

    METHODS build_exception_message
      IMPORTING ix_error TYPE REF TO cx_root
      RETURNING VALUE(rv_message) TYPE string.
ENDCLASS.


CLASS /eacm/cl_mte_posting_worker IMPLEMENTATION.

  METHOD run_pending.
    DATA lv_processed TYPE i.

    SELECT *
      FROM /eacm/job_mte
      WHERE status = 'I'
         OR status = 'W'
         OR status = 'E'
      ORDER BY changed_at, created_at
      INTO TABLE @DATA(lt_status).

    LOOP AT lt_status INTO DATA(ls_status).
      IF iv_max_requests > 0 AND lv_processed >= iv_max_requests.
        EXIT.
      ENDIF.

      TRY.
          NEW /eacm/cl_mte_posting( )->process_status( ls_status ).
        CATCH cx_root INTO DATA(lx_error).
          mark_unhandled_error(
            is_status  = ls_status
            iv_message = build_exception_message( lx_error ) ).
      ENDTRY.
      lv_processed += 1.
    ENDLOOP.
  ENDMETHOD.


  METHOD build_exception_message.
    DATA lo_error TYPE REF TO cx_root.
    lo_error = ix_error.

    WHILE lo_error IS BOUND.
      IF lo_error IS INSTANCE OF /eacm/cx_api_error.
        DATA(lx_api_error) = CAST /eacm/cx_api_error( lo_error ).
        IF lx_api_error->mv_context IS NOT INITIAL
           AND ( rv_message IS INITIAL
                 OR rv_message NS lx_api_error->mv_context ).
          rv_message = COND #(
            WHEN rv_message IS INITIAL THEN lx_api_error->mv_context
            ELSE |{ rv_message }; { lx_api_error->mv_context }| ).
        ENDIF.
      ENDIF.

      DATA(lv_text) = lo_error->get_text( ).
      IF lv_text IS NOT INITIAL
         AND ( rv_message IS INITIAL OR rv_message NS lv_text ).
        rv_message = COND #(
          WHEN rv_message IS INITIAL THEN lv_text
          ELSE |{ rv_message }; { lv_text }| ).
      ENDIF.

      DATA(lv_longtext) = lo_error->get_longtext( ).
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline
        IN lv_longtext WITH ` `.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf
        IN lv_longtext WITH ` `.
      CONDENSE lv_longtext.
      IF lv_longtext IS NOT INITIAL
         AND lv_longtext <> lv_text
         AND ( rv_message IS INITIAL OR rv_message NS lv_longtext ).
        rv_message = COND #(
          WHEN rv_message IS INITIAL THEN lv_longtext
          ELSE |{ rv_message }; { lv_longtext }| ).
      ENDIF.

      lo_error = lo_error->previous.
    ENDWHILE.

    IF rv_message IS INITIAL.
      rv_message = 'Eccezione non identificata nel worker MTE.'.
    ENDIF.
  ENDMETHOD.


  METHOD mark_unhandled_error.
    DATA lv_now TYPE /eacm/job_mte-changed_at.
    DATA(lv_message) = iv_message.
    IF strlen( lv_message ) > 500.
      lv_message = substring( val = lv_message off = 0 len = 497 ) && `...`.
    ENDIF.
    GET TIME STAMP FIELD lv_now.

    SELECT SINGLE status
      FROM /eacm/job_mte
      WHERE job_uuid = @is_status-job_uuid
      INTO @DATA(lv_status).

    IF lv_status = 'W'.
      UPDATE /eacm/job_mte
        SET changed_by   = @sy-uname,
            changed_at   = @lv_now,
            last_message = @lv_message
        WHERE job_uuid = @is_status-job_uuid.
    ELSEIF lv_status = 'I'.
      UPDATE /eacm/job_mte
        SET status       = 'E',
            changed_by   = @sy-uname,
            changed_at   = @lv_now,
            last_message = @lv_message
        WHERE job_uuid = @is_status-job_uuid
          AND status = 'I'.
    ENDIF.
    COMMIT WORK AND WAIT.
  ENDMETHOD.
ENDCLASS.

