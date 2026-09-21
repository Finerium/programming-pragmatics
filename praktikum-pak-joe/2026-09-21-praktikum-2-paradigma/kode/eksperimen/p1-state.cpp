// Eksperimen state Program 1.
// Mencatat nilaiAkhir sebelum dan sesudah hitungNilai(),
// serta posisi dua mahasiswa sebelum dan sesudah sortNilai().
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

void hitungNilai(Mahasiswa mahasiswa[], int jumlah) {
    for (int i = 0; i < jumlah; i++) {
        mahasiswa[i].nilaiAkhir =
            (0.30 * mahasiswa[i].tugas) +
            (0.30 * mahasiswa[i].uts) +
            (0.40 * mahasiswa[i].uas);
    }
}

void sortNilai(Mahasiswa mahasiswa[], int jumlah) {
    for (int i = 0; i < jumlah - 1; i++) {
        for (int j = 0; j < jumlah - 1 - i; j++) {
            if (mahasiswa[j].nilaiAkhir < mahasiswa[j + 1].nilaiAkhir) {
                Mahasiswa temp = mahasiswa[j];
                mahasiswa[j] = mahasiswa[j + 1];
                mahasiswa[j + 1] = temp;
            }
        }
    }
}

int cariIndeks(Mahasiswa mahasiswa[], int jumlah, string nim) {
    for (int i = 0; i < jumlah; i++) {
        if (mahasiswa[i].nim == nim) return i;
    }
    return -1;
}

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

    cout << fixed << setprecision(2);

    cout << "[1] STATE SEBELUM hitungNilai()\n";
    cout << "    mahasiswa[0]  " << mahasiswa[0].nama
         << " nilaiAkhir = " << mahasiswa[0].nilaiAkhir << endl;
    cout << "    mahasiswa[12] " << mahasiswa[12].nama
         << " nilaiAkhir = " << mahasiswa[12].nilaiAkhir << endl;

    hitungNilai(mahasiswa, JUMLAH);

    cout << "\n[2] STATE SESUDAH hitungNilai()\n";
    cout << "    mahasiswa[0]  " << mahasiswa[0].nama
         << " nilaiAkhir = " << mahasiswa[0].nilaiAkhir << endl;
    cout << "    mahasiswa[12] " << mahasiswa[12].nama
         << " nilaiAkhir = " << mahasiswa[12].nilaiAkhir << endl;

    cout << "\n[3] POSISI SEBELUM sortNilai()\n";
    cout << "    Andi ada di indeks " << cariIndeks(mahasiswa, JUMLAH, "24001") << endl;
    cout << "    Maya ada di indeks " << cariIndeks(mahasiswa, JUMLAH, "24013") << endl;

    sortNilai(mahasiswa, JUMLAH);

    cout << "\n[4] POSISI SESUDAH sortNilai()\n";
    cout << "    Andi ada di indeks " << cariIndeks(mahasiswa, JUMLAH, "24001") << endl;
    cout << "    Maya ada di indeks " << cariIndeks(mahasiswa, JUMLAH, "24013") << endl;

    cout << "\n[5] URUTAN EKSEKUSI for (int i = 0; i < 3; i++)\n";
    for (int i = 0; i < 3; i++) {
        cout << "    body jalan dengan i = " << i << endl;
    }

    cout << "\n[6] SORT DULU BARU HITUNG (urutan statement ditukar)\n";
    Mahasiswa uji[3] = {
        {"24016", "Putra", 58, 60, 55},
        {"24013", "Maya",  95, 92, 96},
        {"24001", "Andi",  80, 75, 90}
    };
    sortNilai(uji, 3);
    hitungNilai(uji, 3);
    for (int i = 0; i < 3; i++) {
        cout << "    indeks " << i << " = " << uji[i].nama
             << " nilai " << uji[i].nilaiAkhir << endl;
    }

    return 0;
}
