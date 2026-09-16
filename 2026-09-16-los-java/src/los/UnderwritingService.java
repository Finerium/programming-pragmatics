package los;

/**
 * Padanan tumpukan ReaderT + StateT + ExceptT di Haskell.
 * Reader  : BankConfig disuntik lewat constructor, dibaca semua method tanpa dioper ulang.
 * State   : BankState dioper masuk dan dikembalikan lagi, tidak pernah diubah di tempat.
 * Except  : kegagalan dikembalikan sebagai Result.Err, dan karena state hanya ikut pada jalur sukses,
 *           kegagalan di tengah proses tidak pernah meninggalkan kuota yang terlanjur terpotong.
 */
public final class UnderwritingService {

    private final BankConfig config;

    public UnderwritingService(BankConfig config) {
        this.config = config;
    }

    public record Outcome(LoanDecision decision, BankState state) {
    }

    public Result<Outcome> underwrite(LoanApplication app, BankState awal) {
        if (app.principal() <= 0) {
            return Result.err("Jumlah pinjaman harus positif");
        }
        if (app.creditScore() < config.minCreditScore()) {
            return Result.err("Skor kredit di bawah minimum bank: " + config.minCreditScore());
        }
        BankState state = awal.log("Validasi dasar lolos untuk " + app.applicantName());

        if (app.principal() > state.remainingQuota()) {
            return Result.err("Plafon kredit hari ini sudah habis");
        }
        state = state.reserve(app.principal()).log("Kuota dicadangkan: " + Fmt.rupiah(app.principal()));

        double rate = finalRate(app);
        state = state.log("Disetujui dengan rate " + Fmt.persen(rate));
        return Result.ok(new Outcome(new LoanDecision.Approved(app.principal(), rate), state));
    }

    private double finalRate(LoanApplication app) {
        double premiRisiko;
        if (app.creditScore() < 600) {
            premiRisiko = 3.5;
        } else if (app.creditScore() < 700) {
            premiRisiko = 1.5;
        } else {
            premiRisiko = 0.5;
        }
        return config.baseRate() + premiRisiko + config.policy().penyesuaian();
    }
}
