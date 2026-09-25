# Latihan 3 Pertemuan 3: Regular Expression di Regex101

Dari slide teori pertemuan 3 (Rahil Jumiyani, S.ST., M.Sc.), Jumat 25 September 2026, materi Regular Expression.

## Soal

- Latihan 2: buat regex untuk lima deskripsi string, yaitu (1) huruf kapital A-Z saja, (2) huruf kapital,
  huruf kecil, dan angka tanpa spasi, (3) angka 0-9 saja, (4) email huruf kecil/angka/underscore dengan
  domain huruf kecil berakhiran .com, dan (5) nama file berekstensi .jpg, .png, atau .gif (case sensitive).
- Latihan 3: eksekusi Latihan 2 di Regex101 (https://regex101.com/).

Yang diminta Ghaisan Latihan 3, jadi laporannya berisi regex Latihan 2 beserta hasil eksekusinya.

## Hasil

[`PLP_P3_TE_2B_048.pdf`](PLP_P3_TE_2B_048.pdf), 8 halaman. Tiap soal berisi regex, penjelasan singkat,
screenshot regex101.com, dan tabel string uji (mana yang cocok dan kenapa yang lain ditolak).

| No | Regex | Cocok / diuji |
|---|---|---|
| 1 | `^[A-Z]+$` | 2 / 6 |
| 2 | `^[A-Za-z0-9]+$` | 4 / 7 |
| 3 | `^[0-9]+$` | 3 / 7 |
| 4 | `^[a-z0-9_]+@[a-z]+\.com$` | 3 / 9 |
| 5 | `^[[:alnum:][:punct:]]+\.(jpg\|png\|gif)$` | 4 / 9 |

Pengaturan regex101: flavor PCRE2 (PHP), flag `g` dan `m`, satu string uji per baris. Flag `m` wajib
karena tanpa flag itu `^` dan `$` berlaku untuk seluruh teks, dan hasilnya 0 match di kelima soal (dicek
dengan perl). Soal 5 memakai kelas POSIX `[:alnum:]` dan `[:punct:]` yang ada di PCRE2 tapi tidak ada di
flavor JavaScript.

Screenshot di [`tangkapan/`](tangkapan/) diambil dari halaman regex101.com asli. Regex dan string uji
dimasukkan lewat parameter URL, jadi hasilnya bisa dicek ulang dengan membuka tautan berikut:

- [Soal 1](https://regex101.com/?regex=%5E%5BA-Z%5D%2B%24&testString=POLBAN%0AABCDEFGHIJKLMNOPQRSTUVWXYZ%0AHELLO%20WORLD%0APolban%0AABC123%0AJTK-2B&flags=gm&flavor=pcre2)
- [Soal 2](https://regex101.com/?regex=%5E%5BA-Za-z0-9%5D%2B%24&testString=rumah123%0ARumah123%0AABCdef789%0A2026%0Arumah%20123%0Arumah_123%0Arumah-123&flags=gm&flavor=pcre2)
- [Soal 3](https://regex101.com/?regex=%5E%5B0-9%5D%2B%24&testString=251524048%0A0%0A2026%0A2515%2024048%0A12a%0A-5%0A3.14&flags=gm&flavor=pcre2)
- [Soal 4](https://regex101.com/?regex=%5E%5Ba-z0-9_%5D%2B%40%5Ba-z%5D%2B%5C.com%24&testString=user_01%40gmail.com%0Aghaisan_048%40polban.com%0Aabc%40yahoo.com%0AUser_01%40gmail.com%0Auser.01%40gmail.com%0Auser01%40mail.polban.com%0Auser01%40gmail.co.id%0Auser01%40gmail.com.%0A%40gmail.com&flags=gm&flavor=pcre2)
- [Soal 5](https://regex101.com/?regex=%5E%5B%5B%3Aalnum%3A%5D%5B%3Apunct%3A%5D%5D%2B%5C.%28jpg%7Cpng%7Cgif%29%24&testString=gambar2%21.png%0Afoto_liburan.jpg%0ALogo-Polban.gif%0Ascan%281%29.jpg%0Adokumen5.pdf%0Agambar2%21.PNG%0Afoto%20liburan.jpg%0A.png%0Agambar.png.exe&flags=gm&flavor=pcre2)

Deadline belum diumumkan.
