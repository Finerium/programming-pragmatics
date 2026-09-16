package los;

import java.util.List;

/** Demo end-to-end. Bagian 1 sampai 5 urutannya sama dengan app/Main.hs dan main.pl, 2b dan 6 tambahan. */
public final class Main {

    static final LoanApplication SAMPLE = new LoanApplication("Budi", 200_000_000, 0, 24, 680, 3_000_000, 12_000_000);
    static final LoanApplication SKOR_RENDAH = SAMPLE.withName("Siti").withScore(590).withPrincipal(50_000_000);
    static final LoanApplication LEBIH_KUOTA = SAMPLE.withName("Andi").withPrincipal(3_000_000_000d);

    public static void main(String[] args) {
        System.out.println("=== 1) Perhitungan murni ===");
        System.out.println("  DTI Budi: " + Calculations.calculateDti(SAMPLE.monthlyDebt(), SAMPLE.monthlyIncome()));
        System.out.println("  Cicilan Rp200jt @ 8% / 24bln: "
                + Fmt.rupiah(Calculations.calculateMonthlyPayment(200_000_000, 8.0, 24)));

        System.out.println();
        System.out.println("=== 2) Pipeline keputusan (adjust -> decide -> notify) ===");
        System.out.println("  Budi : " + Pipeline.fullPipeline(SAMPLE));
        System.out.println("  Siti : " + Pipeline.fullPipeline(SKOR_RENDAH));

        System.out.println();
        System.out.println("=== 2b) Aturan sebagai data: berapa aturan yang gagal? ===");
        System.out.println("  Budi gagal di " + Rules.jumlahGagal(SAMPLE) + " aturan");
        System.out.println("  Siti gagal di " + Rules.jumlahGagal(SKOR_RENDAH) + " aturan");

        System.out.println();
        System.out.println("=== 3) Validasi dengan Result (padanan Either) ===");
        cetakHasil(Pipeline.processApplication(SAMPLE));
        cetakHasil(Pipeline.processApplication(SAMPLE.withPrincipal(-1)));

        System.out.println();
        System.out.println("=== 4) Underwriting dengan config + state (Reader + State + Except) ===");
        BankConfig cfg = new BankConfig(6.25, BankPolicy.STANDARD, 500_000_000, 620);
        BankState awal = BankState.awal(1_000_000_000);
        UnderwritingService layanan = new UnderwritingService(cfg);

        switch (layanan.underwrite(SAMPLE, awal)) {
            case Result.Ok<UnderwritingService.Outcome> ok -> {
                System.out.println("  Keputusan  : " + ok.value().decision());
                System.out.println("  Sisa kuota : " + Fmt.rupiah(ok.value().state().remainingQuota()));
                ok.value().state().auditLog().forEach(baris -> System.out.println("    - " + baris));
            }
            case Result.Err<UnderwritingService.Outcome> err -> System.out.println("  Ditolak sistem: " + err.message());
        }

        System.out.println();
        System.out.println("  --- Kasus gagal: melebihi kuota, state awal harus TIDAK berubah ---");
        Result<UnderwritingService.Outcome> gagal = layanan.underwrite(LEBIH_KUOTA, awal);
        if (gagal instanceof Result.Err<UnderwritingService.Outcome> err) {
            System.out.println("  Ditolak sistem: " + err.message());
        }
        System.out.println("  Kuota di state awal tetap: " + Fmt.rupiah(awal.remainingQuota()));

        System.out.println();
        System.out.println("=== 5) Audit trail lewat interface (padanan type class) ===");
        AuditTrail.log(new LoanDecision.Approved(200_000_000, 6.75));
        AuditTrail.log(new LoanDecision.Rejected("Skor kredit tidak memenuhi syarat"));
        AuditTrail.log(SAMPLE);
        AuditTrail.log(new Note("Terdeteksi pola aplikasi yang suspicious dari IP yang sama"));

        System.out.println();
        System.out.println("  --- List campur, hanya Warning ke atas yang tampil ---");
        AuditTrail.logMixed(List.of(
                new LoanDecision.Approved(200_000_000, 6.75),
                new LoanDecision.Rejected("DTI terlalu tinggi"),
                new Note("Login mencurigakan terdeteksi"),
                SAMPLE));

        System.out.println();
        System.out.println("=== 6) BONUS: toString yang menyamarkan data pribadi ===");
        System.out.println("  " + SAMPLE);
        System.out.println("  (nama pemohon disamarkan di satu tempat, jadi tidak ada pemanggil yang lupa)");

        System.out.println();
        System.out.println("=== Selesai ===");
    }

    static void cetakHasil(Result<LoanDecision> hasil) {
        switch (hasil) {
            case Result.Ok<LoanDecision> ok -> System.out.println("  OK  : " + ok.value());
            case Result.Err<LoanDecision> err -> System.out.println("  ERR : " + err.message());
        }
    }
}
