import Data.List (sortBy)
import Data.Ord (comparing)

-- =====================================================
-- DATA MAHASISWA
-- =====================================================

data Mahasiswa = Mahasiswa
    { nim   :: String
    , nama  :: String
    , tugas :: Float
    , uts   :: Float
    , uas   :: Float
    } deriving (Show)


-- =====================================================
-- 1. PURE FUNCTION
-- Menghitung nilai akhir
-- Tidak mengubah data mahasiswa
-- =====================================================

nilaiAkhir :: Mahasiswa -> Float
nilaiAkhir m =
    0.30 * tugas m +
    0.30 * uts m +
    0.40 * uas m


-- =====================================================
-- 2. PURE FUNCTION
-- Menentukan grade
-- =====================================================

grade :: Float -> String
grade nilai
    | nilai >= 85 = "A"
    | nilai >= 75 = "B"
    | nilai >= 65 = "C"
    | nilai >= 55 = "D"
    | otherwise   = "E"


-- =====================================================
-- 3. MENAMPILKAN DATA
-- =====================================================

tampilkan :: Mahasiswa -> IO ()
tampilkan m =
    putStrLn $
        nim m ++ " | " ++
        nama m ++ " | Nilai: " ++
        show (nilaiAkhir m) ++
        " | Grade: " ++
        grade (nilaiAkhir m)


-- =====================================================
-- 4. SORTING
-- Nilai tertinggi -> terendah
-- =====================================================

sortNilai :: [Mahasiswa] -> [Mahasiswa]
sortNilai =
    sortBy (flip (comparing nilaiAkhir))


-- =====================================================
-- 5. TAMBAHKAN SEARCH BERDASARKAN NIM
-- =====================================================

searchNIM :: String -> [Mahasiswa] -> [Mahasiswa]
searchNIM kunci =
    filter (\m -> nim m == kunci)


-- =====================================================
-- 6. TAMBAHKAN SEARCH BERDASARKAN NAMA
-- =====================================================

searchNama :: String -> [Mahasiswa] -> [Mahasiswa]
searchNama kunci =
    filter (\m -> nama m == kunci)


-- =====================================================
-- 7. TAMBAHKAN FILTER BERDASARKAN NILAI
-- =====================================================

filterNilai :: Float -> [Mahasiswa] -> [Mahasiswa]
filterNilai batas =
    filter (\m -> nilaiAkhir m >= batas)


-- =====================================================
-- 8. MAP
-- Mengubah setiap mahasiswa menjadi nilai akhirnya
-- =====================================================

semuaNilai :: [Mahasiswa] -> [Float]
semuaNilai =
    map nilaiAkhir


-- =====================================================
-- 9. FOLD
-- Menghitung total nilai
-- =====================================================

totalNilai :: [Mahasiswa] -> Float
totalNilai mahasiswa =
    foldr (\m total ->
        nilaiAkhir m + total
    ) 0 mahasiswa


-- =====================================================
-- 10. RATA-RATA
-- =====================================================

rataRata :: [Mahasiswa] -> Float
rataRata mahasiswa =
    totalNilai mahasiswa /
    fromIntegral (length mahasiswa)


-- =====================================================
-- DATA 30 MAHASISWA
-- =====================================================

mahasiswa :: [Mahasiswa]
mahasiswa =
    [ Mahasiswa "24001" "Andi"   80 75 90
    , Mahasiswa "24002" "Budi"   70 80 75
    , Mahasiswa "24003" "Citra"  90 85 95
    , Mahasiswa "24004" "Deni"   65 70 60
    , Mahasiswa "24005" "Eka"    85 90 88
    , Mahasiswa "24006" "Fajar"  55 65 58
    , Mahasiswa "24007" "Gina"   78 72 80
    , Mahasiswa "24008" "Hadi"   92 88 94
    , Mahasiswa "24009" "Intan"  60 68 65
    , Mahasiswa "24010" "Joko"   75 70 72
    , Mahasiswa "24011" "Karin"  88 82 90
    , Mahasiswa "24012" "Luthfi" 68 75 70
    , Mahasiswa "24013" "Maya"   95 92 96
    , Mahasiswa "24014" "Nanda"  72 65 68
    , Mahasiswa "24015" "Olivia" 83 78 85
    , Mahasiswa "24016" "Putra"  58 60 55
    , Mahasiswa "24017" "Qori"   80 85 82
    , Mahasiswa "24018" "Raka"   74 76 79
    , Mahasiswa "24019" "Sinta"  90 88 91
    , Mahasiswa "24020" "Taufik" 62 70 64
    , Mahasiswa "24021" "Ulya"   86 84 89
    , Mahasiswa "24022" "Vina"   77 80 83
    , Mahasiswa "24023" "Wahyu"  69 62 67
    , Mahasiswa "24024" "Xena"   94 90 92
    , Mahasiswa "24025" "Yudha"  73 68 75
    , Mahasiswa "24026" "Zahra"  89 93 95
    , Mahasiswa "24027" "Bagas"  64 58 62
    , Mahasiswa "24028" "Rani"   81 79 86
    , Mahasiswa "24029" "Surya"  71 74 70
    , Mahasiswa "24030" "Tiara"  93 87 90
    ]


-- =====================================================
-- PROGRAM UTAMA
-- =====================================================

main :: IO ()
main = do

    -- -----------------------------------------------
    -- SORTING
    -- -----------------------------------------------

    putStrLn "\n=== NILAI TERTINGGI -> TERENDAH ==="

    mapM_ tampilkan (sortNilai mahasiswa)


    -- -----------------------------------------------
    -- SEARCH NIM
    -- -----------------------------------------------

    putStrLn "\n=== SEARCH NIM: 24013 ==="

    mapM_ tampilkan
        (searchNIM "24013" mahasiswa)


    -- -----------------------------------------------
    -- SEARCH NAMA
    -- -----------------------------------------------

    putStrLn "\n=== SEARCH NAMA: Maya ==="

    mapM_ tampilkan
        (searchNama "Maya" mahasiswa)


    -- -----------------------------------------------
    -- FILTER NILAI
    -- -----------------------------------------------

    putStrLn "\n=== NILAI >= 80 ==="

    mapM_ tampilkan
        (filterNilai 80 mahasiswa)

    -- -----------------------------------------------
    -- MAP
    -- -----------------------------------------------

    putStrLn "\n=== SEMUA NILAI AKHIR ==="

    print (semuaNilai mahasiswa)


    -- -----------------------------------------------
    -- FOLD
    -- -----------------------------------------------

    putStrLn "\n=== RATA-RATA KELAS ==="

    print (rataRata mahasiswa)
