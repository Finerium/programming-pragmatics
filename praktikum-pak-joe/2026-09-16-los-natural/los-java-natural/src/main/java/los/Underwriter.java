package los;

import java.math.BigDecimal;
import java.util.List;

/**
 * Penyaringan awal: mencocokkan pengajuan dengan daftar aturan underwriting
 * dan mengeluarkan keputusan. Daftar aturannya disuntik lewat constructor
 * supaya bisa diganti tanpa mengubah kelas ini.
 */
public final class Underwriter {

    private static final int SKOR_TANPA_DOKUMEN_TAMBAHAN = 650;

    private final List<AturanUnderwriting> aturan;

    public Underwriter(List<AturanUnderwriting> aturan) {
        this.aturan = List.copyOf(aturan);
    }

    /** Aturan baku bank: skor 620, DTI 0.43, pokok Rp2 miliar. */
    public static Underwriter standar() {
        return new Underwriter(List.of(
                new AturanUnderwriting.SkorMinimum(620),
                new AturanUnderwriting.DtiMaksimum(new BigDecimal("0.43")),
                new AturanUnderwriting.PokokMaksimum(Uang.dari(2_000_000_000L))));
    }

    /** Semua aturan yang dilanggar, bukan cuma yang pertama. */
    public List<String> aturanDilanggar(Pengajuan pengajuan) {
        return aturan.stream()
                .filter(a -> !a.dipenuhi(pengajuan))
                .map(AturanUnderwriting::nama)
                .toList();
    }

    public Keputusan putuskan(Pengajuan pengajuan) {
        List<String> dilanggar = aturanDilanggar(pengajuan);
        if (!dilanggar.isEmpty()) {
            return new Keputusan.Ditolak(dilanggar);
        }
        if (pengajuan.skor() < SKOR_TANPA_DOKUMEN_TAMBAHAN) {
            return new Keputusan.PerluDokumen(List.of("Slip gaji 3 bulan terakhir"));
        }
        return new Keputusan.Disetujui(pengajuan.pokok(), pengajuan.kelasRisiko().tambahanBungaAwal());
    }
}
