CLASS /eacm/cl_mte_posting_worker DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS run_pending
      IMPORTING iv_max_requests TYPE i DEFAULT 20
                iv_retry_errors TYPE abap_bool DEFAULT abap_false.
    METHODS add_status_to_log
      IMPORTING io_log TYPE REF TO if_bali_log
                iv_text TYPE string.
    METHODS add_error_to_log
      IMPORTING io_log TYPE REF TO if_bali_log
                iv_text TYPE string.
    METHODS save_log
      IMPORTING io_log TYPE REF TO if_bali_log.
  PRIVATE SECTION.
    METHODS mark_unhandled_error
      IMPORTING is_status TYPE /eacm/job_mte
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
         OR ( status = 'E' AND @iv_retry_errors = @abap_true )
      ORDER BY changed_at, created_at
      INTO TABLE @DATA(lt_status).

    DATA lo_log TYPE REF TO if_bali_log.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_time) = cl_abap_context_info=>get_system_time( ).
    DATA(lv_external_id) = |JOB_MTE { lv_date } { lv_time }|.
    TRY.
        lo_log = cl_bali_log=>create_with_header(
          header = cl_bali_header_setter=>create(
            object      = '/EACM/JOB_MTE'
            subobject   = 'POSTING'
            external_id = CONV #( lv_external_id ) ) ).
      CATCH cx_bali_runtime.
        CLEAR lo_log.
    ENDTRY.

    add_status_to_log(
      io_log  = lo_log
      iv_text = 'Start posting MTE' ).

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

      " Legge l'esito gia salvato, senza cambiare PROCESS_STATUS.
      IF lo_log IS BOUND.
        SELECT SINGLE * FROM /eacm/job_mte
          WHERE job_uuid = @ls_status-job_uuid
          INTO @DATA(ls_final_status).
        IF sy-subrc = 0.
          CASE ls_final_status-status.
            WHEN 'E'.
              add_error_to_log(
                io_log  = lo_log
                iv_text = |Societa { ls_final_status-bukrs }, agente { ls_final_status-zcdaz }: { ls_final_status-last_message }| ).
            WHEN 'C'.
              add_status_to_log(
                io_log  = lo_log
                iv_text = |Societa { ls_final_status-bukrs }, agente { ls_final_status-zcdaz }: documento { ls_final_status-belnr }/{ ls_final_status-belnr_gjahr }. { ls_final_status-last_message }| ).
          ENDCASE.
        ENDIF.
      ENDIF.
      lv_processed += 1.
    ENDLOOP.

    save_log( lo_log ).
  ENDMETHOD.

  METHOD build_exception_message.
    DATA lo_error TYPE REF TO cx_root.
    lo_error = ix_error.

    WHILE lo_error IS BOUND.

     DATA(lo_type) = cl_abap_typedescr=>describe_by_object_ref( lo_error ).
      lo_error->get_source_position(
        IMPORTING
          program_name = DATA(lv_program)
          include_name = DATA(lv_include)
          source_line  = DATA(lv_line) ).
      DATA(lv_origin) = COND string(
        WHEN lv_include IS INITIAL THEN lv_program
        ELSE lv_include ).
      DATA(lv_location) = |{ lo_type->absolute_name } in { lv_origin }:{ lv_line }|.
      rv_message = COND #(
        WHEN rv_message IS INITIAL THEN lv_location
        ELSE |{ rv_message }; { lv_location }| ).

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
        SET status       = 'E',
            changed_by   = @sy-uname,
            changed_at   = @lv_now,
            last_message = @lv_message
        WHERE job_uuid = @is_status-job_uuid
          AND status = 'W'.
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
  METHOD add_status_to_log.
    IF io_log IS NOT BOUND.
      RETURN.
    ENDIF.

    TRY.
        io_log->add_item(
          item = cl_bali_free_text_setter=>create(
            severity = if_bali_constants=>c_severity_information
            text     = CONV #( iv_text ) ) ).
      CATCH cx_bali_runtime INTO DATA(lo_cxb_ali). "##NO_HANDLER
        " Un problema di logging non deve cambiare lo stato del Run
        DATA(msg) = lo_cxb_ali->get_text( ).
    ENDTRY.
  ENDMETHOD.

METHOD add_error_to_log.

  CONSTANTS lc_chunk_size TYPE i VALUE 200.

  IF io_log IS NOT BOUND OR iv_text IS INITIAL.
    RETURN.
  ENDIF.

  DATA(lv_offset) = 0.
  DATA(lv_length) = strlen( iv_text ).

  TRY.
      WHILE lv_offset < lv_length.

        DATA(lv_chunk_length) = COND i(
          WHEN lv_length - lv_offset > lc_chunk_size
          THEN lc_chunk_size
          ELSE lv_length - lv_offset ).

        io_log->add_item(
          item = cl_bali_free_text_setter=>create(
            severity = if_bali_constants=>c_severity_error
            text     = CONV #(
              substring(
                val = iv_text
                off = lv_offset
                len = lv_chunk_length ) ) ) ).

        lv_offset += lv_chunk_length.
      ENDWHILE.

    CATCH cx_bali_runtime INTO DATA(lx_bali).
      " Il logging non deve mascherare l'errore di contabilizzazione.
  ENDTRY.

ENDMETHOD.

  METHOD save_log.

    IF io_log IS NOT BOUND.
      RETURN.
    ENDIF.

    TRY.
        cl_bali_log_db=>get_instance(
          )->save_log_2nd_db_connection(
            log                        = io_log
            assign_to_current_appl_job = abap_true ).

      CATCH cx_bali_runtime INTO DATA(lo_cxb_ali). "##NO_HANDLER
        " Il calcolo e lo stato RAP hanno priorità sul logging
        DATA(msg) = lo_cxb_ali->get_text( ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.

