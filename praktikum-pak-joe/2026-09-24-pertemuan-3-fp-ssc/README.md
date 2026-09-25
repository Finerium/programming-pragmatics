# Pertemuan 3 Praktikum PLP: fp-ssc-course

Pesan Pak Joe (Kamis 24 September 2026):

> untuk kegiatan pertemuan 3, kegiatan praktikum mengikuti repo https://github.com/darrenjw/fp-ssc-course
> Tolong diinstall dan dicobakan. Dan mulai dibaca-baca.

Repo itu adalah bahan kursus setengah hari dari Darren Wilkinson, *An introduction to functional
programming for scalable statistical computing and machine learning*. Contohnya ditulis dalam Scala,
Haskell, JAX (Python), dan Dex. Semua bahasa memakai satu contoh yang sama: mencari parameter regresi
logistik dengan gradient ascent pada data Pima (200 baris, 7 prediktor, jadi 8 parameter termasuk intercept).

Menurut `Setup.md`, tidak wajib memasang semua bahasa: Scala ditambah minimal satu bahasa lain sudah cukup.
Di sini yang terpasang Scala, Haskell, dan JAX.

## Yang dipasang

| Komponen | Versi | Cara |
|---|---|---|
| Coursier (`cs`) | 2.1.25 | biner `cs-aarch64-apple-darwin` dari GitHub, lalu `cs setup --yes` |
| sbt, scala, scala-cli, scalac, scalafmt, amm | launcher sbt 2.0.9, Scala 3.9.0 (default), scala-cli 1.17.1 | ikut terpasang dari `cs setup`, lokasinya `~/Library/Application Support/Coursier/bin`, PATH ditambahkan ke `~/.zprofile` |
| JDK 17 | Temurin 17.0.20.1 | `cs java-home --jvm temurin:17`, dipakai khusus untuk kursus ini, `java` bawaan tetap OpenJDK 25 |
| GHC dan cabal | 9.10.3 dan 3.18.1.0 | sudah ada dari persiapan praktikum Haskell 16 September |
| Library Haskell | Frames 0.7.4.2, hmatrix 0.20.2, pipes 4.3.16, microlens 0.5.0.0 | diunduh dan dibangun otomatis oleh `cabal build` |
| JAX | jax 0.11.2, pandas 3.0.6, scipy 1.18.1 | virtualenv `.venv-jax/` (Python 3.12) dibuat dengan `uv` |
| Dex | tidak dipasang | lihat bagian masalah nomor 3 |

Repo kursusnya di-clone ke `fp-ssc-course/` (commit `b757a2a`, 2 Juli 2024). Folder itu tidak ikut di-push
karena isinya milik orang lain, cukup di-clone ulang dari tautan di atas.

## Hasil percobaan

Semua screenshot di bawah adalah jendela Terminal asli, ada di folder [`tangkapan/`](tangkapan/).

| No | Yang dicoba | Hasil |
|---|---|---|
| 1 | [Versi semua alat](tangkapan/01-versi.png) | semua perintah ketemu |
| 2 | [Scala di JDK 25](tangkapan/02-jdk25-gagal.png) | gagal, lihat masalah nomor 1 |
| 3 | [`sbt run`](tangkapan/03-sbt-run.png), contoh utama Scala | log-likelihood naik dari -566.3904 ke -89.19599 setelah 9781 langkah |
| 4 | [`sbt test`](tangkapan/04-sbt-test.png) | 19 tes lolos: 1 unit test, 2 property test, 16 law test Cats (Semigroup dan Functor untuk `List`) |
| 5 | [Empat skrip `scala-cli`](tangkapan/05-scala-cli.png) | `logFact 10` = 15.1044, `logFact 100000` = 1051299.2219, `parallel.scala` dan `futures.scala` memberi nilai sama -4.8442, `ML-GA.scala` sama persis dengan `sbt run` |
| 6 | [Contoh Haskell](tangkapan/06-haskell.png) | log-likelihood -566.3904 ke -89.27143 |
| 7 | [Contoh JAX](tangkapan/07-jax.png) | log-likelihood -566.39044 ke -89.196, gradiennya dari autodiff `grad` |
| 8 | [Latihan sbt sendiri](tangkapan/08-latihan-logfact.png) | log(10000!) = 82108.9278368..., 3 tes lolos |

Beberapa hal yang menarik dari hasilnya:

