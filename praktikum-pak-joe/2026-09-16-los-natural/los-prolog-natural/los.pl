% los.pl
% Loan Originating System sebagai basis pengetahuan Prolog.
%
% Isinya tiga lapis:
%   1. fakta      : profil bank dan daftar pengajuan
%   2. aturan     : hal yang bisa diturunkan dari fakta (DTI, pelanggaran,
%                   keputusan, bunga)
%   3. state hari : kuota yang tersisa dan jurnal, disimpan sebagai predikat
%                   dinamis dan hanya diubah di dalam transaction/1
%
% Kegagalan predikat dipakai apa adanya. Kalau pengajuan tidak valid,
% proses/2 gagal saja, dan alasannya ditanya lewat cacat/2. Tidak ada
% pembungkus ok/error.

:- module(los, [ pengajuan/2, bank/2, batas/2,
                 dti/2, cicilan_bulanan/4,
                 melanggar/2, lolos_underwriting/1, layak/1,
                 penyesuaian_risiko/2, premi_risiko/2, penyesuaian_kebijakan/2,
                 bunga_akhir/2,
                 keputusan/2, pesan/2,
                 cacat/2, valid/1, proses/2,
                 buka_hari/0, kuota_tersisa/1, jurnal/1,
                 hambatan/2, cadangkan_kuota/1, underwrite/2,
                 batas_skor_disetujui/2, pokok_maksimum_disetujui/2,
                 rentang_skor_premi/2, total_pokok_disetujui/1 ]).

:- use_module(library(aggregate)).

% ---------------------------------------------------------------------------
% 1. Fakta
% ---------------------------------------------------------------------------

bank(bunga_dasar,          6.25).
bank(kebijakan,            standard).      % conservative | standard | aggressive
bank(plafon_per_pinjaman,  500_000_000).
bank(skor_minimum,         620).
bank(kuota_harian,         1_000_000_000).

% Ambang aturan underwriting. Dipisah jadi fakta supaya bisa ditanya dan
% diganti tanpa menyentuh aturannya.
batas(skor_minimum,   620).
batas(dti_maksimum,   0.43).
batas(pokok_maksimum, 2_000_000_000).

% pengajuan(?Nama, ?Data)
% Data dipakai dict SWI-Prolog, bukan term posisional, karena field-nya
% dipanggil pakai nama (P.skor) dan skenario "bagaimana kalau skornya 640"
% cukup P.put(skor, 640). Dengan term enam argumen, tiap aturan harus
% menulis loan(_,_,_,Skor,_,_) dan skenario itu berarti menyalin semua argumen.
pengajuan(budi, pengajuan{pokok: 200_000_000,   tenor: 24, skor: 680,
                          cicilan_lain: 3_000_000, pendapatan: 12_000_000}).
pengajuan(siti, pengajuan{pokok: 50_000_000,    tenor: 24, skor: 590,
                          cicilan_lain: 3_000_000, pendapatan: 12_000_000}).
pengajuan(andi, pengajuan{pokok: 3_000_000_000, tenor: 24, skor: 680,
                          cicilan_lain: 3_000_000, pendapatan: 12_000_000}).

% ---------------------------------------------------------------------------
% 2. Perhitungan
% ---------------------------------------------------------------------------

% dti(+P, -Dti)  rasio cicilan lain terhadap pendapatan
dti(P, Dti) :-
    (   P.pendapatan > 0
    ->  Dti is P.cicilan_lain / P.pendapatan
    ;   Dti = 0
    ).

% cicilan_bulanan(+Pokok, +BungaTahunanPersen, +Tenor, -Cicilan)
% Rumus anuitas. Tenor 0 tidak punya cicilan, jadi predikatnya gagal.
cicilan_bulanan(Pokok, Bunga, Tenor, Cicilan) :-
    Tenor > 0,
    (   Bunga =:= 0
    ->  Cicilan is Pokok / Tenor
    ;   R is Bunga / 12 / 100,
        Cicilan is Pokok * R * (1 + R) ** Tenor / ((1 + R) ** Tenor - 1)
    ).

% ---------------------------------------------------------------------------
% 3. Aturan underwriting
%
% Satu klausa per aturan, semuanya berkepala melanggar/2. Jadi pertanyaan
% "aturan mana saja yang dilanggar" tinggal findall(A, melanggar(P, A), As),
% dan "lolos" adalah tidak ada satu pun yang bisa dibuktikan dilanggar.
% ---------------------------------------------------------------------------

