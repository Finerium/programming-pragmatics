package los;

import java.math.BigDecimal;
import java.util.List;

/**
 * Keputusan awal atas sebuah pengajuan. Tiap jenis keputusan tahu sendiri
 * kalimat apa yang dikirim ke pemohon, jadi pemanggil tidak perlu
 * memeriksa jenisnya satu per satu.
 */
public interface Keputusan {

    String pesan();

    record Disetujui(Uang pokok, BigDecimal tambahanBungaRisiko) implements Keputusan {
        @Override
        public String pesan() {
            return "Selamat, pinjaman " + pokok + " disetujui dengan tambahan bunga risiko "
                    + tambahanBungaRisiko + "%";
        }
    }

    record Ditolak(List<String> aturanDilanggar) implements Keputusan {
        public Ditolak {
            aturanDilanggar = List.copyOf(aturanDilanggar);
        }

        @Override
        public String pesan() {
            return "Maaf, pengajuan ditolak. Aturan yang dilanggar: "
                    + String.join(", ", aturanDilanggar);
        }
    }

    record PerluDokumen(List<String> dokumen) implements Keputusan {
        public PerluDokumen {
            dokumen = List.copyOf(dokumen);
        }

        @Override
        public String pesan() {
            return "Perlu dokumen tambahan: " + String.join(", ", dokumen);
        }
    }
}
