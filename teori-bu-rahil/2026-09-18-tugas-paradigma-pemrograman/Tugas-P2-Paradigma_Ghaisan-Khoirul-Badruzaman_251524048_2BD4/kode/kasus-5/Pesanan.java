import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.locks.ReentrantLock;
import static java.util.concurrent.CompletableFuture.*;
import static java.util.concurrent.TimeUnit.MILLISECONDS;

public class Pesanan {
    static Map<String, Integer> stok = new ConcurrentHashMap<>(
            Map.of("buku", 1000, "pena", 1000, "laptop", 10));
    static Map<String, ReentrantLock> kunci = new ConcurrentHashMap<>();
    static BlockingQueue<String> antreanNotif = new LinkedBlockingQueue<>();
    static String pesan(int id, List<String> barang) {
        var urut = barang.stream().sorted().map(b -> kunci.computeIfAbsent(
                b, k -> new ReentrantLock())).toList();
        urut.forEach(ReentrantLock::lock); // urut abjad, cegah deadlock
        try { // cek ketersediaan dan kurangi stok harus satu langkah
            if (barang.stream().anyMatch(b -> stok.get(b) < 1))
                return "stok habis";
            barang.forEach(b -> stok.merge(b, -1, Integer::sum));
        } finally { urut.forEach(ReentrantLock::unlock); }
        // simpan transaksi (database) dan bayar (gateway) jalan bersamaan
        var simpan = supplyAsync(() -> "tersimpan",
                delayedExecutor(30, MILLISECONDS));
        var bayar = supplyAsync(() -> "lunas",
                delayedExecutor(id % 300 == 0 ? 900 : 50, MILLISECONDS))
                .orTimeout(300, MILLISECONDS); // batas tunggu gateway
        boolean ok = allOf(simpan, bayar).handle((v, e) -> e == null).join();
        if (!ok) { // gateway terlalu lama: pesanan batal, stok dikembalikan
            barang.forEach(b -> stok.merge(b, 1, Integer::sum)); // atomik
            return "gagal bayar";
        }
        antreanNotif.add("user" + id); // diambil layanan notifikasi terpisah
        return "berhasil";
    }

    public static void main(String[] args) {
        var rekap = new ConcurrentHashMap<String, Integer>();
        var pool = Executors.newVirtualThreadPerTaskExecutor();
        for (int i = 1; i <= 1000; i++) { // 1 permintaan = 1 virtual thread
            int id = i;
            var barang = id > 900 ? List.of("laptop") : id % 2 == 0
                    ? List.of("pena", "buku") : List.of("buku", "pena");
            pool.submit(() -> rekap.merge(pesan(id, barang), 1, Integer::sum));
        }
        pool.close(); // menunggu semua permintaan selesai
        System.out.println(new TreeMap<>(rekap));
        System.out.println("stok akhir: " + new TreeMap<>(stok));
        System.out.println("antrean notifikasi: " + antreanNotif.size());
    }
}
