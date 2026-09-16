package los;

/** Tiga pemohon contoh yang sama dengan demo, dipakai bersama oleh kelas tes. */
final class Contoh {

    private Contoh() {
    }

    static Pengajuan budi() throws KreditException {
        return budiDenganSkor(680);
    }

    static Pengajuan budiDenganSkor(int skor) throws KreditException {
        return Pengajuan.pemohon("Budi").pokok(200_000_000).tenor(24).skor(skor)
                .cicilanLain(3_000_000).pendapatan(12_000_000).ajukan();
    }

    static Pengajuan siti() throws KreditException {
        return Pengajuan.pemohon("Siti").pokok(50_000_000).tenor(24).skor(590)
                .cicilanLain(3_000_000).pendapatan(12_000_000).ajukan();
    }

    static Pengajuan andi() throws KreditException {
        return Pengajuan.pemohon("Andi").pokok(3_000_000_000L).tenor(24).skor(680)
                .cicilanLain(3_000_000).pendapatan(12_000_000).ajukan();
    }
}
