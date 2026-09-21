# Praktikum 2 Paradigma Pemrograman

Nama: Ghaisan Khoirul Badruzaman
NIM: 251524048
Kelas: 2B D4 Teknik Informatika
Mata kuliah: Programming Language Pragmatics Praktik 2026
Dosen praktikum: Joe Lian Min

Semua jawaban di bawah diambil dari hasil menjalankan program di mesin sendiri.
Keluaran mentahnya ada di folder `hasil/`, perintahnya ada di `run.txt`.

Toolchain: g++ (Apple clang 17.0.0) dengan `-std=c++17`, GHC 9.10.3, SWI-Prolog 10.0.2.

---

## Bagian yang dilengkapi dan alasannya

Kode dari dokumen disalin apa adanya. Yang diubah hanya bagian yang memang
dikosongkan dosen, ditambah satu baris di Program 1 yang bikin kodenya tidak
bisa dikompilasi. Bukti error kode aslinya ada di `hasil/kompilasi-asli.txt`.

| Program | Bagian yang dilengkapi | Alasan |
|---|---|---|
| 1 Imperative | `searchNIM(Mahasiswa[], int, string)` | Komentar `// TAMBAHKAN FUNGSI SEARCH BERDASARKAN NIM` memang kosong. Dibuat linear search karena array sudah diurutkan berdasarkan nilai, bukan berdasarkan NIM, jadi binary search tidak bisa dipakai. |
| 1 Imperative | `searchNama(Mahasiswa[], int, string)` | Sama, bagiannya kosong. Cocokkan string nama persis. |
| 1 Imperative | `searchNilai(Mahasiswa[], int, float)` | Sama, bagiannya kosong. Dibuat menampilkan semua mahasiswa dengan nilai lebih besar atau sama dengan batas, mengikuti keterangan di Program 2 yang menulis "Menampilkan nilai >= batas". |
| 1 Imperative | `case 1: searchNIM(NIM);` di `menuFilter()` | Ini perbaikan wajib. `NIM` tidak pernah dideklarasikan di mana pun, jadi kode dosen gagal dikompilasi dengan pesan `error: use of undeclared identifier 'NIM'`. Diganti jadi blok `case` yang membaca input dulu lalu memanggil `searchNIM(mahasiswa, jumlah, nim)`, meniru gaya `menuFilter()` di Program 2 supaya konsisten. |
| 1 Imperative | `case 2` dan `case 3` di `menuFilter()` | Aslinya hanya komentar `//fungsi search by Nama` dan `//fungsi search by Nilai`, menunya jadi tidak melakukan apa-apa. |
| 2 Object oriented | `filterNIM(string)` | Sudah dipanggil di `menuFilter()` tapi methodnya belum ada, jadi gagal kompilasi dengan `error: use of undeclared identifier 'filterNIM'`. |
| 2 Object oriented | `filterNama(string)` | Sama, dipanggil tapi belum ada. |
| 2 Object oriented | `filterNilai(float)` | Sama, dipanggil tapi belum ada. Memakai `getNilai()` supaya tetap lewat getter, tidak menyentuh atribut private langsung. |
| 3 Haskell | `searchNIM :: String -> [Mahasiswa] -> [Mahasiswa]` | Dipanggil di `main` tapi belum didefinisikan, GHC bilang `Variable not in scope: searchNIM`. Dibuat dengan `filter` supaya tetap murni dan mengembalikan list, sesuai cara `main` memakainya lewat `mapM_ tampilkan`. |
| 3 Haskell | `searchNama :: String -> [Mahasiswa] -> [Mahasiswa]` | Sama, belum didefinisikan. |
| 3 Haskell | `filterNilai :: Float -> [Mahasiswa] -> [Mahasiswa]` | Sama, belum didefinisikan. Urutan parameter mengikuti pemanggilan `filterNilai 80 mahasiswa`. |
| 4 Prolog | Query nomor 13 | Dokumen menulis "Buatkan sintaksnya". Jawabannya `?- lulus(NIM), \+ grade(NIM, a).` Negasi pakai `\+` karena Prolog tidak punya "tidak mendapat A" sebagai fakta, jadi harus pakai negation as failure. |
| 4 Prolog | Query nomor 14 | Jawabannya `?- perlu_bimbingan(NIM), nilai_akhir(NIM, Nilai), Nilai < 60.` `nilai_akhir` dipanggil lagi supaya nilainya ikut ter-binding dan bisa dibandingkan dengan 60. |
| 2 Object oriented | Komentar `// Nilai tertinggi -> terendah` | Di dokumen komentar ini memakai karakter panah unicode. Diganti jadi `->` biasa supaya seluruh berkas tetap ASCII dan tidak bermasalah waktu dipindah antar editor. Ini cuma komentar, tidak mengubah jalannya program. |
| 4 Prolog | Predikat `demo` dan `demo_pengamatan` (BAGIAN 6 dan 7) | Tambahan sendiri, bukan bagian yang dikosongkan dosen. Dipakai supaya keluaran ke-14 query bisa direkam ke berkas, karena toplevel SWI-Prolog susah dipakai kalau inputnya dialihkan dari berkas. Semua fakta dan rule dosen tidak disentuh. |

Berkas tambahan di `kode/eksperimen/` juga buatan sendiri. Isinya potongan kecil
untuk menjawab baris tabel pengamatan yang menyuruh "coba lakukan X", misalnya
memakai `i` setelah blok `for`. Tiga di antaranya memang sengaja gagal
dikompilasi karena itulah yang ditanyakan.

### Status kompilasi dan eksekusi

| Program | Kompilasi | Eksekusi | Keluaran |
|---|---|---|---|
| 1 Imperative | Berhasil, tanpa warning | Berhasil, input dari `kode/program1-imperative/input-demo.txt` | `hasil/program1.txt` |
| 2 Object oriented | Berhasil, tanpa warning | Berhasil, input dari `kode/program2-oo/input-demo.txt` | `hasil/program2.txt` |
| 3 Haskell | Berhasil, `runghc` maupun `ghc` sama hasilnya | Berhasil | `hasil/program3.txt` |
| 4 Prolog | Berhasil dimuat tanpa warning | Berhasil, `demo` dan `demo_pengamatan` | `hasil/program4.txt`, `hasil/program4-pengamatan.txt` |

Hasil utamanya sama di keempat program. Nilai tertinggi Maya 24013 dengan 94.50,
terendah Putra 24016 dengan 57.40, rata-rata kelas 77.80667, dan ada 10 mahasiswa
yang dapat A.

---

## Program 1 Paradigma Imperative

### Tabel 2. Hasil pengamatan Program 1

