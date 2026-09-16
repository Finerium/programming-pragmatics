package los;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Bank yang mengunderwrite pengajuan. Memegang konfigurasi yang tetap
 * (bunga dasar, kebijakan, plafon, skor minimum) dan keadaan hari ini
 * (sisa kuota dan jurnal). Kuota hanya berkurang di dalam underwrite(),
 * dan cuma setelah semua pemeriksaan lolos, jadi tidak pernah ada keadaan
 * setengah jadi: pengajuan yang ditolak tidak meninggalkan jejak apa pun.
 */
public final class Bank {

    private final BigDecimal bungaDasar;
    private final Kebijakan kebijakan;
    private final Uang plafonPerPinjaman;
    private final int skorMinimum;

    private Uang kuotaTersisa;
    private final List<String> jurnal = new ArrayList<>();

    public Bank(BigDecimal bungaDasar, Kebijakan kebijakan, Uang plafonPerPinjaman,
                int skorMinimum, Uang kuotaHarian) {
        this.bungaDasar = bungaDasar;
        this.kebijakan = kebijakan;
        this.plafonPerPinjaman = plafonPerPinjaman;
        this.skorMinimum = skorMinimum;
        this.kuotaTersisa = kuotaHarian;
    }

    public Uang kuotaTersisa() {
        return kuotaTersisa;
    }

    public List<String> jurnal() {
        return Collections.unmodifiableList(jurnal);
    }

    /**
     * Memeriksa pengajuan terhadap ketentuan bank, mencadangkan kuota, dan
     * mengembalikan pinjaman dengan bunga akhirnya. Kalau ada yang menghalangi,
     * semua hambatannya dikumpulkan dulu baru dilempar sebagai satu exception.
     */
    public Pinjaman underwrite(Pengajuan pengajuan) throws UnderwritingDitolakException {
        List<String> hambatan = hambatan(pengajuan);
        if (!hambatan.isEmpty()) {
            throw new UnderwritingDitolakException(pengajuan.nama(), hambatan);
        }
        BigDecimal bunga = bungaAkhir(pengajuan);

        jurnal.add("Validasi dasar lolos untuk " + pengajuan.nama());
        kuotaTersisa = kuotaTersisa.kurang(pengajuan.pokok());
        jurnal.add("Kuota dicadangkan: " + pengajuan.pokok());
        jurnal.add("Disetujui dengan bunga " + bunga + "%");
        return new Pinjaman(pengajuan.pokok(), pengajuan.tenor(), bunga);
    }

    private List<String> hambatan(Pengajuan pengajuan) {
        List<String> hambatan = new ArrayList<>();
        if (pengajuan.skor() < skorMinimum) {
            hambatan.add("skor " + pengajuan.skor() + " di bawah minimum bank " + skorMinimum);
        }
        if (pengajuan.pokok().lebihDari(plafonPerPinjaman)) {
            hambatan.add("pokok " + pengajuan.pokok() + " melebihi plafon per pinjaman " + plafonPerPinjaman);
        }
        if (pengajuan.pokok().lebihDari(kuotaTersisa)) {
            hambatan.add("kuota harian tersisa " + kuotaTersisa + " tidak cukup untuk " + pengajuan.pokok());
        }
        return hambatan;
    }

    /** Bunga dasar + premi kelas risiko + penyesuaian kebijakan, dua angka di belakang koma. */
    private BigDecimal bungaAkhir(Pengajuan pengajuan) {
        return bungaDasar
                .add(pengajuan.kelasRisiko().premiUnderwriting())
                .add(kebijakan.penyesuaian())
                .setScale(2, RoundingMode.HALF_UP);
    }
}
