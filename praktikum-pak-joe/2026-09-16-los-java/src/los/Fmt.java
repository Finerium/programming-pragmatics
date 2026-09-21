package los;

import java.util.Locale;

/** Pembantu format angka supaya keluaran gampang dibaca. */
public final class Fmt {
    private Fmt() {
    }

    public static String rupiah(double nilai) {
        return String.format(Locale.US, "Rp%,.0f", nilai);
    }

    public static String persen(double nilai) {
        return String.format(Locale.US, "%.2f%%", nilai);
    }
}