| Aspek | Pengamatan spesifik | Jawaban |
|---|---|---|
| Binding | Identifikasi kapan `i` pertama kali memperoleh nilai. Identifikasi kapan `mahasiswa[i].nilaiAkhir` memperoleh nilai. | `i` memperoleh nilai saat bagian inisialisasi `int i = 0` dijalankan, yaitu sekali setiap kali loop dimasuki. Kalau fungsinya dipanggil lagi, `i` dibuat dan diberi nilai lagi dari awal. `mahasiswa[i].nilaiAkhir` baru memperoleh nilai hasil hitungan di dalam `hitungNilai()`. Sebelum itu isinya 0.00, terlihat di `hasil/eksperimen.txt` bagian [1]: Andi 0.00 dan Maya 0.00, lalu di bagian [2] berubah jadi 82.50 dan 94.50. Nilai 0.00 itu datang dari aggregate initialization yang cuma diisi lima anggota, anggota keenam otomatis dinolkan. |
| Binding | Perhatikan apakah nilai `nilaiAkhir` dapat diubah lagi setelah assignment pertama. | Bisa. Bindingnya mutable, yang terikat ke nama itu lokasi memori, bukan nilai tetap. Buktinya di `hasil/eksperimen.txt` bagian [6]: `sortNilai()` dipanggil dulu waktu semua nilai masih 0.00, lalu `hitungNilai()` menimpa isinya jadi 57.40, 94.50, dan 82.50. `sortNilai()` sendiri juga menimpa `nilaiAkhir` setiap kali menukar dua elemen. |
| Scope | Coba gunakan `i` setelah blok `for`. Apa yang terjadi? | Gagal dikompilasi. Dicoba di `kode/eksperimen/p1-scope.cpp`, g++ menjawab `error: use of undeclared identifier 'i'` di baris 18. `i` dideklarasikan di bagian inisialisasi `for`, jadi scopenya cuma header dan body loop itu. Begitu keluar kurung kurawal, namanya tidak dikenal lagi. |
| Scope | Coba gunakan variabel lokal di dalam fungsi `hitungNilai()` dari `main()`. Apa yang terjadi? | Gagal dikompilasi juga. Di berkas yang sama, variabel `penghitung` milik `hitungNilai()` dipakai dari `main()` dan g++ menjawab `error: use of undeclared identifier 'penghitung'` di baris 19. Scope variabel lokal berhenti di kurung kurawal fungsinya, fungsi lain tidak bisa melihat namanya. |
| Lifetime | Tambahkan `int temp;` di dalam blok `if`. Amati kapan variabel tersebut dapat digunakan. | `temp` cuma hidup dari baris deklarasinya sampai blok `if` ditutup. Di `kode/eksperimen/p1-lifetime.cpp`, di dalam blok nilainya tercetak normal, begitu dipakai di luar blok g++ menjawab `error: use of undeclared identifier 'temp'`. Di `sortNilai()` hal yang sama terjadi: `Mahasiswa temp` dibuat ulang setiap kali kondisi `if` benar, lalu dibuang lagi begitu blok selesai. |
| Lifetime | Bandingkan variabel lokal fungsi dengan array `mahasiswa`. Mana yang hidup lebih lama? | Array `mahasiswa` yang hidup lebih lama. Dia dideklarasikan di `main()` jadi umurnya selama `main()` berjalan, sedangkan `i`, `j`, dan `temp` di `sortNilai()` lahir dan mati berkali-kali selama fungsi itu jalan. Buktinya array yang sama masih bisa dipakai `menuFilter()` sampai program mau selesai, sedangkan `temp` sudah tidak ada namanya begitu blok `if` lewat. |
| State | Catat nilai `nilaiAkhir` sebelum dan sesudah `hitungNilai()`. | Dari `hasil/eksperimen.txt`: sebelum, `mahasiswa[0]` Andi 0.00 dan `mahasiswa[12]` Maya 0.00. Sesudah, Andi 82.50 dan Maya 94.50. Isinya berubah padahal variabelnya itu-itu juga, jadi yang berubah state objeknya, bukan objek baru. |
| State | Catat posisi dua mahasiswa sebelum dan sesudah `sortNilai()`. | Sebelum sort, Andi 24001 ada di indeks 0 dan Maya 24013 di indeks 12. Sesudah sort, Andi pindah ke indeks 10 dan Maya ke indeks 0. Array yang sama, isinya yang digeser. `sortNilai()` juga tidak mengembalikan apa-apa, jadi satu-satunya efek yang terlihat memang perubahan state array itu. |
| Execution | Tentukan urutan eksekusi: inisialisasi, kondisi, body, increment. | Urutannya inisialisasi sekali di awal, lalu kondisi, kalau benar body, lalu increment, lalu balik ke kondisi lagi. Loop berhenti waktu kondisi salah dan body untuk iterasi itu tidak dijalankan. Di `hasil/eksperimen.txt` bagian [5] untuk `for (int i = 0; i < 3; i++)` body jalan dengan i = 0, 1, dan 2, lalu pada i = 3 kondisi `3 < 3` salah sehingga body tidak dicetak. |
| Execution | Identifikasi statement yang menyebabkan perubahan state. | Ada dua tempat. Pertama assignment `mahasiswa[i].nilaiAkhir = ...` di `hitungNilai()`. Kedua tiga assignment tukar posisi di `sortNilai()`, yaitu `temp = mahasiswa[j]`, `mahasiswa[j] = mahasiswa[j+1]`, dan `mahasiswa[j+1] = temp`. Selain itu `i++`, `j++`, dan `cin >> pilihan` juga mengubah state, tapi cuma state variabel lokal dan bukan data mahasiswanya. Statement `cout` tidak mengubah state data sama sekali. |
| Abstraction | Identifikasi fungsi yang digunakan untuk menyembunyikan detail operasi, misalnya `hitungNilai()` dan `sortNilai()`. | `hitungNilai()` menyembunyikan bobot 30, 30, 40 sehingga `main()` cukup tahu "hitung nilainya" tanpa tahu rumusnya. `sortNilai()` menyembunyikan bubble sort dengan dua loop bersarang dan variabel `temp`. `tampilkanMahasiswa()` menyembunyikan `setw` dan `setprecision`. Fungsi search yang saya tambah juga begitu, `menuFilter()` tidak perlu tahu pencariannya linear. Yang bocor dari abstraksi ini: ketiganya mengubah array yang dioper, jadi pemanggil tetap harus tahu bahwa datanya berubah. |

### Pertanyaan Pengayaan Program 1

**1. Jika nilai `nilaiAkhir` dihitung ulang setelah nilai UAS berubah, bagian program mana yang harus dieksekusi kembali? Mengapa?**

`hitungNilai()` harus dipanggil lagi, lalu `sortNilai()` juga, baru tampilannya
dicetak ulang. Alasannya `nilaiAkhir` disimpan sebagai data, bukan dihitung
tiap kali dibutuhkan. Jadi kalau `uas` berubah tapi `hitungNilai()` tidak
dipanggil, `nilaiAkhir` masih memegang angka lama dan seluruh program ikut
salah. `sortNilai()` juga harus diulang karena urutannya dibuat berdasarkan
nilai lama. Ini yang biasa disebut data turunan tidak sinkron dengan data
sumbernya.

**2. Apa yang terjadi jika variabel `nilaiAkhir` dibuat sebagai variabel lokal di dalam fungsi `hitungNilai()` dibandingkan sebagai atribut dari setiap mahasiswa?**

Kalau jadi variabel lokal, dia mati begitu `hitungNilai()` selesai, jadi
`sortNilai()`, `tampilkanMahasiswa()`, dan `searchNilai()` tidak punya nilai
untuk dibandingkan. Efeknya nilainya harus dihitung ulang di setiap fungsi yang
butuh, dan rumus 30/30/40 tersebar di banyak tempat. Sebagai atribut, nilainya
hidup selama array hidup dan cukup dihitung sekali, tapi risikonya jadi bisa
basi seperti jawaban nomor 1.

**3. Mengapa perubahan urutan dua statement berikut dapat menghasilkan state yang berbeda? `hitungNilai(); sortNilai();` dan `sortNilai(); hitungNilai();`**

Karena `sortNilai()` membaca `nilaiAkhir` untuk menentukan urutan, sedangkan
`hitungNilai()` yang mengisinya. Kalau sort duluan, yang dibandingkan masih
0.00 semua sehingga tidak ada penukaran yang berarti, baru setelah itu nilainya
diisi ke posisi yang sudah salah. Saya coba di `kode/eksperimen/p1-state.cpp`
bagian [6] dengan tiga data: hasilnya indeks 0 Putra 57.40, indeks 1 Maya 94.50,
indeks 2 Andi 82.50, jelas tidak terurut. Bandingkan dengan urutan yang benar di
`hasil/program1.txt` yang diawali Maya 94.50. Jadi di paradigma imperative
urutan statement ikut menentukan hasil, karena tiap statement bekerja di atas
state yang ditinggalkan statement sebelumnya.

