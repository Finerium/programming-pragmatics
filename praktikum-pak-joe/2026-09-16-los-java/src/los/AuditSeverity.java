package los;

/** Tingkat kepentingan catatan audit. Enum di Java adalah padanan enumerasi ADT sederhana. */
public enum AuditSeverity {
    INFO("Info"), WARNING("Warning"), CRITICAL("Critical");

    private final String label;

    AuditSeverity(String label) {
        this.label = label;
    }

    public String label() {
        return label;
    }
}
