// Eksperimen scope dan encapsulation Program 2.
// Mengakses atribut private nim langsung dari main().
#include <iostream>
#include <string>
using namespace std;

class Mahasiswa {
private:
    string nim;
    float nilaiAkhir;
public:
    Mahasiswa(string nim, float tugas, float uts, float uas) {
        this->nim = nim;
        nilaiAkhir = 0.30 * tugas + 0.30 * uts + 0.40 * uas;
    }
    float getNilai() { return nilaiAkhir; }
};

int main() {
    Mahasiswa m("24013", 95, 92, 96);

    cout << m.getNilai() << endl; // lewat getter, public
    cout << m.nim << endl;        // langsung, sengaja error

    return 0;
}