**4. Pada Bubble Sort, mengapa diperlukan variabel sementara `temp`? Apa hubungan penggunaan `temp` dengan konsep mutable state?**

Karena penukaran dilakukan dengan menimpa isi kotak. Begitu
`mahasiswa[j] = mahasiswa[j+1]` dijalankan, isi lama `mahasiswa[j]` hilang, jadi
harus disalin dulu ke `temp`. Kalau tidak, dua elemen jadi kembar. Ini murni
akibat mutable state: yang dipindahkan adalah isi lokasi memori, bukan membuat
list baru. Di Haskell masalah ini tidak ada karena `sortBy` menghasilkan list
baru, tidak menimpa apa-apa.

**5. Jika `i` pada `for` memiliki scope lokal, bagaimana programmer dapat mengakses hasil iterasi setelah loop selesai?**

Datanya harus disimpan di variabel yang scopenya lebih luas, dideklarasikan
sebelum loop. Cara lain, `i` dideklarasikan di luar `for` lalu loopnya ditulis
`for (i = 0; i < n; i++)`, tapi ini bikin `i` hidup lebih lama dari yang perlu
dan gampang kepakai tidak sengaja. Pola yang saya pakai di `searchNIM()` dan
`searchNilai()` adalah membuat variabel `ketemu` sebelum loop, lalu menambahnya
di dalam loop. Hasilnya terlihat di `hasil/program1.txt` sebagai baris
`Jumlah data: 15` yang dicetak setelah loop selesai.

**6. Apa risiko jika sebuah fungsi mengubah array `mahasiswa` secara langsung dibandingkan jika fungsi hanya mengembalikan hasil baru?**

Risikonya data aslinya hilang dan semua bagian program lain ikut terpengaruh
tanpa diberi tahu. Setelah `sortNilai()`, urutan asli sesuai NIM tidak bisa
dikembalikan lagi karena tidak ada salinannya. Fungsi yang mengembalikan hasil
baru lebih aman, data awal tetap utuh dan bisa dipakai untuk keperluan lain,
tapi butuh memori lebih banyak. Program 3 memakai cara ini, di
`hasil/eksperimen.txt` bagian [3] dan [6] terlihat list awalnya tetap empat
elemen dengan urutan yang sama walaupun sudah difilter dan disort.

**7. Bagaimana perubahan state memengaruhi debugging? Misalnya, jika nilai mahasiswa berubah secara tidak terduga, informasi apa yang perlu dilacak?**

Debugging jadi susah karena melihat kode saja tidak cukup, harus tahu juga
statement mana yang sudah jalan sebelumnya. Yang perlu dilacak: fungsi apa saja
yang menerima array itu, urutan pemanggilannya, indeks yang disentuh, dan nilai
variabel sebelum serta sesudah tiap fungsi. Cara paling sederhana yang saya
pakai ya seperti di eksperimen, cetak nilainya sebelum dan sesudah tiap fungsi.
Contohnya indeks Andi berubah dari 0 jadi 10 setelah `sortNilai()`, kalau tidak
sadar itu terjadi dan kita masih memakai indeks 0 untuk mengambil Andi, datanya
sudah salah tapi program tetap jalan tanpa error.

**8. Jika program semakin besar dan banyak fungsi dapat mengubah data mahasiswa, apa konsekuensinya terhadap pemeliharaan program?**

Setiap kali ada bug, semua fungsi yang bisa menyentuh data itu jadi tersangka,
jadi waktu mencarinya naik terus seiring jumlah fungsi. Menambah fungsi baru
juga berisiko karena bisa merusak asumsi fungsi lama, misalnya fungsi lama
menganggap array sudah terurut. Urutan pemanggilan di `main()` jadi bagian dari
aturan program yang tidak tertulis di mana pun. Program 2 mengurangi masalah ini
dengan `private` dan getter, Program 3 mengurangi dengan tidak mengubah data
sama sekali.

---

## Program 2 Paradigma Object Oriented

### Tabel 3. Hasil pengamatan Program 2

| Aspek | Pengamatan spesifik | Jawaban |
|---|---|---|
| Binding | Kapan objek `m` dikaitkan dengan instance `Mahasiswa`? | Saat `new Mahasiswa(...)` dijalankan. Operator `new` mengalokasikan memori, constructor mengisinya, lalu alamatnya dikembalikan dan diikat ke pointer `m`. Di `main()` hal ini terjadi 30 kali, satu untuk tiap baris `sistem.tambahMahasiswa(new Mahasiswa(...))`. Bindingnya terjadi saat runtime, bukan saat kompilasi, karena alamatnya baru diketahui waktu program jalan. Di `hasil/eksperimen.txt` bagian [1] terlihat alamatnya memang beda beda: objek 0 di 0x104a118f0, objek 12 di 0x104a130c0, objek 29 di 0x104a13500. |
| Binding | Kapan atribut `nim`, `nama`, dan `nilaiAkhir` memperoleh nilai? | `nim` dan `nama` memperoleh nilai di baris `this->nim = nim;` dan `this->nama = nama;` di dalam constructor. `nilaiAkhir` sedikit belakangan, yaitu waktu constructor memanggil `hitungNilai()` di baris terakhirnya. Jadi ketiganya sudah terisi sebelum objeknya dipakai siapa pun, beda dengan Program 1 yang `nilaiAkhir`-nya sempat 0.00. |
| Binding | Identifikasi method yang dipanggil melalui objek `m`. | Yang dipanggil lewat objek di program ini: `hitungNilai()` dari dalam constructor, lalu `getNIM()`, `getNama()`, dan `getNilai()` dari `filterNIM()`, `filterNama()`, `filterNilai()`, dan `sortNilai()`, serta `tampilkan()` dari `tampilkanSemua()` dan ketiga filter. Semuanya diakses lewat pointer pakai `->`, misalnya `mahasiswa[i]->getNilai()`. |
| Scope | Apakah `nim` dapat diakses langsung dari `main()`? Mengapa? | Tidak bisa. Dicoba di `kode/eksperimen/p2-scope.cpp` dan g++ menjawab `error: 'nim' is a private member of 'Mahasiswa'` ditambah catatan `declared private here`. Karena `nim` ada di bagian `private`, namanya cuma kelihatan dari dalam kelas itu sendiri. Untuk mengambilnya dari luar harus lewat `getNIM()`. |
| Scope | Apakah `getNilai()` dapat dipanggil dari `main()`? | Bisa, karena `getNilai()` ada di bagian `public`. Di berkas eksperimen yang sama, baris `cout << m.getNilai()` tidak dipermasalahkan g++, yang error cuma baris `m.nim` di bawahnya. Jadi satu kelas bisa punya anggota yang scopenya beda beda tergantung labelnya. |
| Lifetime | Kapan objek `m` dibuat? | Waktu `new Mahasiswa(...)` dijalankan, satu per satu sesuai urutan baris di `main()`. Objeknya ada di heap, jadi tetap hidup walaupun ekspresi yang membuatnya sudah selesai. Di `hasil/eksperimen.txt` bagian [3] sampai [5] terlihat baris `constructor objek 99001`, `constructor objek 99002`, dan `constructor objek 99003` muncul tepat saat objeknya dibuat. |
| Lifetime | Kapan objek `m` dihancurkan? | Di program dosen objeknya tidak pernah dihancurkan sampai program berakhir, karena tidak ada `delete` sama sekali. Ini kebocoran memori, cuma tidak kelihatan karena programnya pendek. Di eksperimen saya tambahkan destructor yang mencetak pesan. Hasilnya: objek stack `99001` mencetak `destructor objek 99001` tepat saat keluar blok, objek `99002` yang dibuat dengan `new` tanpa `delete` tidak pernah mencetak apa apa, dan objek `99003` baru mencetak destructornya setelah `delete` dipanggil. Ke-30 objek di program asli nasibnya sama dengan `99002`. |
| State | Atribut apa yang berubah ketika `hitungNilai()` dipanggil? | Cuma `nilaiAkhir`. Method itu membaca `tugas`, `uts`, dan `uas` tapi tidak menulis ke ketiganya. Dibuktikan di `hasil/eksperimen.txt` bagian [2]: setelah `setUAS(50)` dan `hitungNilai()` dipanggil pada objek indeks 12, nilainya turun dari 94.50 jadi 76.10 sedangkan nim dan namanya tetap. |
| State | Apakah dua objek `Mahasiswa` mempunyai state yang sama? | Tidak, masing masing punya state sendiri. Buktinya di eksperimen yang sama: setelah UAS objek indeks 12 diubah jadi 50, objek 0 tetap 82.50 dan objek 29 tetap 90.00, cuma objek 12 yang berubah jadi 76.10. Alamat ketiganya juga berbeda. Yang dipakai bersama cuma kode methodnya, datanya terpisah tiap objek. |
| Encapsulation | Apa yang terjadi jika `private` diubah menjadi `public`? | Programnya tetap jalan dan hasilnya sama, tapi `main()` jadi bisa menulis `m->nilaiAkhir = 100;` tanpa lewat `hitungNilai()`. Akibatnya `nilaiAkhir` bisa tidak cocok lagi dengan `tugas`, `uts`, dan `uas`, dan aturan bobot 30/30/40 tidak lagi dijamin kelas. Yang hilang bukan kemampuan, tapi jaminan. Dengan `private`, satu satunya jalan mengisi `nilaiAkhir` adalah lewat `hitungNilai()`, jadi datanya tidak mungkin tidak konsisten. |
| Execution | Ketika `m.hitungNilai()` dipanggil, objek mana yang menjadi target operasi? | Objek yang ada di sebelah kiri titik atau panah, yaitu objek yang alamatnya dikirim diam diam sebagai `this`. Waktu `daftar[12]->hitungNilai()` dipanggil di eksperimen, cuma objek indeks 12 yang berubah, dua objek lain tidak tersentuh. Jadi satu kode method bisa bekerja pada 30 objek berbeda, yang membedakan cuma `this`. |
| Abstraction | Detail perhitungan mana yang disembunyikan di dalam method? | Rumus `0.30 * tugas + 0.30 * uts + 0.40 * uas` disembunyikan di `hitungNilai()`, dan pemanggilnya bahkan tidak perlu tahu kapan method ini dipanggil karena constructor sudah mengurusnya. `tampilkan()` menyembunyikan format `setw` dan `setprecision`. `sortNilai()` dan ketiga filter menyembunyikan loop dan perbandingannya dari `main()`, sehingga `main()` cuma berisi urutan langkah tingkat tinggi. |

