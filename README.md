# Programming Language Pragmatics

Sarjana Terapan Teknik Informatika, Jurusan Teknik Komputer dan Informatika,
Politeknik Negeri Bandung. Semester Ganjil 2026/2027.

- Nama  : Ghaisan Khoirul Badruzaman
- NIM   : 251524048
- Kelas : 2B-D4

## Jadwal

| Jenis | Waktu | Ruang | Dosen |
|---|---|---|---|
| Praktikum | Jumat 13.30 - 15.10 | D108 | Joe Lian Min, M.Eng. |
| Teori | Jumat 07.50 - 09.30 | D217 | Rahil Jumiyani, S.ST., M.Sc. |

Mulai 21 September 2026 praktikum pindah dari Kamis 15.40 (H502 Lab. AI) ke Jumat 13.30 - 15.10,
dan teori pindah dari Jumat 13.00 ke Jumat jam ke-2 sampai ke-3, yaitu 07.50 - 09.30.

Tugas akhir mata kuliah ini adalah membuat domain specific language (DSL).

## Tugas

| Tugas | Diberikan | Hasil | Status |
|---|---|---|---|
| [Analisis 5 bahasa dengan ISO/IEC 25010](teori-bu-rahil/2026-09-11-tugas-iso25010/) | Jumat 11 Sep 2026, teori | [PDF 17 halaman](teori-bu-rahil/2026-09-11-tugas-iso25010/Tugas-ISO25010_Ghaisan-Khoirul-Badruzaman_251524048_2BD4.pdf) | Selesai, belum dikumpulkan. Deadline belum diumumkan |
| [Install Haskell dan SWI-Prolog](praktikum-pak-joe/2026-09-16-setup-haskell-prolog/) | Rabu 16 Sep 2026, grup WhatsApp | GHC 9.10.3, cabal 3.18.1.0, SWI-Prolog 10.0.2, plus latihan pertama Haskell dan Prolog | Selesai, persiapan praktikum Kamis 17 Sep 2026 |
| [Rerun los-haskell dan los-prolog](praktikum-pak-joe/2026-09-16-los-haskell-prolog/) | Rabu 16 Sep 2026, grup WhatsApp | Rerun kedua proyek, screenshot terminal, dan [`los-hasil-2B-048.zip`](praktikum-pak-joe/2026-09-16-los-haskell-prolog/los-hasil-2B-048.zip) | Selesai, tiga temuan ditulis di [`catatan.md`](praktikum-pak-joe/2026-09-16-los-haskell-prolog/catatan.md), cara menjalankan Haskell-nya di [`run.txt`](praktikum-pak-joe/2026-09-16-los-haskell-prolog/run.txt) |
| [los-java, versi Java OO](praktikum-pak-joe/2026-09-16-los-java/) | Rabu 16 Sep 2026, permintaan Pak Joe di grup | 18 berkas Java tanpa library luar, demo dan property test jalan, [`los-java-2B-048.zip`](praktikum-pak-joe/2026-09-16-los-java/los-java-2B-048.zip) | Selesai, peta konsep Haskell ke Prolog ke Java ada di [`README.md`](praktikum-pak-joe/2026-09-16-los-java/README.md) |
| [los-natural, Prolog dan Java tanpa mengikuti Haskell](praktikum-pak-joe/2026-09-16-los-natural/) | Rabu 16 Sep 2026, permintaan Pak Joe di grup | Dua proyek yang dirancang dari idiom paradigmanya sendiri, 34 tes plunit dan 27 tes JUnit, [`los-natural-2B-048.zip`](praktikum-pak-joe/2026-09-16-los-natural/los-natural-2B-048.zip) | Selesai, tabel perbedaan rancangan ada di [`README.md`](praktikum-pak-joe/2026-09-16-los-natural/README.md) |
| [Analisis paradigma untuk 5 studi kasus](teori-bu-rahil/2026-09-18-tugas-paradigma-pemrograman/) | Jumat 18 Sep 2026, teori | [PDF 23 halaman](teori-bu-rahil/2026-09-18-tugas-paradigma-pemrograman/Tugas-P2-Paradigma_Ghaisan-Khoirul-Badruzaman_251524048_2BD4.pdf), tabel 10 aspek per kasus plus kode Java, Haskell, dan Prolog dengan screenshot terminal asli, zip kiriman [`Tugas-P2-Paradigma_..._2BD4.zip`](teori-bu-rahil/2026-09-18-tugas-paradigma-pemrograman/Tugas-P2-Paradigma_Ghaisan-Khoirul-Badruzaman_251524048_2BD4.zip) | Selesai, belum dikumpulkan. Deadline belum diumumkan |
| [Praktikum 2: paradigma pemrograman](praktikum-pak-joe/2026-09-21-praktikum-2-paradigma/) | Senin 21 Sep 2026, dokumen Pak Joe | Empat program dilengkapi (C++ imperative, C++ OO, Haskell, SWI-Prolog), [laporan PDF 29 halaman](praktikum-pak-joe/2026-09-21-praktikum-2-paradigma/Praktikum-2-Paradigma_Ghaisan-Khoirul-Badruzaman_251524048_2BD4.pdf) berisi tabel pengamatan dan pertanyaan pengayaan, zip kiriman ada di folder yang sama | Selesai, belum dikumpulkan. Deadline belum disebut di dokumen |

