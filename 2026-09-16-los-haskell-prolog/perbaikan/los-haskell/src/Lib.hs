{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE NumericUnderscores #-}

-- |
-- Module      : Lib
-- Description : A Loan Originating System (LOS) used as a tour of Haskell FP
--
-- This module deliberately walks through, in order:
--   1. Pure functions & data types
--   2. Algebraic Data Types + pattern matching
--   3. Maybe / Either for explicit failure
--   4. Function composition & higher-order functions
--   5. Reader + State + Except combined via a monad transformer stack
--   6. A custom type class ("Auditable") with default methods
module Lib
  ( -- * Core domain types
    LoanApplication (..)
  , LoanDecision (..)
  , BankConfig (..)
  , BankPolicy (..)
  , BankState (..)
  , AuditSeverity (..)

    -- * Pure calculations
  , calculateDTI
  , calculateMonthlyPayment

    -- * Business rules as first-class values
  , Rule
  , minCreditScore
  , maxDTI
  , underwritingRules
  , passesAllRules

    -- * Simple decision pipeline (pure)
  , adjustRateForRisk
  , decide
  , notifyApplicant
  , fullPipeline

    -- * Validation with Either
  , validateApplication
  , processApplication

    -- * The Reader + State + Except stack
  , Underwriting
  , underwriteApplication
  , runUnderwriting

    -- * Type class based audit trail
  , Auditable (..)
  , AnyAuditable (..)
  , logToAuditTrail
  , logBatch
  , logMixedBatch
  ) where

import Control.Monad (forM_, when)
import Control.Monad.Except (ExceptT, runExceptT, throwError)
import Control.Monad.Reader (ReaderT, ask, runReaderT)
import Control.Monad.State (StateT, get, modify, put, runStateT)
import Data.List (isInfixOf)

--------------------------------------------------------------------------------
-- Core domain types
--------------------------------------------------------------------------------

data LoanApplication = LoanApplication
  { applicantName :: String
  , principal     :: Double
  , annualRate    :: Double
  , termMonths    :: Int
  , creditScore   :: Int
  , monthlyDebt   :: Double
  , monthlyIncome :: Double
  } deriving (Eq)

instance Show LoanApplication where
  show app =
    "LoanApplication{applicant=" ++ maskName (applicantName app)
      ++ ", principal=" ++ show (principal app)
      ++ ", score=" ++ show (creditScore app) ++ "}"
    where
      maskName (c : _ : _ : _) = [c] ++ "***"
      maskName other           = other

-- | Illegal states are unrepresentable: a 'Rejected' value can never carry
-- an approved amount, and an 'Approved' value can never be missing a rate.
data LoanDecision
  = Approved { approvedAmount :: Double, finalRate :: Double }
  | Rejected { reason :: String }
  | PendingReview { missingDocs :: [String] }
  deriving (Show, Eq)

data BankPolicy = Conservative | Standard | Aggressive
  deriving (Show, Eq)

data BankConfig = BankConfig
  { baseRate       :: Double
  , bankPolicy     :: BankPolicy
  , maxLoanAmount  :: Double
  , minCreditScoreCfg :: Int
  } deriving (Show)

data BankState = BankState
  { remainingQuota :: Double
  , auditLog       :: [String]
  } deriving (Show, Eq)

data AuditSeverity = Info | Warning | Critical
  deriving (Show, Eq, Ord)

--------------------------------------------------------------------------------
-- Pure calculations
--------------------------------------------------------------------------------

-- | Debt-to-income ratio. Pure: same inputs always give the same output.
calculateDTI :: Double -> Double -> Double
calculateDTI debt income
  | income <= 0 = 0
  | otherwise   = debt / income

-- | Standard amortized monthly payment formula.
calculateMonthlyPayment :: Double -> Double -> Int -> Double
calculateMonthlyPayment princ annualRatePct months
  | months <= 0 = 0
  | r == 0      = princ / fromIntegral months
  | otherwise   =
      princ * r * (1 + r) ** n / ((1 + r) ** n - 1)
  where
    r = annualRatePct / 12 / 100
    n = fromIntegral months

--------------------------------------------------------------------------------
-- Business rules as first-class values
--------------------------------------------------------------------------------

type Rule = LoanApplication -> Bool

minCreditScore :: Int -> Rule
minCreditScore minScore app = creditScore app >= minScore

maxDTI :: Double -> Rule
maxDTI maxRatio app = calculateDTI (monthlyDebt app) (monthlyIncome app) <= maxRatio

underwritingRules :: [Rule]
underwritingRules =
  [ minCreditScore 620
  , maxDTI 0.43
  , \app -> principal app <= 2_000_000_000
  ]

passesAllRules :: LoanApplication -> Bool
passesAllRules app = all (\rule -> rule app) underwritingRules

--------------------------------------------------------------------------------
-- Simple decision pipeline (pure)
--------------------------------------------------------------------------------

adjustRateForRisk :: LoanApplication -> LoanApplication
adjustRateForRisk app
  | creditScore app < 600 = app { annualRate = annualRate app + 3.5 }
  | creditScore app < 700 = app { annualRate = annualRate app + 1.5 }
  | otherwise              = app

decide :: LoanApplication -> LoanDecision
decide app
  | not (passesAllRules app) = Rejected "Tidak memenuhi kriteria underwriting"
  | creditScore app < 650    = PendingReview ["Slip gaji 3 bulan terakhir"]
  | otherwise                 = Approved (principal app) (annualRate app)

notifyApplicant :: LoanDecision -> String
notifyApplicant (Approved amount rate) =
  "Selamat! Pinjaman Rp" ++ show amount ++ " disetujui dengan bunga " ++ show rate ++ "%"
notifyApplicant (Rejected why) =
  "Maaf, pengajuan ditolak. Alasan: " ++ why
notifyApplicant (PendingReview docs) =
  "Perlu dokumen tambahan: " ++ show docs

-- | Function composition: read right-to-left, like a chain of funnels.
fullPipeline :: LoanApplication -> String
fullPipeline = notifyApplicant . decide . adjustRateForRisk

--------------------------------------------------------------------------------
-- Validation with Either
--------------------------------------------------------------------------------

validateApplication :: LoanApplication -> Either String LoanApplication
validateApplication app
  | principal app <= 0    = Left "Jumlah pinjaman harus positif"
  | termMonths app <= 0   = Left "Tenor harus positif"
  | creditScore app < 300 = Left "Skor kredit tidak valid"
  | otherwise              = Right app

processApplication :: LoanApplication -> Either String LoanDecision
processApplication app = do
  validApp <- validateApplication app
  let adjusted = adjustRateForRisk validApp
  return (decide adjusted)

--------------------------------------------------------------------------------
-- The Reader + State + Except stack
--------------------------------------------------------------------------------

-- | A computation that can read a fixed 'BankConfig', thread a mutable
-- 'BankState', and fail at any point with a 'String' explanation.
type Underwriting a = ReaderT BankConfig (StateT BankState (ExceptT String IO)) a

logStep :: String -> Underwriting ()
logStep msg = modify (\st -> st { auditLog = auditLog st ++ [msg] })

validateApp :: LoanApplication -> Underwriting ()
validateApp app = do
  cfg <- ask
  when (principal app <= 0) $
    throwError "Jumlah pinjaman harus positif"
  when (creditScore app < minCreditScoreCfg cfg) $
    throwError ("Skor kredit di bawah minimum bank: " ++ show (minCreditScoreCfg cfg))
  logStep ("Validasi dasar lolos untuk " ++ applicantName app)

checkAndReserveQuota :: LoanApplication -> Underwriting ()
checkAndReserveQuota app = do
  st <- get
  when (principal app > remainingQuota st) $
    throwError "Plafon kredit hari ini sudah habis"
  put st { remainingQuota = remainingQuota st - principal app }
  logStep ("Kuota dicadangkan: Rp" ++ show (principal app))

calculateFinalRate :: LoanApplication -> Underwriting Double
calculateFinalRate app = do
  cfg <- ask
  let riskPremium
        | creditScore app < 600 = 3.5
        | creditScore app < 700 = 1.5
        | otherwise               = 0.5
      policyAdjustment = case bankPolicy cfg of
        Conservative -> 0.5
        Standard     -> 0.0
        Aggressive   -> -0.5
  return (baseRate cfg + riskPremium + policyAdjustment)

underwriteApplication :: LoanApplication -> Underwriting LoanDecision
underwriteApplication app = do
  validateApp app
  checkAndReserveQuota app
  rate <- calculateFinalRate app
  logStep ("Disetujui dengan rate " ++ show rate ++ "%")
  return (Approved (principal app) rate)

-- | Run the full stack. If anything fails with 'throwError', the whole
-- computation short-circuits and the 'BankState' mutations made so far are
-- discarded (nothing "half-updates" the quota) — this is IO because
-- ExceptT sits above IO here, but no real IO is performed in this demo.
runUnderwriting
  :: BankConfig
  -> BankState
  -> LoanApplication
  -> IO (Either String (LoanDecision, BankState))
runUnderwriting cfg initialState app =
  runExceptT (runStateT (runReaderT (underwriteApplication app) cfg) initialState)

--------------------------------------------------------------------------------
-- Type class based audit trail
--------------------------------------------------------------------------------

class Auditable a where
  toAuditEntry :: a -> String

  severity :: a -> AuditSeverity
  severity _ = Info

instance Auditable LoanDecision where
  toAuditEntry (Approved amt rate) =
    "APPROVED | amount=" ++ show amt ++ " | rate=" ++ show rate ++ "%"
  toAuditEntry (Rejected why) =
    "REJECTED | reason=" ++ why
  toAuditEntry (PendingReview docs) =
    "PENDING | missing=" ++ show docs

  severity (Approved _ _)    = Info
  severity (Rejected _)      = Warning
  severity (PendingReview _) = Warning

instance Auditable LoanApplication where
  toAuditEntry app =
    "APPLICATION | applicant=" ++ applicantName app
      ++ " | principal=" ++ show (principal app)
      ++ " | score=" ++ show (creditScore app)

instance Auditable String where
  toAuditEntry s = "NOTE | " ++ s
  severity s
    | "fraud" `isInfixOf` s || "suspicious" `isInfixOf` s = Critical
    | otherwise = Info

logToAuditTrail :: Auditable a => a -> IO ()
logToAuditTrail item =
  putStrLn ("[" ++ show (severity item) ++ "] " ++ toAuditEntry item)

logBatch :: Auditable a => [a] -> IO ()
logBatch = mapM_ logToAuditTrail

-- | An existential wrapper so a single list can hold mixed 'Auditable' types.
data AnyAuditable = forall a. Auditable a => MkAuditable a

logMixedBatch :: [AnyAuditable] -> IO ()
logMixedBatch items = forM_ items $ \(MkAuditable item) ->
  when (severity item >= Warning) $ logToAuditTrail item
