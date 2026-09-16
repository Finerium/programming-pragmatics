package los;

import java.math.BigDecimal;

/**
 * Satu aturan underwriting. Tiap aturan adalah objek bernama dengan ambangnya
 * sendiri, jadi daftar aturan bisa disusun dari luar dan yang dilanggar bisa
 * dilaporkan lewat namanya.
 */
public interface AturanUnderwriting {

    String nama();

    boolean dipenuhi(Pengajuan pengajuan);

    record SkorMinimum(int minimum) implements AturanUnderwriting {
        @Override
        public String nama() {
            return "skor minimum " + minimum;
        }

        @Override
        public boolean dipenuhi(Pengajuan pengajuan) {
            return pengajuan.skor() >= minimum;
        }
    }

    record DtiMaksimum(BigDecimal maksimum) implements AturanUnderwriting {
        @Override
        public String nama() {
            return "DTI maksimum " + maksimum;
        }

        @Override
        public boolean dipenuhi(Pengajuan pengajuan) {
            return pengajuan.dti().compareTo(maksimum) <= 0;
        }
    }

    record PokokMaksimum(Uang maksimum) implements AturanUnderwriting {
        @Override
        public String nama() {
            return "pokok maksimum " + maksimum;
        }

        @Override
        public boolean dipenuhi(Pengajuan pengajuan) {
            return !pengajuan.pokok().lebihDari(maksimum);
        }
    }
}