## Progres

| Pertemuan | Tanggal | Materi | Catatan |
|---|---|---|---|
| Praktikum 1 | Kamis 10 Sep 2026 | Binding, scope, dan lifetime | Belum ada tugas |
| Teori 1 | Jumat 11 Sep 2026 | Evolusi bahasa pemrograman, taksonomi bahasa, kriteria evaluasi bahasa, ISO/IEC 25010 | Tugas analisis 5 bahasa, pengumuman tugas akhir DSL |
| Praktikum 2 | Kamis 17 Sep 2026 | Haskell, mahasiswa disuruh diskusi sendiri antar teman | Tidak ada tugas yang disebut |
| Teori 2 | Jumat 18 Sep 2026 | Paradigma bahasa pemrograman (imperative, object-oriented, functional, logic, concurrent, event-driven) dan lima studi kasus | Tugas analisis 10 aspek untuk kelima kasus |
| Praktikum 2 (dokumen) | Senin 21 Sep 2026 | Paradigma pemrograman lewat satu data nilai mahasiswa, dikerjakan di empat bahasa | Tugas melengkapi kode, mengisi tabel pengamatan, dan menjawab pertanyaan pengayaan |

## Struktur folder

Tugas dipisah per dosen: yang dari kelas teori Bu Rahil dan yang dari praktikum Pak Joe.

```
programming-pragmatics/
├── README.md
├── teori-bu-rahil/
│   ├── 2026-09-11-tugas-iso25010/
│   │   ├── README.md
│   │   └── Tugas-ISO25010_Ghaisan-Khoirul-Badruzaman_251524048_2BD4.pdf
│   └── 2026-09-18-tugas-paradigma-pemrograman/
│       ├── README.md               soal, ringkasan jawaban, cara menjalankan kode
│       ├── kode/                   contoh kode tiap kasus (Java, Haskell, Prolog)
│       ├── tangkapan/              screenshot terminal output tiap kasus
│       ├── Tugas-P2-Paradigma_Ghaisan-Khoirul-Badruzaman_251524048_2BD4.pdf
│       └── Tugas-P2-Paradigma_Ghaisan-Khoirul-Badruzaman_251524048_2BD4.zip
├── praktikum-pak-joe/
│   ├── 2026-09-16-setup-haskell-prolog/
│   │   ├── catatan.md              cara install dan cara menjalankan
│   │   ├── latihan-haskell/        baby.hs dan latihan.hs
│   │   ├── latihan-prolog/         keluarga.pl
│   │   └── hasil/                  output percobaan
│   ├── 2026-09-16-los-haskell-prolog/
│   │   ├── catatan.md              hasil rerun dan tiga temuan
│   │   ├── run.txt                 perintah terminal untuk menjalankan los-haskell
│   │   ├── los-haskell/, los-prolog/   berkas asli dari Pak Joe
│   │   ├── perbaikan/              salinan yang sudah diperbaiki
│   │   ├── hasil/, tangkapan/      output teks dan screenshot terminal
│   │   └── los-hasil-2B-048.zip    kiriman untuk Pak Joe
│   ├── 2026-09-16-los-java/
│   │   ├── README.md               peta konsep dan cara menjalankan
│   │   ├── src/los/                15 berkas sumber Java
│   │   ├── hasil/, tangkapan/      output teks dan screenshot terminal
│   │   └── los-java-2B-048.zip     kiriman untuk Pak Joe
│   ├── 2026-09-16-los-natural/
│   │   ├── README.md               tabel perbedaan rancangan
│   │   ├── los-prolog-natural/     los.pl, demo.pl, tes.pl
│   │   ├── los-java-natural/       proyek Maven, 13 berkas sumber
│   │   ├── hasil/, tangkapan/      output teks dan screenshot terminal
│   │   └── los-natural-2B-048.zip  kiriman untuk Pak Joe
│   └── 2026-09-21-praktikum-2-paradigma/
│       ├── README.md               soal, ringkasan jawaban, cara menjalankan
│       ├── kode/                   empat program: C++ imperative, C++ OO, Haskell, Prolog
│       ├── hasil/, tangkapan/      output teks dan screenshot terminal
│       └── laporan .pdf dan zip kiriman
└── materi/          slide dan dokumen dari dosen, tidak ikut di-push

## Catatan

Folder `materi/` berisi slide dosen, jadi tidak ikut di-push. Contoh tugas milik teman yang
dipakai sebagai pembanding juga tidak ikut di-push.