melanggar(P, skor_minimum)   :- batas(skor_minimum, Min),    P.skor < Min.
melanggar(P, dti_maksimum)   :- batas(dti_maksimum, Maks),   dti(P, D), D > Maks.
melanggar(P, pokok_maksimum) :- batas(pokok_maksimum, Maks), P.pokok > Maks.

lolos_underwriting(P) :- \+ melanggar(P, _).

% layak(?Nama)  pemohon terdaftar yang lolos semua aturan
layak(Nama) :- pengajuan(Nama, P), lolos_underwriting(P).

% ---------------------------------------------------------------------------
% 4. Tabel bunga
% ---------------------------------------------------------------------------

% Tambahan bunga pada keputusan awal, menurut skor.
penyesuaian_risiko(Skor, 3.5) :- Skor < 600.
penyesuaian_risiko(Skor, 1.5) :- Skor >= 600, Skor < 700.
penyesuaian_risiko(Skor, 0.0) :- Skor >= 700.

% Premi risiko waktu underwriting. Bedanya dengan tabel di atas cuma di
% skor 700 ke atas: tetap kena 0.5.
premi_risiko(Skor, 3.5) :- Skor < 600.
premi_risiko(Skor, 1.5) :- Skor >= 600, Skor < 700.
premi_risiko(Skor, 0.5) :- Skor >= 700.

penyesuaian_kebijakan(conservative,  0.5).
penyesuaian_kebijakan(standard,      0.0).
penyesuaian_kebijakan(aggressive,   -0.5).

% bunga_akhir(+Skor, -Bunga)  bunga dasar + premi risiko + penyesuaian kebijakan
bunga_akhir(Skor, Bunga) :-
    bank(bunga_dasar, Dasar),
    bank(kebijakan, Kebijakan),
    premi_risiko(Skor, Premi),
    penyesuaian_kebijakan(Kebijakan, Tambahan),
    Bunga is Dasar + Premi + Tambahan.

% ---------------------------------------------------------------------------
% 5. Keputusan awal
%
% Tiga klausa dengan syarat yang saling lepas, jadi tidak perlu cut dan
% keputusan/2 tetap aman kalau ditanya balik, misalnya
% keputusan(P, disetujui(_, _)) dari dalam generate and test.
% ---------------------------------------------------------------------------

keputusan(P, ditolak(Pelanggaran)) :-
    findall(A, melanggar(P, A), Pelanggaran),
    Pelanggaran \== [].
keputusan(P, perlu_dokumen([slip_gaji_3_bulan])) :-
    lolos_underwriting(P),
    P.skor < 650.
keputusan(P, disetujui(Pokok, Tambahan)) :-
    lolos_underwriting(P),
    P.skor >= 650,
    Pokok = P.pokok,
    penyesuaian_risiko(P.skor, Tambahan).

% pesan(+Keputusan, -Teks)  kalimat yang dikirim ke pemohon
pesan(disetujui(Pokok, Tambahan), Teks) :-
    format(atom(Teks),
           "Selamat, pinjaman Rp~D disetujui dengan tambahan bunga risiko ~1f%",
           [Pokok, Tambahan]).
pesan(ditolak(Pelanggaran), Teks) :-
    atomic_list_concat(Pelanggaran, ', ', Daftar),
    format(atom(Teks), "Maaf, pengajuan ditolak. Aturan yang dilanggar: ~w", [Daftar]).
pesan(perlu_dokumen(Dokumen), Teks) :-
    atomic_list_concat(Dokumen, ', ', Daftar),
    format(atom(Teks), "Perlu dokumen tambahan: ~w", [Daftar]).

% ---------------------------------------------------------------------------
% 6. Validasi dasar
% ---------------------------------------------------------------------------

cacat(P, pokok_tidak_positif) :- P.pokok =< 0.
cacat(P, tenor_tidak_positif) :- P.tenor =< 0.
cacat(P, skor_tidak_valid)    :- P.skor < 300.

valid(P) :- \+ cacat(P, _).

% proses(+P, -Keputusan)  gagal kalau pengajuannya cacat
proses(P, Keputusan) :- valid(P), keputusan(P, Keputusan).

