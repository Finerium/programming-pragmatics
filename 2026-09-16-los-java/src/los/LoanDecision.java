package los;

import java.util.List;

/**
 * Keputusan kredit sebagai sealed interface: hanya tiga bentuk ini yang mungkin.
 * Padanan Algebraic Data Type di Haskell, dan karena sealed, switch-nya dijamin lengkap oleh compiler.
 */
public sealed interface LoanDecision extends Auditable
        permits LoanDecision.Approved, LoanDecision.Rejected, LoanDecision.PendingReview {

    record Approved(double amount, double rate) implements LoanDecision {
        @Override
        public String auditEntry() {
            return "APPROVED | amount=" + Fmt.rupiah(amount) + " | rate=" + Fmt.persen(rate);
        }

        @Override
        public String toString() {
            return "Approved[amount=" + Fmt.rupiah(amount) + ", rate=" + Fmt.persen(rate) + "]";
        }
    }

    record Rejected(String reason) implements LoanDecision {
        @Override
        public String auditEntry() {
            return "REJECTED | reason=" + reason;
        }

        @Override
        public AuditSeverity severity() {
            return AuditSeverity.WARNING;
        }
    }

    record PendingReview(List<String> missingDocs) implements LoanDecision {
        @Override
        public String auditEntry() {
            return "PENDING | missing=" + missingDocs;
        }

        @Override
        public AuditSeverity severity() {
            return AuditSeverity.WARNING;
        }
    }
}
