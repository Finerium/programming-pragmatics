# los-natural: versi Prolog dan Java yang tidak terpengaruh Haskell

Permintaan Pak Joe Lian Min, 16 September 2026: "mintakan buat versi prolog dan java
tanpa terpengaruh oleh haskell. naturalnya di prolog dan java."

Konteksnya, tiga versi LOS yang sudah ada mengerjakan domain yang sama tapi dua di
antaranya mengikuti bentuk Haskell: `los-prolog` mengaku terjemahan setia dari `Lib.hs`,
dan `los-java` memetakan konsep Haskell ke Java satu per satu (Either jadi `Result<T>`,
komposisi fungsi jadi `Function.andThen`, dan seterusnya). Dua proyek di folder ini
mengerjakan domain yang sama, tapi dirancang ulang dari nol dengan cara berpikir
paradigmanya masing-masing. `Lib.hs` cuma dipakai sebagai daftar aturan bisnis.

```
los-prolog-natural/   los.pl, demo.pl, tes.pl, README.md
los-java-natural/     pom.xml, src/main/java/los/, src/test/java/los/, README.md
hasil/                keluaran teks demo dan tes tiap proyek
```

## Menjalankan

```bash
cd los-prolog-natural && swipl demo.pl && swipl tes.pl
cd ../los-java-natural && javac -Xlint:all -Werror -d kelas src/main/java/los/*.java && java -cp kelas los.Demo && mvn -B test
```

## Perbedaan rancangan yang paling penting

| Hal | Versi terjemahan | Prolog natural | Java natural |
|---|---|---|---|
| Kegagalan | `ok(X)`/`error(Msg)` dan `Result<T>` meniru Either | predikat gagal, alasan ditanya lewat `cacat/2` dan `hambatan/2` | exception domain (`KreditException`) yang membawa daftar alasan |
| Aturan underwriting | list lambda (yall) dan list `Predicate`, dites `maplist`/`allMatch` | klausa `melanggar/2` berkepala sama, dienumerasi backtracking | objek Specification bernama (`SkorMinimum`, `DtiMaksimum`, `PokokMaksimum`) |
| Aturan yang dilanggar | benar atau salah, atau hitung jumlah | `findall/3` atas `melanggar/2` | `aturanDilanggar()` mengembalikan list semua yang gagal |
| State bank | pasangan `StateIn`/`StateOut` dan record immutable yang dioper, meniru StateT | fakta dinamis `kuota_tersisa/1` di dalam `transaction/1` | `Bank` memegang kuota dan jurnal, diubah hanya setelah semua cek lolos |
| Data pengajuan | term posisional `loan_app/7` dan record dengan `withX` | dict SWI-Prolog, skenario lewat `put` | `Pengajuan` dengan invarian di constructor dan Builder |
| Keputusan | cut per klausa dan `switch` pattern matching | klausa dengan syarat eksklusif tanpa cut | `Keputusan.pesan()` polimorfik |
| Uang | `double` | integer rupiah | `Uang` di atas `BigDecimal`, pembulatan `HALF_UP` di satu tempat |
| Tabel bunga | if bertingkat di dua tempat | `premi_risiko/2` dan `penyesuaian_risiko/2`, tabelnya bisa dibalik lewat `between/3` | enum `KelasRisiko` memegang dua tabel |
| Query batas | tidak ada | `between/3` + `aggregate_all/3`: skor terendah Siti 650, pokok terbesar Andi Rp2 miliar | tidak dibuat, bukan kekuatan Java |
| Audit trail type class | `audit_entry/3` multifile dan `Auditable` + `Note` | tidak ada, jurnal cukup `jurnal/1` | tidak ada, jurnal cukup `Bank.jurnal()` |
| Tes | plunit acak meniru QuickCheck, `Spec.java` buatan sendiri | plunit 34 tes contoh tetap | JUnit 5 lewat Maven, 27 tes |

Penjelasan panjangnya ada di README masing-masing proyek, bagian "Kenapa ini beda
dengan versi terjemahan".

## Angka hasilnya tetap sama

| Angka | Haskell | Prolog natural | Java natural |
|---|---|---|---|
| DTI Budi | 0.25 | 0.25 | 0.2500 |
| Cicilan Rp200 juta, 8%, 24 bulan | 9045458.291236917 | 9045458 | Rp9,045,458 |
| Bunga akhir Budi | 7.75 | 7.75 | 7.75 |
| Sisa kuota setelah Budi | 8.0e8 | Rp800,000,000 | Rp800,000,000 |
| Siti | ditolak (skor 590 < 620) | `ditolak([skor_minimum])` | `Ditolak[skor minimum 620]` |
| Andi | ditolak (pokok 3 miliar) | `ditolak([pokok_maksimum])` | `Ditolak[pokok maksimum Rp2,000,000,000]` |
| Andi di underwriting bank | kuota habis, state tidak berubah | gagal, dua hambatan, kuota tetap | exception dua alasan, kuota tetap |

Dua hal kecil yang sengaja dibedakan dan dicatat di README masing-masing: plafon per
pinjaman Rp500 juta ikut dicek (di Haskell cuma disimpan di config), dan "bunga 1.5%"
di keputusan awal disebut apa adanya sebagai tambahan bunga risiko karena di Haskell
itu `annualRate` 0 ditambah 1.5.

Keluaran lengkap ada di `hasil/`: `prolog-demo.txt`, `prolog-tes.txt`, `java-demo.txt`,
`java-tes.txt`.
