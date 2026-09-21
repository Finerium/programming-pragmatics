% ============================================================
% PRAKTIKUM LOGIC PROGRAMMING - SWI-PROLOG
% Konsep utama:
% FACTS -> RULES -> QUERY -> SOLUTION
%
% Bobot:
% Tugas = 30%, UTS = 30%, UAS = 40%
%
% Grade:
% A >= 85
% B >= 75 dan < 85
% C >= 65 dan < 75
% D >= 55 dan < 65
% E < 55
%
% Lulus jika Nilai Akhir >= 60
% ============================================================


% ============================================================
% BAGIAN 1 - FACTS
% mahasiswa(NIM, Nama, Tugas, UTS, UAS).
% ============================================================

mahasiswa("24001", "Andi", 80, 75, 90).
mahasiswa("24002", "Budi", 70, 80, 75).
mahasiswa("24003", "Citra", 90, 85, 95).
mahasiswa("24004", "Deni", 65, 70, 60).
mahasiswa("24005", "Eka", 85, 90, 88).
mahasiswa("24006", "Fajar", 55, 65, 58).
mahasiswa("24007", "Gina", 78, 72, 80).
mahasiswa("24008", "Hadi", 92, 88, 94).
mahasiswa("24009", "Intan", 60, 68, 65).
mahasiswa("24010", "Joko", 75, 70, 72).

mahasiswa("24011", "Karin", 88, 82, 90).
mahasiswa("24012", "Luthfi", 68, 75, 70).
mahasiswa("24013", "Maya", 95, 92, 96).
mahasiswa("24014", "Nanda", 72, 65, 68).
mahasiswa("24015", "Olivia", 83, 78, 85).
mahasiswa("24016", "Putra", 58, 60, 55).
mahasiswa("24017", "Qori", 80, 85, 82).
mahasiswa("24018", "Raka", 74, 76, 79).
mahasiswa("24019", "Sinta", 90, 88, 91).
mahasiswa("24020", "Taufik", 62, 70, 64).

mahasiswa("24021", "Ulya", 86, 84, 89).
mahasiswa("24022", "Vina", 77, 80, 83).
mahasiswa("24023", "Wahyu", 69, 62, 67).
mahasiswa("24024", "Xena", 94, 90, 92).
mahasiswa("24025", "Yudha", 73, 68, 75).
mahasiswa("24026", "Zahra", 89, 93, 95).
mahasiswa("24027", "Bagas", 64, 58, 62).
mahasiswa("24028", "Rani", 81, 79, 86).
mahasiswa("24029", "Surya", 71, 74, 70).
mahasiswa("24030", "Tiara", 93, 87, 90).


% ============================================================
% BAGIAN 2 - RULES
% Informasi berikut TIDAK ditulis sebagai fakta.
% Prolog menurunkannya dari fakta + aturan.
% ============================================================

% Rule 1: menghitung nilai akhir
nilai_akhir(NIM, Nilai) :-
    mahasiswa(NIM, _, Tugas, UTS, UAS),
    Nilai is 0.3*Tugas + 0.3*UTS + 0.4*UAS.


% Rule 2: menentukan kelulusan
lulus(NIM) :-
    nilai_akhir(NIM, Nilai),
    Nilai >= 60.



% Rule 3-7: menentukan grade
grade(NIM, a) :-
    nilai_akhir(NIM, Nilai),
    Nilai >= 85.

grade(NIM, b) :-
    nilai_akhir(NIM, Nilai),
    Nilai >= 75,
    Nilai < 85.

grade(NIM, c) :-
    nilai_akhir(NIM, Nilai),
    Nilai >= 65,
    Nilai < 75.

grade(NIM, d) :-
    nilai_akhir(NIM, Nilai),
    Nilai >= 55,
    Nilai < 65.

grade(NIM, e) :-
    nilai_akhir(NIM, Nilai),
    Nilai < 55.


% Rule 8: mahasiswa berprestasi
berprestasi(NIM) :-
    grade(NIM, a),
    lulus(NIM).


% Rule 9: mahasiswa yang memerlukan bimbingan
perlu_bimbingan(NIM) :-
    nilai_akhir(NIM, Nilai),
    Nilai < 65.


% Rule 10: mahasiswa dengan nilai sangat tinggi
unggul(NIM) :-
    nilai_akhir(NIM, Nilai),
    Nilai >= 90.


% Rule 11: mahasiswa dengan kondisi akademik aman
aman(NIM) :-
    lulus(NIM),
    nilai_akhir(NIM, Nilai),
    Nilai >= 75.



