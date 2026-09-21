package los;

/** Perhitungan murni: masukan sama selalu memberi hasil sama, tidak menyentuh apa pun di luar. */
public final class Calculations {
    private Calculations() {
    }

    public static double calculateDti(double utang, double pendapatan) {
        return pendapatan <= 0 ? 0 : utang / pendapatan;
    }

    public static double calculateMonthlyPayment(double pokok, double bungaTahunanPersen, int bulan) {
        if (bulan <= 0) {
            return 0;
        }
        double r = bungaTahunanPersen / 12 / 100;
        if (r == 0) {
            return pokok / bulan;
        }
        double n = bulan;
        return pokok * r * Math.pow(1 + r, n) / (Math.pow(1 + r, n) - 1);
    }
}
