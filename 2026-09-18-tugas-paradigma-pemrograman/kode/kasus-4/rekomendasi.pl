% Kasus 4: sistem pakar rekomendasi olahraga (SWI-Prolog)
:- initialization(main, main).
:- dynamic bmi/2, tujuan/2, keluhan/2, butuh/2, olahraga/3.

% Fakta kondisi pengguna, hasil isian form (masuk lewat assertz)
bmi(budi, 28).
bmi(sari, 21).
bmi(dodi, 22).
tujuan(budi, turun_berat).
tujuan(sari, turun_berat).
tujuan(sari, kelenturan).
tujuan(dodi, turun_berat).
keluhan(sari, nyeri_lutut).

% Fakta dari pakar: olahraga(Nama, Jenis, DampakKeSendi)
olahraga(renang, kardio, rendah).
olahraga(lari, kardio, tinggi).
olahraga(sepeda_statis, kardio, rendah).
olahraga(yoga, kelenturan, rendah).

% Aturan pakar, kesimpulan satu aturan dipakai aturan berikutnya
berat_berlebih(P) :- bmi(P, B), B >= 25.
sendi_rentan(P) :- keluhan(P, nyeri_lutut).
sendi_rentan(P) :- berat_berlebih(P).
butuh(P, kardio) :- tujuan(P, turun_berat).
butuh(P, kardio) :- berat_berlebih(P).
butuh(P, kelenturan) :- tujuan(P, kelenturan).
% \+ artinya "tidak bisa dibuktikan", bukan "terbukti tidak"
aman(_, O) :- olahraga(O, _, rendah).
aman(P, O) :- olahraga(O, _, tinggi), \+ sendi_rentan(P).
rekomendasi(P, O) :- butuh(P, J), olahraga(O, J, _), aman(P, O).

% Query dari sisi pengguna
cek(G) :- (call(G) -> R = true ; R = false), format("?- ~w. ~w~n", [G, R]).
tampil(P) :-
    findall(O, rekomendasi(P, O), Semua),  % backtracking sampai habis
    sort(Semua, Unik),                     % buang jawaban ganda
    format("~w: ~w~n  unik: ~w~n", [P, Semua, Unik]).

main :-
    forall(bmi(U, _), tampil(U)),
    cek(sendi_rentan(budi)),  % terbukti lewat berat_berlebih, bukan keluhan
    cek(rekomendasi(budi, lari)),
    findall(P, rekomendasi(P, yoga), Ps),  % query dibalik: siapa cocok yoga
    format("?- rekomendasi(P,yoga). semua P: ~w~n", [Ps]),
    % pakar menambah aturan dan fakta, mesin pencarian tidak diubah
    assertz((butuh(X, kelenturan) :- sendi_rentan(X))),
    assertz(olahraga(pilates, kelenturan, rendah)),
    writeln('setelah pakar menambah aturan dan fakta:'),
    tampil(budi).
