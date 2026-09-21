-- Ringkasan latihan bab Starting Out, dijadikan satu program supaya hasilnya gampang disimpan.
-- Jalankan: runghc latihan.hs

import Data.Char (toUpper)

doubleMe :: Int -> Int
doubleMe x = x + x

doubleSmallNumber :: Int -> Int
doubleSmallNumber x = if x > 100 then x else x * 2

boomBangs :: [Int] -> [String]
boomBangs xs = [if x < 10 then "BOOM!" else "BANG!" | x <- xs, odd x]

rightTriangles :: [(Int, Int, Int)]
rightTriangles = [(a, b, c) | c <- [1..10], b <- [1..c], a <- [1..b],
                              a^2 + b^2 == c^2, a + b + c == 24]

-- pattern matching, gaya penulisan fungsi yang paling sering dipakai di Haskell
faktorial :: Integer -> Integer
faktorial 0 = 1
faktorial n = n * faktorial (n - 1)

-- guard, mirip if bertingkat tapi lebih rapi
nilaiHuruf :: Int -> String
nilaiHuruf n
  | n >= 80   = "A"
  | n >= 70   = "B"
  | n >= 60   = "C"
  | n >= 50   = "D"
  | otherwise = "E"

main :: IO ()
main = do
  putStrLn ("doubleMe 9             = " ++ show (doubleMe 9))
  putStrLn ("doubleSmallNumber 101  = " ++ show (doubleSmallNumber 101))
  putStrLn ("lostNumbers            = " ++ show [4, 8, 15, 16, 23, 42 :: Int])
  putStrLn ("head/last              = " ++ show (head lost, last lost))
  putStrLn ("take 3 dan reverse     = " ++ show (take 3 lost, reverse lost))
  putStrLn ("range [2,4..20]        = " ++ show ([2,4..20] :: [Int]))
  putStrLn ("take 10 (cycle [1,2,3])= " ++ show (take 10 (cycle [1, 2, 3 :: Int])))
  putStrLn ("boomBangs [7..13]      = " ++ show (boomBangs [7..13]))
  putStrLn ("rightTriangles         = " ++ show rightTriangles)
  putStrLn ("zip nama dan umur      = " ++ show (zip ["ani", "budi", "cici"] [19, 20, 21 :: Int]))
  putStrLn ("faktorial 20           = " ++ show (faktorial 20))
  putStrLn ("nilai 85, 72, 45       = " ++ show (map nilaiHuruf [85, 72, 45]))
  putStrLn ("huruf besar            = " ++ map toUpper "programming pragmatics")
  where lost = [4, 8, 15, 16, 23, 42] :: [Int]
