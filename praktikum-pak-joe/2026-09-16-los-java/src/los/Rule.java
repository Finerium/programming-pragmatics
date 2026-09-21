package los;

import java.util.function.Predicate;

/**
 * Aturan underwriting sebagai nilai, bukan cuma kode di dalam if.
 * Interface fungsional bisa diisi lambda, jadi aturan boleh disimpan di list dan dioper antar method.
 */
@FunctionalInterface
public interface Rule extends Predicate<LoanApplication> {
}
