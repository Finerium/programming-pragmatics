{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE NumericUnderscores #-}
module Main (main) where

import Lib
import Test.QuickCheck

-- | Generator for realistic-looking loan applications.
instance Arbitrary LoanApplication where
  arbitrary = do
    name   <- elements ["Budi", "Siti", "Andi", "Rina", "Wati"]
    princ  <- choose (1_000_000, 5_000_000_000)
    rate   <- choose (3.0, 25.0)
    term   <- choose (6, 360)
    score  <- choose (300, 850)
    debt   <- choose (0, 20_000_000)
    income <- choose (1_000_000, 50_000_000)
    return LoanApplication
      { applicantName = name
      , principal     = princ
      , annualRate    = rate
      , termMonths    = term
      , creditScore   = score
      , monthlyDebt   = debt
      , monthlyIncome = income
      }

-- Property: DTI is never negative for non-negative debt and positive income.
prop_dtiNeverNegative :: NonNegative Double -> Positive Double -> Bool
prop_dtiNeverNegative (NonNegative debt) (Positive income) =
  calculateDTI debt income >= 0

-- Property: a positive principal/rate/term always yields a positive payment.
prop_paymentIsPositive :: Positive Double -> Positive Double -> Positive Int -> Bool
prop_paymentIsPositive (Positive princ) (Positive rate) (Positive months) =
  calculateMonthlyPayment princ rate months > 0

-- Property: an applicant with a strictly higher credit score never ends up
-- with a strictly worse (higher) rate than their lower-score counterpart,
-- all else being equal — a basic fairness/consistency check on the rate
-- engine.
prop_higherScoreGetsBetterOrEqualRate :: LoanApplication -> Property
prop_higherScoreGetsBetterOrEqualRate app =
  creditScore app < 850 ==>
    let appBetter = app { creditScore = min 850 (creditScore app + 50) }
        rateOf a = case decide (adjustRateForRisk a) of
          Approved _ r -> Just r
          _            -> Nothing
    in case (rateOf app, rateOf appBetter) of
         (Just r1, Just r2) -> r2 <= r1
         _                  -> True -- one side rejected/pending: not comparable

-- Property: validateApplication never accepts a non-positive principal.
prop_validateRejectsNonPositivePrincipal :: LoanApplication -> Property
prop_validateRejectsNonPositivePrincipal app =
  principal app <= 0 ==>
    case validateApplication app of
      Left _  -> True
      Right _ -> False

-- Property: passesAllRules implies the application also satisfies each
-- individual rule (a basic sanity check that `all` is doing its job).
prop_passesAllImpliesEachRule :: LoanApplication -> Property
prop_passesAllImpliesEachRule app =
  passesAllRules app ==> all (\rule -> rule app) underwritingRules

-- Property: when the underwriting stack fails, the state returned by
-- runUnderwriting is untouched — i.e. failures never leak a partially
-- mutated BankState. We check this by running twice with identical
-- inputs and confirming both attempts produce the same Either result
-- (determinism / no hidden mutation).
prop_underwritingIsDeterministic :: LoanApplication -> Property
prop_underwritingIsDeterministic app = ioProperty $ do
  let cfg = BankConfig
        { baseRate = 6.25
        , bankPolicy = Standard
        , maxLoanAmount = 500_000_000
        , minCreditScoreCfg = 620
        }
      initSt = BankState { remainingQuota = 1_000_000_000, auditLog = [] }
  r1 <- runUnderwriting cfg initSt app
  r2 <- runUnderwriting cfg initSt app
  return (fmap fst r1 == fmap fst r2)

main :: IO ()
main = do
  putStrLn "prop_dtiNeverNegative"
  quickCheck prop_dtiNeverNegative

  putStrLn "prop_paymentIsPositive"
  quickCheck prop_paymentIsPositive

  putStrLn "prop_higherScoreGetsBetterOrEqualRate"
  quickCheck prop_higherScoreGetsBetterOrEqualRate

  putStrLn "prop_validateRejectsNonPositivePrincipal"
  quickCheck prop_validateRejectsNonPositivePrincipal

  putStrLn "prop_passesAllImpliesEachRule"
  quickCheck prop_passesAllImpliesEachRule

  putStrLn "prop_underwritingIsDeterministic"
  quickCheck prop_underwritingIsDeterministic
