# Praktikum 2: Paradigma Pemrograman

Tugas praktikum dari Pak Joe Lian Min, dokumen `Praktikum 2 Paradigma Pemrograman.docx`.
Satu persoalan yang sama dikerjakan dengan empat paradigma, lalu tiap program diamati
dari sisi binding, scope, lifetime, dan state.

Data yang dipakai: 30 nilai mahasiswa dengan komponen tugas, UTS, dan UAS.
Nilai akhir = 30% tugas + 30% UTS + 40% UAS.

## Yang dikosongkan dosen dan dilengkapi di sini

| Program | Bahasa | Yang dilengkapi |
|---|---|---|
| 1 Imperative | C++ | `searchNIM`, `searchNama`, `searchNilai`, plus tiga cabang `menuFilter()` |
| 2 Object oriented | C++ | method `filterNIM`, `filterNama`, `filterNilai` di kelas `SistemAkademik` |
| 3 Functional | Haskell | `searchNIM`, `searchNama`, `filterNilai` |
| 4 Logic | SWI-Prolog | query gabungan nomor 13 dan 14 |

Kode dosen selain bagian itu tidak diubah. Satu baris di Program 1 memang harus diperbaiki
karena `case 1: searchNIM(NIM);` memakai `NIM` yang tidak pernah dideklarasikan sehingga
g++ menolak mengompilasi. Pesan error kode aslinya direkam di `hasil/kompilasi-asli.txt`.

## Hasil

Keempat program memberi angka yang sama: nilai tertinggi Maya (24013) 94.50, terendah
Putra (24016) 57.40, rata-rata kelas 77.80667, dan 10 mahasiswa bergrade A.

Query nomor 13 dan 14:

```prolog
?- lulus(NIM), \+ grade(NIM, a).                              % 18 mahasiswa
?- perlu_bimbingan(NIM), nilai_akhir(NIM, Nilai), Nilai < 60. % 24006 dan 24016
```

## Isi folder

```
kode/program1-imperative/   program1.cpp dan input-demo.txt
kode/program2-oo/           program2.cpp dan input-demo.txt
kode/program3-haskell/      program3.hs
kode/program4-prolog/       program4.pl
kode/eksperimen/            potongan kecil untuk menjawab baris tabel pengamatan
hasil/                      keluaran asli tiap program dan eksperimen
tangkapan/                  screenshot terminal untuk laporan
jawaban.md                  tabel pengamatan dan pertanyaan pengayaan
run.txt                     perintah kompilasi dan menjalankan
Praktikum-2-Paradigma_Ghaisan-Khoirul-Badruzaman_251524048_2BD4.pdf   laporan 29 halaman
```

## Menjalankan

```
g++ -std=c++17 -o build/program1 kode/program1-imperative/program1.cpp
./build/program1 < kode/program1-imperative/input-demo.txt

g++ -std=c++17 -o build/program2 kode/program2-oo/program2.cpp
./build/program2 < kode/program2-oo/input-demo.txt

. "$HOME/.ghcup/env"
runghc kode/program3-haskell/program3.hs

swipl -q -g demo -t halt kode/program4-prolog/program4.pl
```

Toolchain: Apple clang 17.0.0 (C++17), GHC 9.10.3, SWI-Prolog 10.0.2.
Perintah selengkapnya ada di `run.txt`.
