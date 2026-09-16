% =============================================================================
%  los_lib.pl  —  Loan Originating System (LOS) sebagai tur Logic Programming
%  (terjemahan setia dari los-haskell / Lib.hs ke SWI-Prolog)
%
%  Konsep yang ditunjukkan, secara berurutan:
%   1. Fakta & unifikasi (padanan pure data types)
%   2. Pure calculations sebagai relasi deterministik
%   3. Business rules sebagai klausa Prolog (first-class logic)
%   4. Pattern matching lewat head unification & cut
%   5. Kegagalan eksplisit dengan either/2 (padanan Either)
%   6. State kumulatif lewat argumen ekstra (difference-list style)
%   7. Audit trail via type-class analog (multifile predicate dispatch)
%   8. Meta-programming: rules sebagai data (findall / aggregate)
% =============================================================================

:- module(los_lib,
    [ % 1. Domain facts
      bank_config/4,          % baseRate, policy, maxLoan, minScore
      bank_state/2,           % quota, auditLog

      % 2. Pure calculations
      calculate_dti/3,        % +Debt, +Income, -DTI
      calculate_monthly_payment/4, % +Principal, +AnnualRate%, +Months, -Payment

      % 3. Business rules
      min_credit_score/2,     % +MinScore, +App
      max_dti/2,              % +MaxRatio, +App
      passes_all_rules/1,     % +App
      failing_rules/2,        % +App, -List

      % 4. Decision pipeline
      adjust_rate_for_risk/2, % +AppIn, -AppOut
      decide/2,               % +App, -Decision
      notify_applicant/2,     % +Decision, -Message
      full_pipeline/2,        % +App, -Message

      % 5. Validation with Either analog
      validate_application/2, % +App, -either(Error, App)
      process_application/2,  % +App, -either(Error, Decision)

      % 6. Stateful underwriting (pure, threaded state)
      underwrite_application/5, % +App, +Config, +StateIn, -Decision, -StateOut

      % 7. Audit trail
      audit_entry/3,          % +Item, -Severity, -Entry
      log_to_audit_trail/1,   % +Item
      log_batch/1,            % +List
      log_mixed_batch/1,      % +List (only Warning+)

      % helpers
      mask_name/2,
      severity_gte/2
    ]).

:- use_module(library(lists)).
:- use_module(library(aggregate)).

% =============================================================================
%  §1  DOMAIN TYPES — dinyatakan sebagai struktur Prolog biasa
%
%  Di Haskell: record types dengan field bernama.
%  Di Prolog  : compound terms.  Kita pakai functor deskriptif agar
%               pattern matching di head clause tetap terbaca.
%
%  loan_app(Name, Principal, AnnualRate, TermMonths, CreditScore,
%           MonthlyDebt, MonthlyIncome)
%
%  decision bisa salah satu dari:
%    approved(Amount, Rate)
%    rejected(Reason)
%    pending_review(MissingDocs)
%
%  bank_config(BaseRate, Policy, MaxLoan, MinScore)
%  bank_state(RemainingQuota, AuditLog)
% =============================================================================

% Default config yang dipakai main.pl — bisa di-override
bank_config(6.25, standard, 500_000_000, 620).
bank_state(1_000_000_000, []).

% =============================================================================
%  §2  PURE CALCULATIONS
%
%  Karakteristik logika: relasi deterministik, selalu berhasil untuk
%  input valid, TIDAK ada side-effect.  Identik dengan pure functions
%  di Haskell; perbedaannya hanya pada cara "mengembalikan nilai":
%  via argumen terakhir (output variable) bukan return value.
% =============================================================================

%% calculate_dti(+Debt, +Income, -DTI)
%
%  DTI = Debt / Income.  Jika income <= 0 hasilnya 0 (aman dari div/0).
%  Ini adalah relasi, bukan fungsi — bisa digunakan dalam berbagai
%  konteks query tanpa perubahan kode.
calculate_dti(_, Income, 0) :-
    Income =< 0, !.
calculate_dti(Debt, Income, DTI) :-
    DTI is Debt / Income.