% ---------------------------------------------------------------------------
% 7. State harian bank
%
% Kuota dan jurnal disimpan sebagai fakta dinamis. Cara ini yang lazim di
% SWI-Prolog untuk state yang memang berubah, dan transaction/1 menjamin
% assert/retract di dalamnya dibatalkan semua kalau goal-nya gagal atau
% melempar exception.
% ---------------------------------------------------------------------------

:- dynamic kuota_tersisa/1, jurnal/1.

buka_hari :-
    retractall(kuota_tersisa(_)),
    retractall(jurnal(_)),
    bank(kuota_harian, Kuota),
    assertz(kuota_tersisa(Kuota)).

catat(Format, Args) :-
    format(atom(Pesan), Format, Args),
    assertz(jurnal(Pesan)).

% hambatan(+P, ?Alasan)  hal yang menghalangi underwriting di sisi bank
hambatan(P, pokok_tidak_positif)                    :- P.pokok =< 0.
hambatan(P, skor_di_bawah_minimum_bank(Min))        :- bank(skor_minimum, Min), P.skor < Min.
hambatan(P, melebihi_plafon_per_pinjaman(Plafon))   :- bank(plafon_per_pinjaman, Plafon), P.pokok > Plafon.
hambatan(P, kuota_harian_tidak_cukup(Sisa))         :- kuota_tersisa(Sisa), P.pokok > Sisa.
hambatan(_, hari_belum_dibuka)                      :- \+ kuota_tersisa(_).

% cadangkan_kuota(+Jumlah)  gagal kalau sisa kuota tidak cukup, dan kalau
% gagal tidak ada fakta yang tersentuh
cadangkan_kuota(Jumlah) :-
    kuota_tersisa(Sisa),
    Sisa >= Jumlah,
    retract(kuota_tersisa(Sisa)),
    SisaBaru is Sisa - Jumlah,
    assertz(kuota_tersisa(SisaBaru)).

% underwrite(+Nama, -Hasil)
% Berhasil hanya kalau tidak ada hambatan; kalau gagal, kuota dan jurnal
% dijamin sama seperti sebelum dipanggil.
underwrite(Nama, disetujui(Pokok, Bunga)) :-
    pengajuan(Nama, P),
    Pokok = P.pokok,
    transaction(( \+ hambatan(P, _),
                  catat("Validasi dasar lolos untuk ~w", [Nama]),
                  cadangkan_kuota(Pokok),
                  catat("Kuota dicadangkan: Rp~D", [Pokok]),
                  bunga_akhir(P.skor, Bunga),
                  catat("Disetujui dengan bunga ~2f%", [Bunga]) )).

% ---------------------------------------------------------------------------
% 8. Query yang memanfaatkan backtracking
% ---------------------------------------------------------------------------

% batas_skor_disetujui(+P, -Skor)
% Skor terendah yang membuat pengajuan P disetujui, dicari dengan
% generate and test lewat between/3.
batas_skor_disetujui(P, Skor) :-
    aggregate_all(min(S),
                  ( between(300, 850, S),
                    keputusan(P.put(skor, S), disetujui(_, _)) ),
                  Skor).

% pokok_maksimum_disetujui(+P, -Pokok)
% Pokok terbesar (kelipatan 100 juta sampai 5 miliar) yang masih disetujui.
pokok_maksimum_disetujui(P, Pokok) :-
    aggregate_all(max(X),
                  ( between(1, 50, K),
                    X is K * 100_000_000,
                    keputusan(P.put(pokok, X), disetujui(_, _)) ),
                  Pokok).

% rentang_skor_premi(+Premi, -Rendah-Tinggi)
% Membalik tabel premi: skor berapa saja yang kena premi tertentu.
rentang_skor_premi(Premi, Rendah-Tinggi) :-
    aggregate_all(min(S), ( between(300, 850, S), premi_risiko(S, Premi) ), Rendah),
    aggregate_all(max(S), ( between(300, 850, S), premi_risiko(S, Premi) ), Tinggi).

% total_pokok_disetujui(-Total)
% Jumlah pokok semua pengajuan terdaftar yang keputusannya disetujui.
total_pokok_disetujui(Total) :-
    aggregate_all(sum(Pokok),
                  ( pengajuan(_, P), keputusan(P, disetujui(Pokok, _)) ),
                  Total).
