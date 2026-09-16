package los;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;

import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.Test;

class UnderwriterTest {

    private final Underwriter underwriter = Underwriter.standar();

    @Test
    void budiDisetujuiDenganTambahanSatuSetengah() throws KreditException {
        Keputusan.Disetujui k = assertInstanceOf(Keputusan.Disetujui.class,
                underwriter.putuskan(Contoh.budi()));
        assertEquals(Uang.dari(200_000_000), k.pokok());
        assertEquals(new BigDecimal("1.5"), k.tambahanBungaRisiko());
    }

    @Test
    void sitiDitolakKarenaSkor() throws KreditException {
        Keputusan.Ditolak k = assertInstanceOf(Keputusan.Ditolak.class,
                underwriter.putuskan(Contoh.siti()));
        assertEquals(List.of("skor minimum 620"), k.aturanDilanggar());
    }

    @Test
    void andiDitolakKarenaPokok() throws KreditException {
        assertEquals(List.of("pokok maksimum Rp2,000,000,000"),
                underwriter.aturanDilanggar(Contoh.andi()));
    }

    @Test
    void skor640LolosAturanTapiPerluDokumen() throws KreditException {
        Pengajuan p = Contoh.budiDenganSkor(640);
        assertEquals(List.of(), underwriter.aturanDilanggar(p));
        assertInstanceOf(Keputusan.PerluDokumen.class, underwriter.putuskan(p));
    }

    @Test
    void skor720TidakKenaTambahanBunga() throws KreditException {
        Keputusan.Disetujui k = assertInstanceOf(Keputusan.Disetujui.class,
                underwriter.putuskan(Contoh.budiDenganSkor(720)));
        assertEquals(0, k.tambahanBungaRisiko().signum());
    }

    @Test
    void dtiDiAtasBatasDilanggar() throws KreditException {
        Pengajuan boros = Pengajuan.pemohon("Budi").pokok(200_000_000).tenor(24).skor(680)
                .cicilanLain(6_000_000).pendapatan(12_000_000).ajukan();
        assertEquals(List.of("DTI maksimum 0.43"), underwriter.aturanDilanggar(boros));
    }

    @Test
    void duaPelanggaranSekaligusTerkumpul() throws KreditException {
        Pengajuan p = Pengajuan.pemohon("Andi").pokok(3_000_000_000L).tenor(24).skor(500)
                .cicilanLain(3_000_000).pendapatan(12_000_000).ajukan();
        assertEquals(List.of("skor minimum 620", "pokok maksimum Rp2,000,000,000"),
                underwriter.aturanDilanggar(p));
    }

    @Test
    void pesanDitolakMenyebutSemuaAturan() {
        Keputusan k = new Keputusan.Ditolak(List.of("a", "b"));
        assertEquals("Maaf, pengajuan ditolak. Aturan yang dilanggar: a, b", k.pesan());
    }

    @Test
    void daftarAturanBisaDigantiDariLuar() throws KreditException {
        Underwriter ketat = new Underwriter(List.of(new AturanUnderwriting.SkorMinimum(700)));
        assertEquals(List.of("skor minimum 700"), ketat.aturanDilanggar(Contoh.budi()));
    }
}
