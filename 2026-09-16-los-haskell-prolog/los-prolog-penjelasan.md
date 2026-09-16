# Belajar Prolog Lewat LOS: Penjelasan `los-prolog` per Potongan Kode

Dokumen ini membedah `los-prolog` (hasil terjemahan `los-haskell`) potongan demi
potongan. Untuk tiap blok kode, ada dua lapis penjelasan:

- **Alur bisnis** — kenapa logika ini ada dari sudut pandang proses pengajuan
  kredit (LOS), supaya konteksnya nyambung ke kerjaan kamu sehari-hari.
- **Konsep Prolog** — mekanisme bahasa yang dipakai, supaya kamu paham *kenapa*
  ditulis begitu, bukan cuma *apa* yang ditulis.

Urutan mengikuti alur proses pengajuan pinjaman yang sebenarnya: mulai dari
data aplikasi masuk → hitung angka-angka dasar → cek aturan kelayakan →
putuskan → beri tahu pemohon → validasi input → proses dengan state bank
(kuota, rate final) → catat ke audit log.

---

## §1 — Data Aplikasi Pinjaman (Domain Types)

```prolog
bank_config(6.25, standard, 500_000_000, 620).
bank_state(1_000_000_000, []).
```

**Alur bisnis:** Ini dua "sumber kebenaran" yang dipakai bank tiap kali
memproses pengajuan:
- `bank_config` = kebijakan bank hari itu: base rate 6.25%, kebijakan
  `standard`, plafon maksimum per pinjaman Rp500 juta, minimum credit score
  620.
- `bank_state` = kondisi operasional yang berubah-ubah: sisa kuota kredit
  yang bisa dikucurkan hari ini (mulai dari Rp1 miliar), dan log audit
  (kosong di awal).

Bedanya penting: **config** itu kebijakan (jarang berubah dalam satu sesi
kerja), **state** itu kondisi yang berubah tiap kali ada pinjaman disetujui
(kuota berkurang, log bertambah).

**Konsep Prolog:** Di Prolog tidak ada `record` atau `struct` bawaan —
representasinya adalah **compound term**: `loan_app(Name, Principal,
AnnualRate, TermMonths, CreditScore, MonthlyDebt, MonthlyIncome)`. Ini murni
data terstruktur, mirip tuple bernama. Urutan argumen jadi "skema"-nya —
makanya di sepanjang kode kamu akan lihat pola `loan_app(_, _, _, _, Score,
_, _)` yang pakai `_` (anonymous variable) untuk field yang tidak relevan di
klausa itu — ini adalah **pattern matching lewat unifikasi**, bukan
`app.getScore()` seperti OOP.

Tiga kemungkinan hasil keputusan juga direpresentasikan sebagai term, bukan
enum/class:
- `approved(Amount, Rate)`
- `rejected(Reason)`
- `pending_review(MissingDocs)`

Di Prolog, "tipe" seperti ini hanya konvensi (tidak dicek compiler), tapi
karena Prolog men-dispatch klausa berdasarkan **functor** (nama + arity),
efeknya mirip pattern matching pada algebraic data type di Haskell.

---

## §2 — Hitung DTI dan Cicilan Bulanan (Pure Calculations)

```prolog
calculate_dti(_, Income, 0) :-
    Income =< 0, !.
calculate_dti(Debt, Income, DTI) :-
    DTI is Debt / Income.
```

**Alur bisnis:** DTI (*Debt-to-Income ratio*) adalah rasio utang terhadap
pendapatan bulanan pemohon — salah satu metrik inti underwriting. Kalau
income pemohon nol atau negatif (data tidak valid / belum diisi), sistem
tidak boleh crash karena divide-by-zero — jadi DTI dianggap 0 sebagai nilai
aman default, bukan error yang menghentikan proses.

**Konsep Prolog:** Ini contoh **relasi, bukan fungsi**. `calculate_dti/3`
punya 3 argumen: dua input (`Debt`, `Income`) dan satu output (`DTI`) yang
di-*bind* saat predikat berhasil. Dua klausa di atas adalah dua "kasus":
1. Kasus `Income =< 0` → langsung unify `DTI` dengan `0`, lalu `!` (**cut**)
   memotong supaya klausa kedua tidak dicoba lagi (mencegah komputasi ganda
   / hasil dobel saat backtrack).
2. Kasus umum → hitung `Debt / Income` beneran.

Cut di sini setara `otherwise`/`else` di Haskell — memastikan hanya satu
klausa yang "menang" untuk kondisi yang saling eksklusif.

```prolog
calculate_monthly_payment(_, _, 0, 0) :- !.
calculate_monthly_payment(P, 0.0, Months, Payment) :- !,
    Payment is P / Months.
calculate_monthly_payment(P, 0, Months, Payment) :- !,
    Payment is P / Months.
calculate_monthly_payment(P, AnnualRatePct, Months, Payment) :-
    R is AnnualRatePct / 12.0 / 100.0,
    N is float(Months),
    Payment is P * R * (1+R)**N / ((1+R)**N - 1).
```

**Alur bisnis:** Ini rumus anuitas standar buat hitung cicilan bulanan (mirip
rumus KPR/KTA). Tiga edge case ditangani eksplisit sebelum rumus umum:
tenor 0 bulan (tidak masuk akal, hasil 0), dan rate 0% (baik ditulis `0.0`
maupun `0` — karena Prolog membedakan tipe angka float vs integer secara
sintaks) → cicilan flat = pokok dibagi tenor, tanpa bunga majemuk.

