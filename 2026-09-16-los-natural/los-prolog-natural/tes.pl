% tes.pl
% Jalankan: swipl tes.pl

:- use_module(los).
:- use_module(library(plunit)).
:- initialization(run_tests, main).

:- begin_tests(perhitungan).

test(dti_budi_seperempat, Dti =:= 0.25) :-
    pengajuan(budi, Budi),
    dti(Budi, Dti).

test(cicilan_200juta_8persen_24bulan) :-
    cicilan_bulanan(200_000_000, 8.0, 24, Cicilan),
    abs(Cicilan - 9_045_458) < 1.

test(cicilan_tanpa_bunga_dibagi_rata, Cicilan =:= 10) :-
    cicilan_bulanan(120, 0, 12, Cicilan).

test(cicilan_tenor_nol_tidak_terdefinisi, fail) :-
    cicilan_bulanan(100, 8.0, 0, _).

:- end_tests(perhitungan).

:- begin_tests(aturan_underwriting).

test(budi_tidak_melanggar_apa_pun) :-
    pengajuan(budi, Budi),
    \+ melanggar(Budi, _).

test(siti_hanya_melanggar_skor, all(Aturan == [skor_minimum])) :-
    pengajuan(siti, Siti),
    melanggar(Siti, Aturan).

test(andi_hanya_melanggar_pokok, all(Aturan == [pokok_maksimum])) :-
    pengajuan(andi, Andi),
    melanggar(Andi, Aturan).

test(dti_di_atas_43_persen_melanggar) :-
    pengajuan(budi, Budi),
    melanggar(Budi.put(cicilan_lain, 6_000_000), dti_maksimum).

test(dua_pelanggaran_sekaligus_terenumerasi, all(Aturan == [skor_minimum, pokok_maksimum])) :-
    pengajuan(andi, Andi),
    melanggar(Andi.put(skor, 500), Aturan).

test(yang_layak_cuma_budi, all(Nama == [budi])) :-
    layak(Nama).

:- end_tests(aturan_underwriting).

:- begin_tests(keputusan_awal).

test(budi_disetujui_tambahan_1_5) :-
    pengajuan(budi, Budi),
    keputusan(Budi, disetujui(200_000_000, 1.5)).

test(siti_ditolak_karena_skor) :-
    pengajuan(siti, Siti),
    keputusan(Siti, ditolak([skor_minimum])).

test(skor_640_lolos_tapi_perlu_dokumen) :-
    pengajuan(budi, Budi),
    keputusan(Budi.put(skor, 640), perlu_dokumen(_)).

test(skor_720_tidak_kena_tambahan) :-
    pengajuan(budi, Budi),
    keputusan(Budi.put(skor, 720), disetujui(_, Tambahan)),
    Tambahan =:= 0.

test(keputusan_selalu_tepat_satu, all(Nama == [budi, siti, andi])) :-
    pengajuan(Nama, P),
    findall(K, keputusan(P, K), Semua),
    length(Semua, 1).

test(pesan_ditolak_menyebut_semua_aturan) :-
    pesan(ditolak([skor_minimum, pokok_maksimum]), Teks),
    sub_atom(Teks, _, _, _, 'skor_minimum, pokok_maksimum').

:- end_tests(keputusan_awal).

:- begin_tests(validasi).

test(pokok_negatif_gagal_diproses, fail) :-
    pengajuan(budi, Budi),
    proses(Budi.put(pokok, -1), _).

test(semua_cacat_terkumpul, all(C == [pokok_tidak_positif, tenor_tidak_positif, skor_tidak_valid])) :-
    pengajuan(budi, Budi),
    cacat(Budi.put(_{pokok: 0, tenor: 0, skor: 250}), C).

% nondet: tabel penyesuaian_risiko/2 sengaja tiga klausa tanpa cut supaya
% bisa ditanya balik, jadi wajar menyisakan choicepoint.
test(pengajuan_valid_diproses_normal, nondet) :-
    pengajuan(budi, Budi),
    proses(Budi, disetujui(_, _)).

:- end_tests(validasi).

:- begin_tests(underwriting_bank, [setup(buka_hari)]).

test(bunga_akhir_budi_7_75, [setup(buka_hari)]) :-
    underwrite(budi, disetujui(200_000_000, Bunga)),
    Bunga =:= 7.75.

test(kuota_berkurang_setelah_budi, [setup(buka_hari)]) :-
    underwrite(budi, _),
    kuota_tersisa(800_000_000).

test(jurnal_terisi_tiga_baris, [setup(buka_hari)]) :-
    underwrite(budi, _),
    aggregate_all(count, jurnal(_), 3).

test(andi_gagal_dan_state_utuh, [setup(buka_hari)]) :-
    \+ underwrite(andi, _),
    kuota_tersisa(1_000_000_000),
    \+ jurnal(_).

test(hambatan_andi_dua_sekaligus,
     [setup(buka_hari),
      all(H == [melebihi_plafon_per_pinjaman(500_000_000),
                kuota_harian_tidak_cukup(1_000_000_000)])]) :-
    pengajuan(andi, Andi),
    hambatan(Andi, H).

test(siti_terhambat_skor_minimum_bank, [setup(buka_hari)]) :-
    pengajuan(siti, Siti),
    hambatan(Siti, skor_di_bawah_minimum_bank(620)).

test(kegagalan_di_tengah_transaksi_dibatalkan, [setup(buka_hari)]) :-
    \+ transaction(( cadangkan_kuota(200_000_000), fail )),
    kuota_tersisa(1_000_000_000).

test(kuota_habis_setelah_beberapa_pengajuan, [setup(buka_hari)]) :-
    underwrite(budi, _),
    underwrite(budi, _),
    underwrite(budi, _),
    underwrite(budi, _),
    underwrite(budi, _),
    kuota_tersisa(0),
    \+ underwrite(budi, _).

test(kebijakan_conservative_menaikkan_bunga) :-
    penyesuaian_kebijakan(conservative, Naik),
    Naik =:= 0.5.

test(kebijakan_aggressive_menurunkan_bunga) :-
    penyesuaian_kebijakan(aggressive, Turun),
    Turun =:= -0.5.

:- end_tests(underwriting_bank).

:- begin_tests(query_natural).

test(batas_skor_siti_650) :-
    pengajuan(siti, Siti),
    batas_skor_disetujui(Siti, 650).

test(pokok_maksimum_andi_2_miliar) :-
    pengajuan(andi, Andi),
    pokok_maksimum_disetujui(Andi, 2_000_000_000).

test(rentang_skor_premi_1_5) :-
    rentang_skor_premi(1.5, 600-699).

test(rentang_skor_premi_3_5) :-
    rentang_skor_premi(3.5, 300-599).

test(total_disetujui_hanya_budi, Total =:= 200_000_000) :-
    total_pokok_disetujui(Total).

:- end_tests(query_natural).
