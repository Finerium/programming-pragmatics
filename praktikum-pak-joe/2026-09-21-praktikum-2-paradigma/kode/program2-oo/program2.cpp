#include <iostream>
#include <iomanip>
#include <string>
using namespace std;

// ======================================================
// CLASS MAHASISWA
// Merepresentasikan satu objek mahasiswa
// ======================================================

class Mahasiswa {

private:
    string nim;
    string nama;
    float tugas;
    float uts;
    float uas;
    float nilaiAkhir;

public:
    // Constructor
    Mahasiswa(string nim, string nama,
              float tugas, float uts, float uas) {
        this->nim = nim;
        this->nama = nama;
        this->tugas = tugas;
        this->uts = uts;
        this->uas = uas;

        hitungNilai();
    }


    // Menghitung nilai akhir
    void hitungNilai() {

        nilaiAkhir =
            (0.30 * tugas) +
            (0.30 * uts) +
            (0.40 * uas);
    }


    // Getter
    string getNIM() {
        return nim;
    }

    string getNama() {
        return nama;
    }

    float getNilai() {
        return nilaiAkhir;
    }


    // Menampilkan data mahasiswa
    void tampilkan() {

        cout << left
             << setw(10) << nim
             << setw(12) << nama
             << setw(12)
             << fixed << setprecision(2)
             << nilaiAkhir
             << endl;
    }
};


// ======================================================
// CLASS SISTEM AKADEMIK
// Mengelola kumpulan objek Mahasiswa
// ======================================================

class SistemAkademik {

private:

    Mahasiswa* mahasiswa[30];
    int jumlah;

public:

    // Constructor
    SistemAkademik() {
        jumlah = 0;
    }


    // Menambahkan mahasiswa
    void tambahMahasiswa(Mahasiswa* m) {

        if (jumlah < 30) {

            mahasiswa[jumlah] = m;
            jumlah++;
        }
    }


    // ==================================================
    // SORTING
    // Nilai tertinggi -> terendah
    // ==================================================

    void sortNilai() {

        for (int i = 0; i < jumlah - 1; i++) {

            for (int j = 0; j < jumlah - 1 - i; j++) {

                if (mahasiswa[j]->getNilai() <
                    mahasiswa[j + 1]->getNilai()) {

                    Mahasiswa* temp = mahasiswa[j];

                    mahasiswa[j] = mahasiswa[j + 1];

                    mahasiswa[j + 1] = temp;
                }
            }
        }
    }



    // ==================================================
    // MENAMPILKAN SEMUA MAHASISWA
    // ==================================================

    void tampilkanSemua() {

        cout << "\n========================================\n";
        cout << "       DAFTAR NILAI MAHASISWA\n";
        cout << "========================================\n";

        cout << left
             << setw(10) << "NIM"
             << setw(12) << "Nama"
             << setw(12) << "Nilai"
             << endl;

        cout << "----------------------------------------\n";

        for (int i = 0; i < jumlah; i++) {

            mahasiswa[i]->tampilkan();
        }
    }


    // ==================================================
    // TAMBAHKAN FILTER BERDASARKAN NIM
    // ==================================================

    void filterNIM(string kunci) {

        int ketemu = 0;

        for (int i = 0; i < jumlah; i++) {

            if (mahasiswa[i]->getNIM() == kunci) {

                mahasiswa[i]->tampilkan();

                ketemu++;
            }
        }

        if (ketemu == 0) {

            cout << "Data dengan NIM " << kunci
                 << " tidak ditemukan.\n";
        }
    }


    // ==================================================
    // TAMBAHKAN FILTER BERDASARKAN NAMA
    // ==================================================

    void filterNama(string kunci) {

        int ketemu = 0;

        for (int i = 0; i < jumlah; i++) {

            if (mahasiswa[i]->getNama() == kunci) {

                mahasiswa[i]->tampilkan();

                ketemu++;
            }
        }

        if (ketemu == 0) {

            cout << "Data dengan nama " << kunci
                 << " tidak ditemukan.\n";
        }
    }


    // ==================================================
    // TAMBAHKAN FILTER BERDASARKAN NILAI
    // Menampilkan nilai >= batas
    // ==================================================

    void filterNilai(float batas) {

        int ketemu = 0;

        for (int i = 0; i < jumlah; i++) {

            if (mahasiswa[i]->getNilai() >= batas) {

                mahasiswa[i]->tampilkan();

                ketemu++;
            }
        }

        if (ketemu == 0) {

            cout << "Tidak ada mahasiswa dengan nilai >= "
                 << batas << ".\n";
        } else {

            cout << "Jumlah data: " << ketemu << endl;
        }
    }


    // ==================================================
    // MENU FILTER
    // ==================================================