**Konsep Prolog:** Empat klausa berurutan = empat kasus bisnis, dibaca dari
atas ke bawah seperti guard di Haskell. Tiap klausa yang punya cut (`!`)
"mengunci" pilihan begitu kondisinya cocok, supaya klausa umum di bawahnya
(rumus anuitas penuh) tidak ikut dicoba untuk kasus-kasus khusus itu. Kalau
cut ini dihapus, untuk `Months=0` Prolog akan tetap lanjut mencoba klausa
keempat dan bisa menghasilkan solusi ganda (atau div/0).

---

## §3 — Aturan Underwriting (Business Rules sebagai Klausa)

```prolog
min_credit_score(MinScore, loan_app(_, _, _, _, Score, _, _)) :-
    Score >= MinScore.

max_dti(MaxRatio, loan_app(_, _, _, _, _, Debt, Income)) :-
    calculate_dti(Debt, Income, DTI),
    DTI =< MaxRatio.

max_principal(Max, loan_app(_, Principal, _, _, _, _, _)) :-
    Principal =< Max.
```

**Alur bisnis:** Tiga aturan kelayakan kredit paling dasar — persis yang
biasanya ada di modul underwriting LOS kamu:
1. Skor kredit minimum harus terpenuhi.
2. Rasio utang-pendapatan tidak boleh melebihi ambang (di sini dipakai lewat
   `underwriting_rules` sebagai 0.43 / 43%).
3. Jumlah pinjaman tidak boleh melebihi plafon maksimum.

Masing-masing aturan berdiri sendiri sebagai predikat — kalau bank mau nambah
aturan baru (misal "usia pemohon minimum"), tinggal tambah predikat baru,
tidak perlu ubah yang lama.

**Konsep Prolog:** Tiap "aturan bisnis" adalah **predikat boolean-style**:
berhasil (true) kalau kondisinya terpenuhi, gagal (false) kalau tidak — tidak
ada nilai `true`/`false` eksplisit, keberhasilan/kegagalan predikat itu
sendiri yang jadi sinyalnya. Ini beda dari Haskell yang eksplisit
`Bool`-returning function.

```prolog
:- use_module(library(yall)).

underwriting_rules([
    [App]>>(min_credit_score(620, App)),
    [App]>>(max_dti(0.43, App)),
    [App]>>(max_principal(2_000_000_000, App))
]).
```

**Alur bisnis:** Ini "paket kebijakan underwriting" bank — daftar semua
aturan yang harus dipenuhi pemohon, sudah di-*bind* dengan angka ambang batas
tertentu (skor min 620, DTI maks 43%, plafon maks Rp2 miliar). Ini
memisahkan **definisi aturan** (di atas) dari **konfigurasi ambang batas**
(di sini) — kalau bank mau ubah kebijakan (misal naikkan syarat skor ke 650),
cukup edit list ini.

**Konsep Prolog:** `[App]>>(Goal)` adalah **lambda** dari `library(yall)` —
closure anonim yang menerima `App` dan mengevaluasi `Goal`. Ini padanan
`\rule -> rule app` di Haskell. Listnya sendiri adalah **goals sebagai
data** — setiap elemen bukan nilai biasa, tapi "instruksi yang belum
dijalankan", baru dieksekusi nanti lewat `call/N`. Ini salah satu keunggulan
Prolog: aturan bisnis bisa disimpan, dimanipulasi, di-*inspect* sebagai data
sebelum dieksekusi.

```prolog
passes_all_rules(App) :-
    underwriting_rules(Rules),
    maplist({App}/[Rule]>>(call(Rule, App)), Rules).
```

**Alur bisnis:** Ini gerbang keputusan utama: **pemohon lolos underwriting
kalau dan hanya kalau SEMUA aturan terpenuhi**. Satu saja gagal (skor kurang,
DTI kelebihan, atau pinjaman kelewat besar), pemohon otomatis tidak lolos.

**Konsep Prolog:** `maplist/2` menjalankan goal yang sama untuk tiap elemen
list, dan **berhasil hanya jika semua elemen berhasil** — ini padanan
`all (\rule -> rule app) rules` di Haskell (higher-order function `all`).
`{App}/[Rule]>>(...)` adalah sintaks yall untuk **meng-capture** variabel
`App` dari scope luar ke dalam lambda (mirip closure yang menangkap variabel
eksternal).

```prolog
failing_rules(App, Failing) :-
    underwriting_rules(Rules),
    include({App}/[Rule]>>(\+ call(Rule, App)), Rules, Failing).
```

