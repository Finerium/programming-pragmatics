package los;

import java.util.List;

/** Kumpulan aturan underwriting. Padanan underwritingRules di Haskell. */
public final class Rules {
    private Rules() {
    }

    public static Rule minCreditScore(int minimal) {
        return app -> app.creditScore() >= minimal;
    }

    public static Rule maxDti(double maksimal) {
        return app -> Calculations.calculateDti(app.monthlyDebt(), app.monthlyIncome()) <= maksimal;
    }

    public static Rule maxPrincipal(double maksimal) {
        return app -> app.principal() <= maksimal;
    }

    public static List<Rule> underwriting() {
        return List.of(minCreditScore(620), maxDti(0.43), maxPrincipal(2_000_000_000d));
    }

    /** Higher-order: aturan diperlakukan sebagai data lalu diuji semuanya sekaligus. */
    public static boolean passesAll(LoanApplication app) {
        return underwriting().stream().allMatch(rule -> rule.test(app));
    }

    public static long jumlahGagal(LoanApplication app) {
        return underwriting().stream().filter(rule -> !rule.test(app)).count();
    }
}
