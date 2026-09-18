import java.time.LocalDate;
import java.util.*;
record Produk(String kode, String nama, String kategori, long harga) {}
record Item(Produk produk, int jumlah) {
    Item { if (jumlah < 1) throw new Ditolak("jumlah minimal 1"); }
    long subtotal() { return produk.harga() * jumlah; }
}
record Tagihan(long belanja, long diskon, long ppn, long ongkir, long total) {}
class Ditolak extends RuntimeException { Ditolak(String m) { super(m); } }
interface Diskon { long potongan(long belanja, LocalDate tgl); }
record Promo(String kode, long nilai, LocalDate akhir) implements Diskon {
    public long potongan(long belanja, LocalDate tgl) {
        if (tgl.isAfter(akhir)) throw new Ditolak(kode + " kedaluwarsa");
        return nilai;
    }
}
public class Toko {
    private final Map<String, Integer> stok = new HashMap<>();
    // fungsi murni: hasilnya hanya bergantung pada input
    static Tagihan hitung(List<Item> isi, List<Diskon> aturan, LocalDate tgl) {
        long belanja = isi.stream().mapToLong(Item::subtotal).sum();
        long diskon = Math.min(belanja,
                aturan.stream().mapToLong(d -> d.potongan(belanja, tgl)).sum());
        long neto = belanja - diskon, ppn = neto * 11 / 100, ongkir = 20_000;
        return new Tagihan(belanja, diskon, ppn, ongkir, neto + ppn + ongkir);
    }
    synchronized void checkout(List<Item> isi, List<Diskon> aturan) {
        try {
            Tagihan t = hitung(isi, aturan, LocalDate.now());
            for (Item it : isi)   // semua item dicek dulu, baru stok dipotong
                if (it.jumlah() > stok.getOrDefault(it.produk().kode(), 0))
                    throw new Ditolak("stok " + it.produk().nama() + " kurang");
            for (Item it : isi)
                stok.merge(it.produk().kode(), -it.jumlah(), Integer::sum);
            System.out.println(t);
        } catch (Ditolak e) { System.out.println("gagal: " + e.getMessage()); }
    }
    public static void main(String[] args) {
        var toko = new Toko();
        toko.stok.putAll(Map.of("P01", 5, "P02", 3));
        var kaos = new Produk("P01", "Kaos Polos", "Pakaian", 85_000);
        var buku = new Produk("P02", "Buku Java", "Buku", 120_000);
        Diskon member = (belanja, tgl) -> belanja * 5 / 100;  // hak potongan
        var promo = new Promo("MERDEKA17", 50_000, LocalDate.of(2026, 8, 31));
        var isi = List.of(new Item(buku, 2), new Item(kaos, 1));
        List.of(List.of(member, promo), List.of(member), List.of(member))
                .parallelStream().forEach(aturan -> toko.checkout(isi, aturan));
        System.out.println("stok akhir " + toko.stok);
    }
}
