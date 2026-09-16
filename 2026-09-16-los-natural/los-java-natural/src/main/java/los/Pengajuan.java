package los;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Pengajuan kredit dari satu pemohon.
 *
 * Objek ini tidak pernah ada dalam keadaan tidak valid: constructor-nya
 * memeriksa pokok, tenor, dan skor, lalu melempar PengajuanTidakValidException
 * yang memuat semua cacatnya sekaligus. Jadi kelas lain (Underwriter, Bank)
 * tidak perlu mengecek ulang hal yang sama.
 */
public final class Pengajuan {

    private final String nama;
    private final Uang pokok;
    private final int tenor;
    private final int skor;
    private final Uang cicilanLain;
    private final Uang pendapatan;

    private Pengajuan(Builder b) throws PengajuanTidakValidException {
        List<String> cacat = new ArrayList<>();
        if (!b.pokok.positif()) {
            cacat.add("pokok harus positif, diberikan " + b.pokok);
        }
        if (b.tenor <= 0) {
            cacat.add("tenor harus positif, diberikan " + b.tenor);
        }
        if (b.skor < 300) {
            cacat.add("skor kredit tidak valid, diberikan " + b.skor);
        }
        if (!cacat.isEmpty()) {
            throw new PengajuanTidakValidException(b.nama, cacat);
        }
        this.nama = b.nama;
        this.pokok = b.pokok;
        this.tenor = b.tenor;
        this.skor = b.skor;
        this.cicilanLain = b.cicilanLain;
        this.pendapatan = b.pendapatan;
    }

    public static Builder pemohon(String nama) {
        return new Builder(nama);
    }

    public String nama() {
        return nama;
    }

    public Uang pokok() {
        return pokok;
    }

    public int tenor() {
        return tenor;
    }

    public int skor() {
        return skor;
    }

    /** Rasio cicilan lain terhadap pendapatan bulanan. */
    public BigDecimal dti() {
        return cicilanLain.rasioTerhadap(pendapatan);
    }

    public KelasRisiko kelasRisiko() {
        return KelasRisiko.dariSkor(skor);
    }

    @Override
    public String toString() {
        return nama + " (pokok " + pokok + ", tenor " + tenor + " bulan, skor " + skor + ")";
    }

    /** Enam parameter terlalu banyak untuk satu constructor, jadi dibangun bertahap. */
    public static final class Builder {

        private final String nama;
        private Uang pokok = Uang.NOL;
        private int tenor;
        private int skor;
        private Uang cicilanLain = Uang.NOL;
        private Uang pendapatan = Uang.NOL;

        private Builder(String nama) {
            this.nama = nama;
        }

        public Builder pokok(long rupiah) {
            this.pokok = Uang.dari(rupiah);
            return this;
        }

        public Builder tenor(int bulan) {
            this.tenor = bulan;
            return this;
        }

        public Builder skor(int skor) {
            this.skor = skor;
            return this;
        }

        public Builder cicilanLain(long rupiah) {
            this.cicilanLain = Uang.dari(rupiah);
            return this;
        }

        public Builder pendapatan(long rupiah) {
            this.pendapatan = Uang.dari(rupiah);
            return this;
        }

        public Pengajuan ajukan() throws PengajuanTidakValidException {
            return new Pengajuan(this);
        }
    }
}
