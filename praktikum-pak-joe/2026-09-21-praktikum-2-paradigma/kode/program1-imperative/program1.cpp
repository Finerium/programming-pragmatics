#include <iostream>
#include <iomanip>
#include <string>
using namespace std;

struct Mahasiswa {
    string nim;
    string nama;
    float tugas;
    float uts;
    float uas;
    float nilaiAkhir;
};

// =====================================================
// FUNGSI UNTUK MENGHITUNG NILAI AKHIR
// =====================================================
void hitungNilai(Mahasiswa mahasiswa[], int jumlah) {

    for (int i = 0; i < jumlah; i++) {

        mahasiswa[i].nilaiAkhir =
            (0.30 * mahasiswa[i].tugas) +
            (0.30 * mahasiswa[i].uts) +
            (0.40 * mahasiswa[i].uas);
    }
}


// =====================================================
// FUNGSI SORTING
// Mengurutkan nilai dari tertinggi ke terendah
// Menggunakan Bubble Sort
// =====================================================
void sortNilai(Mahasiswa mahasiswa[], int jumlah) {

    for (int i = 0; i < jumlah - 1; i++) {

        for (int j = 0; j < jumlah - 1 - i; j++) {

            if (mahasiswa[j].nilaiAkhir <
                mahasiswa[j + 1].nilaiAkhir) {

                Mahasiswa temp = mahasiswa[j];

                mahasiswa[j] = mahasiswa[j + 1];

                mahasiswa[j + 1] = temp;
            }
        }
    }
}


// =====================================================
// FUNGSI MENAMPILKAN DATA MAHASISWA
// =====================================================
void tampilkanMahasiswa(Mahasiswa m) {

    cout << left
         << setw(10) << m.nim
         << setw(12) << m.nama
         << setw(12) << fixed << setprecision(2)
         << m.nilaiAkhir
         << endl;
}


// =====================================================
// TAMBAHKAN FUNGSI SEARCH BERDASARKAN NIM
// =====================================================
void searchNIM(Mahasiswa mahasiswa[], int jumlah, string kunci) {

    int ketemu = 0;

    for (int i = 0; i < jumlah; i++) {

        if (mahasiswa[i].nim == kunci) {

            tampilkanMahasiswa(mahasiswa[i]);

            ketemu++;
        }
    }

    if (ketemu == 0) {

        cout << "Data dengan NIM " << kunci
             << " tidak ditemukan.\n";
    }
}


// =====================================================
// TAMBAHKAN FUNGSI SEARCH BERDASARKAN NAMA
// =====================================================
void searchNama(Mahasiswa mahasiswa[], int jumlah, string kunci) {

    int ketemu = 0;

    for (int i = 0; i < jumlah; i++) {

        if (mahasiswa[i].nama == kunci) {

            tampilkanMahasiswa(mahasiswa[i]);

            ketemu++;
        }
    }

    if (ketemu == 0) {

        cout << "Data dengan nama " << kunci
             << " tidak ditemukan.\n";
    }
}