    void menuFilter() {

        int pilihan;

        cout << "\n========================================\n";
        cout << "              MENU FILTER\n";
        cout << "========================================\n";
        cout << "1. Filter berdasarkan NIM\n";
        cout << "2. Filter berdasarkan Nama\n";
        cout << "3. Filter berdasarkan Nilai\n";
        cout << "4. Kembali\n";
        cout << "Pilihan: ";

        cin >> pilihan;


        switch (pilihan) {

            case 1: {

                string nim;

                cout << "Masukkan NIM: ";
                cin >> nim;

                cout << "\nHasil pencarian:\n";

                filterNIM(nim);

                break;
            }


            case 2: {

                string nama;

                cout << "Masukkan Nama: ";
                cin >> nama;

                cout << "\nHasil pencarian:\n";

                filterNama(nama);

                break;
            }


            case 3: {

                float nilai;

                cout << "Masukkan nilai minimum: ";
                cin >> nilai;

                cout << "\nHasil pencarian:\n";

                filterNilai(nilai);

                break;
            }


            case 4:
                break;


            default:

                cout << "Pilihan tidak valid.\n";
        }
    }
};


// ======================================================
// MAIN PROGRAM
// ======================================================

int main() {

    // Membuat objek sistem akademik

    SistemAkademik sistem;


    // ==================================================
    // MEMBUAT OBJEK MAHASISWA
    // ==================================================

    sistem.tambahMahasiswa(
        new Mahasiswa("24001", "Andi", 80, 75, 90));

    sistem.tambahMahasiswa(
        new Mahasiswa("24002", "Budi", 70, 80, 75));

    sistem.tambahMahasiswa(
        new Mahasiswa("24003", "Citra", 90, 85, 95));

    sistem.tambahMahasiswa(
        new Mahasiswa("24004", "Deni", 65, 70, 60));

    sistem.tambahMahasiswa(
        new Mahasiswa("24005", "Eka", 85, 90, 88));

    sistem.tambahMahasiswa(
        new Mahasiswa("24006", "Fajar", 55, 65, 58));

    sistem.tambahMahasiswa(
        new Mahasiswa("24007", "Gina", 78, 72, 80));

    sistem.tambahMahasiswa(
        new Mahasiswa("24008", "Hadi", 92, 88, 94));

    sistem.tambahMahasiswa(
        new Mahasiswa("24009", "Intan", 60, 68, 65));

    sistem.tambahMahasiswa(
        new Mahasiswa("24010", "Joko", 75, 70, 72));

    sistem.tambahMahasiswa(
        new Mahasiswa("24011", "Karin", 88, 82, 90));

    sistem.tambahMahasiswa(
        new Mahasiswa("24012", "Luthfi", 68, 75, 70));

    sistem.tambahMahasiswa(
        new Mahasiswa("24013", "Maya", 95, 92, 96));

    sistem.tambahMahasiswa(
        new Mahasiswa("24014", "Nanda", 72, 65, 68));

    sistem.tambahMahasiswa(
        new Mahasiswa("24015", "Olivia", 83, 78, 85));

    sistem.tambahMahasiswa(
        new Mahasiswa("24016", "Putra", 58, 60, 55));

    sistem.tambahMahasiswa(
        new Mahasiswa("24017", "Qori", 80, 85, 82));

    sistem.tambahMahasiswa(
        new Mahasiswa("24018", "Raka", 74, 76, 79));

    sistem.tambahMahasiswa(
        new Mahasiswa("24019", "Sinta", 90, 88, 91));

    sistem.tambahMahasiswa(
        new Mahasiswa("24020", "Taufik", 62, 70, 64));

    sistem.tambahMahasiswa(
        new Mahasiswa("24021", "Ulya", 86, 84, 89));

    sistem.tambahMahasiswa(
        new Mahasiswa("24022", "Vina", 77, 80, 83));

    sistem.tambahMahasiswa(
        new Mahasiswa("24023", "Wahyu", 69, 62, 67));

    sistem.tambahMahasiswa(
        new Mahasiswa("24024", "Xena", 94, 90, 92));

    sistem.tambahMahasiswa(
        new Mahasiswa("24025", "Yudha", 73, 68, 75));

    sistem.tambahMahasiswa(
        new Mahasiswa("24026", "Zahra", 89, 93, 95));

    sistem.tambahMahasiswa(
        new Mahasiswa("24027", "Bagas", 64, 58, 62));

    sistem.tambahMahasiswa(
        new Mahasiswa("24028", "Rani", 81, 79, 86));

    sistem.tambahMahasiswa(
        new Mahasiswa("24029", "Surya", 71, 74, 70));

    sistem.tambahMahasiswa(
        new Mahasiswa("24030", "Tiara", 93, 87, 90));


    // ==================================================
    // SORTING
    // ==================================================

    sistem.sortNilai();


    // ==================================================
    // TAMPILKAN DATA
    // ==================================================

    sistem.tampilkanSemua();


    // ==================================================
    // MENU FILTER
    // ==================================================

    int ulang = 1;

    while (ulang == 1) {

        sistem.menuFilter();

        cout << "\nFilter lagi? (1 = Ya, 0 = Tidak): ";
        cin >> ulang;
    }
    cout << "\nProgram selesai.\n";
    return 0;
}
