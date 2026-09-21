// Eksperimen state, encapsulation, dan lifetime Program 2.
// 1. membuktikan 30 objek punya state masing-masing
// 2. membandingkan lifetime objek stack dan objek hasil new
#include <iostream>
#include <iomanip>
#include <string>
using namespace std;

class Mahasiswa {
private:
    string nim;
    string nama;
    float tugas;
    float uts;
    float uas;
    float nilaiAkhir;

public:
    Mahasiswa(string nim, string nama, float tugas, float uts, float uas) {
        this->nim = nim;
        this->nama = nama;
        this->tugas = tugas;
        this->uts = uts;
        this->uas = uas;
        hitungNilai();
        cout << "  constructor objek " << this->nim << endl;
    }

    ~Mahasiswa() {
        cout << "  destructor objek " << nim << endl;
    }

    void hitungNilai() {
        nilaiAkhir = (0.30 * tugas) + (0.30 * uts) + (0.40 * uas);
    }

    void setUAS(float nilaiBaru) { uas = nilaiBaru; }

    string getNIM() { return nim; }
    float getNilai() { return nilaiAkhir; }
};

struct Baris {
    const char* nim;
    const char* nama;
    float tugas;
    float uts;
    float uas;
};

int main() {
    cout << fixed << setprecision(2);

    Baris data[30] = {
        {"24001", "Andi",   80, 75, 90}, {"24002", "Budi",   70, 80, 75},
        {"24003", "Citra",  90, 85, 95}, {"24004", "Deni",   65, 70, 60},
        {"24005", "Eka",    85, 90, 88}, {"24006", "Fajar",  55, 65, 58},
        {"24007", "Gina",   78, 72, 80}, {"24008", "Hadi",   92, 88, 94},
        {"24009", "Intan",  60, 68, 65}, {"24010", "Joko",   75, 70, 72},
        {"24011", "Karin",  88, 82, 90}, {"24012", "Luthfi", 68, 75, 70},
        {"24013", "Maya",   95, 92, 96}, {"24014", "Nanda",  72, 65, 68},
        {"24015", "Olivia", 83, 78, 85}, {"24016", "Putra",  58, 60, 55},
        {"24017", "Qori",   80, 85, 82}, {"24018", "Raka",   74, 76, 79},
        {"24019", "Sinta",  90, 88, 91}, {"24020", "Taufik", 62, 70, 64},
        {"24021", "Ulya",   86, 84, 89}, {"24022", "Vina",   77, 80, 83},
        {"24023", "Wahyu",  69, 62, 67}, {"24024", "Xena",   94, 90, 92},
        {"24025", "Yudha",  73, 68, 75}, {"24026", "Zahra",  89, 93, 95},
        {"24027", "Bagas",  64, 58, 62}, {"24028", "Rani",   81, 79, 86},
        {"24029", "Surya",  71, 74, 70}, {"24030", "Tiara",  93, 87, 90}
    };

    cout << "[1] MEMBUAT 30 OBJEK (constructor dimatikan outputnya untuk 30 data)\n";
    cout.setstate(ios::failbit);
    Mahasiswa* daftar[30];
    for (int i = 0; i < 30; i++) {
        daftar[i] = new Mahasiswa(data[i].nim, data[i].nama,
                                  data[i].tugas, data[i].uts, data[i].uas);
    }
    cout.clear();

    cout << "    alamat objek 0  = " << daftar[0]
         << " nilai = " << daftar[0]->getNilai() << endl;
    cout << "    alamat objek 12 = " << daftar[12]
         << " nilai = " << daftar[12]->getNilai() << endl;
    cout << "    alamat objek 29 = " << daftar[29]
         << " nilai = " << daftar[29]->getNilai() << endl;

    cout << "\n[2] MENGUBAH UAS OBJEK 12 SAJA LALU hitungNilai() ULANG\n";
    daftar[12]->setUAS(50);
    daftar[12]->hitungNilai();
    cout << "    objek 0  nilai = " << daftar[0]->getNilai() << endl;
    cout << "    objek 12 nilai = " << daftar[12]->getNilai() << endl;
    cout << "    objek 29 nilai = " << daftar[29]->getNilai() << endl;

    cout << "\n[3] LIFETIME OBJEK STACK\n";
    {
        Mahasiswa lokal("99001", "Uji", 70, 70, 70);
        cout << "  masih di dalam blok, nilai = " << lokal.getNilai() << endl;
    }
    cout << "  sudah keluar blok\n";

    cout << "\n[4] LIFETIME OBJEK new TANPA delete\n";
    Mahasiswa* heap = new Mahasiswa("99002", "Uji2", 70, 70, 70);
    cout << "  nilai = " << heap->getNilai() << endl;
    cout << "  blok selesai, destructor tidak dipanggil\n";

    cout << "\n[5] LIFETIME OBJEK new DENGAN delete\n";
    Mahasiswa* heap2 = new Mahasiswa("99003", "Uji3", 70, 70, 70);
    cout << "  nilai = " << heap2->getNilai() << endl;
    delete heap2;

    cout << "\n[6] PROGRAM SELESAI, 30 objek new juga tidak dihancurkan\n";
    return 0;
}
