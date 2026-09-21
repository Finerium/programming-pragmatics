# los-haskell — Loan Originating System as a tour of Haskell FP

A small, self-contained Haskell project that uses a Loan Originating System
(LOS) domain to walk through the core ideas of functional programming:

| Concept | Where |
|---|---|
| Pure functions | `Lib.calculateDTI`, `Lib.calculateMonthlyPayment` |
| Immutability / record update | `Lib.adjustRateForRisk` |
| Functions as first-class values | `Lib.Rule`, `Lib.underwritingRules` |
| Higher-order functions | `Lib.passesAllRules` (`all`), `logBatch` (`mapM_`) |
| Algebraic data types + pattern matching | `Lib.LoanDecision`, `Lib.notifyApplicant` |
| `Either` for explicit, typed failure | `Lib.validateApplication`, `Lib.processApplication` |
| Function composition | `Lib.fullPipeline` |
| `Reader` + `State` + `Except` stack | `Lib.Underwriting`, `Lib.underwriteApplication`, `Lib.runUnderwriting` |
| Type classes (ad-hoc polymorphism) | `Lib.Auditable`, its three instances |
| Existential types | `Lib.AnyAuditable`, `Lib.logMixedBatch` |
| Property-based testing (QuickCheck) | `test/Spec.hs` |

## Project layout

```
los-haskell/
├── los-haskell.cabal   -- package definition (library + exe + test-suite)
├── app/
│   └── Main.hs         -- runs through every concept end-to-end, prints output
├── src/
│   └── Lib.hs           -- all the domain logic described above
├── test/
│   └── Spec.hs           -- QuickCheck properties
└── README.md
```

## Building and running

This is a standard Cabal package. With GHC + Cabal installed:

```bash
cd los-haskell
cabal build
cabal run los-haskell     # runs app/Main.hs, prints the full walkthrough
cabal test                # runs the QuickCheck property suite
```

If you prefer Stack, `stack init` in this directory will generate a
`stack.yaml` from the `.cabal` file automatically, then:

```bash
stack build
stack exec los-haskell
stack test
```

## What `cabal run` prints

Running the executable walks through, in order:

1. Two pure calculations (DTI and monthly payment)
2. The pure `fullPipeline` for a good applicant and a risky one
3. `Either`-based validation, including a deliberately invalid application
4. The full `Reader`+`State`+`Except` underwriting stack — once for a normal
   approval, once for an application that exceeds the daily credit quota
   (demonstrating that a failure leaves the bank's state untouched)
5. The `Auditable` type class logging several different types through one
   function, plus a mixed-type batch filtered by severity

## What `cabal test` checks

`test/Spec.hs` defines an `Arbitrary LoanApplication` generator and six
properties, e.g. "DTI is never negative", "a strictly higher credit score
never results in a strictly worse rate", and "the underwriting pipeline is
deterministic — no hidden state leaks between runs". QuickCheck generates
100 random applications per property (with automatic shrinking to a minimal
failing case if one is found) rather than relying on a handful of
hand-picked examples.

## Notes on the code

- `Underwriting` is defined as
  `ReaderT BankConfig (StateT BankState (ExceptT String IO)) a`. `IO` sits
  at the bottom only so the demo can be run directly; nothing in `Lib.hs`
  actually performs `IO` other than the final `runExceptT`. In a pure
  setting you'd swap `IO` for `Identity` and use `runIdentity` instead of
  the `IO`-flavoured runner.
- `LoanApplication`'s `Show` instance masks the applicant's name, since
  printing raw customer PII to logs is a compliance risk — this is done
  once, at the type level, so no call site can "forget" to mask it.
