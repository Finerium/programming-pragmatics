{-# LANGUAGE NumericUnderscores #-}
module Main (main) where

import Lib

sampleApp :: LoanApplication
sampleApp = LoanApplication
  { applicantName = "Budi"
  , principal     = 200_000_000
  , annualRate    = 0
  , termMonths    = 24
  , creditScore   = 680
  , monthlyDebt   = 3_000_000
  , monthlyIncome = 12_000_000
  }

lowScoreApp :: LoanApplication
lowScoreApp = sampleApp { applicantName = "Siti", creditScore = 590, principal = 50_000_000 }

overQuotaApp :: LoanApplication
overQuotaApp = sampleApp { applicantName = "Andi", principal = 3_000_000_000 }

main :: IO ()
main = do
  putStrLn "=== 1) Pure calculations ==="
  print (calculateDTI (monthlyDebt sampleApp) (monthlyIncome sampleApp))
  print (calculateMonthlyPayment 200_000_000 8.0 24)

  putStrLn "\n=== 2) Pure decision pipeline (adjustRateForRisk . decide . notify) ==="
  putStrLn (fullPipeline sampleApp)
  putStrLn (fullPipeline lowScoreApp)

  putStrLn "\n=== 3) Either-based validation ==="
  case processApplication sampleApp of
    Left err       -> putStrLn ("Validasi gagal: " ++ err)
    Right decision -> print decision
  case processApplication (sampleApp { principal = -1 }) of
    Left err       -> putStrLn ("Validasi gagal: " ++ err)
    Right decision -> print decision

  putStrLn "\n=== 4) Reader + State + Except stack ==="
  let cfg = BankConfig
        { baseRate = 6.25
        , bankPolicy = Standard
        , maxLoanAmount = 500_000_000
        , minCreditScoreCfg = 620
        }
      initSt = BankState { remainingQuota = 1_000_000_000, auditLog = [] }

  result1 <- runUnderwriting cfg initSt sampleApp
  case result1 of
    Left err -> putStrLn ("Ditolak sistem: " ++ err)
    Right (decision, finalSt) -> do
      print decision
      putStrLn ("Sisa kuota: " ++ show (remainingQuota finalSt))
      mapM_ putStrLn (auditLog finalSt)

  putStrLn "\n--- Kasus gagal: melebihi kuota, state harus TIDAK berubah ---"
  result2 <- runUnderwriting cfg initSt overQuotaApp
  case result2 of
    Left err -> putStrLn ("Ditolak sistem: " ++ err)
    Right (decision, _) -> print decision

  putStrLn "\n=== 5) Type class based audit trail ==="
  logToAuditTrail (Approved 200_000_000 6.75)
  logToAuditTrail (Rejected "Skor kredit tidak memenuhi syarat")
  logToAuditTrail sampleApp
  logToAuditTrail "Terdeteksi pola aplikasi yang suspicious dari IP yang sama"

  putStrLn "\n--- Mixed batch, hanya Warning+ yang tampil ---"
  logMixedBatch
    [ MkAuditable (Approved 200_000_000 6.75)
    , MkAuditable (Rejected "DTI terlalu tinggi")
    , MkAuditable "Login mencurigakan terdeteksi"
    , MkAuditable sampleApp
    ]
