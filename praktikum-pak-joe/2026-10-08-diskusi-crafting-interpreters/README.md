# Resume Diskusi Crafting Interpreters Bab 2 dan Bab 4

Diberikan Kamis 8 Oktober 2026 lewat pesan Pak Joe di grup. Tiga minggu ke depan praktikum dipakai untuk
fondasi kasus-kasus yang bisa diselesaikan dengan Tree-Sitter, dengan buku
[Crafting Interpreters](https://craftinginterpreters.com/contents.html) sebagai pegangan. Fokus pertemuan
ini Bab 2 (A Map of the Territory) dan Bab 4 (Scanning). Asetnya ada di repo
[munificent/craftinginterpreters](https://github.com/munificent/craftinginterpreters).

Mekanismenya diskusi online per kelompok yang direkam, kelompok membuat transkrip dari rekamannya, lalu
setiap anggota menyusun resume dengan pemahamannya sendiri. Folder ini berisi resume individu itu.
Transkrip adalah tugas kelompok dan tidak ada di sini.

## Hasil

`Resume-Diskusi-Crafting-Interpreters_Ghaisan-Khoirul-Badruzaman_251524048_2BD4.pdf`, 17 halaman,
salinannya di `~/Downloads/Submit PLP Resume Diskusi (Pak Joe)/`. PDF dan naskahnya (`resume.md`) disimpan
lokal saja karena memuat nama anggota kelompok.

| Bab | Isi |
|---|---|
| I Pendahuluan | latar belakang dari pesan Pak Joe, mekanisme diskusi, pembagian materi lima anggota, sumber belajar |
| II Ringkasan Materi Diskusi | model gunung dan front/middle/back end, native code lawan bytecode, lexeme dan token, core scanner dan literal, keyword, error leksikal, implicit semicolons |
| III Sesi Tanya Jawab | lima pertanyaan yang muncul selama diskusi beserta jawabannya |
| IV Refleksi | yang didapat dari diskusi, kaitan dengan praktikum 1 (binding, scope) dan teori 3 (regex), bagian Bab 2 yang dilengkapi dari buku (single-pass, tree-walk, transpiler, JIT, runtime), kaitan Bab 4 dengan Tree-Sitter |
| V Kesimpulan | |

Isi BAB II dan III diambil dari ringkasan hasil diskusi kelompok. BAB I dan BAB IV ditulis sendiri.

## Gambar

Tiga diagram di `gambar/` digambar ulang dengan matplotlib, bukan diambil dari buku:

- `gunung.png`: tahapan implementasi bahasa sebagai pendakian gunung, dengan pembagian front end, middle end, dan back end
- `ir.png`: 3 x 3 = 9 compiler tanpa IR lawan 3 front end + 3 back end dengan IR
- `start-current.png`: posisi `start` dan `current` setelah scanner membaca lexeme `18` di `var umur = 18;`

## Membuat ulang

```
python3 draf/gambar.py    # diagram ke gambar/
python3 draf/rakit.py     # resume.md jadi PDF
```

Folder `draf/` (skrip dan builder PDF) tidak ikut di-push, sama seperti tugas lain di repo ini.
