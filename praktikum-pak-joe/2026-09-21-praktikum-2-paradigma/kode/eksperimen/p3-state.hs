-- Eksperimen state dan immutability Program 3.
-- Membandingkan list sebelum dan sesudah filter, map, dan sort.
import Data.List (sortBy)
import Data.Ord (comparing)

data Mahasiswa = Mahasiswa
    { nim   :: String
    , nama  :: String
    , tugas :: Float
    , uts   :: Float
    , uas   :: Float
    } deriving (Show)

nilaiAkhir :: Mahasiswa -> Float
nilaiAkhir m = 0.30 * tugas m + 0.30 * uts m + 0.40 * uas m

daftar :: [Mahasiswa]
daftar =
    [ Mahasiswa "24001" "Andi"  80 75 90
    , Mahasiswa "24013" "Maya"  95 92 96
    , Mahasiswa "24016" "Putra" 58 60 55
    , Mahasiswa "24006" "Fajar" 55 65 58
    ]

main :: IO ()
main = do
    putStrLn "[1] LIST AWAL"
    print (map nim daftar)
    putStrLn ("panjang = " ++ show (length daftar))

    putStrLn "\n[2] HASIL filter nilai >= 80"
    print (map nim (filter (\m -> nilaiAkhir m >= 80) daftar))

    putStrLn "\n[3] LIST AWAL DICETAK LAGI SESUDAH filter"
    print (map nim daftar)
    putStrLn ("panjang = " ++ show (length daftar))

    putStrLn "\n[4] nilaiAkhir DIPANGGIL DUA KALI UNTUK DATA YANG SAMA"
    let maya = daftar !! 1
    print (nilaiAkhir maya)
    print (nilaiAkhir maya)
    putStrLn ("uas Maya tetap = " ++ show (uas maya))

    putStrLn "\n[5] KOMPOSISI filter LALU map"
    print (map nilaiAkhir (filter (\m -> nilaiAkhir m >= 80) daftar))

    putStrLn "\n[6] SORT MENGHASILKAN LIST BARU"
    print (map nim (sortBy (flip (comparing nilaiAkhir)) daftar))
    print (map nim daftar)
