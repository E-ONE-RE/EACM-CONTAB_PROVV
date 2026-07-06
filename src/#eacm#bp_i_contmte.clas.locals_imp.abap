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

ENDCLASS.

CLASS lhc_I_CONTMTE IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

METHOD PostMte.
  DATA(lo_posting) = NEW /eacm/cl_mte_posting( ).

  LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
    DATA(ls_selection) = VALUE /eacm/cl_mte_posting=>ty_selection(
      company_code             = <key>-%param-CompanyCode
      test_run                 = <key>-%param-TestRun
      document_date            = <key>-%param-DocumentDate
      posting_date             = <key>-%param-PostingDate
      accounting_document_type = <key>-%param-AccountingDocumentType
      assignment_rule          = <key>-%param-AssignmentRule
      assignment_reference     = <key>-%param-AssignmentReference
      text_rule                = <key>-%param-TextRule
      item_text                = <key>-%param-ItemText
      use_document_date_rate   = <key>-%param-UseDocumentDateRate ).

    IF <key>-%param-AgentFrom IS NOT INITIAL
       OR <key>-%param-AgentTo IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = COND #( WHEN <key>-%param-AgentTo IS INITIAL THEN 'EQ' ELSE 'BT' )
        low    = <key>-%param-AgentFrom
        high   = <key>-%param-AgentTo ) TO ls_selection-agent_range.
    ENDIF.

    IF <key>-%param-PaymentTypeFrom IS NOT INITIAL
       OR <key>-%param-PaymentTypeTo IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = COND #( WHEN <key>-%param-PaymentTypeTo IS INITIAL THEN 'EQ' ELSE 'BT' )
        low    = <key>-%param-PaymentTypeFrom
        high   = <key>-%param-PaymentTypeTo ) TO ls_selection-payment_type_range.
    ENDIF.

    IF <key>-%param-SalesOrgFrom IS NOT INITIAL
       OR <key>-%param-SalesOrgTo IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = COND #( WHEN <key>-%param-SalesOrgTo IS INITIAL THEN 'EQ' ELSE 'BT' )
        low    = <key>-%param-SalesOrgFrom
        high   = <key>-%param-SalesOrgTo ) TO ls_selection-sales_org_range.
    ENDIF.

    IF <key>-%param-CommissionClassFrom IS NOT INITIAL
       OR <key>-%param-CommissionClassTo IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = COND #( WHEN <key>-%param-CommissionClassTo IS INITIAL THEN 'EQ' ELSE 'BT' )
        low    = <key>-%param-CommissionClassFrom
        high   = <key>-%param-CommissionClassTo ) TO ls_selection-commission_class_range.
    ENDIF.

    IF <key>-%param-BillingDocumentFrom IS NOT INITIAL
       OR <key>-%param-BillingDocumentTo IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = COND #( WHEN <key>-%param-BillingDocumentTo IS INITIAL THEN 'EQ' ELSE 'BT' )
        low    = <key>-%param-BillingDocumentFrom
        high   = <key>-%param-BillingDocumentTo ) TO ls_selection-billing_document_range.
    ENDIF.

    IF <key>-%param-FacsimilePeriodFrom IS NOT INITIAL
       OR <key>-%param-FacsimilePeriodTo IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = COND #( WHEN <key>-%param-FacsimilePeriodTo IS INITIAL THEN 'EQ' ELSE 'BT' )
        low    = <key>-%param-FacsimilePeriodFrom
        high   = <key>-%param-FacsimilePeriodTo ) TO ls_selection-facsimile_period_range.
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
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
