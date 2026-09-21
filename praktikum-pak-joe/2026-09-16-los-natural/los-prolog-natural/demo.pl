% demo.pl
% Jalankan: swipl demo.pl
% Semua aturan ada di los.pl, berkas ini cuma mencetak hasil query.

:- use_module(los).
:- initialization(main, main).

judul(Teks) :- format("~n=== ~w ===~n", [Teks]).

main :-
    judul("1) Perhitungan dasar"),
    pengajuan(budi, Budi),
    dti(Budi, Dti),
    format("  DTI Budi: ~2f~n", [Dti]),
    cicilan_bulanan(200_000_000, 8.0, 24, Cicilan),
    format("  Cicilan Rp200 juta, bunga 8%, tenor 24 bulan: Rp~0f~n", [Cicilan]),

    judul("2) Aturan underwriting yang dilanggar tiap pemohon"),
    forall(pengajuan(Nama, P),
           ( findall(A, melanggar(P, A), Dilanggar),
             format("  ~w: ~w~n", [Nama, Dilanggar]) )),

    judul("3) Siapa saja yang layak? (backtracking atas fakta pengajuan)"),
    forall(layak(Nama), format("  ~w~n", [Nama])),

    judul("4) Keputusan awal dan pesan ke pemohon"),
    forall(pengajuan(Nama, P),
           ( keputusan(P, Keputusan),
             pesan(Keputusan, Teks),
             format("  ~w: ~w~n           ~w~n", [Nama, Keputusan, Teks]) )),

    judul("5) Validasi dasar: pengajuan cacat tidak bisa diproses"),
    Cacat = Budi.put(_{pokok: -1, tenor: 0}),
    (   proses(Cacat, K)
    ->  format("  diproses: ~w~n", [K])
    ;   findall(C, cacat(Cacat, C), SemuaCacat),
        format("  proses/2 gagal. Cacatnya: ~w~n", [SemuaCacat])
    ),

    judul("6) Underwriting dengan state harian bank"),
    buka_hari,
    kuota_tersisa(Awal),
    format("  Kuota awal hari ini: Rp~D~n", [Awal]),
    forall(member(Nama, [budi, andi]),
           (   underwrite(Nama, Hasil)
           ->  format("  ~w: ~w~n", [Nama, Hasil])
           ;   pengajuan(Nama, P),
               findall(H, hambatan(P, H), Hambatan),
               format("  ~w: gagal, hambatan ~w~n", [Nama, Hambatan])
           )),
    kuota_tersisa(Sisa),
    format("  Sisa kuota: Rp~D~n", [Sisa]),
    format("  Jurnal:~n"),
    forall(jurnal(Baris), format("    - ~w~n", [Baris])),

    judul("7) Query yang enak ditanyakan di Prolog"),
    pengajuan(siti, Siti),
    batas_skor_disetujui(Siti, SkorBatas),
    format("  Skor terendah supaya Siti disetujui: ~w~n", [SkorBatas]),
    pengajuan(andi, Andi),
    pokok_maksimum_disetujui(Andi, PokokMaks),
    format("  Pokok terbesar supaya Andi disetujui (kelipatan 100 juta): Rp~D~n", [PokokMaks]),
    rentang_skor_premi(1.5, Rendah-Tinggi),
    format("  Skor yang kena premi risiko 1.5%: ~w sampai ~w~n", [Rendah, Tinggi]),
    total_pokok_disetujui(Total),
    bank(kuota_harian, Kuota),
    format("  Total pokok yang disetujui hari ini: Rp~D dari kuota Rp~D~n", [Total, Kuota]),
    nl.