%% calculate_monthly_payment(+Principal, +AnnualRatePct, +Months, -Payment)
%
%  Rumus anuitas standar: P * r*(1+r)^n / ((1+r)^n - 1)
%  Edge cases: months=0 atau rate=0 ditangani secara eksplisit.
calculate_monthly_payment(_, _, 0, 0) :- !.
calculate_monthly_payment(P, 0.0, Months, Payment) :- !,
    Payment is P / Months.
calculate_monthly_payment(P, 0, Months, Payment) :- !,
    Payment is P / Months.
calculate_monthly_payment(P, AnnualRatePct, Months, Payment) :-
    R is AnnualRatePct / 12.0 / 100.0,
    N is float(Months),
    Payment is P * R * (1+R)**N / ((1+R)**N - 1).

% =============================================================================
%  §3  BUSINESS RULES SEBAGAI KLAUSA PROLOG
%
%  Di Haskell: type Rule = LoanApplication -> Bool, lalu list of Rules.
%  Di Prolog  : setiap rule adalah predikat tersendiri, dan "list of rules"
%               direpresentasikan sebagai daftar goal yang dievaluasi
%               lewat call/2 (higher-order).  Ini lebih alami karena
%               Prolog natively mendukung goals sebagai data (meta-call).
% =============================================================================

%% min_credit_score(+MinScore, +App)
min_credit_score(MinScore, loan_app(_, _, _, _, Score, _, _)) :-
    Score >= MinScore.

%% max_dti(+MaxRatio, +App)
max_dti(MaxRatio, loan_app(_, _, _, _, _, Debt, Income)) :-
    calculate_dti(Debt, Income, DTI),
    DTI =< MaxRatio.

%% max_principal(+Max, +App)
max_principal(Max, loan_app(_, Principal, _, _, _, _, _)) :-
    Principal =< Max.

%% underwriting_rules(-Rules)
%  Rules adalah daftar goal-template (partial application via lambda-analog).
%  Setiap elemen adalah closure: [App]>>(Goal) — pakai library(yall).
:- use_module(library(yall)).

underwriting_rules([
    [App]>>(min_credit_score(620, App)),
    [App]>>(max_dti(0.43, App)),
    [App]>>(max_principal(2_000_000_000, App))
]).

%% passes_all_rules(+App)
%  Berhasil jika App lolos semua underwriting rules.
%  Analog: passesAllRules = all (\rule -> rule app) underwritingRules
passes_all_rules(App) :-
    underwriting_rules(Rules),
    maplist({App}/[Rule]>>(call(Rule, App)), Rules).

%% failing_rules(+App, -FailingGooals)
%  Prolog memungkinkan kita BALIK pertanyaan: rule mana yang gagal?
%  Di Haskell ini butuh filter terpisah; di Prolog satu predikat cukup.
failing_rules(App, Failing) :-
    underwriting_rules(Rules),
    include({App}/[Rule]>>(\+ call(Rule, App)), Rules, Failing).

% =============================================================================
%  §4  DECISION PIPELINE
%
%  Di Haskell: fullPipeline = notifyApplicant . decide . adjustRateForRisk
%  Di Prolog  : rangkaian predikat — tidak ada operator komposisi, tapi
%               pipeline tetap terbaca karena variabel menghubungkan tahap.
%
%  Karakteristik penting: PATTERN MATCHING di head clause menggantikan
%  if-else bertingkat.  Setiap klausa adalah kasus berbeda, dibaca
%  secara deklaratif ("jika Score < 600, maka ...").
% =============================================================================

%% adjust_rate_for_risk(+AppIn, -AppOut)
%  Menyesuaikan bunga berdasarkan risiko kredit.
%  AppOut adalah AppIn dengan annualRate yang dimodifikasi.
adjust_rate_for_risk(
        loan_app(Name, P, Rate, Term, Score, Debt, Inc),
        loan_app(Name, P, NewRate, Term, Score, Debt, Inc)) :-
    Score < 600, !,
    NewRate is Rate + 3.5.