### Pertanyaan Pengayaan Program 2

**1. Apa yang terjadi terhadap state objek `Mahasiswa` setelah method `hitungNilai()` dipanggil?**

Atribut `nilaiAkhir` objek itu terisi atau tertimpa dengan hasil hitungan
terbaru, atribut lain tidak berubah. Kalau `tugas`, `uts`, dan `uas` belum
berubah sejak panggilan sebelumnya, hasilnya sama persis sehingga seolah tidak
terjadi apa apa. Kalau salah satunya sudah berubah, barulah kelihatan. Di
eksperimen, setelah `setUAS(50)` diikuti `hitungNilai()`, state objek indeks 12
berubah dari 94.50 jadi 76.10. Objeknya tetap objek yang sama, alamatnya juga
sama, cuma isinya yang diperbarui.

**2. Mengapa atribut `nilaiAkhir` lebih tepat ditempatkan sebagai bagian dari objek `Mahasiswa` daripada sebagai variabel global?**

Karena nilai akhir itu milik satu mahasiswa tertentu, bukan milik program. Kalau
jadi variabel global, 30 mahasiswa berebut satu kotak yang sama dan cuma nilai
terakhir yang tersimpan, padahal `sortNilai()` butuh membandingkan 30 nilai
sekaligus. Selain itu variabel global bisa diubah dari mana saja sehingga susah
dilacak kalau salah. Sebagai atribut, tiap objek punya salinannya sendiri di
alamat masing masing, terbukti dari tiga alamat berbeda di eksperimen bagian [1].

**3. Apa konsekuensi jika seluruh atribut `private` atau `public` terhadap encapsulation?**

Kalau semuanya `private`, data benar benar terlindungi tapi dari luar tidak ada
yang bisa dibaca sama sekali, jadi tetap butuh getter supaya kelas lain bisa
memakainya. Buktinya `sortNilai()` dan ketiga filter di `SistemAkademik` semua
lewat `getNIM()`, `getNama()`, dan `getNilai()`. Kalau semuanya `public`,
encapsulationnya hilang: kelas tidak bisa lagi menjamin `nilaiAkhir` sesuai
rumus, dan kalau suatu saat rumusnya diganti, semua kode di luar yang menyentuh
atribut langsung harus ikut diperiksa. Yang wajar ya campuran seperti kode
dosen, data `private` dan operasi `public`.

**4. Jika terdapat 30 objek `Mahasiswa`, apakah masing-masing objek memiliki state sendiri? Buktikan melalui eksperimen.**

Punya. Eksperimennya ada di `kode/eksperimen/p2-state.cpp`, hasilnya di
`hasil/eksperimen.txt` bagian [1] dan [2]. Tiga puluh objek dibuat, lalu alamat
dan nilainya dicetak: objek 0 di 0x104a118f0 nilai 82.50, objek 12 di
0x104a130c0 nilai 94.50, objek 29 di 0x104a13500 nilai 90.00. Alamat berbeda
berarti memorinya terpisah. Setelah itu cuma objek 12 yang UAS-nya diubah jadi
50 lalu dihitung ulang. Hasilnya objek 0 tetap 82.50, objek 29 tetap 90.00, dan
objek 12 berubah jadi 76.10. Kalau statenya dipakai bersama, ketiganya pasti
ikut berubah.

**5. Apa yang terjadi terhadap atribut sebuah objek ketika objek tersebut keluar dari scope?**

Untuk objek yang dibuat biasa tanpa `new`, begitu keluar blok destructornya
dipanggil dan memorinya dilepas, jadi atributnya ikut hilang. Terlihat di
`hasil/eksperimen.txt` bagian [3], baris `destructor objek 99001` muncul persis
setelah blok ditutup dan sebelum baris `sudah keluar blok`. Untuk objek hasil
`new`, yang keluar scope cuma pointernya, objeknya sendiri masih di heap dan
atributnya masih ada. Kalau pointernya satu satunya jalan menuju objek itu,
objeknya jadi tidak bisa dijangkau tapi memorinya tetap terpakai, itu memory
leak.

**6. Bandingkan lifetime `Mahasiswa m(...);` dan `Mahasiswa* m = new Mahasiswa(...);`**

`Mahasiswa m(...)` disimpan di stack, umurnya mengikuti blok tempatnya
dideklarasikan, dihancurkan otomatis dan urutannya kebalikan dari urutan
pembuatan. `Mahasiswa* m = new Mahasiswa(...)` disimpan di heap, umurnya
ditentukan programmer dan baru berakhir kalau `delete` dipanggil. Di eksperimen
bagian [4] objek `99002` dibuat dengan `new` tanpa `delete` dan destructornya
memang tidak pernah muncul di keluaran, sedangkan bagian [5] objek `99003`
dihapus dengan `delete` dan baris `destructor objek 99003` langsung muncul.
Program dosen memakai `new` karena `SistemAkademik` menyimpan pointer, jadi
objeknya harus tetap hidup setelah baris pembuatannya lewat. Konsekuensinya
harus ada `delete` atau destructor di `SistemAkademik`, dan itu belum ada.

---

