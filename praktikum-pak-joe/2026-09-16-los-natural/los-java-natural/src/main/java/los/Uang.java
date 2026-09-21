package los;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Locale;

/**
 * Nilai uang dalam rupiah. Dibungkus sendiri supaya pembulatannya cuma diatur
 * di satu tempat: selalu ke rupiah bulat, setengah ke atas. Selain itu
 * perbandingan dan penjumlahan jadi terbaca sebagai bahasa domain, bukan
 * rangkaian compareTo.
 */
public record Uang(BigDecimal rupiah) {

    public static final Uang NOL = Uang.dari(0);

    public Uang {
        rupiah = rupiah.setScale(0, RoundingMode.HALF_UP);
    }

    public static Uang dari(long rupiah) {
        return new Uang(BigDecimal.valueOf(rupiah));
    }

    public Uang tambah(Uang lain) {
        return new Uang(rupiah.add(lain.rupiah));
    }

    public Uang kurang(Uang lain) {
        return new Uang(rupiah.subtract(lain.rupiah));
    }

    public Uang kali(BigDecimal faktor) {
        return new Uang(rupiah.multiply(faktor));
    }

    /**
      * Rasio terhadap uang lain. Sengaja disimpan sampai sepuluh angka di belakang koma supaya
      * perbandingan dengan batas aturan tidak meleset gara-gara pembulatan. Pembulatan untuk
      * ditampilkan dikerjakan di tempat mencetaknya.
      */
    public BigDecimal rasioTerhadap(Uang pembagi) {
        if (!pembagi.positif()) {
            return BigDecimal.ZERO.setScale(10, RoundingMode.HALF_UP);
        }
        return rupiah.divide(pembagi.rupiah, 10, RoundingMode.HALF_UP);
    }

    public boolean positif() {
        return rupiah.signum() > 0;
    }

    public boolean lebihDari(Uang lain) {
        return rupiah.compareTo(lain.rupiah) > 0;
    }

    @Override
    public String toString() {
        return String.format(Locale.US, "Rp%,d", rupiah.toBigInteger());
    }
}