- `logFact 100000` tidak stack overflow walaupun rekursif, karena fungsinya ditandai `@tailrec` sehingga
  dikompilasi jadi loop. Hasilnya cocok dengan `math.lgamma(100001)` di Python sampai 11 digit.
- `parallel.scala` sengaja membuat tiap evaluasi tidur 500 ms. Versi sekuensial 10 data pasti butuh
  sekitar 5 detik, sedangkan waktu total programnya cuma 6,1 detik termasuk menyalakan JVM, jadi versi
  `.par` selesai jauh lebih cepat, dan hasil penjumlahannya sama persis. Ini aman tanpa lock karena
  fungsi `ll` pure dan tidak mengubah state apa pun.
- Nilai akhir tiga bahasa tidak sama (Scala -89.19599, Haskell -89.27143, JAX -89.196) padahal titik awal
  dan learning rate-nya sama. Penyebabnya kriteria berhenti yang berbeda. Scala berhenti kalau perubahan
  log-likelihood di bawah 1e-8. Haskell berhenti kalau norma perubahan parameter di bawah 1e-5, jadi
  berhenti lebih awal. JAX memakai `allclose` dengan toleransi relatif 1e-5 dan bekerja di float32.
- Law test di `sbt test` mengecek sifat asosiatif Semigroup. Sifat inilah yang di Intro disebut syarat
  supaya `reduce` bisa dijalankan paralel dengan tree reduction.

### Latihan: project sbt sendiri

Bagian akhir `Scala/md/ScalaHO.md` meminta membuat project sbt baru dari template lalu mencetak
log-factorial 10000. Project-nya dibuat dengan `sbt new darrenjw/breeze.g8` dan ada di
[`latihan/logfact-app/`](latihan/logfact-app/). Isinya dua versi `logFact` (rekursi ekor dan `foldLeft`)
yang dibandingkan dengan `lgamma` dari Breeze, plus tiga tes ScalaTest. Ketiga angkanya hanya beda di
dua digit terakhir karena urutan penjumlahan float-nya berbeda: rekursi menjumlah dari n turun ke 2,
sedangkan `foldLeft` dari 2 naik ke n.

## Masalah yang ditemukan

1. **Scala tidak bisa jalan di JDK 25.** Project Scala di repo memakai sbt 1.8.1 dan Scala 3.3.0 (tahun
   2023). Compiler versi itu gagal membaca class file JDK 25 dengan pesan `bad constant pool index`,
   baik lewat `sbt` maupun `scala-cli` (screenshot 2). Solusinya memakai JDK 17 khusus untuk kursus ini,
   tanpa mengubah berkas repo supaya `git pull` tetap bersih:
   `sbt -java-home "$(cs java-home --jvm temurin:17)" run` dan `scala-cli --jvm temurin:17 berkas.scala`.
2. **Contoh Haskell disiapkan untuk stack dengan GHC 8.10.7.** Stack belum terpasang, jadi dicoba dengan
   GHC 9.10.3 dan cabal yang sudah ada. Kendalanya, Frames 0.7.4.2 membatasi `base < 4.20`,
   sedangkan GHC 9.10.3 membawa base 4.20.2, sehingga perlu `--allow-newer`. Setelah itu build lolos,
   hanya ada warning.
3. **Dex tidak bisa dipasang.** Dex harus dibangun dari source dan butuh LLVM 12
   (`brew install llvm@12`), tapi formula `llvm@12` sudah tidak ada di Homebrew (brew hanya menyarankan
   `llvm@14` ke atas). Karena `Setup.md` bilang Scala ditambah satu bahasa lain sudah cukup, Dex dilewati.
   Hands-on bilangan acak splittable di `Intro/RandomHO.md` boleh memilih JAX atau Dex, jadi masih bisa
   dikerjakan lewat JAX.
4. Hal kecil: `scala-cli` memberi hint bahwa versi library di header skrip sudah usang, dan Breeze
   menulis warning `Failed to load implementation ... BLAS` lalu memakai implementasi Java. Keduanya tidak
   memengaruhi hasil.

## Cara menjalankan lagi

