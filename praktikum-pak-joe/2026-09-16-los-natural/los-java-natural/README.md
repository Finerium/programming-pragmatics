# los-java-natural

Loan Originating System ditulis ulang sebagai kode OO biasa, bukan Haskell yang dipindah
ke Java. Butuh JDK 17 ke atas. Aturan bisnisnya sama dengan `los-haskell`, kecuali plafon
per pinjaman Rp500 juta yang di Haskell tersimpan di config tetapi tidak pernah dipakai,
di sini ikut diperiksa. Selain itu yang beda cuma bentuknya.

## Cara menjalankan

```bash
javac -Xlint:all -Werror -d kelas src/main/java/los/*.java && java -cp kelas los.Demo   # demo
mvn -B test                                                                          # 27 tes JUnit 5
```

`mvn test` juga mengompilasi dengan `-Xlint:all -Werror` (diatur di `pom.xml`), jadi kalau
ada warning, tesnya tidak jalan. Versi yang dipakai JUnit 5.9.3 dan surefire 3.0.0-M9. Maven
perlu internet sekali untuk mengunduh keduanya, sesudah masuk cache lokal bisa dijalankan
offline dengan `mvn -o test`. Demonya sendiri tidak butuh Maven, cukup `javac` dan `java`.

## Rancangan

Tiga belas berkas di `src/main/java/los/`, semuanya bicara dalam bahasa domain.

| Kelas | Peran |
|---|---|
| `Uang` | nilai rupiah di atas `BigDecimal`, pembulatan ke rupiah bulat setengah ke atas, cuma di sini |
| `Pengajuan` | entity dengan invarian: tidak bisa dibuat kalau pokok, tenor, atau skor tidak masuk akal; punya `dti()` dan `kelasRisiko()` |
| `Pengajuan.Builder` | enam parameter terlalu banyak untuk satu constructor |
| `KelasRisiko` | enum TINGGI / MENENGAH / RENDAH, memegang dua tabel bunga yang batas skornya sama |
| `Kebijakan` | enum KONSERVATIF / STANDAR / AGRESIF dengan penyesuaian bunganya |
| `AturanUnderwriting` | Specification: aturan bernama, tiga implementasi `SkorMinimum`, `DtiMaksimum`, `PokokMaksimum` |
| `Underwriter` | penyaringan awal, daftar aturan disuntik lewat constructor, mengembalikan `Keputusan` |
| `Keputusan` | `Disetujui`, `Ditolak`, `PerluDokumen`, masing-masing tahu `pesan()`-nya sendiri |
| `Bank` | konfigurasi tetap plus kuota harian dan jurnal, `underwrite()` mengembalikan `Pinjaman` atau melempar exception |
| `Pinjaman` | pokok, tenor, bunga akhir, dan `cicilanBulanan()` anuitas |
| `KreditException` dan dua turunannya | kegagalan domain, selalu bawa daftar alasan |
| `Demo` | main |

Alurnya: `Pengajuan.pemohon("Budi").pokok(...).ajukan()` membuat objek yang dijamin
valid. `Underwriter.standar().putuskan(p)` mengembalikan keputusan awal. `Bank.underwrite(p)`
memeriksa ketentuan bank, memotong kuota, mencatat jurnal, dan mengembalikan `Pinjaman`
dengan bunga akhir.

### Keputusan rancangan yang sengaja diambil

**Uang pakai `BigDecimal`, dibungkus `Uang`.** `double` tidak cocok untuk uang, dan kalau
`BigDecimal` dipakai telanjang, `setScale` dan `compareTo` bakal berserakan. Di `Uang`
pembulatannya cuma satu: ke rupiah bulat, `HALF_UP`. Bunga tetap `BigDecimal` dua angka di
belakang koma, DTI empat angka.

**Invarian di constructor, bukan fungsi validasi terpisah.** `Pengajuan` dengan pokok negatif
tidak pernah ada. Semua cacat dikumpulkan dulu baru dilempar sebagai satu
`PengajuanTidakValidException`, jadi pemohon tahu tiga kesalahannya sekaligus, bukan satu per
satu. Validasi dasar itu tidak diulang lagi di `Bank` maupun `Underwriter`. Skor minimum memang
diperiksa di dua tempat, tetapi tujuannya beda: di `Underwriter` sebagai aturan underwriting, di
`Bank` sebagai syarat pencairan, sama seperti di `los-haskell`.

**Polimorfisme ganti percabangan.** `Keputusan.pesan()` diimplementasikan tiap jenis
keputusan, tidak ada `switch` atas jenisnya. Dua tabel bunga (tambahan waktu keputusan awal
dan premi waktu underwriting) jadi atribut `KelasRisiko`, jadi `if skor < 600` cuma ada di
satu tempat, `KelasRisiko.dariSkor`.