adjust_rate_for_risk(
        loan_app(Name, P, Rate, Term, Score, Debt, Inc),
        loan_app(Name, P, NewRate, Term, Score, Debt, Inc)) :-
    Score < 700, !,
    NewRate is Rate + 1.5.
adjust_rate_for_risk(App, App).          % score >= 700: tidak berubah

%% decide(+App, -Decision)
%  Tiga klausa = tiga kasus bisnis.  Cut (!) memastikan hanya satu yang dipilih.
decide(App, rejected("Tidak memenuhi kriteria underwriting")) :-
    \+ passes_all_rules(App), !.
decide(loan_app(_, _, _, _, Score, _, _),
       pending_review(["Slip gaji 3 bulan terakhir"])) :-
    Score < 650, !.
decide(loan_app(_, Principal, Rate, _, _, _, _),
       approved(Principal, Rate)).

%% notify_applicant(+Decision, -Message)
%  Pattern matching pada functor decision — padanan show/notifyApplicant Haskell.
notify_applicant(approved(Amount, Rate), Msg) :-
    format(atom(Msg),
           "Selamat! Pinjaman Rp~0f disetujui dengan bunga ~1f%",
           [Amount, Rate]).
notify_applicant(rejected(Why), Msg) :-
    format(atom(Msg), "Maaf, pengajuan ditolak. Alasan: ~w", [Why]).
notify_applicant(pending_review(Docs), Msg) :-
    atomic_list_concat(Docs, ", ", DocStr),
    format(atom(Msg), "Perlu dokumen tambahan: ~w", [DocStr]).

%% full_pipeline(+App, -Message)
%  Pipeline tiga tahap: adjust → decide → notify.
%  Variabel antara (Adjusted, Decision) bersifat lokal dan tidak perlu
%  diekspor — ini ekuivalen dengan intermediate bindings dalam do-notation.
full_pipeline(App, Message) :-
    adjust_rate_for_risk(App, Adjusted),
    decide(Adjusted, Decision),
    notify_applicant(Decision, Message).

% =============================================================================
%  §5  VALIDASI DENGAN EITHER ANALOG
%
%  Di Haskell: Either String a — Left = error, Right = sukses.
%  Di Prolog  : kita representasikan sebagai error(Msg) atau ok(Value).
%               Alternatif populer lain: exception via catch/throw,
%               tapi term eksplisit lebih deklaratif dan testable.
% =============================================================================

%% validate_application(+App, -Result)
%  Result = ok(App) | error(Reason)
validate_application(loan_app(_, P, _, _, _, _, _), error("Jumlah pinjaman harus positif")) :-
    P =< 0, !.
validate_application(loan_app(_, _, _, Term, _, _, _), error("Tenor harus positif")) :-
    Term =< 0, !.
validate_application(loan_app(_, _, _, _, Score, _, _), error("Skor kredit tidak valid")) :-
    Score < 300, !.
validate_application(App, ok(App)).

%% process_application(+App, -Result)
%  Result = ok(Decision) | error(Reason)
%  Analog: do-notation dengan Either — kegagalan di langkah awal
%  menyebabkan seluruh komputasi gagal (short-circuit).
process_application(App, Result) :-
    validate_application(App, ValidationResult),
    ( ValidationResult = ok(Valid) ->
        adjust_rate_for_risk(Valid, Adjusted),
        decide(Adjusted, Decision),
        Result = ok(Decision)
    ; Result = ValidationResult   % propagate error
    ).

% =============================================================================
%  §6  STATEFUL UNDERWRITING — STATE DITHREAD SEBAGAI ARGUMEN
%
%  Di Haskell: ReaderT BankConfig (StateT BankState (ExceptT String IO)) a
%  Di Prolog  : kita thread state secara eksplisit sebagai pasangan
%               argumen (StateIn, StateOut) — ini adalah teknik
%               "difference list for state" yang idiomatis di Prolog.
%
%  Keuntungan: TIDAK ada mutable state, TIDAK ada efek samping tersembunyi.
%  Kegagalan (fail/throw) secara otomatis "membatalkan" perubahan state
%  karena Prolog menggunakan backtracking — state lama tidak pernah
%  di-mutasi, hanya tidak di-bind ke output variable.
%
%  Config dibaca via argumen (analog Reader) — deterministik dan testable.
% =============================================================================

