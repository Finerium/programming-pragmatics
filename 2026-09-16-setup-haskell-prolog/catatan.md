# Setup Haskell dan SWI-Prolog

Permintaan Pak Joe Lian Min lewat grup WhatsApp, Rabu 16 September 2026:

1. Install environment Haskell untuk perkuliahan minggu ini.
2. Coba materi di https://learnyouahaskell.github.io/introduction.html
3. Install SWI-Prolog dari https://www.swi-prolog.org/download/stable

Dua bahasa ini mewakili dua paradigma yang dibahas di Programming Pragmatics: Haskell untuk paradigma
fungsional dan Prolog untuk paradigma logika.

## Yang terpasang

| Alat | Versi | Cara install | Letak |
|---|---|---|---|
| GHC (compiler + `ghci`) | 9.10.3 | ghcup | `~/.ghcup/bin/ghc` |
| cabal | 3.18.1.0 | ghcup | `~/.ghcup/bin/cabal` |
| SWI-Prolog | 10.0.2 | installer resmi (.dmg) | `/Applications/SWI-Prolog.app`, perintah `swipl` |

Catatan install di MacBook (Apple Silicon, macOS 26.5):

- Homebrew tidak dipakai karena `brew install` gagal mengunduh portable Ruby dari ghcr.io.
- Skrip `get-ghcup.haskell.org` juga sempat gagal karena unduhan besar sering terputus, jadi berkas
  `ghcup`, bindist GHC, dan cabal diunduh manual dengan `curl -C -` (lanjut dari byte terakhir), lalu
  dipasang dengan `ghcup install ghc --url file://...`.
- SWI-Prolog dipasang dari berkas `swipl-10.0.2-1.fat.dmg`, aplikasinya disalin ke `/Applications`,
  lalu dibuat symlink `swipl` di `/opt/homebrew/bin` supaya bisa dipanggil dari terminal.
- PATH Haskell dipasang lewat baris `. "$HOME/.ghcup/env"` di `~/.zshrc`. Kalau terminal sudah terbuka
  sebelum install, jalankan `source ~/.ghcup/env` dulu atau buka terminal baru.

Cek cepat kalau semuanya sudah benar:

```
ghc --version      # The Glorious Glasgow Haskell Compilation System, version 9.10.3
ghci --version
cabal --version
swipl --version    # SWI-Prolog version 10.0.2 for fat-darwin
```

## Cara menjalankan latihan

```
# Haskell, mode interaktif
ghci latihan-haskell/baby.hs
ghci> doubleUs 4 9
ghci> :q

# Haskell, langsung jalan sebagai program
runghc latihan-haskell/latihan.hs

# Prolog, sekali jalan
swipl -q -f latihan-prolog/keluarga.pl -g uji -t halt

# Prolog, mode interaktif
swipl latihan-prolog/keluarga.pl
?- saudara(ani, X).
?- halt.
```

Hasil eksekusi disimpan di `hasil/`: `output-haskell.txt`, `sesi-ghci.txt`, dan `output-prolog.txt`.

## Isi latihan

- `latihan-haskell/baby.hs`: fungsi dasar dari bab Starting Out (`doubleMe`, `doubleUs`,
  `doubleSmallNumber`), list comprehension `boomBangs`, dan `rightTriangles`.
- `latihan-haskell/latihan.hs`: versi program utuh yang mencetak hasil operasi list, range, tuple,
  `zip`, pattern matching (`faktorial`), dan guard (`nilaiHuruf`).
- `latihan-prolog/keluarga.pl`: fakta keluarga, aturan `orangtua`, `saudara`, `kakek`, `keturunan`
  yang rekursif, plus `faktorial` untuk membandingkan rekursi di Prolog dan Haskell.

## Catatan dari percobaan

- **`if` di Haskell wajib punya `else`.** Di Haskell `if` adalah ekspresi yang harus menghasilkan nilai,
  bukan pernyataan seperti di Java atau Python, jadi cabang `else` tidak boleh hilang.
- **GHC 9.10 memperingatkan pemakaian `head`.** Peringatannya `[GHC-63394] [-Wx-partial]`, karena `head`
  adalah partial function yang error kalau listnya kosong. Contoh di Learn You a Haskell masih memakainya,
  tetapi versi amannya `Data.List.uncons` atau pattern matching.
- **`findall` di Prolog bisa memberi hasil dobel.** Query saudara Ani menghasilkan `[cici,cici]` karena
  cici ketemu dua kali, lewat ayah dan lewat ibu. Dipakai `setof` supaya hasilnya unik dan terurut.
- **Rekursi terlihat mirip di kedua bahasa.** `faktorial` di Haskell ditulis dengan pattern matching
  (`faktorial 0 = 1`), di Prolog ditulis sebagai dua klausa fakta dan aturan. Bedanya, Prolog tidak
  mengembalikan nilai, hasilnya diikat ke variabel lewat unifikasi.