```bash
cd fp-ssc-course            # git clone https://github.com/darrenjw/fp-ssc-course.git kalau belum ada
J17=$(cs java-home --jvm temurin:17)

# Scala (dari folder yang berisi build.sbt)
cd Scala
sbt -java-home "$J17" run
sbt -java-home "$J17" test
sbt -java-home "$J17" console      # REPL dengan semua dependency project

# skrip scala-cli
cd cli
scala-cli --jvm temurin:17 logFact.scala -- 10
scala-cli --jvm temurin:17 parallel.scala
scala-cli --jvm temurin:17 futures.scala
scala-cli --jvm temurin:17 ML-GA.scala

# Haskell
cd ../../Haskell
cabal run --allow-newer ml-ga-exe

# JAX
cd ../JAX
../../.venv-jax/bin/python ml-ga.py
```

## Urutan baca

Mengikuti daftar Materials di README repo dan `Outline.md`. Bagian Dex dilewati.

| No | Bahan | Isi singkat |
|---|---|---|
| 1 | `Intro/Readme.md` | kenapa FP cocok untuk komputasi statistik yang skalabel |
| 2 | `Scala/md/ScalaCC.md` | crash course Scala |
| 3 | `Scala/md/ScalaHO.md` | hands-on Scastie, scala-cli, dan sbt (sudah dicoba, lihat di atas) |
| 4 | `Intro/Example.md` | contoh berjalan: log-likelihood regresi logistik dan gradiennya |
| 5 | `Scala/md/Example.md` | contoh itu di Scala dengan Breeze, plus latihan tuning dan line search |
| 6 | `Scala/md/Parallel.md` | koleksi paralel dan Future di Scala |
| 7 | `Haskell/README.md`, `Haskell/Example.md` | crash course Haskell dan contoh yang sama di Haskell |
| 8 | `JAX/Readme.md`, `JAX/Example.md` | JAX sebagai bahasa array fungsional di dalam Python |
| 9 | `Intro/Random.md`, `JAX/Random.md` | bilangan acak yang bisa di-split untuk komputasi paralel |
| 10 | `Intro/Resources.md` | penutup dan bahan belajar lanjutan |

### Catatan dari Intro

- Bahasa yang biasa dipakai untuk komputasi statistik semuanya imperatif. R, Python, dan Matlab terlalu
  lambat, sedangkan C, C++, Java, dan Fortran cepat tapi sulit dipakai untuk membuat kode yang
  komposisional, mudah dites, dan bisa memanfaatkan banyak core.
- Ciri FP: data immutable, fungsi pure yang referentially transparent, dan higher order function. Scala
  dan Haskell yang bertipe statis dekat dengan simply-typed lambda calculus, jadi konsep dari category
  theory seperti functor, monad, dan comonad bisa dipakai untuk menyederhanakan kode.
- Kesulitan pemrograman paralel kebanyakan berasal dari shared mutable state. Di FP murni state tidak
  bisa diubah, jadi masalah itu hilang dan paralelisme kadang bisa otomatis.
- Monoid adalah himpunan dengan operasi biner yang asosiatif dan punya elemen identitas. Karena
  asosiatif, `fold` dan `reduce` bisa dihitung dengan tree reduction, waktunya turun dari O(n) ke
  O(log n) kalau prosesornya cukup banyak. Pola map-reduce adalah memetakan data ke sebuah monoid lalu
  me-reduce hasilnya, disebut juga `foldMap`.
- Spark (RDD) dan JAX memakai model komputasi yang mirip walaupun targetnya berbeda: algoritma ditulis
  sebagai transformasi lazy atas data immutable dengan fungsi pure. Dengan begitu library bisa
  mengoptimalkan, memparalelkan, bahkan menurunkan (autodiff) kode secara otomatis.

Kaitannya dengan praktikum sebelumnya: fungsi `ascend` di contoh Scala memakai fungsi dalam `go` yang
rekursif ekor sebagai pengganti `while` dan variabel yang diubah-ubah. Ini contoh nyata bagaimana state
yang di praktikum 2 disimpan di variabel mutable, di FP dibawa sebagai argumen fungsi.

## Isi folder

```
2026-09-24-pertemuan-3-fp-ssc/
├── README.md                catatan ini
├── catatan/                 catatan belajar per topik, mulai dari 01-konsep-dasar-fp.md
├── tangkapan/               8 screenshot terminal hasil percobaan
├── latihan/logfact-app/     project sbt latihan log-factorial
├── fp-ssc-course/           clone repo kursus (tidak di-push)
└── .venv-jax/               virtualenv JAX (tidak di-push)
```
