package los;

import java.util.ArrayList;
import java.util.List;

/**
 * Kondisi bank yang berubah tiap pinjaman disetujui.
 * Record ini immutable: setiap perubahan mengembalikan objek baru, objek lama tetap utuh.
 * Itulah yang membuat kegagalan di tengah proses tidak meninggalkan state setengah jadi.
 */
public record BankState(double remainingQuota, List<String> auditLog) {
    public BankState {
        auditLog = List.copyOf(auditLog);
    }

    public static BankState awal(double kuota) {
        return new BankState(kuota, List.of());
    }

    public BankState reserve(double jumlah) {
        return new BankState(remainingQuota - jumlah, auditLog);
    }

    public BankState log(String pesan) {
        List<String> baru = new ArrayList<>(auditLog);
        baru.add(pesan);
        return new BankState(remainingQuota, baru);
    }
}