% Rule 12: mahasiswa dengan nilai tinggi
nilai_tinggi(NIM) :-
    nilai_akhir(NIM, Nilai),
    Nilai >= 80.


% Rule 13: mahasiswa sangat baik
sangat_baik(NIM) :-
    grade(NIM, a).


% Rule 14: mahasiswa prioritas bimbingan
mahasiswa_prioritas(NIM) :-
    perlu_bimbingan(NIM).


% ============================================================
% BAGIAN 3 - RELATIONAL RULE
% Contoh hubungan antar-entitas.
% ============================================================

satu_kelas("24001", "24002").
satu_kelas("24001", "24003").
satu_kelas("24002", "24003").
satu_kelas("24004", "24005").
satu_kelas("24004", "24006").

teman_sekelas(X, Y) :-
    satu_kelas(X, Y).

teman_sekelas(X, Y) :-
    satu_kelas(Y, X).


% ============================================================
% BAGIAN 4 - QUERY YANG DAPAT DICOBA
%
% Jalankan query berikut satu per satu di SWI-Prolog.
%
% 1. Mencari fakta mahasiswa
% ?- mahasiswa("24013", Nama, Tugas, UTS, UAS).
%
% 2. Menghitung nilai akhir
% ?- nilai_akhir("24013", Nilai).
%
% 3. Mengecek kelulusan
% ?- lulus("24013").
%
% 4. Menentukan grade
% ?- grade("24013", Grade).
%
% 5. Mencari SEMUA mahasiswa yang mendapat A
% ?- grade(NIM, a).
% Tekan ; untuk mencari solusi berikutnya.
%
% 6. Mencari semua mahasiswa berprestasi
% ?- berprestasi(NIM).
%
% 7. Mencari mahasiswa yang perlu bimbingan
% ?- perlu_bimbingan(NIM).
%
% 8. Mencari mahasiswa dengan nilai >= 90
% ?- unggul(NIM).
%
% 9. Mencari mahasiswa dengan nilai >= 80
% ?- nilai_tinggi(NIM).
%
% 10. Mencari mahasiswa dengan kondisi akademik aman
% ?- aman(NIM).
%
% 11. Mencari teman sekelas
% ?- teman_sekelas("24001", X).
%
% 12. Pertanyaan gabungan:
%    Siapa mahasiswa yang mendapat A dan memiliki nilai >= 90?
% ?- grade(NIM, a), unggul(NIM).
%
% 13.Pertanyaan gabungan:
%    Siapa mahasiswa yang lulus tetapi tidak mendapat A?   Buatkan sintaksnya.
% ?- lulus(NIM), \+ grade(NIM, a).
%
% 14.Pertanyaan gabungan:
%    Siapa yang perlu bimbingan dan nilainya di bawah 60? Buatkan sintaksnya.
% ?- perlu_bimbingan(NIM), nilai_akhir(NIM, Nilai), Nilai < 60.
%
% ============================================================


% ============================================================
% BAGIAN 5 - CONTOH PENELUSURAN REASONING
%
% Query:
% ?- berprestasi("24013").
%
% Prolog menelusuri:
%
% berprestasi("24013")
%        |
%        +--> grade("24013", a)
%        |       |
%        |       +--> nilai_akhir("24013", Nilai)
%        |               |
%        |               +--> mahasiswa("24013", ...)
%        |
%        +--> lulus("24013")
%                |
%                +--> nilai_akhir("24013", Nilai)
%
% Jika semua kondisi terpenuhi -> true.
%
% ============================================================


% ============================================================
% BAGIAN 6 - DEMO
% Tambahan supaya keluaran ke-14 query bisa direkam ke berkas.
% Jalankan: swipl -q -g demo -t halt program4.pl
% ============================================================

judul(Teks) :-
    format("~n--- ~w ---~n", [Teks]).