## Program 3 Paradigma Functional dengan Haskell

### Tabel 4. Hasil pengamatan Program 3

| Aspek | Pengamatan spesifik | Jawaban |
|---|---|---|
| Binding | Kapan parameter `m` memperoleh sebuah nilai mahasiswa? | Waktu fungsinya dipakai pada satu elemen. Di `filter (\m -> nilaiAkhir m >= batas) daftar`, `m` terikat ke elemen pertama, dievaluasi, lalu terikat lagi ke elemen kedua, begitu seterusnya. Karena Haskell malas, bindingnya baru benar benar terjadi saat hasilnya dibutuhkan, misalnya waktu `mapM_ tampilkan` mencetaknya. Bindingnya sekali pakai per elemen, bukan satu variabel yang ditimpa 30 kali. |
| Binding | Apakah terdapat assignment ulang terhadap `m`? | Tidak ada, dan memang tidak bisa. Di seluruh `program3.hs` tidak ada satu pun tanda `=` yang berperan sebagai penimpaan nilai. Tanda `=` di Haskell artinya definisi, bukan assignment. Sekali `m` terikat ke satu mahasiswa, ikatan itu tidak berubah sampai evaluasinya selesai. |
| Scope | Di mana `m` pada lambda `\m -> ...` dapat digunakan? | Hanya di badan lambda itu, yaitu bagian setelah tanda panah sampai akhir ekspresinya. Di `filterNilai` yang saya tulis, `m` cuma dipakai di `nilaiAkhir m >= batas`. Di luar itu namanya tidak dikenal. |
| Scope | Apakah `m` dapat digunakan di luar lambda? | Tidak. Dicoba di `kode/eksperimen/p3-scope.hs` dan GHC menjawab `error: [GHC-88464] Variable not in scope: m :: Mahasiswa`. Jadi sama seperti `i` pada `for` di Program 1, hanya saja alasannya lebih rapi: lambda membuat scope baru dan tidak ada variabel yang bocor keluar. |
| Lifetime | Kapan binding `m` dibutuhkan selama evaluasi filter? | Cuma selama satu elemen sedang diperiksa. Begitu predikatnya menghasilkan `True` atau `False`, binding itu tidak dipakai lagi dan yang berikutnya dibuat untuk elemen selanjutnya. Jadi ada 30 binding `m` yang umurnya pendek pendek, bukan satu binding yang hidup panjang. Karena evaluasinya malas, binding untuk elemen yang hasilnya tidak pernah dipakai bahkan tidak perlu dibuat sama sekali. |
| State | Bandingkan list mahasiswa sebelum dan sesudah filter. Apakah data awal berubah? | Tidak berubah. Di `hasil/eksperimen.txt` bagian [1] list awalnya `["24001","24013","24016","24006"]` dengan panjang 4. Setelah difilter, bagian [2] menghasilkan `["24001","24013"]`. Lalu bagian [3] mencetak list awal lagi dan isinya masih `["24001","24013","24016","24006"]` dengan panjang tetap 4. Hal yang sama berlaku untuk sort di bagian [6]: hasil sortnya `["24013","24001","24006","24016"]` tapi list asalnya tetap urut seperti semula. |
| State | Apakah `nilaiAkhir m` mengubah objek mahasiswa? | Tidak. Fungsi itu cuma membaca `tugas m`, `uts m`, dan `uas m` lalu mengembalikan satu `Float`. Di `hasil/eksperimen.txt` bagian [4], `nilaiAkhir maya` dipanggil dua kali dan keduanya 94.5, lalu `uas maya` dicek dan masih 96.0. Bandingkan dengan Program 1 dan 2 yang menyimpan hasilnya ke dalam data. |
| Evaluation | Identifikasi fungsi yang dievaluasi dalam ekspresi map/filter/fold. | Di `semuaNilai = map nilaiAkhir`, yang dievaluasi `nilaiAkhir` untuk tiap elemen. Di `filterNilai batas = filter (\m -> nilaiAkhir m >= batas)`, yang dievaluasi lambdanya, dan di dalamnya `nilaiAkhir` serta operator `>=`. Di `totalNilai`, yang dievaluasi lambda dua parameter `\m total -> nilaiAkhir m + total` bersama `foldr`. Di `sortNilai`, `comparing nilaiAkhir` dievaluasi setiap kali dua elemen dibandingkan. Semuanya baru dievaluasi kalau hasilnya dipakai, misalnya `print (rataRata mahasiswa)` yang memaksa seluruh rantai perhitungan dijalankan dan menghasilkan 77.80667. |
| Transformation | Tentukan input dan output dari `map nilaiAkhir mahasiswa`. | Inputnya `[Mahasiswa]` berisi 30 elemen, outputnya `[Float]` berisi 30 elemen juga. Hasil lengkapnya ada di `hasil/program3.txt` bagian `=== SEMUA NILAI AKHIR ===`, dimulai `[82.5,75.0,90.5,64.5,...]`. Urutannya persis mengikuti urutan list aslinya, bukan urutan terbesar, karena `map` tidak menyusun ulang apa apa. Tipenya berubah dari record jadi angka, jumlah elemennya tetap. |
| Higher-order function | Identifikasi fungsi yang menerima fungsi sebagai argumen. | `map` menerima `nilaiAkhir`, `filter` menerima lambda, `foldr` menerima lambda dua parameter, `sortBy` menerima fungsi pembanding, dan `mapM_` menerima `tampilkan`. Ada juga `comparing` yang menerima `nilaiAkhir` lalu mengembalikan fungsi pembanding, dan `flip` yang menerima fungsi pembanding itu lalu mengembalikan versi terbaliknya. Jadi `flip (comparing nilaiAkhir)` menerima sekaligus mengembalikan fungsi. |
| Immutability | Cari statement yang mengubah nilai mahasiswa. Apakah ada? | Tidak ada satu pun. Di seluruh berkas tidak ada operasi yang menulis ke data yang sudah ada. Semua fungsi menghasilkan nilai baru: `nilaiAkhir` menghasilkan `Float` baru, `filter` dan `sortNilai` menghasilkan list baru, `map` menghasilkan list baru. Bahkan tidak ada sintaks untuk menulis ulang `uas m`, yang ada cuma membuat record baru. Karena itu di Program 3 tidak dibutuhkan variabel `temp` seperti di bubble sort Program 1. |
| Composition | Amati hasil jika filter dikombinasikan dengan map. | Dicoba di `hasil/eksperimen.txt` bagian [5] dengan `map nilaiAkhir (filter (\m -> nilaiAkhir m >= 80) daftar)` dan hasilnya `[82.5,94.5]`. Yang terjadi: filter memilih dulu, baru map mengubah tipenya, jadi outputnya list angka bukan list mahasiswa. Yang menarik urutannya ikut list asal, bukan terbesar, karena tidak ada sort di rantai itu. Kalau urutannya dibalik jadi filter setelah map, tipenya tidak cocok lagi karena `nilaiAkhir` butuh `Mahasiswa` sedangkan hasil map sudah `Float`. Jadi komposisi di Haskell dibatasi tipe, bukan dibatasi state seperti di Program 1. |

### Pertanyaan Pengayaan Program 3

**1. Mengapa `nilaiAkhir m` tidak perlu mengubah data mahasiswa untuk menghasilkan nilai akhir?**

Karena nilai akhir bisa dihitung ulang kapan saja dari `tugas`, `uts`, dan `uas`
yang sudah ada. Menyimpannya ke dalam data cuma ada gunanya kalau kita mau
menghemat perhitungan, dan itu justru bikin data bisa basi seperti di Program 1.
Di Haskell nilai akhir diperlakukan sebagai fungsi dari data, bukan sebagai
bagian data. Perhatikan `data Mahasiswa` di Program 3 memang tidak punya field
`nilaiAkhir`, beda dengan `struct Mahasiswa` di Program 1.