// =====================================================
// TAMBAHKAN FUNGSI SEARCH BERDASARKAN NILAI
// Menampilkan mahasiswa dengan nilai >= batas
// =====================================================
void searchNilai(Mahasiswa mahasiswa[], int jumlah, float batas) {

    int ketemu = 0;

    for (int i = 0; i < jumlah; i++) {

        if (mahasiswa[i].nilaiAkhir >= batas) {

            tampilkanMahasiswa(mahasiswa[i]);

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


// =====================================================
// MENU SEARCH
// =====================================================
void menuFilter(Mahasiswa mahasiswa[], int jumlah) {

    int pilihan;

    cout << "\n====================================\n";
    cout << "             MENU FILTER\n";
    cout << "====================================\n";
    cout << "1. Search berdasarkan NIM\n";
    cout << "2. Search berdasarkan Nama\n";
    cout << "3. Search berdasarkan Nilai\n";
    cout << "4. Kembali\n";
    cout << "Pilihan: ";
    cin >> pilihan;

    switch (pilihan) {

        case 1: {

            string nim;

            cout << "Masukkan NIM: ";
            cin >> nim;

            cout << "\nHasil pencarian:\n";

            searchNIM(mahasiswa, jumlah, nim);

            break;
        }

        case 2: {

            string nama;

            cout << "Masukkan Nama: ";
            cin >> nama;

            cout << "\nHasil pencarian:\n";

            searchNama(mahasiswa, jumlah, nama);

            break;
        }

        case 3: {

            float nilai;

            cout << "Masukkan nilai minimum: ";
            cin >> nilai;

            cout << "\nHasil pencarian:\n";

            searchNilai(mahasiswa, jumlah, nilai);

            break;
        }

        case 4:
            break;

        default:
            cout << "Pilihan tidak valid.\n";
    }
}


// =====================================================
// PROGRAM UTAMA
// =====================================================
int main() {

    const int JUMLAH = 30;

    Mahasiswa mahasiswa[JUMLAH] = {

        {"24001", "Andi",   80, 75, 90},
        {"24002", "Budi",   70, 80, 75},
        {"24003", "Citra",  90, 85, 95},
        {"24004", "Deni",   65, 70, 60},
        {"24005", "Eka",    85, 90, 88},
        {"24006", "Fajar",  55, 65, 58},
        {"24007", "Gina",   78, 72, 80},
        {"24008", "Hadi",   92, 88, 94},
        {"24009", "Intan",  60, 68, 65},
        {"24010", "Joko",   75, 70, 72},
        {"24011", "Karin",  88, 82, 90},
        {"24012", "Luthfi", 68, 75, 70},
        {"24013", "Maya",   95, 92, 96},
        {"24014", "Nanda",  72, 65, 68},
        {"24015", "Olivia", 83, 78, 85},
        {"24016", "Putra",  58, 60, 55},
        {"24017", "Qori",   80, 85, 82},
        {"24018", "Raka",   74, 76, 79},
        {"24019", "Sinta",  90, 88, 91},
        {"24020", "Taufik", 62, 70, 64},
        {"24021", "Ulya",   86, 84, 89},
        {"24022", "Vina",   77, 80, 83},
        {"24023", "Wahyu",  69, 62, 67},
        {"24024", "Xena",   94, 90, 92},
        {"24025", "Yudha",  73, 68, 75},
        {"24026", "Zahra",  89, 93, 95},
        {"24027", "Bagas",  64, 58, 62},
        {"24028", "Rani",   81, 79, 86},
        {"24029", "Surya",  71, 74, 70},
        {"24030", "Tiara",  93, 87, 90}
    };


    // -------------------------------------------------
    // 1. HITUNG NILAI AKHIR
    // -------------------------------------------------

    hitungNilai(mahasiswa, JUMLAH);


    // -------------------------------------------------
    // 2. SORTING
    // -------------------------------------------------

    sortNilai(mahasiswa, JUMLAH);


    // -------------------------------------------------
    // 3. TAMPILKAN HASIL SORTING
    // -------------------------------------------------

    cout << "\n==============================================\n";
    cout << "     DAFTAR NILAI - TERTINGGI KE TERENDAH\n";
    cout << "==============================================\n";

    cout << left
         << setw(10) << "NIM"
         << setw(12) << "Nama"
         << setw(12) << "Nilai"
         << endl;

    cout << "----------------------------------------------\n";

    for (int i = 0; i < JUMLAH; i++) {

        tampilkanMahasiswa(mahasiswa[i]);
    }


    // -------------------------------------------------
    // 4. MENU FILTER
    // -------------------------------------------------

    int ulang = 1;

    while (ulang == 1) {

        menuFilter(mahasiswa, JUMLAH);

        cout << "\nFilter lagi? (1 = Ya, 0 = Tidak): ";
        cin >> ulang;
    }


    cout << "\nProgram selesai.\n";

    return 0;
}
