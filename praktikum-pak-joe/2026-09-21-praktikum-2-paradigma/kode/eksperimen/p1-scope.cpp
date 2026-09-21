// Eksperimen scope Program 1.
// Sengaja dibuat error untuk menjawab baris Scope pada Tabel Pengamatan 1:
// 1. memakai i setelah blok for
// 2. memakai variabel lokal milik hitungNilai() dari main()
#include <iostream>
using namespace std;

void hitungNilai() {
    int penghitung = 0;
    penghitung = penghitung + 1;
}

int main() {
    for (int i = 0; i < 3; i++) {
        cout << i << endl;
    }

    cout << i << endl;          // percobaan 1: i sudah keluar scope
    cout << penghitung << endl; // percobaan 2: milik hitungNilai()

    return 0;
}