**2. Apa perbedaan antara `nilaiAkhir m` dan `m.nilaiAkhir = ...`?**

`nilaiAkhir m` adalah pemanggilan fungsi yang menghasilkan nilai baru dan tidak
menyentuh `m`. `m.nilaiAkhir = ...` adalah assignment yang menimpa isi memori
milik `m`. Yang pertama bisa dipanggil sepuluh kali tanpa efek samping apa pun,
yang kedua meninggalkan jejak permanen dan urutannya terhadap statement lain
jadi penting. Yang pertama menjawab pertanyaan, yang kedua mengubah dunia.

**3. Jika fungsi `nilaiAkhir` dipanggil dua kali dengan mahasiswa yang sama, apakah hasilnya selalu sama? Mengapa?**

Selalu sama. Diuji di `hasil/eksperimen.txt` bagian [4], `nilaiAkhir maya`
dipanggil dua kali dan keduanya mencetak 94.5. Alasannya fungsi itu murni,
hasilnya cuma bergantung pada argumen dan tidak ada yang bisa mengubah argumen
itu di antara dua panggilan. Ini yang disebut referential transparency:
`nilaiAkhir maya` boleh diganti langsung dengan 94.5 di mana pun tanpa mengubah
arti program. Di Program 1 jaminan seperti ini tidak ada, karena `mahasiswa[12].nilaiAkhir`
bisa saja sudah diubah fungsi lain di antara dua pembacaan.

**4. Bagaimana immutability dapat mengurangi risiko perubahan data yang tidak terduga?**

Karena tidak ada operasi yang bisa mengubah data, sumber perubahan yang tidak
terduga hilang dengan sendirinya. Kalau sebuah list isinya `["24001","24013","24016","24006"]`,
dia akan tetap begitu sampai kapan pun, tidak peduli fungsi apa yang dilewatinya.
Waktu debugging kita cukup melihat definisi fungsinya, tidak perlu melacak
urutan pemanggilan seperti yang harus dilakukan di Program 1. Kerugiannya boros
memori karena tiap operasi bikin struktur baru, walaupun sebenarnya Haskell
banyak berbagi bagian yang tidak berubah.

**5. Apakah tidak adanya assignment ulang berarti program tidak melakukan komputasi? Jelaskan!**

Bukan berarti begitu. Program 3 tetap menghitung 30 nilai akhir, mengurutkannya,
memfilter 15 mahasiswa dengan nilai di atas 80, dan menghitung rata rata
77.80667, semuanya terlihat di `hasil/program3.txt`. Bedanya komputasi dilakukan
dengan menghasilkan nilai baru dari nilai lama, bukan dengan menimpa kotak yang
sudah ada. Jadi assignment ulang itu salah satu cara berkomputasi, bukan
satu satunya. Di paradigma imperative program maju dengan mengubah state, di
paradigma functional program maju dengan menyusun dan mengevaluasi ekspresi.

### Catatan tambahan Program 3

Waktu dijalankan, beberapa nilai tercetak sebagai 92.600006, 87.700005,
91.600006, 86.600006, dan 66.100006. Ini bukan salah rumus, tapi karena tipenya
`Float` yang cuma 32 bit sehingga angka seperti 0.30 tidak bisa disimpan persis
dalam biner, lalu `show` mencetak apa adanya. Program 1 dan 2 sebenarnya
menyimpan galat yang mirip, cuma tidak kelihatan karena `setprecision(2)`
membulatkan tampilannya jadi 92.60 dan 87.70. Kalau mau lebih tepat, tipenya
bisa diganti `Double` atau tampilannya diformat dulu. Hal ini tidak mengubah
urutan sort maupun grade, jadi kodenya saya biarkan seperti aslinya.

---

## Program 4 Logic Programming dengan SWI-Prolog

### Tabel 5. Hasil pengamatan Program 4

