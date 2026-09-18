# Tugas Pertemuan 2: Paradigma Bahasa Pemrograman

Dari slide teori pertemuan 2 (Rahil Jumiyani, S.ST., M.Sc.), Jumat 18 September 2026.

## Soal

Slide berisi lima studi kasus, lalu slide Tugas berisi tabel dua kolom (Aspek Analisis dan Jawaban)
dengan sepuluh aspek: karakteristik masalah, konsep komputasi yang dominan, pendekatan pemrograman
yang dipilih, alasan pemilihan, contoh struktur/pseudocode, kelebihan, keterbatasan, risiko terhadap
kualitas software, ISO/IEC 25010 yang relevan, dan perlu tidaknya kombinasi pendekatan. Slide tidak
menyebut format, jadi kelima kasus dijawab semua.

## Hasil

[`Tugas-P2-Paradigma_Ghaisan-Khoirul-Badruzaman_251524048_2BD4.pdf`](Tugas-P2-Paradigma_Ghaisan-Khoirul-Badruzaman_251524048_2BD4.pdf), 23 halaman.

| Kasus | Pendekatan utama | Contoh kode |
|---|---|---|
| 1. Keranjang belanja e-commerce | Object-Oriented, dibantu fungsi murni untuk checkout dan penguncian stok | [`Toko.java`](kode/kasus-1/Toko.java) |
| 2. Sistem informasi rumah sakit | Object-Oriented dengan hak akses per peran (RBAC) | [`RumahSakit.java`](kode/kasus-2/RumahSakit.java) |
| 3. Analisis data penjualan | Functional (Haskell) | [`Penjualan.hs`](kode/kasus-3/Penjualan.hs) |
| 4. Sistem pakar rekomendasi | Logic (SWI-Prolog) | [`rekomendasi.pl`](kode/kasus-4/rekomendasi.pl) |
| 5. Layanan web dengan banyak pengguna | Concurrent dengan operasi asinkron (Java 25, virtual thread) | [`Pesanan.java`](kode/kasus-5/Pesanan.java) |

Contoh struktur di setiap kasus ditulis sebagai kode yang benar-benar dijalankan, dan outputnya
dicantumkan di PDF. Cara menjalankannya:

```
cd kode/kasus-1 && java Toko.java
cd kode/kasus-2 && java RumahSakit.java
cd kode/kasus-3 && runghc Penjualan.hs
cd kode/kasus-4 && swipl rekomendasi.pl
cd kode/kasus-5 && java Pesanan.java
```

Java butuh JDK 21 ke atas (dibuat dengan OpenJDK 25), Haskell dengan GHC 9.10, dan Prolog dengan SWI-Prolog 10.
Output kasus 1 bergantung pada tanggal hari ini karena promo `MERDEKA17` berakhir 31 Agustus 2026.

## Deadline

Belum diumumkan per 18 September 2026.
