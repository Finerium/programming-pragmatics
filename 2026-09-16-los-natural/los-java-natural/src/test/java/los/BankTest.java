package los;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.math.BigDecimal;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class BankTest {

    private Bank bank;

    @BeforeEach
    void bukaHari() {
        bank = bankDengan(Kebijakan.STANDAR);
    }

    private static Bank bankDengan(Kebijakan kebijakan) {
        return new Bank(new BigDecimal("6.25"), kebijakan, Uang.dari(500_000_000), 620,
                Uang.dari(1_000_000_000));
    }

    @Test
    void budiDapatBungaAkhir775() throws KreditException {
        Pinjaman p = bank.underwrite(Contoh.budi());
        assertEquals(new BigDecimal("7.75"), p.bungaTahunanPersen());
        assertEquals(Uang.dari(200_000_000), p.pokok());
    }

    @Test
    void kuotaBerkurangSetelahBudi() throws KreditException {
        bank.underwrite(Contoh.budi());
        assertEquals(Uang.dari(800_000_000), bank.kuotaTersisa());
        assertEquals(3, bank.jurnal().size());
    }

    @Test
    void andiDitolakDenganDuaHambatanDanStateUtuh() throws KreditException {
        UnderwritingDitolakException e = assertThrows(UnderwritingDitolakException.class,
                () -> bank.underwrite(Contoh.andi()));
        assertEquals(2, e.alasan().size());
        assertTrue(e.alasan().get(0).contains("plafon per pinjaman"));
        assertTrue(e.alasan().get(1).contains("kuota harian"));
        assertEquals(Uang.dari(1_000_000_000), bank.kuotaTersisa());
        assertTrue(bank.jurnal().isEmpty());
    }

    @Test
    void sitiTerhambatSkorMinimumBank() throws KreditException {
        UnderwritingDitolakException e = assertThrows(UnderwritingDitolakException.class,
                () -> bank.underwrite(Contoh.siti()));
        assertEquals(1, e.alasan().size());
        assertTrue(e.alasan().get(0).contains("di bawah minimum bank 620"));
    }

    @Test
    void kebijakanKonservatifMenaikkanSetengah() throws KreditException {
        assertEquals(new BigDecimal("8.25"),
                bankDengan(Kebijakan.KONSERVATIF).underwrite(Contoh.budi()).bungaTahunanPersen());
    }

    @Test
    void kebijakanAgresifMenurunkanSetengah() throws KreditException {
        assertEquals(new BigDecimal("7.25"),
                bankDengan(Kebijakan.AGRESIF).underwrite(Contoh.budi()).bungaTahunanPersen());
    }

    @Test
    void kuotaHabisSetelahLimaPengajuan() throws KreditException {
        for (int i = 0; i < 5; i++) {
            bank.underwrite(Contoh.budi());
        }
        assertEquals(Uang.NOL, bank.kuotaTersisa());
        assertThrows(UnderwritingDitolakException.class, () -> bank.underwrite(Contoh.budi()));
    }

    @Test
    void jurnalTidakBisaDiubahDariLuar() {
        assertThrows(UnsupportedOperationException.class, () -> bank.jurnal().add("iseng"));
    }
}
