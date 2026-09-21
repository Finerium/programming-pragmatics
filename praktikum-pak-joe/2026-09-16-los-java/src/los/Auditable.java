package los;

/**
 * Padanan type class Auditable di Haskell.
 * Method biasa = method wajib, default method = implementasi bawaan yang boleh ditimpa.
 */
public interface Auditable {
    String auditEntry();

    default AuditSeverity severity() {
        return AuditSeverity.INFO;
    }
}