| Aspek | Pengamatan spesifik | Jawaban |
|---|---|---|
| Binding | Jalankan `mahasiswa("24013", Nama, Tugas, UTS, UAS).` Catat binding setiap variabel. | Hasilnya di `hasil/program4-pengamatan.txt`: `Nama = Maya`, `Tugas = 95`, `UTS = 92`, `UAS = 96`. Keempatnya memperoleh nilai sekaligus saat query berhasil diunifikasikan dengan fakta `mahasiswa("24013", "Maya", 95, 92, 96)`. Argumen pertama sudah terisi sejak awal sehingga berfungsi sebagai penyaring, empat sisanya kosong dan justru diisi oleh faktanya. Cuma ada satu solusi karena cuma ada satu fakta dengan NIM itu. |
| Binding | Jalankan `grade(NIM,a).` Identifikasi kapan `NIM` memperoleh nilai. | `NIM` masih kosong waktu query dikirim. Dia baru terisi jauh di dalam, waktu `nilai_akhir(NIM, Nilai)` memanggil `mahasiswa(NIM, _, Tugas, UTS, UAS)` dan berhasil diunifikasikan dengan sebuah fakta. Jadi bindingnya berjalan dari dalam ke luar: fakta mengisi `NIM` dan ketiga komponen nilai, `Nilai` dihitung dengan `is`, baru dibandingkan dengan 85. Kalau perbandingannya gagal, binding itu dibatalkan dan dicoba fakta berikutnya. |
| Scope | Bandingkan variabel `NIM` pada `nilai_akhir/2` dan `grade/2`. Apakah keduanya merupakan variabel yang sama? | Bukan. Keduanya kebetulan dieja sama, tapi scope variabel di Prolog sebatas satu klausa. `NIM` di badan `grade/2` adalah variabel milik klausa `grade`, sedangkan `NIM` di kepala `nilai_akhir/2` milik klausa `nilai_akhir`. Keduanya terhubung bukan karena namanya sama, tapi karena diunifikasikan saat pemanggilan. Kalau `NIM` di `grade` diganti jadi `X` semuanya, programnya tetap jalan sama persis. |
| Scope | Amati scope `NIM` di dalam satu rule. | Di dalam satu klausa, satu nama variabel berarti satu variabel yang sama, mulai dari kepala sampai titik penutup. Di `aman(NIM) :- lulus(NIM), nilai_akhir(NIM, Nilai), Nilai >= 75.` ketiga `NIM` itu satu variabel, jadi begitu `lulus(NIM)` mengisinya, `nilai_akhir` langsung memakai nilai yang sama. Inilah yang bikin rule bisa menyaring, kalau namanya beda semua hasilnya jadi salah. |
| Lifetime | Jalankan `grade(NIM,a)` lalu tekan `;`. Amati perubahan solusi/binding. | Binding cuma hidup selama satu solusi. Begitu ditekan `;`, Prolog membatalkan binding terakhir lalu mencari fakta berikutnya yang cocok. Urutan solusinya terekam di `hasil/program4-pengamatan.txt`: solusi ke-1 sampai ke-10 berturut turut 24003, 24005, 24008, 24011, 24013, 24019, 24021, 24024, 24026, dan 24030, total 10 solusi. Jadi tidak ada satu variabel `NIM` yang ditimpa sepuluh kali, yang ada sepuluh binding pendek yang dipasang lalu dilepas. |
| Backtracking | Catat binding solusi pertama dan solusi berikutnya. | Solusi pertama `NIM = "24003"` yaitu Citra dengan nilai 90.5, solusi kedua `NIM = "24005"` yaitu Eka dengan nilai 87.7. Urutannya mengikuti urutan fakta di berkas, bukan urutan nilai dari besar ke kecil, karena Prolog mencoba fakta dari atas ke bawah. Ini beda dengan `hasil/program1.txt` yang hasilnya sudah diurutkan berdasarkan nilai. |
| State | Apakah fakta `mahasiswa(...)` berubah setelah query? | Tidak. Diuji dengan `aggregate_all(count, mahasiswa(_,_,_,_,_), Jumlah)` sebelum dan sesudah query, hasilnya sama sama 30 seperti terlihat di `hasil/program4-pengamatan.txt`. Query di Prolog cuma bertanya, tidak menulis. Fakta baru berubah kalau kita memakai `assert` atau `retract`, dan keduanya tidak dipakai di program ini. |
| Execution | Apakah Prolog menjalankan statement dari atas ke bawah seperti imperative? | Tidak sama. Prolog memang mencoba klausa dari atas ke bawah dan goal dalam satu badan dari kiri ke kanan, jadi sekilas mirip. Bedanya kalau sebuah goal gagal, Prolog tidak berhenti melainkan mundur ke titik pilihan terakhir dan mencoba kemungkinan lain, sesuatu yang tidak ada di C++. Selain itu tidak ada urutan statement yang mengubah state, jadi menukar `lulus(NIM)` dan `nilai_akhir(NIM, Nilai)` di `aman/1` tidak mengubah hasil, cuma jalur pencariannya. Bandingkan dengan Program 1 yang hasilnya berubah total kalau `hitungNilai()` dan `sortNilai()` ditukar. |
| Inference | Telusuri bagaimana `grade(NIM,a)` dapat diperoleh dari `mahasiswa` melalui `nilai_akhir`. | Penelusuran untuk 24013 saya cetak di `hasil/program4-pengamatan.txt`: fakta `mahasiswa("24013", _, 95, 92, 96)` ditemukan, rule 1 menghitung `nilai_akhir("24013", 94.50)`, lalu rule 3 mengecek 94.50 >= 85 dan terpenuhi sehingga `grade("24013", a)` benar. Yang penting di sini tidak ada satu pun fakta yang menuliskan bahwa Maya dapat A, kesimpulan itu diturunkan dari fakta mentah lewat dua rule. |
| Unification | Identifikasi pasangan term/variabel yang berhasil disatukan. | Pada query `mahasiswa(NIM, "Maya", Tugas, UTS, UAS)` hasilnya `NIM = "24013"`, `Tugas = 95`, `UTS = 92`, `UAS = 96`. Yang disatukan: variabel kosong `NIM` dengan konstanta `"24013"`, konstanta `"Maya"` dengan konstanta `"Maya"` yang kebetulan sama sehingga cocok, lalu tiga variabel sisanya dengan tiga angka. Kalau argumen kedua diisi `"Mayaa"`, unifikasinya gagal dan semua binding dibatalkan. Simbol `_` di `nilai_akhir` juga bentuk unifikasi, cocok dengan apa saja tapi nilainya tidak disimpan. |
| Search | Amati bagaimana Prolog mencari solusi lain setelah `;`. | Prolog kembali ke titik pilihan terakhir, yaitu fakta `mahasiswa` mana yang tadi dipakai, lalu melanjutkan dari fakta sesudahnya. Buktinya urutan solusi `perlu_bimbingan(NIM)` di `hasil/program4-pengamatan.txt` adalah 24004, 24006, 24009, 24016, 24027, persis urutan faktanya di berkas dan bukan urutan nilai. Jadi pencariannya depth first dengan backtracking. Kalau sudah tidak ada fakta tersisa, query berhenti dan menjawab false. |
| Abstraction | Tentukan rule mana yang merepresentasikan pengetahuan domain. | Hampir semua rule di BAGIAN 2. `nilai_akhir/2` memuat aturan bobot 30/30/40, `lulus/1` memuat batas kelulusan 60, `grade/2` memuat lima batas grade, dan `perlu_bimbingan/1`, `unggul/1`, `aman/1`, serta `nilai_tinggi/1` memuat kebijakan akademik lain. Rule seperti `sangat_baik/1` dan `mahasiswa_prioritas/1` tidak menambah pengetahuan baru, cuma memberi nama lain untuk rule yang sudah ada. Bagusnya di Prolog pengetahuan ini ditulis sekali sebagai aturan, dan pertanyaan apa pun tinggal disusun dari aturan itu tanpa perlu menulis langkah pencariannya. |

### Pertanyaan Pengayaan Program 4

**1. Apa perbedaan antara `mahasiswa("24013", "Maya", 95, 92, 96).` dan `nilai_akhir(NIM, Nilai) :- ...` dalam hal pengetahuan yang direpresentasikan?**

Yang pertama fakta, yaitu pengetahuan yang langsung benar tanpa syarat dan harus
ditulis satu per satu untuk 30 mahasiswa. Yang kedua rule, yaitu pengetahuan
bersyarat yang berlaku untuk semua NIM sekaligus. Fakta menyimpan data mentah,
rule menyimpan cara menurunkan informasi baru dari data itu. Karena rule ditulis
sekali, kalau bobotnya berubah dari 30/30/40 jadi 20/30/50 cukup satu baris yang
disunting dan semua kesimpulan ikut berubah, termasuk `grade`, `lulus`, dan
`berprestasi`.

**2. Pada query `?- mahasiswa(NIM, "Maya", Tugas, UTS, UAS).` variabel mana saja yang memperoleh binding?**

Empat variabel: `NIM`, `Tugas`, `UTS`, dan `UAS`. Hasilnya terekam di
`hasil/program4-pengamatan.txt` sebagai `NIM = "24013"`, `Tugas = 95`,
`UTS = 92`, `UAS = 96`. Argumen kedua `"Maya"` bukan variabel melainkan
konstanta, jadi dia tidak memperoleh binding tapi bertugas menyaring fakta mana
yang boleh cocok. Ini menunjukkan predikat yang sama bisa dipakai dua arah:
NIM dicari dari nama, atau nama dicari dari NIM, tanpa menulis dua fungsi
berbeda seperti `searchNIM` dan `searchNama` di Program 1 dan 3.

**3. Mengapa `NIM` pada dua rule berikut tidak berarti variabel yang sama? `nilai_akhir(NIM, Nilai) :- ...` dan `grade(NIM, a) :- ...`**

Karena scope variabel di Prolog sebatas satu klausa, dari kepala sampai titik
penutupnya. Nama `NIM` di dua klausa berbeda adalah dua variabel berbeda yang
kebetulan dieja sama, mirip parameter `x` di dua fungsi berbeda di C++. Mereka
baru terhubung saat `grade` memanggil `nilai_akhir` dan argumennya
diunifikasikan. Buktinya kalau seluruh `NIM` di klausa `grade` diganti jadi `X`,
program tetap memberi sepuluh solusi yang sama.

**4. Apa yang terjadi terhadap binding ketika mahasiswa menekan `;` setelah memperoleh satu solusi?**

Binding solusi sebelumnya dibatalkan seluruhnya, lalu Prolog mundur ke titik
pilihan terakhir dan mencoba kemungkinan berikutnya. Jadi bukan binding lama
ditimpa nilai baru, tapi benar benar dilepas dulu baru dipasang yang baru.
Terlihat dari urutan solusi `grade(NIM, a)` di `hasil/program4-pengamatan.txt`
yang berpindah dari 24003 ke 24005 lalu ke 24008 dan seterusnya sampai 24030.
Kalau sudah tidak ada kemungkinan tersisa, Prolog menjawab false.

**5. Mengapa Prolog dapat menghasilkan beberapa solusi dari `?- grade(NIM, a).`?**

Karena `NIM` dikirim dalam keadaan kosong, jadi Prolog boleh mencoba semua 30
fakta `mahasiswa`. Setiap fakta yang lolos syarat `Nilai >= 85` menjadi satu
solusi. Ada 10 fakta yang lolos, yaitu 24003, 24005, 24008, 24011, 24013, 24019,
24021, 24024, 24026, dan 24030. Angka 10 ini cocok dengan jumlah mahasiswa
bergrade A di `hasil/program3.txt`. Dengan kata lain query ini sekaligus jadi
pencarian, tanpa kita perlu menulis loop seperti di `searchNilai()` pada
Program 1.

