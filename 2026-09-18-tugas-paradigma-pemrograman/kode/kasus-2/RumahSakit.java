import java.util.*;

enum Hak { DATA_PASIEN, JADWAL, REKAM_MEDIS, PEMBAYARAN }
enum Peran { // RBAC: daftar hak melekat ke peran, bukan ke orangnya
    PENDAFTARAN(Hak.DATA_PASIEN, Hak.JADWAL), DOKTER(Hak.REKAM_MEDIS),
    ADMINISTRASI(Hak.PEMBAYARAN);
    final Set<Hak> hak;
    Peran(Hak... h) { hak = Set.of(h); }
}
class Pengguna {
    final String nama; final Peran peran;
    Pengguna(String n, Peran p) { nama = n; peran = p; }
    boolean boleh(Hak h, Pasien p) { return peran.hak.contains(h); }
}
class Dokter extends Pengguna {
    final String spesialisasi;
    private final Set<Pasien> ditangani = new HashSet<>();
    Dokter(String n, String sp) { super(n, Peran.DOKTER); spesialisasi = sp; }
    void tangani(Pasien p) { ditangani.add(p); }
    @Override boolean boleh(Hak h, Pasien p) { // syarat tambahan untuk dokter
        return super.boleh(h, p) && ditangani.contains(p);
    }
}
record Kunjungan(String dokter, String diagnosis, String tindakan,
        String resep) {}
class Pasien {
    final String nama;
    private final List<Kunjungan> riwayat = new ArrayList<>();
    Pasien(String nama) { this.nama = nama; }
    void catat(Pengguna u, String diagnosis, String tindakan, String resep) {
        if (!u.boleh(Hak.REKAM_MEDIS, this)) throw new SecurityException(
                u.nama + " (" + u.peran + ") ditolak mengubah RM " + nama);
        riwayat.add(new Kunjungan(u.nama, diagnosis, tindakan, resep));
    }
    List<Kunjungan> riwayat() { return List.copyOf(riwayat); } // read-only
}

public class RumahSakit {
    public static void main(String[] args) {
        Pasien budi = new Pasien("Budi");
        Dokter sari = new Dokter("dr. Sari", "Penyakit Dalam");
        sari.tangani(budi); // hasil jadwal yang dibuat petugas pendaftaran
        for (Pengguna u : List.of(sari, new Dokter("dr. Andi", "Anak"),
                new Pengguna("Rina", Peran.PENDAFTARAN))) {
            try { budi.catat(u, "Hipertensi", "EKG", "Amlodipin 5 mg"); }
            catch (SecurityException e) { System.out.println(e.getMessage()); }
        }
        for (Kunjungan k : budi.riwayat())
            System.out.println("RM Budi: " + k.dokter() + ", " + k.diagnosis()
                    + ", " + k.tindakan() + ", " + k.resep());
    }
}
