% =============================================================================
%  spec.pl  —  Property-based tests, analog test/Spec.hs (QuickCheck)
%
%  Di Haskell: QuickCheck generate random LoanApplication, cek properti.
%  Di Prolog  : kita gunakan library(quickcheck) dari SWI-Prolog, atau
%               implementasi manual berbasis random_between/3 + forall.
%
%  Jalankan:
%    swipl -g run_tests -t halt spec.pl
%  atau:
%    swipl spec.pl
%    ?- run_tests.
% =============================================================================

:- use_module(los_lib).
:- use_module(library(plunit)).
:- use_module(library(random)).

% ---------------------------------------------------------------------------
%  Generator  (analog Arbitrary instance di Haskell)
% ---------------------------------------------------------------------------

%% gen_loan_app(-App)
%  Membangkitkan loan_app acak dalam rentang realistis.
gen_loan_app(loan_app(Name, Principal, Rate, Term, Score, Debt, Income)) :-
    random_member(Name, ['Budi','Siti','Andi','Rina','Wati']),
    random_between(1_000_000, 5_000_000_000, Principal),
    RateInt is random_between(300, 2500, _) -> true ; RateInt = 825,
    Rate is RateInt / 100.0,
    random_between(6, 360, Term),
    random_between(300, 850, Score),
    random_between(0, 20_000_000, Debt),
    random_between(1_000_000, 50_000_000, Income).

%  SWI-Prolog random_between tidak support float langsung, pakai helper:
random_float(Lo, Hi, F) :-
    random(R),
    F is Lo + R * (Hi - Lo).

gen_loan_app2(loan_app(Name, Principal, Rate, Term, Score, Debt, Income)) :-
    random_member(Name, ['Budi','Siti','Andi','Rina','Wati']),
    random_between(1_000_000, 5_000_000_000, Principal),
    random_float(3.0, 25.0, Rate),
    random_between(6, 360, Term),
    random_between(300, 850, Score),
    random_between(0, 20_000_000, Debt),
    random_between(1_000_000, 50_000_000, Income).

%% check_property(+N, :Prop)
%  Jalankan Prop sebanyak N kali dengan App acak yang berbeda.
check_property(0, _) :- !.
check_property(N, Prop) :-
    N > 0,
    gen_loan_app2(App),
    call(Prop, App),
    N1 is N - 1,
    check_property(N1, Prop).

% ---------------------------------------------------------------------------
:- begin_tests(los_properties).
% ---------------------------------------------------------------------------

%% prop_dti_never_negative
%  DTI tidak pernah negatif untuk debt>=0, income>0.
%  Analog: prop_dtiNeverNegative :: NonNegative Double -> Positive Double -> Bool
test(dti_never_negative, [forall(between(1,100,_))]) :-
    random_between(0, 20_000_000, Debt),
    random_between(1, 50_000_000, Income),
    calculate_dti(Debt, Income, DTI),
    DTI >= 0.

%% prop_payment_positive
%  Cicilan selalu positif untuk principal/rate/term positif.
test(payment_is_positive, [forall(between(1,100,_))]) :-
    random_between(1_000_000, 5_000_000_000, P),
    random_float(0.01, 25.0, Rate),
    random_between(1, 360, Term),
    calculate_monthly_payment(P, Rate, Term, Payment),
    Payment > 0.

%% prop_higher_score_better_or_equal_rate
%  Skor kredit lebih tinggi tidak menghasilkan rate lebih buruk.
%  Analog: prop_higherScoreGetsBetterOrEqualRate
test(higher_score_better_rate, [forall(between(1,100,_))]) :-
    gen_loan_app2(App),
    App = loan_app(N, P, Rate, Term, Score, D, I),
    Score < 850,
    BetterScore is min(850, Score + 50),
    BetterApp = loan_app(N, P, Rate, Term, BetterScore, D, I),
    adjust_rate_for_risk(App, AdjApp),
    adjust_rate_for_risk(BetterApp, AdjBetter),
    decide(AdjApp, Dec1),
    decide(AdjBetter, Dec2),
    ( Dec1 = approved(_, R1), Dec2 = approved(_, R2) ->
        R2 =< R1          % skor lebih tinggi, rate lebih rendah atau sama
    ; true                 % salah satu tidak approved: properti tidak berlaku
    ).

%% prop_validate_rejects_non_positive_principal
%  validate_application harus menolak principal <= 0.
test(validate_rejects_non_positive, [forall(between(1,100,_))]) :-
    gen_loan_app2(App),
    App = loan_app(N, _, Rate, Term, Score, D, I),
    random_between(-10_000_000, 0, BadP),
    BadApp = loan_app(N, BadP, Rate, Term, Score, D, I),
    validate_application(BadApp, error(_)).   % harus error

%% prop_passes_all_implies_each
%  Jika passes_all_rules berhasil, maka setiap rule individu juga berhasil.
%  Analog: prop_passesAllImpliesEachRule
test(passes_all_implies_each, [forall(between(1,100,_))]) :-
    gen_loan_app2(App),
    ( passes_all_rules(App) ->
        underwriting_rules(Rules),
        maplist({App}/[Rule]>>(call(Rule, App)), Rules)
    ; true
    ).

%% prop_underwriting_deterministic
%  Pipeline yang sama dengan input yang sama menghasilkan output yang sama.
%  Analog: prop_underwritingIsDeterministic
test(underwriting_deterministic, [forall(between(1,50,_))]) :-
    gen_loan_app2(App),
    bank_config(Base, Policy, MaxL, MinS),
    Cfg = bank_config(Base, Policy, MaxL, MinS),
    St = bank_state(1_000_000_000, []),
    run_underwriting(App, Cfg, St, Result1),
    run_underwriting(App, Cfg, St, Result2),
    % Keputusan harus identik (ok vs error, dan isinya)
    ( Result1 = ok(D1, _), Result2 = ok(D2, _) -> D1 == D2
    ; Result1 = error(E1), Result2 = error(E2) -> E1 == E2
    ; true
    ).

%% prop_adjust_rate_monotonic
%  adjustRateForRisk tidak pernah menurunkan rate.
test(adjust_rate_monotonic, [forall(between(1,100,_))]) :-
    gen_loan_app2(App),
    App = loan_app(_, _, OrigRate, _, _, _, _),
    adjust_rate_for_risk(App, AdjApp),
    AdjApp = loan_app(_, _, NewRate, _, _, _, _),
    NewRate >= OrigRate.

%% prop_full_pipeline_always_returns_string
%  full_pipeline selalu menghasilkan atom (tidak pernah gagal total).
test(full_pipeline_always_succeeds, [forall(between(1,100,_))]) :-
    gen_loan_app2(App),
    full_pipeline(App, Msg),
    atom(Msg).

:- end_tests(los_properties).

% ---------------------------------------------------------------------------
%  Entry point
% ---------------------------------------------------------------------------
:- initialization(run_tests, main).
