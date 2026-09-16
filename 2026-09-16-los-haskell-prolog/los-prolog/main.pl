% =============================================================================
%  main.pl  —  Demo end-to-end LOS, analog app/Main.hs
%
%  Jalankan di SWI-Prolog:
%    swipl -g main -t halt main.pl
%  atau interaktif:
%    swipl main.pl
%    ?- main.
% =============================================================================

:- use_module(los_lib).

% ---------------------------------------------------------------------------
%  Data aplikasi contoh (analog sampleApp, lowScoreApp, overQuotaApp di Main.hs)
% ---------------------------------------------------------------------------

% loan_app(Name, Principal, AnnualRate, TermMonths, CreditScore, Debt, Income)
sample_app(loan_app('Budi', 200_000_000, 0.0, 24, 680, 3_000_000, 12_000_000)).
low_score_app(loan_app('Siti', 50_000_000, 0.0, 24, 590, 3_000_000, 12_000_000)).
over_quota_app(loan_app('Andi', 3_000_000_000, 0.0, 24, 680, 3_000_000, 12_000_000)).

config(bank_config(6.25, standard, 500_000_000, 620)).
init_state(bank_state(1_000_000_000, [])).

% ---------------------------------------------------------------------------

main :-
    sample_app(SampleApp),
    low_score_app(LowApp),
    over_quota_app(OverApp),
    config(Cfg),
    init_state(InitSt),

    %% ===== 1) Pure calculations =====
    section("1) Pure calculations"),
    SampleApp = loan_app(_, _, _, _, _, Debt, Income),
    calculate_dti(Debt, Income, DTI),
    format("  DTI Budi: ~4f (~1f%)~n", [DTI, DTI*100]),
    calculate_monthly_payment(200_000_000, 8.0, 24, Payment),
    format("  Cicilan bulanan Rp200jt @ 8% / 24bln: Rp~0f~n", [Payment]),

    %% ===== 2) Pure decision pipeline =====
    section("2) Pure decision pipeline (adjust → decide → notify)"),
    full_pipeline(SampleApp, Msg1),
    format("  Budi  : ~w~n", [Msg1]),
    full_pipeline(LowApp, Msg2),
    format("  Siti  : ~w~n", [Msg2]),

    %% ===== 2b) Multi-directional query — hanya bisa di Prolog! =====
    section("2b) BONUS: query multi-arah — \"siapa yang LAYAK?\""),
    forall(
        ( member(App, [SampleApp, LowApp, OverApp]),
          passes_all_rules(App),
          App = loan_app(Name, _, _, _, _, _, _)
        ),
        format("  Lolos: ~w~n", [Name])
    ),
    format("  (Prolog mencari sendiri — tidak ada loop eksplisit)~n", []),

    %% ===== 2c) Aturan mana yang gagal? =====
    section("2c) BONUS: aturan yang GAGAL untuk Siti"),
    low_score_app(LA),
    failing_rules(LA, Failing),
    length(Failing, NF),
    format("  Jumlah aturan gagal: ~w~n", [NF]),

    %% ===== 3) Either-based validation =====
    section("3) Validasi dengan either analog (ok/error)"),
    process_application(SampleApp, R1),
    print_either_result(R1),

    InvalidApp = loan_app('Test', -1, 0.0, 24, 700, 0, 10_000_000),
    process_application(InvalidApp, R2),
    print_either_result(R2),

    %% ===== 4) Stateful underwriting =====
    section("4) Stateful underwriting (state di-thread sebagai argumen)"),
    run_underwriting(SampleApp, Cfg, InitSt, Res1),
    ( Res1 = ok(Decision1, bank_state(Quota1, Log1)) ->
        format("  Keputusan : ~w~n", [Decision1]),
        format("  Sisa kuota: Rp~0f~n", [Quota1]),
        format("  Audit log :\\n", []),
        forall(member(L, Log1), format("    - ~w~n", [L]))
    ; Res1 = error(Err1) ->
        format("  Ditolak sistem: ~w~n", [Err1])
    ),

    nl,
    format("  --- Kasus gagal: melebihi kuota (state TIDAK berubah) ---~n", []),
    run_underwriting(OverApp, Cfg, InitSt, Res2),
    ( Res2 = error(Err2) ->
        format("  Ditolak sistem: ~w~n", [Err2])
    ; format("  Tidak terduga disetujui~n", [])
    ),

    %% ===== 5) Audit trail (type class analog) =====
    section("5) Audit trail — multifile dispatch (analog type class)"),
    log_to_audit_trail(approved(200_000_000, 6.75)),
    log_to_audit_trail(rejected("Skor kredit tidak memenuhi syarat")),
    log_to_audit_trail(SampleApp),
    log_to_audit_trail('Terdeteksi pola aplikasi yang suspicious dari IP yang sama'),

    nl,
    format("  --- Mixed batch, hanya Warning+ yang tampil ---~n", []),
    log_mixed_batch([
        approved(200_000_000, 6.75),
        rejected("DTI terlalu tinggi"),
        'Login mencurigakan terdeteksi',
        SampleApp
    ]),

    %% ===== 6) Meta-programming: rules sebagai data =====
    section("6) BONUS: Meta-programming — rules sebagai data"),
    which_rules_pass(SampleApp, PassNames),
    format("  Budi lolos aturan: ~w~n", [PassNames]),
    which_rules_pass(LowApp, PassNames2),
    format("  Siti lolos aturan: ~w~n", [PassNames2]),

    nl,
    format("=== Selesai ===~n").

% ---------------------------------------------------------------------------
%  Helpers
% ---------------------------------------------------------------------------

section(Title) :-
    nl,
    format("=== ~w ===~n", [Title]).

print_either_result(ok(Decision)) :-
    format("  OK  : ~w~n", [Decision]).
print_either_result(error(Msg)) :-
    format("  ERR : ~w~n", [Msg]).

:- initialization(main, main).
