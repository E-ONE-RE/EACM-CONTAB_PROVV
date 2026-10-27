CLASS lhc_I_CONTMTE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR /eacm/i_contmte RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ /eacm/i_contmte RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /eacm/i_contmte.
    METHODS postmte FOR MODIFY
      IMPORTING keys FOR ACTION /eacm/i_contmte~postmte RESULT result.

    METHODS postmtedirect FOR MODIFY
      IMPORTING keys FOR ACTION /eacm/i_contmte~postmtedirect RESULT result.

    METHODS build_selection
      IMPORTING
        is_param TYPE /eacm/a_mte_post_input
        iv_defer_status_update TYPE abap_bool
      RETURNING VALUE(rs_selection) TYPE /eacm/cl_mte_posting=>ty_selection.

    METHODS format_exception
      IMPORTING ix_error TYPE REF TO cx_root
      RETURNING VALUE(rv_message) TYPE string.

ENDCLASS.

CLASS lhc_I_CONTMTE IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD build_selection.
    rs_selection = VALUE #(
      company_code             = is_param-CompanyCode
      test_run                 = is_param-TestRun
      document_date            = is_param-DocumentDate
      posting_date             = is_param-PostingDate
      accounting_document_type = is_param-AccountingDocumentType
      assignment_rule          = is_param-AssignmentRule
      assignment_reference     = is_param-AssignmentReference
      text_rule                = is_param-TextRule
      item_text                = is_param-ItemText
      use_document_date_rate   = is_param-UseDocumentDateRate
      defer_status_update      = iv_defer_status_update ).

    IF is_param-Agent IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = is_param-Agent ) TO rs_selection-agent_range.
    ENDIF.

    IF is_param-AgentType IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = is_param-AgentType ) TO rs_selection-payment_type_range.
    ENDIF.

    IF is_param-SalesOrganization IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = is_param-SalesOrganization ) TO rs_selection-sales_org_range.
    ENDIF.

    IF is_param-CommissionClass IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = is_param-CommissionClass ) TO rs_selection-commission_class_range.
    ENDIF.

    IF is_param-BillingDocument IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = is_param-BillingDocument ) TO rs_selection-billing_document_range.
    ENDIF.

    IF is_param-FacsimilePeriod IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = is_param-FacsimilePeriod ) TO rs_selection-facsimile_period_range.
    ENDIF.
  ENDMETHOD.

  METHOD format_exception.
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
      DATA(lv_detail) = |{ lo_type->absolute_name } in { lv_origin }:{ lv_line }: { lo_error->get_text( ) }|.

      IF lo_error IS INSTANCE OF /eacm/cx_api_error.
        DATA(lx_api_error) = CAST /eacm/cx_api_error( lo_error ).
        IF lx_api_error->mv_context IS NOT INITIAL.
          lv_detail = |{ lv_detail }; { lx_api_error->mv_context }|.
        ENDIF.
      ENDIF.

      rv_message = COND #(
        WHEN rv_message IS INITIAL THEN lv_detail
        ELSE |{ rv_message }; { lv_detail }| ).
      lo_error = lo_error->previous.
    ENDWHILE.
  ENDMETHOD.

