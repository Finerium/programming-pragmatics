-- Eksperimen scope Program 3.
-- Memakai m di luar lambda \m -> ...
data Mahasiswa = Mahasiswa { nim :: String, uas :: Float }

daftar :: [Mahasiswa]
daftar = [Mahasiswa "24013" 96, Mahasiswa "24016" 55]

hasil :: [Mahasiswa]
hasil = filter (\m -> uas m >= 80) daftar

main :: IO ()
main = do
    mapM_ (putStrLn . nim) hasil
    putStrLn (nim m)   -- sengaja error, m hanya hidup di dalam lambda
