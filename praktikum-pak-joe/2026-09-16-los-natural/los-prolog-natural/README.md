# los-prolog-natural

Loan Originating System ditulis ulang di SWI-Prolog 10.0.2 tanpa mengikuti bentuk
versi Haskell. Aturan bisnisnya sama dengan `los-haskell` (skor minimum 620,
DTI maksimum 0.43, pokok maksimum Rp2 miliar, bunga dasar 6.25, kuota harian Rp1 miliar,
tiga pemohon Budi, Siti, Andi), yang beda cuma cara menyusunnya.

## Cara menjalankan

```bash
swipl demo.pl     # demo, cetak hasil semua query
swipl tes.pl      # 34 tes plunit
```

Yang paling enak sebenarnya tanya sendiri di REPL:

```
$ swipl los.pl
?- layak(Siapa).
?- pengajuan(siti, S), melanggar(S, Aturan).
?- pengajuan(siti, S), batas_skor_disetujui(S, Skor).
?- between(300, 850, S), premi_risiko(S, 0.5).
```

## Rancangan

Cuma tiga berkas. `los.pl` isinya basis pengetahuan, `demo.pl` tinggal mencetak
hasil query, `tes.pl` plunit. Isi `los.pl` dibagi tiga lapis: fakta, aturan yang
menurunkan sesuatu dari fakta, dan state hari yang memang berubah.

### Fakta

`bank/2` untuk profil bank (`bank(bunga_dasar, 6.25)`), `batas/2` untuk ambang
aturan underwriting, dan `pengajuan/2` untuk daftar pemohon. Ambang dipisah jadi
fakta supaya bisa ditanya dan diganti tanpa menyentuh aturannya.

Data pengajuan dipakai dict SWI-Prolog, bukan term posisional:

```prolog
pengajuan(budi, pengajuan{pokok: 200_000_000, tenor: 24, skor: 680,
                          cicilan_lain: 3_000_000, pendapatan: 12_000_000}).
```

Alasannya dua. Pertama, aturan tinggal menulis `P.skor < Min`, tidak perlu
`loan(_, _, _, Skor, _, _)` yang harus dihitung posisinya. Kedua, skenario
"bagaimana kalau skornya 640" cukup `P.put(skor, 640)`, dan itu yang dipakai
untuk query generate and test di bagian akhir.

### Aturan underwriting sebagai klausa berkepala sama

```prolog
melanggar(P, skor_minimum)   :- batas(skor_minimum, Min),    P.skor < Min.
melanggar(P, dti_maksimum)   :- batas(dti_maksimum, Maks),   dti(P, D), D > Maks.
melanggar(P, pokok_maksimum) :- batas(pokok_maksimum, Maks), P.pokok > Maks.

lolos_underwriting(P) :- \+ melanggar(P, _).
```

Karena semua aturan berkepala `melanggar/2`, pertanyaan "aturan mana saja yang
dilanggar" itu `findall(A, melanggar(P, A), As)`, dan "lolos" artinya tidak ada
satu pun pelanggaran yang bisa dibuktikan. Menambah aturan baru berarti menambah
satu klausa, tidak ada daftar yang harus diperbarui.

`keputusan/2` juga tiga klausa (ditolak, perlu dokumen, disetujui) dengan syarat
yang saling lepas, jadi tidak pakai cut. Ini penting karena `keputusan/2` dipanggil
dari dalam `between/3` waktu mencari batas skor.

### Kegagalan sebagai mekanisme normal

`proses/2` gagal kalau pengajuannya cacat, tidak mengembalikan `error(...)`.
Kalau mau tahu kenapa, tanya `cacat/2`, dan semua cacat bisa dienumerasi
sekaligus. Pola yang sama dipakai untuk `underwrite/2` dan `hambatan/2`.
Di `demo.pl` bentuknya:

```prolog
(   proses(Cacat, K)
->  format("  diproses: ~w~n", [K])
;   findall(C, cacat(Cacat, C), SemuaCacat),
    format("  proses/2 gagal. Cacatnya: ~w~n", [SemuaCacat])
)
```

### State bank: predikat dinamis di dalam transaction/1

