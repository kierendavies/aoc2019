#include <iostream>
#include <string>
#include <vector>
using namespace std;

int main() {
    vector<int> m;
    int instr;
    while (cin >> instr) {
        cin.ignore(1, ',');
        m.push_back(instr);
    }

    m[1] = 12;
    m[2] = 2;

    int pc = 0;
    while (m[pc] != 99) {
        if (m[pc] == 1) {
            m[m[pc+3]] = m[m[pc+1]] + m[m[pc+2]];
        } else if (m[pc] == 2) {
            m[m[pc+3]] = m[m[pc+1]] * m[m[pc+2]];
        }
        pc += 4;
    }

    cout << m[0] << endl;

    return 0;
}
