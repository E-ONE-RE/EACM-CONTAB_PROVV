CLASS /eacm/cl_mte_posting_debug DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.
CLASS /eacm/cl_mte_posting_debug IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Eseguire in ADT con F9 (ABAP Application Console).
    " Impostare un breakpoint sulla chiamata seguente o in RUN_PENDING.
    " ATTENZIONE: contabilizzazione reale, non simulazione.
    " Usare dati di test senza job concorrenti sulla stessa coda.
    " Il worker seleziona la prima richiesta I/W per changed_at, created_at.
    out->write( `Avvio worker MTE: massimo una richiesta in stato I/W.` ).
    NEW /eacm/cl_mte_posting_worker( )->run_pending(
      iv_max_requests = 1 ).
    out->write( `Worker terminato. Verificare STATUS e LAST_MESSAGE in /EACM/JOB_MTE.` ).
    out->write( `Se non erano presenti richieste I/W, nessuna richiesta e stata elaborata.` ).
  ENDMETHOD.
ENDCLASS.
