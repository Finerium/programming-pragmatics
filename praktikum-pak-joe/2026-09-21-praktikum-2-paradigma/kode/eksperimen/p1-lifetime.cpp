// Eksperimen lifetime Program 1.
// Menambahkan int temp; di dalam blok if lalu memakainya di luar blok.
#include <iostream>
using namespace std;

int main() {
    int a = 5;
    int b = 9;

    if (a < b) {
        int temp = a;
        a = b;
        b = temp;
        cout << "di dalam blok if, temp = " << temp << endl;
    }

    cout << "di luar blok if, temp = " << temp << endl; // sengaja error

    return 0;
}
