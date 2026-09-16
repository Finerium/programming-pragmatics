package los;

import java.math.BigDecimal;
import java.util.List;

/** Demo ujung ke ujung. Jalankan: java -cp kelas los.Demo */
public final class Demo {

    private Demo() {
    }

    public static void main(String[] args) throws KreditException {
        Pengajuan budi = Pengajuan.pemohon("Budi")
                .pokok(200_000_000).tenor(24).skor(680)
                .cicilanLain(3_000_000).pendapatan(12_000_000)
                .ajukan();
        Pengajuan siti = Pengajuan.pemohon("Siti")
                .pokok(50_000_000).tenor(24).skor(590)
                .cicilanLain(3_000_000).pendapatan(12_000_000)
                .ajukan();
        Pengajuan andi = Pengajuan.pemohon("Andi")
                .pokok(3_000_000_000L).tenor(24).skor(680)
                .cicilanLain(3_000_000).pendapatan(12_000_000)
                .ajukan();
        List<Pengajuan> semua = List.of(budi, siti, andi);

        judul("1) Perhitungan dasar");
        System.out.println("  DTI Budi: " + budi.dti().setScale(4, java.math.RoundingMode.HALF_UP));
        Pinjaman contoh = new Pinjaman(Uang.dari(200_000_000), 24, new BigDecimal("8"));
        System.out.println("  Cicilan Rp200 juta, bunga 8%, tenor 24 bulan: " + contoh.cicilanBulanan());

        judul("2) Penyaringan awal oleh Underwriter");
        Underwriter underwriter = Underwriter.standar();
        for (Pengajuan p : semua) {
            System.out.println("  " + p);
            System.out.println("    dilanggar : " + underwriter.aturanDilanggar(p));
            System.out.println("    keputusan : " + underwriter.putuskan(p).pesan());
        }

        judul("3) Validasi dasar: objek Pengajuan menolak dibuat kalau datanya cacat");
        try {
            Pengajuan.pemohon("Coba").pokok(-1).tenor(0).skor(250).ajukan();
            System.out.println("  (tidak seharusnya sampai sini)");
        } catch (PengajuanTidakValidException e) {
            System.out.println("  " + e.getMessage());
            for (String alasan : e.alasan()) {
                System.out.println("    - " + alasan);
            }
        }

        judul("4) Underwriting oleh Bank dengan kuota harian");
        Bank bank = new Bank(new BigDecimal("6.25"), Kebijakan.STANDAR,
                Uang.dari(500_000_000), 620, Uang.dari(1_000_000_000));
        System.out.println("  Kuota awal hari ini: " + bank.kuotaTersisa());
        for (Pengajuan p : List.of(budi, andi)) {
            try {
                Pinjaman pinjaman = bank.underwrite(p);
                System.out.println("  " + p.nama() + ": disetujui, " + pinjaman);
                System.out.println("    cicilan bulanan " + pinjaman.cicilanBulanan());
            } catch (UnderwritingDitolakException e) {
                System.out.println("  " + p.nama() + ": " + e.getMessage());
            }
        }
        System.out.println("  Sisa kuota: " + bank.kuotaTersisa());
        System.out.println("  Jurnal:");
        for (String baris : bank.jurnal()) {
            System.out.println("    - " + baris);
        }
    }

    private static void judul(String teks) {
        System.out.println();
        System.out.println("=== " + teks + " ===");
    }
}
