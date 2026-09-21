% Latihan pertama SWI-Prolog: fakta, aturan, dan query.
% Jalankan: swipl -q -f keluarga.pl -g uji -t halt

% --- fakta
ayah(budi, ani).
ayah(budi, cici).
ayah(dedi, budi).
ibu(sari, ani).
ibu(sari, cici).
ibu(ratna, budi).

laki(budi).
laki(dedi).
perempuan(ani).
perempuan(cici).
perempuan(sari).
perempuan(ratna).

% --- aturan
orangtua(X, Y) :- ayah(X, Y).
orangtua(X, Y) :- ibu(X, Y).

saudara(X, Y) :- orangtua(Z, X), orangtua(Z, Y), X \= Y.

kakek(X, Y) :- ayah(X, Z), orangtua(Z, Y).

keturunan(X, Y) :- orangtua(Y, X).
keturunan(X, Y) :- orangtua(Z, X), keturunan(Z, Y).

% --- rekursi angka, mirip fungsi rekursif di bahasa lain
faktorial(0, 1).
faktorial(N, H) :- N > 0, M is N - 1, faktorial(M, H1), H is N * H1.

uji :-
    format("anak dari budi   : "), findall(A, ayah(budi, A), L1), writeln(L1),
    format("orangtua ani     : "), findall(O, orangtua(O, ani), L2), writeln(L2),
    % findall memberi [cici,cici] karena cici ketemu lewat ayah dan lewat ibu,
    % setof membuang duplikat sekaligus mengurutkan hasilnya
    format("saudara ani      : "), setof(S, saudara(ani, S), L3), writeln(L3),
    format("kakek dari ani   : "), findall(K, kakek(K, ani), L4), writeln(L4),
    format("keturunan dedi   : "), findall(T, keturunan(T, dedi), L5), writeln(L5),
    format("faktorial 5      : "), faktorial(5, F), writeln(F),
    format("apakah budi laki : "), ( laki(budi) -> writeln(ya) ; writeln(bukan) ).