demo :-
    judul("1. mahasiswa(\"24013\", Nama, Tugas, UTS, UAS)"),
    forall(mahasiswa("24013", Nama, Tugas, UTS, UAS),
           format("Nama = ~w, Tugas = ~w, UTS = ~w, UAS = ~w~n",
                  [Nama, Tugas, UTS, UAS])),

    judul("2. nilai_akhir(\"24013\", Nilai)"),
    forall(nilai_akhir("24013", N2),
           format("Nilai = ~2f~n", [N2])),

    judul("3. lulus(\"24013\")"),
    (   lulus("24013")
    ->  writeln(true)
    ;   writeln(false)
    ),

    judul("4. grade(\"24013\", Grade)"),
    forall(grade("24013", G4),
           format("Grade = ~w~n", [G4])),

    judul("5. grade(NIM, a)"),
    forall(grade(NIM5, a),
           format("NIM = ~w~n", [NIM5])),

    judul("6. berprestasi(NIM)"),
    forall(berprestasi(NIM6),
           format("NIM = ~w~n", [NIM6])),

    judul("7. perlu_bimbingan(NIM)"),
    forall(perlu_bimbingan(NIM7),
           format("NIM = ~w~n", [NIM7])),

    judul("8. unggul(NIM)"),
    forall(unggul(NIM8),
           format("NIM = ~w~n", [NIM8])),

    judul("9. nilai_tinggi(NIM)"),
    forall(nilai_tinggi(NIM9),
           format("NIM = ~w~n", [NIM9])),

    judul("10. aman(NIM)"),
    forall(aman(NIM10),
           format("NIM = ~w~n", [NIM10])),

    judul("11. teman_sekelas(\"24001\", X)"),
    forall(teman_sekelas("24001", X11),
           format("X = ~w~n", [X11])),

    judul("12. grade(NIM, a), unggul(NIM)"),
    forall((grade(NIM12, a), unggul(NIM12)),
           format("NIM = ~w~n", [NIM12])),

    judul("13. lulus(NIM), \\+ grade(NIM, a)"),
    forall((lulus(NIM13), \+ grade(NIM13, a)),
           format("NIM = ~w~n", [NIM13])),

    judul("14. perlu_bimbingan(NIM), nilai_akhir(NIM, Nilai), Nilai < 60"),
    forall((perlu_bimbingan(NIM14),
            nilai_akhir(NIM14, N14),
            N14 < 60),
           format("NIM = ~w, Nilai = ~2f~n", [NIM14, N14])).


% ============================================================
% BAGIAN 7 - DEMO PENGAMATAN
% Untuk mengisi Tabel Pengamatan Program 4.
% Urutan solusi di bawah sama dengan urutan yang muncul
% kalau kita menekan ; satu per satu di toplevel.
% Jalankan: swipl -q -g demo_pengamatan -t halt program4.pl
% ============================================================

cetak_solusi(_, []).
cetak_solusi(N, [S|Sisa]) :-
    format("solusi ke-~w : NIM = ~w~n", [N, S]),
    N2 is N + 1,
    cetak_solusi(N2, Sisa).

demo_pengamatan :-
    judul("BINDING - mahasiswa(\"24013\", Nama, Tugas, UTS, UAS)"),
    forall(mahasiswa("24013", Nama, Tugas, UTS, UAS),
           format("Nama = ~w~nTugas = ~w~nUTS = ~w~nUAS = ~w~n",
                  [Nama, Tugas, UTS, UAS])),

    judul("UNIFICATION - mahasiswa(NIM, \"Maya\", Tugas, UTS, UAS)"),
    forall(mahasiswa(NIM, "Maya", T2, U2, A2),
           format("NIM = ~w~nTugas = ~w~nUTS = ~w~nUAS = ~w~n",
                  [NIM, T2, U2, A2])),

    judul("STATE - jumlah fakta mahasiswa sebelum query"),
    aggregate_all(count, mahasiswa(_, _, _, _, _), Sebelum),
    format("jumlah fakta = ~w~n", [Sebelum]),

    judul("BACKTRACKING - grade(NIM, a) solusi demi solusi"),
    findall(N5, grade(N5, a), SolusiA),
    cetak_solusi(1, SolusiA),
    length(SolusiA, JumlahA),
    format("total solusi = ~w~n", [JumlahA]),

    judul("STATE - jumlah fakta mahasiswa sesudah query"),
    aggregate_all(count, mahasiswa(_, _, _, _, _), Sesudah),
    format("jumlah fakta = ~w~n", [Sesudah]),

    judul("INFERENCE - penelusuran grade(\"24013\", a)"),
    mahasiswa("24013", _, Tg, Us, Ua),
    format("fakta   : mahasiswa(\"24013\", _, ~w, ~w, ~w)~n", [Tg, Us, Ua]),
    nilai_akhir("24013", Nil),
    format("rule 1  : nilai_akhir(\"24013\", ~2f)~n", [Nil]),
    (   Nil >= 85
    ->  format("rule 3  : ~2f >= 85 terpenuhi, grade = a~n", [Nil])
    ;   format("rule 3  : ~2f >= 85 gagal~n", [Nil])
    ),

    judul("SEARCH - urutan solusi perlu_bimbingan(NIM)"),
    findall(N7, perlu_bimbingan(N7), SolusiB),
    cetak_solusi(1, SolusiB).
