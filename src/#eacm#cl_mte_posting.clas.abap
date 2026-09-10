CLASS /eacm/cl_mte_posting DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      tt_agent_range TYPE RANGE OF /eacm/zpraa-zcdaz,
      tt_payment_type_range TYPE RANGE OF /eacm/zpraa-ztpag,
      tt_sales_org_range TYPE RANGE OF /eacm/zprdp-vkorg,
      tt_commission_class_range TYPE RANGE OF /eacm/zprdp-zclpr,
      tt_billing_document_range TYPE RANGE OF /eacm/zprdp-vbeln,
      tt_facsimile_period_range TYPE RANGE OF /eacm/zprdp-zamcf,

      BEGIN OF ty_selection,
        company_code             TYPE bukrs,
        test_run                 TYPE abap_bool,
        document_date            TYPE bldat,
        posting_date             TYPE budat,
        accounting_document_type TYPE blart,
        assignment_rule          TYPE /eacm/zpr43-zfratt,
        assignment_reference     TYPE dzuonr,
        text_rule                TYPE /eacm/zpr43-zfratt,
        item_text                TYPE c LENGTH 50,
        use_document_date_rate   TYPE abap_bool,
        defer_status_update      TYPE abap_bool,
        external_reference       TYPE xblnr,
        agent_range              TYPE tt_agent_range,
        payment_type_range       TYPE tt_payment_type_range,
        sales_org_range          TYPE tt_sales_org_range,
        commission_class_range   TYPE tt_commission_class_range,
        billing_document_range   TYPE tt_billing_document_range,
        facsimile_period_range   TYPE tt_facsimile_period_range,
      END OF ty_selection,

      BEGIN OF ty_result,
        type                TYPE symsgty,
        message_text        TYPE string,
        accounting_document TYPE belnr_d,
        fiscal_year         TYPE gjahr,
        company_code        TYPE bukrs,
        sales_org           TYPE vkorg,
        agent               TYPE /eacm/zcdaz,
        currency            TYPE waers,
        amount              TYPE decfloat34,
        source_count        TYPE i,
        success             TYPE abap_bool,
      END OF ty_result,
      tt_result TYPE STANDARD TABLE OF ty_result WITH EMPTY KEY.

    METHODS run
      IMPORTING is_selection TYPE ty_selection
      RETURNING VALUE(rt_result) TYPE tt_result.

    METHODS enqueue_status_requests
      IMPORTING is_selection TYPE ty_selection
      RETURNING VALUE(rv_count) TYPE i
      RAISING /eacm/cx_eacm_posting.

    METHODS count_status_requests
      IMPORTING is_selection TYPE ty_selection
      RETURNING VALUE(rv_count) TYPE i
      RAISING /eacm/cx_eacm_posting.

    METHODS update_status_schedule_message
      IMPORTING
        is_selection TYPE ty_selection
        iv_message   TYPE string
        iv_status    TYPE /eacm/job_mte-status OPTIONAL.

    METHODS process_status
      IMPORTING is_status TYPE /eacm/job_mte
      RETURNING VALUE(rt_result) TYPE tt_result.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_config,
        company_code        TYPE bukrs,
        currency            TYPE waers,
        kokrs               TYPE kokrs,
        detail_posting      TYPE abap_bool,
        maturity_only       TYPE abap_bool,
      END OF ty_config,

      BEGIN OF ty_agent,
        agent        TYPE /eacm/zpraa-zcdaz,
        supplier     TYPE /eacm/zpraa-lifnr,
        payment_type TYPE /eacm/zpraa-ztpag,
      END OF ty_agent,

      BEGIN OF ty_prdo_info,
        payment_type TYPE /eacm/prdo-ztpag,
        doc_category TYPE /eacm/prdo-vbtyp,
        exchange_rate TYPE /eacm/prdo-kurrf,
      END OF ty_prdo_info,

      BEGIN OF ty_accounts,
        accrual_account      TYPE hkont,
        accrual_special_gl   TYPE /eacm/zcpts_cs,
        maturity_account     TYPE hkont,
        maturity_special_gl  TYPE /eacm/zccpm_cs,
        tax_code             TYPE mwskz,
      END OF ty_accounts,

      BEGIN OF ty_assignment,
        business_area TYPE gsber,
        cost_center   TYPE kostl,
        order_number  TYPE aufnr,
        profit_center TYPE prctr,
      END OF ty_assignment,

      tt_zprdp TYPE STANDARD TABLE OF /eacm/zprdp WITH EMPTY KEY,

      BEGIN OF ty_group,
        company_code            TYPE bukrs,
        sales_org               TYPE vkorg,
        distribution_chan       TYPE vtweg,
        commission_class        TYPE /eacm/zprdp-zclpr,
        billing_document        TYPE /eacm/zprdp-vbeln,
        agent                   TYPE /eacm/zcdaz,
        payment_type            TYPE /eacm/prdo-ztpag,
        currency                TYPE waers,
        business_area           TYPE gsber,
        supplier                TYPE lifnr,
        facsimile_period        TYPE /eacm/zprdp-zamcf,
        facsimile_progressive   TYPE /eacm/zprdp-zidfs,
        legacy_text_seed        TYPE c LENGTH 50,
        accounts                TYPE ty_accounts,
        assignment              TYPE ty_assignment,
        assignment_number       TYPE dzuonr,
        item_text               TYPE c LENGTH 50,
        amount                  TYPE decfloat34,
        source_rows             TYPE tt_zprdp,
      END OF ty_group,
      tt_group TYPE STANDARD TABLE OF ty_group WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_existing_document,
        exists              TYPE abap_bool,
        accounting_document TYPE belnr_d,
        fiscal_year         TYPE gjahr,
      END OF ty_existing_document.

    CONSTANTS:
      gc_msg_error     TYPE symsgty VALUE 'E',
      gc_msg_warning   TYPE symsgty VALUE 'W',
      gc_msg_success   TYPE symsgty VALUE 'S',
      gc_default_blart TYPE blart VALUE 'SA',
      gc_zero_date     TYPE d VALUE '00000000'.

    METHODS validate
      IMPORTING is_selection TYPE ty_selection
      CHANGING  ct_result    TYPE tt_result
      RETURNING VALUE(rv_valid) TYPE abap_bool.

    METHODS load_config
      IMPORTING is_selection TYPE ty_selection
      CHANGING  ct_result    TYPE tt_result
      RETURNING VALUE(rs_config) TYPE ty_config.

    METHODS load_source_rows
      IMPORTING is_selection TYPE ty_selection
      RETURNING VALUE(rt_zprdp) TYPE tt_zprdp.

    METHODS get_posting_agent_type_range
      IMPORTING it_requested_range TYPE tt_payment_type_range
      RETURNING VALUE(rt_agent_type_range) TYPE tt_payment_type_range.

    METHODS get_agent
      IMPORTING
        iv_agent     TYPE /eacm/zcdaz
        is_selection TYPE ty_selection
      RETURNING VALUE(rs_agent) TYPE ty_agent.

    METHODS get_prdo_info
      IMPORTING
        is_zprdp     TYPE /eacm/zprdp
        is_selection TYPE ty_selection
      RETURNING VALUE(rs_prdo) TYPE ty_prdo_info.

    METHODS determine_accounts
      IMPORTING
        is_zprdp  TYPE /eacm/zprdp
        is_prdo   TYPE ty_prdo_info
        is_agent  TYPE ty_agent
        is_config TYPE ty_config
      CHANGING
        ct_result TYPE tt_result
      RETURNING VALUE(rs_accounts) TYPE ty_accounts.

    METHODS determine_assignment
      IMPORTING
        is_zprdp  TYPE /eacm/zprdp
        is_config TYPE ty_config
      RETURNING VALUE(rs_assignment) TYPE ty_assignment.

    METHODS determine_business_area
      IMPORTING is_zprdp TYPE /eacm/zprdp
      RETURNING VALUE(rv_gsber) TYPE gsber.

    METHODS get_document_sign
      IMPORTING iv_vbtyp TYPE /eacm/prdo-vbtyp
      RETURNING VALUE(rv_sign) TYPE decfloat34.

    METHODS determine_assignment_number
      IMPORTING
        is_selection TYPE ty_selection
        is_group     TYPE ty_group
      RETURNING VALUE(rv_zuonr) TYPE dzuonr.

    METHODS determine_item_text
      IMPORTING
        is_selection TYPE ty_selection
        is_group     TYPE ty_group
      RETURNING VALUE(rv_text) TYPE SGTXT.

    METHODS format_by_rule
      IMPORTING
        iv_rule      TYPE /eacm/zpr43-zfratt
        is_selection TYPE ty_selection
        is_group     TYPE ty_group
      RETURNING VALUE(rv_value) TYPE string.

    METHODS get_rule_value
      IMPORTING
        iv_field     TYPE csequence
        is_selection TYPE ty_selection
        is_group     TYPE ty_group
      RETURNING VALUE(rv_value) TYPE string.

    METHODS collect_to_post
      IMPORTING
        is_selection TYPE ty_selection
        is_config    TYPE ty_config
      CHANGING
        ct_result    TYPE tt_result
      RETURNING VALUE(rt_group) TYPE tt_group.

    METHODS post_group
      IMPORTING
        is_selection TYPE ty_selection
        is_group     TYPE ty_group
      CHANGING
        ct_result    TYPE tt_result
      RETURNING VALUE(rv_success) TYPE abap_bool.

    METHODS mark_group_posted
      IMPORTING
        is_selection TYPE ty_selection
        is_group     TYPE ty_group.

    METHODS build_status_from_group
      IMPORTING
        iv_job_uuid  TYPE sysuuid_x16
        is_selection TYPE ty_selection
        is_group     TYPE ty_group
      RETURNING VALUE(rs_status) TYPE /eacm/job_mte
      RAISING /eacm/cx_eacm_posting.

    METHODS save_group_sources
      IMPORTING
        iv_job_uuid TYPE sysuuid_x16
        is_group    TYPE ty_group
      RAISING /eacm/cx_eacm_posting.

    METHODS find_group_job
      IMPORTING is_group TYPE ty_group
      RETURNING VALUE(rv_job_uuid) TYPE sysuuid_x16.

    METHODS build_group_from_status
      IMPORTING is_status TYPE /eacm/job_mte
      RETURNING VALUE(rs_group) TYPE ty_group.

    METHODS mark_status_in_process
      IMPORTING is_status TYPE /eacm/job_mte.

    METHODS mark_status_accounted
      IMPORTING
        is_status              TYPE /eacm/job_mte
        iv_message             TYPE string
        iv_accounting_document TYPE belnr_d OPTIONAL
        iv_fiscal_year         TYPE gjahr OPTIONAL.

    METHODS mark_status_error
      IMPORTING
        is_status  TYPE /eacm/job_mte
        iv_message TYPE string.

    METHODS mark_source_rows_posted
      IMPORTING is_status TYPE /eacm/job_mte.

    METHODS recover_in_process_status
      IMPORTING is_status TYPE /eacm/job_mte
      RETURNING VALUE(rv_recovered) TYPE abap_bool.

    METHODS read_existing_document
      IMPORTING
        iv_bukrs TYPE bukrs
        iv_gjahr TYPE gjahr
        iv_xblnr TYPE xblnr
      RETURNING VALUE(rs_document) TYPE ty_existing_document.

    METHODS build_error_message
      IMPORTING it_result TYPE tt_result
      RETURNING VALUE(rv_message) TYPE string.

    METHODS build_exception_message
      IMPORTING ix_error TYPE REF TO cx_root
      RETURNING VALUE(rv_message) TYPE string.

    METHODS append_message
      IMPORTING
        iv_type  TYPE symsgty
        iv_text  TYPE string
        iv_agent TYPE /eacm/zcdaz OPTIONAL
      CHANGING
        ct_result TYPE tt_result.

