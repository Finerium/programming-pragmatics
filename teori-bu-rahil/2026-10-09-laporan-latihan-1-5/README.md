# Laporan Latihan 1-5 (teori pertemuan 3, 4, 5)

Bu Rahil ternyata minta Latihan 1 sampai 5 dikumpulkan jadi satu berkas `PLP_P3-4-5_TE_2B_048`, formatnya mengikuti
contoh milik teman (lokal, tidak di-push): sampul, lalu satu bagian per latihan.

| Latihan | Isi | Bentuk |
|---|---|---|
| 1 | Mengubah RegEx menjadi string (P, Q, R, T, W) | foto tulisan tangan |
| 2 | Membuat RegEx sesuai deskripsi (5 soal) | foto tulisan tangan |
| 3 | Eksekusi regex di regex101.com | diketik, diambil dari [`../2026-09-25-latihan-regex/`](../2026-09-25-latihan-regex/) |
| 4 | Mengubah RegEx menjadi NFA | foto tulisan tangan |
| 5 | Mengubah NFA menjadi DFA | foto tulisan tangan |

Kunci jawaban Latihan 4 dan 5 ada di [`../2026-10-09-teori-4-regex-nfa-dfa/`](../2026-10-09-teori-4-regex-nfa-dfa/).

## Memasang foto tulisan tangan

Cara 1, lewat skrip: taruh foto di `foto/` dengan nama `latihan1-1.jpg`, `latihan2-1.jpg`, `latihan4-1.jpg`,
`latihan4-2.jpg`, `latihan5-1.jpg`, dan seterusnya (jpg, jpeg, atau png, satu foto satu halaman, urut sesuai nama),
lalu dari folder ini jalankan `python3 draf/rakit.py`. PDF dan DOCX dibuat ulang, latihan yang belum ada fotonya tetap
berupa kotak kosong. Foto diputar otomatis sesuai orientasi kamera.

Cara 2, manual: buka `PLP_P3-4-5_TE_2B_048.docx`, klik di dalam kotak "Tempel foto ...", hapus tulisannya, lalu
Insert > Picture. Setelah itu simpan ulang sebagai PDF dari Word atau Google Docs.