%% underwrite_step_validate(+App, +Config, +StateIn, -StateOut)
underwrite_step_validate(
        loan_app(Name, Principal, _, _, Score, _, _),
        bank_config(_, _, _, MinScore),
        bank_state(Q, Log0),
        bank_state(Q, Log1)) :-
    ( Principal =< 0 ->
        throw(underwriting_error("Jumlah pinjaman harus positif"))
    ; Score < MinScore ->
        format(atom(ErrMsg),
               "Skor kredit di bawah minimum bank: ~w", [MinScore]),
        throw(underwriting_error(ErrMsg))
    ; true
    ),
    format(atom(LogMsg), "Validasi dasar lolos untuk ~w", [Name]),
    append(Log0, [LogMsg], Log1).

%% underwrite_step_quota(+App, +StateIn, -StateOut)
underwrite_step_quota(
        loan_app(_, Principal, _, _, _, _, _),
        bank_state(Quota, Log0),
        bank_state(NewQuota, Log1)) :-
    ( Principal > Quota ->
        throw(underwriting_error("Plafon kredit hari ini sudah habis"))
    ; true
    ),
    NewQuota is Quota - Principal,
    format(atom(LogMsg), "Kuota dicadangkan: Rp~0f", [Principal]),
    append(Log0, [LogMsg], Log1).

%% calculate_final_rate(+App, +Config, -Rate)
calculate_final_rate(
        loan_app(_, _, _, _, Score, _, _),
        bank_config(Base, Policy, _, _),
        Rate) :-
    ( Score < 600 -> RiskPremium = 3.5
    ; Score < 700 -> RiskPremium = 1.5
    ; RiskPremium = 0.5
    ),
    ( Policy = conservative -> PolicyAdj = 0.5
    ; Policy = aggressive   -> PolicyAdj = -0.5
    ; PolicyAdj = 0.0          % standard
    ),
    Rate is Base + RiskPremium + PolicyAdj.

%% underwrite_application(+App, +Config, +StateIn, -Decision, -StateOut)
%
%  Orkestrasi seluruh pipeline underwriting.
%  Jika salah satu langkah melempar underwriting_error, seluruh predikat
%  gagal dan StateIn TIDAK dimodifikasi — persis seperti ExceptT di Haskell
%  yang tidak melakukan commit pada state saat terjadi Left.
underwrite_application(App, Config, State0, Decision, StateOut) :-
    underwrite_step_validate(App, Config, State0, State1),
    underwrite_step_quota(App, State1, State2),
    calculate_final_rate(App, Config, Rate),
    App = loan_app(_, Principal, _, _, _, _, _),
    format(atom(LogMsg), "Disetujui dengan rate ~1f%", [Rate]),
    State2 = bank_state(Q2, Log2),
    append(Log2, [LogMsg], Log3),
    StateOut = bank_state(Q2, Log3),
    Decision = approved(Principal, Rate).

%% run_underwriting(+App, +Config, +StateIn, -Result)
%  Result = ok(Decision, StateOut) | error(Message)
%  Membungkus underwrite_application dengan catch/throw — analog runExceptT.
run_underwriting(App, Config, StateIn, Result) :-
    catch(
        ( underwrite_application(App, Config, StateIn, Decision, StateOut),
          Result = ok(Decision, StateOut)
        ),
        underwriting_error(Msg),
        Result = error(Msg)
    ).

% =============================================================================
%  §7  AUDIT TRAIL — MULTIFILE DISPATCH (ANALOG TYPE CLASS)
%
%  Di Haskell: type class Auditable dengan instance untuk LoanDecision,
%              LoanApplication, String.
%  Di Prolog  : multifile predicate audit_entry/3.  Setiap "instance"
%              adalah sekumpulan klausa yang bisa didefinisikan di modul
%              berbeda (multifile) — ini adalah ad-hoc polymorphism ala Prolog.
%
%  Dispatch terjadi secara otomatis berdasarkan pattern matching pada
%  argumen pertama (functor term) — tidak perlu dictionary/vtable eksplisit.
% =============================================================================

