package los;

/** Konfigurasi bank yang tidak berubah selama satu sesi. Padanan BankConfig di Haskell. */
public record BankConfig(double baseRate, BankPolicy policy, double maxLoanAmount, int minCreditScore) {
}