METHOD PostMte.
  DATA(lo_posting) = NEW /eacm/cl_mte_posting( ).
  DATA lv_enqueued_total TYPE i.

  /eacm/cl_mte_posting_request=>clear_pending( ).

  LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
    DATA(ls_selection) = build_selection(
      is_param = <key>-%param
      iv_defer_status_update = abap_true ).

    IF ls_selection-test_run <> abap_true.
      TRY.
          DATA(lv_enqueued_count) = /eacm/cl_mte_posting_request=>enqueue( ls_selection ).
          lv_enqueued_total += lv_enqueued_count.

          DATA(lv_queue_message) = COND string(
            WHEN lv_enqueued_count > 0
            THEN |Richieste MTE accodate: { lv_enqueued_count }. Il job verra pianificato al salvataggio.|
            ELSE 'Nessuna richiesta MTE accodata: righe gia contabilizzate o gia in elaborazione.' ).

          APPEND VALUE #(
            %cid = <key>-%cid
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-information
              text     = lv_queue_message ) ) TO reported-/eacm/i_contmte.

          APPEND VALUE #(
            %cid = <key>-%cid
            %param = VALUE #(
              Preview      = abap_false
              MessageType  = 'S'
              MessageText  = lv_queue_message
              PostedRows   = 0
              ErrorCount   = 0
              WarningCount = 0 ) ) TO result.

        CATCH cx_root INTO DATA(lx_enqueue).
          APPEND VALUE #( %cid = <key>-%cid ) TO failed-/eacm/i_contmte.
          APPEND VALUE #(
            %cid = <key>-%cid
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = lx_enqueue->get_text( ) ) ) TO reported-/eacm/i_contmte.
          APPEND VALUE #(
            %cid = <key>-%cid
            %param = VALUE #(
              Preview      = abap_false
              MessageType  = 'E'
              MessageText  = lx_enqueue->get_text( )
              PostedRows   = 0
              ErrorCount   = 1
              WarningCount = 0 ) ) TO result.
      ENDTRY.
      CONTINUE.
    ENDIF.

    DATA lt_posting_result TYPE /eacm/cl_mte_posting=>tt_result.

    TRY.
        lt_posting_result = lo_posting->run( ls_selection ).
      CATCH cx_root INTO DATA(lx_posting).
        APPEND VALUE #(
          type         = 'E'
          message_text = lx_posting->get_text( ) ) TO lt_posting_result.
    ENDTRY.

    DATA(lv_message_type) = COND symsgty(
      WHEN line_exists( lt_posting_result[ type = 'E' ] )
        OR line_exists( lt_posting_result[ type = 'A' ] )
        OR line_exists( lt_posting_result[ type = 'X' ] ) THEN 'E'
      WHEN line_exists( lt_posting_result[ type = 'W' ] ) THEN 'W'
      ELSE 'S' ).

    DATA(lv_error_count) = 0.
    DATA(lv_warning_count) = 0.
    DATA(lv_success_count) = 0.

    LOOP AT lt_posting_result INTO DATA(ls_posting_message).
      CASE ls_posting_message-type.
        WHEN 'E' OR 'A' OR 'X'.
          lv_error_count += 1.
        WHEN 'W'.
          lv_warning_count += 1.
      ENDCASE.

      IF ls_posting_message-success = abap_true.
        lv_success_count += ls_posting_message-source_count.
      ENDIF.

      APPEND VALUE #(
        %cid = <key>-%cid
        %msg = new_message_with_text(
          severity = SWITCH #( ls_posting_message-type
            WHEN 'E' THEN if_abap_behv_message=>severity-error
            WHEN 'A' THEN if_abap_behv_message=>severity-error
            WHEN 'X' THEN if_abap_behv_message=>severity-error
            WHEN 'W' THEN if_abap_behv_message=>severity-warning
            WHEN 'S' THEN if_abap_behv_message=>severity-success
            ELSE if_abap_behv_message=>severity-information )
          text = ls_posting_message-message_text ) ) TO reported-/eacm/i_contmte.
    ENDLOOP.

    DATA(lv_message_text) = COND string(
      WHEN lv_message_type = 'E'
      THEN |Contabilizzazione MTE terminata con errori: { lv_error_count }.|
      WHEN lv_message_type = 'W'
      THEN |Contabilizzazione MTE terminata con avvisi: { lv_warning_count }.|
      WHEN lv_success_count > 0
      THEN |Contabilizzazione MTE completata: { lv_success_count } righe sorgente aggiornate.|
      ELSE 'Contabilizzazione MTE completata.' ).

    IF lv_message_type = 'E'.
      APPEND VALUE #( %cid = <key>-%cid ) TO failed-/eacm/i_contmte.
    ENDIF.

    APPEND VALUE #(
      %cid = <key>-%cid
      %param = VALUE #(
        Preview      = ls_selection-test_run
        MessageType  = lv_message_type
        MessageText  = lv_message_text
        PostedRows   = lv_success_count
        ErrorCount   = lv_error_count
        WarningCount = lv_warning_count ) ) TO result.
  ENDLOOP.

  IF lv_enqueued_total > 0.
    APPEND VALUE #(
      %msg = new_message_with_text(
        severity = if_abap_behv_message=>severity-information
        text     = |Application Job MTE pianificato tra 30 secondi al salvataggio. Richieste totali: { lv_enqueued_total }.| ) )
      TO reported-/eacm/i_contmte.
  ENDIF.
ENDMETHOD.


