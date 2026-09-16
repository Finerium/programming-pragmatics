package los;

import java.util.List;

/** Pencatatan audit yang bekerja untuk semua tipe yang mengimplementasikan Auditable. */
public final class AuditTrail {
    private AuditTrail() {
    }

    public static void log(Auditable item) {
        System.out.println("[" + item.severity().label() + "] " + item.auditEntry());
    }

    public static void logBatch(List<? extends Auditable> daftar) {
        daftar.forEach(AuditTrail::log);
    }

    /**
     * Di Haskell list campur butuh existential type (AnyAuditable).
     * Di Java cukup List Auditable, karena polimorfisme subtipe sudah menyatukan tipenya.
     */
    public static void logMixed(List<Auditable> daftar) {
        daftar.stream()
                .filter(item -> item.severity().compareTo(AuditSeverity.WARNING) >= 0)
                .forEach(AuditTrail::log);
    }
}