ENDCLASS.


CLASS /eacm/cl_mte_posting IMPLEMENTATION.

  METHOD run.
    IF validate(
         EXPORTING is_selection = is_selection
         CHANGING  ct_result    = rt_result ) = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_config) = load_config(
      EXPORTING is_selection = is_selection
      CHANGING  ct_result    = rt_result ).
    IF ls_config-company_code IS INITIAL
       OR line_exists( rt_result[ type = gc_msg_error ] ).
      RETURN.
    ENDIF.

    DATA(lt_groups) = collect_to_post(
      EXPORTING
        is_selection = is_selection
        is_config    = ls_config
      CHANGING
        ct_result    = rt_result ).

    IF lt_groups IS INITIAL
       AND NOT line_exists( rt_result[ type = gc_msg_error ] ).
      append_message(
        EXPORTING
          iv_type = gc_msg_warning
          iv_text = 'Nessuna provvigione MTE da contabilizzare.'
        CHANGING
          ct_result = rt_result ).
      RETURN.
    ENDIF.

    LOOP AT lt_groups INTO DATA(ls_group).
      IF is_selection-test_run = abap_true.
        append_message(
          EXPORTING
            iv_type = gc_msg_success
            iv_text = |Simulazione MTE: agente { ls_group-agent }, importo { ls_group-amount } { ls_group-currency }, righe { lines( ls_group-source_rows ) }.|
            iv_agent = ls_group-agent
          CHANGING
            ct_result = rt_result ).
        CONTINUE.
      ENDIF.

      IF post_group(
           EXPORTING
             is_selection = is_selection
             is_group     = ls_group
           CHANGING
             ct_result    = rt_result ) = abap_true.
        IF is_selection-defer_status_update = abap_false.
          mark_group_posted(
            is_selection = is_selection
            is_group     = ls_group ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate.
    rv_valid = abap_true.

    IF is_selection-company_code IS INITIAL.
      rv_valid = abap_false.
      append_message(
        EXPORTING iv_type = gc_msg_error
                  iv_text = 'Societa obbligatoria.'
        CHANGING  ct_result = ct_result ).
    ENDIF.

    IF is_selection-document_date IS INITIAL.
      rv_valid = abap_false.
      append_message(
        EXPORTING iv_type = gc_msg_error
                  iv_text = 'Data documento obbligatoria.'
        CHANGING  ct_result = ct_result ).
    ENDIF.

    IF is_selection-posting_date IS INITIAL.
      rv_valid = abap_false.
      append_message(
        EXPORTING iv_type = gc_msg_error
                  iv_text = 'Data registrazione obbligatoria.'
        CHANGING  ct_result = ct_result ).
    ENDIF.

    IF is_selection-assignment_rule IS INITIAL
       AND is_selection-assignment_reference IS INITIAL.
      rv_valid = abap_false.
      append_message(
        EXPORTING
          iv_type = gc_msg_error
          iv_text = 'Indicare una regola di attribuzione o un riferimento attribuzione.'
        CHANGING
          ct_result = ct_result ).
    ENDIF.

    IF is_selection-use_document_date_rate = abap_true.
      append_message(
        EXPORTING
          iv_type = gc_msg_warning
          iv_text = 'Il wrapper Journal Entry corrente non valorizza manualmente il cambio: verra usata la determinazione standard API.'
        CHANGING
          ct_result = ct_result ).
    ENDIF.
  ENDMETHOD.

  METHOD load_config.
    DATA lv_space TYPE c LENGTH 1.

    rs_config-company_code = is_selection-company_code.

    SELECT SINGLE znelo, zdett
      FROM /eacm/zpr01
      WHERE bukrs = @is_selection-company_code
      INTO (@DATA(lv_maturity_only), @DATA(lv_detail)).

    rs_config-maturity_only = xsdbool( lv_maturity_only = 'X' ).
    rs_config-detail_posting = xsdbool( lv_detail = 'X' ).

    IF rs_config-detail_posting = abap_true.
      append_message(
        EXPORTING
          iv_type = gc_msg_error
          iv_text = |/EACM/ZPR01-ZDETT attivo per societa { is_selection-company_code }: la classe cloud gestisce il riepilogo MTE; implementare il dettaglio RAP/cloud.|
        CHANGING
          ct_result = ct_result ).
    ENDIF.

    SELECT SINGLE waers
      FROM /eacm/t001
      WHERE bukrs = @is_selection-company_code
      INTO @rs_config-currency.

    IF rs_config-currency IS INITIAL.
      rs_config-currency = 'EUR'.
    ENDIF.

    SELECT SINGLE kokrs
      FROM /eacm/t001
      WHERE bukrs = @is_selection-company_code
      INTO @rs_config-kokrs.

    IF rs_config-kokrs IS INITIAL.
      rs_config-kokrs = '9999'.
    ENDIF.
  ENDMETHOD.

  METHOD load_source_rows.
    DATA:
      lv_has_agent_range TYPE abap_bool,
      lv_has_sales_org_range TYPE abap_bool,
      lv_has_class_range TYPE abap_bool,
      lv_has_billing_range TYPE abap_bool,
      lv_has_facsimile_period_range TYPE abap_bool.

    lv_has_agent_range = xsdbool( is_selection-agent_range IS NOT INITIAL ).
    lv_has_sales_org_range = xsdbool( is_selection-sales_org_range IS NOT INITIAL ).
    lv_has_class_range = xsdbool( is_selection-commission_class_range IS NOT INITIAL ).
    lv_has_billing_range = xsdbool( is_selection-billing_document_range IS NOT INITIAL ).
    lv_has_facsimile_period_range = xsdbool( is_selection-facsimile_period_range IS NOT INITIAL ).

    SELECT *  "#EC CI_ALL_FIELDS_NEEDED
      FROM /eacm/zprdp
      WHERE bukrs = @is_selection-company_code
        AND zdtsf <> @gc_zero_date
        AND zstre <> 'C'
        AND zstre <> 'D'
        AND ( @lv_has_facsimile_period_range = @abap_false
              OR zamcf IN @is_selection-facsimile_period_range )
        AND ( @lv_has_agent_range = @abap_false OR zcdaz IN @is_selection-agent_range )
        AND ( @lv_has_sales_org_range = @abap_false OR vkorg IN @is_selection-sales_org_range )
        AND ( @lv_has_class_range = @abap_false OR zclpr IN @is_selection-commission_class_range )
        AND ( @lv_has_billing_range = @abap_false OR vbeln IN @is_selection-billing_document_range )
      ORDER BY bukrs, vkorg, zcdaz, vbeln, posnr, zidfs
      INTO TABLE @rt_zprdp.
  ENDMETHOD.

  METHOD get_posting_agent_type_range.
    DATA lt_agent_types TYPE STANDARD TABLE OF /eacm/zpr02-ztpag WITH EMPTY KEY.

    IF it_requested_range IS INITIAL.
      SELECT DISTINCT ztpag
        FROM /eacm/zpr02
        WHERE zcont = 'X'
        INTO TABLE @lt_agent_types.
    ELSE.
      SELECT DISTINCT ztpag
        FROM /eacm/zpr02
        WHERE zcont = 'X'
          AND ztpag IN @it_requested_range
        INTO TABLE @lt_agent_types.
    ENDIF.

    LOOP AT lt_agent_types INTO DATA(lv_agent_type).
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = lv_agent_type ) TO rt_agent_type_range.
    ENDLOOP.

    "Legacy CHECK_RANGE: un range vuoto deve selezionare soltanto il valore iniziale.
    IF rt_agent_type_range IS INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ' ) TO rt_agent_type_range.
    ENDIF.
  ENDMETHOD.

  METHOD get_agent.
    DATA lv_has_payment_range TYPE abap_bool.
    DATA lt_agent TYPE STANDARD TABLE OF ty_agent WITH EMPTY KEY.

    lv_has_payment_range = xsdbool( is_selection-payment_type_range IS NOT INITIAL ).

    SELECT zcdaz AS agent,
           lifnr AS supplier,
           ztpag AS payment_type
      FROM /eacm/zpraa
      WHERE zcdaz = @iv_agent
        AND erdat <= @is_selection-posting_date
        AND zstre <> 'A'
        AND zstre <> 'S'
        AND ( @lv_has_payment_range = @abap_false OR ztpag IN @is_selection-payment_type_range )
      ORDER BY erdat DESCENDING
      INTO TABLE @lt_agent.

    READ TABLE lt_agent INTO rs_agent INDEX 1.
  ENDMETHOD.

  METHOD get_prdo_info.
    DATA lv_has_payment_range TYPE abap_bool.

    lv_has_payment_range = xsdbool( is_selection-payment_type_range IS NOT INITIAL ).

    SELECT SINGLE ztpag, vbtyp, kurrf
      FROM /eacm/prdo
      WHERE vkorg = @is_zprdp-vkorg
        AND vtweg = @is_zprdp-vtweg
        AND zclpr = @is_zprdp-zclpr
        AND vbeln = @is_zprdp-vbeln
        AND posnr = @is_zprdp-posnr
        AND zcdaz = @is_zprdp-zcdaz
        AND zidag = @is_zprdp-zidag
        AND ( @lv_has_payment_range = @abap_false OR ztpag IN @is_selection-payment_type_range )
      INTO (@rs_prdo-payment_type,
            @rs_prdo-doc_category,
            @rs_prdo-exchange_rate).
  ENDMETHOD.

  METHOD determine_accounts.
    DATA lv_space TYPE c LENGTH 1.
    DATA(lv_currency) = COND waers(
      WHEN is_zprdp-waerk IS INITIAL THEN is_zprdp-zwaer
      ELSE is_zprdp-waerk ).

    IF is_config-maturity_only = abap_true.
      SELECT SINGLE zccos
        FROM /eacm/zprse
        WHERE bukrs  = @is_zprdp-bukrs
          AND ztpag  = @is_prdo-payment_type
          AND waerk  = @lv_currency
          AND zclpr = @is_zprdp-zclpr
          AND vkorg  = @is_zprdp-vkorg
        INTO @rs_accounts-accrual_account.

      IF rs_accounts-accrual_account IS INITIAL.
        SELECT SINGLE zccos
          FROM /eacm/zprse
          WHERE bukrs  = @is_zprdp-bukrs
            AND ztpag  = @is_prdo-payment_type
            AND waerk  = @lv_currency
            AND zclpr = @lv_space
            AND vkorg  = @is_zprdp-vkorg
          INTO @rs_accounts-accrual_account.
      ENDIF.

      IF rs_accounts-accrual_account IS INITIAL.
        SELECT SINGLE zccos
          FROM /eacm/zprse
          WHERE bukrs  = @is_zprdp-bukrs
            AND ztpag  = @is_prdo-payment_type
            AND waerk  = @lv_currency
            AND zclpr = @is_zprdp-zclpr
            AND vkorg  = @lv_space
          INTO @rs_accounts-accrual_account.
      ENDIF.

      IF rs_accounts-accrual_account IS INITIAL.
        SELECT SINGLE zccos
          FROM /eacm/zprse
          WHERE bukrs  = @is_zprdp-bukrs
            AND ztpag  = @is_prdo-payment_type
            AND waerk  = @lv_currency
            AND zclpr = @lv_space
            AND vkorg  = @lv_space
          INTO @rs_accounts-accrual_account.
      ENDIF.
    ENDIF.

    SELECT SINGLE zcpts, zcpts_cs, zcppm, zcppm_cs, mwskz
      FROM /eacm/zprsp
      WHERE bukrs = @is_zprdp-bukrs
        AND ztpag = @is_prdo-payment_type
        AND waerk = @lv_currency
        AND vkorg = @is_zprdp-vkorg
      INTO (@DATA(lv_zcpts),
            @rs_accounts-accrual_special_gl,
            @rs_accounts-maturity_account,
            @rs_accounts-maturity_special_gl,
            @rs_accounts-tax_code).

    IF sy-subrc <> 0
       OR ( lv_zcpts IS INITIAL
            AND rs_accounts-accrual_special_gl IS INITIAL ).
      SELECT SINGLE zcpts, zcpts_cs, zcppm, zcppm_cs, mwskz
        FROM /eacm/zprsp
        WHERE bukrs = @is_zprdp-bukrs
          AND ztpag = @is_prdo-payment_type
          AND waerk = @lv_currency
        INTO (@lv_zcpts,
              @rs_accounts-accrual_special_gl,
              @rs_accounts-maturity_account,
              @rs_accounts-maturity_special_gl,
              @rs_accounts-tax_code).
    ENDIF.

    IF lv_zcpts IS INITIAL
       AND rs_accounts-accrual_special_gl IS INITIAL.
      append_message(
        EXPORTING
          iv_type = gc_msg_error
          iv_text = |ZPRSP non trovato per agente { is_zprdp-zcdaz }, tipo { is_prdo-payment_type }, valuta { lv_currency }.|
          iv_agent = is_zprdp-zcdaz
        CHANGING
          ct_result = ct_result ).
      CLEAR rs_accounts.
      RETURN.
    ENDIF.

    IF is_config-maturity_only = abap_false.
      rs_accounts-accrual_account = lv_zcpts.
    ENDIF.

    IF rs_accounts-accrual_account IS INITIAL
       AND rs_accounts-accrual_special_gl IS INITIAL.
      append_message(
        EXPORTING
          iv_type = gc_msg_error
          iv_text = |Conto maturande MTE non trovato per agente { is_zprdp-zcdaz }, tipo { is_prdo-payment_type }, valuta { lv_currency }.|
          iv_agent = is_zprdp-zcdaz
        CHANGING
          ct_result = ct_result ).
    ENDIF.

    IF rs_accounts-maturity_account IS INITIAL
       AND rs_accounts-maturity_special_gl IS INITIAL.
      append_message(
        EXPORTING
          iv_type = gc_msg_error
          iv_text = |Conto maturate MTE non trovato in /EACM/ZPRSP per agente { is_zprdp-zcdaz }, tipo { is_prdo-payment_type }, valuta { lv_currency }.|
          iv_agent = is_zprdp-zcdaz
        CHANGING
          ct_result = ct_result ).
    ENDIF.

    IF ( rs_accounts-accrual_account IS INITIAL
         AND rs_accounts-accrual_special_gl IS NOT INITIAL
         OR rs_accounts-maturity_account IS INITIAL
         AND rs_accounts-maturity_special_gl IS NOT INITIAL )
       AND is_agent-supplier IS INITIAL.
      append_message(
        EXPORTING
          iv_type = gc_msg_error
          iv_text = |Fornitore non trovato per agente { is_zprdp-zcdaz }: necessario per la contabilizzazione Special G/L.|
          iv_agent = is_zprdp-zcdaz
        CHANGING
          ct_result = ct_result ).
    ENDIF.
  ENDMETHOD.

  METHOD determine_assignment.
    rs_assignment-business_area = determine_business_area( is_zprdp ).

    SELECT SINGLE kostl, aufnr, prctr
      FROM /eacm/zpr13
      WHERE kokrs = @is_config-kokrs
        AND vkorg = @is_zprdp-vkorg
        AND zclpr = @is_zprdp-zclpr
        AND zcdaz = @is_zprdp-zcdaz
      INTO (@rs_assignment-cost_center,
            @rs_assignment-order_number,
            @rs_assignment-profit_center).

    IF sy-subrc <> 0 OR rs_assignment-profit_center IS INITIAL.
      SELECT SINGLE kostl, aufnr, prctr
        FROM /eacm/zpr13
        WHERE kokrs = @is_config-kokrs
          AND vkorg = @is_zprdp-vkorg
          AND zclpr = @is_zprdp-zclpr
        INTO (@rs_assignment-cost_center,
              @rs_assignment-order_number,
              @rs_assignment-profit_center).
    ENDIF.
  ENDMETHOD.

  METHOD determine_business_area.
  "attualmente su /EACM/ZPR43 non è presente questo caso: campo = 'GSBER'
  "quindi per ora non lo gestiamo (le tabelle vbrp e tvta non non accessibili da btp)