METHOD PostMteDirect.
  DATA(lo_posting) = NEW /eacm/cl_mte_posting( ).

  LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
    DATA(ls_selection) = build_selection(
      is_param = <key>-%param
      iv_defer_status_update = abap_true ).

    DATA lt_posting_result TYPE /eacm/cl_mte_posting=>tt_result.
    CLEAR lt_posting_result.

    TRY.
        IF ls_selection-test_run = abap_true.
          lt_posting_result = lo_posting->run( ls_selection ).
        ELSE.
          DATA(lv_direct_count) =
            /eacm/cl_mte_posting_request=>enqueue( ls_selection ).
          DATA(lv_direct_message) = COND string(
            WHEN lv_direct_count > 0
            THEN |Richieste MTE accodate: { lv_direct_count }. Esito e documenti in JOB_MTE.|
            ELSE 'Nessuna richiesta MTE da contabilizzare: righe gia contabilizzate o in elaborazione.' ).
          APPEND VALUE #(
            %cid = <key>-%cid
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-information
              text     = lv_direct_message ) ) TO reported-/eacm/i_contmte.
          APPEND VALUE #(
            %cid = <key>-%cid
            %param = VALUE #(
              Preview      = abap_false
              MessageType  = COND #( WHEN lv_direct_count > 0 THEN 'I' ELSE 'W' )
              MessageText  = lv_direct_message
              PostedRows   = 0
              ErrorCount   = 0
              WarningCount = 0 ) ) TO result.
          CONTINUE.
        ENDIF.
      CATCH cx_root INTO DATA(lx_posting).
        APPEND VALUE #(
          type = 'E'
          message_text = format_exception( lx_posting ) ) TO lt_posting_result.
    ENDTRY.

    DATA(lv_message_type) = COND symsgty(
      WHEN line_exists( lt_posting_result[ type = 'E' ] )
        OR line_exists( lt_posting_result[ type = 'A' ] )
        OR line_exists( lt_posting_result[ type = 'X' ] ) THEN 'E'
      WHEN line_exists( lt_posting_result[ type = 'W' ] ) THEN 'W'
      ELSE 'S' ).

    DATA(lv_error_count) = 0.
    DATA(lv_warning_count) = 0.
    DATA(lv_success_count) = 0.

    LOOP AT lt_posting_result INTO DATA(ls_posting_message).
      CASE ls_posting_message-type.
        WHEN 'E' OR 'A' OR 'X'.
          lv_error_count += 1.
        WHEN 'W'.
          lv_warning_count += 1.
      ENDCASE.

      IF ls_posting_message-success = abap_true.
        lv_success_count += ls_posting_message-source_count.
      ENDIF.

      APPEND VALUE #(
        %cid = <key>-%cid
        %msg = new_message_with_text(
          severity = SWITCH #( ls_posting_message-type
            WHEN 'E' THEN if_abap_behv_message=>severity-error
            WHEN 'A' THEN if_abap_behv_message=>severity-error
            WHEN 'X' THEN if_abap_behv_message=>severity-error
            WHEN 'W' THEN if_abap_behv_message=>severity-warning
            WHEN 'S' THEN if_abap_behv_message=>severity-success
            ELSE if_abap_behv_message=>severity-information )
          text = ls_posting_message-message_text ) ) TO reported-/eacm/i_contmte.
    ENDLOOP.

    DATA(lv_message_text) = COND string(
      WHEN lv_message_type = 'E'
      THEN |Contabilizzazione MTE diretta terminata con errori: { lv_error_count }.|
      WHEN lv_message_type = 'W'
      THEN |Contabilizzazione MTE diretta terminata con avvisi: { lv_warning_count }.|
      WHEN ls_selection-test_run = abap_true
      THEN 'Simulazione MTE diretta completata.'
      WHEN lv_success_count > 0
      THEN |Contabilizzazione MTE diretta completata: { lv_success_count } righe aggiornate.|
      ELSE 'Nessuna provvigione MTE contabilizzata.' ).

    IF lv_message_type = 'E'.
      APPEND VALUE #( %cid = <key>-%cid ) TO failed-/eacm/i_contmte.
    ENDIF.

    APPEND VALUE #(
      %cid = <key>-%cid
      %param = VALUE #(
        Preview      = ls_selection-test_run
        MessageType  = lv_message_type
        MessageText  = lv_message_text
        PostedRows   = lv_success_count
        ErrorCount   = lv_error_count
        WarningCount = lv_warning_count ) ) TO result.
  ENDLOOP.
ENDMETHOD.


ENDCLASS.

CLASS lsc_I_CONTMTE DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_I_CONTMTE IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    /eacm/cl_mte_posting_request=>save_pending( ).
  ENDMETHOD.

  METHOD cleanup.
    /eacm/cl_mte_posting_request=>clear_pending( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
    /eacm/cl_mte_posting_request=>clear_pending( ).
  ENDMETHOD.

ENDCLASS.




