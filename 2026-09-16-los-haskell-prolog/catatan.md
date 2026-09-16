# Rerun los-haskell dan los-prolog

Bahan dari Pak Joe (16 September 2026): `los-haskell.zip`, `los-prolog.zip`, dan
`los-prolog-penjelasan.md`. Pesan beliau: pakai GHC user's guide
(https://downloads.haskell.org/ghc/latest/docs/users_guide/intro.html), utamanya lewat GHCi.

Versi yang dipakai: GHC 9.10.3, cabal 3.18.1.0, SWI-Prolog 10.0.2, macOS 26.5 (Apple Silicon).

Isi zip `los-haskell` berkasnya datar, jadi ditata ulang dulu sesuai `los-haskell.cabal`,
yaitu `src/Lib.hs`, `app/Main.hs`, dan `test/Spec.hs`.

## Hasil rerun berkas asli

| Yang dijalankan | Perintah | Hasil |
|---|---|---|
| Haskell, muat library di GHCi | `ghci -isrc src/Lib.hs` | Jalan, semua fungsi bisa dipanggil |
| Haskell, demo lengkap | `ghci -isrc -iapp app/Main.hs` lalu `:main` | Jalan sampai selesai, bagian 1 sampai 5 keluar semua |
| Haskell, build paket | `cabal build` | **Gagal** |
| Prolog, demo | `swipl -g main -t halt main.pl` | **Berhenti di bagian 4** |
| Prolog, tes | `swipl -g run_tests -t halt spec.pl` | **159 sampai 161 tes gagal**, 589 lolos |

## Temuan 1: `cabal build` gagal walaupun GHCi jalan

```
src/Lib.hs:290:10: error: [GHC-93557]
    Illegal instance declaration for 'Auditable String'
    Suggested fix: Perhaps you intended to use TypeSynonymInstances
```

Penyebabnya `los-haskell.cabal` menulis `default-language: Haskell2010`, sedangkan GHCi dan
`runghc` memakai bawaan GHC 9.x yaitu GHC2021 yang sudah mengaktifkan `FlexibleInstances` dan
`TypeSynonymInstances`. Jadi kode yang sama lolos di GHCi tetapi ditolak lewat cabal.
Perbaikannya satu baris: ganti `default-language` jadi `GHC2021` (atau tambahkan
`default-extensions: FlexibleInstances, TypeSynonymInstances`).

Sesudah diperbaiki, `cabal test` lolos: empat property QuickCheck passed. Satu catatan,
`prop_validateRejectsNonPositivePrincipal` berstatus *Gave up! Passed only 0 tests; 1000
discarded*, artinya generatornya hampir tidak pernah menghasilkan principal <= 0 sehingga
property itu praktis tidak pernah teruji.

## Temuan 2: beberapa predikat tidak diekspor modul `los_lib`

`main.pl` dan `spec.pl` memanggil predikat yang ada di `los_lib.pl` tetapi tidak masuk daftar
ekspor `:- module(los_lib, [...])`, jadi muncul galat `Unknown procedure`:

- `run_underwriting/4` (dipakai `main.pl` bagian 4 dan tes `underwriting_deterministic`)
- `which_rules_pass/2` (dipakai `main.pl` bagian 6)
- `underwriting_rules/1` dan `max_principal/2` (dipakai tes `passes_all_implies_each`)

Kasus `max_principal/2` menarik: aturan di `underwriting_rules/1` berupa lambda
`[App]>>(max_principal(2_000_000_000, App))`. Selama dipanggil dari dalam modul semuanya aman,
tetapi begitu daftar aturan itu dikirim ke `spec.pl` lalu di-`call` dari modul lain, goal-nya
dicari di modul pemanggil sehingga gagal. Jadi kalau goal dipakai sebagai data lintas modul,
predikat yang dipanggil di dalamnya juga harus ikut diekspor.

## Temuan 3: baris aritmetika yang tidak sah di `spec.pl`

```prolog
BadPrincipal is -(random_between(0, 10_000_000, _) -> 1 ; 1),
```

`is/2` hanya menerima ekspresi aritmetika, sedangkan `( -> ; )` itu kontrol. Barisnya melempar
`Arguments are not sufficiently instantiated` sehingga 100 iterasi tes
`validate_rejects_non_positive` gagal semua. Variabel `BadPrincipal` juga tidak pernah dipakai
(SWI sudah memperingatkan *Singleton variables*), jadi barisnya memang bisa dihapus dan nilai
dari `random_between(-10_000_000, 0, BadP)` di baris berikutnya yang dipakai.

## Sesudah tiga perbaikan itu

Berkas asli tidak diubah. Salinan yang sudah diperbaiki ada di `perbaikan/`.

| Yang dijalankan | Hasil |
|---|---|
| `swipl -g main -t halt main.pl` | Jalan sampai bagian 6, tidak ada galat |
| `swipl -g run_tests -t halt spec.pl` | 8 tes (742 sub-tes) lolos |
| `cabal test` (Haskell) | Test suite PASS |

Satu property Prolog, `higher_score_better_rate`, masih kadang gagal sekitar 2 dari 100 kasus
acak dan tidak muncul di setiap run, jadi kelihatannya memang ada kasus batas yang belum cocok
antara aturan `adjust_rate_for_risk` dan bunyi property-nya. Ini justru contoh gunanya
property-based testing dibanding contoh yang dipilih tangan.

## Isi folder

```
los-haskell/      berkas asli dari Pak Joe, ditata ulang jadi src/, app/, test/
los-prolog/       berkas asli dari Pak Joe
perbaikan/        salinan yang sudah diperbaiki (cabal + ekspor modul + spec.pl)
hasil/            keluaran teks tiap perintah
tangkapan/        screenshot terminal tiap perintah
los-hasil-2B-048.zip  isi tangkapan/ dan hasil/ untuk dikirim ke Pak Joe
```
