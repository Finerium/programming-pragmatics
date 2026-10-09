# Teori Pertemuan 4: Regex ke NFA dan NFA ke DFA

Materi `Pertemuan 4_Finite Automata.pdf` (lokal di `materi/2026-10-09-teori-4-finite-automata/`). Soalnya lima
regex dari Latihan 1 pertemuan 3, diubah ke NFA (konstruksi Thompson sesuai slide RegEx to NFA) lalu ke DFA
(epsilon-closure dan move sesuai slide Conversion of an NFA to a DFA).

## Hasil

[`PLP_P4_TE_2B_048.pdf`](PLP_P4_TE_2B_048.pdf), 14 halaman. Salinan di `~/Downloads/Submit PLP Teori 4 NFA DFA (Bu Rahil)/`.
BAB I memuat jawaban Latihan 1 (contoh string tiap regex). Tiap regex berisi diagram NFA, tabel transisi NFA, langkah epsilon-closure dan move, tabel DFA, dan diagram DFA.

| Nama | Regex | State NFA | State DFA | State final DFA |
|---|---|---|---|---|
| P | `x(y)+z` | 6 | 4 | D |
| Q | `m \| nr*` | 9 | 4 | B, C, D |
| R | `(p \| q)*r` | 9 | 4 | D |
| T | `t*(u \| v)` | 9 | 4 | C, D |
| W | `x(y \| z)+` | 9 | 4 | C, D |

NFA, DFA, dan regex aslinya (`re.fullmatch`) sudah dicek menerima string yang sama persis untuk semua string
sampai panjang 6 atas alfabet masing-masing.

## Membuat ulang

`draf/fa.py` (lokal) menyimpan transisi kelima NFA, menghitung subset construction, menggambar diagram ke
`gambar/` dengan graphviz, dan menulis `laporan.md`. Lalu `draf/rakit.py` mengubah `laporan.md` jadi PDF.
