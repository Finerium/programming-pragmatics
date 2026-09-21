package los;

/**
 * Pembungkus catatan bebas.
 * Di Haskell ada instance Auditable untuk String, di Java tipe bawaan seperti String tidak bisa
 * ditambahi interface, jadi dibungkus dulu jadi tipe sendiri.
 */
public record Note(String teks) implements Auditable {
    @Override
    public String auditEntry() {
        return "NOTE | " + teks;
    }

    /**
      * Beda kecil yang disengaja dari versi Haskell: di sana isInfixOf peka huruf besar kecil,
      * di sini dicocokkan setelah di-lowercase supaya "FRAUD" juga ikut tertangkap.
      */
    @Override
    public AuditSeverity severity() {
        String kecil = teks.toLowerCase();
        return kecil.contains("fraud") || kecil.contains("suspicious") ? AuditSeverity.CRITICAL : AuditSeverity.INFO;
    }
}
