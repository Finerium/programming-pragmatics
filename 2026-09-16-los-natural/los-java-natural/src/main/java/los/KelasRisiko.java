package los;

import java.math.BigDecimal;

/**
 * Kelas risiko pemohon menurut skor kredit. Dua tabel bunga di aturan bisnis
 * (tambahan bunga waktu keputusan awal dan premi waktu underwriting) memakai
 * batas skor yang sama, jadi keduanya jadi atribut kelas ini. Pemanggil tinggal
 * tanya kelasnya, tidak perlu mengulang if skor < 600 di banyak tempat.
 */
public enum KelasRisiko {
    TINGGI("3.5", "3.5"),
    MENENGAH("1.5", "1.5"),
    RENDAH("0.0", "0.5");

    private final BigDecimal tambahanBungaAwal;
    private final BigDecimal premiUnderwriting;

    KelasRisiko(String tambahanBungaAwal, String premiUnderwriting) {
        this.tambahanBungaAwal = new BigDecimal(tambahanBungaAwal);
        this.premiUnderwriting = new BigDecimal(premiUnderwriting);
    }

    public static KelasRisiko dariSkor(int skor) {
        if (skor < 600) {
            return TINGGI;
        }
        if (skor < 700) {
            return MENENGAH;
        }
        return RENDAH;
    }

    public BigDecimal tambahanBungaAwal() {
        return tambahanBungaAwal;
    }

    public BigDecimal premiUnderwriting() {
        return premiUnderwriting;
    }
}
