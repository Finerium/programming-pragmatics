# Praktikum Pertemuan 4: Analisis Leksikal

Slide "Praktikum PLP 4" (Rahil Jumiyani), diunduh Jumat 9 Oktober 2026, salinannya di
`materi/2026-10-09-praktikum-4-analisis-leksikal/` (lokal). Isinya:

- slide 2 sampai 6: pola regex, pembentukan lexeme, tabel lexeme ke pola, jenis token, dan token untuk `int total = price + 10;`
- slide 7: jalankan program scanner `Lox.java` dari repo [munificent/craftinginterpreters](https://github.com/munificent/craftinginterpreters) dan baca buku Crafting Interpreters
- slide 8, Latihan identifikasi token untuk dua potongan kode: (a) identifikasi di atas kertas, (b) jalankan lexer, (c) bandingkan

```
a. int diskon = total > 200000 ? total * 10 / 100 : 0;
b. for (i = 0; i < 10; i++) {
       total = total + i;
   }
```

## Hasil

[`PLP_P4_TE_2B_048.pdf`](PLP_P4_TE_2B_048.pdf), 16 halaman, naskahnya [`laporan.md`](laporan.md). Salinan PDF di
`~/Downloads/Submit PLP Praktikum 4 (Bu Rahil)/`.

| Potongan | Manual | Scanner jlox Bab 4 | Scanner modifikasi |
|---|---|---|---|
| a | 15 token | 13 token + EOF, 2 error `Unexpected character.` (`?` dan `:`), `int` jadi IDENTIFIER, exit 65 | 15 token + EOF, sama dengan manual |
| b | 21 token | 22 token + EOF, `++` jadi dua PLUS, tanpa error, exit 0 | 21 token + EOF, sama dengan manual |

Perbedaannya karena identifikasi manual memakai aturan leksikal C/Java, sedangkan jlox memakai aturan Lox
(tidak punya `int`, `?:`, dan `++`, semua angka double). Versi modifikasi menambah token `QUESTION`, `COLON`,
`PLUS_PLUS`, dan keyword `INT`.

## Program

`Lox.java` yang ditautkan di slide adalah versi final jlox. Versi itu langsung mem-parse, jadi untuk
`int total = price + 10;` hasilnya error parser, bukan daftar token. Yang mencetak token adalah versi akhir
Bab 4. Folder `gen/` per bab tidak ada di repo (dibuat tool Dart), jadi versi Bab 4 diambil dari kode final
lewat penanda bab `//>` dan `//<` dengan `draf/ambil_bab4.py`.

| Folder | Isi |
|---|---|
| `kode/lox-bab4/` | jlox versi akhir Bab 4 (Lox, Scanner, Token, TokenType) |
| `kode/lox-modifikasi/` | sama, ditambah `?`, `:`, `++`, dan keyword `int` (baris bertanda `// modifikasi`) |
| `kode/input/` | `contoh.txt` (slide 2), `latihan-a.txt`, `latihan-b.txt` |
| `tangkapan/` | 8 screenshot terminal asli |

Kode jlox milik Robert Nystrom dengan lisensi MIT, teks lisensinya di `kode/LICENSE-craftinginterpreters`.

## Menjalankan ulang

Dari folder ini, dengan JDK 17 ke atas (dicoba dengan OpenJDK 25.0.2):

```
git clone --depth 1 https://github.com/munificent/craftinginterpreters.git
javac -d kelas/final craftinginterpreters/java/com/craftinginterpreters/lox/*.java
javac -d kelas/bab4 kode/lox-bab4/com/craftinginterpreters/lox/*.java
javac -d kelas/modifikasi kode/lox-modifikasi/com/craftinginterpreters/lox/*.java

java -cp kelas/bab4 com.craftinginterpreters.lox.Lox kode/input/latihan-a.txt
java -cp kelas/modifikasi com.craftinginterpreters.lox.Lox kode/input/latihan-a.txt
java -cp kelas/final com.craftinginterpreters.lox.Lox kode/input/latihan-b.txt
```

Tanpa argumen berkas, `Lox` masuk mode REPL (`> `) dan mencetak token tiap baris yang diketik.
Clone repo dan folder `kelas/` tidak ikut di-push.