**Alur bisnis:** Ini fitur yang **kemungkinan besar dibutuhkan tim ops/CS**
kamu: kalau pemohon ditolak, aturan mana spesifiknya yang gagal? Ini yang
biasanya ditampilkan ke pemohon atau dicatat internal ("ditolak karena DTI
dan skor kredit"), bukan cuma status pass/fail generik.

**Konsep Prolog:** `include/3` menyaring list, ambil elemen yang goal-nya
berhasil. `\+ call(Rule, App)` berarti **negation as failure**: "Rule gagal
dibuktikan untuk App". Ini kunci nilai jual Prolog dibanding Haskell —
di Haskell kamu butuh `filter` terpisah yang secara eksplisit membalik
logika `passes_all_rules`; di Prolog, arah query bisa dibalik tanpa nulis
ulang logikanya, cukup ganti bagaimana predikat dipanggil.

---

## §4 — Pipeline Keputusan (Adjust → Decide → Notify)

```prolog
adjust_rate_for_risk(
        loan_app(Name, P, Rate, Term, Score, Debt, Inc),
        loan_app(Name, P, NewRate, Term, Score, Debt, Inc)) :-
    Score < 600, !,
    NewRate is Rate + 3.5.
adjust_rate_for_risk(
        loan_app(Name, P, Rate, Term, Score, Debt, Inc),
        loan_app(Name, P, NewRate, Term, Score, Debt, Inc)) :-
    Score < 700, !,
    NewRate is Rate + 1.5.
adjust_rate_for_risk(App, App).
```

**Alur bisnis:** Ini **risk-based pricing** — pemohon dengan skor kredit
lebih rendah dikenakan bunga lebih tinggi karena risikonya lebih besar bagi
bank:
- Skor < 600 (risiko tinggi) → tambah 3.5% ke rate dasar.
- Skor 600–699 (risiko sedang) → tambah 1.5%.
- Skor ≥ 700 (risiko rendah) → rate tidak berubah.

Ini logika yang sangat umum di sistem kredit nyata: skor kredit bukan cuma
gerbang lolos/tidak, tapi juga menentukan **harga** produk pinjamannya.

**Konsep Prolog:** Perhatikan pola head-nya: argumen pertama `loan_app(Name,
P, Rate, Term, Score, Debt, Inc)` (input) dan argumen kedua `loan_app(Name,
P, NewRate, Term, Score, Debt, Inc)` (output) — **semua field sama kecuali
`Rate`/`NewRate`**. Ini adalah cara Prolog "mengubah satu field" dari sebuah
struct immutable: bukan mutasi, tapi *membuat term baru* yang identik kecuali
satu bagian, lewat unifikasi variabel yang sama (`Name`, `P`, `Term`, dst
dipakai ulang di kedua sisi, jadi otomatis harus sama).

Tiga klausa ini lagi-lagi pattern matching + cut untuk kondisi mutually
exclusive — persis seperti guard `| score < 600 = ... | score < 700 = ... |
otherwise = ...` di Haskell. Klausa terakhir **tanpa cut** karena memang
sudah jadi "kasus sisa" (kalau dua klausa di atas gagal karena `Score < 600`
atau `Score < 700` tidak terpenuhi, otomatis jatuh ke sini).

```prolog
decide(App, rejected("Tidak memenuhi kriteria underwriting")) :-
    \+ passes_all_rules(App), !.
decide(loan_app(_, _, _, _, Score, _, _),
       pending_review(["Slip gaji 3 bulan terakhir"])) :-
    Score < 650, !.
decide(loan_app(_, Principal, Rate, _, _, _, _),
       approved(Principal, Rate)).
```

**Alur bisnis:** Ini **keputusan final** underwriting, dan urutannya
mencerminkan prioritas bisnis:
1. Gagal aturan dasar (§3) → **langsung ditolak**, tidak peduli skornya
   berapa.
2. Kalau lolos aturan dasar tapi skornya masih di bawah 650 (zona abu-abu) →
   **pending review**, minta dokumen tambahan (slip gaji), bukan ditolak
   langsung — bank masih mau kasih kesempatan dengan verifikasi manual.
3. Kalau lolos semua dan skor ≥ 650 → **disetujui** dengan jumlah dan rate
   yang sudah disesuaikan risiko.

Urutan ini penting secara bisnis: `\+ passes_all_rules(App)` dicek **paling
dulu** karena itu aturan keras (hard rule) — DTI kelewat tinggi atau plafon
kelewat besar itu automatic reject, sedangkan skor 650-699 itu soft rule
yang masih bisa dinegosiasikan lewat dokumen tambahan.

**Konsep Prolog:** Tiga klausa = tiga cabang keputusan bisnis yang mutually
exclusive, dijamin lewat cut di klausa 1 dan 2. Ini padanan Algebraic Data
Type + pattern matching Haskell (`data LoanDecision = Approved | Rejected |
PendingReview`), tapi ditulis sebagai relasi: `decide(App, Decision)` bisa
"mengisi" `Decision` untuk `App` tertentu.

```prolog
notify_applicant(approved(Amount, Rate), Msg) :-
    format(atom(Msg), "Selamat! Pinjaman Rp~0f disetujui dengan bunga ~1f%",
           [Amount, Rate]).
notify_applicant(rejected(Why), Msg) :- ...
notify_applicant(pending_review(Docs), Msg) :- ...
```

**Alur bisnis:** Ini lapisan **komunikasi ke pemohon** — mengubah keputusan
teknis (`approved(200000000, 8.0)`) jadi pesan manusiawi yang bisa
dikirim lewat email/SMS/notifikasi app.

**Konsep Prolog:** Dispatch otomatis berdasarkan **functor** argumen
pertama. `notify_applicant(approved(...), Msg)` hanya cocok kalau argumen
pertamanya benar-benar term `approved/2`; kalau `rejected(...)`, Prolog
otomatis pindah ke klausa kedua. Ini "polymorphism gratis" tanpa perlu
`switch`/`instanceof` — padanan pattern matching pada constructor ADT di
Haskell.

```prolog
full_pipeline(App, Message) :-
    adjust_rate_for_risk(App, Adjusted),
    decide(Adjusted, Decision),
    notify_applicant(Decision, Message).
```

**Alur bisnis:** Ini **pipeline end-to-end** satu pengajuan: sesuaikan rate
berdasarkan risiko → putuskan approve/reject/pending → susun pesan ke
pemohon. Tiga langkah ini persis alur yang biasanya terjadi di service layer
LOS kamu (misalnya `RiskAdjustmentService` → `DecisionService` →
`NotificationService`).

**Konsep Prolog:** Tidak ada operator komposisi fungsi (`.` di Haskell), tapi
efek yang sama dicapai lewat **variabel penghubung**: `Adjusted` adalah
output tahap 1 sekaligus input tahap 2, `Decision` output tahap 2 sekaligus
input tahap 3. Prolog "chaining" ini murni lewat unifikasi variabel
berurutan dalam body klausa — mirip `let` binding berantai atau
do-notation di Haskell, tanpa butuh sintaks monadik khusus.

---

## §5 — Validasi Input dengan Pola Either (ok/error)

```prolog
validate_application(loan_app(_, P, _, _, _, _, _), error("Jumlah pinjaman harus positif")) :-
    P =< 0, !.
validate_application(loan_app(_, _, _, Term, _, _, _), error("Tenor harus positif")) :-
    Term =< 0, !.
validate_application(loan_app(_, _, _, _, Score, _, _), error("Skor kredit tidak valid")) :-
    Score < 300, !.
validate_application(App, ok(App)).
```

**Alur bisnis:** Ini **lapisan validasi input** sebelum data pengajuan masuk
ke proses underwriting — beda dari aturan underwriting di §3 (yang menilai
*kelayakan* pemohon), ini menilai *validitas data itu sendiri* (data entry
error, bukan business judgment): jumlah pinjaman negatif/nol, tenor
negatif/nol, atau skor kredit di luar rentang wajar (< 300, di bawah rentang
FICO-style manapun) — semua ini indikasi bug/typo di sisi input, bukan
keputusan kredit.

**Konsep Prolog:** Pola ini adalah **analog `Either` Haskell** tapi tanpa
sistem tipe — direpresentasikan sebagai term `error(Reason)` atau `ok(App)`.
Urutan klausa penting (dicek berurutan, cut mencegah lanjut ke bawah begitu
satu error ditemukan) — ini "short-circuit" validasi: begitu satu masalah
ditemukan, berhenti, tidak perlu cek yang lain dulu (walau di kasus nyata
kamu mungkin mau kumpulkan SEMUA error sekaligus — itu desain trade-off yang
sengaja disederhanakan di sini).

```prolog
process_application(App, Result) :-
    validate_application(App, ValidationResult),
    ( ValidationResult = ok(Valid) ->
        adjust_rate_for_risk(Valid, Adjusted),
        decide(Adjusted, Decision),
        Result = ok(Decision)
    ; Result = ValidationResult
    ).
```

**Alur bisnis:** Ini pipeline yang **lebih aman** dari `full_pipeline/2` di
§4 — sebelum masuk ke adjust/decide, data divalidasi dulu. Kalau validasi
gagal, error itu langsung diteruskan sebagai hasil akhir tanpa buang waktu
proses underwriting untuk data yang jelas rusak.

**Konsep Prolog:** `->` (if-then-else) dipakai di sini, beda dari cut yang
dipakai di §3–4. `( Cond -> Then ; Else )` artinya: kalau `Cond` berhasil,
kerjakan `Then` (dan jangan pernah coba `Else`, bahkan saat backtrack);
kalau `Cond` gagal, kerjakan `Else`. Ini cocok untuk percabangan biner dalam
satu klausa, dibanding pecah jadi beberapa klausa terpisah dengan cut —
trade-off ringkas vs deklaratif yang disebutkan di README (`Catatan
implementasi`).

---

## §6 — Underwriting Stateful (Kuota Bank & Rate Final)

```prolog
underwrite_step_validate(
        loan_app(Name, Principal, _, _, Score, _, _),
        bank_config(_, _, _, MinScore),
        bank_state(Q, Log0),
        bank_state(Q, Log1)) :-
    ( Principal =< 0 ->
        throw(underwriting_error("Jumlah pinjaman harus positif"))
    ; Score < MinScore ->
        format(atom(ErrMsg), "Skor kredit di bawah minimum bank: ~w", [MinScore]),
        throw(underwriting_error(ErrMsg))
    ; true
    ),
    format(atom(LogMsg), "Validasi dasar lolos untuk ~w", [Name]),
    append(Log0, [LogMsg], Log1).
```

**Alur bisnis:** Ini langkah pertama proses underwriting **yang benar-benar
menyentuh state bank** (bukan cuma menghitung dari input): cek dasar
(pinjaman positif, skor memenuhi minimum config bank saat itu), lalu
**mencatat ke audit log** bahwa validasi lolos. Perhatikan: minimum skor di
sini datang dari `Config` (bisa beda-beda per kebijakan bank), bukan
angka hardcoded seperti di §3 — ini titik di mana konfigurasi bank
benar-benar dipakai secara dinamis, bukan cuma aturan tetap.

**Konsep Prolog:** Signature `(App, Config, StateIn, StateOut)` adalah pola
**"threading state"**: state lama (`bank_state(Q, Log0)`) masuk, state baru
(`bank_state(Q, Log1)`) keluar — `Q` (kuota) di sini **tidak berubah**
(argumen sama di kedua sisi), hanya `Log0` → `Log1` yang berubah (nambah satu
baris log lewat `append/3`). Ini padanan **State monad** di Haskell, tapi
tanpa monad — cukup argumen In/Out eksplisit. `throw/1` dipakai untuk
kegagalan validasi — beda dari §3 (yang pakai `\+`/fail biasa) karena di
sini kegagalan harus **membawa pesan error spesifik** yang bisa ditangkap
nanti oleh `catch/3`.

```prolog
underwrite_step_quota(
        loan_app(_, Principal, _, _, _, _, _),
        bank_state(Quota, Log0),
        bank_state(NewQuota, Log1)) :-
    ( Principal > Quota ->
        throw(underwriting_error("Plafon kredit hari ini sudah habis"))
    ; true
    ),
    NewQuota is Quota - Principal,
    format(atom(LogMsg), "Kuota dicadangkan: Rp~0f", [Principal]),
    append(Log0, [LogMsg], Log1).
```

**Alur bisnis:** Ini **pengecekan dan pemotongan kuota harian bank** — bank
punya batas total dana yang bisa dikucurkan per hari (di sini mulai
Rp1 miliar). Kalau pinjaman yang diajukan melebihi sisa kuota, ditolak di
level sistem (bukan di level kelayakan pemohon) — pemohon bisa saja
sebenarnya layak, tapi bank kehabisan dana hari itu. Ini skenario nyata di
LOS: penolakan bisa terjadi bukan karena pemohon, tapi karena kondisi
operasional bank saat itu.

**Konsep Prolog:** Sama seperti step sebelumnya, tapi di sini `Quota` field
memang **berubah** (`Quota` → `NewQuota`, dikurangi `Principal`). Ini
menunjukkan bagaimana "mutasi" state dilakukan tanpa mutasi sungguhan: bukan
`quota -= principal` di tempat, tapi bikin nilai baru dan bind ke variabel
baru.

```prolog
calculate_final_rate(
        loan_app(_, _, _, _, Score, _, _),
        bank_config(Base, Policy, _, _),
        Rate) :-
    ( Score < 600 -> RiskPremium = 3.5
    ; Score < 700 -> RiskPremium = 1.5
    ; RiskPremium = 0.5
    ),
    ( Policy = conservative -> PolicyAdj = 0.5
    ; Policy = aggressive   -> PolicyAdj = -0.5
    ; PolicyAdj = 0.0
    ),
    Rate is Base + RiskPremium + PolicyAdj.
```

**Alur bisnis:** Ini **rate final** yang lebih lengkap dari
`adjust_rate_for_risk/2` di §4 — menggabungkan dua faktor:
1. **Risk premium** dari skor kredit (mirip §4, tapi di sini skor ≥700 tetap
   dapat premium kecil 0.5%, bukan 0 — beda kebijakan dari §4, yang mungkin
   representasi dua model pricing berbeda dalam sistem yang sama).
2. **Policy adjustment** dari kebijakan bank: `conservative` (bank lagi
   hati-hati, naikkan rate +0.5%), `aggressive` (bank lagi agresif cari
   nasabah, turunkan rate -0.5%), atau `standard` (tidak ada penyesuaian).

Ini contoh bagaimana **satu field config** (`Policy`) bisa mengubah hasil
akhir pricing — kalau suatu saat bank switch dari `standard` ke
`aggressive` (misal untuk kejar target akuisisi nasabah kuartal ini), semua
pinjaman baru otomatis dapat rate lebih murah tanpa ubah kode.

**Konsep Prolog:** Nested if-then-else (`->`/`;`) untuk dua keputusan
independen yang lalu digabung jadi satu hasil (`Rate is Base + RiskPremium +
PolicyAdj`). Ini murni kalkulasi (tidak ada state yang diubah), makanya
tidak butuh signature State In/Out seperti dua predikat sebelumnya.

```prolog
underwrite_application(App, Config, State0, Decision, StateOut) :-
    underwrite_step_validate(App, Config, State0, State1),
    underwrite_step_quota(App, State1, State2),
    calculate_final_rate(App, Config, Rate),
    App = loan_app(_, Principal, _, _, _, _, _),
    format(atom(LogMsg), "Disetujui dengan rate ~1f%", [Rate]),
    State2 = bank_state(Q2, Log2),
    append(Log2, [LogMsg], Log3),
    StateOut = bank_state(Q2, Log3),
    Decision = approved(Principal, Rate).
```

**Alur bisnis:** Ini **orkestrasi penuh** proses underwriting versi stateful:
validasi dasar → cek & potong kuota → hitung rate final → catat approval ke
log → hasilkan keputusan `approved`. Beda penting dari `decide/2` di §4:
predikat ini **hanya menghasilkan `approved`** — tidak ada cabang
`rejected`/`pending_review` di sini, karena penolakan ditangani lewat
`throw/1` di step-step sebelumnya (kalau validasi atau kuota gagal, seluruh
predikat ini gagal/throw sebelum sampai baris `Decision = approved(...)`).

Ini pola desain yang umum di sistem finansial nyata: **jalur sukses linear**,
tapi **kegagalan short-circuit lewat exception**, bukan lewat nilai return
kondisional di tiap langkah.

**Konsep Prolog:** Perhatikan bagaimana state di-*thread* berantai:
`State0 → State1 → State2` lewat tiap step, lalu `State2` dipecah lagi jadi
`Q2`/`Log2` untuk ditambah satu log terakhir sebelum jadi `StateOut`. Kalau
`underwrite_step_validate` atau `underwrite_step_quota` throw exception,
**seluruh klausa ini gagal total** — `State0` (kuota awal) tidak pernah
tersentuh sama sekali, karena setiap State1/State2 hanyalah *binding
variabel baru*, bukan mutasi tempat. Ini yang dimaksud README sebagai
"copy semantics" — persis seperti transaksi database yang di-*rollback*
otomatis kalau ada exception di tengah jalan, tapi di sini didapat gratis
dari mekanisme unifikasi Prolog, bukan dari kode transaksi eksplisit.

```prolog
run_underwriting(App, Config, StateIn, Result) :-
    catch(
        ( underwrite_application(App, Config, StateIn, Decision, StateOut),
          Result = ok(Decision, StateOut)
        ),
        underwriting_error(Msg),
        Result = error(Msg)
    ).
```

**Alur bisnis:** Ini **pembungkus aman** yang dipanggil dari luar (dari
`main.pl`) — mengubah kegagalan sistem (kuota habis, skor di bawah minimum)
jadi hasil `error(Message)` yang bisa ditangani dengan baik di lapisan
presentasi, bukan biarkan program crash.

**Konsep Prolog:** `catch(Goal, Catcher, Recovery)` — kalau `Goal`
(`underwrite_application(...)`) sukses, hasilnya `ok(Decision, StateOut)`.
Kalau `Goal` throw `underwriting_error(Msg)`, `catch` menangkapnya dan
jalankan `Recovery` (`Result = error(Msg)`) sebagai gantinya. Ini padanan
`runExceptT` di Haskell — "membuka" lapisan exception handling jadi nilai
biasa yang bisa dipattern-match di pemanggil.

---

## §7 — Audit Trail (Dispatch Berdasarkan Tipe Item)

```prolog
audit_entry(approved(Amount, Rate), info, Entry) :- ...
audit_entry(rejected(Why), warning, Entry) :- ...
audit_entry(pending_review(Docs), warning, Entry) :- ...
audit_entry(loan_app(Name, Principal, _, _, Score, _, _), info, Entry) :- ...
audit_entry(Note, Severity, Entry) :-
    ( atom(Note) ; string(Note) ), !,
    format(atom(Entry), "NOTE | ~w", [Note]),
    ( ( sub_atom(Note, _, _, _, fraud)
      ; sub_atom(Note, _, _, _, suspicious)
      ) ->
        Severity = critical
    ; Severity = info
    ).
```

**Alur bisnis:** Ini **satu titik masuk audit log** yang bisa menerima
berbagai jenis "kejadian" dalam proses LOS: keputusan approve (severity
`info` — normal), keputusan reject/pending (severity `warning` — perlu
perhatian), data aplikasi mentah (`info`), sampai catatan bebas
(`Note`, misal dari fraud detection team). Yang menarik secara bisnis:
kalau catatan bebas mengandung kata `fraud` atau `suspicious`, severity-nya
otomatis naik jadi `critical` — ini simulasi sederhana dari rule engine
deteksi fraud berbasis keyword yang sering ada di sistem audit nyata.

**Konsep Prolog:** Ini padanan **type class** Haskell (`class Auditable a`)
tapi tanpa perlu deklarasi instance formal — cukup definisikan klausa
`audit_entry/3` untuk tiap "bentuk" argumen pertama yang mau didukung.
Dispatch terjadi otomatis lewat unifikasi: `audit_entry(approved(_,_), ...)`
hanya cocok untuk term `approved/2`, dst. Klausa terakhir (untuk
atom/string) memakai `atom(Note) ; string(Note)` sebagai **guard tipe**
eksplisit (karena atom/string tidak punya functor spesifik untuk
di-pattern-match), lalu `sub_atom/5` dipakai untuk cek substring — ini versi
Prolog dari `"fraud" `isInfixOf` note` di Haskell.

```prolog
severity_level(info,     0).
severity_level(warning,  1).
severity_level(critical, 2).

severity_gte(Sev, Min) :-
    severity_level(Sev, SL),
    severity_level(Min, ML),
    SL >= ML.
```

**Alur bisnis:** Ini **pengurutan tingkat keparahan** — supaya sistem bisa
memfilter "tampilkan hanya yang `warning` ke atas" (skip yang cuma `info`),
sesuatu yang lazim di dashboard monitoring/audit.

**Konsep Prolog:** `severity_level/2` memetakan atom (`info`, `warning`,
`critical`) ke angka urutan, lalu `severity_gte/2` membandingkan dua level
lewat angka itu. Trik ini umum di Prolog: kalau butuh **ordering** pada
sesuatu yang bukan angka, petakan dulu ke angka lewat fakta sederhana.

```prolog
log_batch([]).
log_batch([H|T]) :-
    log_to_audit_trail(H),
    log_batch(T).
```

**Alur bisnis:** Proses banyak item audit sekaligus (misal semua keputusan
hari ini di-log ulang secara batch), satu per satu.

**Konsep Prolog:** Ini pola **rekursi list** paling klasik di Prolog: kasus
dasar (`[]`, list kosong → berhasil tanpa apa-apa) + kasus rekursif (proses
`H`ead, lalu rekursi ke `T`ail). Ini padanan langsung `mapM_` di Haskell,
tapi ditulis manual karena efek sampingnya (`format/2` cetak ke layar) perlu
dijalankan berurutan.

```prolog
log_mixed_batch([]).
log_mixed_batch([H|T]) :-
    ( audit_entry(H, Sev, Entry),
      severity_gte(Sev, warning) ->
        format("[~w] ~w~n", [Sev, Entry])
    ; true
    ),
    log_mixed_batch(T).
```

**Alur bisnis:** Sama seperti `log_batch`, tapi **hanya tampilkan yang
level `warning` ke atas** — dan yang penting, list-nya boleh **campuran**
tipe (approved, rejected, string catatan, data aplikasi) dalam satu list
yang sama. Ini skenario nyata: log stream gabungan dari berbagai sumber
event, bukan satu jenis event murni.

**Konsep Prolog:** Ini highlight yang disebut README sebagai keunggulan
Prolog: **list heterogen native**. Di Haskell, menyimpan `[approved(...),
rejected(...), "string biasa"]` dalam satu list butuh *existential type*
(`AnyAuditable`) untuk menyatukan tipe-tipe berbeda ke satu "amplop". Di
Prolog, list memang tidak pernah dicek tipe elemennya — jadi tidak perlu
wrapper apa pun; `audit_entry/3` yang otomatis memilih klausa mana yang
cocok untuk tiap elemen, apa pun bentuknya.

---

## §8 — Meta-Programming Bonus: Rules sebagai Data

```prolog
which_rules_pass(App, Names) :-
    findall(Name,
        ( member(Name-Goal,
            [ min_score_620 - min_credit_score(620, App)
            , max_dti_43    - max_dti(0.43, App)
            , max_principal - max_principal(2_000_000_000, App)
            ]),
          call(Goal)
        ),
        Names).
```

**Alur bisnis:** Ini fitur **diagnostik/transparansi** — buat internal tim
risk/compliance yang mau tahu bukan cuma "lolos atau tidak", tapi **nama
aturan spesifik mana saja** yang dilewati pemohon tertentu. Berguna untuk
laporan, audit kepatuhan, atau debugging keputusan yang dipertanyakan
nasabah.

**Konsep Prolog:** Ini contoh nyata "goals sebagai data": list
`[min_score_620 - min_credit_score(620, App), ...]` memasangkan **nama
manusiawi** (atom seperti `min_score_620`) dengan **goal yang belum
dieksekusi** (`min_credit_score(620, App)`) lewat operator `-` (di sini
cuma dipakai sebagai constructor pasangan, bukan pengurangan — konvensi
umum Prolog untuk representasi `Key-Value`). `findall/3` mengumpulkan
**semua** `Name` yang goal pasangannya berhasil di-`call/1`, jadi satu
list hasil. Ini padanan reflection API yang biasanya butuh library berat di
bahasa lain (misal Java reflection) — di Prolog ini gratis karena goals
memang cuma data biasa sampai saat dieksekusi lewat `call`.

---

## Helper: `mask_name/2`

```prolog
mask_name(Name, Masked) :-
    atom_chars(Name, [First|Rest]),
    length(Rest, Len),
    ( Len >= 2 ->
        atom_chars(Masked, [First, '*', '*', '*'])
    ;   Masked = Name
    ).
```

**Alur bisnis:** Ini **masking PII** (Personally Identifiable Information)
untuk keperluan tampilan log/audit — nama pemohon seperti `'Budi'` disamarkan
jadi `B***` sebelum dicetak di tempat yang mungkin dilihat orang yang tidak
berwenang (misal log level yang lebih luas aksesnya). Ini praktik umum di
sistem finansial yang diatur ketat soal privasi data nasabah.

**Konsep Prolog:** `atom_chars/2` memecah atom jadi list karakter (`'Budi'`
→ `[B,u,d,i]`), ambil karakter pertama (`First`), sisanya (`Rest`) cuma
dipakai untuk dihitung panjangnya. Kalau nama cukup panjang (≥2 karakter
sisa), bentuk ulang jadi `First` + tiga bintang; kalau terlalu pendek,
biarkan apa adanya.

---

## `main.pl` — Demo End-to-End

File ini **tidak berisi logika bisnis baru** — dia adalah *runner* yang
memanggil semua predikat dari `los_lib.pl` secara berurutan untuk
mendemonstrasikan setiap bagian. Yang perlu diperhatikan secara khusus:

```prolog
forall(
    ( member(App, [SampleApp, LowApp, OverApp]),
      passes_all_rules(App),
      App = loan_app(Name, _, _, _, _, _, _)
    ),
    format("  Lolos: ~w~n", [Name])
),
```

**Alur bisnis:** Ini query **"siapa saja yang layak dari daftar
pemohon ini?"** — pertanyaan yang natural muncul kalau kamu punya banyak
pengajuan dan mau filter cepat siapa yang lolos.

**Konsep Prolog:** Ini yang dimaksud README sebagai **query multi-arah**:
`passes_all_rules/1` didefinisikan sebagai "App ini lolos atau tidak", tapi
lewat `forall` + `member`, Prolog otomatis mencoba **setiap** App dalam
list dan melaporkan yang lolos — **tanpa loop eksplisit** yang kamu tulis
manual (`for app in apps: if passes(app): print(app)`). `member/2` melakukan
backtracking otomatis untuk mencoba tiap elemen list satu per satu; kombinasi
dengan `passes_all_rules/1` sebagai filter membuat efeknya seperti query SQL
`WHERE`, bukan imperative loop.

Sisa `main.pl` (§1–§6 di komentarnya) murni memanggil predikat yang sudah
dijelaskan di atas dengan tiga sample data (`sample_app` = Budi, kondisi
normal; `low_score_app` = Siti, skor rendah; `over_quota_app` = Andi,
pinjaman melebihi kuota harian) — masing-masing sengaja dipilih untuk
memicu jalur bisnis berbeda: approved, pending_review/rejected, dan
error kuota.

---

## `spec.pl` — Property-Based Testing

**Alur bisnis dari testing ini:** Alih-alih menulis test case satu-satu
("kalau App A maka hasilnya B"), tiap test di sini menyatakan **properti
yang harus selalu benar**, untuk banyak input acak sekaligus — ini
menangkap bug yang mungkin lolos dari test manual karena kamu tidak
kepikiran kombinasi input tertentu.

```prolog
gen_loan_app2(loan_app(Name, Principal, Rate, Term, Score, Debt, Income)) :-
    random_member(Name, ['Budi','Siti','Andi','Rina','Wati']),
    random_between(1_000_000, 5_000_000_000, Principal),
    random_float(3.0, 25.0, Rate),
    random_between(6, 360, Term),
    random_between(300, 850, Score),
    random_between(0, 20_000_000, Debt),
    random_between(1_000_000, 50_000_000, Income).
```

**Alur bisnis:** Generator ini membangkitkan data pengajuan pinjaman
**acak tapi realistis** — rentang angkanya dipilih supaya masuk akal
(skor kredit 300–850 seperti rentang FICO, tenor 6–360 bulan/0.5–30 tahun,
principal sampai Rp5 miliar). Ini penting: kalau rentangnya sembarangan,
properti yang diuji jadi tidak relevan dengan kasus dunia nyata.

**Konsep Prolog:** Ini padanan `Arbitrary` instance di QuickCheck Haskell,
tapi ditulis manual pakai `random_between/3` (integer) dan helper custom
`random_float/3` (karena SWI-Prolog `random_between` cuma untuk integer).

```prolog
test(higher_score_better_rate, [forall(between(1,100,_))]) :-
    gen_loan_app2(App),
    App = loan_app(N, P, Rate, Term, Score, D, I),
    Score < 850,
    BetterScore is min(850, Score + 50),
    BetterApp = loan_app(N, P, Rate, Term, BetterScore, D, I),
    adjust_rate_for_risk(App, AdjApp),
    adjust_rate_for_risk(BetterApp, AdjBetter),
    decide(AdjApp, Dec1),
    decide(AdjBetter, Dec2),
    ( Dec1 = approved(_, R1), Dec2 = approved(_, R2) ->
        R2 =< R1
    ; true
    ).
```

**Alur bisnis:** Ini properti bisnis yang **sangat penting untuk fairness
kredit**: *"pemohon dengan skor kredit lebih baik tidak boleh mendapat rate
yang lebih buruk"* (kalau sama-sama disetujui). Ini bukan sekadar cek
teknis — ini semacam jaminan kualitas kebijakan pricing bank, dijalankan
otomatis untuk 100 kombinasi pemohon acak setiap kali test dijalankan. Kalau
suatu saat ada perubahan logika `adjust_rate_for_risk` yang tidak sengaja
membalik urutan ini (bug), test ini akan menangkapnya.

**Konsep Prolog:** `[forall(between(1,100,_))]` adalah opsi `plunit` yang
menjalankan body test **100 kali** dengan `_` sebagai counter yang diabaikan
— tiap run memanggil `gen_loan_app2` baru sehingga datanya beda-beda tiap
kali (mirip `quickCheck` menjalankan property berkali-kali dengan input
random berbeda). Baris `( Dec1 = approved(...), Dec2 = approved(...) -> ... ;
true )` penting: kalau salah satu tidak `approved` (misal `BetterApp` malah
jadi `pending_review`), properti dianggap **tidak berlaku untuk kasus itu**
(`true` = lolos otomatis) — bukan gagal. Ini pola umum property-based
testing: properti hanya dicek kalau prasyaratnya (kedua-duanya approved)
terpenuhi.

```prolog
test(underwriting_deterministic, [forall(between(1,50,_))]) :-
    gen_loan_app2(App),
    bank_config(Base, Policy, MaxL, MinS),
    Cfg = bank_config(Base, Policy, MaxL, MinS),
    St = bank_state(1_000_000_000, []),
    run_underwriting(App, Cfg, St, Result1),
    run_underwriting(App, Cfg, St, Result2),
    ( Result1 = ok(D1, _), Result2 = ok(D2, _) -> D1 == D2
    ; Result1 = error(E1), Result2 = error(E2) -> E1 == E2
    ; true
    ).
```

**Alur bisnis:** Ini properti **konsistensi/determinisme** — pengajuan yang
sama, diproses dengan config dan state awal yang sama, harus **selalu
menghasilkan keputusan yang sama**. Ini krusial buat sistem finansial: kalau
proses underwriting bisa menghasilkan keputusan berbeda untuk input identik
(misalnya karena ada state global tersembunyi atau race condition), itu bug
serius yang bisa berujung komplain nasabah ("kenapa kemarin ditolak, hari
ini kok saya coba lagi malah beda alasannya").

**Konsep Prolog:** Test ini secara implisit **memvalidasi arsitektur State
monad-style** di §6 — karena state selalu di-*thread* murni lewat argumen
(tidak ada mutable global), memanggil `run_underwriting` dua kali dengan
`St` awal yang identik **dijamin secara struktural** menghasilkan hasil
sama, tidak bergantung urutan pemanggilan atau efek samping tersembunyi.
Test ini pada dasarnya membuktikan properti yang README klaim ("tidak ada
mutable state").

---

## Ringkasan Peta Alur Bisnis → Section Kode

| Tahap proses bisnis LOS | Predikat/Section |
|---|---|
| Data pengajuan masuk | §1 `loan_app/7`, `bank_config/4`, `bank_state/2` |
| Hitung DTI & simulasi cicilan | §2 `calculate_dti/3`, `calculate_monthly_payment/4` |
| Cek kelayakan (skor, DTI, plafon) | §3 `min_credit_score`, `max_dti`, `max_principal`, `passes_all_rules`, `failing_rules` |
| Sesuaikan bunga berdasar risiko | §4 `adjust_rate_for_risk/2` |
| Keputusan approve/reject/pending | §4 `decide/2` |
| Notifikasi ke pemohon | §4 `notify_applicant/2`, `full_pipeline/2` |
| Validasi data sebelum diproses | §5 `validate_application/2`, `process_application/2` |
| Proses dengan kuota bank & rate final | §6 `underwrite_application/5`, `run_underwriting/4` |
| Audit trail & compliance | §7 `audit_entry/3`, `log_batch/1`, `log_mixed_batch/1` |
| Diagnostik aturan mana yang lolos | §8 `which_rules_pass/2` |
| Masking data sensitif | Helper `mask_name/2` |
| Demo end-to-end | `main.pl` |
| Jaminan kualitas via properti acak | `spec.pl` |

---

## Saran Latihan Lanjutan

Kalau mau makin nempel konsepnya, coba di konsol interaktif (`swipl
los_lib.pl`):

1. **Rasakan multi-directionality** — jalankan `failing_rules/2` untuk
   beberapa `loan_app` beda-beda, lihat bagaimana predikat yang sama bisa
   "dibalik arah" tanpa kode baru.
2. **Coba pecahkan invariant di `spec.pl`** — ubah `adjust_rate_for_risk`
   supaya skor tinggi malah dapat rate lebih buruk, jalankan
   `swipl -g run_tests -t halt spec.pl`, lihat test `higher_score_better_rate`
   gagal. Ini cara paling cepat merasakan *kenapa* property-based test
   berguna.
3. **Tambah aturan underwriting baru** (misal `min_income/2`) dan masukkan
   ke `underwriting_rules/1` — perhatikan `passes_all_rules`, `failing_rules`,
   dan `which_rules_pass` otomatis ikut memakainya tanpa kamu ubah kode
   mereka sama sekali. Ini nunjukin kenapa representasi "rules sebagai data"
   itu powerful.
