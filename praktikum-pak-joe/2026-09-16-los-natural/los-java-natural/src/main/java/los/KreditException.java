package los;

import java.util.List;

/**
 * Induk semua kegagalan di proses kredit. Selalu membawa daftar alasan, bukan
 * cuma alasan pertama, supaya pemohon tahu semua yang harus dibereskan.
 */
public class KreditException extends Exception {

    private static final long serialVersionUID = 1L;

    // javac -Xlint:serial memprotes field bertipe interface di kelas Serializable.
    // Daftarnya sendiri dibuat dengan List.copyOf yang sudah serializable, jadi peringatannya ditekan.
    @SuppressWarnings("serial")
    private final List<String> alasan;

    protected KreditException(String pesan, List<String> alasan) {
        super(pesan + ": " + String.join("; ", alasan));
        this.alasan = List.copyOf(alasan);
    }

    public List<String> alasan() {
        return alasan;
    }
}
