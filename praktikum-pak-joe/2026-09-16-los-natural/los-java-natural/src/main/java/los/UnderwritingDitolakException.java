package los;

import java.util.List;

/** Bank tidak bisa mengunderwrite pengajuan ini, misalnya kuota harian tidak cukup. */
public final class UnderwritingDitolakException extends KreditException {

    private static final long serialVersionUID = 1L;

    public UnderwritingDitolakException(String nama, List<String> alasan) {
        super("Underwriting " + nama + " ditolak", alasan);
    }
}