Kuota tersisa dan jurnal disimpan sebagai fakta dinamis (`kuota_tersisa/1`,
`jurnal/1`) yang diubah pakai `assertz` dan `retract`. Ini cara yang lazim di
SWI-Prolog untuk state yang memang berubah. Supaya tidak ada keadaan setengah
jadi, seluruh badan `underwrite/2` dibungkus `transaction/1`: kalau ada goal di
dalamnya yang gagal atau melempar exception, semua assert dan retract dibatalkan.
Ada tes khusus untuk ini, `kegagalan_di_tengah_transaksi_dibatalkan`, yang memotong
kuota lalu sengaja `fail`, dan kuotanya kembali utuh.

Saya sempat mempertimbangkan DCG untuk mengalirkan state, tapi itu justru mirip
pasangan StateIn/StateOut yang mau dihindari. Predikat dinamis lebih jujur:
kuota bank memang satu, dan memang berubah.

### Query yang enak di Prolog

Bagian 7 demo memperlihatkan query yang di Haskell atau Java butuh loop tersendiri:

| Query | Cara |
|---|---|
| Siapa saja yang layak | `layak(N)` backtracking atas fakta pengajuan |
| Semua aturan yang dilanggar | `findall/3` atas `melanggar/2` |
| Skor terendah supaya Siti disetujui (650) | `between/3` + `aggregate_all(min)` atas `keputusan(P.put(skor, S), disetujui(_, _))` |
| Pokok terbesar supaya Andi disetujui (Rp2 miliar) | sama, `between/3` kelipatan 100 juta + `aggregate_all(max)` |
| Skor berapa saja yang kena premi 1.5 (600 sampai 699) | membalik tabel `premi_risiko/2` dengan `between/3` |
| Total pokok yang disetujui hari ini | `aggregate_all(sum)` |

## Kenapa ini beda dengan versi terjemahan (los-prolog)

| Di los-prolog (terjemahan) | Di sini | Alasan |
|---|---|---|
| `ok(X)` / `error(Msg)` meniru Either | predikat gagal, alasan ditanya lewat `cacat/2` atau `hambatan/2` | kegagalan itu mekanisme bawaan Prolog, tidak perlu dibungkus |
| aturan sebagai lambda `library(yall)` dalam list, dievaluasi `maplist` + `call` | klausa `melanggar/2` yang dienumerasi backtracking | goal sebagai data lintas modul justru sempat bikin `Unknown procedure` di versi lama |
| state dioper `StateIn`, `StateOut` meniru StateT | `kuota_tersisa/1` dinamis di dalam `transaction/1` | state bank memang satu dan berubah; transaction/1 sudah menjamin batal bersih |
| `loan_app/7` term posisional | dict SWI-Prolog | aturan cuma menyebut field yang dipakai, `put` untuk skenario |
| `decide/2` pakai cut per klausa | syarat eksklusif tanpa cut | aman dipanggil balik dari generate and test |
| tiruan type class `Auditable` lewat `audit_entry/3` multifile | tidak ada | itu peragaan type class Haskell, bukan aturan bisnis; jurnal underwriting tetap ada sebagai `jurnal/1` |
| `which_rules_pass/2` dengan pasangan nama-goal | tidak perlu | nama aturan sudah ada di argumen kedua `melanggar/2` |
| tes property acak meniru QuickCheck | tes contoh tetap + query batas | batas skor 650 dan pokok 2 miliar dicari Prolog sendiri, tidak perlu generator acak |

## Catatan

Plafon per pinjaman Rp500 juta di versi Haskell hanya disimpan di config dan tidak
pernah dicek. Di sini ikut dicek di `hambatan/2`, jadi Andi punya dua hambatan
sekaligus (melebihi plafon dan kuota tidak cukup). Angka lainnya tidak terpengaruh.

"Bunga 1.5%" untuk Budi di keputusan awal: di Haskell itu `annualRate` pemohon yang
nilainya 0 lalu ditambah 1.5. Di sini disebut apa adanya sebagai tambahan bunga
risiko, karena bunga sebenarnya baru dihitung waktu underwriting (7.75%).

Satu tes ditandai `nondet`, karena `penyesuaian_risiko/2` sengaja tiga klausa tanpa
cut supaya bisa ditanya balik, dan itu wajar menyisakan choicepoint.

Hasil: `swipl demo.pl` mencetak DTI 0.25, cicilan Rp9045458, bunga akhir Budi 7.75,
sisa kuota Rp800,000,000. `swipl tes.pl` 34 tes lolos tanpa warning.
