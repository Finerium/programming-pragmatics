package los;

import java.util.List;
import java.util.function.Function;

/** Alur keputusan murni: sesuaikan bunga, putuskan, lalu susun pesan untuk pemohon. */
public final class Pipeline {
    private Pipeline() {
    }

    public static LoanApplication adjustRateForRisk(LoanApplication app) {
        if (app.creditScore() < 600) {
            return app.withRate(app.annualRate() + 3.5);
        }
        if (app.creditScore() < 700) {
            return app.withRate(app.annualRate() + 1.5);
        }
        return app;
    }

    public static LoanDecision decide(LoanApplication app) {
        if (!Rules.passesAll(app)) {
            return new LoanDecision.Rejected("Tidak memenuhi kriteria underwriting");
        }
        if (app.creditScore() < 650) {
            return new LoanDecision.PendingReview(List.of("Slip gaji 3 bulan terakhir"));
        }
        return new LoanDecision.Approved(app.principal(), app.annualRate());
    }

    /** Pattern matching atas sealed interface: compiler menolak kalau ada bentuk yang belum ditangani. */
    public static String notifyApplicant(LoanDecision keputusan) {
        return switch (keputusan) {
            case LoanDecision.Approved a ->
                    "Selamat! Pinjaman " + Fmt.rupiah(a.amount()) + " disetujui dengan bunga " + Fmt.persen(a.rate());
            case LoanDecision.Rejected r -> "Maaf, pengajuan ditolak. Alasan: " + r.reason();
            case LoanDecision.PendingReview p -> "Perlu dokumen tambahan: " + p.missingDocs();
        };
    }

    /** Komposisi fungsi: padanan notifyApplicant . decide . adjustRateForRisk di Haskell. */
    public static final Function<LoanApplication, String> FULL_PIPELINE =
            ((Function<LoanApplication, LoanApplication>) Pipeline::adjustRateForRisk)
                    .andThen(Pipeline::decide)
                    .andThen(Pipeline::notifyApplicant);

    public static String fullPipeline(LoanApplication app) {
        return FULL_PIPELINE.apply(app);
    }

    public static Result<LoanApplication> validateApplication(LoanApplication app) {
        if (app.principal() <= 0) {
            return Result.err("Jumlah pinjaman harus positif");
        }
        if (app.termMonths() <= 0) {
            return Result.err("Tenor harus positif");
        }
        if (app.creditScore() < 300) {
            return Result.err("Skor kredit tidak valid");
        }
        return Result.ok(app);
    }

    /** flatMap membuat rantai validasi berhenti di kegagalan pertama, seperti do-block Either. */
    public static Result<LoanDecision> processApplication(LoanApplication app) {
        return validateApplication(app).map(Pipeline::adjustRateForRisk).map(Pipeline::decide);
    }
}
