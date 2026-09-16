package los;

import java.util.List;

/** Data pengajuan tidak masuk akal, misalnya pokok negatif. Dilempar waktu objeknya dibuat. */
public final class PengajuanTidakValidException extends KreditException {

    private static final long serialVersionUID = 1L;

    public PengajuanTidakValidException(String nama, List<String> alasan) {
        super("Pengajuan " + nama + " tidak valid", alasan);
    }
}