*    SELECT SINGLE spart
*      FROM vbrp
*      WHERE vbeln = @is_zprdp-vbeln
*        AND posnr = @is_zprdp-posnr
*      INTO @DATA(lv_spart).
*
*    SELECT SINGLE gsber
*      FROM tvta
*      WHERE vkorg = @is_zprdp-vkorg
*        AND vtweg = @is_zprdp-vtweg
*        AND spart = @lv_spart
*      INTO @rv_gsber.

    IF rv_gsber IS INITIAL.
      SELECT SINGLE gsber
        FROM /eacm/toc2sc
        WHERE vkorg = @is_zprdp-vkorg
        INTO @rv_gsber.
    ENDIF.
  ENDMETHOD.

  METHOD get_document_sign.
    rv_sign = 1.

    SELECT SINGLE zsegn
      FROM /eacm/zpr48
      WHERE vbtyp = @iv_vbtyp
      INTO @DATA(lv_sign).

    IF sy-subrc = 0 AND lv_sign IS NOT INITIAL.
      IF lv_sign = '-1'.
        rv_sign = -1.
      ELSE.
        rv_sign = 1.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD determine_assignment_number.
    rv_zuonr = is_selection-assignment_reference.

    IF rv_zuonr IS INITIAL AND is_selection-assignment_rule IS NOT INITIAL.
      rv_zuonr = format_by_rule(
        iv_rule      = is_selection-assignment_rule
        is_selection = is_selection
        is_group     = is_group ).
    ENDIF.

    IF rv_zuonr IS INITIAL.
      rv_zuonr = is_group-agent.
    ENDIF.
  ENDMETHOD.

  METHOD determine_item_text.
    rv_text = is_selection-item_text.

    IF rv_text IS INITIAL AND is_selection-text_rule IS NOT INITIAL.
      rv_text = format_by_rule(
        iv_rule      = is_selection-text_rule
        is_selection = is_selection
        is_group     = is_group ).
    ENDIF.

    IF rv_text IS INITIAL AND is_group-legacy_text_seed IS NOT INITIAL.
      rv_text = is_group-legacy_text_seed.
    ENDIF.

    IF rv_text IS INITIAL.
      rv_text = 'eACM - MTE'.
    ENDIF.
  ENDMETHOD.

  METHOD format_by_rule.
    FIELD-SYMBOLS:
      <field_name> TYPE any,
      <field_len>  TYPE any.

    DATA ls_rule TYPE /eacm/zpr43.
    DATA lv_part TYPE string.
    DATA lv_len TYPE i.

    SELECT SINGLE *  "#EC CI_ALL_FIELDS_NEEDED
      FROM /eacm/zpr43
      WHERE zfratt = @iv_rule
      INTO @ls_rule.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DO 5 TIMES.
      DATA(lv_index) = sy-index.

      UNASSIGN: <field_name>, <field_len>.
      ASSIGN COMPONENT |ZFIELD{ lv_index }| OF STRUCTURE ls_rule TO <field_name>.
      ASSIGN COMPONENT |ZLENG{ lv_index }| OF STRUCTURE ls_rule TO <field_len>.

      IF <field_name> IS NOT ASSIGNED OR <field_name> IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_part = get_rule_value(
        iv_field     = CONV string( <field_name> )
        is_selection = is_selection
        is_group     = is_group ).
      IF lv_part IS INITIAL.
        CONTINUE.
      ENDIF.

      CLEAR lv_len.
      IF <field_len> IS ASSIGNED AND <field_len> IS NOT INITIAL.
        lv_len = <field_len>.
      ENDIF.

      IF lv_len > 0 AND strlen( lv_part ) > lv_len.
        CONCATENATE rv_value lv_part(lv_len) INTO rv_value.
      ELSE.
        CONCATENATE rv_value lv_part INTO rv_value.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD get_rule_value.
    DATA(lv_field) = to_upper( iv_field ).

    CASE lv_field.
      WHEN 'BLDAT'.
        rv_value = is_selection-document_date.
      WHEN 'BUDAT'.
        rv_value = is_selection-posting_date.
      WHEN 'BUKRS'.
        rv_value = is_group-company_code.
      WHEN 'VKORG'.
        rv_value = is_group-sales_org.
      WHEN 'ZCDAZ' OR 'ZZCDAZ'.
        rv_value = is_group-agent.
      WHEN 'LIFNR' OR 'NAME1'.
        rv_value = is_group-supplier.
      WHEN 'GSBER'.
        rv_value = is_group-business_area.
      WHEN 'WAERK' OR 'ZWAER'.
        rv_value = is_group-currency.
      WHEN 'ZTPAG' OR 'ZZTPAG'.
        rv_value = is_group-payment_type.
      WHEN 'ZCLPR' OR 'ZZCLPR'.
        rv_value = is_group-commission_class.
      WHEN 'ZAMCF'.
        rv_value = is_group-facsimile_period.
      WHEN 'ZIDFS'.
        rv_value = is_group-facsimile_progressive.
      WHEN 'SGTXT'.
        rv_value = is_group-legacy_text_seed.
      WHEN OTHERS.
        CLEAR rv_value.
    ENDCASE.
  ENDMETHOD.

  METHOD collect_to_post.
    DATA(ls_effective_selection) = is_selection.
    ls_effective_selection-payment_type_range = get_posting_agent_type_range(
      is_selection-payment_type_range ).

    DATA(lt_zprdp) = load_source_rows( ls_effective_selection ).
    DATA ls_group TYPE ty_group.
    DATA lv_group_index TYPE sy-tabix.
    DATA lv_update_index TYPE sy-tabix.

    LOOP AT lt_zprdp INTO DATA(ls_zprdp).
      DATA(ls_prdo) = get_prdo_info(
        is_zprdp     = ls_zprdp
        is_selection = ls_effective_selection ).

      IF ls_prdo-payment_type IS INITIAL.
        append_message(
          EXPORTING
            iv_type = gc_msg_warning
            iv_text = |Riga MTE { ls_zprdp-vbeln }/{ ls_zprdp-posnr } agente { ls_zprdp-zcdaz }: documento PRDO o tipo agente non trovato.|
            iv_agent = ls_zprdp-zcdaz
          CHANGING
            ct_result = ct_result ).
        CONTINUE.
      ENDIF.

      DATA(ls_agent) = get_agent(
        iv_agent     = ls_zprdp-zcdaz
        is_selection = ls_effective_selection ).

      IF ls_agent-agent IS INITIAL.
        append_message(
          EXPORTING
            iv_type = gc_msg_warning
            iv_text = |Agente { ls_zprdp-zcdaz } non trovato o non ammesso alla data { is_selection-posting_date }.|
            iv_agent = ls_zprdp-zcdaz
          CHANGING
            ct_result = ct_result ).
        CONTINUE.
      ENDIF.

      DATA(ls_accounts) = determine_accounts(
        EXPORTING
          is_zprdp  = ls_zprdp
          is_prdo   = ls_prdo
          is_agent  = ls_agent
          is_config = is_config
        CHANGING
          ct_result = ct_result ).

      IF ( ls_accounts-accrual_account IS INITIAL
           AND ls_accounts-accrual_special_gl IS INITIAL )
         OR ( ls_accounts-maturity_account IS INITIAL
              AND ls_accounts-maturity_special_gl IS INITIAL )
         OR ( ( ls_accounts-accrual_account IS INITIAL
                AND ls_accounts-accrual_special_gl IS NOT INITIAL
                OR ls_accounts-maturity_account IS INITIAL
                AND ls_accounts-maturity_special_gl IS NOT INITIAL )
              AND ls_agent-supplier IS INITIAL ).
        CONTINUE.
      ENDIF.

      DATA(ls_assignment) = determine_assignment(
        is_zprdp  = ls_zprdp
        is_config = is_config ).

      DATA(lv_currency) = COND waers(
        WHEN ls_zprdp-waerk IS INITIAL THEN ls_zprdp-zwaer
        ELSE ls_zprdp-waerk ).
      DATA(lv_amount) = CONV decfloat34( ls_zprdp-ziprv )
                        * get_document_sign( ls_prdo-doc_category ).

      IF lv_amount = 0.
        CONTINUE.
      ENDIF.

      DATA lv_legacy_text TYPE c LENGTH 50.
      CONCATENATE ls_zprdp-zamco ls_zprdp-zidfs INTO lv_legacy_text.

      CLEAR lv_group_index.
      LOOP AT rt_group INTO ls_group
        WHERE company_code      = ls_zprdp-bukrs
          AND sales_org         = ls_zprdp-vkorg
          AND distribution_chan = ls_zprdp-vtweg
          AND commission_class  = ls_zprdp-zclpr
          AND agent             = ls_zprdp-zcdaz
          AND payment_type      = ls_prdo-payment_type
          AND currency          = lv_currency
          AND business_area     = ls_assignment-business_area
          AND supplier          = ls_agent-supplier
          AND facsimile_period  = ls_zprdp-zamcf
          AND legacy_text_seed  = lv_legacy_text.
        IF ls_group-accounts = ls_accounts
           AND ls_group-assignment = ls_assignment.
          lv_group_index = sy-tabix.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_group_index IS INITIAL.
        APPEND VALUE #(
          company_code          = ls_zprdp-bukrs
          sales_org             = ls_zprdp-vkorg
          distribution_chan     = ls_zprdp-vtweg
          commission_class      = ls_zprdp-zclpr
          billing_document      = ls_zprdp-vbeln
          agent                 = ls_zprdp-zcdaz
          payment_type          = ls_prdo-payment_type
          currency              = lv_currency
          business_area         = ls_assignment-business_area
          supplier              = ls_agent-supplier
          facsimile_period      = ls_zprdp-zamcf
          facsimile_progressive = ls_zprdp-zidfs
          legacy_text_seed      = lv_legacy_text
          accounts              = ls_accounts
          assignment            = ls_assignment ) TO rt_group.
        lv_group_index = lines( rt_group ).
      ENDIF.

      CLEAR ls_group.
      READ TABLE rt_group INDEX lv_group_index INTO ls_group.
      IF sy-subrc = 0.
        ls_group-amount += lv_amount.
        APPEND ls_zprdp TO ls_group-source_rows.
        MODIFY rt_group FROM ls_group INDEX lv_group_index.
      ENDIF.
    ENDLOOP.

    LOOP AT rt_group INTO ls_group.
      lv_update_index = sy-tabix.

      ls_group-assignment_number = determine_assignment_number(
        is_selection = is_selection
        is_group     = ls_group ).
      ls_group-item_text = determine_item_text(
        is_selection = is_selection
        is_group     = ls_group ).
      MODIFY rt_group FROM ls_group INDEX lv_update_index.
    ENDLOOP.
  ENDMETHOD.

  METHOD post_group.
    rv_success = abap_false.

    DATA(lv_blart) = COND blart(
      WHEN is_selection-accounting_document_type IS INITIAL
      THEN gc_default_blart
      ELSE is_selection-accounting_document_type ).

    DATA(ls_request) = VALUE /eacm/cl_eacm_journal_post_api=>ty_request(
      company_code                = is_group-company_code
      document_date               = is_selection-document_date
      posting_date                = is_selection-posting_date
      accounting_document_type    = lv_blart
      original_reference_document = COND #(
        WHEN is_selection-external_reference IS NOT INITIAL
        THEN is_selection-external_reference
        WHEN is_group-assignment_number IS INITIAL
        THEN is_group-agent
        ELSE is_group-assignment_number )
      document_header_text        = 'Contabilizzazione MTE'
      created_by_user             = cl_abap_context_info=>get_user_technical_name( ) ).

    DATA(lv_abs_amount) = abs( is_group-amount ).

    APPEND VALUE /eacm/cl_eacm_journal_post_api=>ty_gl_item(
      gl_account        = is_group-accounts-accrual_account
      supplier          = COND #( WHEN is_group-accounts-accrual_account IS INITIAL
                                  THEN is_group-supplier )
      special_gl_code   = COND #( WHEN is_group-accounts-accrual_account IS INITIAL
                                  THEN is_group-accounts-accrual_special_gl )
      amount            = lv_abs_amount
      currency_code     = is_group-currency
      debit_credit_code = COND #( WHEN is_group-amount < 0 THEN 'H' ELSE 'S' )
      assignment_ref    = is_group-assignment_number
      "EM: aggiunto
      tax_code          = 'KZ' "is_group-accounts-tax_code
      item_text         = COND #( WHEN is_group-item_text IS INITIAL THEN 'eACM - MTE Maturande' ELSE is_group-item_text ) )
      TO ls_request-items.

    APPEND VALUE /eacm/cl_eacm_journal_post_api=>ty_gl_item(
      gl_account        = is_group-accounts-maturity_account
      supplier          = COND #( WHEN is_group-accounts-maturity_account IS INITIAL
                                  THEN is_group-supplier )
      special_gl_code   = COND #( WHEN is_group-accounts-maturity_account IS INITIAL
                                  THEN is_group-accounts-maturity_special_gl )
      amount            = lv_abs_amount
      currency_code     = is_group-currency
      debit_credit_code = COND #( WHEN is_group-amount < 0 THEN 'S' ELSE 'H' )
      assignment_ref    = is_group-assignment_number
      "EM: aggiunto
      tax_code          = 'KZ' "is_group-accounts-tax_code
      item_text         = COND #( WHEN is_group-item_text IS INITIAL THEN 'eACM - MTE Maturate' ELSE is_group-item_text ) )
      TO ls_request-items.

    DATA(ls_response) = NEW /eacm/cl_eacm_journal_post_api( )->post_journal_entry( ls_request ).
    DATA(lv_detail_type) = COND symsgty(
      WHEN ls_response-success = abap_false THEN gc_msg_error
      ELSE 'I' ).

    LOOP AT ls_response-message_details INTO DATA(lv_detail).
      append_message(
        EXPORTING
          iv_type = lv_detail_type
          iv_text = lv_detail
          iv_agent = is_group-agent
        CHANGING
          ct_result = ct_result ).
    ENDLOOP.

    IF ls_response-success = abap_false.
      append_message(
        EXPORTING
          iv_type = gc_msg_error
          iv_text = COND #( WHEN ls_response-message_text IS INITIAL
                            THEN |Contabilizzazione MTE non riuscita per agente { is_group-agent }.|
                            ELSE ls_response-message_text )
          iv_agent = is_group-agent
        CHANGING
          ct_result = ct_result ).
      RETURN.
    ENDIF.

    rv_success = abap_true.
    APPEND VALUE #(
      type                = gc_msg_success
      message_text        = COND #( WHEN ls_response-message_text IS INITIAL
                                    THEN |Contabilizzazione MTE creata per agente { is_group-agent }.|
                                    ELSE ls_response-message_text )
      accounting_document = ls_response-accounting_document
      fiscal_year         = ls_response-fiscal_year
      company_code        = is_group-company_code
      sales_org           = is_group-sales_org
      agent               = is_group-agent
      currency            = is_group-currency
      amount              = is_group-amount
      source_count        = lines( is_group-source_rows )
      success             = abap_true ) TO ct_result.
  ENDMETHOD.

  METHOD mark_group_posted.
    LOOP AT is_group-source_rows INTO DATA(ls_zprdp).
      ls_zprdp-budat = is_selection-posting_date.
      ls_zprdp-zstre = 'C'.
      ls_zprdp-zcamd = cl_abap_context_info=>get_user_technical_name( ).
