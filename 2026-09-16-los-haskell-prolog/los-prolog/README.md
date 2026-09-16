# los-prolog — Loan Originating System sebagai tur Logic Programming

Terjemahan setia dari `los-haskell` ke **SWI-Prolog**, memperlihatkan
bagaimana setiap konsep functional programming di Haskell memiliki padanan
idiomatis di paradigma logic programming.

## Peta konsep: Haskell → Prolog

| Konsep Haskell | Di Haskell | Padanan Prolog |
|---|---|---|
| Pure functions | `calculateDTI :: Double -> Double -> Double` | Relasi deterministik `calculate_dti/3` |
| Algebraic Data Types | `data LoanDecision = Approved \| Rejected \| PendingReview` | Compound terms: `approved/2`, `rejected/1`, `pending_review/1` |
| Pattern matching | `decide app \| not (passes...) = Rejected` | Head unification + cut per klausa |
| Functions as first-class values | `type Rule = LoanApplication -> Bool` | Goals sebagai data, di-`call/2` (meta-call) |
| Higher-order functions | `all (\rule -> rule app) rules` | `maplist/2`, `include/3` |
| `Either` for typed failure | `Either String LoanDecision` | Term `ok(X)` / `error(Msg)` |
| Function composition `.` | `fullPipeline = notify . decide . adjust` | Rantai predikat via variabel antara |
| Reader monad | `ReaderT BankConfig` | Argumen config diteruskan eksplisit |
| State monad | `StateT BankState` | Pasangan argumen `StateIn, StateOut` |
| Except monad | `ExceptT String` | `catch/throw` + term `error(Msg)` |
| Type class (ad-hoc polymorphism) | `class Auditable a where ...` | Multifile predicate `audit_entry/3` |
| Existential types | `data AnyAuditable = forall a. Auditable a => MkAuditable a` | List heterogen native Prolog |
| Property-based testing (QuickCheck) | `prop_dtiNeverNegative :: NonNegative Double -> ...` | `plunit` + generator `gen_loan_app2/1` |

## Yang LEBIH MUDAH di Prolog

- **Query multi-arah**: `layak(X)` menemukan SEMUA pemohon yang layak tanpa loop eksplisit
- **List heterogen**: `log_mixed_batch([approved(...), rejected(...), 'string', app(...)])` bekerja langsung tanpa existential wrapper
- **Meta-programming**: goals adalah data — `findall`, `call`, `assert` tanpa reflection API
- **Backtracking otomatis**: pencarian kombinatorial gratis tanpa kode ekstra

## Struktur file

```
los-prolog/
├── los_lib.pl   -- semua logika domain (analog src/Lib.hs)
├── main.pl      -- demo end-to-end bercetak (analog app/Main.hs)
├── spec.pl      -- property-based tests (analog test/Spec.hs)
└── README.md
```

## Cara menjalankan

### Prasyarat
SWI-Prolog ≥ 9.0 — download di https://www.swi-prolog.org/Download.html

### Demo end-to-end
```bash
# Non-interaktif
swipl -g main -t halt main.pl

# Interaktif (bisa query manual setelahnya)
swipl main.pl
?- main.
```

### Tests
```bash
swipl -g run_tests -t halt spec.pl
```

### Konsol interaktif (yang paling menarik!)
```bash
swipl los_lib.pl
```

Kemudian coba query berikut untuk merasakan multi-directionality:

```prolog
% Apakah Budi layak?
?- passes_all_rules(loan_app('Budi', 200_000_000, 0.0, 24, 680, 3_000_000, 12_000_000)).

% Berapa cicilan?
?- calculate_monthly_payment(200_000_000, 8.0, 24, P).

% Aturan mana yang GAGAL untuk skor rendah?
?- failing_rules(loan_app('Siti', 50_000_000, 0.0, 24, 590, 3_000_000, 12_000_000), F).

% Audit entry untuk berbagai tipe (polymorphism via dispatch):
?- audit_entry(approved(200_000_000, 6.75), Sev, Entry).
?- audit_entry(rejected("DTI terlalu tinggi"), Sev, Entry).
?- audit_entry('pola suspicious terdeteksi', Sev, Entry).

% Meta: rules apa yang lolos?
?- which_rules_pass(loan_app('Budi', 200_000_000, 0.0, 24, 680, 3_000_000, 12_000_000), R).
```

## Karakteristik Logic Programming yang didemonstrasikan

1. **Unifikasi** — pencocokan pola struktural di head clause, bukan assignment
2. **Backtracking** — Prolog otomatis mencoba klausa berikutnya saat gagal
3. **Closed-world assumption** — `\+ goal` berarti "tidak bisa dibuktikan benar"
4. **Relasi invertible** — predikat bisa di-query dari berbagai arah
5. **Goals sebagai data** — meta-call via `call/N`, YALL lambdas (`[X]>>(...)`)
6. **Threaded state** — State monad diimplementasi murni via argumen In/Out
7. **Dispatch via unifikasi** — "type class" tanpa vtable, hanya pattern matching

## Catatan implementasi

- `cut (!)` digunakan minimal, hanya untuk menentukan klausa mana yang "menang"
  ketika kondisi mutually exclusive — analog `|` (otherwise) di Haskell guards.
- `->` (if-then) digunakan untuk branching dalam satu klausa; klausa terpisah
  lebih deklaratif tapi `->` lebih kompak untuk kasus sederhana.
- State underwriting menggunakan **copy semantics**: `bank_state(Q0, Log0)` tidak
  pernah dimutasi — hanya diikat ke variabel baru `bank_state(Q1, Log1)`.
  Jika predikat gagal/throw, `StateOut` tidak ter-bind dan `StateIn` utuh.