:- discontiguous audit_entry/3.

%% audit_entry(+Item, -Severity, -Entry)
%  "Instance" untuk approved/2
audit_entry(approved(Amount, Rate), info, Entry) :-
    format(atom(Entry), "APPROVED | amount=~0f | rate=~1f%", [Amount, Rate]).

%% "Instance" untuk rejected/1
audit_entry(rejected(Why), warning, Entry) :-
    format(atom(Entry), "REJECTED | reason=~w", [Why]).

%% "Instance" untuk pending_review/1
audit_entry(pending_review(Docs), warning, Entry) :-
    atomic_list_concat(Docs, ", ", DocStr),
    format(atom(Entry), "PENDING | missing=~w", [DocStr]).

%% "Instance" untuk loan_app/7
audit_entry(loan_app(Name, Principal, _, _, Score, _, _), info, Entry) :-
    format(atom(Entry),
           "APPLICATION | applicant=~w | principal=~0f | score=~w",
           [Name, Principal, Score]).

%% "Instance" untuk atom/string — analog instance Auditable String
audit_entry(Note, Severity, Entry) :-
    ( atom(Note) ; string(Note) ), !,
    format(atom(Entry), "NOTE | ~w", [Note]),
    ( ( sub_atom(Note, _, _, _, fraud)
      ; sub_atom(Note, _, _, _, suspicious)
      ) ->
        Severity = critical
    ; Severity = info
    ).

%% severity_gte(+Sev, +MinSev)  — ordering: info < warning < critical
severity_level(info,     0).
severity_level(warning,  1).
severity_level(critical, 2).

severity_gte(Sev, Min) :-
    severity_level(Sev, SL),
    severity_level(Min, ML),
    SL >= ML.

%% log_to_audit_trail(+Item)
log_to_audit_trail(Item) :-
    audit_entry(Item, Sev, Entry),
    format("[~w] ~w~n", [Sev, Entry]).

%% log_batch(+List)  — analog logBatch :: Auditable a => [a] -> IO ()
log_batch([]).
log_batch([H|T]) :-
    log_to_audit_trail(H),
    log_batch(T).

%% log_mixed_batch(+List)  — hanya tampilkan Warning+ (heterogeneous list)
%  Di Haskell ini butuh existential type AnyAuditable.
%  Di Prolog list boleh heterogen secara native — tidak perlu wrapper.
log_mixed_batch([]).
log_mixed_batch([H|T]) :-
    ( audit_entry(H, Sev, Entry),
      severity_gte(Sev, warning) ->
        format("[~w] ~w~n", [Sev, Entry])
    ; true
    ),
    log_mixed_batch(T).

% =============================================================================
%  §8  META-PROGRAMMING BONUS
%
%  Kemampuan Prolog untuk memperlakukan goals sebagai data memungkinkan
%  hal-hal yang di bahasa lain butuh reflection/metaprogramming berat:
%  "aplikasi mana yang lolos aturan mana" dalam satu query.
% =============================================================================

%% which_rules_pass(+App, -PassingRuleNames)
which_rules_pass(App, Names) :-
    findall(Name,
        ( member(Name-Goal,
            [ min_score_620 - min_credit_score(620, App)
            , max_dti_43    - max_dti(0.43, App)
            , max_principal - max_principal(2_000_000_000, App)
            ]),
          call(Goal)
        ),
        Names).

% =============================================================================
%  HELPER
% =============================================================================

%% mask_name(+Name, -Masked)
%  Analog Show instance LoanApplication yang menyembunyikan PII.
mask_name(Name, Masked) :-
    atom_chars(Name, [First|Rest]),
    length(Rest, Len),
    ( Len >= 2 ->
        atom_chars(Masked, [First, '*', '*', '*'])
    ;   Masked = Name
    ).
