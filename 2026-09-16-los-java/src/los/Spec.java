package los;

import java.util.List;
import java.util.Random;
import java.util.function.Predicate;

/**
 * Property-based testing sederhana tanpa library tambahan, meniru cara kerja QuickCheck:
 * generator acak, 100 kasus per property, dan kasus yang tidak relevan dihitung sebagai discard.
 */
public final class Spec {

    static final Random ACAK = new Random(42);
    static final BankConfig CFG = new BankConfig(6.25, BankPolicy.STANDARD, 500_000_000, 620);

    static LoanApplication genApp() {
        String[] nama = {"Budi", "Siti", "Andi", "Rina", "Wati"};
        return new LoanApplication(
                nama[ACAK.nextInt(nama.length)],
                1_000_000 + ACAK.nextDouble() * 4_999_000_000d,
                3 + ACAK.nextDouble() * 22,
                6 + ACAK.nextInt(355),
                300 + ACAK.nextInt(551),
                ACAK.nextDouble() * 20_000_000,
                1_000_000 + ACAK.nextDouble() * 49_000_000);
    }

    public static void main(String[] args) {
        int gagal = 0;
        gagal += cek("dtiNeverNegative", app -> Calculations.calculateDti(app.monthlyDebt(), app.monthlyIncome()) >= 0);
        gagal += cek("paymentIsPositive",
                app -> Calculations.calculateMonthlyPayment(app.principal(), app.annualRate(), app.termMonths()) > 0);
        gagal += cekBersyarat("higherScoreGetsBetterOrEqualRate",
                app -> app.creditScore() < 850,
                app -> {
                    Double r1 = rateOf(app);
                    Double r2 = rateOf(app.withScore(Math.min(850, app.creditScore() + 50)));
                    return r1 == null || r2 == null || r2 <= r1;
                });
        gagal += cekBersyarat("validateRejectsNonPositivePrincipal",
                app -> app.principal() <= 0,
                app -> !Pipeline.validateApplication(app).berhasil());
        gagal += cekBersyarat("passesAllImpliesEachRule",
                Rules::passesAll,
                app -> Rules.underwriting().stream().allMatch(rule -> rule.test(app)));
        gagal += cek("underwritingIsDeterministic", app -> {
            UnderwritingService layanan = new UnderwritingService(CFG);
            BankState awal = BankState.awal(1_000_000_000);
            Result<UnderwritingService.Outcome> r1 = layanan.underwrite(app, awal);
            Result<UnderwritingService.Outcome> r2 = layanan.underwrite(app, awal);
            return ringkas(r1).equals(ringkas(r2));
        });

        System.out.println();
        System.out.println(gagal == 0 ? "Semua property lolos." : gagal + " property gagal.");
        if (gagal > 0) {
            System.exit(1);
        }
    }

    static Double rateOf(LoanApplication app) {
        return Pipeline.decide(Pipeline.adjustRateForRisk(app)) instanceof LoanDecision.Approved a ? a.rate() : null;
    }

    static String ringkas(Result<UnderwritingService.Outcome> hasil) {
        return switch (hasil) {
            case Result.Ok<UnderwritingService.Outcome> ok -> "ok:" + ok.value().decision();
            case Result.Err<UnderwritingService.Outcome> err -> "err:" + err.message();
        };
    }

    static int cek(String nama, Predicate<LoanApplication> property) {
        return cekBersyarat(nama, app -> true, property);
    }

    /** Kasus yang tidak memenuhi syarat dibuang (discard), persis seperti operator ==> di QuickCheck. */
    static int cekBersyarat(String nama, Predicate<LoanApplication> syarat, Predicate<LoanApplication> property) {
        int lolos = 0;
        int dibuang = 0;
        List<LoanApplication> gagal = new java.util.ArrayList<>();
        for (int i = 0; lolos < 100 && i < 10_000; i++) {
            LoanApplication app = genApp();
            if (!syarat.test(app)) {
                dibuang++;
                continue;
            }
            if (property.test(app)) {
                lolos++;
            } else {
                gagal.add(app);
                break;
            }
        }
        System.out.print(nama + " ... ");
        if (!gagal.isEmpty()) {
            System.out.println("GAGAL pada kasus: " + gagal.get(0));
            return 1;
        }
        if (lolos < 100) {
            System.out.println("menyerah, cuma " + lolos + " kasus relevan, " + dibuang + " dibuang");
            return 0;
        }
        System.out.println("lolos " + lolos + " kasus" + (dibuang > 0 ? ", " + dibuang + " dibuang" : ""));
        return 0;
    }
}
