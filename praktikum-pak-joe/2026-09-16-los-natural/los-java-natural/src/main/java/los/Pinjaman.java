package los;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;

/** Pinjaman yang sudah disetujui: pokok, tenor, dan bunga tahunan dalam persen. */
public record Pinjaman(Uang pokok, int tenor, BigDecimal bungaTahunanPersen) {

    public Pinjaman {
        if (!pokok.positif()) {
            throw new IllegalArgumentException("pokok pinjaman harus positif");
        }
        if (tenor <= 0) {
            throw new IllegalArgumentException("tenor harus positif");
        }
        if (bungaTahunanPersen.signum() < 0) {
            throw new IllegalArgumentException("bunga tidak boleh negatif");
        }
    }

    private static final MathContext PRESISI = MathContext.DECIMAL64;

    /** Cicilan bulanan dengan rumus anuitas, dibulatkan ke rupiah lewat Uang. */
    public Uang cicilanBulanan() {
        if (bungaTahunanPersen.signum() == 0) {
            return pokok.kali(BigDecimal.ONE.divide(BigDecimal.valueOf(tenor), PRESISI));
        }
        BigDecimal r = bungaTahunanPersen.divide(BigDecimal.valueOf(1200), PRESISI);
        BigDecimal tumbuh = BigDecimal.ONE.add(r).pow(tenor, PRESISI);
        BigDecimal faktor = r.multiply(tumbuh, PRESISI)
                .divide(tumbuh.subtract(BigDecimal.ONE), PRESISI);
        return pokok.kali(faktor);
    }

    @Override
    public String toString() {
        return pokok + " selama " + tenor + " bulan dengan bunga "
                + bungaTahunanPersen.setScale(2, RoundingMode.HALF_UP) + "%";
    }
}