*      ls_zprdp-tcode = sy-tcode.
      ls_zprdp-zdtmd = cl_abap_context_info=>get_system_date( ).
      ls_zprdp-zormd = cl_abap_context_info=>get_system_time( ).

      MODIFY /eacm/zprdp FROM @ls_zprdp.
    ENDLOOP.
  ENDMETHOD.

  METHOD append_message.
    APPEND VALUE #(
      type = iv_type
      message_text = iv_text
      agent = iv_agent ) TO ct_result.
  ENDMETHOD.


  METHOD enqueue_status_requests.
    DATA lt_result TYPE tt_result.
    DATA lv_now TYPE /eacm/job_mte-changed_at.
    DATA lv_exists TYPE abap_bool.

    IF is_selection-test_run = abap_true.
      RETURN.
    ENDIF.

    IF validate(
         EXPORTING is_selection = is_selection
         CHANGING  ct_result    = lt_result ) = abap_false.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING iv_text = build_error_message( lt_result ).
    ENDIF.

    DATA(ls_config) = load_config(
      EXPORTING is_selection = is_selection
      CHANGING  ct_result    = lt_result ).

    DATA(lt_groups) = collect_to_post(
      EXPORTING
        is_selection = is_selection
        is_config    = ls_config
      CHANGING
        ct_result    = lt_result ).

    IF line_exists( lt_result[ type = 'E' ] )
       OR line_exists( lt_result[ type = 'A' ] )
       OR line_exists( lt_result[ type = 'X' ] ).
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING iv_text = build_error_message( lt_result ).
    ENDIF.

    GET TIME STAMP FIELD lv_now.

    LOOP AT lt_groups INTO DATA(ls_group).
      DATA(lv_job_uuid) = find_group_job( ls_group ).

      IF lv_job_uuid IS NOT INITIAL.
        SELECT SINGLE status
          FROM /eacm/job_mte
          WHERE job_uuid = @lv_job_uuid
          INTO @DATA(lv_status).

        IF lv_status = 'I' OR lv_status = 'W' OR lv_status = 'C'.
          CONTINUE.
        ENDIF.
      ELSE.
        TRY.
            lv_job_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error INTO DATA(lx_uuid).
            RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
              EXPORTING iv_text = lx_uuid->get_text( ).
        ENDTRY.
      ENDIF.

      DATA(ls_status) = build_status_from_group(
        iv_job_uuid  = lv_job_uuid
        is_selection = is_selection
        is_group     = ls_group ).

      CLEAR lv_exists.
      SELECT SINGLE @abap_true
        FROM /eacm/job_mte
        WHERE job_uuid = @lv_job_uuid
        INTO @lv_exists.

      IF lv_exists = abap_true.
        ls_status-changed_by = sy-uname.
        ls_status-changed_at = lv_now.
        ls_status-last_message = 'Richiesta MTE pronta per contabilizzazione'.

        UPDATE /eacm/job_mte
          SET status               = 'I',
              bldat                = @ls_status-bldat,
              budat                = @ls_status-budat,
              blart                = @ls_status-blart,
              use_doc_rate         = @ls_status-use_doc_rate,
              assignment_rule      = @ls_status-assignment_rule,
              assignment_reference = @ls_status-assignment_reference,
              text_rule            = @ls_status-text_rule,
              item_text            = @ls_status-item_text,
              lifnr                 = @ls_status-lifnr,
              accrual_account       = @ls_status-accrual_account,
              accrual_special_gl    = @ls_status-accrual_special_gl,
              maturity_account      = @ls_status-maturity_account,
              maturity_special_gl   = @ls_status-maturity_special_gl,
              amount               = @ls_status-amount,
              source_count         = @ls_status-source_count,
              belnr                = '',
              belnr_gjahr          = '',
              changed_by           = @sy-uname,
              changed_at           = @lv_now,
              last_message         = @ls_status-last_message
          WHERE job_uuid = @lv_job_uuid.

        " Ricostruisce il dettaglio in caso di retry E, per recepire eventuali
        " variazioni di configurazione o raggruppamento intervenute nel frattempo.
        DELETE FROM /eacm/job_mtesrc
          WHERE job_uuid = @lv_job_uuid.
      ELSE.
        ls_status-created_by = sy-uname.
        ls_status-created_at = lv_now.
        ls_status-changed_by = sy-uname.
        ls_status-changed_at = lv_now.
        ls_status-last_message = 'Richiesta MTE pronta per contabilizzazione'.
        INSERT /eacm/job_mte FROM @ls_status.
      ENDIF.

      save_group_sources(
        iv_job_uuid = lv_job_uuid
        is_group    = ls_group ).
      rv_count += 1.
    ENDLOOP.
  ENDMETHOD.


  METHOD count_status_requests.
    DATA lt_result TYPE tt_result.

    IF is_selection-test_run = abap_true.
      RETURN.
    ENDIF.

    IF validate(
         EXPORTING is_selection = is_selection
         CHANGING  ct_result    = lt_result ) = abap_false.
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING iv_text = build_error_message( lt_result ).
    ENDIF.

    DATA(ls_config) = load_config(
      EXPORTING is_selection = is_selection
      CHANGING  ct_result    = lt_result ).
    DATA(lt_groups) = collect_to_post(
      EXPORTING
        is_selection = is_selection
        is_config    = ls_config
      CHANGING
        ct_result    = lt_result ).

    IF line_exists( lt_result[ type = 'E' ] )
       OR line_exists( lt_result[ type = 'A' ] )
       OR line_exists( lt_result[ type = 'X' ] ).
      RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
        EXPORTING iv_text = build_error_message( lt_result ).
    ENDIF.

    LOOP AT lt_groups INTO DATA(ls_group).
      DATA(lv_job_uuid) = find_group_job( ls_group ).
      IF lv_job_uuid IS NOT INITIAL.
        SELECT SINGLE status
          FROM /eacm/job_mte
          WHERE job_uuid = @lv_job_uuid
          INTO @DATA(lv_status).
        IF lv_status = 'I' OR lv_status = 'W' OR lv_status = 'C'.
          CONTINUE.
        ENDIF.
      ENDIF.
      rv_count += 1.
    ENDLOOP.
  ENDMETHOD.


  METHOD update_status_schedule_message.
    DATA lv_now TYPE /eacm/job_mte-changed_at.
    DATA lv_has_agent_range TYPE abap_bool.
    DATA lv_has_sales_org_range TYPE abap_bool.

    lv_has_agent_range = xsdbool( is_selection-agent_range IS NOT INITIAL ).
    lv_has_sales_org_range = xsdbool( is_selection-sales_org_range IS NOT INITIAL ).
    GET TIME STAMP FIELD lv_now.

    IF iv_status IS INITIAL.
      UPDATE /eacm/job_mte
        SET changed_by   = @sy-uname,
            changed_at   = @lv_now,
            last_message = @iv_message
        WHERE bukrs = @is_selection-company_code
          AND ( @lv_has_agent_range = @abap_false OR zcdaz IN @is_selection-agent_range )
          AND ( @lv_has_sales_org_range = @abap_false OR vkorg IN @is_selection-sales_org_range )
          AND status <> 'C'.
    ELSE.
      UPDATE /eacm/job_mte
        SET status       = @iv_status,
            changed_by   = @sy-uname,
            changed_at   = @lv_now,
            last_message = @iv_message
        WHERE bukrs = @is_selection-company_code
          AND ( @lv_has_agent_range = @abap_false OR zcdaz IN @is_selection-agent_range )
          AND ( @lv_has_sales_org_range = @abap_false OR vkorg IN @is_selection-sales_org_range )
          AND status <> 'C'.
    ENDIF.
  ENDMETHOD.


  METHOD process_status.
    IF is_status-status = 'C'.
      RETURN.
    ENDIF.

    IF is_status-status = 'W'
       AND recover_in_process_status( is_status ) = abap_true.
      RETURN.
    ENDIF.

    mark_status_in_process( is_status ).
    COMMIT WORK AND WAIT.

    DATA(ls_selection) = VALUE ty_selection(
      company_code             = is_status-bukrs
      document_date            = is_status-bldat
      posting_date             = is_status-budat
      accounting_document_type = is_status-blart
      assignment_rule          = is_status-assignment_rule
      assignment_reference     = is_status-assignment_reference
      text_rule                = is_status-text_rule
      item_text                = is_status-item_text
      use_document_date_rate   = is_status-use_doc_rate
      external_reference       = is_status-xblnr
      defer_status_update      = abap_true ).

    DATA(ls_group) = build_group_from_status( is_status ).
    IF ls_group-source_rows IS INITIAL.
      mark_status_error(
        is_status  = is_status
        iv_message = 'Nessuna riga sorgente MTE collegata alla richiesta.' ).
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    TRY.
        IF post_group(
             EXPORTING
               is_selection = ls_selection
               is_group     = ls_group
             CHANGING
               ct_result    = rt_result ) = abap_true.
          READ TABLE rt_result INTO DATA(ls_success) WITH KEY success = abap_true.
          mark_status_accounted(
            is_status              = is_status
            iv_message             = ls_success-message_text
            iv_accounting_document = ls_success-accounting_document
            iv_fiscal_year         = ls_success-fiscal_year ).
        ELSE.
          mark_status_error(
            is_status  = is_status
            iv_message = build_error_message( rt_result ) ).
        ENDIF.
      CATCH cx_root INTO DATA(lx_error).
        mark_status_error(
          is_status  = is_status
          iv_message = build_exception_message( lx_error ) ).
    ENDTRY.

    /eacm/cl_api_log=>flush( ).
    COMMIT WORK AND WAIT.
  ENDMETHOD.


  METHOD build_status_from_group.
    DATA lv_uuid_c32 TYPE sysuuid_c32.

    TRY.
        cl_system_uuid=>convert_uuid_x16_static(
          EXPORTING uuid     = iv_job_uuid
          IMPORTING uuid_c32 = lv_uuid_c32 ).
      CATCH cx_uuid_error INTO DATA(lx_uuid).
        RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
          EXPORTING iv_text = lx_uuid->get_text( ).
    ENDTRY.

    rs_status = VALUE #(
      job_uuid              = iv_job_uuid
      status                = 'I'
      bukrs                 = is_group-company_code
      vkorg                 = is_group-sales_org
      vtweg                 = is_group-distribution_chan
      zclpr                 = is_group-commission_class
      zcdaz                 = is_group-agent
      ztpag                 = is_group-payment_type
      waers                 = is_group-currency
      lifnr                 = is_group-supplier
      zamcf                 = is_group-facsimile_period
      zidfs                 = is_group-facsimile_progressive
      bldat                 = is_selection-document_date
      budat                 = is_selection-posting_date
      blart                 = COND #( WHEN is_selection-accounting_document_type IS INITIAL
                                      THEN gc_default_blart
                                      ELSE is_selection-accounting_document_type )
      use_doc_rate          = is_selection-use_document_date_rate
      assignment_rule       = is_selection-assignment_rule
      assignment_reference  = is_group-assignment_number
      text_rule             = is_selection-text_rule
      item_text             = is_group-item_text
      business_area         = is_group-business_area
      cost_center           = is_group-assignment-cost_center
      order_number          = is_group-assignment-order_number
      profit_center         = is_group-assignment-profit_center
      accrual_account       = is_group-accounts-accrual_account
      accrual_special_gl    = is_group-accounts-accrual_special_gl
      maturity_account      = is_group-accounts-maturity_account
      maturity_special_gl   = is_group-accounts-maturity_special_gl
      amount                = is_group-amount
      source_count          = lines( is_group-source_rows )
      xblnr                 = lv_uuid_c32(16)
      xblnr_gjahr           = is_selection-posting_date(4) ).
  ENDMETHOD.


  METHOD save_group_sources.
    DATA lv_now TYPE /eacm/job_mtesrc-created_at.
    GET TIME STAMP FIELD lv_now.

    LOOP AT is_group-source_rows INTO DATA(ls_source).
      SELECT SINGLE job_uuid
        FROM /eacm/job_mtesrc
        WHERE bukrs = @ls_source-bukrs
          AND vkorg = @ls_source-vkorg
          AND vtweg = @ls_source-vtweg
          AND zclpr = @ls_source-zclpr
          AND vbeln = @ls_source-vbeln
          AND posnr = @ls_source-posnr
          AND zcdaz = @ls_source-zcdaz
          AND zidag = @ls_source-zidag
          AND zidfs = @ls_source-zidfs
          AND zamcf = @ls_source-zamcf
        INTO @DATA(lv_existing_job_uuid).

      IF sy-subrc = 0.
        IF lv_existing_job_uuid <> iv_job_uuid.
          RAISE EXCEPTION TYPE /eacm/cx_eacm_posting
            EXPORTING iv_text = |Riga MTE { ls_source-vbeln }/{ ls_source-posnr } gia assegnata a un'altra richiesta.|.
        ENDIF.
        CONTINUE.
      ENDIF.

      DATA(ls_source_status) = VALUE /eacm/job_mtesrc(
        bukrs      = ls_source-bukrs
        vkorg      = ls_source-vkorg
        vtweg      = ls_source-vtweg
        zclpr      = ls_source-zclpr
        vbeln      = ls_source-vbeln
        posnr      = ls_source-posnr
        zcdaz      = ls_source-zcdaz
        zidag      = ls_source-zidag
        zidfs      = ls_source-zidfs
        zamcf      = ls_source-zamcf
        job_uuid   = iv_job_uuid
        created_at = lv_now ).
      INSERT /eacm/job_mtesrc FROM @ls_source_status.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_group_job.
    READ TABLE is_group-source_rows INTO DATA(ls_source) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT SINGLE job_uuid
      FROM /eacm/job_mtesrc
      WHERE bukrs = @ls_source-bukrs
        AND vkorg = @ls_source-vkorg
        AND vtweg = @ls_source-vtweg
        AND zclpr = @ls_source-zclpr
        AND vbeln = @ls_source-vbeln
        AND posnr = @ls_source-posnr
        AND zcdaz = @ls_source-zcdaz
        AND zidag = @ls_source-zidag
        AND zidfs = @ls_source-zidfs
        AND zamcf = @ls_source-zamcf
      INTO @rv_job_uuid.
  ENDMETHOD.


  METHOD build_group_from_status.
    rs_group = VALUE #(
      company_code          = is_status-bukrs
      sales_org             = is_status-vkorg
      distribution_chan     = is_status-vtweg
      commission_class      = is_status-zclpr
      agent                 = is_status-zcdaz
      payment_type          = is_status-ztpag
      currency              = is_status-waers
      supplier              = is_status-lifnr
      facsimile_period      = is_status-zamcf
      facsimile_progressive = is_status-zidfs
      business_area         = is_status-business_area
      assignment_number     = is_status-assignment_reference
      item_text             = is_status-item_text
      amount                = is_status-amount ).

    rs_group-accounts-accrual_account = is_status-accrual_account.
    rs_group-accounts-accrual_special_gl = is_status-accrual_special_gl.
    rs_group-accounts-maturity_account = is_status-maturity_account.
    rs_group-accounts-maturity_special_gl = is_status-maturity_special_gl.
    rs_group-assignment-business_area = is_status-business_area.
    rs_group-assignment-cost_center = is_status-cost_center.
    rs_group-assignment-order_number = is_status-order_number.
    rs_group-assignment-profit_center = is_status-profit_center.

    SELECT *
      FROM /eacm/job_mtesrc
      WHERE job_uuid = @is_status-job_uuid
      INTO TABLE @DATA(lt_source_keys).

    LOOP AT lt_source_keys INTO DATA(ls_key).
      SELECT SINGLE *
        FROM /eacm/zprdp
        WHERE bukrs = @ls_key-bukrs
          AND vkorg = @ls_key-vkorg
          AND vtweg = @ls_key-vtweg
          AND zclpr = @ls_key-zclpr
          AND vbeln = @ls_key-vbeln
          AND posnr = @ls_key-posnr
          AND zcdaz = @ls_key-zcdaz
          AND zidag = @ls_key-zidag
          AND zidfs = @ls_key-zidfs
          AND zamcf = @ls_key-zamcf
        INTO @DATA(ls_source).
      IF sy-subrc = 0.
        APPEND ls_source TO rs_group-source_rows.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD mark_status_in_process.
    DATA lv_now TYPE /eacm/job_mte-changed_at.
    GET TIME STAMP FIELD lv_now.
    UPDATE /eacm/job_mte
      SET status       = 'W',
          changed_by   = @sy-uname,
          changed_at   = @lv_now,
          last_message = 'Contabilizzazione MTE in elaborazione'
      WHERE job_uuid = @is_status-job_uuid.
  ENDMETHOD.


  METHOD mark_status_accounted.
    DATA lv_now TYPE /eacm/job_mte-changed_at.
    GET TIME STAMP FIELD lv_now.
    mark_source_rows_posted( is_status ).
    UPDATE /eacm/job_mte
      SET status       = 'C',
          belnr        = @iv_accounting_document,
          belnr_gjahr  = @iv_fiscal_year,
          changed_by   = @sy-uname,
          changed_at   = @lv_now,
          last_message = @iv_message
      WHERE job_uuid = @is_status-job_uuid.
  ENDMETHOD.


  METHOD mark_status_error.
    DATA lv_now TYPE /eacm/job_mte-changed_at.
    DATA(lv_message) = iv_message.
    IF strlen( lv_message ) > 500.
      lv_message = substring( val = lv_message off = 0 len = 497 ) && `...`.
    ENDIF.
    GET TIME STAMP FIELD lv_now.
    UPDATE /eacm/job_mte
      SET status       = 'E',
          changed_by   = @sy-uname,
          changed_at   = @lv_now,
          last_message = @lv_message
      WHERE job_uuid = @is_status-job_uuid.
  ENDMETHOD.


  METHOD mark_source_rows_posted.
    DATA(ls_group) = build_group_from_status( is_status ).
    DATA(ls_selection) = VALUE ty_selection(
      posting_date = is_status-budat ).
    mark_group_posted(
      is_selection = ls_selection
      is_group     = ls_group ).
  ENDMETHOD.


  METHOD recover_in_process_status.
    DATA(ls_document) = read_existing_document(
      iv_bukrs = is_status-bukrs
      iv_gjahr = is_status-xblnr_gjahr
      iv_xblnr = is_status-xblnr ).

    IF ls_document-exists = abap_true.
      mark_status_accounted(
        is_status              = is_status
        iv_message             = 'Documento contabile MTE gia esistente: stato recuperato senza nuova contabilizzazione'
        iv_accounting_document = ls_document-accounting_document
        iv_fiscal_year         = ls_document-fiscal_year ).
      /eacm/cl_api_log=>flush( ).
      COMMIT WORK AND WAIT.
      rv_recovered = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD read_existing_document.
    TRY.
        DATA(lo_reader) = NEW /eacm/cl_api_acct_doc_read(
          i_servide_id = /eacm/cl_api_acct_doc_read=>mapp_service_id ).
        DATA(ls_map) = lo_reader->read_document_map(
          iv_sender_logical_system      = ''
          iv_sender_company_code        = iv_bukrs
          iv_sender_accounting_document = iv_xblnr
          iv_sender_fiscal_year         = |{ iv_gjahr }| ).
        rs_document = VALUE #(
          exists              = xsdbool( ls_map-AccountingDocument IS NOT INITIAL )
          accounting_document = ls_map-AccountingDocument
          fiscal_year         = ls_map-FiscalYear ).
      CATCH /eacm/cx_api_error cx_sy_itab_line_not_found.
        CLEAR rs_document.
    ENDTRY.
  ENDMETHOD.


  METHOD build_error_message.
    LOOP AT it_result INTO DATA(ls_message)
      WHERE type = 'E'
         OR type = 'A'
         OR type = 'X'.
      CHECK ls_message-message_text IS NOT INITIAL.
      rv_message = COND #(
        WHEN rv_message IS INITIAL
        THEN ls_message-message_text
        ELSE |{ rv_message }; { ls_message-message_text }| ).
    ENDLOOP.

    IF rv_message IS INITIAL.
      rv_message = 'Contabilizzazione MTE terminata con errori.'.
    ELSEIF strlen( rv_message ) > 500.
      rv_message = substring( val = rv_message off = 0 len = 497 ) && `...`.
    ENDIF.
  ENDMETHOD.


  METHOD build_exception_message.
    DATA lo_error TYPE REF TO cx_root.
    DATA lv_primary_text TYPE string.

    lo_error = ix_error.

    WHILE lo_error IS BOUND.
      IF lo_error IS INSTANCE OF /eacm/cx_api_error.
        DATA(lx_api_error) = CAST /eacm/cx_api_error( lo_error ).
        IF lx_api_error->mv_context IS NOT INITIAL
           AND ( rv_message IS INITIAL
                 OR rv_message NS lx_api_error->mv_context ).
          rv_message = COND #(
            WHEN rv_message IS INITIAL
            THEN lx_api_error->mv_context
            ELSE |{ rv_message }; { lx_api_error->mv_context }| ).
        ENDIF.
      ENDIF.

      DATA(lv_text) = lo_error->get_text( ).
      IF lv_primary_text IS INITIAL.
        lv_primary_text = lv_text.
      ENDIF.

      IF lv_text IS NOT INITIAL
         AND ( rv_message IS INITIAL OR rv_message NS lv_text ).
        rv_message = COND #(
          WHEN rv_message IS INITIAL
          THEN lv_text
          ELSE |{ rv_message }; { lv_text }| ).
      ENDIF.

      lo_error = lo_error->previous.
    ENDWHILE.

    "Se non esiste una catena PREVIOUS, il long text puo contenere il dettaglio
    "tecnico che GET_TEXT riduce al messaggio generico dell'eccezione wrapper.
    IF ix_error IS BOUND
       AND ix_error->previous IS NOT BOUND.
      DATA(lv_longtext) = ix_error->get_longtext( ).
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline
        IN lv_longtext WITH ` `.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf
        IN lv_longtext WITH ` `.
      CONDENSE lv_longtext.

      IF lv_longtext IS NOT INITIAL
         AND lv_longtext <> lv_primary_text
         AND ( rv_message IS INITIAL OR rv_message NS lv_longtext ).
        rv_message = COND #(
          WHEN rv_message IS INITIAL
          THEN lv_longtext
          ELSE |{ rv_message }; { lv_longtext }| ).
      ENDIF.
    ENDIF.

    IF rv_message IS INITIAL.
      rv_message = 'Eccezione non identificata durante la contabilizzazione MTE.'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.



