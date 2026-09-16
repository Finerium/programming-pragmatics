-- Latihan pertama Haskell, mengikuti bab Starting Out di Learn You a Haskell.
-- Cara pakai: buka ghci, lalu ketik :l baby.hs dan panggil fungsinya satu per satu.

doubleMe x = x + x

doubleUs x y = doubleMe x + doubleMe y

-- if di Haskell wajib punya else, karena if adalah ekspresi yang harus menghasilkan nilai
doubleSmallNumber x = if x > 100 then x else x * 2

-- tanda kutip di akhir nama itu karakter biasa, biasanya dipakai untuk versi lain fungsi yang sama
doubleSmallNumber' x = (if x > 100 then x else x * 2) + 1

-- fungsi tanpa parameter sebenarnya cuma definisi sebuah nilai
conanO'Brien = "It's a-me, Conan O'Brien!"

lostNumbers = [4, 8, 15, 16, 23, 42]

-- list comprehension, mirip notasi himpunan di matematika diskrit
boomBangs xs = [if x < 10 then "BOOM!" else "BANG!" | x <- xs, odd x]

-- semua segitiga siku-siku dengan sisi maksimal 10 dan keliling 24
rightTriangles = [(a, b, c) | c <- [1..10], b <- [1..c], a <- [1..b],
                              a^2 + b^2 == c^2, a + b + c == 24]