**Specification untuk aturan.** Tiap aturan adalah objek bernama dengan ambangnya sendiri.
`Underwriter` menerima daftar aturan lewat constructor, jadi tes bisa bikin `Underwriter`
yang cuma punya satu aturan ketat tanpa mengubah kelasnya. `aturanDilanggar()` mengembalikan
semua yang gagal, bukan berhenti di yang pertama.

**Exception untuk alur gagal.** `Bank.underwrite()` tidak mengembalikan wadah sukses-atau-gagal.
Kalau bank tidak bisa mengunderwrite, dilempar `UnderwritingDitolakException` yang membawa
semua hambatan. Exception-nya checked, karena pemanggil memang harus memutuskan mau diapakan.
Kenapa `Keputusan.Ditolak` bukan exception? Karena ditolak di penyaringan awal itu hasil
yang normal dan harus disampaikan ke pemohon, sedangkan bank yang tidak bisa memproses itu
kegagalan operasi.

**State tanpa keadaan setengah jadi.** `Bank` memeriksa semua hambatan dan menghitung bunga dulu,
baru menyentuh `kuotaTersisa` dan `jurnal`. Pengajuan yang ditolak tidak meninggalkan jejak,
dan itu dites di `andiDitolakDenganDuaHambatanDanStateUtuh`.

## Kenapa ini beda dengan versi terjemahan (los-java)

| Di los-java (terjemahan) | Di sini | Alasan |
|---|---|---|
| `Result<T>` sealed Ok/Err meniru Either | exception domain yang membawa daftar alasan | di Java, kegagalan yang harus ditangani itu exception; caller tidak bisa lupa karena checked |
| `Pipeline.FULL_PIPELINE` rantai `Function.andThen` | `underwriter.putuskan(p).pesan()`, dua panggilan method | komposisi fungsi bukan idiom Java, pemanggilan method biasa lebih terbaca |
| `Calculations`, `Pipeline`, `Rules` kumpulan method `static` | `Pengajuan.dti()`, `Pinjaman.cicilanBulanan()`, `Underwriter.putuskan()` | perilaku ikut objek yang punya datanya |
| `switch` pattern matching atas sealed `LoanDecision` | `Keputusan.pesan()` polimorfik | tell, don't ask |
| `Rule` sebagai lambda `Predicate` tanpa nama | `AturanUnderwriting` dengan `nama()` | pelanggaran bisa dilaporkan pakai nama aturannya |
| `record LoanApplication` dengan `withRate`, `withScore` | `Pengajuan` dengan invarian dan Builder | data yang tidak valid tidak bisa dibuat, dan `annualRate` tidak perlu ada di pengajuan |
| `BankState` record immutable yang dioper masuk dan keluar | `Bank` memegang kuota dan jurnal sendiri | bank memang punya state; yang penting perubahannya cuma setelah semua cek lolos |
| `double` untuk uang dan bunga | `Uang` di atas `BigDecimal` | `double` tidak cocok untuk uang, pembulatan harus jelas |
| validasi berhenti di kegagalan pertama | semua pelanggaran dikumpulkan jadi list | itu yang lazim di validasi Java |
| `Auditable`, `AuditSeverity`, `Note`, `AuditTrail` meniru type class | tidak ada | peragaan type class, bukan aturan bisnis; jurnal underwriting tetap ada di `Bank.jurnal()` |
| `Spec.java` tes property acak buatan sendiri | JUnit 5, satu method satu kasus | tes contoh tetap lebih mudah dibaca dan dijalankan Maven |

## Catatan

Plafon per pinjaman Rp500 juta di versi Haskell cuma disimpan di config dan tidak pernah
dicek. Di sini dicek di `Bank.hambatan()`, jadi Andi mendapat dua alasan sekaligus.

Kolom "bunga 1.5%" untuk Budi di keputusan awal: di Haskell itu `annualRate` 0 ditambah 1.5.
Di sini disebut apa adanya sebagai `tambahanBungaRisiko`. Bunga akhir baru ada di `Pinjaman`
yang dikembalikan `Bank.underwrite()`, dan sekalian dihitung cicilannya (Rp9,022,671 untuk
Budi pada 7.75%).

Field alasan di `KreditException` disimpan sebagai `String[]`, bukan `List<String>`, karena
`javac -Xlint:serial` di JDK 19 ke atas memprotes field non-serializable di kelas yang
serializable.

Hasil: demo mencetak DTI 0.2500, cicilan Rp9,045,458, bunga akhir Budi 7.75%, sisa kuota
Rp800,000,000. `mvn -B test` 27 tes lolos, kompilasi bersih.
