package los;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.Test;

class PengajuanTest {

    @Test
    void dtiBudiSeperempat() throws KreditException {
        Pengajuan budi = Contoh.budi();
        assertEquals(0, budi.dti().compareTo(new BigDecimal("0.25")));
    }

    @Test
    void dtiSedikitDiAtasBatasTetapDihitungMelanggar() throws KreditException {
        Pengajuan lewatTipis = Pengajuan.pemohon("Tipis").pokok(100_000_000).tenor(24).skor(700)
                .cicilanLain(4_300_400).pendapatan(10_000_000).ajukan();
        assertEquals(1, Underwriter.standar().aturanDilanggar(lewatTipis).size());
    }

    @Test
    void pinjamanTenorNolDitolak() {
        assertThrows(IllegalArgumentException.class,
                () -> new Pinjaman(Uang.dari(100_000_000), 0, new BigDecimal("8")));
    }

    @Test
    void dtiNolKalauPendapatanNol() throws KreditException {
        Pengajuan tanpaPendapatan = Pengajuan.pemohon("X").pokok(1).tenor(1).skor(700)
                .cicilanLain(5).pendapatan(0).ajukan();
        assertEquals(0, tanpaPendapatan.dti().signum());
    }

    @Test
    void semuaCacatTerkumpulDalamSatuException() {
        PengajuanTidakValidException e = assertThrows(PengajuanTidakValidException.class,
                () -> Pengajuan.pemohon("Coba").pokok(0).tenor(0).skor(250).ajukan());
        assertEquals(3, e.alasan().size());
    }

    @Test
    void pokokNegatifSajaSudahDitolak() {
        PengajuanTidakValidException e = assertThrows(PengajuanTidakValidException.class,
                () -> Pengajuan.pemohon("Coba").pokok(-1).tenor(24).skor(700).ajukan());
        assertEquals(List.of("pokok harus positif, diberikan Rp-1"), e.alasan());
    }

    @Test
    void kelasRisikoMengikutiBatasSkor() {
        assertEquals(KelasRisiko.TINGGI, KelasRisiko.dariSkor(599));
        assertEquals(KelasRisiko.MENENGAH, KelasRisiko.dariSkor(600));
        assertEquals(KelasRisiko.MENENGAH, KelasRisiko.dariSkor(699));
        assertEquals(KelasRisiko.RENDAH, KelasRisiko.dariSkor(700));
    }

    @Test
    void cicilanDuaRatusJutaBungaDelapanPersenDuaPuluhEmpatBulan() {
        Pinjaman pinjaman = new Pinjaman(Uang.dari(200_000_000), 24, new BigDecimal("8"));
        assertEquals(Uang.dari(9_045_458), pinjaman.cicilanBulanan());
    }

    @Test
    void cicilanTanpaBungaDibagiRata() {
        Pinjaman pinjaman = new Pinjaman(Uang.dari(120), 12, BigDecimal.ZERO);
        assertEquals(Uang.dari(10), pinjaman.cicilanBulanan());
    }

    @Test
    void uangDibulatkanKeRupiahBulat() {
        assertEquals(Uang.dari(3), new Uang(new BigDecimal("2.5")));
        assertEquals(Uang.dari(2), new Uang(new BigDecimal("2.4999")));
        assertEquals("Rp1,000,000,000", Uang.dari(1_000_000_000).toString());
    }
}