### Sintaks query nomor 13 dan 14

**Nomor 13, mahasiswa yang lulus tetapi tidak mendapat A:**

```prolog
?- lulus(NIM), \+ grade(NIM, a).
```

Cara kerjanya `lulus(NIM)` dijalankan dulu supaya `NIM` terisi, baru
`\+ grade(NIM, a)` mengecek bahwa goal itu gagal. Urutannya tidak boleh dibalik,
karena `\+ grade(NIM, a)` dengan `NIM` masih kosong akan langsung gagal begitu
ditemukan satu mahasiswa bergrade A, dan hasilnya jadi salah. Hasilnya 18 NIM,
terekam di `hasil/program4.txt`: 24001, 24002, 24004, 24007, 24009, 24010,
24012, 24014, 24015, 24017, 24018, 24020, 24022, 24023, 24025, 24027, 24028, dan
24029. Angkanya cocok, dari 30 mahasiswa ada 2 yang tidak lulus yaitu Fajar 59.2
dan Putra 57.4, lalu 28 dikurangi 10 yang dapat A sama dengan 18.

**Nomor 14, mahasiswa yang perlu bimbingan dan nilainya di bawah 60:**

```prolog
?- perlu_bimbingan(NIM), nilai_akhir(NIM, Nilai), Nilai < 60.
```

`nilai_akhir` dipanggil lagi supaya `Nilai` ikut ter-binding dan bisa
dibandingkan dengan 60, karena `perlu_bimbingan/1` cuma mengembalikan NIM tanpa
nilainya. Hasilnya 2 mahasiswa, terekam di `hasil/program4.txt`: 24006 Fajar
dengan 59.20 dan 24016 Putra dengan 57.40. Masuk akal, `perlu_bimbingan`
batasnya di bawah 65 dan menghasilkan 5 orang, setelah disaring lagi di bawah 60
tersisa 2 orang. Ini contoh query yang lebih ketat daripada rulenya sendiri, dan
kita tidak perlu membuat rule baru untuk itu.

---

## Lesson Learned Program 1 sampai Program 4

**Yang paling kelihatan, keempat program menjawab persoalan yang sama persis
tapi cara berpikirnya beda beda.** Nilai tertinggi Maya 94.50, terendah Putra
57.40, rata rata 77.80667, dan 10 mahasiswa bergrade A, angka ini sama di
keempatnya. Yang berbeda bukan hasilnya, tapi apa yang harus saya tulis untuk
sampai ke situ. Di Program 1 saya menulis langkahnya, di Program 2 saya menulis
siapa yang bertanggung jawab atas apa, di Program 3 saya menulis transformasinya,
di Program 4 saya menulis aturannya lalu tinggal bertanya.

**Program 1 mengajarkan bahwa urutan statement itu bagian dari kebenaran
program.** Waktu saya coba menukar `hitungNilai()` dan `sortNilai()` hasilnya
langsung kacau, indeks 0 malah diisi Putra dengan nilai 57.40. Kodenya tidak
error, compilernya diam saja, programnya jalan normal, tapi jawabannya salah.
Dari sini saya paham kenapa scope dan lifetime penting dipelajari: variabel yang
hidup terlalu lama seperti array `mahasiswa` bisa diubah siapa saja, sedangkan
`temp` yang hidup cuma satu blok jauh lebih aman. Saya juga sempat kaget waktu
`nilaiAkhir` ternyata 0.00 sebelum `hitungNilai()` dipanggil, ternyata itu
karena aggregate initialization cuma diisi lima anggota.

**Program 2 mengajarkan bahwa encapsulation itu soal menjaga aturan, bukan soal
menyembunyikan.** Waktu saya coba akses `m.nim` dari `main()` dan g++ menolak,
awalnya terasa merepotkan. Tapi setelah lihat bahwa `nilaiAkhir` cuma bisa diisi
lewat `hitungNilai()`, saya paham maksudnya: kelas menjamin datanya selalu
konsisten dengan rumus. Bandingkan dengan Program 1 yang siapa saja bisa menulis
`mahasiswa[0].nilaiAkhir = 100;` dan tidak ada yang mencegah. Pelajaran lain
soal lifetime: destructor yang saya tambahkan menunjukkan objek `new` tanpa
`delete` benar benar tidak pernah dihancurkan, dan kode dosen punya 30 objek
seperti itu. Punya kendali penuh atas umur objek artinya juga punya kewajiban
membereskannya.

**Program 3 mengajarkan bahwa banyak masalah di Program 1 hilang sendiri kalau
datanya tidak bisa diubah.** Tidak ada `temp` karena tidak ada penukaran, tidak
ada data basi karena nilai akhir dihitung saat dibutuhkan, tidak ada urutan
pemanggilan yang harus dihafal karena tidak ada state yang ditinggalkan. Waktu
saya cetak list awal sebelum dan sesudah filter dan sort, isinya tetap sama
persis, padahal di Program 1 posisi Andi sudah pindah dari indeks 0 ke 10.
Yang bikin saya agak kaget, di Haskell error justru datang lebih awal: waktu
`searchNIM` belum saya tulis, GHC langsung menolak dengan `Variable not in scope`
sebelum programnya sempat jalan. Saya juga belajar soal presisi `Float` dari
angka 92.600006 yang muncul di keluaran, sesuatu yang di Program 1 tertutup
`setprecision(2)` sehingga saya tidak pernah sadar galatnya juga ada di sana.

**Program 4 mengajarkan bahwa kita bisa menulis pengetahuan tanpa menulis cara
mencarinya.** Ini yang paling beda dari tiga program sebelumnya. Di Program 1
saya harus membuat loop, variabel `ketemu`, dan pengecekan manual untuk
`searchNilai()`. Di Prolog cukup menulis `nilai_tinggi(NIM) :- nilai_akhir(NIM,
Nilai), Nilai >= 80.` lalu bertanya, dan mesin yang mengurus pencariannya lewat
unifikasi dan backtracking. Waktu mengerjakan query nomor 13 saya baru paham
kenapa urutan goal tetap penting: `\+ grade(NIM, a)` harus ditaruh setelah
`lulus(NIM)` supaya `NIM` sudah terisi, kalau dibalik hasilnya salah. Jadi
Prolog memang deklaratif, tapi tidak berarti urutan sama sekali tidak
berpengaruh. Satu hal lagi, predikat `mahasiswa/5` bisa dipakai dua arah, cari
nama dari NIM atau cari NIM dari nama, tanpa menulis dua fungsi terpisah seperti
`searchNIM` dan `searchNama` yang harus saya tulis dua kali di Program 1 dan 3.

**Kesimpulan buat saya sendiri:** tidak ada paradigma yang menang di semua
keadaan. Program 1 paling dekat dengan cara kerja mesin dan paling gampang
diprediksi performanya, tapi paling gampang salah kalau programnya membesar.
Program 2 merapikan Program 1 dengan membatasi siapa yang boleh menyentuh data,
harganya kode jadi lebih panjang dan urusan memori jadi tanggung jawab kita.
Program 3 paling aman dari bug yang berhubungan dengan state dan paling enak
diuji karena fungsinya bisa dipanggil berkali kali dengan hasil yang sama, tapi
butuh waktu untuk terbiasa berpikir tanpa variabel. Program 4 paling singkat
untuk soal yang bentuknya pencarian dan penalaran, tapi tidak cocok untuk hal
yang butuh langkah berurutan. Yang menarik, konsep binding, scope, lifetime, dan
state ternyata ada di keempatnya, cuma wujudnya beda: di C++ berupa alamat
memori yang bisa ditimpa, di Haskell berupa ikatan sekali pakai, di Prolog
berupa binding yang dipasang dan dilepas mengikuti backtracking.
