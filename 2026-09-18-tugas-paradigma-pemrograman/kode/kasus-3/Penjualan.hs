import Data.List (foldl', sortOn)
import qualified Data.Map.Strict as M

data Transaksi = Transaksi
  { noTrx :: Int, tanggal, produk, kategori :: String
  , harga, jumlah :: Int, lokasi, pelanggan :: String }

nilai :: Transaksi -> Int
nilai t = harga t * jumlah t

total, rataRata :: [Transaksi] -> Int
total = foldl' (+) 0 . map nilai
rataRata ts = if null ts then 0 else total ts `div` length ts  -- dua lintasan

kelompokkan :: (Transaksi -> String) -> [Transaksi] -> M.Map String Int
kelompokkan kunci = M.fromListWith (+) . map (\t -> (kunci t, nilai t))

peringkat :: (Transaksi -> String) -> [Transaksi] -> [(String, Int)]
peringkat kunci = sortOn (negate . snd) . M.toList . kelompokkan kunci

-- laporan baru cukup merangkai fungsi yang sudah ada
laporanProduk :: [String] -> [Transaksi] -> [(String, Int)]
laporanProduk ps = peringkat kategori . filter ((`elem` ps) . produk)

dataTrx, april :: [Transaksi]
dataTrx =
  [ Transaksi 1 "2026-01-05" "Laptop" "Elektronik" 7500000 2 "Bandung" "Andi"
  , Transaksi 2 "2026-01-09" "Mouse" "Aksesoris" 150000 10 "Jakarta" "Sari"
  , Transaksi 3 "2026-02-11" "Pulpen" "ATK" 5000 200 "Bandung" "Budi"
  , Transaksi 4 "2026-02-14" "Laptop" "Elektronik" 7500000 1 "Surabaya" "Sari"
  , Transaksi 5 "2026-03-02" "Keyboard" "Aksesoris" 350000 4 "Bandung" "Dewi" ]
april = [Transaksi 6 "2026-04-03" "Mouse" "Aksesoris" 150000 5 "Jakarta" "Rina"]

main :: IO ()
main = do
  tampil "Total penjualan" (total dataTrx)
  tampil "Rata-rata transaksi" (rataRata dataTrx)
  tampil "Produk tertinggi" (take 1 (peringkat produk dataTrx))
  tampil "Per kategori" (peringkat kategori dataTrx)
  tampil "Per wilayah" (peringkat lokasi dataTrx)
  tampil "Laptop, Mouse" (laporanProduk ["Laptop", "Mouse"] dataTrx)
  tampil "Trx Bandung > 1 juta" (map noTrx (filter kriteria dataTrx))
  -- April masuk sebagai list baru, ringkasan lama tinggal digabung
  tampil "Lama+April = hitung ulang" (gabung == perKategori (dataTrx ++ april))
  tampil "Data asli" (length dataTrx, total dataTrx)
  where
    tampil label x = putStrLn (label ++ ": " ++ show x)
    kriteria t = lokasi t == "Bandung" && nilai t > 1000000
    perKategori = kelompokkan kategori
    gabung = M.unionWith (+) (perKategori dataTrx) (perKategori april)
